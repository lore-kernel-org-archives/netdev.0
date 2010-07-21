From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 1/2] bonding: change test for presence of VLANs
Date: Wed, 21 Jul 2010 15:14:47 -0700
Message-ID: <1279750488-32611-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Pedro Garcia <pedro.netdev@dondevamos.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:48271 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab0GUWO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 18:14:58 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6LM70lf029997
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 16:07:00 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o6LMEpIP119804
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 16:14:51 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6LMEpoq002151
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 16:14:51 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	After commit:

commit ad1afb00393915a51c21b1ae8704562bf036855f
Author: Pedro Garcia <pedro.netdev@dondevamos.com>
Date:   Sun Jul 18 15:38:44 2010 -0700

    vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p packet)

	it is now regular practice for a VLAN "add vid" for VLAN 0 to
arrive prior to any VLAN registration or creation of a vlan_group.

	This patch updates the bonding code that tests for the presence
of VLANs configured above bonding.  The new logic tests for bond->vlgrp
to determine if a registration has occured, instead of testing that
bonding's internal vlan_list is empty.

	The old code would panic when vlan_list was not empty, but
vlgrp was still NULL (because only an "add vid" for VLAN 0 had occured).

	Bonding still adds VLAN 0 to its internal list so that 802.1p
frames are handled correctly on transmit when non-VLAN accelerated
slaves are members of the bond.  The test against bond->vlan_list
remains in bond_dev_queue_xmit for this reason.

	Modification to the bond->vlgrp now occurs under lock (in
addition to RTNL), because not all inspections of it occur under RTNL.

	Additionally, because 8021q will never issue a "kill vid" for
VLAN 0, there is now logic in bond_uninit to release any remaining
entries from vlan_list.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Pedro Garcia <pedro.netdev@dondevamos.com> 
Cc: Patrick McHardy <kaber@trash.net>
---
 drivers/net/bonding/bond_alb.c  |    4 ++--
 drivers/net/bonding/bond_main.c |   30 +++++++++++++++++++++++-------
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 3662d6e..e3b35d0 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -682,7 +682,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 			client_info->ntt = 0;
 		}
 
-		if (!list_empty(&bond->vlan_list)) {
+		if (bond->vlgrp) {
 			if (!vlan_get_tag(skb, &client_info->vlan_id))
 				client_info->tag = 1;
 		}
@@ -904,7 +904,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 		skb->priority = TC_PRIO_CONTROL;
 		skb->dev = slave->dev;
 
-		if (!list_empty(&bond->vlan_list)) {
+		if (bond->vlgrp) {
 			struct vlan_entry *vlan;
 
 			vlan = bond_next_vlan(bond,
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 20f45cb..f3b01ce 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -424,6 +424,7 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 {
 	unsigned short uninitialized_var(vlan_id);
 
+	/* Test vlan_list not vlgrp to catch and handle 802.1p tags */
 	if (!list_empty(&bond->vlan_list) &&
 	    !(slave_dev->features & NETIF_F_HW_VLAN_TX) &&
 	    vlan_get_tag(skb, &vlan_id) == 0) {
@@ -487,7 +488,9 @@ static void bond_vlan_rx_register(struct net_device *bond_dev,
 	struct slave *slave;
 	int i;
 
+	write_lock(&bond->lock);
 	bond->vlgrp = grp;
+	write_unlock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		struct net_device *slave_dev = slave->dev;
@@ -569,7 +572,7 @@ static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *sla
 
 	write_lock_bh(&bond->lock);
 
-	if (list_empty(&bond->vlan_list))
+	if (!bond->vlgrp)
 		goto out;
 
 	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
@@ -596,7 +599,7 @@ static void bond_del_vlans_from_slave(struct bonding *bond,
 
 	write_lock_bh(&bond->lock);
 
-	if (list_empty(&bond->vlan_list))
+	if (!bond->vlgrp)
 		goto out;
 
 	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
@@ -604,6 +607,8 @@ static void bond_del_vlans_from_slave(struct bonding *bond,
 		goto unreg;
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		if (!vlan->vlan_id)
+			continue;
 		/* Save and then restore vlan_dev in the grp array,
 		 * since the slave's driver might clear it.
 		 */
@@ -1443,7 +1448,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
-		if (!list_empty(&bond->vlan_list)) {
+		if (bond->vlgrp) {
 			pr_err("%s: Error: cannot enslave VLAN challenged slave %s on VLAN enabled bond %s\n",
 			       bond_dev->name, slave_dev->name, bond_dev->name);
 			return -EPERM;
@@ -1942,7 +1947,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
-		if (list_empty(&bond->vlan_list)) {
+		if (!bond->vlgrp) {
 			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 		} else {
 			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
@@ -2134,9 +2139,9 @@ static int bond_release_all(struct net_device *bond_dev)
 	 */
 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
-	if (list_empty(&bond->vlan_list))
+	if (!bond->vlgrp) {
 		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
-	else {
+	} else {
 		pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
 			   bond_dev->name, bond_dev->name);
 		pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
@@ -2569,7 +2574,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		if (!targets[i])
 			break;
 		pr_debug("basa: target %x\n", targets[i]);
-		if (list_empty(&bond->vlan_list)) {
+		if (!bond->vlgrp) {
 			pr_debug("basa: empty vlan: arp_send\n");
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 				      bond->master_ip, 0);
@@ -2658,6 +2663,9 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 				bond->master_ip, 0);
 	}
 
+	if (!bond->vlgrp)
+		return;
+
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 		if (vlan->vlan_ip) {
@@ -3590,6 +3598,8 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 		}
 
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+			if (!bond->vlgrp)
+				continue;
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
 				switch (event) {
@@ -4686,6 +4696,7 @@ static void bond_work_cancel_all(struct bonding *bond)
 static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct vlan_entry *vlan, *tmp;
 
 	bond_netpoll_cleanup(bond_dev);
 
@@ -4699,6 +4710,11 @@ static void bond_uninit(struct net_device *bond_dev)
 	bond_remove_proc_entry(bond);
 
 	__hw_addr_flush(&bond->mc_list);
+
+	list_for_each_entry_safe(vlan, tmp, &bond->vlan_list, vlan_list) {
+		list_del(&vlan->vlan_list);
+		kfree(vlan);
+	}
 }
 
 /*------------------------- Module initialization ---------------------------*/
-- 
1.6.0.2

