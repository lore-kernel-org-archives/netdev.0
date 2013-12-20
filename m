From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 02/11] staging: r8188eu: Remove wrapper around spin_lock_bh
Date: Thu, 19 Dec 2013 22:38:34 -0600
Message-ID: <1387514323-4486-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:55907 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3LTEj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:39:59 -0500
Received: by mail-pa0-f45.google.com with SMTP id fb1so2117848pad.32
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:39:59 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some comment lines that mentioned spin_lock_bh() are also removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c           | 38 ++++++++--------
 drivers/staging/rtl8188eu/core/rtw_br_ext.c       | 16 +++----
 drivers/staging/rtl8188eu/core/rtw_cmd.c          | 12 ++---
 drivers/staging/rtl8188eu/core/rtw_debug.c        |  2 +-
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c    | 12 ++---
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 54 +++++++++++------------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 24 +++++-----
 drivers/staging/rtl8188eu/core/rtw_mp.c           |  4 +-
 drivers/staging/rtl8188eu/core/rtw_p2p.c          | 10 ++---
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 16 +++----
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      | 22 ++++-----
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 28 ++++++------
 drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c    |  4 +-
 drivers/staging/rtl8188eu/include/osdep_service.h |  5 ---
 drivers/staging/rtl8188eu/include/rtw_mlme.h      | 10 ++---
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c    | 30 ++++++-------
 drivers/staging/rtl8188eu/os_dep/xmit_linux.c     |  4 +-
 17 files changed, 136 insertions(+), 155 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index 2f548eb..1fa6262 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -62,7 +62,7 @@ void free_mlme_ap_info(struct adapter *padapter)
 
 	/* free bc/mc sta_info */
 	psta = rtw_get_bcmc_stainfo(padapter);
-	_enter_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+	spin_lock_bh(&(pstapriv->sta_hash_lock));
 	rtw_free_stainfo(padapter, psta);
 	_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
 
@@ -286,7 +286,7 @@ void	expire_timeout_chk(struct adapter *padapter)
 	char chk_alive_list[NUM_STA];
 	int i;
 
-	_enter_critical_bh(&pstapriv->auth_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->auth_list_lock);
 
 	phead = &pstapriv->auth_list;
 	plist = get_next(phead);
@@ -307,11 +307,11 @@ void	expire_timeout_chk(struct adapter *padapter)
 
 				_exit_critical_bh(&pstapriv->auth_list_lock, &irqL);
 
-				_enter_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+				spin_lock_bh(&(pstapriv->sta_hash_lock));
 				rtw_free_stainfo(padapter, psta);
 				_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
 
-				_enter_critical_bh(&pstapriv->auth_list_lock, &irqL);
+				spin_lock_bh(&pstapriv->auth_list_lock);
 			}
 		}
 
@@ -320,7 +320,7 @@ void	expire_timeout_chk(struct adapter *padapter)
 
 	psta = NULL;
 
-	_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->asoc_list_lock);
 
 	phead = &pstapriv->asoc_list;
 	plist = get_next(phead);
@@ -424,7 +424,7 @@ void	expire_timeout_chk(struct adapter *padapter)
 			psta->keep_alive_trycnt = 0;
 
 			DBG_88E("asoc expire %pM, state = 0x%x\n", (psta->hwaddr), psta->state);
-			_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+			spin_lock_bh(&pstapriv->asoc_list_lock);
 			rtw_list_delete(&psta->asoc_list);
 			pstapriv->asoc_list_cnt--;
 			updated = ap_free_sta(padapter, psta, true, WLAN_REASON_DEAUTH_LEAVING);
@@ -604,7 +604,7 @@ static void update_bmc_sta(struct adapter *padapter)
 
 		rtw_stassoc_hw_rpt(padapter, psta);
 
-		_enter_critical_bh(&psta->lock, &irqL);
+		spin_lock_bh(&psta->lock);
 		psta->state = _FW_LINKED;
 		_exit_critical_bh(&psta->lock, &irqL);
 
@@ -679,7 +679,7 @@ void update_sta_info_apmode(struct adapter *padapter, struct sta_info *psta)
 
 	_rtw_memset((void *)&psta->sta_stats, 0, sizeof(struct stainfo_stats));
 
-	_enter_critical_bh(&psta->lock, &irqL);
+	spin_lock_bh(&psta->lock);
 	psta->state |= _FW_LINKED;
 	_exit_critical_bh(&psta->lock, &irqL);
 }
@@ -1148,7 +1148,7 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 	if ((NUM_ACL-1) < pacl_list->num)
 		return -1;
 
-	_enter_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_lock_bh(&(pacl_node_q->lock));
 
 	phead = get_list_head(pacl_node_q);
 	plist = get_next(phead);
@@ -1171,7 +1171,7 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 	if (added)
 		return ret;
 
