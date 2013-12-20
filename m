From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/11] staging: r8188eu: Remove wrapper around spin_unlock_bh
Date: Thu, 19 Dec 2013 22:38:35 -0600
Message-ID: <1387514323-4486-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:60530 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3LTEkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:40:17 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so2028569pde.14
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:40:16 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this change, a number of variables for storing flags are no longer used.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c           | 38 +++++------
 drivers/staging/rtl8188eu/core/rtw_br_ext.c       | 28 +++-----
 drivers/staging/rtl8188eu/core/rtw_cmd.c          | 15 ++---
 drivers/staging/rtl8188eu/core/rtw_debug.c        |  2 +-
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c    | 20 ++----
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 82 +++++++++--------------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 21 +++---
 drivers/staging/rtl8188eu/core/rtw_mp.c           |  9 +--
 drivers/staging/rtl8188eu/core/rtw_p2p.c          | 11 +--
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 29 +++-----
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      | 31 ++++-----
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 37 +++++-----
 drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c    |  8 +--
 drivers/staging/rtl8188eu/include/osdep_service.h |  5 --
 drivers/staging/rtl8188eu/include/rtw_mlme.h      | 20 ++----
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c    | 50 +++++---------
 drivers/staging/rtl8188eu/os_dep/xmit_linux.c     |  8 +--
 17 files changed, 156 insertions(+), 258 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index 1fa6262..d86f671 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -64,7 +64,7 @@ void free_mlme_ap_info(struct adapter *padapter)
 	psta = rtw_get_bcmc_stainfo(padapter);
 	spin_lock_bh(&(pstapriv->sta_hash_lock));
 	rtw_free_stainfo(padapter, psta);
-	_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+	spin_unlock_bh(&(pstapriv->sta_hash_lock));
 
 	_rtw_spinlock_free(&pmlmepriv->bcn_update_lock);
 }
@@ -305,18 +305,18 @@ void	expire_timeout_chk(struct adapter *padapter)
 				DBG_88E("auth expire %6ph\n",
 					psta->hwaddr);
 
-				_exit_critical_bh(&pstapriv->auth_list_lock, &irqL);
+				spin_unlock_bh(&pstapriv->auth_list_lock);
 
 				spin_lock_bh(&(pstapriv->sta_hash_lock));
 				rtw_free_stainfo(padapter, psta);
-				_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+				spin_unlock_bh(&(pstapriv->sta_hash_lock));
 
 				spin_lock_bh(&pstapriv->auth_list_lock);
 			}
 		}
 
 	}
-	_exit_critical_bh(&pstapriv->auth_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->auth_list_lock);
 
 	psta = NULL;
 
@@ -387,7 +387,7 @@ void	expire_timeout_chk(struct adapter *padapter)
 		}
 	}
 
-	_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 	if (chk_alive_num) {
 		u8 backup_oper_channel = 0;
@@ -428,7 +428,7 @@ void	expire_timeout_chk(struct adapter *padapter)
 			rtw_list_delete(&psta->asoc_list);
 			pstapriv->asoc_list_cnt--;
 			updated = ap_free_sta(padapter, psta, true, WLAN_REASON_DEAUTH_LEAVING);
-			_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+			spin_unlock_bh(&pstapriv->asoc_list_lock);
 		}
 
 		if (backup_oper_channel > 0) /* back to the original operation channel */
@@ -606,7 +606,7 @@ static void update_bmc_sta(struct adapter *padapter)
 
 		spin_lock_bh(&psta->lock);
 		psta->state = _FW_LINKED;
-		_exit_critical_bh(&psta->lock, &irqL);
+		spin_unlock_bh(&psta->lock);
 
 	} else {
 		DBG_88E("add_RATid_bmc_sta error!\n");
@@ -681,7 +681,7 @@ void update_sta_info_apmode(struct adapter *padapter, struct sta_info *psta)
 
 	spin_lock_bh(&psta->lock);
 	psta->state |= _FW_LINKED;
-	_exit_critical_bh(&psta->lock, &irqL);
+	spin_unlock_bh(&psta->lock);
 }
 
 static void update_hw_ht_param(struct adapter *padapter)
@@ -1166,7 +1166,7 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 		}
 	}
 
-	_exit_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_unlock_bh(&(pacl_node_q->lock));
 
 	if (added)
 		return ret;
@@ -1193,7 +1193,7 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 
 	DBG_88E("%s, acl_num =%d\n", __func__, pacl_list->num);
 
-	_exit_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_unlock_bh(&(pacl_node_q->lock));
 
 	return ret;
 }
@@ -1230,7 +1230,7 @@ int rtw_acl_remove_sta(struct adapter *padapter, u8 *addr)
 		}
 	}
 
-	_exit_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_unlock_bh(&(pacl_node_q->lock));
 
 	DBG_88E("%s, acl_num =%d\n", __func__, pacl_list->num);
 	return ret;
@@ -1416,7 +1416,7 @@ void update_beacon(struct adapter *padapter, u8 ie_id, u8 *oui, u8 tx)
 
 	pmlmepriv->update_bcn = true;
 
-	_exit_critical_bh(&pmlmepriv->bcn_update_lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->bcn_update_lock);
 
 	if (tx)
 		set_tx_beacon_cmd(padapter);
@@ -1523,7 +1523,7 @@ void associated_clients_update(struct adapter *padapter, u8 updated)
 
 			VCS_update(padapter, psta);
 		}
-		_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+		spin_unlock_bh(&pstapriv->asoc_list_lock);
 	}
 }
 
@@ -1755,7 +1755,7 @@ u8 ap_free_sta(struct adapter *padapter, struct sta_info *psta,
 
 	spin_lock_bh(&psta->lock);
 	psta->state &= ~_FW_LINKED;
-	_exit_critical_bh(&psta->lock, &irqL);
+	spin_unlock_bh(&psta->lock);
 
 	rtw_indicate_sta_disassoc_event(padapter, psta);
 
@@ -1765,7 +1765,7 @@ u8 ap_free_sta(struct adapter *padapter, struct sta_info *psta,
 
 	spin_lock_bh(&(pstapriv->sta_hash_lock));
 	rtw_free_stainfo(padapter, psta);
-	_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+	spin_unlock_bh(&(pstapriv->sta_hash_lock));
 
 	return beacon_updated;
 }
@@ -1799,7 +1799,7 @@ int rtw_ap_inform_ch_switch(struct adapter *padapter, u8 new_ch, u8 ch_offset)
 		issue_action_spct_ch_switch(padapter, psta->hwaddr, new_ch, ch_offset);
 		psta->expire_to = ((pstapriv->expire_to * 2) > 5) ? 5 : (pstapriv->expire_to * 2);
 	}
-	_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 	issue_action_spct_ch_switch(padapter, bc_addr, new_ch, ch_offset);
 
@@ -1837,7 +1837,7 @@ int rtw_sta_flush(struct adapter *padapter)
 
 		ap_free_sta(padapter, psta, true, WLAN_REASON_DEAUTH_LEAVING);
 	}
-	_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 
 	issue_deauth(padapter, bc_addr, WLAN_REASON_DEAUTH_LEAVING);
@@ -1969,7 +1969,7 @@ void stop_ap_mode(struct adapter *padapter)
 			pacl_list->num--;
 		}
 	}
-	_exit_critical_bh(&(pacl_node_q->lock), &irqL);
+	spin_unlock_bh(&(pacl_node_q->lock));
 
 	DBG_88E("%s, free acl_node_queue, num =%d\n", __func__, pacl_list->num);
 
@@ -1981,7 +1981,7 @@ void stop_ap_mode(struct adapter *padapter)
 	psta = rtw_get_bcmc_stainfo(padapter);
 	spin_lock_bh(&(pstapriv->sta_hash_lock));
 	rtw_free_stainfo(padapter, psta);
-	_exit_critical_bh(&(pstapriv->sta_hash_lock), &irqL);
+	spin_unlock_bh(&(pstapriv->sta_hash_lock));
 
 	rtw_init_bcmc_stainfo(padapter);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_br_ext.c b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
index 8c36e1e..5425bc5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_br_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
@@ -353,7 +353,6 @@ static int __nat25_db_network_lookup_and_replace(struct adapter *priv,
 				struct sk_buff *skb, unsigned char *networkAddr)
 {
 	struct nat25_network_db_entry *db;
-	unsigned long irqL;
 	spin_lock_bh(&priv->br_ext_lock);
 
 	db = priv->nethash[__nat25_network_hash(networkAddr)];
@@ -390,12 +389,12 @@ static int __nat25_db_network_lookup_and_replace(struct adapter *priv,
 					db->networkAddr[15],
 					db->networkAddr[16]);
 			}
-			_exit_critical_bh(&priv->br_ext_lock, &irqL);
+			spin_unlock_bh(&priv->br_ext_lock);
 			return 1;
 		}
 		db = db->next_hash;
 	}
-	_exit_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_unlock_bh(&priv->br_ext_lock);
 	return 0;
 }
 
@@ -404,7 +403,6 @@ static void __nat25_db_network_insert(struct adapter *priv,
 {
 	struct nat25_network_db_entry *db;
 	int hash;
-	unsigned long irqL;
 
 	spin_lock_bh(&priv->br_ext_lock);
 	hash = __nat25_network_hash(networkAddr);
@@ -413,14 +411,14 @@ static void __nat25_db_network_insert(struct adapter *priv,
 		if (!memcmp(db->networkAddr, networkAddr, MAX_NETWORK_ADDR_LEN)) {
 			memcpy(db->macAddr, macAddr, ETH_ALEN);
 			db->ageing_timer = jiffies;
-			_exit_critical_bh(&priv->br_ext_lock, &irqL);
+			spin_unlock_bh(&priv->br_ext_lock);
 			return;
 		}
 		db = db->next_hash;
 	}
 	db = (struct nat25_network_db_entry *) rtw_malloc(sizeof(*db));
 	if (db == NULL) {
-		_exit_critical_bh(&priv->br_ext_lock, &irqL);
+		spin_unlock_bh(&priv->br_ext_lock);
 		return;
 	}
 	memcpy(db->networkAddr, networkAddr, MAX_NETWORK_ADDR_LEN);
@@ -430,7 +428,7 @@ static void __nat25_db_network_insert(struct adapter *priv,
 
 	__network_hash_link(priv, db, hash);
 
-	_exit_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_unlock_bh(&priv->br_ext_lock);
 }
 
 static void __nat25_db_print(struct adapter *priv)
@@ -444,7 +442,6 @@ static void __nat25_db_print(struct adapter *priv)
 void nat25_db_cleanup(struct adapter *priv)
 {
 	int i;
-	unsigned long irqL;
 	spin_lock_bh(&priv->br_ext_lock);
 
 	for (i = 0; i < NAT25_HASH_SIZE; i++) {
@@ -464,13 +461,12 @@ void nat25_db_cleanup(struct adapter *priv)
 			f = g;
 		}
 	}
-	_exit_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_unlock_bh(&priv->br_ext_lock);
 }
 
 void nat25_db_expire(struct adapter *priv)
 {
 	int i;
-	unsigned long irqL;
 	spin_lock_bh(&priv->br_ext_lock);
 
 	for (i = 0; i < NAT25_HASH_SIZE; i++) {
@@ -495,7 +491,7 @@ void nat25_db_expire(struct adapter *priv)
 			f = g;
 		}
 	}
-	_exit_critical_bh(&priv->br_ext_lock, &irqL);
+	spin_unlock_bh(&priv->br_ext_lock);
 }
 
 int nat25_db_handle(struct adapter *priv, struct sk_buff *skb, int method)
