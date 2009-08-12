From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH 2/2] korina: add error-handling to korina_alloc_ring
Date: Thu, 13 Aug 2009 00:52:32 +0200
Message-ID: <20090812225234.82E6E4CEAA@orbit.nwl.cc>
References: <20090812222249.39EAB4CEAA@orbit.nwl.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org,
	Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:38875 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167AbZHLWwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 18:52:34 -0400
In-Reply-To: <20090812222249.39EAB4CEAA@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also avoids a potential buffer overflow in case the very first
receive descriptor fails to allocate, as an index of -1 would be used
afterwards. Kudos to Roel Kluin for pointing this out and providing an
initial patch.

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 6df9d25..51ca54c 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -750,7 +750,7 @@ static struct ethtool_ops netdev_ethtool_ops = {
 	.get_link               = netdev_get_link,
 };
 
-static void korina_alloc_ring(struct net_device *dev)
+static int korina_alloc_ring(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	struct sk_buff *skb;
@@ -771,7 +771,7 @@ static void korina_alloc_ring(struct net_device *dev)
 	for (i = 0; i < KORINA_NUM_RDS; i++) {
 		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
 		if (!skb)
-			break;
+			return -ENOMEM;
 		skb_reserve(skb, 2);
 		lp->rx_skb[i] = skb;
 		lp->rd_ring[i].control = DMA_DESC_IOD |
@@ -790,6 +790,8 @@ static void korina_alloc_ring(struct net_device *dev)
 	lp->rx_chain_head = 0;
 	lp->rx_chain_tail = 0;
 	lp->rx_chain_status = desc_empty;
+
+	return 0;
 }
 
 static void korina_free_ring(struct net_device *dev)
@@ -832,7 +834,11 @@ static int korina_init(struct net_device *dev)
 	writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
 
 	/* Allocate rings */
-	korina_alloc_ring(dev);
+	if (korina_alloc_ring(dev)) {
+		printk(KERN_ERR "%s: descriptor allocation failed\n", dev->name);
+		korina_free_ring(dev);
+		return -ENOMEM;
+	}
 
 	writel(0, &lp->rx_dma_regs->dmas);
 	/* Start Rx DMA */
-- 
1.6.0.6

