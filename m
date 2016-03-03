From: Lada Trimasova <Lada.Trimasova@synopsys.com>
Subject: [PATCH V3] net: ezchip: adapt driver to little endian architecture
Date: Thu,  3 Mar 2016 17:07:46 +0300
Message-ID: <1457014066-27651-1-git-send-email-ltrimas@synopsys.com>
Cc: linux-kernel@vger.kernel.org,
	Lada Trimasova <Lada.Trimasova@synopsys.com>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>,
	Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:36852 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756915AbcCCOI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:08:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ezchip network driver is written with big endian EZChip platform it
is necessary to add support for little endian architecture.

The first issue is that the order of the bits in a bit field is
implementation specific. So all the bit fields are removed.
Named constants are used to access necessary fields.

And the second one is that network byte order is big endian.
For example, data on ethernet is transmitted with most-significant
octet (byte) first. So in case of little endian architecture
it is important to swap data byte order when we read it from
register. In case of unaligned access we can use "get_unaligned_be32"
and in other case we can use function "ioread32_rep" which reads all
data from register and works either with little endian or big endian
architecture.

And then when we are going to write data to register we need to restore
byte order using the function "put_unaligned_be32" in case of
unaligned access and in other case "iowrite32_rep".

The last little fix is a space between type and pointer to observe
coding style.

Signed-off-by: Lada Trimasova <ltrimas@synopsys.com>
Cc: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Noam Camus <noamc@ezchip.com>
Cc: Tal Zilcer <talz@ezchip.com>
Cc: Arnd Bergmann <arnd@arndb.de>

---
changes v2->v3:
- using ioread32_rep/iowrite32_rep instead of cpu_to_be32/be32_to_cpu
  when reading from FIFO register

changes v1->v2:
- removing all bitfields, using named constants instead
- using put_unaligned_be32/get_unaligned_be32 in case of unaligned access
---
 drivers/net/ethernet/ezchip/nps_enet.c | 222 +++++++++++----------
 drivers/net/ethernet/ezchip/nps_enet.h | 348 +++++++++++----------------------
 2 files changed, 238 insertions(+), 332 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index b102668..1f23845a 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -43,20 +43,21 @@ static void nps_enet_read_rx_fifo(struct net_device *ndev,
 	bool dst_is_aligned = IS_ALIGNED((unsigned long)dst, sizeof(u32));
 
 	/* In case dst is not aligned we need an intermediate buffer */
-	if (dst_is_aligned)
-		for (i = 0; i < len; i++, reg++)
-			*reg = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+	if (dst_is_aligned) {
+		ioread32_rep(priv->regs_base + NPS_ENET_REG_RX_BUF, reg, len);
+		reg += len;
+	}
 	else { /* !dst_is_aligned */
 		for (i = 0; i < len; i++, reg++) {
 			u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
-			put_unaligned(buf, reg);
+			put_unaligned_be32(buf, reg);
 		}
 	}
-
 	/* copy last bytes (if any) */
 	if (last) {
-		u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
-		memcpy((u8*)reg, &buf, last);
+		u32 buf;
+		ioread32_rep(priv->regs_base + NPS_ENET_REG_RX_BUF, &buf, 1);
+		memcpy((u8 *)reg, &buf, last);
 	}
 }
 
@@ -66,26 +67,28 @@ static u32 nps_enet_rx_handler(struct net_device *ndev)
 	u32 work_done = 0;
 	struct nps_enet_priv *priv = netdev_priv(ndev);
 	struct sk_buff *skb;
-	struct nps_enet_rx_ctl rx_ctrl;
+	u32 rx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
+	u32 rx_ctrl_cr = (rx_ctrl_value & RX_CTL_CR_MASK) >> RX_CTL_CR_SHIFT;
+	u32 rx_ctrl_er = (rx_ctrl_value & RX_CTL_ER_MASK) >> RX_CTL_ER_SHIFT;
+	u32 rx_ctrl_crc = (rx_ctrl_value & RX_CTL_CRC_MASK) >> RX_CTL_CRC_SHIFT;
 
-	rx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
-	frame_len = rx_ctrl.nr;
+	frame_len = (rx_ctrl_value & RX_CTL_NR_MASK) >> RX_CTL_NR_SHIFT;
 
 	/* Check if we got RX */
-	if (!rx_ctrl.cr)
+	if (!rx_ctrl_cr)
 		return work_done;
 
 	/* If we got here there is a work for us */
 	work_done++;
 
 	/* Check Rx error */