-	_enter_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_lock_bh(&(pacl_node_q->lock));
 
 	for (i = 0; i < NUM_ACL; i++) {
 		paclnode = &pacl_list->aclnode[i];
@@ -1210,7 +1210,7 @@ int rtw_acl_remove_sta(struct adapter *padapter, u8 *addr)
 
 	DBG_88E("%s(acl_num =%d) =%pM\n", __func__, pacl_list->num, (addr));
 
-	_enter_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_lock_bh(&(pacl_node_q->lock));
 
 	phead = get_list_head(pacl_node_q);
 	plist = get_next(phead);
@@ -1386,7 +1386,7 @@ void update_beacon(struct adapter *padapter, u8 ie_id, u8 *oui, u8 tx)
 	if (!pmlmeext->bstart_bss)
 		return;
 
-	_enter_critical_bh(&pmlmepriv->bcn_update_lock, &irqL);
+	spin_lock_bh(&pmlmepriv->bcn_update_lock);
 
 	switch (ie_id) {
 	case 0xFF:
@@ -1510,7 +1510,7 @@ void associated_clients_update(struct adapter *padapter, u8 updated)
 		struct sta_info *psta = NULL;
 		struct sta_priv *pstapriv = &padapter->stapriv;
 
-		_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+		spin_lock_bh(&pstapriv->asoc_list_lock);
 
 		phead = &pstapriv->asoc_list;
 		plist = get_next(phead);
@@ -1753,7 +1753,7 @@ u8 ap_free_sta(struct adapter *padapter, struct sta_info *psta,
 	rtw_clearstakey_cmd(padapter, (u8 *)psta, (u8)(psta->mac_id + 3), true);
 
 
-	_enter_critical_bh(&psta->lock, &irqL);
+	spin_lock_bh(&psta->lock);
 	psta->state &= ~_FW_LINKED;
 	_exit_critical_bh(&psta->lock, &irqL);
 
@@ -1763,7 +1763,7 @@ u8 ap_free_sta(struct adapter *padapter, struct sta_info *psta,
 
 	beacon_updated = bss_cap_update_on_sta_leave(padapter, psta);
 
-	_enter_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+	spin_lock_bh(&(pstapriv->sta_hash_lock));
 	rtw_free_stainfo(padapter, psta);
 	_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
 
@@ -1787,7 +1787,7 @@ int rtw_ap_inform_ch_switch(struct adapter *padapter, u8 new_ch, u8 ch_offset)
 	DBG_88E(FUNC_NDEV_FMT" with ch:%u, offset:%u\n",
 		FUNC_NDEV_ARG(padapter->pnetdev), new_ch, ch_offset);
 
-	_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
 	plist = get_next(phead);
 
@@ -1822,7 +1822,7 @@ int rtw_sta_flush(struct adapter *padapter)
 	if ((pmlmeinfo->state&0x03) != WIFI_FW_AP_STATE)
 		return ret;
 
-	_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
 	plist = get_next(phead);
 
@@ -1954,7 +1954,7 @@ void stop_ap_mode(struct adapter *padapter)
 	padapter->securitypriv.ndisencryptstatus = Ndis802_11WEPDisabled;
 
 	/* for ACL */
-	_enter_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_lock_bh(&(pacl_node_q->lock));
 	phead = get_list_head(pacl_node_q);
 	plist = get_next(phead);
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
@@ -1979,7 +1979,7 @@ void stop_ap_mode(struct adapter *padapter)
 	rtw_free_all_stainfo(padapter);
 
 	psta = rtw_get_bcmc_stainfo(padapter);
-	_enter_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+	spin_lock_bh(&(pstapriv->sta_hash_lock));
 	rtw_free_stainfo(padapter, psta);
 	_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_br_ext.c b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
index 9f40742..8c36e1e 100644
--- a/drivers/staging/rtl8188eu/core/rtw_br_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
@@ -331,7 +331,7 @@ static inline int __nat25_network_hash(unsigned char *networkAddr)
 static inline void __network_hash_link(struct adapter *priv,
 				struct nat25_network_db_entry *ent, int hash)
 {
-	/*  Caller must _enter_critical_bh already! */
+	/*  Caller must spin_lock_bh already! */
 	ent->next_hash = priv->nethash[hash];
 	if (ent->next_hash != NULL)
 		ent->next_hash->pprev_hash = &ent->next_hash;
@@ -341,7 +341,7 @@ static inline void __network_hash_link(struct adapter *priv,
 
 static inline void __network_hash_unlink(struct nat25_network_db_entry *ent)
 {
-	/*  Caller must _enter_critical_bh already! */
+	/*  Caller must spin_lock_bh already! */
 	*(ent->pprev_hash) = ent->next_hash;
 	if (ent->next_hash != NULL)
 		ent->next_hash->pprev_hash = ent->pprev_hash;
@@ -354,7 +354,7 @@ static int __nat25_db_network_lookup_and_replace(struct adapter *priv,
 {
 	struct nat25_network_db_entry *db;
 	unsigned long irqL;
-	_enter_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_lock_bh(&priv->br_ext_lock);
 
 	db = priv->nethash[__nat25_network_hash(networkAddr)];
 	while (db != NULL) {
@@ -406,7 +406,7 @@ static void __nat25_db_network_insert(struct adapter *priv,
 	int hash;
 	unsigned long irqL;
 
-	_enter_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_lock_bh(&priv->br_ext_lock);
 	hash = __nat25_network_hash(networkAddr);
 	db = priv->nethash[hash];
 	while (db != NULL) {
@@ -445,7 +445,7 @@ void nat25_db_cleanup(struct adapter *priv)
 {
 	int i;
 	unsigned long irqL;
-	_enter_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_lock_bh(&priv->br_ext_lock);
 
 	for (i = 0; i < NAT25_HASH_SIZE; i++) {
 		struct nat25_network_db_entry *f;
@@ -471,7 +471,7 @@ void nat25_db_expire(struct adapter *priv)
 {
 	int i;
 	unsigned long irqL;
-	_enter_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_lock_bh(&priv->br_ext_lock);
 
 	for (i = 0; i < NAT25_HASH_SIZE; i++) {
 		struct nat25_network_db_entry *f;
@@ -1061,7 +1061,7 @@ int nat25_handle_frame(struct adapter *priv, struct sk_buff *skb)
 
 		if (!priv->ethBrExtInfo.nat25_disable) {
 			unsigned long irqL;
-			_enter_critical_bh(&priv->br_ext_lock, &irqL);
+			spin_lock_bh(&priv->br_ext_lock);
 			/*
 			 *	This function look up the destination network address from
 			 *	the NAT2.5 database. Return value = -1 means that the
@@ -1178,8 +1178,6 @@ void *scdb_findEntry(struct adapter *priv, unsigned char *macAddr,
 	unsigned char networkAddr[MAX_NETWORK_ADDR_LEN];
 	struct nat25_network_db_entry *db;
 	int hash;
-	/* unsigned long irqL; */
-	/* _enter_critical_bh(&priv->br_ext_lock, &irqL); */
 
 	__nat25_generate_ipv4_network_addr(networkAddr, (unsigned int *)ipAddr);
 	hash = __nat25_network_hash(networkAddr);
diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index 3e2d980..c0cb186 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -153,12 +153,10 @@ _func_enter_;
 	if (obj == NULL)
 		goto exit;
 
-	/* _enter_critical_bh(&queue->lock, &irqL); */
 	_enter_critical(&queue->lock, &irqL);
 
 	rtw_list_insert_tail(&obj->list, &queue->queue);
 
-	/* _exit_critical_bh(&queue->lock, &irqL); */
 	_exit_critical(&queue->lock, &irqL);
 
 exit:
@@ -175,7 +173,6 @@ struct	cmd_obj	*_rtw_dequeue_cmd(struct __queue *queue)
 
 _func_enter_;
 
-	/* _enter_critical_bh(&(queue->lock), &irqL); */
 	_enter_critical(&queue->lock, &irqL);
 	if (rtw_is_list_empty(&(queue->queue))) {
 		obj = NULL;
@@ -184,7 +181,6 @@ _func_enter_;
 		rtw_list_delete(&obj->list);
 	}
 
-	/* _exit_critical_bh(&(queue->lock), &irqL); */
 	_exit_critical(&queue->lock, &irqL);
 
 _func_exit_;
@@ -2206,7 +2202,7 @@ void rtw_disassoc_cmd_callback(struct adapter *padapter, struct cmd_obj *pcmd)
 _func_enter_;
 
 	if (pcmd->res != H2C_SUCCESS) {
-		_enter_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_lock_bh(&pmlmepriv->lock);
 		set_fwstate(pmlmepriv, _FW_LINKED);
 		_exit_critical_bh(&pmlmepriv->lock, &irqL);
 
@@ -2263,7 +2259,7 @@ _func_enter_;
 
 	_cancel_timer(&pmlmepriv->assoc_timer, &timer_cancelled);
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
 		psta = rtw_get_stainfo(&padapter->stapriv, pnetwork->MacAddress);
@@ -2280,7 +2276,7 @@ _func_enter_;
 		unsigned long	irqL;
 
 		pwlan = _rtw_alloc_network(pmlmepriv);
-		_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+		spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 		if (pwlan == NULL) {
 			pwlan = rtw_get_oldest_wlan_network(&pmlmepriv->scanned_queue);
 			if (pwlan == NULL) {
@@ -2349,7 +2345,7 @@ _func_enter_;
 	psta->aid = passocsta_rsp->cam_id;
 	psta->mac_id = passocsta_rsp->cam_id;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if ((check_fwstate(pmlmepriv, WIFI_MP_STATE) == true) && (check_fwstate(pmlmepriv, _FW_UNDER_LINKING) == true))
 		_clr_fwstate_(pmlmepriv, _FW_UNDER_LINKING);
diff --git a/drivers/staging/rtl8188eu/core/rtw_debug.c b/drivers/staging/rtl8188eu/core/rtw_debug.c
index 0fe5f5d..9352048 100644
--- a/drivers/staging/rtl8188eu/core/rtw_debug.c
+++ b/drivers/staging/rtl8188eu/core/rtw_debug.c
@@ -848,7 +848,7 @@ int proc_get_all_sta_info(char *page, char **start,
 
 	len += snprintf(page + len, count - len, "sta_dz_bitmap=0x%x, tim_bitmap=0x%x\n", pstapriv->sta_dz_bitmap, pstapriv->tim_bitmap);
 
-	_enter_critical_bh(&pstapriv->sta_hash_lock, &irqL);
+	spin_lock_bh(&pstapriv->sta_hash_lock);
 
 	for (i = 0; i < NUM_STA; i++) {
 		phead = &(pstapriv->sta_hash[i]);
diff --git a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
index 193f641..92818eb 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
@@ -77,7 +77,7 @@ u8 rtw_do_join(struct adapter *padapter)
 
 _func_enter_;
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 	phead = get_list_head(queue);
 	plist = get_next(phead);
 
@@ -195,7 +195,7 @@ _func_enter_;
 		goto exit;
 	}
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_lock_bh(&pmlmepriv->lock);
 
 
 	DBG_88E("Set BSSID under fw_state = 0x%08x\n", get_fwstate(pmlmepriv));
@@ -285,7 +285,7 @@ _func_enter_;
 		goto exit;
 	}
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	DBG_88E("Set SSID under fw_state = 0x%08x\n", get_fwstate(pmlmepriv));
 	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY) == true) {
@@ -391,7 +391,7 @@ _func_enter_;
 		  *pold_state, networktype, get_fwstate(pmlmepriv)));
 
 	if (*pold_state != networktype) {
-		_enter_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_lock_bh(&pmlmepriv->lock);
 
 		RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_info_, (" change mode!"));
 		/* DBG_88E("change mode, old_mode =%d, new_mode =%d, fw_state = 0x%x\n", *pold_state, networktype, get_fwstate(pmlmepriv)); */
@@ -455,7 +455,7 @@ u8 rtw_set_802_11_disassociate(struct adapter *padapter)
 
 _func_enter_;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if (check_fwstate(pmlmepriv, _FW_LINKED)) {
 		RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_info_,
@@ -512,7 +512,7 @@ _func_enter_;
 			return _SUCCESS;
 		}
 
-		_enter_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_lock_bh(&pmlmepriv->lock);
 
 		res = rtw_sitesurvey_cmd(padapter, pssid, ssid_max_num, NULL, 0);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index ac3535d..da82fa1 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -154,7 +154,7 @@ _func_enter_;
 	if (pnetwork == NULL)
 		goto exit;
 
-	_enter_critical_bh(&queue->lock, &irql);
+	spin_lock_bh(&queue->lock);
 
 	rtw_list_insert_tail(&pnetwork->list, &queue->queue);
 
@@ -175,7 +175,7 @@ struct	wlan_network *_rtw_dequeue_network(struct __queue *queue)
 
 _func_enter_;
 
-	_enter_critical_bh(&queue->lock, &irql);
+	spin_lock_bh(&queue->lock);
 
 	if (_rtw_queue_empty(queue)) {
 		pnetwork = NULL;
@@ -201,7 +201,7 @@ struct	wlan_network *_rtw_alloc_network(struct	mlme_priv *pmlmepriv)/* _queue *f
 
 _func_enter_;
 
-	_enter_critical_bh(&free_queue->lock, &irql);
+	spin_lock_bh(&free_queue->lock);
 
 	if (_rtw_queue_empty(free_queue) == true) {
 		pnetwork = NULL;
@@ -253,7 +253,7 @@ _func_enter_;
 		if (delta_time < lifetime)/*  unit:sec */
 			goto exit;
 	}
-	_enter_critical_bh(&free_queue->lock, &irql);
+	spin_lock_bh(&free_queue->lock);
 	rtw_list_delete(&(pnetwork->list));
 	rtw_list_insert_tail(&(pnetwork->list), &(free_queue->queue));
 	pmlmepriv->num_of_scanned--;
@@ -324,7 +324,7 @@ void _rtw_free_network_queue(struct adapter *padapter, u8 isfreeall)
 _func_enter_;
 
 
-	_enter_critical_bh(&scanned_queue->lock, &irql);
+	spin_lock_bh(&scanned_queue->lock);
 
 	phead = get_list_head(scanned_queue);
 	plist = get_next(phead);
@@ -602,7 +602,7 @@ void rtw_update_scanned_network(struct adapter *adapter, struct wlan_bssid_ex *t
 
 _func_enter_;
 
-	_enter_critical_bh(&queue->lock, &irql);
+	spin_lock_bh(&queue->lock);
 	phead = get_list_head(queue);
 	plist = get_next(phead);
 
@@ -770,7 +770,7 @@ _func_enter_;
 		RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("\n****rtw_survey_event_callback: return a wrong bss ***\n"));
 		return;
 	}
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	/*  update IBSS_network 's timestamp */
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) == true) {
@@ -779,7 +779,7 @@ _func_enter_;
 			unsigned long	irql;
 
 			memcpy(pmlmepriv->cur_network.network.IEs, pnetwork->IEs, 8);
-			_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+			spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 			ibss_wlan = rtw_find_network(&pmlmepriv->scanned_queue,  pnetwork->MacAddress);
 			if (ibss_wlan) {
 				memcpy(ibss_wlan->network.IEs , pnetwork->IEs, 8);
@@ -815,7 +815,7 @@ void rtw_surveydone_event_callback(struct adapter	*adapter, u8 *pbuf)
 	struct mlme_ext_priv *pmlmeext;
 
 _func_enter_;
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if (pmlmepriv->wps_probe_req_ie) {
 		pmlmepriv->wps_probe_req_ie_len = 0;
@@ -925,8 +925,8 @@ static void free_scanqueue(struct	mlme_priv *pmlmepriv)
 _func_enter_;
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_notice_, ("+free_scanqueue\n"));
-	_enter_critical_bh(&scan_queue->lock, &irql0);
-	_enter_critical_bh(&free_queue->lock, &irql);
+	spin_lock_bh(&scan_queue->lock);
+	spin_lock_bh(&free_queue->lock);
 
 	phead = get_list_head(scan_queue);
 	plist = get_next(phead);
@@ -968,7 +968,7 @@ _func_enter_;
 
 		psta = rtw_get_stainfo(&adapter->stapriv, tgt_network->network.MacAddress);
 
-		_enter_critical_bh(&(pstapriv->sta_hash_lock), &irql);
+		spin_lock_bh(&(pstapriv->sta_hash_lock));
 		rtw_free_stainfo(adapter,  psta);
 		_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql);
 	}
@@ -979,7 +979,7 @@ _func_enter_;
 		rtw_free_all_stainfo(adapter);
 
 		psta = rtw_get_bcmc_stainfo(adapter);
-		_enter_critical_bh(&(pstapriv->sta_hash_lock), &irql);
+		spin_lock_bh(&(pstapriv->sta_hash_lock));
 		rtw_free_stainfo(adapter, psta);
 		_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql);
 
@@ -987,7 +987,7 @@ _func_enter_;
 	}
 
 	if (lock_scanned_queue)
-		_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+		spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	pwlan = rtw_find_network(&pmlmepriv->scanned_queue, tgt_network->network.MacAddress);
 	if (pwlan)
@@ -1249,12 +1249,12 @@ _func_enter_;
 		goto ignore_nolock;
 	}
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("\nrtw_joinbss_event_callback!! _enter_critical\n"));
 
 	if (pnetwork->join_res > 0) {
-		_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+		spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 		if (check_fwstate(pmlmepriv, _FW_UNDER_LINKING)) {
 			/* s1. find ptarget_wlan */
 			if (check_fwstate(pmlmepriv, _FW_LINKED)) {
@@ -1267,7 +1267,7 @@ _func_enter_;
 
 					pcur_sta = rtw_get_stainfo(pstapriv, cur_network->network.MacAddress);
 					if (pcur_sta) {
-						_enter_critical_bh(&(pstapriv->sta_hash_lock), &irql2);
+						spin_lock_bh(&(pstapriv->sta_hash_lock));
 						rtw_free_stainfo(adapter,  pcur_sta);
 						_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql2);
 					}
@@ -1449,11 +1449,11 @@ _func_enter_;
 	if (adapter->securitypriv.dot11AuthAlgrthm == dot11AuthAlgrthm_8021X)
 		psta->dot118021XPrivacy = adapter->securitypriv.dot11PrivacyAlgrthm;
 	psta->ieee8021x_blocked = false;
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) ||
 	    (check_fwstate(pmlmepriv, WIFI_ADHOC_STATE))) {
 		if (adapter->stapriv.asoc_sta_count == 2) {
-			_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+			spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 			ptarget_wlan = rtw_find_network(&pmlmepriv->scanned_queue, cur_network->network.MacAddress);
 			if (ptarget_wlan)
 				ptarget_wlan->fixed = true;
@@ -1503,7 +1503,7 @@ _func_enter_;
 
 	mlmeext_sta_del_event_callback(adapter);
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql2);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if (check_fwstate(pmlmepriv, WIFI_STATION_STATE)) {
 		if (pmlmepriv->to_roaming > 0)
@@ -1518,7 +1518,7 @@ _func_enter_;
 
 		rtw_free_assoc_resources(adapter, 1);
 		rtw_indicate_disconnect(adapter);
-		_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+		spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 		/*  remove the network entry in scanned_queue */
 		pwlan = rtw_find_network(&pmlmepriv->scanned_queue, tgt_network->network.MacAddress);
 		if (pwlan) {
@@ -1530,12 +1530,12 @@ _func_enter_;
 	}
 	if (check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE) ||
 	    check_fwstate(pmlmepriv, WIFI_ADHOC_STATE)) {
-		_enter_critical_bh(&(pstapriv->sta_hash_lock), &irql);
+		spin_lock_bh(&(pstapriv->sta_hash_lock));
 		rtw_free_stainfo(adapter,  psta);
 		_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql);
 
 		if (adapter->stapriv.asoc_sta_count == 1) { /* a sta + bc/mc_stainfo (not Ibss_stainfo) */
-			_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+			spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 			/* free old ibss network */
 			pwlan = rtw_find_network(&pmlmepriv->scanned_queue, tgt_network->network.MacAddress);
 			if (pwlan) {
@@ -1594,7 +1594,7 @@ _func_enter_;
 		return;
 
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if (pmlmepriv->to_roaming > 0) { /*  join timeout caused by roaming */
 		while (1) {
@@ -1631,7 +1631,7 @@ void rtw_scan_timeout_handler (struct adapter *adapter)
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 
 	DBG_88E(FUNC_ADPT_FMT" fw_state=%x\n", FUNC_ADPT_ARG(adapter), get_fwstate(pmlmepriv));
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	_clr_fwstate_(pmlmepriv, _FW_UNDER_SURVEY);
 	_exit_critical_bh(&pmlmepriv->lock, &irql);
 	rtw_indicate_scan_done(adapter, true);
@@ -1772,7 +1772,7 @@ int rtw_select_and_join_from_scanned_queue(struct mlme_priv *pmlmepriv)
 
 _func_enter_;
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 	phead = get_list_head(queue);
 	adapter = (struct adapter *)pmlmepriv->nic_hdl;
 	pmlmepriv->pscanned = get_next(phead);
@@ -2397,7 +2397,7 @@ void rtw_roaming(struct adapter *padapter, struct wlan_network *tgt_network)
 	unsigned long irql;
 	struct mlme_priv	*pmlmepriv = &padapter->mlmepriv;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	_rtw_roaming(padapter, tgt_network);
 	_exit_critical_bh(&pmlmepriv->lock, &irql);
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 6519a7b..ccbf59d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -817,7 +817,7 @@ unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
 		pstat->state = WIFI_FW_AUTH_NULL;
 		pstat->auth_seq = 0;
 	} else {
-		_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+		spin_lock_bh(&pstapriv->asoc_list_lock);
 		if (!rtw_is_list_empty(&pstat->asoc_list)) {
 			rtw_list_delete(&pstat->asoc_list);
 			pstapriv->asoc_list_cnt--;
@@ -829,7 +829,7 @@ unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
 		}
 	}
 
-	_enter_critical_bh(&pstapriv->auth_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->auth_list_lock);
 	if (rtw_is_list_empty(&pstat->auth_list)) {
 		rtw_list_insert_tail(&pstat->auth_list, &pstapriv->auth_list);
 		pstapriv->auth_list_cnt++;
@@ -1408,14 +1408,14 @@ unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 	pstat->state &= (~WIFI_FW_ASSOC_STATE);
 	pstat->state |= WIFI_FW_ASSOC_SUCCESS;
 
-	_enter_critical_bh(&pstapriv->auth_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->auth_list_lock);
 	if (!rtw_is_list_empty(&pstat->auth_list)) {
 		rtw_list_delete(&pstat->auth_list);
 		pstapriv->auth_list_cnt--;
 	}
 	_exit_critical_bh(&pstapriv->auth_list_lock, &irqL);
 
-	_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->asoc_list_lock);
 	if (rtw_is_list_empty(&pstat->asoc_list)) {
 		pstat->expire_to = pstapriv->expire_to;
 		rtw_list_insert_tail(&pstat->asoc_list, &pstapriv->asoc_list);
@@ -1601,7 +1601,7 @@ unsigned int OnDeAuth(struct adapter *padapter, union recv_frame *precv_frame)
 		if (psta) {
 			u8 updated = 0;
 
-			_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+			spin_lock_bh(&pstapriv->asoc_list_lock);
 			if (!rtw_is_list_empty(&psta->asoc_list)) {
 				rtw_list_delete(&psta->asoc_list);
 				pstapriv->asoc_list_cnt--;
@@ -1658,10 +1658,6 @@ unsigned int OnDisassoc(struct adapter *padapter, union recv_frame *precv_frame)
 		struct sta_info *psta;
 		struct sta_priv *pstapriv = &padapter->stapriv;
 
-		/* _enter_critical_bh(&(pstapriv->sta_hash_lock), &irqL); */
-		/* rtw_free_stainfo(padapter, psta); */
-		/* _exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL); */
-
 		DBG_88E_LEVEL(_drv_always_, "ap recv disassoc reason code(%d) sta:%pM\n",
 			      reason, GetAddr2Ptr(pframe));
 
@@ -1669,7 +1665,7 @@ unsigned int OnDisassoc(struct adapter *padapter, union recv_frame *precv_frame)
 		if (psta) {
 			u8 updated = 0;
 
-			_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+			spin_lock_bh(&pstapriv->asoc_list_lock);
 			if (!rtw_is_list_empty(&psta->asoc_list)) {
 				rtw_list_delete(&psta->asoc_list);
 				pstapriv->asoc_list_cnt--;
@@ -4505,7 +4501,7 @@ void issue_beacon(struct adapter *padapter, int timeout_ms)
 		return;
 	}
 #if defined (CONFIG_88EU_AP_MODE)
-	_enter_critical_bh(&pmlmepriv->bcn_update_lock, &irqL);
+	spin_lock_bh(&pmlmepriv->bcn_update_lock);
 #endif /* if defined (CONFIG_88EU_AP_MODE) */
 
 	/* update attribute */
@@ -6231,7 +6227,7 @@ static void issue_action_BSSCoexistPacket(struct adapter *padapter)
 	if (pmlmepriv->num_sta_no_ht > 0) {
 		int i;
 
-		_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+		spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 		phead = get_list_head(queue);
 		plist = get_next(phead);
@@ -8378,7 +8374,7 @@ u8 tx_beacon_hdl(struct adapter *padapter, unsigned char *pbuf)
 
 		if ((pstapriv->tim_bitmap&BIT(0)) && (psta_bmc->sleepq_len > 0)) {
 			rtw_msleep_os(10);/*  10ms, ATIM(HIQ) Windows */
-			_enter_critical_bh(&psta_bmc->sleep_q.lock, &irqL);
+			spin_lock_bh(&psta_bmc->sleep_q.lock);
 
 			xmitframe_phead = get_list_head(&psta_bmc->sleep_q);
 			xmitframe_plist = get_next(xmitframe_phead);
@@ -8403,7 +8399,7 @@ u8 tx_beacon_hdl(struct adapter *padapter, unsigned char *pbuf)
 				_exit_critical_bh(&psta_bmc->sleep_q.lock, &irqL);
 				if (rtw_hal_xmit(padapter, pxmitframe))
 					rtw_os_xmit_complete(padapter, pxmitframe);
-				_enter_critical_bh(&psta_bmc->sleep_q.lock, &irqL);
+				spin_lock_bh(&psta_bmc->sleep_q.lock);
 			}
 			_exit_critical_bh(&psta_bmc->sleep_q.lock, &irqL);
 		}
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp.c b/drivers/staging/rtl8188eu/core/rtw_mp.c
index 0204639..c9ec558 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp.c
@@ -379,7 +379,7 @@ s32 mp_start_test(struct adapter *padapter)
 	else
 		bssid.Length = length;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if (check_fwstate(pmlmepriv, WIFI_MP_STATE) == true)
 		goto end_of_mp_start_test;
@@ -443,7 +443,7 @@ void mp_stop_test(struct adapter *padapter)
 
 	if (pmppriv->mode == MP_ON) {
 		pmppriv->bSetTxPower = 0;
-		_enter_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_lock_bh(&pmlmepriv->lock);
 		if (check_fwstate(pmlmepriv, WIFI_MP_STATE) == false)
 			goto end_of_mp_stop_test;
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index f46cab1..e94321e 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -56,7 +56,7 @@ static u32 go_add_group_info_attr(struct wifidirect_info *pwdinfo, u8 *pbuf)
 	pstart = pdata_attr;
 	pcur = pdata_attr;
 
-	_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
 	plist = get_next(phead);
 
@@ -980,7 +980,7 @@ u32 process_p2p_devdisc_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 					unsigned long irqL;
 					struct list_head *phead, *plist;
 
-					_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+					spin_lock_bh(&pstapriv->asoc_list_lock);
 					phead = &pstapriv->asoc_list;
 					plist = get_next(phead);
 
@@ -1509,10 +1509,6 @@ _func_enter_;
 
 	rtw_p2p_set_state(pwdinfo, P2P_STATE_FIND_PHASE_SEARCH);
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
-
-
 _func_exit_;
 }
 
@@ -1839,7 +1835,7 @@ static void pre_tx_scan_timer_process(void *FunctionContext)
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE))
 		return;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_lock_bh(&pmlmepriv->lock);
 
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_TX_PROVISION_DIS_REQ)) {
 		if (pwdinfo->tx_prov_disc_info.benable) {	/*	the provision discovery request frame is trigger to send or not */
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 9f0f30f7..32ea9a2 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -184,7 +184,7 @@ union recv_frame *rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 	unsigned long irqL;
 	union recv_frame  *precvframe;
 
-	_enter_critical_bh(&pfree_recv_queue->lock, &irqL);
+	spin_lock_bh(&pfree_recv_queue->lock);
 
 	precvframe = _rtw_alloc_recvframe(pfree_recv_queue);
 
@@ -217,7 +217,7 @@ _func_enter_;
 		precvframe->u.hdr.pkt = NULL;
 	}
 
-	_enter_critical_bh(&pfree_recv_queue->lock, &irqL);
+	spin_lock_bh(&pfree_recv_queue->lock);
 
 	rtw_list_delete(&(precvframe->u.hdr.list));
 
@@ -262,7 +262,7 @@ int rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue)
 	int ret;
 	unsigned long irqL;
 
-	_enter_critical_bh(&queue->lock, &irqL);
+	spin_lock_bh(&queue->lock);
 	ret = _rtw_enqueue_recvframe(precvframe, queue);
 	_exit_critical_bh(&queue->lock, &irqL);
 
@@ -318,7 +318,7 @@ int rtw_enqueue_recvbuf_to_head(struct recv_buf *precvbuf, struct __queue *queue
 {
 	unsigned long irqL;
 
-	_enter_critical_bh(&queue->lock, &irqL);
+	spin_lock_bh(&queue->lock);
 
 	rtw_list_delete(&precvbuf->list);
 	rtw_list_insert_head(&precvbuf->list, get_list_head(queue));
@@ -1112,7 +1112,7 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 			struct list_head *xmitframe_plist, *xmitframe_phead;
 			struct xmit_frame *pxmitframe = NULL;
 
-			_enter_critical_bh(&psta->sleep_q.lock, &irqL);
+			spin_lock_bh(&psta->sleep_q.lock);
 
 			xmitframe_phead = get_list_head(&psta->sleep_q);
 			xmitframe_plist = get_next(xmitframe_phead);
@@ -1136,7 +1136,7 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 				_exit_critical_bh(&psta->sleep_q.lock, &irqL);
 				if (rtw_hal_xmit(padapter, pxmitframe) == true)
 					rtw_os_xmit_complete(padapter, pxmitframe);
-				_enter_critical_bh(&psta->sleep_q.lock, &irqL);
+				spin_lock_bh(&psta->sleep_q.lock);
 
 				if (psta->sleepq_len == 0) {
 					pstapriv->tim_bitmap &= ~BIT(psta->aid);
@@ -1984,7 +1984,7 @@ static int recv_indicatepkt_reorder(struct adapter *padapter, union recv_frame *
 		}
 	}
 
-	_enter_critical_bh(&ppending_recvframe_queue->lock, &irql);
+	spin_lock_bh(&ppending_recvframe_queue->lock);
 
 	RT_TRACE(_module_rtl871x_recv_c_, _drv_notice_,
 		 ("recv_indicatepkt_reorder: indicate=%d seq=%d\n",
@@ -2043,7 +2043,7 @@ void rtw_reordering_ctrl_timeout_handler(void *pcontext)
 	if (padapter->bDriverStopped || padapter->bSurpriseRemoved)
 		return;
 
-	_enter_critical_bh(&ppending_recvframe_queue->lock, &irql);
+	spin_lock_bh(&ppending_recvframe_queue->lock);
 
 	if (recv_indicatepkts_in_order(padapter, preorder_ctrl, true) == true)
 		_set_timer(&preorder_ctrl->reordering_ctrl_timer, REORDER_WAIT_TIME);
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index cd3c9a7..2d805c5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -197,7 +197,7 @@ void rtw_mfree_all_stainfo(struct sta_priv *pstapriv)
 
 _func_enter_;
 
-	_enter_critical_bh(&pstapriv->sta_hash_lock, &irql);
+	spin_lock_bh(&pstapriv->sta_hash_lock);
 
 	phead = get_list_head(&pstapriv->free_sta_queue);
 	plist = get_next(phead);
@@ -246,7 +246,7 @@ u32	_rtw_free_sta_priv(struct	sta_priv *pstapriv)
 _func_enter_;
 	if (pstapriv) {
 		/*	delete all reordering_ctrl_timer		*/
-		_enter_critical_bh(&pstapriv->sta_hash_lock, &irql);
+		spin_lock_bh(&pstapriv->sta_hash_lock);
 		for (index = 0; index < NUM_STA; index++) {
 			phead = &(pstapriv->sta_hash[index]);
 			plist = get_next(phead);
@@ -290,7 +290,7 @@ _func_enter_;
 
 	pfree_sta_queue = &pstapriv->free_sta_queue;
 
-	_enter_critical_bh(&(pfree_sta_queue->lock), &irql);
+	spin_lock_bh(&(pfree_sta_queue->lock));
 
 	if (_rtw_queue_empty(pfree_sta_queue) == true) {
 		_exit_critical_bh(&(pfree_sta_queue->lock), &irql);
@@ -310,7 +310,7 @@ _func_enter_;
 		}
 		phash_list = &(pstapriv->sta_hash[index]);
 
-		_enter_critical_bh(&(pstapriv->sta_hash_lock), &irql2);
+		spin_lock_bh(&(pstapriv->sta_hash_lock));
 
 		rtw_list_insert_tail(&psta->hash_list, phash_list);
 
@@ -384,7 +384,7 @@ _func_enter_;
 
 	pstaxmitpriv = &psta->sta_xmitpriv;
 
-	_enter_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_lock_bh(&pxmitpriv->lock);
 
 	rtw_free_xmitframe_queue(pxmitpriv, &psta->sleep_q);
 	psta->sleepq_len = 0;
@@ -431,7 +431,7 @@ _func_enter_;
 
 		ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
 
-		_enter_critical_bh(&ppending_recvframe_queue->lock, &irql);
+		spin_lock_bh(&ppending_recvframe_queue->lock);
 
 		phead =		get_list_head(ppending_recvframe_queue);
 		plist = get_next(phead);
@@ -454,7 +454,7 @@ _func_enter_;
 
 #ifdef CONFIG_88EU_AP_MODE
 
-	_enter_critical_bh(&pstapriv->auth_list_lock, &irql0);
+	spin_lock_bh(&pstapriv->auth_list_lock);
 	if (!rtw_is_list_empty(&psta->auth_list)) {
 		rtw_list_delete(&psta->auth_list);
 		pstapriv->auth_list_cnt--;
@@ -485,7 +485,7 @@ _func_enter_;
 
 #endif	/*  CONFIG_88EU_AP_MODE */
 
-	_enter_critical_bh(&(pfree_sta_queue->lock), &irql0);
+	spin_lock_bh(&(pfree_sta_queue->lock));
 	rtw_list_insert_tail(&psta->list, get_list_head(pfree_sta_queue));
 	_exit_critical_bh(&(pfree_sta_queue->lock), &irql0);
 
@@ -511,7 +511,7 @@ _func_enter_;
 	if (pstapriv->asoc_sta_count == 1)
 		goto exit;
 
-	_enter_critical_bh(&pstapriv->sta_hash_lock, &irql);
+	spin_lock_bh(&pstapriv->sta_hash_lock);
 
 	for (index = 0; index < NUM_STA; index++) {
 		phead = &(pstapriv->sta_hash[index]);
@@ -556,7 +556,7 @@ _func_enter_;
 
 	index = wifi_mac_hash(addr);
 
-	_enter_critical_bh(&pstapriv->sta_hash_lock, &irql);
+	spin_lock_bh(&pstapriv->sta_hash_lock);
 
 	phead = &(pstapriv->sta_hash[index]);
 	plist = get_next(phead);
@@ -625,7 +625,7 @@ u8 rtw_access_ctrl(struct adapter *padapter, u8 *mac_addr)
 	struct wlan_acl_pool *pacl_list = &pstapriv->acl_list;
 	struct __queue *pacl_node_q = &pacl_list->acl_node_q;
 
-	_enter_critical_bh(&(pacl_node_q->lock), &irql);
+	spin_lock_bh(&(pacl_node_q->lock));
 	phead = get_list_head(pacl_node_q);
 	plist = get_next(phead);
 	while ((!rtw_end_of_queue_search(phead, plist))) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 01662f7..76de05f 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -1429,7 +1429,7 @@ struct xmit_frame *rtw_alloc_xmitframe(struct xmit_priv *pxmitpriv)/* _queue *pf
 
 _func_enter_;
 
-	_enter_critical_bh(&pfree_xmit_queue->lock, &irql);
+	spin_lock_bh(&pfree_xmit_queue->lock);
 
 	if (_rtw_queue_empty(pfree_xmit_queue) == true) {
 		RT_TRACE(_module_rtl871x_xmit_c_, _drv_info_, ("rtw_alloc_xmitframe:%d\n", pxmitpriv->free_xmitframe_cnt));
@@ -1485,7 +1485,7 @@ _func_enter_;
 		goto exit;
 	}
 
-	_enter_critical_bh(&pfree_xmit_queue->lock, &irql);
+	spin_lock_bh(&pfree_xmit_queue->lock);
 
 	rtw_list_delete(&pxmitframe->list);
 
@@ -1519,7 +1519,7 @@ void rtw_free_xmitframe_queue(struct xmit_priv *pxmitpriv, struct __queue *pfram
 
 _func_enter_;
 
-	_enter_critical_bh(&(pframequeue->lock), &irql);
+	spin_lock_bh(&(pframequeue->lock));
 
 	phead = get_list_head(pframequeue);
 	plist = get_next(phead);
@@ -1591,7 +1591,7 @@ _func_enter_;
 			inx[j] = pxmitpriv->wmm_para_seq[j];
 	}
 
-	_enter_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_lock_bh(&pxmitpriv->lock);
 
 	for (i = 0; i < entry; i++) {
 		phwxmit = phwxmit_i + inx[i];
@@ -1762,7 +1762,7 @@ static int rtw_br_client_tx(struct adapter *padapter, struct sk_buff **pskb)
 	rcu_read_lock();
 	br_port = rcu_dereference(padapter->pnetdev->rx_handler_data);
 	rcu_read_unlock();
-	_enter_critical_bh(&padapter->br_ext_lock, &irql);
+	spin_lock_bh(&padapter->br_ext_lock);
 	if (!(skb->data[0] & 1) && br_port &&
 	    memcmp(skb->data+MACADDRLEN, padapter->br_mac, MACADDRLEN) &&
 	    *((__be16 *)(skb->data+MACADDRLEN*2)) != __constant_htons(ETH_P_8021Q) &&
@@ -1972,7 +1972,7 @@ s32 rtw_xmit(struct adapter *padapter, struct sk_buff **ppkt)
 	do_queue_select(padapter, &pxmitframe->attrib);
 
 #ifdef CONFIG_88EU_AP_MODE
-	_enter_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_lock_bh(&pxmitpriv->lock);
 	if (xmitframe_enqueue_for_sleeping_sta(padapter, pxmitframe)) {
 		_exit_critical_bh(&pxmitpriv->lock, &irql0);
 		return 1;
@@ -2016,7 +2016,7 @@ int xmitframe_enqueue_for_sleeping_sta(struct adapter *padapter, struct xmit_fra
 	}
 
 	if (bmcst) {
-		_enter_critical_bh(&psta->sleep_q.lock, &irql);
+		spin_lock_bh(&psta->sleep_q.lock);
 
 		if (pstapriv->sta_dz_bitmap) {/* if any one sta is in ps mode */
 			rtw_list_delete(&pxmitframe->list);
@@ -2038,7 +2038,7 @@ int xmitframe_enqueue_for_sleeping_sta(struct adapter *padapter, struct xmit_fra
 		return ret;
 	}
 
-	_enter_critical_bh(&psta->sleep_q.lock, &irql);
+	spin_lock_bh(&psta->sleep_q.lock);
 
 	if (psta->state&WIFI_SLEEP_STATE) {
 		u8 wmmps_ac = 0;
@@ -2132,7 +2132,7 @@ void stop_sta_xmit(struct adapter *padapter, struct sta_info *psta)
 	/* for BC/MC Frames */
 	psta_bmc = rtw_get_bcmc_stainfo(padapter);
 
-	_enter_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_lock_bh(&pxmitpriv->lock);
 
 	psta->state |= WIFI_SLEEP_STATE;
 
@@ -2167,7 +2167,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 	struct xmit_frame *pxmitframe = NULL;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 
-	_enter_critical_bh(&psta->sleep_q.lock, &irql);
+	spin_lock_bh(&psta->sleep_q.lock);
 
 	xmitframe_phead = get_list_head(&psta->sleep_q);
 	xmitframe_plist = get_next(xmitframe_phead);
@@ -2221,7 +2221,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 		_exit_critical_bh(&psta->sleep_q.lock, &irql);
 		if (rtw_hal_xmit(padapter, pxmitframe))
 			rtw_os_xmit_complete(padapter, pxmitframe);
-		_enter_critical_bh(&psta->sleep_q.lock, &irql);
+		spin_lock_bh(&psta->sleep_q.lock);
 	}
 
 	if (psta->sleepq_len == 0) {
@@ -2248,7 +2248,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 		return;
 
 	if ((pstapriv->sta_dz_bitmap&0xfffe) == 0x0) { /* no any sta in ps mode */
-		_enter_critical_bh(&psta_bmc->sleep_q.lock, &irql);
+		spin_lock_bh(&psta_bmc->sleep_q.lock);
 
 		xmitframe_phead = get_list_head(&psta_bmc->sleep_q);
 		xmitframe_plist = get_next(xmitframe_phead);
@@ -2271,7 +2271,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 			_exit_critical_bh(&psta_bmc->sleep_q.lock, &irql);
 			if (rtw_hal_xmit(padapter, pxmitframe))
 				rtw_os_xmit_complete(padapter, pxmitframe);
-			_enter_critical_bh(&psta_bmc->sleep_q.lock, &irql);
+			spin_lock_bh(&psta_bmc->sleep_q.lock);
 		}
 
 		if (psta_bmc->sleepq_len == 0) {
@@ -2296,7 +2296,7 @@ void xmit_delivery_enabled_frames(struct adapter *padapter, struct sta_info *pst
 	struct xmit_frame *pxmitframe = NULL;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 
-	_enter_critical_bh(&psta->sleep_q.lock, &irql);
+	spin_lock_bh(&psta->sleep_q.lock);
 
 	xmitframe_phead = get_list_head(&psta->sleep_q);
 	xmitframe_plist = get_next(xmitframe_phead);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
index 8f43f49..fa692c4 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
@@ -535,7 +535,7 @@ s32 rtl8188eu_xmitframe_complete(struct adapter *adapt, struct xmit_priv *pxmitp
 		phwxmit = pxmitpriv->hwxmits + 2;
 		break;
 	}
-	_enter_critical_bh(&pxmitpriv->lock, &irql);
+	spin_lock_bh(&pxmitpriv->lock);
 
 	xmitframe_phead = get_list_head(&ptxservq->sta_pending);
 	xmitframe_plist = get_next(xmitframe_phead);
@@ -648,7 +648,7 @@ static s32 pre_xmitframe(struct adapter *adapt, struct xmit_frame *pxmitframe)
 	struct pkt_attrib *pattrib = &pxmitframe->attrib;
 	struct mlme_priv *pmlmepriv = &adapt->mlmepriv;
 
-	_enter_critical_bh(&pxmitpriv->lock, &irql);
+	spin_lock_bh(&pxmitpriv->lock);
 
 	if (rtw_txframes_sta_ac_pending(adapt, pattrib) > 0)
 		goto enqueue;
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index ba790f0..894514e 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -97,11 +97,6 @@ static inline void _exit_critical_ex(spinlock_t *plock, unsigned long *pirqL)
 	spin_unlock_irqrestore(plock, *pirqL);
 }
 
-static inline void _enter_critical_bh(spinlock_t *plock, unsigned long *pirqL)
-{
-	spin_lock_bh(plock);
-}
-
 static inline void _exit_critical_bh(spinlock_t *plock, unsigned long *pirqL)
 {
 	spin_unlock_bh(plock);
diff --git a/drivers/staging/rtl8188eu/include/rtw_mlme.h b/drivers/staging/rtl8188eu/include/rtw_mlme.h
index 4a7143e..ff4d686 100644
--- a/drivers/staging/rtl8188eu/include/rtw_mlme.h
+++ b/drivers/staging/rtl8188eu/include/rtw_mlme.h
@@ -528,7 +528,7 @@ static inline void clr_fwstate(struct mlme_priv *pmlmepriv, int state)
 {
 	unsigned long irql;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	if (check_fwstate(pmlmepriv, state) == true)
 		pmlmepriv->fw_state ^= state;
 	_exit_critical_bh(&pmlmepriv->lock, &irql);
@@ -538,7 +538,7 @@ static inline void clr_fwstate_ex(struct mlme_priv *pmlmepriv, int state)
 {
 	unsigned long irql;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	_clr_fwstate_(pmlmepriv, state);
 	_exit_critical_bh(&pmlmepriv->lock, &irql);
 }
@@ -547,7 +547,7 @@ static inline void up_scanned_network(struct mlme_priv *pmlmepriv)
 {
 	unsigned long irql;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	pmlmepriv->num_of_scanned++;
 	_exit_critical_bh(&pmlmepriv->lock, &irql);
 }
@@ -556,7 +556,7 @@ static inline void down_scanned_network(struct mlme_priv *pmlmepriv)
 {
 	unsigned long irql;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	pmlmepriv->num_of_scanned--;
 	_exit_critical_bh(&pmlmepriv->lock, &irql);
 }
@@ -565,7 +565,7 @@ static inline void set_scanned_network_val(struct mlme_priv *pmlmepriv, int val)
 {
 	unsigned long irql;
 
-	_enter_critical_bh(&pmlmepriv->lock, &irql);
+	spin_lock_bh(&pmlmepriv->lock);
 	pmlmepriv->num_of_scanned = val;
 	_exit_critical_bh(&pmlmepriv->lock, &irql);
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index 1f39249..5f6f7eb 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -1137,7 +1137,7 @@ static int rtw_wx_set_wap(struct net_device *dev,
 	}
 
 	authmode = padapter->securitypriv.ndisauthtype;
-	_enter_critical_bh(&queue->lock, &irqL);
+	spin_lock_bh(&queue->lock);
 	phead = get_list_head(queue);
 	pmlmepriv->pscanned = get_next(phead);
 
@@ -1321,7 +1321,7 @@ _func_enter_;
 
 			DBG_88E("IW_SCAN_THIS_ESSID, ssid =%s, len =%d\n", req->essid, req->essid_len);
 
-			_enter_critical_bh(&pmlmepriv->lock, &irqL);
+			spin_lock_bh(&pmlmepriv->lock);
 
 			_status = rtw_sitesurvey_cmd(padapter, ssid, 1, NULL, 0);
 
@@ -1440,7 +1440,7 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 			break;
 	}
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -1532,7 +1532,7 @@ static int rtw_wx_set_essid(struct net_device *dev,
 		src_ssid = ndis_ssid.Ssid;
 
 		RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_info_, ("rtw_wx_set_essid: ssid =[%s]\n", src_ssid));
-		_enter_critical_bh(&queue->lock, &irqL);
+		spin_lock_bh(&queue->lock);
 	       phead = get_list_head(queue);
 	      pmlmepriv->pscanned = get_next(phead);
 
@@ -2609,7 +2609,7 @@ static int rtw_get_ap_info(struct net_device *dev,
 		goto exit;
 	}
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3113,7 +3113,7 @@ static int rtw_p2p_get_wps_configmethod(struct net_device *dev,
 	for (jj = 0, kk = 0; jj < ETH_ALEN; jj++, kk += 3)
 		peerMAC[jj] = key_2char2num(peerMACStr[kk], peerMACStr[kk + 1]);
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3186,7 +3186,7 @@ static int rtw_p2p_get_go_device_address(struct net_device *dev,
 	for (jj = 0, kk = 0; jj < ETH_ALEN; jj++, kk += 3)
 		peerMAC[jj] = key_2char2num(peerMACStr[kk], peerMACStr[kk + 1]);
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3271,7 +3271,7 @@ static int rtw_p2p_get_device_type(struct net_device *dev,
 	for (jj = 0, kk = 0; jj < ETH_ALEN; jj++, kk += 3)
 		peerMAC[jj] = key_2char2num(peerMACStr[kk], peerMACStr[kk + 1]);
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3351,7 +3351,7 @@ static int rtw_p2p_get_device_name(struct net_device *dev,
 	for (jj = 0, kk = 0; jj < ETH_ALEN; jj++, kk += 3)
 		peerMAC[jj] = key_2char2num(peerMACStr[kk], peerMACStr[kk + 1]);
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3423,7 +3423,7 @@ static int rtw_p2p_get_invitation_procedure(struct net_device *dev,
 	for (jj = 0, kk = 0; jj < ETH_ALEN; jj++, kk += 3)
 		peerMAC[jj] = key_2char2num(peerMACStr[kk], peerMACStr[kk + 1]);
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3506,7 +3506,7 @@ static int rtw_p2p_connect(struct net_device *dev,
 	for (jj = 0, kk = 0; jj < ETH_ALEN; jj++, kk += 3)
 		peerMAC[jj] = key_2char2num(extra[kk], extra[kk + 1]);
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3602,7 +3602,7 @@ static int rtw_p2p_invite_req(struct net_device *dev,
 	for (jj = 0, kk = 0; jj < ETH_ALEN; jj++, kk += 3)
 		pinvite_req_info->peer_macaddr[jj] = key_2char2num(extra[kk], extra[kk + 1]);
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -3753,7 +3753,7 @@ static int rtw_p2p_prov_disc(struct net_device *dev,
 		return ret;
 	}
 
-	_enter_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
 	plist = get_next(phead);
@@ -4448,7 +4448,7 @@ static int rtw_dbg_port(struct net_device *dev,
 #ifdef CONFIG_88EU_AP_MODE
 				DBG_88E("sta_dz_bitmap = 0x%x, tim_bitmap = 0x%x\n", pstapriv->sta_dz_bitmap, pstapriv->tim_bitmap);
 #endif
-				_enter_critical_bh(&pstapriv->sta_hash_lock, &irqL);
+				spin_lock_bh(&pstapriv->sta_hash_lock);
 
 				for (i = 0; i < NUM_STA; i++) {
 					phead = &(pstapriv->sta_hash[i]);
@@ -5271,7 +5271,7 @@ static int rtw_del_sta(struct net_device *dev, struct ieee_param *param)
 
 	psta = rtw_get_stainfo(pstapriv, param->sta_addr);
 	if (psta) {
-		_enter_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+		spin_lock_bh(&pstapriv->asoc_list_lock);
 		if (!rtw_is_list_empty(&psta->asoc_list)) {
 			rtw_list_delete(&psta->asoc_list);
 			pstapriv->asoc_list_cnt--;
diff --git a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
index 2e586c0..4fd5869 100644
--- a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
@@ -164,7 +164,7 @@ void rtw_os_xmit_schedule(struct adapter *padapter)
 
 	pxmitpriv = &padapter->xmitpriv;
 
-	_enter_critical_bh(&pxmitpriv->lock, &irql);
+	spin_lock_bh(&pxmitpriv->lock);
 
 	if (rtw_txframes_pending(padapter))
 		tasklet_hi_schedule(&pxmitpriv->xmit_tasklet);
@@ -200,7 +200,7 @@ static int rtw_mlcst2unicst(struct adapter *padapter, struct sk_buff *skb)
 	struct sta_info *psta = NULL;
 	s32	res;
 
-	_enter_critical_bh(&pstapriv->asoc_list_lock, &irql);
+	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
 	plist = get_next(phead);
 
-- 
1.8.4
