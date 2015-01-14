From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH for 3.19 3/3] rtlwifi: rtl8192ee: Fix several bugs
Date: Wed, 14 Jan 2015 11:37:16 -0600
Message-ID: <1421257036-5382-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33396 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbbANRhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 12:37:41 -0500
In-Reply-To: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Tan <troy_tan@realsil.com.cn>

The following bugs are fixed in this driver:
1. Problems parsing C2H CMD
2. An ad-hoc connection can cause a TX freeze.
3. There are additional conditions that cause a TX freeze.
4. The previous code failed to handle situations where an RX
   descriptor was unavailable.

Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c  | 167 +++++++++++++++++++++----
 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h |   2 +
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c  |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c | 175 +++++++++++----------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h |   4 +-
 5 files changed, 217 insertions(+), 134 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
index 47beb49..215b970 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
@@ -85,29 +85,6 @@ static void _rtl92ee_enable_bcn_sub_func(struct ieee80211_hw *hw)
 	_rtl92ee_set_bcn_ctrl_reg(hw, 0, BIT(1));
 }
 
-static void _rtl92ee_return_beacon_queue_skb(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[BEACON_QUEUE];
-	unsigned long flags;
-
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
-	while (skb_queue_len(&ring->queue)) {
-		struct rtl_tx_buffer_desc *entry =
-						&ring->buffer_desc[ring->idx];
-		struct sk_buff *skb = __skb_dequeue(&ring->queue);
-
-		pci_unmap_single(rtlpci->pdev,
-				 rtlpriv->cfg->ops->get_desc(
-				 (u8 *)entry, true, HW_DESC_TXBUFF_ADDR),
-				 skb->len, PCI_DMA_TODEVICE);
-		kfree_skb(skb);
-		ring->idx = (ring->idx + 1) % ring->entries;
-	}
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
-}
-
 static void _rtl92ee_disable_bcn_sub_func(struct ieee80211_hw *hw)
 {
 	_rtl92ee_set_bcn_ctrl_reg(hw, BIT(1), 0);
@@ -403,9 +380,6 @@ static void _rtl92ee_download_rsvd_page(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, REG_DWBCN0_CTRL + 2,
 			       bcnvalid_reg | BIT(0));
 
-		/* Return Beacon TCB */
-		_rtl92ee_return_beacon_queue_skb(hw);
-
 		/* download rsvd page */
 		rtl92ee_set_fw_rsvdpagepkt(hw, false);
 
@@ -1163,6 +1137,140 @@ void rtl92ee_enable_hw_security_config(struct ieee80211_hw *hw)
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
 }
 