-	if (rx_ctrl.er) {
+	if (rx_ctrl_er) {
 		ndev->stats.rx_errors++;
 		err = 1;
 	}
 
 	/* Check Rx CRC error */
-	if (rx_ctrl.crc) {
+	if (rx_ctrl_crc) {
 		ndev->stats.rx_crc_errors++;
 		ndev->stats.rx_dropped++;
 		err = 1;
@@ -136,23 +139,24 @@ rx_irq_frame_done:
 static void nps_enet_tx_handler(struct net_device *ndev)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_tx_ctl tx_ctrl;
-
-	tx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+	u32 tx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+	u32 tx_ctrl_ct = (tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
+	u32 tx_ctrl_et = (tx_ctrl_value & TX_CTL_ET_MASK) >> TX_CTL_ET_SHIFT;
+	u32 tx_ctrl_nt = (tx_ctrl_value & TX_CTL_NT_MASK) >> TX_CTL_NT_SHIFT;
 
 	/* Check if we got TX */
-	if (!priv->tx_packet_sent || tx_ctrl.ct)
+	if (!priv->tx_packet_sent || tx_ctrl_ct)
 		return;
 
 	/* Ack Tx ctrl register */
 	nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, 0);
 
 	/* Check Tx transmit error */
-	if (unlikely(tx_ctrl.et)) {
+	if (unlikely(tx_ctrl_et)) {
 		ndev->stats.tx_errors++;
 	} else {
 		ndev->stats.tx_packets++;
-		ndev->stats.tx_bytes += tx_ctrl.nt;
+		ndev->stats.tx_bytes += tx_ctrl_nt;
 	}
 
 	dev_kfree_skb(priv->tx_skb);
@@ -178,13 +182,16 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 	nps_enet_tx_handler(ndev);
 	work_done = nps_enet_rx_handler(ndev);
 	if (work_done < budget) {
-		struct nps_enet_buf_int_enable buf_int_enable;
+		u32 buf_int_enable_value = 0;
 
 		napi_complete(napi);
-		buf_int_enable.rx_rdy = NPS_ENET_ENABLE;
-		buf_int_enable.tx_done = NPS_ENET_ENABLE;
+
+		/* set tx_done and rx_rdy bits */
+		buf_int_enable_value |= NPS_ENET_ENABLE << RX_RDY_SHIFT;
+		buf_int_enable_value |= NPS_ENET_ENABLE << TX_DONE_SHIFT;
+
 		nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
-				 buf_int_enable.value);
+				 buf_int_enable_value);
 	}
 
 	return work_done;
@@ -205,13 +212,12 @@ static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
 {
 	struct net_device *ndev = dev_instance;
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_rx_ctl rx_ctrl;
-	struct nps_enet_tx_ctl tx_ctrl;
-
-	rx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
-	tx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+	u32 rx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
+	u32 tx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+	u32 tx_ctrl_ct = (tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
+	u32 rx_ctrl_cr = (rx_ctrl_value & RX_CTL_CR_MASK) >> RX_CTL_CR_SHIFT;
 
-	if ((!tx_ctrl.ct && priv->tx_packet_sent) || rx_ctrl.cr)
+	if ((!tx_ctrl_ct && priv->tx_packet_sent) || rx_ctrl_cr)
 		if (likely(napi_schedule_prep(&priv->napi))) {
 			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
 			__napi_schedule(&priv->napi);
@@ -223,22 +229,24 @@ static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
 static void nps_enet_set_hw_mac_address(struct net_device *ndev)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_ge_mac_cfg_1 ge_mac_cfg_1;
-	struct nps_enet_ge_mac_cfg_2 *ge_mac_cfg_2 = &priv->ge_mac_cfg_2;
+	u32 ge_mac_cfg_1_value = 0;
+	u32 *ge_mac_cfg_2_value = &priv->ge_mac_cfg_2_value;
 
 	/* set MAC address in HW */
-	ge_mac_cfg_1.octet_0 = ndev->dev_addr[0];
-	ge_mac_cfg_1.octet_1 = ndev->dev_addr[1];
-	ge_mac_cfg_1.octet_2 = ndev->dev_addr[2];
-	ge_mac_cfg_1.octet_3 = ndev->dev_addr[3];
-	ge_mac_cfg_2->octet_4 = ndev->dev_addr[4];
-	ge_mac_cfg_2->octet_5 = ndev->dev_addr[5];
+	ge_mac_cfg_1_value |= ndev->dev_addr[0] << CFG_1_OCTET_0_SHIFT;
+	ge_mac_cfg_1_value |= ndev->dev_addr[1] << CFG_1_OCTET_1_SHIFT;
+	ge_mac_cfg_1_value |= ndev->dev_addr[2] << CFG_1_OCTET_2_SHIFT;
+	ge_mac_cfg_1_value |= ndev->dev_addr[3] << CFG_1_OCTET_3_SHIFT;
+	*ge_mac_cfg_2_value = (*ge_mac_cfg_2_value & ~CFG_2_OCTET_4_MASK)
+		 | ndev->dev_addr[4] << CFG_2_OCTET_4_SHIFT;
+	*ge_mac_cfg_2_value = (*ge_mac_cfg_2_value & ~CFG_2_OCTET_5_MASK)
+		 | ndev->dev_addr[5] << CFG_2_OCTET_5_SHIFT;
 
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_1,
-			 ge_mac_cfg_1.value);
+			 ge_mac_cfg_1_value);
 
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_2,
-			 ge_mac_cfg_2->value);
+			 *ge_mac_cfg_2_value);
 }
 
 /**
@@ -254,93 +262,97 @@ static void nps_enet_set_hw_mac_address(struct net_device *ndev)
 static void nps_enet_hw_reset(struct net_device *ndev)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_ge_rst ge_rst;
-	struct nps_enet_phase_fifo_ctl phase_fifo_ctl;
+	u32 ge_rst_value = 0, phase_fifo_ctl_value = 0;
 
-	ge_rst.value = 0;
-	phase_fifo_ctl.value = 0;
 	/* Pcs reset sequence*/
