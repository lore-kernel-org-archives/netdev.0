From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.6 patch] net/sunrpc/xprt.c: fix inline problem
Date: Sat, 10 Jul 2004 03:17:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040710011732.GY28324@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trying to compile net/sunrpc/xprt.c with gcc 3.4 and
  # define inline         __inline__ __attribute__((always_inline))
results in the following error:

<--  snip  -->

...
  CC      net/sunrpc/xprt.o
net/sunrpc/xprt.c: In function `xprt_reserve':
net/sunrpc/xprt.c:84: sorry, unimplemented: inlining failed in call to 
'do_xprt_reserve': function body not available
net/sunrpc/xprt.c:1307: sorry, unimplemented: called from here
make[2]: *** [net/sunrpc/xprt.o] Error 1

<--  snip  -->


The patch below moves the inline function in front of its' (only) 
caller.

diffstat output:
 net/sunrpc/xprt.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)


Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

--- linux-2.6.7-mm7-full-gcc3.4/net/sunrpc/xprt.c.old	2004-07-10 03:07:17.000000000 +0200
+++ linux-2.6.7-mm7-full-gcc3.4/net/sunrpc/xprt.c	2004-07-10 03:09:36.000000000 +0200
@@ -1293,24 +1293,6 @@
 	spin_unlock_bh(&xprt->sock_lock);
 }
 
-/*
- * Reserve an RPC call slot.
- */
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
@@ -1333,6 +1315,24 @@
 }
 
 /*
+ * Reserve an RPC call slot.
+ */
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
+/*
  * Allocate a 'unique' XID
  */
 static inline u32 xprt_alloc_xid(struct rpc_xprt *xprt)
