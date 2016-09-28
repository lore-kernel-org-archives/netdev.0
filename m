From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] Add netdev all_adj_list refcnt propagation to fix panic
Date: Wed, 28 Sep 2016 11:06:51 -0700
Message-ID: <1475086011-5588-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vfalico@gmail.com, nikolay@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, acollins@cradlepoint.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33181 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcI1SG5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 14:06:57 -0400
Received: by mail-pf0-f182.google.com with SMTP id 21so19834347pfy.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 11:06:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Collins posted this patch as RFC in March:
    http://patchwork.ozlabs.org/patch/603101/

It has apparently fallen through the cracks and never applied.

It solves a refcnt problem (thanks Nik for pointing out this patch)
with stacked devices that involves macvlan on a bridge, a bond into
the bridge, and the bridge and macvlan are enslaved to a vrf:

        +--------+
        |  myvrf |
        +--------+
          |    |
          |  +---------+
          |  | macvlan |
          |  +---------+
          |    |
      +----------+
      |  bridge  |
      +----------+
          |
      +--------+
      | bond0  |
      +--------+
          |
      +--------+
      |  swp3  |
      +--------+

Deleting bond0 hangs waiting for bond0 to become free. The splat in dmesg
is:

[  206.485340] ------------[ cut here ]------------
[  206.486052] WARNING: CPU: 0 PID: 746 at /home/dsa/kernel-3.git/net/core/dev.c:6772 rollback_registered_many+0x28a/0x2da
[  206.487563] Modules linked in: macvlan bonding bridge stp llc vrf
[  206.488946] CPU: 0 PID: 746 Comm: ifdown Not tainted 4.8.0-rc7+ #144
[  206.489768] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  206.490973]  0000000000000000 ffff88003b3a3ca8 ffffffff81287ad3 0000000000000000
[  206.491939]  0000000000000000 ffff88003b3a3ce8 ffffffff8104f19d 00001a743b3a3b58
[  206.492914]  ffff88003c93e000 ffff88003b3a3d48 ffff88003c877400 ffff88003b3a3d48
[  206.493873] Call Trace:
[  206.494184]  [<ffffffff81287ad3>] dump_stack+0x81/0xb6
[  206.494805]  [<ffffffff8104f19d>] __warn+0xc5/0xe0
[  206.495382]  [<ffffffff8104f265>] warn_slowpath_null+0x18/0x1a
[  206.496094]  [<ffffffff81412703>] rollback_registered_many+0x28a/0x2da
[  206.496888]  [<ffffffff8141277c>] rollback_registered+0x29/0x36
[  206.497596]  [<ffffffff81412950>] unregister_netdevice_queue+0x6a/0xa6
[  206.498383]  [<ffffffffa004ff10>] bonding_store_bonds+0x132/0x186 [bonding]
[  206.499209]  [<ffffffff8133baff>] class_attr_store+0x1e/0x20
[  206.499893]  [<ffffffff811c21ce>] sysfs_kf_write+0x44/0x4b
[  206.500558]  [<ffffffff811c14cb>] kernfs_fop_write+0x113/0x15d
[  206.501269]  [<ffffffff8116216b>] __vfs_write+0x21/0xa0
[  206.501897]  [<ffffffff810833cf>] ? percpu_down_read+0x4e/0x7a
[  206.502595]  [<ffffffff81164f25>] ? __sb_start_write+0x5a/0xab
[  206.503302]  [<ffffffff81164f25>] ? __sb_start_write+0x5a/0xab
[  206.504015]  [<ffffffff81162d7f>] vfs_write+0xa2/0xc6
[  206.504637]  [<ffffffff8116397a>] SyS_write+0x4b/0x79
[  206.505251]  [<ffffffff8150833c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[  206.506054] ---[ end trace a578aa9ea7e7176a ]---
[  206.512017] PF_BRIDGE: RTM_SETLINK with unknown ifindex
[  216.765567] unregister_netdevice: waiting for bond0 to become free. Usage count = 1

The splate is from this line in rollback_registered_many():

                WARN_ON(netdev_has_any_upper_dev(dev));
  ---

This is the original commit message from Andrew:

This is an RFC patch to fix a relatively easily reproducible kernel
panic related to the all_adj_list handling for netdevs in recent kernels.

This is more to generate discussion than anything else.  I don't
particularly like this approach, I'm hoping someone has a better idea.

The following sequence of commands will reproduce the issue:

ip link add link eth0 name eth0.100 type vlan id 100
ip link add link eth0 name eth0.200 type vlan id 200
ip link add name testbr type bridge
ip link set eth0.100 master testbr
ip link set eth0.200 master testbr
ip link add link testbr mac0 type macvlan
ip link delete dev testbr

This creates an upper/lower tree of (excuse the poor ASCII art):

            /---eth0.100-eth0
mac0-testbr-
            \---eth0.200-eth0

When testbr is deleted, the all_adj_lists are walked, and eth0 is deleted twice from
the mac0 list. Unfortunately, during setup in __netdev_upper_dev_link, only one
reference to eth0 is added, so this results in a panic.

This change adds reference count propagation so things are handled properly.

Matthias Schiffer reported a similar crash in batman-adv:

https://github.com/freifunk-gluon/gluon/issues/680
https://www.open-mesh.org/issues/247

which this patch also seems to resolve.

Patch is from Andrew Collins <acollins@cradlepoint.com>, but did not have
a formal sign-off. The patch applies to top of tree, so no change made on
my part I just pulled it off the web.

From: Andrew Collins <acollins@cradlepoint.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/dev.c | 69 ++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 38 insertions(+), 31 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c0c291f721d6..84963c99763a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5589,6 +5589,7 @@ static inline bool netdev_adjacent_is_neigh_list(struct net_device *dev,
 
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
+					u16 ref_nr,
 					struct list_head *dev_list,
 					void *private, bool master)
 {
@@ -5598,7 +5599,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	adj = __netdev_find_adj(adj_dev, dev_list);
 
 	if (adj) {
-		adj->ref_nr++;
+		adj->ref_nr += ref_nr;
 		return 0;
 	}
 
@@ -5608,7 +5609,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	adj->dev = adj_dev;
 	adj->master = master;
-	adj->ref_nr = 1;
+	adj->ref_nr = ref_nr;
 	adj->private = private;
 	dev_hold(adj_dev);
 
@@ -5647,6 +5648,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 static void __netdev_adjacent_dev_remove(struct net_device *dev,
 					 struct net_device *adj_dev,
+					 u16 ref_nr,
 					 struct list_head *dev_list)
 {
 	struct netdev_adjacent *adj;
@@ -5659,10 +5661,10 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 		BUG();
 	}
 
-	if (adj->ref_nr > 1) {
-		pr_debug("%s to %s ref_nr-- = %d\n", dev->name, adj_dev->name,
-			 adj->ref_nr-1);
-		adj->ref_nr--;
+	if (adj->ref_nr > ref_nr) {
+		pr_debug("%s to %s ref_nr-%d = %d\n", dev->name, adj_dev->name,
+			 ref_nr, adj->ref_nr - ref_nr);
+		adj->ref_nr -= ref_nr;
 		return;
 	}
 
@@ -5681,21 +5683,22 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 
 static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 					    struct net_device *upper_dev,
+					    u16 ref_nr,
 					    struct list_head *up_list,
 					    struct list_head *down_list,
 					    void *private, bool master)
 {
 	int ret;
 
-	ret = __netdev_adjacent_dev_insert(dev, upper_dev, up_list, private,
-					   master);
+	ret = __netdev_adjacent_dev_insert(dev, upper_dev, ref_nr, up_list,
+					   private, master);
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_insert(upper_dev, dev, down_list, private,
-					   false);
+	ret = __netdev_adjacent_dev_insert(upper_dev, dev, ref_nr, down_list,
+					   private, false);
 	if (ret) {
-		__netdev_adjacent_dev_remove(dev, upper_dev, up_list);
+		__netdev_adjacent_dev_remove(dev, upper_dev, ref_nr, up_list);
 		return ret;
 	}
 
@@ -5703,9 +5706,10 @@ static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 }
 
 static int __netdev_adjacent_dev_link(struct net_device *dev,
-				      struct net_device *upper_dev)
+				      struct net_device *upper_dev,
+				      u16 ref_nr)
 {
-	return __netdev_adjacent_dev_link_lists(dev, upper_dev,
+	return __netdev_adjacent_dev_link_lists(dev, upper_dev, ref_nr,
 						&dev->all_adj_list.upper,
 						&upper_dev->all_adj_list.lower,
 						NULL, false);
@@ -5713,17 +5717,19 @@ static int __netdev_adjacent_dev_link(struct net_device *dev,
 
 static void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
 					       struct net_device *upper_dev,
+					       u16 ref_nr,
 					       struct list_head *up_list,
 					       struct list_head *down_list)
 {
-	__netdev_adjacent_dev_remove(dev, upper_dev, up_list);
-	__netdev_adjacent_dev_remove(upper_dev, dev, down_list);
+	__netdev_adjacent_dev_remove(dev, upper_dev, ref_nr, up_list);
+	__netdev_adjacent_dev_remove(upper_dev, dev, ref_nr, down_list);
 }
 
 static void __netdev_adjacent_dev_unlink(struct net_device *dev,
-					 struct net_device *upper_dev)
+					 struct net_device *upper_dev,
+					 u16 ref_nr)
 {
-	__netdev_adjacent_dev_unlink_lists(dev, upper_dev,
+	__netdev_adjacent_dev_unlink_lists(dev, upper_dev, ref_nr,
 					   &dev->all_adj_list.upper,
 					   &upper_dev->all_adj_list.lower);
 }
@@ -5732,17 +5738,17 @@ static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 						struct net_device *upper_dev,
 						void *private, bool master)
 {
-	int ret = __netdev_adjacent_dev_link(dev, upper_dev);
+	int ret = __netdev_adjacent_dev_link(dev, upper_dev, 1);
 
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev,
+	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev, 1,
 					       &dev->adj_list.upper,
 					       &upper_dev->adj_list.lower,
 					       private, master);
 	if (ret) {
-		__netdev_adjacent_dev_unlink(dev, upper_dev);
+		__netdev_adjacent_dev_unlink(dev, upper_dev, 1);
 		return ret;
 	}
 
@@ -5752,8 +5758,8 @@ static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 static void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
 						   struct net_device *upper_dev)
 {
-	__netdev_adjacent_dev_unlink(dev, upper_dev);
-	__netdev_adjacent_dev_unlink_lists(dev, upper_dev,
+	__netdev_adjacent_dev_unlink(dev, upper_dev, 1);
+	__netdev_adjacent_dev_unlink_lists(dev, upper_dev, 1,
 					   &dev->adj_list.upper,
 					   &upper_dev->adj_list.lower);
 }
@@ -5806,7 +5812,8 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
 			pr_debug("Interlinking %s with %s, non-neighbour\n",
 				 i->dev->name, j->dev->name);
-			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
+			ret = __netdev_adjacent_dev_link(i->dev, j->dev,
+							 i->ref_nr);
 			if (ret)
 				goto rollback_mesh;
 		}
@@ -5816,7 +5823,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
 		pr_debug("linking %s's upper device %s with %s\n",
 			 upper_dev->name, i->dev->name, dev->name);
-		ret = __netdev_adjacent_dev_link(dev, i->dev);
+		ret = __netdev_adjacent_dev_link(dev, i->dev, i->ref_nr);
 		if (ret)
 			goto rollback_upper_mesh;
 	}
