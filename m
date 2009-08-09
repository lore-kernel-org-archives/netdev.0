From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH 2/3] korina: add error-handling to korina_alloc_ring
Date: Sun,  9 Aug 2009 02:06:27 +0200
Message-ID: <20090809000637.964054CEAA@orbit.nwl.cc>
References: <20090808164512.02C174CEAA@orbit.nwl.cc>
 <1249776388-4626-1-git-send-email-n0-1@freewrt.org>
 <1249776388-4626-2-git-send-email-n0-1@freewrt.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org,
	Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:36044 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302AbZHIAGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2009 20:06:37 -0400
In-Reply-To: <1249776388-4626-2-git-send-email-n0-1@freewrt.org>
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
index c09e2ce..d256022 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -741,7 +741,7 @@ static struct ethtool_ops netdev_ethtool_ops = {
 	.get_link               = netdev_get_link,
 };
 
-static void korina_alloc_ring(struct net_device *dev)
+static int korina_alloc_ring(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	struct sk_buff *skb;
@@ -762,7 +762,7 @@ static void korina_alloc_ring(struct net_device *dev)
 	for (i = 0; i < KORINA_NUM_RDS; i++) {
 		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
 		if (!skb)
-			break;
+			return -ENOMEM;
 		skb_reserve(skb, 2);
 		skb->dev = dev;
 		lp->rx_skb[i] = skb;
@@ -782,6 +782,8 @@ static void korina_alloc_ring(struct net_device *dev)
 	lp->rx_chain_head = 0;
 	lp->rx_chain_tail = 0;
 	lp->rx_chain_status = desc_empty;
+
+	return 0;
 }
 
 static void korina_free_ring(struct net_device *dev)
@@ -824,7 +826,11 @@ static int korina_init(struct net_device *dev)
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

