From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 02/16] tipc: remove
	tipc_core_start/stop routines
Date: Fri, 9 Jan 2015 15:26:59 +0800
Message-ID: <1420788433-17960-3-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Remove redundant wrapper functions like tipc_core_start() and
tipc_core_stop(), and directly move them to their callers, such
as tipc_init() and tipc_exit(), having us clearly know what are
really done in both initialization and deinitialzation functions.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/core.c |   66 +++++++++++++++++++------------------------------------
 1 file changed, 23 insertions(+), 43 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 71b2ada..10bc0bf 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -75,28 +75,21 @@ struct sk_buff *tipc_buf_acquire(u32 size)
 	return skb;
 }
 
-/**
- * tipc_core_stop - switch TIPC from SINGLE NODE to NOT RUNNING mode
- */
-static void tipc_core_stop(void)
-{
-	tipc_net_stop();
-	tipc_bearer_cleanup();
-	tipc_netlink_stop();
-	tipc_subscr_stop();
-	tipc_nametbl_stop();
-	tipc_socket_stop();
-	tipc_unregister_sysctl();
-	tipc_sk_rht_destroy();
-}
-
-/**
- * tipc_core_start - switch TIPC from NOT RUNNING to SINGLE NODE mode
- */
-static int tipc_core_start(void)
+static int __init tipc_init(void)
 {
 	int err;
 
+	pr_info("Activated (version " TIPC_MOD_VER ")\n");
+
+	tipc_own_addr = 0;
+	tipc_net_id = 4711;
+
+	sysctl_tipc_rmem[0] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
+			      TIPC_LOW_IMPORTANCE;
+	sysctl_tipc_rmem[1] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
+			      TIPC_CRITICAL_IMPORTANCE;
+	sysctl_tipc_rmem[2] = TIPC_CONN_OVERLOAD_LIMIT;
+
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
 
 	err = tipc_sk_rht_init();
@@ -127,6 +120,7 @@ static int tipc_core_start(void)
 	if (err)
 		goto out_bearer;
 
+	pr_info("Started in single node mode\n");
 	return 0;
 out_bearer:
 	tipc_subscr_stop();
@@ -141,35 +135,21 @@ out_netlink:
 out_nametbl:
 	tipc_sk_rht_destroy();
 out_reftbl:
+	pr_err("Unable to start in single node mode\n");
 	return err;
 }
 
-static int __init tipc_init(void)
-{
-	int res;
-
-	pr_info("Activated (version " TIPC_MOD_VER ")\n");
-
-	tipc_own_addr = 0;
-	tipc_net_id = 4711;
-
-	sysctl_tipc_rmem[0] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
-			      TIPC_LOW_IMPORTANCE;
-	sysctl_tipc_rmem[1] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
-			      TIPC_CRITICAL_IMPORTANCE;
-	sysctl_tipc_rmem[2] = TIPC_CONN_OVERLOAD_LIMIT;
-
-	res = tipc_core_start();
-	if (res)
-		pr_err("Unable to start in single node mode\n");
-	else
-		pr_info("Started in single node mode\n");
-	return res;
-}
-
 static void __exit tipc_exit(void)
 {
-	tipc_core_stop();
+	tipc_net_stop();
+	tipc_bearer_cleanup();
+	tipc_netlink_stop();
+	tipc_subscr_stop();
+	tipc_nametbl_stop();
+	tipc_socket_stop();
+	tipc_unregister_sysctl();
+	tipc_sk_rht_destroy();
+
 	pr_info("Deactivated\n");
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