+static bool _rtl8192ee_check_pcie_dma_hang(struct rtl_priv *rtlpriv)
+{
+	u8 tmp;
+
+	/* write reg 0x350 Bit[26]=1. Enable debug port. */
+	tmp = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 3);
+	if (!(tmp & BIT(2))) {
+		rtl_write_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 3,
+			       (tmp | BIT(2)));
+		mdelay(100); /* Suggested by DD Justin_tsai. */
+	}
+
+	/* read reg 0x350 Bit[25] if 1 : RX hang
+	 * read reg 0x350 Bit[24] if 1 : TX hang
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 3);
+	if ((tmp & BIT(0)) || (tmp & BIT(1))) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "CheckPcieDMAHang8192EE(): true!!\n");
+		return true;
+	}
+	return false;
+}
+
+static void _rtl8192ee_reset_pcie_interface_dma(struct rtl_priv *rtlpriv,
+						bool mac_power_on)
+{
+	u8 tmp;
+	bool release_mac_rx_pause;
+	u8 backup_pcie_dma_pause;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "ResetPcieInterfaceDMA8192EE()\n");
+
+	/* Revise Note: Follow the document "PCIe RX DMA Hang Reset Flow_v03"
+	 * released by SD1 Alan.
+	 * 2013.05.07, by tynli.
+	 */
+
+	/* 1. disable register write lock
+	 *	write 0x1C bit[1:0] = 2'h0
+	 *	write 0xCC bit[2] = 1'b1
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL);
+	tmp &= ~(BIT(1) | BIT(0));
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, tmp);
+	tmp = rtl_read_byte(rtlpriv, REG_PMC_DBG_CTRL2);
+	tmp |= BIT(2);
+	rtl_write_byte(rtlpriv, REG_PMC_DBG_CTRL2, tmp);
+
+	/* 2. Check and pause TRX DMA
+	 *	write 0x284 bit[18] = 1'b1
+	 *	write 0x301 = 0xFF
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+	if (tmp & BIT(2)) {
+		/* Already pause before the function for another purpose. */
+		release_mac_rx_pause = false;
+	} else {
+		rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, (tmp | BIT(2)));
+		release_mac_rx_pause = true;
+	}
+
+	backup_pcie_dma_pause = rtl_read_byte(rtlpriv, REG_PCIE_CTRL_REG + 1);
+	if (backup_pcie_dma_pause != 0xFF)
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0xFF);
+
+	if (mac_power_on) {
+		/* 3. reset TRX function
+		 *	write 0x100 = 0x00
+		 */
+		rtl_write_byte(rtlpriv, REG_CR, 0);
+	}
+
+	/* 4. Reset PCIe DMA
+	 *	write 0x003 bit[0] = 0
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	tmp &= ~(BIT(0));
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp);
+
+	/* 5. Enable PCIe DMA
+	 *	write 0x003 bit[0] = 1
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	tmp |= BIT(0);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp);
+
+	if (mac_power_on) {
+		/* 6. enable TRX function
+		 *	write 0x100 = 0xFF
+		 */
+		rtl_write_byte(rtlpriv, REG_CR, 0xFF);
+
+		/* We should init LLT & RQPN and
+		 * prepare Tx/Rx descrptor address later
+		 * because MAC function is reset.
+		 */
+	}
+
+	/* 7. Restore PCIe autoload down bit
+	 *	write 0xF8 bit[17] = 1'b1
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_MAC_PHY_CTRL_NORMAL + 2);
+	tmp |= BIT(1);
+	rtl_write_byte(rtlpriv, REG_MAC_PHY_CTRL_NORMAL + 2, tmp);
+
+	/* In MAC power on state, BB and RF maybe in ON state,
+	 * if we release TRx DMA here
+	 * it will cause packets to be started to Tx/Rx,
+	 * so we release Tx/Rx DMA later.
+	 */
+	if (!mac_power_on) {
+		/* 8. release TRX DMA
+		 *	write 0x284 bit[18] = 1'b0
+		 *	write 0x301 = 0x00
+		 */
+		if (release_mac_rx_pause) {
+			tmp = rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+			rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL,
+				       (tmp & (~BIT(2))));
+		}
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1,
+			       backup_pcie_dma_pause);
+	}
+
+	/* 9. lock system register
+	 *	write 0xCC bit[2] = 1'b0
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_PMC_DBG_CTRL2);
+	tmp &= ~(BIT(2));
+	rtl_write_byte(rtlpriv, REG_PMC_DBG_CTRL2, tmp);
+}
+
 int rtl92ee_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1188,6 +1296,13 @@ int rtl92ee_hw_init(struct ieee80211_hw *hw)
 		rtlhal->fw_ps_state = FW_PS_STATE_ALL_ON_92E;
 	}
 
+	if (_rtl8192ee_check_pcie_dma_hang(rtlpriv)) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "92ee dma hang!\n");
+		_rtl8192ee_reset_pcie_interface_dma(rtlpriv,
+						    rtlhal->mac_func_enable);
+		rtlhal->mac_func_enable = false;
+	}
+
 	rtstatus = _rtl92ee_init_mac(hw);
 
 	rtl_write_byte(rtlpriv, 0x577, 0x03);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/reg.h b/drivers/net/wireless/rtlwifi/rtl8192ee/reg.h
index 3f2a959..696ae188 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/reg.h
@@ -77,9 +77,11 @@
 #define REG_HIMRE				0x00B8
 #define REG_HISRE				0x00BC
 
+#define REG_PMC_DBG_CTRL2			0x00CC
 #define REG_EFUSE_ACCESS			0x00CF
 #define REG_HPON_FSM				0x00EC
 #define REG_SYS_CFG1				0x00F0
+#define REG_MAC_PHY_CTRL_NORMAL		0x00F8
 #define REG_SYS_CFG2				0x00FC
 
 #define REG_CR					0x0100
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
index f30c916..100d6fc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
@@ -114,8 +114,6 @@ int rtl92ee_init_sw_vars(struct ieee80211_hw *hw)
 				  RCR_AMF			|
 				  RCR_ACF			|
 				  RCR_ADF			|
-				  RCR_AICV			|
-				  RCR_ACRC32			|
 				  RCR_AB			|
 				  RCR_AM			|
 				  RCR_APM			|
@@ -241,6 +239,7 @@ static struct rtl_hal_ops rtl8192ee_hal_ops = {
 	.set_desc = rtl92ee_set_desc,
 	.get_desc = rtl92ee_get_desc,
 	.is_tx_desc_closed = rtl92ee_is_tx_desc_closed,
+	.get_available_desc = rtl92ee_get_available_desc,
 	.tx_polling = rtl92ee_tx_polling,
 	.enable_hw_sec = rtl92ee_enable_hw_security_config,
 	.init_sw_leds = rtl92ee_init_sw_leds,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
index 51806ac..ee1df82 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
@@ -354,6 +354,11 @@ bool rtl92ee_rx_query_desc(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr;
 	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
 
+	if (GET_RX_STATUS_DESC_RPT_SEL(pdesc) == 0)
+		status->packet_report_type = NORMAL_RX;
+	else
+		status->packet_report_type = C2H_PACKET;
+
 	status->length = (u16)GET_RX_DESC_PKT_LEN(pdesc);
 	status->rx_drvinfo_size = (u8)GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
 				  RX_DRV_INFO_SIZE_UNIT;
@@ -472,44 +477,22 @@ u16 rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw, u8 queue_index)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u16 read_point = 0, write_point = 0, remind_cnt = 0;
-	u32 tmp_4byte = 0;
-	static u16 last_read_point;
-	static bool start_rx;
-
-	tmp_4byte = rtl_read_dword(rtlpriv, REG_RXQ_TXBD_IDX);
-	read_point = (u16)((tmp_4byte>>16) & 0x7ff);
-	write_point = (u16)(tmp_4byte & 0x7ff);
-
-	if (write_point != rtlpci->rx_ring[queue_index].next_rx_rp) {
-		RT_TRACE(rtlpriv, COMP_RXDESC, DBG_DMESG,
-			 "!!!write point is 0x%x, reg 0x3B4 value is 0x%x\n",
-			  write_point, tmp_4byte);
-		tmp_4byte = rtl_read_dword(rtlpriv, REG_RXQ_TXBD_IDX);
-		read_point = (u16)((tmp_4byte>>16) & 0x7ff);
-		write_point = (u16)(tmp_4byte & 0x7ff);
-	}
-
-	if (read_point > 0)
-		start_rx = true;
-	if (!start_rx)
-		return 0;
+	u16 desc_idx_hw = 0, desc_idx_host = 0, remind_cnt = 0;
+	u32 tmp_4byte = rtl_read_dword(rtlpriv, REG_RXQ_TXBD_IDX);
+	u32 rw_mask = 0x1ff;
 
-	if ((last_read_point > (RX_DESC_NUM_92E / 2)) &&
-	    (read_point <= (RX_DESC_NUM_92E / 2))) {
-		remind_cnt = RX_DESC_NUM_92E - write_point;
-	} else {
-		remind_cnt = (read_point >= write_point) ?
-			     (read_point - write_point) :
-			     (RX_DESC_NUM_92E - write_point + read_point);
-	}
+	desc_idx_hw = (u16)((tmp_4byte>>16) & rw_mask);
+	desc_idx_host = (u16)(tmp_4byte & rw_mask);
 
-	if (remind_cnt == 0)
+	/* may be no data, donot rx */
+	if (desc_idx_hw == desc_idx_host)
 		return 0;
 
