From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 04/27] rtlwifi: Modify files for 2013.02.07 vendor version - part 4
Date: Mon, 25 Feb 2013 18:13:16 -0600
Message-ID: <1361837619-2985-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:47949 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759709Ab3BZAOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:11 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates files debug.{c,h}, efuse.c, pci.{c,h}, and wifi.h for
the changes in the newest vendor driver. The changes in pci.c include a
modification of the way the initial RX descriptors are assigned and
populated. Although the end result is identical, I made this change to
ease future comparisons between the vendor and kernel versions.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/debug.c |   5 +-
 drivers/net/wireless/rtlwifi/debug.h |   7 +
 drivers/net/wireless/rtlwifi/efuse.c |  42 ++-
 drivers/net/wireless/rtlwifi/pci.c   | 589 +++++++++++++++++++----------------
 drivers/net/wireless/rtlwifi/pci.h   |   1 +
 drivers/net/wireless/rtlwifi/wifi.h  |   1 +
 6 files changed, 363 insertions(+), 282 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.c b/drivers/net/wireless/rtlwifi/debug.c
index bdda9b2..7d52d3d 100644
--- a/drivers/net/wireless/rtlwifi/debug.c
+++ b/drivers/net/wireless/rtlwifi/debug.c
@@ -41,7 +41,10 @@ void rtl_dbgp_flag_init(struct ieee80211_hw *hw)
 	    COMP_BEACON | COMP_RATE | COMP_RXDESC | COMP_DIG | COMP_TXAGC |
 	    COMP_POWER | COMP_POWER_TRACKING | COMP_BB_POWERSAVING | COMP_SWAS |
 	    COMP_RF | COMP_TURBO | COMP_RATR | COMP_CMD |
-	    COMP_EFUSE | COMP_QOS | COMP_MAC80211 | COMP_REGD | COMP_CHAN;
+	    COMP_EFUSE | COMP_QOS | COMP_MAC80211 | COMP_REGD | COMP_CHAN |
+	    COMP_EASY_CONCURRENT | COMP_EFUSE | COMP_QOS | COMP_MAC80211 |
+	    COMP_REGD | COMP_CHAN | COMP_BT_COEXIST;
+
 
 	for (i = 0; i < DBGP_TYPE_MAX; i++)
 		rtlpriv->dbg.dbgp_type[i] = 0;
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index fd3269f..60119a6 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -135,6 +135,13 @@
 #define	PHY_TXPWR			BIT(8)
 #define	PHY_PWRDIFF			BIT(9)
 
+/* Define Dynamic Mechanism check module bit --> FDM */
+#define WA_IOT				BIT(0)
+#define DM_PWDB				BIT(1)
+#define DM_MONITOR			BIT(2)
+#define DM_DIG				BIT(3)
+#define DM_EDCA_TURBO			BIT(4)
+
 enum dbgp_flag_e {
 	FQOS = 0,
 	FTX = 1,
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 8e2f9af..41a03b1 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -35,8 +35,6 @@ static const u8 MAX_PGPKT_SIZE = 9;
 static const u8 PGPKT_DATA_SIZE = 8;
 static const int EFUSE_MAX_SIZE = 512;
 
-static const u8 EFUSE_OOB_PROTECT_BYTES = 15;
-
 static const struct efuse_map RTL8712_SDIO_EFUSE_TABLE[] = {
 	{0, 0, 0, 2},
 	{0, 1, 0, 2},
@@ -240,6 +238,7 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	u8 rtemp8[1];
 	u16 efuse_addr = 0;
 	u8 offset, wren;
+	u8 u1temp = 0;
 	u16 i;
 	u16 j;
 	const u16 efuse_max_section =
@@ -285,10 +284,31 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	}
 
 	while ((*rtemp8 != 0xFF) && (efuse_addr < efuse_len)) {
-		offset = ((*rtemp8 >> 4) & 0x0f);
+		/*  Check PG header for section num.  */
+		if ((*rtemp8 & 0x1F) == 0x0F) {/* extended header */
+			u1temp = ((*rtemp8 & 0xE0) >> 5);
+			read_efuse_byte(hw, efuse_addr, rtemp8);
 
-		if (offset < efuse_max_section) {
+			if ((*rtemp8 & 0x0F) == 0x0F) {
+				efuse_addr++;
+				read_efuse_byte(hw, efuse_addr, rtemp8);
+
+				if (*rtemp8 != 0xFF &&
+				    (efuse_addr < efuse_len)) {
+					efuse_addr++;
+				}
+				continue;
+			} else {
+				offset = ((*rtemp8 & 0xF0) >> 1) | u1temp;
+				wren = (*rtemp8 & 0x0F);
+				efuse_addr++;
+			}
+		} else {
+			offset = ((*rtemp8 >> 4) & 0x0f);
 			wren = (*rtemp8 & 0x0f);
+		}
+
+		if (offset < efuse_max_section) {
 			RTPRINT(rtlpriv, FEEPROM, EFUSE_READ_ALL,
 				"offset-%d Worden=%x\n", offset, wren);
 
@@ -391,7 +411,8 @@ bool efuse_shadow_update_chk(struct ieee80211_hw *hw)
 	efuse_used = rtlefuse->efuse_usedbytes;
 
 	if ((totalbytes + efuse_used) >=
-	    (EFUSE_MAX_SIZE - EFUSE_OOB_PROTECT_BYTES))
+	    (EFUSE_MAX_SIZE -
+	     rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN]))
 		result = false;
 
 	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
@@ -932,8 +953,8 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	u8 badworden = 0x0F;
 	static int repeat_times;
 
-	if (efuse_get_current_size(hw) >=
-	    (EFUSE_MAX_SIZE - EFUSE_OOB_PROTECT_BYTES)) {
+	if (efuse_get_current_size(hw) >= (EFUSE_MAX_SIZE -
+	    rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN])) {
 		RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
 			"efuse_pg_packet_write error\n");
 		return false;
@@ -949,8 +970,8 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 
 	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,  "efuse Power ON\n");
 
-	while (continual && (efuse_addr <
-	       (EFUSE_MAX_SIZE - EFUSE_OOB_PROTECT_BYTES))) {
+	while (continual && (efuse_addr < (EFUSE_MAX_SIZE -
+	       rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN]))) {
 
 		if (write_state == PG_STATE_HEADER) {
 			badworden = 0x0F;
@@ -1003,7 +1024,8 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 		}
 	}
 
-	if (efuse_addr >= (EFUSE_MAX_SIZE - EFUSE_OOB_PROTECT_BYTES)) {
+	if (efuse_addr >= (EFUSE_MAX_SIZE -
+	    rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN])) {
 		RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
 			 "efuse_addr(%#x) Out of size!!\n", efuse_addr);
 	}
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 4261e8e..70c2497 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -59,7 +59,7 @@ static u8 _rtl_mac_to_hwqueue(struct ieee80211_hw *hw,
 
 	if (unlikely(ieee80211_is_beacon(fc)))
 		return BEACON_QUEUE;
-	if (ieee80211_is_mgmt(fc))
+	if (ieee80211_is_mgmt(fc) || ieee80211_is_ctl(fc))
 		return MGNT_QUEUE;
 	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192SE)
 		if (ieee80211_is_nullfunc(fc))
