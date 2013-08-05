From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 1/3] bonding: fix vlan 0 addition and removal
Date: Mon,  5 Aug 2013 15:28:22 +0200
Message-ID: <1375709304-16778-2-git-send-email-nikolay@redhat.com>
References: <1375709304-16778-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156Ab3HENcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 09:32:04 -0400
In-Reply-To: <1375709304-16778-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>

Right now if we have 8021q module loaded vlan 0 is added to all network
devices but since the bonding is a software device (and doesn't have hw
filters) it doesn't really need it, and moreover it causes the bond to
output warnings when a slave is being released if the slave's mac is in
use by the bonding like:
Aug  5 14:02:53 localhost kernel: [163030.313576] bonding: bond0:
Warning: clearing HW address of bond0 while it still has VLANs.
Aug  5 14:02:53 localhost kernel: [163030.313584] bonding: bond0: When
re-adding slaves, make sure the bond's HW address matches its VLANs'.

Although there aren't any real vlans on the bonding, it also causes the
ALB/TLB modes to transmit their learning packets tagged with vlan 0, and
bond_vlan_used() always evaluates to true when 8021q is loaded without
adding any vlans on the bonding.

This is fixed by forbidding the addition/removal of vlan 0 through the
bond's ndo_vlan_rx_add/kill_vid functions, and adding/removing it only when
vlan 0 is in fact being created (or destroyed) on top of a bond interface
in the bond's netdev handling function.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 55 ++++++++++++++++++++++++++++++++++++-----
 1 file changed, 49 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 476df7d..5df8bcd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -434,12 +434,13 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 */
 
 /**
- * bond_vlan_rx_add_vid - Propagates adding an id to slaves
+ * __bond_vlan_rx_add_vid - Propagates adding an id to slaves
  * @bond_dev: bonding net device that got called
+ * @proto: vlan protocol
  * @vid: vlan id being added
  */
-static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
-				__be16 proto, u16 vid)
+static int __bond_vlan_rx_add_vid(struct net_device *bond_dev,
+				  __be16 proto, u16 vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
@@ -468,13 +469,27 @@ unwind:
 	return res;
 }
 
+/* Wrapper for ndo_vlan_rx_add_vid */
+static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
+				__be16 proto, u16 vid)
+{
+	/* don't add vlan 0 through ndo_rx_vlan_add_vid
+	 * it's taken care of in the netdev event code upon NETDEV_REGISTER
+	 */
+	if (!vid)
+		return 0;
+
+	return __bond_vlan_rx_add_vid(bond_dev, proto, vid);
+}
+
 /**
- * bond_vlan_rx_kill_vid - Propagates deleting an id to slaves
+ * __bond_vlan_rx_kill_vid - Propagates deleting an id to slaves
  * @bond_dev: bonding net device that got called
+ * @proto: vlan protocol
  * @vid: vlan id being removed
  */
-static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
-				 __be16 proto, u16 vid)
+static int __bond_vlan_rx_kill_vid(struct net_device *bond_dev,
+				   __be16 proto, u16 vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
@@ -493,6 +508,19 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
 	return 0;
 }
 
+/* Wrapper for ndo_vlan_rx_kill_vid */
+static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
+				 __be16 proto, u16 vid)
+{
+	/* don't remove vlan 0 through ndo_rx_vlan_kill_vid
+	 * it's taken care of in the netdev event code upon NETDEV_UNREGISTER
+	 */
+	if (!vid)
+		return 0;
+
+	return __bond_vlan_rx_kill_vid(bond_dev, proto, vid);
+}
+
 static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *slave_dev)
 {
 	struct vlan_entry *vlan;
@@ -3175,11 +3203,26 @@ static int bond_netdev_event(struct notifier_block *this,
 			     unsigned long event, void *ptr)
 {
 	struct net_device *event_dev = netdev_notifier_info_to_dev(ptr);
+	struct net_device *real_dev;
 
 	pr_debug("event_dev: %s, event: %lx\n",
 		 event_dev ? event_dev->name : "None",
 		 event);
 
+	/* Take care of addition/removal of vlan 0 on top of a bond interface */
+	if (is_vlan_dev(event_dev)) {
+		real_dev = vlan_dev_real_dev(event_dev);
+		if (netif_is_bond_master(real_dev) &&
+		    vlan_dev_vlan_id(event_dev) == 0) {
+			__be16 proto = htons(ETH_P_8021Q);
+
+			if (event == NETDEV_REGISTER)
+				__bond_vlan_rx_add_vid(real_dev, proto, 0);
+			else if (event == NETDEV_UNREGISTER)
+				__bond_vlan_rx_kill_vid(real_dev, proto, 0);
+		}
+	}
+
 	if (!(event_dev->priv_flags & IFF_BONDING))
 		return NOTIFY_DONE;
 
-- 
1.8.1.4
