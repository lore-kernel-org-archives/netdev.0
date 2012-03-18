From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net V4] bonding: send igmp report for its master
Date: Sun, 18 Mar 2012 11:23:27 +0800
Message-ID: <07f6298b0c2dca06856e6dcdab7f684447b6f199.1332040061.git.panweiping3@gmail.com>
References: <31016.1331869399@death.nxdomain>
Cc: Weiping Pan <panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:50212 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab2CRDSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 23:18:49 -0400
In-Reply-To: <31016.1331869399@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Liang Zheng(lzheng@redhat.com) found that in the following topo,
bonding does not send igmp report when we trigger a fail-over of bonding.

eth0--
      |-- bond0 -- br0
eth1--

modprobe bonding mode=1 miimon=100 resend_igmp=10
ifconfig bond0 up
ifenslave bond0 eth0 eth1

brctl addbr br0
ifconfig br0 192.168.100.2/24 up
brctl addif br0 bond0

Add 192.168.100.2(br0) into a multicast group, like 224.10.10.10,
then trigger a fali-over in bonding.
You can see that parameter "resend_igmp" does not work.

The reason is that when we add br0 into a multicast group,
it does not propagate multicast knowledge down to its ports.

If we choose to propagate multicast knowledge down to all ports for bridge,
then we have to track every change that is done to bridge, and keep a backup
for all ports. It is hard to track, I think.

Instead I choose to modify bonding to send igmp report for its master.

Changelog:
V2: correct comments
V3: move this check into bond_resend_igmp_join_requests()
V4: only send igmp reports if bond is enslaved to a bridge

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_main.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 435984a..4a70e01 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -766,18 +766,30 @@ static void __bond_resend_igmp_join_requests(struct net_device *dev)
  */
 static void bond_resend_igmp_join_requests(struct bonding *bond)
 {
-	struct net_device *vlan_dev;
+	struct net_device *bond_dev, *vlan_dev, *master_dev;
 	struct vlan_entry *vlan;
 
 	read_lock(&bond->lock);
 
+	bond_dev = bond->dev;
+
 	/* rejoin all groups on bond device */
-	__bond_resend_igmp_join_requests(bond->dev);
+	__bond_resend_igmp_join_requests(bond_dev);
+
+	/* 
+	 * if bond is enslaved to a bridge,
+	 * then rejoin all groups on its master
+	 */
+	master_dev = bond_dev->master;
+	if (master_dev)
+		if ((master_dev->priv_flags & IFF_EBRIDGE)
+			&& (bond_dev->priv_flags & IFF_BRIDGE_PORT))
+			__bond_resend_igmp_join_requests(master_dev);
 
 	/* rejoin all groups on vlan devices */
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		rcu_read_lock();
-		vlan_dev = __vlan_find_dev_deep(bond->dev,
+		vlan_dev = __vlan_find_dev_deep(bond_dev,
 						vlan->vlan_id);
 		rcu_read_unlock();
 		if (vlan_dev)
-- 
1.7.4.4