@@ -271,9 +271,6 @@ static void rtl_pci_enable_aspm(struct ieee80211_hw *hw)
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	u8 pcibridge_busnum = pcipriv->ndis_adapter.pcibridge_busnum;
-	u8 pcibridge_devnum = pcipriv->ndis_adapter.pcibridge_devnum;
-	u8 pcibridge_funcnum = pcipriv->ndis_adapter.pcibridge_funcnum;
 	u8 pcibridge_vendor = pcipriv->ndis_adapter.pcibridge_vendor;
 	u8 num4bytes = pcipriv->ndis_adapter.num4bytes;
 	u16 aspmlevel;
@@ -302,8 +299,7 @@ static void rtl_pci_enable_aspm(struct ieee80211_hw *hw)
 			      u_pcibridge_aspmsetting);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "PlatformEnableASPM():PciBridge busnumber[%x], DevNumbe[%x], funcnumber[%x], Write reg[%x] = %x\n",
-		 pcibridge_busnum, pcibridge_devnum, pcibridge_funcnum,
+		 "PlatformEnableASPM(): Write reg[%x] = %x\n",
 		 (pcipriv->ndis_adapter.pcibridge_pciehdr_offset + 0x10),
 		 u_pcibridge_aspmsetting);
 
@@ -349,6 +345,49 @@ static bool rtl_pci_get_amd_l1_patch(struct ieee80211_hw *hw)
 	return status;
 }
 
+static bool rtl_pci_check_buddy_priv(struct ieee80211_hw *hw,
+				     struct rtl_priv **buddy_priv)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	bool find_buddy_priv = false;
+	struct rtl_priv *tpriv = NULL;
+	struct rtl_pci_priv *tpcipriv = NULL;
+
+	if (!list_empty(&rtlpriv->glb_var->glb_priv_list)) {
+		list_for_each_entry(tpriv, &rtlpriv->glb_var->glb_priv_list,
+				    list) {
+			if (tpriv) {
+				tpcipriv = (struct rtl_pci_priv *)tpriv->priv;
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "pcipriv->ndis_adapter.funcnumber %x\n",
+					pcipriv->ndis_adapter.funcnumber);
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "tpcipriv->ndis_adapter.funcnumber %x\n",
+					tpcipriv->ndis_adapter.funcnumber);
+
+				if ((pcipriv->ndis_adapter.busnumber ==
+				     tpcipriv->ndis_adapter.busnumber) &&
+				    (pcipriv->ndis_adapter.devnumber ==
+				    tpcipriv->ndis_adapter.devnumber) &&
+				    (pcipriv->ndis_adapter.funcnumber !=
+				    tpcipriv->ndis_adapter.funcnumber)) {
+					find_buddy_priv = true;
+					break;
+				}
+			}
+		}
+	}
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "find_buddy_priv %d\n", find_buddy_priv);
+
+	if (find_buddy_priv)
+		*buddy_priv = tpriv;
+
+	return find_buddy_priv;
+}
+
 static void rtl_pci_get_linkcontrol_field(struct ieee80211_hw *hw)
 {
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
@@ -420,17 +459,14 @@ static void _rtl_pci_io_handler_init(struct device *dev,
 
 }
 
-static void _rtl_pci_io_handler_release(struct ieee80211_hw *hw)
-{
-}
-
 static bool _rtl_update_earlymode_info(struct ieee80211_hw *hw,
 		struct sk_buff *skb, struct rtl_tcb_desc *tcb_desc, u8 tid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
-	u8 additionlen = FCS_LEN;
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct sk_buff *next_skb;
+	u8 additionlen = FCS_LEN;
 
 	/* here open is 4, wep/tkip is 8, aes is 12*/
 	if (info->control.hw_key)
@@ -455,7 +491,7 @@ static bool _rtl_update_earlymode_info(struct ieee80211_hw *hw,
 				      next_skb))
 			break;
 
-		if (tcb_desc->empkt_num >= 5)
+		if (tcb_desc->empkt_num >= rtlhal->max_earlymode_num)
 			break;
 	}
 	spin_unlock_bh(&rtlpriv->locks.waitq_lock);
@@ -471,11 +507,17 @@ static void _rtl_pci_tx_chk_waitq(struct ieee80211_hw *hw)
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct sk_buff *skb = NULL;
 	struct ieee80211_tx_info *info = NULL;
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	int tid;
 
 	if (!rtlpriv->rtlhal.earlymode_enable)
 		return;
 
