From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 07/11] tipc: purge tipc_net_lock
	lock
Date: Mon, 21 Apr 2014 10:55:48 +0800
Message-ID: <1398048952-7825-8-git-send-email-ying.xue@windriver.com>
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

Now tipc routing hierarchy comprises the structures 'node', 'link'and
'bearer'. The whole hierarchy is protected by a big read/write lock,
tipc_net_lock, to ensure that nothing is added or removed while code
is accessing any of these structures. Obviously the locking policy
makes node, link and bearer components closely bound together so that
their relationship becomes unnecessarily complex. In the worst case,
such locking policy not only has a negative influence on performance,
but also it's prone to lead to deadlock occasionally.

In order o decouple the complex relationship between bearer and node
as well as link, the locking policy is adjusted as follows:

- Bearer level
  RTNL lock is used on update side, and RCU is used on read side.
  Meanwhile, all bearer instances including broadcast bearer are
  saved into bearer_list array.

- Node and link level
  All node instances are saved into two tipc_node_list and node_htable
  lists. The two lists are protected by node_list_lock on write side,
  and they are guarded with RCU lock on read side. All members in node
  structure including link instances are protected by node spin lock.

- The relationship between bearer and node
  When link accesses bearer, it first needs to find the bearer with
  its bearer identity from the bearer_list array. When bearer accesses
  node, it can iterate the node_htable hash list with the node
  address to find the corresponding node.

In the new locking policy, every component has its private locking
solution and the relationship between bearer and node is very simple,
that is, they can find each other with node address or bearer identity
from node_htable hash list or bearer_list array.

Until now above all changes have been done, so tipc_net_lock can be
removed safely.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bcast.c      |    6 ++---
 net/tipc/bearer.c     |   31 +++++++++-----------------
 net/tipc/link.c       |   40 +++++----------------------------
 net/tipc/name_distr.c |    2 --
 net/tipc/net.c        |   59 ++++++++++++++++++++-----------------------------
 net/tipc/net.h        |    2 --
 net/tipc/node.c       |    2 --
 7 files changed, 42 insertions(+), 100 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 51dab96..0f32226 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -273,7 +273,7 @@ exit:
 /**
  * tipc_bclink_update_link_state - update broadcast link state
  *
- * tipc_net_lock and node lock set
+ * RCU and node lock set
  */
 void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 {
@@ -335,8 +335,6 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
  *
  * Delay any upcoming NACK by this node if another node has already
  * requested the first message this node is going to ask for.
- *
- * Only tipc_net_lock set.
  */
 static void bclink_peek_nack(struct tipc_msg *msg)
 {
@@ -408,7 +406,7 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 /**
  * tipc_bclink_rcv - receive a broadcast packet, and deliver upwards
  *
- * tipc_net_lock is read_locked, no other locks set
+ * RCU is locked, no other locks set
  */
 void tipc_bclink_rcv(struct sk_buff *buf)
 {
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index c24a351..1bd96eb 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -198,7 +198,6 @@ struct sk_buff *tipc_bearer_get_names(void)
 	if (!buf)
 		return NULL;
 
-	read_lock_bh(&tipc_net_lock);
 	for (i = 0; media_info_array[i] != NULL; i++) {
 		for (j = 0; j < MAX_BEARERS; j++) {
 			b = rtnl_dereference(bearer_list[j]);
@@ -211,7 +210,6 @@ struct sk_buff *tipc_bearer_get_names(void)
 			}
 		}
 	}
-	read_unlock_bh(&tipc_net_lock);
 	return buf;
 }
 
@@ -285,13 +283,11 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 		return -EINVAL;
 	}
 
-	write_lock_bh(&tipc_net_lock);
-
 	m_ptr = tipc_media_find(b_names.media_name);
 	if (!m_ptr) {
 		pr_warn("Bearer <%s> rejected, media <%s> not registered\n",
 			name, b_names.media_name);
-		goto exit;
+		return -EINVAL;
 	}
 
 	if (priority == TIPC_MEDIA_LINK_PRI)
