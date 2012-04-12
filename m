From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH] bonding: start slaves with link down for ARP monitor
Date: Thu, 12 Apr 2012 20:38:09 +0200
Message-ID: <94e5ccf29d92f9a4b815f895b6bb8d9f326566cb.1334256203.git.mkubecek@suse.cz>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kubecekserver.ph.gin.cz ([212.71.128.105]:52591 "EHLO
	kubecekserver.ph.gin.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754230Ab2DLUBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 16:01:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize slave device link state as down if ARP monitor
is active. Also shift initial value of its last_arp_tx so that
it doesn't immediately cause fake detection of "up" state.

When ARP monitoring is used, initializing the slave device with
up link state can cause ARP monitor to detect link failure
before the device is really up (with igb driver, this can take
more than two seconds).

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---

When MII monitoring is active for a bond, initial link state of slaves
is set according to real link state of the corresponding device,
otherwise it is always set to UP. This makes sense if no monitoring is
active but with ARP monitoring, it can lead to situations like this:

[ 1280.431383] bonding: bond0: setting mode to active-backup (1).
[ 1280.443305] bonding: bond0: adding ARP target 10.11.0.8.
[ 1280.454079] bonding: bond0: setting arp_validate to all (3).
[ 1280.465561] bonding: bond0: Setting ARP monitoring interval to 500.
[ 1280.480366] ADDRCONF(NETDEV_UP): bond0: link is not ready
[ 1280.491471] bonding: bond0: Adding slave eth1.
[ 1280.584158] bonding: bond0: making interface eth1 the new active one.
[ 1280.597274] bonding: bond0: first active interface up!
[ 1280.607675] bonding: bond0: enslaving eth1 as an active interface with an up link.
[ 1280.623567] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[ 1280.635511] bonding: bond0: Adding slave eth2.
[ 1280.726423] bonding: bond0: enslaving eth2 as a backup interface with an up link.
[ 1281.976030] bonding: bond0: link status definitely down for interface eth1, disabling it
[ 1281.992350] bonding: bond0: making interface eth2 the new active one.
[ 1282.639276] igb: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[ 1283.002282] bonding: bond0: link status definitely down for interface eth2, disabling it
[ 1283.018713] bonding: bond0: now running without any active interface !
[ 1283.529415] bonding: bond0: link status definitely up for interface eth1.
[ 1283.543075] bonding: bond0: making interface eth1 the new active one.
[ 1283.556614] bonding: bond0: first active interface up!

Here eth1 is enslaved with link state UP but before the device is really
UP, ARP monitor detects it is actually down (it takes more than two
seconds and arp_interval was set to 500). This causes a spurious failure
in logs and in statistics.

I propose to initialize slaves with DOWN link state if ARP monitor is
active so that the ARP monitor can switch it to UP when appropriate.
This also requires adjusting the initial value of last_arp_rx as setting
it to current jiffies would pretend a packet arrived when slave was
initialized, leading to DOWN -> UP -> DOWN -> UP sequence.

---
 drivers/net/bonding/bond_main.c |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 62d2409..c1eda74 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1727,6 +1727,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	read_lock(&bond->lock);
 
 	new_slave->last_arp_rx = jiffies;
+	if (bond->params.arp_interval)
+		new_slave->last_arp_rx -=
+			(msecs_to_jiffies(bond->params.arp_interval) + 1);
 
 	if (bond->params.miimon && !bond->params.use_carrier) {
 		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
@@ -1751,21 +1754,26 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	/* check for initial state */
-	if (!bond->params.miimon ||
-	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
-		if (bond->params.updelay) {
-			pr_debug("Initial state of slave_dev is BOND_LINK_BACK\n");
-			new_slave->link  = BOND_LINK_BACK;
-			new_slave->delay = bond->params.updelay;
-		} else {
-			pr_debug("Initial state of slave_dev is BOND_LINK_UP\n");
-			new_slave->link  = BOND_LINK_UP;
-		}
-		new_slave->jiffies = jiffies;
-	} else {
-		pr_debug("Initial state of slave_dev is BOND_LINK_DOWN\n");
-		new_slave->link  = BOND_LINK_DOWN;
+	if (bond->params.miimon) {
+		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
+			if (bond->params.updelay) {
+				new_slave->link = BOND_LINK_BACK;
+				new_slave->delay = bond->params.updelay;
+			} else
+				new_slave->link = BOND_LINK_UP;
+		} else
+			new_slave->link = BOND_LINK_DOWN;
 	}
+	else if (bond->params.arp_interval)
+		new_slave->link = BOND_LINK_DOWN;
+	else
+		new_slave->link = BOND_LINK_UP;
+
+	if (new_slave->link != BOND_LINK_DOWN)
+		new_slave->jiffies = jiffies;
+	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
+		new_slave->link == BOND_LINK_DOWN ? "DOWN" :
+			(new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
 
 	bond_update_speed_duplex(new_slave);
 
-- 
1.7.7
