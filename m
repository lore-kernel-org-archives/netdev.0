From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH] bonding:update speed/duplex for NETDEV_CHANGE
Date: Tue,  1 Nov 2011 11:20:48 +0800
Message-ID: <9765cb601d0b4330cf7775ec3cd6b9e1ea13c71e.1320117071.git.wpan@redhat.com>
References: <14973.1320093129@death>
Cc: fubar@us.ibm.com, andy@greyhouse.net, linux-kernel@vger.kernel.org,
	Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14973.1320093129@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zheng Liang(lzheng@redhat.com) found a bug that if we config bonding with
arp monitor, sometimes bonding driver cannot get the speed and duplex from
its slaves, it will assume them to be 100Mb/sec and Full, please see
/proc/net/bonding/bond0.
But there is no such problem when uses miimon.

(Take igb for example)
I find that the reason is that after dev_open() in bond_enslave(),
bond_update_speed_duplex() will call igb_get_settings()
, but in that function,
it runs ethtool_cmd_speed_set(ecmd, -1); ecmd->duplex = -1;
because igb get an error value of status.
So even dev_open() is called, but the device is not really ready to get its
settings.

Maybe it is safe for us to call igb_get_settings() only after
this message shows up, that is "igb: p4p1 NIC Link is Up 1000 Mbps Full Duplex,
Flow Control: RX".

So I prefer to update the speed and duplex for a slave when reseices
NETDEV_CHANGE/NETDEV_UP event.

Changelog
V2:
1 remove the "fake 100/Full" logic in bond_update_speed_duplex(),
  set speed and duplex to -1 when it gets error value of speed and duplex.
2 delete the warning in bond_enslave() if bond_update_speed_duplex() returns
  error.
3 make bond_info_show_slave() handle bad values of speed and duplex.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 drivers/net/bonding/bond_main.c   |   37 ++++++++++++-------------------------
 drivers/net/bonding/bond_procfs.c |   12 ++++++++++--
 2 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c34cc1e..b2b9109 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -550,7 +550,7 @@ down:
 /*
  * Get link speed and duplex from the slave's base driver
  * using ethtool. If for some reason the call fails or the
- * values are invalid, fake speed and duplex to 100/Full
+ * values are invalid, set speed and duplex to -1,
  * and return error.
  */
 static int bond_update_speed_duplex(struct slave *slave)
@@ -560,9 +560,8 @@ static int bond_update_speed_duplex(struct slave *slave)
 	u32 slave_speed;
 	int res;
 
-	/* Fake speed and duplex */
-	slave->speed = SPEED_100;
-	slave->duplex = DUPLEX_FULL;
+	slave->speed = -1;
+	slave->duplex = -1;
 
 	res = __ethtool_get_settings(slave_dev, &ecmd);
 	if (res < 0)
@@ -1751,16 +1750,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		new_slave->link  = BOND_LINK_DOWN;
 	}
 
-	if (bond_update_speed_duplex(new_slave) &&
-	    (new_slave->link != BOND_LINK_DOWN)) {
-		pr_warning("%s: Warning: failed to get speed and duplex from %s, assumed to be 100Mb/sec and Full.\n",
-			   bond_dev->name, new_slave->dev->name);
-
-		if (bond->params.mode == BOND_MODE_8023AD) {
-			pr_warning("%s: Warning: Operation of 802.3ad mode requires ETHTOOL support in base driver for proper aggregator selection.\n",
-				   bond_dev->name);
-		}
-	}
+	bond_update_speed_duplex(new_slave);
 
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
@@ -3220,6 +3210,7 @@ static int bond_slave_netdev_event(unsigned long event,
 {
 	struct net_device *bond_dev = slave_dev->master;
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave = NULL;
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
@@ -3230,20 +3221,16 @@ static int bond_slave_netdev_event(unsigned long event,
 				bond_release(bond_dev, slave_dev);
 		}
 		break;
+	case NETDEV_UP:
 	case NETDEV_CHANGE:
-		if (bond->params.mode == BOND_MODE_8023AD || bond_is_lb(bond)) {
-			struct slave *slave;
+		slave = bond_get_slave_by_dev(bond, slave_dev);
+		if (slave) {
+			u32 old_speed = slave->speed;
+			u8  old_duplex = slave->duplex;
 
-			slave = bond_get_slave_by_dev(bond, slave_dev);
-			if (slave) {
-				u32 old_speed = slave->speed;
-				u8  old_duplex = slave->duplex;
-
-				bond_update_speed_duplex(slave);
-
-				if (bond_is_lb(bond))
-					break;
+			bond_update_speed_duplex(slave);
 
+			if (bond->params.mode == BOND_MODE_8023AD) {
 				if (old_speed != slave->speed)
 					bond_3ad_adapter_speed_changed(slave);
 				if (old_duplex != slave->duplex)
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 95de93b..d2ff52e 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -157,8 +157,16 @@ static void bond_info_show_slave(struct seq_file *seq,
 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
 	seq_printf(seq, "MII Status: %s\n",
 		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
-	seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
-	seq_printf(seq, "Duplex: %s\n", slave->duplex ? "full" : "half");
+	if (slave->speed == -1)
+		seq_printf(seq, "Speed: %s\n", "Unknown");
+	else
+		seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
+
+	if (slave->duplex == -1)
+		seq_printf(seq, "Duplex: %s\n", "Unknown");
+	else
+		seq_printf(seq, "Duplex: %s\n", slave->duplex ? "full" : "half");
+
 	seq_printf(seq, "Link Failure Count: %u\n",
 		   slave->link_failure_count);
 
-- 
1.7.4
