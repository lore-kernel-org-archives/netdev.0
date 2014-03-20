From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 3/3] bonding: add net_ratelimt to avoid spam in arp interval
Date: Thu, 20 Mar 2014 16:15:35 +0800
Message-ID: <1395303335-10088-4-git-send-email-dingtianhong@huawei.com>
References: <1395303335-10088-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [119.145.14.66] ([119.145.14.66]:31659 "EHLO
	szxga03-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754736AbaCTIRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 04:17:23 -0400
In-Reply-To: <1395303335-10088-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unnecessary log and add net_ratelimit to the others, in order to
avoid spam the log.

Cc: Joe Perches <joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6758c2d..9b678fb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2131,32 +2131,33 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 {
 	struct sk_buff *skb;
 
-	pr_debug("arp %d on slave %s: dst %pI4 src %pI4\n",
-		 arp_op, slave_dev->name, &dest_ip, &src_ip);
+	net_dbg_ratelimited("arp %d on slave %s: dst %pI4 src %pI4\n",
+			    arp_op, slave_dev->name, &dest_ip, &src_ip);
 
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
+			net_dbg_ratelimited("inner tag: proto %X vid %X\n",
+					    ntohs(inner->vlan_proto),
+					    inner->vlan_id);
 			skb = __vlan_put_tag(skb, inner->vlan_proto, inner->vlan_id);
 			if (!skb) {
-				pr_err("failed to insert inner VLAN tag\n");
+				net_err_ratelimited("failed to insert inner VLAN tag\n");
 				return;
 			}
 		}
 
-		pr_debug("outer reg: proto %X vid %X\n",
-			 ntohs(outer->vlan_proto), outer->vlan_id);
+		net_dbg_ratelimited("outer reg: proto %X vid %X\n",
+				     ntohs(outer->vlan_proto), outer->vlan_id);
 		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);
 		if (!skb) {
-			pr_err("failed to insert outer VLAN tag\n");
+			net_err_ratelimited("failed to insert outer VLAN tag\n");
 			return;
 		}
 	}
@@ -2174,7 +2175,6 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 	int i;
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
-		pr_debug("basa: target %pI4\n", &targets[i]);
 		inner.vlan_proto = 0;
 		inner.vlan_id = 0;
 		outer.vlan_proto = 0;
@@ -2187,9 +2187,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			/* there's no route to target - try to send arp
 			 * probe to generate any traffic (arp_validate=0)
 			 */
-			if (bond->params.arp_validate && net_ratelimit())
-				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
-					bond->dev->name, &targets[i]);
+			if (bond->params.arp_validate)
+				net_dbg_ratelimited("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
+						    bond->dev->name,
+						    &targets[i]);
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, &inner, &outer);
 			continue;
 		}
@@ -2246,9 +2247,9 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		rcu_read_unlock();
 
 		/* Not our device - skip */
-		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
-			 bond->dev->name, &targets[i],
-			 rt->dst.dev ? rt->dst.dev->name : "NULL");
+		net_dbg_ratelimited("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
+				    bond->dev->name, &targets[i],
+				    rt->dst.dev ? rt->dst.dev->name : "NULL");
 
 		ip_rt_put(rt);
 		continue;
-- 
1.8.0
