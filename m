From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 04/11] tipc: convert bearer_list
	to RCU list
Date: Mon, 21 Apr 2014 10:55:45 +0800
Message-ID: <1398048952-7825-5-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert bearer_list to RCU list. It's protected by RTNL lock on
update side, and RCU read lock is applied to read side.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bcast.c  |    9 ++++++---
 net/tipc/bearer.c |   18 +++++++++---------
 net/tipc/bearer.h |    4 +++-
 3 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 95ab5ef..223a199 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -659,6 +659,7 @@ void tipc_bcbearer_sort(void)
 {
 	struct tipc_bcbearer_pair *bp_temp = bcbearer->bpairs_temp;
 	struct tipc_bcbearer_pair *bp_curr;
+	struct tipc_bearer *b;
 	int b_index;
 	int pri;
 
@@ -667,8 +668,9 @@ void tipc_bcbearer_sort(void)
 	/* Group bearers by priority (can assume max of two per priority) */
 	memset(bp_temp, 0, sizeof(bcbearer->bpairs_temp));
 
+	rcu_read_lock();
 	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
-		struct tipc_bearer *b = bearer_list[b_index];
+		b = rcu_dereference_rtnl(bearer_list[b_index]);
 		if (!b || !b->nodes.count)
 			continue;
 
@@ -677,6 +679,7 @@ void tipc_bcbearer_sort(void)
 		else
 			bp_temp[b->priority].secondary = b;
 	}
+	rcu_read_unlock();
 
 	/* Create array of bearer pairs for broadcasting */
 	bp_curr = bcbearer->bpairs;
@@ -784,7 +787,7 @@ void tipc_bclink_init(void)
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
 	bcl->b_ptr = &bcbearer->bearer;
-	bearer_list[BCBEARER] = &bcbearer->bearer;
+	rcu_assign_pointer(bearer_list[MAX_BEARERS], &bcbearer->bearer);
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 }
@@ -795,7 +798,7 @@ void tipc_bclink_stop(void)
 	tipc_link_purge_queues(bcl);
 	spin_unlock_bh(&bc_lock);
 
-	bearer_list[BCBEARER] = NULL;
+	RCU_INIT_POINTER(bearer_list[BCBEARER], NULL);
 	memset(bclink, 0, sizeof(*bclink));
 	memset(bcbearer, 0, sizeof(*bcbearer));
 }
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index dfb4c7f..65b1763 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -49,7 +49,7 @@ static struct tipc_media * const media_info_array[] = {
 	NULL
 };
 
-struct tipc_bearer *bearer_list[MAX_BEARERS + 1];
+struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
 
 static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down);
 
@@ -178,7 +178,7 @@ struct tipc_bearer *tipc_bearer_find(const char *name)
 	u32 i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		b_ptr = bearer_list[i];
+		b_ptr = rtnl_dereference(bearer_list[i]);
 		if (b_ptr && (!strcmp(b_ptr->name, name)))
 			return b_ptr;
 	}
@@ -201,7 +201,7 @@ struct sk_buff *tipc_bearer_get_names(void)
 	read_lock_bh(&tipc_net_lock);
 	for (i = 0; media_info_array[i] != NULL; i++) {
 		for (j = 0; j < MAX_BEARERS; j++) {
-			b = bearer_list[j];
+			b = rtnl_dereference(bearer_list[j]);
 			if (!b)
 				continue;
 			if (b->media == media_info_array[i]) {
@@ -287,7 +287,7 @@ restart:
 	bearer_id = MAX_BEARERS;
 	with_this_prio = 1;
 	for (i = MAX_BEARERS; i-- != 0; ) {
-		b_ptr = bearer_list[i];
+		b_ptr = rtnl_dereference(bearer_list[i]);
 		if (!b_ptr) {
 			bearer_id = i;
 			continue;
@@ -344,7 +344,7 @@ restart:
 		goto exit;
 	}
 
-	bearer_list[bearer_id] = b_ptr;
+	rcu_assign_pointer(bearer_list[bearer_id], b_ptr);
 
 	pr_info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 		name,
@@ -385,12 +385,12 @@ static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down)
 		tipc_disc_delete(b_ptr->link_req);
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		if (b_ptr == bearer_list[i]) {
-			bearer_list[i] = NULL;
+		if (b_ptr == rtnl_dereference(bearer_list[i])) {
+			RCU_INIT_POINTER(bearer_list[i], NULL);
 			break;
 		}
 	}
-	kfree(b_ptr);
+	kfree_rcu(b_ptr, rcu);
 }
 
 int tipc_disable_bearer(const char *name)
@@ -628,7 +628,7 @@ void tipc_bearer_stop(void)
 	u32 i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		b_ptr = bearer_list[i];
+		b_ptr = rtnl_dereference(bearer_list[i]);
 		if (b_ptr) {
 			bearer_disable(b_ptr, true);
 			bearer_list[i] = NULL;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index ba48145..b67b7ea 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -113,6 +113,7 @@ struct tipc_media {
  * @name: bearer name (format = media:interface)
  * @media: ptr to media structure associated with bearer
  * @bcast_addr: media address used in broadcasting
+ * @rcu: rcu struct for tipc_bearer
  * @priority: default link priority for bearer
  * @window: default window size for bearer
  * @tolerance: default link tolerance for bearer
@@ -133,6 +134,7 @@ struct tipc_bearer {
 	char name[TIPC_MAX_BEARER_NAME];
 	struct tipc_media *media;
 	struct tipc_media_addr bcast_addr;
+	struct rcu_head rcu;
 	u32 priority;
 	u32 window;
 	u32 tolerance;
@@ -150,7 +152,7 @@ struct tipc_bearer_names {
 
 struct tipc_link;
 
-extern struct tipc_bearer *bearer_list[];
+extern struct tipc_bearer __rcu *bearer_list[];
 
 /*
  * TIPC routines available to supported media types
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
