From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/6] staging: r8188eu: Eliminate macro to get next list item
Date: Sun,  9 Feb 2014 15:15:58 -0600
Message-ID: <1391980559-24288-6-git-send-email-Larry.Finger@lwfinger.net>
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

The driver contains a macro that gets the next item in a linked list.
Replace it with a simple copy of the pointer.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c           | 32 +++++++-------
 drivers/staging/rtl8188eu/core/rtw_cmd.c          |  2 +-
 drivers/staging/rtl8188eu/core/rtw_debug.c        |  4 +-
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c    |  2 +-
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 28 ++++++------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     |  8 ++--
 drivers/staging/rtl8188eu/core/rtw_p2p.c          |  8 ++--
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 26 ++++++------
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      | 26 ++++++------
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 34 +++++++--------
 drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c    |  4 +-
 drivers/staging/rtl8188eu/include/osdep_service.h |  5 ---
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c    | 52 +++++++++++------------
 drivers/staging/rtl8188eu/os_dep/xmit_linux.c     |  4 +-
 14 files changed, 115 insertions(+), 120 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index f32011c..62a6147 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -285,12 +285,12 @@ void	expire_timeout_chk(struct adapter *padapter)
 	spin_lock_bh(&pstapriv->auth_list_lock);
 
 	phead = &pstapriv->auth_list;
-	plist = get_next(phead);
+	plist = phead->next;
 
 	/* check auth_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
 		psta = container_of(plist, struct sta_info, auth_list);
-		plist = get_next(plist);
+		plist = plist->next;
 
 		if (psta->expire_to > 0) {
 			psta->expire_to--;
@@ -319,12 +319,12 @@ void	expire_timeout_chk(struct adapter *padapter)
 	spin_lock_bh(&pstapriv->asoc_list_lock);
 
 	phead = &pstapriv->asoc_list;
-	plist = get_next(phead);
+	plist = phead->next;
 
 	/* check asoc_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
 		psta = container_of(plist, struct sta_info, asoc_list);
-		plist = get_next(plist);
+		plist = plist->next;
 
 		if (chk_sta_is_alive(psta) || !psta->expire_to) {
 			psta->expire_to = pstapriv->expire_to;
@@ -1144,11 +1144,11 @@ int rtw_acl_add_sta(struct adapter *padapter, u8 *addr)
 	spin_lock_bh(&(pacl_node_q->lock));
 
 	phead = get_list_head(pacl_node_q);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
 		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
-		plist = get_next(plist);
+		plist = plist->next;
 
 		if (!memcmp(paclnode->addr, addr, ETH_ALEN)) {
 			if (paclnode->valid) {
@@ -1205,11 +1205,11 @@ int rtw_acl_remove_sta(struct adapter *padapter, u8 *addr)
 	spin_lock_bh(&(pacl_node_q->lock));
 
 	phead = get_list_head(pacl_node_q);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
 		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
-		plist = get_next(plist);
+		plist = plist->next;
 
 		if (!memcmp(paclnode->addr, addr, ETH_ALEN)) {
 			if (paclnode->valid) {
@@ -1503,13 +1503,13 @@ void associated_clients_update(struct adapter *padapter, u8 updated)
 		spin_lock_bh(&pstapriv->asoc_list_lock);
 
 		phead = &pstapriv->asoc_list;
-		plist = get_next(phead);
+		plist = phead->next;
 
 		/* check asoc_queue */
 		while ((rtw_end_of_queue_search(phead, plist)) == false) {
 			psta = container_of(plist, struct sta_info, asoc_list);
 
-			plist = get_next(plist);
+			plist = plist->next;
 
 			VCS_update(padapter, psta);
 		}
@@ -1777,12 +1777,12 @@ int rtw_ap_inform_ch_switch(struct adapter *padapter, u8 new_ch, u8 ch_offset)
 
 	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
