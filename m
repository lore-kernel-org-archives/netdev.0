From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v4 3/3] bonding: add net_ratelimt to avoid spam in arp interval
Date: Tue, 25 Mar 2014 17:44:44 +0800
Message-ID: <1395740684-12224-4-git-send-email-dingtianhong@huawei.com>
References: <1395740684-12224-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44761 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbaCYJrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 05:47:40 -0400
In-Reply-To: <1395740684-12224-1-git-send-email-dingtianhong@huawei.com>
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
 drivers/net/bonding/bond_main.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6758c2d..e2b3721 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2138,16 +2138,17 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 			 NULL, slave_dev->dev_addr, NULL);
 
 	if (!skb) {
-		pr_err("ARP packet allocation failed\n");
+		net_err_ratelimited("ARP packet allocation failed\n");
 		return;
 	}
 	if (outer->vlan_id) {
 		if (inner->vlan_id) {
 			pr_debug("inner tag: proto %X vid %X\n",
 				 ntohs(inner->vlan_proto), inner->vlan_id);
-			skb = __vlan_put_tag(skb, inner->vlan_proto, inner->vlan_id);
+			skb = __vlan_put_tag(skb, inner->vlan_proto,
+					     inner->vlan_id);
 			if (!skb) {
-				pr_err("failed to insert inner VLAN tag\n");
+				net_err_ratelimited("failed to insert inner VLAN tag\n");
 				return;
 			}
 		}
@@ -2156,7 +2157,7 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 			 ntohs(outer->vlan_proto), outer->vlan_id);
 		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);
 		if (!skb) {
-			pr_err("failed to insert outer VLAN tag\n");
+			net_err_ratelimited("failed to insert outer VLAN tag\n");
 			return;
 		}
 	}
@@ -2187,9 +2188,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			/* there's no route to target - try to send arp
 			 * probe to generate any traffic (arp_validate=0)
 			 */
-			if (bond->params.arp_validate && net_ratelimit())
-				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
-					bond->dev->name, &targets[i]);
+			if (bond->params.arp_validate)
+				net_warn_ratelimited("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
+						     bond->dev->name,
+						     &targets[i]);
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, &inner, &outer);
 			continue;
 		}
-- 
1.8.0