+	if (rtlpriv->dm.supp_phymode_switch &&
+	    (rtlpriv->easy_concurrent_ctl.switch_in_process ||
+	    (rtlpriv->buddy_priv &&
+	    rtlpriv->buddy_priv->easy_concurrent_ctl.switch_in_process)))
+		return;
 	/* we juse use em for BE/BK/VI/VO */
 	for (tid = 7; tid >= 0; tid--) {
 		u8 hw_queue = ac_to_hwq[rtl_tid_to_ac(tid)];
@@ -487,7 +529,8 @@ static void _rtl_pci_tx_chk_waitq(struct ieee80211_hw *hw)
 
 			spin_lock_bh(&rtlpriv->locks.waitq_lock);
 			if (!skb_queue_empty(&mac->skb_waitq[tid]) &&
-			   (ring->entries - skb_queue_len(&ring->queue) > 5)) {
+			    (ring->entries - skb_queue_len(&ring->queue) >
+			     rtlhal->max_earlymode_num)) {
 				skb = skb_dequeue(&mac->skb_waitq[tid]);
 			} else {
 				spin_unlock_bh(&rtlpriv->locks.waitq_lock);
@@ -527,7 +570,7 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 
 		/*
 		 *beacon packet will only use the first
-		 *descriptor defautly,and the own may not
+		 *descriptor by defaut, and the own may not
 		 *be cleared by the hardware
 		 */
 		if (own)
@@ -558,8 +601,9 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 		}
 
 		/* for sw LPS, just after NULL skb send out, we can
-		 * sure AP kown we are sleeped, our we should not let
-		 * rf to sleep*/
+		 * sure AP knows we are sleeping, we should not let
+		 * rf sleep
+		 */
 		fc = rtl_get_fc(skb);
 		if (ieee80211_is_nullfunc(fc)) {
 			if (ieee80211_has_pm(fc)) {
@@ -569,6 +613,15 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 				rtlpriv->psc.state_inap = false;
 			}
 		}
+		if (ieee80211_is_action(fc)) {
+			struct ieee80211_mgmt *action_frame =
+				(struct ieee80211_mgmt *)skb->data;
+			if (action_frame->u.action.u.ht_smps.action ==
+			    WLAN_HT_ACTION_SMPS) {
+				dev_kfree_skb(skb);
+				goto tx_status_ok;
+			}
+		}
 
 		/* update tid tx pkt num */
 		tid = rtl_get_tid(skb);
@@ -606,16 +659,84 @@ tx_status_ok:
 	}
 }
 
-static void _rtl_receive_one(struct ieee80211_hw *hw, struct sk_buff *skb,
-			     struct ieee80211_rx_status rx_status)
+static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
+	struct rtl_rx_desc *entry, int rxring_idx, int desc_idx)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
-	__le16 fc = rtl_get_fc(skb);
-	bool unicast = false;
-	struct sk_buff *uskb = NULL;
-	u8 *pdata;
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 bufferaddress;
+	u8 tmp_one = 1;
+	struct sk_buff *skb;
+
+	skb = dev_alloc_skb(rtlpci->rxbuffersize);
+	if (!skb)
+		return 0;
+	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
 
+	/* just set skb->cb to mapping addr
+	 * for pci_unmap_single use
+	 */
+	*((dma_addr_t *)skb->cb) = pci_map_single(rtlpci->pdev,
+				skb_tail_pointer(skb), rtlpci->rxbuffersize,
+				PCI_DMA_FROMDEVICE);
+	bufferaddress = *((dma_addr_t *)skb->cb);
+	if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress))
+		return 0;
+
+	rtlpriv->cfg->ops->set_desc((u8 *)entry, false, HW_DESC_RXBUFF_ADDR,
+				    (u8 *)&bufferaddress);
+	rtlpriv->cfg->ops->set_desc((u8 *)entry, false, HW_DESC_RXPKT_LEN,
+				    (u8 *)&rtlpci->rxbuffersize);
+	rtlpriv->cfg->ops->set_desc((u8 *)entry, false, HW_DESC_RXOWN,
+				    (u8 *)&tmp_one);
+
+	return 1;
+}
+
+/* inorder to receive 8K AMSDU we have set skb to
+ * 9100bytes in init rx ring, but if this packet is
+ * not a AMSDU, this so big packet will be sent to
+ * TCP/IP directly, this cause big packet ping fail
+ * like: "ping -s 65507", so here we will realloc skb
+ * based on the true size of packet, I think mac80211
+ * do it will be better, but now mac80211 haven't
+ *
+ * but some platform will fail when alloc skb sometimes.
+ * in this condition, we will send the old skb to
+ * mac80211 directly, this will not cause any other
+ * issues, but only be losted by TCP/IP
+ */
+static void _rtl_pci_rx_to_mac80211(struct ieee80211_hw *hw,
+	struct sk_buff *skb, struct ieee80211_rx_status rx_status)
+{
+	if (unlikely(!rtl_action_proc(hw, skb, false))) {
+		dev_kfree_skb_any(skb);
+	} else {
+		struct sk_buff *uskb = NULL;
+		u8 *pdata;
+
+		uskb = dev_alloc_skb(skb->len + 128);
+		if (likely(uskb)) {
+			memcpy(IEEE80211_SKB_RXCB(uskb), &rx_status,
+			       sizeof(rx_status));
+			pdata = (u8 *)skb_put(uskb, skb->len);
+			memcpy(pdata, skb->data, skb->len);
+			dev_kfree_skb_any(skb);
+
+			ieee80211_rx_irqsafe(hw, uskb);
+		} else {
+			ieee80211_rx_irqsafe(hw, skb);
+		}
+	}
+}
+
+static void handle_ok_packet(struct ieee80211_hw *hw, struct sk_buff *skb,
+			     struct ieee80211_rx_status rx_status,
+			     struct ieee80211_hdr *hdr)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	bool unicast = false;
+	__le16 fc = rtl_get_fc(skb);
 
 	memcpy(IEEE80211_SKB_RXCB(skb), &rx_status, sizeof(rx_status));
 