@@ -5825,7 +5832,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
 		pr_debug("linking %s's lower device %s with %s\n", dev->name,
 			 i->dev->name, upper_dev->name);
-		ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
+		ret = __netdev_adjacent_dev_link(i->dev, upper_dev, i->ref_nr);
 		if (ret)
 			goto rollback_lower_mesh;
 	}
@@ -5843,7 +5850,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
 		if (i == to_i)
 			break;
-		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
+		__netdev_adjacent_dev_unlink(i->dev, upper_dev, i->ref_nr);
 	}
 
 	i = NULL;
@@ -5853,7 +5860,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
 		if (i == to_i)
 			break;
-		__netdev_adjacent_dev_unlink(dev, i->dev);
+		__netdev_adjacent_dev_unlink(dev, i->dev, i->ref_nr);
 	}
 
 	i = j = NULL;
@@ -5865,7 +5872,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
 			if (i == to_i && j == to_j)
 				break;
-			__netdev_adjacent_dev_unlink(i->dev, j->dev);
+			__netdev_adjacent_dev_unlink(i->dev, j->dev, i->ref_nr);
 		}
 		if (i == to_i)
 			break;
@@ -5945,16 +5952,16 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 	 */
 	list_for_each_entry(i, &dev->all_adj_list.lower, list)
 		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list)
-			__netdev_adjacent_dev_unlink(i->dev, j->dev);
+			__netdev_adjacent_dev_unlink(i->dev, j->dev, i->ref_nr);
 
 	/* remove also the devices itself from lower/upper device
 	 * list
 	 */
 	list_for_each_entry(i, &dev->all_adj_list.lower, list)
-		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
+		__netdev_adjacent_dev_unlink(i->dev, upper_dev, i->ref_nr);
 
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list)
-		__netdev_adjacent_dev_unlink(dev, i->dev);
+		__netdev_adjacent_dev_unlink(dev, i->dev, i->ref_nr);
 
 	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
 				      &changeupper_info.info);
-- 
2.1.4
