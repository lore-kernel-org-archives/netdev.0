From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 15/18] tg3: Add 5717 asic rev
Date: Tue, 1 Sep 2009 16:19:53 -0700
Message-ID: <1251867314.5956@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4112 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144AbZIBEz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 5717 asic rev.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  130 +++++++++++++++++++++++++++++++++++++++++------------
 drivers/net/tg3.h |   25 +++++++---
 2 files changed, 119 insertions(+), 36 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a2ff202..2310e56 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -111,7 +111,8 @@
  * replace things like '% foo' with '& (foo - 1)'.
  */
 #define TG3_RX_RCB_RING_SIZE(tp)	\
-	((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ?  512 : 1024)
+	(((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) && \
+	  !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) ? 512 : 1024)
 
 #define TG3_TX_RING_SIZE		512
 #define TG3_DEF_TX_RING_PENDING		(TG3_TX_RING_SIZE - 1)
@@ -733,13 +734,15 @@ static inline void tg3_netif_start(struct tg3 *tp)
 
 static void tg3_switch_clocks(struct tg3 *tp)
 {
-	u32 clock_ctrl = tr32(TG3PCI_CLOCK_CTRL);
+	u32 clock_ctrl;
 	u32 orig_clock_ctrl;
 
 	if ((tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) ||
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		return;
 
+	clock_ctrl = tr32(TG3PCI_CLOCK_CTRL);
+
 	orig_clock_ctrl = clock_ctrl;
 	clock_ctrl &= (CLOCK_CTRL_FORCE_CLKRUN |
 		       CLOCK_CTRL_CLKRUN_OENABLE |
@@ -1993,8 +1996,9 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 	if ((tp->tg3_flags2 & TG3_FLG2_IS_NIC) == 0)
 		return;
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714)) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
 		struct net_device *dev_peer;
 
 		dev_peer = pci_get_drvdata(tp->pdev_peer);
@@ -5211,6 +5215,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	mss = 0;
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
 		int tcp_opt_len, ip_tcp_len;
+		u32 hdrlen;
 
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -5219,7 +5224,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 		}
 
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
+			hdrlen = skb_headlen(skb) - ETH_HLEN;
 		else {
 			struct iphdr *iph = ip_hdr(skb);
 
@@ -5228,9 +5233,17 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 			iph->check = 0;
 			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-			mss |= (ip_tcp_len + tcp_opt_len) << 9;
+			hdrlen = ip_tcp_len + tcp_opt_len;
 		}
 
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+			mss |= (hdrlen & 0xc) << 12;
+			if (hdrlen & 0x10)
+				base_flags |= 0x00000010;
+			base_flags |= (hdrlen & 0x3e0) << 5;
+		} else
+			mss |= hdrlen << 9;
+
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
@@ -5258,6 +5271,10 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 	len = skb_headlen(skb);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+	    !mss && skb->len > ETH_DATA_LEN)
+		base_flags |= TXD_FLAG_JMB_PKT;
+
 	tg3_set_txd(tnapi, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
 
@@ -6564,7 +6581,9 @@ static int tg3_chip_reset(struct tg3 *tp)
 	tg3_mdio_start(tp);
 
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
-	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0) {
+	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
 		val = tr32(0x7c00);
 
 		tw32(0x7c00, val | (1 << 25));
@@ -6993,7 +7012,9 @@ static void tg3_rings_reset(struct tg3 *tp)
 
 
 	/* Disable all receive return rings but the first. */
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 17;
+	else if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 16;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 4;
@@ -7197,7 +7218,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		return err;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
 		/* This value is determined during the probe time DMA
 		 * engine test, tg3_test_dma.
 		 */
@@ -7351,7 +7373,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			     BDINFO_FLAGS_DISABLED);
 		}
 
-		val = RX_STD_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+			val = (RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT) |
+			      (RX_STD_MAX_SIZE << 2);
+		else
+			val = RX_STD_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT;
 	} else
 		val = RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT;
 
@@ -7366,6 +7392,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
 		     tpr->rx_jmb_ptr);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		tw32(STD_REPLENISH_LWM, 32);
+		tw32(JMB_REPLENISH_LWM, 16);
+	}
+
 	tg3_rings_reset(tp);
 
 	/* Initialize MAC address and backoff seed. */
@@ -8021,6 +8052,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	struct tg3_napi *tnapi = &tp->napi[0];
 	struct net_device *dev = tp->dev;
 	int err, i, intr_ok = 0;
