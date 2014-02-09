From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/6] staging: r8188eu: Replace wrapper around _rtw_memcmp()
Date: Sun,  9 Feb 2014 15:15:54 -0600
Message-ID: <1391980559-24288-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This wrapper is replaced with a simple memcmp(). As the wrapper inverts the
logic of memcmp(), care needed to be taken.

This patch also adds one include of vmalloc.h that was missed in a previous
patch.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c           | 16 ++---
 drivers/staging/rtl8188eu/core/rtw_ieee80211.c    | 42 ++++++-------
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c    |  4 +-
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 20 +++---
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 76 ++++++++++++-----------
 drivers/staging/rtl8188eu/core/rtw_p2p.c          | 20 +++---
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 48 +++++++-------
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      | 10 +--
 drivers/staging/rtl8188eu/core/rtw_wlan_util.c    | 42 ++++++-------
 drivers/staging/rtl8188eu/core/rtw_xmit.c         |  4 +-
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c    |  4 +-
 drivers/staging/rtl8188eu/hal/odm.c               |  4 +-
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 33 ----------
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c |  1 +
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c       |  4 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c   |  4 +-
 drivers/staging/rtl8188eu/include/osdep_service.h |  1 -
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 10 ---
 drivers/staging/rtl8188eu/os_dep/recv_linux.c     |  4 +-
 19 files changed, 154 insertions(+), 193 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index 8ebe6bc..fe5ec8e 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -980,7 +980,7 @@ int rtw_check_beacon_data(struct adapter *padapter, u8 *pbuf,  int len)
 	for (p = ie + _BEACON_IE_OFFSET_;; p += (ie_len + 2)) {
 		p = rtw_get_ie(p, _SSN_IE_1_, &ie_len,
 			       (pbss_network->IELength - _BEACON_IE_OFFSET_ - (ie_len + 2)));
-		if ((p) && (_rtw_memcmp(p+2, OUI1, 4))) {
+		if ((p) && (!memcmp(p+2, OUI1, 4))) {
 			if (rtw_parse_wpa_ie(p, ie_len+2, &group_cipher,
 					     &pairwise_cipher, NULL) == _SUCCESS) {
 				psecuritypriv->dot11AuthAlgrthm = dot11AuthAlgrthm_8021X;
@@ -1005,7 +1005,7 @@ int rtw_check_beacon_data(struct adapter *padapter, u8 *pbuf,  int len)
 		for (p = ie + _BEACON_IE_OFFSET_;; p += (ie_len + 2)) {
 			p = rtw_get_ie(p, _VENDOR_SPECIFIC_IE_, &ie_len,
 				       (pbss_network->IELength - _BEACON_IE_OFFSET_ - (ie_len + 2)));
-			if ((p) && _rtw_memcmp(p+2, WMM_PARA_IE, 6)) {
+			if ((p) && !memcmp(p+2, WMM_PARA_IE, 6)) {
 				pmlmepriv->qospriv.qos_option = 1;
 
 				*(p+8) |= BIT(7);/* QoS Info, support U-APSD */
@@ -1150,7 +1150,7 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 		paclnode = LIST_CONTAINOR(plist, struct rtw_wlan_acl_node, list);
 		plist = get_next(plist);
 
-		if (_rtw_memcmp(paclnode->addr, addr, ETH_ALEN)) {
+		if (!memcmp(paclnode->addr, addr, ETH_ALEN)) {
 			if (paclnode->valid) {
 				added = true;
 				DBG_88E("%s, sta has been added\n", __func__);
@@ -1211,7 +1211,7 @@ int rtw_acl_remove_sta(struct adapter *padapter, u8 *addr)
 		paclnode = LIST_CONTAINOR(plist, struct rtw_wlan_acl_node, list);
 		plist = get_next(plist);
 
-		if (_rtw_memcmp(paclnode->addr, addr, ETH_ALEN)) {
+		if (!memcmp(paclnode->addr, addr, ETH_ALEN)) {
 			if (paclnode->valid) {
 				paclnode->valid = false;
 
@@ -1351,13 +1351,13 @@ static void update_bcn_vendor_spec_ie(struct adapter *padapter, u8 *oui)
 {
 	DBG_88E("%s\n", __func__);
 
-	if (_rtw_memcmp(RTW_WPA_OUI, oui, 4))
+	if (!memcmp(RTW_WPA_OUI, oui, 4))
 		update_bcn_wpa_ie(padapter);
-	else if (_rtw_memcmp(WMM_OUI, oui, 4))
+	else if (!memcmp(WMM_OUI, oui, 4))
 		update_bcn_wmm_ie(padapter);
-	else if (_rtw_memcmp(WPS_OUI, oui, 4))
+	else if (!memcmp(WPS_OUI, oui, 4))
 		update_bcn_wps_ie(padapter);
-	else if (_rtw_memcmp(P2P_OUI, oui, 4))
+	else if (!memcmp(P2P_OUI, oui, 4))
 		update_bcn_p2p_ie(padapter);
 	else
 		DBG_88E("unknown OUI type!\n");
diff --git a/drivers/staging/rtl8188eu/core/rtw_ieee80211.c b/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
index e6f98fb..002195a 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ieee80211.c
@@ -273,7 +273,7 @@ u8 *rtw_get_ie_ex(u8 *in_ie, uint in_len, u8 eid, u8 *oui, u8 oui_len, u8 *ie, u
 	cnt = 0;
 
 	while (cnt < in_len) {
-		if (eid == in_ie[cnt] && (!oui || _rtw_memcmp(&in_ie[cnt+2], oui, oui_len))) {
+		if (eid == in_ie[cnt] && (!oui || !memcmp(&in_ie[cnt+2], oui, oui_len))) {
 			target_ie = &in_ie[cnt];
 
 			if (ie)
@@ -463,7 +463,7 @@ unsigned char *rtw_get_wpa_ie(unsigned char *pie, int *wpa_ie_len, int limit)
 
 		if (pbuf) {
 			/* check if oui matches... */
-			if (_rtw_memcmp((pbuf + 2), wpa_oui_type, sizeof (wpa_oui_type)) == false)
+			if (!memcmp((pbuf + 2), wpa_oui_type, sizeof(wpa_oui_type)) == false)
 				goto check_next_ie;
 
 			/* check version... */
@@ -497,15 +497,15 @@ unsigned char *rtw_get_wpa2_ie(unsigned char *pie, int *rsn_ie_len, int limit)
 
 int rtw_get_wpa_cipher_suite(u8 *s)
 {
-	if (_rtw_memcmp(s, WPA_CIPHER_SUITE_NONE, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_NONE, WPA_SELECTOR_LEN) == true)
 		return WPA_CIPHER_NONE;
-	if (_rtw_memcmp(s, WPA_CIPHER_SUITE_WEP40, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_WEP40, WPA_SELECTOR_LEN) == true)
 		return WPA_CIPHER_WEP40;
-	if (_rtw_memcmp(s, WPA_CIPHER_SUITE_TKIP, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_TKIP, WPA_SELECTOR_LEN) == true)
 		return WPA_CIPHER_TKIP;
-	if (_rtw_memcmp(s, WPA_CIPHER_SUITE_CCMP, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_CCMP, WPA_SELECTOR_LEN) == true)
 		return WPA_CIPHER_CCMP;
-	if (_rtw_memcmp(s, WPA_CIPHER_SUITE_WEP104, WPA_SELECTOR_LEN) == true)
+	if (!memcmp(s, WPA_CIPHER_SUITE_WEP104, WPA_SELECTOR_LEN) == true)
 		return WPA_CIPHER_WEP104;
 
 	return 0;
@@ -513,15 +513,15 @@ int rtw_get_wpa_cipher_suite(u8 *s)
 
 int rtw_get_wpa2_cipher_suite(u8 *s)
 {
-	if (_rtw_memcmp(s, RSN_CIPHER_SUITE_NONE, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_NONE, RSN_SELECTOR_LEN) == true)
 		return WPA_CIPHER_NONE;
-	if (_rtw_memcmp(s, RSN_CIPHER_SUITE_WEP40, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_WEP40, RSN_SELECTOR_LEN) == true)
 		return WPA_CIPHER_WEP40;
-	if (_rtw_memcmp(s, RSN_CIPHER_SUITE_TKIP, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_TKIP, RSN_SELECTOR_LEN) == true)
 		return WPA_CIPHER_TKIP;
-	if (_rtw_memcmp(s, RSN_CIPHER_SUITE_CCMP, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_CCMP, RSN_SELECTOR_LEN) == true)
 		return WPA_CIPHER_CCMP;
-	if (_rtw_memcmp(s, RSN_CIPHER_SUITE_WEP104, RSN_SELECTOR_LEN) == true)
+	if (!memcmp(s, RSN_CIPHER_SUITE_WEP104, RSN_SELECTOR_LEN) == true)
 		return WPA_CIPHER_WEP104;
 
 	return 0;
@@ -542,7 +542,7 @@ int rtw_parse_wpa_ie(u8 *wpa_ie, int wpa_ie_len, int *group_cipher, int *pairwis
 
 
 	if ((*wpa_ie != _WPA_IE_ID_) || (*(wpa_ie+1) != (u8)(wpa_ie_len - 2)) ||
-	    (_rtw_memcmp(wpa_ie+2, RTW_WPA_OUI_TYPE, WPA_SELECTOR_LEN) != true))
+	    (!memcmp(wpa_ie+2, RTW_WPA_OUI_TYPE, WPA_SELECTOR_LEN) != true))
 		return _FAIL;
 
 	pos = wpa_ie;
@@ -587,7 +587,7 @@ int rtw_parse_wpa_ie(u8 *wpa_ie, int wpa_ie_len, int *group_cipher, int *pairwis
 	if (is_8021x) {
 		if (left >= 6) {
 			pos += 2;
-			if (_rtw_memcmp(pos, SUITE_1X, 4) == 1) {
+			if (!memcmp(pos, SUITE_1X, 4) == 1) {
 				RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("%s : there has 802.1x auth\n", __func__));
 				*is_8021x = 1;
 			}
@@ -657,7 +657,7 @@ int rtw_parse_wpa2_ie(u8 *rsn_ie, int rsn_ie_len, int *group_cipher, int *pairwi
 	if (is_8021x) {
 		if (left >= 6) {
 			pos += 2;
-			if (_rtw_memcmp(pos, SUITE_1X, 4) == 1) {
+			if (!memcmp(pos, SUITE_1X, 4) == 1) {
 				RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("%s (): there has 802.1x auth\n", __func__));
 				*is_8021x = 1;
 			}
@@ -683,7 +683,7 @@ _func_enter_;
 	while (cnt < in_len) {
 		authmode = in_ie[cnt];
 
-		if ((authmode == _WPA_IE_ID_) && (_rtw_memcmp(&in_ie[cnt+2], &wpa_oui[0], 4))) {
+		if ((authmode == _WPA_IE_ID_) && (!memcmp(&in_ie[cnt+2], &wpa_oui[0], 4))) {
 				RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_,
 					 ("\n rtw_get_wpa_ie: sec_idx =%d in_ie[cnt+1]+2 =%d\n",
 					 sec_idx, in_ie[cnt+1]+2));
@@ -741,7 +741,7 @@ u8 rtw_is_wps_ie(u8 *ie_ptr, uint *wps_ielen)
 
 	eid = ie_ptr[0];
 
-	if ((eid == _WPA_IE_ID_) && (_rtw_memcmp(&ie_ptr[2], wps_oui, 4))) {
+	if ((eid == _WPA_IE_ID_) && (!memcmp(&ie_ptr[2], wps_oui, 4))) {
 		*wps_ielen = ie_ptr[1]+2;
 		match = true;
 	}
@@ -774,7 +774,7 @@ u8 *rtw_get_wps_ie(u8 *in_ie, uint in_len, u8 *wps_ie, uint *wps_ielen)
 	while (cnt < in_len) {
 		eid = in_ie[cnt];
 
-		if ((eid == _WPA_IE_ID_) && (_rtw_memcmp(&in_ie[cnt+2], wps_oui, 4))) {
+		if ((eid == _WPA_IE_ID_) && (!memcmp(&in_ie[cnt+2], wps_oui, 4))) {
 			wpsie_ptr = &in_ie[cnt];
 
 			if (wps_ie)
@@ -813,7 +813,7 @@ u8 *rtw_get_wps_attr(u8 *wps_ie, uint wps_ielen, u16 target_attr_id , u8 *buf_at
 		*len_attr = 0;
 
 	if ((wps_ie[0] != _VENDOR_SPECIFIC_IE_) ||
-	    (_rtw_memcmp(wps_ie + 2, wps_oui , 4) != true))
+	    (!memcmp(wps_ie + 2, wps_oui , 4) != true))
 		return attr_ptr;
 
 	/*  6 = 1(Element ID) + 1(Length) + 4(WPS OUI) */
@@ -1223,7 +1223,7 @@ u8 *rtw_get_p2p_ie(u8 *in_ie, int in_len, u8 *p2p_ie, uint *p2p_ielen)
 			dump_stack();
 			return NULL;
 		}
-		if ((eid == _VENDOR_SPECIFIC_IE_) && (_rtw_memcmp(&in_ie[cnt+2], p2p_oui, 4) == true)) {
+		if ((eid == _VENDOR_SPECIFIC_IE_) && (!memcmp(&in_ie[cnt+2], p2p_oui, 4) == true)) {
 			p2p_ie_ptr = in_ie + cnt;
 
 			if (p2p_ie != NULL)
@@ -1258,7 +1258,7 @@ u8 *rtw_get_p2p_attr(u8 *p2p_ie, uint p2p_ielen, u8 target_attr_id , u8 *buf_att
 		*len_attr = 0;
 
 	if (!p2p_ie || (p2p_ie[0] != _VENDOR_SPECIFIC_IE_) ||
-	    (_rtw_memcmp(p2p_ie + 2, p2p_oui , 4) != true))
+	    (!memcmp(p2p_ie + 2, p2p_oui , 4) != true))
 		return attr_ptr;
 
 	/*  6 = 1(Element ID) + 1(Length) + 3 (OUI) + 1(OUI Type) */
diff --git a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
index e25b39b..125ba4c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
@@ -205,7 +205,7 @@ _func_enter_;
 	if (check_fwstate(pmlmepriv, _FW_LINKED|WIFI_ADHOC_MASTER_STATE)) {
 		RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_info_, ("set_bssid: _FW_LINKED||WIFI_ADHOC_MASTER_STATE\n"));
 
-		if (_rtw_memcmp(&pmlmepriv->cur_network.network.MacAddress, bssid, ETH_ALEN)) {
+		if (!memcmp(&pmlmepriv->cur_network.network.MacAddress, bssid, ETH_ALEN)) {
 			if (check_fwstate(pmlmepriv, WIFI_STATION_STATE) == false)
 				goto release_mlme_lock;/* it means driver is in WIFI_ADHOC_MASTER_STATE, we needn't create bss again. */
 		} else {
@@ -296,7 +296,7 @@ _func_enter_;
 			 ("set_ssid: _FW_LINKED||WIFI_ADHOC_MASTER_STATE\n"));
 
 		if ((pmlmepriv->assoc_ssid.SsidLength == ssid->SsidLength) &&
-		    (_rtw_memcmp(&pmlmepriv->assoc_ssid.Ssid, ssid->Ssid, ssid->SsidLength))) {
+		    (!memcmp(&pmlmepriv->assoc_ssid.Ssid, ssid->Ssid, ssid->SsidLength))) {
 			if ((check_fwstate(pmlmepriv, WIFI_STATION_STATE) == false)) {
 				RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_,
 					 ("Set SSID is the same ssid, fw_state = 0x%08x\n",
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 927fc72..4f482e2 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -277,7 +277,7 @@ struct wlan_network *_rtw_find_network(struct __queue *scanned_queue, u8 *addr)
 	u8 zero_addr[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 
 _func_enter_;
-	if (_rtw_memcmp(zero_addr, addr, ETH_ALEN)) {
+	if (!memcmp(zero_addr, addr, ETH_ALEN)) {
 		pnetwork = NULL;
 		goto exit;
 	}
@@ -286,7 +286,7 @@ _func_enter_;
 
 	while (plist != phead) {
 		pnetwork = LIST_CONTAINOR(plist, struct wlan_network , list);
-		if (_rtw_memcmp(addr, pnetwork->network.MacAddress, ETH_ALEN) == true)
+		if (!memcmp(addr, pnetwork->network.MacAddress, ETH_ALEN) == true)
 			break;
 		plist = get_next(plist);
 	}
@@ -458,7 +458,7 @@ int rtw_is_same_ibss(struct adapter *adapter, struct wlan_network *pnetwork)
 static int is_same_ess(struct wlan_bssid_ex *a, struct wlan_bssid_ex *b)
 {
 	return (a->Ssid.SsidLength == b->Ssid.SsidLength) &&
-	       _rtw_memcmp(a->Ssid.Ssid, b->Ssid.Ssid, a->Ssid.SsidLength);
+	       !memcmp(a->Ssid.Ssid, b->Ssid.Ssid, a->Ssid.SsidLength);
 }
 
 int is_same_network(struct wlan_bssid_ex *src, struct wlan_bssid_ex *dst)
@@ -477,8 +477,8 @@ _func_enter_;
 _func_exit_;
 
 	return ((src->Ssid.SsidLength == dst->Ssid.SsidLength) &&
-		((_rtw_memcmp(src->MacAddress, dst->MacAddress, ETH_ALEN)) == true) &&
-		((_rtw_memcmp(src->Ssid.Ssid, dst->Ssid.Ssid, src->Ssid.SsidLength)) == true) &&
+		((!memcmp(src->MacAddress, dst->MacAddress, ETH_ALEN)) == true) &&
+		((!memcmp(src->Ssid.Ssid, dst->Ssid.Ssid, src->Ssid.SsidLength)) == true) &&
 		((s_cap & WLAN_CAPABILITY_IBSS) ==
 		(d_cap & WLAN_CAPABILITY_IBSS)) &&
 		((s_cap & WLAN_CAPABILITY_BSS) ==
@@ -756,7 +756,7 @@ _func_enter_;
 
 	/*  update IBSS_network 's timestamp */
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) == true) {
-		if (_rtw_memcmp(&(pmlmepriv->cur_network.network.MacAddress), pnetwork->MacAddress, ETH_ALEN)) {
+		if (!memcmp(&(pmlmepriv->cur_network.network.MacAddress), pnetwork->MacAddress, ETH_ALEN)) {
 			struct wlan_network *ibss_wlan = NULL;
 
 			memcpy(pmlmepriv->cur_network.network.IEs, pnetwork->IEs, 8);
@@ -1218,7 +1218,7 @@ _func_enter_;
 	else
 		RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("@@@@@   rtw_joinbss_event_callback for SSid:%s\n", pmlmepriv->assoc_ssid.Ssid));
 
-	the_same_macaddr = _rtw_memcmp(pnetwork->network.MacAddress, cur_network->network.MacAddress, ETH_ALEN);
+	the_same_macaddr = !memcmp(pnetwork->network.MacAddress, cur_network->network.MacAddress, ETH_ALEN);
 
 	pnetwork->network.Length = get_wlan_bssid_ex_sz(&pnetwork->network);
 	if (pnetwork->network.Length > sizeof(struct wlan_bssid_ex)) {
@@ -1687,14 +1687,14 @@ static int rtw_check_join_candidate(struct mlme_priv *pmlmepriv
 
 	/* check bssid, if needed */
 	if (pmlmepriv->assoc_by_bssid) {
-		if (!_rtw_memcmp(competitor->network.MacAddress, pmlmepriv->assoc_bssid, ETH_ALEN))
+		if (memcmp(competitor->network.MacAddress, pmlmepriv->assoc_bssid, ETH_ALEN))
 			goto exit;
 	}
 
 	/* check ssid, if needed */
 	if (pmlmepriv->assoc_ssid.Ssid && pmlmepriv->assoc_ssid.SsidLength) {
 		if (competitor->network.Ssid.SsidLength != pmlmepriv->assoc_ssid.SsidLength ||
-		    _rtw_memcmp(competitor->network.Ssid.Ssid, pmlmepriv->assoc_ssid.Ssid, pmlmepriv->assoc_ssid.SsidLength) == false)
+		    !memcmp(competitor->network.Ssid.Ssid, pmlmepriv->assoc_ssid.Ssid, pmlmepriv->assoc_ssid.SsidLength) == false)
 			goto exit;
 	}
 
@@ -1964,7 +1964,7 @@ static int SecIsInPMKIDList(struct adapter *Adapter, u8 *bssid)
 
 	do {
 		if ((psecuritypriv->PMKIDList[i].bUsed) &&
-		    (_rtw_memcmp(psecuritypriv->PMKIDList[i].Bssid, bssid, ETH_ALEN) == true)) {
+		    (!memcmp(psecuritypriv->PMKIDList[i].Bssid, bssid, ETH_ALEN) == true)) {
 			break;
 		} else {
 			i++;
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 6f7e415..ce96586 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -421,8 +421,8 @@ static void _mgt_dispatcher(struct adapter *padapter, struct mlme_handler *ptabl
 
 	  if (ptable->func) {
 	 /* receive the frames that ra(a1) is my address or ra(a1) is bc address. */
-		if (!_rtw_memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN) &&
-		    !_rtw_memcmp(GetAddr1Ptr(pframe), bc_addr, ETH_ALEN))
+		if (memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN) &&
+		    memcmp(GetAddr1Ptr(pframe), bc_addr, ETH_ALEN))
 			return;
 		ptable->func(padapter, precv_frame);
 	}
@@ -449,8 +449,8 @@ void mgt_dispatcher(struct adapter *padapter, union recv_frame *precv_frame)
 	}
 
 	/* receive the frames that ra(a1) is my address or ra(a1) is bc address. */
-	if (!_rtw_memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN) &&
-	    !_rtw_memcmp(GetAddr1Ptr(pframe), bc_addr, ETH_ALEN))
+	if (memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN) &&
+	    memcmp(GetAddr1Ptr(pframe), bc_addr, ETH_ALEN))
 		return;
 
 	ptable = mlme_sta_tbl;
@@ -596,7 +596,7 @@ _continue:
 		if (is_valid_p2p_probereq)
 			goto _issue_probersp;
 
-		if ((ielen != 0 && !_rtw_memcmp((void *)(p+2), (void *)cur->Ssid.Ssid, cur->Ssid.SsidLength)) ||
+		if ((ielen != 0 && memcmp((void *)(p+2), (void *)cur->Ssid.Ssid, cur->Ssid.SsidLength)) ||
 		    (ielen == 0 && pmlmeinfo->hidden_ssid_mode))
 			return _SUCCESS;
 
@@ -620,7 +620,7 @@ unsigned int OnProbeRsp(struct adapter *padapter, union recv_frame *precv_frame)
 #ifdef CONFIG_88EU_P2P
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_TX_PROVISION_DIS_REQ)) {
 		if (pwdinfo->tx_prov_disc_info.benable) {
-			if (_rtw_memcmp(pwdinfo->tx_prov_disc_info.peerIFAddr, GetAddr2Ptr(pframe), ETH_ALEN)) {
+			if (!memcmp(pwdinfo->tx_prov_disc_info.peerIFAddr, GetAddr2Ptr(pframe), ETH_ALEN)) {
 				if (rtw_p2p_chk_role(pwdinfo, P2P_ROLE_CLIENT)) {
 					pwdinfo->tx_prov_disc_info.benable = false;
 					issue_p2p_provision_request(padapter,
@@ -638,7 +638,7 @@ unsigned int OnProbeRsp(struct adapter *padapter, union recv_frame *precv_frame)
 	} else if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_GONEGO_ING)) {
 		if (pwdinfo->nego_req_info.benable) {
 			DBG_88E("[%s] P2P State is GONEGO ING!\n", __func__);
-			if (_rtw_memcmp(pwdinfo->nego_req_info.peerDevAddr, GetAddr2Ptr(pframe), ETH_ALEN)) {
+			if (!memcmp(pwdinfo->nego_req_info.peerDevAddr, GetAddr2Ptr(pframe), ETH_ALEN)) {
 				pwdinfo->nego_req_info.benable = false;
 				issue_p2p_GO_request(padapter, pwdinfo->nego_req_info.peerDevAddr);
 			}
@@ -646,7 +646,7 @@ unsigned int OnProbeRsp(struct adapter *padapter, union recv_frame *precv_frame)
 	} else if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_TX_INVITE_REQ)) {
 		if (pwdinfo->invitereq_info.benable) {
 			DBG_88E("[%s] P2P_STATE_TX_INVITE_REQ!\n", __func__);
-			if (_rtw_memcmp(pwdinfo->invitereq_info.peer_macaddr, GetAddr2Ptr(pframe), ETH_ALEN)) {
+			if (!memcmp(pwdinfo->invitereq_info.peer_macaddr, GetAddr2Ptr(pframe), ETH_ALEN)) {
 				pwdinfo->invitereq_info.benable = false;
 				issue_p2p_invitation_request(padapter, pwdinfo->invitereq_info.peer_macaddr);
 			}
@@ -681,7 +681,7 @@ unsigned int OnBeacon(struct adapter *padapter, union recv_frame *precv_frame)
 		return _SUCCESS;
 	}
 
-	if (_rtw_memcmp(GetAddr3Ptr(pframe), get_my_bssid(&pmlmeinfo->network), ETH_ALEN)) {
+	if (!memcmp(GetAddr3Ptr(pframe), get_my_bssid(&pmlmeinfo->network), ETH_ALEN)) {
 		if (pmlmeinfo->state & WIFI_FW_AUTH_NULL) {
 			/* we should update current network before auth, or some IE is wrong */
 			pbss = (struct wlan_bssid_ex *)rtw_malloc(sizeof(struct wlan_bssid_ex));
@@ -878,7 +878,7 @@ unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
 				goto auth_fail;
 			}
 
-			if (_rtw_memcmp((void *)(p + 2), pstat->chg_txt, 128)) {
+			if (!memcmp((void *)(p + 2), pstat->chg_txt, 128)) {
 				pstat->state &= (~WIFI_FW_AUTH_STATE);
 				pstat->state |= WIFI_FW_AUTH_SUCCESS;
 				/*  challenging txt is correct... */
@@ -939,7 +939,7 @@ unsigned int OnAuthClient(struct adapter *padapter, union recv_frame *precv_fram
 	DBG_88E("%s\n", __func__);
 
 	/* check A1 matches or not */
-	if (!_rtw_memcmp(myid(&(padapter->eeprompriv)), get_da(pframe), ETH_ALEN))
+	if (memcmp(myid(&(padapter->eeprompriv)), get_da(pframe), ETH_ALEN))
 		return _SUCCESS;
 
 	if (!(pmlmeinfo->state & WIFI_FW_AUTH_STATE))
@@ -1097,7 +1097,7 @@ unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 		status = _STATS_FAILURE_;
 	} else {
 		/*  check if ssid match */
-		if (!_rtw_memcmp((void *)(p+2), cur->Ssid.Ssid, cur->Ssid.SsidLength))
+		if (memcmp((void *)(p+2), cur->Ssid.Ssid, cur->Ssid.SsidLength))
 			status = _STATS_FAILURE_;
 
 		if (ie_len != cur->Ssid.SsidLength)
@@ -1270,7 +1270,7 @@ unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 		for (;;) {
 			p = rtw_get_ie(p, _VENDOR_SPECIFIC_IE_, &ie_len, pkt_len - WLAN_HDR_A3_LEN - ie_offset);
 			if (p != NULL) {
-				if (_rtw_memcmp(p+2, WMM_IE, 6)) {
+				if (!memcmp(p+2, WMM_IE, 6)) {
 					pstat->flags |= WLAN_STA_WME;
 
 					pstat->qos_option = 1;
@@ -1486,7 +1486,7 @@ unsigned int OnAssocRsp(struct adapter *padapter, union recv_frame *precv_frame)
 	DBG_88E("%s\n", __func__);
 
 	/* check A1 matches or not */
-	if (!_rtw_memcmp(myid(&(padapter->eeprompriv)), get_da(pframe), ETH_ALEN))
+	if (memcmp(myid(&(padapter->eeprompriv)), get_da(pframe), ETH_ALEN))
 		return _SUCCESS;
 
 	if (!(pmlmeinfo->state & (WIFI_FW_AUTH_SUCCESS | WIFI_FW_ASSOC_STATE)))
@@ -1524,7 +1524,7 @@ unsigned int OnAssocRsp(struct adapter *padapter, union recv_frame *precv_frame)
 
 		switch (pIE->ElementID) {
 		case _VENDOR_SPECIFIC_IE_:
-			if (_rtw_memcmp(pIE->data, WMM_PARA_OUI, 6))	/* WMM */
+			if (!memcmp(pIE->data, WMM_PARA_OUI, 6)) /* WMM */
 				WMM_param_handler(padapter, pIE);
 			break;
 		case _HT_CAPABILITY_IE_:	/* HT caps */
@@ -1572,7 +1572,8 @@ unsigned int OnDeAuth(struct adapter *padapter, union recv_frame *precv_frame)
 #endif /* CONFIG_88EU_P2P */
 
 	/* check A3 */
-	if (!(_rtw_memcmp(GetAddr3Ptr(pframe), get_my_bssid(&pmlmeinfo->network), ETH_ALEN)))
+	if (memcmp(GetAddr3Ptr(pframe), get_my_bssid(&pmlmeinfo->network),
+		   ETH_ALEN))
 		return _SUCCESS;
 
 #ifdef CONFIG_88EU_P2P
@@ -1635,7 +1636,8 @@ unsigned int OnDisassoc(struct adapter *padapter, union recv_frame *precv_frame)
 #endif /* CONFIG_88EU_P2P */
 
 	/* check A3 */
-	if (!(_rtw_memcmp(GetAddr3Ptr(pframe), get_my_bssid(&pmlmeinfo->network), ETH_ALEN)))
+	if (memcmp(GetAddr3Ptr(pframe), get_my_bssid(&pmlmeinfo->network),
+		   ETH_ALEN))
 		return _SUCCESS;
 
 #ifdef CONFIG_88EU_P2P
@@ -1752,7 +1754,8 @@ unsigned int OnAction_back(struct adapter *padapter, union recv_frame *precv_fra
 	u8 *pframe = precv_frame->u.hdr.rx_data;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 	/* check RA matches or not */
-	if (!_rtw_memcmp(myid(&(padapter->eeprompriv)), GetAddr1Ptr(pframe), ETH_ALEN))/* for if1, sta/ap mode */
+	if (memcmp(myid(&(padapter->eeprompriv)), GetAddr1Ptr(pframe),
+		   ETH_ALEN))/* for if1, sta/ap mode */
 		return _SUCCESS;
 
 	DBG_88E("%s\n", __func__);
@@ -2280,7 +2283,7 @@ static void issue_p2p_GO_response(struct adapter *padapter, u8 *raddr, u8 *frame
 	/*	Commented by Kurt 20120113 */
 	/*	If some device wants to do p2p handshake without sending prov_disc_req */
 	/*	We have to get peer_req_cm from here. */
-	if (_rtw_memcmp(pwdinfo->rx_prov_disc_info.strconfig_method_desc_of_prov_disc_req, "000", 3)) {
+	if (!memcmp(pwdinfo->rx_prov_disc_info.strconfig_method_desc_of_prov_disc_req, "000", 3)) {
 		if (wps_devicepassword_id == WPS_DPID_USER_SPEC)
 			memcpy(pwdinfo->rx_prov_disc_info.strconfig_method_desc_of_prov_disc_req, "dis", 3);
 		else if (wps_devicepassword_id == WPS_DPID_REGISTRAR_SPEC)
@@ -2825,7 +2828,8 @@ void issue_p2p_invitation_request(struct adapter *padapter, u8 *raddr)
 	/*	Channel Number */
 	p2pie[p2pielen++] = pwdinfo->invitereq_info.operating_ch;	/*	operating channel number */
 
-	if (_rtw_memcmp(myid(&padapter->eeprompriv), pwdinfo->invitereq_info.go_bssid, ETH_ALEN)) {
+	if (!memcmp(myid(&padapter->eeprompriv),
+		    pwdinfo->invitereq_info.go_bssid, ETH_ALEN)) {
 		/*	P2P Group BSSID */
 		/*	Type: */
 		p2pie[p2pielen++] = P2P_ATTR_GROUP_BSSID;
@@ -3260,7 +3264,7 @@ static u8 is_matched_in_profilelist(u8 *peermacaddr, struct profile_info *profil
 	for (i = 0; i < P2P_MAX_PERSISTENT_GROUP_NUM; i++, profileinfo++) {
 	       DBG_88E("[%s] profileinfo_mac=%.2X %.2X %.2X %.2X %.2X %.2X\n", __func__,
 			    profileinfo->peermac[0], profileinfo->peermac[1], profileinfo->peermac[2], profileinfo->peermac[3], profileinfo->peermac[4], profileinfo->peermac[5]);
-		if (_rtw_memcmp(peermacaddr, profileinfo->peermac, ETH_ALEN)) {
+		if (!memcmp(peermacaddr, profileinfo->peermac, ETH_ALEN)) {
 			match_result = 1;
 			DBG_88E("[%s] Match!\n", __func__);
 			break;
@@ -3939,7 +3943,8 @@ static unsigned int on_action_public_p2p(union recv_frame *precv_frame)
 
 		/*	Commented by Kurt 20120113 */
 		/*	Get peer_dev_addr here if peer doesn't issue prov_disc frame. */
-		if (_rtw_memcmp(pwdinfo->rx_prov_disc_info.peerDevAddr, empty_addr, ETH_ALEN))
+		if (!memcmp(pwdinfo->rx_prov_disc_info.peerDevAddr, empty_addr,
+			    ETH_ALEN))
 			memcpy(pwdinfo->rx_prov_disc_info.peerDevAddr, GetAddr2Ptr(pframe), ETH_ALEN);
 
 		result = process_p2p_group_negotation_req(pwdinfo, frame_body, len);
@@ -4021,7 +4026,7 @@ static unsigned int on_action_public_p2p(union recv_frame *precv_frame)
 					_rtw_memset(&group_id, 0x00, sizeof(struct group_id_info));
 					rtw_get_p2p_attr_content(p2p_ie, p2p_ielen, P2P_ATTR_GROUP_ID, (u8 *)&group_id, &attr_contentlen);
 					if (attr_contentlen) {
-						if (_rtw_memcmp(group_id.go_device_addr, myid(&padapter->eeprompriv), ETH_ALEN)) {
+						if (!memcmp(group_id.go_device_addr, myid(&padapter->eeprompriv), ETH_ALEN)) {
 							/*	The p2p device sending this p2p invitation request wants this Wi-Fi device to be the persistent GO. */
 							rtw_p2p_set_state(pwdinfo, P2P_STATE_RECV_INVITE_REQ_GO);
 							rtw_p2p_set_role(pwdinfo, P2P_ROLE_GO);
@@ -4069,7 +4074,7 @@ static unsigned int on_action_public_p2p(union recv_frame *precv_frame)
 					_rtw_memset(&group_id, 0x00, sizeof(struct group_id_info));
 					rtw_get_p2p_attr_content(p2p_ie, p2p_ielen, P2P_ATTR_GROUP_ID, (u8 *)&group_id, &attr_contentlen);
 					if (attr_contentlen) {
-						if (_rtw_memcmp(group_id.go_device_addr, myid(&padapter->eeprompriv), ETH_ALEN)) {
+						if (!memcmp(group_id.go_device_addr, myid(&padapter->eeprompriv), ETH_ALEN)) {
 							/*	In this case, the GO can't be myself. */
 							rtw_p2p_set_state(pwdinfo, P2P_STATE_RECV_INVITE_REQ_DISMATCH);
 							status_code = P2P_STATUS_FAIL_INFO_UNAVAILABLE;
@@ -4116,7 +4121,7 @@ static unsigned int on_action_public_p2p(union recv_frame *precv_frame)
 				pwdinfo->invitereq_info.benable = false;
 
 				if (attr_content == P2P_STATUS_SUCCESS) {
-					if (_rtw_memcmp(pwdinfo->invitereq_info.go_bssid, myid(&padapter->eeprompriv), ETH_ALEN)) {
+					if (!memcmp(pwdinfo->invitereq_info.go_bssid, myid(&padapter->eeprompriv), ETH_ALEN)) {
 						rtw_p2p_set_role(pwdinfo, P2P_ROLE_GO);
 					} else {
 						rtw_p2p_set_role(pwdinfo, P2P_ROLE_CLIENT);
@@ -4181,9 +4186,8 @@ static unsigned int on_action_public_vendor(union recv_frame *precv_frame)
 	u8 *pframe = precv_frame->u.hdr.rx_data;
 	u8 *frame_body = pframe + sizeof(struct rtw_ieee80211_hdr_3addr);
 
-	if (_rtw_memcmp(frame_body + 2, P2P_OUI, 4) == true) {
+	if (!memcmp(frame_body + 2, P2P_OUI, 4) == true)
 		ret = on_action_public_p2p(precv_frame);
-	}
 
 	return ret;
 }
@@ -4214,7 +4218,7 @@ unsigned int on_action_public(struct adapter *padapter, union recv_frame *precv_
 	u8 category, action;
 
 	/* check RA matches or not */
-	if (!_rtw_memcmp(myid(&(padapter->eeprompriv)), GetAddr1Ptr(pframe), ETH_ALEN))
+	if (memcmp(myid(&(padapter->eeprompriv)), GetAddr1Ptr(pframe), ETH_ALEN))
 		goto exit;
 
 	category = frame_body[0];
@@ -4258,7 +4262,7 @@ unsigned int OnAction_p2p(struct adapter *padapter, union recv_frame *precv_fram
 	DBG_88E("%s\n", __func__);
 
 	/* check RA matches or not */
-	if (!_rtw_memcmp(myid(&(padapter->eeprompriv)), GetAddr1Ptr(pframe), ETH_ALEN))/* for if1, sta/ap mode */
+	if (memcmp(myid(&(padapter->eeprompriv)), GetAddr1Ptr(pframe), ETH_ALEN))/* for if1, sta/ap mode */
 		return _SUCCESS;
 
 	frame_body = (unsigned char *)(pframe + sizeof(struct rtw_ieee80211_hdr_3addr));
@@ -5234,7 +5238,7 @@ void issue_asocrsp(struct adapter *padapter, unsigned short status, struct sta_i
 
 		for (pbuf = ie + _BEACON_IE_OFFSET_;; pbuf += (ie_len + 2)) {
 			pbuf = rtw_get_ie(pbuf, _VENDOR_SPECIFIC_IE_, &ie_len, (pnetwork->IELength - _BEACON_IE_OFFSET_ - (ie_len + 2)));
-			if (pbuf && _rtw_memcmp(pbuf+2, WMM_PARA_IE, 6)) {
+			if (pbuf && !memcmp(pbuf+2, WMM_PARA_IE, 6)) {
 				memcpy(pframe, pbuf, ie_len+2);
 				pframe += (ie_len+2);
 				pattrib->pktlen += (ie_len+2);
@@ -5439,14 +5443,14 @@ void issue_assocreq(struct adapter *padapter)
 
 		switch (pIE->ElementID) {
 		case _VENDOR_SPECIFIC_IE_:
-			if ((_rtw_memcmp(pIE->data, RTW_WPA_OUI, 4)) ||
-			    (_rtw_memcmp(pIE->data, WMM_OUI, 4)) ||
-			    (_rtw_memcmp(pIE->data, WPS_OUI, 4))) {
+			if ((!memcmp(pIE->data, RTW_WPA_OUI, 4)) ||
+			    (!memcmp(pIE->data, WMM_OUI, 4)) ||
+			    (!memcmp(pIE->data, WPS_OUI, 4))) {
 				if (!padapter->registrypriv.wifi_spec) {
 					/* Commented by Kurt 20110629 */
 					/* In some older APs, WPS handshake */
 					/* would be fail if we append vender extensions informations to AP */
-					if (_rtw_memcmp(pIE->data, WPS_OUI, 4))
+					if (!memcmp(pIE->data, WPS_OUI, 4))
 						pIE->Length = 14;
 				}
 				pframe = rtw_set_ie(pframe, _VENDOR_SPECIFIC_IE_, pIE->Length, pIE->data, &(pattrib->pktlen));
@@ -6851,7 +6855,7 @@ unsigned int receive_disconnect(struct adapter *padapter, unsigned char *MacAddr
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 
 	/* check A3 */
-	if (!(_rtw_memcmp(MacAddr, get_my_bssid(&pmlmeinfo->network), ETH_ALEN)))
+	if (memcmp(MacAddr, get_my_bssid(&pmlmeinfo->network), ETH_ALEN))
 		return _SUCCESS;
 
 	DBG_88E("%s\n", __func__);
@@ -7902,7 +7906,7 @@ u8 join_cmd_hdl(struct adapter *padapter, u8 *pbuf)
 
 		switch (pIE->ElementID) {
 		case _VENDOR_SPECIFIC_IE_:/* Get WMM IE. */
-			if (_rtw_memcmp(pIE->data, WMM_OUI, 4))
+			if (!memcmp(pIE->data, WMM_OUI, 4))
 				pmlmeinfo->WMM_enable = 1;
 			break;
 		case _HT_CAPABILITY_IE_:	/* Get HT Cap IE. */
diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index 6e8c06e..4a9342d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -824,7 +824,7 @@ u32 process_probe_req_p2p_ie(struct wifidirect_info *pwdinfo, u8 *pframe, uint l
 	if (rtw_p2p_chk_role(pwdinfo, P2P_ROLE_DEVICE) || rtw_p2p_chk_role(pwdinfo, P2P_ROLE_GO)) {
 		p2pie = rtw_get_p2p_ie(pframe + WLAN_HDR_A3_LEN + _PROBEREQ_IE_OFFSET_ , len - WLAN_HDR_A3_LEN - _PROBEREQ_IE_OFFSET_ , NULL, &p2pielen);
 		if (p2pie) {
-			if ((p != NULL) && _rtw_memcmp((void *)(p+2), (void *)pwdinfo->p2p_wildcard_ssid , 7)) {
+			if ((p != NULL) && !memcmp((void *)(p+2), (void *)pwdinfo->p2p_wildcard_ssid , 7)) {
 				/* todo: */
 				/* Check Requested Device Type attributes in WSC IE. */
 				/* Check Device ID attribute in P2P IE */
@@ -972,8 +972,8 @@ u32 process_p2p_devdisc_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 		u32	attr_contentlen = 0;
 
 		if (rtw_get_p2p_attr_content(p2p_ie, p2p_ielen, P2P_ATTR_GROUP_ID, groupid, &attr_contentlen)) {
-			if (_rtw_memcmp(pwdinfo->device_addr, groupid, ETH_ALEN) &&
-			    _rtw_memcmp(pwdinfo->p2p_group_ssid, groupid+ETH_ALEN, pwdinfo->p2p_group_ssid_len)) {
+			if (!memcmp(pwdinfo->device_addr, groupid, ETH_ALEN) &&
+			    !memcmp(pwdinfo->p2p_group_ssid, groupid+ETH_ALEN, pwdinfo->p2p_group_ssid_len)) {
 				attr_contentlen = 0;
 				if (rtw_get_p2p_attr_content(p2p_ie, p2p_ielen, P2P_ATTR_DEVICE_ID, dev_addr, &attr_contentlen)) {
 					struct list_head *phead, *plist;
@@ -989,7 +989,7 @@ u32 process_p2p_devdisc_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 						plist = get_next(plist);
 
 						if (psta->is_p2p_device && (psta->dev_cap&P2P_DEVCAP_CLIENT_DISCOVERABILITY) &&
-						    _rtw_memcmp(psta->dev_addr, dev_addr, ETH_ALEN)) {
+						    !memcmp(psta->dev_addr, dev_addr, ETH_ALEN)) {
 							/* issue GO Discoverability Request */
 							issue_group_disc_req(pwdinfo, psta->hwaddr);
 							status = P2P_STATUS_SUCCESS;
@@ -1118,7 +1118,7 @@ u8 process_p2p_group_negotation_req(struct wifidirect_info *pwdinfo, u8 *pframe,
 		/*	Commented by Kurt 20120113 */
 		/*	If some device wants to do p2p handshake without sending prov_disc_req */
 		/*	We have to get peer_req_cm from here. */
-		if (_rtw_memcmp(pwdinfo->rx_prov_disc_info.strconfig_method_desc_of_prov_disc_req, "000", 3)) {
+		if (!memcmp(pwdinfo->rx_prov_disc_info.strconfig_method_desc_of_prov_disc_req, "000", 3)) {
 			rtw_get_wps_attr_content(wpsie, wps_ielen, WPS_ATTR_DEVICE_PWID, (u8 *)&be_tmp, &wps_devicepassword_id_len);
 			wps_devicepassword_id = be16_to_cpu(be_tmp);
 
@@ -2024,11 +2024,11 @@ int rtw_p2p_enable(struct adapter *padapter, enum P2P_ROLE role)
 
 		/* Disable P2P function */
 		if (!rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE)) {
-			_cancel_timer_ex(&pwdinfo->find_phase_timer);
-			_cancel_timer_ex(&pwdinfo->restore_p2p_state_timer);
-			_cancel_timer_ex(&pwdinfo->pre_tx_scan_timer);
-			_cancel_timer_ex(&pwdinfo->reset_ch_sitesurvey);
-			_cancel_timer_ex(&pwdinfo->reset_ch_sitesurvey2);
+			del_timer_sync(&pwdinfo->find_phase_timer);
+			del_timer_sync(&pwdinfo->restore_p2p_state_timer);
+			del_timer_sync(&pwdinfo->pre_tx_scan_timer);
+			del_timer_sync(&pwdinfo->reset_ch_sitesurvey);
+			del_timer_sync(&pwdinfo->reset_ch_sitesurvey2);
 			reset_ch_sitesurvey_timer_process(padapter);
 			reset_ch_sitesurvey_timer_process2(padapter);
 			rtw_p2p_set_state(pwdinfo, P2P_STATE_NONE);
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index ed308ff..7c5bfaf 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -783,20 +783,20 @@ _func_enter_;
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_STATE) == true) ||
 	    (check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE) == true)) {
 		/*  filter packets that SA is myself or multicast or broadcast */
-		if (_rtw_memcmp(myhwaddr, pattrib->src, ETH_ALEN)) {
+		if (!memcmp(myhwaddr, pattrib->src, ETH_ALEN)) {
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, (" SA==myself\n"));
 			ret = _FAIL;
 			goto exit;
 		}
 
-		if ((!_rtw_memcmp(myhwaddr, pattrib->dst, ETH_ALEN))	&& (!bmcast)) {
+		if ((memcmp(myhwaddr, pattrib->dst, ETH_ALEN)) && (!bmcast)) {
 			ret = _FAIL;
 			goto exit;
 		}
 
-		if (_rtw_memcmp(pattrib->bssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
-		    _rtw_memcmp(mybssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
-		    !_rtw_memcmp(pattrib->bssid, mybssid, ETH_ALEN)) {
+		if (!memcmp(pattrib->bssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
+		    !memcmp(mybssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
+		    memcmp(pattrib->bssid, mybssid, ETH_ALEN)) {
 			ret = _FAIL;
 			goto exit;
 		}
@@ -804,7 +804,7 @@ _func_enter_;
 		sta_addr = pattrib->src;
 	} else if (check_fwstate(pmlmepriv, WIFI_STATION_STATE)) {
 		/*  For Station mode, sa and bssid should always be BSSID, and DA is my mac-address */
-		if (!_rtw_memcmp(pattrib->bssid, pattrib->src, ETH_ALEN)) {
+		if (memcmp(pattrib->bssid, pattrib->src, ETH_ALEN)) {
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("bssid!=TA under STATION_MODE; drop pkt\n"));
 			ret = _FAIL;
 			goto exit;
@@ -819,7 +819,7 @@ _func_enter_;
 			}
 		} else { /*  not mc-frame */
 			/*  For AP mode, if DA is non-MCAST, then it must be BSSID, and bssid == BSSID */
-			if (!_rtw_memcmp(pattrib->bssid, pattrib->dst, ETH_ALEN)) {
+			if (memcmp(pattrib->bssid, pattrib->dst, ETH_ALEN)) {
 				ret = _FAIL;
 				goto exit;
 			}
@@ -878,14 +878,14 @@ _func_enter_;
 	    (check_fwstate(pmlmepriv, _FW_LINKED) == true ||
 	    check_fwstate(pmlmepriv, _FW_UNDER_LINKING))) {
 		/*  filter packets that SA is myself or multicast or broadcast */
-		if (_rtw_memcmp(myhwaddr, pattrib->src, ETH_ALEN)) {
+		if (!memcmp(myhwaddr, pattrib->src, ETH_ALEN)) {
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, (" SA==myself\n"));
 			ret = _FAIL;
 			goto exit;
 		}
 
 		/*  da should be for me */
-		if ((!_rtw_memcmp(myhwaddr, pattrib->dst, ETH_ALEN)) && (!bmcast)) {
+		if ((memcmp(myhwaddr, pattrib->dst, ETH_ALEN)) && (!bmcast)) {
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_,
 				 (" ap2sta_data_frame:  compare DA fail; DA=%pM\n", (pattrib->dst)));
 			ret = _FAIL;
@@ -893,9 +893,9 @@ _func_enter_;
 		}
 
 		/*  check BSSID */
-		if (_rtw_memcmp(pattrib->bssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
-		    _rtw_memcmp(mybssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
-		     (!_rtw_memcmp(pattrib->bssid, mybssid, ETH_ALEN))) {
+		if (!memcmp(pattrib->bssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
+		    !memcmp(mybssid, "\x0\x0\x0\x0\x0\x0", ETH_ALEN) ||
+		     (memcmp(pattrib->bssid, mybssid, ETH_ALEN))) {
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_,
 				 (" ap2sta_data_frame:  compare BSSID fail ; BSSID=%pM\n", (pattrib->bssid)));
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("mybssid=%pM\n", (mybssid)));
@@ -951,7 +951,7 @@ _func_enter_;
 		ret = RTW_RX_HANDLED;
 		goto exit;
 	} else {
-		if (_rtw_memcmp(myhwaddr, pattrib->dst, ETH_ALEN) && (!bmcast)) {
+		if (!memcmp(myhwaddr, pattrib->dst, ETH_ALEN) && (!bmcast)) {
 			*psta = rtw_get_stainfo(pstapriv, pattrib->bssid); /*  get sta_info */
 			if (*psta == NULL) {
 				DBG_88E("issue_deauth to the ap =%pM for the reason(7)\n", (pattrib->bssid));
@@ -985,7 +985,7 @@ _func_enter_;
 
 	if (check_fwstate(pmlmepriv, WIFI_AP_STATE) == true) {
 		/* For AP mode, RA = BSSID, TX = STA(SRC_ADDR), A3 = DST_ADDR */
-		if (!_rtw_memcmp(pattrib->bssid, mybssid, ETH_ALEN)) {
+		if (memcmp(pattrib->bssid, mybssid, ETH_ALEN)) {
 			ret = _FAIL;
 			goto exit;
 		}
@@ -1015,7 +1015,7 @@ _func_enter_;
 		}
 	} else {
 		u8 *myhwaddr = myid(&adapter->eeprompriv);
-		if (!_rtw_memcmp(pattrib->ra, myhwaddr, ETH_ALEN)) {
+		if (memcmp(pattrib->ra, myhwaddr, ETH_ALEN)) {
 			ret = RTW_RX_HANDLED;
 			goto exit;
 		}
@@ -1045,7 +1045,7 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 		return _FAIL;
 
 	/* receive the frames that ra(a1) is my address */
-	if (!_rtw_memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN))
+	if (memcmp(GetAddr1Ptr(pframe), myid(&padapter->eeprompriv), ETH_ALEN))
 		return _FAIL;
 
 	/* only handle ps-poll */
@@ -1182,7 +1182,7 @@ static int validate_recv_mgnt_frame(struct adapter *padapter,
 		} else if (GetFrameSubType(precv_frame->u.hdr.rx_data) == WIFI_PROBEREQ) {
 			psta->sta_stats.rx_probereq_pkts++;
 		} else if (GetFrameSubType(precv_frame->u.hdr.rx_data) == WIFI_PROBERSP) {
-			if (_rtw_memcmp(padapter->eeprompriv.mac_addr, GetAddr1Ptr(precv_frame->u.hdr.rx_data), ETH_ALEN) == true)
+			if (!memcmp(padapter->eeprompriv.mac_addr, GetAddr1Ptr(precv_frame->u.hdr.rx_data), ETH_ALEN) == true)
 				psta->sta_stats.rx_probersp_pkts++;
 			else if (is_broadcast_mac_addr(GetAddr1Ptr(precv_frame->u.hdr.rx_data)) ||
 				 is_multicast_mac_addr(GetAddr1Ptr(precv_frame->u.hdr.rx_data)))
@@ -1454,10 +1454,10 @@ _func_enter_;
 	psnap = (struct ieee80211_snap_hdr *)(ptr+pattrib->hdrlen + pattrib->iv_len);
 	psnap_type = ptr+pattrib->hdrlen + pattrib->iv_len+SNAP_SIZE;
 	/* convert hdr + possible LLC headers into Ethernet header */
-	if ((_rtw_memcmp(psnap, rtw_rfc1042_header, SNAP_SIZE) &&
-	     (_rtw_memcmp(psnap_type, SNAP_ETH_TYPE_IPX, 2) == false) &&
-	     (_rtw_memcmp(psnap_type, SNAP_ETH_TYPE_APPLETALK_AARP, 2) == false)) ||
-	    _rtw_memcmp(psnap, rtw_bridge_tunnel_header, SNAP_SIZE)) {
+	if ((!memcmp(psnap, rtw_rfc1042_header, SNAP_SIZE) &&
+	     (!memcmp(psnap_type, SNAP_ETH_TYPE_IPX, 2) == false) &&
+	     (!memcmp(psnap_type, SNAP_ETH_TYPE_APPLETALK_AARP, 2) == false)) ||
+	     !memcmp(psnap, rtw_bridge_tunnel_header, SNAP_SIZE)) {
 		/* remove RFC1042 or Bridge-Tunnel encapsulation and replace EtherType */
 		bsnaphdr = true;
 	} else {
@@ -1769,9 +1769,9 @@ static int amsdu_to_msdu(struct adapter *padapter, union recv_frame *prframe)
 		/* convert hdr + possible LLC headers into Ethernet header */
 		eth_type = RTW_GET_BE16(&sub_skb->data[6]);
 		if (sub_skb->len >= 8 &&
-		    ((_rtw_memcmp(sub_skb->data, rtw_rfc1042_header, SNAP_SIZE) &&
+		    ((!memcmp(sub_skb->data, rtw_rfc1042_header, SNAP_SIZE) &&
 			  eth_type != ETH_P_AARP && eth_type != ETH_P_IPX) ||
-			 _rtw_memcmp(sub_skb->data, rtw_bridge_tunnel_header, SNAP_SIZE))) {
+			 !memcmp(sub_skb->data, rtw_bridge_tunnel_header, SNAP_SIZE))) {
 			/* remove RFC1042 or Bridge-Tunnel encapsulation and replace EtherType */
 			skb_pull(sub_skb, SNAP_SIZE);
 			memcpy(skb_push(sub_skb, ETH_ALEN), pattrib->src, ETH_ALEN);
@@ -2002,7 +2002,7 @@ static int recv_indicatepkt_reorder(struct adapter *padapter, union recv_frame *
 		spin_unlock_bh(&ppending_recvframe_queue->lock);
 	} else {
 		spin_unlock_bh(&ppending_recvframe_queue->lock);
-		_cancel_timer_ex(&preorder_ctrl->reordering_ctrl_timer);
+		del_timer_sync(&preorder_ctrl->reordering_ctrl_timer);
 	}
 
 _success_exit:
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index e8a654d..0441bcc 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -199,7 +199,7 @@ _func_enter_;
 
 				for (i = 0; i < 16; i++) {
 					preorder_ctrl = &psta->recvreorder_ctrl[i];
-					_cancel_timer_ex(&preorder_ctrl->reordering_ctrl_timer);
+					del_timer_sync(&preorder_ctrl->reordering_ctrl_timer);
 				}
 			}
 		}
@@ -354,7 +354,7 @@ _func_enter_;
 	_rtw_init_sta_xmit_priv(&psta->sta_xmitpriv);
 	_rtw_init_sta_recv_priv(&psta->sta_recvpriv);
 
-	_cancel_timer_ex(&psta->addba_retry_timer);
+	del_timer_sync(&psta->addba_retry_timer);
 
 	/* for A-MPDU Rx reordering buffer control, cancel reordering_ctrl_timer */
 	for (i = 0; i < 16; i++) {
@@ -365,7 +365,7 @@ _func_enter_;
 
 		preorder_ctrl = &psta->recvreorder_ctrl[i];
 
-		_cancel_timer_ex(&preorder_ctrl->reordering_ctrl_timer);
+		del_timer_sync(&preorder_ctrl->reordering_ctrl_timer);
 
 		ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
 
@@ -500,7 +500,7 @@ _func_enter_;
 	while ((!rtw_end_of_queue_search(phead, plist))) {
 		psta = LIST_CONTAINOR(plist, struct sta_info, hash_list);
 
-		if ((_rtw_memcmp(psta->hwaddr, addr, ETH_ALEN)) == true) {
+		if ((!memcmp(psta->hwaddr, addr, ETH_ALEN)) == true) {
 			/*  if found the matched address */
 			break;
 		}
@@ -567,7 +567,7 @@ u8 rtw_access_ctrl(struct adapter *padapter, u8 *mac_addr)
 		paclnode = LIST_CONTAINOR(plist, struct rtw_wlan_acl_node, list);
 		plist = get_next(plist);
 
-		if (_rtw_memcmp(paclnode->addr, mac_addr, ETH_ALEN)) {
+		if (!memcmp(paclnode->addr, mac_addr, ETH_ALEN)) {
 			if (paclnode->valid) {
 				match = true;
 				break;
diff --git a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
index 96df62f..2c8d58d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
+++ b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
@@ -929,7 +929,7 @@ int rtw_check_bcn_info(struct adapter  *Adapter, u8 *pframe, u32 packet_len)
 		return _FAIL;
 	}
 
-	if (_rtw_memcmp(cur_network->network.MacAddress, pbssid, 6) == false) {
+	if (!memcmp(cur_network->network.MacAddress, pbssid, 6) == false) {
 		DBG_88E("Oops: rtw_check_network_encrypt linked but recv other bssid bcn\n%pM %pM\n",
 			(pbssid), (cur_network->network.MacAddress));
 		return true;
@@ -1014,7 +1014,7 @@ int rtw_check_bcn_info(struct adapter  *Adapter, u8 *pframe, u32 packet_len)
 				bssid->Ssid.SsidLength, cur_network->network.Ssid.Ssid,
 				cur_network->network.Ssid.SsidLength));
 
-	if (!_rtw_memcmp(bssid->Ssid.Ssid, cur_network->network.Ssid.Ssid, 32) ||
+	if (memcmp(bssid->Ssid.Ssid, cur_network->network.Ssid.Ssid, 32) ||
 	    bssid->Ssid.SsidLength != cur_network->network.Ssid.SsidLength) {
 		if (bssid->Ssid.Ssid[0] != '\0' && bssid->Ssid.SsidLength != 0) { /* not hidden ssid */
 			DBG_88E("%s(), SSID is not match return FAIL\n", __func__);
@@ -1141,11 +1141,11 @@ unsigned int is_ap_in_tkip(struct adapter *padapter)
 
 			switch (pIE->ElementID) {
 			case _VENDOR_SPECIFIC_IE_:
-				if ((_rtw_memcmp(pIE->data, RTW_WPA_OUI, 4)) && (_rtw_memcmp((pIE->data + 12), WPA_TKIP_CIPHER, 4)))
+				if ((!memcmp(pIE->data, RTW_WPA_OUI, 4)) && (!memcmp((pIE->data + 12), WPA_TKIP_CIPHER, 4)))
 					return true;
 				break;
 			case _RSN_IE_2_:
-				if (_rtw_memcmp((pIE->data + 8), RSN_TKIP_CIPHER, 4))
+				if (!memcmp((pIE->data + 8), RSN_TKIP_CIPHER, 4))
 					return true;
 			default:
 				break;
@@ -1172,14 +1172,14 @@ unsigned int should_forbid_n_rate(struct adapter *padapter)
 
 			switch (pIE->ElementID) {
 			case _VENDOR_SPECIFIC_IE_:
-				if (_rtw_memcmp(pIE->data, RTW_WPA_OUI, 4) &&
-				    ((_rtw_memcmp((pIE->data + 12), WPA_CIPHER_SUITE_CCMP, 4)) ||
-				    (_rtw_memcmp((pIE->data + 16), WPA_CIPHER_SUITE_CCMP, 4))))
+				if (!memcmp(pIE->data, RTW_WPA_OUI, 4) &&
+				    ((!memcmp((pIE->data + 12), WPA_CIPHER_SUITE_CCMP, 4)) ||
+				    (!memcmp((pIE->data + 16), WPA_CIPHER_SUITE_CCMP, 4))))
 					return false;
 				break;
 			case _RSN_IE_2_:
-				if  ((_rtw_memcmp((pIE->data + 8), RSN_CIPHER_SUITE_CCMP, 4))  ||
-				       (_rtw_memcmp((pIE->data + 12), RSN_CIPHER_SUITE_CCMP, 4)))
+				if  ((!memcmp((pIE->data + 8), RSN_CIPHER_SUITE_CCMP, 4))  ||
+				       (!memcmp((pIE->data + 12), RSN_CIPHER_SUITE_CCMP, 4)))
 					return false;
 			default:
 				break;
@@ -1208,7 +1208,7 @@ unsigned int is_ap_in_wep(struct adapter *padapter)
 
 			switch (pIE->ElementID) {
 			case _VENDOR_SPECIFIC_IE_:
-				if (_rtw_memcmp(pIE->data, RTW_WPA_OUI, 4))
+				if (!memcmp(pIE->data, RTW_WPA_OUI, 4))
 					return false;
 				break;
 			case _RSN_IE_2_:
@@ -1400,35 +1400,35 @@ unsigned char check_assoc_AP(u8 *pframe, uint len)
 
 		switch (pIE->ElementID) {
 		case _VENDOR_SPECIFIC_IE_:
-			if ((_rtw_memcmp(pIE->data, ARTHEROS_OUI1, 3)) ||
-			    (_rtw_memcmp(pIE->data, ARTHEROS_OUI2, 3))) {
+			if ((!memcmp(pIE->data, ARTHEROS_OUI1, 3)) ||
+			    (!memcmp(pIE->data, ARTHEROS_OUI2, 3))) {
 				DBG_88E("link to Artheros AP\n");
 				return HT_IOT_PEER_ATHEROS;
-			} else if ((_rtw_memcmp(pIE->data, BROADCOM_OUI1, 3)) ||
-				   (_rtw_memcmp(pIE->data, BROADCOM_OUI2, 3)) ||
-				   (_rtw_memcmp(pIE->data, BROADCOM_OUI2, 3))) {
+			} else if ((!memcmp(pIE->data, BROADCOM_OUI1, 3)) ||
+				   (!memcmp(pIE->data, BROADCOM_OUI2, 3)) ||
+				   (!memcmp(pIE->data, BROADCOM_OUI2, 3))) {
 				DBG_88E("link to Broadcom AP\n");
 				return HT_IOT_PEER_BROADCOM;
-			} else if (_rtw_memcmp(pIE->data, MARVELL_OUI, 3)) {
+			} else if (!memcmp(pIE->data, MARVELL_OUI, 3)) {
 				DBG_88E("link to Marvell AP\n");
 				return HT_IOT_PEER_MARVELL;
-			} else if (_rtw_memcmp(pIE->data, RALINK_OUI, 3)) {
+			} else if (!memcmp(pIE->data, RALINK_OUI, 3)) {
 				if (!ralink_vendor_flag) {
 					ralink_vendor_flag = 1;
 				} else {
 					DBG_88E("link to Ralink AP\n");
 					return HT_IOT_PEER_RALINK;
 				}
-			} else if (_rtw_memcmp(pIE->data, CISCO_OUI, 3)) {
+			} else if (!memcmp(pIE->data, CISCO_OUI, 3)) {
 				DBG_88E("link to Cisco AP\n");
 				return HT_IOT_PEER_CISCO;
-			} else if (_rtw_memcmp(pIE->data, REALTEK_OUI, 3)) {
+			} else if (!memcmp(pIE->data, REALTEK_OUI, 3)) {
 				DBG_88E("link to Realtek 96B\n");
 				return HT_IOT_PEER_REALTEK;
-			} else if (_rtw_memcmp(pIE->data, AIRGOCAP_OUI, 3)) {
+			} else if (!memcmp(pIE->data, AIRGOCAP_OUI, 3)) {
 				DBG_88E("link to Airgo Cap\n");
 				return HT_IOT_PEER_AIRGO;
-			} else if (_rtw_memcmp(pIE->data, EPIGRAM_OUI, 3)) {
+			} else if (!memcmp(pIE->data, EPIGRAM_OUI, 3)) {
 				epigram_vendor_flag = 1;
 				if (ralink_vendor_flag) {
 					DBG_88E("link to Tenda W311R AP\n");
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 2c0a40f..be35db6 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -677,12 +677,12 @@ _func_enter_;
 			pframe = pxmitframe->buf_addr + hw_hdr_offset;
 
 			if (bmcst) {
-				if (_rtw_memcmp(psecuritypriv->dot118021XGrptxmickey[psecuritypriv->dot118021XGrpKeyid].skey, null_key, 16))
+				if (!memcmp(psecuritypriv->dot118021XGrptxmickey[psecuritypriv->dot118021XGrpKeyid].skey, null_key, 16))
 					return _FAIL;
 				/* start to calculate the mic code */
 				rtw_secmicsetkey(&micdata, psecuritypriv->dot118021XGrptxmickey[psecuritypriv->dot118021XGrpKeyid].skey);
 			} else {
-				if (_rtw_memcmp(&stainfo->dot11tkiptxmickey.skey[0], null_key, 16) == true) {
+				if (!memcmp(&stainfo->dot11tkiptxmickey.skey[0], null_key, 16) == true) {
 					/* DbgPrint("\nxmitframe_addmic:stainfo->dot11tkiptxmickey == 0\n"); */
 					/* msleep(10); */
 					return _FAIL;
diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 4b5caa1..056052d 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -217,7 +217,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 
 		for (i = 0; i < CCK_TABLE_SIZE; i++) {
 			if (dm_odm->RFCalibrateInfo.bCCKinCH14) {
-				if (_rtw_memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch14[i][2], 4) == 0) {
+				if (memcmp(&TempCCk, &CCKSwingTable_Ch14[i][2], 4)) {
 					CCK_index_old = (u8)i;
 					dm_odm->BbSwingIdxCckBase = (u8)i;
 					ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
@@ -229,7 +229,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 				ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 					     ("RegA24: 0x%X, CCKSwingTable_Ch1_Ch13[%d][2]: CCKSwingTable_Ch1_Ch13[i][2]: 0x%X\n",
 					     TempCCk, i, CCKSwingTable_Ch1_Ch13[i][2]));
-				if (_rtw_memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch1_Ch13[i][2], 4) == 0) {
+				if (memcmp(&TempCCk, &CCKSwingTable_Ch1_Ch13[i][2], 4)) {
 					CCK_index_old = (u8)i;
 					dm_odm->BbSwingIdxCckBase = (u8)i;
 					ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index fc05e48..89a26e3 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -1302,8 +1302,8 @@ void odm_RSSIMonitorCheckCE(struct odm_dm_struct *pDM_Odm)
 		psta = pDM_Odm->pODM_StaInfo[i];
 		if (IS_STA_VALID(psta) &&
 		    (psta->state & WIFI_ASOC_STATE) &&
-		    !_rtw_memcmp(psta->hwaddr, bcast_addr, ETH_ALEN) &&
-		    !_rtw_memcmp(psta->hwaddr, myid(&Adapter->eeprompriv), ETH_ALEN)) {
+		    memcmp(psta->hwaddr, bcast_addr, ETH_ALEN) &&
+		    memcmp(psta->hwaddr, myid(&Adapter->eeprompriv), ETH_ALEN)) {
 			if (psta->rssi_stat.UndecoratedSmoothedPWDB < tmpEntryMinPWDB)
 				tmpEntryMinPWDB = psta->rssi_stat.UndecoratedSmoothedPWDB;
 
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 710f8e1..8b13789 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -1,34 +1 @@
-/******************************************************************************
- *
- * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
- *
- ******************************************************************************/
 
-#include "odm_precomp.h"
-
-void ODM_CancelTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer)
-{
-	_cancel_timer_ex(pTimer);
-}
-
-/*  ODM FW relative API. */
-u32 ODM_FillH2CCmd(u8 *pH2CBuffer, u32 H2CBufferLen, u32 CmdNum,
-		      u32 *pElementID, u32 *pCmdLen,
-		      u8 **pCmbBuffer, u8 *CmdStartSeq)
-{
-	return	true;
-}
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
index f29c003..5248995 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -20,6 +20,7 @@
 #define _HAL_INIT_C_
 
 #include <linux/firmware.h>
+#include <linux/vmalloc.h>
 #include <drv_types.h>
 #include <rtw_efuse.h>
 
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
index 3d0e6c9..cd2027b 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
@@ -184,12 +184,12 @@ void Hal_MPT_CCKTxPowerAdjustbyIndex(struct adapter *pAdapter, bool beven)
 		TempCCk = read_bbreg(pAdapter, rCCK0_TxFilter2, bMaskDWord) & bMaskCCK;
 		for (i = 0; i < CCK_TABLE_SIZE; i++) {
 			if (pDM_Odm->RFCalibrateInfo.bCCKinCH14) {
-				if (_rtw_memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch14[i][2], 4)) {
+				if (!memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch14[i][2], 4)) {
 					CCK_index_old = (u8)i;
 					break;
 				}
 			} else {
-				if (_rtw_memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch1_Ch13[i][2], 4)) {
+				if (!memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch1_Ch13[i][2], 4)) {
 					CCK_index_old = (u8)i;
 					break;
 				}
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c b/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
index 511f61c..4e36306 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
@@ -158,11 +158,11 @@ void update_recvframe_phyinfo_88e(union recv_frame *precvframe, struct phy_stat
 
 	pkt_info.bPacketMatchBSSID = ((!IsFrameTypeCtrl(wlanhdr)) &&
 		!pattrib->icv_err && !pattrib->crc_err &&
-		_rtw_memcmp(get_hdr_bssid(wlanhdr),
+		!memcmp(get_hdr_bssid(wlanhdr),
 		 get_bssid(&padapter->mlmepriv), ETH_ALEN));
 
 	pkt_info.bPacketToSelf = pkt_info.bPacketMatchBSSID &&
-				 (_rtw_memcmp(get_da(wlanhdr),
+				 (!memcmp(get_da(wlanhdr),
 				  myid(&padapter->eeprompriv), ETH_ALEN));
 
 	pkt_info.bPacketBeacon = pkt_info.bPacketMatchBSSID &&
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 495420e..e726ff8 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -241,7 +241,6 @@ void *rtw_malloc2d(int h, int w, int size);
 void rtw_mfree2d(void *pbuf, int h, int w, int size);
 
 void _rtw_memcpy(void *dec, void *sour, u32 sz);
-int  _rtw_memcmp(void *dst, void *src, u32 sz);
 void _rtw_memset(void *pbuf, int c, u32 sz);
 
 void _rtw_init_listhead(struct list_head *list);
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 622b70c..2579a40 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -93,16 +93,6 @@ void rtw_mfree2d(void *pbuf, int h, int w, int size)
 	kfree(pbuf);
 }
 
-int _rtw_memcmp(void *dst, void *src, u32 sz)
-{
-/* under Linux/GNU/GLibc, the return value of memcmp for two same
- * mem. chunk is 0 */
-	if (!(memcmp(dst, src, sz)))
-		return true;
-	else
-		return false;
-}
-
 void _rtw_memset(void *pbuf, int c, u32 sz)
 {
 	memset(pbuf, c, sz);
diff --git a/drivers/staging/rtl8188eu/os_dep/recv_linux.c b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
index 2a18b32..989b7f1 100644
--- a/drivers/staging/rtl8188eu/os_dep/recv_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
@@ -170,8 +170,8 @@ _func_enter_;
 		struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
 		int bmcast = IS_MCAST(pattrib->dst);
 
-		if (!_rtw_memcmp(pattrib->dst, myid(&padapter->eeprompriv),
-				 ETH_ALEN)) {
+		if (memcmp(pattrib->dst, myid(&padapter->eeprompriv),
+			   ETH_ALEN)) {
 			if (bmcast) {
 				psta = rtw_get_bcmc_stainfo(padapter);
 				pskb2 = skb_clone(skb, GFP_ATOMIC);
-- 
1.8.4.5