@@ -1060,7 +1056,6 @@ int nat25_handle_frame(struct adapter *priv, struct sk_buff *skb)
 		}
 
 		if (!priv->ethBrExtInfo.nat25_disable) {
-			unsigned long irqL;
 			spin_lock_bh(&priv->br_ext_lock);
 			/*
 			 *	This function look up the destination network address from
@@ -1072,9 +1067,9 @@ int nat25_handle_frame(struct adapter *priv, struct sk_buff *skb)
 			    !memcmp(priv->scdb_ip, skb->data+ETH_HLEN+16, 4)) {
 				memcpy(skb->data, priv->scdb_mac, ETH_ALEN);
 
-				_exit_critical_bh(&priv->br_ext_lock, &irqL);
+				spin_unlock_bh(&priv->br_ext_lock);
 			} else {
-				_exit_critical_bh(&priv->br_ext_lock, &irqL);
+				spin_unlock_bh(&priv->br_ext_lock);
 
 				retval = nat25_db_handle(priv, skb, NAT25_LOOKUP);
 			}
@@ -1183,14 +1178,11 @@ void *scdb_findEntry(struct adapter *priv, unsigned char *macAddr,
 	hash = __nat25_network_hash(networkAddr);
 	db = priv->nethash[hash];
 	while (db != NULL) {
-		if (!memcmp(db->networkAddr, networkAddr, MAX_NETWORK_ADDR_LEN)) {
-			/* _exit_critical_bh(&priv->br_ext_lock, &irqL); */
+		if (!memcmp(db->networkAddr, networkAddr, MAX_NETWORK_ADDR_LEN))
 			return (void *)db;
-		}
 
 		db = db->next_hash;
 	}
 
