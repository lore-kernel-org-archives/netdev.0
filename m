From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/2] tipc: correct usage of spin_lock() vs spin_lock_bh()
Date: Fri, 14 Feb 2014 16:40:44 -0500
Message-ID: <1392414044-14326-3-git-send-email-jon.maloy@ericsson.com>
References: <1392414044-14326-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:21117 "HELO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752701AbaBNVr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:47:59 -0500
In-Reply-To: <1392414044-14326-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I commit e099e86c9e24fe9aff36773600543eb31d8954d
("tipc: add node_lock protection to link lookup function")
we are calling spin_lock(&node->lock) directly instead of indirectly
via the tipc_node_lock(node) function. However, tipc_node_lock() is
using spin_lock_bh(), not spin_lock(), something leading to
unbalanced usage in one place, and a smatch warning.

We fix this by consistently using tipc_node_lock()/unlock() in
in the places touched by the mentioned commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4fb4ae0..5422e96 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2410,7 +2410,7 @@ static struct tipc_node *tipc_link_find_owner(const char *link_name,
 
 	*bearer_id = 0;
 	list_for_each_entry_safe(n_ptr, tmp_n_ptr, &tipc_node_list, list) {
-		spin_lock(&n_ptr->lock);
+		tipc_node_lock(n_ptr);
 		for (i = 0; i < MAX_BEARERS; i++) {
 			l_ptr = n_ptr->links[i];
 			if (l_ptr && !strcmp(l_ptr->name, link_name)) {
@@ -2419,7 +2419,7 @@ static struct tipc_node *tipc_link_find_owner(const char *link_name,
 				break;
 			}
 		}
-		spin_unlock(&n_ptr->lock);
+		tipc_node_unlock(n_ptr);
 		if (found_node)
 			break;
 	}
@@ -2603,7 +2603,7 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string("link not found");
 	}
-	spin_lock(&node->lock);
+	tipc_node_lock(node);
 	l_ptr = node->links[bearer_id];
 	if (!l_ptr) {
 		tipc_node_unlock(node);
-- 
1.7.9.5
