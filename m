From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 4/7] SUNRPC: parametrize local rpcbind clients creation with
 net ns
Date: Thu, 15 Dec 2011 20:00:15 +0300
Message-ID: <20111215160015.2434.2579.stgit@localhost6.localdomain6>
References: <20111215155252.2434.39434.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111215155252.2434.39434.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These client are per network namespace and thus can be created for different
network namespaces.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/clnt.h |    4 ++--
 net/sunrpc/rpcb_clnt.c      |    7 +++----
 net/sunrpc/svc.c            |    4 ++--
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 1e56469..5748807 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -136,8 +136,8 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
 
-int		rpcb_create_local(void);
-void		rpcb_put_local(void);
+int		rpcb_create_local(struct net *);
+void		rpcb_put_local(struct net *);
 int		rpcb_register(struct net *, u32, u32, int, unsigned short);
 int		rpcb_v4_register(struct net *net, const u32 program,
 				 const u32 version,
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d94f188..4ce3a8e 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -175,9 +175,9 @@ static int rpcb_get_local(struct net *net)
 	return cnt;
 }
 
-void rpcb_put_local(void)
+void rpcb_put_local(struct net *net)
 {
-	struct sunrpc_net *sn = net_generic(&init_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct rpc_clnt *clnt = sn->rpcb_local_clnt;
 	struct rpc_clnt *clnt4 = sn->rpcb_local_clnt4;
 	int shutdown;
@@ -323,11 +323,10 @@ out:
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-int rpcb_create_local(void)
+int rpcb_create_local(struct net *net)
 {
 	static DEFINE_MUTEX(rpcb_create_local_mutex);
 	int result = 0;
-	struct net *net = &init_net;
 
 	if (rpcb_get_local(net))
 		return result;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e9c42ad..03e9f04 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -370,7 +370,7 @@ static int svc_rpcb_setup(struct svc_serv *serv)
 {
 	int err;
 
-	err = rpcb_create_local();
+	err = rpcb_create_local(&init_net);
 	if (err)
 		return err;
 
@@ -382,7 +382,7 @@ static int svc_rpcb_setup(struct svc_serv *serv)
 void svc_rpcb_cleanup(struct svc_serv *serv)
 {
 	svc_unregister(serv);
-	rpcb_put_local();
+	rpcb_put_local(&init_net);
 }
 EXPORT_SYMBOL_GPL(svc_rpcb_cleanup);
 