-	/* _exit_critical_bh(&priv->br_ext_lock, &irqL); */
 	return NULL;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index c0cb186..5e9b8a5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -2196,7 +2196,6 @@ _func_exit_;
 }
 void rtw_disassoc_cmd_callback(struct adapter *padapter, struct cmd_obj *pcmd)
 {
-	unsigned long	irqL;
 	struct	mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
 _func_enter_;
@@ -2204,7 +2203,7 @@ _func_enter_;
 	if (pcmd->res != H2C_SUCCESS) {
 		spin_lock_bh(&pmlmepriv->lock);
 		set_fwstate(pmlmepriv, _FW_LINKED);
-		_exit_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_unlock_bh(&pmlmepriv->lock);
 
 		RT_TRACE(_module_rtl871x_cmd_c_, _drv_err_, ("\n ***Error: disconnect_cmd_callback Fail ***\n."));
 
@@ -2242,7 +2241,6 @@ _func_exit_;
 
 void rtw_createbss_cmd_callback(struct adapter *padapter, struct cmd_obj *pcmd)
 {
-	unsigned long irqL;
 	u8 timer_cancelled;
 	struct sta_info *psta = NULL;
 	struct wlan_network *pwlan = NULL;
@@ -2273,15 +2271,13 @@ _func_enter_;
 
 		rtw_indicate_connect(padapter);
 	} else {
-		unsigned long	irqL;
-
 		pwlan = _rtw_alloc_network(pmlmepriv);
 		spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 		if (pwlan == NULL) {
 			pwlan = rtw_get_oldest_wlan_network(&pmlmepriv->scanned_queue);
 			if (pwlan == NULL) {
 				RT_TRACE(_module_rtl871x_cmd_c_, _drv_err_, ("\n Error:  can't get pwlan in rtw_joinbss_event_callback\n"));
-				_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+				spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 				goto createbss_cmd_fail;
 			}
 			pwlan->last_scanned = rtw_get_current_time();
@@ -2296,13 +2292,13 @@ _func_enter_;
 
 		_clr_fwstate_(pmlmepriv, _FW_UNDER_LINKING);
 
-		_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+		spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 		/*  we will set _FW_LINKED when there is one more sat to join us (rtw_stassoc_event_callback) */
 	}
 
 createbss_cmd_fail:
 
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 	rtw_free_cmd_obj(pcmd);
 
@@ -2328,7 +2324,6 @@ _func_exit_;
 
 void rtw_setassocsta_cmdrsp_callback(struct adapter *padapter,  struct cmd_obj *pcmd)
 {
-	unsigned long	irqL;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct set_assocsta_parm *passocsta_parm = (struct set_assocsta_parm *)(pcmd->parmbuf);
@@ -2351,7 +2346,7 @@ _func_enter_;
 		_clr_fwstate_(pmlmepriv, _FW_UNDER_LINKING);
 
 	set_fwstate(pmlmepriv, _FW_LINKED);
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 exit:
 	rtw_free_cmd_obj(pcmd);
diff --git a/drivers/staging/rtl8188eu/core/rtw_debug.c b/drivers/staging/rtl8188eu/core/rtw_debug.c
index 9352048..8a1988e 100644
--- a/drivers/staging/rtl8188eu/core/rtw_debug.c
+++ b/drivers/staging/rtl8188eu/core/rtw_debug.c
@@ -882,7 +882,7 @@ int proc_get_all_sta_info(char *page, char **start,
 			}
 		}
 	}
-	_exit_critical_bh(&pstapriv->sta_hash_lock, &irqL);
+	spin_unlock_bh(&pstapriv->sta_hash_lock);
 
 	*eof = 1;
 	return len;
diff --git a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
index 92818eb..7b54c1e 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
@@ -68,7 +68,6 @@ _func_exit_;
 
 u8 rtw_do_join(struct adapter *padapter)
 {
-	unsigned long	irqL;
 	struct list_head *plist, *phead;
 	u8 *pibss = NULL;
 	struct	mlme_priv	*pmlmepriv = &(padapter->mlmepriv);
@@ -92,7 +91,7 @@ _func_enter_;
 	pmlmepriv->to_join = true;
 
 	if (_rtw_queue_empty(queue)) {
-		_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+		spin_unlock_bh(&(pmlmepriv->scanned_queue.lock));
 		_clr_fwstate_(pmlmepriv, _FW_UNDER_LINKING);
 
 		/* when set_ssid/set_bssid for rtw_do_join(), but scanning queue is empty */
@@ -116,7 +115,7 @@ _func_enter_;
 	} else {
 		int select_ret;
 
-		_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+		spin_unlock_bh(&(pmlmepriv->scanned_queue.lock));
 		select_ret = rtw_select_and_join_from_scanned_queue(pmlmepriv);
 		if (select_ret == _SUCCESS) {
 			pmlmepriv->to_join = false;
@@ -178,7 +177,6 @@ _func_exit_;
 
 u8 rtw_set_802_11_bssid(struct adapter *padapter, u8 *bssid)
 {
-	unsigned long irqL;
 	u8 status = _SUCCESS;
 	u32 cur_time = 0;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
@@ -253,7 +251,7 @@ handle_tkip_countermeasure:
 		status = rtw_do_join(padapter);
 
 release_mlme_lock:
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 exit:
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_,
@@ -266,7 +264,6 @@ _func_exit_;
 
 u8 rtw_set_802_11_ssid(struct adapter *padapter, struct ndis_802_11_ssid *ssid)
 {
-	unsigned long irqL;
 	u8 status = _SUCCESS;
 	u32 cur_time = 0;
 
@@ -367,7 +364,7 @@ handle_tkip_countermeasure:
 	}
 
 release_mlme_lock:
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 exit:
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_,
@@ -379,7 +376,6 @@ _func_exit_;
 u8 rtw_set_802_11_infrastructure_mode(struct adapter *padapter,
 	enum ndis_802_11_network_infra networktype)
 {
-	unsigned long irqL;
 	struct	mlme_priv	*pmlmepriv = &padapter->mlmepriv;
 	struct	wlan_network	*cur_network = &pmlmepriv->cur_network;
 	enum ndis_802_11_network_infra *pold_state = &(cur_network->network.InfrastructureMode);
@@ -439,7 +435,7 @@ _func_enter_;
 		case Ndis802_11InfrastructureMax:
 			break;
 		}
-		_exit_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_unlock_bh(&pmlmepriv->lock);
 	}
 
 _func_exit_;
@@ -450,7 +446,6 @@ _func_exit_;
 
 u8 rtw_set_802_11_disassociate(struct adapter *padapter)
 {
-	unsigned long irqL;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
 _func_enter_;
@@ -467,7 +462,7 @@ _func_enter_;
 		rtw_pwr_wakeup(padapter);
 	}
 
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 _func_exit_;
 
@@ -476,7 +471,6 @@ _func_exit_;
 
 u8 rtw_set_802_11_bssid_list_scan(struct adapter *padapter, struct ndis_802_11_ssid *pssid, int ssid_max_num)
 {
-	unsigned long	irqL;
 	struct	mlme_priv		*pmlmepriv = &padapter->mlmepriv;
 	u8	res = true;
 
@@ -516,7 +510,7 @@ _func_enter_;
 
 		res = rtw_sitesurvey_cmd(padapter, pssid, ssid_max_num, NULL, 0);
 
-		_exit_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_unlock_bh(&pmlmepriv->lock);
 	}
 exit:
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index da82fa1..27dfba2 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -147,8 +147,6 @@ _func_exit_;
 
 int	_rtw_enqueue_network(struct __queue *queue, struct wlan_network *pnetwork)
 {
-	unsigned long irql;
-
 _func_enter_;
 
 	if (pnetwork == NULL)
@@ -158,7 +156,7 @@ _func_enter_;
 
 	rtw_list_insert_tail(&pnetwork->list, &queue->queue);
 
-	_exit_critical_bh(&queue->lock, &irql);
+	spin_unlock_bh(&queue->lock);
 
 exit:
 
@@ -169,8 +167,6 @@ _func_exit_;
 
 struct	wlan_network *_rtw_dequeue_network(struct __queue *queue)
 {
-	unsigned long irql;
-
 	struct wlan_network *pnetwork;
 
 _func_enter_;
@@ -185,7 +181,7 @@ _func_enter_;
 		rtw_list_delete(&(pnetwork->list));
 	}
 
-	_exit_critical_bh(&queue->lock, &irql);
+	spin_unlock_bh(&queue->lock);
 
 _func_exit_;
 
@@ -194,7 +190,6 @@ _func_exit_;
 
 struct	wlan_network *_rtw_alloc_network(struct	mlme_priv *pmlmepriv)/* _queue *free_queue) */
 {
-	unsigned long	irql;
 	struct	wlan_network	*pnetwork;
 	struct __queue *free_queue = &pmlmepriv->free_bss_pool;
 	struct list_head *plist = NULL;
@@ -223,7 +218,7 @@ _func_enter_;
 	pmlmepriv->num_of_scanned++;
 
 exit:
-	_exit_critical_bh(&free_queue->lock, &irql);
+	spin_unlock_bh(&free_queue->lock);
 
 _func_exit_;
 
@@ -234,7 +229,6 @@ void _rtw_free_network(struct	mlme_priv *pmlmepriv , struct wlan_network *pnetwo
 {
 	u32 curr_time, delta_time;
 	u32 lifetime = SCANQUEUE_LIFETIME;
-	unsigned long irql;
 	struct __queue *free_queue = &(pmlmepriv->free_bss_pool);
 
 _func_enter_;
@@ -257,7 +251,7 @@ _func_enter_;
 	rtw_list_delete(&(pnetwork->list));
 	rtw_list_insert_tail(&(pnetwork->list), &(free_queue->queue));
 	pmlmepriv->num_of_scanned--;
-	_exit_critical_bh(&free_queue->lock, &irql);
+	spin_unlock_bh(&free_queue->lock);
 
 exit:
 _func_exit_;
@@ -315,7 +309,6 @@ _func_exit_;
 
 void _rtw_free_network_queue(struct adapter *padapter, u8 isfreeall)
 {
-	unsigned long irql;
 	struct list_head *phead, *plist;
 	struct wlan_network *pnetwork;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
@@ -336,7 +329,7 @@ _func_enter_;
 
 		_rtw_free_network(pmlmepriv, pnetwork, isfreeall);
 	}
-	_exit_critical_bh(&scanned_queue->lock, &irql);
+	spin_unlock_bh(&scanned_queue->lock);
 _func_exit_;
 }
 
@@ -592,7 +585,6 @@ Caller must hold pmlmepriv->lock first.
 */
 void rtw_update_scanned_network(struct adapter *adapter, struct wlan_bssid_ex *target)
 {
-	unsigned long irql;
 	struct list_head *plist, *phead;
 	u32	bssid_ex_sz;
 	struct mlme_priv	*pmlmepriv = &(adapter->mlmepriv);
@@ -678,7 +670,7 @@ _func_enter_;
 	}
 
 exit:
-	_exit_critical_bh(&queue->lock, &irql);
+	spin_unlock_bh(&queue->lock);
 
 _func_exit_;
 }
@@ -754,7 +746,6 @@ _func_exit_;
 
 void rtw_survey_event_callback(struct adapter	*adapter, u8 *pbuf)
 {
-	unsigned long  irql;
 	u32 len;
 	struct wlan_bssid_ex *pnetwork;
 	struct	mlme_priv	*pmlmepriv = &(adapter->mlmepriv);
@@ -776,17 +767,16 @@ _func_enter_;
 	if ((check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE)) == true) {
 		if (_rtw_memcmp(&(pmlmepriv->cur_network.network.MacAddress), pnetwork->MacAddress, ETH_ALEN)) {
 			struct wlan_network *ibss_wlan = NULL;
-			unsigned long	irql;
 
 			memcpy(pmlmepriv->cur_network.network.IEs, pnetwork->IEs, 8);
 			spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 			ibss_wlan = rtw_find_network(&pmlmepriv->scanned_queue,  pnetwork->MacAddress);
 			if (ibss_wlan) {
 				memcpy(ibss_wlan->network.IEs , pnetwork->IEs, 8);
-				_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+				spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 				goto exit;
 			}
-			_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+			spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 		}
 	}
 
@@ -799,7 +789,7 @@ _func_enter_;
 
 exit:
 
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 _func_exit_;
 
@@ -810,7 +800,6 @@ _func_exit_;
 
 void rtw_surveydone_event_callback(struct adapter	*adapter, u8 *pbuf)
 {
-	unsigned long  irql;
 	struct	mlme_priv *pmlmepriv = &(adapter->mlmepriv);
 	struct mlme_ext_priv *pmlmeext;
 
@@ -894,7 +883,7 @@ _func_enter_;
 
 	indicate_wx_scan_complete_event(adapter);
 
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 	if (check_fwstate(pmlmepriv, _FW_LINKED) == true)
 		p2p_ps_wk_cmd(adapter, P2P_PS_SCAN_DONE, 0);
@@ -917,7 +906,6 @@ void rtw_fwdbg_event_callback(struct adapter *adapter , u8 *pbuf)
 
 static void free_scanqueue(struct	mlme_priv *pmlmepriv)
 {
-	unsigned long irql, irql0;
 	struct __queue *free_queue = &pmlmepriv->free_bss_pool;
 	struct __queue *scan_queue = &pmlmepriv->scanned_queue;
 	struct list_head *plist, *phead, *ptemp;
@@ -939,8 +927,8 @@ _func_enter_;
 		pmlmepriv->num_of_scanned--;
 	}
 
-	_exit_critical_bh(&free_queue->lock, &irql);
-	_exit_critical_bh(&scan_queue->lock, &irql0);
+	spin_unlock_bh(&free_queue->lock);
+	spin_unlock_bh(&scan_queue->lock);
 
 _func_exit_;
 }
@@ -950,7 +938,6 @@ _func_exit_;
 */
 void rtw_free_assoc_resources(struct adapter *adapter, int lock_scanned_queue)
 {
-	unsigned long irql;
 	struct wlan_network *pwlan = NULL;
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	struct	sta_priv *pstapriv = &adapter->stapriv;
@@ -970,7 +957,7 @@ _func_enter_;
 
 		spin_lock_bh(&(pstapriv->sta_hash_lock));
 		rtw_free_stainfo(adapter,  psta);
-		_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql);
+		spin_unlock_bh(&pstapriv->sta_hash_lock);
 	}
 
 	if (check_fwstate(pmlmepriv, WIFI_ADHOC_STATE | WIFI_ADHOC_MASTER_STATE | WIFI_AP_STATE)) {
@@ -981,7 +968,7 @@ _func_enter_;
 		psta = rtw_get_bcmc_stainfo(adapter);
 		spin_lock_bh(&(pstapriv->sta_hash_lock));
 		rtw_free_stainfo(adapter, psta);
-		_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql);
+		spin_unlock_bh(&pstapriv->sta_hash_lock);
 
 		rtw_init_bcmc_stainfo(adapter);
 	}
@@ -999,7 +986,7 @@ _func_enter_;
 		rtw_free_network_nolock(pmlmepriv, pwlan);
 
 	if (lock_scanned_queue)
-		_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+		spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 	pmlmepriv->key_mask = 0;
 _func_exit_;
 }
@@ -1219,7 +1206,6 @@ static void rtw_joinbss_update_network(struct adapter *padapter, struct wlan_net
 
 void rtw_joinbss_event_prehandle(struct adapter *adapter, u8 *pbuf)
 {
-	unsigned long irql, irql2;
 	u8 timer_cancelled;
 	struct sta_info *ptarget_sta = NULL, *pcur_sta = NULL;
 	struct	sta_priv *pstapriv = &adapter->stapriv;
@@ -1269,7 +1255,7 @@ _func_enter_;
 					if (pcur_sta) {
 						spin_lock_bh(&(pstapriv->sta_hash_lock));
 						rtw_free_stainfo(adapter,  pcur_sta);
-						_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql2);
+						spin_unlock_bh(&pstapriv->sta_hash_lock);
 					}
 
 					ptarget_wlan = rtw_find_network(&pmlmepriv->scanned_queue, pnetwork->network.MacAddress);
@@ -1291,7 +1277,7 @@ _func_enter_;
 				rtw_joinbss_update_network(adapter, ptarget_wlan, pnetwork);
 			} else {
 				RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("Can't find ptarget_wlan when joinbss_event callback\n"));
-				_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+				spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 				goto ignore_joinbss_callback;
 			}
 
@@ -1301,7 +1287,7 @@ _func_enter_;
 				ptarget_sta = rtw_joinbss_update_stainfo(adapter, pnetwork);
 				if (ptarget_sta == NULL) {
 					RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("Can't update stainfo when joinbss_event callback\n"));
-					_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+					spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 					goto ignore_joinbss_callback;
 				}
 			}
@@ -1321,11 +1307,11 @@ _func_enter_;
 
 		} else {
 			RT_TRACE(_module_rtl871x_mlme_c_, _drv_err_, ("rtw_joinbss_event_callback err: fw_state:%x", get_fwstate(pmlmepriv)));
-			_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+			spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 			goto ignore_joinbss_callback;
 		}
 
-		_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+		spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	} else if (pnetwork->join_res == -4) {
 		rtw_reset_securitypriv(adapter);
@@ -1341,7 +1327,7 @@ _func_enter_;
 	}
 
 ignore_joinbss_callback:
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 ignore_nolock:
 _func_exit_;
 }