-	ge_rst.gmac_0 = NPS_ENET_ENABLE;
-	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst.value);
+	ge_rst_value |= NPS_ENET_ENABLE << RST_GMAC_0_SHIFT;
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst_value);
 	usleep_range(10, 20);
-	ge_rst.value = 0;
-	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst.value);
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst_value);
 
 	/* Tx fifo reset sequence */
-	phase_fifo_ctl.rst = NPS_ENET_ENABLE;
-	phase_fifo_ctl.init = NPS_ENET_ENABLE;
+	phase_fifo_ctl_value |= NPS_ENET_ENABLE << PHASE_FIFO_CTL_RST_SHIFT;
+	phase_fifo_ctl_value |= NPS_ENET_ENABLE << PHASE_FIFO_CTL_INIT_SHIFT;
 	nps_enet_reg_set(priv, NPS_ENET_REG_PHASE_FIFO_CTL,
-			 phase_fifo_ctl.value);
+			 phase_fifo_ctl_value);
 	usleep_range(10, 20);
-	phase_fifo_ctl.value = 0;
+	phase_fifo_ctl_value = 0;
 	nps_enet_reg_set(priv, NPS_ENET_REG_PHASE_FIFO_CTL,
-			 phase_fifo_ctl.value);
+			 phase_fifo_ctl_value);
 }
 
 static void nps_enet_hw_enable_control(struct net_device *ndev)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_ge_mac_cfg_0 ge_mac_cfg_0;
-	struct nps_enet_buf_int_enable buf_int_enable;
-	struct nps_enet_ge_mac_cfg_2 *ge_mac_cfg_2 = &priv->ge_mac_cfg_2;
-	struct nps_enet_ge_mac_cfg_3 *ge_mac_cfg_3 = &priv->ge_mac_cfg_3;
+	u32 ge_mac_cfg_0_value = 0, buf_int_enable_value = 0;
+	u32 *ge_mac_cfg_2_value = &priv->ge_mac_cfg_2_value;
+	u32 *ge_mac_cfg_3_value = &priv->ge_mac_cfg_3_value;
 	s32 max_frame_length;
 
-	ge_mac_cfg_0.value = 0;
-	buf_int_enable.value = 0;
 	/* Enable Rx and Tx statistics */
-	ge_mac_cfg_2->stat_en = NPS_ENET_GE_MAC_CFG_2_STAT_EN;
+	*ge_mac_cfg_2_value = (*ge_mac_cfg_2_value & ~CFG_2_STAT_EN_MASK)
+		 | NPS_ENET_GE_MAC_CFG_2_STAT_EN << CFG_2_STAT_EN_SHIFT;
 
 	/* Discard packets with different MAC address */
-	ge_mac_cfg_2->disc_da = NPS_ENET_ENABLE;
+	*ge_mac_cfg_2_value = (*ge_mac_cfg_2_value & ~CFG_2_DISK_DA_MASK)
+		 | NPS_ENET_ENABLE << CFG_2_DISK_DA_SHIFT;
 
 	/* Discard multicast packets */
-	ge_mac_cfg_2->disc_mc = NPS_ENET_ENABLE;
+	*ge_mac_cfg_2_value = (*ge_mac_cfg_2_value & ~CFG_2_DISK_MC_MASK)
+		 | NPS_ENET_ENABLE << CFG_2_DISK_MC_SHIFT;
 
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_2,
-			 ge_mac_cfg_2->value);
+			 *ge_mac_cfg_2_value);
 
 	/* Discard Packets bigger than max frame length */
 	max_frame_length = ETH_HLEN + ndev->mtu + ETH_FCS_LEN;