+	u32 val;
 
 	if (!netif_running(dev))
 		return -ENODEV;
@@ -8029,6 +8061,16 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	free_irq(tnapi->irq_vec, tnapi);
 
+	/*
+	 * Turn off MSI one shot mode.  Otherwise this test has no
+	 * observable way to know whether the interrupt was delivered.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+	    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
+		val = tr32(MSGINT_MODE) | MSGINT_MODE_ONE_SHOT_DISABLE;
+		tw32(MSGINT_MODE, val);
+	}
+
 	err = request_irq(tnapi->irq_vec, tg3_test_isr,
 			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, tnapi);
 	if (err)
@@ -8064,8 +8106,15 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	if (err)
 		return err;
 
-	if (intr_ok)
+	if (intr_ok) {
+		/* Reenable MSI one shot mode. */
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
+			val = tr32(MSGINT_MODE) & ~MSGINT_MODE_ONE_SHOT_DISABLE;
+			tw32(MSGINT_MODE, val);
+		}
 		return 0;
+	}
 
 	return -EIO;
 }
@@ -8350,13 +8399,13 @@ static int tg3_open(struct net_device *dev)
 			goto err_out2;
 		}
 
-		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
-			if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI) {
-				u32 val = tr32(PCIE_TRANSACTION_CFG);
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
+		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI) &&
+		    (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)) {
+			u32 val = tr32(PCIE_TRANSACTION_CFG);
 
-				tw32(PCIE_TRANSACTION_CFG,
-				     val | PCIE_TRANS_CFG_1SHOT_MSI);
-			}
+			tw32(PCIE_TRANSACTION_CFG,
+			     val | PCIE_TRANS_CFG_1SHOT_MSI);
 		}
 	}
 
@@ -9392,7 +9441,8 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
 			    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 			     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 				dev->features |= NETIF_F_TSO_ECN;
 		} else
 			dev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
@@ -12291,8 +12341,17 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_USE_PROD_ID_REG) {
 		u32 prod_id_asic_rev;
 
-		pci_read_config_dword(tp->pdev, TG3PCI_PRODID_ASICREV,
-				      &prod_id_asic_rev);
+		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717C ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717S ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718C ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718S)
+			pci_read_config_dword(tp->pdev,
+					      TG3PCI_GEN2_PRODID_ASICREV,
+					      &prod_id_asic_rev);
+		else
+			pci_read_config_dword(tp->pdev, TG3PCI_PRODID_ASICREV,
+					      &prod_id_asic_rev);
+
 		tp->pci_chip_rev_id = prod_id_asic_rev;
 	}
 
@@ -12430,8 +12489,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	pci_write_config_dword(tp->pdev, TG3PCI_MISC_HOST_CTRL,
 			       tp->misc_host_ctrl);
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714))
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 		tp->pdev_peer = tg3_find_peer(tp);
 
 	/* Intentionally exclude ASIC_REV_5906 */
@@ -12440,7 +12500,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 		tp->tg3_flags3 |= TG3_FLG3_5755_PLUS;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
@@ -12490,8 +12551,16 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	tp->irq_max = 1;
 
