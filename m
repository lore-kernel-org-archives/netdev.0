From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4/cxgb4vf: Fixes regression in perf when tx vlan offload is disabled
Date: Thu, 28 Jul 2016 13:28:57 +0530
Message-ID: <1469692737-19583-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38314 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750946AbcG1Hxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 03:53:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 637d3e997351 ("cxgb4: Discard the packet if the length is
greater than mtu") introduced a regression in the VLAN interface
performance when Tx VLAN offload is disabled.

Check if skb is tagged, regardless of whether it is hardware accelerated
or not. Presently we were checking only for hardware acclereated one,
which caused performance to drop to ~0.17Mbps on a 10GbE adapter for
VLAN interface, when tx vlan offload is turned off using ethtool.
The ethernet head length calculation was going wrong in this case, and
driver ended up dropping packets.

Fixes: 637d3e997351 ("cxgb4: Discard the packet if the length is greater than mtu")

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c   | 2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index bad253beb8c8..ad3552df0545 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1192,7 +1192,7 @@ out_free:	dev_kfree_skb_any(skb);
 
 	/* Discard the packet if the length is greater than mtu */
 	max_pkt_len = ETH_HLEN + dev->mtu;
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tagged(skb))
 		max_pkt_len += VLAN_HLEN;
 	if (!skb_shinfo(skb)->gso_size && (unlikely(skb->len > max_pkt_len)))
 		goto out_free;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 1bb57d3fbbe8..c8fd4f8fe1fa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1188,7 +1188,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Discard the packet if the length is greater than mtu */
 	max_pkt_len = ETH_HLEN + dev->mtu;
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tagged(skb))
 		max_pkt_len += VLAN_HLEN;
 	if (!skb_shinfo(skb)->gso_size && (unlikely(skb->len > max_pkt_len)))
 		goto out_free;
-- 
2.3.4
