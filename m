From: Mikael Pettersson <mikpe@csd.uu.se>
Subject: [PATCH][2.6.8-rc1-mm1] net/sunrpc/xprt.c gcc341 inlining fix
Date: Wed, 14 Jul 2004 14:17:25 +0200 (MEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200407141217.i6ECHPT3008341@harpo.it.uu.se>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267371AbUGNMS2@vger.kernel.org>
To: akpm@osdl.org
List-Id: netdev.vger.kernel.org

gcc-3.4.1 errors out in 2.6.8-rc1-mm1 at net/sunrpc/xprt.c:

net/sunrpc/xprt.c: In function `xprt_reserve':
net/sunrpc/xprt.c:84: sorry, unimplemented: inlining failed in call to 'do_xprt_reserve': function body not available
net/sunrpc/xprt.c:1307: sorry, unimplemented: called from here
make[2]: *** [net/sunrpc/xprt.o] Error 1
make[1]: *** [net/sunrpc] Error 2
make: *** [net] Error 2

do_xprt_reserve() is marked inline but used defore its function
body is available. Moving it before its only caller fixes the problem.

Signed-off-by: Mikael Pettersson <mikpe@csd.uu.se>

--- linux-2.6.8-rc1-mm1/net/sunrpc/xprt.c.~1~	2004-07-14 12:58:35.000000000 +0200
+++ linux-2.6.8-rc1-mm1/net/sunrpc/xprt.c	2004-07-14 13:47:46.000000000 +0200
@@ -1296,21 +1296,6 @@
 /*
  * Reserve an RPC call slot.
  */
-void
-xprt_reserve(struct rpc_task *task)
-{
-	struct rpc_xprt	*xprt = task->tk_xprt;
-
-	task->tk_status = -EIO;
-	if (!xprt->shutdown) {
-		spin_lock(&xprt->xprt_lock);
-		do_xprt_reserve(task);
-		spin_unlock(&xprt->xprt_lock);
-		if (task->tk_rqstp)
-			del_timer_sync(&xprt->timer);
-	}
-}
-
 static inline void
 do_xprt_reserve(struct rpc_task *task)
 {
@@ -1332,6 +1317,21 @@
 	rpc_sleep_on(&xprt->backlog, task, NULL, NULL);
 }
 
+void
+xprt_reserve(struct rpc_task *task)
+{
+	struct rpc_xprt	*xprt = task->tk_xprt;
+
+	task->tk_status = -EIO;
+	if (!xprt->shutdown) {
+		spin_lock(&xprt->xprt_lock);
+		do_xprt_reserve(task);
+		spin_unlock(&xprt->xprt_lock);
+		if (task->tk_rqstp)
+			del_timer_sync(&xprt->timer);
+	}
+}
+
 /*
  * Allocate a 'unique' XID
  */
