From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/11] staging: r8188eu: Remove calls to _rtw_spinlock_free
Date: Thu, 19 Dec 2013 22:38:39 -0600
Message-ID: <1387514323-4486-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
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

This wrapper does nothing on Linux. When calls to it were removed, a number of
routines became empty and could also be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c           |  2 -
 drivers/staging/rtl8188eu/core/rtw_cmd.c          |  1 -
 drivers/staging/rtl8188eu/core/rtw_mlme.c         |  9 ----
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 11 -----
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      | 55 -----------------------
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 13 ------
 drivers/staging/rtl8188eu/include/osdep_service.h |  1 -
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       |  3 --
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  |  4 --
 9 files changed, 99 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index c3a1561..e022aaa 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -65,8 +65,6 @@ void free_mlme_ap_info(struct adapter *padapter)
 	spin_lock_bh(&(pstapriv->sta_hash_lock));
 	rtw_free_stainfo(padapter, psta);
 	spin_unlock_bh(&(pstapriv->sta_hash_lock));
-
-	_rtw_spinlock_free(&pmlmepriv->bcn_update_lock);
 }
 
 static void update_BCNTIM(struct adapter *padapter)
diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index d40ee08..64e29a9 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -121,7 +121,6 @@ void _rtw_free_cmd_priv (struct	cmd_priv *pcmdpriv)
 _func_enter_;
 
 	if (pcmdpriv) {
-		_rtw_spinlock_free(&(pcmdpriv->cmd_queue.lock));
 		_rtw_free_sema(&(pcmdpriv->cmd_queue_sema));
 		_rtw_free_sema(&(pcmdpriv->terminate_cmdthread_sema));
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index eb79bf3..3ac632c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -93,13 +93,6 @@ _func_exit_;
 	return res;
 }
 