@@ -637,134 +758,100 @@ static void _rtl_receive_one(struct ieee80211_hw *hw, struct sk_buff *skb,
 			rtlpriv->link_info.num_rx_inperiod++;
 	}
 
+	/* static bcn for roaming */
+	rtl_beacon_statistic(hw, skb);
+	rtl_p2p_info(hw, (void *)skb->data, skb->len);
 	/* for sw lps */
 	rtl_swlps_beacon(hw, (void *)skb->data, skb->len);
 	rtl_recognize_peer(hw, (void *)skb->data, skb->len);
 	if ((rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP) &&
 	    (rtlpriv->rtlhal.current_bandtype == BAND_ON_2_4G) &&
-	     (ieee80211_is_beacon(fc) || ieee80211_is_probe_resp(fc)))
-		return;
-
-	if (unlikely(!rtl_action_proc(hw, skb, false)))
-		return;
-
-	uskb = dev_alloc_skb(skb->len + 128);
-	if (!uskb)
-		return;		/* exit if allocation failed */
-	memcpy(IEEE80211_SKB_RXCB(uskb), &rx_status, sizeof(rx_status));
-	pdata = (u8 *)skb_put(uskb, skb->len);
-	memcpy(pdata, skb->data, skb->len);
-
-	ieee80211_rx_irqsafe(hw, uskb);
+	    (ieee80211_is_beacon(fc) || ieee80211_is_probe_resp(fc)))
+		dev_kfree_skb_any(skb);
+	else
+		_rtl_pci_rx_to_mac80211(hw, skb, rx_status);
 }
 
 static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	int rx_queue_idx = RTL_PCI_RX_MPDU_QUEUE;
+	int rxring_idx = RTL_PCI_RX_MPDU_QUEUE;
 
 	struct ieee80211_rx_status rx_status = { 0 };
 	unsigned int count = rtlpci->rxringcount;
 	u8 own;
 	u8 tmp_one;
-	u32 bufferaddress;
 
 	struct rtl_stats stats = {
 		.signal = 0,
 		.noise = -98,
 		.rate = 0,
 	};
-	int index = rtlpci->rx_ring[rx_queue_idx].idx;
 
 	/*RX NORMAL PKT */
 	while (count--) {
 		/*rx descriptor */
-		struct rtl_rx_desc *pdesc = &rtlpci->rx_ring[rx_queue_idx].desc[
-				index];
+		struct rtl_rx_desc *pdesc = &rtlpci->rx_ring[rxring_idx].desc[
+				rtlpci->rx_ring[rxring_idx].idx];
 		/*rx pkt */
-		struct sk_buff *skb = rtlpci->rx_ring[rx_queue_idx].rx_buf[
-				index];
-		struct sk_buff *new_skb = NULL;
+		struct sk_buff *skb = rtlpci->rx_ring[rxring_idx].rx_buf[
+				rtlpci->rx_ring[rxring_idx].idx];
 
-		own = (u8) rtlpriv->cfg->ops->get_desc((u8 *) pdesc,
+		own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc,
 						       false, HW_DESC_OWN);
 
-		/*wait data to be filled by hardware */
-		if (own)
-			break;
+		if (own) {
+			/*wait data to be filled by hardware */
+			return;
 
-		rtlpriv->cfg->ops->query_rx_desc(hw, &stats,
-						 &rx_status,
-						 (u8 *) pdesc, skb);
+		} else {
+			struct ieee80211_hdr *hdr;
+			__le16 fc;
 
-		if (stats.crc || stats.hwerror)
-			goto done;
+			rtlpriv->cfg->ops->query_rx_desc(hw, &stats,
+					 &rx_status, (u8 *)pdesc, skb);
+			pci_unmap_single(rtlpci->pdev, *((dma_addr_t *)skb->cb),
+					 rtlpci->rxbuffersize,
+					 PCI_DMA_FROMDEVICE);
 
-		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
-		if (unlikely(!new_skb)) {
-			RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV), DBG_DMESG,
-				 "can't alloc skb for rx\n");
-			goto done;
-		}
+			skb_put(skb, rtlpriv->cfg->ops->get_desc((u8 *)pdesc,
+				false, HW_DESC_RXPKT_LEN));
+			skb_reserve(skb, stats.rx_drvinfo_size +
+				    stats.rx_bufshift);
 
-		pci_unmap_single(rtlpci->pdev,
-				 *((dma_addr_t *) skb->cb),
-				 rtlpci->rxbuffersize,
-				 PCI_DMA_FROMDEVICE);
+			/*
+			 *NOTICE This can not be use for mac80211,
+			 *this is done in mac80211 code,
+			 *if you done here sec DHCP will fail
+			 *skb_trim(skb, skb->len - 4);
+			 */
 
-		skb_put(skb, rtlpriv->cfg->ops->get_desc((u8 *) pdesc, false,
-			HW_DESC_RXPKT_LEN));
-		skb_reserve(skb, stats.rx_drvinfo_size + stats.rx_bufshift);
+			hdr = rtl_get_hdr(skb);
+			fc = rtl_get_fc(skb);
 
-		/*
-		 * NOTICE This can not be use for mac80211,
-		 * this is done in mac80211 code,
-		 * if you done here sec DHCP will fail
-		 * skb_trim(skb, skb->len - 4);
-		 */
+			if (!stats.crc && !stats.hwerror)
+				handle_ok_packet(hw, skb, rx_status, hdr);
+			else
+				dev_kfree_skb_any(skb);
 
-		_rtl_receive_one(hw, skb, rx_status);
+			if (((rtlpriv->link_info.num_rx_inperiod +
+			      rtlpriv->link_info.num_tx_inperiod) > 8) ||
+			      (rtlpriv->link_info.num_rx_inperiod > 2))
+				schedule_work(&rtlpriv->works.lps_leave_work);
 
-		if (((rtlpriv->link_info.num_rx_inperiod +
-			rtlpriv->link_info.num_tx_inperiod) > 8) ||
-			(rtlpriv->link_info.num_rx_inperiod > 2)) {
-			schedule_work(&rtlpriv->works.lps_leave_work);
+			_rtl_pci_init_one_rxdesc(hw, pdesc, rxring_idx,
+				rtlpci->rx_ring[rxring_idx].idx);
 		}
 