@@ -309,14 +305,14 @@ restart:
 		if (!strcmp(name, b_ptr->name)) {
 			pr_warn("Bearer <%s> rejected, already enabled\n",
 				name);
-			goto exit;
+			return -EINVAL;
 		}
 		if ((b_ptr->priority == priority) &&
 		    (++with_this_prio > 2)) {
 			if (priority-- == 0) {
 				pr_warn("Bearer <%s> rejected, duplicate priority\n",
 					name);
-				goto exit;
+				return -EINVAL;
 			}
 			pr_warn("Bearer <%s> priority adjustment required %u->%u\n",
 				name, priority + 1, priority);
@@ -326,21 +322,20 @@ restart:
 	if (bearer_id >= MAX_BEARERS) {
 		pr_warn("Bearer <%s> rejected, bearer limit reached (%u)\n",
 			name, MAX_BEARERS);
-		goto exit;
+		return -EINVAL;
 	}
 
 	b_ptr = kzalloc(sizeof(*b_ptr), GFP_ATOMIC);
-	if (!b_ptr) {
-		res = -ENOMEM;
-		goto exit;
-	}
+	if (!b_ptr)
+		return -ENOMEM;
+
 	strcpy(b_ptr->name, name);
 	b_ptr->media = m_ptr;
 	res = m_ptr->enable_media(b_ptr);
 	if (res) {
 		pr_warn("Bearer <%s> rejected, enable failure (%d)\n",
 			name, -res);
-		goto exit;
+		return -EINVAL;
 	}
 
 	b_ptr->identity = bearer_id;
@@ -355,7 +350,7 @@ restart:
 		bearer_disable(b_ptr, false);
 		pr_warn("Bearer <%s> rejected, discovery object creation failed\n",
 			name);
-		goto exit;
+		return -EINVAL;
 	}
 
 	rcu_assign_pointer(bearer_list[bearer_id], b_ptr);
@@ -363,8 +358,6 @@ restart:
 	pr_info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 		name,
 		tipc_addr_string_fill(addr_string, disc_domain), priority);
-exit:
-	write_unlock_bh(&tipc_net_lock);
 	return res;
 }
 
@@ -373,19 +366,17 @@ exit:
  */
 static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
 {
-	read_lock_bh(&tipc_net_lock);
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
 	tipc_disc_delete(b_ptr->link_req);
 	tipc_link_reset_list(b_ptr->identity);
 	tipc_disc_create(b_ptr, &b_ptr->bcast_addr);
-	read_unlock_bh(&tipc_net_lock);
 	return 0;
 }
 
 /**
  * bearer_disable
  *
- * Note: This routine assumes caller holds tipc_net_lock.
+ * Note: This routine assumes caller holds RTNL lock.
  */
 static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down)
 {
@@ -412,7 +403,6 @@ int tipc_disable_bearer(const char *name)
 	struct tipc_bearer *b_ptr;
 	int res;
 
-	write_lock_bh(&tipc_net_lock);
 	b_ptr = tipc_bearer_find(name);
 	if (b_ptr == NULL) {
 		pr_warn("Attempt to disable unknown bearer <%s>\n", name);
@@ -421,7 +411,6 @@ int tipc_disable_bearer(const char *name)
 		bearer_disable(b_ptr, false);
 		res = 0;
 	}
-	write_unlock_bh(&tipc_net_lock);
 	return res;
 }
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 229d478..c723ee9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -835,7 +835,6 @@ int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector)
 	struct tipc_node *n_ptr;
 	int res = -ELINKCONG;
 
-	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find(dest);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
@@ -848,7 +847,6 @@ int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector)
 	} else {
 		kfree_skb(buf);
 	}
-	read_unlock_bh(&tipc_net_lock);
 	return res;
 }
 
@@ -912,7 +910,6 @@ void tipc_link_names_xmit(struct list_head *message_list, u32 dest)
 	if (list_empty(message_list))
 		return;
 
-	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find(dest);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
@@ -927,7 +924,6 @@ void tipc_link_names_xmit(struct list_head *message_list, u32 dest)
 		}
 		tipc_node_unlock(n_ptr);
 	}
