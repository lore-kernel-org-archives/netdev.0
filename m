From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Fri,  2 Aug 2013 18:41:05 +0200
Message-ID: <1375461665-4186-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, davem@davemloft.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab3HBQon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 12:44:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>

When arp monitoring is enabled the bonding relies on slaves'
dev_trans_start() value to check if the slave link is up or not, but for
8021q devices that value is either stale or 0, and can't be used. So use
the 8021q's underlying device value.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07f257d4..5f2bad3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -665,6 +665,17 @@ static int bond_check_dev_link(struct bonding *bond,
 	return reporting ? -1 : BMSR_LSTATUS;
 }
 
+/* For 8021q devices dev_trans_start() returns 0 or a stale value, so use the
+ * 8021q's underlying device value
+ */
+static unsigned long bond_dev_trans_start(struct net_device *dev)
+{
+	while (dev->priv_flags & IFF_802_1Q_VLAN)
+		dev = vlan_dev_real_dev(dev);
+
+	return dev_trans_start(dev);
+}
+
 /*----------------------------- Multicast list ------------------------------*/
 
 /*
@@ -2750,7 +2761,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	 *       so it can wait
 	 */
 	bond_for_each_slave(bond, slave, i) {
-		unsigned long trans_start = dev_trans_start(slave->dev);
+		unsigned long trans_start = bond_dev_trans_start(slave->dev);
 
 		if (slave->link != BOND_LINK_UP) {
 			if (time_in_range(jiffies,
@@ -2912,7 +2923,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 * - (more than 2*delta since receive AND
 		 *    the bond has an IP address)
 		 */
-		trans_start = dev_trans_start(slave->dev);
+		trans_start = bond_dev_trans_start(slave->dev);
 		if (bond_is_active_slave(slave) &&
 		    (!time_in_range(jiffies,
 			trans_start - delta_in_ticks,
@@ -2947,7 +2958,7 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 			continue;
 
 		case BOND_LINK_UP:
-			trans_start = dev_trans_start(slave->dev);
+			trans_start = bond_dev_trans_start(slave->dev);
 			if ((!bond->curr_active_slave &&
 			     time_in_range(jiffies,
 					   trans_start - delta_in_ticks,
-- 
1.8.1.4
