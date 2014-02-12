From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 05/14] tipc: remove 'links' list
	from tipc_bearer struct
Date: Wed, 12 Feb 2014 13:31:05 -0500
Message-ID: <1392229874-29675-6-git-send-email-jon.maloy@ericsson.com>
References: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>

In our ongoing effort to simplify the TIPC locking structure,
we see a need to remove the linked list for tipc_links
in the bearer. This can be explained as follows.

Currently, we have three different ways to access a link,
via three different lists/tables:

1: Via a node hash table:
   Used by the time-critical outgoing/incoming data paths.
   (e.g. link_send_sections_fast() and tipc_recv_msg() ):

grab net_lock(read)
   find node from node hash table
   grab node_lock
       select link
       grab bearer_lock
          send_msg()
       release bearer_lock
   release node lock
release net_lock

2: Via a global linked list for nodes:
   Used by configuration commands (link_cmd_set_value())

grab net_lock(read)
   find node and link from global node list (using link name)
   grab node_lock
       update link
   release node lock
release net_lock

(Same locking order as above. No problem.)

3: Via the bearer's linked link list:
   Used by notifications from interface (e.g. tipc_disable_bearer() )

grab net_lock(write)
   grab bearer_lock
      get link ptr from bearer's link list
      get node from link
      grab node_lock
         delete link
      release node lock
   release bearer_lock
release net_lock

(Different order from above, but works because we grab the
outer net_lock in write mode first, excluding all other access.)

The first major goal in our simplification effort is to get rid
of the "big" net_lock, replacing it with rcu-locks when accessing
the node list and node hash array. This will come in a later patch
series.

But to get there we first need to rewrite access methods ##2 and 3,
since removal of net_lock would introduce three major problems:

a) In access method #2, we access the link before taking the
   protecting node_lock. This will not work once net_lock is gone,
   so we will have to change the access order. We will deal with
   this in a later commit in this series, "tipc: add node lock
   protection to link found by link_find_link()".

b) When the outer protection from net_lock is gone, taking
   bearer_lock and node_lock in opposite order of method 1) and 2)
   will become an obvious deadlock hazard. This is fixed in the
   commit ("tipc: remove bearer_lock from tipc_bearer struct")
   later in this series.

c) Similar to what is described in problem a), access method #3
   starts with using a link pointer that is unprotected by node_lock,
   in order to via that pointer find the correct node struct and
   lock it. Before we remove net_lock, this access order must be
   altered. This is what we do with this commit.

We can avoid introducing problem problem c) by even here using the
global node list to find the node, before accessing its links. When
we loop though the node list we use the own bearer identity as search
criteria, thus easily finding the links that are associated to the
resetting/disabling bearer. It should be noted that although this
method is somewhat slower than the current list traversal, it is in
no way time critical. This is only about resetting or deleting links,
something that must be considered relatively infrequent events.

As a bonus, we can get rid of the mutual pointers between links and
bearers. After this commit, pointer dependency go in one direction
only: from the link to the bearer.

This commit pre-empts introduction of problem c) as described above.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c |    5 ++--
 net/tipc/bearer.h |    2 --
 net/tipc/core.c   |    2 +-
 net/tipc/link.c   |   68 +++++++++++++++++++----------------------------------
 net/tipc/link.h   |    8 +++----
 5 files changed, 30 insertions(+), 55 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a5be053..4931eea 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -327,7 +327,6 @@ restart:
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->active = 1;
 	b_ptr->priority = priority;
-	INIT_LIST_HEAD(&b_ptr->links);
 	spin_lock_init(&b_ptr->lock);
 
 	res = tipc_disc_create(b_ptr, &b_ptr->bcast_addr, disc_domain);
@@ -353,7 +352,7 @@ static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
 	read_lock_bh(&tipc_net_lock);
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
-	tipc_link_reset_list(b_ptr);
+	tipc_link_reset_list(b_ptr->identity);
 	spin_unlock_bh(&b_ptr->lock);
 	read_unlock_bh(&tipc_net_lock);
 	return 0;