-	read_unlock_bh(&tipc_net_lock);
 
 	/* discard the messages if they couldn't be sent */
 	list_for_each_safe(buf, temp_buf, ((struct sk_buff *)message_list)) {
@@ -989,7 +985,6 @@ again:
 	if (unlikely(res < 0))
 		return res;
 
-	read_lock_bh(&tipc_net_lock);
 	node = tipc_node_find(destaddr);
 	if (likely(node)) {
 		tipc_node_lock(node);
@@ -1000,7 +995,6 @@ again:
 							  &sender->max_pkt);
 exit:
 				tipc_node_unlock(node);
-				read_unlock_bh(&tipc_net_lock);
 				return res;
 			}
 
@@ -1017,7 +1011,6 @@ exit:
 			 */
 			sender->max_pkt = l_ptr->max_pkt;
 			tipc_node_unlock(node);
-			read_unlock_bh(&tipc_net_lock);
 
 
 			if ((msg_hdr_sz(hdr) + res) <= sender->max_pkt)
@@ -1028,7 +1021,6 @@ exit:
 		}
 		tipc_node_unlock(node);
 	}
-	read_unlock_bh(&tipc_net_lock);
 
 	/* Couldn't find a link to the destination node */
 	kfree_skb(buf);
@@ -1273,12 +1265,9 @@ static void link_reset_all(unsigned long addr)
 	char addr_string[16];
 	u32 i;
 
-	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find((u32)addr);
-	if (!n_ptr) {
-		read_unlock_bh(&tipc_net_lock);
+	if (!n_ptr)
 		return;	/* node no longer exists */
-	}
 
 	tipc_node_lock(n_ptr);
 
@@ -1293,7 +1282,6 @@ static void link_reset_all(unsigned long addr)
 	}
 
 	tipc_node_unlock(n_ptr);
-	read_unlock_bh(&tipc_net_lock);
 }
 
 static void link_retransmit_failure(struct tipc_link *l_ptr,
@@ -1458,7 +1446,6 @@ static int link_recv_buf_validate(struct sk_buff *buf)
  */
 void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 {
-	read_lock_bh(&tipc_net_lock);
 	while (head) {
 		struct tipc_node *n_ptr;
 		struct tipc_link *l_ptr;
@@ -1646,7 +1633,6 @@ unlock_discard:
 discard:
 		kfree_skb(buf);
 	}
-	read_unlock_bh(&tipc_net_lock);
 }
 
 /**
@@ -2408,8 +2394,6 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 /* tipc_link_find_owner - locate owner node of link by link's name
  * @name: pointer to link name string
  * @bearer_id: pointer to index in 'node->links' array where the link was found.
- * Caller must hold 'tipc_net_lock' to ensure node and bearer are not deleted;
- * this also prevents link deletion.
  *
  * Returns pointer to node owning the link, or 0 if no matching link is found.
  */
@@ -2471,7 +2455,7 @@ static int link_value_is_valid(u16 cmd, u32 new_value)
  * @new_value: new value of link, bearer, or media setting
  * @cmd: which link, bearer, or media attribute to set (TIPC_CMD_SET_LINK_*)
  *
- * Caller must hold 'tipc_net_lock' to ensure link/bearer/media is not deleted.
+ * Caller must hold RTNL lock to ensure link/bearer/media is not deleted.
  *
  * Returns 0 if value updated and negative value on error.
  */
@@ -2577,9 +2561,7 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
 						   " (cannot change setting on broadcast link)");
 	}
 
-	read_lock_bh(&tipc_net_lock);
 	res = link_cmd_set_value(args->name, new_value, cmd);
-	read_unlock_bh(&tipc_net_lock);
 	if (res)
 		return tipc_cfg_reply_error_string("cannot change link setting");
 
@@ -2613,22 +2595,18 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 			return tipc_cfg_reply_error_string("link not found");
 		return tipc_cfg_reply_none();
 	}
-	read_lock_bh(&tipc_net_lock);
 	node = tipc_link_find_owner(link_name, &bearer_id);
