From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 08/11] staging: r8188eu: Replace rtw_get_current_time() with jiffies
Date: Thu, 19 Dec 2013 22:38:40 -0600
Message-ID: <1387514323-4486-9-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:63060 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab3LTElP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:41:15 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so2011580pdj.26
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:41:15 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          |  6 +++---
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c    |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 14 +++++++-------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 12 ++++++------
 drivers/staging/rtl8188eu/core/rtw_p2p.c          |  2 +-
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c      | 18 +++++++++---------
 drivers/staging/rtl8188eu/core/rtw_xmit.c         |  4 ++--
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c |  6 +++---
 drivers/staging/rtl8188eu/hal/rtl8188e_sreset.c   |  2 +-
 drivers/staging/rtl8188eu/hal/usb_halinit.c       |  4 ++--
 drivers/staging/rtl8188eu/include/osdep_service.h |  1 -
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       |  4 ++--
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  |  8 +-------
 drivers/staging/rtl8188eu/os_dep/recv_linux.c     |  6 +++---
 drivers/staging/rtl8188eu/os_dep/usb_intf.c       |  4 ++--
 drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c  |  4 ++--
 16 files changed, 46 insertions(+), 53 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index 64e29a9..73cb2be 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -529,7 +529,7 @@ _func_enter_;
 	res = rtw_enqueue_cmd(pcmdpriv, ph2c);
 
 	if (res == _SUCCESS) {
-		pmlmepriv->scan_start_time = rtw_get_current_time();
+		pmlmepriv->scan_start_time = jiffies;
 
 		_set_timer(&pmlmepriv->scan_to_timer, SCANNING_TIMEOUT);
 
@@ -1717,7 +1717,7 @@ _func_enter_;
 		break;
 	case LPS_CTRL_SPECIAL_PACKET:
 		/* DBG_88E("LPS_CTRL_SPECIAL_PACKET\n"); */
-		pwrpriv->DelayLPSLastTimeStamp = rtw_get_current_time();
+		pwrpriv->DelayLPSLastTimeStamp = jiffies;
 		LPS_Leave(padapter);
 		break;
 	case LPS_CTRL_LEAVE:
@@ -2279,7 +2279,7 @@ _func_enter_;
 				spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 				goto createbss_cmd_fail;
 			}
-			pwlan->last_scanned = rtw_get_current_time();
+			pwlan->last_scanned = jiffies;
 		} else {
 			rtw_list_insert_tail(&(pwlan->list), &pmlmepriv->scanned_queue.queue);
 		}
