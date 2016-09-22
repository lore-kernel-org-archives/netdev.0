From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 net-next 1/2] bnx2x: allocate mac filtering 'mcast_list' in PAGE_SIZE increments
Date: Thu, 22 Sep 2016 17:12:25 -0400
Message-ID: <a332c760662a70c15ab326fccdb3878bcd919b5a.1474577624.git.jbaron@akamai.com>
References: <cover.1474577624.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
        Yuval.Mintz@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:61535 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753874AbcIVVM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 17:12:57 -0400
In-Reply-To: <cover.1474577624.git.jbaron@akamai.com>
In-Reply-To: <cover.1474577624.git.jbaron@akamai.com>
References: <cover.1474577624.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

Currently, we can have high order page allocations that specify
GFP_ATOMIC when configuring multicast MAC address filters.

For example, we have seen order 2 page allocation failures with
~500 multicast addresses configured.

Convert the allocation for 'mcast_list' to be done in PAGE_SIZE
increments.

Signed-off-by: Jason Baron <jbaron@akamai.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 79 +++++++++++++++---------
 1 file changed, 51 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index dab61a81a3ba..20fe6a8c35c1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12563,43 +12563,64 @@ static int bnx2x_close(struct net_device *dev)
 	return 0;
 }
 
-static int bnx2x_init_mcast_macs_list(struct bnx2x *bp,
-				      struct bnx2x_mcast_ramrod_params *p)
+struct bnx2x_mcast_list_elem_group
 {
-	int mc_count = netdev_mc_count(bp->dev);
-	struct bnx2x_mcast_list_elem *mc_mac =
-		kcalloc(mc_count, sizeof(*mc_mac), GFP_ATOMIC);
-	struct netdev_hw_addr *ha;
+	struct list_head mcast_group_link;
+	struct bnx2x_mcast_list_elem mcast_elems[];
+};
 
-	if (!mc_mac) {
-		BNX2X_ERR("Failed to allocate mc MAC list\n");
-		return -ENOMEM;
+#define MCAST_ELEMS_PER_PG \
+	((PAGE_SIZE - sizeof(struct bnx2x_mcast_list_elem_group)) / \
+	sizeof(struct bnx2x_mcast_list_elem))
+
+static void bnx2x_free_mcast_macs_list(struct list_head *mcast_group_list)
+{
+	struct bnx2x_mcast_list_elem_group *current_mcast_group;
+
+	while (!list_empty(mcast_group_list)) {
+		current_mcast_group = list_first_entry(mcast_group_list,
+				      struct bnx2x_mcast_list_elem_group,
+				      mcast_group_link);
+		list_del(&current_mcast_group->mcast_group_link);
+		free_page((unsigned long)current_mcast_group);
 	}
+}
 
-	INIT_LIST_HEAD(&p->mcast_list);
+static int bnx2x_init_mcast_macs_list(struct bnx2x *bp,
+				      struct bnx2x_mcast_ramrod_params *p,
+				      struct list_head *mcast_group_list)
+{
+	struct bnx2x_mcast_list_elem *mc_mac;
+	struct netdev_hw_addr *ha;
+	struct bnx2x_mcast_list_elem_group *current_mcast_group = NULL;
+	int mc_count = netdev_mc_count(bp->dev);
+	int offset = 0;
 
+	INIT_LIST_HEAD(&p->mcast_list);
 	netdev_for_each_mc_addr(ha, bp->dev) {
+		if (!offset) {
+			current_mcast_group =
+				(struct bnx2x_mcast_list_elem_group *)
+				__get_free_page(GFP_ATOMIC);
+			if (!current_mcast_group) {
+				bnx2x_free_mcast_macs_list(mcast_group_list);
+				BNX2X_ERR("Failed to allocate mc MAC list\n");
+				return -ENOMEM;
+			}
+			list_add(&current_mcast_group->mcast_group_link,
+				 mcast_group_list);
+		}
+		mc_mac = &current_mcast_group->mcast_elems[offset];
 		mc_mac->mac = bnx2x_mc_addr(ha);
 		list_add_tail(&mc_mac->link, &p->mcast_list);
-		mc_mac++;
+		offset++;
+		if (offset == MCAST_ELEMS_PER_PG)
+			offset = 0;
 	}
-
 	p->mcast_list_len = mc_count;
-
 	return 0;
 }
 
-static void bnx2x_free_mcast_macs_list(
-	struct bnx2x_mcast_ramrod_params *p)
-{
-	struct bnx2x_mcast_list_elem *mc_mac =
-		list_first_entry(&p->mcast_list, struct bnx2x_mcast_list_elem,
-				 link);
-
-	WARN_ON(!mc_mac);
-	kfree(mc_mac);
-}
-
 /**
  * bnx2x_set_uc_list - configure a new unicast MACs list.
  *
@@ -12647,6 +12668,7 @@ static int bnx2x_set_uc_list(struct bnx2x *bp)
 
 static int bnx2x_set_mc_list_e1x(struct bnx2x *bp)
 {
+	LIST_HEAD(mcast_group_list);
 	struct net_device *dev = bp->dev;
 	struct bnx2x_mcast_ramrod_params rparam = {NULL};
 	int rc = 0;
@@ -12662,7 +12684,7 @@ static int bnx2x_set_mc_list_e1x(struct bnx2x *bp)
 
 	/* then, configure a new MACs list */
 	if (netdev_mc_count(dev)) {
-		rc = bnx2x_init_mcast_macs_list(bp, &rparam);
+		rc = bnx2x_init_mcast_macs_list(bp, &rparam, &mcast_group_list);
 		if (rc)
 			return rc;
 
@@ -12673,7 +12695,7 @@ static int bnx2x_set_mc_list_e1x(struct bnx2x *bp)
 			BNX2X_ERR("Failed to set a new multicast configuration: %d\n",
 				  rc);
 
-		bnx2x_free_mcast_macs_list(&rparam);
+		bnx2x_free_mcast_macs_list(&mcast_group_list);
 	}
 
 	return rc;
@@ -12681,6 +12703,7 @@ static int bnx2x_set_mc_list_e1x(struct bnx2x *bp)
 
 static int bnx2x_set_mc_list(struct bnx2x *bp)
 {
+	LIST_HEAD(mcast_group_list);
 	struct bnx2x_mcast_ramrod_params rparam = {NULL};
 	struct net_device *dev = bp->dev;
 	int rc = 0;
@@ -12692,7 +12715,7 @@ static int bnx2x_set_mc_list(struct bnx2x *bp)
 	rparam.mcast_obj = &bp->mcast_obj;
 
 	if (netdev_mc_count(dev)) {
-		rc = bnx2x_init_mcast_macs_list(bp, &rparam);
+		rc = bnx2x_init_mcast_macs_list(bp, &rparam, &mcast_group_list);
 		if (rc)
 			return rc;
 
@@ -12703,7 +12726,7 @@ static int bnx2x_set_mc_list(struct bnx2x *bp)
 			BNX2X_ERR("Failed to set a new multicast configuration: %d\n",
 				  rc);
 
-		bnx2x_free_mcast_macs_list(&rparam);
+		bnx2x_free_mcast_macs_list(&mcast_group_list);
 	} else {
 		/* If no mc addresses are required, flush the configuration */
 		rc = bnx2x_config_mcast(bp, &rparam, BNX2X_MCAST_CMD_DEL);
-- 
2.6.1
