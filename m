From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/13] mac80211: Convert compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:52 -0700
Message-ID: <18cea8c5f35423fd8c730d571570f67fa3d7e94a.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 net/mac80211/cfg.c          |    2 +-
 net/mac80211/ibss.c         |   12 ++++++------
 net/mac80211/ieee80211_i.h  |    2 +-
 net/mac80211/iface.c        |    2 +-
 net/mac80211/mesh.c         |    4 ++--
 net/mac80211/mesh_hwmp.c    |   14 +++++++-------
 net/mac80211/mesh_pathtbl.c |   12 ++++++------
 net/mac80211/mlme.c         |   29 +++++++++++++----------------
 net/mac80211/rx.c           |   35 ++++++++++++++++-------------------
 net/mac80211/scan.c         |    2 +-
 net/mac80211/sta_info.c     |    8 ++++----
 net/mac80211/status.c       |    2 +-
 net/mac80211/tx.c           |   11 +++++------
 13 files changed, 64 insertions(+), 71 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 70b2af2..7e6781f 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -919,7 +919,7 @@ static int ieee80211_add_station(struct wiphy *wiphy, struct net_device *dev,
 	} else
 		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	if (compare_ether_addr(mac, sdata->vif.addr) == 0)
+	if (ether_addr_equal(mac, sdata->vif.addr))
 		return -EINVAL;
 
 	if (is_multicast_ether_addr(mac))
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 61cd391..d307d3b 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -66,7 +66,7 @@ static void __ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 	skb_reset_tail_pointer(skb);
 	skb_reserve(skb, sdata->local->hw.extra_tx_headroom);
 
-	if (compare_ether_addr(ifibss->bssid, bssid))
+	if (!ether_addr_equal(ifibss->bssid, bssid))
 		sta_info_flush(sdata->local, sdata);
 
 	/* if merging, indicate to driver that we leave the old IBSS */
@@ -315,7 +315,7 @@ ieee80211_ibss_add_sta(struct ieee80211_sub_if_data *sdata,
 		return NULL;
 	}
 
