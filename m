From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 13/15] rtlwifi: rtl8723ae: Add new driver - Part 13
Date: Mon, 17 Sep 2012 16:18:52 -0500
Message-ID: <1347916754-9219-13-git-send-email-Larry.Finger@lwfinger.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347483294-6943-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is part 13 of the addition of files for a new driver to handle
the Realtek RTL8723AE wireless device.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |  830 ++++++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h |  725 ++++++++++++++++++++++
 2 files changed, 1555 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h

Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -0,0 +1,823 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *****************************************************************************/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "../base.h"
+#include "../stats.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "trx.h"
+#include "led.h"
+
+static u8 _rtl8723ae_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
+{
+	__le16 fc = rtl_get_fc(skb);
+
+	if (unlikely(ieee80211_is_beacon(fc)))
+		return QSLT_BEACON;
+	if (ieee80211_is_mgmt(fc) || ieee80211_is_ctl(fc))
+		return QSLT_MGNT;
+
+	return skb->priority;
+}
+
+/* mac80211's rate_idx is like this:
+ *
+ * 2.4G band:rx_status->band == IEEE80211_BAND_2GHZ
+ *
+ * B/G rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE1M-->DESC92C_RATE54M ==> idx is 0-->11,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ *
+ * 5G band:rx_status->band == IEEE80211_BAND_5GHZ
+ * A rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE6M-->DESC92C_RATE54M ==> idx is 0-->7,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ */
+static int _rtl8723ae_rate_mapping(struct ieee80211_hw *hw,
+	bool isht, u8 desc_rate)
+{
+	int rate_idx;
+
+	if (false == isht) {
+		if (IEEE80211_BAND_2GHZ == hw->conf.channel->band) {
+			switch (desc_rate) {
+			case DESC92C_RATE1M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE2M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE5_5M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE11M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE6M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 7;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 8;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 9;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 10;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 11;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		} else {
+			switch (desc_rate) {
+			case DESC92C_RATE6M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 7;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		}
+	} else {
+		switch (desc_rate) {
+		case DESC92C_RATEMCS0:
+			rate_idx = 0;
+			break;
+		case DESC92C_RATEMCS1:
+			rate_idx = 1;
+			break;
+		case DESC92C_RATEMCS2:
+			rate_idx = 2;
+			break;
+		case DESC92C_RATEMCS3:
+			rate_idx = 3;
+			break;
+		case DESC92C_RATEMCS4:
+			rate_idx = 4;
+			break;
+		case DESC92C_RATEMCS5:
+			rate_idx = 5;
+			break;
+		case DESC92C_RATEMCS6:
+			rate_idx = 6;
+			break;
+		case DESC92C_RATEMCS7:
+			rate_idx = 7;
+			break;
+		case DESC92C_RATEMCS8:
+			rate_idx = 8;
+			break;
+		case DESC92C_RATEMCS9:
+			rate_idx = 9;
+			break;
+		case DESC92C_RATEMCS10:
+			rate_idx = 10;
+			break;
+		case DESC92C_RATEMCS11:
+			rate_idx = 11;
+			break;
+		case DESC92C_RATEMCS12:
+			rate_idx = 12;
+			break;
+		case DESC92C_RATEMCS13:
+			rate_idx = 13;
+			break;
+		case DESC92C_RATEMCS14:
+			rate_idx = 14;
+			break;
+		case DESC92C_RATEMCS15:
+			rate_idx = 15;
+			break;
+		default:
+			rate_idx = 0;
+			break;
+		}
+	}
+	return rate_idx;
+}
+
+static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
+			struct rtl_stats *pstatus, u8 *pdesc,
+			struct rx_fwinfo_8723e *p_drvinfo,
+			bool bpacket_match_bssid,
+			bool bpacket_toself, bool packet_beacon)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
+	struct phy_sts_cck_8723e_t *cck_buf;
+	s8 rx_pwr_all, rx_pwr[4];
+	u8 rf_rx_num = 0, evm, pwdb_all;
+	u8 i, max_spatial_stream;
+	u32 rssi, total_rssi = 0;
+	bool is_cck = pstatus->is_cck;
+
+	/* Record it for next packet processing */
+	pstatus->packet_matchbssid = bpacket_match_bssid;
+	pstatus->packet_toself = bpacket_toself;
+	pstatus->packet_beacon = packet_beacon;
+	pstatus->rx_mimo_signalquality[0] = -1;
+	pstatus->rx_mimo_signalquality[1] = -1;
+
+	if (is_cck) {
+		u8 report, cck_highpwr;
+
+		/* CCK Driver info Structure is not the same as OFDM packet. */
+		cck_buf = (struct phy_sts_cck_8723e_t *)p_drvinfo;
+
+		/* (1)Hardware does not provide RSSI for CCK */
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive) */
+		if (ppsc->rfpwr_state == ERFON)
+			cck_highpwr = (u8) rtl_get_bbreg(hw,
+						 RFPGA0_XA_HSSIPARAMETER2,
+						 BIT(9));
+		else
+			cck_highpwr = false;
+
+		if (!cck_highpwr) {
+			u8 cck_agc_rpt = cck_buf->cck_agc_rpt;
+			report = cck_buf->cck_agc_rpt & 0xc0;
+			report = report >> 6;
+			switch (report) {
+			case 0x3:
+				rx_pwr_all = -46 - (cck_agc_rpt & 0x3e);
+				break;
+			case 0x2:
+				rx_pwr_all = -26 - (cck_agc_rpt & 0x3e);
+				break;
+			case 0x1:
+				rx_pwr_all = -12 - (cck_agc_rpt & 0x3e);
+				break;
+			case 0x0:
+				rx_pwr_all = 16 - (cck_agc_rpt & 0x3e);
+				break;
+			}
+		} else {
+			u8 cck_agc_rpt = cck_buf->cck_agc_rpt;
+			report = p_drvinfo->cfosho[0] & 0x60;
+			report = report >> 5;
+			switch (report) {
+			case 0x3:
+				rx_pwr_all = -46 - ((cck_agc_rpt & 0x1f) << 1);
+				break;
+			case 0x2:
+				rx_pwr_all = -26 - ((cck_agc_rpt & 0x1f) << 1);
+				break;
+			case 0x1:
+				rx_pwr_all = -12 - ((cck_agc_rpt & 0x1f) << 1);
+				break;
+			case 0x0:
+				rx_pwr_all = 16 - ((cck_agc_rpt & 0x1f) << 1);
+				break;
+			}
+		}
+
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
+		/* CCK gain is smaller than OFDM/MCS gain,  */
+		/* so we add gain diff by experiences,
+		 * the val is 6 */
+		pwdb_all += 6;
+		if (pwdb_all > 100)
+			pwdb_all = 100;
+		/* modify the offset to make the same
+		 * gain index with OFDM. */
+		if (pwdb_all > 34 && pwdb_all <= 42)
+			pwdb_all -= 2;
+		else if (pwdb_all > 26 && pwdb_all <= 34)
+			pwdb_all -= 6;
+		else if (pwdb_all > 14 && pwdb_all <= 26)
+			pwdb_all -= 8;
+		else if (pwdb_all > 4 && pwdb_all <= 14)
+			pwdb_all -= 4;
+
+		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->recvsignalpower = rx_pwr_all;
+
+		/* (3) Get Signal Quality (EVM) */
+		if (bpacket_match_bssid) {
+			u8 sq;
+
+			if (pstatus->rx_pwdb_all > 40)
+				sq = 100;
+			else {
+				sq = cck_buf->sq_rpt;
+				if (sq > 64)
+					sq = 0;
+				else if (sq < 20)
+					sq = 100;
+				else
+					sq = ((64 - sq) * 100) / 44;
+			}
+
+			pstatus->signalquality = sq;
+			pstatus->rx_mimo_signalquality[0] = sq;
+			pstatus->rx_mimo_signalquality[1] = -1;
+		}
+	} else {
+		rtlpriv->dm.rfpath_rxenable[0] =
+		    rtlpriv->dm.rfpath_rxenable[1] = true;
+
+		/* (1)Get RSSI for HT rate */
+		for (i = RF90_PATH_A; i < RF6052_MAX_PATH; i++) {
+
+			/* we will judge RF RX path now. */
+			if (rtlpriv->dm.rfpath_rxenable[i])
+				rf_rx_num++;
+
+			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f)*2) - 110;
+
+			/* Translate DBM to percentage. */
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
+			total_rssi += rssi;
+
+			/* Get Rx snr value in DB */
+			rtlpriv->stats.rx_snr_db[i] = (p_drvinfo->rxsnr[i] / 2);
+
+			/* Record Signal Strength for next packet */
+			if (bpacket_match_bssid)
+				pstatus->rx_mimo_signalstrength[i] = (u8) rssi;
+		}
+
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive) */
+		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
+
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
+		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->rxpower = rx_pwr_all;
+		pstatus->recvsignalpower = rx_pwr_all;
+
+		/* (3)EVM of HT rate */
+		if (pstatus->is_ht && pstatus->rate >= DESC92C_RATEMCS8 &&
+		    pstatus->rate <= DESC92C_RATEMCS15)
+			max_spatial_stream = 2;
+		else
+			max_spatial_stream = 1;
+
+		for (i = 0; i < max_spatial_stream; i++) {
+			evm = rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
+
+			if (bpacket_match_bssid) {
+				/* Fill value in RFD, Get the first
+				 * spatial stream only */
+				if (i == 0)
+					pstatus->signalquality = (evm & 0xff);
+				pstatus->rx_mimo_signalquality[i] =
+								 (evm & 0xff);
+			}
+		}
+	}
+
+	/* UI BSS List signal strength(in percentage),
+	 * make it good looking, from 0~100. */
+	if (is_cck)
+		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
+			pwdb_all));
+	else if (rf_rx_num != 0)
+		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
+			total_rssi /= rf_rx_num));
+}
+
+static void _rtl8723ae_translate_rx_signal_stuff(struct ieee80211_hw *hw,
+		struct sk_buff *skb, struct rtl_stats *pstatus,
+		u8 *pdesc, struct rx_fwinfo_8723e *p_drvinfo)
+{
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct ieee80211_hdr *hdr;
+	u8 *tmp_buf;
+	u8 *praddr;
+	u8 *psaddr;
+	__le16 fc;
+	u16 type;
+	bool packet_matchbssid, packet_toself, packet_beacon;
+
+	tmp_buf = skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
+
+	hdr = (struct ieee80211_hdr *)tmp_buf;
+	fc = hdr->frame_control;
+	type = WLAN_FC_GET_TYPE(fc);
+	praddr = hdr->addr1;
+	psaddr = ieee80211_get_SA(hdr);
+
+	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
+			    (!compare_ether_addr(mac->bssid,
+			    (le16_to_cpu(fc) & IEEE80211_FCTL_TODS) ?
+			    hdr->addr1 : (le16_to_cpu(fc) &
+			    IEEE80211_FCTL_FROMDS) ?
+			    hdr->addr2 : hdr->addr3)) && (!pstatus->hwerror) &&
+			    (!pstatus->crc) && (!pstatus->icv));
+
+	packet_toself = packet_matchbssid &&
+	    (!compare_ether_addr(praddr, rtlefuse->dev_addr));
+
+	if (ieee80211_is_beacon(fc))
+		packet_beacon = true;
+
+	_rtl8723ae_query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
+				   packet_matchbssid, packet_toself,
+				   packet_beacon);
+
+	rtl_process_phyinfo(hw, tmp_buf, pstatus);
+}
+
+bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
+			     struct rtl_stats *status,
+			     struct ieee80211_rx_status *rx_status,
+			     u8 *pdesc, struct sk_buff *skb)
+{
+	struct rx_fwinfo_8723e *p_drvinfo;
+	struct ieee80211_hdr *hdr;
+	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
+
+	status->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
+	status->rx_drvinfo_size = (u8) GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
+	    RX_DRV_INFO_SIZE_UNIT;
+	status->rx_bufshift = (u8) (GET_RX_DESC_SHIFT(pdesc) & 0x03);
+	status->icv = (u16) GET_RX_DESC_ICV(pdesc);
+	status->crc = (u16) GET_RX_DESC_CRC32(pdesc);
+	status->hwerror = (status->crc | status->icv);
+	status->decrypted = !GET_RX_DESC_SWDEC(pdesc);
+	status->rate = (u8) GET_RX_DESC_RXMCS(pdesc);
+	status->shortpreamble = (u16) GET_RX_DESC_SPLCP(pdesc);
+	status->isampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
+	status->isfirst_ampdu = (bool) ((GET_RX_DESC_PAGGR(pdesc) == 1)
+				   && (GET_RX_DESC_FAGGR(pdesc) == 1));
+	status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
+	status->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
+	status->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
+
+	status->is_cck = RTL8723E_RX_HAL_IS_CCK_RATE(status->rate);
+
+	rx_status->freq = hw->conf.channel->center_freq;
+	rx_status->band = hw->conf.channel->band;
+
+	hdr = (struct ieee80211_hdr *)(skb->data + status->rx_drvinfo_size
+			+ status->rx_bufshift);
+
+	if (status->crc)
+		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
+
+	if (status->rx_is40Mhzpacket)
+		rx_status->flag |= RX_FLAG_40MHZ;
+
+	if (status->is_ht)
+		rx_status->flag |= RX_FLAG_HT;
+
+	rx_status->flag |= RX_FLAG_MACTIME_MPDU;
+
+	/* hw will set status->decrypted true, if it finds the
+	 * frame is open data frame or mgmt frame.
+	 * Thus hw will not decrypt a robust managment frame
+	 * for IEEE80211w but still set status->decrypted
+	 * true, so here we should set it back to undecrypted
+	 * for IEEE80211w frame, and mac80211 sw will help
+	 * to decrypt it */
+	if (status->decrypted) {
+		if ((ieee80211_is_robust_mgmt_frame(hdr)) &&
+			(ieee80211_has_protected(hdr->frame_control)))
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag |= RX_FLAG_DECRYPTED;
+	}
+
+	/* rate_idx: index of data rate into band's
+	 * supported rates or MCS index if HT rates
+	 * are use (RX_FLAG_HT)*/
+	/* Notice: this is diff with windows define */
+	rx_status->rate_idx = _rtl8723ae_rate_mapping(hw,
+				status->is_ht, status->rate);
+
+	rx_status->mactime = status->timestamp_low;
+	if (phystatus == true) {
+		p_drvinfo = (struct rx_fwinfo_8723e *)(skb->data +
+			     status->rx_bufshift);
+
+		_rtl8723ae_translate_rx_signal_stuff(hw,
+			   skb, status, pdesc, p_drvinfo);
+	}
+
+	/*rx_status->qual = status->signal; */
+	rx_status->signal = status->recvsignalpower + 10;
+	/*rx_status->noise = -status->noise; */
+
+	return true;
+}
+
+void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
+			    struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			    struct ieee80211_tx_info *info,
+			    struct ieee80211_sta *sta,
+			    struct sk_buff *skb, u8 hw_queue,
+			    struct rtl_tcb_desc *ptcdesc)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	bool defaultadapter = true;
+	u8 *pdesc = (u8 *) pdesc_tx;
+	u16 seq_number;
+	__le16 fc = hdr->frame_control;
+	u8 fw_qsel = _rtl8723ae_map_hwqueue_to_fwqueue(skb, hw_queue);
+	bool firstseg = ((hdr->seq_ctrl &
+			    cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
+	bool lastseg = ((hdr->frame_control &
+			   cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
+	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
+					    skb->data, skb->len,
+					    PCI_DMA_TODEVICE);
+	u8 bw_40 = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_STATION) {
+		bw_40 = mac->bw_40;
+	} else if (mac->opmode == NL80211_IFTYPE_AP ||
+		mac->opmode == NL80211_IFTYPE_ADHOC) {
+		if (sta)
+			bw_40 = sta->ht_cap.cap &
+				IEEE80211_HT_CAP_SUP_WIDTH_20_40;
+	}
+
+	seq_number = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
+
+	rtl_get_tcb_desc(hw, info, sta, skb, ptcdesc);
+
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_8723e));
+
+	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
+		firstseg = true;
+		lastseg = true;
+	}
+
+	if (firstseg) {
+		SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+
+		SET_TX_DESC_TX_RATE(pdesc, ptcdesc->hw_rate);
+
+		if (ptcdesc->use_shortgi || ptcdesc->use_shortpreamble)
+			SET_TX_DESC_DATA_SHORTGI(pdesc, 1);
+
+		if (info->flags & IEEE80211_TX_CTL_AMPDU) {
+			SET_TX_DESC_AGG_BREAK(pdesc, 1);
+			SET_TX_DESC_MAX_AGG_NUM(pdesc, 0x14);
+		}
+		SET_TX_DESC_SEQ(pdesc, seq_number);
+
+		SET_TX_DESC_RTS_ENABLE(pdesc, ((ptcdesc->rts_enable &&
+						!ptcdesc->
+						cts_enable) ? 1 : 0));
+		SET_TX_DESC_HW_RTS_ENABLE(pdesc,
+					  ((ptcdesc->rts_enable
+					    || ptcdesc->cts_enable) ? 1 : 0));
+		SET_TX_DESC_CTS2SELF(pdesc, ((ptcdesc->cts_enable) ? 1 : 0));
+		SET_TX_DESC_RTS_STBC(pdesc, ((ptcdesc->rts_stbc) ? 1 : 0));
+
+		SET_TX_DESC_RTS_RATE(pdesc, ptcdesc->rts_rate);
+		SET_TX_DESC_RTS_BW(pdesc, 0);
+		SET_TX_DESC_RTS_SC(pdesc, ptcdesc->rts_sc);
+		SET_TX_DESC_RTS_SHORT(pdesc,
+				      ((ptcdesc->rts_rate <= DESC92C_RATE54M) ?
+				       (ptcdesc->rts_use_shortpreamble ? 1 : 0)
+				       : (ptcdesc->rts_use_shortgi ? 1 : 0)));
+
+		if (bw_40) {
+			if (ptcdesc->packet_bw) {
+				SET_TX_DESC_DATA_BW(pdesc, 1);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc, 3);
+			} else {
+				SET_TX_DESC_DATA_BW(pdesc, 0);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc,
+							 mac->cur_40_prime_sc);
+			}
+		} else {
+			SET_TX_DESC_DATA_BW(pdesc, 0);
+			SET_TX_DESC_TX_SUB_CARRIER(pdesc, 0);
+		}
+
+		SET_TX_DESC_LINIP(pdesc, 0);
+		SET_TX_DESC_PKT_SIZE(pdesc, (u16) skb->len);
+
+		if (sta) {
+			u8 ampdu_density = sta->ht_cap.ampdu_density;
+			SET_TX_DESC_AMPDU_DENSITY(pdesc, ampdu_density);
+		}
+
+		if (info->control.hw_key) {
+			struct ieee80211_key_conf *keyconf =
+			    info->control.hw_key;
+
+			switch (keyconf->cipher) {
+			case WLAN_CIPHER_SUITE_WEP40:
+			case WLAN_CIPHER_SUITE_WEP104:
+			case WLAN_CIPHER_SUITE_TKIP:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x1);
+				break;
+			case WLAN_CIPHER_SUITE_CCMP:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x3);
+				break;
+			default:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x0);
+				break;
+			}
+		}
+
+		SET_TX_DESC_PKT_ID(pdesc, 0);
+		SET_TX_DESC_QUEUE_SEL(pdesc, fw_qsel);
+
+		SET_TX_DESC_DATA_RATE_FB_LIMIT(pdesc, 0x1F);
+		SET_TX_DESC_RTS_RATE_FB_LIMIT(pdesc, 0xF);
+		SET_TX_DESC_DISABLE_FB(pdesc, 0);
+		SET_TX_DESC_USE_RATE(pdesc, ptcdesc->use_driver_rate ? 1 : 0);
+
+		if (ieee80211_is_data_qos(fc)) {
+			if (mac->rdg_en) {
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+					 "Enable RDG function.\n");
+				SET_TX_DESC_RDG_ENABLE(pdesc, 1);
+				SET_TX_DESC_HTC(pdesc, 1);
+			}
+		}
+	}
+
+	SET_TX_DESC_FIRST_SEG(pdesc, (firstseg ? 1 : 0));
+	SET_TX_DESC_LAST_SEG(pdesc, (lastseg ? 1 : 0));
+
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16) skb->len);
+
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+
+	if (rtlpriv->dm.useramask) {
+		SET_TX_DESC_RATE_ID(pdesc, ptcdesc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcdesc->mac_id);
+	} else {
+		SET_TX_DESC_RATE_ID(pdesc, 0xC + ptcdesc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcdesc->ratr_index);
+	}
+
+	if ((!ieee80211_is_data_qos(fc)) && ppsc->fwctrl_lps) {
+		SET_TX_DESC_HWSEQ_EN_8723(pdesc, 1);
+
+		if (!defaultadapter)
+			SET_TX_DESC_HWSEQ_SEL_8723(pdesc, 1);
+	}
+
+	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
+
+	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
+	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
+		SET_TX_DESC_BMC(pdesc, 1);
+	}
+
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
+}
+
+void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
+			      u8 *pdesc, bool firstseg,
+			      bool lastseg, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)(skb->data);
+	u8 fw_queue = QSLT_BEACON;
+	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
+					    skb->data, skb->len,
+					    PCI_DMA_TODEVICE);
+	__le16 fc = hdr->frame_control;
+
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
+
+	if (firstseg)
+		SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+
+	SET_TX_DESC_TX_RATE(pdesc, DESC92C_RATE1M);
+
+	SET_TX_DESC_SEQ(pdesc, 0);
+
+	SET_TX_DESC_LINIP(pdesc, 0);
+
+	SET_TX_DESC_QUEUE_SEL(pdesc, fw_queue);
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16) (skb->len));
+
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+
+	SET_TX_DESC_RATE_ID(pdesc, 7);
+	SET_TX_DESC_MACID(pdesc, 0);
+
+	SET_TX_DESC_OWN(pdesc, 1);
+
+	SET_TX_DESC_PKT_SIZE((u8 *) pdesc, (u16) (skb->len));
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_OFFSET(pdesc, 0x20);
+
+	SET_TX_DESC_USE_RATE(pdesc, 1);
+
+	if (!ieee80211_is_data_qos(fc)) {
+		SET_TX_DESC_HWSEQ_EN_8723(pdesc, 1);
+		/* SET_TX_DESC_HWSEQ_EN(pdesc, 1); */
+		/* SET_TX_DESC_PKT_ID(pdesc, 8); */
+	}
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "H2C Tx Cmd Content\n",
+		      pdesc, TX_DESC_SIZE);
+}
+
+void rtl8723ae_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
+{
+	if (istx == true) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			SET_TX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_TX_NEXTDESC_ADDR:
+			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *) val);
+			break;
+		default:
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_RXOWN:
+			SET_RX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_RXBUFF_ADDR:
+			SET_RX_DESC_BUFF_ADDR(pdesc, *(u32 *) val);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			SET_RX_DESC_PKT_LEN(pdesc, *(u32 *) val);
+			break;
+		case HW_DESC_RXERO:
+			SET_RX_DESC_EOR(pdesc, 1);
+			break;
+		default:
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	}
+}
+
+u32 rtl8723ae_get_desc(u8 *pdesc, bool istx, u8 desc_name)
+{
+	u32 ret = 0;
+
+	if (istx == true) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret = GET_TX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_TXBUFF_ADDR:
+			ret = GET_TX_DESC_TX_BUFFER_ADDRESS(pdesc);
+			break;
+		default:
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret = GET_RX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			ret = GET_RX_DESC_PKT_LEN(pdesc);
+			break;
+		default:
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	}
+	return ret;
+}
+
+void rtl8723ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	if (hw_queue == BEACON_QUEUE) {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG, BIT(4));
+	} else {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG,
+			       BIT(0) << (hw_queue));
+	}
+}
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
@@ -0,0 +1,725 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL8723E_TRX_H__
+#define __RTL8723E_TRX_H__
+
+#define TX_DESC_SIZE				64
+#define TX_DESC_AGGR_SUBFRAME_SIZE		32
+
+#define RX_DESC_SIZE				32
+#define RX_DRV_INFO_SIZE_UNIT			8
+
+#define	TX_DESC_NEXT_DESC_OFFSET		40
+#define USB_HWDESC_HEADER_LEN			32
+#define CRCLENGTH				4
+
+#define SET_TX_DESC_PKT_SIZE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 16, __val)
+#define SET_TX_DESC_OFFSET(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 16, 8, __val)
+#define SET_TX_DESC_BMC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 24, 1, __val)
+#define SET_TX_DESC_HTC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 25, 1, __val)
+#define SET_TX_DESC_LAST_SEG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 26, 1, __val)
+#define SET_TX_DESC_FIRST_SEG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 27, 1, __val)
+#define SET_TX_DESC_LINIP(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 28, 1, __val)
+#define SET_TX_DESC_NO_ACM(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 29, 1, __val)
+#define SET_TX_DESC_GF(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
+#define SET_TX_DESC_OWN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+#define GET_TX_DESC_PKT_SIZE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 0, 16)
+#define GET_TX_DESC_OFFSET(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 16, 8)
+#define GET_TX_DESC_BMC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 24, 1)
+#define GET_TX_DESC_HTC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 25, 1)
+#define GET_TX_DESC_LAST_SEG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
+#define GET_TX_DESC_FIRST_SEG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
+#define GET_TX_DESC_LINIP(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
+#define GET_TX_DESC_NO_ACM(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
+#define GET_TX_DESC_GF(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
+#define GET_TX_DESC_OWN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
+
+#define SET_TX_DESC_MACID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 0, 5, __val)
+#define SET_TX_DESC_AGG_BREAK(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 5, 1, __val)
+#define SET_TX_DESC_BK(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 6, 1, __val)
+#define SET_TX_DESC_RDG_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 7, 1, __val)
+#define SET_TX_DESC_QUEUE_SEL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 8, 5, __val)
+#define SET_TX_DESC_RDG_NAV_EXT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 13, 1, __val)
+#define SET_TX_DESC_LSIG_TXOP_EN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 14, 1, __val)
+#define SET_TX_DESC_PIFS(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 15, 1, __val)
+#define SET_TX_DESC_RATE_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 16, 4, __val)
+#define SET_TX_DESC_NAV_USE_HDR(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 20, 1, __val)
+#define SET_TX_DESC_EN_DESC_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 21, 1, __val)
+#define SET_TX_DESC_SEC_TYPE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 22, 2, __val)
+#define SET_TX_DESC_PKT_OFFSET(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 24, 8, __val)
+
+#define GET_TX_DESC_MACID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 0, 5)
+#define GET_TX_DESC_AGG_ENABLE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 5, 1)
+#define GET_TX_DESC_AGG_BREAK(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 6, 1)
+#define GET_TX_DESC_RDG_ENABLE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 7, 1)
+#define GET_TX_DESC_QUEUE_SEL(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 8, 5)
+#define GET_TX_DESC_RDG_NAV_EXT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 13, 1)
+#define GET_TX_DESC_LSIG_TXOP_EN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
+#define GET_TX_DESC_PIFS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
+#define GET_TX_DESC_RATE_ID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
+#define GET_TX_DESC_NAV_USE_HDR(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 20, 1)
+#define GET_TX_DESC_EN_DESC_ID(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 21, 1)
+#define GET_TX_DESC_SEC_TYPE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 22, 2)
+#define GET_TX_DESC_PKT_OFFSET(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 24, 8)
+
+#define SET_TX_DESC_RTS_RC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 0, 6, __val)
+#define SET_TX_DESC_DATA_RC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 6, 6, __val)
+#define SET_TX_DESC_BAR_RTY_TH(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 14, 2, __val)
+#define SET_TX_DESC_MORE_FRAG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 17, 1, __val)
+#define SET_TX_DESC_RAW(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 18, 1, __val)
+#define SET_TX_DESC_CCX(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 19, 1, __val)
+#define SET_TX_DESC_AMPDU_DENSITY(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 20, 3, __val)
+#define SET_TX_DESC_ANTSEL_A(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 24, 1, __val)
+#define SET_TX_DESC_ANTSEL_B(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 25, 1, __val)
+#define SET_TX_DESC_TX_ANT_CCK(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 26, 2, __val)
+#define SET_TX_DESC_TX_ANTL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 28, 2, __val)
+#define SET_TX_DESC_TX_ANT_HT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 30, 2, __val)
+
+#define GET_TX_DESC_RTS_RC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 0, 6)
+#define GET_TX_DESC_DATA_RC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 6, 6)
+#define GET_TX_DESC_BAR_RTY_TH(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+8, 14, 2)
+#define GET_TX_DESC_MORE_FRAG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 17, 1)
+#define GET_TX_DESC_RAW(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 18, 1)
+#define GET_TX_DESC_CCX(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 19, 1)
+#define GET_TX_DESC_AMPDU_DENSITY(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+8, 20, 3)
+#define GET_TX_DESC_ANTSEL_A(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 24, 1)
+#define GET_TX_DESC_ANTSEL_B(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 25, 1)
+#define GET_TX_DESC_TX_ANT_CCK(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+8, 26, 2)
+#define GET_TX_DESC_TX_ANTL(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 28, 2)
+#define GET_TX_DESC_TX_ANT_HT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 30, 2)
+
+#define SET_TX_DESC_NEXT_HEAP_PAGE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 0, 8, __val)
+#define SET_TX_DESC_TAIL_PAGE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 8, 8, __val)
+#define SET_TX_DESC_SEQ(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 16, 12, __val)
+#define SET_TX_DESC_PKT_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 28, 4, __val)
+
+#define GET_TX_DESC_NEXT_HEAP_PAGE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 0, 8)
+#define GET_TX_DESC_TAIL_PAGE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 8, 8)
+#define GET_TX_DESC_SEQ(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 16, 12)
+#define GET_TX_DESC_PKT_ID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 28, 4)
+
+/* For RTL8723 */
+#define SET_TX_DESC_TRIGGER_INT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 30, 1, __val)
+#define SET_TX_DESC_HWSEQ_EN_8723(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 31, 1, __val)
+#define SET_TX_DESC_HWSEQ_SEL_8723(__pTxDesc, __Value)	\
+	SET_BITS_TO_LE_4BYTE(__pTxDesc+16, 6, 2, __Value)
+
+#define SET_TX_DESC_RTS_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 5, __val)
+#define SET_TX_DESC_AP_DCFE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 5, 1, __val)
+#define SET_TX_DESC_QOS(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 6, 1, __val)
+#define SET_TX_DESC_HWSEQ_EN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 7, 1, __val)
+#define SET_TX_DESC_USE_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 8, 1, __val)
+#define SET_TX_DESC_DISABLE_RTS_FB(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 9, 1, __val)
+#define SET_TX_DESC_DISABLE_FB(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 10, 1, __val)
+#define SET_TX_DESC_CTS2SELF(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 11, 1, __val)
+#define SET_TX_DESC_RTS_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 12, 1, __val)
+#define SET_TX_DESC_HW_RTS_ENABLE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 13, 1, __val)
+#define SET_TX_DESC_PORT_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 14, 1, __val)
+#define SET_TX_DESC_WAIT_DCTS(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 18, 1, __val)
+#define SET_TX_DESC_CTS2AP_EN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 19, 1, __val)
+#define SET_TX_DESC_TX_SUB_CARRIER(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 20, 2, __val)
+#define SET_TX_DESC_TX_STBC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 22, 2, __val)
+#define SET_TX_DESC_DATA_SHORT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 24, 1, __val)
+#define SET_TX_DESC_DATA_BW(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 25, 1, __val)
+#define SET_TX_DESC_RTS_SHORT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 26, 1, __val)
+#define SET_TX_DESC_RTS_BW(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 27, 1, __val)
+#define SET_TX_DESC_RTS_SC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 28, 2, __val)
+#define SET_TX_DESC_RTS_STBC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 30, 2, __val)
+
+#define GET_TX_DESC_RTS_RATE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 0, 5)
+#define GET_TX_DESC_AP_DCFE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 5, 1)
+#define GET_TX_DESC_QOS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 6, 1)
+#define GET_TX_DESC_HWSEQ_EN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 7, 1)
+#define GET_TX_DESC_USE_RATE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 8, 1)
+#define GET_TX_DESC_DISABLE_RTS_FB(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+16, 9, 1)
+#define GET_TX_DESC_DISABLE_FB(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+16, 10, 1)
+#define GET_TX_DESC_CTS2SELF(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 11, 1)
+#define GET_TX_DESC_RTS_ENABLE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+16, 12, 1)
+#define GET_TX_DESC_HW_RTS_ENABLE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+16, 13, 1)
+#define GET_TX_DESC_PORT_ID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 14, 1)
+#define GET_TX_DESC_WAIT_DCTS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 18, 1)
+#define GET_TX_DESC_CTS2AP_EN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 19, 1)
+#define GET_TX_DESC_TX_SUB_CARRIER(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+16, 20, 2)
+#define GET_TX_DESC_TX_STBC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 22, 2)
+#define GET_TX_DESC_DATA_SHORT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+16, 24, 1)
+#define GET_TX_DESC_DATA_BW(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 25, 1)
+#define GET_TX_DESC_RTS_SHORT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 26, 1)
+#define GET_TX_DESC_RTS_BW(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 27, 1)
+#define GET_TX_DESC_RTS_SC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 28, 2)
+#define GET_TX_DESC_RTS_STBC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 30, 2)
+
+#define SET_TX_DESC_TX_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 0, 6, __val)
+#define SET_TX_DESC_DATA_SHORTGI(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 6, 1, __val)
+#define SET_TX_DESC_CCX_TAG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 7, 1, __val)
+#define SET_TX_DESC_DATA_RATE_FB_LIMIT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 8, 5, __val)
+#define SET_TX_DESC_RTS_RATE_FB_LIMIT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 13, 4, __val)
+#define SET_TX_DESC_RETRY_LIMIT_ENABLE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 17, 1, __val)
+#define SET_TX_DESC_DATA_RETRY_LIMIT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 18, 6, __val)
+#define SET_TX_DESC_USB_TXAGG_NUM(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 24, 8, __val)
+
+#define GET_TX_DESC_TX_RATE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+20, 0, 6)
+#define GET_TX_DESC_DATA_SHORTGI(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 6, 1)
+#define GET_TX_DESC_CCX_TAG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+20, 7, 1)
+#define GET_TX_DESC_DATA_RATE_FB_LIMIT(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+20, 8, 5)
+#define GET_TX_DESC_RTS_RATE_FB_LIMIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 13, 4)
+#define GET_TX_DESC_RETRY_LIMIT_ENABLE(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+20, 17, 1)
+#define GET_TX_DESC_DATA_RETRY_LIMIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 18, 6)
+#define GET_TX_DESC_USB_TXAGG_NUM(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+20, 24, 8)
+
+#define SET_TX_DESC_TXAGC_A(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 5, __val)
+#define SET_TX_DESC_TXAGC_B(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 5, 5, __val)
+#define SET_TX_DESC_USE_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 10, 1, __val)
+#define SET_TX_DESC_MAX_AGG_NUM(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 11, 5, __val)
+#define SET_TX_DESC_MCSG1_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 16, 4, __val)
+#define SET_TX_DESC_MCSG2_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 20, 4, __val)
+#define SET_TX_DESC_MCSG3_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 24, 4, __val)
+#define SET_TX_DESC_MCS7_SGI_MAX_LEN(__pdesc, __val)\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 28, 4, __val)
+
+#define GET_TX_DESC_TXAGC_A(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+24, 0, 5)
+#define GET_TX_DESC_TXAGC_B(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+24, 5, 5)
+#define GET_TX_DESC_USE_MAX_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 10, 1)
+#define GET_TX_DESC_MAX_AGG_NUM(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 11, 5)
+#define GET_TX_DESC_MCSG1_MAX_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 16, 4)
+#define GET_TX_DESC_MCSG2_MAX_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 20, 4)
+#define GET_TX_DESC_MCSG3_MAX_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 24, 4)
+#define GET_TX_DESC_MCS7_SGI_MAX_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+24, 28, 4)
+
+#define SET_TX_DESC_TX_BUFFER_SIZE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 16, __val)
+#define SET_TX_DESC_MCSG4_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 16, 4, __val)
+#define SET_TX_DESC_MCSG5_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 20, 4, __val)
+#define SET_TX_DESC_MCSG6_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 24, 4, __val)
+#define SET_TX_DESC_MCS15_SGI_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 28, 4, __val)
+
+#define GET_TX_DESC_TX_BUFFER_SIZE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+28, 0, 16)
+#define GET_TX_DESC_MCSG4_MAX_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+28, 16, 4)
+#define GET_TX_DESC_MCSG5_MAX_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+28, 20, 4)
+#define GET_TX_DESC_MCSG6_MAX_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+28, 24, 4)
+#define GET_TX_DESC_MCS15_SGI_MAX_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+28, 28, 4)
+
+#define SET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32, 0, 32, __val)
+#define SET_TX_DESC_TX_BUFFER_ADDRESS64(__pdesc, __val) \
+	SET_BITS_TO_LE_4BYTE(__pdesc+36, 0, 32, __val)
+
+#define GET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+32, 0, 32)
+#define GET_TX_DESC_TX_BUFFER_ADDRESS64(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+36, 0, 32)
+
+#define SET_TX_DESC_NEXT_DESC_ADDRESS(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+40, 0, 32, __val)
+#define SET_TX_DESC_NEXT_DESC_ADDRESS64(__pdesc, __val) \
+	SET_BITS_TO_LE_4BYTE(__pdesc+44, 0, 32, __val)
+
+#define GET_TX_DESC_NEXT_DESC_ADDRESS(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+40, 0, 32)
+#define GET_TX_DESC_NEXT_DESC_ADDRESS64(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+44, 0, 32)
+
+#define GET_RX_DESC_PKT_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 0, 14)
+#define GET_RX_DESC_CRC32(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 14, 1)
+#define GET_RX_DESC_ICV(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 15, 1)
+#define GET_RX_DESC_DRV_INFO_SIZE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc, 16, 4)
+#define GET_RX_DESC_SECURITY(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 20, 3)
+#define GET_RX_DESC_QOS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 23, 1)
+#define GET_RX_DESC_SHIFT(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 24, 2)
+#define GET_RX_DESC_PHYST(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
+#define GET_RX_DESC_SWDEC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
+#define GET_RX_DESC_LS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
+#define GET_RX_DESC_FS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
+#define GET_RX_DESC_EOR(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
+#define GET_RX_DESC_OWN(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
+
+#define SET_RX_DESC_PKT_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 14, __val)
+#define SET_RX_DESC_EOR(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
+#define SET_RX_DESC_OWN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+#define GET_RX_DESC_MACID(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 0, 5)
+#define GET_RX_DESC_TID(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 5, 4)
+#define GET_RX_DESC_HWRSVD(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 9, 5)
+#define GET_RX_DESC_PAGGR(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
+#define GET_RX_DESC_FAGGR(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
+#define GET_RX_DESC_A1_FIT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
+#define GET_RX_DESC_A2_FIT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 20, 4)
+#define GET_RX_DESC_PAM(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 24, 1)
+#define GET_RX_DESC_PWR(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 25, 1)
+#define GET_RX_DESC_MD(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 26, 1)
+#define GET_RX_DESC_MF(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 27, 1)
+#define GET_RX_DESC_TYPE(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 28, 2)
+#define GET_RX_DESC_MC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 30, 1)
+#define GET_RX_DESC_BC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 31, 1)
+#define GET_RX_DESC_SEQ(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 0, 12)
+#define GET_RX_DESC_FRAG(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 12, 4)
+#define GET_RX_DESC_NEXT_PKT_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+8, 16, 14)
+#define GET_RX_DESC_NEXT_IND(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 30, 1)
+#define GET_RX_DESC_RSVD(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 31, 1)
+
+#define GET_RX_DESC_RXMCS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 0, 6)
+#define GET_RX_DESC_RXHT(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 6, 1)
+#define GET_RX_DESC_SPLCP(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 8, 1)
+#define GET_RX_DESC_BW(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 9, 1)
+#define GET_RX_DESC_HTC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 10, 1)
+#define GET_RX_DESC_HWPC_ERR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 14, 1)
+#define GET_RX_DESC_HWPC_IND(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 15, 1)
+#define GET_RX_DESC_IV0(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 16, 16)
+
+#define GET_RX_DESC_IV1(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+16, 0, 32)
+#define GET_RX_DESC_TSFL(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+20, 0, 32)
+
+#define GET_RX_DESC_BUFF_ADDR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 0, 32)
+#define GET_RX_DESC_BUFF_ADDR64(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+28, 0, 32)
+
+#define SET_RX_DESC_BUFF_ADDR(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 32, __val)
+#define SET_RX_DESC_BUFF_ADDR64(__pdesc, __val) \
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 32, __val)
+
+#define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)		\
+do {								\
+	if (_size > TX_DESC_NEXT_DESC_OFFSET)			\
+		memset(__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
+	else							\
+		memset(__pdesc, 0, _size);			\
+} while (0)
+
+#define RTL8723E_RX_HAL_IS_CCK_RATE(rxmcs)\
+	((rxmcs) == DESC92C_RATE1M ||\
+	 (rxmcs) == DESC92C_RATE2M ||\
+	 (rxmcs) == DESC92C_RATE5_5M ||\
+	 (rxmcs) == DESC92C_RATE11M)
+
+struct rx_fwinfo_8723e {
+	u8 gain_trsw[4];
+	u8 pwdb_all;
+	u8 cfosho[4];
+	u8 cfotail[4];
+	char rxevm[2];
+	char rxsnr[4];
+	u8 pdsnr[2];
+	u8 csi_current[2];
+	u8 csi_target[2];
+	u8 sigevm;
+	u8 max_ex_pwr;
+	u8 ex_intf_flag:1;
+	u8 sgi_en:1;
+	u8 rxsc:2;
+	u8 reserve:4;
+} __packed;
+
+struct tx_desc_8723e {
+	u32 pktsize:16;
+	u32 offset:8;
+	u32 bmc:1;
+	u32 htc:1;
+	u32 lastseg:1;
+	u32 firstseg:1;
+	u32 linip:1;
+	u32 noacm:1;
+	u32 gf:1;
+	u32 own:1;
+
+	u32 macid:5;
+	u32 agg_en:1;
+	u32 bk:1;
+	u32 rdg_en:1;
+	u32 queuesel:5;
+	u32 rd_nav_ext:1;
+	u32 lsig_txop_en:1;
+	u32 pifs:1;
+	u32 rateid:4;
+	u32 nav_usehdr:1;
+	u32 en_descid:1;
+	u32 sectype:2;
+	u32 pktoffset:8;
+
+	u32 rts_rc:6;
+	u32 data_rc:6;
+	u32 rsvd0:2;
+	u32 bar_retryht:2;
+	u32 rsvd1:1;
+	u32 morefrag:1;
+	u32 raw:1;
+	u32 ccx:1;
+	u32 ampdudensity:3;
+	u32 rsvd2:1;
+	u32 ant_sela:1;
+	u32 ant_selb:1;
+	u32 txant_cck:2;
+	u32 txant_l:2;
+	u32 txant_ht:2;
+
+	u32 nextheadpage:8;
+	u32 tailpage:8;
+	u32 seq:12;
+	u32 pktid:4;
+
+	u32 rtsrate:5;
+	u32 apdcfe:1;
+	u32 qos:1;
+	u32 hwseq_enable:1;
+	u32 userrate:1;
+	u32 dis_rtsfb:1;
+	u32 dis_datafb:1;
+	u32 cts2self:1;
+	u32 rts_en:1;
+	u32 hwrts_en:1;
+	u32 portid:1;
+	u32 rsvd3:3;
+	u32 waitdcts:1;
+	u32 cts2ap_en:1;
+	u32 txsc:2;
+	u32 stbc:2;
+	u32 txshort:1;
+	u32 txbw:1;
+	u32 rtsshort:1;
+	u32 rtsbw:1;
+	u32 rtssc:2;
+	u32 rtsstbc:2;
+
+	u32 txrate:6;
+	u32 shortgi:1;
+	u32 ccxt:1;
+	u32 txrate_fb_lmt:5;
+	u32 rtsrate_fb_lmt:4;
+	u32 retrylmt_en:1;
+	u32 txretrylmt:6;
+	u32 usb_txaggnum:8;
+
+	u32 txagca:5;
+	u32 txagcb:5;
+	u32 usemaxlen:1;
+	u32 maxaggnum:5;
+	u32 mcsg1maxlen:4;
+	u32 mcsg2maxlen:4;
+	u32 mcsg3maxlen:4;
+	u32 mcs7sgimaxlen:4;
+
+	u32 txbuffersize:16;
+	u32 mcsg4maxlen:4;
+	u32 mcsg5maxlen:4;
+	u32 mcsg6maxlen:4;
+	u32 mcsg15sgimaxlen:4;
+
+	u32 txbuffaddr;
+	u32 txbufferaddr64;
+	u32 nextdescaddress;
+	u32 nextdescaddress64;
+
+	u32 reserve_pass_pcie_mm_limit[4];
+} __packed;
+
+struct rx_desc_8723e {
+	u32 length:14;
+	u32 crc32:1;
+	u32 icverror:1;
+	u32 drv_infosize:4;
+	u32 security:3;
+	u32 qos:1;
+	u32 shift:2;
+	u32 phystatus:1;
+	u32 swdec:1;
+	u32 lastseg:1;
+	u32 firstseg:1;
+	u32 eor:1;
+	u32 own:1;
+
+	u32 macid:5;
+	u32 tid:4;
+	u32 hwrsvd:5;
+	u32 paggr:1;
+	u32 faggr:1;
+	u32 a1_fit:4;
+	u32 a2_fit:4;
+	u32 pam:1;
+	u32 pwr:1;
+	u32 moredata:1;
+	u32 morefrag:1;
+	u32 type:2;
+	u32 mc:1;
+	u32 bc:1;
+
+	u32 seq:12;
+	u32 frag:4;
+	u32 nextpktlen:14;
+	u32 nextind:1;
+	u32 rsvd:1;
+
+	u32 rxmcs:6;
+	u32 rxht:1;
+	u32 amsdu:1;
+	u32 splcp:1;
+	u32 bandwidth:1;
+	u32 htc:1;
+	u32 tcpchk_rpt:1;
+	u32 ipcchk_rpt:1;
+	u32 tcpchk_valid:1;
+	u32 hwpcerr:1;
+	u32 hwpcind:1;
+	u32 iv0:16;
+
+	u32 iv1;
+
+	u32 tsfl;
+
+	u32 bufferaddress;
+	u32 bufferaddress64;
+
+} __packed;
+
+void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
+			    struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			    struct ieee80211_tx_info *info,
+			    struct ieee80211_sta *sta,
+			    struct sk_buff *skb, u8 hw_queue,
+			    struct rtl_tcb_desc *ptcb_desc);
+bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
+			     struct rtl_stats *status,
+			     struct ieee80211_rx_status *rx_status,
+			     u8 *pdesc, struct sk_buff *skb);
+void rtl8723ae_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val);
+u32 rtl8723ae_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+void rtl8723ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
+void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
+			       bool b_firstseg, bool b_lastseg,
+			       struct sk_buff *skb);
+
+#endif
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
