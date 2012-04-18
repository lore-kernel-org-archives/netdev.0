From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next] bonding,vlan: propagate MAC failover changes to VLANs
Date: Wed, 18 Apr 2012 11:02:43 -0700
Message-ID: <10757.1334772163@death.nxdomain>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:45382 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765Ab2DRSCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 14:02:53 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 18 Apr 2012 14:02:52 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id AE42D38C8063
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 14:02:49 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3II2noJ238876
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 14:02:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3II2mJe030952
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 15:02:49 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	With bonding's fail_over_mac=active, during failover the MAC
address of the bond itself changes to match that of the slave.

	This patch adds a notifier call to cause VLANs stacked atop the
bonding to also change their MAC addresses to the new address when a
failover occurs.

	While it is legal for a VLAN to have a MAC address that differs
from the underlying device, at least one device (qeth) that requires the
use of fail_over_mac for bonding cannot handle the VLAN's MAC differing
from that of the bond; thus, it needs the MAC change to propagate up
to any VLANs when fail_over_mac is set to active.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_main.c |    2 ++
 include/linux/netdevice.h       |    1 +
 net/8021q/vlan.c                |    7 +++++++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 44e6a64..7a92e35 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -896,6 +896,8 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 			       new_active->dev->addr_len);
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
+			call_netdevice_notifiers(NETDEV_PROPAGATE_ADDR,
+						 bond->dev);
 			call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
 			read_lock(&bond->lock);
 			write_lock_bh(&bond->curr_slave_lock);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e0b70e9..2fe9697 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1559,6 +1559,7 @@ struct packet_type {
 #define NETDEV_RELEASE		0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
+#define NETDEV_PROPAGATE_ADDR	0x0015
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index efea35b..29da25f 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -303,6 +303,8 @@ static void vlan_transfer_features(struct net_device *dev,
 
 static void __vlan_device_event(struct net_device *dev, unsigned long event)
 {
+	struct net_device *realdev;
+
 	switch (event) {
 	case NETDEV_CHANGENAME:
 		vlan_proc_rem_dev(dev);
@@ -317,6 +319,10 @@ static void __vlan_device_event(struct net_device *dev, unsigned long event)
 	case NETDEV_UNREGISTER:
 		vlan_proc_rem_dev(dev);
 		break;
+	case NETDEV_PROPAGATE_ADDR:
+		realdev = vlan_dev_priv(dev)->real_dev;
+		memcpy(dev->dev_addr, realdev->dev_addr, ETH_ALEN);
+		break;
 	}
 }
 
@@ -464,6 +470,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_BONDING_FAILOVER:
+	case NETDEV_PROPAGATE_ADDR:
 		/* Propagate to vlan devices */
 		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
-- 
1.7.7
