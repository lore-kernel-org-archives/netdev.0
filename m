From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 01/10] tipc: always use tipc_node_lock() to hold node lock
Date: Mon, 5 May 2014 08:56:09 +0800
Message-ID: <1399251378-23842-2-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40111 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbaEEA4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:36 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although we obtain node lock with tipc_node_lock() in most time, there
are still places where we directly use native spin lock interface
to grab node lock. But as we will do more jobs in the future when node
lock is released, we should ensure that tipc_node_lock() is always
called when node lock is taken.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c       |   12 ++++++------
 net/tipc/name_distr.c |    6 +++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index c723ee9..3a80145 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -297,14 +297,14 @@ void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
-		spin_lock_bh(&n_ptr->lock);
+		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->links[bearer_id];
 		if (l_ptr) {
 			tipc_link_reset(l_ptr);
 			if (shutting_down || !tipc_node_is_up(n_ptr)) {
 				tipc_node_detach_link(l_ptr->owner, l_ptr);
 				tipc_link_reset_fragments(l_ptr);
-				spin_unlock_bh(&n_ptr->lock);
+				tipc_node_unlock(n_ptr);
 
 				/* Nobody else can access this link now: */
 				del_timer_sync(&l_ptr->timer);
@@ -312,12 +312,12 @@ void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down)
 			} else {
 				/* Detach/delete when failover is finished: */
 				l_ptr->flags |= LINK_STOPPED;
-				spin_unlock_bh(&n_ptr->lock);
+				tipc_node_unlock(n_ptr);
 				del_timer_sync(&l_ptr->timer);
 			}
 			continue;
 		}
-		spin_unlock_bh(&n_ptr->lock);
+		tipc_node_unlock(n_ptr);
 	}
 	rcu_read_unlock();
 }
@@ -474,11 +474,11 @@ void tipc_link_reset_list(unsigned int bearer_id)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
-		spin_lock_bh(&n_ptr->lock);
+		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->links[bearer_id];
 		if (l_ptr)
 			tipc_link_reset(l_ptr);
-		spin_unlock_bh(&n_ptr->lock);
+		tipc_node_unlock(n_ptr);
 	}
 	rcu_read_unlock();
 }
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 974a73f..8465263 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -135,18 +135,18 @@ void named_cluster_distribute(struct sk_buff *buf)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
-		spin_lock_bh(&n_ptr->lock);
+		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[n_ptr->addr & 1];
 		if (l_ptr) {
 			buf_copy = skb_copy(buf, GFP_ATOMIC);
 			if (!buf_copy) {
-				spin_unlock_bh(&n_ptr->lock);
+				tipc_node_unlock(n_ptr);
 				break;
 			}
 			msg_set_destnode(buf_msg(buf_copy), n_ptr->addr);
 			__tipc_link_xmit(l_ptr, buf_copy);
 		}
-		spin_unlock_bh(&n_ptr->lock);
+		tipc_node_unlock(n_ptr);
 	}
 	rcu_read_unlock();
 
-- 
1.7.9.5
