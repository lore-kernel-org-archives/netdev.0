From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH for 3.18] staging: r8188eu: Fix scheduling while atomic error
 introduced in commit fadbe0cd
Date: Wed, 12 Nov 2014 10:07:49 -0600
Message-ID: <1415808469-5848-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

In commit fadbe0cd5292851608e2e01b91d9295fa287b9fe entitled "staging:
rtl8188eu:Remove rtw_zmalloc(), wrapper for kzalloc()", the author failed
to note that the original code in the wrapper tested whether the caller
could sleep, and set the flags argument to kzalloc() appropriately.
After the patch, GFP_KERNEL is used unconditionally. Unfortunately, several
of the routines may be entered from an interrupt routine and generate
a BUG splat for every such call. Routine rtw_sitesurvey_cmd() is used in the
example below:

BUG: sleeping function called from invalid context at mm/slub.c:1240
in_atomic(): 1, irqs_disabled(): 0, pid: 756, name: wpa_supplicant
INFO: lockdep is turned off.
CPU: 2 PID: 756 Comm: wpa_supplicant Tainted: G        WC O   3.18.0-rc4+ #34
Hardware name: TOSHIBA TECRA A50-A/TECRA A50-A, BIOS Version 4.20   04/17/2014
ffffc90005557000 ffff880216fafaa8 ffffffff816b0bbf 0000000000000000
ffff8800c3b58000 ffff880216fafac8 ffffffff8107af77 0000000000000001
0000000000000010 ffff880216fafb18 ffffffff811b06ce 0000000000000000
Call Trace:
 [<ffffffff816b0bbf>] dump_stack+0x4e/0x71
 [<ffffffff8107af77>] __might_sleep+0xf7/0x120
 [<ffffffff811b06ce>] kmem_cache_alloc_trace+0x4e/0x1f0
 [<ffffffffa0888226>] ? rtw_sitesurvey_cmd+0x56/0x2a0 [r8188eu]
 [<ffffffffa0888226>] rtw_sitesurvey_cmd+0x56/0x2a0 [r8188eu]
 [<ffffffffa088f00d>] rtw_do_join+0x22d/0x370 [r8188eu]
 [<ffffffffa088f6e8>] rtw_set_802_11_ssid+0x218/0x3d0 [r8188eu]
 [<ffffffffa08c3ca5>] rtw_wx_set_essid+0x1e5/0x410 [r8188eu]
 [<ffffffffa08c3ac0>] ? rtw_wx_get_rate+0x50/0x50 [r8188eu]
 [<ffffffff816938f1>] ioctl_standard_iw_point+0x151/0x3f0
 [<ffffffff81693d52>] ioctl_standard_call+0xb2/0xe0
 [<ffffffff81597df7>] ? rtnl_lock+0x17/0x20
 [<ffffffff816945a0>] ? iw_handler_get_private+0x70/0x70
 [<ffffffff81693ca0>] ? call_commit_handler+0x40/0x40
 [<ffffffff81693256>] wireless_process_ioctl+0x176/0x1c0
 [<ffffffff81693e79>] wext_handle_ioctl+0x69/0xc0
 [<ffffffff8159fe79>] dev_ioctl+0x309/0x5e0
 [<ffffffff810be9c7>] ? call_rcu+0x17/0x20
 [<ffffffff8156a472>] sock_ioctl+0x142/0x2e0
 [<ffffffff811e0c70>] do_vfs_ioctl+0x300/0x520
 [<ffffffff81101514>] ? __audit_syscall_entry+0xb4/0x110
 [<ffffffff81101514>] ? __audit_syscall_entry+0xb4/0x110
 [<ffffffff810102bc>] ? do_audit_syscall_entry+0x6c/0x70
 [<ffffffff811e0f11>] SyS_ioctl+0x81/0xa0
 [<ffffffff816ba1d2>] system_call_fastpath+0x12/0x17