-		dev_kfree_skb_any(skb);
-		skb = new_skb;
-
-		rtlpci->rx_ring[rx_queue_idx].rx_buf[index] = skb;
-		*((dma_addr_t *) skb->cb) =
-			    pci_map_single(rtlpci->pdev, skb_tail_pointer(skb),
-					   rtlpci->rxbuffersize,
-					   PCI_DMA_FROMDEVICE);
-
-done:
-		bufferaddress = (*((dma_addr_t *)skb->cb));
-		if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress))
-			return;
-		tmp_one = 1;
-		rtlpriv->cfg->ops->set_desc((u8 *) pdesc, false,
-					    HW_DESC_RXBUFF_ADDR,
-					    (u8 *)&bufferaddress);
-		rtlpriv->cfg->ops->set_desc((u8 *)pdesc, false,
-					    HW_DESC_RXPKT_LEN,
-					    (u8 *)&rtlpci->rxbuffersize);
-
-		if (index == rtlpci->rxringcount - 1)
+		if (rtlpci->rx_ring[rxring_idx].idx == rtlpci->rxringcount - 1)
 			rtlpriv->cfg->ops->set_desc((u8 *)pdesc, false,
 						    HW_DESC_RXERO,
-						    &tmp_one);
-
-		rtlpriv->cfg->ops->set_desc((u8 *)pdesc, false, HW_DESC_RXOWN,
-					    &tmp_one);
-
-		index = (index + 1) % rtlpci->rxringcount;
+						    (u8 *)&tmp_one);
+		rtlpci->rx_ring[rxring_idx].idx =
+			 (rtlpci->rx_ring[rxring_idx].idx + 1) %
+			 rtlpci->rxringcount;
 	}
-
-	rtlpci->rx_ring[rx_queue_idx].idx = index;
 }
 
 static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
@@ -884,6 +971,16 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		_rtl_pci_rx_interrupt(hw);
 	}
 
+	/*fw related*/
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723AE) {
+		if (inta & rtlpriv->cfg->maps[RTL_IMR_C2HCMD]) {
+			RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
+				 "firmware interrupt!\n");
+			queue_delayed_work(rtlpriv->works.rtl_wq,
+					   &rtlpriv->works.fwevt_wq, 0);
+		}
+	}
+
 	if (rtlpriv->rtlhal.earlymode_enable)
 		tasklet_schedule(&rtlpriv->works.irq_tasklet);
 
@@ -913,13 +1010,8 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 	memset(&tcb_desc, 0, sizeof(struct rtl_tcb_desc));
 	ring = &rtlpci->tx_ring[BEACON_QUEUE];
 	pskb = __skb_dequeue(&ring->queue);
-	if (pskb) {
-		struct rtl_tx_desc *entry = &ring->desc[ring->idx];
-		pci_unmap_single(rtlpci->pdev, rtlpriv->cfg->ops->get_desc(
-				 (u8 *) entry, true, HW_DESC_TXBUFF_ADDR),
-				 pskb->len, PCI_DMA_TODEVICE);
+	if (pskb)
 		kfree_skb(pskb);
-	}
 
 	/*NB: the beacon data buffer must be 32-bit aligned. */
 	pskb = ieee80211_beacon_get(hw, mac->vif);
@@ -928,14 +1020,12 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 	hdr = rtl_get_hdr(pskb);
 	info = IEEE80211_SKB_CB(pskb);
 	pdesc = &ring->desc[0];
-	rtlpriv->cfg->ops->fill_tx_desc(hw, hdr, (u8 *) pdesc,
+	rtlpriv->cfg->ops->fill_tx_desc(hw, hdr, (u8 *)pdesc,
 		info, NULL, pskb, BEACON_QUEUE, &tcb_desc);
-
 	__skb_queue_tail(&ring->queue, pskb);
 
-	rtlpriv->cfg->ops->set_desc((u8 *) pdesc, true, HW_DESC_OWN,
-				    &temp_one);
-
+	rtlpriv->cfg->ops->set_desc((u8 *)pdesc, true, HW_DESC_OWN,
+				    (u8 *)&temp_one);
 	return;
 }
 
@@ -1022,6 +1112,7 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 	u32 nextdescaddress;
 	int i;
 
+	/* alloc dma for this ring */
 	ring = pci_alloc_consistent(rtlpci->pdev,
 				    sizeof(*ring) * entries, &dma);
 
@@ -1041,9 +1132,9 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "queue:%d, ring_addr:%p\n",
 		 prio, ring);
 
+	/* init every desc in this ring */
 	for (i = 0; i < entries; i++) {
-		nextdescaddress = (u32) dma +
-					      ((i + 1) % entries) *
+		nextdescaddress = (u32)dma + ((i + 1) % entries) *
 					      sizeof(*ring);
 
 		rtlpriv->cfg->ops->set_desc((u8 *)&(ring[i]),
@@ -1054,88 +1145,39 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 	return 0;
 }
 
-static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw)
+static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw, int rxring_idx)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_rx_desc *entry = NULL;
-	int i, rx_queue_idx;
+	int i;
 	u8 tmp_one = 1;
 
