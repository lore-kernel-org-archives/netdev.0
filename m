From: David Decotigny <decot@google.com>
Subject: [PATCH 3/3] net-bonding: Adding support for throughputs larger than 65536 Mbps
Date: Wed, 13 Apr 2011 18:22:31 -0700
Message-ID: <1302744151-12452-3-git-send-email-decot@google.com>
References: <1302744151-12452-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302744151-12452-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This updates the bonding driver to support v2.6.27-rc3 enhancements
(b11f8d8c aka. "ethtool: Expand ethtool_cmd.speed to 32 bits") which
allow to encode the Mbps link speed on 32-bits (Max 4 Pbps) instead of
16 (Max 65536 Mbps).

This patch also attempts to compact struct slave by reordering its
fields.

Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/bonding/bond_main.c |   12 +++++++-----
 drivers/net/bonding/bonding.h   |    6 +++---
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 145f9be..c5d8ac2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -631,7 +631,8 @@ down:
 static int bond_update_speed_duplex(struct slave *slave)
 {
 	struct net_device *slave_dev = slave->dev;
-	struct ethtool_cmd etool;
+	struct ethtool_cmd etool = { .cmd = ETHTOOL_GSET };
+	u32 slave_speed;
 	int res;
 
 	/* Fake speed and duplex */
@@ -645,7 +646,8 @@ static int bond_update_speed_duplex(struct slave *slave)
 	if (res < 0)
 		return -1;
 
-	switch (etool.speed) {
+	slave_speed = ethtool_cmd_speed(&etool);
+	switch (slave_speed) {
 	case SPEED_10:
 	case SPEED_100:
 	case SPEED_1000:
@@ -663,7 +665,7 @@ static int bond_update_speed_duplex(struct slave *slave)
 		return -1;
 	}
 
-	slave->speed = etool.speed;
+	slave->speed = slave_speed;
 	slave->duplex = etool.duplex;
 
 	return 0;
@@ -2493,7 +2495,7 @@ static void bond_miimon_commit(struct bonding *bond)
 
 			bond_update_speed_duplex(slave);
 
-			pr_info("%s: link status definitely up for interface %s, %d Mbps %s duplex.\n",
+			pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
 				bond->dev->name, slave->dev->name,
 				slave->speed, slave->duplex ? "full" : "half");
 
@@ -3339,7 +3341,7 @@ static int bond_slave_netdev_event(unsigned long event,
 
 			slave = bond_get_slave_by_dev(bond, slave_dev);
 			if (slave) {
-				u16 old_speed = slave->speed;
+				u32 old_speed = slave->speed;
 				u8  old_duplex = slave->duplex;
 
 				bond_update_speed_duplex(slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 3ca503e..553c764 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -196,12 +196,12 @@ struct slave {
 	u8     backup:1,   /* indicates backup slave. Value corresponds with
 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
 	       inactive:1; /* indicates inactive slave */
+	u8     duplex;
 	u32    original_mtu;
 	u32    link_failure_count;
-	u8     perm_hwaddr[ETH_ALEN];
-	u16    speed;
-	u8     duplex;
+	u32    speed;
 	u16    queue_id;
+	u8     perm_hwaddr[ETH_ALEN];
 	struct ad_slave_info ad_info; /* HUGE - better to dynamically alloc */
 	struct tlb_slave_info tlb_info;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.3.1
