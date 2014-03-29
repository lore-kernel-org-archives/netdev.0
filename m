From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/6 NEXT] staging: r8723au: Add source files for new driver - part 3
Date: Fri, 28 Mar 2014 21:37:40 -0500
Message-ID: <1396060663-3589-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:53444 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaC2CiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 22:38:25 -0400
Received: by mail-oa0-f48.google.com with SMTP id m1so6970788oag.21
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 19:38:24 -0700 (PDT)
In-Reply-To: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Realtek USB device RTL8723AU is found in Lenovo Yoga 13 tablets.
A driver for it has been available in a GitHub repo for several months.
This commit contains the third part of source files. The source
is arbitrarily split to avoid E-mail files that are too large.

Jes Sorensen at RedHat has made many improvements to the vendor code,
and he has been doing the testing. I do not have access to this device.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c | 4501 +++++++++++++++++++++
 drivers/staging/rtl8723au/os_dep/mlme_linux.c     |  187 +
 drivers/staging/rtl8723au/os_dep/os_intfs.c       |  970 +++++
 drivers/staging/rtl8723au/os_dep/osdep_service.c  |  429 ++
 drivers/staging/rtl8723au/os_dep/recv_linux.c     |  225 +
 drivers/staging/rtl8723au/os_dep/usb_intf.c       |  836 ++++
 drivers/staging/rtl8723au/os_dep/usb_ops_linux.c  |  283 ++
 drivers/staging/rtl8723au/os_dep/xmit_linux.c     |  195 +
 8 files changed, 7626 insertions(+)
 create mode 100644 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
 create mode 100644 drivers/staging/rtl8723au/os_dep/mlme_linux.c
 create mode 100644 drivers/staging/rtl8723au/os_dep/os_intfs.c
 create mode 100644 drivers/staging/rtl8723au/os_dep/osdep_service.c
 create mode 100644 drivers/staging/rtl8723au/os_dep/recv_linux.c
 create mode 100644 drivers/staging/rtl8723au/os_dep/usb_intf.c
 create mode 100644 drivers/staging/rtl8723au/os_dep/usb_ops_linux.c
 create mode 100644 drivers/staging/rtl8723au/os_dep/xmit_linux.c

