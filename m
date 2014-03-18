From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 3/3] bonding: convert pr_xxx() to pr_xxx_ratelimited() for arp interval
Date: Tue, 18 Mar 2014 18:43:53 +0800
Message-ID: <1395139433-19576-4-git-send-email-dingtianhong@huawei.com>
References: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:44484 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587AbaCRKo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 06:44:26 -0400
In-Reply-To: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The debug log in the arp interval should be rate limited, otherwise would
occur spam the log, so convert them.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6758c2d..8707bb3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2131,32 +2131,33 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 {
 	struct sk_buff *skb;
 
-	pr_debug("arp %d on slave %s: dst %pI4 src %pI4\n",
-		 arp_op, slave_dev->name, &dest_ip, &src_ip);
+	pr_debug_ratelimited("arp %d on slave %s: dst %pI4 src %pI4\n",
+			     arp_op, slave_dev->name, &dest_ip, &src_ip);
 
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
 
 	if (!skb) {
-		pr_err("ARP packet allocation failed\n");
+		pr_err_ratelimited("ARP packet allocation failed\n");
 		return;
 	}
 	if (outer->vlan_id) {
 		if (inner->vlan_id) {
-			pr_debug("inner tag: proto %X vid %X\n",
-				 ntohs(inner->vlan_proto), inner->vlan_id);
+			pr_debug_ratelimited("inner tag: proto %X vid %X\n",
+					     ntohs(inner->vlan_proto),
+					     inner->vlan_id);
 			skb = __vlan_put_tag(skb, inner->vlan_proto, inner->vlan_id);
 			if (!skb) {
-				pr_err("failed to insert inner VLAN tag\n");
+				pr_err_ratelimited("failed to insert inner VLAN tag\n");
 				return;
 			}
 		}
 
-		pr_debug("outer reg: proto %X vid %X\n",
-			 ntohs(outer->vlan_proto), outer->vlan_id);
+		pr_debug_ratelimited("outer reg: proto %X vid %X\n",
+				     ntohs(outer->vlan_proto), outer->vlan_id);
 		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);
 		if (!skb) {
-			pr_err("failed to insert outer VLAN tag\n");
+			pr_err_ratelimited("failed to insert outer VLAN tag\n");
 			return;
 		}
 	}
@@ -2174,7 +2175,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 	int i;
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
-		pr_debug("basa: target %pI4\n", &targets[i]);
+		pr_debug_ratelimited("basa: target %pI4\n", &targets[i]);
 		inner.vlan_proto = 0;
 		inner.vlan_id = 0;
 		outer.vlan_proto = 0;
@@ -2187,9 +2188,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			/* there's no route to target - try to send arp
 			 * probe to generate any traffic (arp_validate=0)
 			 */
-			if (bond->params.arp_validate && net_ratelimit())
-				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
-					bond->dev->name, &targets[i]);
+			if (bond->params.arp_validate)
+				pr_warn_ratelimited("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
+						    bond->dev->name,
+						    &targets[i]);
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, &inner, &outer);
 			continue;
 		}
@@ -2246,9 +2248,9 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		rcu_read_unlock();
 
 		/* Not our device - skip */
-		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
-			 bond->dev->name, &targets[i],
-			 rt->dst.dev ? rt->dst.dev->name : "NULL");
+		pr_debug_ratelimited("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
+				     bond->dev->name, &targets[i],
+				     rt->dst.dev ? rt->dst.dev->name : "NULL");
 
 		ip_rt_put(rt);
 		continue;
-- 
1.8.0
