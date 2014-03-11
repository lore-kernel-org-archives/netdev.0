From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/3] bonding: support different vlan proto for bond_arp_send()
Date: Tue, 11 Mar 2014 11:43:41 +0800
Message-ID: <1394509422-8704-3-git-send-email-dingtianhong@huawei.com>
References: <1394509422-8704-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:57428 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126AbaCKDqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:46:02 -0400
In-Reply-To: <1394509422-8704-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan support 2 proto: 802.1q and 802.1ad, but the bonding dev always
send ARP frames by proto 802.1q regardless the vlan dev is 802.1q or 802.1ad,
so make the bond dev support to send ARP according its real vlan proto.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 324389b..1494d8e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2124,12 +2124,15 @@ static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
  * switches in VLAN mode (especially if ports are configured as
  * "native" to a VLAN) might not pass non-tagged frames.
  */
-static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_ip, __be32 src_ip, unsigned short vlan_id)
+static void bond_arp_send(struct net_device *slave_dev, int arp_op,
+			  __be32 dest_ip, __be32 src_ip,
+			  __be16 vlan_proto, unsigned short vlan_id)
 {
 	struct sk_buff *skb;
 
-	pr_debug("arp %d on slave %s: dst %pI4 src %pI4 vid %d\n",
-		 arp_op, slave_dev->name, &dest_ip, &src_ip, vlan_id);
+	pr_debug("arp %d on slave %s: dst %pI4 src %pI4 proto %x vid %d\n",
+		 arp_op, slave_dev->name, &dest_ip, &src_ip, vlan_proto,
+		 vlan_id);
 
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
@@ -2139,7 +2142,7 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 		return;
 	}
 	if (vlan_id) {
-		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
+		skb = vlan_put_tag(skb, vlan_proto, vlan_id);
 		if (!skb) {
 			pr_err("failed to insert VLAN tag\n");
 			return;
@@ -2156,6 +2159,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 	struct rtable *rt;
 	__be32 *targets = bond->params.arp_targets, addr;
 	int i, vlan_id;
+	__be16 vlan_proto = 0;
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
 		pr_debug("basa: target %pI4\n", &targets[i]);
@@ -2170,7 +2174,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			if (bond->params.arp_validate && net_ratelimit())
 				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
 					bond->dev->name, &targets[i]);
-			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, 0);
+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
+				      0, 0, 0);
 			continue;
 		}
 
@@ -2196,6 +2201,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 							  iter) {
 				if (upper == rt->dst.dev) {
 					vlan_id = vlan_dev_vlan_id(vlan_upper);
+					vlan_proto = vlan_dev_vlan_id(vlan_upper);
 					rcu_read_unlock();
 					goto found;
 				}
@@ -2209,9 +2215,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
 			if (upper == rt->dst.dev) {
 				/* if it's a vlan - get its VID */
-				if (is_vlan_dev(upper))
+				if (is_vlan_dev(upper)) {
 					vlan_id = vlan_dev_vlan_id(upper);
-
+					vlan_proto = vlan_dev_vlan_proto(upper);
+				}
 				rcu_read_unlock();
 				goto found;
 			}
@@ -2230,7 +2237,7 @@ found:
 		addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
 		ip_rt_put(rt);
 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
-			      addr, vlan_id);
+			      addr, vlan_proto, vlan_id);
 	}
 }
 
-- 
1.8.0