diff --git a/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c b/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
new file mode 100644
index 0000000..1c99616
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
@@ -0,0 +1,4501 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+#define  _IOCTL_CFG80211_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <rtw_ioctl_set.h>
+#include <xmit_osdep.h>
+
+#include "ioctl_cfg80211.h"
+#include <linux/version.h>
+
+#define RTW_MAX_MGMT_TX_CNT 8
+
+#define RTW_MAX_REMAIN_ON_CHANNEL_DURATION 65535	/* ms */
+#define RTW_MAX_NUM_PMKIDS 4
+
+#define RTW_CH_MAX_2G_CHANNEL               14	/* Max channel in 2G band */
+
+static const u32 rtw_cipher_suites[] = {
+	WLAN_CIPHER_SUITE_WEP40,
+	WLAN_CIPHER_SUITE_WEP104,
+	WLAN_CIPHER_SUITE_TKIP,
+	WLAN_CIPHER_SUITE_CCMP,
+};
+
+#define RATETAB_ENT(_rate, _rateid, _flags) {			\
+	.bitrate	= (_rate),				\
+	.hw_value	= (_rateid),				\
+	.flags		= (_flags),				\
+}
+
+#define CHAN2G(_channel, _freq, _flags) {			\
+	.band			= IEEE80211_BAND_2GHZ,		\
+	.center_freq		= (_freq),			\
+	.hw_value		= (_channel),			\
+	.flags			= (_flags),			\
+	.max_antenna_gain	= 0,				\
+	.max_power		= 30,				\
+}
+
+#define CHAN5G(_channel, _flags) {				\
+	.band			= IEEE80211_BAND_5GHZ,		\
+	.center_freq		= 5000 + (5 * (_channel)),	\
+	.hw_value		= (_channel),			\
+	.flags			= (_flags),			\
+	.max_antenna_gain	= 0,				\
+	.max_power		= 30,				\
+}
+
+static struct ieee80211_rate rtw_rates[] = {
+	RATETAB_ENT(10, 0x1, 0),
+	RATETAB_ENT(20, 0x2, 0),
+	RATETAB_ENT(55, 0x4, 0),
+	RATETAB_ENT(110, 0x8, 0),
+	RATETAB_ENT(60, 0x10, 0),
+	RATETAB_ENT(90, 0x20, 0),
+	RATETAB_ENT(120, 0x40, 0),
+	RATETAB_ENT(180, 0x80, 0),
+	RATETAB_ENT(240, 0x100, 0),
+	RATETAB_ENT(360, 0x200, 0),
+	RATETAB_ENT(480, 0x400, 0),
+	RATETAB_ENT(540, 0x800, 0),
+};
+
+#define rtw_a_rates		(rtw_rates + 4)
+#define RTW_A_RATES_NUM	8
+#define rtw_g_rates		(rtw_rates + 0)
+#define RTW_G_RATES_NUM	12
+
+#define RTW_2G_CHANNELS_NUM 14
+#define RTW_5G_CHANNELS_NUM 37
+
+static struct ieee80211_channel rtw_2ghz_channels[] = {
+	CHAN2G(1, 2412, 0),
+	CHAN2G(2, 2417, 0),
+	CHAN2G(3, 2422, 0),
+	CHAN2G(4, 2427, 0),
+	CHAN2G(5, 2432, 0),
+	CHAN2G(6, 2437, 0),
+	CHAN2G(7, 2442, 0),
+	CHAN2G(8, 2447, 0),
+	CHAN2G(9, 2452, 0),
+	CHAN2G(10, 2457, 0),
+	CHAN2G(11, 2462, 0),
+	CHAN2G(12, 2467, 0),
+	CHAN2G(13, 2472, 0),
+	CHAN2G(14, 2484, 0),
+};
+
+static struct ieee80211_channel rtw_5ghz_a_channels[] = {
+	CHAN5G(34, 0), CHAN5G(36, 0),
+	CHAN5G(38, 0), CHAN5G(40, 0),
+	CHAN5G(42, 0), CHAN5G(44, 0),
+	CHAN5G(46, 0), CHAN5G(48, 0),
+	CHAN5G(52, 0), CHAN5G(56, 0),
+	CHAN5G(60, 0), CHAN5G(64, 0),
+	CHAN5G(100, 0), CHAN5G(104, 0),
+	CHAN5G(108, 0), CHAN5G(112, 0),
+	CHAN5G(116, 0), CHAN5G(120, 0),
+	CHAN5G(124, 0), CHAN5G(128, 0),
+	CHAN5G(132, 0), CHAN5G(136, 0),
+	CHAN5G(140, 0), CHAN5G(149, 0),
+	CHAN5G(153, 0), CHAN5G(157, 0),
+	CHAN5G(161, 0), CHAN5G(165, 0),
+	CHAN5G(184, 0), CHAN5G(188, 0),
+	CHAN5G(192, 0), CHAN5G(196, 0),
+	CHAN5G(200, 0), CHAN5G(204, 0),
+	CHAN5G(208, 0), CHAN5G(212, 0),
+	CHAN5G(216, 0),
+};
+
+static void rtw_2g_channels_init(struct ieee80211_channel *channels)
+{
+	memcpy((void *)channels, (void *)rtw_2ghz_channels,
+	       sizeof(struct ieee80211_channel) * RTW_2G_CHANNELS_NUM);
+}
+
+static void rtw_5g_channels_init(struct ieee80211_channel *channels)
+{
+	memcpy((void *)channels, (void *)rtw_5ghz_a_channels,
+	       sizeof(struct ieee80211_channel) * RTW_5G_CHANNELS_NUM);
+}
+
+static void rtw_2g_rates_init(struct ieee80211_rate *rates)
+{
+	memcpy(rates, rtw_g_rates,
+	       sizeof(struct ieee80211_rate) * RTW_G_RATES_NUM);
+}
+
+static void rtw_5g_rates_init(struct ieee80211_rate *rates)
+{
+	memcpy(rates, rtw_a_rates,
+	       sizeof(struct ieee80211_rate) * RTW_A_RATES_NUM);
+}
+
+static struct ieee80211_supported_band *
+rtw_spt_band_alloc(enum ieee80211_band band)
+{
+	struct ieee80211_supported_band *spt_band = NULL;
+	int n_channels, n_bitrates;
+
+	if (band == IEEE80211_BAND_2GHZ) {
+		n_channels = RTW_2G_CHANNELS_NUM;
+		n_bitrates = RTW_G_RATES_NUM;
+	} else if (band == IEEE80211_BAND_5GHZ) {
+		n_channels = RTW_5G_CHANNELS_NUM;
+		n_bitrates = RTW_A_RATES_NUM;
+	} else {
+		goto exit;
+	}
+	spt_band = kzalloc(sizeof(struct ieee80211_supported_band) +
+			   sizeof(struct ieee80211_channel) * n_channels +
+			   sizeof(struct ieee80211_rate) * n_bitrates,
+			   GFP_KERNEL);
+	if (!spt_band)
+		goto exit;
+
+	spt_band->channels =
+		(struct ieee80211_channel *)(((u8 *) spt_band) +
+					     sizeof(struct
+						    ieee80211_supported_band));
+	spt_band->bitrates =
+		(struct ieee80211_rate *)(((u8 *) spt_band->channels) +
+					  sizeof(struct ieee80211_channel) *
+					  n_channels);
+	spt_band->band = band;
+	spt_band->n_channels = n_channels;
+	spt_band->n_bitrates = n_bitrates;
+
+	if (band == IEEE80211_BAND_2GHZ) {
+		rtw_2g_channels_init(spt_band->channels);
+		rtw_2g_rates_init(spt_band->bitrates);
+	} else if (band == IEEE80211_BAND_5GHZ) {
+		rtw_5g_channels_init(spt_band->channels);
+		rtw_5g_rates_init(spt_band->bitrates);
+	}
+
+	/* spt_band.ht_cap */
+
+exit:
+	return spt_band;
+}
+
+static const struct ieee80211_txrx_stypes
+rtw_cfg80211_default_mgmt_stypes[NUM_NL80211_IFTYPES] = {
+	[NL80211_IFTYPE_ADHOC] = {
+		.tx = 0xffff,
+		.rx = BIT(IEEE80211_STYPE_ACTION >> 4)
+	},
+	[NL80211_IFTYPE_STATION] = {
+		.tx = 0xffff,
+		.rx = BIT(IEEE80211_STYPE_ACTION >> 4) |
+		      BIT(IEEE80211_STYPE_PROBE_REQ >> 4)
+	},
+	[NL80211_IFTYPE_AP] = {
+		.tx = 0xffff,
+		.rx = BIT(IEEE80211_STYPE_ASSOC_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_REASSOC_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_PROBE_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_DISASSOC >> 4) |
+		      BIT(IEEE80211_STYPE_AUTH >> 4) |
+		      BIT(IEEE80211_STYPE_DEAUTH >> 4) |
+		      BIT(IEEE80211_STYPE_ACTION >> 4)
+	},
+	[NL80211_IFTYPE_AP_VLAN] = {
+		/* copy AP */
+		.tx = 0xffff,
+		.rx = BIT(IEEE80211_STYPE_ASSOC_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_REASSOC_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_PROBE_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_DISASSOC >> 4) |
+		      BIT(IEEE80211_STYPE_AUTH >> 4) |
+		      BIT(IEEE80211_STYPE_DEAUTH >> 4) |
+		      BIT(IEEE80211_STYPE_ACTION >> 4)
+	},
+	[NL80211_IFTYPE_P2P_CLIENT] = {
+		.tx = 0xffff,
+		.rx = BIT(IEEE80211_STYPE_ACTION >> 4) |
+		      BIT(IEEE80211_STYPE_PROBE_REQ >> 4)
+	},
+	[NL80211_IFTYPE_P2P_GO] = {
+		.tx = 0xffff,
+		.rx = BIT(IEEE80211_STYPE_ASSOC_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_REASSOC_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_PROBE_REQ >> 4) |
+		      BIT(IEEE80211_STYPE_DISASSOC >> 4) |
+		      BIT(IEEE80211_STYPE_AUTH >> 4) |
+		      BIT(IEEE80211_STYPE_DEAUTH >> 4) |
+		      BIT(IEEE80211_STYPE_ACTION >> 4)
+	},
+};
+
+#define MAX_BSSINFO_LEN 1000
+static int rtw_cfg80211_inform_bss(struct rtw_adapter *padapter,
+				   struct wlan_network *pnetwork)
+{
+	int ret = 0;
+	struct ieee80211_channel *notify_channel;
+	struct cfg80211_bss *bss;
+	/* struct ieee80211_supported_band *band; */
+	u16 channel;
+	u32 freq;
+	u64 notify_timestamp;
+	u16 notify_capability;
+	u16 notify_interval;
+	u8 *notify_ie;
+	size_t notify_ielen;
+	s32 notify_signal;
+	u8 buf[MAX_BSSINFO_LEN], *pbuf;
+	size_t len, bssinf_len = 0;
+	struct ieee80211_hdr *pwlanhdr;
+	unsigned short *fctrl;
+	u8 bc_addr[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+
+	struct wireless_dev *wdev = padapter->rtw_wdev;
+	struct wiphy *wiphy = wdev->wiphy;
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+	/* DBG_8723A("%s\n", __func__); */
+
+	bssinf_len =
+		pnetwork->network.IELength + sizeof(struct ieee80211_hdr_3addr);
+	if (bssinf_len > MAX_BSSINFO_LEN) {
+		DBG_8723A("%s IE Length too long > %d byte\n", __func__,
+			  MAX_BSSINFO_LEN);
+		goto exit;
+	}
+
+	channel = pnetwork->network.Configuration.DSConfig;
+	if (channel <= RTW_CH_MAX_2G_CHANNEL)
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_2GHZ);
+	else
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_5GHZ);
+
+	notify_channel = ieee80211_get_channel(wiphy, freq);
+
+	/* rtw_get_timestampe_from_ie23a() */
+	notify_timestamp = jiffies_to_msecs(jiffies) * 1000;	/* uSec */
+
+	notify_interval =
+	    le16_to_cpu(*(u16 *)
+			rtw_get_beacon_interval23a_from_ie(pnetwork->network.IEs));
+	notify_capability =
+	    le16_to_cpu(*(u16 *)
+			rtw_get_capability23a_from_ie(pnetwork->network.IEs));
+
+	notify_ie = pnetwork->network.IEs + _FIXED_IE_LENGTH_;
+	notify_ielen = pnetwork->network.IELength - _FIXED_IE_LENGTH_;
+
+	/* We've set wiphy's signal_type as CFG80211_SIGNAL_TYPE_MBM:
+	 *  signal strength in mBm (100*dBm)
+	 */
+	if (check_fwstate(pmlmepriv, _FW_LINKED) &&
+	    is_same_network23a(&pmlmepriv->cur_network.network,
+			    &pnetwork->network)) {
+		notify_signal = 100 * translate_percentage_to_dbm(padapter->recvpriv.signal_strength);	/* dbm */
+	} else {
+		notify_signal = 100 * translate_percentage_to_dbm(pnetwork->network.PhyInfo.SignalStrength);	/* dbm */
+	}
+	pbuf = buf;
+
+	pwlanhdr = (struct ieee80211_hdr *)pbuf;
+	fctrl = &pwlanhdr->frame_control;
+	*(fctrl) = 0;
+
+	SetSeqNum(pwlanhdr, 0);
+
+	if (pnetwork->network.reserved == 1) {	/*  WIFI_BEACON */
+		memcpy(pwlanhdr->addr1, bc_addr, ETH_ALEN);
+		SetFrameSubType(pbuf, WIFI_BEACON);
+	} else {
+		memcpy(pwlanhdr->addr1, myid(&padapter->eeprompriv), ETH_ALEN);
+		SetFrameSubType(pbuf, WIFI_PROBERSP);
+	}
+
+	memcpy(pwlanhdr->addr2, pnetwork->network.MacAddress, ETH_ALEN);
+	memcpy(pwlanhdr->addr3, pnetwork->network.MacAddress, ETH_ALEN);
+
+	pbuf += sizeof(struct ieee80211_hdr_3addr);
+	len = sizeof(struct ieee80211_hdr_3addr);
+
+	memcpy(pbuf, pnetwork->network.IEs, pnetwork->network.IELength);
+	len += pnetwork->network.IELength;
+
+	bss = cfg80211_inform_bss_frame(wiphy, notify_channel,
+					(struct ieee80211_mgmt *)buf, len,
+					notify_signal, GFP_ATOMIC);
+
+	if (unlikely(!bss)) {
+		DBG_8723A("rtw_cfg80211_inform_bss error\n");
+		return -EINVAL;
+	}
+
+	cfg80211_put_bss(wiphy, bss);
+
+exit:
+	return ret;
+}
+
+void rtw_cfg80211_indicate_connect(struct rtw_adapter *padapter)
+{
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct wlan_network *cur_network = &pmlmepriv->cur_network;
+	struct wireless_dev *pwdev = padapter->rtw_wdev;
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+#endif
+
+	DBG_8723A("%s(padapter =%p)\n", __func__, padapter);
+
+	if (pwdev->iftype != NL80211_IFTYPE_STATION &&
+	    pwdev->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return;
+
+	if (check_fwstate(pmlmepriv, WIFI_AP_STATE))
+		return;
+
+#ifdef CONFIG_8723AU_P2P
+	if (!rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
+		rtw_p2p_set_pre_state(pwdinfo, rtw_p2p_state(pwdinfo));
+		rtw_p2p_set_role(pwdinfo, P2P_ROLE_CLIENT);
+		rtw_p2p_set_state(pwdinfo, P2P_STATE_GONEGO_OK);
+		DBG_8723A("%s, role =%d, p2p_state =%d, pre_p2p_state =%d\n",
+			  __func__, rtw_p2p_role(pwdinfo),
+			  rtw_p2p_state(pwdinfo), rtw_p2p_pre_state(pwdinfo));
+	}
+#endif /* CONFIG_8723AU_P2P */
+
+	if (rtw_to_roaming(padapter) > 0) {
+		struct wiphy *wiphy = pwdev->wiphy;
+		struct ieee80211_channel *notify_channel;
+		u32 freq;
+		u16 channel = cur_network->network.Configuration.DSConfig;
+
+		if (channel <= RTW_CH_MAX_2G_CHANNEL)
+			freq =
+			    ieee80211_channel_to_frequency(channel,
+							   IEEE80211_BAND_2GHZ);
+		else
+			freq =
+			    ieee80211_channel_to_frequency(channel,
+							   IEEE80211_BAND_5GHZ);
+
+		notify_channel = ieee80211_get_channel(wiphy, freq);
+
+		DBG_8723A("%s call cfg80211_roamed\n", __func__);
+		cfg80211_roamed(padapter->pnetdev, notify_channel,
+				cur_network->network.MacAddress,
+				pmlmepriv->assoc_req +
+				sizeof(struct ieee80211_hdr_3addr) + 2,
+				pmlmepriv->assoc_req_len -
+				sizeof(struct ieee80211_hdr_3addr) - 2,
+				pmlmepriv->assoc_rsp +
+				sizeof(struct ieee80211_hdr_3addr) + 6,
+				pmlmepriv->assoc_rsp_len -
+				sizeof(struct ieee80211_hdr_3addr) - 6,
+				GFP_ATOMIC);
+	} else {
+		cfg80211_connect_result(padapter->pnetdev,
+					cur_network->network.MacAddress,
+					pmlmepriv->assoc_req +
+					sizeof(struct ieee80211_hdr_3addr) + 2,
+					pmlmepriv->assoc_req_len -
+					sizeof(struct ieee80211_hdr_3addr) - 2,
+					pmlmepriv->assoc_rsp +
+					sizeof(struct ieee80211_hdr_3addr) + 6,
+					pmlmepriv->assoc_rsp_len -
+					sizeof(struct ieee80211_hdr_3addr) - 6,
+					WLAN_STATUS_SUCCESS, GFP_ATOMIC);
+	}
+}
+
+void rtw_cfg80211_indicate_disconnect(struct rtw_adapter *padapter)
+{
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct wireless_dev *pwdev = padapter->rtw_wdev;
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+#endif
+
+	DBG_8723A("%s(padapter =%p)\n", __func__, padapter);
+
+	if (pwdev->iftype != NL80211_IFTYPE_STATION &&
+	    pwdev->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return;
+
+	if (check_fwstate(pmlmepriv, WIFI_AP_STATE))
+		return;
+
+#ifdef CONFIG_8723AU_P2P
+	if (!rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
+		del_timer_sync(&pwdinfo->find_phase_timer);
+		del_timer_sync(&pwdinfo->restore_p2p_state_timer);
+		del_timer_sync(&pwdinfo->pre_tx_scan_timer);
+
+		rtw_p2p_set_state(pwdinfo, rtw_p2p_pre_state(pwdinfo));
+		rtw_p2p_set_role(pwdinfo, P2P_ROLE_DEVICE);
+
+		DBG_8723A("%s, role =%d, p2p_state =%d, pre_p2p_state =%d\n",
+			  __func__, rtw_p2p_role(pwdinfo),
+			  rtw_p2p_state(pwdinfo), rtw_p2p_pre_state(pwdinfo));
+	}
+#endif /* CONFIG_8723AU_P2P */
+
+	if (!padapter->mlmepriv.not_indic_disco) {
+		if (check_fwstate(&padapter->mlmepriv, WIFI_UNDER_LINKING)) {
+			cfg80211_connect_result(padapter->pnetdev, NULL, NULL,
+						0, NULL, 0,
+						WLAN_STATUS_UNSPECIFIED_FAILURE,
+						GFP_ATOMIC);
+		} else {
+			cfg80211_disconnected(padapter->pnetdev, 0, NULL,
+					      0, GFP_ATOMIC);
+		}
+	}
+}
+
+#ifdef CONFIG_8723AU_AP_MODE
+static u8 set_pairwise_key(struct rtw_adapter *padapter, struct sta_info *psta)
+{
+	struct cmd_obj *ph2c;
+	struct set_stakey_parm *psetstakey_para;
+	struct cmd_priv *pcmdpriv = &padapter->cmdpriv;
+	u8 res = _SUCCESS;
+
+	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	if (ph2c == NULL) {
+		res = _FAIL;
+		goto exit;
+	}
+
+	psetstakey_para = kzalloc(sizeof(struct set_stakey_parm), GFP_KERNEL);
+	if (psetstakey_para == NULL) {
+		kfree(ph2c);
+		res = _FAIL;
+		goto exit;
+	}
+
+	init_h2fwcmd_w_parm_no_rsp(ph2c, psetstakey_para, _SetStaKey_CMD_);
+
+	psetstakey_para->algorithm = (u8) psta->dot118021XPrivacy;
+
+	memcpy(psetstakey_para->addr, psta->hwaddr, ETH_ALEN);
+
+	memcpy(psetstakey_para->key, &psta->dot118021x_UncstKey, 16);
+
+	res = rtw_enqueue_cmd23a(pcmdpriv, ph2c);
+
+exit:
+	return res;
+}
+
+static int set_group_key(struct rtw_adapter *padapter, u8 *key, u8 alg,
+			 int keyid)
+{
+	u8 keylen;
+	struct cmd_obj *pcmd;
+	struct setkey_parm *psetkeyparm;
+	struct cmd_priv *pcmdpriv = &padapter->cmdpriv;
+	int res = _SUCCESS;
+
+	DBG_8723A("%s\n", __func__);
+
+	pcmd = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	if (!pcmd) {
+		res = _FAIL;
+		goto exit;
+	}
+	psetkeyparm = kzalloc(sizeof(struct setkey_parm), GFP_KERNEL);
+	if (!psetkeyparm) {
+		kfree(pcmd);
+		res = _FAIL;
+		goto exit;
+	}
+
+	psetkeyparm->keyid = (u8) keyid;
+	if (is_wep_enc(alg))
+		padapter->mlmepriv.key_mask |= CHKBIT(psetkeyparm->keyid);
+
+	psetkeyparm->algorithm = alg;
+
+	psetkeyparm->set_tx = 1;
+
+	switch (alg) {
+	case _WEP40_:
+		keylen = 5;
+		break;
+	case _WEP104_:
+		keylen = 13;
+		break;
+	case _TKIP_:
+	case _TKIP_WTMIC_:
+	case _AES_:
+	default:
+		keylen = 16;
+	}
+
+	memcpy(&psetkeyparm->key[0], key, keylen);
+
+	pcmd->cmdcode = _SetKey_CMD_;
+	pcmd->parmbuf = (u8 *) psetkeyparm;
+	pcmd->cmdsz = (sizeof(struct setkey_parm));
+	pcmd->rsp = NULL;
+	pcmd->rspsz = 0;
+
+	INIT_LIST_HEAD(&pcmd->list);
+
+	res = rtw_enqueue_cmd23a(pcmdpriv, pcmd);
+
+exit:
+	return res;
+}
+
+static int set_wep_key(struct rtw_adapter *padapter, u8 *key, u8 keylen,
+		       int keyid)
+{
+	u8 alg;
+
+	switch (keylen) {
+	case 5:
+		alg = _WEP40_;
+		break;
+	case 13:
+		alg = _WEP104_;
+		break;
+	default:
+		alg = _NO_PRIVACY_;
+	}
+
+	return set_group_key(padapter, key, alg, keyid);
+}
+
+static int rtw_cfg80211_ap_set_encryption(struct net_device *dev,
+					  struct ieee_param *param,
+					  u32 param_len)
+{
+	int ret = 0;
+	u32 wep_key_idx, wep_key_len;
+	struct sta_info *psta = NULL, *pbcmc_sta = NULL;
+	struct rtw_adapter *padapter = netdev_priv(dev);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+	struct sta_priv *pstapriv = &padapter->stapriv;
+
+	DBG_8723A("%s\n", __func__);
+
+	param->u.crypt.err = 0;
+	param->u.crypt.alg[IEEE_CRYPT_ALG_NAME_LEN - 1] = '\0';
+
+	/* sizeof(struct ieee_param) = 64 bytes; */
+	/* if (param_len !=  (u32) ((u8 *) param->u.crypt.key -
+	   (u8 *) param) + param->u.crypt.key_len) */
+	if (param_len != sizeof(struct ieee_param) + param->u.crypt.key_len) {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	if (is_broadcast_ether_addr(param->sta_addr)) {
+		if (param->u.crypt.idx >= WEP_KEYS) {
+			ret = -EINVAL;
+			goto exit;
+		}
+	} else {
+		psta = rtw_get_stainfo23a(pstapriv, param->sta_addr);
+		if (!psta) {
+			/* ret = -EINVAL; */
+			DBG_8723A("rtw_set_encryption(), sta has already "
+				  "been removed or never been added\n");
+			goto exit;
+		}
+	}
+
+	if (strcmp(param->u.crypt.alg, "none") == 0 && (psta == NULL)) {
+		/* todo:clear default encryption keys */
+
+		DBG_8723A("clear default encryption keys, keyid =%d\n",
+			  param->u.crypt.idx);
+
+		goto exit;
+	}
+
+	if (strcmp(param->u.crypt.alg, "WEP") == 0 && (psta == NULL)) {
+		DBG_8723A("r871x_set_encryption, crypt.alg = WEP\n");
+
+		wep_key_idx = param->u.crypt.idx;
+		wep_key_len = param->u.crypt.key_len;
+
+		DBG_8723A("r871x_set_encryption, wep_key_idx =%d, len =%d\n",
+			  wep_key_idx, wep_key_len);
+
+		if ((wep_key_idx >= WEP_KEYS) || (wep_key_len <= 0)) {
+			ret = -EINVAL;
+			goto exit;
+		}
+
+		if (wep_key_len > 0) {
+			wep_key_len = wep_key_len <= 5 ? 5 : 13;
+		}
+
+		if (psecuritypriv->bWepDefaultKeyIdxSet == 0) {
+			/* wep default key has not been set, so use
+			   this key index as default key. */
+
+			psecuritypriv->ndisencryptstatus =
+				Ndis802_11Encryption1Enabled;
+			psecuritypriv->dot11PrivacyAlgrthm = _WEP40_;
+			psecuritypriv->dot118021XGrpPrivacy = _WEP40_;
+
+			if (wep_key_len == 13) {
+				psecuritypriv->dot11PrivacyAlgrthm = _WEP104_;
+				psecuritypriv->dot118021XGrpPrivacy = _WEP104_;
+			}
+
+			psecuritypriv->dot11PrivacyKeyIndex = wep_key_idx;
+		}
+
+		memcpy(&psecuritypriv->dot11DefKey[wep_key_idx].skey[0],
+		       param->u.crypt.key, wep_key_len);
+
+		psecuritypriv->dot11DefKeylen[wep_key_idx] = wep_key_len;
+
+		set_wep_key(padapter, param->u.crypt.key, wep_key_len,
+			    wep_key_idx);
+
+		goto exit;
+
+	}
+
+	if (!psta && check_fwstate(pmlmepriv, WIFI_AP_STATE)) {	/*  group key */
+		if (param->u.crypt.set_tx == 0) {	/* group key */
+			if (strcmp(param->u.crypt.alg, "WEP") == 0) {
+				DBG_8723A("%s, set group_key, WEP\n",
+					  __func__);
+
+				memcpy(psecuritypriv->
+				       dot118021XGrpKey[param->u.crypt.idx].
+				       skey, param->u.crypt.key,
+				       (param->u.crypt.key_len >
+					16 ? 16 : param->u.crypt.key_len));
+
+				psecuritypriv->dot118021XGrpPrivacy = _WEP40_;
+				if (param->u.crypt.key_len == 13) {
+					psecuritypriv->dot118021XGrpPrivacy =
+					    _WEP104_;
+				}
+
+			} else if (strcmp(param->u.crypt.alg, "TKIP") == 0) {
+				DBG_8723A("%s, set group_key, TKIP\n",
+					  __func__);
+
+				psecuritypriv->dot118021XGrpPrivacy = _TKIP_;
+
+				memcpy(psecuritypriv->
+				       dot118021XGrpKey[param->u.crypt.idx].
+				       skey, param->u.crypt.key,
+				       (param->u.crypt.key_len >
+					16 ? 16 : param->u.crypt.key_len));
+
+				/* DEBUG_ERR("set key length :param->u.crypt.key_len =%d\n", param->u.crypt.key_len); */
+				/* set mic key */
+				memcpy(psecuritypriv->
+				       dot118021XGrptxmickey[param->u.crypt.
+							     idx].skey,
+				       &param->u.crypt.key[16], 8);
+				memcpy(psecuritypriv->
+				       dot118021XGrprxmickey[param->u.crypt.
+							     idx].skey,
+				       &param->u.crypt.key[24], 8);
+
+				psecuritypriv->busetkipkey = true;
+
+			} else if (strcmp(param->u.crypt.alg, "CCMP") == 0) {
+				DBG_8723A("%s, set group_key, CCMP\n",
+					  __func__);
+
+				psecuritypriv->dot118021XGrpPrivacy = _AES_;
+
+				memcpy(psecuritypriv->
+				       dot118021XGrpKey[param->u.crypt.idx].
+				       skey, param->u.crypt.key,
+				       (param->u.crypt.key_len >
+					16 ? 16 : param->u.crypt.key_len));
+			} else {
+				DBG_8723A("%s, set group_key, none\n",
+					  __func__);
+
+				psecuritypriv->dot118021XGrpPrivacy =
+				    _NO_PRIVACY_;
+			}
+
+			psecuritypriv->dot118021XGrpKeyid = param->u.crypt.idx;
+
+			psecuritypriv->binstallGrpkey = true;
+
+			psecuritypriv->dot11PrivacyAlgrthm =
+				psecuritypriv->dot118021XGrpPrivacy;
+
+			set_group_key(padapter, param->u.crypt.key,
+				      psecuritypriv->dot118021XGrpPrivacy,
+				      param->u.crypt.idx);
+
+			pbcmc_sta = rtw_get_bcmc_stainfo23a(padapter);
+			if (pbcmc_sta) {
+				pbcmc_sta->ieee8021x_blocked = false;
+				/* rx will use bmc_sta's dot118021XPrivacy */
+				pbcmc_sta->dot118021XPrivacy =
+					psecuritypriv->dot118021XGrpPrivacy;
+
+			}
+
+		}
+
+		goto exit;
+	}
+
+	if (psecuritypriv->dot11AuthAlgrthm ==
+	    dot11AuthAlgrthm_8021X && psta) {	/*  psk/802_1x */
+		if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
+			if (param->u.crypt.set_tx == 1) {
+				/* pairwise key */
+				memcpy(psta->dot118021x_UncstKey.skey,
+				       param->u.crypt.key,
+				       (param->u.crypt.key_len >
+					16 ? 16 : param->u.crypt.key_len));
+
+				if (!strcmp(param->u.crypt.alg, "WEP")) {
+					DBG_8723A("%s, set pairwise key, WEP\n",
+						  __func__);
+
+					psta->dot118021XPrivacy = _WEP40_;
+					if (param->u.crypt.key_len == 13) {
+						psta->dot118021XPrivacy =
+							_WEP104_;
+					}
+				} else if (!strcmp(param->u.crypt.alg, "TKIP")) {
+					DBG_8723A("%s, set pairwise key, "
+						  "TKIP\n", __func__);
+
+					psta->dot118021XPrivacy = _TKIP_;
+
+					/* DEBUG_ERR("set key length :param->u.crypt.key_len =%d\n", param->u.crypt.key_len); */
+					/* set mic key */
+					memcpy(psta->dot11tkiptxmickey.skey,
+					       &param->u.crypt.key[16], 8);
+					memcpy(psta->dot11tkiprxmickey.skey,
+					       &param->u.crypt.key[24], 8);
+
+					psecuritypriv->busetkipkey = true;
+
+				} else if (!strcmp(param->u.crypt.alg, "CCMP")) {
+
+					DBG_8723A("%s, set pairwise key, "
+						  "CCMP\n", __func__);
+
+					psta->dot118021XPrivacy = _AES_;
+				} else {
+					DBG_8723A("%s, set pairwise key, "
+						  "none\n", __func__);
+
+					psta->dot118021XPrivacy = _NO_PRIVACY_;
+				}
+
+				set_pairwise_key(padapter, psta);
+
+				psta->ieee8021x_blocked = false;
+
+				psta->bpairwise_key_installed = true;
+			} else {	/* group key??? */
+				if (!strcmp(param->u.crypt.alg, "WEP")) {
+					memcpy(psecuritypriv->
+					       dot118021XGrpKey[param->u.crypt.
+								idx].skey,
+					       param->u.crypt.key,
+					       (param->u.crypt.key_len >
+						16 ? 16 : param->u.crypt.
+						key_len));
+
+					psecuritypriv->dot118021XGrpPrivacy =
+						_WEP40_;
+					if (param->u.crypt.key_len == 13) {
+						psecuritypriv->
+						    dot118021XGrpPrivacy =
+							_WEP104_;
+					}
+				} else if (!strcmp(param->u.crypt.alg, "TKIP")) {
+					psecuritypriv->dot118021XGrpPrivacy =
+					    _TKIP_;
+
+					memcpy(psecuritypriv->
+					       dot118021XGrpKey[param->u.crypt.
+								idx].skey,
+					       param->u.crypt.key,
+					       (param->u.crypt.key_len >
+						16 ? 16 : param->u.crypt.
+						key_len));
+
+					/* DEBUG_ERR("set key length :param->u"
+					   ".crypt.key_len =%d\n",
+					   param->u.crypt.key_len); */
+					/* set mic key */
+					memcpy(psecuritypriv->
+					       dot118021XGrptxmickey[param->u.
+								     crypt.idx].
+					       skey, &param->u.crypt.key[16],
+					       8);
+					memcpy(psecuritypriv->
+					       dot118021XGrprxmickey[param->u.
+								     crypt.idx].
+					       skey, &param->u.crypt.key[24],
+					       8);
+
+					psecuritypriv->busetkipkey = true;
+
+				} else if (!strcmp(param->u.crypt.alg, "CCMP")) {
+					psecuritypriv->dot118021XGrpPrivacy =
+						_AES_;
+
+					memcpy(psecuritypriv->
+					       dot118021XGrpKey[param->u.crypt.
+								idx].skey,
+					       param->u.crypt.key,
+					       (param->u.crypt.key_len >
+						16 ? 16 : param->u.crypt.
+						key_len));
+				} else {
+					psecuritypriv->dot118021XGrpPrivacy =
+						_NO_PRIVACY_;
+				}
+
+				psecuritypriv->dot118021XGrpKeyid =
+					param->u.crypt.idx;
+
+				psecuritypriv->binstallGrpkey = true;
+
+				psecuritypriv->dot11PrivacyAlgrthm =
+					psecuritypriv->dot118021XGrpPrivacy;
+
+				set_group_key(padapter, param->u.crypt.key,
+					      psecuritypriv->
+					      dot118021XGrpPrivacy,
+					      param->u.crypt.idx);
+
+				pbcmc_sta = rtw_get_bcmc_stainfo23a(padapter);
+				if (pbcmc_sta) {
+					/* rx will use bmc_sta's
+					   dot118021XPrivacy */
+					pbcmc_sta->ieee8021x_blocked = false;
+					pbcmc_sta->dot118021XPrivacy = psecuritypriv->dot118021XGrpPrivacy;
+				}
+			}
+		}
+	}
+
+exit:
+
+	return ret;
+
+}
+#endif
+
+static int rtw_cfg80211_set_encryption(struct net_device *dev,
+				       struct ieee_param *param, u32 param_len)
+{
+	int ret = 0;
+	u32 wep_key_idx, wep_key_len;
+	struct rtw_adapter *padapter = netdev_priv(dev);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+#endif /* CONFIG_8723AU_P2P */
+
+
+
+	DBG_8723A("%s\n", __func__);
+
+	param->u.crypt.err = 0;
+	param->u.crypt.alg[IEEE_CRYPT_ALG_NAME_LEN - 1] = '\0';
+
+	if (param_len <
+	    (u32) ((u8 *) param->u.crypt.key - (u8 *) param) +
+	    param->u.crypt.key_len) {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	if (is_broadcast_ether_addr(param->sta_addr)) {
+		if (param->u.crypt.idx >= WEP_KEYS) {
+			ret = -EINVAL;
+			goto exit;
+		}
+	} else {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	if (strcmp(param->u.crypt.alg, "WEP") == 0) {
+		RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_err_,
+			 ("wpa_set_encryption, crypt.alg = WEP\n"));
+		DBG_8723A("wpa_set_encryption, crypt.alg = WEP\n");
+
+		wep_key_idx = param->u.crypt.idx;
+		wep_key_len = param->u.crypt.key_len;
+
+		if ((wep_key_idx > WEP_KEYS) || (wep_key_len <= 0)) {
+			ret = -EINVAL;
+			goto exit;
+		}
+
+		if (psecuritypriv->bWepDefaultKeyIdxSet == 0) {
+			/* wep default key has not been set, so use this
+			   key index as default key. */
+
+			wep_key_len = wep_key_len <= 5 ? 5 : 13;
+
+			psecuritypriv->ndisencryptstatus =
+				Ndis802_11Encryption1Enabled;
+			psecuritypriv->dot11PrivacyAlgrthm = _WEP40_;
+			psecuritypriv->dot118021XGrpPrivacy = _WEP40_;
+
+			if (wep_key_len == 13) {
+				psecuritypriv->dot11PrivacyAlgrthm = _WEP104_;
+				psecuritypriv->dot118021XGrpPrivacy = _WEP104_;
+			}
+
+			psecuritypriv->dot11PrivacyKeyIndex = wep_key_idx;
+		}
+
+		memcpy(&psecuritypriv->dot11DefKey[wep_key_idx].skey[0],
+		       param->u.crypt.key, wep_key_len);
+
+		psecuritypriv->dot11DefKeylen[wep_key_idx] = wep_key_len;
+
+		rtw_set_key23a(padapter, psecuritypriv, wep_key_idx, 0);
+
+		goto exit;
+	}
+
+	if (padapter->securitypriv.dot11AuthAlgrthm ==
+	    dot11AuthAlgrthm_8021X) {	/*  802_1x */
+		struct sta_info *psta, *pbcmc_sta;
+		struct sta_priv *pstapriv = &padapter->stapriv;
+
+		if (check_fwstate(pmlmepriv,
+				  WIFI_STATION_STATE | WIFI_MP_STATE)) {
+			/* sta mode */
+			psta = rtw_get_stainfo23a(pstapriv, get_bssid(pmlmepriv));
+			if (psta == NULL) {
+				DBG_8723A("%s, : Obtain Sta_info fail\n",
+					  __func__);
+			} else {
+				/* Jeff: don't disable ieee8021x_blocked
+				   while clearing key */
+				if (strcmp(param->u.crypt.alg, "none") != 0)
+					psta->ieee8021x_blocked = false;
+
+				if ((padapter->securitypriv.ndisencryptstatus ==
+				     Ndis802_11Encryption2Enabled) ||
+				    (padapter->securitypriv.ndisencryptstatus ==
+				     Ndis802_11Encryption3Enabled)) {
+					psta->dot118021XPrivacy =
+						padapter->securitypriv.
+						dot11PrivacyAlgrthm;
+				}
+
+				if (param->u.crypt.set_tx == 1) {
+					/* pairwise key */
+					DBG_8723A("%s, : param->u.crypt.set_tx"
+						  " == 1\n", __func__);
+
+					memcpy(psta->dot118021x_UncstKey.skey,
+					       param->u.crypt.key,
+					       (param->u.crypt.key_len >
+						16 ? 16 : param->u.crypt.
+						key_len));
+
+					if (strcmp(param->u.crypt.alg,
+						   "TKIP") == 0) {
+						memcpy(psta->dot11tkiptxmickey.
+						       skey,
+						       &param->u.crypt.key[16],
+						       8);
+						memcpy(psta->dot11tkiprxmickey.
+						       skey,
+						       &param->u.crypt.key[24],
+						       8);
+
+						padapter->securitypriv.
+							busetkipkey = false;
+					}
+					DBG_8723A(" ~~~~set sta key:unicastkey\n");
+
+					rtw_setstakey_cmd23a(padapter,
+							  (unsigned char *)psta,
+							  true);
+				} else {	/* group key */
+					memcpy(padapter->securitypriv.
+					       dot118021XGrpKey[param->u.crypt.
+								idx].skey,
+					       param->u.crypt.key,
+					       (param->u.crypt.key_len >
+						16 ? 16 : param->u.crypt.
+						key_len));
+					memcpy(padapter->securitypriv.
+					       dot118021XGrptxmickey[param->u.
+								     crypt.idx].
+					       skey, &param->u.crypt.key[16],
+					       8);
+					memcpy(padapter->securitypriv.
+					       dot118021XGrprxmickey[param->u.
+								     crypt.idx].
+					       skey, &param->u.crypt.key[24],
+					       8);
+					padapter->securitypriv.binstallGrpkey =
+					    true;
+					/* DEBUG_ERR((" param->u.crypt.key_len"
+					   "=%d\n", param->u.crypt.key_len)); */
+					DBG_8723A
+					    (" ~~~~set sta key:groupkey\n");
+
+					padapter->securitypriv.
+					    dot118021XGrpKeyid =
+						param->u.crypt.idx;
+
+					rtw_set_key23a(padapter,
+						    &padapter->securitypriv,
+						    param->u.crypt.idx, 1);
+#ifdef CONFIG_8723AU_P2P
+					if (rtw_p2p_chk_state
+					    (pwdinfo,
+					     P2P_STATE_PROVISIONING_ING)) {
+						rtw_p2p_set_state(pwdinfo,
+								  P2P_STATE_PROVISIONING_DONE);
+					}
+#endif /* CONFIG_8723AU_P2P */
+
+				}
+			}
+
+			pbcmc_sta = rtw_get_bcmc_stainfo23a(padapter);
+			if (pbcmc_sta) {
+				/* Jeff: don't disable ieee8021x_blocked
+				   while clearing key */
+				if (strcmp(param->u.crypt.alg, "none") != 0)
+					pbcmc_sta->ieee8021x_blocked = false;
+
+				if ((padapter->securitypriv.ndisencryptstatus ==
+				     Ndis802_11Encryption2Enabled) ||
+				    (padapter->securitypriv.ndisencryptstatus ==
+				     Ndis802_11Encryption3Enabled)) {
+					pbcmc_sta->dot118021XPrivacy =
+					    padapter->securitypriv.
+					    dot11PrivacyAlgrthm;
+				}
+			}
+		} else if (check_fwstate(pmlmepriv, WIFI_ADHOC_STATE)) {	/* adhoc mode */
+		}
+	}
+
+exit:
+
+	DBG_8723A("%s, ret =%d\n", __func__, ret);
+
+
+
+	return ret;
+}
+
+static int cfg80211_rtw_add_key(struct wiphy *wiphy, struct net_device *ndev,
+				u8 key_index, bool pairwise,
+				const u8 *mac_addr, struct key_params *params)
+{
+	char *alg_name;
+	u32 param_len;
+	struct ieee_param *param = NULL;
+	int ret = 0;
+	struct wireless_dev *rtw_wdev = wiphy_to_wdev(wiphy);
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+	DBG_8723A(FUNC_NDEV_FMT " adding key for %pM\n", FUNC_NDEV_ARG(ndev),
+		  mac_addr);
+	DBG_8723A("cipher = 0x%x\n", params->cipher);
+	DBG_8723A("key_len = 0x%x\n", params->key_len);
+	DBG_8723A("seq_len = 0x%x\n", params->seq_len);
+	DBG_8723A("key_index =%d\n", key_index);
+	DBG_8723A("pairwise =%d\n", pairwise);
+
+	param_len = sizeof(struct ieee_param) + params->key_len;
+	param = kzalloc(param_len, GFP_KERNEL);
+	if (param == NULL)
+		return -1;
+
+	param->cmd = IEEE_CMD_SET_ENCRYPTION;
+	memset(param->sta_addr, 0xff, ETH_ALEN);
+
+	switch (params->cipher) {
+	case IW_AUTH_CIPHER_NONE:
+		/* todo: remove key */
+		/* remove = 1; */
+		alg_name = "none";
+		break;
+	case WLAN_CIPHER_SUITE_WEP40:
+	case WLAN_CIPHER_SUITE_WEP104:
+		alg_name = "WEP";
+		break;
+	case WLAN_CIPHER_SUITE_TKIP:
+		alg_name = "TKIP";
+		break;
+	case WLAN_CIPHER_SUITE_CCMP:
+		alg_name = "CCMP";
+		break;
+
+	default:
+		ret = -ENOTSUPP;
+		goto addkey_end;
+	}
+
+	strncpy((char *)param->u.crypt.alg, alg_name, IEEE_CRYPT_ALG_NAME_LEN);
+
+	if (!mac_addr || is_broadcast_ether_addr(mac_addr)) {
+		param->u.crypt.set_tx = 0;	/* for wpa/wpa2 group key */
+	} else {
+		param->u.crypt.set_tx = 1;	/* for wpa/wpa2 pairwise key */
+	}
+
+	/* param->u.crypt.idx = key_index - 1; */
+	param->u.crypt.idx = key_index;
+
+	if (params->seq_len && params->seq) {
+		memcpy(param->u.crypt.seq, params->seq, params->seq_len);
+	}
+
+	if (params->key_len && params->key) {
+		param->u.crypt.key_len = params->key_len;
+		memcpy(param->u.crypt.key, params->key, params->key_len);
+	}
+
+	if (check_fwstate(pmlmepriv, WIFI_STATION_STATE)) {
+		ret = rtw_cfg80211_set_encryption(ndev, param, param_len);
+	} else if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
+#ifdef CONFIG_8723AU_AP_MODE
+		if (mac_addr)
+			memcpy(param->sta_addr, (void *)mac_addr, ETH_ALEN);
+
+		ret = rtw_cfg80211_ap_set_encryption(ndev, param, param_len);
+#endif
+	} else {
+		DBG_8723A("error! fw_state = 0x%x, iftype =%d\n",
+			  pmlmepriv->fw_state, rtw_wdev->iftype);
+
+	}
+
+addkey_end:
+	kfree(param);
+
+	return ret;
+}
+
+static int
+cfg80211_rtw_get_key(struct wiphy *wiphy, struct net_device *ndev,
+		     u8 key_index, bool pairwise, const u8 *mac_addr,
+		     void *cookie,
+		     void (*callback) (void *cookie, struct key_params *))
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+	return 0;
+}
+
+static int cfg80211_rtw_del_key(struct wiphy *wiphy, struct net_device *ndev,
+				u8 key_index, bool pairwise,
+				const u8 *mac_addr)
+{
+	struct rtw_adapter *padapter = netdev_priv(ndev);
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+
+	DBG_8723A(FUNC_NDEV_FMT " key_index =%d\n", FUNC_NDEV_ARG(ndev),
+		  key_index);
+
+	if (key_index == psecuritypriv->dot11PrivacyKeyIndex) {
+		/* clear the flag of wep default key set. */
+		psecuritypriv->bWepDefaultKeyIdxSet = 0;
+	}
+
+	return 0;
+}
+
+static int cfg80211_rtw_set_default_key(struct wiphy *wiphy,
+					struct net_device *ndev, u8 key_index,
+					bool unicast, bool multicast)
+{
+	struct rtw_adapter *padapter = netdev_priv(ndev);
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+
+	DBG_8723A(FUNC_NDEV_FMT " key_index =%d"
+		  ", unicast =%d, multicast =%d.\n", FUNC_NDEV_ARG(ndev),
+		  key_index, unicast, multicast);
+
+	if ((key_index < WEP_KEYS) &&
+	    ((psecuritypriv->dot11PrivacyAlgrthm == _WEP40_) ||
+	     (psecuritypriv->dot11PrivacyAlgrthm == _WEP104_))) {
+		/* set wep default key */
+		psecuritypriv->ndisencryptstatus = Ndis802_11Encryption1Enabled;
+
+		psecuritypriv->dot11PrivacyKeyIndex = key_index;
+
+		psecuritypriv->dot11PrivacyAlgrthm = _WEP40_;
+		psecuritypriv->dot118021XGrpPrivacy = _WEP40_;
+		if (psecuritypriv->dot11DefKeylen[key_index] == 13) {
+			psecuritypriv->dot11PrivacyAlgrthm = _WEP104_;
+			psecuritypriv->dot118021XGrpPrivacy = _WEP104_;
+		}
+
+		/* set the flag to represent that wep default key
+		   has been set */
+		psecuritypriv->bWepDefaultKeyIdxSet = 1;
+	}
+
+	return 0;
+}
+
+static int cfg80211_rtw_get_station(struct wiphy *wiphy,
+				    struct net_device *ndev,
+				    u8 *mac, struct station_info *sinfo)
+{
+	int ret = 0;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct sta_info *psta = NULL;
+	struct sta_priv *pstapriv = &padapter->stapriv;
+
+	sinfo->filled = 0;
+
+	if (!mac) {
+		DBG_8723A(FUNC_NDEV_FMT " mac ==%p\n", FUNC_NDEV_ARG(ndev), mac);
+		ret = -ENOENT;
+		goto exit;
+	}
+
+	psta = rtw_get_stainfo23a(pstapriv, mac);
+	if (psta == NULL) {
+		DBG_8723A("%s, sta_info is null\n", __func__);
+		ret = -ENOENT;
+		goto exit;
+	}
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A(FUNC_NDEV_FMT " mac =" MAC_FMT "\n", FUNC_NDEV_ARG(ndev),
+		  MAC_ARG(mac));
+#endif
+
+	/* for infra./P2PClient mode */
+	if (check_fwstate(pmlmepriv, WIFI_STATION_STATE) &&
+	    check_fwstate(pmlmepriv, _FW_LINKED)) {
+		struct wlan_network *cur_network = &pmlmepriv->cur_network;
+
+		if (memcmp(mac, cur_network->network.MacAddress, ETH_ALEN)) {
+			DBG_8723A("%s, mismatch bssid =" MAC_FMT "\n", __func__,
+				  MAC_ARG(cur_network->network.MacAddress));
+			ret = -ENOENT;
+			goto exit;
+		}
+
+		sinfo->filled |= STATION_INFO_SIGNAL;
+		sinfo->signal = translate_percentage_to_dbm(padapter->recvpriv.
+							    signal_strength);
+
+		sinfo->filled |= STATION_INFO_TX_BITRATE;
+		sinfo->txrate.legacy = rtw_get_cur_max_rate23a(padapter);
+
+		sinfo->filled |= STATION_INFO_RX_PACKETS;
+		sinfo->rx_packets = sta_rx_data_pkts(psta);
+
+		sinfo->filled |= STATION_INFO_TX_PACKETS;
+		sinfo->tx_packets = psta->sta_stats.tx_pkts;
+	}
+
+	/* for Ad-Hoc/AP mode */
+	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_STATE) ||
+	     check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE) ||
+	     check_fwstate(pmlmepriv, WIFI_AP_STATE)) &&
+	    check_fwstate(pmlmepriv, _FW_LINKED)
+	    ) {
+		/* TODO: should acquire station info... */
+	}
+
+exit:
+	return ret;
+}
+
+static int cfg80211_rtw_change_iface(struct wiphy *wiphy,
+				     struct net_device *ndev,
+				     enum nl80211_iftype type, u32 *flags,
+				     struct vif_params *params)
+{
+	enum nl80211_iftype old_type;
+	enum ndis_802_11_net_infra networkType;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+	struct wireless_dev *rtw_wdev = wiphy_to_wdev(wiphy);
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+#endif
+	int ret = 0;
+	u8 change = false;
+
+	DBG_8723A(FUNC_NDEV_FMT " call netdev_open23a\n", FUNC_NDEV_ARG(ndev));
+	if (netdev_open23a(ndev) != 0) {
+		ret = -EPERM;
+		goto exit;
+	}
+
+	if (_FAIL == rtw_pwr_wakeup(padapter)) {
+		ret = -EPERM;
+		goto exit;
+	}
+
+	old_type = rtw_wdev->iftype;
+	DBG_8723A(FUNC_NDEV_FMT " old_iftype =%d, new_iftype =%d\n",
+		  FUNC_NDEV_ARG(ndev), old_type, type);
+
+	if (old_type != type) {
+		change = true;
+		pmlmeext->action_public_rxseq = 0xffff;
+		pmlmeext->action_public_dialog_token = 0xff;
+	}
+
+	switch (type) {
+	case NL80211_IFTYPE_ADHOC:
+		networkType = Ndis802_11IBSS;
+		break;
+	case NL80211_IFTYPE_P2P_CLIENT:
+	case NL80211_IFTYPE_STATION:
+		networkType = Ndis802_11Infrastructure;
+#ifdef CONFIG_8723AU_P2P
+		if (change && rtw_p2p_chk_role(pwdinfo, P2P_ROLE_GO)) {
+			del_timer_sync(&pwdinfo->find_phase_timer);
+			del_timer_sync(&pwdinfo->restore_p2p_state_timer);
+			del_timer_sync(&pwdinfo->pre_tx_scan_timer);
+
+			/* it means remove GO and change mode from AP(GO)
+			   to station(P2P DEVICE) */
+			rtw_p2p_set_role(pwdinfo, P2P_ROLE_DEVICE);
+			rtw_p2p_set_state(pwdinfo, rtw_p2p_pre_state(pwdinfo));
+
+			DBG_8723A("%s, role =%d, p2p_state =%d, pre_p2p_state ="
+				  "%d\n", __func__, rtw_p2p_role(pwdinfo),
+				  rtw_p2p_state(pwdinfo),
+				  rtw_p2p_pre_state(pwdinfo));
+		}
+#endif /* CONFIG_8723AU_P2P */
+		break;
+	case NL80211_IFTYPE_P2P_GO:
+	case NL80211_IFTYPE_AP:
+		networkType = Ndis802_11APMode;
+#ifdef CONFIG_8723AU_P2P
+		if (change && !rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
+			/* it means P2P Group created, we will be GO
+			   and change mode from  P2P DEVICE to AP(GO) */
+			rtw_p2p_set_role(pwdinfo, P2P_ROLE_GO);
+		}
+#endif /* CONFIG_8723AU_P2P */
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	rtw_wdev->iftype = type;
+
+	if (rtw_set_802_11_infrastructure_mode23a(padapter, networkType) == false) {
+		rtw_wdev->iftype = old_type;
+		ret = -EPERM;
+		goto exit;
+	}
+
+	rtw_setopmode_cmd23a(padapter, networkType);
+
+exit:
+	return ret;
+}
+
+void rtw_cfg80211_indicate_scan_done(struct rtw_wdev_priv *pwdev_priv,
+				     bool aborted)
+{
+	spin_lock_bh(&pwdev_priv->scan_req_lock);
+	if (pwdev_priv->scan_request != NULL) {
+#ifdef CONFIG_DEBUG_CFG80211
+		DBG_8723A("%s with scan req\n", __func__);
+#endif
+		if (pwdev_priv->scan_request->wiphy !=
+		    pwdev_priv->rtw_wdev->wiphy)
+			DBG_8723A("error wiphy compare\n");
+		else
+			cfg80211_scan_done(pwdev_priv->scan_request, aborted);
+
+		pwdev_priv->scan_request = NULL;
+	} else {
+#ifdef CONFIG_DEBUG_CFG80211
+		DBG_8723A("%s without scan req\n", __func__);
+#endif
+	}
+	spin_unlock_bh(&pwdev_priv->scan_req_lock);
+}
+
+void rtw_cfg80211_surveydone_event_callback(struct rtw_adapter *padapter)
+{
+	struct list_head *plist, *phead, *ptmp;
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct rtw_queue *queue = &pmlmepriv->scanned_queue;
+	struct wlan_network *pnetwork;
+
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A("%s\n", __func__);
+#endif
+
+	spin_lock_bh(&pmlmepriv->scanned_queue.lock);
+
+	phead = get_list_head(queue);
+
+	list_for_each_safe(plist, ptmp, phead) {
+		pnetwork = container_of(plist, struct wlan_network, list);
+
+		/* report network only if the current channel set
+		   contains the channel to which this network belongs */
+		if (rtw_ch_set_search_ch23a
+		    (padapter->mlmeextpriv.channel_set,
+		     pnetwork->network.Configuration.DSConfig) >= 0)
+			rtw_cfg80211_inform_bss(padapter, pnetwork);
+	}
+
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
+
+	/* call this after other things have been done */
+	rtw_cfg80211_indicate_scan_done(wdev_to_priv(padapter->rtw_wdev),
+					false);
+}
+
+static int rtw_cfg80211_set_probe_req_wpsp2pie(struct rtw_adapter *padapter,
+					       char *buf, int len)
+{
+	int ret = 0;
+	uint wps_ielen = 0;
+	u8 *wps_ie;
+	u32 p2p_ielen = 0;
+	u8 *p2p_ie;
+	u32 wfd_ielen = 0;
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A("%s, ielen =%d\n", __func__, len);
+#endif
+
+	if (len > 0) {
+		wps_ie = rtw_get_wps_ie23a(buf, len, NULL, &wps_ielen);
+		if (wps_ie) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("probe_req_wps_ielen =%d\n", wps_ielen);
+#endif
+			if (pmlmepriv->wps_probe_req_ie) {
+				pmlmepriv->wps_probe_req_ie_len = 0;
+				kfree(pmlmepriv->wps_probe_req_ie);
+				pmlmepriv->wps_probe_req_ie = NULL;
+			}
+
+			pmlmepriv->wps_probe_req_ie =
+				kmalloc(wps_ielen, GFP_KERNEL);
+			if (pmlmepriv->wps_probe_req_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+			}
+			memcpy(pmlmepriv->wps_probe_req_ie, wps_ie, wps_ielen);
+			pmlmepriv->wps_probe_req_ie_len = wps_ielen;
+		}
+#ifdef CONFIG_8723AU_P2P
+		p2p_ie = rtw_get_p2p_ie23a(buf, len, NULL, &p2p_ielen);
+		if (p2p_ie) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("probe_req_p2p_ielen =%d\n", p2p_ielen);
+#endif
+
+			if (pmlmepriv->p2p_probe_req_ie) {
+				pmlmepriv->p2p_probe_req_ie_len = 0;
+				kfree(pmlmepriv->p2p_probe_req_ie);
+				pmlmepriv->p2p_probe_req_ie = NULL;
+			}
+
+			pmlmepriv->p2p_probe_req_ie =
+				kmalloc(p2p_ielen, GFP_KERNEL);
+			if (pmlmepriv->p2p_probe_req_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+
+			}
+			memcpy(pmlmepriv->p2p_probe_req_ie, p2p_ie, p2p_ielen);
+			pmlmepriv->p2p_probe_req_ie_len = p2p_ielen;
+		}
+#endif /* CONFIG_8723AU_P2P */
+
+		/* buf += p2p_ielen; */
+		/* len -= p2p_ielen; */
+
+#ifdef CONFIG_8723AU_P2P
+		if (rtw_get_wfd_ie(buf, len, NULL, &wfd_ielen)) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("probe_req_wfd_ielen =%d\n", wfd_ielen);
+#endif
+
+			if (pmlmepriv->wfd_probe_req_ie) {
+				pmlmepriv->wfd_probe_req_ie_len = 0;
+				kfree(pmlmepriv->wfd_probe_req_ie);
+				pmlmepriv->wfd_probe_req_ie = NULL;
+			}
+
+			pmlmepriv->wfd_probe_req_ie =
+				kmalloc(wfd_ielen, GFP_KERNEL);
+			if (pmlmepriv->wfd_probe_req_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+
+			}
+			rtw_get_wfd_ie(buf, len, pmlmepriv->wfd_probe_req_ie,
+				       &pmlmepriv->wfd_probe_req_ie_len);
+		}
+#endif /* CONFIG_8723AU_P2P */
+
+	}
+
+	return ret;
+}
+
+static int cfg80211_rtw_scan(struct wiphy *wiphy,
+			     struct cfg80211_scan_request *request)
+{
+	int i;
+	u8 _status = false;
+	int ret = 0;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct cfg80211_ssid ssid[RTW_SSID_SCAN_AMOUNT];
+	struct rtw_ieee80211_channel ch[RTW_CHANNEL_SCAN_AMOUNT];
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+#endif /* CONFIG_8723AU_P2P */
+	struct rtw_wdev_priv *pwdev_priv = wdev_to_priv(padapter->rtw_wdev);
+	struct cfg80211_ssid *ssids = request->ssids;
+	int social_channel = 0;
+	bool need_indicate_scan_done = false;
+
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A(FUNC_ADPT_FMT "\n", FUNC_ADPT_ARG(padapter));
+#endif
+
+	spin_lock_bh(&pwdev_priv->scan_req_lock);
+	pwdev_priv->scan_request = request;
+	spin_unlock_bh(&pwdev_priv->scan_req_lock);
+
+	if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
+
+#ifdef CONFIG_DEBUG_CFG80211
+		DBG_8723A("%s under WIFI_AP_STATE\n", __func__);
+#endif
+		/* need_indicate_scan_done = true; */
+		/* goto check_need_indicate_scan_done; */
+	}
+
+	if (rtw_pwr_wakeup(padapter) == _FAIL) {
+		need_indicate_scan_done = true;
+		goto check_need_indicate_scan_done;
+	}
+#ifdef CONFIG_8723AU_P2P
+	if (ssids->ssid != NULL &&
+	    !memcmp(ssids->ssid, "DIRECT-", 7) &&
+	    rtw_get_p2p_ie23a((u8 *) request->ie, request->ie_len, NULL, NULL)) {
+		if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
+			rtw_p2p_enable23a(padapter, P2P_ROLE_DEVICE);
+			wdev_to_priv(padapter->rtw_wdev)->p2p_enabled = true;
+		} else {
+			rtw_p2p_set_pre_state(pwdinfo, rtw_p2p_state(pwdinfo));
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("%s, role =%d, p2p_state =%d\n", __func__,
+				  rtw_p2p_role(pwdinfo),
+				  rtw_p2p_state(pwdinfo));
+#endif
+		}
+		rtw_p2p_set_state(pwdinfo, P2P_STATE_LISTEN);
+
+		if (request->n_channels == 3 &&
+		    request->channels[0]->hw_value == 1 &&
+		    request->channels[1]->hw_value == 6 &&
+		    request->channels[2]->hw_value == 11)
+			social_channel = 1;
+	}
+#endif /* CONFIG_8723AU_P2P */
+
+	if (request->ie && request->ie_len > 0) {
+		rtw_cfg80211_set_probe_req_wpsp2pie(padapter,
+						    (u8 *) request->ie,
+						    request->ie_len);
+	}
+
+	if (pmlmepriv->LinkDetectInfo.bBusyTraffic == true) {
+		DBG_8723A("%s, bBusyTraffic == true\n", __func__);
+		need_indicate_scan_done = true;
+		goto check_need_indicate_scan_done;
+	}
+	if (rtw_is_scan_deny(padapter)) {
+		DBG_8723A(FUNC_ADPT_FMT ": scan deny\n",
+			  FUNC_ADPT_ARG(padapter));
+		need_indicate_scan_done = true;
+		goto check_need_indicate_scan_done;
+	}
+
+	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY | _FW_UNDER_LINKING) ==
+	    true) {
+		DBG_8723A("%s, fwstate = 0x%x\n", __func__, pmlmepriv->fw_state);
+		need_indicate_scan_done = true;
+		goto check_need_indicate_scan_done;
+	}
+#ifdef CONFIG_8723AU_P2P
+	if (!rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE) &&
+	    !rtw_p2p_chk_state(pwdinfo, P2P_STATE_IDLE)) {
+		rtw_p2p_set_state(pwdinfo, P2P_STATE_FIND_PHASE_SEARCH);
+		rtw_free_network_queue23a(padapter, true);
+
+		if (social_channel == 0)
+			rtw_p2p_findphase_ex_set(pwdinfo,
+						 P2P_FINDPHASE_EX_NONE);
+		else
+			rtw_p2p_findphase_ex_set(pwdinfo,
+						 P2P_FINDPHASE_EX_SOCIAL_LAST);
+	}
+#endif /* CONFIG_8723AU_P2P */
+
+	memset(ssid, 0, sizeof(struct cfg80211_ssid) * RTW_SSID_SCAN_AMOUNT);
+	/* parsing request ssids, n_ssids */
+	for (i = 0; i < request->n_ssids && i < RTW_SSID_SCAN_AMOUNT; i++) {
+#ifdef CONFIG_DEBUG_CFG80211
+		DBG_8723A("ssid =%s, len =%d\n", ssids[i].ssid,
+			  ssids[i].ssid_len);
+#endif
+		memcpy(ssid[i].ssid, ssids[i].ssid, ssids[i].ssid_len);
+		ssid[i].ssid_len = ssids[i].ssid_len;
+	}
+
+	/* parsing channels, n_channels */
+	memset(ch, 0,
+	       sizeof(struct rtw_ieee80211_channel) * RTW_CHANNEL_SCAN_AMOUNT);
+
+	if (request->n_channels == 1) {
+		for (i = 0; i < request->n_channels &&
+		     i < RTW_CHANNEL_SCAN_AMOUNT; i++) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A(FUNC_ADPT_FMT CHAN_FMT "\n",
+				  FUNC_ADPT_ARG(padapter),
+				  CHAN_ARG(request->channels[i]));
+#endif
+			ch[i].hw_value = request->channels[i]->hw_value;
+			ch[i].flags = request->channels[i]->flags;
+		}
+	}
+
+	spin_lock_bh(&pmlmepriv->lock);
+	if (request->n_channels == 1) {
+		memcpy(&ch[1], &ch[0], sizeof(struct rtw_ieee80211_channel));
+		memcpy(&ch[2], &ch[0], sizeof(struct rtw_ieee80211_channel));
+		_status = rtw_sitesurvey_cmd23a(padapter, ssid,
+					     RTW_SSID_SCAN_AMOUNT, ch, 3);
+	} else {
+		_status = rtw_sitesurvey_cmd23a(padapter, ssid,
+					     RTW_SSID_SCAN_AMOUNT, NULL, 0);
+	}
+	spin_unlock_bh(&pmlmepriv->lock);
+
+	if (_status == false)
+		ret = -1;
+
+check_need_indicate_scan_done:
+	if (need_indicate_scan_done)
+		rtw_cfg80211_surveydone_event_callback(padapter);
+	return ret;
+}
+
+static int cfg80211_rtw_set_wiphy_params(struct wiphy *wiphy, u32 changed)
+{
+	DBG_8723A("%s\n", __func__);
+	return 0;
+}
+
+static int cfg80211_rtw_join_ibss(struct wiphy *wiphy, struct net_device *ndev,
+				  struct cfg80211_ibss_params *params)
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+	return 0;
+}
+
+static int cfg80211_rtw_leave_ibss(struct wiphy *wiphy, struct net_device *ndev)
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+	return 0;
+}
+
+static int rtw_cfg80211_set_wpa_version(struct security_priv *psecuritypriv,
+					u32 wpa_version)
+{
+	DBG_8723A("%s, wpa_version =%d\n", __func__, wpa_version);
+
+	if (!wpa_version) {
+		psecuritypriv->ndisauthtype = Ndis802_11AuthModeOpen;
+		return 0;
+	}
+
+	if (wpa_version & (NL80211_WPA_VERSION_1 | NL80211_WPA_VERSION_2)) {
+		psecuritypriv->ndisauthtype = Ndis802_11AuthModeWPAPSK;
+	}
+
+/*
+	if (wpa_version & NL80211_WPA_VERSION_2)
+	{
+		psecuritypriv->ndisauthtype = Ndis802_11AuthModeWPA2PSK;
+	}
+*/
+
+	return 0;
+}
+
+static int rtw_cfg80211_set_auth_type(struct security_priv *psecuritypriv,
+				      enum nl80211_auth_type sme_auth_type)
+{
+	DBG_8723A("%s, nl80211_auth_type =%d\n", __func__, sme_auth_type);
+
+	switch (sme_auth_type) {
+	case NL80211_AUTHTYPE_AUTOMATIC:
+		psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_Auto;
+
+		break;
+	case NL80211_AUTHTYPE_OPEN_SYSTEM:
+		psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_Open;
+
+		if (psecuritypriv->ndisauthtype > Ndis802_11AuthModeWPA)
+			psecuritypriv->dot11AuthAlgrthm =
+				dot11AuthAlgrthm_8021X;
+		break;
+	case NL80211_AUTHTYPE_SHARED_KEY:
+		psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_Shared;
+
+		psecuritypriv->ndisencryptstatus = Ndis802_11Encryption1Enabled;
+		break;
+	default:
+		psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_Open;
+		/* return -ENOTSUPP; */
+	}
+
+	return 0;
+}
+
+static int rtw_cfg80211_set_cipher(struct security_priv *psecuritypriv,
+				   u32 cipher, bool ucast)
+{
+	u32 ndisencryptstatus = Ndis802_11EncryptionDisabled;
+
+	u32 *profile_cipher = ucast ? &psecuritypriv->dot11PrivacyAlgrthm :
+	    &psecuritypriv->dot118021XGrpPrivacy;
+
+	DBG_8723A("%s, ucast =%d, cipher = 0x%x\n", __func__, ucast, cipher);
+
+	if (!cipher) {
+		*profile_cipher = _NO_PRIVACY_;
+		psecuritypriv->ndisencryptstatus = ndisencryptstatus;
+		return 0;
+	}
+
+	switch (cipher) {
+	case IW_AUTH_CIPHER_NONE:
+		*profile_cipher = _NO_PRIVACY_;
+		ndisencryptstatus = Ndis802_11EncryptionDisabled;
+		break;
+	case WLAN_CIPHER_SUITE_WEP40:
+		*profile_cipher = _WEP40_;
+		ndisencryptstatus = Ndis802_11Encryption1Enabled;
+		break;
+	case WLAN_CIPHER_SUITE_WEP104:
+		*profile_cipher = _WEP104_;
+		ndisencryptstatus = Ndis802_11Encryption1Enabled;
+		break;
+	case WLAN_CIPHER_SUITE_TKIP:
+		*profile_cipher = _TKIP_;
+		ndisencryptstatus = Ndis802_11Encryption2Enabled;
+		break;
+	case WLAN_CIPHER_SUITE_CCMP:
+		*profile_cipher = _AES_;
+		ndisencryptstatus = Ndis802_11Encryption3Enabled;
+		break;
+	default:
+		DBG_8723A("Unsupported cipher: 0x%x\n", cipher);
+		return -ENOTSUPP;
+	}
+
+	if (ucast)
+		psecuritypriv->ndisencryptstatus = ndisencryptstatus;
+
+	return 0;
+}
+
+static int rtw_cfg80211_set_key_mgt(struct security_priv *psecuritypriv,
+				    u32 key_mgt)
+{
+	DBG_8723A("%s, key_mgt = 0x%x\n", __func__, key_mgt);
+
+	if (key_mgt == WLAN_AKM_SUITE_8021X)
+		psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_8021X;
+	else if (key_mgt == WLAN_AKM_SUITE_PSK)
+		psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_8021X;
+	else
+		DBG_8723A("Invalid key mgt: 0x%x\n", key_mgt);
+
+	return 0;
+}
+
+static int rtw_cfg80211_set_wpa_ie(struct rtw_adapter *padapter, const u8 *pie,
+				   size_t ielen)
+{
+	u8 *buf = NULL, *pos = NULL;
+	int group_cipher = 0, pairwise_cipher = 0;
+	int ret = 0;
+	int wpa_ielen = 0;
+	int wpa2_ielen = 0;
+	u8 *pwpa, *pwpa2;
+	u8 null_addr[] = { 0, 0, 0, 0, 0, 0 };
+	int i;
+
+	if (!pie || !ielen) {
+		/* Treat this as normal case, but need to clear
+		   WIFI_UNDER_WPS */
+		_clr_fwstate_(&padapter->mlmepriv, WIFI_UNDER_WPS);
+		goto exit;
+	}
+	if (ielen > MAX_WPA_IE_LEN + MAX_WPS_IE_LEN + MAX_P2P_IE_LEN) {
+		ret = -EINVAL;
+		goto exit;
+	}
+	buf = kzalloc(ielen, GFP_KERNEL);
+	if (buf == NULL) {
+		ret = -ENOMEM;
+		goto exit;
+	}
+	memcpy(buf, pie, ielen);
+
+	/* dump */
+	DBG_8723A("set wpa_ie(length:%zu):\n", ielen);
+	for (i = 0; i < ielen; i = i + 8)
+		DBG_8723A("0x%.2x 0x%.2x 0x%.2x 0x%.2x 0x%.2x 0x%.2x 0x%.2x 0x%.2x\n",
+			  buf[i], buf[i + 1],
+			  buf[i + 2], buf[i + 3], buf[i + 4],
+			  buf[i + 5], buf[i + 6], buf[i + 7]);
+	pos = buf;
+	if (ielen < RSN_HEADER_LEN) {
+		RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_err_,
+			 ("Ie len too short %d\n", (int)ielen));
+		ret = -1;
+		goto exit;
+	}
+
+	pwpa = rtw_get_wpa_ie23a(buf, &wpa_ielen, ielen);
+	if (pwpa && wpa_ielen > 0) {
+		if (rtw_parse_wpa_ie23a(pwpa, wpa_ielen + 2, &group_cipher,
+				     &pairwise_cipher, NULL) == _SUCCESS) {
+			padapter->securitypriv.dot11AuthAlgrthm =
+				dot11AuthAlgrthm_8021X;
+			padapter->securitypriv.ndisauthtype =
+				Ndis802_11AuthModeWPAPSK;
+			memcpy(padapter->securitypriv.supplicant_ie, &pwpa[0],
+			       wpa_ielen + 2);
+
+			DBG_8723A("got wpa_ie, wpa_ielen:%u\n", wpa_ielen);
+		}
+	}
+
+	pwpa2 = rtw_get_wpa2_ie23a(buf, &wpa2_ielen, ielen);
+	if (pwpa2 && wpa2_ielen > 0) {
+		if (rtw_parse_wpa2_ie23a (pwpa2, wpa2_ielen + 2, &group_cipher,
+				       &pairwise_cipher, NULL) == _SUCCESS) {
+			padapter->securitypriv.dot11AuthAlgrthm =
+				dot11AuthAlgrthm_8021X;
+			padapter->securitypriv.ndisauthtype =
+				Ndis802_11AuthModeWPA2PSK;
+			memcpy(padapter->securitypriv.supplicant_ie, &pwpa2[0],
+			       wpa2_ielen + 2);
+
+			DBG_8723A("got wpa2_ie, wpa2_ielen:%u\n", wpa2_ielen);
+		}
+	}
+
+	if (group_cipher == 0) {
+		group_cipher = WPA_CIPHER_NONE;
+	}
+	if (pairwise_cipher == 0) {
+		pairwise_cipher = WPA_CIPHER_NONE;
+	}
+
+	switch (group_cipher) {
+	case WPA_CIPHER_NONE:
+		padapter->securitypriv.dot118021XGrpPrivacy = _NO_PRIVACY_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11EncryptionDisabled;
+		break;
+	case WPA_CIPHER_WEP40:
+		padapter->securitypriv.dot118021XGrpPrivacy = _WEP40_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption1Enabled;
+		break;
+	case WPA_CIPHER_TKIP:
+		padapter->securitypriv.dot118021XGrpPrivacy = _TKIP_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption2Enabled;
+		break;
+	case WPA_CIPHER_CCMP:
+		padapter->securitypriv.dot118021XGrpPrivacy = _AES_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption3Enabled;
+		break;
+	case WPA_CIPHER_WEP104:
+		padapter->securitypriv.dot118021XGrpPrivacy = _WEP104_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption1Enabled;
+		break;
+	}
+
+	switch (pairwise_cipher) {
+	case WPA_CIPHER_NONE:
+		padapter->securitypriv.dot11PrivacyAlgrthm = _NO_PRIVACY_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11EncryptionDisabled;
+		break;
+	case WPA_CIPHER_WEP40:
+		padapter->securitypriv.dot11PrivacyAlgrthm = _WEP40_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption1Enabled;
+		break;
+	case WPA_CIPHER_TKIP:
+		padapter->securitypriv.dot11PrivacyAlgrthm = _TKIP_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption2Enabled;
+		break;
+	case WPA_CIPHER_CCMP:
+		padapter->securitypriv.dot11PrivacyAlgrthm = _AES_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption3Enabled;
+		break;
+	case WPA_CIPHER_WEP104:
+		padapter->securitypriv.dot11PrivacyAlgrthm = _WEP104_;
+		padapter->securitypriv.ndisencryptstatus =
+			Ndis802_11Encryption1Enabled;
+		break;
+	}
+
+	{			/* handle wps_ie */
+		uint wps_ielen;
+		u8 *wps_ie;
+
+		wps_ie = rtw_get_wps_ie23a(buf, ielen, NULL, &wps_ielen);
+		if (wps_ie && wps_ielen > 0) {
+			DBG_8723A("got wps_ie, wps_ielen:%u\n", wps_ielen);
+			padapter->securitypriv.wps_ie_len =
+				wps_ielen <
+				MAX_WPS_IE_LEN ? wps_ielen : MAX_WPS_IE_LEN;
+			memcpy(padapter->securitypriv.wps_ie, wps_ie,
+			       padapter->securitypriv.wps_ie_len);
+			set_fwstate(&padapter->mlmepriv, WIFI_UNDER_WPS);
+		} else {
+			_clr_fwstate_(&padapter->mlmepriv, WIFI_UNDER_WPS);
+		}
+	}
+
+#ifdef CONFIG_8723AU_P2P
+	{			/* check p2p_ie for assoc req; */
+		uint p2p_ielen = 0;
+		u8 *p2p_ie;
+		struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+		p2p_ie = rtw_get_p2p_ie23a(buf, ielen, NULL, &p2p_ielen);
+		if (p2p_ie) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("%s p2p_assoc_req_ielen =%d\n", __func__,
+				  p2p_ielen);
+#endif
+
+			if (pmlmepriv->p2p_assoc_req_ie) {
+				pmlmepriv->p2p_assoc_req_ie_len = 0;
+				kfree(pmlmepriv->p2p_assoc_req_ie);
+				pmlmepriv->p2p_assoc_req_ie = NULL;
+			}
+
+			pmlmepriv->p2p_assoc_req_ie =
+				kmalloc(p2p_ielen, GFP_KERNEL);
+			if (pmlmepriv->p2p_assoc_req_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				goto exit;
+			}
+			memcpy(pmlmepriv->p2p_assoc_req_ie, p2p_ie, p2p_ielen);
+			pmlmepriv->p2p_assoc_req_ie_len = p2p_ielen;
+		}
+	}
+#endif /* CONFIG_8723AU_P2P */
+
+#ifdef CONFIG_8723AU_P2P
+	{			/* check wfd_ie for assoc req; */
+		uint wfd_ielen = 0;
+		struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+		if (rtw_get_wfd_ie(buf, ielen, NULL, &wfd_ielen)) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("%s wfd_assoc_req_ielen =%d\n", __func__,
+				  wfd_ielen);
+#endif
+
+			if (pmlmepriv->wfd_assoc_req_ie) {
+				pmlmepriv->wfd_assoc_req_ie_len = 0;
+				kfree(pmlmepriv->wfd_assoc_req_ie);
+				pmlmepriv->wfd_assoc_req_ie = NULL;
+			}
+
+			pmlmepriv->wfd_assoc_req_ie =
+				kmalloc(wfd_ielen, GFP_KERNEL);
+			if (pmlmepriv->wfd_assoc_req_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				goto exit;
+			}
+			rtw_get_wfd_ie(buf, ielen, pmlmepriv->wfd_assoc_req_ie,
+				       &pmlmepriv->wfd_assoc_req_ie_len);
+		}
+	}
+#endif /* CONFIG_8723AU_P2P */
+
+	/* TKIP and AES disallow multicast packets until installing group key */
+	if (padapter->securitypriv.dot11PrivacyAlgrthm == _TKIP_ ||
+	    padapter->securitypriv.dot11PrivacyAlgrthm == _TKIP_WTMIC_ ||
+	    padapter->securitypriv.dot11PrivacyAlgrthm == _AES_)
+		/* WPS open need to enable multicast */
+		/* check_fwstate(&padapter->mlmepriv, WIFI_UNDER_WPS) == true)*/
+		rtw_hal_set_hwreg23a(padapter, HW_VAR_OFF_RCR_AM, null_addr);
+
+	RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_info_,
+		 ("rtw_set_wpa_ie: pairwise_cipher = 0x%08x padapter->"
+		  "securitypriv.ndisencryptstatus =%d padapter->"
+		  "securitypriv.ndisauthtype =%d\n", pairwise_cipher,
+		  padapter->securitypriv.ndisencryptstatus,
+		  padapter->securitypriv.ndisauthtype));
+
+exit:
+	kfree(buf);
+	if (ret)
+		_clr_fwstate_(&padapter->mlmepriv, WIFI_UNDER_WPS);
+	return ret;
+}
+
+static int cfg80211_rtw_connect(struct wiphy *wiphy, struct net_device *ndev,
+				struct cfg80211_connect_params *sme)
+{
+	int ret = 0;
+	struct list_head *phead, *plist, *ptmp;
+	struct wlan_network *pnetwork = NULL;
+	enum ndis_802_11_auth_mode authmode;
+	struct cfg80211_ssid ndis_ssid;
+	u8 *dst_ssid;
+	u8 *src_ssid;
+	u8 *dst_bssid;
+	const u8 *src_bssid;
+	/* u8 matched_by_bssid = false; */
+	/* u8 matched_by_ssid = false; */
+	u8 matched = false;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+	struct rtw_queue *queue = &pmlmepriv->scanned_queue;
+
+	DBG_8723A("=>" FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+	DBG_8723A("privacy =%d, key =%p, key_len =%d, key_idx =%d\n",
+		  sme->privacy, sme->key, sme->key_len, sme->key_idx);
+
+	if (wdev_to_priv(padapter->rtw_wdev)->block) {
+		ret = -EBUSY;
+		DBG_8723A("%s wdev_priv.block is set\n", __func__);
+		goto exit;
+	}
+
+	if (_FAIL == rtw_pwr_wakeup(padapter)) {
+		ret = -EPERM;
+		goto exit;
+	}
+
+	if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
+		ret = -EPERM;
+		goto exit;
+	}
+
+	if (!sme->ssid || !sme->ssid_len) {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	if (sme->ssid_len > IW_ESSID_MAX_SIZE) {
+		ret = -E2BIG;
+		goto exit;
+	}
+
+	memset(&ndis_ssid, 0, sizeof(struct cfg80211_ssid));
+	ndis_ssid.ssid_len = sme->ssid_len;
+	memcpy(ndis_ssid.ssid, sme->ssid, sme->ssid_len);
+
+	DBG_8723A("ssid =%s, len =%zu\n", ndis_ssid.ssid, sme->ssid_len);
+
+	if (sme->bssid)
+		DBG_8723A("bssid =" MAC_FMT "\n", MAC_ARG(sme->bssid));
+
+	if (check_fwstate(pmlmepriv, _FW_UNDER_LINKING)) {
+		ret = -EBUSY;
+		DBG_8723A("%s, fw_state = 0x%x, goto exit\n", __func__,
+			  pmlmepriv->fw_state);
+		goto exit;
+	}
+	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY)) {
+		rtw_scan_abort23a(padapter);
+	}
+
+	spin_lock_bh(&queue->lock);
+
+	phead = get_list_head(queue);
+
+	list_for_each_safe(plist, ptmp, phead) {
+		pnetwork = container_of(plist, struct wlan_network, list);
+
+		dst_ssid = pnetwork->network.Ssid.ssid;
+		dst_bssid = pnetwork->network.MacAddress;
+
+		if (sme->bssid) {
+			if (memcmp(pnetwork->network.MacAddress,
+				   sme->bssid, ETH_ALEN))
+				continue;
+		}
+
+		if (sme->ssid && sme->ssid_len) {
+			if (pnetwork->network.Ssid.ssid_len != sme->ssid_len ||
+			    memcmp(pnetwork->network.Ssid.ssid, sme->ssid,
+				   sme->ssid_len))
+				continue;
+		}
+
+		if (sme->bssid) {
+			src_bssid = sme->bssid;
+
+			if ((!memcmp(dst_bssid, src_bssid, ETH_ALEN))) {
+				DBG_8723A("matched by bssid\n");
+
+				ndis_ssid.ssid_len =
+				    pnetwork->network.Ssid.ssid_len;
+				memcpy(ndis_ssid.ssid,
+				       pnetwork->network.Ssid.ssid,
+				       pnetwork->network.Ssid.ssid_len);
+
+				matched = true;
+				break;
+			}
+
+		} else if (sme->ssid && sme->ssid_len) {
+			src_ssid = ndis_ssid.ssid;
+
+			if ((!memcmp(dst_ssid, src_ssid, ndis_ssid.ssid_len)) &&
+			    (pnetwork->network.Ssid.ssid_len ==
+			     ndis_ssid.ssid_len)) {
+				DBG_8723A("matched by ssid\n");
+				matched = true;
+				break;
+			}
+		}
+	}
+
+	spin_unlock_bh(&queue->lock);
+
+	if (!matched || (pnetwork == NULL)) {
+		ret = -ENOENT;
+		DBG_8723A("connect, matched == false, goto exit\n");
+		goto exit;
+	}
+
+	if (rtw_set_802_11_infrastructure_mode23a
+	    (padapter, pnetwork->network.InfrastructureMode) == false) {
+		ret = -EPERM;
+		goto exit;
+	}
+
+	psecuritypriv->ndisencryptstatus = Ndis802_11EncryptionDisabled;
+	psecuritypriv->dot11PrivacyAlgrthm = _NO_PRIVACY_;
+	psecuritypriv->dot118021XGrpPrivacy = _NO_PRIVACY_;
+	psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_Open;
+	psecuritypriv->ndisauthtype = Ndis802_11AuthModeOpen;
+
+	ret =
+	    rtw_cfg80211_set_wpa_version(psecuritypriv,
+					 sme->crypto.wpa_versions);
+	if (ret < 0)
+		goto exit;
+
+	ret = rtw_cfg80211_set_auth_type(psecuritypriv, sme->auth_type);
+
+	if (ret < 0)
+		goto exit;
+
+	DBG_8723A("%s, ie_len =%zu\n", __func__, sme->ie_len);
+
+	ret = rtw_cfg80211_set_wpa_ie(padapter, sme->ie, sme->ie_len);
+	if (ret < 0)
+		goto exit;
+
+	if (sme->crypto.n_ciphers_pairwise) {
+		ret = rtw_cfg80211_set_cipher(psecuritypriv,
+					      sme->crypto.ciphers_pairwise[0],
+					      true);
+		if (ret < 0)
+			goto exit;
+	}
+
+	/* For WEP Shared auth */
+	if ((psecuritypriv->dot11AuthAlgrthm == dot11AuthAlgrthm_Shared ||
+	     psecuritypriv->dot11AuthAlgrthm == dot11AuthAlgrthm_Auto) &&
+	    sme->key) {
+		u32 wep_key_idx, wep_key_len, wep_total_len;
+		struct ndis_802_11_wep *pwep = NULL;
+		DBG_8723A("%s(): Shared/Auto WEP\n", __func__);
+
+		wep_key_idx = sme->key_idx;
+		wep_key_len = sme->key_len;
+
+		if (sme->key_idx > WEP_KEYS) {
+			ret = -EINVAL;
+			goto exit;
+		}
+
+		if (wep_key_len > 0) {
+			wep_key_len = wep_key_len <= 5 ? 5 : 13;
+			wep_total_len =
+				wep_key_len +
+				offsetof(struct ndis_802_11_wep, KeyMaterial);
+			pwep = (struct ndis_802_11_wep *)kmalloc(wep_total_len,
+								 GFP_KERNEL);
+			if (pwep == NULL) {
+				DBG_8723A(" wpa_set_encryption: pwep "
+					  "allocate fail !!!\n");
+				ret = -ENOMEM;
+				goto exit;
+			}
+
+			memset(pwep, 0, wep_total_len);
+
+			pwep->KeyLength = wep_key_len;
+			pwep->Length = wep_total_len;
+
+			if (wep_key_len == 13) {
+				padapter->securitypriv.dot11PrivacyAlgrthm =
+				    _WEP104_;
+				padapter->securitypriv.dot118021XGrpPrivacy =
+				    _WEP104_;
+			}
+		} else {
+			ret = -EINVAL;
+			goto exit;
+		}
+
+		pwep->KeyIndex = wep_key_idx;
+		pwep->KeyIndex |= 0x80000000;
+
+		memcpy(pwep->KeyMaterial, (void *)sme->key, pwep->KeyLength);
+
+		if (rtw_set_802_11_add_wep23a(padapter, pwep) == (u8) _FAIL) {
+			ret = -EOPNOTSUPP;
+		}
+
+		kfree(pwep);
+
+		if (ret < 0)
+			goto exit;
+	}
+
+	ret = rtw_cfg80211_set_cipher(psecuritypriv,
+				      sme->crypto.cipher_group, false);
+	if (ret < 0)
+		return ret;
+
+	if (sme->crypto.n_akm_suites) {
+		ret = rtw_cfg80211_set_key_mgt(psecuritypriv,
+					       sme->crypto.akm_suites[0]);
+		if (ret < 0)
+			goto exit;
+	}
+
+	authmode = psecuritypriv->ndisauthtype;
+	rtw_set_802_11_authentication_mode23a(padapter, authmode);
+
+	/* rtw_set_802_11_encryption_mode(padapter,
+	   padapter->securitypriv.ndisencryptstatus); */
+
+	if (rtw_set_802_11_ssid23a(padapter, &ndis_ssid) == false) {
+		ret = -1;
+		goto exit;
+	}
+
+	DBG_8723A("set ssid:dot11AuthAlgrthm =%d, dot11PrivacyAlgrthm =%d, "
+		  "dot118021XGrpPrivacy =%d\n", psecuritypriv->dot11AuthAlgrthm,
+		  psecuritypriv->dot11PrivacyAlgrthm,
+		  psecuritypriv->dot118021XGrpPrivacy);
+
+exit:
+
+	DBG_8723A("<=%s, ret %d\n", __func__, ret);
+
+	return ret;
+}
+
+static int cfg80211_rtw_disconnect(struct wiphy *wiphy, struct net_device *ndev,
+				   u16 reason_code)
+{
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+
+	rtw_set_roaming(padapter, 0);
+
+	if (check_fwstate(&padapter->mlmepriv, _FW_LINKED)) {
+		rtw_scan_abort23a(padapter);
+		LeaveAllPowerSaveMode23a(padapter);
+		rtw_disassoc_cmd23a(padapter, 500, false);
+
+		DBG_8723A("%s...call rtw_indicate_disconnect23a\n", __func__);
+
+		padapter->mlmepriv.not_indic_disco = true;
+		rtw_indicate_disconnect23a(padapter);
+		padapter->mlmepriv.not_indic_disco = false;
+
+		rtw_free_assoc_resources23a(padapter, 1);
+	}
+
+	return 0;
+}
+
+static int cfg80211_rtw_set_txpower(struct wiphy *wiphy,
+				    struct wireless_dev *wdev,
+				    enum nl80211_tx_power_setting type, int mbm)
+{
+	DBG_8723A("%s\n", __func__);
+	return 0;
+}
+
+static int cfg80211_rtw_get_txpower(struct wiphy *wiphy,
+				    struct wireless_dev *wdev, int *dbm)
+{
+	DBG_8723A("%s\n", __func__);
+	*dbm = (12);
+	return 0;
+}
+
+inline bool rtw_cfg80211_pwr_mgmt(struct rtw_adapter *adapter)
+{
+	struct rtw_wdev_priv *rtw_wdev_priv = wdev_to_priv(adapter->rtw_wdev);
+	return rtw_wdev_priv->power_mgmt;
+}
+
+static int cfg80211_rtw_set_power_mgmt(struct wiphy *wiphy,
+				       struct net_device *ndev,
+				       bool enabled, int timeout)
+{
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct rtw_wdev_priv *rtw_wdev_priv = wdev_to_priv(padapter->rtw_wdev);
+
+	DBG_8723A(FUNC_NDEV_FMT " enabled:%u, timeout:%d\n",
+		  FUNC_NDEV_ARG(ndev), enabled, timeout);
+
+	rtw_wdev_priv->power_mgmt = enabled;
+
+	if (!enabled)
+		LPS_Leave23a(padapter);
+
+	return 0;
+}
+
+static int cfg80211_rtw_set_pmksa(struct wiphy *wiphy,
+				  struct net_device *netdev,
+				  struct cfg80211_pmksa *pmksa)
+{
+	u8 index, blInserted = false;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+	u8 strZeroMacAddress[ETH_ALEN] = { 0x00 };
+
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(netdev));
+
+	if (!memcmp(pmksa->bssid, strZeroMacAddress, ETH_ALEN)) {
+		return -EINVAL;
+	}
+
+	blInserted = false;
+
+	/* overwrite PMKID */
+	for (index = 0; index < NUM_PMKID_CACHE; index++) {
+		if (!memcmp(psecuritypriv->PMKIDList[index].Bssid,
+			    pmksa->bssid, ETH_ALEN)) {
+			/* BSSID is matched, the same AP => rewrite with
+			   new PMKID. */
+			DBG_8723A(FUNC_NDEV_FMT
+				  " BSSID exists in the PMKList.\n",
+				  FUNC_NDEV_ARG(netdev));
+
+			memcpy(psecuritypriv->PMKIDList[index].PMKID,
+			       pmksa->pmkid, WLAN_PMKID_LEN);
+			psecuritypriv->PMKIDList[index].bUsed = true;
+			psecuritypriv->PMKIDIndex = index + 1;
+			blInserted = true;
+			break;
+		}
+	}
+
+	if (!blInserted) {
+		/*  Find a new entry */
+		DBG_8723A(FUNC_NDEV_FMT
+			  " Use the new entry index = %d for this PMKID.\n",
+			  FUNC_NDEV_ARG(netdev), psecuritypriv->PMKIDIndex);
+
+		memcpy(psecuritypriv->PMKIDList[psecuritypriv->PMKIDIndex].
+		       Bssid, pmksa->bssid, ETH_ALEN);
+		memcpy(psecuritypriv->PMKIDList[psecuritypriv->PMKIDIndex].
+		       PMKID, pmksa->pmkid, WLAN_PMKID_LEN);
+
+		psecuritypriv->PMKIDList[psecuritypriv->PMKIDIndex].bUsed =
+			true;
+		psecuritypriv->PMKIDIndex++;
+		if (psecuritypriv->PMKIDIndex == 16) {
+			psecuritypriv->PMKIDIndex = 0;
+		}
+	}
+
+	return 0;
+}
+
+static int cfg80211_rtw_del_pmksa(struct wiphy *wiphy,
+				  struct net_device *netdev,
+				  struct cfg80211_pmksa *pmksa)
+{
+	u8 index, bMatched = false;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(netdev));
+
+	for (index = 0; index < NUM_PMKID_CACHE; index++) {
+		if (!memcmp(psecuritypriv->PMKIDList[index].Bssid,
+			    pmksa->bssid, ETH_ALEN)) {
+			/* BSSID is matched, the same AP => Remove this PMKID information and reset it. */
+			memset(psecuritypriv->PMKIDList[index].Bssid, 0x00,
+			       ETH_ALEN);
+			memset(psecuritypriv->PMKIDList[index].PMKID, 0x00,
+			       WLAN_PMKID_LEN);
+			psecuritypriv->PMKIDList[index].bUsed = false;
+			bMatched = true;
+			break;
+		}
+	}
+
+	if (false == bMatched) {
+		DBG_8723A(FUNC_NDEV_FMT " do not have matched BSSID\n",
+			  FUNC_NDEV_ARG(netdev));
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int cfg80211_rtw_flush_pmksa(struct wiphy *wiphy,
+				    struct net_device *netdev)
+{
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(netdev));
+
+	memset(&psecuritypriv->PMKIDList[0], 0x00,
+	       sizeof(struct rt_pmkid_list) * NUM_PMKID_CACHE);
+	psecuritypriv->PMKIDIndex = 0;
+
+	return 0;
+}
+
+#ifdef CONFIG_8723AU_AP_MODE
+void rtw_cfg80211_indicate_sta_assoc(struct rtw_adapter *padapter,
+				     u8 *pmgmt_frame, uint frame_len)
+{
+	s32 freq;
+	int channel;
+	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+	struct net_device *ndev = padapter->pnetdev;
+
+	DBG_8723A("%s(padapter =%p,%s)\n", __func__, padapter, ndev->name);
+
+#if defined(RTW_USE_CFG80211_STA_EVENT)
+	{
+		struct station_info sinfo;
+		u8 ie_offset;
+		if (ieee80211_is_assoc_req(hdr->frame_control))
+			ie_offset = _ASOCREQ_IE_OFFSET_;
+		else		/*  WIFI_REASSOCREQ */
+			ie_offset = _REASOCREQ_IE_OFFSET_;
+
+		sinfo.filled = 0;
+		sinfo.filled = STATION_INFO_ASSOC_REQ_IES;
+		sinfo.assoc_req_ies = pmgmt_frame + WLAN_HDR_A3_LEN + ie_offset;
+		sinfo.assoc_req_ies_len =
+			frame_len - WLAN_HDR_A3_LEN - ie_offset;
+		cfg80211_new_sta(ndev, hdr->addr2, &sinfo, GFP_ATOMIC);
+	}
+#else /* defined(RTW_USE_CFG80211_STA_EVENT) */
+	channel = pmlmeext->cur_channel;
+	if (channel <= RTW_CH_MAX_2G_CHANNEL)
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_2GHZ);
+	else
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_5GHZ);
+
+	rtw_cfg80211_rx_mgmt(padapter, freq, 0, pmgmt_frame, frame_len,
+			     GFP_ATOMIC);
+#endif /* defined(RTW_USE_CFG80211_STA_EVENT) */
+}
+
+void rtw_cfg80211_indicate_sta_disassoc(struct rtw_adapter *padapter,
+					unsigned char *da,
+					unsigned short reason)
+{
+	s32 freq;
+	int channel;
+	u8 *pmgmt_frame;
+	uint frame_len;
+	struct ieee80211_hdr *pwlanhdr;
+	unsigned short *fctrl;
+	u8 mgmt_buf[128] = { 0 };
+	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo = &pmlmeext->mlmext_info;
+	struct net_device *ndev = padapter->pnetdev;
+
+	DBG_8723A("%s(padapter =%p,%s)\n", __func__, padapter, ndev->name);
+
+#if defined(RTW_USE_CFG80211_STA_EVENT)
+	cfg80211_del_sta(ndev, da, GFP_ATOMIC);
+#else /* defined(RTW_USE_CFG80211_STA_EVENT) */
+	channel = pmlmeext->cur_channel;
+	if (channel <= RTW_CH_MAX_2G_CHANNEL)
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_2GHZ);
+	else
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_5GHZ);
+
+	pmgmt_frame = mgmt_buf;
+	pwlanhdr = (struct ieee80211_hdr *)pmgmt_frame;
+
+	fctrl = &pwlanhdr->frame_control;
+	*(fctrl) = 0;
+
+	memcpy(pwlanhdr->addr1, myid(&padapter->eeprompriv), ETH_ALEN);
+	memcpy(pwlanhdr->addr2, da, ETH_ALEN);
+	memcpy(pwlanhdr->addr3, get_my_bssid23a(&pmlmeinfo->network), ETH_ALEN);
+
+	SetSeqNum(pwlanhdr, pmlmeext->mgnt_seq);
+	pmlmeext->mgnt_seq++;
+	SetFrameSubType(pmgmt_frame, WIFI_DEAUTH);
+
+	pmgmt_frame += sizeof(struct ieee80211_hdr_3addr);
+	frame_len = sizeof(struct ieee80211_hdr_3addr);
+
+	reason = cpu_to_le16(reason);
+	pmgmt_frame = rtw_set_fixed_ie23a(pmgmt_frame,
+				       WLAN_REASON_PREV_AUTH_NOT_VALID,
+				       (unsigned char *)&reason, &frame_len);
+
+	rtw_cfg80211_rx_mgmt(padapter, freq, 0, mgmt_buf, frame_len,
+			     GFP_ATOMIC);
+#endif /* defined(RTW_USE_CFG80211_STA_EVENT) */
+}
+
+static int rtw_cfg80211_monitor_if_open(struct net_device *ndev)
+{
+	int ret = 0;
+
+	DBG_8723A("%s\n", __func__);
+
+	return ret;
+}
+
+static int rtw_cfg80211_monitor_if_close(struct net_device *ndev)
+{
+	int ret = 0;
+
+	DBG_8723A("%s\n", __func__);
+
+	return ret;
+}
+
+static int rtw_cfg80211_monitor_if_xmit_entry(struct sk_buff *skb,
+					      struct net_device *ndev)
+{
+	int ret = 0;
+	int rtap_len;
+	int qos_len = 0;
+	int dot11_hdr_len = 24;
+	int snap_len = 6;
+	unsigned char *pdata;
+	unsigned char src_mac_addr[6];
+	unsigned char dst_mac_addr[6];
+	struct ieee80211_hdr *dot11_hdr;
+	struct ieee80211_radiotap_header *rtap_hdr;
+	struct rtw_adapter *padapter = netdev_priv(ndev);
+
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+
+	if (unlikely(skb->len < sizeof(struct ieee80211_radiotap_header)))
+		goto fail;
+
+	rtap_hdr = (struct ieee80211_radiotap_header *)skb->data;
+	if (unlikely(rtap_hdr->it_version))
+		goto fail;
+
+	rtap_len = ieee80211_get_radiotap_len(skb->data);
+	if (unlikely(skb->len < rtap_len))
+		goto fail;
+
+	if (rtap_len != 14) {
+		DBG_8723A("radiotap len (should be 14): %d\n", rtap_len);
+		goto fail;
+	}
+
+	/* Skip the ratio tap header */
+	skb_pull(skb, rtap_len);
+
+	dot11_hdr = (struct ieee80211_hdr *)skb->data;
+	/* Check if the QoS bit is set */
+	if (ieee80211_is_data(dot11_hdr->frame_control)) {
+		/* Check if this ia a Wireless Distribution System (WDS) frame
+		 * which has 4 MAC addresses
+		 */
+		if (ieee80211_is_data_qos(dot11_hdr->frame_control))
+			qos_len = IEEE80211_QOS_CTL_LEN;
+		if (ieee80211_has_a4(dot11_hdr->frame_control))
+			dot11_hdr_len += 6;
+
+		memcpy(dst_mac_addr, dot11_hdr->addr1, sizeof(dst_mac_addr));
+		memcpy(src_mac_addr, dot11_hdr->addr2, sizeof(src_mac_addr));
+
+		/*
+		 * Skip the 802.11 header, QoS (if any) and SNAP,
+		 * but leave spaces for two MAC addresses
+		 */
+		skb_pull(skb, dot11_hdr_len + qos_len + snap_len -
+			 ETH_ALEN * 2);
+		pdata = (unsigned char *)skb->data;
+		memcpy(pdata, dst_mac_addr, ETH_ALEN);
+		memcpy(pdata + ETH_ALEN, src_mac_addr, ETH_ALEN);
+
+		DBG_8723A("should be eapol packet\n");
+
+		/* Use the real net device to transmit the packet */
+		ret = rtw_xmit23a_entry23a(skb, padapter->pnetdev);
+
+		return ret;
+
+	} else if (ieee80211_is_action(dot11_hdr->frame_control)) {
+		/* only for action frames */
+		struct xmit_frame *pmgntframe;
+		struct pkt_attrib *pattrib;
+		unsigned char *pframe;
+		/* u8 category, action, OUI_Subtype, dialogToken = 0; */
+		/* unsigned char        *frame_body; */
+		struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+		struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+		u32 len = skb->len;
+		u8 category, action;
+		int type = -1;
+
+		if (rtw_action_frame_parse23a(skb->data, len, &category,
+					   &action) == false) {
+			DBG_8723A(FUNC_NDEV_FMT " frame_control:0x%x\n",
+				  FUNC_NDEV_ARG(ndev),
+				  le16_to_cpu(dot11_hdr->frame_control));
+			goto fail;
+		}
+
+		DBG_8723A("RTW_Tx:da =" MAC_FMT " via " FUNC_NDEV_FMT "\n",
+			  MAC_ARG(dot11_hdr->addr1), FUNC_NDEV_ARG(ndev));
+#ifdef CONFIG_8723AU_P2P
+		type = rtw_p2p_check_frames(padapter, skb->data, len, true);
+		if (type >= 0)
+			goto dump;
+#endif
+		if (category == WLAN_CATEGORY_PUBLIC)
+			DBG_8723A("RTW_Tx:%s\n", action_public_str23a(action));
+		else
+			DBG_8723A("RTW_Tx:category(%u), action(%u)\n", category,
+				  action);
+dump:
+		/* starting alloc mgmt frame to dump it */
+		pmgntframe = alloc_mgtxmitframe23a(pxmitpriv);
+		if (pmgntframe == NULL)
+			goto fail;
+
+		/* update attribute */
+		pattrib = &pmgntframe->attrib;
+		update_mgntframe_attrib23a(padapter, pattrib);
+		pattrib->retry_ctrl = false;
+
+		memset(pmgntframe->buf_addr, 0, WLANHDR_OFFSET + TXDESC_OFFSET);
+
+		pframe = (u8 *)(pmgntframe->buf_addr) + TXDESC_OFFSET;
+
+		memcpy(pframe, skb->data, len);
+#ifdef CONFIG_8723AU_P2P
+		if (type >= 0) {
+			struct wifi_display_info *pwfd_info;
+
+			pwfd_info = padapter->wdinfo.wfd_info;
+
+			if (pwfd_info->wfd_enable)
+				rtw_append_wfd_ie(padapter, pframe, &len);
+		}
+#endif /*  CONFIG_8723AU_P2P */
+		pattrib->pktlen = len;
+
+		/* update seq number */
+		pmlmeext->mgnt_seq = le16_to_cpu(dot11_hdr->seq_ctrl) >> 4;
+		pattrib->seqnum = pmlmeext->mgnt_seq;
+		pmlmeext->mgnt_seq++;
+
+		pattrib->last_txcmdsz = pattrib->pktlen;
+
+		dump_mgntframe23a(padapter, pmgntframe);
+	}
+
+fail:
+
+	dev_kfree_skb(skb);
+
+	return 0;
+}
+
+static int
+rtw_cfg80211_monitor_if_set_mac_address(struct net_device *ndev, void *addr)
+{
+	int ret = 0;
+
+	DBG_8723A("%s\n", __func__);
+
+	return ret;
+}
+
+static const struct net_device_ops rtw_cfg80211_monitor_if_ops = {
+	.ndo_open = rtw_cfg80211_monitor_if_open,
+	.ndo_stop = rtw_cfg80211_monitor_if_close,
+	.ndo_start_xmit = rtw_cfg80211_monitor_if_xmit_entry,
+	.ndo_set_mac_address = rtw_cfg80211_monitor_if_set_mac_address,
+};
+
+static int rtw_cfg80211_add_monitor_if(struct rtw_adapter *padapter, char *name,
+				       struct net_device **ndev)
+{
+	int ret = 0;
+	struct net_device *mon_ndev = NULL;
+	struct wireless_dev *mon_wdev = NULL;
+	struct rtw_wdev_priv *pwdev_priv = wdev_to_priv(padapter->rtw_wdev);
+
+	if (!name) {
+		DBG_8723A(FUNC_ADPT_FMT " without specific name\n",
+			  FUNC_ADPT_ARG(padapter));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (pwdev_priv->pmon_ndev) {
+		DBG_8723A(FUNC_ADPT_FMT " monitor interface exist: " NDEV_FMT
+			  "\n", FUNC_ADPT_ARG(padapter),
+			  NDEV_ARG(pwdev_priv->pmon_ndev));
+		ret = -EBUSY;
+		goto out;
+	}
+
+	mon_ndev = alloc_etherdev(sizeof(struct rtw_adapter));
+	if (!mon_ndev) {
+		DBG_8723A(FUNC_ADPT_FMT " allocate ndev fail\n",
+			  FUNC_ADPT_ARG(padapter));
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	mon_ndev->type = ARPHRD_IEEE80211_RADIOTAP;
+	strncpy(mon_ndev->name, name, IFNAMSIZ);
+	mon_ndev->name[IFNAMSIZ - 1] = 0;
+	mon_ndev->destructor = rtw_ndev_destructor;
+
+	mon_ndev->netdev_ops = &rtw_cfg80211_monitor_if_ops;
+
+	/*  wdev */
+	mon_wdev = kzalloc(sizeof(struct wireless_dev), GFP_KERNEL);
+	if (!mon_wdev) {
+		DBG_8723A(FUNC_ADPT_FMT " allocate mon_wdev fail\n",
+			  FUNC_ADPT_ARG(padapter));
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	mon_wdev->wiphy = padapter->rtw_wdev->wiphy;
+	mon_wdev->netdev = mon_ndev;
+	mon_wdev->iftype = NL80211_IFTYPE_MONITOR;
+	mon_ndev->ieee80211_ptr = mon_wdev;
+
+	ret = register_netdevice(mon_ndev);
+	if (ret) {
+		goto out;
+	}
+
+	*ndev = pwdev_priv->pmon_ndev = mon_ndev;
+	memcpy(pwdev_priv->ifname_mon, name, IFNAMSIZ + 1);
+
+out:
+	if (ret) {
+		kfree(mon_wdev);
+		mon_wdev = NULL;
+	}
+
+	if (ret && mon_ndev) {
+		free_netdev(mon_ndev);
+		*ndev = mon_ndev = NULL;
+	}
+
+	return ret;
+}
+
+static struct wireless_dev *
+cfg80211_rtw_add_virtual_intf(struct wiphy *wiphy, const char *name,
+			      enum nl80211_iftype type, u32 *flags,
+			      struct vif_params *params)
+{
+	int ret = 0;
+	struct net_device *ndev = NULL;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+
+	DBG_8723A(FUNC_ADPT_FMT " wiphy:%s, name:%s, type:%d\n",
+		  FUNC_ADPT_ARG(padapter), wiphy_name(wiphy), name, type);
+
+	switch (type) {
+	case NL80211_IFTYPE_ADHOC:
+	case NL80211_IFTYPE_AP_VLAN:
+	case NL80211_IFTYPE_WDS:
+	case NL80211_IFTYPE_MESH_POINT:
+		ret = -ENODEV;
+		break;
+	case NL80211_IFTYPE_MONITOR:
+		ret =
+		    rtw_cfg80211_add_monitor_if(padapter, (char *)name, &ndev);
+		break;
+
+	case NL80211_IFTYPE_P2P_CLIENT:
+	case NL80211_IFTYPE_STATION:
+		ret = -ENODEV;
+		break;
+
+	case NL80211_IFTYPE_P2P_GO:
+	case NL80211_IFTYPE_AP:
+		ret = -ENODEV;
+		break;
+	default:
+		ret = -ENODEV;
+		DBG_8723A("Unsupported interface type\n");
+		break;
+	}
+
+	DBG_8723A(FUNC_ADPT_FMT " ndev:%p, ret:%d\n", FUNC_ADPT_ARG(padapter),
+		  ndev, ret);
+
+	return ndev ? ndev->ieee80211_ptr : ERR_PTR(ret);
+}
+
+static int cfg80211_rtw_del_virtual_intf(struct wiphy *wiphy,
+					 struct wireless_dev *wdev)
+{
+	struct rtw_wdev_priv *pwdev_priv =
+	    (struct rtw_wdev_priv *)wiphy_priv(wiphy);
+	struct net_device *ndev;
+	ndev = wdev ? wdev->netdev : NULL;
+
+	if (!ndev)
+		goto exit;
+
+	unregister_netdevice(ndev);
+
+	if (ndev == pwdev_priv->pmon_ndev) {
+		pwdev_priv->pmon_ndev = NULL;
+		pwdev_priv->ifname_mon[0] = '\0';
+		DBG_8723A(FUNC_NDEV_FMT " remove monitor interface\n",
+			  FUNC_NDEV_ARG(ndev));
+	}
+
+exit:
+	return 0;
+}
+
+static int rtw_add_beacon(struct rtw_adapter *adapter, const u8 *head,
+			  size_t head_len, const u8 *tail, size_t tail_len)
+{
+	int ret = 0;
+	u8 *pbuf = NULL;
+	uint len, wps_ielen = 0;
+	uint p2p_ielen = 0;
+	u8 got_p2p_ie = false;
+	struct mlme_priv *pmlmepriv = &adapter->mlmepriv;
+	/* struct sta_priv *pstapriv = &padapter->stapriv; */
+
+	DBG_8723A("%s beacon_head_len =%zu, beacon_tail_len =%zu\n",
+		  __func__, head_len, tail_len);
+
+	if (check_fwstate(pmlmepriv, WIFI_AP_STATE) != true)
+		return -EINVAL;
+
+	if (head_len < 24)
+		return -EINVAL;
+
+	pbuf = kzalloc(head_len + tail_len, GFP_KERNEL);
+	if (!pbuf)
+		return -ENOMEM;
+	/*  24 = beacon header len. */
+	memcpy(pbuf, (void *)head + 24, head_len - 24);
+	memcpy(pbuf + head_len - 24, (void *)tail, tail_len);
+
+	len = head_len + tail_len - 24;
+
+	/* check wps ie if inclued */
+	if (rtw_get_wps_ie23a
+	    (pbuf + _FIXED_IE_LENGTH_, len - _FIXED_IE_LENGTH_, NULL,
+	     &wps_ielen))
+		DBG_8723A("add bcn, wps_ielen =%d\n", wps_ielen);
+
+#ifdef CONFIG_8723AU_P2P
+	/* check p2p ie if inclued */
+	if (rtw_get_p2p_ie23a
+	    (pbuf + _FIXED_IE_LENGTH_, len - _FIXED_IE_LENGTH_, NULL,
+	     &p2p_ielen)) {
+		DBG_8723A("got p2p_ie, len =%d\n", p2p_ielen);
+		got_p2p_ie = true;
+	}
+#endif
+
+	/* pbss_network->IEs will not include p2p_ie, wfd ie */
+	rtw_ies_remove_ie23a(pbuf, &len, _BEACON_IE_OFFSET_, _VENDOR_SPECIFIC_IE_,
+			  P2P_OUI23A, 4);
+	rtw_ies_remove_ie23a(pbuf, &len, _BEACON_IE_OFFSET_, _VENDOR_SPECIFIC_IE_,
+			  WFD_OUI23A, 4);
+
+	if (rtw_check_beacon_data23a(adapter, pbuf, len) == _SUCCESS) {
+#ifdef CONFIG_8723AU_P2P
+		/* check p2p if enable */
+		if (got_p2p_ie == true) {
+			struct mlme_ext_priv *pmlmeext = &adapter->mlmeextpriv;
+			struct wifidirect_info *pwdinfo = &adapter->wdinfo;
+
+			if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
+				DBG_8723A("Enable P2P function for the first "
+					  "time\n");
+				rtw_p2p_enable23a(adapter, P2P_ROLE_GO);
+				wdev_to_priv(adapter->rtw_wdev)->p2p_enabled =
+					true;
+			} else {
+				del_timer_sync(&pwdinfo->find_phase_timer);
+				del_timer_sync(&pwdinfo->
+					       restore_p2p_state_timer);
+				del_timer_sync(&pwdinfo->pre_tx_scan_timer);
+
+				DBG_8723A("enter GO Mode, p2p_ielen =%d\n",
+					  p2p_ielen);
+
+				rtw_p2p_set_role(pwdinfo, P2P_ROLE_GO);
+				rtw_p2p_set_state(pwdinfo, P2P_STATE_GONEGO_OK);
+				pwdinfo->intent = 15;
+			}
+
+			pwdinfo->operating_channel = pmlmeext->cur_channel;
+		}
+#endif /* CONFIG_8723AU_P2P */
+
+		ret = 0;
+
+	} else {
+		ret = -EINVAL;
+	}
+
+	kfree(pbuf);
+
+	return ret;
+}
+
+static int cfg80211_rtw_start_ap(struct wiphy *wiphy, struct net_device *ndev,
+				 struct cfg80211_ap_settings *settings)
+{
+	int ret = 0;
+	struct rtw_adapter *adapter = wiphy_to_adapter(wiphy);
+
+	DBG_8723A(FUNC_NDEV_FMT " hidden_ssid:%d, auth_type:%d\n",
+		  FUNC_NDEV_ARG(ndev), settings->hidden_ssid,
+		  settings->auth_type);
+
+	ret = rtw_add_beacon(adapter, settings->beacon.head,
+			     settings->beacon.head_len, settings->beacon.tail,
+			     settings->beacon.tail_len);
+
+	adapter->mlmeextpriv.mlmext_info.hidden_ssid_mode =
+		settings->hidden_ssid;
+
+	if (settings->ssid && settings->ssid_len) {
+		struct wlan_bssid_ex *pbss_network =
+			&adapter->mlmepriv.cur_network.network;
+		struct wlan_bssid_ex *pbss_network_ext =
+			&adapter->mlmeextpriv.mlmext_info.network;
+
+		if (0)
+			DBG_8723A(FUNC_ADPT_FMT
+				  " ssid:(%s,%d), from ie:(%s,%d)\n",
+				  FUNC_ADPT_ARG(adapter), settings->ssid,
+				  (int)settings->ssid_len,
+				  pbss_network->Ssid.ssid,
+				  pbss_network->Ssid.ssid_len);
+
+		memcpy(pbss_network->Ssid.ssid, (void *)settings->ssid,
+		       settings->ssid_len);
+		pbss_network->Ssid.ssid_len = settings->ssid_len;
+		memcpy(pbss_network_ext->Ssid.ssid, (void *)settings->ssid,
+		       settings->ssid_len);
+		pbss_network_ext->Ssid.ssid_len = settings->ssid_len;
+
+		if (0)
+			DBG_8723A(FUNC_ADPT_FMT
+				  " after ssid:(%s,%d), (%s,%d)\n",
+				  FUNC_ADPT_ARG(adapter),
+				  pbss_network->Ssid.ssid,
+				  pbss_network->Ssid.ssid_len,
+				  pbss_network_ext->Ssid.ssid,
+				  pbss_network_ext->Ssid.ssid_len);
+	}
+
+	return ret;
+}
+
+static int cfg80211_rtw_change_beacon(struct wiphy *wiphy,
+				      struct net_device *ndev,
+				      struct cfg80211_beacon_data *info)
+{
+	int ret = 0;
+	struct rtw_adapter *adapter = wiphy_to_adapter(wiphy);
+
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+
+	ret = rtw_add_beacon(adapter, info->head, info->head_len, info->tail,
+			     info->tail_len);
+
+	return ret;
+}
+
+static int cfg80211_rtw_stop_ap(struct wiphy *wiphy, struct net_device *ndev)
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+	return 0;
+}
+
+static int cfg80211_rtw_add_station(struct wiphy *wiphy,
+				    struct net_device *ndev, u8 *mac,
+				    struct station_parameters *params)
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+
+	return 0;
+}
+
+static int cfg80211_rtw_del_station(struct wiphy *wiphy,
+				    struct net_device *ndev, u8 *mac)
+{
+	int ret = 0;
+	struct list_head *phead, *plist, *ptmp;
+	u8 updated = 0;
+	struct sta_info *psta;
+	struct rtw_adapter *padapter = netdev_priv(ndev);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct sta_priv *pstapriv = &padapter->stapriv;
+
+	DBG_8723A("+" FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+
+	if (check_fwstate(pmlmepriv, (_FW_LINKED | WIFI_AP_STATE)) != true) {
+		DBG_8723A("%s, fw_state != FW_LINKED|WIFI_AP_STATE\n",
+			  __func__);
+		return -EINVAL;
+	}
+
+	if (!mac) {
+		DBG_8723A("flush all sta, and cam_entry\n");
+
+		flush_all_cam_entry23a(padapter);	/* clear CAM */
+
+		ret = rtw_sta_flush23a(padapter);
+
+		return ret;
+	}
+
+	DBG_8723A("free sta macaddr =" MAC_FMT "\n", MAC_ARG(mac));
+
+	if (is_broadcast_ether_addr(mac))
+		return -EINVAL;
+
+	spin_lock_bh(&pstapriv->asoc_list_lock);
+
+	phead = &pstapriv->asoc_list;
+
+	/* check asoc_queue */
+	list_for_each_safe(plist, ptmp, phead) {
+		psta = container_of(plist, struct sta_info, asoc_list);
+
+		if (!memcmp(mac, psta->hwaddr, ETH_ALEN)) {
+			if (psta->dot8021xalg == 1 &&
+			    psta->bpairwise_key_installed == false) {
+				DBG_8723A("%s, sta's dot8021xalg = 1 and "
+					  "key_installed = false\n", __func__);
+			} else {
+				DBG_8723A("free psta =%p, aid =%d\n", psta,
+					  psta->aid);
+
+				list_del_init(&psta->asoc_list);
+				pstapriv->asoc_list_cnt--;
+
+				/* spin_unlock_bh(&pstapriv->asoc_list_lock); */
+				updated =
+				    ap_free_sta23a(padapter, psta, true,
+						WLAN_REASON_DEAUTH_LEAVING);
+				/* spin_lock_bh(&pstapriv->asoc_list_lock); */
+
+				psta = NULL;
+
+				break;
+			}
+		}
+	}
+
+	spin_unlock_bh(&pstapriv->asoc_list_lock);
+
+	associated_clients_update23a(padapter, updated);
+
+	DBG_8723A("-" FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+
+	return ret;
+}
+
+static int cfg80211_rtw_change_station(struct wiphy *wiphy,
+				       struct net_device *ndev, u8 *mac,
+				       struct station_parameters *params)
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+	return 0;
+}
+
+static int cfg80211_rtw_dump_station(struct wiphy *wiphy,
+				     struct net_device *ndev, int idx, u8 *mac,
+				     struct station_info *sinfo)
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+
+	/* TODO: dump scanned queue */
+
+	return -ENOENT;
+}
+
+static int cfg80211_rtw_change_bss(struct wiphy *wiphy, struct net_device *ndev,
+				   struct bss_parameters *params)
+{
+	DBG_8723A(FUNC_NDEV_FMT "\n", FUNC_NDEV_ARG(ndev));
+	return 0;
+}
+#endif /* CONFIG_8723AU_AP_MODE */
+
+void rtw_cfg80211_rx_action_p2p(struct rtw_adapter *padapter, u8 *pmgmt_frame,
+				uint frame_len)
+{
+	int type;
+	s32 freq;
+	int channel;
+	u8 category, action;
+
+	channel = rtw_get_oper_ch23a(padapter);
+
+	DBG_8723A("RTW_Rx:cur_ch =%d\n", channel);
+#ifdef CONFIG_8723AU_P2P
+	type = rtw_p2p_check_frames(padapter, pmgmt_frame, frame_len, false);
+	if (type >= 0)
+		goto indicate;
+#endif
+	rtw_action_frame_parse23a(pmgmt_frame, frame_len, &category, &action);
+	DBG_8723A("RTW_Rx:category(%u), action(%u)\n", category, action);
+
+indicate:
+	if (channel <= RTW_CH_MAX_2G_CHANNEL)
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_2GHZ);
+	else
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_5GHZ);
+
+	rtw_cfg80211_rx_mgmt(padapter, freq, 0, pmgmt_frame, frame_len,
+			     GFP_ATOMIC);
+}
+
+void rtw_cfg80211_rx_p2p_action_public(struct rtw_adapter *padapter,
+				       u8 *pmgmt_frame, uint frame_len)
+{
+	int type;
+	s32 freq;
+	int channel;
+	u8 category, action;
+
+	channel = rtw_get_oper_ch23a(padapter);
+
+	DBG_8723A("RTW_Rx:cur_ch =%d\n", channel);
+#ifdef CONFIG_8723AU_P2P
+	type = rtw_p2p_check_frames(padapter, pmgmt_frame, frame_len, false);
+	if (type >= 0) {
+		switch (type) {
+		case P2P_GO_NEGO_CONF:
+		case P2P_PROVISION_DISC_RESP:
+			rtw_clear_scan_deny(padapter);
+		}
+		goto indicate;
+	}
+#endif
+	rtw_action_frame_parse23a(pmgmt_frame, frame_len, &category, &action);
+	DBG_8723A("RTW_Rx:category(%u), action(%u)\n", category, action);
+
+indicate:
+	if (channel <= RTW_CH_MAX_2G_CHANNEL)
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_2GHZ);
+	else
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_5GHZ);
+
+	rtw_cfg80211_rx_mgmt(padapter, freq, 0, pmgmt_frame, frame_len,
+			     GFP_ATOMIC);
+}
+
+void rtw_cfg80211_rx_action(struct rtw_adapter *adapter, u8 *frame,
+			    uint frame_len, const char *msg)
+{
+	s32 freq;
+	int channel;
+	u8 category, action;
+
+	channel = rtw_get_oper_ch23a(adapter);
+
+	rtw_action_frame_parse23a(frame, frame_len, &category, &action);
+
+	DBG_8723A("RTW_Rx:cur_ch =%d\n", channel);
+	if (msg)
+		DBG_8723A("RTW_Rx:%s\n", msg);
+	else
+		DBG_8723A("RTW_Rx:category(%u), action(%u)\n", category,
+			  action);
+
+	if (channel <= RTW_CH_MAX_2G_CHANNEL)
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_2GHZ);
+	else
+		freq = ieee80211_channel_to_frequency(channel,
+						      IEEE80211_BAND_5GHZ);
+
+	rtw_cfg80211_rx_mgmt(adapter, freq, 0, frame, frame_len, GFP_ATOMIC);
+}
+
+#ifdef CONFIG_8723AU_P2P
+void rtw_cfg80211_issue_p2p_provision_request23a(struct rtw_adapter *padapter,
+					      const u8 *buf, size_t len)
+{
+	u16 wps_devicepassword_id = 0x0000;
+	uint wps_devicepassword_id_len = 0;
+	u8 wpsie[255] = { 0x00 }, p2p_ie[255] = { 0x00 };
+	uint p2p_ielen = 0;
+	uint wpsielen = 0;
+	u32 devinfo_contentlen = 0;
+	u8 devinfo_content[64] = { 0x00 };
+	u16 capability = 0;
+	uint capability_len = 0;
+
+	unsigned char category = WLAN_CATEGORY_PUBLIC;
+	u8 action = P2P_PUB_ACTION_ACTION;
+	u8 dialogToken = 1;
+	u32 p2poui = cpu_to_be32(P2POUI);
+	u8 oui_subtype = P2P_PROVISION_DISC_REQ;
+	u32 p2pielen = 0;
+#ifdef CONFIG_8723AU_P2P
+	u32 wfdielen = 0;
+#endif /* CONFIG_8723AU_P2P */
+
+	struct xmit_frame *pmgntframe;
+	struct pkt_attrib *pattrib;
+	unsigned char *pframe;
+	struct ieee80211_hdr *pwlanhdr, *hdr;
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+	u8 *frame_body =
+	    (unsigned char *)(buf + sizeof(struct ieee80211_hdr_3addr));
+	size_t frame_body_len = len - sizeof(struct ieee80211_hdr_3addr);
+
+	DBG_8723A("[%s] In\n", __func__);
+
+	hdr = (struct ieee80211_hdr *)buf;
+	/* prepare for building provision_request frame */
+	memcpy(pwdinfo->tx_prov_disc_info.peerIFAddr, hdr->addr1, ETH_ALEN);
+	memcpy(pwdinfo->tx_prov_disc_info.peerDevAddr, hdr->addr1, ETH_ALEN);
+
+	pwdinfo->tx_prov_disc_info.wps_config_method_request =
+	    WPS_CM_PUSH_BUTTON;
+
+	rtw_get_wps_ie23a(frame_body + _PUBLIC_ACTION_IE_OFFSET_,
+		       frame_body_len - _PUBLIC_ACTION_IE_OFFSET_, wpsie,
+		       &wpsielen);
+	rtw_get_wps_attr_content23a(wpsie, wpsielen, WPS_ATTR_DEVICE_PWID,
+				    (u8 *)&wps_devicepassword_id,
+				    &wps_devicepassword_id_len);
+	wps_devicepassword_id = be16_to_cpu(wps_devicepassword_id);
+
+	switch (wps_devicepassword_id) {
+	case WPS_DPID_PIN:
+		pwdinfo->tx_prov_disc_info.wps_config_method_request =
+			WPS_CM_LABEL;
+		break;
+	case WPS_DPID_USER_SPEC:
+		pwdinfo->tx_prov_disc_info.wps_config_method_request =
+			WPS_CM_DISPLYA;
+		break;
+	case WPS_DPID_MACHINE_SPEC:
+		break;
+	case WPS_DPID_REKEY:
+		break;
+	case WPS_DPID_PBC:
+		pwdinfo->tx_prov_disc_info.wps_config_method_request =
+			WPS_CM_PUSH_BUTTON;
+		break;
+	case WPS_DPID_REGISTRAR_SPEC:
+		pwdinfo->tx_prov_disc_info.wps_config_method_request =
+			WPS_CM_KEYPAD;
+		break;
+	default:
+		break;
+	}
+
+	if (rtw_get_p2p_ie23a(frame_body + _PUBLIC_ACTION_IE_OFFSET_,
+			   frame_body_len - _PUBLIC_ACTION_IE_OFFSET_,
+			   p2p_ie, &p2p_ielen)) {
+		rtw_get_p2p_attr23a_content(p2p_ie, p2p_ielen,
+					 P2P_ATTR_DEVICE_INFO, devinfo_content,
+					 &devinfo_contentlen);
+		rtw_get_p2p_attr23a_content(p2p_ie, p2p_ielen, P2P_ATTR_CAPABILITY,
+					 (u8 *)&capability, &capability_len);
+	}
+
+	/* start to build provision_request frame */
+	memset(wpsie, 0, sizeof(wpsie));
+	memset(p2p_ie, 0, sizeof(p2p_ie));
+	p2p_ielen = 0;
+
+	pmgntframe = alloc_mgtxmitframe23a(pxmitpriv);
+	if (pmgntframe == NULL)
+		return;
+	/* update attribute */
+	pattrib = &pmgntframe->attrib;
+	update_mgntframe_attrib23a(padapter, pattrib);
+
+	memset(pmgntframe->buf_addr, 0, WLANHDR_OFFSET + TXDESC_OFFSET);
+
+	pframe = (u8 *) (pmgntframe->buf_addr) + TXDESC_OFFSET;
+	pwlanhdr = (struct ieee80211_hdr *)pframe;
+
+	pwlanhdr->frame_control = 0;
+
+	memcpy(pwlanhdr->addr1, pwdinfo->tx_prov_disc_info.peerDevAddr,
+	       ETH_ALEN);
+	memcpy(pwlanhdr->addr2, myid(&padapter->eeprompriv), ETH_ALEN);
+	memcpy(pwlanhdr->addr3, pwdinfo->tx_prov_disc_info.peerDevAddr,
+	       ETH_ALEN);
+
+	SetSeqNum(pwlanhdr, pmlmeext->mgnt_seq);
+	pmlmeext->mgnt_seq++;
+	SetFrameSubType(pframe, WIFI_ACTION);
+
+	pframe += sizeof(struct ieee80211_hdr_3addr);
+	pattrib->pktlen = sizeof(struct ieee80211_hdr_3addr);
+
+	pframe = rtw_set_fixed_ie23a(pframe, 1, &category, &pattrib->pktlen);
+	pframe = rtw_set_fixed_ie23a(pframe, 1, &action, &pattrib->pktlen);
+	pframe = rtw_set_fixed_ie23a(pframe, 4, (unsigned char *)&p2poui,
+				  &pattrib->pktlen);
+	pframe = rtw_set_fixed_ie23a(pframe, 1, &oui_subtype, &pattrib->pktlen);
+	pframe = rtw_set_fixed_ie23a(pframe, 1, &dialogToken, &pattrib->pktlen);
+
+	/* build_prov_disc_request_p2p_ie23a */
+	/*      P2P OUI */
+	p2pielen = 0;
+	p2p_ie[p2pielen++] = 0x50;
+	p2p_ie[p2pielen++] = 0x6F;
+	p2p_ie[p2pielen++] = 0x9A;
+	p2p_ie[p2pielen++] = 0x09;	/*      WFA P2P v1.0 */
+
+	/*      Commented by Albert 20110301 */
+	/*      According to the P2P Specification, the provision discovery request frame should contain 3 P2P attributes */
+	/*      1. P2P Capability */
+	/*      2. Device Info */
+	/*      3. Group ID ( When joining an operating P2P Group ) */
+
+	/*      P2P Capability ATTR */
+	/*      Type: */
+	p2p_ie[p2pielen++] = P2P_ATTR_CAPABILITY;
+
+	/*      Length: */
+	RTW_PUT_LE16(p2p_ie + p2pielen, 0x0002);
+	p2pielen += 2;
+
+	/*      Value: */
+	/*      Device Capability Bitmap, 1 byte */
+	/*      Group Capability Bitmap, 1 byte */
+	memcpy(p2p_ie + p2pielen, &capability, 2);
+	p2pielen += 2;
+
+	/*      Device Info ATTR */
+	/*      Type: */
+	p2p_ie[p2pielen++] = P2P_ATTR_DEVICE_INFO;
+
+	/*      Length: */
+	RTW_PUT_LE16(p2p_ie + p2pielen, devinfo_contentlen);
+	p2pielen += 2;
+
+	/*      Value: */
+	memcpy(p2p_ie + p2pielen, devinfo_content, devinfo_contentlen);
+	p2pielen += devinfo_contentlen;
+
+	pframe = rtw_set_ie23a(pframe, _VENDOR_SPECIFIC_IE_, p2pielen,
+			    (unsigned char *)p2p_ie, &p2p_ielen);
+	pattrib->pktlen += p2p_ielen;
+
+	wpsielen = 0;
+	/*      WPS OUI */
+	*(u32 *)(wpsie) = cpu_to_be32(WPSOUI);
+	wpsielen += 4;
+
+	/*      WPS version */
+	/*      Type: */
+	*(u16 *)(wpsie + wpsielen) = cpu_to_be16(WPS_ATTR_VER1);
+	wpsielen += 2;
+
+	/*      Length: */
+	*(u16 *)(wpsie + wpsielen) = cpu_to_be16(0x0001);
+	wpsielen += 2;
+
+	/*      Value: */
+	wpsie[wpsielen++] = WPS_VERSION_1;	/*      Version 1.0 */
+
+	/*      Config Method */
+	/*      Type: */
+	*(u16 *)(wpsie + wpsielen) = cpu_to_be16(WPS_ATTR_CONF_METHOD);
+	wpsielen += 2;
+
+	/*      Length: */
+	*(u16 *)(wpsie + wpsielen) = cpu_to_be16(0x0002);
+	wpsielen += 2;
+
+	/*      Value: */
+	*(u16 *)(wpsie + wpsielen) =
+	    cpu_to_be16(pwdinfo->tx_prov_disc_info.wps_config_method_request);
+	wpsielen += 2;
+
+	pframe = rtw_set_ie23a(pframe, _VENDOR_SPECIFIC_IE_, wpsielen,
+			    (unsigned char *)wpsie, &pattrib->pktlen);
+
+#ifdef CONFIG_8723AU_P2P
+	wfdielen = build_provdisc_req_wfd_ie(pwdinfo, pframe);
+	pframe += wfdielen;
+	pattrib->pktlen += wfdielen;
+#endif /* CONFIG_8723AU_P2P */
+
+	pattrib->last_txcmdsz = pattrib->pktlen;
+
+	/* dump_mgntframe23a(padapter, pmgntframe); */
+	if (dump_mgntframe23a_and_wait_ack23a(padapter, pmgntframe) != _SUCCESS)
+		DBG_8723A("%s, ack to\n", __func__);
+}
+
+static s32 cfg80211_rtw_remain_on_channel(struct wiphy *wiphy,
+					  struct wireless_dev *wdev,
+					  struct ieee80211_channel *channel,
+					  unsigned int duration, u64 *cookie)
+{
+	s32 err = 0;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+	struct cfg80211_wifidirect_info *pcfg80211_wdinfo =
+	    &padapter->cfg80211_wdinfo;
+	u8 remain_ch =
+		(u8) ieee80211_frequency_to_channel(channel->center_freq);
+	u8 ready_on_channel = false;
+
+	DBG_8723A(FUNC_ADPT_FMT " ch:%u duration:%d\n", FUNC_ADPT_ARG(padapter),
+		  remain_ch, duration);
+
+	if (pcfg80211_wdinfo->is_ro_ch == true) {
+		DBG_8723A("%s, cancel ro ch timer\n", __func__);
+
+		del_timer_sync(&padapter->cfg80211_wdinfo.remain_on_ch_timer);
+
+		p2p_protocol_wk_hdl23a(padapter, P2P_RO_CH_WK);
+	}
+
+	pcfg80211_wdinfo->is_ro_ch = true;
+
+	if (_FAIL == rtw_pwr_wakeup(padapter)) {
+		err = -EFAULT;
+		goto exit;
+	}
+
+	memcpy(&pcfg80211_wdinfo->remain_on_ch_channel, channel,
+	       sizeof(struct ieee80211_channel));
+	pcfg80211_wdinfo->remain_on_ch_cookie = *cookie;
+
+	rtw_scan_abort23a(padapter);
+	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
+		rtw_p2p_enable23a(padapter, P2P_ROLE_DEVICE);
+		wdev_to_priv(padapter->rtw_wdev)->p2p_enabled = true;
+	} else {
+		rtw_p2p_set_pre_state(pwdinfo, rtw_p2p_state(pwdinfo));
+#ifdef CONFIG_DEBUG_CFG80211
+		DBG_8723A("%s, role =%d, p2p_state =%d\n", __func__,
+			  rtw_p2p_role(pwdinfo), rtw_p2p_state(pwdinfo));
+#endif
+	}
+
+	rtw_p2p_set_state(pwdinfo, P2P_STATE_LISTEN);
+
+	if (duration < 400)
+		duration = duration * 3;	/* extend from exper. */
+
+	pcfg80211_wdinfo->restore_channel = pmlmeext->cur_channel;
+
+	if (rtw_ch_set_search_ch23a(pmlmeext->channel_set, remain_ch) >= 0) {
+		if (remain_ch != pmlmeext->cur_channel) {
+			ready_on_channel = true;
+		}
+	} else {
+		DBG_8723A("%s remain_ch:%u not in channel plan!!!!\n",
+			  __func__, remain_ch);
+	}
+
+	/* call this after other things have been done */
+	if (ready_on_channel == true) {
+		if (!check_fwstate(&padapter->mlmepriv, _FW_LINKED)) {
+			pmlmeext->cur_channel = remain_ch;
+
+			set_channel_bwmode23a(padapter, remain_ch,
+					   HAL_PRIME_CHNL_OFFSET_DONT_CARE,
+					   HT_CHANNEL_WIDTH_20);
+		}
+	}
+	DBG_8723A("%s, set ro ch timer, duration =%d\n", __func__, duration);
+	mod_timer(&pcfg80211_wdinfo->remain_on_ch_timer,
+		  jiffies + msecs_to_jiffies(duration));
+
+	rtw_cfg80211_ready_on_channel(padapter, *cookie, channel, channel_type,
+				      duration, GFP_KERNEL);
+
+	pwdinfo->listen_channel = pmlmeext->cur_channel;
+
+exit:
+	if (err)
+		pcfg80211_wdinfo->is_ro_ch = false;
+
+	return err;
+}
+
+static s32 cfg80211_rtw_cancel_remain_on_channel(struct wiphy *wiphy,
+						 struct wireless_dev *wdev,
+						 u64 cookie)
+{
+	s32 err = 0;
+	struct rtw_adapter *padapter = wiphy_to_adapter(wiphy);
+	struct wifidirect_info *pwdinfo = &padapter->wdinfo;
+	struct cfg80211_wifidirect_info *pcfg80211_wdinfo =
+	    &padapter->cfg80211_wdinfo;
+
+	DBG_8723A(FUNC_ADPT_FMT "\n", FUNC_ADPT_ARG(padapter));
+
+	if (pcfg80211_wdinfo->is_ro_ch == true) {
+		DBG_8723A("%s, cancel ro ch timer\n", __func__);
+		del_timer_sync(&padapter->cfg80211_wdinfo.remain_on_ch_timer);
+		p2p_protocol_wk_hdl23a(padapter, P2P_RO_CH_WK);
+	}
+
+	rtw_p2p_set_state(pwdinfo, rtw_p2p_pre_state(pwdinfo));
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A("%s, role =%d, p2p_state =%d\n", __func__,
+		  rtw_p2p_role(pwdinfo), rtw_p2p_state(pwdinfo));
+#endif
+	pcfg80211_wdinfo->is_ro_ch = false;
+
+	return err;
+}
+
+#endif /* CONFIG_8723AU_P2P */
+
+static int _cfg80211_rtw_mgmt_tx(struct rtw_adapter *padapter, u8 tx_ch,
+				 const u8 *buf, size_t len)
+{
+	struct xmit_frame *pmgntframe;
+	struct pkt_attrib *pattrib;
+	unsigned char *pframe;
+	int ret = _FAIL;
+	bool ack = true;
+	struct ieee80211_hdr *pwlanhdr;
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+	/* struct cfg80211_wifidirect_info *pcfg80211_wdinfo = &padapter->cfg80211_wdinfo; */
+
+	if (_FAIL == rtw_pwr_wakeup(padapter)) {
+		ret = -EFAULT;
+		goto exit;
+	}
+
+	rtw_set_scan_deny(padapter, 1000);
+
+	rtw_scan_abort23a(padapter);
+
+	if (tx_ch != rtw_get_oper_ch23a(padapter)) {
+		if (!check_fwstate(&padapter->mlmepriv, _FW_LINKED))
+			pmlmeext->cur_channel = tx_ch;
+		set_channel_bwmode23a(padapter, tx_ch,
+				   HAL_PRIME_CHNL_OFFSET_DONT_CARE,
+				   HT_CHANNEL_WIDTH_20);
+	}
+
+	/* starting alloc mgmt frame to dump it */
+	pmgntframe = alloc_mgtxmitframe23a(pxmitpriv);
+	if (pmgntframe == NULL) {
+		/* ret = -ENOMEM; */
+		ret = _FAIL;
+		goto exit;
+	}
+
+	/* update attribute */
+	pattrib = &pmgntframe->attrib;
+	update_mgntframe_attrib23a(padapter, pattrib);
+	pattrib->retry_ctrl = false;
+
+	memset(pmgntframe->buf_addr, 0, WLANHDR_OFFSET + TXDESC_OFFSET);
+
+	pframe = (u8 *) (pmgntframe->buf_addr) + TXDESC_OFFSET;
+
+	memcpy(pframe, (void *)buf, len);
+	pattrib->pktlen = len;
+
+	pwlanhdr = (struct ieee80211_hdr *)pframe;
+	/* update seq number */
+	pmlmeext->mgnt_seq = le16_to_cpu(pwlanhdr->seq_ctrl) >> 4;
+	pattrib->seqnum = pmlmeext->mgnt_seq;
+	pmlmeext->mgnt_seq++;
+
+#ifdef CONFIG_8723AU_P2P
+	{
+		struct wifi_display_info *pwfd_info;
+
+		pwfd_info = padapter->wdinfo.wfd_info;
+
+		if (true == pwfd_info->wfd_enable) {
+			rtw_append_wfd_ie(padapter, pframe, &pattrib->pktlen);
+		}
+	}
+#endif /*  CONFIG_8723AU_P2P */
+
+	pattrib->last_txcmdsz = pattrib->pktlen;
+
+	if (dump_mgntframe23a_and_wait_ack23a(padapter, pmgntframe) != _SUCCESS) {
+		ack = false;
+		ret = _FAIL;
+
+#ifdef CONFIG_DEBUG_CFG80211
+		DBG_8723A("%s, ack == _FAIL\n", __func__);
+#endif
+	} else {
+#ifdef CONFIG_DEBUG_CFG80211
+		DBG_8723A("%s, ack =%d, ok!\n", __func__, ack);
+#endif
+		ret = _SUCCESS;
+	}
+
+exit:
+
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A("%s, ret =%d\n", __func__, ret);
+#endif
+
+	return ret;
+}
+
+static int cfg80211_rtw_mgmt_tx(struct wiphy *wiphy, struct wireless_dev *wdev,
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(3, 14, 0))
+				struct ieee80211_channel *chan,
+				bool offchan,
+				unsigned int wait,
+				const u8 *buf, size_t len,
+				bool no_cck, bool dont_wait_for_ack,
+#else
+				struct cfg80211_mgmt_tx_params *params,
+#endif
+				u64 *cookie)
+{
+	struct rtw_adapter *padapter =
+		(struct rtw_adapter *)wiphy_to_adapter(wiphy);
+	struct rtw_wdev_priv *pwdev_priv = wdev_to_priv(padapter->rtw_wdev);
+	int ret = 0;
+	int tx_ret;
+	u32 dump_limit = RTW_MAX_MGMT_TX_CNT;
+	u32 dump_cnt = 0;
+	bool ack = true;
+	u8 category, action;
+	int type = (-1);
+	unsigned long start = jiffies;
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(3, 14, 0))
+	size_t len = params->len;
+	struct ieee80211_channel *chan = params->chan;
+	const u8 *buf = params->buf;
+#endif
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)buf;
+	u8 tx_ch = (u8) ieee80211_frequency_to_channel(chan->center_freq);
+
+	/* cookie generation */
+	*cookie = (unsigned long)buf;
+
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A(FUNC_ADPT_FMT " len =%zu, ch =%d"
+		  "\n", FUNC_ADPT_ARG(padapter), len, tx_ch);
+#endif /* CONFIG_DEBUG_CFG80211 */
+
+	/* indicate ack before issue frame to avoid racing with rsp frame */
+	rtw_cfg80211_mgmt_tx_status(padapter, *cookie, buf, len, ack,
+				    GFP_KERNEL);
+
+	if (rtw_action_frame_parse23a(buf, len, &category, &action) == false) {
+		DBG_8723A(FUNC_ADPT_FMT " frame_control:0x%x\n",
+			  FUNC_ADPT_ARG(padapter),
+			  le16_to_cpu(hdr->frame_control));
+		goto exit;
+	}
+
+	DBG_8723A("RTW_Tx:tx_ch =%d, da =" MAC_FMT "\n", tx_ch,
+		  MAC_ARG(hdr->addr1));
+#ifdef CONFIG_8723AU_P2P
+	type = rtw_p2p_check_frames(padapter, buf, len, true);
+	if (type >= 0)
+		goto dump;
+#endif
+	if (category == WLAN_CATEGORY_PUBLIC)
+		DBG_8723A("RTW_Tx:%s\n", action_public_str23a(action));
+	else
+		DBG_8723A("RTW_Tx:category(%u), action(%u)\n",
+			  category, action);
+
+dump:
+	do {
+		dump_cnt++;
+		tx_ret = _cfg80211_rtw_mgmt_tx(padapter, tx_ch, buf, len);
+	} while (dump_cnt < dump_limit && tx_ret != _SUCCESS);
+
+	if (tx_ret != _SUCCESS || dump_cnt > 1) {
+		DBG_8723A(FUNC_ADPT_FMT " %s (%d/%d) in %d ms\n",
+			  FUNC_ADPT_ARG(padapter),
+			  tx_ret == _SUCCESS ? "OK" : "FAIL", dump_cnt,
+			  dump_limit, jiffies_to_msecs(jiffies - start));
+	}
+
+	switch (type) {
+	case P2P_GO_NEGO_CONF:
+		rtw_clear_scan_deny(padapter);
+		break;
+	case P2P_INVIT_RESP:
+		if (pwdev_priv->invit_info.flags & BIT(0)
+		    && pwdev_priv->invit_info.status == 0) {
+			DBG_8723A(FUNC_ADPT_FMT " agree with invitation of "
+				  "persistent group\n",
+				  FUNC_ADPT_ARG(padapter));
+			rtw_set_scan_deny(padapter, 5000);
+			rtw_pwr_wakeup_ex(padapter, 5000);
+			rtw_clear_scan_deny(padapter);
+		}
+		break;
+	}
+
+exit:
+	return ret;
+}
+
+static void cfg80211_rtw_mgmt_frame_register(struct wiphy *wiphy,
+					     struct wireless_dev *wdev,
+					     u16 frame_type, bool reg)
+{
+
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A(FUNC_ADPT_FMT " frame_type:%x, reg:%d\n",
+		  FUNC_ADPT_ARG(adapter), frame_type, reg);
+#endif
+
+	if (frame_type != (IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_PROBE_REQ))
+		return;
+
+	return;
+}
+
+static int rtw_cfg80211_set_beacon_wpsp2pie(struct net_device *ndev, char *buf,
+					    int len)
+{
+	int ret = 0;
+	uint wps_ielen = 0;
+	u8 *wps_ie;
+	u32 p2p_ielen = 0;
+	u8 wps_oui[8] = { 0x0, 0x50, 0xf2, 0x04 };
+	u8 *p2p_ie;
+	u32 wfd_ielen = 0;
+	struct rtw_adapter *padapter = netdev_priv(ndev);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
+
+	DBG_8723A(FUNC_NDEV_FMT " ielen =%d\n", FUNC_NDEV_ARG(ndev), len);
+
+	if (len > 0) {
+		wps_ie = rtw_get_wps_ie23a(buf, len, NULL, &wps_ielen);
+		if (wps_ie) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("bcn_wps_ielen =%d\n", wps_ielen);
+#endif
+
+			if (pmlmepriv->wps_beacon_ie) {
+				pmlmepriv->wps_beacon_ie_len = 0;
+				kfree(pmlmepriv->wps_beacon_ie);
+				pmlmepriv->wps_beacon_ie = NULL;
+			}
+
+			pmlmepriv->wps_beacon_ie =
+				kmalloc(wps_ielen, GFP_KERNEL);
+			if (pmlmepriv->wps_beacon_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+			}
+			memcpy(pmlmepriv->wps_beacon_ie, wps_ie, wps_ielen);
+			pmlmepriv->wps_beacon_ie_len = wps_ielen;
+
+			update_beacon23a(padapter, _VENDOR_SPECIFIC_IE_, wps_oui,
+				      true);
+		}
+#ifdef CONFIG_8723AU_P2P
+		p2p_ie = rtw_get_p2p_ie23a(buf, len, NULL, &p2p_ielen);
+		if (p2p_ie) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("bcn_p2p_ielen =%d\n", p2p_ielen);
+#endif
+
+			if (pmlmepriv->p2p_beacon_ie) {
+				pmlmepriv->p2p_beacon_ie_len = 0;
+				kfree(pmlmepriv->p2p_beacon_ie);
+				pmlmepriv->p2p_beacon_ie = NULL;
+			}
+
+			pmlmepriv->p2p_beacon_ie =
+				kmalloc(p2p_ielen, GFP_KERNEL);
+			if (pmlmepriv->p2p_beacon_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+			}
+
+			memcpy(pmlmepriv->p2p_beacon_ie, p2p_ie, p2p_ielen);
+			pmlmepriv->p2p_beacon_ie_len = p2p_ielen;
+		}
+#endif /* CONFIG_8723AU_P2P */
+
+		/* buf += p2p_ielen; */
+		/* len -= p2p_ielen; */
+
+#ifdef CONFIG_8723AU_P2P
+		if (rtw_get_wfd_ie(buf, len, NULL, &wfd_ielen)) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("bcn_wfd_ielen =%d\n", wfd_ielen);
+#endif
+
+			if (pmlmepriv->wfd_beacon_ie) {
+				pmlmepriv->wfd_beacon_ie_len = 0;
+				kfree(pmlmepriv->wfd_beacon_ie);
+				pmlmepriv->wfd_beacon_ie = NULL;
+			}
+
+			pmlmepriv->wfd_beacon_ie =
+				kmalloc(wfd_ielen, GFP_KERNEL);
+			if (pmlmepriv->wfd_beacon_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+
+			}
+			rtw_get_wfd_ie(buf, len, pmlmepriv->wfd_beacon_ie,
+				       &pmlmepriv->wfd_beacon_ie_len);
+		}
+#endif /* CONFIG_8723AU_P2P */
+
+		pmlmeext->bstart_bss = true;
+
+	}
+
+	return ret;
+}
+
+static int rtw_cfg80211_set_probe_resp_wpsp2pie(struct net_device *net,
+						char *buf, int len)
+{
+	struct rtw_adapter *padapter = netdev_priv(net);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	int ret = 0;
+	uint wps_ielen = 0;
+	u8 *wps_ie;
+	u32 p2p_ielen = 0;
+	u8 *p2p_ie;
+	u32 wfd_ielen = 0;
+
+	if (len > 0) {
+		wps_ie = rtw_get_wps_ie23a(buf, len, NULL, &wps_ielen);
+		if (wps_ie) {
+			uint attr_contentlen = 0;
+			u16 uconfig_method, *puconfig_method = NULL;
+
+			if (pmlmepriv->wps_probe_resp_ie) {
+				pmlmepriv->wps_probe_resp_ie_len = 0;
+				kfree(pmlmepriv->wps_probe_resp_ie);
+				pmlmepriv->wps_probe_resp_ie = NULL;
+			}
+
+			pmlmepriv->wps_probe_resp_ie =
+				kmalloc(wps_ielen, GFP_KERNEL);
+			if (pmlmepriv->wps_probe_resp_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+
+			}
+
+			/* add PUSH_BUTTON config_method by driver self in
+			   wpsie of probe_resp at GO Mode */
+			puconfig_method = (u16 *)rtw_get_wps_attr_content23a(wps_ie, wps_ielen,
+							      WPS_ATTR_CONF_METHOD,
+							      NULL,
+							      &attr_contentlen);
+			if (puconfig_method) {
+				uconfig_method = WPS_CM_PUSH_BUTTON;
+				uconfig_method = cpu_to_be16(uconfig_method);
+
+				*puconfig_method |= uconfig_method;
+			}
+
+			memcpy(pmlmepriv->wps_probe_resp_ie, wps_ie, wps_ielen);
+			pmlmepriv->wps_probe_resp_ie_len = wps_ielen;
+
+		}
+
+		/* buf += wps_ielen; */
+		/* len -= wps_ielen; */
+
+#ifdef CONFIG_8723AU_P2P
+		p2p_ie = rtw_get_p2p_ie23a(buf, len, NULL, &p2p_ielen);
+		if (p2p_ie) {
+			u8 is_GO = false;
+			u32 attr_contentlen = 0;
+			u16 cap_attr = 0;
+
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("probe_resp_p2p_ielen =%d\n", p2p_ielen);
+#endif
+
+			/* Check P2P Capability ATTR */
+			if (rtw_get_p2p_attr23a_content(p2p_ie, p2p_ielen,
+						     P2P_ATTR_CAPABILITY,
+						     (u8 *) &cap_attr,
+						     (uint *) &attr_contentlen)) {
+				u8 grp_cap = 0;
+				/* DBG_8723A( "[%s] Got P2P Capability Attr!!\n", __func__ ); */
+				cap_attr = le16_to_cpu(cap_attr);
+				grp_cap = (u8) ((cap_attr >> 8) & 0xff);
+
+				is_GO = (grp_cap & BIT(0)) ? true : false;
+
+				if (is_GO)
+					DBG_8723A
+					    ("Got P2P Capability Attr, grp_cap"
+					     "= 0x%x, is_GO\n", grp_cap);
+			}
+
+			if (is_GO == false) {
+				if (pmlmepriv->p2p_probe_resp_ie) {
+					pmlmepriv->p2p_probe_resp_ie_len = 0;
+					kfree(pmlmepriv->p2p_probe_resp_ie);
+					pmlmepriv->p2p_probe_resp_ie = NULL;
+				}
+
+				pmlmepriv->p2p_probe_resp_ie =
+				    kmalloc(p2p_ielen, GFP_KERNEL);
+				if (pmlmepriv->p2p_probe_resp_ie == NULL) {
+					DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+						  __func__, __LINE__);
+					return -EINVAL;
+				}
+				memcpy(pmlmepriv->p2p_probe_resp_ie, p2p_ie,
+				       p2p_ielen);
+				pmlmepriv->p2p_probe_resp_ie_len = p2p_ielen;
+			} else {
+				if (pmlmepriv->p2p_go_probe_resp_ie) {
+					pmlmepriv->p2p_go_probe_resp_ie_len = 0;
+					kfree(pmlmepriv->p2p_go_probe_resp_ie);
+					pmlmepriv->p2p_go_probe_resp_ie = NULL;
+				}
+
+				pmlmepriv->p2p_go_probe_resp_ie =
+				    kmalloc(p2p_ielen, GFP_KERNEL);
+				if (pmlmepriv->p2p_go_probe_resp_ie == NULL) {
+					DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+						  __func__, __LINE__);
+					return -EINVAL;
+
+				}
+				memcpy(pmlmepriv->p2p_go_probe_resp_ie,
+				       p2p_ie, p2p_ielen);
+				pmlmepriv->p2p_go_probe_resp_ie_len = p2p_ielen;
+			}
+		}
+#endif /* CONFIG_8723AU_P2P */
+
+		/* buf += p2p_ielen; */
+		/* len -= p2p_ielen; */
+
+#ifdef CONFIG_8723AU_P2P
+		if (rtw_get_wfd_ie(buf, len, NULL, &wfd_ielen)) {
+#ifdef CONFIG_DEBUG_CFG80211
+			DBG_8723A("probe_resp_wfd_ielen =%d\n", wfd_ielen);
+#endif
+
+			if (pmlmepriv->wfd_probe_resp_ie) {
+				pmlmepriv->wfd_probe_resp_ie_len = 0;
+				kfree(pmlmepriv->wfd_probe_resp_ie);
+				pmlmepriv->wfd_probe_resp_ie = NULL;
+			}
+
+			pmlmepriv->wfd_probe_resp_ie =
+			    kmalloc(wfd_ielen, GFP_KERNEL);
+			if (pmlmepriv->wfd_probe_resp_ie == NULL) {
+				DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+					  __func__, __LINE__);
+				return -EINVAL;
+
+			}
+			rtw_get_wfd_ie(buf, len, pmlmepriv->wfd_probe_resp_ie,
+				       &pmlmepriv->wfd_probe_resp_ie_len);
+		}
+#endif /* CONFIG_8723AU_P2P */
+	}
+
+	return ret;
+}
+
+static int rtw_cfg80211_set_assoc_resp_wpsp2pie(struct net_device *net,
+						char *buf, int len)
+{
+	int ret = 0;
+	struct rtw_adapter *padapter = netdev_priv(net);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+	DBG_8723A("%s, ielen =%d\n", __func__, len);
+
+	if (len > 0) {
+		if (pmlmepriv->wps_assoc_resp_ie) {
+			pmlmepriv->wps_assoc_resp_ie_len = 0;
+			kfree(pmlmepriv->wps_assoc_resp_ie);
+			pmlmepriv->wps_assoc_resp_ie = NULL;
+		}
+
+		pmlmepriv->wps_assoc_resp_ie = kmalloc(len, GFP_KERNEL);
+		if (pmlmepriv->wps_assoc_resp_ie == NULL) {
+			DBG_8723A("%s()-%d: kmalloc() ERROR!\n",
+				  __func__, __LINE__);
+			return -EINVAL;
+
+		}
+		memcpy(pmlmepriv->wps_assoc_resp_ie, buf, len);
+		pmlmepriv->wps_assoc_resp_ie_len = len;
+	}
+
+	return ret;
+}
+
+int rtw_cfg80211_set_mgnt_wpsp2pie(struct net_device *net, char *buf, int len,
+				   int type)
+{
+	int ret = 0;
+	uint wps_ielen = 0;
+	u32 p2p_ielen = 0;
+
+#ifdef CONFIG_DEBUG_CFG80211
+	DBG_8723A("%s, ielen =%d\n", __func__, len);
+#endif
+
+	if ((rtw_get_wps_ie23a(buf, len, NULL, &wps_ielen) && (wps_ielen > 0))
+#ifdef CONFIG_8723AU_P2P
+	    || (rtw_get_p2p_ie23a(buf, len, NULL, &p2p_ielen) && (p2p_ielen > 0))
+#endif
+	    ) {
+		if (net) {
+			switch (type) {
+			case 0x1:	/* BEACON */
+				ret =
+				    rtw_cfg80211_set_beacon_wpsp2pie(net, buf,
+								     len);
+				break;
+			case 0x2:	/* PROBE_RESP */
+				ret =
+				    rtw_cfg80211_set_probe_resp_wpsp2pie(net,
+									 buf,
+									 len);
+				break;
+			case 0x4:	/* ASSOC_RESP */
+				ret =
+				    rtw_cfg80211_set_assoc_resp_wpsp2pie(net,
+									 buf,
+									 len);
+				break;
+			}
+		}
+	}
+
+	return ret;
+
+}
+
+static struct cfg80211_ops rtw_cfg80211_ops = {
+	.change_virtual_intf = cfg80211_rtw_change_iface,
+	.add_key = cfg80211_rtw_add_key,
+	.get_key = cfg80211_rtw_get_key,
+	.del_key = cfg80211_rtw_del_key,
+	.set_default_key = cfg80211_rtw_set_default_key,
+	.get_station = cfg80211_rtw_get_station,
+	.scan = cfg80211_rtw_scan,
+	.set_wiphy_params = cfg80211_rtw_set_wiphy_params,
+	.connect = cfg80211_rtw_connect,
+	.disconnect = cfg80211_rtw_disconnect,
+	.join_ibss = cfg80211_rtw_join_ibss,
+	.leave_ibss = cfg80211_rtw_leave_ibss,
+	.set_tx_power = cfg80211_rtw_set_txpower,
+	.get_tx_power = cfg80211_rtw_get_txpower,
+	.set_power_mgmt = cfg80211_rtw_set_power_mgmt,
+	.set_pmksa = cfg80211_rtw_set_pmksa,
+	.del_pmksa = cfg80211_rtw_del_pmksa,
+	.flush_pmksa = cfg80211_rtw_flush_pmksa,
+
+#ifdef CONFIG_8723AU_AP_MODE
+	.add_virtual_intf = cfg80211_rtw_add_virtual_intf,
+	.del_virtual_intf = cfg80211_rtw_del_virtual_intf,
+
+	.start_ap = cfg80211_rtw_start_ap,
+	.change_beacon = cfg80211_rtw_change_beacon,
+	.stop_ap = cfg80211_rtw_stop_ap,
+
+	.add_station = cfg80211_rtw_add_station,
+	.del_station = cfg80211_rtw_del_station,
+	.change_station = cfg80211_rtw_change_station,
+	.dump_station = cfg80211_rtw_dump_station,
+	.change_bss = cfg80211_rtw_change_bss,
+#endif /* CONFIG_8723AU_AP_MODE */
+
+#ifdef CONFIG_8723AU_P2P
+	.remain_on_channel = cfg80211_rtw_remain_on_channel,
+	.cancel_remain_on_channel = cfg80211_rtw_cancel_remain_on_channel,
+#endif
+
+	.mgmt_tx = cfg80211_rtw_mgmt_tx,
+	.mgmt_frame_register = cfg80211_rtw_mgmt_frame_register,
+};
+
+static void rtw_cfg80211_init_ht_capab(struct ieee80211_sta_ht_cap *ht_cap,
+				       enum ieee80211_band band, u8 rf_type)
+{
+
+#define MAX_BIT_RATE_40MHZ_MCS15	300	/* Mbps */
+#define MAX_BIT_RATE_40MHZ_MCS7		150	/* Mbps */
+
+	ht_cap->ht_supported = true;
+
+	ht_cap->cap = IEEE80211_HT_CAP_SUP_WIDTH_20_40 |
+	    IEEE80211_HT_CAP_SGI_40 | IEEE80211_HT_CAP_SGI_20 |
+	    IEEE80211_HT_CAP_DSSSCCK40 | IEEE80211_HT_CAP_MAX_AMSDU;
+
+	/*
+	 *Maximum length of AMPDU that the STA can receive.
+	 *Length = 2 ^ (13 + max_ampdu_length_exp) - 1 (octets)
+	 */
+	ht_cap->ampdu_factor = IEEE80211_HT_MAX_AMPDU_64K;
+
+	/*Minimum MPDU start spacing , */
+	ht_cap->ampdu_density = IEEE80211_HT_MPDU_DENSITY_16;
+
+	ht_cap->mcs.tx_params = IEEE80211_HT_MCS_TX_DEFINED;
+
+	/*
+	 *hw->wiphy->bands[IEEE80211_BAND_2GHZ]
+	 *base on ant_num
+	 *rx_mask: RX mask
+	 *if rx_ant = 1 rx_mask[0]= 0xff;==>MCS0-MCS7
+	 *if rx_ant = 2 rx_mask[1]= 0xff;==>MCS8-MCS15
+	 *if rx_ant >= 3 rx_mask[2]= 0xff;
+	 *if BW_40 rx_mask[4]= 0x01;
+	 *highest supported RX rate
+	 */
+	if (rf_type == RF_1T1R) {
+		ht_cap->mcs.rx_mask[0] = 0xFF;
+		ht_cap->mcs.rx_mask[1] = 0x00;
+		ht_cap->mcs.rx_mask[4] = 0x01;
+
+		ht_cap->mcs.rx_highest = MAX_BIT_RATE_40MHZ_MCS7;
+	} else if ((rf_type == RF_1T2R) || (rf_type == RF_2T2R)) {
+		ht_cap->mcs.rx_mask[0] = 0xFF;
+		ht_cap->mcs.rx_mask[1] = 0xFF;
+		ht_cap->mcs.rx_mask[4] = 0x01;
+
+		ht_cap->mcs.rx_highest = MAX_BIT_RATE_40MHZ_MCS15;
+	} else {
+		DBG_8723A("%s, error rf_type =%d\n", __func__, rf_type);
+	}
+
+}
+
+void rtw_cfg80211_init_wiphy(struct rtw_adapter *padapter)
+{
+	u8 rf_type;
+	struct ieee80211_supported_band *bands;
+	struct wireless_dev *pwdev = padapter->rtw_wdev;
+	struct wiphy *wiphy = pwdev->wiphy;
+
+	rtw23a_hal_get_hwreg(padapter, HW_VAR_RF_TYPE, (u8 *)(&rf_type));
+
+	DBG_8723A("%s:rf_type =%d\n", __func__, rf_type);
+
+	/* if (padapter->registrypriv.wireless_mode & WIRELESS_11G) */
+	{
+		bands = wiphy->bands[IEEE80211_BAND_2GHZ];
+		if (bands)
+			rtw_cfg80211_init_ht_capab(&bands->ht_cap,
+						   IEEE80211_BAND_2GHZ,
+						   rf_type);
+	}
+
+	/* if (padapter->registrypriv.wireless_mode & WIRELESS_11A) */
+	{
+		bands = wiphy->bands[IEEE80211_BAND_5GHZ];
+		if (bands)
+			rtw_cfg80211_init_ht_capab(&bands->ht_cap,
+						   IEEE80211_BAND_5GHZ,
+						   rf_type);
+	}
+}
+
+static void rtw_cfg80211_preinit_wiphy(struct rtw_adapter *padapter,
+				       struct wiphy *wiphy)
+{
+	wiphy->signal_type = CFG80211_SIGNAL_TYPE_MBM;
+
+	wiphy->max_scan_ssids = RTW_SSID_SCAN_AMOUNT;
+	wiphy->max_scan_ie_len = IEEE80211_MAX_DATA_LEN;
+	wiphy->max_num_pmkids = RTW_MAX_NUM_PMKIDS;
+
+	wiphy->max_remain_on_channel_duration =
+	    RTW_MAX_REMAIN_ON_CHANNEL_DURATION;
+
+	wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION) |
+	    BIT(NL80211_IFTYPE_ADHOC) |
+#ifdef CONFIG_8723AU_AP_MODE
+	    BIT(NL80211_IFTYPE_AP) | BIT(NL80211_IFTYPE_MONITOR) |
+#endif
+#if defined(CONFIG_8723AU_P2P)
+	    BIT(NL80211_IFTYPE_P2P_CLIENT) | BIT(NL80211_IFTYPE_P2P_GO) |
+#endif
+	    0;
+
+#ifdef CONFIG_8723AU_AP_MODE
+	wiphy->mgmt_stypes = rtw_cfg80211_default_mgmt_stypes;
+#endif /* CONFIG_8723AU_AP_MODE */
+
+	wiphy->software_iftypes |= BIT(NL80211_IFTYPE_MONITOR);
+
+	/*
+	   wiphy->iface_combinations = &rtw_combinations;
+	   wiphy->n_iface_combinations = 1;
+	 */
+
+	wiphy->cipher_suites = rtw_cipher_suites;
+	wiphy->n_cipher_suites = ARRAY_SIZE(rtw_cipher_suites);
+
+	/* if (padapter->registrypriv.wireless_mode & WIRELESS_11G) */
+	wiphy->bands[IEEE80211_BAND_2GHZ] =
+	    rtw_spt_band_alloc(IEEE80211_BAND_2GHZ);
+	/* if (padapter->registrypriv.wireless_mode & WIRELESS_11A) */
+	wiphy->bands[IEEE80211_BAND_5GHZ] =
+	    rtw_spt_band_alloc(IEEE80211_BAND_5GHZ);
+
+	wiphy->flags |= WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL;
+	wiphy->flags |= WIPHY_FLAG_OFFCHAN_TX | WIPHY_FLAG_HAVE_AP_SME;
+
+	if (padapter->registrypriv.power_mgnt != PS_MODE_ACTIVE)
+		wiphy->flags |= WIPHY_FLAG_PS_ON_BY_DEFAULT;
+	else
+		wiphy->flags &= ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+}
+
+int rtw_wdev_alloc(struct rtw_adapter *padapter, struct device *dev)
+{
+	int ret = 0;
+	struct wiphy *wiphy;
+	struct wireless_dev *wdev;
+	struct rtw_wdev_priv *pwdev_priv;
+	struct net_device *pnetdev = padapter->pnetdev;
+
+	DBG_8723A("%s(padapter =%p)\n", __func__, padapter);
+
+	/* wiphy */
+	wiphy = wiphy_new(&rtw_cfg80211_ops, sizeof(struct rtw_wdev_priv));
+	if (!wiphy) {
+		DBG_8723A("Couldn't allocate wiphy device\n");
+		ret = -ENOMEM;
+		goto exit;
+	}
+	set_wiphy_dev(wiphy, dev);
+	rtw_cfg80211_preinit_wiphy(padapter, wiphy);
+
+	ret = wiphy_register(wiphy);
+	if (ret < 0) {
+		DBG_8723A("Couldn't register wiphy device\n");
+		goto free_wiphy;
+	}
+
+	/*  wdev */
+	wdev = kzalloc(sizeof(struct wireless_dev), GFP_KERNEL);
+	if (!wdev) {
+		DBG_8723A("Couldn't allocate wireless device\n");
+		ret = -ENOMEM;
+		goto unregister_wiphy;
+	}
+	wdev->wiphy = wiphy;
+	wdev->netdev = pnetdev;
+	/* wdev->iftype = NL80211_IFTYPE_STATION; */
+	/*  for rtw_setopmode_cmd23a() in cfg80211_rtw_change_iface() */
+	wdev->iftype = NL80211_IFTYPE_MONITOR;
+	padapter->rtw_wdev = wdev;
+	pnetdev->ieee80211_ptr = wdev;
+
+	/* init pwdev_priv */
+	pwdev_priv = wdev_to_priv(wdev);
+	pwdev_priv->rtw_wdev = wdev;
+	pwdev_priv->pmon_ndev = NULL;
+	pwdev_priv->ifname_mon[0] = '\0';
+	pwdev_priv->padapter = padapter;
+	pwdev_priv->scan_request = NULL;
+	spin_lock_init(&pwdev_priv->scan_req_lock);
+
+	pwdev_priv->p2p_enabled = false;
+	pwdev_priv->provdisc_req_issued = false;
+	rtw_wdev_invit_info_init(&pwdev_priv->invit_info);
+
+	if (padapter->registrypriv.power_mgnt != PS_MODE_ACTIVE)
+		pwdev_priv->power_mgmt = true;
+	else
+		pwdev_priv->power_mgmt = false;
+
+	return ret;
+unregister_wiphy:
+	wiphy_unregister(wiphy);
+free_wiphy:
+	wiphy_free(wiphy);
+exit:
+	return ret;
+}
+
+void rtw_wdev_free(struct wireless_dev *wdev)
+{
+	struct rtw_wdev_priv *pwdev_priv;
+
+	DBG_8723A("%s(wdev =%p)\n", __func__, wdev);
+
+	if (!wdev)
+		return;
+
+	pwdev_priv = wdev_to_priv(wdev);
+
+	kfree(wdev->wiphy->bands[IEEE80211_BAND_2GHZ]);
+	kfree(wdev->wiphy->bands[IEEE80211_BAND_5GHZ]);
+
+	wiphy_free(wdev->wiphy);
+
+	kfree(wdev);
+}
+
+void rtw_wdev_unregister(struct wireless_dev *wdev)
+{
+	struct rtw_wdev_priv *pwdev_priv;
+
+	DBG_8723A("%s(wdev =%p)\n", __func__, wdev);
+
+	if (!wdev)
+		return;
+
+	pwdev_priv = wdev_to_priv(wdev);
+
+	rtw_cfg80211_indicate_scan_done(pwdev_priv, true);
+
+	if (pwdev_priv->pmon_ndev) {
+		DBG_8723A("%s, unregister monitor interface\n", __func__);
+		unregister_netdev(pwdev_priv->pmon_ndev);
+	}
+
+	wiphy_unregister(wdev->wiphy);
+}
diff --git a/drivers/staging/rtl8723au/os_dep/mlme_linux.c b/drivers/staging/rtl8723au/os_dep/mlme_linux.c
new file mode 100644
index 0000000..b30d4d3
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/mlme_linux.c
@@ -0,0 +1,187 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+
+#define _MLME_OSDEP_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <mlme_osdep.h>
+#include <rtw_ioctl_set.h>
+
+void rtw_os_indicate_connect23a(struct rtw_adapter *adapter)
+{
+	rtw_cfg80211_indicate_connect(adapter);
+
+	netif_carrier_on(adapter->pnetdev);
+
+	if (adapter->pid[2] != 0)
+		rtw_signal_process(adapter->pid[2], SIGALRM);
+}
+
+void rtw_os_indicate_scan_done23a(struct rtw_adapter *padapter, bool aborted)
+{
+	rtw_cfg80211_indicate_scan_done(wdev_to_priv(padapter->rtw_wdev),
+					aborted);
+}
+
+static struct rt_pmkid_list backupPMKIDList[NUM_PMKID_CACHE];
+
+void rtw_reset_securitypriv23a(struct rtw_adapter *adapter)
+{
+	u8	backupPMKIDIndex = 0;
+	u8	backupTKIPCountermeasure = 0x00;
+	unsigned long backupTKIPcountermeasure_time = 0;
+
+	if (adapter->securitypriv.dot11AuthAlgrthm ==
+	    dot11AuthAlgrthm_8021X) { /* 802.1x */
+		/*  We have to backup the PMK information for WiFi PMK
+		 *  Caching test item.
+		 *  Backup the btkip_countermeasure information.
+		 *  When the countermeasure is trigger, the driver have to
+		 *  disconnect with AP for 60 seconds.
+		 */
+		memset(&backupPMKIDList[0], 0x00, sizeof(struct rt_pmkid_list) *
+		       NUM_PMKID_CACHE);
+
+		memcpy(&backupPMKIDList[0], &adapter->securitypriv.PMKIDList[0],
+		       sizeof(struct rt_pmkid_list) * NUM_PMKID_CACHE);
+		backupPMKIDIndex = adapter->securitypriv.PMKIDIndex;
+		backupTKIPCountermeasure = adapter->securitypriv.btkip_countermeasure;
+		backupTKIPcountermeasure_time = adapter->securitypriv.btkip_countermeasure_time;
+
+		memset((unsigned char *)&adapter->securitypriv, 0,
+		       sizeof (struct security_priv));
+		/* Restore the PMK information to securitypriv structure
+		 * for the following connection.
+		 */
+		memcpy(&adapter->securitypriv.PMKIDList[0], &backupPMKIDList[0],
+		       sizeof(struct rt_pmkid_list) * NUM_PMKID_CACHE);
+		adapter->securitypriv.PMKIDIndex = backupPMKIDIndex;
+		adapter->securitypriv.btkip_countermeasure = backupTKIPCountermeasure;
+		adapter->securitypriv.btkip_countermeasure_time = backupTKIPcountermeasure_time;
+
+		adapter->securitypriv.ndisauthtype = Ndis802_11AuthModeOpen;
+		adapter->securitypriv.ndisencryptstatus = Ndis802_11WEPDisabled;
+	} else {  /* reset values in securitypriv */
+		struct security_priv *psec_priv = &adapter->securitypriv;
+
+		/* open system */
+		psec_priv->dot11AuthAlgrthm = dot11AuthAlgrthm_Open;
+		psec_priv->dot11PrivacyAlgrthm = _NO_PRIVACY_;
+		psec_priv->dot11PrivacyKeyIndex = 0;
+
+		psec_priv->dot118021XGrpPrivacy = _NO_PRIVACY_;
+		psec_priv->dot118021XGrpKeyid = 1;
+
+		psec_priv->ndisauthtype = Ndis802_11AuthModeOpen;
+		psec_priv->ndisencryptstatus = Ndis802_11WEPDisabled;
+	}
+}
+
+void rtw_os_indicate_disconnect23a(struct rtw_adapter *adapter)
+{
+	/* Do it first for tx broadcast pkt after disconnection issue! */
+	netif_carrier_off(adapter->pnetdev);
+
+	rtw_cfg80211_indicate_disconnect(adapter);
+
+	rtw_reset_securitypriv23a(adapter);
+}
+
+void rtw_report_sec_ie23a(struct rtw_adapter *adapter, u8 authmode, u8 *sec_ie)
+{
+	uint	len;
+	u8	*buff, *p, i;
+	union iwreq_data wrqu;
+
+	RT_TRACE(_module_mlme_osdep_c_, _drv_info_,
+		 ("+rtw_report_sec_ie23a, authmode =%d\n", authmode));
+
+	buff = NULL;
+	if (authmode == _WPA_IE_ID_) {
+		RT_TRACE(_module_mlme_osdep_c_, _drv_info_,
+			 ("rtw_report_sec_ie23a, authmode =%d\n", authmode));
+
+		buff = kzalloc(IW_CUSTOM_MAX, GFP_KERNEL);
+		if (!buff)
+			return;
+		p = buff;
+
+		p += sprintf(p, "ASSOCINFO(ReqIEs =");
+
+		len = sec_ie[1]+2;
+		len =  (len < IW_CUSTOM_MAX) ? len : IW_CUSTOM_MAX;
+
+		for (i = 0; i < len; i++)
+			p += sprintf(p, "%02x", sec_ie[i]);
+
+		p += sprintf(p, ")");
+
+		memset(&wrqu, 0, sizeof(wrqu));
+
+		wrqu.data.length = p-buff;
+
+		wrqu.data.length = (wrqu.data.length < IW_CUSTOM_MAX) ?
+				   wrqu.data.length : IW_CUSTOM_MAX;
+
+		kfree(buff);
+	}
+}
+
+#ifdef CONFIG_8723AU_AP_MODE
+void rtw_indicate_sta_assoc_event23a(struct rtw_adapter *padapter,
+				  struct sta_info *psta)
+{
+	struct sta_priv *pstapriv = &padapter->stapriv;
+	union iwreq_data wrqu;
+
+	if (psta == NULL)
+		return;
+
+	if (psta->aid > NUM_STA)
+		return;
+
+	if (pstapriv->sta_aid[psta->aid - 1] != psta)
+		return;
+
+	wrqu.addr.sa_family = ARPHRD_ETHER;
+
+	memcpy(wrqu.addr.sa_data, psta->hwaddr, ETH_ALEN);
+
+	DBG_8723A("+rtw_indicate_sta_assoc_event23a\n");
+}
+
+void rtw_indicate_sta_disassoc_event23a(struct rtw_adapter *padapter,
+				     struct sta_info *psta)
+{
+	struct sta_priv *pstapriv = &padapter->stapriv;
+	union iwreq_data wrqu;
+
+	if (psta == NULL)
+		return;
+
+	if (psta->aid > NUM_STA)
+		return;
+
+	if (pstapriv->sta_aid[psta->aid - 1] != psta)
+		return;
+
+	wrqu.addr.sa_family = ARPHRD_ETHER;
+
+	memcpy(wrqu.addr.sa_data, psta->hwaddr, ETH_ALEN);
+
+	DBG_8723A("+rtw_indicate_sta_disassoc_event23a\n");
+}
+#endif
diff --git a/drivers/staging/rtl8723au/os_dep/os_intfs.c b/drivers/staging/rtl8723au/os_dep/os_intfs.c
new file mode 100644
index 0000000..57eca7a
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/os_intfs.c
@@ -0,0 +1,970 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+#define _OS_INTFS_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <xmit_osdep.h>
+#include <recv_osdep.h>
+#include <hal_intf.h>
+#include <rtw_version.h>
+#include <ethernet.h>
+
+#include <usb_osintf.h>
+#include <linux/version.h>
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Realtek Wireless Lan Driver");
+MODULE_AUTHOR("Realtek Semiconductor Corp.");
+MODULE_AUTHOR("Larry Finger <Larry.Finger@lwfinger.net>");
+MODULE_AUTHOR("Jes Sorensen <Jes.Sorensen@redhat.com>");
+MODULE_VERSION(DRIVERVERSION);
+MODULE_FIRMWARE("rtlwifi/rtl8821aefw.bin");
+
+/* module param defaults */
+static int rtw_chip_version = 0x00;
+static int rtw_rfintfs = HWPI;
+static int rtw_debug = 1;
+
+static int rtw_channel = 1;/* ad-hoc support requirement */
+static int rtw_wireless_mode = WIRELESS_11BG_24N;
+static int rtw_vrtl_carrier_sense = AUTO_VCS;
+static int rtw_vcs_type = RTS_CTS;/*  */
+static int rtw_rts_thresh = 2347;/*  */
+static int rtw_frag_thresh = 2346;/*  */
+static int rtw_preamble = PREAMBLE_LONG;/* long, short, auto */
+static int rtw_scan_mode = 1;/* active, passive */
+static int rtw_adhoc_tx_pwr = 1;
+static int rtw_soft_ap;
+static int rtw_power_mgnt = 1;
+static int rtw_ips_mode = IPS_NORMAL;
+
+static int rtw_smart_ps = 2;
+
+module_param(rtw_ips_mode, int, 0644);
+MODULE_PARM_DESC(rtw_ips_mode, "The default IPS mode");
+
+static int rtw_long_retry_lmt = 7;
+static int rtw_short_retry_lmt = 7;
+static int rtw_busy_thresh = 40;
+static int rtw_ack_policy = NORMAL_ACK;
+
+static int rtw_acm_method;/*  0:By SW 1:By HW. */
+
+static int rtw_wmm_enable = 1;/*  default is set to enable the wmm. */
+static int rtw_uapsd_enable;
+
+int rtw_ht_enable23A = 1;
+/* 0 :diable, bit(0): enable 2.4g, bit(1): enable 5g */
+int rtw_cbw40_enable23A = 3;
+int rtw_ampdu_enable23A = 1;/* for enable tx_ampdu */
+/*  0: disable, bit(0):enable 2.4g, bit(1):enable 5g, default is set to enable
+ * 2.4GHZ for IOT issue with bufflao's AP at 5GHZ
+ */
+static int rtw_rx_stbc = 1;
+static int rtw_ampdu_amsdu;/*  0: disabled, 1:enabled, 2:auto */
+
+/* Use 2 path Tx to transmit MCS0~7 and legacy mode */
+static int rtw_lowrate_two_xmit = 1;
+
+/* int rf_config = RF_1T2R;  1T2R */
+static int rtw_rf_config = RF_819X_MAX_TYPE;  /* auto */
+static int rtw_low_power;
+static int rtw_wifi_spec;
+static int rtw_channel_plan = RT_CHANNEL_DOMAIN_MAX;
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+static int rtw_btcoex_enable = 1;
+static int rtw_bt_iso = 2;/*  0:Low, 1:High, 2:From Efuse */
+/*  0:Idle, 1:None-SCO, 2:SCO, 3:From Counter, 4.Busy, 5.OtherBusy */
+static int rtw_bt_sco = 3;
+/*  0:Disable BT control A-MPDU, 1:Enable BT control A-MPDU. */
+static int rtw_bt_ampdu = 1 ;
+#endif
+
+/*  0:Reject AP's Add BA req, 1:Accept AP's Add BA req. */
+static int rtw_AcceptAddbaReq = true;
+
+static int rtw_antdiv_cfg = 2; /*  0:OFF , 1:ON, 2:decide by Efuse config */
+static int rtw_antdiv_type; /* 0:decide by efuse */
+
+static int rtw_enusbss;/* 0:disable, 1:enable */
+
+static int rtw_hwpdn_mode = 2;/* 0:disable, 1:enable, 2: by EFUSE config */
+
+static int rtw_hwpwrp_detect; /* HW power  ping detect 0:disable , 1:enable */
+
+static int rtw_hw_wps_pbc = 1;
+
+static int rtw_80211d;
+
+static int rtw_regulatory_id = 0xff;/*  Regulatory tab id, 0xff = follow efuse's setting */
+
+module_param(rtw_regulatory_id, int, 0644);
+
+static char *ifname = "wlan%d";
+module_param(ifname, charp, 0644);
+MODULE_PARM_DESC(ifname, "The default name to allocate for first interface");
+
+static char *if2name = "wlan%d";
+module_param(if2name, charp, 0644);
+MODULE_PARM_DESC(if2name, "The default name to allocate for second interface");
+
+module_param(rtw_channel_plan, int, 0644);
+module_param(rtw_chip_version, int, 0644);
+module_param(rtw_rfintfs, int, 0644);
+module_param(rtw_channel, int, 0644);
+module_param(rtw_wmm_enable, int, 0644);
+module_param(rtw_vrtl_carrier_sense, int, 0644);
+module_param(rtw_vcs_type, int, 0644);
+module_param(rtw_busy_thresh, int, 0644);
+module_param(rtw_ht_enable23A, int, 0644);
+module_param(rtw_cbw40_enable23A, int, 0644);
+module_param(rtw_ampdu_enable23A, int, 0644);
+module_param(rtw_rx_stbc, int, 0644);
+module_param(rtw_ampdu_amsdu, int, 0644);
+
+module_param(rtw_lowrate_two_xmit, int, 0644);
+
+module_param(rtw_rf_config, int, 0644);
+module_param(rtw_power_mgnt, int, 0644);
+module_param(rtw_smart_ps, int, 0644);
+module_param(rtw_low_power, int, 0644);
+module_param(rtw_wifi_spec, int, 0644);
+
+module_param(rtw_antdiv_cfg, int, 0644);
+
+module_param(rtw_enusbss, int, 0644);
+module_param(rtw_hwpdn_mode, int, 0644);
+module_param(rtw_hwpwrp_detect, int, 0644);
+
+module_param(rtw_hw_wps_pbc, int, 0644);
+
+static uint rtw_max_roaming_times = 2;
+module_param(rtw_max_roaming_times, uint, 0644);
+MODULE_PARM_DESC(rtw_max_roaming_times, "The max roaming times to try");
+
+module_param(rtw_80211d, int, 0644);
+MODULE_PARM_DESC(rtw_80211d, "Enable 802.11d mechanism");
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+module_param(rtw_btcoex_enable, int, 0644);
+MODULE_PARM_DESC(rtw_btcoex_enable, "Enable BT co-existence mechanism");
+#endif
+
+static uint rtw_notch_filter;
+module_param(rtw_notch_filter, uint, 0644);
+MODULE_PARM_DESC(rtw_notch_filter, "0:Disable, 1:Enable, 2:Enable only for P2P");
+module_param_named(debug, rtw_debug, int, 0444);
+MODULE_PARM_DESC(debug, "Set debug level (1-9) (default 1)");
+
+static int netdev_close(struct net_device *pnetdev);
+
+static uint loadparam(struct rtw_adapter *padapter,  struct net_device *pnetdev)
+{
+	struct registry_priv  *registry_par = &padapter->registrypriv;
+	uint status = _SUCCESS;
+
+	GlobalDebugLevel23A = rtw_debug;
+	registry_par->chip_version = (u8)rtw_chip_version;
+	registry_par->rfintfs = (u8)rtw_rfintfs;
+	memcpy(registry_par->ssid.ssid, "ANY", 3);
+	registry_par->ssid.ssid_len = 3;
+	registry_par->channel = (u8)rtw_channel;
+	registry_par->wireless_mode = (u8)rtw_wireless_mode;
+	registry_par->vrtl_carrier_sense = (u8)rtw_vrtl_carrier_sense;
+	registry_par->vcs_type = (u8)rtw_vcs_type;
+	registry_par->rts_thresh = (u16)rtw_rts_thresh;
+	registry_par->frag_thresh = (u16)rtw_frag_thresh;
+	registry_par->preamble = (u8)rtw_preamble;
+	registry_par->scan_mode = (u8)rtw_scan_mode;
+	registry_par->adhoc_tx_pwr = (u8)rtw_adhoc_tx_pwr;
+	registry_par->soft_ap =  (u8)rtw_soft_ap;
+	registry_par->smart_ps =  (u8)rtw_smart_ps;
+	registry_par->power_mgnt = (u8)rtw_power_mgnt;
+	registry_par->ips_mode = (u8)rtw_ips_mode;
+	registry_par->long_retry_lmt = (u8)rtw_long_retry_lmt;
+	registry_par->short_retry_lmt = (u8)rtw_short_retry_lmt;
+	registry_par->busy_thresh = (u16)rtw_busy_thresh;
+	registry_par->ack_policy = (u8)rtw_ack_policy;
+	registry_par->acm_method = (u8)rtw_acm_method;
+	 /* UAPSD */
+	registry_par->wmm_enable = (u8)rtw_wmm_enable;
+	registry_par->uapsd_enable = (u8)rtw_uapsd_enable;
+	registry_par->ht_enable = (u8)rtw_ht_enable23A;
+	registry_par->cbw40_enable = (u8)rtw_cbw40_enable23A;
+	registry_par->ampdu_enable = (u8)rtw_ampdu_enable23A;
+	registry_par->rx_stbc = (u8)rtw_rx_stbc;
+	registry_par->ampdu_amsdu = (u8)rtw_ampdu_amsdu;
+	registry_par->lowrate_two_xmit = (u8)rtw_lowrate_two_xmit;
+	registry_par->rf_config = (u8)rtw_rf_config;
+	registry_par->low_power = (u8)rtw_low_power;
+	registry_par->wifi_spec = (u8)rtw_wifi_spec;
+	registry_par->channel_plan = (u8)rtw_channel_plan;
+#ifdef CONFIG_8723AU_BT_COEXIST
+	registry_par->btcoex = (u8)rtw_btcoex_enable;
+	registry_par->bt_iso = (u8)rtw_bt_iso;
+	registry_par->bt_sco = (u8)rtw_bt_sco;
+	registry_par->bt_ampdu = (u8)rtw_bt_ampdu;
+#endif
+	registry_par->bAcceptAddbaReq = (u8)rtw_AcceptAddbaReq;
+	registry_par->antdiv_cfg = (u8)rtw_antdiv_cfg;
+	registry_par->antdiv_type = (u8)rtw_antdiv_type;
+
+	/* 0:disable, 1:enable, 2:by EFUSE config */
+	registry_par->hwpdn_mode = (u8)rtw_hwpdn_mode;
+	/* 0:disable, 1:enable */
+	registry_par->hwpwrp_detect = (u8)rtw_hwpwrp_detect;
+	registry_par->hw_wps_pbc = (u8)rtw_hw_wps_pbc;
+	registry_par->max_roaming_times = (u8)rtw_max_roaming_times;
+	registry_par->enable80211d = (u8)rtw_80211d;
+	snprintf(registry_par->ifname, 16, "%s", ifname);
+	snprintf(registry_par->if2name, 16, "%s", if2name);
+	registry_par->notch_filter = (u8)rtw_notch_filter;
+	registry_par->regulatory_tid = (u8)rtw_regulatory_id;
+	return status;
+}
+
+static int rtw_net_set_mac_address(struct net_device *pnetdev, void *p)
+{
+	struct rtw_adapter *padapter = netdev_priv(pnetdev);
+	struct sockaddr *addr = p;
+
+	if (!padapter->bup)
+		ether_addr_copy(padapter->eeprompriv.mac_addr, addr->sa_data);
+	return 0;
+}
+
+static struct net_device_stats *rtw_net_get_stats(struct net_device *pnetdev)
+{
+	struct rtw_adapter *padapter = netdev_priv(pnetdev);
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	struct recv_priv *precvpriv = &padapter->recvpriv;
+
+	padapter->stats.tx_packets = pxmitpriv->tx_pkts;
+	padapter->stats.rx_packets = precvpriv->rx_pkts;
+	padapter->stats.tx_dropped = pxmitpriv->tx_drop;
+	padapter->stats.rx_dropped = precvpriv->rx_drop;
+	padapter->stats.tx_bytes = pxmitpriv->tx_bytes;
+	padapter->stats.rx_bytes = precvpriv->rx_bytes;
+
+	return &padapter->stats;
+}
+
+/*
+ * AC to queue mapping
+ *
+ * AC_VO -> queue 0
+ * AC_VI -> queue 1
+ * AC_BE -> queue 2
+ * AC_BK -> queue 3
+ */
+static const u16 rtw_1d_to_queue[8] = { 2, 3, 3, 2, 1, 1, 0, 0 };
+
+/* Given a data frame determine the 802.1p/1d tag to use. */
+static unsigned int rtw_classify8021d(struct sk_buff *skb)
+{
+	unsigned int dscp;
+
+	/* skb->priority values from 256->263 are magic values to
+	 * directly indicate a specific 802.1d priority.  This is used
+	 * to allow 802.1d priority to be passed directly in from VLAN
+	 * tags, etc.
+	 */
+	if (skb->priority >= 256 && skb->priority <= 263)
+		return skb->priority - 256;
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		dscp = ip_hdr(skb)->tos & 0xfc;
+		break;
+	default:
+		return 0;
+	}
+	return dscp >> 5;
+}
+
+static u16 rtw_select_queue(struct net_device *dev, struct sk_buff *skb,
+			    void *accel_priv,
+			    select_queue_fallback_t fallback)
+{
+	struct rtw_adapter *padapter = netdev_priv(dev);
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+	skb->priority = rtw_classify8021d(skb);
+
+	if (pmlmepriv->acm_mask != 0)
+		skb->priority = qos_acm23a(pmlmepriv->acm_mask, skb->priority);
+	return rtw_1d_to_queue[skb->priority];
+}
+
+u16 rtw_recv_select_queue23a(struct sk_buff *skb)
+{
+	struct iphdr *piphdr;
+	unsigned int dscp;
+	u16 eth_type;
+	u32 priority;
+	u8 *pdata = skb->data;
+
+	memcpy(&eth_type, pdata + (ETH_ALEN << 1), 2);
+	switch (eth_type) {
+	case htons(ETH_P_IP):
+		piphdr = (struct iphdr *)(pdata + ETH_HLEN);
+		dscp = piphdr->tos & 0xfc;
+		priority = dscp >> 5;
+		break;
+	default:
+		priority = 0;
+	}
+	return rtw_1d_to_queue[priority];
+}
+
+static const struct net_device_ops rtw_netdev_ops = {
+	.ndo_open = netdev_open23a,
+	.ndo_stop = netdev_close,
+	.ndo_start_xmit = rtw_xmit23a_entry23a,
+	.ndo_select_queue = rtw_select_queue,
+	.ndo_set_mac_address = rtw_net_set_mac_address,
+	.ndo_get_stats = rtw_net_get_stats,
+};
+
+int rtw_init_netdev23a_name23a(struct net_device *pnetdev, const char *ifname)
+{
+	if (dev_alloc_name(pnetdev, ifname) < 0) {
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("dev_alloc_name, fail!\n"));
+	}
+	netif_carrier_off(pnetdev);
+	return 0;
+}
+
+static const struct device_type wlan_type = {
+	.name = "wlan",
+};
+
+struct net_device *rtw_init_netdev23a(struct rtw_adapter *old_padapter)
+{
+	struct rtw_adapter *padapter;
+	struct net_device *pnetdev;
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+init_net_dev\n"));
+
+	pnetdev = alloc_etherdev_mq(sizeof(struct rtw_adapter), 4);
+	if (!pnetdev)
+		return NULL;
+
+	pnetdev->dev.type = &wlan_type;
+	padapter = netdev_priv(pnetdev);
+	padapter->pnetdev = pnetdev;
+
+	DBG_8723A("register rtw_netdev_ops to netdev_ops\n");
+	pnetdev->netdev_ops = &rtw_netdev_ops;
+
+	pnetdev->watchdog_timeo = HZ*3; /* 3 second timeout */
+
+	/* step 2. */
+	loadparam(padapter, pnetdev);
+	return pnetdev;
+}
+
+u32 rtw_start_drv_threads23a(struct rtw_adapter *padapter)
+{
+	u32 _status = _SUCCESS;
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_,
+		 ("+rtw_start_drv_threads23a\n"));
+	padapter->cmdThread = kthread_run(rtw_cmd_thread23a, padapter,
+					  "RTW_CMD_THREAD");
+	if (IS_ERR(padapter->cmdThread)) {
+		_status = _FAIL;
+	} else {
+		/* wait for cmd_thread to run */
+		down(&padapter->cmdpriv.terminate_cmdthread_sema);
+	}
+	rtw_hal_start_thread23a(padapter);
+	return _status;
+}
+
+void rtw_stop_drv_threads23a(struct rtw_adapter *padapter)
+{
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+rtw_stop_drv_threads23a\n"));
+
+	/* Below is to termindate rtw_cmd_thread23a & event_thread... */
+	up(&padapter->cmdpriv.cmd_queue_sema);
+	if (padapter->cmdThread)
+		down(&padapter->cmdpriv.terminate_cmdthread_sema);
+	rtw_hal_stop_thread23a(padapter);
+}
+
+static u8 rtw_init_default_value(struct rtw_adapter *padapter)
+{
+	struct registry_priv *pregistrypriv = &padapter->registrypriv;
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+	u8 ret = _SUCCESS;
+
+	/* xmit_priv */
+	pxmitpriv->vcs_setting = pregistrypriv->vrtl_carrier_sense;
+	pxmitpriv->vcs = pregistrypriv->vcs_type;
+	pxmitpriv->vcs_type = pregistrypriv->vcs_type;
+	/* pxmitpriv->rts_thresh = pregistrypriv->rts_thresh; */
+	pxmitpriv->frag_len = pregistrypriv->frag_thresh;
+
+	/* mlme_priv */
+	pmlmepriv->scan_interval = SCAN_INTERVAL;/*  30*2 sec = 60sec */
+	pmlmepriv->scan_mode = SCAN_ACTIVE;
+
+	/* ht_priv */
+	pmlmepriv->htpriv.ampdu_enable = false;/* set to disabled */
+
+	/* security_priv */
+	psecuritypriv->binstallGrpkey = _FAIL;
+
+	 /* open system */
+	psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_Open;
+	psecuritypriv->dot11PrivacyAlgrthm = _NO_PRIVACY_;
+
+	psecuritypriv->dot11PrivacyKeyIndex = 0;
+
+	psecuritypriv->dot118021XGrpPrivacy = _NO_PRIVACY_;
+	psecuritypriv->dot118021XGrpKeyid = 1;
+
+	psecuritypriv->ndisauthtype = Ndis802_11AuthModeOpen;
+	psecuritypriv->ndisencryptstatus = Ndis802_11WEPDisabled;
+
+	/* registry_priv */
+	rtw_init_registrypriv_dev_network23a(padapter);
+	rtw_update_registrypriv_dev_network23a(padapter);
+
+	/* hal_priv */
+	rtw_hal_def_value_init23a(padapter);
+
+	/* misc. */
+	padapter->bReadPortCancel = false;
+	padapter->bWritePortCancel = false;
+	padapter->bRxRSSIDisplay = 0;
+	padapter->bNotifyChannelChange = 0;
+#ifdef CONFIG_8723AU_P2P
+	padapter->bShowGetP2PState = 1;
+#endif
+	return ret;
+}
+
+u8 rtw_reset_drv_sw23a(struct rtw_adapter *padapter)
+{
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct pwrctrl_priv *pwrctrlpriv = &padapter->pwrctrlpriv;
+	u8 ret8 = _SUCCESS;
+
+	/* hal_priv */
+	rtw_hal_def_value_init23a(padapter);
+	padapter->bReadPortCancel = false;
+	padapter->bWritePortCancel = false;
+	padapter->bRxRSSIDisplay = 0;
+	pmlmepriv->scan_interval = SCAN_INTERVAL;/*  30*2 sec = 60sec */
+
+	padapter->xmitpriv.tx_pkts = 0;
+	padapter->recvpriv.rx_pkts = 0;
+
+	pmlmepriv->LinkDetectInfo.bBusyTraffic = false;
+
+	_clr_fwstate_(pmlmepriv, _FW_UNDER_SURVEY | _FW_UNDER_LINKING);
+
+	rtw_hal_sreset_reset23a_value23a(padapter);
+	pwrctrlpriv->pwr_state_check_cnts = 0;
+
+	/* mlmeextpriv */
+	padapter->mlmeextpriv.sitesurvey_res.state = SCAN_DISABLE;
+
+	rtw_set_signal_stat_timer(&padapter->recvpriv);
+	return ret8;
+}
+
+u8 rtw_init_drv_sw23a(struct rtw_adapter *padapter)
+{
+	u8 ret8 = _SUCCESS;
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+rtw_init_drv_sw23a\n"));
+
+	if ((rtw_init_cmd_priv23a(&padapter->cmdpriv)) == _FAIL) {
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("\n Can't init cmd_priv\n"));
+		ret8 = _FAIL;
+		goto exit;
+	}
+
+	padapter->cmdpriv.padapter = padapter;
+
+	if (rtw_init_evt_priv23a(&padapter->evtpriv) == _FAIL) {
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("\n Can't init evt_priv\n"));
+		ret8 = _FAIL;
+		goto exit;
+	}
+
+	if (rtw_init_mlme_priv23a(padapter) == _FAIL) {
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("\n Can't init mlme_priv\n"));
+		ret8 = _FAIL;
+		goto exit;
+	}
+
+#ifdef CONFIG_8723AU_P2P
+	rtw_init_wifidirect_timers23a(padapter);
+	init_wifidirect_info23a(padapter, P2P_ROLE_DISABLE);
+	reset_global_wifidirect_info23a(padapter);
+	rtw_init_cfg80211_wifidirect_info(padapter);
+#ifdef CONFIG_8723AU_P2P
+	if (rtw_init_wifi_display_info(padapter) == _FAIL)
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("\n Can't init init_wifi_display_info\n"));
+#endif
+#endif /* CONFIG_8723AU_P2P */
+
+	if (init_mlme_ext_priv23a(padapter) == _FAIL) {
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("\n Can't init mlme_ext_priv\n"));
+		ret8 = _FAIL;
+		goto exit;
+	}
+
+	if (_rtw_init_xmit_priv23a(&padapter->xmitpriv, padapter) == _FAIL) {
+		DBG_8723A("Can't _rtw_init_xmit_priv23a\n");
+		ret8 = _FAIL;
+		goto exit;
+	}
+
+	if (_rtw_init_recv_priv23a(&padapter->recvpriv, padapter) == _FAIL) {
+		DBG_8723A("Can't _rtw_init_recv_priv23a\n");
+		ret8 = _FAIL;
+		goto exit;
+	}
+
+	if (_rtw_init_sta_priv23a(&padapter->stapriv) == _FAIL) {
+		DBG_8723A("Can't _rtw_init_sta_priv23a\n");
+		ret8 = _FAIL;
+		goto exit;
+	}
+
+	padapter->stapriv.padapter = padapter;
+	padapter->setband = GHZ24_50;
+	rtw_init_bcmc_stainfo23a(padapter);
+
+	rtw_init_pwrctrl_priv23a(padapter);
+
+	ret8 = rtw_init_default_value(padapter);
+
+	rtw_hal_dm_init23a(padapter);
+	rtw_hal_sw_led_init23a(padapter);
+
+	rtw_hal_sreset_init23a(padapter);
+
+exit:
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("-rtw_init_drv_sw23a\n"));
+	return ret8;
+}
+
+void rtw_cancel_all_timer23a(struct rtw_adapter *padapter)
+{
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+rtw_cancel_all_timer23a\n"));
+
+	del_timer_sync(&padapter->mlmepriv.assoc_timer);
+	RT_TRACE(_module_os_intfs_c_, _drv_info_,
+		 ("rtw_cancel_all_timer23a:cancel association timer complete!\n"));
+
+	del_timer_sync(&padapter->mlmepriv.scan_to_timer);
+	RT_TRACE(_module_os_intfs_c_, _drv_info_,
+		 ("rtw_cancel_all_timer23a:cancel scan_to_timer!\n"));
+
+	del_timer_sync(&padapter->mlmepriv.dynamic_chk_timer);
+	RT_TRACE(_module_os_intfs_c_, _drv_info_,
+		 ("rtw_cancel_all_timer23a:cancel dynamic_chk_timer!\n"));
+
+	/*  cancel sw led timer */
+	rtw_hal_sw_led_deinit23a(padapter);
+	RT_TRACE(_module_os_intfs_c_, _drv_info_,
+		 ("rtw_cancel_all_timer23a:cancel DeInitSwLeds!\n"));
+
+	del_timer_sync(&padapter->pwrctrlpriv.pwr_state_check_timer);
+
+#ifdef CONFIG_8723AU_P2P
+	del_timer_sync(&padapter->cfg80211_wdinfo.remain_on_ch_timer);
+#endif /* CONFIG_8723AU_P2P */
+
+	del_timer_sync(&padapter->mlmepriv.set_scan_deny_timer);
+	rtw_clear_scan_deny(padapter);
+	RT_TRACE(_module_os_intfs_c_, _drv_info_,
+		 ("rtw_cancel_all_timer23a:cancel set_scan_deny_timer!\n"));
+
+	del_timer_sync(&padapter->recvpriv.signal_stat_timer);
+	/* cancel dm timer */
+	rtw_hal_dm_deinit23a(padapter);
+}
+
+u8 rtw_free_drv_sw23a(struct rtw_adapter *padapter)
+{
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info *pwdinfo;
+#endif
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("==>rtw_free_drv_sw23a"));
+
+	/* we can call rtw_p2p_enable23a here, but:
+	 *  1. rtw_p2p_enable23a may have IO operation
+	 *  2. rtw_p2p_enable23a is bundled with wext interface
+	 */
+#ifdef CONFIG_8723AU_P2P
+	pwdinfo = &padapter->wdinfo;
+	if (!rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
+		del_timer_sync(&pwdinfo->find_phase_timer);
+		del_timer_sync(&pwdinfo->restore_p2p_state_timer);
+		del_timer_sync(&pwdinfo->pre_tx_scan_timer);
+		rtw_p2p_set_state(pwdinfo, P2P_STATE_NONE);
+	}
+#endif
+
+	free_mlme_ext_priv23a(&padapter->mlmeextpriv);
+
+	rtw_free_cmd_priv23a(&padapter->cmdpriv);
+
+	rtw_free_evt_priv23a(&padapter->evtpriv);
+
+	rtw_free_mlme_priv23a(&padapter->mlmepriv);
+
+	_rtw_free_xmit_priv23a(&padapter->xmitpriv);
+
+	_rtw_free_sta_priv23a(&padapter->stapriv);/* will free bcmc_stainfo here */
+
+	_rtw_free_recv_priv23a(&padapter->recvpriv);
+
+	rtw_free_pwrctrl_priv(padapter);
+
+	rtw_hal_free_data23a(padapter);
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("<== rtw_free_drv_sw23a\n"));
+
+	/* free the old_pnetdev */
+	if (padapter->rereg_nd_name_priv.old_pnetdev) {
+		free_netdev(padapter->rereg_nd_name_priv.old_pnetdev);
+		padapter->rereg_nd_name_priv.old_pnetdev = NULL;
+	}
+
+	/*  clear pbuddy_adapter to avoid access wrong pointer. */
+	if (padapter->pbuddy_adapter != NULL)
+		padapter->pbuddy_adapter->pbuddy_adapter = NULL;
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("-rtw_free_drv_sw23a\n"));
+	return _SUCCESS;
+}
+
+static int _rtw_drv_register_netdev(struct rtw_adapter *padapter, char *name)
+{
+	struct net_device *pnetdev = padapter->pnetdev;
+	int ret = _SUCCESS;
+
+	/* alloc netdev name */
+	rtw_init_netdev23a_name23a(pnetdev, name);
+
+	ether_addr_copy(pnetdev->dev_addr, padapter->eeprompriv.mac_addr);
+
+	/* Tell the network stack we exist */
+	if (register_netdev(pnetdev)) {
+		DBG_8723A(FUNC_NDEV_FMT "Failed!\n", FUNC_NDEV_ARG(pnetdev));
+		ret = _FAIL;
+		goto error_register_netdev;
+	}
+	DBG_8723A("%s, MAC Address (if%d) = " MAC_FMT "\n", __func__,
+		  (padapter->iface_id + 1), MAC_ARG(pnetdev->dev_addr));
+	return ret;
+
+error_register_netdev:
+
+	if (padapter->iface_id > IFACE_ID0) {
+		rtw_free_drv_sw23a(padapter);
+
+		free_netdev(pnetdev);
+	}
+	return ret;
+}
+
+int rtw_drv_register_netdev(struct rtw_adapter *if1)
+{
+	struct dvobj_priv *dvobj = if1->dvobj;
+	int i, status = _SUCCESS;
+
+	if (dvobj->iface_nums < IFACE_ID_MAX) {
+		for (i = 0; i < dvobj->iface_nums; i++) {
+			struct rtw_adapter *padapter = dvobj->padapters[i];
+
+			if (padapter) {
+				char *name;
+
+				if (padapter->iface_id == IFACE_ID0)
+					name = if1->registrypriv.ifname;
+				else if (padapter->iface_id == IFACE_ID1)
+					name = if1->registrypriv.if2name;
+				else
+					name = "wlan%d";
+				status = _rtw_drv_register_netdev(padapter,
+								  name);
+				if (status != _SUCCESS)
+					break;
+			}
+		}
+	}
+	return status;
+}
+
+int netdev_open23a(struct net_device *pnetdev)
+{
+	struct rtw_adapter *padapter = netdev_priv(pnetdev);
+	struct pwrctrl_priv *pwrctrlpriv;
+	int ret = 0;
+	uint status;
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+871x_drv - dev_open\n"));
+	DBG_8723A("+871x_drv - drv_open, bup =%d\n", padapter->bup);
+
+	mutex_lock(&adapter_to_dvobj(padapter)->hw_init_mutex);
+
+	pwrctrlpriv = &padapter->pwrctrlpriv;
+	if (pwrctrlpriv->ps_flag) {
+		padapter->net_closed = false;
+		goto netdev_open23a_normal_process;
+	}
+
+	if (!padapter->bup) {
+		padapter->bDriverStopped = false;
+		padapter->bSurpriseRemoved = false;
+		padapter->bCardDisableWOHSM = false;
+
+		status = rtw_hal_init23a(padapter);
+		if (status == _FAIL) {
+			RT_TRACE(_module_os_intfs_c_, _drv_err_,
+				 ("rtl871x_hal_init(): Can't init h/w!\n"));
+			goto netdev_open23a_error;
+		}
+
+		DBG_8723A("MAC Address = "MAC_FMT"\n",
+			  MAC_ARG(pnetdev->dev_addr));
+
+		status = rtw_start_drv_threads23a(padapter);
+		if (status == _FAIL) {
+			DBG_8723A("Initialize driver software resource Failed!\n");
+			goto netdev_open23a_error;
+		}
+
+		if (init_hw_mlme_ext23a(padapter) == _FAIL) {
+			DBG_8723A("can't init mlme_ext_priv\n");
+			goto netdev_open23a_error;
+		}
+
+		if (padapter->intf_start)
+			padapter->intf_start(padapter);
+
+		rtw_cfg80211_init_wiphy(padapter);
+
+		rtw_led_control(padapter, LED_CTL_NO_LINK);
+
+		padapter->bup = true;
+	}
+	padapter->net_closed = false;
+
+	mod_timer(&padapter->mlmepriv.dynamic_chk_timer,
+		  jiffies + msecs_to_jiffies(2000));
+
+	padapter->pwrctrlpriv.bips_processing = false;
+	rtw_set_pwr_state_check_timer(&padapter->pwrctrlpriv);
+
+	/* netif_carrier_on(pnetdev);call this func when
+	   rtw23a_joinbss_event_cb return success */
+	if (!rtw_netif_queue_stopped(pnetdev))
+		netif_tx_start_all_queues(pnetdev);
+	else
+		netif_tx_wake_all_queues(pnetdev);
+
+netdev_open23a_normal_process:
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("-871x_drv - dev_open\n"));
+	DBG_8723A("-871x_drv - drv_open, bup =%d\n", padapter->bup);
+exit:
+	mutex_unlock(&adapter_to_dvobj(padapter)->hw_init_mutex);
+	return ret;
+
+netdev_open23a_error:
+	padapter->bup = false;
+
+	netif_carrier_off(pnetdev);
+	netif_tx_stop_all_queues(pnetdev);
+
+	RT_TRACE(_module_os_intfs_c_, _drv_err_,
+		 ("-871x_drv - dev_open, fail!\n"));
+	DBG_8723A("-871x_drv - drv_open fail, bup =%d\n", padapter->bup);
+
+	ret = -1;
+	goto exit;
+}
+
+static int  ips_netdrv_open(struct rtw_adapter *padapter)
+{
+	int status = _SUCCESS;
+
+	padapter->net_closed = false;
+	DBG_8723A("===> %s.........\n", __func__);
+
+	padapter->bDriverStopped = false;
+	padapter->bSurpriseRemoved = false;
+	padapter->bCardDisableWOHSM = false;
+
+	status = rtw_hal_init23a(padapter);
+	if (status == _FAIL) {
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("ips_netdrv_open(): Can't init h/w!\n"));
+		goto netdev_open23a_error;
+	}
+
+	if (padapter->intf_start)
+		padapter->intf_start(padapter);
+
+	rtw_set_pwr_state_check_timer(&padapter->pwrctrlpriv);
+	mod_timer(&padapter->mlmepriv.dynamic_chk_timer,
+		  jiffies + msecs_to_jiffies(5000));
+
+	return _SUCCESS;
+
+netdev_open23a_error:
+	/* padapter->bup = false; */
+	DBG_8723A("-ips_netdrv_open - drv_open failure, bup =%d\n",
+		  padapter->bup);
+
+	return _FAIL;
+}
+
+int rtw_ips_pwr_up23a(struct rtw_adapter *padapter)
+{
+	int result;
+	unsigned long start_time = jiffies;
+
+	DBG_8723A("===>  rtw_ips_pwr_up23a..............\n");
+	rtw_reset_drv_sw23a(padapter);
+
+	result = ips_netdrv_open(padapter);
+
+	rtw_led_control(padapter, LED_CTL_NO_LINK);
+
+	DBG_8723A("<===  rtw_ips_pwr_up23a.............. in %dms\n",
+		  jiffies_to_msecs(jiffies - start_time));
+	return result;
+}
+
+void rtw_ips_pwr_down23a(struct rtw_adapter *padapter)
+{
+	unsigned long start_time = jiffies;
+
+	DBG_8723A("===> rtw_ips_pwr_down23a...................\n");
+
+	padapter->bCardDisableWOHSM = true;
+	padapter->net_closed = true;
+
+	rtw_led_control(padapter, LED_CTL_POWER_OFF);
+
+	rtw_ips_dev_unload23a(padapter);
+	padapter->bCardDisableWOHSM = false;
+	DBG_8723A("<=== rtw_ips_pwr_down23a..................... in %dms\n",
+		  jiffies_to_msecs(jiffies - start_time));
+}
+
+void rtw_ips_dev_unload23a(struct rtw_adapter *padapter)
+{
+	rtw_hal_set_hwreg23a(padapter, HW_VAR_FIFO_CLEARN_UP, NULL);
+
+	if (padapter->intf_stop)
+		padapter->intf_stop(padapter);
+
+	/* s5. */
+	if (!padapter->bSurpriseRemoved)
+		rtw_hal_deinit23a(padapter);
+}
+
+int pm_netdev_open23a(struct net_device *pnetdev, u8 bnormal)
+{
+	int status;
+
+	if (bnormal)
+		status = netdev_open23a(pnetdev);
+	else
+		status = (_SUCCESS == ips_netdrv_open(netdev_priv(pnetdev))) ?
+			 (0) : (-1);
+
+	return status;
+}
+
+static int netdev_close(struct net_device *pnetdev)
+{
+	struct rtw_adapter *padapter = netdev_priv(pnetdev);
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+871x_drv - drv_close\n"));
+
+	if (padapter->pwrctrlpriv.bInternalAutoSuspend) {
+		if (padapter->pwrctrlpriv.rf_pwrstate == rf_off)
+			padapter->pwrctrlpriv.ps_flag = true;
+	}
+	padapter->net_closed = true;
+
+	if (padapter->pwrctrlpriv.rf_pwrstate == rf_on) {
+		DBG_8723A("(2)871x_drv - drv_close, bup =%d, hw_init_completed =%d\n",
+			  padapter->bup,
+			  padapter->hw_init_completed);
+
+		/* s1. */
+		if (pnetdev) {
+			if (!rtw_netif_queue_stopped(pnetdev))
+				netif_tx_stop_all_queues(pnetdev);
+		}
+
+		/* s2. */
+		LeaveAllPowerSaveMode23a(padapter);
+		rtw_disassoc_cmd23a(padapter, 500, false);
+		/* s2-2.  indicate disconnect to os */
+		rtw_indicate_disconnect23a(padapter);
+		/* s2-3. */
+		rtw_free_assoc_resources23a(padapter, 1);
+		/* s2-4. */
+		rtw_free_network_queue23a(padapter, true);
+		/*  Close LED */
+		rtw_led_control(padapter, LED_CTL_POWER_OFF);
+	}
+
+#ifdef CONFIG_8723AU_P2P
+	if (wdev_to_priv(padapter->rtw_wdev)->p2p_enabled)
+		wdev_to_priv(padapter->rtw_wdev)->p2p_enabled = false;
+	rtw_p2p_enable23a(padapter, P2P_ROLE_DISABLE);
+#endif /* CONFIG_8723AU_P2P */
+
+	rtw_scan_abort23a(padapter);
+	 /* set this at the end */
+	padapter->rtw_wdev->iftype = NL80211_IFTYPE_MONITOR;
+
+	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("-871x_drv - drv_close\n"));
+	DBG_8723A("-871x_drv - drv_close, bup =%d\n", padapter->bup);
+
+	return 0;
+}
+
+void rtw_ndev_destructor(struct net_device *ndev)
+{
+	DBG_8723A(FUNC_NDEV_FMT"\n", FUNC_NDEV_ARG(ndev));
+	kfree(ndev->ieee80211_ptr);
+	free_netdev(ndev);
+}
diff --git a/drivers/staging/rtl8723au/os_dep/osdep_service.c b/drivers/staging/rtl8723au/os_dep/osdep_service.c
new file mode 100644
index 0000000..aeb48db
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/osdep_service.c
@@ -0,0 +1,429 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+
+
+#define _OSDEP_SERVICE_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <recv_osdep.h>
+#include <linux/vmalloc.h>
+
+#define RT_TAG	('1178')
+
+/*
+* Translate the OS dependent @param error_code to OS independent RTW_STATUS_CODE23a
+* @return: one of RTW_STATUS_CODE23a
+*/
+inline int RTW_STATUS_CODE23a(int error_code)
+{
+	if (error_code >= 0)
+		return _SUCCESS;
+	return _FAIL;
+}
+
+inline u8 *_rtw_vmalloc(u32 sz)
+{
+	u8	*pbuf;
+	pbuf = vmalloc(sz);
+
+	return pbuf;
+}
+
+inline u8 *_rtw_zvmalloc(u32 sz)
+{
+	u8	*pbuf;
+	pbuf = _rtw_vmalloc(sz);
+	if (pbuf != NULL)
+		memset(pbuf, 0, sz);
+
+	return pbuf;
+}
+
+inline void _rtw_vmfree(u8 *pbuf, u32 sz)
+{
+	vfree(pbuf);
+}
+
+void _rtw_init_queue23a(struct rtw_queue *pqueue)
+{
+	INIT_LIST_HEAD(&pqueue->queue);
+	spin_lock_init(&pqueue->lock);
+}
+
+u32 _rtw_queue_empty23a(struct rtw_queue *pqueue)
+{
+	if (list_empty(&pqueue->queue))
+		return true;
+	else
+		return false;
+}
+
+u32	rtw_get_current_time(void)
+{
+	return jiffies;
+}
+
+inline u32 rtw_systime_to_ms23a(u32 systime)
+{
+	return systime * 1000 / HZ;
+}
+
+inline u32 rtw_ms_to_systime23a(u32 ms)
+{
+	return ms * HZ / 1000;
+}
+
+/*  the input parameter start use the same unit as returned
+ * by rtw_get_current_time
+ */
+inline s32 rtw_get_passing_time_ms23a(u32 start)
+{
+	return rtw_systime_to_ms23a(jiffies-start);
+}
+
+inline s32 rtw_get_time_interval_ms23a(u32 start, u32 end)
+{
+	return rtw_systime_to_ms23a(end-start);
+}
+
+#define RTW_SUSPEND_LOCK_NAME "rtw_wifi"
+
+inline void rtw_suspend_lock_init(void)
+{
+}
+
+inline void rtw_suspend_lock_uninit(void)
+{
+}
+
+inline void rtw_lock_suspend(void)
+{
+}
+
+inline void rtw_unlock_suspend(void)
+{
+}
+
+/* Open a file with the specific @param path, @param flag, @param mode
+ * @param fpp the pointer of struct file pointer to get struct
+ * file pointer while file opening is success
+ * @param path the path of the file to open
+ * @param flag file operation flags, please refer to linux document
+ * @param mode please refer to linux document
+ * @return Linux specific error code
+ */
+static int openFile(struct file **fpp, char *path, int flag, int mode)
+{
+	struct file *fp;
+
+	fp = filp_open(path, flag, mode);
+	if (IS_ERR(fp)) {
+		*fpp = NULL;
+		return PTR_ERR(fp);
+	} else {
+		*fpp = fp;
+		return 0;
+	}
+}
+
+/* Close the file with the specific @param fp
+ * @param fp the pointer of struct file to close
+ * @return always 0
+ */
+static int closeFile(struct file *fp)
+{
+	filp_close(fp, NULL);
+	return 0;
+}
+
+static int readFile(struct file *fp, char *buf, int len)
+{
+	int rlen = 0, sum = 0;
+
+	if (!fp->f_op || !fp->f_op->read)
+		return -EPERM;
+
+	while (sum < len) {
+		rlen = fp->f_op->read(fp, buf+sum, len-sum, &fp->f_pos);
+		if (rlen > 0)
+			sum += rlen;
+		else if (0 != rlen)
+			return rlen;
+		else
+			break;
+	}
+	return  sum;
+}
+
+static int writeFile(struct file *fp, char *buf, int len)
+{
+	int wlen = 0, sum = 0;
+
+	if (!fp->f_op || !fp->f_op->write)
+		return -EPERM;
+
+	while (sum < len) {
+		wlen = fp->f_op->write(fp, buf+sum, len-sum, &fp->f_pos);
+		if (wlen > 0)
+			sum += wlen;
+		else if (0 != wlen)
+			return wlen;
+		else
+			break;
+	}
+	return sum;
+}
+
+/* Test if the specifi @param path is a file and readable
+ * @param path the path of the file to test
+ * @return Linux specific error code
+ */
+static int isFileReadable(char *path)
+{
+	struct file *fp;
+	int ret = 0;
+	mm_segment_t oldfs;
+	char buf;
+
+	fp = filp_open(path, O_RDONLY, 0);
+	if (IS_ERR(fp)) {
+		ret = PTR_ERR(fp);
+	} else {
+		oldfs = get_fs();
+		set_fs(get_ds());
+
+		if (1 != readFile(fp, &buf, 1))
+			ret = PTR_ERR(fp);
+
+		set_fs(oldfs);
+		filp_close(fp, NULL);
+	}
+	return ret;
+}
+
+/* Open the file with @param path and retrive the file content into
+ * memory starting from @param buf for @param sz at most
+ * @param path the path of the file to open and read
+ * @param buf the starting address of the buffer to store file content
+ * @param sz how many bytes to read at most
+ * @return the byte we've read, or Linux specific error code
+ */
+static int retriveFromFile(char *path, u8 *buf, u32 sz)
+{
+	int ret = -1;
+	mm_segment_t oldfs;
+	struct file *fp;
+
+	if (path && buf) {
+		ret = openFile(&fp, path, O_RDONLY, 0);
+		if (!ret) {
+			DBG_8723A("%s openFile path:%s fp =%p\n",
+				  __func__, path, fp);
+
+			oldfs = get_fs(); set_fs(get_ds());
+			ret = readFile(fp, buf, sz);
+			set_fs(oldfs);
+			closeFile(fp);
+
+			DBG_8723A("%s readFile, ret:%d\n", __func__, ret);
+		} else {
+			DBG_8723A("%s openFile path:%s Fail, ret:%d\n",
+				  __func__, path, ret);
+		}
+	} else {
+		DBG_8723A("%s NULL pointer\n", __func__);
+		ret =  -EINVAL;
+	}
+	return ret;
+}
+
+/* Open the file with @param path and wirte @param sz byte of data starting
+ * from @param buf into the file
+ * @param path the path of the file to open and write
+ * @param buf the starting address of the data to write into file
+ * @param sz how many bytes to write at most
+ * @return the byte we've written, or Linux specific error code
+ */
+static int storeToFile(char *path, u8 *buf, u32 sz)
+{
+	struct file *fp;
+	int ret = 0;
+	mm_segment_t oldfs;
+
+	if (path && buf) {
+		ret = openFile(&fp, path, O_CREAT|O_WRONLY, 0666);
+		if (!ret) {
+			DBG_8723A("%s openFile path:%s fp =%p\n", __func__,
+				  path, fp);
+
+			oldfs = get_fs(); set_fs(get_ds());
+			ret = writeFile(fp, buf, sz);
+			set_fs(oldfs);
+			closeFile(fp);
+
+			DBG_8723A("%s writeFile, ret:%d\n", __func__, ret);
+		} else {
+			DBG_8723A("%s openFile path:%s Fail, ret:%d\n",
+				  __func__, path, ret);
+		}
+	} else {
+		DBG_8723A("%s NULL pointer\n", __func__);
+		ret =  -EINVAL;
+	}
+	return ret;
+}
+
+/*
+* Test if the specifi @param path is a file and readable
+* @param path the path of the file to test
+* @return true or false
+*/
+int rtw_is_file_readable(char *path)
+{
+	if (isFileReadable(path) == 0)
+		return true;
+	else
+		return false;
+}
+
+/* Open the file with @param path and retrive the file content into memoryi
+ * starting from @param buf for @param sz at most
+ * @param path the path of the file to open and read
+ * @param buf the starting address of the buffer to store file content
+ * @param sz how many bytes to read at most
+ * @return the byte we've read
+ */
+int rtw_retrive_from_file(char *path, u8 *buf, u32 sz)
+{
+	int ret = retriveFromFile(path, buf, sz);
+	return ret >= 0 ? ret : 0;
+}
+
+/* Open the file with @param path and wirte @param sz byte of
+ * data starting from @param buf into the file
+ * @param path the path of the file to open and write
+ * @param buf the starting address of the data to write into file
+ * @param sz how many bytes to write at most
+ * @return the byte we've written
+ */
+int rtw_store_to_file(char *path, u8 *buf, u32 sz)
+{
+	int ret = storeToFile(path, buf, sz);
+	return ret >= 0 ? ret : 0;
+}
+
+u64 rtw_modular6423a(u64 x, u64 y)
+{
+	return do_div(x, y);
+}
+
+u64 rtw_division6423a(u64 x, u64 y)
+{
+	do_div(x, y);
+	return x;
+}
+
+/* rtw_cbuf_full23a - test if cbuf is full
+ * @cbuf: pointer of struct rtw_cbuf
+ *
+ * Returns: true if cbuf is full
+ */
+inline bool rtw_cbuf_full23a(struct rtw_cbuf *cbuf)
+{
+	return (cbuf->write == cbuf->read-1) ? true : false;
+}
+
+/* rtw_cbuf_empty23a - test if cbuf is empty
+ * @cbuf: pointer of struct rtw_cbuf
+ *
+ * Returns: true if cbuf is empty
+ */
+inline bool rtw_cbuf_empty23a(struct rtw_cbuf *cbuf)
+{
+	return (cbuf->write == cbuf->read) ? true : false;
+}
+
+/**
+ * rtw_cbuf_push23a - push a pointer into cbuf
+ * @cbuf: pointer of struct rtw_cbuf
+ * @buf: pointer to push in
+ *
+ * Lock free operation, be careful of the use scheme
+ * Returns: true push success
+ */
+bool rtw_cbuf_push23a(struct rtw_cbuf *cbuf, void *buf)
+{
+	if (rtw_cbuf_full23a(cbuf))
+		return _FAIL;
+
+	if (0)
+		DBG_8723A("%s on %u\n", __func__, cbuf->write);
+	cbuf->bufs[cbuf->write] = buf;
+	cbuf->write = (cbuf->write+1)%cbuf->size;
+
+	return _SUCCESS;
+}
+
+/**
+ * rtw_cbuf_pop23a - pop a pointer from cbuf
+ * @cbuf: pointer of struct rtw_cbuf
+ *
+ * Lock free operation, be careful of the use scheme
+ * Returns: pointer popped out
+ */
+void *rtw_cbuf_pop23a(struct rtw_cbuf *cbuf)
+{
+	void *buf;
+	if (rtw_cbuf_empty23a(cbuf))
+		return NULL;
+
+	if (0)
+		DBG_8723A("%s on %u\n", __func__, cbuf->read);
+	buf = cbuf->bufs[cbuf->read];
+	cbuf->read = (cbuf->read+1)%cbuf->size;
+
+	return buf;
+}
+
+/**
+ * rtw_cbuf_alloc23a - allocte a rtw_cbuf with given size and do initialization
+ * @size: size of pointer
+ *
+ * Returns: pointer of srtuct rtw_cbuf, NULL for allocation failure
+ */
+struct rtw_cbuf *rtw_cbuf_alloc23a(u32 size)
+{
+	struct rtw_cbuf *cbuf;
+
+	cbuf = kmalloc(sizeof(*cbuf) + sizeof(void *)*size, GFP_KERNEL);
+
+	if (cbuf) {
+		cbuf->write = 0;
+		cbuf->read = 0;
+		cbuf->size = size;
+	}
+
+	return cbuf;
+}
+
+/**
+ * rtw_cbuf_free - free the given rtw_cbuf
+ * @cbuf: pointer of struct rtw_cbuf to free
+ */
+void rtw_cbuf_free(struct rtw_cbuf *cbuf)
+{
+	kfree(cbuf);
+}
diff --git a/drivers/staging/rtl8723au/os_dep/recv_linux.c b/drivers/staging/rtl8723au/os_dep/recv_linux.c
new file mode 100644
index 0000000..84402a5
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/recv_linux.c
@@ -0,0 +1,225 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+#define _RECV_OSDEP_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#include <wifi.h>
+#include <recv_osdep.h>
+
+#include <osdep_intf.h>
+#include <ethernet.h>
+
+#include <usb_ops.h>
+
+/* alloc os related resource in struct recv_frame */
+int rtw_os_recv_resource_alloc23a(struct rtw_adapter *padapter,
+			       struct recv_frame *precvframe)
+{
+	int res = _SUCCESS;
+
+	precvframe->pkt = NULL;
+
+	return res;
+}
+
+/* alloc os related resource in struct recv_buf */
+int rtw_os_recvbuf_resource_alloc23a(struct rtw_adapter *padapter,
+				  struct recv_buf *precvbuf)
+{
+	int res = _SUCCESS;
+
+	precvbuf->purb = usb_alloc_urb(0, GFP_KERNEL);
+	if (precvbuf->purb == NULL)
+		res = _FAIL;
+
+	precvbuf->pskb = NULL;
+
+	return res;
+}
+
+/* free os related resource in struct recv_buf */
+int rtw_os_recvbuf_resource_free23a(struct rtw_adapter *padapter,
+				 struct recv_buf *precvbuf)
+{
+	int ret = _SUCCESS;
+
+	usb_free_urb(precvbuf->purb);
+
+	if (precvbuf->pskb)
+		dev_kfree_skb_any(precvbuf->pskb);
+
+	return ret;
+}
+
+void rtw_handle_tkip_mic_err23a(struct rtw_adapter *padapter, u8 bgroup)
+{
+	enum nl80211_key_type key_type = 0;
+	union iwreq_data wrqu;
+	struct iw_michaelmicfailure ev;
+	struct mlme_priv *pmlmepriv  = &padapter->mlmepriv;
+	struct security_priv *psecuritypriv = &padapter->securitypriv;
+	unsigned long cur_time;
+
+	if (psecuritypriv->last_mic_err_time == 0) {
+		psecuritypriv->last_mic_err_time = jiffies;
+	} else {
+		cur_time = jiffies;
+
+		if (cur_time - psecuritypriv->last_mic_err_time < 60*HZ) {
+			psecuritypriv->btkip_countermeasure = true;
+			psecuritypriv->last_mic_err_time = 0;
+			psecuritypriv->btkip_countermeasure_time = cur_time;
+		} else {
+			psecuritypriv->last_mic_err_time = jiffies;
+		}
+	}
+
+	if (bgroup)
+		key_type |= NL80211_KEYTYPE_GROUP;
+	else
+		key_type |= NL80211_KEYTYPE_PAIRWISE;
+
+	cfg80211_michael_mic_failure(padapter->pnetdev,
+				     (u8 *)&pmlmepriv->assoc_bssid[0],
+				     key_type, -1, NULL, GFP_ATOMIC);
+
+	memset(&ev, 0x00, sizeof(ev));
+	if (bgroup)
+		ev.flags |= IW_MICFAILURE_GROUP;
+	else
+		ev.flags |= IW_MICFAILURE_PAIRWISE;
+
+	ev.src_addr.sa_family = ARPHRD_ETHER;
+	ether_addr_copy(ev.src_addr.sa_data, &pmlmepriv->assoc_bssid[0]);
+
+	memset(&wrqu, 0x00, sizeof(wrqu));
+	wrqu.data.length = sizeof(ev);
+}
+
+void rtw_hostapd_mlme_rx23a(struct rtw_adapter *padapter,
+			 struct recv_frame *precv_frame)
+{
+}
+
+int rtw_recv_indicatepkt23a(struct rtw_adapter *padapter,
+			 struct recv_frame *precv_frame)
+{
+	struct recv_priv *precvpriv;
+	struct rtw_queue *pfree_recv_queue;
+	struct sk_buff *skb;
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+	precvpriv = &(padapter->recvpriv);
+	pfree_recv_queue = &(precvpriv->free_recv_queue);
+
+	skb = precv_frame->pkt;
+	if (!skb) {
+		RT_TRACE(_module_recv_osdep_c_, _drv_err_,
+			 ("rtw_recv_indicatepkt23a():skb == NULL!!!!\n"));
+		goto _recv_indicatepkt_drop;
+	}
+
+	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
+		 ("rtw_recv_indicatepkt23a():skb != NULL !!!\n"));
+	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
+		 ("rtw_recv_indicatepkt23a():precv_frame->hdr.rx_data =%p\n",
+		  precv_frame->pkt->data));
+	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
+		 ("\n skb->head =%p skb->data =%p skb->tail =%p skb->end =%p skb->len =%d\n",
+		  skb->head, skb->data,
+		  skb_tail_pointer(skb), skb_end_pointer(skb), skb->len));
+
+	if (check_fwstate(pmlmepriv, WIFI_AP_STATE) == true) {
+		struct sk_buff *pskb2 = NULL;
+		struct sta_info *psta = NULL;
+		struct sta_priv *pstapriv = &padapter->stapriv;
+		struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
+		int bmcast = is_multicast_ether_addr(pattrib->dst);
+
+		/* DBG_8723A("bmcast =%d\n", bmcast); */
+
+		if (!ether_addr_equal(pattrib->dst,
+				      myid(&padapter->eeprompriv))) {
+			/* DBG_8723A("not ap psta =%p, addr =%pM\n", psta, pattrib->dst); */
+			if (bmcast) {
+				psta = rtw_get_bcmc_stainfo23a(padapter);
+				pskb2 = skb_clone(skb, GFP_ATOMIC);
+			} else {
+				psta = rtw_get_stainfo23a(pstapriv, pattrib->dst);
+			}
+
+			if (psta) {
+				struct net_device *pnetdev = padapter->pnetdev;
+
+				/* DBG_8723A("directly forwarding to the rtw_xmit23a_entry23a\n"); */
+
+				/* skb->ip_summed = CHECKSUM_NONE; */
+				skb->dev = pnetdev;
+				skb_set_queue_mapping(skb, rtw_recv_select_queue23a(skb));
+
+				rtw_xmit23a_entry23a(skb, pnetdev);
+
+				if (bmcast)
+					skb = pskb2;
+				else
+					goto _recv_indicatepkt_end;
+			}
+		} else { /*  to APself */
+			/* DBG_8723A("to APSelf\n"); */
+		}
+	}
+
+	skb->ip_summed = CHECKSUM_NONE;
+	skb->dev = padapter->pnetdev;
+	skb->protocol = eth_type_trans(skb, padapter->pnetdev);
+
+	netif_rx(skb);
+
+_recv_indicatepkt_end:
+
+	precv_frame->pkt = NULL; /*  pointers to NULL before rtw_free_recvframe23a() */
+
+	rtw_free_recvframe23a(precv_frame, pfree_recv_queue);
+
+	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
+		 ("\n rtw_recv_indicatepkt23a :after netif_rx!!!!\n"));
+	return _SUCCESS;
+
+_recv_indicatepkt_drop:
+
+	 rtw_free_recvframe23a(precv_frame, pfree_recv_queue);
+	 return _FAIL;
+}
+
+void rtw_os_read_port23a(struct rtw_adapter *padapter, struct recv_buf *precvbuf)
+{
+	struct recv_priv *precvpriv = &padapter->recvpriv;
+
+	/* free skb in recv_buf */
+	dev_kfree_skb_any(precvbuf->pskb);
+
+	precvbuf->pskb = NULL;
+
+	rtw_read_port(padapter, precvpriv->ff_hwaddr, 0, precvbuf);
+}
+
+void rtw_init_recv_timer23a(struct recv_reorder_ctrl *preorder_ctrl)
+{
+	setup_timer(&preorder_ctrl->reordering_ctrl_timer,
+		    rtw_reordering_ctrl_timeout_handler23a,
+		    (unsigned long)preorder_ctrl);
+}
diff --git a/drivers/staging/rtl8723au/os_dep/usb_intf.c b/drivers/staging/rtl8723au/os_dep/usb_intf.c
new file mode 100644
index 0000000..040bf29
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/usb_intf.c
@@ -0,0 +1,836 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+#define _HCI_INTF_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <recv_osdep.h>
+#include <xmit_osdep.h>
+#include <hal_intf.h>
+#include <rtw_version.h>
+#include <osdep_intf.h>
+#include <usb_vendor_req.h>
+#include <usb_ops.h>
+#include <usb_osintf.h>
+#include <usb_hal.h>
+
+static int rtw_suspend(struct usb_interface *intf, pm_message_t message);
+static int rtw_resume(struct usb_interface *intf);
+static int rtw_drv_init(struct usb_interface *pusb_intf,
+			const struct usb_device_id *pdid);
+static void rtw_disconnect(struct usb_interface *pusb_intf);
+
+#define USB_VENDER_ID_REALTEK		0x0BDA
+
+#define RTL8723A_USB_IDS \
+	{USB_DEVICE_AND_INTERFACE_INFO(USB_VENDER_ID_REALTEK, 0x8724,	\
+	 0xff, 0xff, 0xff)}, /* 8723AU 1*1 */ \
+	{USB_DEVICE_AND_INTERFACE_INFO(USB_VENDER_ID_REALTEK, 0x1724,	\
+	 0xff, 0xff, 0xff)}, /* 8723AU 1*1 */ \
+	{USB_DEVICE_AND_INTERFACE_INFO(USB_VENDER_ID_REALTEK, 0x0724,	\
+	 0xff, 0xff, 0xff)}, /* 8723AU 1*1 */
+
+static struct usb_device_id rtl8723a_usb_id_tbl[] = {
+	RTL8723A_USB_IDS
+	{}	/* Terminating entry */
+};
+
+MODULE_DEVICE_TABLE(usb, rtl8723a_usb_id_tbl);
+
+static struct usb_driver rtl8723a_usb_drv = {
+	.name = (char *)"rtl8723au",
+	.probe = rtw_drv_init,
+	.disconnect = rtw_disconnect,
+	.id_table = rtl8723a_usb_id_tbl,
+	.suspend = rtw_suspend,
+	.resume = rtw_resume,
+	.reset_resume  = rtw_resume,
+};
+
+static struct usb_driver *usb_drv = &rtl8723a_usb_drv;
+
+static inline int RT_usb_endpoint_dir_in(const struct usb_endpoint_descriptor *epd)
+{
+	return (epd->bEndpointAddress & USB_ENDPOINT_DIR_MASK) == USB_DIR_IN;
+}
+
+static inline int RT_usb_endpoint_dir_out(const struct usb_endpoint_descriptor *epd)
+{
+	return (epd->bEndpointAddress & USB_ENDPOINT_DIR_MASK) == USB_DIR_OUT;
+}
+
+static inline int RT_usb_endpoint_xfer_int(const struct usb_endpoint_descriptor *epd)
+{
+	return (epd->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_INT;
+}
+
+static inline int RT_usb_endpoint_xfer_bulk(const struct usb_endpoint_descriptor *epd)
+{
+	return (epd->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_BULK;
+}
+
+static inline int RT_usb_endpoint_is_bulk_in(const struct usb_endpoint_descriptor *epd)
+{
+	return RT_usb_endpoint_xfer_bulk(epd) && RT_usb_endpoint_dir_in(epd);
+}
+
+static inline int RT_usb_endpoint_is_bulk_out(const struct usb_endpoint_descriptor *epd)
+{
+	return RT_usb_endpoint_xfer_bulk(epd) && RT_usb_endpoint_dir_out(epd);
+}
+
+static inline int RT_usb_endpoint_is_int_in(const struct usb_endpoint_descriptor *epd)
+{
+	return RT_usb_endpoint_xfer_int(epd) && RT_usb_endpoint_dir_in(epd);
+}
+
+static inline int RT_usb_endpoint_num(const struct usb_endpoint_descriptor *epd)
+{
+	return epd->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
+}
+
+static u8 rtw_init_intf_priv(struct dvobj_priv *dvobj)
+{
+	u8 rst = _SUCCESS;
+
+	mutex_init(&dvobj->usb_vendor_req_mutex);
+	dvobj->usb_alloc_vendor_req_buf = kzalloc(MAX_USB_IO_CTL_SIZE,
+						  GFP_KERNEL);
+	if (dvobj->usb_alloc_vendor_req_buf == NULL) {
+		DBG_8723A("alloc usb_vendor_req_buf failed... /n");
+		rst = _FAIL;
+		goto exit;
+	}
+	dvobj->usb_vendor_req_buf =
+		PTR_ALIGN(dvobj->usb_alloc_vendor_req_buf, ALIGNMENT_UNIT);
+exit:
+	return rst;
+}
+
+static u8 rtw_deinit_intf_priv(struct dvobj_priv *dvobj)
+{
+	u8 rst = _SUCCESS;
+
+	kfree(dvobj->usb_alloc_vendor_req_buf);
+
+	mutex_destroy(&dvobj->usb_vendor_req_mutex);
+
+	return rst;
+}
+
+static struct dvobj_priv *usb_dvobj_init(struct usb_interface *usb_intf)
+{
+	struct dvobj_priv *pdvobjpriv;
+	struct usb_device_descriptor *pdev_desc;
+	struct usb_host_config	 *phost_conf;
+	struct usb_config_descriptor *pconf_desc;
+	struct usb_host_interface *phost_iface;
+	struct usb_interface_descriptor *piface_desc;
+	struct usb_host_endpoint *phost_endp;
+	struct usb_endpoint_descriptor *pendp_desc;
+	struct usb_device		 *pusbd;
+	int	i;
+	int	status = _FAIL;
+
+	pdvobjpriv = kzalloc(sizeof(*pdvobjpriv), GFP_KERNEL);
+	if (!pdvobjpriv)
+		goto exit;
+
+	mutex_init(&pdvobjpriv->hw_init_mutex);
+	mutex_init(&pdvobjpriv->h2c_fwcmd_mutex);
+	mutex_init(&pdvobjpriv->setch_mutex);
+	mutex_init(&pdvobjpriv->setbw_mutex);
+
+	pdvobjpriv->pusbintf = usb_intf;
+	pusbd = interface_to_usbdev(usb_intf);
+	pdvobjpriv->pusbdev = pusbd;
+	usb_set_intfdata(usb_intf, pdvobjpriv);
+
+	pdvobjpriv->RtNumInPipes = 0;
+	pdvobjpriv->RtNumOutPipes = 0;
+
+	pdev_desc = &pusbd->descriptor;
+
+	phost_conf = pusbd->actconfig;
+	pconf_desc = &phost_conf->desc;
+
+	phost_iface = &usb_intf->altsetting[0];
+	piface_desc = &phost_iface->desc;
+
+	pdvobjpriv->NumInterfaces = pconf_desc->bNumInterfaces;
+	pdvobjpriv->InterfaceNumber = piface_desc->bInterfaceNumber;
+	pdvobjpriv->nr_endpoint = piface_desc->bNumEndpoints;
+
+	for (i = 0; i < pdvobjpriv->nr_endpoint; i++) {
+		phost_endp = phost_iface->endpoint + i;
+		if (phost_endp) {
+			pendp_desc = &phost_endp->desc;
+
+			DBG_8723A("\nusb_endpoint_descriptor(%d):\n", i);
+			DBG_8723A("bLength =%x\n", pendp_desc->bLength);
+			DBG_8723A("bDescriptorType =%x\n",
+				  pendp_desc->bDescriptorType);
+			DBG_8723A("bEndpointAddress =%x\n",
+				  pendp_desc->bEndpointAddress);
+			DBG_8723A("wMaxPacketSize =%d\n",
+				  le16_to_cpu(pendp_desc->wMaxPacketSize));
+			DBG_8723A("bInterval =%x\n", pendp_desc->bInterval);
+
+			if (RT_usb_endpoint_is_bulk_in(pendp_desc)) {
+				DBG_8723A("RT_usb_endpoint_is_bulk_in = %x\n",
+					  RT_usb_endpoint_num(pendp_desc));
+				pdvobjpriv->RtInPipe[pdvobjpriv->RtNumInPipes] =
+					RT_usb_endpoint_num(pendp_desc);
+				pdvobjpriv->RtNumInPipes++;
+			} else if (RT_usb_endpoint_is_int_in(pendp_desc)) {
+				DBG_8723A("RT_usb_endpoint_is_int_in = %x, Interval = %x\n",
+					  RT_usb_endpoint_num(pendp_desc),
+					  pendp_desc->bInterval);
+				pdvobjpriv->RtInPipe[pdvobjpriv->RtNumInPipes] =
+					RT_usb_endpoint_num(pendp_desc);
+				pdvobjpriv->RtNumInPipes++;
+			} else if (RT_usb_endpoint_is_bulk_out(pendp_desc)) {
+				DBG_8723A("RT_usb_endpoint_is_bulk_out = %x\n",
+					  RT_usb_endpoint_num(pendp_desc));
+				pdvobjpriv->RtOutPipe[pdvobjpriv->RtNumOutPipes] =
+					RT_usb_endpoint_num(pendp_desc);
+				pdvobjpriv->RtNumOutPipes++;
+			}
+			pdvobjpriv->ep_num[i] = RT_usb_endpoint_num(pendp_desc);
+		}
+	}
+	DBG_8723A("nr_endpoint =%d, in_num =%d, out_num =%d\n\n",
+		  pdvobjpriv->nr_endpoint, pdvobjpriv->RtNumInPipes,
+		  pdvobjpriv->RtNumOutPipes);
+
+	if (pusbd->speed == USB_SPEED_HIGH) {
+		pdvobjpriv->ishighspeed = true;
+		DBG_8723A("USB_SPEED_HIGH\n");
+	} else {
+		pdvobjpriv->ishighspeed = false;
+		DBG_8723A("NON USB_SPEED_HIGH\n");
+	}
+
+	if (rtw_init_intf_priv(pdvobjpriv) == _FAIL) {
+		RT_TRACE(_module_os_intfs_c_, _drv_err_,
+			 ("\n Can't INIT rtw_init_intf_priv\n"));
+		goto free_dvobj;
+	}
+	/* 3 misc */
+	sema_init(&(pdvobjpriv->usb_suspend_sema), 0);
+	rtw_reset_continual_urb_error(pdvobjpriv);
+	usb_get_dev(pusbd);
+	status = _SUCCESS;
+free_dvobj:
+	if (status != _SUCCESS && pdvobjpriv) {
+		usb_set_intfdata(usb_intf, NULL);
+		mutex_destroy(&pdvobjpriv->hw_init_mutex);
+		mutex_destroy(&pdvobjpriv->h2c_fwcmd_mutex);
+		mutex_destroy(&pdvobjpriv->setch_mutex);
+		mutex_destroy(&pdvobjpriv->setbw_mutex);
+		kfree(pdvobjpriv);
+		pdvobjpriv = NULL;
+	}
+exit:
+	return pdvobjpriv;
+}
+
+static void usb_dvobj_deinit(struct usb_interface *usb_intf)
+{
+	struct dvobj_priv *dvobj = usb_get_intfdata(usb_intf);
+
+	usb_set_intfdata(usb_intf, NULL);
+	if (dvobj) {
+		/* Modify condition for 92DU DMDP 2010.11.18, by Thomas */
+		if ((dvobj->NumInterfaces != 2 && dvobj->NumInterfaces != 3) ||
+		    (dvobj->InterfaceNumber == 1)) {
+			if (interface_to_usbdev(usb_intf)->state !=
+			    USB_STATE_NOTATTACHED) {
+				/* If we didn't unplug usb dongle and
+				 * remove/insert module, driver fails on
+				 * sitesurvey for the first time when
+				 * device is up .
+				 * Reset usb port for sitesurvey fail issue.
+				 */
+				DBG_8723A("usb attached..., try to reset usb device\n");
+				usb_reset_device(interface_to_usbdev(usb_intf));
+			}
+		}
+		rtw_deinit_intf_priv(dvobj);
+		mutex_destroy(&dvobj->hw_init_mutex);
+		mutex_destroy(&dvobj->h2c_fwcmd_mutex);
+		mutex_destroy(&dvobj->setch_mutex);
+		mutex_destroy(&dvobj->setbw_mutex);
+		kfree(dvobj);
+	}
+	usb_put_dev(interface_to_usbdev(usb_intf));
+}
+
+static void decide_chip_type_by_usb_device_id(struct rtw_adapter *padapter,
+					      const struct usb_device_id *pdid)
+{
+	padapter->chip_type = NULL_CHIP_TYPE;
+	hal_set_hw_type(padapter);
+}
+
+static void usb_intf_start(struct rtw_adapter *padapter)
+{
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+usb_intf_start\n"));
+	rtw_hal_inirp_init23a(padapter);
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("-usb_intf_start\n"));
+}
+
+static void usb_intf_stop(struct rtw_adapter *padapter)
+{
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+usb_intf_stop\n"));
+
+	/* disable_hw_interrupt */
+	if (!padapter->bSurpriseRemoved) {
+		/* device still exists, so driver can do i/o operation
+		 * TODO:
+		 */
+		RT_TRACE(_module_hci_intfs_c_, _drv_err_,
+			 ("SurpriseRemoved == false\n"));
+	}
+
+	/* cancel in irp */
+	rtw_hal_inirp_deinit23a(padapter);
+
+	/* cancel out irp */
+	rtw_write_port_cancel(padapter);
+
+	/* todo:cancel other irps */
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("-usb_intf_stop\n"));
+}
+
+static void rtw_dev_unload(struct rtw_adapter *padapter)
+{
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+rtw_dev_unload\n"));
+
+	if (padapter->bup) {
+		DBG_8723A("===> rtw_dev_unload\n");
+
+		padapter->bDriverStopped = true;
+		if (padapter->xmitpriv.ack_tx)
+			rtw_ack_tx_done23a(&padapter->xmitpriv,
+					RTW_SCTX_DONE_DRV_STOP);
+
+		/* s3. */
+		if (padapter->intf_stop)
+			padapter->intf_stop(padapter);
+
+		/* s4. */
+		if (!padapter->pwrctrlpriv.bInternalAutoSuspend)
+			rtw_stop_drv_threads23a(padapter);
+
+		/* s5. */
+		if (!padapter->bSurpriseRemoved) {
+			rtw_hal_deinit23a(padapter);
+			padapter->bSurpriseRemoved = true;
+		}
+		padapter->bup = false;
+	} else {
+		RT_TRACE(_module_hci_intfs_c_, _drv_err_,
+			 ("r871x_dev_unload():padapter->bup == false\n"));
+	}
+	DBG_8723A("<=== rtw_dev_unload\n");
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("-rtw_dev_unload\n"));
+}
+
+int rtw_hw_suspend23a(struct rtw_adapter *padapter)
+{
+	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
+	struct net_device *pnetdev = padapter->pnetdev;
+
+	if ((!padapter->bup) || (padapter->bDriverStopped) ||
+	    (padapter->bSurpriseRemoved)) {
+		DBG_8723A("padapter->bup =%d bDriverStopped =%d bSurpriseRemoved = %d\n",
+			  padapter->bup, padapter->bDriverStopped,
+			  padapter->bSurpriseRemoved);
+		goto error_exit;
+	}
+
+	if (padapter) { /* system suspend */
+		LeaveAllPowerSaveMode23a(padapter);
+
+		DBG_8723A("==> rtw_hw_suspend23a\n");
+		down(&pwrpriv->lock);
+		pwrpriv->bips_processing = true;
+		/* padapter->net_closed = true; */
+		/* s1. */
+		if (pnetdev) {
+			netif_carrier_off(pnetdev);
+			netif_tx_stop_all_queues(pnetdev);
+		}
+
+		/* s2. */
+		rtw_disassoc_cmd23a(padapter, 500, false);
+
+		/* s2-2.  indicate disconnect to os */
+		/* rtw_indicate_disconnect23a(padapter); */
+		{
+			struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
+
+			if (check_fwstate(pmlmepriv, _FW_LINKED)) {
+				_clr_fwstate_(pmlmepriv, _FW_LINKED);
+
+				rtw_led_control(padapter, LED_CTL_NO_LINK);
+
+				rtw_os_indicate_disconnect23a(padapter);
+
+				/* donnot enqueue cmd */
+				rtw_lps_ctrl_wk_cmd23a(padapter,
+						    LPS_CTRL_DISCONNECT, 0);
+			}
+		}
+		/* s2-3. */
+		rtw_free_assoc_resources23a(padapter, 1);
+
+		/* s2-4. */
+		rtw_free_network_queue23a(padapter, true);
+		rtw_ips_dev_unload23a(padapter);
+		pwrpriv->rf_pwrstate = rf_off;
+		pwrpriv->bips_processing = false;
+		up(&pwrpriv->lock);
+	} else {
+		goto error_exit;
+	}
+	return 0;
+error_exit:
+	DBG_8723A("%s, failed\n", __func__);
+	return -1;
+}
+
+int rtw_hw_resume23a(struct rtw_adapter *padapter)
+{
+	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
+	struct net_device *pnetdev = padapter->pnetdev;
+
+	if (padapter) { /* system resume */
+		DBG_8723A("==> rtw_hw_resume23a\n");
+		down(&pwrpriv->lock);
+		pwrpriv->bips_processing = true;
+		rtw_reset_drv_sw23a(padapter);
+
+		if (pm_netdev_open23a(pnetdev, false)) {
+			up(&pwrpriv->lock);
+			goto error_exit;
+		}
+
+		netif_device_attach(pnetdev);
+		netif_carrier_on(pnetdev);
+
+		if (!rtw_netif_queue_stopped(pnetdev))
+			netif_tx_start_all_queues(pnetdev);
+		else
+			netif_tx_wake_all_queues(pnetdev);
+
+		pwrpriv->bkeepfwalive = false;
+		pwrpriv->brfoffbyhw = false;
+
+		pwrpriv->rf_pwrstate = rf_on;
+		pwrpriv->bips_processing = false;
+
+		up(&pwrpriv->lock);
+	} else {
+		goto error_exit;
+	}
+	return 0;
+error_exit:
+	DBG_8723A("%s, Open net dev failed\n", __func__);
+	return -1;
+}
+
+static int rtw_suspend(struct usb_interface *pusb_intf, pm_message_t message)
+{
+	struct dvobj_priv *dvobj = usb_get_intfdata(pusb_intf);
+	struct rtw_adapter *padapter = dvobj->if1;
+	struct net_device *pnetdev = padapter->pnetdev;
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
+	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
+	int ret = 0;
+	unsigned long start_time = jiffies;
+
+	DBG_8723A("==> %s (%s:%d)\n", __func__, current->comm, current->pid);
+
+	if ((!padapter->bup) || (padapter->bDriverStopped) ||
+	    (padapter->bSurpriseRemoved)) {
+		DBG_8723A("padapter->bup =%d bDriverStopped =%d bSurpriseRemoved = %d\n",
+			  padapter->bup, padapter->bDriverStopped,
+			  padapter->bSurpriseRemoved);
+		goto exit;
+	}
+	pwrpriv->bInSuspend = true;
+	rtw_cancel_all_timer23a(padapter);
+	LeaveAllPowerSaveMode23a(padapter);
+
+	down(&pwrpriv->lock);
+	/* padapter->net_closed = true; */
+	/* s1. */
+	if (pnetdev) {
+		netif_carrier_off(pnetdev);
+		netif_tx_stop_all_queues(pnetdev);
+	}
+
+	/* s2. */
+	rtw_disassoc_cmd23a(padapter, 0, false);
+
+	if (check_fwstate(pmlmepriv, WIFI_STATION_STATE) &&
+	    check_fwstate(pmlmepriv, _FW_LINKED)) {
+		DBG_8723A("%s:%d %s(%pM), length:%d assoc_ssid.length:%d\n",
+			  __func__, __LINE__,
+			  pmlmepriv->cur_network.network.Ssid.ssid,
+			  pmlmepriv->cur_network.network.MacAddress,
+			  pmlmepriv->cur_network.network.Ssid.ssid_len,
+			  pmlmepriv->assoc_ssid.ssid_len);
+
+		rtw_set_roaming(padapter, 1);
+	}
+	/* s2-2.  indicate disconnect to os */
+	rtw_indicate_disconnect23a(padapter);
+	/* s2-3. */
+	rtw_free_assoc_resources23a(padapter, 1);
+	/* s2-4. */
+	rtw_free_network_queue23a(padapter, true);
+
+	rtw_dev_unload(padapter);
+	up(&pwrpriv->lock);
+
+	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY))
+		rtw_indicate_scan_done23a(padapter, 1);
+
+	if (check_fwstate(pmlmepriv, _FW_UNDER_LINKING))
+		rtw_indicate_disconnect23a(padapter);
+
+exit:
+	DBG_8723A("<===  %s return %d.............. in %dms\n", __func__,
+		  ret, jiffies_to_msecs(jiffies - start_time));
+
+	return ret;
+}
+
+static int rtw_resume(struct usb_interface *pusb_intf)
+{
+	struct dvobj_priv *dvobj = usb_get_intfdata(pusb_intf);
+	struct rtw_adapter *padapter = dvobj->if1;
+	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
+	int ret = 0;
+
+	if (pwrpriv->bInternalAutoSuspend)
+		ret = rtw_resume_process23a(padapter);
+	else
+		ret = rtw_resume_process23a(padapter);
+
+	return ret;
+}
+
+int rtw_resume_process23a(struct rtw_adapter *padapter)
+{
+	struct net_device *pnetdev;
+	struct pwrctrl_priv *pwrpriv = NULL;
+	int ret = -1;
+	unsigned long start_time = jiffies;
+
+	DBG_8723A("==> %s (%s:%d)\n", __func__, current->comm, current->pid);
+
+	if (!padapter)
+		goto exit;
+	pnetdev = padapter->pnetdev;
+	pwrpriv = &padapter->pwrctrlpriv;
+
+	down(&pwrpriv->lock);
+	rtw_reset_drv_sw23a(padapter);
+	pwrpriv->bkeepfwalive = false;
+
+	DBG_8723A("bkeepfwalive(%x)\n", pwrpriv->bkeepfwalive);
+	if (pm_netdev_open23a(pnetdev, true) != 0)
+		goto exit;
+
+	netif_device_attach(pnetdev);
+	netif_carrier_on(pnetdev);
+
+	up(&pwrpriv->lock);
+
+	if (padapter->pid[1] != 0) {
+		DBG_8723A("pid[1]:%d\n", padapter->pid[1]);
+		rtw_signal_process(padapter->pid[1], SIGUSR2);
+	}
+
+	rtw23a_roaming(padapter, NULL);
+
+	ret = 0;
+exit:
+	if (pwrpriv)
+		pwrpriv->bInSuspend = false;
+	DBG_8723A("<===  %s return %d.............. in %dms\n", __func__,
+		  ret, jiffies_to_msecs(jiffies - start_time));
+
+	return ret;
+}
+
+/*
+ * drv_init() - a device potentially for us
+ *
+ * notes: drv_init() is called when the bus driver has located a card
+ * for us to support.
+ *        We accept the new device by returning 0.
+ */
+static struct rtw_adapter *rtw_usb_if1_init(struct dvobj_priv *dvobj,
+					    struct usb_interface *pusb_intf,
+					    const struct usb_device_id *pdid)
+{
+	struct rtw_adapter *padapter = NULL;
+	struct net_device *pnetdev = NULL;
+	int status = _FAIL;
+
+	pnetdev = rtw_init_netdev23a(padapter);
+	if (!pnetdev)
+		goto handle_dualmac;
+	padapter = netdev_priv(pnetdev);
+
+	padapter->dvobj = dvobj;
+	padapter->bDriverStopped = true;
+	dvobj->if1 = padapter;
+	dvobj->padapters[dvobj->iface_nums++] = padapter;
+	padapter->iface_id = IFACE_ID0;
+
+	/* step 1-1., decide the chip_type via vid/pid */
+	decide_chip_type_by_usb_device_id(padapter, pdid);
+
+	if (rtw_handle_dualmac23a(padapter, 1) != _SUCCESS)
+		goto free_adapter;
+
+	SET_NETDEV_DEV(pnetdev, dvobj_to_dev(dvobj));
+
+	if (rtw_wdev_alloc(padapter, dvobj_to_dev(dvobj)))
+		goto handle_dualmac;
+
+	/* step 2. hook HalFunc, allocate HalData */
+	if (rtl8723au_set_hal_ops(padapter))
+		return NULL;
+
+	padapter->intf_start = &usb_intf_start;
+	padapter->intf_stop = &usb_intf_stop;
+
+	/* step init_io_priv */
+	rtw_init_io_priv23a(padapter, usb_set_intf_ops);
+
+	/* step read_chip_version */
+	rtw_hal_read_chip_version23a(padapter);
+
+	/* step usb endpoint mapping */
+	rtw_hal_chip_configure23a(padapter);
+
+	/* step read efuse/eeprom data and get mac_addr */
+	rtw_hal_read_chip_info23a(padapter);
+
+	/* step 5. */
+	if (rtw_init_drv_sw23a(padapter) == _FAIL) {
+		RT_TRACE(_module_hci_intfs_c_, _drv_err_,
+			 ("Initialize driver software resource Failed!\n"));
+		goto free_hal_data;
+	}
+
+#ifdef CONFIG_PM
+	if (padapter->pwrctrlpriv.bSupportRemoteWakeup) {
+		dvobj->pusbdev->do_remote_wakeup = 1;
+		pusb_intf->needs_remote_wakeup = 1;
+		device_init_wakeup(&pusb_intf->dev, 1);
+		DBG_8723A("\n  padapter->pwrctrlpriv.bSupportRemoteWakeup~~~~~~\n");
+		DBG_8723A("\n  padapter->pwrctrlpriv.bSupportRemoteWakeup~~~[%d]~~~\n",
+			  device_may_wakeup(&pusb_intf->dev));
+	}
+#endif
+	/* 2012-07-11 Move here to prevent the 8723AS-VAU BT
+	 * auto suspend influence
+	 */
+	if (usb_autopm_get_interface(pusb_intf) < 0)
+		DBG_8723A("can't get autopm:\n");
+#ifdef	CONFIG_8723AU_BT_COEXIST
+	padapter->pwrctrlpriv.autopm_cnt = 1;
+#endif
+
+	/*  set mac addr */
+	rtw_macaddr_cfg23a(padapter->eeprompriv.mac_addr);
+	rtw_init_wifidirect_addrs23a(padapter, padapter->eeprompriv.mac_addr,
+				  padapter->eeprompriv.mac_addr);
+
+	DBG_8723A("bDriverStopped:%d, bSurpriseRemoved:%d, bup:%d, hw_init_completed:%d\n",
+		  padapter->bDriverStopped, padapter->bSurpriseRemoved,
+		  padapter->bup, padapter->hw_init_completed
+	);
+	status = _SUCCESS;
+
+free_hal_data:
+	if (status != _SUCCESS)
+		kfree(padapter->HalData);
+	if (status != _SUCCESS) {
+		rtw_wdev_unregister(padapter->rtw_wdev);
+		rtw_wdev_free(padapter->rtw_wdev);
+	}
+handle_dualmac:
+	if (status != _SUCCESS)
+		rtw_handle_dualmac23a(padapter, 0);
+free_adapter:
+	if (status != _SUCCESS) {
+		if (pnetdev)
+			free_netdev(pnetdev);
+		padapter = NULL;
+	}
+	return padapter;
+}
+
+static void rtw_usb_if1_deinit(struct rtw_adapter *if1)
+{
+	struct net_device *pnetdev = if1->pnetdev;
+	struct mlme_priv *pmlmepriv = &if1->mlmepriv;
+
+	if (check_fwstate(pmlmepriv, _FW_LINKED))
+		rtw_disassoc_cmd23a(if1, 0, false);
+
+#ifdef CONFIG_8723AU_AP_MODE
+	free_mlme_ap_info23a(if1);
+#endif
+
+	if (pnetdev)
+		unregister_netdev(pnetdev); /* will call netdev_close() */
+
+	rtw_cancel_all_timer23a(if1);
+
+	rtw_dev_unload(if1);
+
+	DBG_8723A("+r871xu_dev_remove, hw_init_completed =%d\n",
+		  if1->hw_init_completed);
+
+	rtw_handle_dualmac23a(if1, 0);
+
+	if (if1->rtw_wdev) {
+		rtw_wdev_unregister(if1->rtw_wdev);
+		rtw_wdev_free(if1->rtw_wdev);
+	}
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	if (1 == if1->pwrctrlpriv.autopm_cnt) {
+		usb_autopm_put_interface(adapter_to_dvobj(if1)->pusbintf);
+		if1->pwrctrlpriv.autopm_cnt--;
+	}
+#endif
+
+	rtw_free_drv_sw23a(if1);
+
+	if (pnetdev)
+		free_netdev(pnetdev);
+}
+
+static int rtw_drv_init(struct usb_interface *pusb_intf,
+			const struct usb_device_id *pdid)
+{
+	struct rtw_adapter *if1 = NULL;
+	struct dvobj_priv *dvobj;
+	int status = _FAIL;
+
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+rtw_drv_init\n"));
+
+	/* Initialize dvobj_priv */
+	dvobj = usb_dvobj_init(pusb_intf);
+	if (!dvobj) {
+		RT_TRACE(_module_hci_intfs_c_, _drv_err_,
+			 ("initialize device object priv Failed!\n"));
+		goto exit;
+	}
+
+	if1 = rtw_usb_if1_init(dvobj, pusb_intf, pdid);
+	if (!if1) {
+		DBG_8723A("rtw_init_primary_adapter Failed!\n");
+		goto free_dvobj;
+	}
+
+	/* dev_alloc_name && register_netdev */
+	status = rtw_drv_register_netdev(if1);
+	if (status != _SUCCESS)
+		goto free_if1;
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_,
+		 ("-871x_drv - drv_init, success!\n"));
+
+	status = _SUCCESS;
+
+free_if1:
+	if (status != _SUCCESS && if1)
+		rtw_usb_if1_deinit(if1);
+free_dvobj:
+	if (status != _SUCCESS)
+		usb_dvobj_deinit(pusb_intf);
+exit:
+	return status == _SUCCESS ? 0 : -ENODEV;
+}
+
+/* dev_remove() - our device is being removed */
+static void rtw_disconnect(struct usb_interface *pusb_intf)
+{
+	struct dvobj_priv *dvobj;
+	struct rtw_adapter *padapter;
+	struct net_device *pnetdev;
+	struct mlme_priv *pmlmepriv;
+
+	dvobj = usb_get_intfdata(pusb_intf);
+	if (!dvobj)
+		return;
+
+	padapter = dvobj->if1;
+	pnetdev = padapter->pnetdev;
+	pmlmepriv = &padapter->mlmepriv;
+
+	usb_set_intfdata(pusb_intf, NULL);
+
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+dev_remove()\n"));
+
+	rtw_pm_set_ips23a(padapter, IPS_NONE);
+	rtw_pm_set_lps23a(padapter, PS_MODE_ACTIVE);
+
+	LeaveAllPowerSaveMode23a(padapter);
+
+	rtw_usb_if1_deinit(padapter);
+
+	usb_dvobj_deinit(pusb_intf);
+
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("-dev_remove()\n"));
+	DBG_8723A("-r871xu_dev_remove, done\n");
+
+	return;
+}
+
+extern int console_suspend_enabled;
+
+static int __init rtw_drv_entry(void)
+{
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+rtw_drv_entry\n"));
+	rtw_suspend_lock_init();
+	return usb_register(usb_drv);
+}
+
+static void __exit rtw_drv_halt(void)
+{
+	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+rtw_drv_halt\n"));
+	DBG_8723A("+rtw_drv_halt\n");
+
+	rtw_suspend_lock_uninit();
+
+	usb_deregister(usb_drv);
+
+	DBG_8723A("-rtw_drv_halt\n");
+}
+
+module_init(rtw_drv_entry);
+module_exit(rtw_drv_halt);
diff --git a/drivers/staging/rtl8723au/os_dep/usb_ops_linux.c b/drivers/staging/rtl8723au/os_dep/usb_ops_linux.c
new file mode 100644
index 0000000..c49160e
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/usb_ops_linux.c
@@ -0,0 +1,283 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+#define _USB_OPS_LINUX_C_
+
+#include <drv_types.h>
+#include <usb_ops_linux.h>
+#include <rtw_sreset.h>
+
+unsigned int ffaddr2pipehdl23a(struct dvobj_priv *pdvobj, u32 addr)
+{
+	struct usb_device *pusbd = pdvobj->pusbdev;
+	unsigned int pipe = 0, ep_num = 0;
+
+	if (addr == RECV_BULK_IN_ADDR) {
+		pipe = usb_rcvbulkpipe(pusbd, pdvobj->RtInPipe[0]);
+	} else if (addr == RECV_INT_IN_ADDR) {
+		pipe = usb_rcvbulkpipe(pusbd, pdvobj->RtInPipe[1]);
+	} else if (addr < HW_QUEUE_ENTRY) {
+		ep_num = pdvobj->Queue2Pipe[addr];
+		pipe = usb_sndbulkpipe(pusbd, ep_num);
+	}
+	return pipe;
+}
+
+struct zero_bulkout_context {
+	void *pbuf;
+	void *purb;
+	void *pirp;
+	void *padapter;
+};
+
+void usb_read_mem23a(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *rmem)
+{
+}
+
+void usb_write_mem23a(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *wmem)
+{
+}
+
+void usb_read_port_cancel23a(struct intf_hdl *pintfhdl)
+{
+	struct recv_buf *precvbuf;
+	struct rtw_adapter *padapter = pintfhdl->padapter;
+	int i;
+
+	precvbuf = (struct recv_buf *)padapter->recvpriv.precv_buf;
+
+	DBG_8723A("%s\n", __func__);
+
+	padapter->bReadPortCancel = true;
+
+	for (i = 0; i < NR_RECVBUFF ; i++) {
+		if (precvbuf->purb)
+			usb_kill_urb(precvbuf->purb);
+		precvbuf++;
+	}
+	usb_kill_urb(padapter->recvpriv.int_in_urb);
+}
+
+static void usb_write_port23a_complete(struct urb *purb, struct pt_regs *regs)
+{
+	struct xmit_buf *pxmitbuf = (struct xmit_buf *)purb->context;
+	struct rtw_adapter *padapter = pxmitbuf->padapter;
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	struct hal_data_8723a *phaldata;
+	unsigned long irqL;
+
+	switch (pxmitbuf->flags) {
+	case VO_QUEUE_INX:
+		pxmitpriv->voq_cnt--;
+		break;
+	case VI_QUEUE_INX:
+		pxmitpriv->viq_cnt--;
+		break;
+	case BE_QUEUE_INX:
+		pxmitpriv->beq_cnt--;
+		break;
+	case BK_QUEUE_INX:
+		pxmitpriv->bkq_cnt--;
+		break;
+	case HIGH_QUEUE_INX:
+#ifdef CONFIG_8723AU_AP_MODE
+		rtw_chk_hi_queue_cmd23a(padapter);
+#endif
+		break;
+	default:
+		break;
+	}
+
+	if (padapter->bSurpriseRemoved || padapter->bDriverStopped ||
+	    padapter->bWritePortCancel) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_write_port23a_complete:bDriverStopped(%d) OR bSurpriseRemoved(%d)",
+			 padapter->bDriverStopped, padapter->bSurpriseRemoved));
+		DBG_8723A("%s(): TX Warning! bDriverStopped(%d) OR bSurpriseRemoved(%d) bWritePortCancel(%d) pxmitbuf->ext_tag(%x)\n",
+			  __func__, padapter->bDriverStopped,
+			  padapter->bSurpriseRemoved, padapter->bReadPortCancel,
+			  pxmitbuf->ext_tag);
+
+		goto check_completion;
+	}
+
+	if (purb->status) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_write_port23a_complete : purb->status(%d) != 0\n",
+			 purb->status));
+		DBG_8723A("###=> urb_write_port_complete status(%d)\n",
+			  purb->status);
+		if ((purb->status == -EPIPE) || (purb->status == -EPROTO)) {
+			sreset_set_wifi_error_status23a(padapter,
+						     USB_WRITE_PORT_FAIL);
+		} else if (purb->status == -EINPROGRESS) {
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_write_port23a_complete: EINPROGESS\n"));
+			goto check_completion;
+		} else if (purb->status == -ENOENT) {
+			DBG_8723A("%s: -ENOENT\n", __func__);
+			goto check_completion;
+		} else if (purb->status == -ECONNRESET) {
+			DBG_8723A("%s: -ECONNRESET\n", __func__);
+			goto check_completion;
+		} else if (purb->status == -ESHUTDOWN) {
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_write_port23a_complete: ESHUTDOWN\n"));
+			padapter->bDriverStopped = true;
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_write_port23a_complete:bDriverStopped = true\n"));
+			goto check_completion;
+		} else {
+			padapter->bSurpriseRemoved = true;
+			DBG_8723A("bSurpriseRemoved = true\n");
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_write_port23a_complete:bSurpriseRemoved = true\n"));
+			goto check_completion;
+		}
+	}
+	phaldata = GET_HAL_DATA(padapter);
+	phaldata->srestpriv.last_tx_complete_time = jiffies;
+
+check_completion:
+	spin_lock_irqsave(&pxmitpriv->lock_sctx, irqL);
+	rtw23a_sctx_done_err(&pxmitbuf->sctx,
+			  purb->status ? RTW_SCTX_DONE_WRITE_PORT_ERR :
+			  RTW_SCTX_DONE_SUCCESS);
+	spin_unlock_irqrestore(&pxmitpriv->lock_sctx, irqL);
+
+	rtw_free_xmitbuf23a(pxmitpriv, pxmitbuf);
+
+	tasklet_hi_schedule(&pxmitpriv->xmit_tasklet);
+}
+
+u32 usb_write_port23a(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
+		   struct xmit_buf *pxmitbuf)
+{
+	struct urb *purb = NULL;
+	struct rtw_adapter *padapter = (struct rtw_adapter *)pintfhdl->padapter;
+	struct dvobj_priv *pdvobj = adapter_to_dvobj(padapter);
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	struct xmit_frame *pxmitframe = (struct xmit_frame *)pxmitbuf->priv_data;
+	struct usb_device *pusbd = pdvobj->pusbdev;
+	unsigned long irqL;
+	unsigned int pipe;
+	int status;
+	u32 ret = _FAIL;
+
+	RT_TRACE(_module_hci_ops_os_c_, _drv_err_, ("+usb_write_port23a\n"));
+
+	if ((padapter->bDriverStopped) || (padapter->bSurpriseRemoved) ||
+	    (padapter->pwrctrlpriv.pnp_bstop_trx)) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_write_port23a:( padapter->bDriverStopped ||padapter->bSurpriseRemoved ||adapter->pwrctrlpriv.pnp_bstop_trx)!!!\n"));
+		rtw23a_sctx_done_err(&pxmitbuf->sctx, RTW_SCTX_DONE_TX_DENY);
+		goto exit;
+	}
+
+	spin_lock_irqsave(&pxmitpriv->lock, irqL);
+
+	switch (addr) {
+	case VO_QUEUE_INX:
+		pxmitpriv->voq_cnt++;
+		pxmitbuf->flags = VO_QUEUE_INX;
+		break;
+	case VI_QUEUE_INX:
+		pxmitpriv->viq_cnt++;
+		pxmitbuf->flags = VI_QUEUE_INX;
+		break;
+	case BE_QUEUE_INX:
+		pxmitpriv->beq_cnt++;
+		pxmitbuf->flags = BE_QUEUE_INX;
+		break;
+	case BK_QUEUE_INX:
+		pxmitpriv->bkq_cnt++;
+		pxmitbuf->flags = BK_QUEUE_INX;
+		break;
+	case HIGH_QUEUE_INX:
+		pxmitbuf->flags = HIGH_QUEUE_INX;
+		break;
+	default:
+		pxmitbuf->flags = MGT_QUEUE_INX;
+		break;
+	}
+
+	spin_unlock_irqrestore(&pxmitpriv->lock, irqL);
+
+	purb	= pxmitbuf->pxmit_urb[0];
+
+	/* translate DMA FIFO addr to pipehandle */
+	pipe = ffaddr2pipehdl23a(pdvobj, addr);
+
+	usb_fill_bulk_urb(purb, pusbd, pipe,
+			  pxmitframe->buf_addr, /*  pxmitbuf->pbuf */
+			  cnt, usb_write_port23a_complete,
+			  pxmitbuf);/* context is pxmitbuf */
+
+	status = usb_submit_urb(purb, GFP_ATOMIC);
+	if (!status) {
+		struct hal_data_8723a *phaldata = GET_HAL_DATA(padapter);
+		phaldata->srestpriv.last_tx_time = jiffies;
+	} else {
+		rtw23a_sctx_done_err(&pxmitbuf->sctx,
+				  RTW_SCTX_DONE_WRITE_PORT_ERR);
+		DBG_8723A("usb_write_port23a, status =%d\n", status);
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_write_port23a(): usb_submit_urb, status =%x\n",
+			 status));
+
+		switch (status) {
+		case -ENODEV:
+			padapter->bDriverStopped = true;
+			break;
+		default:
+			break;
+		}
+		goto exit;
+	}
+	ret = _SUCCESS;
+	RT_TRACE(_module_hci_ops_os_c_, _drv_err_, ("-usb_write_port23a\n"));
+
+exit:
+	if (ret != _SUCCESS)
+		rtw_free_xmitbuf23a(pxmitpriv, pxmitbuf);
+
+	return ret;
+}
+
+void usb_write_port23a_cancel(struct intf_hdl *pintfhdl)
+{
+	struct rtw_adapter *padapter = pintfhdl->padapter;
+	struct xmit_buf *pxmitbuf;
+	struct list_head *plist;
+	int j;
+
+	DBG_8723A("%s\n", __func__);
+
+	padapter->bWritePortCancel = true;
+
+	list_for_each(plist, &padapter->xmitpriv.xmitbuf_list) {
+		pxmitbuf = container_of(plist, struct xmit_buf, list2);
+		for (j = 0; j < 8; j++) {
+			if (pxmitbuf->pxmit_urb[j])
+				usb_kill_urb(pxmitbuf->pxmit_urb[j]);
+		}
+	}
+	list_for_each(plist, &padapter->xmitpriv.xmitextbuf_list) {
+		pxmitbuf = container_of(plist, struct xmit_buf, list2);
+		for (j = 0; j < 8; j++) {
+			if (pxmitbuf->pxmit_urb[j])
+				usb_kill_urb(pxmitbuf->pxmit_urb[j]);
+		}
+	}
+}
diff --git a/drivers/staging/rtl8723au/os_dep/xmit_linux.c b/drivers/staging/rtl8723au/os_dep/xmit_linux.c
new file mode 100644
index 0000000..e1c6fc7
--- /dev/null
+++ b/drivers/staging/rtl8723au/os_dep/xmit_linux.c
@@ -0,0 +1,195 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ ******************************************************************************/
+#define _XMIT_OSDEP_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#include <linux/if_ether.h>
+#include <linux/ip.h>
+#include <wifi.h>
+#include <mlme_osdep.h>
+#include <xmit_osdep.h>
+#include <osdep_intf.h>
+
+uint rtw_remainder_len23a(struct pkt_file *pfile)
+{
+	return pfile->buf_len - ((unsigned long)(pfile->cur_addr) -
+	       (unsigned long)(pfile->buf_start));
+}
+
+void _rtw_open_pktfile23a(struct sk_buff *pktptr, struct pkt_file *pfile)
+{
+	pfile->pkt = pktptr;
+	pfile->buf_start = pktptr->data;
+	pfile->cur_addr = pktptr->data;
+	pfile->buf_len = pktptr->len;
+	pfile->pkt_len = pktptr->len;
+
+	pfile->cur_buffer = pfile->buf_start;
+}
+
+uint _rtw_pktfile_read23a(struct pkt_file *pfile, u8 *rmem, uint rlen)
+{
+	uint	len = 0;
+
+	len =  rtw_remainder_len23a(pfile);
+	len = (rlen > len) ? len : rlen;
+
+	if (rmem)
+		skb_copy_bits(pfile->pkt, pfile->buf_len-pfile->pkt_len,
+			      rmem, len);
+
+	pfile->cur_addr += len;
+	pfile->pkt_len -= len;
+
+	return len;
+}
+
+int rtw_endofpktfile23a(struct pkt_file *pfile)
+{
+	if (pfile->pkt_len == 0)
+		return true;
+	return false;
+}
+
+int rtw_os_xmit_resource_alloc23a(struct rtw_adapter *padapter,
+			       struct xmit_buf *pxmitbuf, u32 alloc_sz)
+{
+	int i;
+
+	pxmitbuf->pallocated_buf = kzalloc(alloc_sz, GFP_KERNEL);
+	if (pxmitbuf->pallocated_buf == NULL)
+		return _FAIL;
+
+	pxmitbuf->pbuf = PTR_ALIGN(pxmitbuf->pallocated_buf, XMITBUF_ALIGN_SZ);
+
+	for (i = 0; i < 8; i++) {
+		pxmitbuf->pxmit_urb[i] = usb_alloc_urb(0, GFP_KERNEL);
+		if (pxmitbuf->pxmit_urb[i] == NULL) {
+			DBG_8723A("pxmitbuf->pxmit_urb[i]==NULL");
+			return _FAIL;
+		}
+	}
+	return _SUCCESS;
+}
+
+void rtw_os_xmit_resource_free23a(struct rtw_adapter *padapter,
+			       struct xmit_buf *pxmitbuf)
+{
+	int i;
+
+	for (i = 0; i < 8; i++)
+		usb_free_urb(pxmitbuf->pxmit_urb[i]);
+	kfree(pxmitbuf->pallocated_buf);
+}
+
+#define WMM_XMIT_THRESHOLD	(NR_XMITFRAME*2/5)
+
+void rtw_os_pkt_complete23a(struct rtw_adapter *padapter, struct sk_buff *pkt)
+{
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	u16	queue;
+
+	queue = skb_get_queue_mapping(pkt);
+	if (padapter->registrypriv.wifi_spec) {
+		if (__netif_subqueue_stopped(padapter->pnetdev, queue) &&
+		    (pxmitpriv->hwxmits[queue].accnt < WMM_XMIT_THRESHOLD))
+			netif_wake_subqueue(padapter->pnetdev, queue);
+	} else {
+		if (__netif_subqueue_stopped(padapter->pnetdev, queue))
+			netif_wake_subqueue(padapter->pnetdev, queue);
+	}
+	dev_kfree_skb_any(pkt);
+}
+
+void rtw_os_xmit_complete23a(struct rtw_adapter *padapter,
+			  struct xmit_frame *pxframe)
+{
+	if (pxframe->pkt)
+		rtw_os_pkt_complete23a(padapter, pxframe->pkt);
+
+	pxframe->pkt = NULL;
+}
+
+void rtw_os_xmit_schedule23a(struct rtw_adapter *padapter)
+{
+	struct xmit_priv *pxmitpriv;
+
+	if (!padapter)
+		return;
+	pxmitpriv = &padapter->xmitpriv;
+
+	spin_lock_bh(&pxmitpriv->lock);
+
+	if (rtw_txframes_pending23a(padapter))
+		tasklet_hi_schedule(&pxmitpriv->xmit_tasklet);
+	spin_unlock_bh(&pxmitpriv->lock);
+}
+
+static void rtw_check_xmit_resource(struct rtw_adapter *padapter,
+				    struct sk_buff *pkt)
+{
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	u16	queue;
+
+	queue = skb_get_queue_mapping(pkt);
+	if (padapter->registrypriv.wifi_spec) {
+		/* No free space for Tx, tx_worker is too slow */
+		if (pxmitpriv->hwxmits[queue].accnt > WMM_XMIT_THRESHOLD)
+			netif_stop_subqueue(padapter->pnetdev, queue);
+	} else {
+		if (pxmitpriv->free_xmitframe_cnt <= 4) {
+			if (!netif_tx_queue_stopped(netdev_get_tx_queue(padapter->pnetdev, queue)))
+				netif_stop_subqueue(padapter->pnetdev, queue);
+		}
+	}
+}
+
+int rtw_xmit23a_entry23a(struct sk_buff *skb, struct net_device *pnetdev)
+{
+	struct rtw_adapter *padapter = netdev_priv(pnetdev);
+	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
+	int res = 0;
+
+	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("+xmit_enry\n"));
+
+	if (!rtw_if_up23a(padapter)) {
+		RT_TRACE(_module_xmit_osdep_c_, _drv_err_,
+			 ("rtw_xmit23a_entry23a: rtw_if_up23a fail\n"));
+		goto drop_packet;
+	}
+
+	rtw_check_xmit_resource(padapter, skb);
+
+	res = rtw_xmit23a(padapter, skb);
+	if (res < 0)
+		goto drop_packet;
+
+	pxmitpriv->tx_pkts++;
+	RT_TRACE(_module_xmit_osdep_c_, _drv_info_,
+		 ("rtw_xmit23a_entry23a: tx_pkts=%d\n",
+		 (u32)pxmitpriv->tx_pkts));
+	goto exit;
+
+drop_packet:
+	pxmitpriv->tx_drop++;
+	dev_kfree_skb_any(skb);
+	RT_TRACE(_module_xmit_osdep_c_, _drv_notice_,
+		 ("rtw_xmit23a_entry23a: drop, tx_drop=%d\n",
+		 (u32)pxmitpriv->tx_drop));
+exit:
+	return 0;
+}
-- 
1.8.4.5
