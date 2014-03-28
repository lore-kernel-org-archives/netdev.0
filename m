From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 1/2] tipc: fix neighbor detection problem after hw address change
Date: Fri, 28 Mar 2014 10:32:08 +0100
Message-ID: <1395999129-31688-2-git-send-email-erik.hugne@ericsson.com>
References: <1395999129-31688-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, <aleksandar.igic@dektech.com.au>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:62076 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaC1Jb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:31:57 -0400
In-Reply-To: <1395999129-31688-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

If the hardware address of a underlying netdevice is changed, it is
not enough to simply reset the bearer/links over this device. We
also need to reflect this change in the TIPC bearer and node
discovery structures aswell.

This patch adds the necessary reinitialization of the node disovery
mechanism following a hardware address change so that the correct
originating media address is advertised in the discovery messages.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reported-by: Dong Liu <dliu.cn@gmail.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bearer.c | 7 +++++++
 net/tipc/bearer.h | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index ed45f97..3cd65d4 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -332,6 +332,7 @@ restart:
 	b_ptr->identity = bearer_id;
 	b_ptr->tolerance = m_ptr->tolerance;
 	b_ptr->window = m_ptr->window;
+	b_ptr->domain = disc_domain;
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->priority = priority;
 
@@ -360,7 +361,9 @@ static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
 {
 	read_lock_bh(&tipc_net_lock);
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
+	tipc_disc_delete(b_ptr->link_req);
 	tipc_link_reset_list(b_ptr->identity);
+	tipc_disc_create(b_ptr, &b_ptr->bcast_addr, b_ptr->domain);
 	read_unlock_bh(&tipc_net_lock);
 	return 0;
 }
@@ -580,7 +583,11 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 			break;
 	case NETDEV_DOWN:
 	case NETDEV_CHANGEMTU:
+		tipc_reset_bearer(b_ptr);
+		break;
 	case NETDEV_CHANGEADDR:
+		tipc_l2_media_addr_set(b_ptr, &b_ptr->addr,
+				       (char *)dev->dev_addr);
 		tipc_reset_bearer(b_ptr);
 		break;
 	case NETDEV_UNREGISTER:
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 3f6d7d0..ba48145 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -116,6 +116,7 @@ struct tipc_media {
  * @priority: default link priority for bearer
  * @window: default window size for bearer
  * @tolerance: default link tolerance for bearer
+ * @domain: network domain to which links can be established
  * @identity: array index of this bearer within TIPC bearer array
  * @link_req: ptr to (optional) structure making periodic link setup requests
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
@@ -135,6 +136,7 @@ struct tipc_bearer {
 	u32 priority;
 	u32 window;
 	u32 tolerance;
+	u32 domain;
 	u32 identity;
 	struct tipc_link_req *link_req;
 	char net_plane;
-- 
1.8.3.2
