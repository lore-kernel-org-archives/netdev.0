From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/11 NEXT] rtlwifi: rtl_pci: Start modification for new drivers
Date: Mon, 22 Sep 2014 09:39:19 -0500
Message-ID: <1411396767-20611-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:44227 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147AbaIVOj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 10:39:57 -0400
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Future patches will move the drivers for RTL8192EE and RTL8821AE
from staging to the regular wireless tree. Here, the necessary features
are added to the PCI driver. Other files are touched due to changes
in the various data structs.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/core.c |  15 +-
 drivers/net/wireless/rtlwifi/core.h |  10 +-
 drivers/net/wireless/rtlwifi/pci.c  | 849 +++++++++++++++++++++++-------------
 drivers/net/wireless/rtlwifi/pci.h  |  56 ++-
 drivers/net/wireless/rtlwifi/wifi.h |   9 +-
 5 files changed, 605 insertions(+), 334 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 56e218e..98e564d 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -129,19 +129,6 @@ found_alt:
 	memcpy(rtlpriv->rtlhal.pfirmware, firmware->data, firmware->size);
 	rtlpriv->rtlhal.fwsize = firmware->size;
 	release_firmware(firmware);
-
-	err = ieee80211_register_hw(hw);
-	if (err) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Can't register mac80211 hw\n");
-		return;
-	} else {
-		rtlpriv->mac80211.mac80211_registered = 1;
-	}
-	set_bit(RTL_STATUS_INTERFACE_START, &rtlpriv->status);
-
-	/*init rfkill */
-	rtl_init_rfkill(hw);
 }
 EXPORT_SYMBOL(rtl_fw_cb);
 
@@ -1392,7 +1379,7 @@ static void rtl_op_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (rtlpriv->intf_ops->flush)
-		rtlpriv->intf_ops->flush(hw, drop);
+		rtlpriv->intf_ops->flush(hw, queues, drop);
 }
 
 const struct ieee80211_ops rtl_ops = {
diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
index 027e753..cdd4727 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -2,20 +2,16 @@
  *
  * Copyright(c) 2009-2012  Realtek Corporation.
  *
- * Tmis program is free software; you can redistribute it and/or modify it
+ * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License as
  * published by the Free Software Foundation.
  *
- * Tmis program is distributed in the hope that it will be useful, but WITHOUT
+ * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * tmis program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
- * Tme full GNU General Public License is included in this distribution in the
+ * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
  * Contact Information:
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 74a8ba4..37a78bf 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -33,6 +33,7 @@
 #include "base.h"
 #include "ps.h"
 #include "efuse.h"
+#include <linux/interrupt.h>
 #include <linux/export.h>
 #include <linux/kmemleak.h>
 #include <linux/module.h>
@@ -44,10 +45,10 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("PCI basic driver for rtlwifi");
 
 static const u16 pcibridge_vendors[PCI_BRIDGE_VENDOR_MAX] = {
-	PCI_VENDOR_ID_INTEL,
-	PCI_VENDOR_ID_ATI,
-	PCI_VENDOR_ID_AMD,
-	PCI_VENDOR_ID_SI
+	INTEL_VENDOR_ID,
+	ATI_VENDOR_ID,
+	AMD_VENDOR_ID,
+	SIS_VENDOR_ID
 };
 
 static const u8 ac_to_hwq[] = {
@@ -566,27 +567,25 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[prio];
 
 	while (skb_queue_len(&ring->queue)) {
-		struct rtl_tx_desc *entry = &ring->desc[ring->idx];
 		struct sk_buff *skb;
 		struct ieee80211_tx_info *info;
 		__le16 fc;
 		u8 tid;
+		u8 *entry;
 
-		u8 own = (u8) rtlpriv->cfg->ops->get_desc((u8 *) entry, true,
-							  HW_DESC_OWN);
+		if (rtlpriv->use_new_trx_flow)
+			entry = (u8 *)(&ring->buffer_desc[ring->idx]);
+		else
+			entry = (u8 *)(&ring->desc[ring->idx]);
 
-		/*beacon packet will only use the first
-		 *descriptor by defaut, and the own may not
-		 *be cleared by the hardware
-		 */
-		if (own)
+		if (!rtlpriv->cfg->ops->is_tx_desc_closed(hw, prio, ring->idx))
 			return;
 		ring->idx = (ring->idx + 1) % ring->entries;
 
 		skb = __skb_dequeue(&ring->queue);
 		pci_unmap_single(rtlpci->pdev,
 				 rtlpriv->cfg->ops->
-					     get_desc((u8 *) entry, true,
+					     get_desc((u8 *)entry, true,
 						      HW_DESC_TXBUFF_ADDR),
 				 skb->len, PCI_DMA_TODEVICE);
 
@@ -598,7 +597,7 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 			 "new ring->idx:%d, free: skb_queue_len:%d, free: seq:%x\n",
 			 ring->idx,
 			 skb_queue_len(&ring->queue),
-			 *(u16 *) (skb->data + 22));
+			 *(u16 *)(skb->data + 22));
 
 		if (prio == TXCMD_QUEUE) {
 			dev_kfree_skb(skb);
@@ -666,175 +665,276 @@ tx_status_ok:
 	}
 }
 
-static void _rtl_receive_one(struct ieee80211_hw *hw, struct sk_buff *skb,
-			     struct ieee80211_rx_status rx_status)
+static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
+				    u8 *entry, int rxring_idx, int desc_idx)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
-	__le16 fc = rtl_get_fc(skb);
-	bool unicast = false;
-	struct sk_buff *uskb = NULL;
-	u8 *pdata;
-
-
-	memcpy(IEEE80211_SKB_RXCB(skb), &rx_status, sizeof(rx_status));
-
-	if (is_broadcast_ether_addr(hdr->addr1)) {
-		;/*TODO*/
-	} else if (is_multicast_ether_addr(hdr->addr1)) {
-		;/*TODO*/
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 bufferaddress;
+	u8 tmp_one = 1;
+	struct sk_buff *skb;
+
+	skb = dev_alloc_skb(rtlpci->rxbuffersize);
+	if (!skb)
+		return 0;
+	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
+
+	/* just set skb->cb to mapping addr for pci_unmap_single use */
+	*((dma_addr_t *)skb->cb) =
+		pci_map_single(rtlpci->pdev, skb_tail_pointer(skb),
+			       rtlpci->rxbuffersize, PCI_DMA_FROMDEVICE);
+	bufferaddress = *((dma_addr_t *)skb->cb);
+	if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress))
+		return 0;
+	if (rtlpriv->use_new_trx_flow) {
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
+					    HW_DESC_RX_PREPARE,
+					    (u8 *)&bufferaddress);
 	} else {
-		unicast = true;
-		rtlpriv->stats.rxbytesunicast += skb->len;
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
+					    HW_DESC_RXBUFF_ADDR,
+					    (u8 *)&bufferaddress);
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
+					    HW_DESC_RXPKT_LEN,
+					    (u8 *)&rtlpci->rxbuffersize);
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
+					    HW_DESC_RXOWN,
+					    (u8 *)&tmp_one);
 	}
