From: Michal Kubecek <mkubecek@suse.cz>
Subject: [net-next PATCH v3] bonding: start slaves with link down for ARP monitor
Date: Tue, 17 Apr 2012 14:02:06 +0200
Message-ID: <20120417121135.5F9A740290@alaris.suse.cz>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Flavio Leitner <fbl@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45260 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799Ab2DQMLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 08:11:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize slave device link state as down if ARP monitor is
active and net_carrier_ok() returns zero. Also shift initial
value of its last_arp_tx so that it doesn't immediately cause
fake detection of "up" state.

When ARP monitoring is used, initializing the slave device with
up link state can cause ARP monitor to detect link failure
before the device is really up (with igb driver, this can take
more than two seconds).

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/bonding/bond_main.c |   33 +++++++++++++++++++++------------
 1 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bb92899..44e6a64 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1726,7 +1726,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	read_lock(&bond->lock);
 
-	new_slave->last_arp_rx = jiffies;
+	new_slave->last_arp_rx = jiffies -
+		(msecs_to_jiffies(bond->params.arp_interval) + 1);
 
 	if (bond->params.miimon && !bond->params.use_carrier) {
 		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
@@ -1751,22 +1752,30 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	/* check for initial state */
-	if (!bond->params.miimon ||
-	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
-		if (bond->params.updelay) {
-			pr_debug("Initial state of slave_dev is BOND_LINK_BACK\n");
-			new_slave->link  = BOND_LINK_BACK;
-			new_slave->delay = bond->params.updelay;
+	if (bond->params.miimon) {
+		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
+			if (bond->params.updelay) {
+				new_slave->link = BOND_LINK_BACK;
+				new_slave->delay = bond->params.updelay;
+			} else {
+				new_slave->link = BOND_LINK_UP;
+			}
 		} else {
-			pr_debug("Initial state of slave_dev is BOND_LINK_UP\n");
-			new_slave->link  = BOND_LINK_UP;
+			new_slave->link = BOND_LINK_DOWN;
 		}
-		new_slave->jiffies = jiffies;
+	} else if (bond->params.arp_interval) {
+		new_slave->link = (netif_carrier_ok(slave_dev) ?
+			BOND_LINK_UP : BOND_LINK_DOWN);
 	} else {
-		pr_debug("Initial state of slave_dev is BOND_LINK_DOWN\n");
-		new_slave->link  = BOND_LINK_DOWN;
+		new_slave->link = BOND_LINK_UP;
 	}
 
+	if (new_slave->link != BOND_LINK_DOWN)
+		new_slave->jiffies = jiffies;
+	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
+		new_slave->link == BOND_LINK_DOWN ? "DOWN" :
+			(new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
+
 	bond_update_speed_duplex(new_slave);
 
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
-- 
1.7.7