-	rtlpci->rx_ring[queue_index].next_rx_rp = write_point;
+	remind_cnt = (desc_idx_hw > desc_idx_host) ?
+		     (desc_idx_hw - desc_idx_host) :
+		     (RX_DESC_NUM_92E - (desc_idx_host - desc_idx_hw));
 
-	last_read_point = read_point;
+	rtlpci->rx_ring[queue_index].next_rx_rp = desc_idx_host;
 	return remind_cnt;
 }
 
@@ -551,7 +534,8 @@ static u16 get_desc_addr_fr_q_idx(u16 queue_index)
 	return desc_address;
 }
 
-void rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 q_idx)
+/*free  desc that can be used */
+u16 rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 q_idx)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -561,15 +545,25 @@ void rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 q_idx)
 
 	tmp_4byte = rtl_read_dword(rtlpriv,
 				   get_desc_addr_fr_q_idx(q_idx));
-	current_tx_read_point = (u16)((tmp_4byte >> 16) & 0x0fff);
-	current_tx_write_point = (u16)((tmp_4byte) & 0x0fff);
+	current_tx_read_point = (u16)((tmp_4byte >> 16) & 0x01ff);
+	current_tx_write_point = (u16)((tmp_4byte) & 0x01ff);
+
+	if (current_tx_read_point == current_tx_write_point)
+		point_diff = TX_DESC_NUM_92E - 1;
+	else if (current_tx_read_point < current_tx_write_point)
+		point_diff = TX_DESC_NUM_92E - (current_tx_write_point -
+			     current_tx_read_point) - 1;
+	else
+		point_diff = current_tx_read_point - current_tx_write_point - 1;
 