+	return 1;
+}
 
-	if (ieee80211_is_data(fc)) {
-		rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
-
-		if (unicast)
-			rtlpriv->link_info.num_rx_inperiod++;
+/* inorder to receive 8K AMSDU we have set skb to
+ * 9100bytes in init rx ring, but if this packet is
+ * not a AMSDU, this large packet will be sent to
+ * TCP/IP directly, this cause big packet ping fail
+ * like: "ping -s 65507", so here we will realloc skb
+ * based on the true size of packet, Mac80211
+ * Probably will do it better, but does not yet.
+ *
+ * Some platform will fail when alloc skb sometimes.
+ * in this condition, we will send the old skb to
+ * mac80211 directly, this will not cause any other
+ * issues, but only this packet will be lost by TCP/IP
+ */
+static void _rtl_pci_rx_to_mac80211(struct ieee80211_hw *hw,
+				    struct sk_buff *skb,
+				    struct ieee80211_rx_status rx_status)
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
+			ieee80211_rx_irqsafe(hw, uskb);
+		} else {
+			ieee80211_rx_irqsafe(hw, skb);
+		}
 	}
+}
 
-	/* static bcn for roaming */
-	rtl_beacon_statistic(hw, skb);
-	rtl_p2p_info(hw, (void *)skb->data, skb->len);
-
-	/* for sw lps */
-	rtl_swlps_beacon(hw, (void *)skb->data, skb->len);
-	rtl_recognize_peer(hw, (void *)skb->data, skb->len);
-	if ((rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP) &&
-	    (rtlpriv->rtlhal.current_bandtype == BAND_ON_2_4G) &&
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
+/*hsisr interrupt handler*/
+static void _rtl_pci_hs_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
-	ieee80211_rx_irqsafe(hw, uskb);
+	rtl_write_byte(rtlpriv, rtlpriv->cfg->maps[MAC_HSISR],
+		       rtl_read_byte(rtlpriv, rtlpriv->cfg->maps[MAC_HSISR]) |
+		       rtlpci->sys_irq_mask);
 }
 
 static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	int rx_queue_idx = RTL_PCI_RX_MPDU_QUEUE;
-
+	int rxring_idx = RTL_PCI_RX_MPDU_QUEUE;
 	struct ieee80211_rx_status rx_status = { 0 };
 	unsigned int count = rtlpci->rxringcount;
 	u8 own;
 	u8 tmp_one;
-	u32 bufferaddress;
-
+	bool unicast = false;
+	u8 hw_queue = 0;
+	unsigned int rx_remained_cnt;
 	struct rtl_stats stats = {
 		.signal = 0,
 		.rate = 0,
 	};
-	int index = rtlpci->rx_ring[rx_queue_idx].idx;
 
-	if (rtlpci->driver_is_goingto_unload)
-		return;
 	/*RX NORMAL PKT */
 	while (count--) {
-		/*rx descriptor */
-		struct rtl_rx_desc *pdesc = &rtlpci->rx_ring[rx_queue_idx].desc[
-				index];
+		struct ieee80211_hdr *hdr;
+		__le16 fc;
+		u16 len;
+		/*rx buffer descriptor */
+		struct rtl_rx_buffer_desc *buffer_desc = NULL;
+		/*if use new trx flow, it means wifi info */
+		struct rtl_rx_desc *pdesc = NULL;
 		/*rx pkt */
-		struct sk_buff *skb = rtlpci->rx_ring[rx_queue_idx].rx_buf[
-				index];
-		struct sk_buff *new_skb = NULL;
-
-		own = (u8) rtlpriv->cfg->ops->get_desc((u8 *) pdesc,
-						       false, HW_DESC_OWN);
-
-		/*wait data to be filled by hardware */
-		if (own)
-			break;
+		struct sk_buff *skb = rtlpci->rx_ring[rxring_idx].rx_buf[
+				      rtlpci->rx_ring[rxring_idx].idx];
+
+		if (rtlpriv->use_new_trx_flow) {
+			rx_remained_cnt =
+				rtlpriv->cfg->ops->rx_desc_buff_remained_cnt(hw,
+								      hw_queue);
+			if (rx_remained_cnt < 1)
+				return;
+
+		} else {	/* rx descriptor */
+			pdesc = &rtlpci->rx_ring[rxring_idx].desc[
+				rtlpci->rx_ring[rxring_idx].idx];
+
+			own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc,
+							      false,
+							      HW_DESC_OWN);
+			if (own) /* wait data to be filled by hardware */
+				return;
+		}
 
+		/* Reaching this point means: data is filled already
+		 * AAAAAAttention !!!
+		 * We can NOT access 'skb' before 'pci_unmap_single'
+		 */
+		pci_unmap_single(rtlpci->pdev, *((dma_addr_t *)skb->cb),
+				 rtlpci->rxbuffersize, PCI_DMA_FROMDEVICE);
+
+		if (rtlpriv->use_new_trx_flow) {
+			buffer_desc =
+			  &rtlpci->rx_ring[rxring_idx].buffer_desc
+				[rtlpci->rx_ring[rxring_idx].idx];
+			/*means rx wifi info*/
+			pdesc = (struct rtl_rx_desc *)skb->data;
+		}
+		memset(&rx_status , 0 , sizeof(rx_status));
 		rtlpriv->cfg->ops->query_rx_desc(hw, &stats,
-						 &rx_status,
-						 (u8 *) pdesc, skb);
+						 &rx_status, (u8 *)pdesc, skb);
 
-		if (stats.crc || stats.hwerror)
-			goto done;
+		if (rtlpriv->use_new_trx_flow)
+			rtlpriv->cfg->ops->rx_check_dma_ok(hw,
+							   (u8 *)buffer_desc,
+							   hw_queue);
 
-		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
-		if (unlikely(!new_skb)) {
-			RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV), DBG_DMESG,
-				 "can't alloc skb for rx\n");
-			goto done;
-		}
-		kmemleak_not_leak(new_skb);
+		len = rtlpriv->cfg->ops->get_desc((u8 *)pdesc, false,
+						  HW_DESC_RXPKT_LEN);
 
-		pci_unmap_single(rtlpci->pdev,
-				 *((dma_addr_t *) skb->cb),
-				 rtlpci->rxbuffersize,
-				 PCI_DMA_FROMDEVICE);
+		if (skb->end - skb->tail > len) {
+			skb_put(skb, len);
+			if (rtlpriv->use_new_trx_flow)
+				skb_reserve(skb, stats.rx_drvinfo_size +
+					    stats.rx_bufshift + 24);
+			else
+				skb_reserve(skb, stats.rx_drvinfo_size +
+					    stats.rx_bufshift);
 
-		skb_put(skb, rtlpriv->cfg->ops->get_desc((u8 *) pdesc, false,
-			HW_DESC_RXPKT_LEN));
-		skb_reserve(skb, stats.rx_drvinfo_size + stats.rx_bufshift);
+		} else {
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+				 "skb->end - skb->tail = %d, len is %d\n",
+				 skb->end - skb->tail, len);
+			break;
+		}
+		/* handle command packet here */
+		if (rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
+				dev_kfree_skb_any(skb);
+				goto end;
+		}
 
 		/*
 		 * NOTICE This can not be use for mac80211,
 		 * this is done in mac80211 code,
-		 * if you done here sec DHCP will fail
+		 * if done here sec DHCP will fail
 		 * skb_trim(skb, skb->len - 4);
 		 */
 