-	if (!node) {
-		read_unlock_bh(&tipc_net_lock);
+	if (!node)
 		return tipc_cfg_reply_error_string("link not found");
-	}
+
 	tipc_node_lock(node);
 	l_ptr = node->links[bearer_id];
 	if (!l_ptr) {
 		tipc_node_unlock(node);
-		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string("link not found");
 	}
 	link_reset_statistics(l_ptr);
 	tipc_node_unlock(node);
-	read_unlock_bh(&tipc_net_lock);
 	return tipc_cfg_reply_none();
 }
 
@@ -2661,18 +2639,15 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 	if (!strcmp(name, tipc_bclink_name))
 		return tipc_bclink_stats(buf, buf_size);
 
-	read_lock_bh(&tipc_net_lock);
 	node = tipc_link_find_owner(name, &bearer_id);
-	if (!node) {
-		read_unlock_bh(&tipc_net_lock);
+	if (!node)
 		return 0;
-	}
+
 	tipc_node_lock(node);
 
 	l = node->links[bearer_id];
 	if (!l) {
 		tipc_node_unlock(node);
-		read_unlock_bh(&tipc_net_lock);
 		return 0;
 	}
 
@@ -2738,7 +2713,6 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
 
 	tipc_node_unlock(node);
-	read_unlock_bh(&tipc_net_lock);
 	return ret;
 }
 
@@ -2789,7 +2763,6 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 	if (dest == tipc_own_addr)
 		return MAX_MSG_SIZE;
 
-	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find(dest);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
@@ -2798,7 +2771,6 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 			res = l_ptr->max_pkt;
 		tipc_node_unlock(n_ptr);
 	}
-	read_unlock_bh(&tipc_net_lock);
 	return res;
 }
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index aff8041..36a7282 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -248,7 +248,6 @@ void tipc_named_node_up(unsigned long nodearg)
 	u32 max_item_buf = 0;
 
 	/* compute maximum amount of publication data to send per message */
-	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find(node);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
@@ -258,7 +257,6 @@ void tipc_named_node_up(unsigned long nodearg)
 				ITEM_SIZE) * ITEM_SIZE;
 		tipc_node_unlock(n_ptr);
 	}
