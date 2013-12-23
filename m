From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 19/21] wireless: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:11:28 +0800
Message-ID: <52B7C600.8030907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/wireless/adm8211.c                        |  2 +-
 drivers/net/wireless/ath/ath10k/mac.c                 |  2 +-
 drivers/net/wireless/ath/ath10k/txrx.c                |  2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c            |  2 +-
 drivers/net/wireless/ath/ath6kl/main.c                |  6 +++---
 drivers/net/wireless/ath/ath6kl/txrx.c                |  3 +--
 drivers/net/wireless/ath/ath6kl/wmi.c                 |  4 ++--
 drivers/net/wireless/ath/wcn36xx/txrx.c               |  2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c           |  2 +-
 drivers/net/wireless/atmel.c                          | 16 +++++++++-------
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c    |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c         |  9 ++++-----
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 10 ++++------
 drivers/net/wireless/libertas/main.c                  |  2 +-
 drivers/net/wireless/mac80211_hwsim.c                 |  7 +++----
 drivers/net/wireless/mwl8k.c                          |  7 +++----
 drivers/net/wireless/orinoco/main.c                   |  2 +-
 drivers/net/wireless/prism54/isl_ioctl.c              |  9 +++++----
 drivers/net/wireless/ray_cs.c                         |  2 +-
 drivers/net/wireless/ti/wl1251/main.c                 |  2 +-
 drivers/net/wireless/wl3501_cs.c                      |  3 +--
 21 files changed, 46 insertions(+), 50 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index cfce83e..040612a 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1314,7 +1314,7 @@ static void adm8211_bss_info_changed(struct ieee80211_hw *dev,
 	if (!(changes & BSS_CHANGED_BSSID))
 		return;
 
-	if (memcmp(conf->bssid, priv->bssid, ETH_ALEN)) {
+	if (!ether_addr_equal_unaligned(conf->bssid, priv->bssid)) {
 		adm8211_set_bssid(dev, conf->bssid);
 		memcpy(priv->bssid, conf->bssid, ETH_ALEN);
 	}
diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index ce9ef349..c5db100 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -66,7 +66,7 @@ static int ath10k_send_key(struct ath10k_vif *arvif,
 		arg.key_cipher = WMI_CIPHER_WEP;
 		/* AP/IBSS mode requires self-key to be groupwise
 		 * Otherwise pairwise key must be set */
-		if (memcmp(macaddr, arvif->vif->addr, ETH_ALEN))
+		if (!ether_addr_equal_unaligned(macaddr, arvif->vif->addr))
 			arg.key_flags = WMI_KEY_PAIRWISE;
 		break;
 	default:
diff --git a/drivers/net/wireless/ath/ath10k/txrx.c b/drivers/net/wireless/ath/ath10k/txrx.c
index 2282980..1fbd95f 100644
--- a/drivers/net/wireless/ath/ath10k/txrx.c
+++ b/drivers/net/wireless/ath/ath10k/txrx.c
@@ -288,7 +288,7 @@ struct ath10k_peer *ath10k_peer_find(struct ath10k *ar, int vdev_id,
 	list_for_each_entry(peer, &ar->peers, list) {
 		if (peer->vdev_id != vdev_id)
 			continue;
-		if (memcmp(peer->addr, addr, ETH_ALEN))
+		if (!ether_addr_equal_unaligned(peer->addr, addr))
 			continue;
 
 		return peer;
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index fd4c89d..38d275f 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -1773,7 +1773,7 @@ static int ath6kl_get_station(struct wiphy *wiphy, struct net_device *dev,
 	int ret;
 	u8 mcs;
 
-	if (memcmp(mac, vif->bssid, ETH_ALEN) != 0)
+	if (!ether_addr_equal_unaligned(mac, vif->bssid))
 		return -ENOENT;
 
 	if (down_interruptible(&ar->sem))
diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index 5839fc2..d6edc247 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -35,7 +35,7 @@ struct ath6kl_sta *ath6kl_find_sta(struct ath6kl_vif *vif, u8 *node_addr)
 	max_conn = (vif->nw_type == AP_NETWORK) ? AP_MAX_NUM_STA : 0;
 
 	for (i = 0; i < max_conn; i++) {
-		if (memcmp(node_addr, ar->sta_list[i].mac, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(node_addr, ar->sta_list[i].mac)) {
 			conn = &ar->sta_list[i];
 			break;
 		}
@@ -132,7 +132,7 @@ static u8 ath6kl_remove_sta(struct ath6kl *ar, u8 *mac, u16 reason)
 		}
 	} else {
 		for (i = 0; i < AP_MAX_NUM_STA; i++) {
-			if (memcmp(ar->sta_list[i].mac, mac, ETH_ALEN) == 0) {
+			if (ether_addr_equal_unaligned(ar->sta_list[i].mac, mac)) {
 				ath6kl_dbg(ATH6KL_DBG_TRC,
 					   "deleting station %pM aid=%d reason=%d\n",
 					   mac, ar->sta_list[i].aid, reason);
@@ -1008,7 +1008,7 @@ void ath6kl_disconnect_event(struct ath6kl_vif *vif, u8 reason, u8 *bssid,
 			cfg80211_del_sta(vif->ndev, bssid, GFP_KERNEL);
 		}
 
-		if (memcmp(vif->ndev->dev_addr, bssid, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(vif->ndev->dev_addr, bssid)) {
 			memset(vif->wep_key_list, 0, sizeof(vif->wep_key_list));
 			clear_bit(CONNECTED, &vif->flags);
 		}
diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index ebb2404..782e139 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -55,8 +55,7 @@ static u8 ath6kl_ibss_map_epid(struct sk_buff *skb, struct net_device *dev,
 		return ENDPOINT_2;
 
 	for (i = 0; i < ar->node_num; i++) {
-		if (memcmp(eth_hdr->h_dest, ar->node_map[i].mac_addr,
-			   ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(eth_hdr->h_dest, ar->node_map[i].mac_addr)) {
 			*map_no = i + 1;
 			ar->node_map[i].tx_pend++;
 			return ar->node_map[i].ep_id;
diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index 546d5da..b45be4a 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -817,7 +817,7 @@ static int ath6kl_wmi_connect_event_rx(struct wmi *wmi, u8 *datap, int len,
 	if (vif->nw_type == AP_NETWORK) {
 		/* AP mode start/STA connected event */
 		struct net_device *dev = vif->ndev;
-		if (memcmp(dev->dev_addr, ev->u.ap_bss.bssid, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(dev->dev_addr, ev->u.ap_bss.bssid)) {
 			ath6kl_dbg(ATH6KL_DBG_WMI,
 				   "%s: freq %d bssid %pM (AP started)\n",
 				   __func__, le16_to_cpu(ev->u.ap_bss.ch),
@@ -1080,7 +1080,7 @@ static int ath6kl_wmi_bssinfo_event_rx(struct wmi *wmi, u8 *datap, int len,
 
 	if (bih->frame_type == BEACON_FTYPE &&
 	    test_bit(CONNECTED, &vif->flags) &&
-	    memcmp(bih->bssid, vif->bssid, ETH_ALEN) == 0) {
+	    ether_addr_equal_unaligned(bih->bssid, vif->bssid)) {
 		const u8 *tim;
 		tim = cfg80211_find_ie(WLAN_EID_TIM, buf + 8 + 2 + 2,
 				       len - 8 - 2 - 2);
diff --git a/drivers/net/wireless/ath/wcn36xx/txrx.c b/drivers/net/wireless/ath/wcn36xx/txrx.c
index b2b60e3..e25bd0f 100644
--- a/drivers/net/wireless/ath/wcn36xx/txrx.c
+++ b/drivers/net/wireless/ath/wcn36xx/txrx.c
@@ -105,7 +105,7 @@ static inline struct wcn36xx_vif *get_vif_by_addr(struct wcn36xx *wcn,
 			vif = container_of((void *)vif_priv,
 				   struct ieee80211_vif,
 				   drv_priv);
-			if (memcmp(vif->addr, addr, ETH_ALEN) == 0)
+			if (ether_addr_equal_unaligned(vif->addr, addr))
 				return vif_priv;
 	}
 	wcn36xx_warn("vif %pM not found\n", addr);
diff --git a/drivers/net/wireless/ath/wil6210/cfg80211.c b/drivers/net/wireless/ath/wil6210/cfg80211.c
index 5b34076..58d0ffb 100644
--- a/drivers/net/wireless/ath/wil6210/cfg80211.c
+++ b/drivers/net/wireless/ath/wil6210/cfg80211.c
@@ -115,7 +115,7 @@ static int wil_cfg80211_get_station(struct wiphy *wiphy,
 		.interval_usec = 0,
 	};
 
-	if (memcmp(mac, wil->dst_addr[0], ETH_ALEN))
+	if (!ether_addr_equal_unaligned(mac, wil->dst_addr[0]))
 		return -ENOENT;
 
 	/* WMI_NOTIFY_REQ_DONE_EVENTID handler fills wil->stats.bf_mcs */
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index b73b7e3..8caf599 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1012,7 +1012,7 @@ static void frag_rx_path(struct atmel_private *priv,
 
 	} else if (priv->frag_no == frag_no &&
 		   priv->frag_seq == seq_no &&
-		   memcmp(priv->frag_source, source, ETH_ALEN) == 0) {
+		   ether_addr_equal_unaligned(priv->frag_source, source)) {
 
 		atmel_copy_to_host(priv->dev, &priv->rx_buf[12 + priv->frag_len],
 				   rx_packet_loc, msdu_size);
@@ -2499,8 +2499,8 @@ static int atmel_set_wap(struct net_device *dev,
 	if (awrq->sa_family != ARPHRD_ETHER)
 		return -EINVAL;
 
-	if (!memcmp(any, awrq->sa_data, 6) ||
-	    !memcmp(off, awrq->sa_data, 6)) {
+	if (ether_addr_equal_unaligned(any, awrq->sa_data) ||
+	    ether_addr_equal_unaligned(off, awrq->sa_data)) {
 		del_timer_sync(&priv->management_timer);
 		spin_lock_irqsave(&priv->irqlock, flags);
 		atmel_scan(priv, 1);
@@ -2509,7 +2509,7 @@ static int atmel_set_wap(struct net_device *dev,
 	}
 
 	for (i = 0; i < priv->BSS_list_entries; i++) {
-		if (memcmp(priv->BSSinfo[i].BSSID, awrq->sa_data, 6) == 0) {
+		if (ether_addr_equal_unaligned(priv->BSSinfo[i].BSSID, awrq->sa_data)) {
 			if (!priv->wep_is_on && priv->BSSinfo[i].UsingWEP) {
 				return -EINVAL;
 			} else if  (priv->wep_is_on && !priv->BSSinfo[i].UsingWEP) {
@@ -2966,9 +2966,11 @@ static int is_frame_from_current_bss(struct atmel_private *priv,
 				     struct ieee80211_hdr *header)
 {
 	if (le16_to_cpu(header->frame_control) & IEEE80211_FCTL_FROMDS)
-		return memcmp(header->addr3, priv->CurrentBSSID, 6) == 0;
+		return ether_addr_equal_unaligned(header->addr3,
+						  priv->CurrentBSSID);
 	else
-		return memcmp(header->addr2, priv->CurrentBSSID, 6) == 0;
+		return ether_addr_equal_unaligned(header->addr2,
+						  priv->CurrentBSSID);
 }
 
 static int retrieve_bss(struct atmel_private *priv)
@@ -3021,7 +3023,7 @@ static void store_bss_info(struct atmel_private *priv,
 	int i, index;
 
 	for (index = -1, i = 0; i < priv->BSS_list_entries; i++)
-		if (memcmp(bss, priv->BSSinfo[i].BSSID, ETH_ALEN) == 0)
+		if (ether_addr_equal_unaligned(bss, priv->BSSinfo[i].BSSID))
 			index = i;
 
 	/* If we process a probe and an entry from this BSS exists
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
index e9bdfdb..6be1c20 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
@@ -719,7 +719,7 @@ brcmf_fws_macdesc_lookup(struct brcmf_fws_info *fws, u8 *ea)
 
 	entry = &fws->desc.nodes[0];
 	for (i = 0; i < ARRAY_SIZE(fws->desc.nodes); i++) {
-		if (entry->occupied && !memcmp(entry->ea, ea, ETH_ALEN))
+		if (entry->occupied && ether_addr_equal_unaligned(entry->ea, ea))
 			return entry;
 		entry++;
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index d318036..a1f38b4 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -1243,7 +1243,7 @@ bool brcmf_p2p_scan_finding_common_channel(struct brcmf_cfg80211_info *cfg,
 					    IEEE80211_P2P_ATTR_DEVICE_ID,
 					    p2p_dev_addr, sizeof(p2p_dev_addr));
 	if ((err >= 0) &&
-	    (!memcmp(p2p_dev_addr, afx_hdl->tx_dst_addr, ETH_ALEN))) {
+	    (ether_addr_equal_unaligned(p2p_dev_addr, afx_hdl->tx_dst_addr))) {
 		if (!bi->ctl_ch) {
 			ch.chspec = le16_to_cpu(bi->chanspec);
 			cfg->d11inf.decchspec(&ch);
@@ -1313,7 +1313,7 @@ brcmf_p2p_gon_req_collision(struct brcmf_p2p_info *p2p, u8 *mac)
 	 * this device will process gon request and drop gon req of peer.
 	 */
 	ifp = p2p->bss_idx[P2PAPI_BSSCFG_DEVICE].vif->ifp;
-	if (memcmp(mac, ifp->mac_addr, ETH_ALEN) < 0) {
+	if (!ether_addr_equal_unaligned(mac, ifp->mac_addr) < 0) {
 		brcmf_dbg(INFO, "Block transmit gon req !!!\n");
 		p2p->block_gon_req_tx = true;
 		/* if we are finding a common channel for sending af,
@@ -1380,8 +1380,7 @@ int brcmf_p2p_notify_action_frame_rx(struct brcmf_if *ifp,
 		    (brcmf_p2p_gon_req_collision(p2p, (u8 *)e->addr))) {
 			if (test_bit(BRCMF_P2P_STATUS_FINDING_COMMON_CHANNEL,
 				     &p2p->status) &&
-			    (memcmp(afx_hdl->tx_dst_addr, e->addr,
-				    ETH_ALEN) == 0)) {
+			    (ether_addr_equal_unaligned(afx_hdl->tx_dst_addr, e->addr))) {
 				afx_hdl->peer_chan = ch.chnum;
 				brcmf_dbg(INFO, "GON request: Peer found, channel=%d\n",
 					  afx_hdl->peer_chan);
@@ -1865,7 +1864,7 @@ s32 brcmf_p2p_notify_rx_mgmt_p2p_probereq(struct brcmf_if *ifp,
 	cfg->d11inf.decchspec(&ch);
 
 	if (test_bit(BRCMF_P2P_STATUS_FINDING_COMMON_CHANNEL, &p2p->status) &&
-	    (memcmp(afx_hdl->tx_dst_addr, e->addr, ETH_ALEN) == 0)) {
+	    (ether_addr_equal_unaligned(afx_hdl->tx_dst_addr, e->addr))) {
 		afx_hdl->peer_chan = ch.chnum;
 		brcmf_dbg(INFO, "PROBE REQUEST: Peer found, channel=%d\n",
 			  afx_hdl->peer_chan);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 3966fe0..f4b0115 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -2186,7 +2186,7 @@ brcmf_cfg80211_get_station(struct wiphy *wiphy, struct net_device *ndev,
 		brcmf_dbg(TRACE, "STA idle time : %d ms, connected time :%d sec\n",
 			  sinfo->inactive_time, sinfo->connected_time);
 	} else if (ifp->vif->mode == WL_MODE_BSS) {
-		if (memcmp(mac, bssid, ETH_ALEN)) {
+		if (!ether_addr_equal_unaligned(mac, bssid)) {
 			brcmf_err("Wrong Mac address cfg_mac-%pM wl_bssid-%pM\n",
 				  mac, bssid);
 			err = -ENOENT;
@@ -2552,7 +2552,7 @@ brcmf_compare_update_same_bss(struct brcmf_cfg80211_info *cfg,
 	ch_bss_info_le.chspec = le16_to_cpu(bss_info_le->chanspec);
 	cfg->d11inf.decchspec(&ch_bss_info_le);
 
-	if (!memcmp(&bss_info_le->BSSID, &bss->BSSID, ETH_ALEN) &&
+	if (ether_addr_equal_unaligned(&bss_info_le->BSSID, &bss->BSSID) &&
 		ch_bss.band == ch_bss_info_le.band &&
 		bss_info_le->SSID_len == bss->SSID_len &&
 		!memcmp(bss_info_le->SSID, bss->SSID, bss_info_le->SSID_len)) {
@@ -2798,7 +2798,7 @@ brcmf_cfg80211_set_pmksa(struct wiphy *wiphy, struct net_device *ndev,
 
 	pmkid_len = le32_to_cpu(pmkids->npmkid);
 	for (i = 0; i < pmkid_len; i++)
-		if (!memcmp(pmksa->bssid, pmkids->pmkid[i].BSSID, ETH_ALEN))
+		if (ether_addr_equal_unaligned(pmksa->bssid, pmkids->pmkid[i].BSSID))
 			break;
 	if (i < WL_NUM_PMKIDS_MAX) {
 		memcpy(pmkids->pmkid[i].BSSID, pmksa->bssid, ETH_ALEN);
@@ -2845,9 +2845,7 @@ brcmf_cfg80211_del_pmksa(struct wiphy *wiphy, struct net_device *ndev,
 
 	pmkid_len = le32_to_cpu(cfg->pmk_list->pmkids.npmkid);
 	for (i = 0; i < pmkid_len; i++)
-		if (!memcmp
-		    (pmksa->bssid, &cfg->pmk_list->pmkids.pmkid[i].BSSID,
-		     ETH_ALEN))
+		if (ether_addr_equal_unaligned(pmksa->bssid, &cfg->pmk_list->pmkids.pmkid[i].BSSID))
 			break;
 
 	if ((pmkid_len > 0)
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 0c02f04..6c92239 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -327,7 +327,7 @@ static inline int mac_in_list(unsigned char *list, int list_len,
 			      unsigned char *mac)
 {
 	while (list_len) {
-		if (!memcmp(list, mac, ETH_ALEN))
+		if (ether_addr_equal_unaligned(list, mac))
 			return 1;
 		list += ETH_ALEN;
 		list_len--;
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 9c0cc8d..b10fc6b 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -561,8 +561,7 @@ static bool hwsim_ps_rx_ok(struct mac80211_hwsim_data *data,
 		/* Allow unicast frames to own address if there is a pending
 		 * PS-Poll */
 		if (data->ps_poll_pending &&
-		    memcmp(data->hw->wiphy->perm_addr, skb->data + 4,
-			   ETH_ALEN) == 0) {
+		    ether_addr_equal_unaligned(data->hw->wiphy->perm_addr, skb->data + 4)) {
 			data->ps_poll_pending = false;
 			return true;
 		}
@@ -582,7 +581,7 @@ static void mac80211_hwsim_addr_iter(void *data, u8 *mac,
 				     struct ieee80211_vif *vif)
 {
 	struct mac80211_hwsim_addr_match_data *md = data;
-	if (memcmp(mac, md->addr, ETH_ALEN) == 0)
+	if (ether_addr_equal_unaligned(mac, md->addr))
 		md->ret = true;
 }
 
@@ -592,7 +591,7 @@ static bool mac80211_hwsim_addr_match(struct mac80211_hwsim_data *data,
 {
 	struct mac80211_hwsim_addr_match_data md;
 
-	if (memcmp(addr, data->hw->wiphy->perm_addr, ETH_ALEN) == 0)
+	if (ether_addr_equal_unaligned(addr, data->hw->wiphy->perm_addr))
 		return true;
 
 	md.ret = false;
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index b953ad6..b4ca4b6 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1286,8 +1286,7 @@ static inline struct mwl8k_vif *mwl8k_find_vif_bss(struct list_head *vif_list,
 
 	list_for_each_entry(mwl8k_vif,
 			    vif_list, list) {
-		if (memcmp(bssid, mwl8k_vif->bssid,
-			   ETH_ALEN) == 0)
+		if (ether_addr_equal_unaligned(bssid, mwl8k_vif->bssid))
 			return mwl8k_vif;
 	}
 
@@ -1826,7 +1825,7 @@ mwl8k_lookup_stream(struct ieee80211_hw *hw, u8 *addr, u8 tid)
 		stream = &priv->ampdu[i];
 		if (stream->state == AMPDU_NO_STREAM)
 			continue;
-		if (!memcmp(stream->sta->addr, addr, ETH_ALEN) &&
+		if (ether_addr_equal_unaligned(stream->sta->addr, addr) &&
 		    stream->tid == tid)
 			return stream;
 	}
@@ -4030,7 +4029,7 @@ static int mwl8k_cmd_set_new_stn_del(struct ieee80211_hw *hw,
 		struct mwl8k_ampdu_stream *s;
 		s = &priv->ampdu[i];
 		if (s->state != AMPDU_NO_STREAM) {
-			if (memcmp(s->sta->addr, addr, ETH_ALEN) == 0) {
+			if (ether_addr_equal_unaligned(s->sta->addr, addr)) {
 				if (s->state == AMPDU_STREAM_ACTIVE) {
 					idx = s->idx;
 					spin_unlock(&priv->stream_lock);
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 38ec8d1..5a6212d 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1203,7 +1203,7 @@ static void orinoco_join_ap(struct work_struct *work)
 	 * we were requested to join */
 	for (; offset + atom_len <= len; offset += atom_len) {
 		atom = (struct prism2_scan_apinfo *) (buf + offset);
-		if (memcmp(&atom->bssid, priv->desired_bssid, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(&atom->bssid, priv->desired_bssid, ETH_ALEN) != 0) {
 			found = 1;
 			break;
 		}
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index df784fe..444438d 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -24,6 +24,7 @@
 #include <linux/if_arp.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
+#include <linux/etherdevice.h>
 
 #include <asm/uaccess.h>
 
@@ -1860,7 +1861,7 @@ prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 	if (mutex_lock_interruptible(&acl->lock))
 		return -ERESTARTSYS;
 	list_for_each_entry(entry, &acl->mac_list, _list) {
-		if (memcmp(entry->addr, addr->sa_data, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(entry->addr, addr->sa_data)) {
 			list_del(&entry->_list);
 			acl->size--;
 			kfree(entry);
@@ -1965,7 +1966,7 @@ prism54_mac_accept(struct islpci_acl *acl, char *mac)
 	}
 
 	list_for_each_entry(entry, &acl->mac_list, _list) {
-		if (memcmp(entry->addr, mac, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(entry->addr, mac)) {
 			res = 1;
 			break;
 		}
@@ -2121,7 +2122,7 @@ prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 	/* try to use existing entry */
 	list_for_each(ptr, &priv->bss_wpa_list) {
 		bss = list_entry(ptr, struct islpci_bss_wpa_ie, list);
-		if (memcmp(bss->bssid, bssid, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(bss->bssid, bssid)) {
 			list_move(&bss->list, &priv->bss_wpa_list);
 			break;
 		}
@@ -2181,7 +2182,7 @@ prism54_wpa_bss_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie)
 
 	list_for_each(ptr, &priv->bss_wpa_list) {
 		bss = list_entry(ptr, struct islpci_bss_wpa_ie, list);
-		if (memcmp(bss->bssid, bssid, ETH_ALEN) == 0)
+		if (ether_addr_equal_unaligned(bss->bssid, bssid))
 			break;
 		bss = NULL;
 	}
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index cbf0a58..6375429 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -2257,7 +2257,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 	/* For the Access Point or the node having started the ad-hoc net
 	 * note : ad-hoc work only in some specific configurations, but we
 	 * kludge in ray_get_wireless_stats... */
-	if (!memcmp(linksrcaddr, local->bss_id, ETH_ALEN)) {
+	if (ether_addr_equal_unaligned(linksrcaddr, local->bss_id)) {
 		/* Update statistics */
 		/*local->wstats.qual.qual = none ? */
 		local->wstats.qual.level = siglev;
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 3291ffa..b8a360b 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -521,7 +521,7 @@ static int wl1251_op_add_interface(struct ieee80211_hw *hw,
 		goto out;
 	}
 
-	if (memcmp(wl->mac_addr, vif->addr, ETH_ALEN)) {
+	if (!ether_addr_equal_unaligned(wl->mac_addr, vif->addr)) {
 		memcpy(wl->mac_addr, vif->addr, ETH_ALEN);
 		SET_IEEE80211_PERM_ADDR(wl->hw, wl->mac_addr);
 		ret = wl1251_acx_station_id(wl);
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 38d2089..c56214c 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -673,8 +673,7 @@ static void wl3501_mgmt_scan_confirm(struct wl3501_card *this, u16 addr)
 				matchflag = 1;
 			if (matchflag) {
 				for (i = 0; i < this->bss_cnt; i++) {
-					if (!memcmp(this->bss_set[i].bssid,
-						    sig.bssid, ETH_ALEN)) {
+					if (ether_addr_equal_unaligned(this->bss_set[i].bssid, sig.bssid)) {
 						matchflag = 0;
 						break;
 					}
-- 
1.8.0