-		_rtl_receive_one(hw, skb, rx_status);
+		hdr = rtl_get_hdr(skb);
+		fc = rtl_get_fc(skb);
+
+		if (!stats.crc && !stats.hwerror) {
+			memcpy(IEEE80211_SKB_RXCB(skb), &rx_status,
+			       sizeof(rx_status));
+
+			if (is_broadcast_ether_addr(hdr->addr1)) {
+				;/*TODO*/
+			} else if (is_multicast_ether_addr(hdr->addr1)) {
+				;/*TODO*/
+			} else {
+				unicast = true;
+				rtlpriv->stats.rxbytesunicast += skb->len;
+			}
+			rtl_is_special_data(hw, skb, false);
 
+			if (ieee80211_is_data(fc)) {
+				rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
+				if (unicast)
+					rtlpriv->link_info.num_rx_inperiod++;
+			}
+			/* static bcn for roaming */
+			rtl_beacon_statistic(hw, skb);
+			rtl_p2p_info(hw, (void *)skb->data, skb->len);
+			/* for sw lps */
+			rtl_swlps_beacon(hw, (void *)skb->data, skb->len);
+			rtl_recognize_peer(hw, (void *)skb->data, skb->len);
+			if ((rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP) &&
+			    (rtlpriv->rtlhal.current_bandtype ==
+			     BAND_ON_2_4G) &&
+			    (ieee80211_is_beacon(fc) ||
+			     ieee80211_is_probe_resp(fc))) {
+				dev_kfree_skb_any(skb);
+			} else {
+				_rtl_pci_rx_to_mac80211(hw, skb, rx_status);
+			}
+		} else {
+			dev_kfree_skb_any(skb);
+		}
+		if (rtlpriv->use_new_trx_flow) {
+			rtlpci->rx_ring[hw_queue].next_rx_rp += 1;
+			rtlpci->rx_ring[hw_queue].next_rx_rp %=
+					RTL_PCI_MAX_RX_COUNT;
+
+			rx_remained_cnt--;
+			rtl_write_word(rtlpriv, 0x3B4,
+				       rtlpci->rx_ring[hw_queue].next_rx_rp);
+		}
 		if (((rtlpriv->link_info.num_rx_inperiod +
 		      rtlpriv->link_info.num_tx_inperiod) > 8) ||
 		      (rtlpriv->link_info.num_rx_inperiod > 2)) {
 			rtlpriv->enter_ps = false;
 			schedule_work(&rtlpriv->works.lps_change_work);
 		}
+end:
+		if (rtlpriv->use_new_trx_flow) {
+			_rtl_pci_init_one_rxdesc(hw, (u8 *)buffer_desc,
+						 rxring_idx,
+					       rtlpci->rx_ring[rxring_idx].idx);
+		} else {
+			_rtl_pci_init_one_rxdesc(hw, (u8 *)pdesc, rxring_idx,
+						 rtlpci->rx_ring[rxring_idx].idx);
 
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
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, false,
-					    HW_DESC_RXBUFF_ADDR,
-					    (u8 *)&bufferaddress);
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, false,
-					    HW_DESC_RXPKT_LEN,
-					    (u8 *)&rtlpci->rxbuffersize);
-
-		if (index == rtlpci->rxringcount - 1)
-			rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, false,
-						    HW_DESC_RXERO,
-						    &tmp_one);
-
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, false, HW_DESC_RXOWN,
-					    &tmp_one);
-
-		index = (index + 1) % rtlpci->rxringcount;
+			if (rtlpci->rx_ring[rxring_idx].idx ==
+			    rtlpci->rxringcount - 1)
+				rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc,
+							    false,
+							    HW_DESC_RXERO,
+							    (u8 *)&tmp_one);
+		}
+		rtlpci->rx_ring[rxring_idx].idx =
+				(rtlpci->rx_ring[rxring_idx].idx + 1) %
+				rtlpci->rxringcount;
 	}
-
-	rtlpci->rx_ring[rx_queue_idx].idx = index;
 }
 
 static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 {
 	struct ieee80211_hw *hw = dev_id;
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	unsigned long flags;
@@ -842,7 +942,11 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 	u32 intb = 0;
 	irqreturn_t ret = IRQ_HANDLED;
 
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
+	if (rtlpci->irq_enabled == 0)
+		return ret;
+
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock , flags);
+	rtlpriv->cfg->ops->disable_interrupt(hw);
 
 	/*read ISR: 4/8bytes */
 	rtlpriv->cfg->ops->interrupt_recognized(hw, &inta, &intb);
@@ -874,8 +978,8 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		tasklet_schedule(&rtlpriv->works.irq_prepare_bcn_tasklet);
 	}
 
-	/*<3> Tx related */
-	if (unlikely(inta & rtlpriv->cfg->maps[RTL_IMR_TXFOVW]))
+	/*<2> Tx related */
+	if (unlikely(intb & rtlpriv->cfg->maps[RTL_IMR_TXFOVW]))
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, "IMR_TXFOVW!\n");
 
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_MGNTDOK]) {
@@ -932,7 +1036,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		}
 	}
 
-	/*<2> Rx related */
+	/*<3> Rx related */
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_ROK]) {
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE, "Rx ok interrupt!\n");
 		_rtl_pci_rx_interrupt(hw);
@@ -944,12 +1048,12 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		_rtl_pci_rx_interrupt(hw);
 	}
 
-	if (unlikely(inta & rtlpriv->cfg->maps[RTL_IMR_RXFOVW])) {
+	if (unlikely(intb & rtlpriv->cfg->maps[RTL_IMR_RXFOVW])) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, "rx overflow !\n");
 		_rtl_pci_rx_interrupt(hw);
 	}
 
-	/*fw related*/
+	/*<4> fw related*/
 	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723AE) {
 		if (inta & rtlpriv->cfg->maps[RTL_IMR_C2HCMD]) {
 			RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
@@ -959,10 +1063,26 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		}
 	}
 
+	/*<5> hsisr related*/
+	/* Only 8188EE & 8723BE Supported.
+	 * If Other ICs Come in, System will corrupt,
+	 * because maps[RTL_IMR_HSISR_IND] & maps[MAC_HSISR]
+	 * are not initialized
+	 */
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8188EE ||
+	    rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (unlikely(inta & rtlpriv->cfg->maps[RTL_IMR_HSISR_IND])) {
+			RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
+				 "hsisr interrupt!\n");
+			_rtl_pci_hs_interrupt(hw);
+		}
+	}
+
 	if (rtlpriv->rtlhal.earlymode_enable)
 		tasklet_schedule(&rtlpriv->works.irq_tasklet);
 
 done:
