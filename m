From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 04/16] sunrpc: tag svc_serv with rpc_pipefs mount point
Date: Fri, 14 Jan 2011 15:49:02 +0200
Message-ID: <1295012954-7769-5-git-send-email-kas@openvz.org>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1295012954-7769-1-git-send-email-kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Kirill A. Shutemov <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index c81d4d8..534ea8e 100644
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
index 0e659c6..8cc6e79 100644
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
@@ -488,6 +491,7 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
+	mntput(serv->sv_rpcmount);
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
-- 
1.7.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