+#ifdef TG3_NAPI
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSIX;
+		tp->irq_max = TG3_IRQ_MAX_VECS;
+	}
+#endif
+
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-	     (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+	     (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 		tp->tg3_flags |= TG3_FLAG_JUMBO_CAPABLE;
 
 	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
@@ -12625,7 +12694,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->write32 = tg3_write_flush_reg32;
 	}
 
-
 	if ((tp->tg3_flags & TG3_FLAG_TXD_MBOX_HWBUG) ||
 	    (tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER)) {
 		tp->write32_tx_mbox = tg3_write32_tx_mbox;
@@ -12684,7 +12752,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
 	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
@@ -12762,7 +12831,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
 	    !(tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57780) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57780 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
@@ -13486,7 +13556,8 @@ static void __devinit tg3_init_link_config(struct tg3 *tp)
 
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
 			DEFAULT_MB_RDMA_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_mac_rx_low_water =
@@ -13925,7 +13996,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 		     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
 			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 			dev->features |= NETIF_F_TSO_ECN;
 	}
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 685d971..5994476 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -46,6 +46,10 @@
 #define  TG3PCI_DEVICE_TIGON3_57788	 0x1691
 #define  TG3PCI_DEVICE_TIGON3_5785_G	 0x1699 /* GPHY */
 #define  TG3PCI_DEVICE_TIGON3_5785_F	 0x16a0 /* 10/100 only */
+#define  TG3PCI_DEVICE_TIGON3_5717C	 0x1655
+#define  TG3PCI_DEVICE_TIGON3_5717S	 0x1656
+#define  TG3PCI_DEVICE_TIGON3_5718C	 0x1665
+#define  TG3PCI_DEVICE_TIGON3_5718S	 0x1666
 /* 0x04 --> 0x64 unused */
 #define TG3PCI_MSI_DATA			0x00000064
 /* 0x66 --> 0x68 unused */
@@ -117,6 +121,7 @@
 #define   ASIC_REV_5761			 0x5761
 #define   ASIC_REV_5785			 0x5785
 #define   ASIC_REV_57780		 0x57780
+#define   ASIC_REV_5717			 0x5717
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -203,20 +208,20 @@
 #define TG3PCI_MEM_WIN_BASE_ADDR	0x0000007c
 #define TG3PCI_REG_DATA			0x00000080
 #define TG3PCI_MEM_WIN_DATA		0x00000084
-#define TG3PCI_MODE_CTRL		0x00000088
-#define TG3PCI_MISC_CFG			0x0000008c
 #define TG3PCI_MISC_LOCAL_CTRL		0x00000090
 /* 0x94 --> 0x98 unused */
 #define TG3PCI_STD_RING_PROD_IDX	0x00000098 /* 64-bit */
 #define TG3PCI_RCV_RET_RING_CON_IDX	0x000000a0 /* 64-bit */
-#define TG3PCI_SND_PROD_IDX		0x000000a8 /* 64-bit */
-/* 0xb0 --> 0xb8 unused */
+/* 0xa0 --> 0xb8 unused */
 #define TG3PCI_DUAL_MAC_CTRL		0x000000b8
 #define  DUAL_MAC_CTRL_CH_MASK		 0x00000003
 #define  DUAL_MAC_CTRL_ID		 0x00000004
 #define TG3PCI_PRODID_ASICREV		0x000000bc
 #define  PROD_ID_ASIC_REV_MASK		 0x0fffffff
-/* 0xc0 --> 0x110 unused */
+/* 0xc0 --> 0xf4 unused */
+
+#define TG3PCI_GEN2_PRODID_ASICREV	0x000000f4
+/* 0xf8 --> 0x200 unused */
 
 #define TG3_CORR_ERR_STAT		0x00000110
 #define  TG3_CORR_ERR_STAT_CLEAR	0xffffffff
@@ -972,7 +977,11 @@
 #define RCVBDI_MINI_THRESH		0x00002c14
 #define RCVBDI_STD_THRESH		0x00002c18
 #define RCVBDI_JUMBO_THRESH		0x00002c1c
-/* 0x2c20 --> 0x3000 unused */
+/* 0x2c20 --> 0x2d00 unused */
+
+#define STD_REPLENISH_LWM		0x00002d00
+#define JMB_REPLENISH_LWM		0x00002d04
+/* 0x2d08 --> 0x3000 unused */
 
 /* Receive BD Completion Control Registers */
 #define RCVCC_MODE			0x00003000
@@ -1486,6 +1495,7 @@
 #define MSGINT_MODE			0x00006000
 #define  MSGINT_MODE_RESET		 0x00000001
 #define  MSGINT_MODE_ENABLE		 0x00000002
+#define  MSGINT_MODE_ONE_SHOT_DISABLE	 0x00000020
 #define  MSGINT_MODE_MULTIVEC_EN	 0x00000080
 #define MSGINT_STATUS			0x00006004
 #define MSGINT_FIFO			0x00006008
@@ -2124,6 +2134,7 @@ struct tg3_tx_buffer_desc {
 #define TXD_FLAG_IP_CSUM		0x0002
 #define TXD_FLAG_END			0x0004
 #define TXD_FLAG_IP_FRAG		0x0008
+#define TXD_FLAG_JMB_PKT		0x0008
 #define TXD_FLAG_IP_FRAG_END		0x0010
 #define TXD_FLAG_VLAN			0x0040
 #define TXD_FLAG_COAL_NOW		0x0080
@@ -2520,7 +2531,7 @@ struct tg3_rx_prodring_set {
 	dma_addr_t			rx_jmb_mapping;
 };
 
-#define TG3_IRQ_MAX_VECS 1
+#define TG3_IRQ_MAX_VECS 5
 
 struct tg3_napi {
 	struct napi_struct		napi	____cacheline_aligned;
-- 
1.6.3.3