+	rtlpriv->cfg->ops->enable_interrupt(hw);
 	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 	return ret;
 }
@@ -990,13 +1110,8 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
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
@@ -1005,7 +1120,10 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 	hdr = rtl_get_hdr(pskb);
 	info = IEEE80211_SKB_CB(pskb);
 	pdesc = &ring->desc[0];
-	rtlpriv->cfg->ops->fill_tx_desc(hw, hdr, (u8 *) pdesc,
+	if (rtlpriv->use_new_trx_flow)
+		pbuffer_desc = &ring->buffer_desc[0];
+
+	rtlpriv->cfg->ops->fill_tx_desc(hw, hdr, (u8 *)pdesc,
 					(u8 *)pbuffer_desc, info, NULL, pskb,
 					BEACON_QUEUE, &tcb_desc);
 
@@ -1020,10 +1138,18 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 static void _rtl_pci_init_trx_var(struct ieee80211_hw *hw)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	u8 i;
+	u16 desc_num;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE)
+		desc_num = TX_DESC_NUM_92E;
+	else
+		desc_num = RT_TXDESC_NUM;
 
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++)
-		rtlpci->txringcount[i] = RT_TXDESC_NUM;
+		rtlpci->txringcount[i] = desc_num;
 
 	/*
 	 *we just alloc 2 desc for beacon queue,
@@ -1031,12 +1157,12 @@ static void _rtl_pci_init_trx_var(struct ieee80211_hw *hw)
 	 */
 	rtlpci->txringcount[BEACON_QUEUE] = 2;
 
-	/*
-	 *BE queue need more descriptor for performance
+	/*BE queue need more descriptor for performance
 	 *consideration or, No more tx desc will happen,
 	 *and may cause mac80211 mem leakage.
 	 */
-	rtlpci->txringcount[BE_QUEUE] = RT_TXDESC_NUM_BE_QUEUE;
+	if (!rtl_priv(hw)->use_new_trx_flow)
+		rtlpci->txringcount[BE_QUEUE] = RT_TXDESC_NUM_BE_QUEUE;
 
 	rtlpci->rxbuffersize = 9100;	/*2048/1024; */
 	rtlpci->rxringcount = RTL_PCI_MAX_RX_COUNT;	/*64; */
@@ -1087,113 +1213,124 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_tx_desc *ring;
-	dma_addr_t dma;
+	struct rtl_tx_buffer_desc *buffer_desc;
+	struct rtl_tx_desc *desc;
+	dma_addr_t buffer_desc_dma, desc_dma;
 	u32 nextdescaddress;
 	int i;
 
-	ring = pci_zalloc_consistent(rtlpci->pdev, sizeof(*ring) * entries,
-				     &dma);
-	if (!ring || (unsigned long)ring & 0xFF) {
+	/* alloc tx buffer desc for new trx flow*/
+	if (rtlpriv->use_new_trx_flow) {
+		buffer_desc =
+		   pci_zalloc_consistent(rtlpci->pdev,
+					 sizeof(*buffer_desc) * entries,
+					 &buffer_desc_dma);
+
+		if (!buffer_desc || (unsigned long)buffer_desc & 0xFF) {
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Cannot allocate TX ring (prio = %d)\n",
+				 prio);
+			return -ENOMEM;
+		}
+
+		rtlpci->tx_ring[prio].buffer_desc = buffer_desc;
+		rtlpci->tx_ring[prio].buffer_desc_dma = buffer_desc_dma;
+
+		rtlpci->tx_ring[prio].cur_tx_rp = 0;
+		rtlpci->tx_ring[prio].cur_tx_wp = 0;
+		rtlpci->tx_ring[prio].avl_desc = entries;
+	}
+
+	/* alloc dma for this ring */
+	desc = pci_zalloc_consistent(rtlpci->pdev,
+				     sizeof(*desc) * entries, &desc_dma);
+
+	if (!desc || (unsigned long)desc & 0xFF) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Cannot allocate TX ring (prio = %d)\n", prio);
 		return -ENOMEM;
 	}
 
-	rtlpci->tx_ring[prio].desc = ring;
-	rtlpci->tx_ring[prio].dma = dma;
+	rtlpci->tx_ring[prio].desc = desc;
+	rtlpci->tx_ring[prio].dma = desc_dma;
+
 	rtlpci->tx_ring[prio].idx = 0;
 	rtlpci->tx_ring[prio].entries = entries;
 	skb_queue_head_init(&rtlpci->tx_ring[prio].queue);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "queue:%d, ring_addr:%p\n",
-		 prio, ring);
-
-	for (i = 0; i < entries; i++) {
-		nextdescaddress = (u32) dma +
-					      ((i + 1) % entries) *
-					      sizeof(*ring);
-
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)&(ring[i]),
-					    true, HW_DESC_TX_NEXTDESC_ADDR,
-					    (u8 *)&nextdescaddress);
+		 prio, desc);
+
+	/* init every desc in this ring */
+	if (!rtlpriv->use_new_trx_flow) {
+		for (i = 0; i < entries; i++) {
+			nextdescaddress = (u32)desc_dma +
+					  ((i +	1) % entries) *
+					  sizeof(*desc);
+
+			rtlpriv->cfg->ops->set_desc(hw, (u8 *)&desc[i],
+						    true,
+						    HW_DESC_TX_NEXTDESC_ADDR,
+						    (u8 *)&nextdescaddress);
+		}
 	}
-
 	return 0;
 }
 
-static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw)
+static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw, int rxring_idx)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_rx_desc *entry = NULL;
-	int i, rx_queue_idx;
-	u8 tmp_one = 1;
+	int i;
 