-	point_diff = ((current_tx_read_point > current_tx_write_point) ?
-		      (current_tx_read_point - current_tx_write_point) :
-		      (TX_DESC_NUM_92E - current_tx_write_point +
-		       current_tx_read_point));
+	if (0 == point_diff) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
+			 "CR:%d,CW:%d\n",
+			 current_tx_read_point, current_tx_write_point);
+	}
 
 	rtlpci->tx_ring[q_idx].avl_desc = point_diff;
+	return point_diff;
 }
 
 void rtl92ee_pre_fill_tx_bd_desc(struct ieee80211_hw *hw,
@@ -706,7 +700,7 @@ void rtl92ee_tx_fill_desc(struct ieee80211_hw *hw,
 	mapping = pci_map_single(rtlpci->pdev, skb->data, skb->len,
 				 PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
 			 "DMA mapping error");
 		return;
 	}
@@ -870,7 +864,7 @@ void rtl92ee_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	u8 txdesc_len = 40;
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
 			 "DMA mapping error");
 		return;
 	}
@@ -918,8 +912,6 @@ void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 cur_tx_rp = 0;
 	u16 cur_tx_wp = 0;
-	static u16 last_txw_point;
-	static bool over_run;
 	u32 tmp = 0;
 	u8 q_idx = *val;
 
@@ -932,6 +924,7 @@ void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 			struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 			struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[q_idx];
 			u16 max_tx_desc = ring->entries;
+			u16 point_diff = 0;
 
 			if (q_idx == BEACON_QUEUE) {
 				ring->cur_tx_wp = 0;
@@ -940,44 +933,32 @@ void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 				return;
 			}
 
+			tmp = rtl_read_dword(rtlpriv,
+					     get_desc_addr_fr_q_idx(q_idx));
+			cur_tx_rp = (u16)((tmp >> 16) & 0x0fff);
+			cur_tx_wp = (u16)(tmp & 0x0fff);
+
+			ring->cur_tx_wp = cur_tx_wp;
+			ring->cur_tx_rp = cur_tx_rp;
+			point_diff = ((cur_tx_rp > cur_tx_wp) ?
+					      (cur_tx_rp - cur_tx_wp) :
+					      (TX_DESC_NUM_92E - 1 -
+					       cur_tx_wp + cur_tx_rp));
+
+			ring->avl_desc = point_diff;
+
 			ring->cur_tx_wp = ((ring->cur_tx_wp + 1) % max_tx_desc);
 
-			if (over_run) {
-				ring->cur_tx_wp = 0;
-				over_run = false;
-			}
-			if (ring->avl_desc > 1) {
+			if (ring->avl_desc >= 1) {
 				ring->avl_desc--;
-
 				rtl_write_word(rtlpriv,
 					       get_desc_addr_fr_q_idx(q_idx),
 					       ring->cur_tx_wp);
-
-				if (q_idx == 1)
-					last_txw_point = cur_tx_wp;
-			}
-
-			if (ring->avl_desc < (max_tx_desc - 15)) {
-				u16 point_diff = 0;
-
-				tmp =
-				  rtl_read_dword(rtlpriv,
-						 get_desc_addr_fr_q_idx(q_idx));
-				cur_tx_rp = (u16)((tmp >> 16) & 0x0fff);
-				cur_tx_wp = (u16)(tmp & 0x0fff);
-
-				ring->cur_tx_wp = cur_tx_wp;
-				ring->cur_tx_rp = cur_tx_rp;
-				point_diff = ((cur_tx_rp > cur_tx_wp) ?
-					      (cur_tx_rp - cur_tx_wp) :
-					      (TX_DESC_NUM_92E - 1 -
-					       cur_tx_wp + cur_tx_rp));
-
-				ring->avl_desc = point_diff;
+			} else {
+				pr_err("critical error! ring->avl_desc == 0\n");
 			}
 		}
