From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 5/8] tipc: avoid unnecessary lookup for tipc bearer instance
Date: Fri, 18 Oct 2013 07:23:18 +0200
Message-ID: <1382073801-22128-6-git-send-email-jon.maloy@ericsson.com>
References: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.gq1.yahoo.com ([98.137.12.179]:46736 "HELO
	smtp104.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750895Ab3JRFaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 01:30:24 -0400
In-Reply-To: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

tipc_block_bearer() currently takes a bearer name (const char*)
as argument. This requires the function to make a lookup to find
the pointer to the corresponding bearer struct. In the current
code base this is not necessary, since the only two callers
(tipc_continue(),recv_notification()) already have validated
copies of this pointer, and hence can pass it directly in the
function call.

We change tipc_block_bearer() to directly take struct tipc_bearer*
as argument instead.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c    |   14 +++-----------
 net/tipc/bearer.h    |    2 +-
 net/tipc/eth_media.c |    6 +++---
 net/tipc/ib_media.c  |    6 +++---
 4 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 09faa55..3f9707a 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -420,23 +420,15 @@ exit:
 }
 
 /**
- * tipc_block_bearer - Block the bearer with the given name, and reset all its links
+ * tipc_block_bearer - Block the bearer, and reset all its links
  */
-int tipc_block_bearer(const char *name)
+int tipc_block_bearer(struct tipc_bearer *b_ptr)
 {
-	struct tipc_bearer *b_ptr = NULL;
 	struct tipc_link *l_ptr;
 	struct tipc_link *temp_l_ptr;
 
 	read_lock_bh(&tipc_net_lock);
-	b_ptr = tipc_bearer_find(name);
-	if (!b_ptr) {
-		pr_warn("Attempt to block unknown bearer <%s>\n", name);
-		read_unlock_bh(&tipc_net_lock);
-		return -EINVAL;
-	}
-
-	pr_info("Blocking bearer <%s>\n", name);
+	pr_info("Blocking bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index f800e63..e5e04be 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -163,7 +163,7 @@ int tipc_register_media(struct tipc_media *m_ptr);
 
 void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
 
-int  tipc_block_bearer(const char *name);
+int  tipc_block_bearer(struct tipc_bearer *b_ptr);
 void tipc_continue(struct tipc_bearer *tb_ptr);
 
 int tipc_enable_bearer(const char *bearer_name, u32 disc_domain, u32 priority);
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index e048d49..c36c938 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -265,17 +265,17 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 		if (netif_carrier_ok(dev))
 			tipc_continue(eb_ptr->bearer);
 		else
-			tipc_block_bearer(eb_ptr->bearer->name);
+			tipc_block_bearer(eb_ptr->bearer);
 		break;
 	case NETDEV_UP:
 		tipc_continue(eb_ptr->bearer);
 		break;
 	case NETDEV_DOWN:
-		tipc_block_bearer(eb_ptr->bearer->name);
+		tipc_block_bearer(eb_ptr->bearer);
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGEADDR:
-		tipc_block_bearer(eb_ptr->bearer->name);
+		tipc_block_bearer(eb_ptr->bearer);
 		tipc_continue(eb_ptr->bearer);
 		break;
 	case NETDEV_UNREGISTER:
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 5545145..20b1aa4 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -258,17 +258,17 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 		if (netif_carrier_ok(dev))
 			tipc_continue(ib_ptr->bearer);
 		else
-			tipc_block_bearer(ib_ptr->bearer->name);
+			tipc_block_bearer(ib_ptr->bearer);
 		break;
 	case NETDEV_UP:
 		tipc_continue(ib_ptr->bearer);
 		break;
 	case NETDEV_DOWN:
-		tipc_block_bearer(ib_ptr->bearer->name);
+		tipc_block_bearer(ib_ptr->bearer);
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGEADDR:
-		tipc_block_bearer(ib_ptr->bearer->name);
+		tipc_block_bearer(ib_ptr->bearer);
 		tipc_continue(ib_ptr->bearer);
 		break;
 	case NETDEV_UNREGISTER:
-- 
1.7.9.5
