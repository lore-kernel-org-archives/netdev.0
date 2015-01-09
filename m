From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 15/16] tipc: make tipc random
	value aware of net namespace
Date: Fri, 9 Jan 2015 15:27:12 +0800
Message-ID: <1420788433-17960-16-git-send-email-ying.xue@windriver.com>
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

After namespace is supported, each namespace should own its private
random value. So the global variable representing the random value
must be moved to tipc_net structure.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/core.c     |    6 +-----
 net/tipc/core.h     |    6 +-----
 net/tipc/discover.c |    2 +-
 net/tipc/link.c     |    2 +-
 4 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 4a8b795..674bd26 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -44,9 +44,6 @@
 
 #include <linux/module.h>
 
-/* global variables used by multiple sub-systems within TIPC */
-int tipc_random __read_mostly;
-
 /* configurable TIPC parameters */
 int tipc_net_id __read_mostly;
 int sysctl_tipc_rmem[3] __read_mostly;	/* min/default/max */
@@ -58,6 +55,7 @@ static int __net_init tipc_init_net(struct net *net)
 
 	tn->net_id = 4711;
 	tn->own_addr = 0;
+	get_random_bytes(&tn->random, sizeof(int));
 	INIT_LIST_HEAD(&tn->node_list);
 	spin_lock_init(&tn->node_list_lock);
 
@@ -109,8 +107,6 @@ static int __init tipc_init(void)
 			      TIPC_CRITICAL_IMPORTANCE;
 	sysctl_tipc_rmem[2] = TIPC_CONN_OVERLOAD_LIMIT;
 
-	get_random_bytes(&tipc_random, sizeof(tipc_random));
-
 	err = tipc_netlink_start();
 	if (err)
 		goto out_netlink;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 639f562..817b2e9 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -76,14 +76,10 @@ extern int tipc_net_id __read_mostly;
 extern int sysctl_tipc_rmem[3] __read_mostly;
 extern int sysctl_tipc_named_timeout __read_mostly;
 
-/*
- * Other global variables
- */
-extern int tipc_random __read_mostly;
-
 struct tipc_net {
 	u32 own_addr;
 	int net_id;
+	int random;
 
 	/* Node table and node list */
 	spinlock_t node_list_lock;
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 786411d..5b40cb8 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -88,7 +88,7 @@ static void tipc_disc_init_msg(struct net *net, struct sk_buff *buf, u32 type,
 	msg = buf_msg(buf);
 	tipc_msg_init(net, msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
 	msg_set_non_seq(msg, 1);
-	msg_set_node_sig(msg, tipc_random);
+	msg_set_node_sig(msg, tn->random);
 	msg_set_dest_domain(msg, dest_domain);
 	msg_set_bc_netid(msg, tn->net_id);
 	b_ptr->media->addr2msg(msg_media_addr(msg), &b_ptr->addr);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9972567..193bc15 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -289,7 +289,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	tipc_msg_init(n_ptr->net, msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE,
 		      l_ptr->addr);
 	msg_set_size(msg, sizeof(l_ptr->proto_msg));
-	msg_set_session(msg, (tipc_random & 0xffff));
+	msg_set_session(msg, (tn->random & 0xffff));
 	msg_set_bearer_id(msg, b_ptr->identity);
 	strcpy((char *)msg_data(msg), if_name);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