-		break;
-		}
+		break; }
 	} else {
 		switch (desc_name) {
 		case HW_DESC_RX_PREPARE:
@@ -1043,38 +1024,29 @@ bool rtl92ee_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u16 read_point, write_point, available_desc_num;
+	u16 read_point, write_point;
 	bool ret = false;
-	static u8 stop_report_cnt;
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+	u16 cur_tx_rp, cur_tx_wp;
+	u32 tmpu32 = 0;
+
+	tmpu32 = rtl_read_dword(rtlpriv,
+				get_desc_addr_fr_q_idx(hw_queue));
+	cur_tx_rp = (u16)((tmpu32 >> 16) & 0x01ff);
+	cur_tx_wp = (u16)(tmpu32 & 0x01ff);
+
+	ring->cur_tx_wp = cur_tx_wp;
+	ring->cur_tx_rp = cur_tx_rp;
+	ring->avl_desc = ((cur_tx_rp > cur_tx_wp) ? (cur_tx_rp - cur_tx_wp) :
+			  (TX_DESC_NUM_92E - cur_tx_wp + cur_tx_rp));
 
-	/*checking Read/Write Point each interrupt wastes CPU */
-	if (stop_report_cnt > 15 || !rtlpriv->link_info.busytraffic) {
-		u16 point_diff = 0;
-		u16 cur_tx_rp, cur_tx_wp;
-		u32 tmpu32 = 0;
-
-		tmpu32 =
-		  rtl_read_dword(rtlpriv,
-				 get_desc_addr_fr_q_idx(hw_queue));
-		cur_tx_rp = (u16)((tmpu32 >> 16) & 0x0fff);
-		cur_tx_wp = (u16)(tmpu32 & 0x0fff);
-
-		ring->cur_tx_wp = cur_tx_wp;
-		ring->cur_tx_rp = cur_tx_rp;
-		point_diff = ((cur_tx_rp > cur_tx_wp) ?
-			      (cur_tx_rp - cur_tx_wp) :
-			      (TX_DESC_NUM_92E - cur_tx_wp + cur_tx_rp));
-
-		ring->avl_desc = point_diff;
-	}
 
 	read_point = ring->cur_tx_rp;
 	write_point = ring->cur_tx_wp;
-	available_desc_num = ring->avl_desc;
+
 
 	if (write_point > read_point) {
-		if (index < write_point && index >= read_point)
+		if (index <= write_point && index >= read_point)
 			ret = false;
 		else
 			ret = true;
@@ -1095,13 +1067,6 @@ bool rtl92ee_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index)
 	    rtlpriv->psc.rfoff_reason > RF_CHANGE_BY_PS)
 		ret = true;
 
-	if (hw_queue < BEACON_QUEUE) {
-		if (!ret)
-			stop_report_cnt++;
-		else
-			stop_report_cnt = 0;
-	}
-
 	return ret;
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
index 45fd9db..8f78ac9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
@@ -542,6 +542,8 @@
 	LE_BITS_TO_4BYTE(__pdesc+8, 12, 4)
 #define GET_RX_DESC_RX_IS_QOS(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+8, 16, 1)
+#define GET_RX_STATUS_DESC_RPT_SEL(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+8, 28, 1)
 
 #define GET_RX_DESC_RXMCS(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+12, 0, 7)
@@ -829,7 +831,7 @@ void rtl92ee_rx_check_dma_ok(struct ieee80211_hw *hw, u8 *header_desc,
 			     u8 queue_index);
 u16	rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw,
 					  u8 queue_index);
-void rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 queue_index);
+u16 rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 queue_index);
 void rtl92ee_pre_fill_tx_bd_desc(struct ieee80211_hw *hw,
 				 u8 *tx_bd_desc, u8 *desc, u8 queue_index,
 				 struct sk_buff *skb, dma_addr_t addr);
-- 
2.1.2
