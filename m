From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] bonding: Fix stacked device detection in arp monitoring
Date: Tue,  6 May 2014 13:41:15 -0400
Message-ID: <1399398075-16323-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Patric McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbaEFRld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 13:41:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to commit fbd929f2dce460456807a51e18d623db3db9f077
	bonding: support QinQ for bond arp interval

the arp monitoring code allowed for proper detection of devices
stacked on top of vlans.  Since the above commit, the
code can still detect a device stacked on top of single
vlan, but not a device stacked on top of Q-in-Q configuration.
The search will only set the inner vlan tag if the route
device is the vlan device.  However, this is not always the
case, as it is possible to extend the stacked configuration.

With this patch it is possible to provision devices on
top Q-in-Q vlan configuration that should be used as
a source of ARP monitoring information.

For example:
ip link add link bond0 vlan10 type vlan proto 802.1q id 10
ip link add link vlan10 vlan100 type vlan proto 802.1q id 100
ip link add link vlan100 type macvlan

Note:  This patch limits the number of stacked VLANs to 2,
just like before.  The original, however had another issue
in that if we had more then 2 levels of VLANs, we would end
up generating incorrectly tagged traffic.  This is no longer
possible.

Fixes: fbd929f2dce460456807a51e18d623db3db9f077 (bonding: support QinQ for bond arp interval)
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Veaceslav Falico <vfalico@redhat.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Ding Tianhong <dingtianhong@huawei.com>
CC: Patric McHardy <kaber@trash.net>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/bonding/bond_main.c | 90 +++++++++++++++++------------------------
 1 file changed, 37 insertions(+), 53 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9d08e00..4822728 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2164,22 +2164,46 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 	arp_xmit(skb);
 }
 
+static bool bond_collect_vlans(struct net_device *start, struct net_device *end,
+				struct bond_vlan_tag *tag, int idx)
+{
+	struct net_device *upper;
+	struct list_head  *iter;
+
+	/* We do not support more then 2 levels of VLAN nesting */
+	if (idx >= 2)
+		return false;
+
+	netdev_for_each_all_upper_dev_rcu(start, upper, iter) {
+		if (is_vlan_dev(upper)) {
+			tag[idx].vlan_proto = vlan_dev_vlan_proto(upper);
+			tag[idx].vlan_id = vlan_dev_vlan_id(upper);
+			idx++;
+		}
+		if (upper == end)
+			return true;
+
+		/* Look at upper devices list only if current device
+		 * is a vlan
+		 */
+		if (is_vlan_dev(upper) && bond_collect_vlans(upper, end, tag, idx))
+			return true;
+	}
+	return false;
+}
+
 
 static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
-	struct net_device *upper, *vlan_upper;
-	struct list_head *iter, *vlan_iter;
 	struct rtable *rt;
-	struct bond_vlan_tag inner, outer;
+	struct bond_vlan_tag tags[2];
 	__be32 *targets = bond->params.arp_targets, addr;
 	int i;
+	bool ret;
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
 		pr_debug("basa: target %pI4\n", &targets[i]);
-		inner.vlan_proto = 0;
-		inner.vlan_id = 0;
-		outer.vlan_proto = 0;
-		outer.vlan_id = 0;
+		memset(tags, 0, sizeof(tags));
 
 		/* Find out through which dev should the packet go */
 		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
@@ -2192,7 +2216,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 				net_warn_ratelimited("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
 						     bond->dev->name,
 						     &targets[i]);
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, &inner, &outer);
+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, &tags[1], &tags[0]);
 			continue;
 		}
 
@@ -2201,52 +2225,12 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			goto found;
 
 		rcu_read_lock();
-		/* first we search only for vlan devices. for every vlan
-		 * found we verify its upper dev list, searching for the
-		 * rt->dst.dev. If found we save the tag of the vlan and
-		 * proceed to send the packet.
-		 */
-		netdev_for_each_all_upper_dev_rcu(bond->dev, vlan_upper,
-						  vlan_iter) {
-			if (!is_vlan_dev(vlan_upper))
-				continue;
-
-			if (vlan_upper == rt->dst.dev) {
-				outer.vlan_proto = vlan_dev_vlan_proto(vlan_upper);
-				outer.vlan_id = vlan_dev_vlan_id(vlan_upper);
-				rcu_read_unlock();
-				goto found;
-			}
-			netdev_for_each_all_upper_dev_rcu(vlan_upper, upper,
-							  iter) {
-				if (upper == rt->dst.dev) {
-					/* If the upper dev is a vlan dev too,
-					 *  set the vlan tag to inner tag.
-					 */
-					if (is_vlan_dev(upper)) {
-						inner.vlan_proto = vlan_dev_vlan_proto(upper);
-						inner.vlan_id = vlan_dev_vlan_id(upper);
-					}
-					outer.vlan_proto = vlan_dev_vlan_proto(vlan_upper);
-					outer.vlan_id = vlan_dev_vlan_id(vlan_upper);
-					rcu_read_unlock();
-					goto found;
-				}
-			}
-		}
-
-		/* if the device we're looking for is not on top of any of
-		 * our upper vlans, then just search for any dev that
-		 * matches, and in case it's a vlan - save the id
-		 */
-		netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
-			if (upper == rt->dst.dev) {
-				rcu_read_unlock();
-				goto found;
-			}
-		}
+		ret = bond_collect_vlans(bond->dev, rt->dst.dev, tags, 0);
 		rcu_read_unlock();
 
+		if (ret)
+			goto found;
+
 		/* Not our device - skip */
 		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 			 bond->dev->name, &targets[i],
@@ -2259,7 +2243,7 @@ found:
 		addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
 		ip_rt_put(rt);
 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
-			      addr, &inner, &outer);
+			      addr, &tags[1], &tags[0]);
 	}
 }
 
-- 
1.9.0
