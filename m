From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/22] staging: rtl8723bs: Fix various errors in os_dep/ioctl_cfg80211.c
Date: Sat,  8 Apr 2017 11:07:29 -0500
Message-ID: <20170408160745.14328-7-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34150 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752540AbdDHQIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:07 -0400
Received: by mail-oi0-f67.google.com with SMTP id w197so6121279oiw.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:07 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:

  CHECK   drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:470 rtw_cfg80211_ibss_indicate_connect() error: we previously assumed 'scanned' could be null (see line 466)
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:942 rtw_cfg80211_set_encryption() warn: inconsistent indenting
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:955 rtw_cfg80211_set_encryption() error: buffer overflow 'psecuritypriv->dot11DefKey' 4 <= 4
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:1017 rtw_cfg80211_set_encryption() error: buffer overflow 'padapter->securitypriv.dot118021XGrpKey' 5 <= 5
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:1216 cfg80211_rtw_set_default_key() warn: inconsistent indenting
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2498 rtw_cfg80211_monitor_if_xmit_entry() error: we previously assumed 'skb' could be null (see line 2495)
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2850 cfg80211_rtw_start_ap() warn: if statement not indented
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2860 cfg80211_rtw_start_ap() warn: if statement not indented
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:3417 rtw_cfg80211_preinit_wiphy() warn: inconsistent indenting
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:3547 rtw_wdev_alloc() info: ignoring unreachable code.

The indenting warnings were fixed by simple white space changes.

The section where 'scanned' could be null required an immediate exit from
the routine at that point. A similar fix was required where 'skb' could be null.

The two buffer overflow errors were caused by off-by-one errors. While
locating these problems, another one was found in os_dep/ioctl_linux.c.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c | 38 +++++++++--------------
 drivers/staging/rtl8723bs/os_dep/ioctl_linux.c    |  2 +-
 2 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c b/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