-	/*
-	 *rx_queue_idx 0:RX_MPDU_QUEUE
-	 *rx_queue_idx 1:RX_CMD_QUEUE
-	 */
-	for (rx_queue_idx = 0; rx_queue_idx < RTL_PCI_MAX_RX_QUEUE;
-	     rx_queue_idx++) {
-		rtlpci->rx_ring[rx_queue_idx].desc =
-		    pci_alloc_consistent(rtlpci->pdev,
-					 sizeof(*rtlpci->rx_ring[rx_queue_idx].
-						desc) * rtlpci->rxringcount,
-					 &rtlpci->rx_ring[rx_queue_idx].dma);
-
-		if (!rtlpci->rx_ring[rx_queue_idx].desc ||
-		    (unsigned long)rtlpci->rx_ring[rx_queue_idx].desc & 0xFF) {
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "Cannot allocate RX ring\n");
-			return -ENOMEM;
-		}
-
-		memset(rtlpci->rx_ring[rx_queue_idx].desc, 0,
-		       sizeof(*rtlpci->rx_ring[rx_queue_idx].desc) *
-		       rtlpci->rxringcount);
-
-		rtlpci->rx_ring[rx_queue_idx].idx = 0;
-
-		/* If amsdu_8k is disabled, set buffersize to 4096. This
-		 * change will reduce memory fragmentation.
-		 */
-		if (rtlpci->rxbuffersize > 4096 &&
-		    rtlpriv->rtlhal.disable_amsdu_8k)
-			rtlpci->rxbuffersize = 4096;
-
-		for (i = 0; i < rtlpci->rxringcount; i++) {
-			struct sk_buff *skb =
-			    dev_alloc_skb(rtlpci->rxbuffersize);
-			u32 bufferaddress;
-			if (!skb)
-				return 0;
-			kmemleak_not_leak(skb);
-			entry = &rtlpci->rx_ring[rx_queue_idx].desc[i];
-
-			/*skb->dev = dev; */
-
-			rtlpci->rx_ring[rx_queue_idx].rx_buf[i] = skb;
-
-			/*
-			 *just set skb->cb to mapping addr
-			 *for pci_unmap_single use
-			 */
-			*((dma_addr_t *) skb->cb) =
-			    pci_map_single(rtlpci->pdev, skb_tail_pointer(skb),
-					   rtlpci->rxbuffersize,
-					   PCI_DMA_FROMDEVICE);
+	/* alloc dma for this ring */
+	rtlpci->rx_ring[rxring_idx].desc = pci_alloc_consistent(rtlpci->pdev,
+				 sizeof(*rtlpci->rx_ring[rxring_idx].desc) *
+				 rtlpci->rxringcount,
+				 &rtlpci->rx_ring[rxring_idx].dma);
+	if (!rtlpci->rx_ring[rxring_idx].desc ||
+	    (unsigned long)rtlpci->rx_ring[rxring_idx].desc & 0xFF) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Cannot allocate RX ring\n");
+		return -ENOMEM;
+	}
 
-			bufferaddress = (*((dma_addr_t *)skb->cb));
-			if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress)) {
-				dev_kfree_skb_any(skb);
-				return 1;
-			}
-			rtlpriv->cfg->ops->set_desc((u8 *)entry, false,
-						    HW_DESC_RXBUFF_ADDR,
-						    (u8 *)&bufferaddress);
-			rtlpriv->cfg->ops->set_desc((u8 *)entry, false,
-						    HW_DESC_RXPKT_LEN,
-						    (u8 *)&rtlpci->
-						    rxbuffersize);
-			rtlpriv->cfg->ops->set_desc((u8 *) entry, false,
-						    HW_DESC_RXOWN,
-						    &tmp_one);
-		}
+	memset(rtlpci->rx_ring[rxring_idx].desc, 0,
+	       sizeof(*rtlpci->rx_ring[rxring_idx].desc) *
+	       rtlpci->rxringcount);
 
-		rtlpriv->cfg->ops->set_desc((u8 *) entry, false,
-					    HW_DESC_RXERO, &tmp_one);
+	/* init every desc in this ring */
+	rtlpci->rx_ring[rxring_idx].idx = 0;
+	for (i = 0; i < rtlpci->rxringcount; i++) {
+		entry = &rtlpci->rx_ring[rxring_idx].desc[i];
+		if (!_rtl_pci_init_one_rxdesc(hw, entry, rxring_idx, i))
+			return -ENOMEM;
 	}
+	rtlpriv->cfg->ops->set_desc((u8 *)entry, false,
+				    HW_DESC_RXERO, (u8 *)&tmp_one);
 	return 0;
 }
 
@@ -1146,72 +1188,69 @@ static void _rtl_pci_free_tx_ring(struct ieee80211_hw *hw,
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[prio];
 
+	/* free every desc in this ring */
 	while (skb_queue_len(&ring->queue)) {
 		struct rtl_tx_desc *entry = &ring->desc[ring->idx];
 		struct sk_buff *skb = __skb_dequeue(&ring->queue);
 
 		pci_unmap_single(rtlpci->pdev,
-				 rtlpriv->cfg->
-					     ops->get_desc((u8 *) entry, true,
-						   HW_DESC_TXBUFF_ADDR),
+				 rtlpriv->cfg->ops->get_desc((u8 *)entry, true,
+				 HW_DESC_TXBUFF_ADDR),
 				 skb->len, PCI_DMA_TODEVICE);
 		kfree_skb(skb);
 		ring->idx = (ring->idx + 1) % ring->entries;
 	}
 
-	if (ring->desc) {
-		pci_free_consistent(rtlpci->pdev,
-				    sizeof(*ring->desc) * ring->entries,
-				    ring->desc, ring->dma);
-		ring->desc = NULL;
-	}
+	/* free dma of this ring */
+	pci_free_consistent(rtlpci->pdev,
+			    sizeof(*ring->desc) * ring->entries,
+			    ring->desc, ring->dma);
+	ring->desc = NULL;
 }
 
