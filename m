From: domen@coderock.org
Subject: [patch 5/5] net/clnt: remove sleep_on*() usage
Date: Sun, 06 Mar 2005 23:21:21 +0100
Message-ID: <20050306222121.7D8791EFA4@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com
To: davem@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Directly use wait-queues instead of the deprecated
sleep_on_timeout(). Since the sleep in this function is unconditional,
wait_event_timeout() does not appear to be appropriate. Patch is
compile-tested.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/net/sunrpc/clnt.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff -puN net/sunrpc/clnt.c~sleep_on-net_sunrpc_clnt net/sunrpc/clnt.c
--- kj/net/sunrpc/clnt.c~sleep_on-net_sunrpc_clnt	2005-03-05 16:13:14.000000000 +0100
+++ kj-domen/net/sunrpc/clnt.c	2005-03-05 16:13:14.000000000 +0100
@@ -28,6 +28,7 @@
 #include <linux/slab.h>
 #include <linux/in.h>
 #include <linux/utsname.h>
+#include <linux/wait.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/workqueue.h>
@@ -222,6 +223,7 @@ out_no_clnt:
 int
 rpc_shutdown_client(struct rpc_clnt *clnt)
 {
+	DEFINE_WAIT(wait);
 	dprintk("RPC: shutting down %s client for %s, tasks=%d\n",
 			clnt->cl_protname, clnt->cl_server,
 			atomic_read(&clnt->cl_users));
@@ -231,7 +233,9 @@ rpc_shutdown_client(struct rpc_clnt *cln
 		clnt->cl_oneshot = 0;
 		clnt->cl_dead = 0;
 		rpc_killall_tasks(clnt);
-		sleep_on_timeout(&destroy_wait, 1*HZ);
+		prepare_to_wait(&destroy_wait, &wait, TASK_UNINTERRUPTIBLE);
+		schedule_timeout(HZ);
+		finish_wait(&destroy_wait, &wait);
 	}
 
 	if (atomic_read(&clnt->cl_users) < 0) {
_
