From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] drivers/net: Convert compare_ether_addr to ether_addr_equal
Date: Wed,  9 May 2012 20:17:46 -0700
Message-ID: <7c9881a67c52c2f218480b6742155b6d6928122d.1336618708.git.joe@perches.com>
References: <cover.1336618707.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	ath5k-devel@lists.ath5k.org, ath9k-devel@lists.ath9k.org
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40035 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754550Ab2EJDR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 23:17:58 -0400
In-Reply-To: <cover.1336618707.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_main.c                   |    2 +-
 drivers/net/ethernet/amd/depca.c                  |    3 ++-
 drivers/net/ethernet/cisco/enic/enic_main.c       |   12 ++++--------
 drivers/net/ethernet/dec/ewrk3.c                  |    3 ++-
 drivers/net/ethernet/dec/tulip/de4x5.c            |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |    5 ++---
 drivers/net/ethernet/sfc/ethtool.c                |    2 +-
 drivers/net/ethernet/sun/sunvnet.c                |    2 +-
 drivers/net/ethernet/tile/tilepro.c               |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c |    8 ++++----
 drivers/net/tun.c                                 |    2 +-
 drivers/net/wireless/at76c50x-usb.c               |    2 +-
 drivers/net/wireless/ath/ath5k/base.c             |    6 +++---
 drivers/net/wireless/ath/ath9k/recv.c             |    2 +-
 drivers/net/wireless/ath/carl9170/rx.c            |    2 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c          |   16 ++++++++--------
 drivers/net/wireless/iwlegacy/3945.c              |    4 ++--
 drivers/net/wireless/iwlegacy/4965-mac.c          |    2 +-
 drivers/net/wireless/iwlegacy/common.c            |   14 +++++++-------
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c         |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c       |    8 ++++----
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c        |    6 +++---
 drivers/net/wireless/mwl8k.c                      |    2 +-
 drivers/net/wireless/p54/txrx.c                   |    2 +-
 drivers/net/wireless/rndis_wlan.c                 |   12 ++++++------
 drivers/net/wireless/rtlwifi/base.c               |    2 +-
 drivers/net/wireless/rtlwifi/ps.c                 |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c      |   10 +++++-----
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c      |   10 +++++-----
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c      |   11 ++++++-----
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c      |   11 ++++++-----
 31 files changed, 85 insertions(+), 86 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 16dbf53..bbb0043 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1961,7 +1961,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	write_lock_bh(&bond->lock);
 
 	if (!bond->params.fail_over_mac) {
-		if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr) &&
+		if (ether_addr_equal(bond_dev->dev_addr, slave->perm_hwaddr) &&
 		    bond->slave_cnt > 1)
 			pr_warning("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
 				   bond_dev->name, slave_dev->name,
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index 86dd957..7f7b99a 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -1079,7 +1079,8 @@ static int depca_rx(struct net_device *dev)
 						} else {
 							lp->pktStats.multicast++;
 						}