-static void rtw_mfree_mlme_priv_lock (struct mlme_priv *pmlmepriv)
-{
-	_rtw_spinlock_free(&pmlmepriv->lock);
-	_rtw_spinlock_free(&(pmlmepriv->free_bss_pool.lock));
-	_rtw_spinlock_free(&(pmlmepriv->scanned_queue.lock));
-}
-
 #if defined (CONFIG_88EU_AP_MODE)
 static void rtw_free_mlme_ie_data(u8 **ppie, u32 *plen)
 {
@@ -136,8 +129,6 @@ _func_enter_;
 	rtw_free_mlme_priv_ie_data(pmlmepriv);
 
 	if (pmlmepriv) {
-		rtw_mfree_mlme_priv_lock (pmlmepriv);
-
 		if (pmlmepriv->free_bss_buf) {
 			rtw_vmfree(pmlmepriv->free_bss_buf, MAX_BSS_CNT * sizeof(struct wlan_network));
 		}
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 1a140de..9c9d1dd 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -118,15 +118,6 @@ _func_exit_;
 	return res;
 }
 
-static void rtw_mfree_recv_priv_lock(struct recv_priv *precvpriv)
-{
-	_rtw_spinlock_free(&precvpriv->lock);
-	_rtw_spinlock_free(&precvpriv->free_recv_queue.lock);
-	_rtw_spinlock_free(&precvpriv->recv_pending_queue.lock);
-
-	_rtw_spinlock_free(&precvpriv->free_recv_buf_queue.lock);
-}
-
 void _rtw_free_recv_priv (struct recv_priv *precvpriv)
 {
 	struct adapter	*padapter = precvpriv->adapter;
@@ -135,8 +126,6 @@ _func_enter_;
 
 	rtw_free_uc_swdec_pending_queue(padapter);
 
-	rtw_mfree_recv_priv_lock(precvpriv);
-
 	rtw_os_recv_resource_free(precvpriv);
 
 	if (precvpriv->pallocated_frame_buf) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 81bb7a5..ff03424 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -148,47 +148,7 @@ inline struct sta_info *rtw_get_stainfo_by_offset(struct sta_priv *stapriv, int
 	return (struct sta_info *)(stapriv->pstainfo_buf + offset * sizeof(struct sta_info));
 }
 
-void	_rtw_free_sta_xmit_priv_lock(struct sta_xmit_priv *psta_xmitpriv);
-void	_rtw_free_sta_xmit_priv_lock(struct sta_xmit_priv *psta_xmitpriv)
-{
-_func_enter_;
-
-	_rtw_spinlock_free(&psta_xmitpriv->lock);
-
-	_rtw_spinlock_free(&(psta_xmitpriv->be_q.sta_pending.lock));
-	_rtw_spinlock_free(&(psta_xmitpriv->bk_q.sta_pending.lock));
-	_rtw_spinlock_free(&(psta_xmitpriv->vi_q.sta_pending.lock));
-	_rtw_spinlock_free(&(psta_xmitpriv->vo_q.sta_pending.lock));
-_func_exit_;
-}
-
-static void	_rtw_free_sta_recv_priv_lock(struct sta_recv_priv *psta_recvpriv)
-{
-_func_enter_;
-
-	_rtw_spinlock_free(&psta_recvpriv->lock);
-
-	_rtw_spinlock_free(&(psta_recvpriv->defrag_q.lock));
-
-_func_exit_;
-}
-
-void rtw_mfree_stainfo(struct sta_info *psta);
-void rtw_mfree_stainfo(struct sta_info *psta)
-{
-_func_enter_;
-
-	if (&psta->lock != NULL)
-		 _rtw_spinlock_free(&psta->lock);
-
-	_rtw_free_sta_xmit_priv_lock(&psta->sta_xmitpriv);
-	_rtw_free_sta_recv_priv_lock(&psta->sta_recvpriv);
-
-_func_exit_;
-}
-
 /*  this function is used to free the memory of lock || sema for all stainfos */
-void rtw_mfree_all_stainfo(struct sta_priv *pstapriv);
 void rtw_mfree_all_stainfo(struct sta_priv *pstapriv)
 {
 	struct list_head *plist, *phead;
@@ -204,8 +164,6 @@ _func_enter_;
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
 		psta = LIST_CONTAINOR(plist, struct sta_info , list);
 		plist = get_next(plist);
-
-		rtw_mfree_stainfo(psta);
 	}
 
 	spin_unlock_bh(&pstapriv->sta_hash_lock);
@@ -218,20 +176,7 @@ static void rtw_mfree_sta_priv_lock(struct sta_priv *pstapriv)
 #ifdef CONFIG_88EU_AP_MODE
 	struct wlan_acl_pool *pacl_list = &pstapriv->acl_list;
 #endif
-
 	 rtw_mfree_all_stainfo(pstapriv); /* be done before free sta_hash_lock */
-
-	_rtw_spinlock_free(&pstapriv->free_sta_queue.lock);
-
-	_rtw_spinlock_free(&pstapriv->sta_hash_lock);
-	_rtw_spinlock_free(&pstapriv->wakeup_q.lock);
-	_rtw_spinlock_free(&pstapriv->sleep_q.lock);
-
-#ifdef CONFIG_88EU_AP_MODE
-	_rtw_spinlock_free(&pstapriv->asoc_list_lock);
-	_rtw_spinlock_free(&pstapriv->auth_list_lock);
-	_rtw_spinlock_free(&pacl_list->acl_node_q.lock);
-#endif
 }
 
 u32	_rtw_free_sta_priv(struct	sta_priv *pstapriv)
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index c0ccbaf..a936f81 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -233,19 +233,8 @@ _func_exit_;
 
 static void  rtw_mfree_xmit_priv_lock (struct xmit_priv *pxmitpriv)
 {
-	_rtw_spinlock_free(&pxmitpriv->lock);
 	_rtw_free_sema(&pxmitpriv->xmit_sema);
 	_rtw_free_sema(&pxmitpriv->terminate_xmitthread_sema);
-
-	_rtw_spinlock_free(&pxmitpriv->be_pending.lock);
-	_rtw_spinlock_free(&pxmitpriv->bk_pending.lock);
-	_rtw_spinlock_free(&pxmitpriv->vi_pending.lock);
-	_rtw_spinlock_free(&pxmitpriv->vo_pending.lock);
-	_rtw_spinlock_free(&pxmitpriv->bm_pending.lock);
-
-	_rtw_spinlock_free(&pxmitpriv->free_xmit_queue.lock);
-	_rtw_spinlock_free(&pxmitpriv->free_xmitbuf_queue.lock);
-	_rtw_spinlock_free(&pxmitpriv->pending_xmitbuf_queue.lock);
 }
 
 void _rtw_free_xmit_priv (struct xmit_priv *pxmitpriv)
@@ -284,8 +273,6 @@ void _rtw_free_xmit_priv (struct xmit_priv *pxmitpriv)
 		rtw_vmfree(pxmitpriv->pallocated_xmitbuf, NR_XMITBUFF * sizeof(struct xmit_buf) + 4);
 
 	/*  free xmit extension buff */
-	_rtw_spinlock_free(&pxmitpriv->free_xmit_extbuf_queue.lock);
-
 	pxmitbuf = (struct xmit_buf *)pxmitpriv->pxmit_extbuf;
 	for (i = 0; i < num_xmit_extbuf; i++) {
 		rtw_os_xmit_resource_free(padapter, pxmitbuf, (max_xmit_extbuf_size + XMITBUF_ALIGN_SZ));
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 4b1a6ae..ebfbedc 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -262,7 +262,6 @@ void _rtw_up_sema(struct semaphore *sema);
 u32  _rtw_down_sema(struct semaphore *sema);
 void _rtw_mutex_init(struct mutex *pmutex);
 void _rtw_mutex_free(struct mutex *pmutex);
-void _rtw_spinlock_free(spinlock_t *plock);
 
 void _rtw_init_queue(struct __queue *pqueue);
 u32  _rtw_queue_empty(struct __queue *pqueue);
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index bc2986a..e50e3ad 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -977,9 +977,6 @@ u8 rtw_free_drv_sw(struct adapter *padapter)
 	}
 	#endif
 
-
-	_rtw_spinlock_free(&padapter->br_ext_lock);
-
 	free_mlme_ext_priv(&padapter->mlmeextpriv);
 
 	rtw_free_cmd_priv(&padapter->cmdpriv);
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 13d9b13..787626c 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -193,10 +193,6 @@ void	_rtw_mutex_free(struct mutex *pmutex)
 	mutex_destroy(pmutex);
 }
 
-void	_rtw_spinlock_free(spinlock_t *plock)
-{
-}
-
 void	_rtw_init_queue(struct __queue *pqueue)
 {
 	_rtw_init_listhead(&(pqueue->queue));
-- 
1.8.4