-	/*
-	 *rx_queue_idx 0:RX_MPDU_QUEUE
-	 *rx_queue_idx 1:RX_CMD_QUEUE
-	 */
-	for (rx_queue_idx = 0; rx_queue_idx < RTL_PCI_MAX_RX_QUEUE;
-	     rx_queue_idx++) {
-		rtlpci->rx_ring[rx_queue_idx].desc =
-			pci_zalloc_consistent(rtlpci->pdev,
-					      sizeof(*rtlpci->rx_ring[rx_queue_idx].desc) * rtlpci->rxringcount,
-					      &rtlpci->rx_ring[rx_queue_idx].dma);
-
-		if (!rtlpci->rx_ring[rx_queue_idx].desc ||
-		    (unsigned long)rtlpci->rx_ring[rx_queue_idx].desc & 0xFF) {
+	if (rtlpriv->use_new_trx_flow) {
+		struct rtl_rx_buffer_desc *entry = NULL;
+		/* alloc dma for this ring */
+		rtlpci->rx_ring[rxring_idx].buffer_desc =
+		    pci_zalloc_consistent(rtlpci->pdev,
+					  sizeof(*rtlpci->rx_ring[rxring_idx].
+						 buffer_desc) *
+						 rtlpci->rxringcount,
+					  &rtlpci->rx_ring[rxring_idx].dma);
+		if (!rtlpci->rx_ring[rxring_idx].buffer_desc ||
+		    (ulong)rtlpci->rx_ring[rxring_idx].buffer_desc & 0xFF) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 				 "Cannot allocate RX ring\n");
 			return -ENOMEM;
 		}
 
-		rtlpci->rx_ring[rx_queue_idx].idx = 0;
+		/* init every desc in this ring */
+		rtlpci->rx_ring[rxring_idx].idx = 0;
+		for (i = 0; i < rtlpci->rxringcount; i++) {
+			entry = &rtlpci->rx_ring[rxring_idx].buffer_desc[i];
+			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)entry,
+						      rxring_idx, i))
+				return -ENOMEM;
+		}
+	} else {
+		struct rtl_rx_desc *entry = NULL;
+		u8 tmp_one = 1;
+		/* alloc dma for this ring */
+		rtlpci->rx_ring[rxring_idx].desc =
+		    pci_zalloc_consistent(rtlpci->pdev,
+					  sizeof(*rtlpci->rx_ring[rxring_idx].
+					  desc) * rtlpci->rxringcount,
+					  &rtlpci->rx_ring[rxring_idx].dma);
+		if (!rtlpci->rx_ring[rxring_idx].desc ||
+		    (unsigned long)rtlpci->rx_ring[rxring_idx].desc & 0xFF) {
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Cannot allocate RX ring\n");
+			return -ENOMEM;
+		}
 
-		/* If amsdu_8k is disabled, set buffersize to 4096. This
-		 * change will reduce memory fragmentation.
-		 */
-		if (rtlpci->rxbuffersize > 4096 &&
-		    rtlpriv->rtlhal.disable_amsdu_8k)
-			rtlpci->rxbuffersize = 4096;
+		/* init every desc in this ring */
+		rtlpci->rx_ring[rxring_idx].idx = 0;
 
 		for (i = 0; i < rtlpci->rxringcount; i++) {
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
-
-			bufferaddress = (*((dma_addr_t *)skb->cb));
-			if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress)) {
-				dev_kfree_skb_any(skb);
-				return 1;
-			}
-			rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-						    HW_DESC_RXBUFF_ADDR,
-						    (u8 *)&bufferaddress);
-			rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-						    HW_DESC_RXPKT_LEN,
-						    (u8 *)&rtlpci->
-						    rxbuffersize);
-			rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-						    HW_DESC_RXOWN,
-						    &tmp_one);
+			entry = &rtlpci->rx_ring[rxring_idx].desc[i];
+			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)entry,
+						      rxring_idx, i))
+				return -ENOMEM;
 		}
 
 		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
@@ -1209,56 +1346,70 @@ static void _rtl_pci_free_tx_ring(struct ieee80211_hw *hw,
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[prio];
 
+	/* free every desc in this ring */
 	while (skb_queue_len(&ring->queue)) {
-		struct rtl_tx_desc *entry = &ring->desc[ring->idx];
+		u8 *entry;
 		struct sk_buff *skb = __skb_dequeue(&ring->queue);
 
+		if (rtlpriv->use_new_trx_flow)
+			entry = (u8 *)(&ring->buffer_desc[ring->idx]);
+		else
+			entry = (u8 *)(&ring->desc[ring->idx]);
+
 		pci_unmap_single(rtlpci->pdev,
 				 rtlpriv->cfg->
-					     ops->get_desc((u8 *) entry, true,
+					     ops->get_desc((u8 *)entry, true,
 						   HW_DESC_TXBUFF_ADDR),
 				 skb->len, PCI_DMA_TODEVICE);
 		kfree_skb(skb);
 		ring->idx = (ring->idx + 1) % ring->entries;
 	}
 
-	if (ring->desc) {
+	/* free dma of this ring */
+	pci_free_consistent(rtlpci->pdev,
+			    sizeof(*ring->desc) * ring->entries,
+			    ring->desc, ring->dma);
+	ring->desc = NULL;
+	if (rtlpriv->use_new_trx_flow) {
 		pci_free_consistent(rtlpci->pdev,
 				    sizeof(*ring->desc) * ring->entries,
-				    ring->desc, ring->dma);
+				    ring->buffer_desc, ring->buffer_desc_dma);
 		ring->desc = NULL;
 	}
 }
 
-static void _rtl_pci_free_rx_ring(struct rtl_pci *rtlpci)
+static void _rtl_pci_free_rx_ring(struct ieee80211_hw *hw, int rxring_idx)
 {
-	int i, rx_queue_idx;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	int i;
 
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
+	/* free every desc in this ring */
+	for (i = 0; i < rtlpci->rxringcount; i++) {
+		struct sk_buff *skb = rtlpci->rx_ring[rxring_idx].rx_buf[i];
 
-		if (rtlpci->rx_ring[rx_queue_idx].desc) {
-			pci_free_consistent(rtlpci->pdev,
-				    sizeof(*rtlpci->rx_ring[rx_queue_idx].
-					   desc) * rtlpci->rxringcount,
-				    rtlpci->rx_ring[rx_queue_idx].desc,
-				    rtlpci->rx_ring[rx_queue_idx].dma);
-			rtlpci->rx_ring[rx_queue_idx].desc = NULL;
-		}
+		if (!skb)
+			continue;
+		pci_unmap_single(rtlpci->pdev, *((dma_addr_t *)skb->cb),
+				 rtlpci->rxbuffersize, PCI_DMA_FROMDEVICE);
+		kfree_skb(skb);
+	}
+
+	/* free dma of this ring */
+	if (rtlpriv->use_new_trx_flow) {
+		pci_free_consistent(rtlpci->pdev,
+				    sizeof(*rtlpci->rx_ring[rxring_idx].
+				    buffer_desc) * rtlpci->rxringcount,
+				    rtlpci->rx_ring[rxring_idx].buffer_desc,
+				    rtlpci->rx_ring[rxring_idx].dma);
+		rtlpci->rx_ring[rxring_idx].buffer_desc = NULL;
+	} else {
+		pci_free_consistent(rtlpci->pdev,
+				    sizeof(*rtlpci->rx_ring[rxring_idx].desc) *
+				    rtlpci->rxringcount,
+				    rtlpci->rx_ring[rxring_idx].desc,
+				    rtlpci->rx_ring[rxring_idx].dma);
+		rtlpci->rx_ring[rxring_idx].desc = NULL;
 	}
 }
 
@@ -1266,11 +1417,16 @@ static int _rtl_pci_init_trx_ring(struct ieee80211_hw *hw)
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
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE; rxring_idx++) {
+		ret = _rtl_pci_init_rx_ring(hw, rxring_idx);
+		if (ret)
+			return ret;
+	}
 
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++) {
 		ret = _rtl_pci_init_tx_ring(hw, i,
@@ -1282,10 +1438,12 @@ static int _rtl_pci_init_trx_ring(struct ieee80211_hw *hw)
 	return 0;
 
 err_free_rings:
-	_rtl_pci_free_rx_ring(rtlpci);
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE; rxring_idx++)
+		_rtl_pci_free_rx_ring(hw, rxring_idx);
 
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++)
-		if (rtlpci->tx_ring[i].desc)
+		if (rtlpci->tx_ring[i].desc ||
+		    rtlpci->tx_ring[i].buffer_desc)
 			_rtl_pci_free_tx_ring(hw, i);
 
 	return 1;
