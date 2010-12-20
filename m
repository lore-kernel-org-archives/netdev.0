From: "Kirill A. Shutsemov" <kirill@shutemov.name>
Subject: [PATCH 04/12] sunrpc: tag svc_serv with rpc_pipefs mount point
Date: Mon, 20 Dec 2010 13:54:30 +0200
Message-ID: <1292846078-31793-5-git-send-email-kirill@shutemov.name>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill@shutemov.name>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill A. Shutemov <kirill@shutemov.name>

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..3b6b26c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -64,6 +64,7 @@ struct svc_pool {
  */
 struct svc_serv {
 	struct svc_program *	sv_program;	/* RPC program */
+	struct vfsmount *	sv_rpcmount;	/* rpc_pipefs mount point*/
 	struct svc_stat *	sv_stats;	/* RPC statistics */
 	spinlock_t		sv_lock;
 	unsigned int		sv_nrthreads;	/* # of server threads */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6359c42..d2f7c03 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/kthread.h>
 #include <linux/slab.h>
+#include <linux/mount.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -27,6 +28,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
@@ -371,6 +373,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		return NULL;
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
+	serv->sv_rpcmount  = mntget(init_rpc_pipefs);
 	serv->sv_nrthreads = 1;
 	serv->sv_stats     = prog->pg_stats;
 	if (bufsize > RPCSVC_MAXPAYLOAD)
@@ -492,6 +495,7 @@ svc_destroy(struct svc_serv *serv)
 	svc_sock_destroy(serv->bc_xprt);
 #endif /* CONFIG_NFS_V4_1 */
 
+	mntput(serv->sv_rpcmount);
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
-- 
1.7.3.4
