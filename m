From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/4] tipc: add reference count to
	struct tipc_link
Date: Tue,  3 Feb 2015 08:59:17 -0500
Message-ID: <1422971960-9172-2-git-send-email-jon.maloy@ericsson.com>
References: <1422971960-9172-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1422971960-9172-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a bearer is disabled, all pertaining links will be reset and
deleted. However, if there is a second active link towards a killed
link's destination, the delete has to be postponed until the failover
is finished. During this interval, we currently put the link in zombie
mode, i.e., we take it out of traffic, delete its timer, but leave it
attached to the owner node structure until all missing packets have
been received.  When this is done, we detach the link from its node
and delete it, assuming that the synchronous timer deletion that was
initiated earlier in a different thread has finished.

This is unsafe, as the failover may finish before del_timer_sync()
has returned in the other thread.

We fix this by adding an atomic reference counter of type kref in
struct tipc_link. The counter keeps track of the references kept
to the link by the owner node and the timer. We then do a conditional
delete, based on the reference counter, both after the failover has
been finished and when the timer expires, if applicable. Whoever
comes last, will actually delete the link. This approach also implies
that we can make the deletion of the timer asynchronous.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 79 +++++++++++++++++++++++++++++++++++----------------------
 net/tipc/link.h |  2 ++
 2 files changed, 50 insertions(+), 31 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2846ad80..46aa599 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -127,6 +127,21 @@ static unsigned int align(unsigned int i)
 	return (i + 3) & ~3u;
 }
 
+static void tipc_link_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tipc_link, ref));
+}
+
+static void tipc_link_get(struct tipc_link *l_ptr)
+{
+	kref_get(&l_ptr->ref);
+}
+
+static void tipc_link_put(struct tipc_link *l_ptr)
+{
+	kref_put(&l_ptr->ref, tipc_link_release);
+}
+
 static void link_init_max_pkt(struct tipc_link *l_ptr)
 {
 	struct tipc_node *node = l_ptr->owner;
@@ -222,11 +237,13 @@ static void link_timeout(unsigned long data)
 		tipc_link_push_packets(l_ptr);
 
 	tipc_node_unlock(l_ptr->owner);
+	tipc_link_put(l_ptr);
 }
 
 static void link_set_timer(struct tipc_link *link, unsigned long time)
 {
-	mod_timer(&link->timer, jiffies + time);
+	if (!mod_timer(&link->timer, jiffies + time))
+		tipc_link_get(link);
 }
 
 /**
@@ -267,7 +284,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 		pr_warn("Link creation failed, no memory\n");
 		return NULL;
 	}
-
+	kref_init(&l_ptr->ref);
 	l_ptr->addr = peer;
 	if_name = strchr(b_ptr->name, ':') + 1;
 	sprintf(l_ptr->name, "%u.%u.%u:%s-%u.%u.%u:unknown",
@@ -305,46 +322,48 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	skb_queue_head_init(&l_ptr->waiting_sks);
 
 	link_reset_statistics(l_ptr);
-
 	tipc_node_attach_link(n_ptr, l_ptr);
-
 	setup_timer(&l_ptr->timer, link_timeout, (unsigned long)l_ptr);
-
 	link_state_event(l_ptr, STARTING_EVT);
 
 	return l_ptr;
 }
 
+/**
+ * link_delete - Conditional deletion of link.
+ *               If timer still running, real delete is done when it expires
+ * @link: link to be deleted
+ */
+void tipc_link_delete(struct tipc_link *link)
+{
+	tipc_link_reset_fragments(link);
+	tipc_node_detach_link(link->owner, link);
+	tipc_link_put(link);
+}
+
 void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 			   bool shutting_down)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct tipc_link *l_ptr;
-	struct tipc_node *n_ptr;
+	struct tipc_link *link;
+	struct tipc_node *node;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
-		tipc_node_lock(n_ptr);
-		l_ptr = n_ptr->links[bearer_id];
-		if (l_ptr) {
-			tipc_link_reset(l_ptr);
-			if (shutting_down || !tipc_node_is_up(n_ptr)) {
-				tipc_node_detach_link(l_ptr->owner, l_ptr);
-				tipc_link_reset_fragments(l_ptr);
-				tipc_node_unlock(n_ptr);
-
-				/* Nobody else can access this link now: */
-				del_timer_sync(&l_ptr->timer);
-				kfree(l_ptr);
-			} else {
-				/* Detach/delete when failover is finished: */
-				l_ptr->flags |= LINK_STOPPED;
-				tipc_node_unlock(n_ptr);
-				del_timer_sync(&l_ptr->timer);
-			}
+	list_for_each_entry_rcu(node, &tn->node_list, list) {
+		tipc_node_lock(node);
+		link = node->links[bearer_id];
+		if (!link) {
+			tipc_node_unlock(node);
 			continue;
 		}
-		tipc_node_unlock(n_ptr);
+		tipc_link_reset(link);
+		if (del_timer(&link->timer))
+			tipc_link_put(link);
+		link->flags |= LINK_STOPPED;
+		/* Delete link now, or when failover is finished: */
+		if (shutting_down || !tipc_node_is_up(node))
+			tipc_link_delete(link);
+		tipc_node_unlock(node);
 	}
 	rcu_read_unlock();
 }
@@ -1837,10 +1856,8 @@ static struct sk_buff *tipc_link_failover_rcv(struct tipc_link *l_ptr,
 		}
 	}
 exit:
-	if ((l_ptr->exp_msg_count == 0) && (l_ptr->flags & LINK_STOPPED)) {
-		tipc_node_detach_link(l_ptr->owner, l_ptr);
-		kfree(l_ptr);
-	}
+	if ((!l_ptr->exp_msg_count) && (l_ptr->flags & LINK_STOPPED))
+		tipc_link_delete(l_ptr);
 	return buf;
 }
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 9df7fa4..f06b779 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -103,6 +103,7 @@ struct tipc_stats {
  * @media_addr: media address to use when sending messages over link
  * @timer: link timer
  * @owner: pointer to peer node
+ * @refcnt: reference counter for permanent references (owner node & timer)
  * @flags: execution state flags for link endpoint instance
  * @checkpoint: reference point for triggering link continuity checking
  * @peer_session: link session # being used by peer end of link
@@ -142,6 +143,7 @@ struct tipc_link {
 	struct tipc_media_addr media_addr;
 	struct timer_list timer;
 	struct tipc_node *owner;
+	struct kref ref;
 
 	/* Management and link supervision data */
 	unsigned int flags;
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