Additional routines that generate this BUG are rtw_joinbss_cmd(),
rtw_dynamic_chk_wk_cmd(), rtw_lps_ctrl_wk_cmd(), rtw_rpt_timer_cfg_cmd(),
rtw_ps_cmd(), report_survey_event(), report_join_res(), survey_timer_hdl(),
and rtw_check_bcn_info().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: navin patidar <navin.patidar@gmail.com>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c       | 22 +++++++++++-----------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c  | 12 ++++++------
 drivers/staging/rtl8188eu/core/rtw_wlan_util.c |  2 +-
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index a1cc788..4b43462 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -275,11 +275,11 @@ u8 rtw_sitesurvey_cmd(struct adapter  *padapter, struct ndis_802_11_ssid *ssid,
 	if (check_fwstate(pmlmepriv, _FW_LINKED) == true)
 		rtw_lps_ctrl_wk_cmd(padapter, LPS_CTRL_SCAN, 1);
 
-	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (ph2c == NULL)
 		return _FAIL;
 
-	psurveyPara = kzalloc(sizeof(struct sitesurvey_parm), GFP_KERNEL);
+	psurveyPara = kzalloc(sizeof(struct sitesurvey_parm), GFP_ATOMIC);
 	if (psurveyPara == NULL) {
 		kfree(ph2c);
 		return _FAIL;
@@ -405,7 +405,7 @@ u8 rtw_joinbss_cmd(struct adapter  *padapter, struct wlan_network *pnetwork)
 	else
 		RT_TRACE(_module_rtl871x_cmd_c_, _drv_notice_, ("+Join cmd: SSid =[%s]\n", pmlmepriv->assoc_ssid.Ssid));
 
-	pcmd = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	pcmd = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (pcmd == NULL) {
 		res = _FAIL;
 		RT_TRACE(_module_rtl871x_cmd_c_, _drv_err_, ("rtw_joinbss_cmd: memory allocate for cmd_obj fail!!!\n"));
@@ -754,13 +754,13 @@ u8 rtw_dynamic_chk_wk_cmd(struct adapter *padapter)
 	u8	res = _SUCCESS;
 
 
-	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (ph2c == NULL) {
 		res = _FAIL;
 		goto exit;
 	}
 
-	pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_KERNEL);
+	pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_ATOMIC);
 	if (pdrvextra_cmd_parm == NULL) {
 		kfree(ph2c);
 		res = _FAIL;
@@ -966,13 +966,13 @@ u8 rtw_lps_ctrl_wk_cmd(struct adapter *padapter, u8 lps_ctrl_type, u8 enqueue)
 	u8	res = _SUCCESS;
 
 	if (enqueue) {
-		ph2c = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+		ph2c = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 		if (ph2c == NULL) {
 			res = _FAIL;
 			goto exit;
 		}
 
-		pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_KERNEL);
+		pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_ATOMIC);
 		if (pdrvextra_cmd_parm == NULL) {
 			kfree(ph2c);
 			res = _FAIL;
@@ -1009,13 +1009,13 @@ u8 rtw_rpt_timer_cfg_cmd(struct adapter *padapter, u16 min_time)
 
 	u8	res = _SUCCESS;
 
-	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (ph2c == NULL) {
 		res = _FAIL;
 		goto exit;
 	}
 
-	pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_KERNEL);
+	pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_ATOMIC);
 	if (pdrvextra_cmd_parm == NULL) {
 		kfree(ph2c);
 		res = _FAIL;
@@ -1087,13 +1087,13 @@ u8 rtw_ps_cmd(struct adapter *padapter)
 
 	u8	res = _SUCCESS;
 
-	ppscmd = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	ppscmd = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (ppscmd == NULL) {
 		res = _FAIL;
 		goto exit;
 	}
 
-	pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_KERNEL);
+	pdrvextra_cmd_parm = kzalloc(sizeof(struct drvextra_cmd_parm), GFP_ATOMIC);
 	if (pdrvextra_cmd_parm == NULL) {
 		kfree(ppscmd);
 		res = _FAIL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 990c168..e4b7ee4 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -4239,12 +4239,12 @@ void report_survey_event(struct adapter *padapter,
 	pcmdpriv = &padapter->cmdpriv;
 
 
-	pcmd_obj = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	pcmd_obj = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (pcmd_obj == NULL)
 		return;
 
 	cmdsz = (sizeof(struct survey_event) + sizeof(struct C2HEvent_Header));
-	pevtcmd = kzalloc(cmdsz, GFP_KERNEL);
+	pevtcmd = kzalloc(cmdsz, GFP_ATOMIC);
 	if (pevtcmd == NULL) {
 		kfree(pcmd_obj);
 		return;
@@ -4337,12 +4337,12 @@ void report_join_res(struct adapter *padapter, int res)
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 	struct cmd_priv *pcmdpriv = &padapter->cmdpriv;
 
-	pcmd_obj = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	pcmd_obj = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (pcmd_obj == NULL)
 		return;
 
 	cmdsz = (sizeof(struct joinbss_event) + sizeof(struct C2HEvent_Header));
-	pevtcmd = kzalloc(cmdsz, GFP_KERNEL);
+	pevtcmd = kzalloc(cmdsz, GFP_ATOMIC);
 	if (pevtcmd == NULL) {
 		kfree(pcmd_obj);
 		return;
@@ -4852,11 +4852,11 @@ void survey_timer_hdl(void *function_context)
 			pmlmeext->scan_abort = false;/* reset */
 		}
 
-		ph2c = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+		ph2c = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 		if (ph2c == NULL)
 			goto exit_survey_timer_hdl;
 
-		psurveyPara = kzalloc(sizeof(struct sitesurvey_parm), GFP_KERNEL);
+		psurveyPara = kzalloc(sizeof(struct sitesurvey_parm), GFP_ATOMIC);
 		if (psurveyPara == NULL) {
 			kfree(ph2c);
 			goto exit_survey_timer_hdl;
diff --git a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
index c495977..324c1a7 100644
--- a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
+++ b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
@@ -935,7 +935,7 @@ int rtw_check_bcn_info(struct adapter  *Adapter, u8 *pframe, u32 packet_len)
 		return true;
 	}
 
-	bssid = kzalloc(sizeof(struct wlan_bssid_ex), GFP_KERNEL);
+	bssid = kzalloc(sizeof(struct wlan_bssid_ex), GFP_ATOMIC);
 
 	subtype = GetFrameSubType(pframe) >> 4;
 
-- 
2.1.2
