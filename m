From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 10/31] staging: r8188eu: Remove wrappers _rtw_free_sema, _rtw_up_sema, and _rtw_mutex_init
Date: Sun, 22 Dec 2013 17:36:41 -0600
Message-ID: <1387755422-11443-11-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:47110 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756731Ab3LVXhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:37:50 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so4664218pbc.35
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:37:49 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any routines that are empty as a result of these changes are also removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          | 11 ++++-------
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c      |  7 -------
 drivers/staging/rtl8188eu/core/rtw_sreset.c       |  2 +-
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 10 +---------
 drivers/staging/rtl8188eu/include/osdep_service.h |  3 ---
 drivers/staging/rtl8188eu/include/rtw_pwrctrl.h   |  8 +-------
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       |  4 +---
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 14 --------------
 drivers/staging/rtl8188eu/os_dep/usb_intf.c       |  4 ++--
 9 files changed, 10 insertions(+), 53 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index a46aadd..82fe8c4 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -121,9 +121,6 @@ void _rtw_free_cmd_priv (struct	cmd_priv *pcmdpriv)
 _func_enter_;
 
 	if (pcmdpriv) {
-		_rtw_free_sema(&(pcmdpriv->cmd_queue_sema));
-		_rtw_free_sema(&(pcmdpriv->terminate_cmdthread_sema));
-
 		if (pcmdpriv->cmd_allocated_buf)
 			kfree(pcmdpriv->cmd_allocated_buf);
 
@@ -257,7 +254,7 @@ _func_enter_;
 	res = _rtw_enqueue_cmd(&pcmdpriv->cmd_queue, cmd_obj);
 
 	if (res == _SUCCESS)
-		_rtw_up_sema(&pcmdpriv->cmd_queue_sema);
+		up(&pcmdpriv->cmd_queue_sema);
 
 exit:
 
@@ -282,7 +279,7 @@ void rtw_cmd_clr_isr(struct	cmd_priv *pcmdpriv)
 {
 _func_enter_;
 	pcmdpriv->cmd_done_cnt++;
-	/* _rtw_up_sema(&(pcmdpriv->cmd_done_sema)); */
+	/* up(&(pcmdpriv->cmd_done_sema)); */
 _func_exit_;
 }
 
@@ -325,7 +322,7 @@ _func_enter_;
 	pcmdbuf = pcmdpriv->cmd_buf;
 
 	pcmdpriv->cmdthd_running = true;
-	_rtw_up_sema(&pcmdpriv->terminate_cmdthread_sema);
+	up(&pcmdpriv->terminate_cmdthread_sema);
 
 	RT_TRACE(_module_rtl871x_cmd_c_, _drv_info_, ("start r871x rtw_cmd_thread !!!!\n"));
 
@@ -411,7 +408,7 @@ post_process:
 		rtw_free_cmd_obj(pcmd);
 	} while (1);
 
-	_rtw_up_sema(&pcmdpriv->terminate_cmdthread_sema);
+	up(&pcmdpriv->terminate_cmdthread_sema);
 
 _func_exit_;
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
index c011efe..4eec447 100644
--- a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
@@ -524,13 +524,6 @@ _func_exit_;
 
 void rtw_free_pwrctrl_priv(struct adapter *adapter)
 {
-	struct pwrctrl_priv *pwrctrlpriv = &adapter->pwrctrlpriv;
-
-_func_enter_;
-
-	_free_pwrlock(&pwrctrlpriv->lock);
-
-_func_exit_;
 }
 
 u8 rtw_interface_ps_func(struct adapter *padapter, enum hal_intf_ps_func efunc_id, u8 *val)
diff --git a/drivers/staging/rtl8188eu/core/rtw_sreset.c b/drivers/staging/rtl8188eu/core/rtw_sreset.c
index 298f754..ee20d4a 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sreset.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sreset.c
@@ -25,7 +25,7 @@ void sreset_init_value(struct adapter *padapter)
 	struct hal_data_8188e	*pHalData = GET_HAL_DATA(padapter);
 	struct sreset_priv *psrtpriv = &pHalData->srestpriv;
 
-	_rtw_mutex_init(&psrtpriv->silentreset_mutex);
+	mutex_init(&psrtpriv->silentreset_mutex);
 	psrtpriv->silent_reset_inprogress = false;
 	psrtpriv->Wifi_Error_Status = WIFI_STATUS_SUCCESS;
 	psrtpriv->last_tx_time = 0;
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index b372408..b1af4ef 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -219,7 +219,7 @@ _func_enter_;
 	pxmitpriv->voq_cnt = 0;
 
 	pxmitpriv->ack_tx = false;
-	_rtw_mutex_init(&pxmitpriv->ack_tx_mutex);
+	mutex_init(&pxmitpriv->ack_tx_mutex);
 	rtw_sctx_init(&pxmitpriv->ack_tx_ops, 0);
 
 	rtw_hal_init_xmit_priv(padapter);
@@ -231,12 +231,6 @@ _func_exit_;
 	return res;
 }
 
