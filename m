From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 3/8] bonding: make bond_arp_send_all use upper device list
Date: Mon, 26 Aug 2013 18:28:48 +0200
Message-ID: <1377534533-6944-4-git-send-email-vfalico@redhat.com>
References: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130Ab3HZQ2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 12:28:51 -0400
In-Reply-To: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bond_arp_send_all() is aware only of vlans, which breaks
configurations like bond <- bridge (or any other 'upper' device) with IP
(which is quite a common scenario for virt setups).

To fix this we convert the bond_arp_send_all() to first verify if the rt
device is the bond itself, and if not - to go through its list of upper
devices to see if any of them match the route device for the target. If the
match is a vlan device - we also save its vlan_id and tag it in
bond_arp_send().

Also, clean the function a bit to be more readable.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   84 ++++++++++++++------------------------
 1 files changed, 31 insertions(+), 53 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7407e65..f8927b3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2444,30 +2444,15 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 
 static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
-	int i, vlan_id;
-	__be32 *targets = bond->params.arp_targets;
-	struct vlan_entry *vlan;
-	struct net_device *vlan_dev = NULL;
+	struct netdev_upper *upper;
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
@@ -2478,47 +2463,40 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
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
-			}
-		}
 
-		if (vlan_id && vlan_dev) {
-			ip_rt_put(rt);
-			addr = bond_confirm_addr(vlan_dev, targets[i], 0);
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
-				      addr, vlan_id);
-			continue;
+		/* bond device itself */
+		if (rt->dst.dev == bond->dev)
+			goto found;
+
+		/* search for upper device, like vlan/bridge/team/etc */
+		rcu_read_lock();
+		list_for_each_entry_rcu(upper, &bond->dev->upper_dev_list,
+					list) {
+			if (upper->dev == rt->dst.dev) {
+				/* if it's a vlan - get its VID */
+				if (is_vlan_dev(rt->dst.dev))
+					vlan_id = vlan_dev_vlan_id(rt->dst.dev);
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
1.7.1
