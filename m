From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v4 07/13] bonding: make bond_arp_send_all use upper device list
Date: Wed, 28 Aug 2013 23:25:10 +0200
Message-ID: <1377725116-31126-8-git-send-email-vfalico@redhat.com>
References: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228Ab3H1VZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 17:25:09 -0400
In-Reply-To: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bond_arp_send_all() is aware only of vlans, which breaks
configurations like bond <- bridge (or any other 'upper' device) with IP
(which is quite a common scenario for virt setups).

To fix this we convert the bond_arp_send_all() to first verify if the rt
device is the bond itself, and if not - to go through its list of upper
vlans and their respectiv upper devices (if the vlan's upper device matches
- tag the packet), if still not found - go through all of our upper list
devices to see if any of them match the route device for the target. If the
match is a vlan device - we also save its vlan_id and tag it in
bond_arp_send().

Also, clean the function a bit to be more readable.

CC: Vlad Yasevich <vyasevic@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v1: use netdev_for_each_upper_dev()
    v2: use netdev_for_each_upper_dev_rcu()
    v3: no change
    v4: first search for any device that's on top of our upper vlans, to spot a
        config like "bond <- vlan <- bridge (ip address)", and only after that
        go through all devices.

 drivers/net/bonding/bond_main.c | 102 ++++++++++++++++++++--------------------
 1 file changed, 51 insertions(+), 51 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7407e65..28f4ad0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2444,30 +2444,16 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 
 static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
-	int i, vlan_id;
-	__be32 *targets = bond->params.arp_targets;
-	struct vlan_entry *vlan;
-	struct net_device *vlan_dev = NULL;
+	struct net_device *upper, *vlan_upper;
+	struct list_head *iter, *vlan_iter;
 	struct rtable *rt;
+	__be32 *targets = bond->params.arp_targets, addr;
+	int i, vlan_id;
 
-	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
-		__be32 addr;
-		if (!targets[i])
-			break;
+	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
 		pr_debug("basa: target %pI4\n", &targets[i]);
-		if (!bond_vlan_used(bond)) {
-			pr_debug("basa: empty vlan: arp_send\n");
-			addr = bond_confirm_addr(bond->dev, targets[i], 0);
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
-				      addr, 0);
-			continue;
-		}
 
-		/*
-		 * If VLANs are configured, we do a route lookup to
-		 * determine which VLAN interface would be used, so we
-		 * can tag the ARP with the proper VLAN tag.
-		 */
+		/* Find out through which dev should the packet go */
 		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
 				     RTO_ONLINK, 0);
 		if (IS_ERR(rt)) {
@@ -2478,47 +2464,61 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			continue;
 		}
 
-		/*
-		 * This target is not on a VLAN
-		 */
-		if (rt->dst.dev == bond->dev) {
-			ip_rt_put(rt);
-			pr_debug("basa: rtdev == bond->dev: arp_send\n");
-			addr = bond_confirm_addr(bond->dev, targets[i], 0);
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
-				      addr, 0);
-			continue;
-		}
-
 		vlan_id = 0;
-		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			rcu_read_lock();
-			vlan_dev = __vlan_find_dev_deep(bond->dev,
-							htons(ETH_P_8021Q),
-							vlan->vlan_id);
-			rcu_read_unlock();
-			if (vlan_dev == rt->dst.dev) {
-				vlan_id = vlan->vlan_id;
-				pr_debug("basa: vlan match on %s %d\n",
-				       vlan_dev->name, vlan_id);
-				break;
+
+		/* bond device itself */
+		if (rt->dst.dev == bond->dev)
+			goto found;
+
+		rcu_read_lock();
+		/* first we search only for vlan devices. for every vlan
+		 * found we verify its upper dev list, searching for the
+		 * rt->dst.dev. If found we save the tag of the vlan and
+		 * proceed to send the packet.
+		 *
+		 * TODO: QinQ?
+		 */
+		netdev_for_each_upper_dev_rcu(bond->dev, vlan_upper, vlan_iter) {
+			if (!is_vlan_dev(vlan_upper))
+				continue;
+			netdev_for_each_upper_dev_rcu(vlan_upper, upper, iter) {
+				if (upper == rt->dst.dev) {
+					vlan_id = vlan_dev_vlan_id(vlan_upper);
+					rcu_read_unlock();
+					goto found;
+				}
 			}
 		}
 
-		if (vlan_id && vlan_dev) {
-			ip_rt_put(rt);
-			addr = bond_confirm_addr(vlan_dev, targets[i], 0);
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
-				      addr, vlan_id);
-			continue;
+		/* if the device we're looking for is not on top of any of
+		 * our upper vlans, then just search for any dev that
+		 * matches, and in case it's a vlan - save the id
+		 */
+		netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
+			if (upper == rt->dst.dev) {
+				/* if it's a vlan - get its VID */
+				if (is_vlan_dev(upper))
+					vlan_id = vlan_dev_vlan_id(upper);
+
+				rcu_read_unlock();
+				goto found;
+			}
 		}
+		rcu_read_unlock();
 
-		if (net_ratelimit()) {
+		/* Not our device - skip */
+		if (net_ratelimit())
 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 				   bond->dev->name, &targets[i],
 				   rt->dst.dev ? rt->dst.dev->name : "NULL");
-		}
 		ip_rt_put(rt);
+		continue;
+
+found:
+		addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
+		ip_rt_put(rt);
+		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
+			      addr, vlan_id);
 	}
 }
 
-- 
1.8.4
