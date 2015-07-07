From: Mazhar Rana <ranamazharp@gmail.com>
Subject: [PATCH v3] bonding: "primary_reselect" with "failure" is not working properly
Date: Tue,  7 Jul 2015 15:04:50 +0530
Message-ID: <1436261690-1121-1-git-send-email-ranamazharp@gmail.com>
Cc: Mazhar Rana <mazhar.rana@cyberoam.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	sanket.shah@cyberoam.com
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32867 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbbGGJgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 05:36:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mazhar Rana <mazhar.rana@cyberoam.com>

When "primary_reselect" is set to "failure", primary interface should
not become active until current active slave is down. But if we set first
member of bond device as a "primary" interface and "primary_reselect"
is set to "failure" then whenever primary interface's link get back(up)
it become active slave even if current active slave is still up.

With this patch, "bond_find_best_slave" will not traverse members if
primary interface is not candidate for failover/reselection and current
active slave is still up.

Signed-off-by: Mazhar Rana <mazhar.rana@cyberoam.com>
Signed-off-by: Jay Vosburgh <j.vosburgh@gmail.com>
---

v1->v2: 
return "curr" instead of "bond->curr_active_slave".

v2->v3: 
To make code more clear, replaced function bond_should_change_active
with bond_choose_primary_or_current which will return slave device.

 drivers/net/bonding/bond_main.c | 51 +++++++++++++++++++++++++++--------------
 1 file changed, 34 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eb990..317a494 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -689,40 +689,57 @@ out:
 
 }
 
-static bool bond_should_change_active(struct bonding *bond)
+static struct slave *bond_choose_primary_or_current(struct bonding *bond)
 {
 	struct slave *prim = rtnl_dereference(bond->primary_slave);
 	struct slave *curr = rtnl_dereference(bond->curr_active_slave);
 
-	if (!prim || !curr || curr->link != BOND_LINK_UP)
-		return true;
+	if (!prim || prim->link != BOND_LINK_UP) {
+		if (!curr || curr->link != BOND_LINK_UP)
+			return NULL;
+		return curr;
+	}
+
 	if (bond->force_primary) {
 		bond->force_primary = false;
-		return true;
+		return prim;
+	}
+
+	if (!curr || curr->link != BOND_LINK_UP)
+		return prim;
+
+	/* At this point, prim and curr are both up */
+	switch (bond->params.primary_reselect) {
+	case BOND_PRI_RESELECT_ALWAYS:
+		return prim;
+	case BOND_PRI_RESELECT_BETTER:
+		if (prim->speed < curr->speed)
+			return curr;
+		if (prim->speed == curr->speed && prim->duplex <= curr->duplex)
+			return curr;
+		return prim;
+	case BOND_PRI_RESELECT_FAILURE:
+		return curr;
+	default:
+		netdev_err(bond->dev, "impossible primary_reselect %d\n",
+			   bond->params.primary_reselect);
+		return curr;
 	}
-	if (bond->params.primary_reselect == BOND_PRI_RESELECT_BETTER &&
-	    (prim->speed < curr->speed ||
-	     (prim->speed == curr->speed && prim->duplex <= curr->duplex)))
-		return false;
-	if (bond->params.primary_reselect == BOND_PRI_RESELECT_FAILURE)
-		return false;
-	return true;
 }
 
 /**
- * find_best_interface - select the best available slave to be the active one
+ * bond_find_best_slave - select the best available slave to be the active one
  * @bond: our bonding struct
  */
 static struct slave *bond_find_best_slave(struct bonding *bond)
 {
-	struct slave *slave, *bestslave = NULL, *primary;
+	struct slave *slave, *bestslave = NULL;
 	struct list_head *iter;
 	int mintime = bond->params.updelay;
 
-	primary = rtnl_dereference(bond->primary_slave);
-	if (primary && primary->link == BOND_LINK_UP &&
-	    bond_should_change_active(bond))
-		return primary;
+	slave = bond_choose_primary_or_current(bond);
+	if (slave)
+		return slave;
 
 	bond_for_each_slave(bond, slave, iter) {
 		if (slave->link == BOND_LINK_UP)
-- 
1.9.1