index ce7cca68ff7a..d2c66041a561 100644
--- a/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
+++ b/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
@@ -463,9 +463,10 @@ void rtw_cfg80211_ibss_indicate_connect(struct adapter *padapter)
 		}
 		else
 		{
-			if (scanned == NULL)
+			if (scanned == NULL) {
 				rtw_warn_on(1);
-
+				return;
+			}
 			if (!memcmp(&(scanned->network.Ssid), &(pnetwork->Ssid), sizeof(struct ndis_802_11_ssid))
 				&& !memcmp(scanned->network.MacAddress, pnetwork->MacAddress, sizeof(NDIS_802_11_MAC_ADDRESS))
 			) {
@@ -906,7 +907,7 @@ static int rtw_cfg80211_set_encryption(struct net_device *dev, struct ieee_param
 	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff)
 	{
 		if (param->u.crypt.idx >= WEP_KEYS
-			&& param->u.crypt.idx > BIP_MAX_KEYID
+			|| param->u.crypt.idx >= BIP_MAX_KEYID
 		)
 		{
 			ret = -EINVAL;
@@ -927,7 +928,7 @@ static int rtw_cfg80211_set_encryption(struct net_device *dev, struct ieee_param
 		wep_key_idx = param->u.crypt.idx;
 		wep_key_len = param->u.crypt.key_len;
 
-		if ((wep_key_idx > WEP_KEYS) || (wep_key_len <= 0))
+		if ((wep_key_idx >= WEP_KEYS) || (wep_key_len <= 0))
 		{
 			ret = -EINVAL;
 			goto exit;
@@ -939,7 +940,7 @@ static int rtw_cfg80211_set_encryption(struct net_device *dev, struct ieee_param
 
 			wep_key_len = wep_key_len <= 5 ? 5 : 13;
 
-		psecuritypriv->ndisencryptstatus = Ndis802_11Encryption1Enabled;
+			psecuritypriv->ndisencryptstatus = Ndis802_11Encryption1Enabled;
 			psecuritypriv->dot11PrivacyAlgrthm = _WEP40_;
 			psecuritypriv->dot118021XGrpPrivacy = _WEP40_;
 
@@ -1213,11 +1214,8 @@ static int cfg80211_rtw_set_default_key(struct wiphy *wiphy,
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(ndev);
 	struct security_priv *psecuritypriv = &padapter->securitypriv;
 
-		DBG_871X(FUNC_NDEV_FMT" key_index =%d"
-		", unicast =%d, multicast =%d"
-		".\n", FUNC_NDEV_ARG(ndev), key_index
-		, unicast, multicast
-		);
+	DBG_871X(FUNC_NDEV_FMT" key_index =%d, unicast =%d, multicast =%d\n",
+		 FUNC_NDEV_ARG(ndev), key_index, unicast, multicast);
 
 	if ((key_index < WEP_KEYS) && ((psecuritypriv->dot11PrivacyAlgrthm == _WEP40_) || (psecuritypriv->dot11PrivacyAlgrthm == _WEP104_))) /* set wep default key */
 	{
@@ -2492,8 +2490,10 @@ static int rtw_cfg80211_monitor_if_xmit_entry(struct sk_buff *skb, struct net_de
 
 	DBG_871X(FUNC_NDEV_FMT"\n", FUNC_NDEV_ARG(ndev));
 
-	if (skb)
-		rtw_mstat_update(MSTAT_TYPE_SKB, MSTAT_ALLOC_SUCCESS, skb->truesize);
+	if (!skb)
+		goto fail;
+
+	rtw_mstat_update(MSTAT_TYPE_SKB, MSTAT_ALLOC_SUCCESS, skb->truesize);
 
 	if (unlikely(skb->len < sizeof(struct ieee80211_radiotap_header)))
 		goto fail;
@@ -2847,20 +2847,10 @@ static int cfg80211_rtw_start_ap(struct wiphy *wiphy, struct net_device *ndev,
 		struct wlan_bssid_ex *pbss_network = &adapter->mlmepriv.cur_network.network;
 		struct wlan_bssid_ex *pbss_network_ext = &adapter->mlmeextpriv.mlmext_info.network;
 
-		if (0)
-		DBG_871X(FUNC_ADPT_FMT" ssid:(%s,%zu), from ie:(%s,%d)\n", FUNC_ADPT_ARG(adapter),
-			settings->ssid, settings->ssid_len,
-			pbss_network->Ssid.Ssid, pbss_network->Ssid.SsidLength);
-
 		memcpy(pbss_network->Ssid.Ssid, (void *)settings->ssid, settings->ssid_len);
 		pbss_network->Ssid.SsidLength = settings->ssid_len;
 		memcpy(pbss_network_ext->Ssid.Ssid, (void *)settings->ssid, settings->ssid_len);
 		pbss_network_ext->Ssid.SsidLength = settings->ssid_len;
-
-		if (0)
-		DBG_871X(FUNC_ADPT_FMT" after ssid:(%s,%d), (%s,%d)\n", FUNC_ADPT_ARG(adapter),
-			pbss_network->Ssid.Ssid, pbss_network->Ssid.SsidLength,
-			pbss_network_ext->Ssid.Ssid, pbss_network_ext->Ssid.SsidLength);
 	}
 
 	return ret;
@@ -3414,7 +3404,7 @@ static void rtw_cfg80211_preinit_wiphy(struct adapter *padapter, struct wiphy *w
 	wiphy->n_cipher_suites = ARRAY_SIZE(rtw_cipher_suites);
 
 	/* if (padapter->registrypriv.wireless_mode & WIRELESS_11G) */
-		wiphy->bands[NL80211_BAND_2GHZ] = rtw_spt_band_alloc(NL80211_BAND_2GHZ);
+	wiphy->bands[NL80211_BAND_2GHZ] = rtw_spt_band_alloc(NL80211_BAND_2GHZ);
 
 	wiphy->flags |= WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL;
 	wiphy->flags |= WIPHY_FLAG_OFFCHAN_TX | WIPHY_FLAG_HAVE_AP_SME;
@@ -3541,10 +3531,10 @@ int rtw_wdev_alloc(struct adapter *padapter, struct device *dev)
 		pwdev_priv->power_mgmt = true;
 	else
 		pwdev_priv->power_mgmt = false;
+	kfree((u8 *)wdev);
 
 	return ret;
 
-	kfree((u8 *)wdev);
 unregister_wiphy:
 	wiphy_unregister(wiphy);
  free_wiphy:
diff --git a/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c b/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c
index 3faa5d943466..fe3c42a0da31 100644
--- a/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c
@@ -570,7 +570,7 @@ static int wpa_set_encryption(struct net_device *dev, struct ieee_param *param,
 	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff)
 	{
 
-		if (param->u.crypt.idx >= WEP_KEYS &&
+		if (param->u.crypt.idx >= WEP_KEYS ||
 		    param->u.crypt.idx >= BIP_MAX_KEYID) {
 			ret = -EINVAL;
 			goto exit;
-- 
2.12.0
