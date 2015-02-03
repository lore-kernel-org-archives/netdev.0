From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 02/10] net/bonding: Move slave state changes to a helper function
Date: Tue,  3 Feb 2015 16:48:30 +0200
Message-ID: <1422974919-28084-3-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60021 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751725AbbBCOtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:49:31 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

Move slave state changes to a helper function, this is a pre-step for adding
functionality of dispatching an event when this helper is called.

This commit doesn't add new functionality.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/bonding/bond_main.c |   64 +++++++++++++++++++++++----------------
 include/net/bonding.h           |    5 +++
 2 files changed, 43 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e229a86..0665608 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -789,7 +789,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			}
 
 			new_active->delay = 0;
-			new_active->link = BOND_LINK_UP;
+			bond_set_slave_link_state(new_active, BOND_LINK_UP);
 
 			if (BOND_MODE(bond) == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
@@ -1176,6 +1176,21 @@ static void bond_free_slave(struct slave *slave)
 	kfree(slave);
 }
 
+static void bond_fill_ifbond(struct bonding *bond, struct ifbond *info)
+{
+	info->bond_mode = BOND_MODE(bond);
+	info->miimon = bond->params.miimon;
+	info->num_slaves = bond->slave_cnt;
+}
+
+static void bond_fill_ifslave(struct slave *slave, struct ifslave *info)
+{
+	strcpy(info->slave_name, slave->dev->name);
+	info->link = slave->link;
+	info->state = bond_slave_state(slave);
+	info->link_failure_count = slave->link_failure_count;
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1439,19 +1454,22 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (bond->params.miimon) {
 		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
 			if (bond->params.updelay) {
-				new_slave->link = BOND_LINK_BACK;
+				bond_set_slave_link_state(new_slave,
+							  BOND_LINK_BACK);
 				new_slave->delay = bond->params.updelay;
 			} else {
-				new_slave->link = BOND_LINK_UP;
+				bond_set_slave_link_state(new_slave,
+							  BOND_LINK_UP);
 			}
 		} else {
-			new_slave->link = BOND_LINK_DOWN;
+			bond_set_slave_link_state(new_slave, BOND_LINK_DOWN);
 		}
 	} else if (bond->params.arp_interval) {
-		new_slave->link = (netif_carrier_ok(slave_dev) ?
-			BOND_LINK_UP : BOND_LINK_DOWN);
+		bond_set_slave_link_state(new_slave,
+					  (netif_carrier_ok(slave_dev) ?
+					  BOND_LINK_UP : BOND_LINK_DOWN));
 	} else {
-		new_slave->link = BOND_LINK_UP;
+		bond_set_slave_link_state(new_slave, BOND_LINK_UP);
 	}
 
 	if (new_slave->link != BOND_LINK_DOWN)
@@ -1816,11 +1834,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-
-	info->bond_mode = BOND_MODE(bond);
-	info->miimon = bond->params.miimon;
-	info->num_slaves = bond->slave_cnt;
-
+	bond_fill_ifbond(bond, info);
 	return 0;
 }
 
@@ -1834,10 +1848,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 	bond_for_each_slave(bond, slave, iter) {
 		if (i++ == (int)info->slave_id) {
 			res = 0;
-			strcpy(info->slave_name, slave->dev->name);
-			info->link = slave->link;
-			info->state = bond_slave_state(slave);
-			info->link_failure_count = slave->link_failure_count;
+			bond_fill_ifslave(slave, info);
 			break;
 		}
 	}
@@ -1867,7 +1878,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (link_state)
 				continue;
 
-			slave->link = BOND_LINK_FAIL;
+			bond_set_slave_link_state(slave, BOND_LINK_FAIL);
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
 				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
@@ -1882,7 +1893,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 		case BOND_LINK_FAIL:
 			if (link_state) {
 				/* recovered before downdelay expired */
-				slave->link = BOND_LINK_UP;
+				bond_set_slave_link_state(slave, BOND_LINK_UP);
 				slave->last_link_up = jiffies;
 				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
 					    (bond->params.downdelay - slave->delay) *
@@ -1904,7 +1915,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (!link_state)
 				continue;
 
-			slave->link = BOND_LINK_BACK;
+			bond_set_slave_link_state(slave, BOND_LINK_BACK);
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
@@ -1917,7 +1928,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 			/*FALLTHRU*/
 		case BOND_LINK_BACK:
 			if (!link_state) {
-				slave->link = BOND_LINK_DOWN;
+				bond_set_slave_link_state(slave,
+							  BOND_LINK_DOWN);
 				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
 					    (bond->params.updelay - slave->delay) *
 					    bond->params.miimon,
@@ -1955,7 +1967,7 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_UP:
-			slave->link = BOND_LINK_UP;
+			bond_set_slave_link_state(slave, BOND_LINK_UP);
 			slave->last_link_up = jiffies;
 
 			primary = rtnl_dereference(bond->primary_slave);
@@ -1995,7 +2007,7 @@ static void bond_miimon_commit(struct bonding *bond)
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
-			slave->link = BOND_LINK_DOWN;
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
 
 			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
 			    BOND_MODE(bond) == BOND_MODE_8023AD)
@@ -2578,7 +2590,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 				struct slave *current_arp_slave;
 
 				current_arp_slave = rtnl_dereference(bond->current_arp_slave);
-				slave->link = BOND_LINK_UP;
+				bond_set_slave_link_state(slave, BOND_LINK_UP);
 				if (current_arp_slave) {
 					bond_set_slave_inactive_flags(
 						current_arp_slave,
@@ -2601,7 +2613,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
-			slave->link = BOND_LINK_DOWN;
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
 			bond_set_slave_inactive_flags(slave,
 						      BOND_SLAVE_NOTIFY_NOW);
 
@@ -2680,7 +2692,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 		 * up when it is actually down
 		 */
 		if (!bond_slave_is_up(slave) && slave->link == BOND_LINK_UP) {
-			slave->link = BOND_LINK_DOWN;
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
@@ -2700,7 +2712,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	if (!new_slave)
 		goto check_state;
 
-	new_slave->link = BOND_LINK_BACK;
+	bond_set_slave_link_state(new_slave, BOND_LINK_BACK);
 	bond_set_slave_active_flags(new_slave, BOND_SLAVE_NOTIFY_LATER);
 	bond_arp_send_all(bond, new_slave);
 	new_slave->last_link_up = jiffies;
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 29f53ea..d1367ec 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -490,6 +490,11 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
 	return slave->inactive;
 }
 
+static inline void bond_set_slave_link_state(struct slave *slave, int state)
+{
+	slave->link = state;
+}
+
 static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
 {
 	struct in_device *in_dev;
-- 
1.7.1