@@ -371,7 +370,7 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
 	pr_info("Disabling bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->media->disable_media(b_ptr);
-	tipc_link_delete_list(b_ptr);
+	tipc_link_delete_list(b_ptr->identity);
 	temp_req = b_ptr->link_req;
 	b_ptr->link_req = NULL;
 	spin_unlock_bh(&b_ptr->lock);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 4f5db9a..647cb1d 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -120,7 +120,6 @@ struct tipc_media {
  * @tolerance: default link tolerance for bearer
  * @identity: array index of this bearer within TIPC bearer array
  * @link_req: ptr to (optional) structure making periodic link setup requests
- * @links: list of non-congested links associated with bearer
  * @active: non-zero if bearer structure is represents a bearer
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
  * @nodes: indicates which nodes in cluster can be reached through bearer
@@ -142,7 +141,6 @@ struct tipc_bearer {
 	u32 tolerance;
 	u32 identity;
 	struct tipc_link_req *link_req;
-	struct list_head links;
 	int active;
 	char net_plane;
 	struct tipc_node_map nodes;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index f9e88d8..3f76b98 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/core.c: TIPC module code
  *
- * Copyright (c) 2003-2006, Ericsson AB
+ * Copyright (c) 2003-2006, 2013, Ericsson AB
  * Copyright (c) 2005-2006, 2010-2013, Wind River Systems
  * All rights reserved.
  *
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2070d03..736b30c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -146,12 +146,6 @@ int tipc_link_is_active(struct tipc_link *l_ptr)
 
 /**
  * link_timeout - handle expiration of link timer
- * @l_ptr: pointer to link
- *
- * This routine must not grab "tipc_net_lock" to avoid a potential deadlock conflict
- * with tipc_link_delete().  (There is no risk that the node will be deleted by
- * another thread because tipc_link_delete() always cancels the link timer before
- * tipc_node_delete() is called.)
  */
 static void link_timeout(struct tipc_link *l_ptr)
 {
@@ -213,8 +207,8 @@ static void link_set_timer(struct tipc_link *l_ptr, u32 time)
  * Returns pointer to link.
  */
 struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
-			      struct tipc_bearer *b_ptr,
-			      const struct tipc_media_addr *media_addr)
+				   struct tipc_bearer *b_ptr,
+				   const struct tipc_media_addr *media_addr)
 {
 	struct tipc_link *l_ptr;
 	struct tipc_msg *msg;
@@ -279,47 +273,32 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	k_init_timer(&l_ptr->timer, (Handler)link_timeout,
 		     (unsigned long)l_ptr);
-	list_add_tail(&l_ptr->link_list, &b_ptr->links);
 
 	link_state_event(l_ptr, STARTING_EVT);
 
 	return l_ptr;
 }
 
-/**
- * tipc_link_delete - delete a link
- * @l_ptr: pointer to link
- *
- * Note: 'tipc_net_lock' is write_locked, bearer is locked.
- * This routine must not grab the node lock until after link timer cancellation
- * to avoid a potential deadlock situation.
- */
-void tipc_link_delete(struct tipc_link *l_ptr)
-{
-	if (!l_ptr) {
-		pr_err("Attempt to delete non-existent link\n");
-		return;
-	}
-
-	k_cancel_timer(&l_ptr->timer);
-
-	tipc_node_lock(l_ptr->owner);
-	tipc_link_reset(l_ptr);
-	tipc_node_detach_link(l_ptr->owner, l_ptr);
-	tipc_link_purge_queues(l_ptr);
-	list_del_init(&l_ptr->link_list);
-	tipc_node_unlock(l_ptr->owner);
-	k_term_timer(&l_ptr->timer);
-	kfree(l_ptr);
-}
 
-void tipc_link_delete_list(struct tipc_bearer *b_ptr)
+void tipc_link_delete_list(unsigned int bearer_id)
 {
 	struct tipc_link *l_ptr;
-	struct tipc_link *temp_l_ptr;
+	struct tipc_node *n_ptr;
+
+	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+		spin_lock_bh(&n_ptr->lock);
+		l_ptr = n_ptr->links[bearer_id];
+		if (l_ptr) {
+			tipc_link_reset(l_ptr);
+			tipc_node_detach_link(n_ptr, l_ptr);
+			spin_unlock_bh(&n_ptr->lock);
 
-	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
-		tipc_link_delete(l_ptr);
+			/* Nobody else can access this link now: */
+			del_timer_sync(&l_ptr->timer);
+			kfree(l_ptr);
+			continue;
+		}
+		spin_unlock_bh(&n_ptr->lock);
 	}
 }
 
@@ -470,15 +449,16 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	link_reset_statistics(l_ptr);
 }
 
-void tipc_link_reset_list(struct tipc_bearer *b_ptr)
+void tipc_link_reset_list(unsigned int bearer_id)
 {
 	struct tipc_link *l_ptr;
+	struct tipc_node *n_ptr;
 
-	list_for_each_entry(l_ptr, &b_ptr->links, link_list) {
-		struct tipc_node *n_ptr = l_ptr->owner;
-
+	list_for_each_entry(n_ptr, &tipc_node_list, list) {
 		spin_lock_bh(&n_ptr->lock);
-		tipc_link_reset(l_ptr);
+		l_ptr = n_ptr->links[bearer_id];
+		if (l_ptr)
+			tipc_link_reset(l_ptr);
 		spin_unlock_bh(&n_ptr->lock);
 	}
 }
diff --git a/net/tipc/link.h b/net/tipc/link.h
index a900e74..3340fc1 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -59,6 +59,7 @@
 /* Link endpoint execution states
  */
 #define LINK_STARTED    0x0001
+#define LINK_STOPPED    0x0002
 
 /* Starting value for maximum packet size negotiation on unicast links
  * (unless bearer MTU is less)
@@ -102,7 +103,6 @@ struct tipc_stats {
  * @media_addr: media address to use when sending messages over link
  * @timer: link timer
  * @owner: pointer to peer node
- * @link_list: adjacent links in bearer's list of links
  * @flags: execution state flags for link endpoint instance
  * @checkpoint: reference point for triggering link continuity checking
  * @peer_session: link session # being used by peer end of link
@@ -149,7 +149,6 @@ struct tipc_link {
 	struct tipc_media_addr media_addr;
 	struct timer_list timer;
 	struct tipc_node *owner;
-	struct list_head link_list;
 
 	/* Management and link supervision data */
 	unsigned int flags;
@@ -215,11 +214,10 @@ struct tipc_port;
 struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr);
-void tipc_link_delete(struct tipc_link *l_ptr);
+void tipc_link_delete_list(unsigned int bearer_id);
 void tipc_link_failover_send_queue(struct tipc_link *l_ptr);
 void tipc_link_dup_send_queue(struct tipc_link *l_ptr,
 			      struct tipc_link *dest);
-void tipc_link_delete_list(struct tipc_bearer *b_ptr);
 void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
@@ -232,7 +230,7 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area,
 struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
 					  int req_tlv_space);
 void tipc_link_reset(struct tipc_link *l_ptr);
-void tipc_link_reset_list(struct tipc_bearer *b_ptr);
+void tipc_link_reset_list(unsigned int bearer_id);
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector);
 void tipc_link_send_names(struct list_head *message_list, u32 dest);
 int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