@@ -1405,7 +1391,6 @@ void rtw_stassoc_hw_rpt(struct adapter *adapter, struct sta_info *psta)
 
 void rtw_stassoc_event_callback(struct adapter *adapter, u8 *pbuf)
 {
-	unsigned long irql;
 	struct sta_info *psta;
 	struct mlme_priv *pmlmepriv = &(adapter->mlmepriv);
 	struct stassoc_event	*pstassoc = (struct stassoc_event *)pbuf;
@@ -1457,12 +1442,12 @@ _func_enter_;
 			ptarget_wlan = rtw_find_network(&pmlmepriv->scanned_queue, cur_network->network.MacAddress);
 			if (ptarget_wlan)
 				ptarget_wlan->fixed = true;
-			_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+			spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 			/*  a sta + bc/mc_stainfo (not Ibss_stainfo) */
 			rtw_indicate_connect(adapter);
 		}
 	}
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 	mlmeext_sta_add_event_callback(adapter, psta);
 exit:
 _func_exit_;
@@ -1470,7 +1455,6 @@ _func_exit_;
 
 void rtw_stadel_event_callback(struct adapter *adapter, u8 *pbuf)
 {
-	unsigned long irql, irql2;
 	int mac_id = -1;
 	struct sta_info *psta;
 	struct wlan_network *pwlan = NULL;
@@ -1525,14 +1509,14 @@ _func_enter_;
 			pwlan->fixed = false;
 			rtw_free_network_nolock(pmlmepriv, pwlan);
 		}
-		_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+		spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 		_rtw_roaming(adapter, tgt_network);
 	}
 	if (check_fwstate(pmlmepriv, WIFI_ADHOC_MASTER_STATE) ||
 	    check_fwstate(pmlmepriv, WIFI_ADHOC_STATE)) {
 		spin_lock_bh(&(pstapriv->sta_hash_lock));
 		rtw_free_stainfo(adapter,  psta);
-		_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql);
+		spin_unlock_bh(&pstapriv->sta_hash_lock);
 
 		if (adapter->stapriv.asoc_sta_count == 1) { /* a sta + bc/mc_stainfo (not Ibss_stainfo) */
 			spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
@@ -1542,7 +1526,7 @@ _func_enter_;
 				pwlan->fixed = false;
 				rtw_free_network_nolock(pmlmepriv, pwlan);
 			}
-			_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+			spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 			/* re-create ibss */
 			pdev_network = &(adapter->registrypriv.dev_network);
 			pibss = adapter->registrypriv.dev_network.MacAddress;
@@ -1565,7 +1549,7 @@ _func_enter_;
 				RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_err_, ("***Error=>stadel_event_callback: rtw_createbss_cmd status FAIL***\n "));
 		}
 	}
-	_exit_critical_bh(&pmlmepriv->lock, &irql2);
+	spin_unlock_bh(&pmlmepriv->lock);
 _func_exit_;
 }
 
@@ -1582,7 +1566,6 @@ _func_exit_;
 */
 void _rtw_join_timeout_handler (struct adapter *adapter)
 {
-	unsigned long irql;
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	int do_join_r;
 
@@ -1617,7 +1600,7 @@ _func_enter_;
 		rtw_indicate_disconnect(adapter);
 		free_scanqueue(pmlmepriv);/*  */
 	}
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 _func_exit_;
 }
 
@@ -1627,13 +1610,12 @@ _func_exit_;
 */
 void rtw_scan_timeout_handler (struct adapter *adapter)
 {
-	unsigned long irql;
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 
 	DBG_88E(FUNC_ADPT_FMT" fw_state=%x\n", FUNC_ADPT_ARG(adapter), get_fwstate(pmlmepriv));
 	spin_lock_bh(&pmlmepriv->lock);
 	_clr_fwstate_(pmlmepriv, _FW_UNDER_SURVEY);
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 	rtw_indicate_scan_done(adapter, true);
 }
 
@@ -1761,7 +1743,6 @@ pmlmepriv->lock
 
 int rtw_select_and_join_from_scanned_queue(struct mlme_priv *pmlmepriv)
 {
-	unsigned long	irql;
 	int ret;
 	struct list_head *phead;
 	struct adapter *adapter;
@@ -1819,7 +1800,7 @@ _func_enter_;
 	ret = rtw_joinbss_cmd(adapter, candidate);
 
 exit:
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irql);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 _func_exit_;
 
@@ -2394,12 +2375,11 @@ void rtw_issue_addbareq_cmd(struct adapter *padapter, struct xmit_frame *pxmitfr
 
 void rtw_roaming(struct adapter *padapter, struct wlan_network *tgt_network)
 {
-	unsigned long irql;
 	struct mlme_priv	*pmlmepriv = &padapter->mlmepriv;
 
 	spin_lock_bh(&pmlmepriv->lock);
 	_rtw_roaming(padapter, tgt_network);
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 }
 void _rtw_roaming(struct adapter *padapter, struct wlan_network *tgt_network)
 {
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index ccbf59d..5f1df23 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -822,7 +822,7 @@ unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
 			rtw_list_delete(&pstat->asoc_list);
 			pstapriv->asoc_list_cnt--;
 		}
-		_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+		spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 		if (seq == 1) {
 			/* TODO: STA re_auth and auth timeout */
@@ -834,7 +834,7 @@ unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
 		rtw_list_insert_tail(&pstat->auth_list, &pstapriv->auth_list);
 		pstapriv->auth_list_cnt++;
 	}
-	_exit_critical_bh(&pstapriv->auth_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->auth_list_lock);
 
 	if (pstat->auth_seq == 0)
 		pstat->expire_to = pstapriv->auth_to;
@@ -1413,7 +1413,7 @@ unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 		rtw_list_delete(&pstat->auth_list);
 		pstapriv->auth_list_cnt--;
 	}
-	_exit_critical_bh(&pstapriv->auth_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->auth_list_lock);
 
 	spin_lock_bh(&pstapriv->asoc_list_lock);
 	if (rtw_is_list_empty(&pstat->asoc_list)) {
@@ -1421,7 +1421,7 @@ unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 		rtw_list_insert_tail(&pstat->asoc_list, &pstapriv->asoc_list);
 		pstapriv->asoc_list_cnt++;
 	}
-	_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 	/*  now the station is qualified to join our BSS... */
 	if (pstat && (pstat->state & WIFI_FW_ASSOC_SUCCESS) && (_STATS_SUCCESSFUL_ == status)) {
@@ -1607,7 +1607,7 @@ unsigned int OnDeAuth(struct adapter *padapter, union recv_frame *precv_frame)
 				pstapriv->asoc_list_cnt--;
 				updated = ap_free_sta(padapter, psta, false, reason);
 			}
-			_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+			spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 			associated_clients_update(padapter, updated);
 		}
@@ -1671,7 +1671,7 @@ unsigned int OnDisassoc(struct adapter *padapter, union recv_frame *precv_frame)
 				pstapriv->asoc_list_cnt--;
 				updated = ap_free_sta(padapter, psta, false, reason);
 			}
-			_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+			spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 			associated_clients_update(padapter, updated);
 		}
@@ -4686,7 +4686,7 @@ _issue_bcn:
 #if defined (CONFIG_88EU_AP_MODE)
 	pmlmepriv->update_bcn = false;
 
-	_exit_critical_bh(&pmlmepriv->bcn_update_lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->bcn_update_lock);
 #endif /* if defined (CONFIG_88EU_AP_MODE) */
 
 	if ((pattrib->pktlen + TXDESC_SIZE) > 512) {
@@ -6152,7 +6152,6 @@ void issue_action_BA(struct adapter *padapter, unsigned char *raddr, unsigned ch
 
 static void issue_action_BSSCoexistPacket(struct adapter *padapter)
 {
-	unsigned long	irqL;
 	struct list_head *plist, *phead;
 	unsigned char category, action;
 	struct xmit_frame			*pmgntframe;
@@ -6257,7 +6256,7 @@ static void issue_action_BSSCoexistPacket(struct adapter *padapter)
 					ICS[0][0] = 1;
 			}
 		}
-		_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+		spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 		for (i = 0; i < 8; i++) {
 			if (ICS[i][0] == 1) {
@@ -8396,12 +8395,12 @@ u8 tx_beacon_hdl(struct adapter *padapter, unsigned char *pbuf)
 
 				pxmitframe->attrib.qsel = 0x11;/* HIQ */
 
-				_exit_critical_bh(&psta_bmc->sleep_q.lock, &irqL);
+				spin_unlock_bh(&psta_bmc->sleep_q.lock);
 				if (rtw_hal_xmit(padapter, pxmitframe))
 					rtw_os_xmit_complete(padapter, pxmitframe);
 				spin_lock_bh(&psta_bmc->sleep_q.lock);
 			}
-			_exit_critical_bh(&psta_bmc->sleep_q.lock, &irqL);
+			spin_unlock_bh(&psta_bmc->sleep_q.lock);
 		}
 	}
 #endif
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp.c b/drivers/staging/rtl8188eu/core/rtw_mp.c
index c9ec558..f347354 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp.c
@@ -323,10 +323,7 @@ s32 mp_start_test(struct adapter *padapter)
 	struct sta_info *psta;
 	u32 length;
 	u8 val8;
-
-	unsigned long irqL;
 	s32 res = _SUCCESS;
-
 	struct mp_priv *pmppriv = &padapter->mppriv;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct wlan_network *tgt_network = &pmlmepriv->cur_network;
@@ -420,7 +417,7 @@ s32 mp_start_test(struct adapter *padapter)
 
 end_of_mp_start_test:
 
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->lock);
 
 	if (res == _SUCCESS) {
 		/*  set MSR to WIFI_FW_ADHOC_STATE */
@@ -439,8 +436,6 @@ void mp_stop_test(struct adapter *padapter)
 	struct wlan_network *tgt_network = &pmlmepriv->cur_network;
 	struct sta_info *psta;
 
-	unsigned long irqL;
-
 	if (pmppriv->mode == MP_ON) {
 		pmppriv->bSetTxPower = 0;
 		spin_lock_bh(&pmlmepriv->lock);
@@ -465,7 +460,7 @@ void mp_stop_test(struct adapter *padapter)
 
 end_of_mp_stop_test:
 
-		_exit_critical_bh(&pmlmepriv->lock, &irqL);
+		spin_unlock_bh(&pmlmepriv->lock);
 	}
 }
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index e94321e..f7defc7 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -40,7 +40,6 @@ static int rtw_p2p_is_channel_list_ok(u8 desired_ch, u8 *ch_list, u8 ch_cnt)
 
 static u32 go_add_group_info_attr(struct wifidirect_info *pwdinfo, u8 *pbuf)
 {
-	unsigned long irqL;
 	struct list_head *phead, *plist;
 	u32 len = 0;
 	u16 attr_len = 0;
@@ -120,7 +119,7 @@ static u32 go_add_group_info_attr(struct wifidirect_info *pwdinfo, u8 *pbuf)
 			pstart = pcur;
 		}
 	}