-	plist = get_next(phead);
+	plist = phead->next;
 
 	/* for each sta in asoc_queue */
 	while (!rtw_end_of_queue_search(phead, plist)) {
 		psta = container_of(plist, struct sta_info, asoc_list);
-		plist = get_next(plist);
+		plist = plist->next;
 
 		issue_action_spct_ch_switch(padapter, psta->hwaddr, new_ch, ch_offset);
 		psta->expire_to = ((pstapriv->expire_to * 2) > 5) ? 5 : (pstapriv->expire_to * 2);
@@ -1811,13 +1811,13 @@ int rtw_sta_flush(struct adapter *padapter)
 
 	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
-	plist = get_next(phead);
+	plist = phead->next;
 
 	/* free sta asoc_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
 		psta = container_of(plist, struct sta_info, asoc_list);
 
-		plist = get_next(plist);
+		plist = plist->next;
 
 		rtw_list_delete(&psta->asoc_list);
 		pstapriv->asoc_list_cnt--;
@@ -1942,10 +1942,10 @@ void stop_ap_mode(struct adapter *padapter)
 	/* for ACL */
 	spin_lock_bh(&(pacl_node_q->lock));
 	phead = get_list_head(pacl_node_q);
-	plist = get_next(phead);
+	plist = phead->next;
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
 		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
-		plist = get_next(plist);
+		plist = plist->next;
 
 		if (paclnode->valid) {
 			paclnode->valid = false;
diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index d24252d..cc322e5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -173,7 +173,7 @@ _func_enter_;
 	if (rtw_is_list_empty(&(queue->queue))) {
 		obj = NULL;
 	} else {
-		obj = container_of(get_next(&(queue->queue)), struct cmd_obj, list);
+		obj = container_of((&queue->queue)->next, struct cmd_obj, list);
 		rtw_list_delete(&obj->list);
 	}
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_debug.c b/drivers/staging/rtl8188eu/core/rtw_debug.c
index 76e7b7b..1812ba9 100644
--- a/drivers/staging/rtl8188eu/core/rtw_debug.c
+++ b/drivers/staging/rtl8188eu/core/rtw_debug.c
@@ -851,12 +851,12 @@ int proc_get_all_sta_info(char *page, char **start,
 
 	for (i = 0; i < NUM_STA; i++) {
 		phead = &(pstapriv->sta_hash[i]);
-		plist = get_next(phead);
+		plist = phead->next;
 
 		while ((rtw_end_of_queue_search(phead, plist)) == false) {
 			psta = container_of(plist, struct sta_info, hash_list);
 
-			plist = get_next(plist);
+			plist = plist->next;
 
 			len += snprintf(page + len, count - len, "sta's macaddr: %pM\n", psta->hwaddr);
 			len += snprintf(page + len, count - len, "rtsen=%d, cts2slef=%d\n", psta->rtsen, psta->cts2self);
diff --git a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
index 125ba4c..0f0f515 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ioctl_set.c
@@ -78,7 +78,7 @@ _func_enter_;
 
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	RT_TRACE(_module_rtl871x_ioctl_set_c_, _drv_info_, ("\n rtw_do_join: phead = %p; plist = %p\n\n\n", phead, plist));
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 55090d7..700a34d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -167,7 +167,7 @@ _func_enter_;
 	if (_rtw_queue_empty(queue)) {
 		pnetwork = NULL;
 	} else {
-		pnetwork = container_of(get_next(&queue->queue), struct wlan_network, list);
+		pnetwork = container_of((&queue->queue)->next, struct wlan_network, list);
 
 		rtw_list_delete(&(pnetwork->list));
 	}
@@ -193,7 +193,7 @@ _func_enter_;
 		pnetwork = NULL;
 		goto exit;
 	}
-	plist = get_next(&(free_queue->queue));
+	plist = free_queue->queue.next;
 
 	pnetwork = container_of(plist , struct wlan_network, list);
 
@@ -282,13 +282,13 @@ _func_enter_;
 		goto exit;
 	}
 	phead = get_list_head(scanned_queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (plist != phead) {
 		pnetwork = container_of(plist, struct wlan_network , list);
 		if (!memcmp(addr, pnetwork->network.MacAddress, ETH_ALEN) == true)
 			break;
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 	if (plist == phead)
 		pnetwork = NULL;
@@ -311,12 +311,12 @@ _func_enter_;
 	spin_lock_bh(&scanned_queue->lock);
 
 	phead = get_list_head(scanned_queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
 		pnetwork = container_of(plist, struct wlan_network, list);
 
-		plist = get_next(plist);
+		plist = plist->next;
 
 		_rtw_free_network(pmlmepriv, pnetwork, isfreeall);
 	}
@@ -494,7 +494,7 @@ struct	wlan_network	*rtw_get_oldest_wlan_network(struct __queue *scanned_queue)
 _func_enter_;
 	phead = get_list_head(scanned_queue);
 
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -507,7 +507,7 @@ _func_enter_;
 				oldest = pwlan;
 		}
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 _func_exit_;
 	return oldest;
@@ -587,7 +587,7 @@ _func_enter_;
 
 	spin_lock_bh(&queue->lock);
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -600,7 +600,7 @@ _func_enter_;
 		if ((oldest == ((struct wlan_network *)0)) ||
 		    time_after(oldest->last_scanned, pnetwork->last_scanned))
 			oldest = pnetwork;
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 	/* If we didn't find a match, then get a new network slot to initialize
 	 * with this beacon's information */
@@ -908,10 +908,10 @@ _func_enter_;
 	spin_lock_bh(&free_queue->lock);
 
 	phead = get_list_head(scan_queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (plist != phead) {
-		ptemp = get_next(plist);
+		ptemp = plist->next;
 		rtw_list_delete(plist);
 		rtw_list_insert_tail(plist, &free_queue->queue);
 		plist = ptemp;
@@ -1747,7 +1747,7 @@ _func_enter_;
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 	phead = get_list_head(queue);
 	adapter = (struct adapter *)pmlmepriv->nic_hdl;
-	pmlmepriv->pscanned = get_next(phead);
+	pmlmepriv->pscanned = phead->next;
 	while (!rtw_end_of_queue_search(phead, pmlmepriv->pscanned)) {
 		pnetwork = container_of(pmlmepriv->pscanned, struct wlan_network, list);
 		if (pnetwork == NULL) {
@@ -1755,7 +1755,7 @@ _func_enter_;
 			ret = _FAIL;
 			goto exit;
 		}
-		pmlmepriv->pscanned = get_next(pmlmepriv->pscanned);
+		pmlmepriv->pscanned = pmlmepriv->pscanned->next;
 		rtw_check_join_candidate(pmlmepriv, &candidate, pnetwork);
 	}
 	if (candidate == NULL) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 8e92335..2c5d704 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -6226,7 +6226,7 @@ static void issue_action_BSSCoexistPacket(struct adapter *padapter)
 		spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 		phead = get_list_head(queue);
-		plist = get_next(phead);
+		plist = phead->next;
 
 		while (1) {
 			int len;
@@ -6238,7 +6238,7 @@ static void issue_action_BSSCoexistPacket(struct adapter *padapter)
 
 			pnetwork = container_of(plist, struct wlan_network, list);
 
-			plist = get_next(plist);
+			plist = plist->next;
 
 			pbss_network = (struct wlan_bssid_ex *)&pnetwork->network;
 
@@ -8372,12 +8372,12 @@ u8 tx_beacon_hdl(struct adapter *padapter, unsigned char *pbuf)
 			spin_lock_bh(&psta_bmc->sleep_q.lock);
 
 			xmitframe_phead = get_list_head(&psta_bmc->sleep_q);
-			xmitframe_plist = get_next(xmitframe_phead);
+			xmitframe_plist = xmitframe_phead->next;
 
 			while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
 				pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
-				xmitframe_plist = get_next(xmitframe_plist);
+				xmitframe_plist = xmitframe_plist->next;
 
 				rtw_list_delete(&pxmitframe->list);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index e91a2ee..4670eb3 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -57,13 +57,13 @@ static u32 go_add_group_info_attr(struct wifidirect_info *pwdinfo, u8 *pbuf)
 
 	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
-	plist = get_next(phead);
+	plist = phead->next;
 
 	/* look up sta asoc_queue */
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
 		psta = container_of(plist, struct sta_info, asoc_list);
 
-		plist = get_next(plist);
+		plist = plist->next;
 
 
 		if (psta->is_p2p_device) {
@@ -980,13 +980,13 @@ u32 process_p2p_devdisc_req(struct wifidirect_info *pwdinfo, u8 *pframe, uint le
 
 					spin_lock_bh(&pstapriv->asoc_list_lock);
 					phead = &pstapriv->asoc_list;
-					plist = get_next(phead);
+					plist = phead->next;
 
 					/* look up sta asoc_queue */
 					while ((rtw_end_of_queue_search(phead, plist)) == false) {
 						psta = container_of(plist, struct sta_info, asoc_list);
 
-						plist = get_next(plist);
+						plist = plist->next;
 
 						if (psta->is_p2p_device && (psta->dev_cap&P2P_DEVCAP_CLIENT_DISCOVERABILITY) &&
 						    !memcmp(psta->dev_addr, dev_addr, ETH_ALEN)) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index edc40e5..f21630d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -151,7 +151,7 @@ _func_enter_;
 	} else {
 		phead = get_list_head(pfree_recv_queue);
 
-		plist = get_next(phead);
+		plist = phead->next;
 
 		hdr = container_of(plist, struct recv_frame_hdr, list);
 
@@ -273,12 +273,12 @@ _func_enter_;
 	spin_lock(&pframequeue->lock);
 
 	phead = get_list_head(pframequeue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
 		hdr = container_of(plist, struct recv_frame_hdr, list);
 
-		plist = get_next(plist);
+		plist = plist->next;
 
 		rtw_free_recvframe((union recv_frame *)hdr, pfree_recv_queue);
 	}
@@ -338,7 +338,7 @@ struct recv_buf *rtw_dequeue_recvbuf (struct __queue *queue)
 	} else {
 		phead = get_list_head(queue);
 
-		plist = get_next(phead);
+		plist = phead->next;
 
 		precvbuf = container_of(plist, struct recv_buf, list);
 
@@ -1099,12 +1099,12 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 			spin_lock_bh(&psta->sleep_q.lock);
 
 			xmitframe_phead = get_list_head(&psta->sleep_q);
-			xmitframe_plist = get_next(xmitframe_phead);
+			xmitframe_plist = xmitframe_phead->next;
 
 			if ((rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) == false) {
 				pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
-				xmitframe_plist = get_next(xmitframe_plist);
+				xmitframe_plist = xmitframe_plist->next;
 
 				rtw_list_delete(&pxmitframe->list);
 
@@ -1517,7 +1517,7 @@ _func_enter_;
 	pfree_recv_queue = &adapter->recvpriv.free_recv_queue;
 
 	phead = get_list_head(defrag_q);
-	plist = get_next(phead);
+	plist = phead->next;
 	pfhdr = container_of(plist, struct recv_frame_hdr, list);
 	prframe = (union recv_frame *)pfhdr;
 	rtw_list_delete(&(prframe->u.list));
@@ -1535,7 +1535,7 @@ _func_enter_;
 
 	plist = get_list_head(defrag_q);
 
-	plist = get_next(plist);
+	plist = plist->next;
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
 		pnfhdr = container_of(plist, struct recv_frame_hdr , list);
@@ -1569,7 +1569,7 @@ _func_enter_;
 		recvframe_put(prframe, pnfhdr->len);
 
 		pfhdr->attrib.icv_len = pnfhdr->attrib.icv_len;
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	/* free the defrag_q queue and return the prframe */
@@ -1843,14 +1843,14 @@ int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl, union rec
 	struct rx_pkt_attrib *pnextattrib;
 
 	phead = get_list_head(ppending_recvframe_queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
 		hdr = container_of(plist, struct recv_frame_hdr, list);
 		pnextattrib = &hdr->attrib;
 
 		if (SN_LESS(pnextattrib->seq_num, pattrib->seq_num))
-			plist = get_next(plist);
+			plist = plist->next;
 		else if (SN_EQUAL(pnextattrib->seq_num, pattrib->seq_num))
 			return false;
 		else
@@ -1874,7 +1874,7 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 	struct __queue *ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
 
 	phead =		get_list_head(ppending_recvframe_queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	/*  Handling some condition for forced indicate case. */
 	if (bforced) {
@@ -1897,7 +1897,7 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_notice_,
 				 ("recv_indicatepkts_in_order: indicate=%d seq=%d amsdu=%d\n",
 				  preorder_ctrl->indicate_seq, pattrib->seq_num, pattrib->amsdu));
-			plist = get_next(plist);
+			plist = plist->next;
 			rtw_list_delete(&(prframe->u.hdr.list));
 
 			if (SN_EQUAL(preorder_ctrl->indicate_seq, pattrib->seq_num))
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 6f870b8..5c9326d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -160,11 +160,11 @@ _func_enter_;
 	spin_lock_bh(&pstapriv->sta_hash_lock);
 
 	phead = get_list_head(&pstapriv->free_sta_queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while ((rtw_end_of_queue_search(phead, plist)) == false) {
 		psta = container_of(plist, struct sta_info , list);
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pstapriv->sta_hash_lock);
@@ -190,12 +190,12 @@ _func_enter_;
 		spin_lock_bh(&pstapriv->sta_hash_lock);
 		for (index = 0; index < NUM_STA; index++) {
 			phead = &(pstapriv->sta_hash[index]);
-			plist = get_next(phead);
+			plist = phead->next;
 
 			while ((rtw_end_of_queue_search(phead, plist)) == false) {
 				int i;
 				psta = container_of(plist, struct sta_info , hash_list);
-				plist = get_next(plist);
+				plist = plist->next;
 
 				for (i = 0; i < 16; i++) {
 					preorder_ctrl = &psta->recvreorder_ctrl[i];
@@ -236,7 +236,7 @@ _func_enter_;
 		spin_unlock_bh(&pfree_sta_queue->lock);
 		psta = NULL;
 	} else {
-		psta = container_of(get_next(&pfree_sta_queue->queue), struct sta_info, list);
+		psta = container_of((&pfree_sta_queue->queue)->next, struct sta_info, list);
 		rtw_list_delete(&(psta->list));
 		spin_unlock_bh(&pfree_sta_queue->lock);
 		_rtw_init_stainfo(psta);
@@ -373,13 +373,13 @@ _func_enter_;
 		spin_lock_bh(&ppending_recvframe_queue->lock);
 
 		phead =		get_list_head(ppending_recvframe_queue);
-		plist = get_next(phead);
+		plist = phead->next;
 
 		while (!rtw_is_list_empty(phead)) {
 			prhdr = container_of(plist, struct recv_frame_hdr, list);
 			prframe = (union recv_frame *)prhdr;
 
-			plist = get_next(plist);
+			plist = plist->next;
 
 			rtw_list_delete(&(prframe->u.hdr.list));
 
@@ -454,12 +454,12 @@ _func_enter_;
 
 	for (index = 0; index < NUM_STA; index++) {
 		phead = &(pstapriv->sta_hash[index]);
-		plist = get_next(phead);
+		plist = phead->next;
 
 		while ((!rtw_end_of_queue_search(phead, plist))) {
 			psta = container_of(plist, struct sta_info , hash_list);
 
-			plist = get_next(plist);
+			plist = plist->next;
 
 			if (pbcmc_stainfo != psta)
 				rtw_free_stainfo(padapter , psta);
@@ -497,7 +497,7 @@ _func_enter_;
 	spin_lock_bh(&pstapriv->sta_hash_lock);
 
 	phead = &(pstapriv->sta_hash[index]);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while ((!rtw_end_of_queue_search(phead, plist))) {
 		psta = container_of(plist, struct sta_info, hash_list);
@@ -507,7 +507,7 @@ _func_enter_;
 			break;
 		}
 		psta = NULL;
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pstapriv->sta_hash_lock);
@@ -564,10 +564,10 @@ u8 rtw_access_ctrl(struct adapter *padapter, u8 *mac_addr)
 
 	spin_lock_bh(&(pacl_node_q->lock));
 	phead = get_list_head(pacl_node_q);
-	plist = get_next(phead);
+	plist = phead->next;
 	while ((!rtw_end_of_queue_search(phead, plist))) {
 		paclnode = container_of(plist, struct rtw_wlan_acl_node, list);
-		plist = get_next(plist);
+		plist = plist->next;
 
 		if (!memcmp(paclnode->addr, mac_addr, ETH_ALEN)) {
 			if (paclnode->valid) {
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index d459127..37030e1 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -1260,7 +1260,7 @@ _func_enter_;
 	} else {
 		phead = get_list_head(pfree_queue);
 
-		plist = get_next(phead);
+		plist = phead->next;
 
 		pxmitbuf = container_of(plist, struct xmit_buf, list);
 
@@ -1328,7 +1328,7 @@ _func_enter_;
 	} else {
 		phead = get_list_head(pfree_xmitbuf_queue);
 
-		plist = get_next(phead);
+		plist = phead->next;
 
 		pxmitbuf = container_of(plist, struct xmit_buf, list);
 
@@ -1416,7 +1416,7 @@ _func_enter_;
 	} else {
 		phead = get_list_head(pfree_xmit_queue);
 
-		plist = get_next(phead);
+		plist = phead->next;
 
 		pxframe = container_of(plist, struct xmit_frame, list);
 
@@ -1499,12 +1499,12 @@ _func_enter_;
 	spin_lock_bh(&(pframequeue->lock));
 
 	phead = get_list_head(pframequeue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
 		pxmitframe = container_of(plist, struct xmit_frame, list);
 
-		plist = get_next(plist);
+		plist = plist->next;
 
 		rtw_free_xmitframe(pxmitpriv, pxmitframe);
 	}
@@ -1531,12 +1531,12 @@ static struct xmit_frame *dequeue_one_xmitframe(struct xmit_priv *pxmitpriv, str
 	struct	xmit_frame	*pxmitframe = NULL;
 
 	xmitframe_phead = get_list_head(pframe_queue);
-	xmitframe_plist = get_next(xmitframe_phead);
+	xmitframe_plist = xmitframe_phead->next;
 
 	if (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
 		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
-		xmitframe_plist = get_next(xmitframe_plist);
+		xmitframe_plist = xmitframe_plist->next;
 
 		rtw_list_delete(&pxmitframe->list);
 
@@ -1573,7 +1573,7 @@ _func_enter_;
 		phwxmit = phwxmit_i + inx[i];
 
 		sta_phead = get_list_head(phwxmit->sta_queue);
-		sta_plist = get_next(sta_phead);
+		sta_plist = sta_phead->next;
 
 		while (!rtw_end_of_queue_search(sta_phead, sta_plist)) {
 			ptxservq = container_of(sta_plist, struct tx_servq, tx_pending);
@@ -1591,7 +1591,7 @@ _func_enter_;
 				goto exit;
 			}
 
-			sta_plist = get_next(sta_plist);
+			sta_plist = sta_plist->next;
 		}
 	}
 exit:
@@ -2071,12 +2071,12 @@ static void dequeue_xmitframes_to_sleeping_queue(struct adapter *padapter, struc
 	struct hw_xmit *phwxmits =  padapter->xmitpriv.hwxmits;
 
 	phead = get_list_head(pframequeue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (!rtw_end_of_queue_search(phead, plist)) {
 		pxmitframe = container_of(plist, struct xmit_frame, list);
 
-		plist = get_next(plist);
+		plist = plist->next;
 
 		xmitframe_enqueue_for_sleeping_sta(padapter, pxmitframe);
 
@@ -2138,12 +2138,12 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 	spin_lock_bh(&psta->sleep_q.lock);
 
 	xmitframe_phead = get_list_head(&psta->sleep_q);
-	xmitframe_plist = get_next(xmitframe_phead);
+	xmitframe_plist = xmitframe_phead->next;
 
 	while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
 		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
-		xmitframe_plist = get_next(xmitframe_plist);
+		xmitframe_plist = xmitframe_plist->next;
 
 		rtw_list_delete(&pxmitframe->list);
 
@@ -2219,12 +2219,12 @@ void wakeup_sta_to_xmit(struct adapter *padapter, struct sta_info *psta)
 		spin_lock_bh(&psta_bmc->sleep_q.lock);
 
 		xmitframe_phead = get_list_head(&psta_bmc->sleep_q);
-		xmitframe_plist = get_next(xmitframe_phead);
+		xmitframe_plist = xmitframe_phead->next;
 
 		while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
 			pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
-			xmitframe_plist = get_next(xmitframe_plist);
+			xmitframe_plist = xmitframe_plist->next;
 
 			rtw_list_delete(&pxmitframe->list);
 
@@ -2266,12 +2266,12 @@ void xmit_delivery_enabled_frames(struct adapter *padapter, struct sta_info *pst
 	spin_lock_bh(&psta->sleep_q.lock);
 
 	xmitframe_phead = get_list_head(&psta->sleep_q);
-	xmitframe_plist = get_next(xmitframe_phead);
+	xmitframe_plist = xmitframe_phead->next;
 
 	while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
 		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
 
-		xmitframe_plist = get_next(xmitframe_plist);
+		xmitframe_plist = xmitframe_plist->next;
 
 		switch (pxmitframe->attrib.priority) {
 		case 1:
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
index 50bc215..3476f88 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c
@@ -537,11 +537,11 @@ s32 rtl8188eu_xmitframe_complete(struct adapter *adapt, struct xmit_priv *pxmitp
 	spin_lock_bh(&pxmitpriv->lock);
 
 	xmitframe_phead = get_list_head(&ptxservq->sta_pending);
-	xmitframe_plist = get_next(xmitframe_phead);
+	xmitframe_plist = xmitframe_phead->next;
 
 	while (!rtw_end_of_queue_search(xmitframe_phead, xmitframe_plist)) {
 		pxmitframe = container_of(xmitframe_plist, struct xmit_frame, list);
-		xmitframe_plist = get_next(xmitframe_plist);
+		xmitframe_plist = xmitframe_plist->next;
 
 		pxmitframe->agg_num = 0; /*  not first frame of aggregation */
 		pxmitframe->pkt_offset = 0; /*  not first frame of aggregation, no need to reserve offset */
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 5939921..09e2d48 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -62,11 +62,6 @@ struct	__queue	{
 	spinlock_t lock;
 };
 
-static inline struct list_head *get_next(struct list_head *list)
-{
-	return list->next;
-}
-
 static inline struct list_head *get_list_head(struct __queue *queue)
 {
 	return &(queue->queue);
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index f9e52b3..08be34e 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -1139,7 +1139,7 @@ static int rtw_wx_set_wap(struct net_device *dev,
 	authmode = padapter->securitypriv.ndisauthtype;
 	spin_lock_bh(&queue->lock);
 	phead = get_list_head(queue);
-	pmlmepriv->pscanned = get_next(phead);
+	pmlmepriv->pscanned = phead->next;
 
 	while (1) {
 		if ((rtw_end_of_queue_search(phead, pmlmepriv->pscanned)) == true)
@@ -1147,7 +1147,7 @@ static int rtw_wx_set_wap(struct net_device *dev,
 
 		pnetwork = container_of(pmlmepriv->pscanned, struct wlan_network, list);
 
-		pmlmepriv->pscanned = get_next(pmlmepriv->pscanned);
+		pmlmepriv->pscanned = pmlmepriv->pscanned->next;
 
 		dst_bssid = pnetwork->network.MacAddress;
 
@@ -1441,7 +1441,7 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist))
@@ -1458,7 +1458,7 @@ static int rtw_wx_get_scan(struct net_device *dev, struct iw_request_info *a,
 		if (rtw_ch_set_search_ch(padapter->mlmeextpriv.channel_set, pnetwork->network.Configuration.DSConfig) >= 0)
 			ev = translate_scan(padapter, a, pnetwork, ev, stop);
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -1531,7 +1531,7 @@ static int rtw_wx_set_essid(struct net_device *dev,
 		RT_TRACE(_module_rtl871x_ioctl_os_c, _drv_info_, ("rtw_wx_set_essid: ssid =[%s]\n", src_ssid));
 		spin_lock_bh(&queue->lock);
 	       phead = get_list_head(queue);
-	      pmlmepriv->pscanned = get_next(phead);
+	      pmlmepriv->pscanned = phead->next;
 
 		while (1) {
 			if (rtw_end_of_queue_search(phead, pmlmepriv->pscanned) == true) {
@@ -1543,7 +1543,7 @@ static int rtw_wx_set_essid(struct net_device *dev,
 
 			pnetwork = container_of(pmlmepriv->pscanned, struct wlan_network, list);
 
-			pmlmepriv->pscanned = get_next(pmlmepriv->pscanned);
+			pmlmepriv->pscanned = pmlmepriv->pscanned->next;
 
 			dst_ssid = pnetwork->network.Ssid.Ssid;
 
@@ -2608,7 +2608,7 @@ static int rtw_get_ap_info(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -2639,7 +2639,7 @@ static int rtw_get_ap_info(struct net_device *dev,
 			}
 		}
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3111,7 +3111,7 @@ static int rtw_p2p_get_wps_configmethod(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3135,7 +3135,7 @@ static int rtw_p2p_get_wps_configmethod(struct net_device *dev,
 			}
 			break;
 		}
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3181,7 +3181,7 @@ static int rtw_p2p_get_go_device_address(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3216,7 +3216,7 @@ static int rtw_p2p_get_go_device_address(struct net_device *dev,
 			}
 	     }
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3265,7 +3265,7 @@ static int rtw_p2p_get_device_type(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3296,7 +3296,7 @@ static int rtw_p2p_get_device_type(struct net_device *dev,
 			break;
 	     }
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3344,7 +3344,7 @@ static int rtw_p2p_get_device_name(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3367,7 +3367,7 @@ static int rtw_p2p_get_device_name(struct net_device *dev,
 			break;
 		}
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3415,7 +3415,7 @@ static int rtw_p2p_get_invitation_procedure(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3441,7 +3441,7 @@ static int rtw_p2p_get_invitation_procedure(struct net_device *dev,
 				}
 			}
 		}
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3497,7 +3497,7 @@ static int rtw_p2p_connect(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3509,7 +3509,7 @@ static int rtw_p2p_connect(struct net_device *dev,
 			break;
 		}
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3592,7 +3592,7 @@ static int rtw_p2p_invite_req(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3623,7 +3623,7 @@ static int rtw_p2p_invite_req(struct net_device *dev,
 				}
 			}
 		}
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -3742,7 +3742,7 @@ static int rtw_p2p_prov_disc(struct net_device *dev,
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 
 	phead = get_list_head(queue);
-	plist = get_next(phead);
+	plist = phead->next;
 
 	while (1) {
 		if (rtw_end_of_queue_search(phead, plist) == true)
@@ -3782,7 +3782,7 @@ static int rtw_p2p_prov_disc(struct net_device *dev,
 			}
 		}
 
-		plist = get_next(plist);
+		plist = plist->next;
 	}
 
 	spin_unlock_bh(&pmlmepriv->scanned_queue.lock);
@@ -4437,12 +4437,12 @@ static int rtw_dbg_port(struct net_device *dev,
 
 				for (i = 0; i < NUM_STA; i++) {
 					phead = &(pstapriv->sta_hash[i]);
-					plist = get_next(phead);
+					plist = phead->next;
 
 					while ((rtw_end_of_queue_search(phead, plist)) == false) {
 						psta = container_of(plist, struct sta_info, hash_list);
 
-						plist = get_next(plist);
+						plist = plist->next;
 
 						if (extra_arg == psta->aid) {
 							DBG_88E("sta's macaddr:%pM\n", (psta->hwaddr));
diff --git a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
index dda73b3..a84a8b9 100644
--- a/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/xmit_linux.c
@@ -200,13 +200,13 @@ static int rtw_mlcst2unicst(struct adapter *padapter, struct sk_buff *skb)
 
 	spin_lock_bh(&pstapriv->asoc_list_lock);
 	phead = &pstapriv->asoc_list;
-	plist = get_next(phead);
+	plist = phead->next;
 
 	/* free sta asoc_queue */
 	while (!rtw_end_of_queue_search(phead, plist)) {
 		psta = container_of(plist, struct sta_info, asoc_list);
 
-		plist = get_next(plist);
+		plist = plist->next;
 
 		/* avoid   come from STA1 and send back STA1 */
 		if (!memcmp(psta->hwaddr, &skb->data[6], 6))
-- 
1.8.4.5