-static void  rtw_mfree_xmit_priv_lock (struct xmit_priv *pxmitpriv)
-{
-	_rtw_free_sema(&pxmitpriv->xmit_sema);
-	_rtw_free_sema(&pxmitpriv->terminate_xmitthread_sema);
-}
-
 void _rtw_free_xmit_priv (struct xmit_priv *pxmitpriv)
 {
 	int i;
@@ -250,8 +244,6 @@ void _rtw_free_xmit_priv (struct xmit_priv *pxmitpriv)
 
 	rtw_hal_free_xmit_priv(padapter);
 
-	rtw_mfree_xmit_priv_lock(pxmitpriv);
-
 	if (pxmitpriv->pxmit_frame_buf == NULL)
 		goto out;
 
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 77829b9..3ea97fd 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -256,10 +256,7 @@ void rtw_list_insert_head(struct list_head *plist, struct list_head *phead);
 void rtw_list_insert_tail(struct list_head *plist, struct list_head *phead);
 void rtw_list_delete(struct list_head *plist);
 
-void _rtw_free_sema(struct semaphore *sema);
-void _rtw_up_sema(struct semaphore *sema);
 u32  _rtw_down_sema(struct semaphore *sema);
-void _rtw_mutex_init(struct mutex *pmutex);
 void _rtw_mutex_free(struct mutex *pmutex);
 
 void _rtw_init_queue(struct __queue *pqueue);
diff --git a/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h b/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h
index 3946c03..4a0e9ff 100644
--- a/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h
+++ b/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h
@@ -102,11 +102,6 @@ static inline void _init_pwrlock(struct semaphore  *plock)
 	sema_init(plock, 1);
 }
 
-static inline void _free_pwrlock(struct semaphore  *plock)
-{
-	_rtw_free_sema(plock);
-}
-
 static inline void _enter_pwrlock(struct semaphore  *plock)
 {
 	_rtw_down_sema(plock);
@@ -114,7 +109,7 @@ static inline void _enter_pwrlock(struct semaphore  *plock)
 
 static inline void _exit_pwrlock(struct semaphore  *plock)
 {
-	_rtw_up_sema(plock);
+	up(plock);
 }
 
 #define LPS_DELAY_TIME	1*HZ /*  1 sec */
@@ -251,7 +246,6 @@ struct pwrctrl_priv {
 				       (pwrctrl)->pwr_state_check_interval)
 
 void rtw_init_pwrctrl_priv(struct adapter *adapter);
-void rtw_free_pwrctrl_priv(struct adapter *adapter);
 
 void rtw_set_ps_mode(struct adapter *adapter, u8 ps_mode, u8 smart_ps,
 		     u8 bcn_ant_mode);
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index 21ca9fe..92e9008 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -761,7 +761,7 @@ void rtw_stop_drv_threads(struct adapter *padapter)
 	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+rtw_stop_drv_threads\n"));
 
 	/* Below is to termindate rtw_cmd_thread & event_thread... */
-	_rtw_up_sema(&padapter->cmdpriv.cmd_queue_sema);
+	up(&padapter->cmdpriv.cmd_queue_sema);
 	if (padapter->cmdThread)
 		_rtw_down_sema(&padapter->cmdpriv.terminate_cmdthread_sema);
 
@@ -990,8 +990,6 @@ u8 rtw_free_drv_sw(struct adapter *padapter)
 
 	_rtw_free_recv_priv(&padapter->recvpriv);
 
-	rtw_free_pwrctrl_priv(padapter);
-
 	rtw_hal_free_data(padapter);
 
 	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("<== rtw_free_drv_sw\n"));
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index f292427..23d39cc 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -161,15 +161,6 @@ void rtw_list_insert_tail(struct list_head *plist, struct list_head *phead)
 Caller must check if the list is empty before calling rtw_list_delete
 */
 
-void _rtw_free_sema(struct semaphore *sema)
-{
-}
-
-void _rtw_up_sema(struct semaphore *sema)
-{
-	up(sema);
-}
-
 u32 _rtw_down_sema(struct semaphore *sema)
 {
 	if (down_interruptible(sema))
@@ -178,11 +169,6 @@ u32 _rtw_down_sema(struct semaphore *sema)
 		return _SUCCESS;
 }
 
-void	_rtw_mutex_init(struct mutex *pmutex)
-{
-	mutex_init(pmutex);
-}
-
 void	_rtw_mutex_free(struct mutex *pmutex)
 {
 	mutex_destroy(pmutex);
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 8642397..32d1e97 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -126,7 +126,7 @@ static u8 rtw_init_intf_priv(struct dvobj_priv *dvobj)
 {
 	u8 rst = _SUCCESS;
 
-	_rtw_mutex_init(&dvobj->usb_vendor_req_mutex);
+	mutex_init(&dvobj->usb_vendor_req_mutex);
 
 	dvobj->usb_alloc_vendor_req_buf = rtw_zmalloc(MAX_USB_IO_CTL_SIZE);
 	if (dvobj->usb_alloc_vendor_req_buf == NULL) {
@@ -867,7 +867,7 @@ static int __init rtw_drv_entry(void)
 	DBG_88E(DRV_NAME " driver version=%s\n", DRIVERVERSION);
 	DBG_88E("build time: %s %s\n", __DATE__, __TIME__);
 
-	_rtw_mutex_init(&usb_drv->hw_init_mutex);
+	mutex_init(&usb_drv->hw_init_mutex);
 
 	usb_drv->drv_registered = true;
 	return usb_register(&usb_drv->usbdrv);
-- 
1.8.4