-	_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+	spin_unlock_bh(&pstapriv->asoc_list_lock);
 
 	if (attr_len > 0)
 		len = rtw_set_p2p_attr_content(pbuf, P2P_ATTR_GROUP_INFO, attr_len, pdata_attr);
@@ -977,7 +976,6 @@ u32 process_p2p_devdisc_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 			    _rtw_memcmp(pwdinfo->p2p_group_ssid, groupid+ETH_ALEN, pwdinfo->p2p_group_ssid_len)) {
 				attr_contentlen = 0;
 				if (rtw_get_p2p_attr_content(p2p_ie, p2p_ielen, P2P_ATTR_DEVICE_ID, dev_addr, &attr_contentlen)) {
-					unsigned long irqL;
 					struct list_head *phead, *plist;
 
 					spin_lock_bh(&pstapriv->asoc_list_lock);
@@ -1000,7 +998,7 @@ u32 process_p2p_devdisc_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 							status = P2P_STATUS_FAIL_INFO_UNAVAILABLE;
 						}
 					}
-					_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+					spin_unlock_bh(&pstapriv->asoc_list_lock);
 				} else {
 					status = P2P_STATUS_FAIL_INVALID_PARAM;
 				}
@@ -1497,9 +1495,7 @@ u8 process_p2p_presence_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 static void find_phase_handler(struct adapter *padapter)
 {
 	struct wifidirect_info  *pwdinfo = &padapter->wdinfo;
-	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
 	struct ndis_802_11_ssid	ssid;
-	unsigned long				irqL;
 
 _func_enter_;
 
@@ -1829,7 +1825,6 @@ static void pre_tx_scan_timer_process(void *FunctionContext)
 {
 	struct adapter *adapter = (struct adapter *)FunctionContext;
 	struct	wifidirect_info *pwdinfo = &adapter->wdinfo;
-	unsigned long irqL;
 	struct mlme_priv *pmlmepriv = &adapter->mlmepriv;
 
 	if (rtw_p2p_chk_state(pwdinfo, P2P_STATE_NONE))
@@ -1853,7 +1848,7 @@ static void pre_tx_scan_timer_process(void *FunctionContext)
 		DBG_88E("[%s] p2p_state is %d, ignore!!\n", __func__, rtw_p2p_state(pwdinfo));
 	}
 
-	_exit_critical_bh(&pmlmepriv->lock, &irqL);
+	spin_unlock_bh(&pmlmepriv->lock);
 }
 
 static void find_phase_timer_process(void *FunctionContext)
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 32ea9a2..f77b3aa 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -181,14 +181,13 @@ _func_exit_;
 
 union recv_frame *rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 {
-	unsigned long irqL;
 	union recv_frame  *precvframe;
 
 	spin_lock_bh(&pfree_recv_queue->lock);
 
 	precvframe = _rtw_alloc_recvframe(pfree_recv_queue);
 
-	_exit_critical_bh(&pfree_recv_queue->lock, &irqL);
+	spin_unlock_bh(&pfree_recv_queue->lock);
 
 	return precvframe;
 }
@@ -203,7 +202,6 @@ void rtw_init_recvframe(union recv_frame *precvframe, struct recv_priv *precvpri
 
 int rtw_free_recvframe(union recv_frame *precvframe, struct __queue *pfree_recv_queue)
 {
-	unsigned long irqL;
 	struct adapter *padapter;
 	struct recv_priv *precvpriv;
 
@@ -230,7 +228,7 @@ _func_enter_;
 				precvpriv->free_recvframe_cnt++;
 	}
 
-      _exit_critical_bh(&pfree_recv_queue->lock, &irqL);
+      spin_unlock_bh(&pfree_recv_queue->lock);
 
 _func_exit_;
 
@@ -260,11 +258,10 @@ _func_exit_;
 int rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue)
 {
 	int ret;
-	unsigned long irqL;
 
 	spin_lock_bh(&queue->lock);
 	ret = _rtw_enqueue_recvframe(precvframe, queue);
-	_exit_critical_bh(&queue->lock, &irqL);
+	spin_unlock_bh(&queue->lock);
 
 	return ret;
 }
@@ -316,14 +313,12 @@ u32 rtw_free_uc_swdec_pending_queue(struct adapter *adapter)
 
 int rtw_enqueue_recvbuf_to_head(struct recv_buf *precvbuf, struct __queue *queue)
 {
-	unsigned long irqL;
-
 	spin_lock_bh(&queue->lock);
 
 	rtw_list_delete(&precvbuf->list);
 	rtw_list_insert_head(&precvbuf->list, get_list_head(queue));
 
-	_exit_critical_bh(&queue->lock, &irqL);
+	spin_unlock_bh(&queue->lock);
 
 	return _SUCCESS;
 }
@@ -1133,7 +1128,7 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 
 				pxmitframe->attrib.triggered = 1;
 
-				_exit_critical_bh(&psta->sleep_q.lock, &irqL);
+				spin_unlock_bh(&psta->sleep_q.lock);
 				if (rtw_hal_xmit(padapter, pxmitframe) == true)
 					rtw_os_xmit_complete(padapter, pxmitframe);
 				spin_lock_bh(&psta->sleep_q.lock);
@@ -1165,7 +1160,7 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 				}
 			}
 
-			_exit_critical_bh(&psta->sleep_q.lock, &irqL);
+			spin_unlock_bh(&psta->sleep_q.lock);
 		}
 	}
 
@@ -1943,7 +1938,6 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 
 static int recv_indicatepkt_reorder(struct adapter *padapter, union recv_frame *prframe)
 {
-	unsigned long irql;
 	int retval = _SUCCESS;
 	struct rx_pkt_attrib *pattrib = &prframe->u.hdr.attrib;
 	struct recv_reorder_ctrl *preorder_ctrl = prframe->u.hdr.preorder_ctrl;
@@ -1994,7 +1988,7 @@ static int recv_indicatepkt_reorder(struct adapter *padapter, union recv_frame *
 	if (!check_indicate_seq(preorder_ctrl, pattrib->seq_num)) {
 		rtw_recv_indicatepkt(padapter, prframe);
 
-		_exit_critical_bh(&ppending_recvframe_queue->lock, &irql);
+		spin_unlock_bh(&ppending_recvframe_queue->lock);
 
 		goto _success_exit;
 	}
@@ -2016,9 +2010,9 @@ static int recv_indicatepkt_reorder(struct adapter *padapter, union recv_frame *
 	/* recv_indicatepkts_in_order(padapter, preorder_ctrl, true); */
 	if (recv_indicatepkts_in_order(padapter, preorder_ctrl, false)) {
 		_set_timer(&preorder_ctrl->reordering_ctrl_timer, REORDER_WAIT_TIME);
-		_exit_critical_bh(&ppending_recvframe_queue->lock, &irql);
+		spin_unlock_bh(&ppending_recvframe_queue->lock);
 	} else {
-		_exit_critical_bh(&ppending_recvframe_queue->lock, &irql);
+		spin_unlock_bh(&ppending_recvframe_queue->lock);
 		_cancel_timer_ex(&preorder_ctrl->reordering_ctrl_timer);
 	}
 
@@ -2028,14 +2022,13 @@ _success_exit:
 
 _err_exit:
 
-	_exit_critical_bh(&ppending_recvframe_queue->lock, &irql);
+	spin_unlock_bh(&ppending_recvframe_queue->lock);
 
 	return _FAIL;
 }
 
 void rtw_reordering_ctrl_timeout_handler(void *pcontext)
 {
-	unsigned long irql;
 	struct recv_reorder_ctrl *preorder_ctrl = (struct recv_reorder_ctrl *)pcontext;
 	struct adapter *padapter = preorder_ctrl->padapter;
 	struct __queue *ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
@@ -2048,7 +2041,7 @@ void rtw_reordering_ctrl_timeout_handler(void *pcontext)
 	if (recv_indicatepkts_in_order(padapter, preorder_ctrl, true) == true)
 		_set_timer(&preorder_ctrl->reordering_ctrl_timer, REORDER_WAIT_TIME);
 
-	_exit_critical_bh(&ppending_recvframe_queue->lock, &irql);
+	spin_unlock_bh(&ppending_recvframe_queue->lock);
 }
 
 static int process_recv_indicatepkts(struct adapter *padapter, union recv_frame *prframe)
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 2d805c5..0b8c1bf 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -191,7 +191,6 @@ _func_exit_;
 void rtw_mfree_all_stainfo(struct sta_priv *pstapriv);
 void rtw_mfree_all_stainfo(struct sta_priv *pstapriv)
 {
-	unsigned long	 irql;
 	struct list_head *plist, *phead;
 	struct sta_info *psta = NULL;
 
@@ -209,7 +208,7 @@ _func_enter_;
 		rtw_mfree_stainfo(psta);
 	}
 
-	_exit_critical_bh(&pstapriv->sta_hash_lock, &irql);
+	spin_unlock_bh(&pstapriv->sta_hash_lock);
 
 _func_exit_;
 }
@@ -237,7 +236,6 @@ static void rtw_mfree_sta_priv_lock(struct sta_priv *pstapriv)
 
 u32	_rtw_free_sta_priv(struct	sta_priv *pstapriv)
 {
-	unsigned long	irql;
 	struct list_head *phead, *plist;
 	struct sta_info *psta = NULL;
 	struct recv_reorder_ctrl *preorder_ctrl;
@@ -262,7 +260,7 @@ _func_enter_;
 				}
 			}
 		}
-		_exit_critical_bh(&pstapriv->sta_hash_lock, &irql);
+		spin_unlock_bh(&pstapriv->sta_hash_lock);
 		/*===============================*/
 
 		rtw_mfree_sta_priv_lock(pstapriv);