-static void _rtl_pci_free_rx_ring(struct rtl_pci *rtlpci)
+static void _rtl_pci_free_rx_ring(struct rtl_pci *rtlpci,
+			int rxring_idx)
 {
-	int i, rx_queue_idx;
-
-	/*rx_queue_idx 0:RX_MPDU_QUEUE */
-	/*rx_queue_idx 1:RX_CMD_QUEUE */
-	for (rx_queue_idx = 0; rx_queue_idx < RTL_PCI_MAX_RX_QUEUE;
-	     rx_queue_idx++) {
-		for (i = 0; i < rtlpci->rxringcount; i++) {
-			struct sk_buff *skb =
-			    rtlpci->rx_ring[rx_queue_idx].rx_buf[i];
-			if (!skb)
-				continue;
-
-			pci_unmap_single(rtlpci->pdev,
-					 *((dma_addr_t *) skb->cb),
-					 rtlpci->rxbuffersize,
-					 PCI_DMA_FROMDEVICE);
-			kfree_skb(skb);
-		}
+	int i;
 
-		if (rtlpci->rx_ring[rx_queue_idx].desc) {
-			pci_free_consistent(rtlpci->pdev,
-				    sizeof(*rtlpci->rx_ring[rx_queue_idx].
-					   desc) * rtlpci->rxringcount,
-				    rtlpci->rx_ring[rx_queue_idx].desc,
-				    rtlpci->rx_ring[rx_queue_idx].dma);
-			rtlpci->rx_ring[rx_queue_idx].desc = NULL;
-		}
+	/* free every desc in this ring */
+	for (i = 0; i < rtlpci->rxringcount; i++) {
+		struct sk_buff *skb = rtlpci->rx_ring[rxring_idx].rx_buf[i];
+		if (!skb)
+			continue;
+
+		pci_unmap_single(rtlpci->pdev, *((dma_addr_t *)skb->cb),
+				 rtlpci->rxbuffersize, PCI_DMA_FROMDEVICE);
+		kfree_skb(skb);
 	}
+
+	/* free dma of this ring */
+	pci_free_consistent(rtlpci->pdev,
+			    sizeof(*rtlpci->rx_ring[rxring_idx].desc) *
+			    rtlpci->rxringcount,
+			    rtlpci->rx_ring[rxring_idx].desc,
+			    rtlpci->rx_ring[rxring_idx].dma);
+	rtlpci->rx_ring[rxring_idx].desc = NULL;
 }
 
 static int _rtl_pci_init_trx_ring(struct ieee80211_hw *hw)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	int ret;
-	int i;
+	int i, rxring_idx;
 
-	ret = _rtl_pci_init_rx_ring(hw);
-	if (ret)
-		return ret;
+	/* rxring_idx 0:RX_MPDU_QUEUE
+	 * rxring_idx 1:RX_CMD_QUEUE
+	 */
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE;
+	     rxring_idx++) {
+		ret = _rtl_pci_init_rx_ring(hw, rxring_idx);
+		if (ret)
+			return ret;
+	}
 
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++) {
-		ret = _rtl_pci_init_tx_ring(hw, i,
-				 rtlpci->txringcount[i]);
+		ret = _rtl_pci_init_tx_ring(hw, i, rtlpci->txringcount[i]);
 		if (ret)
 			goto err_free_rings;
 	}
@@ -1219,7 +1258,9 @@ static int _rtl_pci_init_trx_ring(struct ieee80211_hw *hw)
 	return 0;
 
 err_free_rings:
-	_rtl_pci_free_rx_ring(rtlpci);
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE;
+	     rxring_idx++)
+		_rtl_pci_free_rx_ring(rtlpci, rxring_idx);
 
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++)
 		if (rtlpci->tx_ring[i].desc)
@@ -1231,10 +1272,12 @@ err_free_rings:
 static int _rtl_pci_deinit_trx_ring(struct ieee80211_hw *hw)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	u32 i;
+	u32 i, rxring_idx;
 
 	/*free rx rings */
-	_rtl_pci_free_rx_ring(rtlpci);
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE;
+	     rxring_idx++)
+		_rtl_pci_free_rx_ring(rtlpci, rxring_idx);
 
 	/*free tx rings */
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++)
@@ -1247,36 +1290,33 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	int i, rx_queue_idx;
+	int i, rxring_idx;
 	unsigned long flags;
 	u8 tmp_one = 1;
 
-	/*rx_queue_idx 0:RX_MPDU_QUEUE */
-	/*rx_queue_idx 1:RX_CMD_QUEUE */
-	for (rx_queue_idx = 0; rx_queue_idx < RTL_PCI_MAX_RX_QUEUE;
-	     rx_queue_idx++) {
-		/*
-		 *force the rx_ring[RX_MPDU_QUEUE/
-		 *RX_CMD_QUEUE].idx to the first one
+	/* rxring_idx 0:RX_MPDU_QUEUE */
+	/* rxring_idx 1:RX_CMD_QUEUE */
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE;
+	     rxring_idx++) {
+		/* force the rx_ring[RX_MPDU_QUEUE/
+		 * RX_CMD_QUEUE].idx to the first one
 		 */
-		if (rtlpci->rx_ring[rx_queue_idx].desc) {
+		if (rtlpci->rx_ring[rxring_idx].desc) {
 			struct rtl_rx_desc *entry = NULL;
 
 			for (i = 0; i < rtlpci->rxringcount; i++) {
-				entry = &rtlpci->rx_ring[rx_queue_idx].desc[i];
-				rtlpriv->cfg->ops->set_desc((u8 *) entry,
-							    false,
-							    HW_DESC_RXOWN,
-							    &tmp_one);
+				entry = &rtlpci->rx_ring[rxring_idx].desc[i];
+				rtlpriv->cfg->ops->set_desc((u8 *)entry, false,
+					HW_DESC_RXOWN, (u8 *)&tmp_one);
 			}
-			rtlpci->rx_ring[rx_queue_idx].idx = 0;
+			rtlpci->rx_ring[rxring_idx].idx = 0;
 		}
 	}
 
-	/*
-	 *after reset, release previous pending packet,
-	 *and force the  tx idx to the first one
+	/* after reset, release previous pending packet,
+	 * and force tx idx to the first one
 	 */
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++) {
 		if (rtlpci->tx_ring[i].desc) {
 			struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[i];
@@ -1285,26 +1325,21 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 				struct rtl_tx_desc *entry;
 				struct sk_buff *skb;
 
-				spin_lock_irqsave(&rtlpriv->locks.irq_th_lock,
-						  flags);
 				entry = &ring->desc[ring->idx];
 				skb = __skb_dequeue(&ring->queue);
 				pci_unmap_single(rtlpci->pdev,
-						 rtlpriv->cfg->ops->
-							 get_desc((u8 *)
-							 entry,
-							 true,
-							 HW_DESC_TXBUFF_ADDR),
-						 skb->len, PCI_DMA_TODEVICE);
-				ring->idx = (ring->idx + 1) % ring->entries;
-				spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock,
-						  flags);
+					rtlpriv->cfg->ops->get_desc((u8 *)
+					entry, true, HW_DESC_TXBUFF_ADDR),
+					skb->len, PCI_DMA_TODEVICE);
 				kfree_skb(skb);
