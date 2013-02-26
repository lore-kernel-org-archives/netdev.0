From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 22/27] rtlwifi: rtl8188ee: Add files for new driver - part 13
Date: Mon, 25 Feb 2013 18:13:34 -0600
Message-ID: <1361837619-2985-23-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:53978 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932280Ab3BZAOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:46 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c | 984 +++++++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h | 797 ++++++++++++++++++++++
 2 files changed, 1781 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
new file mode 100644
index 0000000..2540a93
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -0,0 +1,984 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2013  Realtek Corporation.
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
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
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
+#include "dm.h"
+#include "phy.h"
+
+static u8 _rtl88ee_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
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
+static int _rtl88ee_rate_mapping(struct ieee80211_hw *hw,
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
+static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
+			struct rtl_stats *pstatus, u8 *pdesc,
+			struct rx_fwinfo_88e *p_drvinfo,
+			bool bpacket_match_bssid,
+			bool bpacket_toself, bool packet_beacon)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
+	struct phy_sts_cck_8192s_t *cck_buf;
+	struct phy_status_rpt *phystrpt = (struct phy_status_rpt *)p_drvinfo;
+	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
+	char rx_pwr_all = 0, rx_pwr[4];
+	u8 rf_rx_num = 0, evm, pwdb_all;
+	u8 i, max_spatial_stream;
+	u32 rssi, total_rssi = 0;
+	bool is_cck = pstatus->is_cck;
+	u8 lan_idx, vga_idx;
+
+	/* Record it for next packet processing */
+	pstatus->packet_matchbssid = bpacket_match_bssid;
+	pstatus->packet_toself = bpacket_toself;
+	pstatus->packet_beacon = packet_beacon;
+	pstatus->rx_mimo_sig_qual[0] = -1;
+	pstatus->rx_mimo_sig_qual[1] = -1;
+
+	if (is_cck) {
+		u8 cck_highpwr;
+		u8 cck_agc_rpt;
+		/* CCK Driver info Structure is not the same as OFDM packet. */
+		cck_buf = (struct phy_sts_cck_8192s_t *)p_drvinfo;
+		cck_agc_rpt = cck_buf->cck_agc_rpt;
+
+		/* (1)Hardware does not provide RSSI for CCK
+		 * (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive)
+		 */
+		if (ppsc->rfpwr_state == ERFON)
+			cck_highpwr = rtl_get_bbreg(hw,
+						    RFPGA0_XA_HSSIPARAMETER2,
+						    BIT(9));
+		else
+			cck_highpwr = false;
+
+		lan_idx = ((cck_agc_rpt & 0xE0) >> 5);
+		vga_idx = (cck_agc_rpt & 0x1f);
+		switch (lan_idx) {
+		case 7:
+			if (vga_idx <= 27)
+				rx_pwr_all = -100 + 2*(27-vga_idx);
+			else
+				rx_pwr_all = -100;
+			break;
+		case 6:
+			rx_pwr_all = -48 + 2*(2-vga_idx); /*VGA_idx = 2~0*/
+			break;
+		case 5:
+			rx_pwr_all = -42 + 2*(7-vga_idx); /*VGA_idx = 7~5*/
+			break;
+		case 4:
+			rx_pwr_all = -36 + 2*(7-vga_idx); /*VGA_idx = 7~4*/
+			break;
+		case 3:
+			rx_pwr_all = -24 + 2*(7-vga_idx); /*VGA_idx = 7~0*/
+			break;
+		case 2:
+			if (cck_highpwr)
+				rx_pwr_all = -12 + 2*(5-vga_idx);
+			else
+				rx_pwr_all = -6 + 2*(5-vga_idx);
+			break;
+		case 1:
+			rx_pwr_all = 8-2*vga_idx;
+			break;
+		case 0:
+			rx_pwr_all = 14-2*vga_idx;
+			break;
+		default:
+			break;
+		}
+		rx_pwr_all += 6;
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
+		/* CCK gain is smaller than OFDM/MCS gain,
+		 * so we add gain diff by experiences,
+		 * the val is 6
+		 */
+		pwdb_all += 6;
+		if (pwdb_all > 100)
+			pwdb_all = 100;
+		/* modify the offset to make the same
+		 * gain index with OFDM.
+		 */
+		if (pwdb_all > 34 && pwdb_all <= 42)
+			pwdb_all -= 2;
+		else if (pwdb_all > 26 && pwdb_all <= 34)
+			pwdb_all -= 6;
+		else if (pwdb_all > 14 && pwdb_all <= 26)
+			pwdb_all -= 8;
+		else if (pwdb_all > 4 && pwdb_all <= 14)
+			pwdb_all -= 4;
+		if (cck_highpwr == false) {
+			if (pwdb_all >= 80)
+				pwdb_all = ((pwdb_all-80)<<1) +
+					   ((pwdb_all-80)>>1)+80;
+			else if ((pwdb_all <= 78) && (pwdb_all >= 20))
+				pwdb_all += 3;
+			if (pwdb_all > 100)
+				pwdb_all = 100;
+		}
+
+		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->recvsignalpower = rx_pwr_all;
+
+		/* (3) Get Signal Quality (EVM) */
+		if (bpacket_match_bssid) {
+			u8 sq;
+
+			if (pstatus->rx_pwdb_all > 40) {
+				sq = 100;
+			} else {
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
+			pstatus->rx_mimo_sig_qual[0] = sq;
+			pstatus->rx_mimo_sig_qual[1] = -1;
+		}
+	} else {
+		rtlpriv->dm.rfpath_rxenable[0] =
+		    rtlpriv->dm.rfpath_rxenable[1] = true;
+
+		/* (1)Get RSSI for HT rate */
+		for (i = RF90_PATH_A; i < RF6052_MAX_PATH; i++) {
+			/* we will judge RF RX path now. */
+			if (rtlpriv->dm.rfpath_rxenable[i])
+				rf_rx_num++;
+
+			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f) * 2)-110;
+
+			/* Translate DBM to percentage. */
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
+			total_rssi += rssi;
+
+			/* Get Rx snr value in DB */
+			rtlpriv->stats.rx_snr_db[i] = p_drvinfo->rxsnr[i] / 2;
+
+			/* Record Signal Strength for next packet */
+			if (bpacket_match_bssid)
+				pstatus->rx_mimo_signalstrength[i] = (u8) rssi;
+		}
+
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive)
+		 */
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
+				 * spatial stream only
+				 */
+				if (i == 0)
+					pstatus->signalquality = evm & 0xff;
+				pstatus->rx_mimo_sig_qual[i] = evm & 0xff;
+			}
+		}
+	}
+
+	/* UI BSS List signal strength(in percentage),
+	 * make it good looking, from 0~100.
+	 */
+	if (is_cck)
+		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
+			pwdb_all));
+	else if (rf_rx_num != 0)
+		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
+			total_rssi /= rf_rx_num));
+	/*HW antenna diversity*/
+	rtldm->fat_table.antsel_rx_keep_0 = phystrpt->ant_sel;
+	rtldm->fat_table.antsel_rx_keep_1 = phystrpt->ant_sel_b;
+	rtldm->fat_table.antsel_rx_keep_2 = phystrpt->antsel_rx_keep_2;
+}
+
+static void _rtl88ee_smart_antenna(struct ieee80211_hw *hw,
+	struct rtl_stats *pstatus)
+{
+	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u8 antsel_tr_mux;
+	struct fast_ant_training *pfat = &(rtldm->fat_table);
+
+	if (rtlefuse->antenna_div_type == CG_TRX_SMART_ANTDIV) {
+		if (pfat->fat_state == FAT_TRAINING_STATE) {
+			if (pstatus->packet_toself) {
+				antsel_tr_mux = (pfat->antsel_rx_keep_2 << 2) |
+					(pfat->antsel_rx_keep_1 << 1) |
+					 pfat->antsel_rx_keep_0;
+				pfat->ant_sum[antsel_tr_mux] +=
+					 pstatus->rx_pwdb_all;
+				pfat->ant_cnt[antsel_tr_mux]++;
+			}
+		}
+	} else if ((rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV) ||
+	(rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)) {
+		if (pstatus->packet_toself || pstatus->packet_matchbssid) {
+			antsel_tr_mux = (pfat->antsel_rx_keep_2 << 2) |
+					(pfat->antsel_rx_keep_1 << 1) |
+					 pfat->antsel_rx_keep_0;
+			rtl88e_dm_ant_sel_statistics(hw, antsel_tr_mux, 0,
+						     pstatus->rx_pwdb_all);
+		}
+	}
+}
+
+static void _rtl88ee_translate_rx_signal_stuff(struct ieee80211_hw *hw,
+		struct sk_buff *skb, struct rtl_stats *pstatus,
+		u8 *pdesc, struct rx_fwinfo_88e *p_drvinfo)
+{
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct ieee80211_hdr *hdr;
+	u8 *tmp_buf;
+	u8 *praddr;
+	u8 *psaddr;
+	__le16 fc;
+	u16 type, ufc;
+	bool packet_matchbssid, packet_toself, packet_beacon;
+
+	tmp_buf = skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
+
+	hdr = (struct ieee80211_hdr *)tmp_buf;
+	fc = hdr->frame_control;
+	ufc = le16_to_cpu(fc);
+	type = WLAN_FC_GET_TYPE(fc);
+	praddr = hdr->addr1;
+	psaddr = ieee80211_get_SA(hdr);
+	memcpy(pstatus->psaddr, psaddr, ETH_ALEN);
+
+	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
+	     (!compare_ether_addr(mac->bssid, (ufc & IEEE80211_FCTL_TODS) ?
+				  hdr->addr1 : (ufc & IEEE80211_FCTL_FROMDS) ?
+				  hdr->addr2 : hdr->addr3)) &&
+				  (!pstatus->hwerror) &&
+				  (!pstatus->crc) && (!pstatus->icv));
+
+	packet_toself = packet_matchbssid &&
+	    (!compare_ether_addr(praddr, rtlefuse->dev_addr));
+
+	if (ieee80211_is_beacon(fc))
+		packet_beacon = true;
+
+	_rtl88ee_query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
+				   packet_matchbssid, packet_toself,
+				   packet_beacon);
+	_rtl88ee_smart_antenna(hw, pstatus);
+	rtl_process_phyinfo(hw, tmp_buf, pstatus);
+}
+
+static void _rtl88ee_insert_emcontent(struct rtl_tcb_desc *ptcb_desc,
+				      u8 *virtualaddress)
+{
+	u32 dwtmp = 0;
+	memset(virtualaddress, 0, 8);
+
+	SET_EARLYMODE_PKTNUM(virtualaddress, ptcb_desc->empkt_num);
+	if (ptcb_desc->empkt_num == 1) {
+		dwtmp = ptcb_desc->empkt_len[0];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[0];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[1];
+	}
+	SET_EARLYMODE_LEN0(virtualaddress, dwtmp);
+
+	if (ptcb_desc->empkt_num <= 3) {
+		dwtmp = ptcb_desc->empkt_len[2];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[2];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[3];
+	}
+	SET_EARLYMODE_LEN1(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <= 5) {
+		dwtmp = ptcb_desc->empkt_len[4];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[4];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[5];
+	}
+	SET_EARLYMODE_LEN2_1(virtualaddress, dwtmp & 0xF);
+	SET_EARLYMODE_LEN2_2(virtualaddress, dwtmp >> 4);
+	if (ptcb_desc->empkt_num <= 7) {
+		dwtmp = ptcb_desc->empkt_len[6];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[6];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[7];
+	}
+	SET_EARLYMODE_LEN3(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <= 9) {
+		dwtmp = ptcb_desc->empkt_len[8];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[8];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[9];
+	}
+	SET_EARLYMODE_LEN4(virtualaddress, dwtmp);
+}
+
+bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
+			   struct rtl_stats *status,
+			   struct ieee80211_rx_status *rx_status,
+			   u8 *pdesc, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rx_fwinfo_88e *p_drvinfo;
+	struct ieee80211_hdr *hdr;
+
+	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
+	status->packet_report_type = (u8)GET_RX_STATUS_DESC_RPT_SEL(pdesc);
+	if (status->packet_report_type == TX_REPORT2)
+		status->length = (u16) GET_RX_RPT2_DESC_PKT_LEN(pdesc);
+	else
+		status->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
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
+	status->isfirst_ampdu = (bool) ((GET_RX_DESC_PAGGR(pdesc) == 1) &&
+					(GET_RX_DESC_FAGGR(pdesc) == 1));
+	if (status->packet_report_type == NORMAL_RX)
+		status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
+	status->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
+	status->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
+
+	status->is_cck = RTL8188_RX_HAL_IS_CCK_RATE(status->rate);
+
+	status->macid = GET_RX_DESC_MACID(pdesc);
+	if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
+		status->wake_match = BIT(2);
+	else if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
+		status->wake_match = BIT(1);
+	else if (GET_RX_STATUS_DESC_UNICAST_MATCH(pdesc))
+		status->wake_match = BIT(0);
+	else
+		status->wake_match = 0;
+	if (status->wake_match)
+		RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD,
+			 "GGGGGGGGGGGGGet Wakeup Packet!! WakeMatch =%d\n",
+			 status->wake_match);
+	rx_status->freq = hw->conf.channel->center_freq;
+	rx_status->band = hw->conf.channel->band;
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
+	rx_status->flag |= RX_FLAG_MACTIME_START;
+
+	/* hw will set status->decrypted true, if it finds the
+	 * frame is open data frame or mgmt frame.
+	 * So hw will not decryption robust managment frame
+	 * for IEEE80211w but still set status->decrypted
+	 * true, so here we should set it back to undecrypted
+	 * for IEEE80211w frame, and mac80211 sw will help
+	 * to decrypt it
+	 */
+	if (status->decrypted) {
+		hdr = (struct ieee80211_hdr *)(skb->data +
+		       status->rx_drvinfo_size + status->rx_bufshift);
+
+		if (!hdr) {
+			/* During testing, hdr was NULL */
+			return false;
+		}
+		if ((ieee80211_is_robust_mgmt_frame(hdr)) &&
+		    (ieee80211_has_protected(hdr->frame_control)))
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag |= RX_FLAG_DECRYPTED;
+	}
+
+	/* rate_idx: index of data rate into band's
+	 * supported rates or MCS index if HT rates
+	 * are use (RX_FLAG_HT)
+	 * Notice: this is diff with windows define
+	 */
+	rx_status->rate_idx = _rtl88ee_rate_mapping(hw, status->is_ht,
+						    status->rate);
+
+	rx_status->mactime = status->timestamp_low;
+	if (phystatus == true) {
+		p_drvinfo = (struct rx_fwinfo_88e *)(skb->data +
+						     status->rx_bufshift);
+
+		_rtl88ee_translate_rx_signal_stuff(hw,
+						   skb, status, pdesc,
+						   p_drvinfo);
+	}
+
+	/*rx_status->qual = status->signal; */
+	rx_status->signal = status->recvsignalpower + 10;
+	/*rx_status->noise = -status->noise; */
+	if (status->packet_report_type == TX_REPORT2) {
+		status->macid_valid_entry[0] =
+			 GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
+		status->macid_valid_entry[1] =
+			 GET_RX_RPT2_DESC_MACID_VALID_2(pdesc);
+	}
+	return true;
+}
+
+void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
+			  struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			  struct ieee80211_tx_info *info,
+			  struct ieee80211_sta *sta,
+			  struct sk_buff *skb,
+			  u8 hw_queue, struct rtl_tcb_desc *ptcb_desc)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 *pdesc = (u8 *)pdesc_tx;
+	u16 seq_number;
+	__le16 fc = hdr->frame_control;
+	unsigned int buf_len = 0;
+	unsigned int skb_len = skb->len;
+	u8 fw_qsel = _rtl88ee_map_hwqueue_to_fwqueue(skb, hw_queue);
+	bool firstseg = ((hdr->seq_ctrl &
+			    cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
+	bool lastseg = ((hdr->frame_control &
+			   cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
+	dma_addr_t mapping;
+	u8 bw_40 = 0;
+	u8 short_gi = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_STATION) {
+		bw_40 = mac->bw_40;
+	} else if (mac->opmode == NL80211_IFTYPE_AP ||
+		mac->opmode == NL80211_IFTYPE_ADHOC) {
+		if (sta)
+			bw_40 = sta->ht_cap.cap &
+				IEEE80211_HT_CAP_SUP_WIDTH_20_40;
+	}
+	seq_number = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
+	rtl_get_tcb_desc(hw, info, sta, skb, ptcb_desc);
+	/* reserve 8 byte for AMPDU early mode */
+	if (rtlhal->earlymode_enable) {
+		skb_push(skb, EM_HDR_LEN);
+		memset(skb->data, 0, EM_HDR_LEN);
+	}
+	buf_len = skb->len;
+	mapping = pci_map_single(rtlpci->pdev, skb->data, skb->len,
+				 PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_88e));
+	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
+		firstseg = true;
+		lastseg = true;
+	}
+	if (firstseg) {
+		if (rtlhal->earlymode_enable) {
+			SET_TX_DESC_PKT_OFFSET(pdesc, 1);
+			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN +
+					   EM_HDR_LEN);
+			if (ptcb_desc->empkt_num) {
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+					 "Insert 8 byte.pTcb->EMPktNum:%d\n",
+					 ptcb_desc->empkt_num);
+				_rtl88ee_insert_emcontent(ptcb_desc,
+							  (u8 *)(skb->data));
+			}
+		} else {
+			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+		}
+
+		ptcb_desc->use_driver_rate = true;
+		SET_TX_DESC_TX_RATE(pdesc, ptcb_desc->hw_rate);
+		if (ptcb_desc->hw_rate > DESC92C_RATEMCS0)
+			short_gi = (ptcb_desc->use_shortgi) ? 1 : 0;
+		else
+			short_gi = (ptcb_desc->use_shortpreamble) ? 1 : 0;
+		SET_TX_DESC_DATA_SHORTGI(pdesc, short_gi);
+
+		if (info->flags & IEEE80211_TX_CTL_AMPDU) {
+			SET_TX_DESC_AGG_ENABLE(pdesc, 1);
+			SET_TX_DESC_MAX_AGG_NUM(pdesc, 0x14);
+		}
+		SET_TX_DESC_SEQ(pdesc, seq_number);
+		SET_TX_DESC_RTS_ENABLE(pdesc, ((ptcb_desc->rts_enable &&
+					      !ptcb_desc->cts_enable) ? 1 : 0));
+		SET_TX_DESC_HW_RTS_ENABLE(pdesc, 0);
+		SET_TX_DESC_CTS2SELF(pdesc, ((ptcb_desc->cts_enable) ? 1 : 0));
+		SET_TX_DESC_RTS_STBC(pdesc, ((ptcb_desc->rts_stbc) ? 1 : 0));
+
+		SET_TX_DESC_RTS_RATE(pdesc, ptcb_desc->rts_rate);
+		SET_TX_DESC_RTS_BW(pdesc, 0);
+		SET_TX_DESC_RTS_SC(pdesc, ptcb_desc->rts_sc);
+		SET_TX_DESC_RTS_SHORT(pdesc,
+			((ptcb_desc->rts_rate <= DESC92C_RATE54M) ?
+			(ptcb_desc->rts_use_shortpreamble ? 1 : 0) :
+			(ptcb_desc->rts_use_shortgi ? 1 : 0)));
+
+		if (ptcb_desc->btx_enable_sw_calc_duration)
+			SET_TX_DESC_NAV_USE_HDR(pdesc, 1);
+
+		if (bw_40) {
+			if (ptcb_desc->packet_bw) {
+				SET_TX_DESC_DATA_BW(pdesc, 1);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc, 3);
+			} else {
+				SET_TX_DESC_DATA_BW(pdesc, 0);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc,
+						   mac->cur_40_prime_sc);
+			}
+		} else {
+			SET_TX_DESC_DATA_BW(pdesc, 0);
+			SET_TX_DESC_TX_SUB_CARRIER(pdesc, 0);
+		}
+
+		SET_TX_DESC_LINIP(pdesc, 0);
+		SET_TX_DESC_PKT_SIZE(pdesc, (u16) skb_len);
+		if (sta) {
+			u8 ampdu_density = sta->ht_cap.ampdu_density;
+			SET_TX_DESC_AMPDU_DENSITY(pdesc, ampdu_density);
+		}
+		if (info->control.hw_key) {
+			struct ieee80211_key_conf *keyconf;
+			keyconf = info->control.hw_key;
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
+		SET_TX_DESC_QUEUE_SEL(pdesc, fw_qsel);
+		SET_TX_DESC_DATA_RATE_FB_LIMIT(pdesc, 0x1F);
+		SET_TX_DESC_RTS_RATE_FB_LIMIT(pdesc, 0xF);
+		SET_TX_DESC_DISABLE_FB(pdesc, ptcb_desc->disable_ratefallback ?
+				       1 : 0);
+		SET_TX_DESC_USE_RATE(pdesc, ptcb_desc->use_driver_rate ? 1 : 0);
+
+		/* Set TxRate and RTSRate in TxDesc  */
+		/* This prevent Tx initial rate of new-coming packets */
+		/* from being overwritten by retried  packet rate.*/
+		if (!ptcb_desc->use_driver_rate) {
+			/*SET_TX_DESC_RTS_RATE(pdesc, 0x08); */
+			/* SET_TX_DESC_TX_RATE(pdesc, 0x0b); */
+		}
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
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16) buf_len);
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+	if (rtlpriv->dm.useramask) {
+		SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
+	} else {
+		SET_TX_DESC_RATE_ID(pdesc, 0xC + ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->ratr_index);
+	}
+	if (ieee80211_is_data_qos(fc))
+		SET_TX_DESC_QOS(pdesc, 1);
+
+	if (!ieee80211_is_data_qos(fc))
+		SET_TX_DESC_HWSEQ_EN(pdesc, 1);
+	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
+	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
+	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
+		SET_TX_DESC_BMC(pdesc, 1);
+	}
+
+	rtl88e_dm_set_tx_ant_by_tx_info(hw, pdesc, ptcb_desc->mac_id);
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
+}
+
+void rtl88ee_tx_fill_cmddesc(struct ieee80211_hw *hw,
+			     u8 *pdesc, bool firstseg,
+			     bool lastseg, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u8 fw_queue = QSLT_BEACON;
+
+	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
+					    skb->data, skb->len,
+					    PCI_DMA_TODEVICE);
+
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)(skb->data);
+	__le16 fc = hdr->frame_control;
+
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
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
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+
+	SET_TX_DESC_RATE_ID(pdesc, 7);
+	SET_TX_DESC_MACID(pdesc, 0);
+
+	SET_TX_DESC_OWN(pdesc, 1);
+
+	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_OFFSET(pdesc, 0x20);
+
+	SET_TX_DESC_USE_RATE(pdesc, 1);
+
+	if (!ieee80211_is_data_qos(fc))
+		SET_TX_DESC_HWSEQ_EN(pdesc, 1);
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "H2C Tx Cmd Content\n",
+		      pdesc, TX_DESC_SIZE);
+}
+
+void rtl88ee_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
+{
+	if (istx == true) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			SET_TX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_TX_NEXTDESC_ADDR:
+			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *)val);
+			break;
+		default:
+			RT_ASSERT(false, "ERR txdesc :%d not processed\n",
+				  desc_name);
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_RXOWN:
+			SET_RX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_RXBUFF_ADDR:
+			SET_RX_DESC_BUFF_ADDR(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			SET_RX_DESC_PKT_LEN(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_RXERO:
+			SET_RX_DESC_EOR(pdesc, 1);
+			break;
+		default:
+			RT_ASSERT(false, "ERR rxdesc :%d not processed\n",
+				  desc_name);
+			break;
+		}
+	}
+}
+
+u32 rtl88ee_get_desc(u8 *pdesc, bool istx, u8 desc_name)
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
+			RT_ASSERT(false, "ERR txdesc :%d not processed\n",
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
+			RT_ASSERT(false, "ERR rxdesc :%d not processed\n",
+				  desc_name);
+			break;
+		}
+	}
+	return ret;
+}
+
+void rtl88ee_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	if (hw_queue == BEACON_QUEUE) {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG, BIT(4));
+	} else {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG,
+			       BIT(0) << (hw_queue));
+	}
+}
+
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
new file mode 100644
index 0000000..03cb8c3
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
@@ -0,0 +1,797 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2013  Realtek Corporation.
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
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92CE_TRX_H__
+#define __RTL92CE_TRX_H__
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
+#define SET_TX_DESC_BMC(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 24, 1, __val)
+#define SET_TX_DESC_HTC(__pdesc, __val)			\
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
+#define SET_TX_DESC_OWN(__pdesc, __val)			\
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
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 0, 6, __val)
+#define SET_TX_DESC_QUEUE_SEL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 8, 5, __val)
+#define SET_TX_DESC_RDG_NAV_EXT(__pdesc, __val)		\
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
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 26, 5, __val)
+#define SET_TX_DESC_PADDING_LEN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 24, 8, __val)
+
+#define GET_TX_DESC_MACID(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 0, 5)
+#define GET_TX_DESC_AGG_ENABLE(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 5, 1)
+#define GET_TX_DESC_AGG_BREAK(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 6, 1)
+#define GET_TX_DESC_RDG_ENABLE(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 7, 1)
+#define GET_TX_DESC_QUEUE_SEL(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 8, 5)
+#define GET_TX_DESC_RDG_NAV_EXT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 13, 1)
+#define GET_TX_DESC_LSIG_TXOP_EN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
+#define GET_TX_DESC_PIFS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
+#define GET_TX_DESC_RATE_ID(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
+#define GET_TX_DESC_NAV_USE_HDR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 20, 1)
+#define GET_TX_DESC_EN_DESC_ID(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 21, 1)
+#define GET_TX_DESC_SEC_TYPE(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 22, 2)
+#define GET_TX_DESC_PKT_OFFSET(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 24, 8)
+
+#define SET_TX_DESC_RTS_RC(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 0, 6, __val)
+#define SET_TX_DESC_DATA_RC(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 6, 6, __val)
+#define SET_TX_DESC_AGG_ENABLE(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 12, 1, __val)
+#define SET_TX_DESC_RDG_ENABLE(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 13, 1, __val)
+#define SET_TX_DESC_BAR_RTY_TH(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 14, 2, __val)
+#define SET_TX_DESC_AGG_BREAK(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 16, 1, __val)
+#define SET_TX_DESC_MORE_FRAG(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 17, 1, __val)
+#define SET_TX_DESC_RAW(__pdesc, __val)				\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 18, 1, __val)
+#define SET_TX_DESC_CCX(__pdesc, __val)				\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 19, 1, __val)
+#define SET_TX_DESC_AMPDU_DENSITY(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 20, 3, __val)
+#define SET_TX_DESC_BT_INT(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 23, 1, __val)
+#define SET_TX_DESC_ANTSEL_A(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 24, 1, __val)
+#define SET_TX_DESC_ANTSEL_B(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 25, 1, __val)
+#define SET_TX_DESC_TX_ANT_CCK(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 26, 2, __val)
+#define SET_TX_DESC_TX_ANTL(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 28, 2, __val)
+#define SET_TX_DESC_TX_ANT_HT(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 30, 2, __val)
+
+#define GET_TX_DESC_RTS_RC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 0, 6)
+#define GET_TX_DESC_DATA_RC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 6, 6)
+#define GET_TX_DESC_BAR_RTY_TH(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 14, 2)
+#define GET_TX_DESC_MORE_FRAG(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 17, 1)
+#define GET_TX_DESC_RAW(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 18, 1)
+#define GET_TX_DESC_CCX(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 19, 1)
+#define GET_TX_DESC_AMPDU_DENSITY(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 20, 3)
+#define GET_TX_DESC_ANTSEL_A(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 24, 1)
+#define GET_TX_DESC_ANTSEL_B(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 25, 1)
+#define GET_TX_DESC_TX_ANT_CCK(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 26, 2)
+#define GET_TX_DESC_TX_ANTL(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 28, 2)
+#define GET_TX_DESC_TX_ANT_HT(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 30, 2)
+
+#define SET_TX_DESC_NEXT_HEAP_PAGE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 0, 8, __val)
+#define SET_TX_DESC_TAIL_PAGE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 8, 8, __val)
+#define SET_TX_DESC_SEQ(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 16, 12, __val)
+#define SET_TX_DESC_CPU_HANDLE(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 28, 1, __val)
+#define SET_TX_DESC_TAG1(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 29, 1, __val)
+#define SET_TX_DESC_TRIGGER_INT(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 30, 1, __val)
+#define SET_TX_DESC_HWSEQ_EN(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 31, 1, __val)
+
+
+#define GET_TX_DESC_NEXT_HEAP_PAGE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 0, 8)
+#define GET_TX_DESC_TAIL_PAGE(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 8, 8)
+#define GET_TX_DESC_SEQ(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc+12, 16, 12)
+
+
+#define SET_TX_DESC_RTS_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 5, __val)
+#define SET_TX_DESC_AP_DCFE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 5, 1, __val)
+#define SET_TX_DESC_QOS(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 6, 1, __val)
+#define SET_TX_DESC_HWSEQ_SSN(__pdesc, __val)		\
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
+#define SET_TX_DESC_PWR_STATUS(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 15, 3, __val)
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
+#define GET_TX_DESC_DISABLE_FB(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 10, 1)
+#define GET_TX_DESC_CTS2SELF(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 11, 1)
+#define GET_TX_DESC_RTS_ENABLE(__pdesc)			\
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
+#define GET_TX_DESC_DATA_SHORT(__pdesc)			\
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
+#define GET_TX_DESC_DATA_RATE_FB_LIMIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 8, 5)
+#define GET_TX_DESC_RTS_RATE_FB_LIMIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 13, 4)
+#define GET_TX_DESC_RETRY_LIMIT_ENABLE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 17, 1)
+#define GET_TX_DESC_DATA_RETRY_LIMIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 18, 6)
+#define GET_TX_DESC_USB_TXAGG_NUM(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+20, 24, 8)
+
+#define SET_TX_DESC_TXAGC_A(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 5, __val)
+#define SET_TX_DESC_TXAGC_B(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 5, 5, __val)
+#define SET_TX_DESC_USE_MAX_LEN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 10, 1, __val)
+#define SET_TX_DESC_MAX_AGG_NUM(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 11, 5, __val)
+#define SET_TX_DESC_MCSG1_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 16, 4, __val)
+#define SET_TX_DESC_MCSG2_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 20, 4, __val)
+#define SET_TX_DESC_MCSG3_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 24, 4, __val)
+#define SET_TX_DESC_MCS7_SGI_MAX_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 28, 4, __val)
+
+#define GET_TX_DESC_TXAGC_A(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 0, 5)
+#define GET_TX_DESC_TXAGC_B(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 5, 5)
+#define GET_TX_DESC_USE_MAX_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+24, 10, 1)
+#define GET_TX_DESC_MAX_AGG_NUM(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+24, 11, 5)
+#define GET_TX_DESC_MCSG1_MAX_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+24, 16, 4)
+#define GET_TX_DESC_MCSG2_MAX_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+24, 20, 4)
+#define GET_TX_DESC_MCSG3_MAX_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+24, 24, 4)
+#define GET_TX_DESC_MCS7_SGI_MAX_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+24, 28, 4)
+
+#define SET_TX_DESC_TX_BUFFER_SIZE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 16, __val)
+#define SET_TX_DESC_SW_OFFSET30(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 16, 8, __val)
+#define SET_TX_DESC_SW_OFFSET31(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 24, 4, __val)
+#define SET_TX_DESC_ANTSEL_C(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 29, 1, __val)
+#define SET_TX_DESC_NULL_0(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 30, 1, __val)
+#define SET_TX_DESC_NULL_1(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 30, 1, __val)
+
+#define GET_TX_DESC_TX_BUFFER_SIZE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+28, 0, 16)
+
+
+#define SET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32, 0, 32, __val)
+#define SET_TX_DESC_TX_BUFFER_ADDRESS64(__pdesc, __val) \
+	SET_BITS_TO_LE_4BYTE(__pdesc+36, 0, 32, __val)
+
+#define GET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+32, 0, 32)
+#define GET_TX_DESC_TX_BUFFER_ADDRESS64(__pdesc)	\
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
+#define GET_RX_DESC_CRC32(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 14, 1)
+#define GET_RX_DESC_ICV(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 15, 1)
+#define GET_RX_DESC_DRV_INFO_SIZE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc, 16, 4)
+#define GET_RX_DESC_SECURITY(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 20, 3)
+#define GET_RX_DESC_QOS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 23, 1)
+#define GET_RX_DESC_SHIFT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 24, 2)
+#define GET_RX_DESC_PHYST(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
+#define GET_RX_DESC_SWDEC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
+#define GET_RX_DESC_LS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
+#define GET_RX_DESC_FS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
+#define GET_RX_DESC_EOR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
+#define GET_RX_DESC_OWN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
+
+#define SET_RX_DESC_PKT_LEN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 14, __val)
+#define SET_RX_DESC_EOR(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
+#define SET_RX_DESC_OWN(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+#define GET_RX_DESC_MACID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 0, 6)
+#define GET_RX_DESC_PAGGR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
+#define GET_RX_DESC_FAGGR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
+#define GET_RX_DESC_A1_FIT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
+#define GET_RX_DESC_A2_FIT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 20, 4)
+#define GET_RX_DESC_PAM(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 24, 1)
+#define GET_RX_DESC_PWR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 25, 1)
+#define GET_RX_DESC_MD(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 26, 1)
+#define GET_RX_DESC_MF(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 27, 1)
+#define GET_RX_DESC_TYPE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 28, 2)
+#define GET_RX_DESC_MC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 30, 1)
+#define GET_RX_DESC_BC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 31, 1)
+#define GET_RX_DESC_SEQ(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 0, 12)
+#define GET_RX_DESC_FRAG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 12, 4)
+
+
+#define GET_RX_DESC_RXMCS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 0, 6)
+#define GET_RX_DESC_RXHT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 6, 1)
+#define GET_RX_STATUS_DESC_RX_GF(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 7, 1)
+#define GET_RX_DESC_SPLCP(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 8, 1)
+#define GET_RX_DESC_BW(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 9, 1)
+#define GET_RX_DESC_HTC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 10, 1)
+#define GET_RX_STATUS_DESC_EOSP(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 11, 1)
+#define GET_RX_STATUS_DESC_BSSID_FIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 12, 2)
+#define GET_RX_STATUS_DESC_RPT_SEL(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 14, 2)
+
+#define GET_RX_STATUS_DESC_PATTERN_MATCH(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+12, 29, 1)
+#define GET_RX_STATUS_DESC_UNICAST_MATCH(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+12, 30, 1)
+#define GET_RX_STATUS_DESC_MAGIC_MATCH(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 31, 1)
+
+#define GET_RX_DESC_IV1(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+16, 0, 32)
+#define GET_RX_DESC_TSFL(__pdesc)			\
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
+
+/* TX report 2 format in Rx desc*/
+
+#define GET_RX_RPT2_DESC_PKT_LEN(__status)	\
+	LE_BITS_TO_4BYTE(__status, 0, 9)
+#define GET_RX_RPT2_DESC_MACID_VALID_1(__status)	\
+	LE_BITS_TO_4BYTE(__status+16, 0, 32)
+#define GET_RX_RPT2_DESC_MACID_VALID_2(__status)	\
+	LE_BITS_TO_4BYTE(__status+20, 0, 32)
+
+#define SET_EARLYMODE_PKTNUM(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 0, 4, __value)
+#define SET_EARLYMODE_LEN0(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 4, 12, __value)
+#define SET_EARLYMODE_LEN1(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 16, 12, __value)
+#define SET_EARLYMODE_LEN2_1(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 28, 4, __value)
+#define SET_EARLYMODE_LEN2_2(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr+4, 0, 8, __value)
+#define SET_EARLYMODE_LEN3(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr+4, 8, 12, __value)
+#define SET_EARLYMODE_LEN4(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr+4, 20, 12, __value)
+
+#define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)		\
+do {								\
+	if (_size > TX_DESC_NEXT_DESC_OFFSET)			\
+		memset(__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
+	else							\
+		memset(__pdesc, 0, _size);			\
+} while (0)
+
+#define RTL8188_RX_HAL_IS_CCK_RATE(rxmcs)\
+	(rxmcs == DESC92C_RATE1M ||\
+	 rxmcs == DESC92C_RATE2M ||\
+	 rxmcs == DESC92C_RATE5_5M ||\
+	 rxmcs == DESC92C_RATE11M)
+
+struct phy_rx_agc_info_t {
+	#if __LITTLE_ENDIAN
+		u8	gain:7, trsw:1;
+	#else
+		u8	trsw:1, gain:7;
+	#endif
+};
+struct phy_status_rpt {
+	struct phy_rx_agc_info_t path_agc[2];
+	u8	ch_corr[2];
+	u8	cck_sig_qual_ofdm_pwdb_all;
+	u8	cck_agc_rpt_ofdm_cfosho_a;
+	u8	cck_rpt_b_ofdm_cfosho_b;
+	u8	rsvd_1;
+	u8	noise_power_db_msb;
+	u8	path_cfotail[2];
+	u8	pcts_mask[2];
+	u8	stream_rxevm[2];
+	u8	path_rxsnr[2];
+	u8	noise_power_db_lsb;
+	u8	rsvd_2[3];
+	u8	stream_csi[2];
+	u8	stream_target_csi[2];
+	u8	sig_evm;
+	u8	rsvd_3;
+#if __LITTLE_ENDIAN
+	u8	antsel_rx_keep_2:1;	/*ex_intf_flg:1;*/
+	u8	sgi_en:1;
+	u8	rxsc:2;
+	u8	idle_long:1;
+	u8	r_ant_train_en:1;
+	u8	ant_sel_b:1;
+	u8	ant_sel:1;
+#else	/* _BIG_ENDIAN_	*/
+	u8	ant_sel:1;
+	u8	ant_sel_b:1;
+	u8	r_ant_train_en:1;
+	u8	idle_long:1;
+	u8	rxsc:2;
+	u8	sgi_en:1;
+	u8	antsel_rx_keep_2:1;	/*ex_intf_flg:1;*/
+#endif
+} __packed;
+
+struct rx_fwinfo_88e {
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
+struct tx_desc_88e {
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
+	u32 macid:6;
+	u32 rsvd0:2;
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
+	u32 agg_en:1;
+	u32 rdg_en:1;
+	u32 bar_retryht:2;
+	u32 agg_break:1;
+	u32 morefrag:1;
+	u32 raw:1;
+	u32 ccx:1;
+	u32 ampdudensity:3;
+	u32 bt_int:1;
+	u32 ant_sela:1;
+	u32 ant_selb:1;
+	u32 txant_cck:2;
+	u32 txant_l:2;
+	u32 txant_ht:2;
+
+	u32 nextheadpage:8;
+	u32 tailpage:8;
+	u32 seq:12;
+	u32 cpu_handle:1;
+	u32 tag1:1;
+	u32 trigger_int:1;
+	u32 hwseq_en:1;
+
+	u32 rtsrate:5;
+	u32 apdcfe:1;
+	u32 qos:1;
+	u32 hwseq_ssn:1;
+	u32 userrate:1;
+	u32 dis_rtsfb:1;
+	u32 dis_datafb:1;
+	u32 cts2self:1;
+	u32 rts_en:1;
+	u32 hwrts_en:1;
+	u32 portid:1;
+	u32 pwr_status:3;
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
+	u32 sw_offset30:8;
+	u32 sw_offset31:4;
+	u32 rsvd1:1;
+	u32 antsel_c:1;
+	u32 null_0:1;
+	u32 null_1:1;
+
+	u32 txbuffaddr;
+	u32 txbufferaddr64;
+	u32 nextdescaddress;
+	u32 nextdescaddress64;
+
+	u32 reserve_pass_pcie_mm_limit[4];
+} __packed;
+
+struct rx_desc_88e {
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
+	u32 macid:6;
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
+void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
+			  struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			  struct ieee80211_tx_info *info,
+			  struct ieee80211_sta *sta,
+			  struct sk_buff *skb,
+			  u8 hw_queue, struct rtl_tcb_desc *ptcb_desc);
+bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
+			   struct rtl_stats *status,
+			   struct ieee80211_rx_status *rx_status,
+			   u8 *pdesc, struct sk_buff *skb);
+void rtl88ee_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val);
+u32 rtl88ee_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+void rtl88ee_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
+void rtl88ee_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
+			     bool b_firstseg, bool b_lastseg,
+			     struct sk_buff *skb);
+
+#endif
-- 
1.8.1.4