diff --git a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
index 7b54c1e..e25b39b 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
@@ -231,7 +231,7 @@ handle_tkip_countermeasure:
 	/* should we add something here...? */
 
 	if (padapter->securitypriv.btkip_countermeasure) {
-		cur_time = rtw_get_current_time();
+		cur_time = jiffies;
 
 		if ((cur_time - padapter->securitypriv.btkip_countermeasure_time) > 60 * HZ) {
 			padapter->securitypriv.btkip_countermeasure = false;
@@ -343,7 +343,7 @@ _func_enter_;
 handle_tkip_countermeasure:
 
 	if (padapter->securitypriv.btkip_countermeasure) {
-		cur_time = rtw_get_current_time();
+		cur_time = jiffies;
 
 		if ((cur_time - padapter->securitypriv.btkip_countermeasure_time) > 60 * HZ) {
 			padapter->securitypriv.btkip_countermeasure = false;
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 3ac632c..6078d03 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -202,7 +202,7 @@ _func_enter_;
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("_rtw_alloc_network: ptr=%p\n", plist));
 	pnetwork->network_type = 0;
 	pnetwork->fixed = false;
-	pnetwork->last_scanned = rtw_get_current_time();
+	pnetwork->last_scanned = jiffies;
 	pnetwork->aid = 0;
 	pnetwork->join_res = 0;
 
@@ -229,7 +229,7 @@ _func_enter_;
 
 	if (pnetwork->fixed)
 		goto exit;
-	curr_time = rtw_get_current_time();
+	curr_time = jiffies;
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) ||
 	    (check_fwstate(pmlmepriv, WIFI_ADHOC_STATE)))
 		lifetime = 1;
@@ -345,7 +345,7 @@ _func_exit_;
 
 void rtw_generate_random_ibss(u8 *pibss)
 {
-	u32	curtime = rtw_get_current_time();
+	u32	curtime = jiffies;
 
 _func_enter_;
 	pibss[0] = 0x02;  /* in ad-hoc mode bit1 must set to 1 */
@@ -613,7 +613,7 @@ _func_enter_;
 			memcpy(&(pnetwork->network), target,  get_wlan_bssid_ex_sz(target));
 			/*  variable initialize */
 			pnetwork->fixed = false;
-			pnetwork->last_scanned = rtw_get_current_time();
+			pnetwork->last_scanned = jiffies;
 
 			pnetwork->network_type = 0;
 			pnetwork->aid = 0;
@@ -637,7 +637,7 @@ _func_enter_;
 			rtw_hal_get_def_var(adapter, HAL_DEF_CURRENT_ANTENNA, &(target->PhyInfo.Optimum_antenna));
 			memcpy(&(pnetwork->network), target, bssid_ex_sz);
 
-			pnetwork->last_scanned = rtw_get_current_time();
+			pnetwork->last_scanned = jiffies;
 
 			/* bss info not receiving from the right channel */
 			if (pnetwork->network.PhyInfo.SignalQuality == 101)
@@ -651,7 +651,7 @@ _func_enter_;
 		 */
 		bool update_ie = true;
 
-		pnetwork->last_scanned = rtw_get_current_time();
+		pnetwork->last_scanned = jiffies;
 
 		/* target.Reserved[0]== 1, means that scanned network is a bcn frame. */
 		if ((pnetwork->network.IELength > target->IELength) && (target->Reserved[0] == 1))
@@ -1053,7 +1053,7 @@ void rtw_scan_abort(struct adapter *adapter)
 	struct mlme_priv	*pmlmepriv = &(adapter->mlmepriv);
 	struct mlme_ext_priv	*pmlmeext = &(adapter->mlmeextpriv);
 
-	start = rtw_get_current_time();
+	start = jiffies;
 	pmlmeext->scan_abort = true;
 	while (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY) &&
 	       rtw_get_passing_time_ms(start) <= 200) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 5f1df23..bada209 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -3822,7 +3822,7 @@ int issue_probereq_p2p_ex(struct adapter *adapter, u8 *da, int try_cnt, int wait
 {
 	int ret;
 	int i = 0;
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 
 	do {
 		ret = _issue_probereq_p2p(adapter, da, wait_ms > 0 ? true : false);
@@ -4968,7 +4968,7 @@ int issue_probereq_ex(struct adapter *padapter, struct ndis_802_11_ssid *pssid,
 {
 	int ret;
 	int i = 0;
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 
 	do {
 		ret = _issue_probereq(padapter, pssid, da, wait_ms > 0 ? true : false);
@@ -5689,7 +5689,7 @@ int issue_nulldata(struct adapter *padapter, unsigned char *da, unsigned int pow
 {
 	int ret;
 	int i = 0;
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 
@@ -5812,7 +5812,7 @@ int issue_qos_nulldata(struct adapter *padapter, unsigned char *da, u16 tid, int
 {
 	int ret;
 	int i = 0;
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 
@@ -5930,7 +5930,7 @@ int issue_deauth_ex(struct adapter *padapter, u8 *da, unsigned short reason, int
 {
 	int ret;
 	int i = 0;
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 
 	do {
 		ret = _issue_deauth(padapter, da, reason, wait_ms > 0 ? true : false);
@@ -6333,7 +6333,7 @@ unsigned int send_beacon(struct adapter *padapter)
 	int	issue = 0;
 	int poll = 0;
 
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 
 	rtw_hal_set_hwreg(padapter, HW_VAR_BCN_VALID, NULL);
 	do {
diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index f7defc7..402fd21 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -1958,7 +1958,7 @@ void init_wifidirect_info(struct adapter *padapter, enum P2P_ROLE role)
 
 	rtw_p2p_findphase_ex_set(pwdinfo, P2P_FINDPHASE_EX_NONE);
 
-	pwdinfo->listen_dwell = (u8) ((rtw_get_current_time() % 3) + 1);
+	pwdinfo->listen_dwell = (u8) ((jiffies % 3) + 1);
 
 	_rtw_memset(&pwdinfo->tx_prov_disc_info, 0x00, sizeof(struct tx_provdisc_req_info));
 	pwdinfo->tx_prov_disc_info.wps_config_method_request = WPS_CM_NONE;
diff --git a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
index b45461f..86b522f 100644
--- a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
@@ -122,7 +122,7 @@ static bool rtw_pwr_unassociated_idle(struct adapter *adapter)
 
 	bool ret = false;
 
-	if (adapter->pwrctrlpriv.ips_deny_time >= rtw_get_current_time())
+	if (adapter->pwrctrlpriv.ips_deny_time >= jiffies)
 		goto exit;
 
 	if (check_fwstate(pmlmepriv, WIFI_ASOC_STATE|WIFI_SITE_MONITOR) ||
@@ -285,7 +285,7 @@ static u8 PS_RDY_CHECK(struct adapter *padapter)
 	struct mlme_priv	*pmlmepriv = &(padapter->mlmepriv);
 
 
-	curr_time = rtw_get_current_time();
+	curr_time = jiffies;
 	delta_time = curr_time - pwrpriv->DelayLPSLastTimeStamp;
 
 	if (delta_time < LPS_DELAY_TIME)
@@ -379,7 +379,7 @@ s32 LPS_RF_ON_check(struct adapter *padapter, u32 delay_ms)
 	s32 err = 0;
 
 
-	start_time = rtw_get_current_time();
+	start_time = jiffies;
 	while (1) {
 		rtw_hal_get_hwreg(padapter, HW_VAR_FWLPS_RF_ON, &bAwake);
 		if (bAwake)
@@ -545,7 +545,7 @@ u8 rtw_interface_ps_func(struct adapter *padapter, enum hal_intf_ps_func efunc_i
 inline void rtw_set_ips_deny(struct adapter *padapter, u32 ms)
 {
 	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
-	pwrpriv->ips_deny_time = rtw_get_current_time() + rtw_ms_to_systime(ms);
+	pwrpriv->ips_deny_time = jiffies + rtw_ms_to_systime(ms);
 }
 
 /*
@@ -561,11 +561,11 @@ int _rtw_pwr_wakeup(struct adapter *padapter, u32 ips_deffer_ms, const char *cal
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	int ret = _SUCCESS;
 
-	if (pwrpriv->ips_deny_time < rtw_get_current_time() + rtw_ms_to_systime(ips_deffer_ms))
-		pwrpriv->ips_deny_time = rtw_get_current_time() + rtw_ms_to_systime(ips_deffer_ms);
+	if (pwrpriv->ips_deny_time < jiffies + rtw_ms_to_systime(ips_deffer_ms))
+		pwrpriv->ips_deny_time = jiffies + rtw_ms_to_systime(ips_deffer_ms);
 
 {
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 	if (pwrpriv->ps_processing) {
 		DBG_88E("%s wait ps_processing...\n", __func__);
 		while (pwrpriv->ps_processing && rtw_get_passing_time_ms(start) <= 3000)
@@ -616,8 +616,8 @@ int _rtw_pwr_wakeup(struct adapter *padapter, u32 ips_deffer_ms, const char *cal
 	}
 
 exit:
-	if (pwrpriv->ips_deny_time < rtw_get_current_time() + rtw_ms_to_systime(ips_deffer_ms))
-		pwrpriv->ips_deny_time = rtw_get_current_time() + rtw_ms_to_systime(ips_deffer_ms);
+	if (pwrpriv->ips_deny_time < jiffies + rtw_ms_to_systime(ips_deffer_ms))
+		pwrpriv->ips_deny_time = jiffies + rtw_ms_to_systime(ips_deffer_ms);
 	return ret;
 }
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index a936f81..4845d96 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -2345,7 +2345,7 @@ void xmit_delivery_enabled_frames(struct adapter *padapter, struct sta_info *pst
 void rtw_sctx_init(struct submit_ctx *sctx, int timeout_ms)
 {
 	sctx->timeout_ms = timeout_ms;
-	sctx->submit_time = rtw_get_current_time();
+	sctx->submit_time = jiffies;
 	init_completion(&sctx->done);
 	sctx->status = RTW_SCTX_SUBMITTED;
 }
@@ -2406,7 +2406,7 @@ int rtw_ack_tx_wait(struct xmit_priv *pxmitpriv, u32 timeout_ms)
 {
 	struct submit_ctx *pack_tx_ops = &pxmitpriv->ack_tx_ops;
 
-	pack_tx_ops->submit_time = rtw_get_current_time();
+	pack_tx_ops->submit_time = jiffies;
 	pack_tx_ops->timeout_ms = timeout_ms;
 	pack_tx_ops->status = RTW_SCTX_SUBMITTED;
 
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
index a291d7a..0a0bc41 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -60,7 +60,7 @@ static s32 iol_execute(struct adapter *padapter, u8 control)
 	reg_0x88 = rtw_read8(padapter, REG_HMEBOX_E0);
 	rtw_write8(padapter, REG_HMEBOX_E0,  reg_0x88|control);
 
-	start = rtw_get_current_time();
+	start = jiffies;
 	while ((reg_0x88 = rtw_read8(padapter, REG_HMEBOX_E0)) & control &&
 	       (passing_time = rtw_get_passing_time_ms(start)) < 1000) {
 		;
@@ -238,7 +238,7 @@ static void efuse_read_phymap_from_txpktbuf(
 		rtw_write16(adapter, REG_PKTBUF_DBG_ADDR, dbg_addr+i);
 
 		rtw_write8(adapter, REG_TXPKTBUF_DBG, 0);
-		start = rtw_get_current_time();
+		start = jiffies;
 		while (!(reg_0x143 = rtw_read8(adapter, REG_TXPKTBUF_DBG)) &&
 		       (passing_time = rtw_get_passing_time_ms(start)) < 1000) {
 			DBG_88E("%s polling reg_0x143:0x%02x, reg_0x106:0x%02x\n", __func__, reg_0x143, rtw_read8(adapter, 0x106));
@@ -660,7 +660,7 @@ s32 rtl8188e_FirmwareDownload(struct adapter *padapter)
 	}
 
 	_FWDownloadEnable(padapter, true);
-	fwdl_start_time = rtw_get_current_time();
+	fwdl_start_time = jiffies;
 	while (1) {
 		/* reset the FWDL chksum */
 		rtw_write8(padapter, REG_MCUFWDL, rtw_read8(padapter, REG_MCUFWDL) | FWDL_ChkSum_rpt);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_sreset.c b/drivers/staging/rtl8188eu/hal/rtl8188e_sreset.c
index 96d698e..047b534 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_sreset.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_sreset.c
@@ -43,7 +43,7 @@ void rtl8188e_sreset_xmit_status_check(struct adapter *padapter)
 		rtl8188e_silentreset_for_specific_platform(padapter);
 	}
 	/* total xmit irp = 4 */
-	current_time = rtw_get_current_time();
+	current_time = jiffies;
 	if (0 == pxmitpriv->free_xmitbuf_cnt) {
 		diff_time = jiffies_to_msecs(current_time - psrtpriv->last_tx_time);
 
diff --git a/drivers/staging/rtl8188eu/hal/usb_halinit.c b/drivers/staging/rtl8188eu/hal/usb_halinit.c
index cca9732..b867bbb 100644
--- a/drivers/staging/rtl8188eu/hal/usb_halinit.c
+++ b/drivers/staging/rtl8188eu/hal/usb_halinit.c
@@ -705,7 +705,7 @@ static u32 rtl8188eu_hal_init(struct adapter *Adapter)
 	struct hal_data_8188e		*haldata = GET_HAL_DATA(Adapter);
 	struct pwrctrl_priv		*pwrctrlpriv = &Adapter->pwrctrlpriv;
 	struct registry_priv	*pregistrypriv = &Adapter->registrypriv;
-	u32 init_start_time = rtw_get_current_time();
+	u32 init_start_time = jiffies;
 
 	#define HAL_INIT_PROFILE_TAG(stage) do {} while (0)
 
@@ -1251,7 +1251,7 @@ static void _ReadRFType(struct adapter *Adapter)
 
 static int _ReadAdapterInfo8188EU(struct adapter *Adapter)
 {
-	u32 start = rtw_get_current_time();
+	u32 start = jiffies;
 
 	MSG_88E("====> %s\n", __func__);
 
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index ebfbedc..7a0fbe6 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -268,7 +268,6 @@ u32  _rtw_queue_empty(struct __queue *pqueue);
 u32  rtw_end_of_queue_search(struct list_head *queue,
 			     struct list_head *pelement);
 
-u32  rtw_get_current_time(void);
 u32  rtw_systime_to_ms(u32 systime);
 u32  rtw_ms_to_systime(u32 ms);
 s32  rtw_get_passing_time_ms(u32 start);
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index e50e3ad..21ca9fe 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -1154,7 +1154,7 @@ netdev_open_error:
 int rtw_ips_pwr_up(struct adapter *padapter)
 {
 	int result;
-	u32 start_time = rtw_get_current_time();
+	u32 start_time = jiffies;
 	DBG_88E("===>  rtw_ips_pwr_up..............\n");
 	rtw_reset_drv_sw(padapter);
 
@@ -1168,7 +1168,7 @@ int rtw_ips_pwr_up(struct adapter *padapter)
 
 void rtw_ips_pwr_down(struct adapter *padapter)
 {
-	u32 start_time = rtw_get_current_time();
+	u32 start_time = jiffies;
 	DBG_88E("===> rtw_ips_pwr_down...................\n");
 
 	padapter->bCardDisableWOHSM = true;
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 787626c..59c098f 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -212,11 +212,6 @@ u32 rtw_end_of_queue_search(struct list_head *head, struct list_head *plist)
 		return false;
 }
 
-u32	rtw_get_current_time(void)
-{
-	return jiffies;
-}
-
 inline u32 rtw_systime_to_ms(u32 systime)
 {
 	return systime * 1000 / HZ;
@@ -227,8 +222,7 @@ inline u32 rtw_ms_to_systime(u32 ms)
 	return ms * HZ / 1000;
 }
 
-/*  the input parameter start use the same unit as returned by
- *  rtw_get_current_time */
+/*  the input parameter start must be in jiffies */
 inline s32 rtw_get_passing_time_ms(u32 start)
 {
 	return rtw_systime_to_ms(jiffies-start);
diff --git a/drivers/staging/rtl8188eu/os_dep/recv_linux.c b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
index 3852ff4..2a18b32 100644
--- a/drivers/staging/rtl8188eu/os_dep/recv_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
@@ -90,16 +90,16 @@ void rtw_handle_tkip_mic_err(struct adapter *padapter, u8 bgroup)
 	u32 cur_time = 0;
 
 	if (psecuritypriv->last_mic_err_time == 0) {
-		psecuritypriv->last_mic_err_time = rtw_get_current_time();
+		psecuritypriv->last_mic_err_time = jiffies;
 	} else {
-		cur_time = rtw_get_current_time();
+		cur_time = jiffies;
 
 		if (cur_time - psecuritypriv->last_mic_err_time < 60*HZ) {
 			psecuritypriv->btkip_countermeasure = true;
 			psecuritypriv->last_mic_err_time = 0;
 			psecuritypriv->btkip_countermeasure_time = cur_time;
 		} else {
-			psecuritypriv->last_mic_err_time = rtw_get_current_time();
+			psecuritypriv->last_mic_err_time = jiffies;
 		}
 	}
 
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index b21b156..527d4e7 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -504,7 +504,7 @@ static int rtw_suspend(struct usb_interface *pusb_intf, pm_message_t message)
 	struct pwrctrl_priv *pwrpriv = &padapter->pwrctrlpriv;
 
 	int ret = 0;
-	u32 start_time = rtw_get_current_time();
+	u32 start_time = jiffies;
 
 	_func_enter_;
 
@@ -586,7 +586,7 @@ int rtw_resume_process(struct adapter *padapter)
 	struct net_device *pnetdev;
 	struct pwrctrl_priv *pwrpriv = NULL;
 	int ret = -1;
-	u32 start_time = rtw_get_current_time();
+	u32 start_time = jiffies;
 	_func_enter_;
 
 	DBG_88E("==> %s (%s:%d)\n", __func__, current->comm, current->pid);
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
index 93fc5ee..7e3f2fa 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
@@ -146,7 +146,7 @@ _func_enter_;
 	}
 
 	haldata = GET_HAL_DATA(padapter);
-	haldata->srestpriv.last_tx_complete_time = rtw_get_current_time();
+	haldata->srestpriv.last_tx_complete_time = jiffies;
 
 check_completion:
 	rtw_sctx_done_err(&pxmitbuf->sctx,
@@ -230,7 +230,7 @@ _func_enter_;
 	if (!status) {
 		struct hal_data_8188e	*haldata = GET_HAL_DATA(padapter);
 
-		haldata->srestpriv.last_tx_time = rtw_get_current_time();
+		haldata->srestpriv.last_tx_time = jiffies;
 	} else {
 		rtw_sctx_done_err(&pxmitbuf->sctx, RTW_SCTX_DONE_WRITE_PORT_ERR);
 		DBG_88E("usb_write_port, status =%d\n", status);
-- 
1.8.4
