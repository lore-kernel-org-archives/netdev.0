From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 12/14] tipc: delay delete of link when failover is needed
Date: Thu, 13 Feb 2014 17:29:16 -0500
Message-ID: <1392330558-19048-13-git-send-email-jon.maloy@ericsson.com>
References: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.ne1.yahoo.com ([98.138.207.10]:21117 "HELO
	smtp103.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752557AbaBMW3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:29:47 -0500
In-Reply-To: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a bearer is disabled, all its attached links are deleted.
Ideally, we should do link failover to redundant links on other bearers,
if there are any, in such cases. This would be consistent with current
behavior when a link is reset, but not deleted. However, due to the
complexity involved, and the (wrongly) perceived low demand for this
feature, it was never implemented until now.

We mark the doomed link for deletion with a new flag, but wait until the
failover process is finished before we actually delete it. With the
improved link tunnelling/failover code introduced earlier in this commit
series, it is now easy to identify a spot in the code where the failover
is finished and it is safe to delete the marked link. Moreover, the test
for the flag and the deletion can be done synchronously, and outside the
most time critical data path.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bearer.c |   12 ++++++------
 net/tipc/link.c   |   31 ++++++++++++++++++++++---------
 net/tipc/link.h   |    2 +-
 net/tipc/node.c   |    8 +++++++-
 4 files changed, 36 insertions(+), 17 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 4931eea..60caa45 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -51,7 +51,7 @@ static struct tipc_media * const media_info_array[] = {
 
 struct tipc_bearer tipc_bearers[MAX_BEARERS];
 
-static void bearer_disable(struct tipc_bearer *b_ptr);
+static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down);
 
 /**
  * tipc_media_find - locates specified media object by name
@@ -331,7 +331,7 @@ restart:
 
 	res = tipc_disc_create(b_ptr, &b_ptr->bcast_addr, disc_domain);
 	if (res) {
-		bearer_disable(b_ptr);
+		bearer_disable(b_ptr, false);
 		pr_warn("Bearer <%s> rejected, discovery object creation failed\n",
 			name);
 		goto exit;
@@ -363,14 +363,14 @@ static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
  *
  * Note: This routine assumes caller holds tipc_net_lock.
  */
-static void bearer_disable(struct tipc_bearer *b_ptr)
+static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down)
 {
 	struct tipc_link_req *temp_req;
 
 	pr_info("Disabling bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->media->disable_media(b_ptr);
-	tipc_link_delete_list(b_ptr->identity);
+	tipc_link_delete_list(b_ptr->identity, shutting_down);
 	temp_req = b_ptr->link_req;
 	b_ptr->link_req = NULL;
 	spin_unlock_bh(&b_ptr->lock);
@@ -392,7 +392,7 @@ int tipc_disable_bearer(const char *name)
 		pr_warn("Attempt to disable unknown bearer <%s>\n", name);
 		res = -EINVAL;
 	} else {
-		bearer_disable(b_ptr);
+		bearer_disable(b_ptr, false);
 		res = 0;
 	}
 	write_unlock_bh(&tipc_net_lock);
@@ -612,6 +612,6 @@ void tipc_bearer_stop(void)
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		if (tipc_bearers[i].active)
-			bearer_disable(&tipc_bearers[i]);
+			bearer_disable(&tipc_bearers[i], true);
 	}
 }
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 663623c..0307516 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -281,7 +281,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 }
 
 
-void tipc_link_delete_list(unsigned int bearer_id)
+void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down)
 {
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
@@ -291,12 +291,20 @@ void tipc_link_delete_list(unsigned int bearer_id)
 		l_ptr = n_ptr->links[bearer_id];
 		if (l_ptr) {
 			tipc_link_reset(l_ptr);
-			tipc_node_detach_link(n_ptr, l_ptr);
-			spin_unlock_bh(&n_ptr->lock);
-
-			/* Nobody else can access this link now: */
-			del_timer_sync(&l_ptr->timer);
-			kfree(l_ptr);
+			if (shutting_down || !tipc_node_is_up(n_ptr)) {
+				tipc_node_detach_link(l_ptr->owner, l_ptr);
+				tipc_link_reset_fragments(l_ptr);
+				spin_unlock_bh(&n_ptr->lock);
+
+				/* Nobody else can access this link now: */
+				del_timer_sync(&l_ptr->timer);
+				kfree(l_ptr);
+			} else {
+				/* Detach/delete when failover is finished: */
+				l_ptr->flags |= LINK_STOPPED;
+				spin_unlock_bh(&n_ptr->lock);
+				del_timer_sync(&l_ptr->timer);
+			}
 			continue;
 		}
 		spin_unlock_bh(&n_ptr->lock);
@@ -481,6 +489,9 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 	struct tipc_link *other;
 	u32 cont_intv = l_ptr->continuity_interval;
 
+	if (l_ptr->flags & LINK_STOPPED)
+		return;
+
 	if (!(l_ptr->flags & LINK_STARTED) && (event != STARTING_EVT))
 		return;		/* Not yet. */
 
@@ -2167,8 +2178,11 @@ static struct sk_buff *tipc_link_failover_rcv(struct tipc_link *l_ptr,
 					   &buf);
 		}
 	}
-
 exit:
+	if ((l_ptr->exp_msg_count == 0) && (l_ptr->flags & LINK_STOPPED)) {
+		tipc_node_detach_link(l_ptr->owner, l_ptr);
+		kfree(l_ptr);
+	}
 	return buf;
 }
 
@@ -2201,7 +2215,6 @@ static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 		*buf = tipc_link_failover_rcv(l_ptr, t_buf);
 	else
 		pr_warn("%sunknown tunnel pkt received\n", link_co_err);
-
 exit:
 	kfree_skb(t_buf);
 	return *buf != NULL;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 3340fc1..45b9cd0 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -214,7 +214,7 @@ struct tipc_port;
 struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr);
-void tipc_link_delete_list(unsigned int bearer_id);
+void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down);
 void tipc_link_failover_send_queue(struct tipc_link *l_ptr);
 void tipc_link_dup_send_queue(struct tipc_link *l_ptr,
 			      struct tipc_link *dest);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index efe4d41..833324b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -249,7 +249,13 @@ void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
-	n_ptr->links[l_ptr->b_ptr->identity] = NULL;
+	int i;
+
+	for (i = 0; i < MAX_BEARERS; i++) {
+		if (l_ptr == n_ptr->links[i])
+			break;
+	}
+	n_ptr->links[i] = NULL;
 	atomic_dec(&tipc_num_links);
 	n_ptr->link_cnt--;
 }
-- 
1.7.9.5
