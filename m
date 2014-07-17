From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next] bonding: make it possible to have unlimited nested upper vlans
Date: Thu, 17 Jul 2014 17:02:23 +0200
Message-ID: <1405609343-3502-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933357AbaGQPGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 11:06:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're limited by a constant level of vlan nestings, and fail to
find anything beyound that level (currently 2).

To fix this - remove the limit of nestings when going through device tree,
and when the end device is found - allocate the needed amount of vlan tags
and return them, instead of found/not found.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_alb.c  |  8 ++--
 drivers/net/bonding/bond_main.c | 82 +++++++++++++++++++++++++----------------
 drivers/net/bonding/bonding.h   |  7 ++--
 3 files changed, 58 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index d3c6801..95dd1f5 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1042,7 +1042,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[],
 	struct bonding *bond = bond_get_bond_by_slave(slave);
 	struct net_device *upper;
 	struct list_head *iter;
-	struct bond_vlan_tag tags[BOND_MAX_VLAN_ENCAP];
+	struct bond_vlan_tag *tags;
 
 	/* send untagged */
 	alb_send_lp_vid(slave, mac_addr, 0, 0);
@@ -1070,10 +1070,12 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[],
 		 * when strict_match is turned off.
 		 */
 		if (netif_is_macvlan(upper) && !strict_match) {
-			memset(tags, 0, sizeof(tags));
-			bond_verify_device_path(bond->dev, upper, tags);
+			tags = bond_verify_device_path(bond->dev, upper, 0);
+			if (IS_ERR_OR_NULL(tags))
+				BUG();
 			alb_send_lp_vid(slave, upper->dev_addr,
 					tags[0].vlan_proto, tags[0].vlan_id);
+			kfree(tags);
 		}
 	}
 	rcu_read_unlock();
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1ff676ca..b9304ee 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2147,7 +2147,7 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 			  struct bond_vlan_tag *tags)
 {
 	struct sk_buff *skb;
-	int i;
+	struct bond_vlan_tag *outer_tag = tags;
 
 	netdev_dbg(slave_dev, "arp %d on slave %s: dst %pI4 src %pI4\n",
 		   arp_op, slave_dev->name, &dest_ip, &src_ip);
@@ -2160,30 +2160,42 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 		return;
 	}
 
+	if (!tags || tags->vlan_proto == VLAN_N_VID)
+		goto xmit;
+
+	tags++;
+
 	/* Go through all the tags backwards and add them to the packet */
-	for (i = BOND_MAX_VLAN_ENCAP - 1; i > 0; i--) {
-		if (!tags[i].vlan_id)
+	while (tags->vlan_proto != VLAN_N_VID) {
+		if (!tags->vlan_id) {
+			tags++;
 			continue;
+		}
 
 		netdev_dbg(slave_dev, "inner tag: proto %X vid %X\n",
-			   ntohs(tags[i].vlan_proto), tags[i].vlan_id);
-		skb = __vlan_put_tag(skb, tags[i].vlan_proto,
-				     tags[i].vlan_id);
+			   ntohs(outer_tag->vlan_proto), tags->vlan_id);
+		skb = __vlan_put_tag(skb, tags->vlan_proto,
+				     tags->vlan_id);
 		if (!skb) {
 			net_err_ratelimited("failed to insert inner VLAN tag\n");
 			return;
 		}
+
+		tags++;
 	}
 	/* Set the outer tag */
-	if (tags[0].vlan_id) {
+	if (outer_tag->vlan_id) {
 		netdev_dbg(slave_dev, "outer tag: proto %X vid %X\n",
-			   ntohs(tags[0].vlan_proto), tags[0].vlan_id);
-		skb = vlan_put_tag(skb, tags[0].vlan_proto, tags[0].vlan_id);
+			   ntohs(outer_tag->vlan_proto), outer_tag->vlan_id);
+		skb = vlan_put_tag(skb, outer_tag->vlan_proto,
+				   outer_tag->vlan_id);
 		if (!skb) {
 			net_err_ratelimited("failed to insert outer VLAN tag\n");
 			return;
 		}
 	}