@@ -277,7 +275,6 @@ _func_exit_;
 
 struct	sta_info *rtw_alloc_stainfo(struct sta_priv *pstapriv, u8 *hwaddr)
 {
-	unsigned long irql, irql2;
 	s32	index;
 	struct list_head *phash_list;
 	struct sta_info	*psta;
@@ -293,12 +290,12 @@ _func_enter_;
 	spin_lock_bh(&(pfree_sta_queue->lock));
 
 	if (_rtw_queue_empty(pfree_sta_queue) == true) {
-		_exit_critical_bh(&(pfree_sta_queue->lock), &irql);
+		spin_unlock_bh(&pfree_sta_queue->lock);
 		psta = NULL;
 	} else {
 		psta = LIST_CONTAINOR(get_next(&pfree_sta_queue->queue), struct sta_info, list);
 		rtw_list_delete(&(psta->list));
-		_exit_critical_bh(&(pfree_sta_queue->lock), &irql);
+		spin_unlock_bh(&pfree_sta_queue->lock);
 		_rtw_init_stainfo(psta);
 		memcpy(psta->hwaddr, hwaddr, ETH_ALEN);
 		index = wifi_mac_hash(hwaddr);
@@ -316,7 +313,7 @@ _func_enter_;
 
 		pstapriv->asoc_sta_count++;
 
-		_exit_critical_bh(&(pstapriv->sta_hash_lock), &irql2);
+		spin_unlock_bh(&pstapriv->sta_hash_lock);
 
 /*  Commented by Albert 2009/08/13 */
 /*  For the SMC router, the sequence number of first packet of WPS handshake will be 0. */
@@ -368,7 +365,6 @@ _func_exit_;
 u32	rtw_free_stainfo(struct adapter *padapter , struct sta_info *psta)
 {
 	int i;
-	unsigned long irql0;
 	struct __queue *pfree_sta_queue;
 	struct recv_reorder_ctrl *preorder_ctrl;
 	struct	sta_xmit_priv	*pstaxmitpriv;
@@ -405,7 +401,7 @@ _func_enter_;
 
 	rtw_list_delete(&(pstaxmitpriv->be_q.tx_pending));
 
-	_exit_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_unlock_bh(&pxmitpriv->lock);
 
 	rtw_list_delete(&psta->hash_list);
 	RT_TRACE(_module_rtl871x_sta_mgt_c_, _drv_err_, ("\n free number_%d stainfo  with hwaddr=0x%.2x 0x%.2x 0x%.2x 0x%.2x 0x%.2x 0x%.2x\n", pstapriv->asoc_sta_count , psta->hwaddr[0], psta->hwaddr[1], psta->hwaddr[2], psta->hwaddr[3], psta->hwaddr[4], psta->hwaddr[5]));
@@ -419,7 +415,6 @@ _func_enter_;
 
 	/* for A-MPDU Rx reordering buffer control, cancel reordering_ctrl_timer */
 	for (i = 0; i < 16; i++) {
-		unsigned long irql;
 		struct list_head *phead, *plist;
 		union recv_frame *prframe;
 		struct __queue *ppending_recvframe_queue;
@@ -446,7 +441,7 @@ _func_enter_;
 			rtw_free_recvframe(prframe, pfree_recv_queue);
 		}
 
-		_exit_critical_bh(&ppending_recvframe_queue->lock, &irql);
+		spin_unlock_bh(&ppending_recvframe_queue->lock);
 	}
 
 	if (!(psta->state & WIFI_AP_STATE))
@@ -459,7 +454,7 @@ _func_enter_;
 		rtw_list_delete(&psta->auth_list);
 		pstapriv->auth_list_cnt--;
 	}
-	_exit_critical_bh(&pstapriv->auth_list_lock, &irql0);
+	spin_unlock_bh(&pstapriv->auth_list_lock);
 
 	psta->expire_to = 0;
 
@@ -487,7 +482,7 @@ _func_enter_;
 
 	spin_lock_bh(&(pfree_sta_queue->lock));
 	rtw_list_insert_tail(&psta->list, get_list_head(pfree_sta_queue));
-	_exit_critical_bh(&(pfree_sta_queue->lock), &irql0);
+	spin_unlock_bh(&pfree_sta_queue->lock);
 
 exit:
 
@@ -499,7 +494,6 @@ _func_exit_;
 /*  free all stainfo which in sta_hash[all] */
 void rtw_free_all_stainfo(struct adapter *padapter)
 {
-	unsigned long	 irql;
 	struct list_head *plist, *phead;
 	s32	index;
 	struct sta_info *psta = NULL;
@@ -527,7 +521,7 @@ _func_enter_;
 		}
 	}
 
-	_exit_critical_bh(&pstapriv->sta_hash_lock, &irql);
+	spin_unlock_bh(&pstapriv->sta_hash_lock);
 
 exit:
 
@@ -537,7 +531,6 @@ _func_exit_;
 /* any station allocated can be searched by hash list */
 struct sta_info *rtw_get_stainfo(struct sta_priv *pstapriv, u8 *hwaddr)
 {
-	unsigned long	 irql;
 	struct list_head *plist, *phead;
 	struct sta_info *psta = NULL;
 	u32	index;
@@ -572,7 +565,7 @@ _func_enter_;
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&pstapriv->sta_hash_lock, &irql);
+	spin_unlock_bh(&pstapriv->sta_hash_lock);
 _func_exit_;
 	return psta;
 }
@@ -639,7 +632,7 @@ u8 rtw_access_ctrl(struct adapter *padapter, u8 *mac_addr)
 			}
 		}
 	}
-	_exit_critical_bh(&(pacl_node_q->lock), &irql);
+	spin_unlock_bh(&pacl_node_q->lock);
 
 	if (pacl_list->mode == 1)/* accept unless in deny list */
 		res = (match) ? false : true;
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 76de05f..b57ed45 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -1422,7 +1422,6 @@ struct xmit_frame *rtw_alloc_xmitframe(struct xmit_priv *pxmitpriv)/* _queue *pf
 		pfree_xmit_queue
 	*/
 
-	unsigned long irql;
 	struct xmit_frame *pxframe = NULL;
 	struct list_head *plist, *phead;
 	struct __queue *pfree_xmit_queue = &pxmitpriv->free_xmit_queue;
@@ -1464,7 +1463,7 @@ _func_enter_;
 		pxframe->ack_report = 0;
 	}
 
-	_exit_critical_bh(&pfree_xmit_queue->lock, &irql);
+	spin_unlock_bh(&pfree_xmit_queue->lock);
 
 _func_exit_;
 
@@ -1473,7 +1472,6 @@ _func_exit_;
 
 s32 rtw_free_xmitframe(struct xmit_priv *pxmitpriv, struct xmit_frame *pxmitframe)
 {
-	unsigned long irql;
 	struct __queue *pfree_xmit_queue = &pxmitpriv->free_xmit_queue;
 	struct adapter *padapter = pxmitpriv->adapter;
 	struct sk_buff *pndis_pkt = NULL;
@@ -1499,7 +1497,7 @@ _func_enter_;
 	pxmitpriv->free_xmitframe_cnt++;
 	RT_TRACE(_module_rtl871x_xmit_c_, _drv_debug_, ("rtw_free_xmitframe():free_xmitframe_cnt=%d\n", pxmitpriv->free_xmitframe_cnt));
 
-	_exit_critical_bh(&pfree_xmit_queue->lock, &irql);
+	spin_unlock_bh(&pfree_xmit_queue->lock);
 
 	if (pndis_pkt)
 		rtw_os_pkt_complete(padapter, pndis_pkt);
@@ -1513,7 +1511,6 @@ _func_exit_;
 
 void rtw_free_xmitframe_queue(struct xmit_priv *pxmitpriv, struct __queue *pframequeue)
 {
-	unsigned long irql;
 	struct list_head *plist, *phead;
 	struct	xmit_frame	*pxmitframe;
 
@@ -1531,7 +1528,7 @@ _func_enter_;
 
 		rtw_free_xmitframe(pxmitpriv, pxmitframe);
 	}
-	_exit_critical_bh(&(pframequeue->lock), &irql);
+	spin_unlock_bh(&(pframequeue->lock));
 
 _func_exit_;
 }
@@ -1570,7 +1567,6 @@ static struct xmit_frame *dequeue_one_xmitframe(struct xmit_priv *pxmitpriv, str
 
 struct xmit_frame *rtw_dequeue_xframe(struct xmit_priv *pxmitpriv, struct hw_xmit *phwxmit_i, int entry)
 {
-	unsigned long irql0;
 	struct list_head *sta_plist, *sta_phead;
 	struct hw_xmit *phwxmit;
 	struct tx_servq *ptxservq = NULL;
@@ -1619,7 +1615,7 @@ _func_enter_;
 		}
 	}
 exit:
-	_exit_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_unlock_bh(&pxmitpriv->lock);
 _func_exit_;
 	return pxmitframe;
 }
@@ -1754,7 +1750,6 @@ _func_exit_;
 static int rtw_br_client_tx(struct adapter *padapter, struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
-	unsigned long irql;
 	int res, is_vlan_tag = 0, i, do_nat25 = 1;
 	unsigned short vlan_hdr = 0;
 	void *br_port = NULL;
@@ -1770,7 +1765,7 @@ static int rtw_br_client_tx(struct adapter *padapter, struct sk_buff **pskb)
 	    !memcmp(padapter->scdb_mac, skb->data+MACADDRLEN, MACADDRLEN) && padapter->scdb_entry) {
 		memcpy(skb->data+MACADDRLEN, GET_MY_HWADDR(padapter), MACADDRLEN);
 		padapter->scdb_entry->ageing_timer = jiffies;
-		_exit_critical_bh(&padapter->br_ext_lock, &irql);
+		spin_unlock_bh(&padapter->br_ext_lock);
 	} else {
 		if (*((__be16 *)(skb->data+MACADDRLEN*2)) == __constant_htons(ETH_P_8021Q)) {
 			is_vlan_tag = 1;
@@ -1803,7 +1798,7 @@ static int rtw_br_client_tx(struct adapter *padapter, struct sk_buff **pskb)
 				}
 			}
 		}
-		_exit_critical_bh(&padapter->br_ext_lock, &irql);
+		spin_unlock_bh(&padapter->br_ext_lock);
 		if (do_nat25) {
 			if (nat25_db_handle(padapter, skb, NAT25_CHECK) == 0) {
 				struct sk_buff *newskb;
@@ -1974,10 +1969,10 @@ s32 rtw_xmit(struct adapter *padapter, struct sk_buff **ppkt)
 #ifdef CONFIG_88EU_AP_MODE
 	spin_lock_bh(&pxmitpriv->lock);
 	if (xmitframe_enqueue_for_sleeping_sta(padapter, pxmitframe)) {
-		_exit_critical_bh(&pxmitpriv->lock, &irql0);
+		spin_unlock_bh(&pxmitpriv->lock);
 		return 1;
 	}
-	_exit_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_unlock_bh(&pxmitpriv->lock);
 #endif
 
 	if (rtw_hal_xmit(padapter, pxmitframe) == false)
@@ -2033,7 +2028,7 @@ int xmitframe_enqueue_for_sleeping_sta(struct adapter *padapter, struct xmit_fra
 			ret = true;
 		}
 
-		_exit_critical_bh(&psta->sleep_q.lock, &irql);
+		spin_unlock_bh(&psta->sleep_q.lock);
 
 		return ret;
 	}
@@ -2086,7 +2081,7 @@ int xmitframe_enqueue_for_sleeping_sta(struct adapter *padapter, struct xmit_fra
 		}
 	}
 