-	if (max_frame_length <= NPS_ENET_MAX_FRAME_LENGTH)
-		ge_mac_cfg_3->max_len = max_frame_length;
+	if (max_frame_length <= NPS_ENET_MAX_FRAME_LENGTH) {
+		*ge_mac_cfg_3_value =
+			 (*ge_mac_cfg_3_value & ~CFG_3_MAX_LEN_MASK)
+			 | max_frame_length << CFG_3_MAX_LEN_SHIFT;
+	}
 
 	/* Enable interrupts */
-	buf_int_enable.rx_rdy = NPS_ENET_ENABLE;
-	buf_int_enable.tx_done = NPS_ENET_ENABLE;
+	buf_int_enable_value |= NPS_ENET_ENABLE << RX_RDY_SHIFT;
+	buf_int_enable_value |= NPS_ENET_ENABLE << TX_DONE_SHIFT;
 	nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
-			 buf_int_enable.value);
+			 buf_int_enable_value);
 
 	/* Write device MAC address to HW */
 	nps_enet_set_hw_mac_address(ndev);
 
 	/* Rx and Tx HW features */
-	ge_mac_cfg_0.tx_pad_en = NPS_ENET_ENABLE;
-	ge_mac_cfg_0.tx_crc_en = NPS_ENET_ENABLE;
-	ge_mac_cfg_0.rx_crc_strip = NPS_ENET_ENABLE;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_TX_PAD_EN_SHIFT;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_TX_CRC_EN_SHIFT;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_RX_CRC_STRIP_SHIFT;
 
 	/* IFG configuration */
-	ge_mac_cfg_0.rx_ifg = NPS_ENET_GE_MAC_CFG_0_RX_IFG;
-	ge_mac_cfg_0.tx_ifg = NPS_ENET_GE_MAC_CFG_0_TX_IFG;
+	ge_mac_cfg_0_value |=
+		 NPS_ENET_GE_MAC_CFG_0_RX_IFG << CFG_0_RX_IFG_SHIFT;
+	ge_mac_cfg_0_value |=
+		 NPS_ENET_GE_MAC_CFG_0_TX_IFG << CFG_0_TX_IFG_SHIFT;
 
 	/* preamble configuration */
-	ge_mac_cfg_0.rx_pr_check_en = NPS_ENET_ENABLE;
-	ge_mac_cfg_0.tx_pr_len = NPS_ENET_GE_MAC_CFG_0_TX_PR_LEN;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_RX_PR_CHECK_EN_SHIFT;
+	ge_mac_cfg_0_value |=
+		 NPS_ENET_GE_MAC_CFG_0_TX_PR_LEN << CFG_0_TX_PR_LEN_SHIFT;
 
 	/* enable flow control frames */
-	ge_mac_cfg_0.tx_fc_en = NPS_ENET_ENABLE;
-	ge_mac_cfg_0.rx_fc_en = NPS_ENET_ENABLE;
-	ge_mac_cfg_0.tx_fc_retr = NPS_ENET_GE_MAC_CFG_0_TX_FC_RETR;
-	ge_mac_cfg_3->cf_drop = NPS_ENET_ENABLE;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_TX_FC_EN_SHIFT;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_RX_FC_EN_SHIFT;
+	ge_mac_cfg_0_value |=
+		 NPS_ENET_GE_MAC_CFG_0_TX_FC_RETR << CFG_0_TX_FC_RETR_SHIFT;
+	*ge_mac_cfg_3_value = (*ge_mac_cfg_3_value & ~CFG_3_CF_DROP_MASK)
+		 | NPS_ENET_ENABLE << CFG_3_CF_DROP_SHIFT;
 
 	/* Enable Rx and Tx */
-	ge_mac_cfg_0.rx_en = NPS_ENET_ENABLE;
-	ge_mac_cfg_0.tx_en = NPS_ENET_ENABLE;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_RX_EN_SHIFT;
+	ge_mac_cfg_0_value |= NPS_ENET_ENABLE << CFG_0_TX_EN_SHIFT;
 
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_3,
-			 ge_mac_cfg_3->value);
+			 *ge_mac_cfg_3_value);
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_0,
-			 ge_mac_cfg_0.value);
+			 ge_mac_cfg_0_value);
 }
 
 static void nps_enet_hw_disable_control(struct net_device *ndev)
@@ -358,31 +370,28 @@ static void nps_enet_send_frame(struct net_device *ndev,
 				struct sk_buff *skb)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_tx_ctl tx_ctrl;
+	u32 tx_ctrl_value = 0;
 	short length = skb->len;
 	u32 i, len = DIV_ROUND_UP(length, sizeof(u32));
 	u32 *src = (void *)skb->data;
 	bool src_is_aligned = IS_ALIGNED((unsigned long)src, sizeof(u32));
 
-	tx_ctrl.value = 0;
 	/* In case src is not aligned we need an intermediate buffer */
 	if (src_is_aligned)
