From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 3/5] SUNRPC: make RPC service dependable on rpcbind clients
	creation
Date: Wed, 24 Aug 2011 22:33:59 +0400
Message-ID: <20110824183359.4924.94364.stgit@localhost6.localdomain6>
References: <20110824183304.4924.94670.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110824183304.4924.94670.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We create or increase users counter of rcbind clients during RPC service
creation and decrease this counter (and possibly destroy those clients) on RPC
service destruction.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/rpcb_clnt.c      |    2 +-
 net/sunrpc/svc.c            |    5 +++++
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index db7bcaf..65a8115 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -135,10 +135,12 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
 
+int		rpcb_create_local(void);
 int		rpcb_register(u32, u32, int, unsigned short);
 int		rpcb_v4_register(const u32 program, const u32 version,
 				 const struct sockaddr *address,
 				 const char *netid);
+void		rpcb_put_local(void);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_start(struct rpc_task *);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index b4cc0f1..437ec60 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -318,7 +318,7 @@ out:
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-static int rpcb_create_local(void)
+int rpcb_create_local(void)
 {
 	static DEFINE_MUTEX(rpcb_create_local_mutex);
 	int result = 0;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6a69a11..0df8532 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -367,6 +367,9 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	unsigned int xdrsize;
 	unsigned int i;
 
+	if (rpcb_create_local() < 0)
+		return NULL;
+
 	if (!(serv = kzalloc(sizeof(*serv), GFP_KERNEL)))
 		return NULL;
 	serv->sv_name      = prog->pg_name;
@@ -491,6 +494,8 @@ svc_destroy(struct svc_serv *serv)
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
+
+	rpcb_put_local();
 }
 EXPORT_SYMBOL_GPL(svc_destroy);
 