-	read_unlock_bh(&tipc_net_lock);
 	if (!max_item_buf)
 		return;
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 24d2d21..75bb390 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -45,39 +45,34 @@
 /*
  * The TIPC locking policy is designed to ensure a very fine locking
  * granularity, permitting complete parallel access to individual
- * port and node/link instances. The code consists of three major
+ * port and node/link instances. The code consists of four major
  * locking domains, each protected with their own disjunct set of locks.
  *
- * 1: The routing hierarchy.
- *    Comprises the structures 'zone', 'cluster', 'node', 'link'
- *    and 'bearer'. The whole hierarchy is protected by a big
- *    read/write lock, tipc_net_lock, to enssure that nothing is added
- *    or removed while code is accessing any of these structures.
- *    This layer must not be called from the two others while they
- *    hold any of their own locks.
- *    Neither must it itself do any upcalls to the other two before
- *    it has released tipc_net_lock and other protective locks.
+ * 1: The bearer level.
+ *    RTNL lock is used to serialize the process of configuring bearer
+ *    on update side, and RCU lock is applied on read side to make
+ *    bearer instance valid on both paths of message transmission and
+ *    reception.
  *
- *   Within the tipc_net_lock domain there are two sub-domains;'node' and
- *   'bearer', where local write operations are permitted,
- *   provided that those are protected by individual spin_locks
- *   per instance. Code holding tipc_net_lock(read) and a node spin_lock
- *   is permitted to poke around in both the node itself and its
- *   subordinate links. I.e, it can update link counters and queues,
- *   change link state, send protocol messages, and alter the
- *   "active_links" array in the node; but it can _not_ remove a link
- *   or a node from the overall structure.
- *   Correspondingly, individual bearers may change status within a
- *   tipc_net_lock(read), protected by an individual spin_lock ber bearer
- *   instance, but it needs tipc_net_lock(write) to remove/add any bearers.
+ * 2: The node and link level.
+ *    All node instances are saved into two tipc_node_list and node_htable
+ *    lists. The two lists are protected by node_list_lock on write side,
+ *    and they are guarded with RCU lock on read side. Especially node
+ *    instance is destroyed only when TIPC module is removed, and we can
+ *    confirm that there has no any user who is accessing the node at the
+ *    moment. Therefore, Except for iterating the two lists within RCU
+ *    protection, it's no needed to hold RCU that we access node instance
+ *    in other places.
  *
+ *    In addition, all members in node structure including link instances
+ *    are protected by node spin lock.
  *
- *  2: The transport level of the protocol.
- *     This consists of the structures port, (and its user level
- *     representations, such as user_port and tipc_sock), reference and
- *     tipc_user (port.c, reg.c, socket.c).
+ * 3: The transport level of the protocol.
+ *    This consists of the structures port, (and its user level
+ *    representations, such as user_port and tipc_sock), reference and
+ *    tipc_user (port.c, reg.c, socket.c).
  *
- *     This layer has four different locks:
+ *    This layer has four different locks:
  *     - The tipc_port spin_lock. This is protecting each port instance
  *       from parallel data access and removal. Since we can not place
  *       this lock in the port itself, it has been placed in the
@@ -96,7 +91,7 @@
  *       There are two such lists; 'port_list', which is used for management,
  *       and 'wait_list', which is used to queue ports during congestion.
  *
- *  3: The name table (name_table.c, name_distr.c, subscription.c)
+ *  4: The name table (name_table.c, name_distr.c, subscription.c)
  *     - There is one big read/write-lock (tipc_nametbl_lock) protecting the
  *       overall name table structure. Nothing must be added/removed to
  *       this structure without holding write access to it.
@@ -108,8 +103,6 @@
  *     - A local spin_lock protecting the queue of subscriber events.
 */
 
-DEFINE_RWLOCK(tipc_net_lock);
-
 static void net_route_named_msg(struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
@@ -175,15 +168,13 @@ void tipc_net_start(u32 addr)
 {
 	char addr_string[16];
 
-	write_lock_bh(&tipc_net_lock);
 	tipc_own_addr = addr;
 	tipc_named_reinit();
 	tipc_port_reinit();
 	tipc_bclink_init();
-	write_unlock_bh(&tipc_net_lock);
-
 	tipc_nametbl_publish(TIPC_CFG_SRV, tipc_own_addr, tipc_own_addr,
 			     TIPC_ZONE_SCOPE, 0, tipc_own_addr);
+
 	pr_info("Started in network mode\n");
 	pr_info("Own node address %s, network identity %u\n",
 		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
@@ -196,11 +187,9 @@ void tipc_net_stop(void)
 
 	tipc_nametbl_withdraw(TIPC_CFG_SRV, tipc_own_addr, 0, tipc_own_addr);
 	rtnl_lock();
-	write_lock_bh(&tipc_net_lock);
 	tipc_bearer_stop();
 	tipc_bclink_stop();
 	tipc_node_stop();
-	write_unlock_bh(&tipc_net_lock);
 	rtnl_unlock();
 
 	pr_info("Left network mode\n");
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 079daad..f781cae 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -37,8 +37,6 @@
 #ifndef _TIPC_NET_H
 #define _TIPC_NET_H
 
-extern rwlock_t tipc_net_lock;
-
 void tipc_net_route_msg(struct sk_buff *buf);
 
 void tipc_net_start(u32 addr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index fa6823f..be90115 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -273,14 +273,12 @@ static void node_name_purge_complete(unsigned long node_addr)
 {
 	struct tipc_node *n_ptr;
 
-	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find(node_addr);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
 		n_ptr->block_setup &= ~WAIT_NAMES_GONE;
 		tipc_node_unlock(n_ptr);
 	}
-	read_unlock_bh(&tipc_net_lock);
 }
 
 static void node_lost_contact(struct tipc_node *n_ptr)
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