+
+xmit:
 	arp_xmit(skb);
 }
 
@@ -2193,46 +2205,50 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
  * When the path is validated, collect any vlan information in the
  * path.
  */
-bool bond_verify_device_path(struct net_device *start_dev,
-			     struct net_device *end_dev,
-			     struct bond_vlan_tag *tags)
+struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
+					      struct net_device *end_dev,
+					      int level)
 {
+	struct bond_vlan_tag *tags;
 	struct net_device *upper;
 	struct list_head  *iter;
-	int  idx;
 
-	if (start_dev == end_dev)
-		return true;
+	if (start_dev == end_dev) {
+		tags = kzalloc(sizeof(*tags) * (level + 1), GFP_ATOMIC);
+		if (!tags)
+			return ERR_PTR(-ENOMEM);
+		tags[level].vlan_proto = VLAN_N_VID;
+		return tags;
+	}
 
 	netdev_for_each_upper_dev_rcu(start_dev, upper, iter) {
-		if (bond_verify_device_path(upper, end_dev, tags)) {
-			if (is_vlan_dev(upper)) {
-				idx = vlan_get_encap_level(upper);
-				if (idx >= BOND_MAX_VLAN_ENCAP)
-					return false;
-
-				tags[idx].vlan_proto =
-						    vlan_dev_vlan_proto(upper);
-				tags[idx].vlan_id = vlan_dev_vlan_id(upper);
-			}
-			return true;
+		tags = bond_verify_device_path(upper, end_dev, level + 1);
+		if (IS_ERR_OR_NULL(tags)) {
+			if (IS_ERR(tags))
+				return tags;
+			continue;
 		}
+		if (is_vlan_dev(upper)) {
+			tags[level].vlan_proto = vlan_dev_vlan_proto(upper);
+			tags[level].vlan_id = vlan_dev_vlan_id(upper);
+		}
+
+		return tags;
 	}
 
-	return false;
+	return NULL;
 }
 
 static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
 	struct rtable *rt;
-	struct bond_vlan_tag tags[BOND_MAX_VLAN_ENCAP];
+	struct bond_vlan_tag *tags;
 	__be32 *targets = bond->params.arp_targets, addr;
 	int i;
-	bool ret;
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
 		netdev_dbg(bond->dev, "basa: target %pI4\n", &targets[i]);
-		memset(tags, 0, sizeof(tags));
+		tags = NULL;
 
 		/* Find out through which dev should the packet go */
 		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
@@ -2255,10 +2271,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			goto found;
 
 		rcu_read_lock();
-		ret = bond_verify_device_path(bond->dev, rt->dst.dev, tags);
+		tags = bond_verify_device_path(bond->dev, rt->dst.dev, 0);
 		rcu_read_unlock();
 
-		if (ret)
+		if (!IS_ERR_OR_NULL(tags))
 			goto found;
 
 		/* Not our device - skip */
@@ -2273,6 +2289,8 @@ found:
 		ip_rt_put(rt);
 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 			      addr, tags);
+		if (!tags)
+			kfree(tags);
 	}
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a85ca51..aace510 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -36,7 +36,6 @@
 
 #define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
 
-#define BOND_MAX_VLAN_ENCAP	2
 #define BOND_MAX_ARP_TARGETS	16
 
 #define BOND_DEFAULT_MIIMON	100
@@ -525,9 +524,9 @@ int bond_netlink_init(void);
 void bond_netlink_fini(void);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 const char *bond_slave_link_status(s8 link);
-bool bond_verify_device_path(struct net_device *start_dev,
-			     struct net_device *end_dev,
-			     struct bond_vlan_tag *tags);
+struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
+					      struct net_device *end_dev,
+					      int level);
 
 #ifdef CONFIG_PROC_FS
 void bond_create_proc_entry(struct bonding *bond);
-- 
1.8.4