-	_exit_critical_bh(&psta->sleep_q.lock, &irql);
+	spin_unlock_bh(&psta->sleep_q.lock);
 
 	return ret;
 }
@@ -2155,7 +2150,7 @@ void stop_sta_xmit(struct adapter *padapter, struct sta_info *psta)
 	dequeue_xmitframes_to_sleeping_queue(padapter, psta_bmc, &pstaxmitpriv->be_q.sta_pending);
 	rtw_list_delete(&(pstaxmitpriv->be_q.tx_pending));
 
-	_exit_critical_bh(&pxmitpriv->lock, &irql0);
+	spin_unlock_bh(&pxmitpriv->lock);
 }
 
 void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
@@ -2218,7 +2213,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 
 		pxmitframe->attrib.triggered = 1;
 
-		_exit_critical_bh(&psta->sleep_q.lock, &irql);
+		spin_unlock_bh(&psta->sleep_q.lock);
 		if (rtw_hal_xmit(padapter, pxmitframe))
 			rtw_os_xmit_complete(padapter, pxmitframe);
 		spin_lock_bh(&psta->sleep_q.lock);
@@ -2240,7 +2235,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 		pstapriv->sta_dz_bitmap &= ~BIT(psta->aid);
 	}
 
-	_exit_critical_bh(&psta->sleep_q.lock, &irql);
+	spin_unlock_bh(&psta->sleep_q.lock);
 
 	/* for BC/MC Frames */
 	psta_bmc = rtw_get_bcmc_stainfo(padapter);
@@ -2268,7 +2263,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 
 			pxmitframe->attrib.triggered = 1;
 
-			_exit_critical_bh(&psta_bmc->sleep_q.lock, &irql);
+			spin_unlock_bh(&psta_bmc->sleep_q.lock);
 			if (rtw_hal_xmit(padapter, pxmitframe))
 				rtw_os_xmit_complete(padapter, pxmitframe);
 			spin_lock_bh(&psta_bmc->sleep_q.lock);
@@ -2281,7 +2276,7 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 			update_mask |= BIT(1);
 		}
 
-		_exit_critical_bh(&psta_bmc->sleep_q.lock, &irql);
+		spin_unlock_bh(&psta_bmc->sleep_q.lock);
 	}
 
 	if (update_mask)
@@ -2355,7 +2350,7 @@ void xmit_delivery_enabled_frames(struct adapter *padapter, struct sta_info *pst
 		}
 	}
 
