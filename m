From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 04/25] rtlwifi: Modify files for 2013.02.07 vendor version - part 4
Date: Sun, 24 Mar 2013 22:06:36 -0500
Message-ID: <1364180817-8028-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jcheung-IBi9RG/b67k@public.gmane.org, machen-IBi9RG/b67k@public.gmane.org,
	mmarek-AlSwsSmVLrQ@public.gmane.org, zhiyuan_yang-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, page_he-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364180817-8028-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch updates files debug.{c,h}, efuse.c, pci.{c,h}, and wifi.h for
the changes in the newest vendor driver.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: jcheung-IBi9RG/b67k@public.gmane.org
Cc: machen-IBi9RG/b67k@public.gmane.org
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org
Cc: zhiyuan_yang-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
Cc: page_he-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
---
 drivers/net/wireless/rtlwifi/base.c  |   2 +
 drivers/net/wireless/rtlwifi/debug.c |   5 +-
 drivers/net/wireless/rtlwifi/debug.h |   7 +++
 drivers/net/wireless/rtlwifi/efuse.c |  42 ++++++++++---
 drivers/net/wireless/rtlwifi/pci.c   | 117 +++++++++++++++++++++++++++++------
 drivers/net/wireless/rtlwifi/pci.h   |   1 +
 drivers/net/wireless/rtlwifi/wifi.h  |   3 +
 7 files changed, 146 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index acea8e8..270b27a 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -466,6 +466,8 @@ int rtl_init_core(struct ieee80211_hw *hw)
 	mutex_init(&rtlpriv->locks.ps_mutex);
 	spin_lock_init(&rtlpriv->locks.ips_lock);
 	spin_lock_init(&rtlpriv->locks.irq_th_lock);
+	spin_lock_init(&rtlpriv->locks.irq_pci_lock);
+	spin_lock_init(&rtlpriv->locks.tx_lock);
 	spin_lock_init(&rtlpriv->locks.h2c_lock);
 	spin_lock_init(&rtlpriv->locks.rf_ps_lock);
 	spin_lock_init(&rtlpriv->locks.rf_lock);
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
index 4261e8e..4af6abd 100644
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
@@ -525,9 +568,8 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 		u8 own = (u8) rtlpriv->cfg->ops->get_desc((u8 *) entry, true,
 							  HW_DESC_OWN);
 
-		/*
-		 *beacon packet will only use the first
-		 *descriptor defautly,and the own may not
+		/*beacon packet will only use the first
+		 *descriptor by defaut, and the own may not
 		 *be cleared by the hardware
 		 */
 		if (own)
@@ -558,8 +600,9 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
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
@@ -569,6 +612,15 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
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
@@ -637,6 +689,10 @@ static void _rtl_receive_one(struct ieee80211_hw *hw, struct sk_buff *skb,
 			rtlpriv->link_info.num_rx_inperiod++;
 	}
 
+	/* static bcn for roaming */
+	rtl_beacon_statistic(hw, skb);
+	rtl_p2p_info(hw, (void *)skb->data, skb->len);
+
 	/* for sw lps */
 	rtl_swlps_beacon(hw, (void *)skb->data, skb->len);
 	rtl_recognize_peer(hw, (void *)skb->data, skb->len);
@@ -884,6 +940,16 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
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
 
@@ -1458,10 +1524,14 @@ static void rtl_pci_flush(struct ieee80211_hw *hw, bool drop)
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
@@ -1704,6 +1774,9 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	pcipriv->ndis_adapter.devnumber = PCI_SLOT(pdev->devfn);
 	pcipriv->ndis_adapter.funcnumber = PCI_FUNC(pdev->devfn);
 
+	/* some ARM have no bridge_pdev and will crash here
+	 * so we should check if bridge_pdev is NULL
+	 */
 	if (bridge_pdev) {
 		/*find bridge info if available */
 		pcipriv->ndis_adapter.pcibridge_vendorid = bridge_pdev->vendor;
@@ -1758,6 +1831,7 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 		 pcipriv->ndis_adapter.amd_l1_patch);
 
 	rtl_pci_parse_configuration(pdev, hw);
+	list_add_tail(&rtlpriv->list, &rtlpriv->glb_var->glb_priv_list);
 
 	return true;
 }
@@ -1804,6 +1878,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, hw);
 
 	rtlpriv = hw->priv;
+	rtlpriv->hw = hw;
 	pcipriv = (void *)rtlpriv->priv;
 	pcipriv->dev.pdev = pdev;
 	init_completion(&rtlpriv->firmware_loading_complete);
@@ -1812,6 +1887,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	rtlpriv->rtlhal.interface = INTF_PCI;
 	rtlpriv->cfg = (struct rtl_hal_cfg *)(id->driver_data);
 	rtlpriv->intf_ops = &rtl_pci_ops;
+	rtlpriv->glb_var = &global_var;
 
 	/*
 	 *init dbgp flags before all
@@ -1916,7 +1992,6 @@ int rtl_pci_probe(struct pci_dev *pdev,
 
 fail3:
 	rtl_deinit_core(hw);
-	_rtl_pci_io_handler_release(hw);
 
 	if (rtlpriv->io.pci_mem_start != 0)
 		pci_iounmap(pdev, (void __iomem *)rtlpriv->io.pci_mem_start);
@@ -1965,14 +2040,15 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 
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
@@ -2034,6 +2110,7 @@ struct rtl_intf_ops rtl_pci_ops = {
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
index 312a54f..9edd412 100644
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
@@ -1733,6 +1734,8 @@ struct rtl_locks {
 	/*spin lock */
 	spinlock_t ips_lock;
 	spinlock_t irq_th_lock;
+	spinlock_t irq_pci_lock;
+	spinlock_t tx_lock;
 	spinlock_t h2c_lock;
 	spinlock_t rf_ps_lock;
 	spinlock_t rf_lock;
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