-		for (i = 0; i < len; i++, src++)
-			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF, *src);
+		iowrite32_rep(priv->regs_base + NPS_ENET_REG_TX_BUF, src, len);
 	else /* !src_is_aligned */
 		for (i = 0; i < len; i++, src++)
 			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF,
-					 get_unaligned(src));
+					 get_unaligned_be32(src));
 
 	/* Write the length of the Frame */
-	tx_ctrl.nt = length;
+	tx_ctrl_value |= length << TX_CTL_NT_SHIFT;
 
 	/* Indicate SW is done */
 	priv->tx_packet_sent = true;
-	tx_ctrl.ct = NPS_ENET_ENABLE;
-
+	tx_ctrl_value |= NPS_ENET_ENABLE << TX_CTL_CT_SHIFT;
 	/* Send Frame */
-	nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl.value);
+	nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl_value);
 }
 
 /**
@@ -422,19 +431,23 @@ static s32 nps_enet_set_mac_address(struct net_device *ndev, void *p)
 static void nps_enet_set_rx_mode(struct net_device *ndev)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_ge_mac_cfg_2 ge_mac_cfg_2;
-
-	ge_mac_cfg_2.value = priv->ge_mac_cfg_2.value;
+	u32 ge_mac_cfg_2_value = priv->ge_mac_cfg_2_value;
 
 	if (ndev->flags & IFF_PROMISC) {
-		ge_mac_cfg_2.disc_da = NPS_ENET_DISABLE;
-		ge_mac_cfg_2.disc_mc = NPS_ENET_DISABLE;
+		ge_mac_cfg_2_value = (ge_mac_cfg_2_value & ~CFG_2_DISK_DA_MASK)
+			 | NPS_ENET_DISABLE << CFG_2_DISK_DA_SHIFT;
+		ge_mac_cfg_2_value = (ge_mac_cfg_2_value & ~CFG_2_DISK_MC_MASK)
+			 | NPS_ENET_DISABLE << CFG_2_DISK_MC_SHIFT;
+
 	} else {
-		ge_mac_cfg_2.disc_da = NPS_ENET_ENABLE;
-		ge_mac_cfg_2.disc_mc = NPS_ENET_ENABLE;
+		ge_mac_cfg_2_value = (ge_mac_cfg_2_value & ~CFG_2_DISK_DA_MASK)
+			 | NPS_ENET_ENABLE << CFG_2_DISK_DA_SHIFT;
+		ge_mac_cfg_2_value = (ge_mac_cfg_2_value & ~CFG_2_DISK_MC_MASK)
+			 | NPS_ENET_ENABLE << CFG_2_DISK_MC_SHIFT;
+
 	}
 
-	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_2, ge_mac_cfg_2.value);
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_2, ge_mac_cfg_2_value);
 }
 
 /**
@@ -453,12 +466,15 @@ static s32 nps_enet_open(struct net_device *ndev)
 
 	/* Reset private variables */
 	priv->tx_packet_sent = false;
-	priv->ge_mac_cfg_2.value = 0;
-	priv->ge_mac_cfg_3.value = 0;
+	priv->ge_mac_cfg_2_value = 0;
+	priv->ge_mac_cfg_3_value = 0;
 
 	/* ge_mac_cfg_3 default values */
-	priv->ge_mac_cfg_3.rx_ifg_th = NPS_ENET_GE_MAC_CFG_3_RX_IFG_TH;
-	priv->ge_mac_cfg_3.max_len = NPS_ENET_GE_MAC_CFG_3_MAX_LEN;
+	priv->ge_mac_cfg_3_value |=
+		 NPS_ENET_GE_MAC_CFG_3_RX_IFG_TH << CFG_3_RX_IFG_TH_SHIFT;
+
+	priv->ge_mac_cfg_3_value |=
+		 NPS_ENET_GE_MAC_CFG_3_MAX_LEN << CFG_3_MAX_LEN_SHIFT;
 
 	/* Disable HW device */
 	nps_enet_hw_disable_control(ndev);
diff --git a/drivers/net/ethernet/ezchip/nps_enet.h b/drivers/net/ethernet/ezchip/nps_enet.h
index 6703674..d0cab60 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.h
+++ b/drivers/net/ethernet/ezchip/nps_enet.h
@@ -43,233 +43,123 @@
 #define NPS_ENET_REG_GE_RST		0x1400
 #define NPS_ENET_REG_PHASE_FIFO_CTL	0x1404
 