@@ -1293,11 +1451,11 @@ err_free_rings:
 
 static int _rtl_pci_deinit_trx_ring(struct ieee80211_hw *hw)
 {
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	u32 i;
+	u32 i, rxring_idx;
 
 	/*free rx rings */
-	_rtl_pci_free_rx_ring(rtlpci);
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE; rxring_idx++)
+		_rtl_pci_free_rx_ring(hw, rxring_idx);
 
 	/*free tx rings */
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++)
@@ -1310,48 +1468,76 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	int i, rx_queue_idx;
+	int i, rxring_idx;
 	unsigned long flags;
 	u8 tmp_one = 1;
-
-	/*rx_queue_idx 0:RX_MPDU_QUEUE */
-	/*rx_queue_idx 1:RX_CMD_QUEUE */
-	for (rx_queue_idx = 0; rx_queue_idx < RTL_PCI_MAX_RX_QUEUE;
-	     rx_queue_idx++) {
-		/*
-		 *force the rx_ring[RX_MPDU_QUEUE/
-		 *RX_CMD_QUEUE].idx to the first one
-		 */
-		if (rtlpci->rx_ring[rx_queue_idx].desc) {
+	u32 bufferaddress;
+	/* rxring_idx 0:RX_MPDU_QUEUE */
+	/* rxring_idx 1:RX_CMD_QUEUE */
+	for (rxring_idx = 0; rxring_idx < RTL_PCI_MAX_RX_QUEUE; rxring_idx++) {
+		/* force the rx_ring[RX_MPDU_QUEUE/
+		 * RX_CMD_QUEUE].idx to the first one
+		 *new trx flow, do nothing
+		*/
+		if (!rtlpriv->use_new_trx_flow &&
+		    rtlpci->rx_ring[rxring_idx].desc) {
 			struct rtl_rx_desc *entry = NULL;
 
+			rtlpci->rx_ring[rxring_idx].idx = 0;
 			for (i = 0; i < rtlpci->rxringcount; i++) {
-				entry = &rtlpci->rx_ring[rx_queue_idx].desc[i];
-				rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry,
-							    false,
-							    HW_DESC_RXOWN,
-							    &tmp_one);
+				entry = &rtlpci->rx_ring[rxring_idx].desc[i];
+				bufferaddress =
+				  rtlpriv->cfg->ops->get_desc((u8 *)entry,
+				  false , HW_DESC_RXBUFF_ADDR);
+				memset((u8 *)entry , 0 ,
+				       sizeof(*rtlpci->rx_ring
+				       [rxring_idx].desc));/*clear one entry*/
+				if (rtlpriv->use_new_trx_flow) {
+					rtlpriv->cfg->ops->set_desc(hw,
+					    (u8 *)entry, false,
+					    HW_DESC_RX_PREPARE,
+					    (u8 *)&bufferaddress);
+				} else {
+					rtlpriv->cfg->ops->set_desc(hw,
+					    (u8 *)entry, false,
+					    HW_DESC_RXBUFF_ADDR,
+					    (u8 *)&bufferaddress);
+					rtlpriv->cfg->ops->set_desc(hw,
+					    (u8 *)entry, false,
+					    HW_DESC_RXPKT_LEN,
+					    (u8 *)&rtlpci->rxbuffersize);
+					rtlpriv->cfg->ops->set_desc(hw,
+					    (u8 *)entry, false,
+					    HW_DESC_RXOWN,
+					    (u8 *)&tmp_one);
+				}
 			}
-			rtlpci->rx_ring[rx_queue_idx].idx = 0;
+			rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
+					    HW_DESC_RXERO, (u8 *)&tmp_one);
 		}
+		rtlpci->rx_ring[rxring_idx].idx = 0;
 	}
 
 	/*
 	 *after reset, release previous pending packet,
 	 *and force the  tx idx to the first one
 	 */
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	for (i = 0; i < RTL_PCI_MAX_TX_QUEUE_COUNT; i++) {
-		if (rtlpci->tx_ring[i].desc) {
+		if (rtlpci->tx_ring[i].desc ||
+		    rtlpci->tx_ring[i].buffer_desc) {
 			struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[i];
 
 			while (skb_queue_len(&ring->queue)) {
-				struct rtl_tx_desc *entry;
-				struct sk_buff *skb;
+				u8 *entry;
+				struct sk_buff *skb =
+					__skb_dequeue(&ring->queue);
+				if (rtlpriv->use_new_trx_flow)
+					entry = (u8 *)(&ring->buffer_desc
+								[ring->idx]);
+				else
+					entry = (u8 *)(&ring->desc[ring->idx]);
 
-				spin_lock_irqsave(&rtlpriv->locks.irq_th_lock,
-						  flags);
-				entry = &ring->desc[ring->idx];
-				skb = __skb_dequeue(&ring->queue);
 				pci_unmap_single(rtlpci->pdev,
 						 rtlpriv->cfg->ops->
 							 get_desc((u8 *)
@@ -1360,13 +1546,13 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 							 HW_DESC_TXBUFF_ADDR),
 						 skb->len, PCI_DMA_TODEVICE);
 				ring->idx = (ring->idx + 1) % ring->entries;
-				spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock,
-						  flags);
 				kfree_skb(skb);
+				ring->idx = (ring->idx + 1) % ring->entries;
 			}
 			ring->idx = 0;
 		}
 	}
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 
 	return 0;
 }
@@ -1421,7 +1607,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 	struct rtl8192_tx_ring *ring;
 	struct rtl_tx_desc *pdesc;
 	struct rtl_tx_buffer_desc *ptx_bd_desc = NULL;
-	u8 idx;
+	u16 idx;
 	u8 hw_queue = _rtl_mac_to_hwqueue(hw, skb);
 	unsigned long flags;
 	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
@@ -1454,11 +1640,15 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 
 	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	ring = &rtlpci->tx_ring[hw_queue];
-	if (hw_queue != BEACON_QUEUE)
-		idx = (ring->idx + skb_queue_len(&ring->queue)) %
-				ring->entries;
-	else
+	if (hw_queue != BEACON_QUEUE) {
+		if (rtlpriv->use_new_trx_flow)
+			idx = ring->cur_tx_wp;
+		else
+			idx = (ring->idx + skb_queue_len(&ring->queue)) %
+			      ring->entries;
+	} else {
 		idx = 0;
+	}
 
 	pdesc = &ring->desc[idx];
 	if (rtlpriv->use_new_trx_flow) {
@@ -1525,7 +1715,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 	return 0;
 }
 