-	if (compare_ether_addr(bssid, sdata->u.ibss.bssid)) {
+	if (!ether_addr_equal(bssid, sdata->u.ibss.bssid)) {
 		rcu_read_lock();
 		return NULL;
 	}
@@ -401,7 +401,7 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	if (sdata->vif.type == NL80211_IFTYPE_ADHOC &&
-	    compare_ether_addr(mgmt->bssid, sdata->u.ibss.bssid) == 0) {
+	    ether_addr_equal(mgmt->bssid, sdata->u.ibss.bssid)) {
 
 		rcu_read_lock();
 		sta = sta_info_get(sdata, mgmt->sa);
@@ -506,7 +506,7 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 		goto put_bss;
 
 	/* same BSSID */
-	if (compare_ether_addr(cbss->bssid, sdata->u.ibss.bssid) == 0)
+	if (ether_addr_equal(cbss->bssid, sdata->u.ibss.bssid))
 		goto put_bss;
 
 	if (rx_status->flag & RX_FLAG_MACTIME_MPDU) {
@@ -591,7 +591,7 @@ void ieee80211_ibss_rx_no_sta(struct ieee80211_sub_if_data *sdata,
 	if (ifibss->state == IEEE80211_IBSS_MLME_SEARCH)
 		return;
 
-	if (compare_ether_addr(bssid, sdata->u.ibss.bssid))
+	if (!ether_addr_equal(bssid, sdata->u.ibss.bssid))
 		return;
 
 	sta = sta_info_alloc(sdata, addr, GFP_ATOMIC);
@@ -829,7 +829,7 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 	if (!tx_last_beacon && is_multicast_ether_addr(mgmt->da))
 		return;
 
-	if (compare_ether_addr(mgmt->bssid, ifibss->bssid) != 0 &&
+	if (!ether_addr_equal(mgmt->bssid, ifibss->bssid) &&
 	    !is_broadcast_ether_addr(mgmt->bssid))
 		return;
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 6cd89d4..fabee97 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1195,7 +1195,7 @@ static inline struct ieee80211_local *hw_to_local(
 
 static inline int ieee80211_bssid_match(const u8 *raddr, const u8 *addr)
 {
-	return compare_ether_addr(raddr, addr) == 0 ||
+	return ether_addr_equal(raddr, addr) ||
 	       is_broadcast_ether_addr(raddr);
 }
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 3e05a8b..856237c 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -127,7 +127,7 @@ static int ieee80211_check_concurrent_iface(struct ieee80211_sub_if_data *sdata,
 			 * The remaining checks are only performed for interfaces
 			 * with the same MAC address.
 			 */
-			if (compare_ether_addr(dev->dev_addr, ndev->dev_addr))
+			if (!ether_addr_equal(dev->dev_addr, ndev->dev_addr))
 				continue;
 
 			/*
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 598a96a..7756271 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -209,7 +209,7 @@ int mesh_rmc_check(u8 *sa, struct ieee80211s_hdr *mesh_hdr,
 			kmem_cache_free(rm_cache, p);
 			--entries;
 		} else if ((seqnum == p->seqnum) &&
-			   (compare_ether_addr(sa, p->sa) == 0))
+			   (ether_addr_equal(sa, p->sa)))
 			return -1;
 	}
 
@@ -639,7 +639,7 @@ static void ieee80211_mesh_rx_bcn_presp(struct ieee80211_sub_if_data *sdata,
 
 	/* ignore ProbeResp to foreign address */
 	if (stype == IEEE80211_STYPE_PROBE_RESP &&
-	    compare_ether_addr(mgmt->da, sdata->vif.addr))
+	    !ether_addr_equal(mgmt->da, sdata->vif.addr))
 		return;
 
 	baselen = (u8 *) mgmt->u.probe_resp.variable - (u8 *) mgmt;
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 503016f..27e0c2f 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -422,7 +422,7 @@ static u32 hwmp_route_info_get(struct ieee80211_sub_if_data *sdata,
 		new_metric = MAX_METRIC;
 	exp_time = TU_TO_EXP_TIME(orig_lifetime);
 
-	if (compare_ether_addr(orig_addr, sdata->vif.addr) == 0) {
+	if (ether_addr_equal(orig_addr, sdata->vif.addr)) {
 		/* This MP is the originator, we are not interested in this
 		 * frame, except for updating transmitter's path info.
 		 */
@@ -472,7 +472,7 @@ static u32 hwmp_route_info_get(struct ieee80211_sub_if_data *sdata,
 
 	/* Update and check transmitter routing info */
 	ta = mgmt->sa;
-	if (compare_ether_addr(orig_addr, ta) == 0)
+	if (ether_addr_equal(orig_addr, ta))
 		fresh_info = false;
 	else {
 		fresh_info = true;
@@ -533,7 +533,7 @@ static void hwmp_preq_frame_process(struct ieee80211_sub_if_data *sdata,
 
 	mhwmp_dbg("received PREQ from %pM", orig_addr);
 
-	if (compare_ether_addr(target_addr, sdata->vif.addr) == 0) {
+	if (ether_addr_equal(target_addr, sdata->vif.addr)) {
 		mhwmp_dbg("PREQ is for us");
 		forward = false;
 		reply = true;
@@ -631,7 +631,7 @@ static void hwmp_prep_frame_process(struct ieee80211_sub_if_data *sdata,
 	mhwmp_dbg("received PREP from %pM", PREP_IE_ORIG_ADDR(prep_elem));
 
 	orig_addr = PREP_IE_ORIG_ADDR(prep_elem);
-	if (compare_ether_addr(orig_addr, sdata->vif.addr) == 0)
+	if (ether_addr_equal(orig_addr, sdata->vif.addr))
 		/* destination, no forwarding required */
 		return;
 
@@ -709,7 +709,7 @@ static void hwmp_perr_frame_process(struct ieee80211_sub_if_data *sdata,
 		spin_lock_bh(&mpath->state_lock);
 		sta = next_hop_deref_protected(mpath);
 		if (mpath->flags & MESH_PATH_ACTIVE &&
-		    compare_ether_addr(ta, sta->sta.addr) == 0 &&
+		    ether_addr_equal(ta, sta->sta.addr) &&
 		    (!(mpath->flags & MESH_PATH_SN_VALID) ||
 		    SN_GT(target_sn, mpath->sn))) {
 			mpath->flags &= ~MESH_PATH_ACTIVE;
@@ -756,7 +756,7 @@ static void hwmp_rann_frame_process(struct ieee80211_sub_if_data *sdata,
 	metric = le32_to_cpu(rann->rann_metric);
 
 	/*  Ignore our own RANNs */
-	if (compare_ether_addr(orig_addr, sdata->vif.addr) == 0)
+	if (ether_addr_equal(orig_addr, sdata->vif.addr))
 		return;
 
 	mhwmp_dbg("received RANN from %pM via neighbour %pM (is_gate=%d)",
@@ -1099,7 +1099,7 @@ int mesh_nexthop_lookup(struct sk_buff *skb,
 	if (time_after(jiffies,
 		       mpath->exp_time -
 		       msecs_to_jiffies(sdata->u.mesh.mshcfg.path_refresh_time)) &&
-	    !compare_ether_addr(sdata->vif.addr, hdr->addr4) &&
+	    ether_addr_equal(sdata->vif.addr, hdr->addr4) &&
 	    !(mpath->flags & MESH_PATH_RESOLVING) &&
 	    !(mpath->flags & MESH_PATH_FIXED))
 		mesh_queue_preq(mpath, PREQ_Q_F_START | PREQ_Q_F_REFRESH);
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index baa6096..b39224d 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -348,7 +348,7 @@ static struct mesh_path *mpath_lookup(struct mesh_table *tbl, u8 *dst,
 	hlist_for_each_entry_rcu(node, n, bucket, list) {
 		mpath = node->mpath;
 		if (mpath->sdata == sdata &&
-				compare_ether_addr(dst, mpath->dst) == 0) {
+		    ether_addr_equal(dst, mpath->dst)) {
 			if (MPATH_EXPIRED(mpath)) {
 				spin_lock_bh(&mpath->state_lock);
 				mpath->flags &= ~MESH_PATH_ACTIVE;
@@ -517,7 +517,7 @@ int mesh_path_add(u8 *dst, struct ieee80211_sub_if_data *sdata)
 	int err = 0;
 	u32 hash_idx;
 
-	if (compare_ether_addr(dst, sdata->vif.addr) == 0)
+	if (ether_addr_equal(dst, sdata->vif.addr))
 		/* never add ourselves as neighbours */
 		return -ENOTSUPP;
 
@@ -561,7 +561,7 @@ int mesh_path_add(u8 *dst, struct ieee80211_sub_if_data *sdata)
 	hlist_for_each_entry(node, n, bucket, list) {
 		mpath = node->mpath;
 		if (mpath->sdata == sdata &&
-		    compare_ether_addr(dst, mpath->dst) == 0)
+		    ether_addr_equal(dst, mpath->dst))
 			goto err_exists;
 	}
 
@@ -652,7 +652,7 @@ int mpp_path_add(u8 *dst, u8 *mpp, struct ieee80211_sub_if_data *sdata)
 	int err = 0;
 	u32 hash_idx;
 
-	if (compare_ether_addr(dst, sdata->vif.addr) == 0)
+	if (ether_addr_equal(dst, sdata->vif.addr))
 		/* never add ourselves as neighbours */
 		return -ENOTSUPP;
 
@@ -690,7 +690,7 @@ int mpp_path_add(u8 *dst, u8 *mpp, struct ieee80211_sub_if_data *sdata)
 	hlist_for_each_entry(node, n, bucket, list) {
 		mpath = node->mpath;
 		if (mpath->sdata == sdata &&
-		    compare_ether_addr(dst, mpath->dst) == 0)
+		    ether_addr_equal(dst, mpath->dst))
 			goto err_exists;
 	}
 
@@ -884,7 +884,7 @@ int mesh_path_del(u8 *addr, struct ieee80211_sub_if_data *sdata)
 	hlist_for_each_entry(node, n, bucket, list) {
 		mpath = node->mpath;
 		if (mpath->sdata == sdata &&
-		    compare_ether_addr(addr, mpath->dst) == 0) {
+		    ether_addr_equal(addr, mpath->dst)) {
 			__mesh_path_del(tbl, node);
 			goto enddel;
 		}
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 03f93f9..b1c617f 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1776,7 +1776,7 @@ ieee80211_rx_mgmt_auth(struct ieee80211_sub_if_data *sdata,
 
 	memcpy(bssid, ifmgd->auth_data->bss->bssid, ETH_ALEN);
 
-	if (compare_ether_addr(bssid, mgmt->bssid))
+	if (!ether_addr_equal(bssid, mgmt->bssid))
 		return RX_MGMT_NONE;
 
 	auth_alg = le16_to_cpu(mgmt->u.auth.auth_alg);
@@ -1853,7 +1853,7 @@ ieee80211_rx_mgmt_deauth(struct ieee80211_sub_if_data *sdata,
 		return RX_MGMT_NONE;
 
 	if (!ifmgd->associated ||
-	    compare_ether_addr(mgmt->bssid, ifmgd->associated->bssid))
+	    !ether_addr_equal(mgmt->bssid, ifmgd->associated->bssid))
 		return RX_MGMT_NONE;
 
 	bssid = ifmgd->associated->bssid;
@@ -1886,7 +1886,7 @@ ieee80211_rx_mgmt_disassoc(struct ieee80211_sub_if_data *sdata,
 		return RX_MGMT_NONE;
 
 	if (!ifmgd->associated ||
-	    compare_ether_addr(mgmt->bssid, ifmgd->associated->bssid))
+	    !ether_addr_equal(mgmt->bssid, ifmgd->associated->bssid))
 		return RX_MGMT_NONE;
 
 	reason_code = le16_to_cpu(mgmt->u.disassoc.reason_code);
@@ -2113,7 +2113,7 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_if_data *sdata,
 
 	if (!assoc_data)
 		return RX_MGMT_NONE;
-	if (compare_ether_addr(assoc_data->bss->bssid, mgmt->bssid))
+	if (!ether_addr_equal(assoc_data->bss->bssid, mgmt->bssid))
 		return RX_MGMT_NONE;
 
 	/*
@@ -2193,8 +2193,7 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 	bool need_ps = false;
 
 	if (sdata->u.mgd.associated &&
-	    compare_ether_addr(mgmt->bssid, sdata->u.mgd.associated->bssid)
-	    == 0) {
+	    ether_addr_equal(mgmt->bssid, sdata->u.mgd.associated->bssid)) {
 		bss = (void *)sdata->u.mgd.associated->priv;
 		/* not previously set so we may need to recalc */
 		need_ps = !bss->dtim_period;
@@ -2249,7 +2248,7 @@ static void ieee80211_rx_mgmt_probe_resp(struct ieee80211_sub_if_data *sdata,
 
 	ASSERT_MGD_MTX(ifmgd);
 
-	if (compare_ether_addr(mgmt->da, sdata->vif.addr))
+	if (!ether_addr_equal(mgmt->da, sdata->vif.addr))
 		return; /* ignore ProbeResp to foreign address */
 
 	baselen = (u8 *) mgmt->u.probe_resp.variable - (u8 *) mgmt;
@@ -2262,12 +2261,11 @@ static void ieee80211_rx_mgmt_probe_resp(struct ieee80211_sub_if_data *sdata,
 	ieee80211_rx_bss_info(sdata, mgmt, len, rx_status, &elems, false);
 
 	if (ifmgd->associated &&
-	    compare_ether_addr(mgmt->bssid, ifmgd->associated->bssid) == 0)
+	    ether_addr_equal(mgmt->bssid, ifmgd->associated->bssid))
 		ieee80211_reset_ap_probe(sdata);
 
 	if (ifmgd->auth_data && !ifmgd->auth_data->bss->proberesp_ies &&
-	    compare_ether_addr(mgmt->bssid, ifmgd->auth_data->bss->bssid)
-	    == 0) {
+	    ether_addr_equal(mgmt->bssid, ifmgd->auth_data->bss->bssid)) {
 		/* got probe response, continue with auth */
 		printk(KERN_DEBUG "%s: direct probe responded\n", sdata->name);
 		ifmgd->auth_data->tries = 0;
@@ -2324,8 +2322,7 @@ static void ieee80211_rx_mgmt_beacon(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	if (ifmgd->assoc_data && !ifmgd->assoc_data->have_beacon &&
-	    compare_ether_addr(mgmt->bssid, ifmgd->assoc_data->bss->bssid)
-	    == 0) {
+	    ether_addr_equal(mgmt->bssid, ifmgd->assoc_data->bss->bssid)) {
 		ieee802_11_parse_elems(mgmt->u.beacon.variable,
 				       len - baselen, &elems);
 
@@ -2340,7 +2337,7 @@ static void ieee80211_rx_mgmt_beacon(struct ieee80211_sub_if_data *sdata,
 	}
 
 	if (!ifmgd->associated ||
-	    compare_ether_addr(mgmt->bssid, ifmgd->associated->bssid))
+	    !ether_addr_equal(mgmt->bssid, ifmgd->associated->bssid))
 		return;
 	bssid = ifmgd->associated->bssid;
 
@@ -3166,7 +3163,7 @@ static int ieee80211_prep_connection(struct ieee80211_sub_if_data *sdata,
 			return err;
 		}
 	} else
-		WARN_ON_ONCE(compare_ether_addr(ifmgd->bssid, cbss->bssid));
+		WARN_ON_ONCE(!ether_addr_equal(ifmgd->bssid, cbss->bssid));
 
 	return 0;
 }
@@ -3306,7 +3303,7 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 		bool match;
 
 		/* keep sta info, bssid if matching */
-		match = compare_ether_addr(ifmgd->bssid, req->bss->bssid) == 0;
+		match = ether_addr_equal(ifmgd->bssid, req->bss->bssid);
 		ieee80211_destroy_auth_data(sdata, match);
 	}
 
@@ -3466,7 +3463,7 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data *sdata,
 	       sdata->name, req->bssid, req->reason_code);
 
 	if (ifmgd->associated &&
-	    compare_ether_addr(ifmgd->associated->bssid, req->bssid) == 0)
+	    ether_addr_equal(ifmgd->associated->bssid, req->bssid))
 		ieee80211_set_disassoc(sdata, IEEE80211_STYPE_DEAUTH,
 				       req->reason_code, true, frame_buf);
 	else
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index d5ac02f..26bfd6f 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -492,12 +492,12 @@ ieee80211_rx_mesh_check(struct ieee80211_rx_data *rx)
 			if (ieee80211_has_tods(hdr->frame_control) ||
 				!ieee80211_has_fromds(hdr->frame_control))
 				return RX_DROP_MONITOR;
-			if (compare_ether_addr(hdr->addr3, dev_addr) == 0)
+			if (ether_addr_equal(hdr->addr3, dev_addr))
 				return RX_DROP_MONITOR;
 		} else {
 			if (!ieee80211_has_a4(hdr->frame_control))
 				return RX_DROP_MONITOR;
-			if (compare_ether_addr(hdr->addr4, dev_addr) == 0)
+			if (ether_addr_equal(hdr->addr4, dev_addr))
 				return RX_DROP_MONITOR;
 		}
 	}
@@ -1275,7 +1275,7 @@ ieee80211_rx_h_sta_process(struct ieee80211_rx_data *rx)
 	if (rx->sdata->vif.type == NL80211_IFTYPE_ADHOC) {
 		u8 *bssid = ieee80211_get_bssid(hdr, rx->skb->len,
 						NL80211_IFTYPE_ADHOC);
-		if (compare_ether_addr(bssid, rx->sdata->u.ibss.bssid) == 0) {
+		if (ether_addr_equal(bssid, rx->sdata->u.ibss.bssid)) {
 			sta->last_rx = jiffies;
 			if (ieee80211_is_data(hdr->frame_control)) {
 				sta->last_rx_rate_idx = status->rate_idx;
@@ -1438,8 +1438,8 @@ ieee80211_reassemble_find(struct ieee80211_sub_if_data *sdata,
 		 */
 		if (((hdr->frame_control ^ f_hdr->frame_control) &
 		     cpu_to_le16(IEEE80211_FCTL_FTYPE)) ||
-		    compare_ether_addr(hdr->addr1, f_hdr->addr1) != 0 ||
-		    compare_ether_addr(hdr->addr2, f_hdr->addr2) != 0)
+		    !ether_addr_equal(hdr->addr1, f_hdr->addr1) ||
+		    !ether_addr_equal(hdr->addr2, f_hdr->addr2))
 			continue;
 
 		if (time_after(jiffies, entry->first_frag_time + 2 * HZ)) {
@@ -1925,7 +1925,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 			mpp_path_add(proxied_addr, mpp_addr, sdata);
 		} else {
 			spin_lock_bh(&mppath->state_lock);
-			if (compare_ether_addr(mppath->mpp, mpp_addr) != 0)
+			if (!ether_addr_equal(mppath->mpp, mpp_addr))
 				memcpy(mppath->mpp, mpp_addr, ETH_ALEN);
 			spin_unlock_bh(&mppath->state_lock);
 		}
@@ -1934,7 +1934,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 
 	/* Frame has reached destination.  Don't forward */
 	if (!is_multicast_ether_addr(hdr->addr1) &&
-	    compare_ether_addr(sdata->vif.addr, hdr->addr3) == 0)
+	    ether_addr_equal(sdata->vif.addr, hdr->addr3))
 		return RX_CONTINUE;
 
 	q = ieee80211_select_queue_80211(local, skb, hdr);
@@ -2122,13 +2122,13 @@ static void ieee80211_process_sa_query_req(struct ieee80211_sub_if_data *sdata,
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *resp;
 
-	if (compare_ether_addr(mgmt->da, sdata->vif.addr) != 0) {
+	if (!ether_addr_equal(mgmt->da, sdata->vif.addr)) {
 		/* Not to own unicast address */
 		return;
 	}
 
-	if (compare_ether_addr(mgmt->sa, sdata->u.mgd.bssid) != 0 ||
-	    compare_ether_addr(mgmt->bssid, sdata->u.mgd.bssid) != 0) {
+	if (!ether_addr_equal(mgmt->sa, sdata->u.mgd.bssid) ||
+	    !ether_addr_equal(mgmt->bssid, sdata->u.mgd.bssid)) {
 		/* Not from the current AP or not associated yet. */
 		return;
 	}
@@ -2338,7 +2338,7 @@ ieee80211_rx_h_action(struct ieee80211_rx_data *rx)
 			if (sdata->vif.type != NL80211_IFTYPE_STATION)
 				break;
 
-			if (compare_ether_addr(mgmt->bssid, sdata->u.mgd.bssid))
+			if (!ether_addr_equal(mgmt->bssid, sdata->u.mgd.bssid))
 				break;
 
 			goto queue;
@@ -2772,7 +2772,7 @@ static int prepare_for_handlers(struct ieee80211_rx_data *rx,
 		if (!bssid && !sdata->u.mgd.use_4addr)
 			return 0;
 		if (!multicast &&
-		    compare_ether_addr(sdata->vif.addr, hdr->addr1) != 0) {
+		    !ether_addr_equal(sdata->vif.addr, hdr->addr1)) {
 			if (!(sdata->dev->flags & IFF_PROMISC) ||
 			    sdata->u.mgd.use_4addr)
 				return 0;
@@ -2790,8 +2790,7 @@ static int prepare_for_handlers(struct ieee80211_rx_data *rx,
 				return 0;
 			status->rx_flags &= ~IEEE80211_RX_RA_MATCH;
 		} else if (!multicast &&
-			   compare_ether_addr(sdata->vif.addr,
-					      hdr->addr1) != 0) {
+			   !ether_addr_equal(sdata->vif.addr, hdr->addr1)) {
 			if (!(sdata->dev->flags & IFF_PROMISC))
 				return 0;
 			status->rx_flags &= ~IEEE80211_RX_RA_MATCH;
@@ -2807,8 +2806,7 @@ static int prepare_for_handlers(struct ieee80211_rx_data *rx,
 		break;
 	case NL80211_IFTYPE_MESH_POINT:
 		if (!multicast &&
-		    compare_ether_addr(sdata->vif.addr,
-				       hdr->addr1) != 0) {
+		    !ether_addr_equal(sdata->vif.addr, hdr->addr1)) {
 			if (!(sdata->dev->flags & IFF_PROMISC))
 				return 0;
 
@@ -2818,8 +2816,7 @@ static int prepare_for_handlers(struct ieee80211_rx_data *rx,
 	case NL80211_IFTYPE_AP_VLAN:
 	case NL80211_IFTYPE_AP:
 		if (!bssid) {
-			if (compare_ether_addr(sdata->vif.addr,
-					       hdr->addr1))
+			if (!ether_addr_equal(sdata->vif.addr, hdr->addr1))
 				return 0;
 		} else if (!ieee80211_bssid_match(bssid,
 					sdata->vif.addr)) {
@@ -2841,7 +2838,7 @@ static int prepare_for_handlers(struct ieee80211_rx_data *rx,
 	case NL80211_IFTYPE_WDS:
 		if (bssid || !ieee80211_is_data(hdr->frame_control))
 			return 0;
-		if (compare_ether_addr(sdata->u.wds.remote_addr, hdr->addr2))
+		if (!ether_addr_equal(sdata->u.wds.remote_addr, hdr->addr2))
 			return 0;
 		break;
 	default:
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 8282284..169da07 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -194,7 +194,7 @@ ieee80211_scan_rx(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb)
 	presp = ieee80211_is_probe_resp(fc);
 	if (presp) {
 		/* ignore ProbeResp to foreign address */
-		if (compare_ether_addr(mgmt->da, sdata->vif.addr))
+		if (!ether_addr_equal(mgmt->da, sdata->vif.addr))
 			return RX_DROP_MONITOR;
 
 		presp = true;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 97a9d66..f5b1638 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -102,7 +102,7 @@ struct sta_info *sta_info_get(struct ieee80211_sub_if_data *sdata,
 				    lockdep_is_held(&local->sta_mtx));
 	while (sta) {
 		if (sta->sdata == sdata &&
-		    compare_ether_addr(sta->sta.addr, addr) == 0)
+		    ether_addr_equal(sta->sta.addr, addr))
 			break;
 		sta = rcu_dereference_check(sta->hnext,
 					    lockdep_is_held(&local->sta_mtx));
@@ -125,7 +125,7 @@ struct sta_info *sta_info_get_bss(struct ieee80211_sub_if_data *sdata,
 	while (sta) {
 		if ((sta->sdata == sdata ||
 		     (sta->sdata->bss && sta->sdata->bss == sdata->bss)) &&
-		    compare_ether_addr(sta->sta.addr, addr) == 0)
+		    ether_addr_equal(sta->sta.addr, addr))
 			break;
 		sta = rcu_dereference_check(sta->hnext,
 					    lockdep_is_held(&local->sta_mtx));
@@ -302,7 +302,7 @@ static int sta_info_insert_check(struct sta_info *sta)
 	if (unlikely(!ieee80211_sdata_running(sdata)))
 		return -ENETDOWN;
 
-	if (WARN_ON(compare_ether_addr(sta->sta.addr, sdata->vif.addr) == 0 ||
+	if (WARN_ON(ether_addr_equal(sta->sta.addr, sdata->vif.addr) ||
 		    is_multicast_ether_addr(sta->sta.addr)))
 		return -EINVAL;
 
@@ -912,7 +912,7 @@ struct ieee80211_sta *ieee80211_find_sta_by_ifaddr(struct ieee80211_hw *hw,
 	 */
 	for_each_sta_info(hw_to_local(hw), addr, sta, nxt) {
 		if (localaddr &&
-		    compare_ether_addr(sta->sdata->vif.addr, localaddr) != 0)
+		    !ether_addr_equal(sta->sdata->vif.addr, localaddr))
 			continue;
 		if (!sta->uploaded)
 			return NULL;
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 05f257a..28cfa98 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -384,7 +384,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 
 	for_each_sta_info(local, hdr->addr1, sta, tmp) {
 		/* skip wrong virtual interface */
-		if (compare_ether_addr(hdr->addr2, sta->sdata->vif.addr))
+		if (!ether_addr_equal(hdr->addr2, sta->sdata->vif.addr))
 			continue;
 
 		if (info->flags & IEEE80211_TX_STATUS_EOSP)
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index d67d36f..e03abc7 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1665,7 +1665,7 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct sk_buff *skb,
 	    skb->len >= len_rthdr + hdrlen + sizeof(rfc1042_header) + 2) {
 		u8 *payload = (u8 *)hdr + hdrlen;
 
-		if (compare_ether_addr(payload, rfc1042_header) == 0)
+		if (ether_addr_equal(payload, rfc1042_header))
 			skb->protocol = cpu_to_be16((payload[6] << 8) |
 						    payload[7]);
 	}
@@ -1698,7 +1698,7 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct sk_buff *skb,
 		    tmp_sdata->vif.type == NL80211_IFTYPE_AP_VLAN ||
 		    tmp_sdata->vif.type == NL80211_IFTYPE_WDS)
 			continue;
-		if (compare_ether_addr(tmp_sdata->vif.addr, hdr->addr2) == 0) {
+		if (ether_addr_equal(tmp_sdata->vif.addr, hdr->addr2)) {
 			sdata = tmp_sdata;
 			break;
 		}
@@ -1815,9 +1815,8 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		 * is being proxied by a portal (i.e. portal address
 		 * differs from proxied address)
 		 */
-		if (compare_ether_addr(sdata->vif.addr,
-				       skb->data + ETH_ALEN) == 0 &&
-		    !(mppath && compare_ether_addr(mppath->mpp, skb->data))) {
+		if (ether_addr_equal(sdata->vif.addr, skb->data + ETH_ALEN) &&
+		    !(mppath && !ether_addr_equal(mppath->mpp, skb->data))) {
 			hdrlen = ieee80211_fill_mesh_addresses(&hdr, &fc,
 					skb->data, skb->data + ETH_ALEN);
 			rcu_read_unlock();
@@ -1964,7 +1963,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	if (unlikely(!ieee80211_vif_is_mesh(&sdata->vif) &&
 		     !is_multicast_ether_addr(hdr.addr1) && !authorized &&
 		     (cpu_to_be16(ethertype) != sdata->control_port_protocol ||
-		      compare_ether_addr(sdata->vif.addr, skb->data + ETH_ALEN)))) {
+		      !ether_addr_equal(sdata->vif.addr, skb->data + ETH_ALEN)))) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: dropped frame to %pM"
-- 
1.7.8.111.gad25c.dirty