-	_exit_critical_bh(&psta->sleep_q.lock, &irql);
+	spin_unlock_bh(&psta->sleep_q.lock);
 }
 
 #endif
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
index fa692c4..6fb6a46 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
@@ -445,7 +445,6 @@ s32 rtl8188eu_xmitframe_complete(struct adapter *adapt, struct xmit_priv *pxmitp
 	struct sta_info *psta = NULL;
 	struct tx_servq *ptxservq = NULL;
 
-	unsigned long irql;
 	struct list_head *xmitframe_plist = NULL, *xmitframe_phead = NULL;
 
 	u32 pbuf;	/*  next pkt address */
@@ -591,7 +590,7 @@ s32 rtl8188eu_xmitframe_complete(struct adapter *adapt, struct xmit_priv *pxmitp
 	if (_rtw_queue_empty(&ptxservq->sta_pending) == true)
 		rtw_list_delete(&ptxservq->tx_pending);
 
-	_exit_critical_bh(&pxmitpriv->lock, &irql);
+	spin_unlock_bh(&pxmitpriv->lock);
 	if ((pfirstframe->attrib.ether_type != 0x0806) &&
 	    (pfirstframe->attrib.ether_type != 0x888e) &&
 	    (pfirstframe->attrib.ether_type != 0x88b4) &&
@@ -641,7 +640,6 @@ static s32 xmitframe_direct(struct adapter *adapt, struct xmit_frame *pxmitframe
  */
 static s32 pre_xmitframe(struct adapter *adapt, struct xmit_frame *pxmitframe)
 {
-	unsigned long irql;
 	s32 res;
 	struct xmit_buf *pxmitbuf = NULL;
 	struct xmit_priv *pxmitpriv = &adapt->xmitpriv;
@@ -660,7 +658,7 @@ static s32 pre_xmitframe(struct adapter *adapt, struct xmit_frame *pxmitframe)
 	if (pxmitbuf == NULL)
 		goto enqueue;
 
-	_exit_critical_bh(&pxmitpriv->lock, &irql);
+	spin_unlock_bh(&pxmitpriv->lock);
 
 	pxmitframe->pxmitbuf = pxmitbuf;
 	pxmitframe->buf_addr = pxmitbuf->pbuf;
@@ -675,7 +673,7 @@ static s32 pre_xmitframe(struct adapter *adapt, struct xmit_frame *pxmitframe)
 
 enqueue:
 	res = rtw_xmitframe_enqueue(adapt, pxmitframe);
-	_exit_critical_bh(&pxmitpriv->lock, &irql);
+	spin_unlock_bh(&pxmitpriv->lock);
 
 	if (res != _SUCCESS) {
 		RT_TRACE(_module_xmit_osdep_c_, _drv_err_, ("pre_xmitframe: enqueue xmitframe fail\n"));
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 894514e..c39c226 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -97,11 +97,6 @@ static inline void _exit_critical_ex(spinlock_t *plock, unsigned long *pirqL)
 	spin_unlock_irqrestore(plock, *pirqL);
 }
 
-static inline void _exit_critical_bh(spinlock_t *plock, unsigned long *pirqL)
-{
-	spin_unlock_bh(plock);
-}
-
 static inline int _enter_critical_mutex(struct mutex *pmutex,
 					unsigned long *pirqL)
 {
diff --git a/drivers/staging/rtl8188eu/include/rtw_mlme.h b/drivers/staging/rtl8188eu/include/rtw_mlme.h
index ff4d686..33965ca 100644
--- a/drivers/staging/rtl8188eu/include/rtw_mlme.h
+++ b/drivers/staging/rtl8188eu/include/rtw_mlme.h
@@ -526,48 +526,38 @@ static inline void _clr_fwstate_(struct mlme_priv *pmlmepriv, int state)
  */
 static inline void clr_fwstate(struct mlme_priv *pmlmepriv, int state)
 {
-	unsigned long irql;
-
 	spin_lock_bh(&pmlmepriv->lock);
 	if (check_fwstate(pmlmepriv, state) == true)
 		pmlmepriv->fw_state ^= state;
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 }
 
 static inline void clr_fwstate_ex(struct mlme_priv *pmlmepriv, int state)
 {
-	unsigned long irql;
-
 	spin_lock_bh(&pmlmepriv->lock);
 	_clr_fwstate_(pmlmepriv, state);
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 }
 
 static inline void up_scanned_network(struct mlme_priv *pmlmepriv)
 {
-	unsigned long irql;
-
 	spin_lock_bh(&pmlmepriv->lock);
 	pmlmepriv->num_of_scanned++;
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 }
 
 static inline void down_scanned_network(struct mlme_priv *pmlmepriv)
 {
-	unsigned long irql;
-
 	spin_lock_bh(&pmlmepriv->lock);
 	pmlmepriv->num_of_scanned--;
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 }
 
 static inline void set_scanned_network_val(struct mlme_priv *pmlmepriv, int val)
 {
-	unsigned long irql;
-
 	spin_lock_bh(&pmlmepriv->lock);
 	pmlmepriv->num_of_scanned = val;
-	_exit_critical_bh(&pmlmepriv->lock, &irql);
+	spin_unlock_bh(&pmlmepriv->lock);
 }
 
 u16 rtw_get_capability(struct wlan_bssid_ex *bss);
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index 5f6f7eb..ef3ae06 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -1108,7 +1108,6 @@ static int rtw_wx_set_wap(struct net_device *dev,
 			 union iwreq_data *awrq,
 			 char *extra)
 {
-	unsigned long	irqL;
 	uint ret = 0;
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 	struct sockaddr *temp = (struct sockaddr *)awrq;
@@ -1156,14 +1155,14 @@ static int rtw_wx_set_wap(struct net_device *dev,
 		if ((!memcmp(dst_bssid, src_bssid, ETH_ALEN))) {
 			if (!rtw_set_802_11_infrastructure_mode(padapter, pnetwork->network.InfrastructureMode)) {
 				ret = -1;
-				_exit_critical_bh(&queue->lock, &irqL);
+				spin_unlock_bh(&queue->lock);
 				goto exit;
 			}
 
 				break;
 		}
 	}
-	_exit_critical_bh(&queue->lock, &irqL);
+	spin_unlock_bh(&queue->lock);
 
 	rtw_set_802_11_authentication_mode(padapter, authmode);
 	/* set_802_11_encryption_mode(padapter, padapter->securitypriv.ndisencryptstatus); */
@@ -1248,7 +1247,6 @@ static int rtw_wx_set_scan(struct net_device *dev, struct iw_request_info *a,
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct ndis_802_11_ssid ssid[RTW_SSID_SCAN_AMOUNT];
-	unsigned long	irqL;
 #ifdef CONFIG_88EU_P2P
 	struct wifidirect_info *pwdinfo = &(padapter->wdinfo);
 #endif /* CONFIG_88EU_P2P */
@@ -1325,7 +1323,7 @@ _func_enter_;
 
 			_status = rtw_sitesurvey_cmd(padapter, ssid, 1, NULL, 0);
 
-			_exit_critical_bh(&pmlmepriv->lock, &irqL);
+			spin_unlock_bh(&pmlmepriv->lock);
 		} else if (req->scan_type == IW_SCAN_TYPE_PASSIVE) {
 			DBG_88E("rtw_wx_set_scan, req->scan_type == IW_SCAN_TYPE_PASSIVE\n");
 		}
@@ -1392,7 +1390,6 @@ _func_exit_;
 static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 			     union iwreq_data *wrqu, char *extra)
 {
-	unsigned long	irqL;
 	struct list_head *plist, *phead;
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 	struct	mlme_priv	*pmlmepriv = &(padapter->mlmepriv);
@@ -1463,7 +1460,7 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	wrqu->data.length = ev-extra;
 	wrqu->data.flags = 0;
@@ -1482,7 +1479,6 @@ static int rtw_wx_set_essid(struct net_device *dev,
 			      struct iw_request_info *a,
 			      union iwreq_data *wrqu, char *extra)
 {
-	unsigned long irqL;
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct __queue *queue = &pmlmepriv->scanned_queue;
@@ -1566,14 +1562,14 @@ static int rtw_wx_set_essid(struct net_device *dev,
 
 				if (!rtw_set_802_11_infrastructure_mode(padapter, pnetwork->network.InfrastructureMode)) {
 					ret = -1;
-					_exit_critical_bh(&queue->lock, &irqL);
+					spin_unlock_bh(&queue->lock);
 					goto exit;
 				}
 
 				break;
 			}
 		}
-		_exit_critical_bh(&queue->lock, &irqL);
+		spin_unlock_bh(&queue->lock);
 		RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_info_,
 			 ("set ssid: set_802_11_auth. mode =%d\n", authmode));
 		rtw_set_802_11_authentication_mode(padapter, authmode);
@@ -2574,7 +2570,6 @@ static int rtw_get_ap_info(struct net_device *dev,
 {
 	int ret = 0;
 	u32 cnt = 0, wpa_ielen;
-	unsigned long	irqL;
 	struct list_head *plist, *phead;
 	unsigned char *pbuf;
 	u8 bssid[ETH_ALEN];
@@ -2622,7 +2617,7 @@ static int rtw_get_ap_info(struct net_device *dev,
 
 		if (hwaddr_aton_i(data, bssid)) {
 			DBG_88E("Invalid BSSID '%s'.\n", (u8 *)data);
-			_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+			spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 			return -EINVAL;
 		}
 
@@ -2646,7 +2641,7 @@ static int rtw_get_ap_info(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (pdata->length >= 34) {
 		if (copy_to_user(pdata->pointer+32, (u8 *)&pdata->flags, 1)) {
@@ -3091,7 +3086,6 @@ static int rtw_p2p_get_wps_configmethod(struct net_device *dev,
 	int jj, kk;
 	u8 peerMACStr[17] = {0x00};
 	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
-	unsigned long				irqL;
 	struct list_head *plist, *phead;
 	struct __queue *queue	= &(pmlmepriv->scanned_queue);
 	struct	wlan_network	*pnetwork = NULL;
@@ -3143,7 +3137,7 @@ static int rtw_p2p_get_wps_configmethod(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (!blnMatch)
 		sprintf(attr_content_str, "\n\nM = 0000");
@@ -3163,7 +3157,6 @@ static int rtw_p2p_get_go_device_address(struct net_device *dev,
 	int jj, kk;
 	u8 peerMACStr[17] = {0x00};
 	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
-	unsigned long				irqL;
 	struct list_head *plist, *phead;
 	struct __queue *queue	= &(pmlmepriv->scanned_queue);
 	struct	wlan_network	*pnetwork = NULL;
@@ -3227,7 +3220,7 @@ static int rtw_p2p_get_go_device_address(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (!blnMatch)
 		sprintf(go_devadd_str, "\n\ndev_add = NULL");
@@ -3250,7 +3243,6 @@ static int rtw_p2p_get_device_type(struct net_device *dev,
 	int jj, kk;
 	u8 peerMACStr[17] = {0x00};
 	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
-	unsigned long				irqL;
 	struct list_head *plist, *phead;
 	struct __queue *queue	= &(pmlmepriv->scanned_queue);
 	struct	wlan_network	*pnetwork = NULL;
@@ -3308,7 +3300,7 @@ static int rtw_p2p_get_device_type(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (!blnMatch)
 		sprintf(dev_type_str, "\n\nN = 00");
@@ -3330,7 +3322,6 @@ static int rtw_p2p_get_device_name(struct net_device *dev,
 	int jj, kk;
 	u8 peerMACStr[17] = {0x00};
 	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
-	unsigned long				irqL;
 	struct list_head *plist, *phead;
 	struct __queue *queue	= &(pmlmepriv->scanned_queue);
 	struct	wlan_network	*pnetwork = NULL;
@@ -3380,7 +3371,7 @@ static int rtw_p2p_get_device_name(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (!blnMatch)
 		sprintf(dev_name_str, "\n\nN = 0000");
@@ -3400,7 +3391,6 @@ static int rtw_p2p_get_invitation_procedure(struct net_device *dev,
 	int jj, kk;
 	u8 peerMACStr[17] = {0x00};
 	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
-	unsigned long				irqL;
 	struct list_head *plist, *phead;
 	struct __queue *queue	= &(pmlmepriv->scanned_queue);
 	struct	wlan_network	*pnetwork = NULL;
@@ -3455,7 +3445,7 @@ static int rtw_p2p_get_invitation_procedure(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (!blnMatch) {
 		sprintf(inv_proc_str, "\nIP =-1");
@@ -3480,7 +3470,6 @@ static int rtw_p2p_connect(struct net_device *dev,
 	u8 peerMAC[ETH_ALEN] = {0x00};
 	int jj, kk;
 	struct mlme_priv		*pmlmepriv = &padapter->mlmepriv;
-	unsigned long				irqL;
 	struct list_head *plist, *phead;
 	struct __queue *queue	= &(pmlmepriv->scanned_queue);
 	struct	wlan_network	*pnetwork = NULL;
@@ -3524,7 +3513,7 @@ static int rtw_p2p_connect(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (uintPeerChannel) {
 		_rtw_memset(&pwdinfo->nego_req_info, 0x00, sizeof(struct tx_nego_req_info));
@@ -3569,7 +3558,6 @@ static int rtw_p2p_invite_req(struct net_device *dev,
 	u8 attr_content[50] = {0x00};
 	u8 *p2pie;
 	uint p2pielen = 0, attr_contentlen = 0;
-	unsigned long	irqL;
 	struct tx_invite_req_info *pinvite_req_info = &pwdinfo->invitereq_info;
 
 	/*	The input data contains two informations. */
@@ -3639,7 +3627,7 @@ static int rtw_p2p_invite_req(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (uintPeerChannel) {
 		/*	Store the GO's bssid */
@@ -3712,7 +3700,6 @@ static int rtw_p2p_prov_disc(struct net_device *dev,
 	u8 attr_content[100] = {0x00};
 	u8 *p2pie;
 	uint p2pielen = 0, attr_contentlen = 0;
-	unsigned long				irqL;
 
 	/*	The input data contains two informations. */
 	/*	1. First information is the MAC address which wants to issue the provisioning discovery request frame. */
@@ -3799,7 +3786,7 @@ static int rtw_p2p_prov_disc(struct net_device *dev,
 		plist = get_next(plist);
 	}
 
-	_exit_critical_bh(&(pmlmepriv->scanned_queue.lock), &irqL);
+	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
 
 	if (uintPeerChannel) {
 		DBG_88E("[%s] peer channel: %d!\n", __func__, uintPeerChannel);
@@ -4132,7 +4119,6 @@ static int rtw_dbg_port(struct net_device *dev,
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	unsigned long irqL;
 	int ret = 0;
 	u8 major_cmd, minor_cmd;
 	u16 arg;
@@ -4486,7 +4472,7 @@ static int rtw_dbg_port(struct net_device *dev,
 						}
 					}
 				}
-				_exit_critical_bh(&pstapriv->sta_hash_lock, &irqL);
+				spin_unlock_bh(&pstapriv->sta_hash_lock);
 			}
 			break;
 		case 0x0c:/* dump rx/tx packet */
@@ -5277,7 +5263,7 @@ static int rtw_del_sta(struct net_device *dev, struct ieee_param *param)
 			pstapriv->asoc_list_cnt--;
 			updated = ap_free_sta(padapter, psta, true, WLAN_REASON_DEAUTH_LEAVING);
 		}
-		_exit_critical_bh(&pstapriv->asoc_list_lock, &irqL);
+		spin_unlock_bh(&pstapriv->asoc_list_lock);
 		associated_clients_update(padapter, updated);
 		psta = NULL;
 	} else {
diff --git a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
index 4fd5869..9005971 100644
--- a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
@@ -156,7 +156,6 @@ void rtw_os_xmit_complete(struct adapter *padapter, struct xmit_frame *pxframe)
 
 void rtw_os_xmit_schedule(struct adapter *padapter)
 {
-	unsigned long  irql;
 	struct xmit_priv *pxmitpriv;
 
 	if (!padapter)
@@ -169,7 +168,7 @@ void rtw_os_xmit_schedule(struct adapter *padapter)
 	if (rtw_txframes_pending(padapter))
 		tasklet_hi_schedule(&pxmitpriv->xmit_tasklet);
 
-	_exit_critical_bh(&pxmitpriv->lock, &irql);
+	spin_unlock_bh(&pxmitpriv->lock);
 }
 
 static void rtw_check_xmit_resource(struct adapter *padapter, struct sk_buff *pkt)
@@ -194,7 +193,6 @@ static int rtw_mlcst2unicst(struct adapter *padapter, struct sk_buff *skb)
 {
 	struct	sta_priv *pstapriv = &padapter->stapriv;
 	struct xmit_priv *pxmitpriv = &padapter->xmitpriv;
-	unsigned long	irql;
 	struct list_head *phead, *plist;
 	struct sk_buff *newskb;
 	struct sta_info *psta = NULL;
@@ -230,12 +228,12 @@ static int rtw_mlcst2unicst(struct adapter *padapter, struct sk_buff *skb)
 			DBG_88E("%s-%d: skb_copy() failed!\n", __func__, __LINE__);
 			pxmitpriv->tx_drop++;
 
-			_exit_critical_bh(&pstapriv->asoc_list_lock, &irql);
+			spin_unlock_bh(&pstapriv->asoc_list_lock);
 			return false;	/*  Caller shall tx this multicast frame via normal way. */
 		}
 	}
 
-	_exit_critical_bh(&pstapriv->asoc_list_lock, &irql);
+	spin_unlock_bh(&pstapriv->asoc_list_lock);
 	dev_kfree_skb_any(skb);
 	return true;
 }
-- 
1.8.4
