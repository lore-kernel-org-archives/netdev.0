From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net V3] bonding: send igmp report for its master
Date: Thu, 15 Mar 2012 11:11:58 +0800
Message-ID: <3072c40712c2f5506fc57937da921da0d3d83450.1331778582.git.panweiping3@gmail.com>
References: <20120314172237.GA12372@quad.redhat.com>
Cc: Weiping Pan <panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120314172237.GA12372@quad.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_main.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 435984a..037fdd3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -766,18 +766,26 @@ static void __bond_resend_igmp_join_requests(struct net_device *dev)
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
+	/* rejoin all groups on its master */
+	master_dev = bond_dev->master;
+	if (unlikely(master_dev)) {
+		__bond_resend_igmp_join_requests(master_dev);
+	}
 
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
