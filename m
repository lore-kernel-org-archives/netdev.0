From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 2/2] bonding: don't lock when copying/clearing VLAN list on slave
Date: Wed, 21 Jul 2010 15:14:48 -0700
Message-ID: <1279750488-32611-2-git-send-email-fubar@us.ibm.com>
References: <1279750488-32611-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49342 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab0GUWPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 18:15:07 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6LMAVaB025099
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 16:10:31 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6LMEqba047960
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 16:14:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6LMEqcd002204
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 16:14:52 -0600
In-Reply-To: <1279750488-32611-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	When copying VLAN information to or removing from a slave
during slave addition or removal, the bonding code currently holds
the bond->lock for write to prevent concurrent modification of the
vlan_list / vlgrp.

	This is unnecessary, as all of these operations occur under
RTNL.  Holding the bond->lock also caused might_sleep issues for
some drivers' ndo_vlan_* functions.  This patch removes the extra
locking.

	Problem reported by Michael Chan <mchan@broadcom.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bonding/bond_main.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f3b01ce..2cc4cfc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -570,10 +570,8 @@ static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *sla
 	struct vlan_entry *vlan;
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 
-	write_lock_bh(&bond->lock);
-
 	if (!bond->vlgrp)
-		goto out;
+		return;
 
 	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
 	    slave_ops->ndo_vlan_rx_register)
@@ -581,13 +579,10 @@ static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *sla
 
 	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
 	    !(slave_ops->ndo_vlan_rx_add_vid))
-		goto out;
+		return;
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list)
 		slave_ops->ndo_vlan_rx_add_vid(slave_dev, vlan->vlan_id);
-
-out:
-	write_unlock_bh(&bond->lock);
 }
 
 static void bond_del_vlans_from_slave(struct bonding *bond,
@@ -597,10 +592,8 @@ static void bond_del_vlans_from_slave(struct bonding *bond,
 	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 
-	write_lock_bh(&bond->lock);
-
 	if (!bond->vlgrp)
-		goto out;
+		return;
 
 	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
 	    !(slave_ops->ndo_vlan_rx_kill_vid))
@@ -621,9 +614,6 @@ unreg:
 	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
 	    slave_ops->ndo_vlan_rx_register)
 		slave_ops->ndo_vlan_rx_register(slave_dev, NULL);
-
-out:
-	write_unlock_bh(&bond->lock);
 }
 
 /*------------------------------- Link status -------------------------------*/
-- 
1.6.0.2

