From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 1/2] bonding: slight optimization for bond xmit path
Date: Tue, 25 Mar 2014 17:00:09 +0800
Message-ID: <1395738010-12212-2-git-send-email-dingtianhong@huawei.com>
References: <1395738010-12212-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:15767 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaCYJFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 05:05:52 -0400
In-Reply-To: <1395738010-12212-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add unlikely() micro to the unlikely conditions in the bond
xmit path for slight optimization.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e717db3..ee17c24 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2957,7 +2957,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 	fk->ports = 0;
 	noff = skb_network_offset(skb);
 	if (skb->protocol == htons(ETH_P_IP)) {
-		if (!pskb_may_pull(skb, noff + sizeof(*iph)))
+		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph))))
 			return false;
 		iph = ip_hdr(skb);
 		fk->src = iph->saddr;
@@ -2966,7 +2966,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 		if (!ip_is_fragment(iph))
 			proto = iph->protocol;
 	} else if (skb->protocol == htons(ETH_P_IPV6)) {
-		if (!pskb_may_pull(skb, noff + sizeof(*iph6)))
+		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph6))))
 			return false;
 		iph6 = ipv6_hdr(skb);
 		fk->src = (__force __be32)ipv6_addr_hash(&iph6->saddr);
@@ -3768,7 +3768,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * If we risk deadlock from transmitting this in the
 	 * netpoll path, tell netpoll to queue the frame for later tx
 	 */
-	if (is_netpoll_tx_blocked(dev))
+	if (unlikely(is_netpoll_tx_blocked(dev)))
 		return NETDEV_TX_BUSY;
 
 	rcu_read_lock();
-- 
1.8.0
