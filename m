From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v6 6/8] NFSd: call svc rpcbind cleanup explicitly
Date: Tue, 25 Oct 2011 14:17:28 +0300
Message-ID: <20111025101725.12689.17164.stgit@localhost6.localdomain6>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have to call svc_rpcb_cleanup() explicitly from nfsd_last_thread() since
this function is registered as service shutdown callback and thus nobody else
will done it for us.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfssvc.c           |    2 ++
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    3 ++-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index dc5a1bf..52cd976 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -256,6 +256,8 @@ static void nfsd_last_thread(struct svc_serv *serv)
 	nfsd_serv = NULL;
 	nfsd_shutdown();
 
+	svc_rpcb_cleanup(serv);
+
 	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
 			    "cache\n");
 	nfsd_export_flush();
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 223588a..5e71a30 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -401,6 +401,7 @@ struct svc_procedure {
 /*
  * Function prototypes.
  */
+void svc_rpcb_cleanup(struct svc_serv *serv);
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
 			    void (*shutdown)(struct svc_serv *));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 407462f..252552a 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -367,11 +367,12 @@ static int svc_rpcb_setup(struct svc_serv *serv)
 	return 0;
 }
 
-static void svc_rpcb_cleanup(struct svc_serv *serv)
+void svc_rpcb_cleanup(struct svc_serv *serv)
 {
 	svc_unregister(serv);
 	rpcb_put_local();
 }
+EXPORT_SYMBOL_GPL(svc_rpcb_cleanup);
 
 static int svc_uses_rpcbind(struct svc_serv *serv)
 {