-					} else if (compare_ether_addr(buf, dev->dev_addr) == 0) {
+					} else if (ether_addr_equal(buf,
+								    dev->dev_addr)) {
 						lp->pktStats.unicast++;
 					}
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index d7ac6c1..8132c78 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -944,8 +944,7 @@ static void enic_update_multicast_addr_list(struct enic *enic)
 
 	for (i = 0; i < enic->mc_count; i++) {
 		for (j = 0; j < mc_count; j++)
-			if (compare_ether_addr(enic->mc_addr[i],
-				mc_addr[j]) == 0)
+			if (ether_addr_equal(enic->mc_addr[i], mc_addr[j]))
 				break;
 		if (j == mc_count)
 			enic_dev_del_addr(enic, enic->mc_addr[i]);
@@ -953,8 +952,7 @@ static void enic_update_multicast_addr_list(struct enic *enic)
 
 	for (i = 0; i < mc_count; i++) {
 		for (j = 0; j < enic->mc_count; j++)
-			if (compare_ether_addr(mc_addr[i],
-				enic->mc_addr[j]) == 0)
+			if (ether_addr_equal(mc_addr[i], enic->mc_addr[j]))
 				break;
 		if (j == enic->mc_count)
 			enic_dev_add_addr(enic, mc_addr[i]);
@@ -999,8 +997,7 @@ static void enic_update_unicast_addr_list(struct enic *enic)
 
 	for (i = 0; i < enic->uc_count; i++) {
 		for (j = 0; j < uc_count; j++)
-			if (compare_ether_addr(enic->uc_addr[i],
-				uc_addr[j]) == 0)
+			if (ether_addr_equal(enic->uc_addr[i], uc_addr[j]))
 				break;
 		if (j == uc_count)
 			enic_dev_del_addr(enic, enic->uc_addr[i]);
@@ -1008,8 +1005,7 @@ static void enic_update_unicast_addr_list(struct enic *enic)
 
 	for (i = 0; i < uc_count; i++) {
 		for (j = 0; j < enic->uc_count; j++)
-			if (compare_ether_addr(uc_addr[i],
-				enic->uc_addr[j]) == 0)
+			if (ether_addr_equal(uc_addr[i], enic->uc_addr[j]))
 				break;
 		if (j == enic->uc_count)
 			enic_dev_add_addr(enic, uc_addr[i]);
diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index 1879f84..17ae8c6 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -1016,7 +1016,8 @@ static int ewrk3_rx(struct net_device *dev)
 							} else {
 								lp->pktStats.multicast++;
 							}
-						} else if (compare_ether_addr(p, dev->dev_addr) == 0) {
+						} else if (ether_addr_equal(p,
+									    dev->dev_addr)) {
 							lp->pktStats.unicast++;
 						}
 						lp->pktStats.bins[0]++;		/* Duplicates stats.rx_packets */
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 18b106c..d3cd489 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1874,7 +1874,7 @@ de4x5_local_stats(struct net_device *dev, char *buf, int pkt_len)
 	} else {
 	    lp->pktStats.multicast++;
 	}
-    } else if (compare_ether_addr(buf, dev->dev_addr) == 0) {
+    } else if (ether_addr_equal(buf, dev->dev_addr)) {
         lp->pktStats.unicast++;
     }
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 5c47135..46e77a2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1965,7 +1965,7 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	__le16 vlan_id = 0;
 	u8 hindex;
 
-	if (!compare_ether_addr(phdr->h_source, adapter->mac_addr))
+	if (ether_addr_equal(phdr->h_source, adapter->mac_addr))
 		return;
 
 	if (adapter->fhash.fnum >= adapter->fhash.fmax)
@@ -2235,8 +2235,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (adapter->flags & QLCNIC_MACSPOOF) {
 		phdr = (struct ethhdr *)skb->data;
-		if (compare_ether_addr(phdr->h_source,
-					adapter->mac_addr))
+		if (!ether_addr_equal(phdr->h_source, adapter->mac_addr))
 			goto drop_packet;
 	}
 
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index f22f45f..62d4b81 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1023,7 +1023,7 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 			return -EINVAL;
 
 		/* Is it a default UC or MC filter? */