-static void rtl_pci_flush(struct ieee80211_hw *hw, bool drop)
+static void rtl_pci_flush(struct ieee80211_hw *hw, u32 queues, bool drop)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
@@ -1540,6 +1730,11 @@ static void rtl_pci_flush(struct ieee80211_hw *hw, bool drop)
 
 	for (queue_id = RTL_PCI_MAX_TX_QUEUE_COUNT - 1; queue_id >= 0;) {
 		u32 queue_len;
+
+		if (((queues >> queue_id) & 0x1) == 0) {
+			queue_id--;
+			continue;
+		}
 		ring = &pcipriv->dev.tx_ring[queue_id];
 		queue_len = skb_queue_len(&ring->queue);
 		if (queue_len == 0 || queue_id == BEACON_QUEUE ||
@@ -1603,6 +1798,10 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 	rtl_pci_reset_trx_ring(hw);
 
 	rtlpci->driver_is_goingto_unload = false;
+	if (rtlpriv->cfg->ops->get_btc_status()) {
+		rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
+		rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
+	}
 	err = rtlpriv->cfg->ops->hw_init(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
@@ -1622,7 +1821,7 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 
 	rtlpci->up_first_time = false;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "OK\n");
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "rtl_pci_start OK\n");
 	return 0;
 }
 
@@ -1635,6 +1834,9 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	unsigned long flags;
 	u8 RFInProgressTimeOut = 0;
 
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_halt_notify();
+
 	/*
 	 *should be before disable interrupt&adapter
 	 *and will do it immediately.
@@ -1753,6 +1955,22 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 		rtlhal->hw_type = HARDWARE_TYPE_RTL8188EE;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "Find adapter, Hardware type is 8188EE\n");
+	} else if (deviceid == RTL_PCI_8723BE_DID) {
+			rtlhal->hw_type = HARDWARE_TYPE_RTL8723BE;
+			RT_TRACE(rtlpriv, COMP_INIT , DBG_LOUD,
+				 "Find adapter, Hardware type is 8723BE\n");
+	} else if (deviceid == RTL_PCI_8192EE_DID) {
+			rtlhal->hw_type = HARDWARE_TYPE_RTL8192EE;
+			RT_TRACE(rtlpriv, COMP_INIT , DBG_LOUD,
+				 "Find adapter, Hardware type is 8192EE\n");
+	} else if (deviceid == RTL_PCI_8821AE_DID) {
+			rtlhal->hw_type = HARDWARE_TYPE_RTL8821AE;
+			RT_TRACE(rtlpriv, COMP_INIT , DBG_LOUD,
+				 "Find adapter, Hardware type is 8821AE\n");
+	} else if (deviceid == RTL_PCI_8812AE_DID) {
+			rtlhal->hw_type = HARDWARE_TYPE_RTL8812AE;
+			RT_TRACE(rtlpriv, COMP_INIT , DBG_LOUD,
+				 "Find adapter, Hardware type is 8812AE\n");
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Err: Unknown device - vid/did=%x/%x\n",
@@ -1779,11 +1997,20 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 			rtlhal->interfaceindex = 0;
 		}
 	}
+
+	/* 92ee use new trx flow */
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE)
+		rtlpriv->use_new_trx_flow = true;
+	else
+		rtlpriv->use_new_trx_flow = false;
+
 	/*find bus info */
 	pcipriv->ndis_adapter.busnumber = pdev->bus->number;
 	pcipriv->ndis_adapter.devnumber = PCI_SLOT(pdev->devfn);
 	pcipriv->ndis_adapter.funcnumber = PCI_FUNC(pdev->devfn);
 
+	/*find bridge info */
+	pcipriv->ndis_adapter.pcibridge_vendor = PCI_BRIDGE_VENDOR_UNKNOWN;
 	/* some ARM have no bridge_pdev and will crash here
 	 * so we should check if bridge_pdev is NULL
 	 */
@@ -1951,6 +2178,11 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	pcipriv = (void *)rtlpriv->priv;
 	pcipriv->dev.pdev = pdev;
 	init_completion(&rtlpriv->firmware_loading_complete);
+	/*proximity init here*/
+	rtlpriv->proximity.proxim_on = false;
+
+	pcipriv = (void *)rtlpriv->priv;
+	pcipriv->dev.pdev = pdev;
 
 	/* init cfg & intf_ops */
 	rtlpriv->rtlhal.interface = INTF_PCI;
@@ -2013,6 +2245,13 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	/*like read eeprom and so on */
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
 
+	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
+		err = -ENODEV;
+		goto fail3;
+	}
+	rtlpriv->cfg->ops->init_sw_leds(hw);
+
 	/*aspm */
 	rtl_pci_init_aspm(hw);
 
@@ -2031,13 +2270,14 @@ int rtl_pci_probe(struct pci_dev *pdev,
 		goto fail3;
 	}
 
-	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
+	err = ieee80211_register_hw(hw);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Can't register mac80211 hw.\n");
 		err = -ENODEV;
 		goto fail3;
 	}
-
-	rtlpriv->cfg->ops->init_sw_leds(hw);
+	rtlpriv->mac80211.mac80211_registered = 1;
 
 	err = sysfs_create_group(&pdev->dev.kobj, &rtl_attribute_group);
 	if (err) {
@@ -2046,6 +2286,9 @@ int rtl_pci_probe(struct pci_dev *pdev,
 		goto fail3;
 	}
 
+	/*init rfkill */
+	rtl_init_rfkill(hw);	/* Init PCI sw */
+
 	rtlpci = rtl_pcidev(pcipriv);
 	err = rtl_pci_intr_mode_decide(hw);
 	if (err) {
@@ -2056,9 +2299,11 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	}
 	rtlpci->irq_alloc = 1;
 
+	set_bit(RTL_STATUS_INTERFACE_START, &rtlpriv->status);
 	return 0;
 
 fail3:
+	pci_set_drvdata(pdev, NULL);
 	rtl_deinit_core(hw);
 
 	if (rtlpriv->io.pci_mem_start != 0)
@@ -2128,6 +2373,8 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 
 	rtl_pci_disable_aspm(hw);
 
+	pci_set_drvdata(pdev, NULL);
+
 	ieee80211_free_hw(hw);
 }
 EXPORT_SYMBOL(rtl_pci_disconnect);
diff --git a/drivers/net/wireless/rtlwifi/pci.h b/drivers/net/wireless/rtlwifi/pci.h
index 90174a8..5e83230 100644
--- a/drivers/net/wireless/rtlwifi/pci.h
+++ b/drivers/net/wireless/rtlwifi/pci.h
@@ -39,10 +39,11 @@
 #define RTL_PCI_RX_CMD_QUEUE			1
 #define RTL_PCI_MAX_RX_QUEUE			2
 
-#define RTL_PCI_MAX_RX_COUNT			64
+#define RTL_PCI_MAX_RX_COUNT			512/*64*/
 #define RTL_PCI_MAX_TX_QUEUE_COUNT		9
 
 #define RT_TXDESC_NUM				128
+#define TX_DESC_NUM_92E				512
 #define RT_TXDESC_NUM_BE_QUEUE			256
 
 #define BK_QUEUE				0