-/* Tx control register */
-struct nps_enet_tx_ctl {
-	union {
-		/* ct: SW sets to indicate frame ready in Tx buffer for
-		 *     transmission. HW resets to when transmission done
-		 * et: Transmit error
-		 * nt: Length in bytes of Tx frame loaded to Tx buffer
-		 */
-		struct {
-			u32
-			__reserved_1:16,
-			ct:1,
-			et:1,
-			__reserved_2:3,
-			nt:11;
-		};
-
-		u32 value;
-	};
-};
-
-/* Rx control register */
-struct nps_enet_rx_ctl {
-	union {
-		/* cr:  HW sets to indicate frame ready in Rx buffer.
-		 *      SW resets to indicate host read received frame
-		 *      and new frames can be written to Rx buffer
-		 * er:  Rx error indication
-		 * crc: Rx CRC error indication
-		 * nr:  Length in bytes of Rx frame loaded by MAC to Rx buffer
-		 */
-		struct {
-			u32
-			__reserved_1:16,
-			cr:1,
-			er:1,
-			crc:1,
-			__reserved_2:2,
-			nr:11;
-		};
-
-		u32 value;
-	};
-};
-
-/* Interrupt enable for data buffer events register */
-struct nps_enet_buf_int_enable {
-	union {
-		/* tx_done: Interrupt generation in the case when new frame
-		 *          is ready in Rx buffer
-		 * rx_rdy:  Interrupt generation in the case when current frame
-		 *          was read from TX buffer
-		 */
-		struct {
-			u32
-			__reserved:30,
-			tx_done:1,
-			rx_rdy:1;
-		};
-
-		u32 value;
-	};
-};
-
-/* Gbps Eth MAC Configuration 0 register */
-struct nps_enet_ge_mac_cfg_0 {
-	union {
-		/* tx_pr_len:          Transmit preamble length in bytes
-		 * tx_ifg_nib:         Tx idle pattern
-		 * nib_mode:           Nibble (4-bit) Mode
-		 * rx_pr_check_en:     Receive preamble Check Enable
-		 * tx_ifg:             Transmit inter-Frame Gap
-		 * rx_ifg:             Receive inter-Frame Gap
-		 * tx_fc_retr:         Transmit Flow Control Retransmit Mode
-		 * rx_length_check_en: Receive Length Check Enable
-		 * rx_crc_ignore:      Results of the CRC check are ignored
-		 * rx_crc_strip:       MAC strips the CRC from received frames
-		 * rx_fc_en:           Receive Flow Control Enable
-		 * tx_crc_en:          Transmit CRC Enabled
-		 * tx_pad_en:          Transmit Padding Enable
-		 * tx_cf_en:           Transmit Flow Control Enable
-		 * tx_en:              Transmit Enable
-		 * rx_en:              Receive Enable
-		 */
-		struct {
-			u32
-			tx_pr_len:4,
-			tx_ifg_nib:4,
-			nib_mode:1,
-			rx_pr_check_en:1,
-			tx_ifg:6,
-			rx_ifg:4,
-			tx_fc_retr:3,
-			rx_length_check_en:1,
-			rx_crc_ignore:1,
-			rx_crc_strip:1,
-			rx_fc_en:1,
-			tx_crc_en:1,
-			tx_pad_en:1,
-			tx_fc_en:1,
-			tx_en:1,
-			rx_en:1;
-		};
-
-		u32 value;
-	};
-};
-
-/* Gbps Eth MAC Configuration 1 register */
-struct nps_enet_ge_mac_cfg_1 {
-	union {
-		/* octet_3: MAC address octet 3
-		 * octet_2: MAC address octet 2
-		 * octet_1: MAC address octet 1
-		 * octet_0: MAC address octet 0
-		 */
-		struct {
-			u32
-			octet_3:8,
-			octet_2:8,
-			octet_1:8,
-			octet_0:8;
-		};
-
-		u32 value;
-	};
-};
-
-/* Gbps Eth MAC Configuration 2 register */
-struct nps_enet_ge_mac_cfg_2 {
-	union {
-		/* transmit_flush_en: MAC flush enable
-		 * stat_en:           RMON statistics interface enable
-		 * disc_da:           Discard frames with DA different
-		 *                    from MAC address
-		 * disc_bc:           Discard broadcast frames
-		 * disc_mc:           Discard multicast frames
-		 * octet_5:           MAC address octet 5
-		 * octet_4:           MAC address octet 4
-		 */
-		struct {
-			u32
-			transmit_flush_en:1,
-			__reserved_1:5,
-			stat_en:2,
-			__reserved_2:1,
-			disc_da:1,
-			disc_bc:1,
-			disc_mc:1,
-			__reserved_3:4,
-			octet_5:8,
-			octet_4:8;
-		};
-
-		u32 value;
-	};
-};
-
-/* Gbps Eth MAC Configuration 3 register */
-struct nps_enet_ge_mac_cfg_3 {
-	union {
-		/* ext_oob_cbfc_sel:  Selects one of the 4 profiles for
-		 *                    extended OOB in-flow-control indication
-		 * max_len:           Maximum receive frame length in bytes
-		 * tx_cbfc_en:        Enable transmission of class-based
-		 *                    flow control packets
-		 * rx_ifg_th:         Threshold for IFG status reporting via OOB
-		 * cf_timeout:        Configurable time to decrement FC counters
-		 * cf_drop:           Drop control frames
-		 * redirect_cbfc_sel: Selects one of CBFC redirect profiles
-		 * rx_cbfc_redir_en:  Enable Rx class-based flow
-		 *                    control redirect
-		 * rx_cbfc_en:        Enable Rx class-based flow control
-		 * tm_hd_mode:        TM header mode
-		 */
-		struct {
-			u32
-			ext_oob_cbfc_sel:2,
-			max_len:14,
-			tx_cbfc_en:1,
-			rx_ifg_th:5,
-			cf_timeout:4,
-			cf_drop:1,
-			redirect_cbfc_sel:2,
-			rx_cbfc_redir_en:1,
-			rx_cbfc_en:1,
-			tm_hd_mode:1;
-		};
-
-		u32 value;
-	};
-};
-
-/* GE MAC, PCS reset control register */
-struct nps_enet_ge_rst {
-	union {
-		/* gmac_0: GE MAC reset
-		 * spcs_0: SGMII PCS reset
-		 */
-		struct {
-			u32
-			__reserved_1:23,
-			gmac_0:1,
-			__reserved_2:7,
-			spcs_0:1;
-		};
-
-		u32 value;
-	};
-};
-
-/* Tx phase sync FIFO control register */
-struct nps_enet_phase_fifo_ctl {
-	union {
-		/* init: initialize serdes TX phase sync FIFO pointers
-		 * rst:  reset serdes TX phase sync FIFO
-		 */
-		struct {
-			u32
-			__reserved:30,
-			init:1,
-			rst:1;
-		};
-
-		u32 value;
-	};
-};
+/* Tx control register masks and shifts */
+#define TX_CTL_NT_MASK 0x7FF
+#define TX_CTL_NT_SHIFT 0
+#define TX_CTL_ET_MASK 0x4000
+#define TX_CTL_ET_SHIFT 14
+#define TX_CTL_CT_MASK 0x8000
+#define TX_CTL_CT_SHIFT 15
+
+/* Rx control register masks and shifts */
+#define RX_CTL_NR_MASK 0x7FF
+#define RX_CTL_NR_SHIFT 0
+#define RX_CTL_CRC_MASK 0x2000
+#define RX_CTL_CRC_SHIFT 13
+#define RX_CTL_ER_MASK 0x4000
+#define RX_CTL_ER_SHIFT 14
+#define RX_CTL_CR_MASK 0x8000
+#define RX_CTL_CR_SHIFT 15
+
+/* Interrupt enable for data buffer events register masks and shifts */
+#define RX_RDY_MASK 0x1
+#define RX_RDY_SHIFT 0
+#define TX_DONE_MASK 0x2
+#define TX_DONE_SHIFT 1
+
+/* Gbps Eth MAC Configuration 0 register masks and shifts */
+#define CFG_0_RX_EN_MASK 0x1
+#define CFG_0_RX_EN_SHIFT 0
+#define CFG_0_TX_EN_MASK 0x2
+#define CFG_0_TX_EN_SHIFT 1
+#define CFG_0_TX_FC_EN_MASK 0x4
+#define CFG_0_TX_FC_EN_SHIFT 2
+#define CFG_0_TX_PAD_EN_MASK 0x8
+#define CFG_0_TX_PAD_EN_SHIFT 3
+#define CFG_0_TX_CRC_EN_MASK 0x10
+#define CFG_0_TX_CRC_EN_SHIFT 4
+#define CFG_0_RX_FC_EN_MASK 0x20
+#define CFG_0_RX_FC_EN_SHIFT 5
+#define CFG_0_RX_CRC_STRIP_MASK 0x40
+#define CFG_0_RX_CRC_STRIP_SHIFT 6
+#define CFG_0_RX_CRC_IGNORE_MASK 0x80
+#define CFG_0_RX_CRC_IGNORE_SHIFT 7
+#define CFG_0_RX_LENGTH_CHECK_EN_MASK 0x100
+#define CFG_0_RX_LENGTH_CHECK_EN_SHIFT 8
+#define CFG_0_TX_FC_RETR_MASK 0xE00
+#define CFG_0_TX_FC_RETR_SHIFT 9
+#define CFG_0_RX_IFG_MASK 0xF000
+#define CFG_0_RX_IFG_SHIFT 12
+#define CFG_0_TX_IFG_MASK 0x3F0000
+#define CFG_0_TX_IFG_SHIFT 16
+#define CFG_0_RX_PR_CHECK_EN_MASK 0x400000
+#define CFG_0_RX_PR_CHECK_EN_SHIFT 22
+#define CFG_0_NIB_MODE_MASK 0x800000
+#define CFG_0_NIB_MODE_SHIFT 23
+#define CFG_0_TX_IFG_NIB_MASK 0xF000000
+#define CFG_0_TX_IFG_NIB_SHIFT 24
+#define CFG_0_TX_PR_LEN_MASK 0xF0000000
+#define CFG_0_TX_PR_LEN_SHIFT 28
+
+/* Gbps Eth MAC Configuration 1 register masks and shifts */
+#define CFG_1_OCTET_0_MASK 0x000000FF
+#define CFG_1_OCTET_0_SHIFT 0
+#define CFG_1_OCTET_1_MASK 0x0000FF00
+#define CFG_1_OCTET_1_SHIFT 8
+#define CFG_1_OCTET_2_MASK 0x00FF0000
+#define CFG_1_OCTET_2_SHIFT 16
+#define CFG_1_OCTET_3_MASK 0xFF000000
+#define CFG_1_OCTET_3_SHIFT 24
+
+/* Gbps Eth MAC Configuration 2 register masks and shifts */
+#define CFG_2_OCTET_4_MASK 0x000000FF
+#define CFG_2_OCTET_4_SHIFT 0
+#define CFG_2_OCTET_5_MASK 0x0000FF00
+#define CFG_2_OCTET_5_SHIFT 8
+#define CFG_2_DISK_MC_MASK 0x00100000
+#define CFG_2_DISK_MC_SHIFT 20
+#define CFG_2_DISK_BC_MASK 0x00200000
+#define CFG_2_DISK_BC_SHIFT 21
+#define CFG_2_DISK_DA_MASK 0x00400000
+#define CFG_2_DISK_DA_SHIFT 22
+#define CFG_2_STAT_EN_MASK 0x3000000
+#define CFG_2_STAT_EN_SHIFT 24
+#define CFG_2_TRANSMIT_FLUSH_EN_MASK 0x80000000
+#define CFG_2_TRANSMIT_FLUSH_EN_SHIFT 31
+
+/* Gbps Eth MAC Configuration 3 register masks and shifts */
+#define CFG_3_TM_HD_MODE_MASK 0x1
+#define CFG_3_TM_HD_MODE_SHIFT 0
+#define CFG_3_RX_CBFC_EN_MASK 0x2
+#define CFG_3_RX_CBFC_EN_SHIFT 1
+#define CFG_3_RX_CBFC_REDIR_EN_MASK 0x4
+#define CFG_3_RX_CBFC_REDIR_EN_SHIFT 2
+#define CFG_3_REDIRECT_CBFC_SEL_MASK 0x18
+#define CFG_3_REDIRECT_CBFC_SEL_SHIFT 3
+#define CFG_3_CF_DROP_MASK 0x20
+#define CFG_3_CF_DROP_SHIFT 5
+#define CFG_3_CF_TIMEOUT_MASK 0x3C0
+#define CFG_3_CF_TIMEOUT_SHIFT 6
+#define CFG_3_RX_IFG_TH_MASK 0x7C00
+#define CFG_3_RX_IFG_TH_SHIFT 10
+#define CFG_3_TX_CBFC_EN_MASK 0x8000
+#define CFG_3_TX_CBFC_EN_SHIFT 15
+#define CFG_3_MAX_LEN_MASK 0x3FFF0000
+#define CFG_3_MAX_LEN_SHIFT 16
+#define CFG_3_EXT_OOB_CBFC_SEL_MASK 0xC0000000
+#define CFG_3_EXT_OOB_CBFC_SEL_SHIFT 30
+
+/* GE MAC, PCS reset control register masks and shifts */
+#define RST_SPCS_MASK 0x1
+#define RST_SPCS_SHIFT 0
+#define RST_GMAC_0_MASK 0x100
+#define RST_GMAC_0_SHIFT 8
+
+/* Tx phase sync FIFO control register masks and shifts */
+#define PHASE_FIFO_CTL_RST_MASK 0x1
+#define PHASE_FIFO_CTL_RST_SHIFT 0
+#define PHASE_FIFO_CTL_INIT_MASK 0x2
+#define PHASE_FIFO_CTL_INIT_SHIFT 1
 
 /**
  * struct nps_enet_priv - Storage of ENET's private information.
@@ -285,8 +175,8 @@ struct nps_enet_priv {
 	bool tx_packet_sent;
 	struct sk_buff *tx_skb;
 	struct napi_struct napi;
-	struct nps_enet_ge_mac_cfg_2 ge_mac_cfg_2;
-	struct nps_enet_ge_mac_cfg_3 ge_mac_cfg_3;
+	u32 ge_mac_cfg_2_value;
+	u32 ge_mac_cfg_3_value;
 };
 
 /**
-- 
2.5.0