-		if (!compare_ether_addr(mac_mask->h_dest, mac_addr_mc_mask) &&
+		if (ether_addr_equal(mac_mask->h_dest, mac_addr_mc_mask) &&
 		    vlan_tag_mask == 0) {
 			if (is_multicast_ether_addr(mac_entry->h_dest))
 				rc = efx_filter_set_mc_def(&spec);
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 38e3ae9..a108db3 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -618,7 +618,7 @@ struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
 	struct vnet_port *port;
 
 	hlist_for_each_entry(port, n, hp, hash) {
-		if (!compare_ether_addr(port->raddr, skb->data))
+		if (ether_addr_equal(port->raddr, skb->data))
 			return port;
 	}
 	port = NULL;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 3d501ec..96070e9 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -843,7 +843,7 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		if (!is_multicast_ether_addr(buf)) {
 			/* Filter packets not for our address. */
 			const u8 *mine = dev->dev_addr;
-			filter = compare_ether_addr(mine, buf);
+			filter = !ether_addr_equal(mine, buf);
 		}
 	}
 
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 5c14f82..961c832 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1590,8 +1590,8 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 		found = 0;
 		oldest = NULL;
 		list_for_each_entry(target, &wl->network_list, list) {
-			if (!compare_ether_addr(&target->hwinfo->bssid[2],
-						&scan_info->bssid[2])) {
+			if (ether_addr_equal(&target->hwinfo->bssid[2],
+					     &scan_info->bssid[2])) {
 				found = 1;
 				pr_debug("%s: same BBS found scanned list\n",
 					 __func__);
@@ -1691,8 +1691,8 @@ struct gelic_wl_scan_info *gelic_wl_find_best_bss(struct gelic_wl_info *wl)
 
 		/* If bss specified, check it only */
 		if (test_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat)) {
-			if (!compare_ether_addr(&scan_info->hwinfo->bssid[2],
-						wl->bssid)) {
+			if (ether_addr_equal(&scan_info->hwinfo->bssid[2],
+					     wl->bssid)) {
 				best_bss = scan_info;
 				pr_debug("%s: bssid matched\n", __func__);
 				break;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bb8c72c..987aeef 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -313,7 +313,7 @@ static int run_filter(struct tap_filter *filter, const struct sk_buff *skb)
 
 	/* Exact match */
 	for (i = 0; i < filter->count; i++)
-		if (!compare_ether_addr(eh->h_dest, filter->addr[i]))
+		if (ether_addr_equal(eh->h_dest, filter->addr[i]))
 			return 1;
 
 	/* Inexact match (multicast only) */
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index faa8bcb..5ad74c8 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -1751,7 +1751,7 @@ static void at76_mac80211_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	 * following workaround is necessary. If the TX frame is an
 	 * authentication frame extract the bssid and send the CMD_JOIN. */
 	if (mgmt->frame_control & cpu_to_le16(IEEE80211_STYPE_AUTH)) {
-		if (compare_ether_addr(priv->bssid, mgmt->bssid)) {
+		if (!ether_addr_equal(priv->bssid, mgmt->bssid)) {
 			memcpy(priv->bssid, mgmt->bssid, ETH_ALEN);
 			ieee80211_queue_work(hw, &priv->work_join_bssid);
 			dev_kfree_skb_any(skb);
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 49e3b19..0ba81a6 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -462,7 +462,7 @@ void ath5k_vif_iter(void *data, u8 *mac, struct ieee80211_vif *vif)
 	}
 
 	if (iter_data->need_set_hw_addr && iter_data->hw_macaddr)
-		if (compare_ether_addr(iter_data->hw_macaddr, mac) == 0)
+		if (ether_addr_equal(iter_data->hw_macaddr, mac))
 			iter_data->need_set_hw_addr = false;
 
 	if (!iter_data->any_assoc) {
@@ -1170,7 +1170,7 @@ ath5k_check_ibss_tsf(struct ath5k_hw *ah, struct sk_buff *skb,
 
 	if (ieee80211_is_beacon(mgmt->frame_control) &&
 	    le16_to_cpu(mgmt->u.beacon.capab_info) & WLAN_CAPABILITY_IBSS &&
-	    compare_ether_addr(mgmt->bssid, common->curbssid) == 0) {
+	    ether_addr_equal(mgmt->bssid, common->curbssid)) {
 		/*
 		 * Received an IBSS beacon with the same BSSID. Hardware *must*
 		 * have updated the local TSF. We have to work around various
@@ -1234,7 +1234,7 @@ ath5k_update_beacon_rssi(struct ath5k_hw *ah, struct sk_buff *skb, int rssi)
 
 	/* only beacons from our BSSID */
 	if (!ieee80211_is_beacon(mgmt->frame_control) ||
-	    compare_ether_addr(mgmt->bssid, common->curbssid) != 0)
+	    !ether_addr_equal(mgmt->bssid, common->curbssid))
 		return;
 
 	ewma_add(&ah->ah_beacon_rssi_avg, rssi);
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 544e549..e1fcc68 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -1833,7 +1833,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		if (ieee80211_is_beacon(hdr->frame_control)) {
 			RX_STAT_INC(rx_beacons);
 			if (!is_zero_ether_addr(common->curbssid) &&
-			    !compare_ether_addr(hdr->addr3, common->curbssid))
+			    ether_addr_equal(hdr->addr3, common->curbssid))
 				rs.is_mybeacon = true;
 			else
 				rs.is_mybeacon = false;
diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index dc99030..84b22ee 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -538,7 +538,7 @@ static void carl9170_ps_beacon(struct ar9170 *ar, void *data, unsigned int len)
 		return;
 
 	/* and only beacons from the associated BSSID, please */
-	if (compare_ether_addr(hdr->addr3, ar->common.curbssid) ||
+	if (!ether_addr_equal(hdr->addr3, ar->common.curbssid) ||
 	    !ar->common.curaid)
 		return;
 
diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index c4955d2..02e0579 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -77,8 +77,8 @@ static struct libipw_frag_entry *libipw_frag_cache_find(struct
 
 		if (entry->skb != NULL && entry->seq == seq &&
 		    (entry->last_frag + 1 == frag || frag == -1) &&
-		    !compare_ether_addr(entry->src_addr, src) &&
-		    !compare_ether_addr(entry->dst_addr, dst))
+		    ether_addr_equal(entry->src_addr, src) &&
+		    ether_addr_equal(entry->dst_addr, dst))
 			return entry;
 	}
 
@@ -245,12 +245,12 @@ static int libipw_is_eapol_frame(struct libipw_device *ieee,
 	/* check that the frame is unicast frame to us */
 	if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
 	    IEEE80211_FCTL_TODS &&
-	    !compare_ether_addr(hdr->addr1, dev->dev_addr) &&
-	    !compare_ether_addr(hdr->addr3, dev->dev_addr)) {
+	    ether_addr_equal(hdr->addr1, dev->dev_addr) &&
+	    ether_addr_equal(hdr->addr3, dev->dev_addr)) {
 		/* ToDS frame with own addr BSSID and DA */
 	} else if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
 		   IEEE80211_FCTL_FROMDS &&
-		   !compare_ether_addr(hdr->addr1, dev->dev_addr)) {
+		   ether_addr_equal(hdr->addr1, dev->dev_addr)) {
 		/* FromDS frame with own addr as DA */
 	} else
 		return 0;
@@ -523,8 +523,8 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 
 	if (ieee->iw_mode == IW_MODE_MASTER && !wds &&
 	    (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
-	    IEEE80211_FCTL_FROMDS && ieee->stadev
-	    && !compare_ether_addr(hdr->addr2, ieee->assoc_ap_addr)) {
+	    IEEE80211_FCTL_FROMDS && ieee->stadev &&
+	    ether_addr_equal(hdr->addr2, ieee->assoc_ap_addr)) {
 		/* Frame from BSSID of the AP for which we are a client */
 		skb->dev = dev = ieee->stadev;
 		stats = hostap_get_stats(dev);
@@ -1468,7 +1468,7 @@ static inline int is_same_network(struct libipw_network *src,
 	 * as one network */
 	return ((src->ssid_len == dst->ssid_len) &&
 		(src->channel == dst->channel) &&
-		!compare_ether_addr(src->bssid, dst->bssid) &&
+		ether_addr_equal(src->bssid, dst->bssid) &&
 		!memcmp(src->ssid, dst->ssid, src->ssid_len));
 }
 
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index b25c01b..87e5398 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -453,10 +453,10 @@ il3945_is_network_packet(struct il_priv *il, struct ieee80211_hdr *header)
 	switch (il->iw_mode) {
 	case NL80211_IFTYPE_ADHOC:	/* Header: Dest. | Source    | BSSID */
 		/* packets to our IBSS update information */
-		return !compare_ether_addr(header->addr3, il->bssid);
+		return ether_addr_equal(header->addr3, il->bssid);
 	case NL80211_IFTYPE_STATION:	/* Header: Dest. | AP{BSSID} | Source */
 		/* packets to our IBSS update information */
-		return !compare_ether_addr(header->addr2, il->bssid);
+		return ether_addr_equal(header->addr2, il->bssid);
 	default:
 		return 1;
 	}
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index f2baf94..509301a 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -2565,7 +2565,7 @@ il4965_find_station(struct il_priv *il, const u8 *addr)
 	spin_lock_irqsave(&il->sta_lock, flags);
 	for (i = start; i < il->hw_params.max_stations; i++)
 		if (il->stations[i].used &&
-		    (!compare_ether_addr(il->stations[i].sta.sta.addr, addr))) {
+		    ether_addr_equal(il->stations[i].sta.sta.addr, addr)) {
 			ret = i;
 			goto out;
 		}
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index eaf24945..cbf2dc1 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -1896,8 +1896,8 @@ il_prep_station(struct il_priv *il, const u8 *addr, bool is_ap,
 		sta_id = il->hw_params.bcast_id;
 	else
 		for (i = IL_STA_ID; i < il->hw_params.max_stations; i++) {
-			if (!compare_ether_addr
-			    (il->stations[i].sta.sta.addr, addr)) {
+			if (ether_addr_equal(il->stations[i].sta.sta.addr,
+					     addr)) {
 				sta_id = i;
 				break;
 			}
@@ -1926,7 +1926,7 @@ il_prep_station(struct il_priv *il, const u8 *addr, bool is_ap,
 
 	if ((il->stations[sta_id].used & IL_STA_DRIVER_ACTIVE) &&
 	    (il->stations[sta_id].used & IL_STA_UCODE_ACTIVE) &&
-	    !compare_ether_addr(il->stations[sta_id].sta.sta.addr, addr)) {
+	    ether_addr_equal(il->stations[sta_id].sta.sta.addr, addr)) {
 		D_ASSOC("STA %d (%pM) already added, not adding again.\n",
 			sta_id, addr);
 		return sta_id;
@@ -3744,10 +3744,10 @@ il_full_rxon_required(struct il_priv *il)
 
 	/* These items are only settable from the full RXON command */
 	CHK(!il_is_associated(il));
-	CHK(compare_ether_addr(staging->bssid_addr, active->bssid_addr));
-	CHK(compare_ether_addr(staging->node_addr, active->node_addr));
-	CHK(compare_ether_addr
-	    (staging->wlap_bssid_addr, active->wlap_bssid_addr));
+	CHK(!ether_addr_equal(staging->bssid_addr, active->bssid_addr));
+	CHK(!ether_addr_equal(staging->node_addr, active->node_addr));
+	CHK(!ether_addr_equal(staging->wlap_bssid_addr,
+			      active->wlap_bssid_addr));
 	CHK_NEQ(staging->dev_type, active->dev_type);
 	CHK_NEQ(staging->channel, active->channel);
 	CHK_NEQ(staging->air_propagation, active->air_propagation);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
index 0c252c5..779f819 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
@@ -779,8 +779,8 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 	*/
 	if (unlikely(ieee80211_is_beacon(fc) && priv->passive_no_rx)) {
 		for_each_context(priv, ctx) {
-			if (compare_ether_addr(hdr->addr3,
-					       ctx->active.bssid_addr))
+			if (!ether_addr_equal(hdr->addr3,
+					      ctx->active.bssid_addr))
 				continue;
 			iwlagn_lift_passive_no_rx(priv);
 		}
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index 0f7c444..74fbee6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -881,10 +881,10 @@ int iwl_full_rxon_required(struct iwl_priv *priv,
 
 	/* These items are only settable from the full RXON command */
 	CHK(!iwl_is_associated_ctx(ctx));
-	CHK(compare_ether_addr(staging->bssid_addr, active->bssid_addr));
-	CHK(compare_ether_addr(staging->node_addr, active->node_addr));
-	CHK(compare_ether_addr(staging->wlap_bssid_addr,
-				active->wlap_bssid_addr));
+	CHK(!ether_addr_equal(staging->bssid_addr, active->bssid_addr));
+	CHK(!ether_addr_equal(staging->node_addr, active->node_addr));
+	CHK(!ether_addr_equal(staging->wlap_bssid_addr,
+			      active->wlap_bssid_addr));
 	CHK_NEQ(staging->dev_type, active->dev_type);
 	CHK_NEQ(staging->channel, active->channel);
 	CHK_NEQ(staging->air_propagation, active->air_propagation);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
index 67e6f1d..b31584e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
@@ -322,8 +322,8 @@ u8 iwl_prep_station(struct iwl_priv *priv, struct iwl_rxon_context *ctx,
 		sta_id = ctx->bcast_sta_id;
 	else
 		for (i = IWL_STA_ID; i < IWLAGN_STATION_COUNT; i++) {
-			if (!compare_ether_addr(priv->stations[i].sta.sta.addr,
-						addr)) {
+			if (ether_addr_equal(priv->stations[i].sta.sta.addr,
+					     addr)) {
 				sta_id = i;
 				break;
 			}
@@ -353,7 +353,7 @@ u8 iwl_prep_station(struct iwl_priv *priv, struct iwl_rxon_context *ctx,
 
 	if ((priv->stations[sta_id].used & IWL_STA_DRIVER_ACTIVE) &&
 	    (priv->stations[sta_id].used & IWL_STA_UCODE_ACTIVE) &&
-	    !compare_ether_addr(priv->stations[sta_id].sta.sta.addr, addr)) {
+	    ether_addr_equal(priv->stations[sta_id].sta.sta.addr, addr)) {
 		IWL_DEBUG_ASSOC(priv, "STA %d (%pM) already added, not "
 				"adding again.\n", sta_id, addr);
 		return sta_id;
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index e30cc32..cf7bdc6 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1235,7 +1235,7 @@ mwl8k_capture_bssid(struct mwl8k_priv *priv, struct ieee80211_hdr *wh)
 {
 	return priv->capture_beacon &&
 		ieee80211_is_beacon(wh->frame_control) &&
-		!compare_ether_addr(wh->addr3, priv->capture_bssid);
+		ether_addr_equal(wh->addr3, priv->capture_bssid);
 }
 
 static inline void mwl8k_save_beacon(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 7c8f118..82a1cac 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -308,7 +308,7 @@ static void p54_pspoll_workaround(struct p54_common *priv, struct sk_buff *skb)
 		return;
 
 	/* only consider beacons from the associated BSSID */
-	if (compare_ether_addr(hdr->addr3, priv->bssid))
+	if (!ether_addr_equal(hdr->addr3, priv->bssid))
 		return;
 
 	tim = p54_find_ie(skb, WLAN_EID_TIM);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d66e298..dcf0e7e 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1801,8 +1801,8 @@ static struct ndis_80211_pmkid *remove_pmkid(struct usbnet *usbdev,
 		count = max_pmkids;
 
 	for (i = 0; i < count; i++)
-		if (!compare_ether_addr(pmkids->bssid_info[i].bssid,
-							pmksa->bssid))
+		if (ether_addr_equal(pmkids->bssid_info[i].bssid,
+				     pmksa->bssid))
 			break;
 
 	/* pmkid not found */
@@ -1843,8 +1843,8 @@ static struct ndis_80211_pmkid *update_pmkid(struct usbnet *usbdev,
 
 	/* update with new pmkid */
 	for (i = 0; i < count; i++) {
-		if (compare_ether_addr(pmkids->bssid_info[i].bssid,
-							pmksa->bssid))
+		if (!ether_addr_equal(pmkids->bssid_info[i].bssid,
+				      pmksa->bssid))
 			continue;
 
 		memcpy(pmkids->bssid_info[i].pmkid, pmksa->pmkid,
@@ -2139,7 +2139,7 @@ resize_buf:
 	while (check_bssid_list_item(bssid, bssid_len, buf, len)) {
 		if (rndis_bss_info_update(usbdev, bssid) && match_bssid &&
 		    matched) {
-			if (compare_ether_addr(bssid->mac, match_bssid))
+			if (!ether_addr_equal(bssid->mac, match_bssid))
 				*matched = true;
 		}
 
@@ -2531,7 +2531,7 @@ static int rndis_get_station(struct wiphy *wiphy, struct net_device *dev,
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
 
-	if (compare_ether_addr(priv->bssid, mac))
+	if (!ether_addr_equal(priv->bssid, mac))
 		return -ENOENT;
 
 	rndis_fill_station_info(usbdev, sinfo);
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index e54488d..f4c852c 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1460,7 +1460,7 @@ void rtl_recognize_peer(struct ieee80211_hw *hw, u8 *data, unsigned int len)
 		return;
 
 	/* and only beacons from the associated BSSID, please */
-	if (compare_ether_addr(hdr->addr3, rtlpriv->mac80211.bssid))
+	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
 		return;
 
 	if (rtl_find_221_ie(hw, data, len))
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 5b9c3b5..5ae2664 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -480,7 +480,7 @@ void rtl_swlps_beacon(struct ieee80211_hw *hw, void *data, unsigned int len)
 		return;
 
 	/* and only beacons from the associated BSSID, please */
-	if (compare_ether_addr(hdr->addr3, rtlpriv->mac80211.bssid))
+	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
 		return;
 
 	rtlpriv->psc.last_beacon = jiffies;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 37b1363..3af874e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -508,14 +508,14 @@ static void _rtl92ce_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 
 	packet_matchbssid =
 	    ((IEEE80211_FTYPE_CTL != type) &&
-	     (!compare_ether_addr(mac->bssid,
-				  (c_fc & IEEE80211_FCTL_TODS) ?
-				  hdr->addr1 : (c_fc & IEEE80211_FCTL_FROMDS) ?
-				  hdr->addr2 : hdr->addr3)) &&
+	     ether_addr_equal(mac->bssid,
+			      (c_fc & IEEE80211_FCTL_TODS) ? hdr->addr1 :
+			      (c_fc & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
+			      hdr->addr3) &&
 	     (!pstats->hwerror) && (!pstats->crc) && (!pstats->icv));
 
 	packet_toself = packet_matchbssid &&
-	    (!compare_ether_addr(praddr, rtlefuse->dev_addr));
+	     ether_addr_equal(praddr, rtlefuse->dev_addr);
 
 	if (ieee80211_is_beacon(fc))
 		packet_beacon = true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 025bdc2..7e91c76 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -1099,14 +1099,14 @@ void rtl92c_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	praddr = hdr->addr1;
 	packet_matchbssid =
 	    ((IEEE80211_FTYPE_CTL != type) &&
-	     (!compare_ether_addr(mac->bssid,
-			  (cpu_fc & IEEE80211_FCTL_TODS) ?
-			  hdr->addr1 : (cpu_fc & IEEE80211_FCTL_FROMDS) ?
-			  hdr->addr2 : hdr->addr3)) &&
+	     ether_addr_equal(mac->bssid,
+			      (cpu_fc & IEEE80211_FCTL_TODS) ? hdr->addr1 :
+			      (cpu_fc & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
+			      hdr->addr3) &&
 	     (!pstats->hwerror) && (!pstats->crc) && (!pstats->icv));
 
 	packet_toself = packet_matchbssid &&
-	    (!compare_ether_addr(praddr, rtlefuse->dev_addr));
+	    ether_addr_equal(praddr, rtlefuse->dev_addr);
 	if (ieee80211_is_beacon(fc))
 		packet_beacon = true;
 	_rtl92c_query_rxphystatus(hw, pstats, pdesc, p_drvinfo,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index a7f6126..1666ef7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -466,12 +466,13 @@ static void _rtl92de_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	type = WLAN_FC_GET_TYPE(fc);
 	praddr = hdr->addr1;
 	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
-	     (!compare_ether_addr(mac->bssid, (cfc & IEEE80211_FCTL_TODS) ?
-		  hdr->addr1 : (cfc & IEEE80211_FCTL_FROMDS) ?
-		  hdr->addr2 : hdr->addr3)) && (!pstats->hwerror) &&
-		  (!pstats->crc) && (!pstats->icv));
+	     ether_addr_equal(mac->bssid,
+			      (cfc & IEEE80211_FCTL_TODS) ? hdr->addr1 :
+			      (cfc & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
+			      hdr->addr3) &&
+	     (!pstats->hwerror) && (!pstats->crc) && (!pstats->icv));
 	packet_toself = packet_matchbssid &&
-			(!compare_ether_addr(praddr, rtlefuse->dev_addr));
+			ether_addr_equal(praddr, rtlefuse->dev_addr);
 	if (ieee80211_is_beacon(fc))
 		packet_beacon = true;
 	_rtl92de_query_rxphystatus(hw, pstats, pdesc, p_drvinfo,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 2fd3d13..812b585 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -492,13 +492,14 @@ static void _rtl92se_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	praddr = hdr->addr1;
 
 	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
-	     (!compare_ether_addr(mac->bssid, (cfc & IEEE80211_FCTL_TODS) ?
-			hdr->addr1 : (cfc & IEEE80211_FCTL_FROMDS) ?
-			hdr->addr2 : hdr->addr3)) && (!pstats->hwerror) &&
-			(!pstats->crc) && (!pstats->icv));
+	     ether_addr_equal(mac->bssid,
+			      (cfc & IEEE80211_FCTL_TODS) ? hdr->addr1 :
+			      (cfc & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
+			      hdr->addr3) &&
+	     (!pstats->hwerror) && (!pstats->crc) && (!pstats->icv));
 
 	packet_toself = packet_matchbssid &&
-	    (!compare_ether_addr(praddr, rtlefuse->dev_addr));
+	    ether_addr_equal(praddr, rtlefuse->dev_addr);
 
 	if (ieee80211_is_beacon(fc))
 		packet_beacon = true;
-- 
1.7.8.111.gad25c.dirty