@@ -62,6 +63,12 @@
 	.subdevice = PCI_ANY_ID,\
 	.driver_data = (kernel_ulong_t)&(cfg)
 
+#define INTEL_VENDOR_ID				0x8086
+#define SIS_VENDOR_ID				0x1039
+#define ATI_VENDOR_ID				0x1002
+#define ATI_DEVICE_ID				0x7914
+#define AMD_VENDOR_ID				0x1022
+
 #define PCI_MAX_BRIDGE_NUMBER			255
 #define PCI_MAX_DEVICES				32
 #define PCI_MAX_FUNCTION			8
@@ -69,6 +76,11 @@
 #define PCI_CONF_ADDRESS	0x0CF8	/*PCI Configuration Space Address */
 #define PCI_CONF_DATA		0x0CFC	/*PCI Configuration Space Data */
 
+#define PCI_CLASS_BRIDGE_DEV		0x06
+#define PCI_SUBCLASS_BR_PCI_TO_PCI	0x04
+#define PCI_CAPABILITY_ID_PCI_EXPRESS	0x10
+#define PCI_CAP_ID_EXP			0x10
+
 #define U1DONTCARE			0xFF
 #define U2DONTCARE			0xFFFF
 #define U4DONTCARE			0xFFFFFFFF
@@ -87,6 +99,7 @@
 #define RTL_PCI_700F_DID	0x700F
 #define RTL_PCI_701F_DID	0x701F
 #define RTL_PCI_DLINK_DID	0x3304
+#define RTL_PCI_8723AE_DID	0x8723	/*8723e */
 #define RTL_PCI_8192CET_DID	0x8191	/*8192ce */
 #define RTL_PCI_8192CE_DID	0x8178	/*8192ce */
 #define RTL_PCI_8191CE_DID	0x8177	/*8192ce */
@@ -95,6 +108,10 @@
 #define RTL_PCI_8192DE_DID	0x8193	/*8192de */
 #define RTL_PCI_8192DE_DID2	0x002B	/*92DE*/
 #define RTL_PCI_8188EE_DID	0x8179  /*8188ee*/
+#define RTL_PCI_8723BE_DID	0xB723  /*8723be*/
+#define RTL_PCI_8192EE_DID	0x818B	/*8192ee*/
+#define RTL_PCI_8821AE_DID	0x8821	/*8821ae*/
+#define RTL_PCI_8812AE_DID	0x8812	/*8812ae*/
 
 /*8192 support 16 pages of IO registers*/
 #define RTL_MEM_MAPPED_IO_RANGE_8190PCI		0x1000
@@ -125,24 +142,34 @@ struct rtl_pci_capabilities_header {
 	u8 next;
 };
 
-struct rtl_rx_desc {
-	u32 dword[8];
+/* In new TRX flow, Buffer_desc is new concept
+ * But TX wifi info == TX descriptor in old flow
+ * RX wifi info == RX descriptor in old flow
+ */
+struct rtl_tx_buffer_desc {
+#if (RTL8192EE_SEG_NUM == 2)
+	u32 dword[2*(DMA_IS_64BIT + 1)*8]; /*seg = 8*/
+#elif (RTL8192EE_SEG_NUM == 1)
+	u32 dword[2*(DMA_IS_64BIT + 1)*4]; /*seg = 4*/
+#elif (RTL8192EE_SEG_NUM == 0)
+	u32 dword[2*(DMA_IS_64BIT + 1)*2]; /*seg = 2*/
+#endif
 } __packed;
 
 struct rtl_tx_desc {
 	u32 dword[16];
 } __packed;
 
-struct rtl_tx_cmd_desc {
-	u32 dword[16];
+struct rtl_rx_buffer_desc { /*rx buffer desc*/
+	u32 dword[2];
 } __packed;
 
-/* In new TRX flow, Buffer_desc is new concept
- * But TX wifi info == TX descriptor in old flow
- * RX wifi info == RX descriptor in old flow
- */
-struct rtl_tx_buffer_desc {
-	u32 dword[8]; /*seg = 4*/
+struct rtl_rx_desc { /*old: rx desc new: rx wifi info*/
+	u32 dword[8];
+} __packed;
+
+struct rtl_tx_cmd_desc {
+	u32 dword[16];
 } __packed;
 
 struct rtl8192_tx_ring {
@@ -153,6 +180,10 @@ struct rtl8192_tx_ring {
 	struct sk_buff_head queue;
 	/*add for new trx flow*/
 	struct rtl_tx_buffer_desc *buffer_desc; /*tx buffer descriptor*/
+	dma_addr_t buffer_desc_dma; /*tx bufferd desc dma memory*/
+	u16 avl_desc; /* available_desc_to_write */
+	u16 cur_tx_wp; /* current_tx_write_point */
+	u16 cur_tx_rp; /* current_tx_read_point */
 };
 
 struct rtl8192_rx_ring {
@@ -160,6 +191,9 @@ struct rtl8192_rx_ring {
 	dma_addr_t dma;
 	unsigned int idx;
 	struct sk_buff *rx_buf[RTL_PCI_MAX_RX_COUNT];
+	/*add for new trx flow*/
+	struct rtl_rx_buffer_desc *buffer_desc; /*rx buffer descriptor*/
+	u16 next_rx_rp; /* next_rx_read_point */
 };
 
 struct rtl_pci {
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index a943a24..9e990be 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -163,6 +163,12 @@
 #define DEL_SW_IDX_SZ		30
 #define BAND_NUM			3
 
+/* For now, it's just for 8192ee
+ * but not OK yet, keep it 0
+ */
+#define DMA_IS_64BIT 0
+#define RTL8192EE_SEG_NUM		1 /* 0:2 seg, 1: 4 seg, 2: 8 seg */
+
 enum rf_tx_num {
 	RF_1TX = 0,
 	RF_2TX,
@@ -636,6 +642,7 @@ enum rtl_var_map {
 	RTL_IMR_VIDOK,		/*AC_VI DMA OK Interrupt */
 	RTL_IMR_VODOK,		/*AC_VO DMA Interrupt */
 	RTL_IMR_ROK,		/*Receive DMA OK Interrupt */
+	RTL_IMR_HSISR_IND,	/*HSISR Interrupt*/
 	RTL_IBSS_INT_MASKS,	/*(RTL_IMR_BCNINT | RTL_IMR_TBDOK |
 				 * RTL_IMR_TBDER) */
 	RTL_IMR_C2HCMD,		/*fw interrupt*/
@@ -2006,7 +2013,7 @@ struct rtl_intf_ops {
 			   struct ieee80211_sta *sta,
 			   struct sk_buff *skb,
 			   struct rtl_tcb_desc *ptcb_desc);
-	void (*flush)(struct ieee80211_hw *hw, bool drop);
+	void (*flush)(struct ieee80211_hw *hw, u32 queues, bool drop);
 	int (*reset_trx_ring) (struct ieee80211_hw *hw);
 	bool (*waitq_insert) (struct ieee80211_hw *hw,
 			      struct ieee80211_sta *sta,
-- 
1.8.4.5