+				ring->idx = (ring->idx + 1) % ring->entries;
 			}
 			ring->idx = 0;
 		}
 	}
 
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
+
 	return 0;
 }
 
@@ -1397,7 +1432,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 		idx = 0;
 
 	pdesc = &ring->desc[idx];
-	own = (u8) rtlpriv->cfg->ops->get_desc((u8 *) pdesc,
+	own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc,
 			true, HW_DESC_OWN);
 
 	if ((own == 1) && (hw_queue != BEACON_QUEUE)) {
@@ -1458,10 +1493,14 @@ static void rtl_pci_flush(struct ieee80211_hw *hw, bool drop)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u16 i = 0;
 	int queue_id;
 	struct rtl8192_tx_ring *ring;
 
+	if (mac->skip_scan)
+		return;
+
 	for (queue_id = RTL_PCI_MAX_TX_QUEUE_COUNT - 1; queue_id >= 0;) {
 		u32 queue_len;
 		ring = &pcipriv->dev.tx_ring[queue_id];
@@ -1704,6 +1743,10 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	pcipriv->ndis_adapter.devnumber = PCI_SLOT(pdev->devfn);
 	pcipriv->ndis_adapter.funcnumber = PCI_FUNC(pdev->devfn);
 
+	pcipriv->ndis_adapter.pcibridge_vendor = PCI_BRIDGE_VENDOR_UNKNOWN;
+	/* some ARM have no bridge_pdev and will crash here
+	 * so we should check if bridge_pdev is NULL
+	 */
 	if (bridge_pdev) {
 		/*find bridge info if available */
 		pcipriv->ndis_adapter.pcibridge_vendorid = bridge_pdev->vendor;
@@ -1758,6 +1801,7 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 		 pcipriv->ndis_adapter.amd_l1_patch);
 
 	rtl_pci_parse_configuration(pdev, hw);
+	list_add_tail(&rtlpriv->list, &rtlpriv->glb_var->glb_priv_list);
 
 	return true;
 }
@@ -1804,6 +1848,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, hw);
 
 	rtlpriv = hw->priv;
+	rtlpriv->hw = hw;
 	pcipriv = (void *)rtlpriv->priv;
 	pcipriv->dev.pdev = pdev;
 	init_completion(&rtlpriv->firmware_loading_complete);
@@ -1812,6 +1857,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	rtlpriv->rtlhal.interface = INTF_PCI;
 	rtlpriv->cfg = (struct rtl_hal_cfg *)(id->driver_data);
 	rtlpriv->intf_ops = &rtl_pci_ops;
+	rtlpriv->glb_var = &global_var;
 
 	/*
 	 *init dbgp flags before all
@@ -1916,7 +1962,6 @@ int rtl_pci_probe(struct pci_dev *pdev,
 
 fail3:
 	rtl_deinit_core(hw);
-	_rtl_pci_io_handler_release(hw);
 
 	if (rtlpriv->io.pci_mem_start != 0)
 		pci_iounmap(pdev, (void __iomem *)rtlpriv->io.pci_mem_start);
@@ -1965,14 +2010,15 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 
 	rtl_pci_deinit(hw);
 	rtl_deinit_core(hw);
-	_rtl_pci_io_handler_release(hw);
 	rtlpriv->cfg->ops->deinit_sw_vars(hw);
 
 	if (rtlpci->irq_alloc) {
+		synchronize_irq(rtlpci->pdev->irq);
 		free_irq(rtlpci->pdev->irq, hw);
 		rtlpci->irq_alloc = 0;
 	}
 
+	list_del(&rtlpriv->list);
 	if (rtlpriv->io.pci_mem_start != 0) {
 		pci_iounmap(pdev, (void __iomem *)rtlpriv->io.pci_mem_start);
 		pci_release_regions(pdev);
@@ -2034,6 +2080,7 @@ struct rtl_intf_ops rtl_pci_ops = {
 	.read_efuse_byte = read_efuse_byte,
 	.adapter_start = rtl_pci_start,
 	.adapter_stop = rtl_pci_stop,
+	.check_buddy_priv = rtl_pci_check_buddy_priv,
 	.adapter_tx = rtl_pci_tx,
 	.flush = rtl_pci_flush,
 	.reset_trx_ring = rtl_pci_reset_trx_ring,
diff --git a/drivers/net/wireless/rtlwifi/pci.h b/drivers/net/wireless/rtlwifi/pci.h
index 65b08f5..bd368d9 100644
--- a/drivers/net/wireless/rtlwifi/pci.h
+++ b/drivers/net/wireless/rtlwifi/pci.h
@@ -175,6 +175,7 @@ struct rtl_pci {
 	/*irq */
 	u8 irq_alloc;
 	u32 irq_mask[2];
+	u32 sys_irq_mask;
 
 	/*Bcn control register setting */
 	u32 reg_bcn_ctrl_val;
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 3cc2c08..944b5d2 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1222,6 +1222,7 @@ struct rtl_hal {
 	/* just for DualMac S3S4 */
 	u8 macphyctl_reg;
 	bool earlymode_enable;
+	u8 max_earlymode_num;
 	/* Dual mac*/
 	bool during_mac0init_radiob;
 	bool during_mac1init_radioa;
-- 
1.8.1.4
