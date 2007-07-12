From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] macb: Add multicast capability
Date: Thu, 12 Jul 2007 19:07:25 +0200
Message-ID: <11842600453756-git-send-email-hskinnemoen@atmel.com>
References: <11842600452017-git-send-email-hskinnemoen@atmel.com>
Cc: Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	Jeff Garzik <jeff@garzik.org>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:52479 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752769AbXGLRHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 13:07:45 -0400
In-Reply-To: <11842600452017-git-send-email-hskinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrice Vilchez <patrice.vilchez@rfo.atmel.com>

Add multicast capability to Atmel ethernet macb driver.

Signed-off-by: Patrice Vilchez <patrice.vilchez@rfo.atmel.com>
Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/macb.c |  120 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 120 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 83c35fd..a4bb026 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -796,6 +796,125 @@ static void macb_init_hw(struct macb *bp)
 
 }
 
+/*
+ * The hash address register is 64 bits long and takes up two
+ * locations in the memory map.  The least significant bits are stored
+ * in EMAC_HSL and the most significant bits in EMAC_HSH.
+ *
+ * The unicast hash enable and the multicast hash enable bits in the
+ * network configuration register enable the reception of hash matched
+ * frames. The destination address is reduced to a 6 bit index into
+ * the 64 bit hash register using the following hash function.  The
+ * hash function is an exclusive or of every sixth bit of the
+ * destination address.
+ *
+ * hi[5] = da[5] ^ da[11] ^ da[17] ^ da[23] ^ da[29] ^ da[35] ^ da[41] ^ da[47]
+ * hi[4] = da[4] ^ da[10] ^ da[16] ^ da[22] ^ da[28] ^ da[34] ^ da[40] ^ da[46]
+ * hi[3] = da[3] ^ da[09] ^ da[15] ^ da[21] ^ da[27] ^ da[33] ^ da[39] ^ da[45]
+ * hi[2] = da[2] ^ da[08] ^ da[14] ^ da[20] ^ da[26] ^ da[32] ^ da[38] ^ da[44]
+ * hi[1] = da[1] ^ da[07] ^ da[13] ^ da[19] ^ da[25] ^ da[31] ^ da[37] ^ da[43]
+ * hi[0] = da[0] ^ da[06] ^ da[12] ^ da[18] ^ da[24] ^ da[30] ^ da[36] ^ da[42]
+ *
+ * da[0] represents the least significant bit of the first byte
+ * received, that is, the multicast/unicast indicator, and da[47]
+ * represents the most significant bit of the last byte received.  If
+ * the hash index, hi[n], points to a bit that is set in the hash
+ * register then the frame will be matched according to whether the
+ * frame is multicast or unicast.  A multicast match will be signalled
+ * if the multicast hash enable bit is set, da[0] is 1 and the hash
+ * index points to a bit set in the hash register.  A unicast match
+ * will be signalled if the unicast hash enable bit is set, da[0] is 0
+ * and the hash index points to a bit set in the hash register.  To
+ * receive all multicast frames, the hash register should be set with
+ * all ones and the multicast hash enable bit should be set in the
+ * network configuration register.
+ */
+
+static inline int hash_bit_value(int bitnr, __u8 *addr)
+{
+	if (addr[bitnr / 8] & (1 << (bitnr % 8)))
+		return 1;
+	return 0;
+}
+
+/*
+ * Return the hash index value for the specified address.
+ */
+static int hash_get_index(__u8 *addr)
+{
+	int i, j, bitval;
+	int hash_index = 0;
+
+	for (j = 0; j < 6; j++) {
+		for (i = 0, bitval = 0; i < 8; i++)
+			bitval ^= hash_bit_value(i*6 + j, addr);
+
+		hash_index |= (bitval << j);
+	}
+
+	return hash_index;
+}
+
+/*
+ * Add multicast addresses to the internal multicast-hash table.
+ */
+static void macb_sethashtable(struct net_device *dev)
+{
+	struct dev_mc_list *curr;
+	unsigned long mc_filter[2];
+	unsigned int i, bitnr;
+	struct macb *bp = netdev_priv(dev);
+
+	mc_filter[0] = mc_filter[1] = 0;
+
+	curr = dev->mc_list;
+	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+		if (!curr) break;	/* unexpected end of list */
+
+		bitnr = hash_get_index(curr->dmi_addr);
+		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
+	}
+
+	macb_writel(bp, HRB, mc_filter[0]);
+	macb_writel(bp, HRT, mc_filter[1]);
+}
+
+/*
+ * Enable/Disable promiscuous and multicast modes.
+ */
+static void macb_set_rx_mode(struct net_device *dev)
+{
+	unsigned long cfg;
+	struct macb *bp = netdev_priv(dev);
+
+	cfg = macb_readl(bp, NCFGR);
+
+	if (dev->flags & IFF_PROMISC)
+		/* Enable promiscuous mode */
+		cfg |= MACB_BIT(CAF);
+	else if (dev->flags & (~IFF_PROMISC))
+		 /* Disable promiscuous mode */
+		cfg &= ~MACB_BIT(CAF);
+
+	if (dev->flags & IFF_ALLMULTI) {
+		/* Enable all multicast mode */
+		macb_writel(bp, HRB, -1);
+		macb_writel(bp, HRT, -1);
+		cfg |= MACB_BIT(NCFGR_MTI);
+	} else if (dev->mc_count > 0) {
+		/* Enable specific multicasts */
+		macb_sethashtable(dev);
+		cfg |= MACB_BIT(NCFGR_MTI);
+	} else if (dev->flags & (~IFF_ALLMULTI)) {
+		/* Disable all multicast mode */
+		macb_writel(bp, HRB, 0);
+		macb_writel(bp, HRT, 0);
+		cfg &= ~MACB_BIT(NCFGR_MTI);
+	}
+
+	macb_writel(bp, NCFGR, cfg);
+}
+
 static int macb_open(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
@@ -1025,6 +1144,7 @@ static int __devinit macb_probe(struct platform_device *pdev)
 	dev->stop = macb_close;
 	dev->hard_start_xmit = macb_start_xmit;
 	dev->get_stats = macb_get_stats;
+	dev->set_multicast_list = macb_set_rx_mode;
 	dev->do_ioctl = macb_ioctl;
 	dev->poll = macb_poll;
 	dev->weight = 64;
-- 
1.5.2.3

