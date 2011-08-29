From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/24] mac80211: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:31 -0700
Message-ID: <af1425e68de37e461a310327f3bd2ad165d560be.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/mac80211/agg-rx.c    |   19 ++-----------------
 net/mac80211/agg-tx.c    |   35 ++++++++---------------------------
 net/mac80211/debugfs.c   |    3 +++
 net/mac80211/ht.c        |    6 +-----
 net/mac80211/mesh.c      |    5 ++---
 net/mac80211/mlme.c      |   17 +++++------------
 net/mac80211/spectmgmt.c |    6 +-----
 net/mac80211/tx.c        |   17 +++++------------
 net/mac80211/util.c      |   11 +++--------
 net/mac80211/work.c      |    6 ++----
 10 files changed, 32 insertions(+), 93 deletions(-)

diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 9b5bd8c..7c366df 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -167,12 +167,8 @@ static void ieee80211_send_addba_resp(struct ieee80211_sub_if_data *sdata, u8 *d
 	u16 capab;
 
 	skb = dev_alloc_skb(sizeof(*mgmt) + local->hw.extra_tx_headroom);
-
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer "
-		       "for addba resp frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
@@ -279,14 +275,8 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 
 	/* prepare A-MPDU MLME for Rx aggregation */
 	tid_agg_rx = kmalloc(sizeof(struct tid_ampdu_rx), GFP_KERNEL);
-	if (!tid_agg_rx) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		if (net_ratelimit())
-			printk(KERN_ERR "allocate rx mlme to tid %d failed\n",
-					tid);
-#endif
+	if (!tid_agg_rx)
 		goto end;
-	}
 
 	spin_lock_init(&tid_agg_rx->reorder_lock);
 
@@ -306,11 +296,6 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 	tid_agg_rx->reorder_time =
 		kcalloc(buf_size, sizeof(unsigned long), GFP_KERNEL);
 	if (!tid_agg_rx->reorder_buf || !tid_agg_rx->reorder_time) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		if (net_ratelimit())
-			printk(KERN_ERR "can not allocate reordering buffer "
-			       "to tid %d\n", tid);
-#endif
 		kfree(tid_agg_rx->reorder_buf);
 		kfree(tid_agg_rx->reorder_time);
 		kfree(tid_agg_rx);
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index b7075f3..7f568d6 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -68,11 +68,9 @@ static void ieee80211_send_addba_request(struct ieee80211_sub_if_data *sdata,
 
 	skb = dev_alloc_skb(sizeof(*mgmt) + local->hw.extra_tx_headroom);
 
-	if (!skb) {
-		printk(KERN_ERR "%s: failed to allocate buffer "
-				"for addba request frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
@@ -114,11 +112,9 @@ void ieee80211_send_bar(struct ieee80211_sub_if_data *sdata, u8 *ra, u16 tid, u1
 	u16 bar_control = 0;
 
 	skb = dev_alloc_skb(sizeof(*bar) + local->hw.extra_tx_headroom);
-	if (!skb) {
-		printk(KERN_ERR "%s: failed to allocate buffer for "
-			"bar frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 	bar = (struct ieee80211_bar *)skb_put(skb, sizeof(*bar));
 	memset(bar, 0, sizeof(*bar));
@@ -413,11 +409,6 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	/* prepare A-MPDU MLME for Tx aggregation */
 	tid_tx = kzalloc(sizeof(struct tid_ampdu_tx), GFP_ATOMIC);
 	if (!tid_tx) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		if (net_ratelimit())
-			printk(KERN_ERR "allocate tx mlme to tid %d failed\n",
-					tid);
-#endif
 		ret = -ENOMEM;
 		goto err_unlock_sta;
 	}
@@ -574,14 +565,9 @@ void ieee80211_start_tx_ba_cb_irqsafe(struct ieee80211_vif *vif,
 	struct ieee80211_ra_tid *ra_tid;
 	struct sk_buff *skb = dev_alloc_skb(0);
 
-	if (unlikely(!skb)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		if (net_ratelimit())
-			printk(KERN_WARNING "%s: Not enough memory, "
-			       "dropping start BA session", sdata->name);
-#endif
+	if (unlikely(!skb))
 		return;
-	}
+
 	ra_tid = (struct ieee80211_ra_tid *) &skb->cb;
 	memcpy(&ra_tid->ra, ra, ETH_ALEN);
 	ra_tid->tid = tid;
@@ -727,14 +713,9 @@ void ieee80211_stop_tx_ba_cb_irqsafe(struct ieee80211_vif *vif,
 	struct ieee80211_ra_tid *ra_tid;
 	struct sk_buff *skb = dev_alloc_skb(0);
 
-	if (unlikely(!skb)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		if (net_ratelimit())
-			printk(KERN_WARNING "%s: Not enough memory, "
-			       "dropping stop BA session", sdata->name);
-#endif
+	if (unlikely(!skb))
 		return;
-	}
+
 	ra_tid = (struct ieee80211_ra_tid *) &skb->cb;
 	memcpy(&ra_tid->ra, ra, ETH_ALEN);
 	ra_tid->tid = tid;
diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index 186e02f..583c9ed 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -305,6 +305,9 @@ static ssize_t hwflags_read(struct file *file, char __user *user_buf,
 	char *buf = kzalloc(mxln, GFP_KERNEL);
 	int sf = 0; /* how many written so far */
 
+	if (!buf)
+		return 0;
+
 	sf += snprintf(buf, mxln - sf, "0x%x\n", local->hw.flags);
 	if (local->hw.flags & IEEE80211_HW_HAS_RATE_CONTROL)
 		sf += snprintf(buf + sf, mxln - sf, "HAS_RATE_CONTROL\n");
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 7cfc286..2b9b52c 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -186,12 +186,8 @@ void ieee80211_send_delba(struct ieee80211_sub_if_data *sdata,
 	u16 params;
 
 	skb = dev_alloc_skb(sizeof(*mgmt) + local->hw.extra_tx_headroom);
-
-	if (!skb) {
-		printk(KERN_ERR "%s: failed to allocate buffer "
-					"for delba frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 29e9980..d262f38 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -193,10 +193,9 @@ int mesh_rmc_check(u8 *sa, struct ieee80211s_hdr *mesh_hdr,
 	}
 
 	p = kmem_cache_alloc(rm_cache, GFP_ATOMIC);
-	if (!p) {
-		printk(KERN_DEBUG "o11s: could not allocate RMC entry\n");
+	if (!p)
 		return 0;
-	}
+
 	p->seqnum = seqnum;
 	p->exp_time = jiffies + RMC_TIMEOUT;
 	memcpy(p->sa, sa, ETH_ALEN);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index d6470c7..f193a91 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -271,11 +271,9 @@ static void ieee80211_send_deauth_disassoc(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_mgmt *mgmt;
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*mgmt));
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer for "
-		       "deauth/disassoc frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
@@ -354,11 +352,9 @@ static void ieee80211_send_4addr_nullfunc(struct ieee80211_local *local,
 		return;
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom + 30);
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer for 4addr "
-		       "nullfunc frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	nullfunc = (struct ieee80211_hdr *) skb_put(skb, 30);
@@ -1483,11 +1479,8 @@ static bool ieee80211_assoc_success(struct ieee80211_work *wk,
 	ifmgd->aid = aid;
 
 	sta = sta_info_alloc(sdata, cbss->bssid, GFP_KERNEL);
-	if (!sta) {
-		printk(KERN_DEBUG "%s: failed to alloc STA entry for"
-		       " the AP\n", sdata->name);
+	if (!sta)
 		return false;
-	}
 
 	set_sta_flags(sta, WLAN_STA_AUTH | WLAN_STA_ASSOC |
 			   WLAN_STA_ASSOC_AP);
diff --git a/net/mac80211/spectmgmt.c b/net/mac80211/spectmgmt.c
index 7733f66..578eea3 100644
--- a/net/mac80211/spectmgmt.c
+++ b/net/mac80211/spectmgmt.c
@@ -32,12 +32,8 @@ static void ieee80211_send_refuse_measurement_request(struct ieee80211_sub_if_da
 
 	skb = dev_alloc_skb(sizeof(*msr_report) + local->hw.extra_tx_headroom +
 				sizeof(struct ieee80211_msrment_ie));
-
-	if (!skb) {
-		printk(KERN_ERR "%s: failed to allocate buffer for "
-				"measurement report frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 	msr_report = (struct ieee80211_mgmt *)skb_put(skb, 24);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 69fd494..55bc1f6 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2355,11 +2355,9 @@ struct sk_buff *ieee80211_pspoll_get(struct ieee80211_hw *hw,
 	local = sdata->local;
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*pspoll));
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer for "
-		       "pspoll template\n", sdata->name);
+	if (!skb)
 		return NULL;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	pspoll = (struct ieee80211_pspoll *) skb_put(skb, sizeof(*pspoll));
@@ -2395,11 +2393,9 @@ struct sk_buff *ieee80211_nullfunc_get(struct ieee80211_hw *hw,
 	local = sdata->local;
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*nullfunc));
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer for nullfunc "
-		       "template\n", sdata->name);
+	if (!skb)
 		return NULL;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	nullfunc = (struct ieee80211_hdr_3addr *) skb_put(skb,
@@ -2434,11 +2430,8 @@ struct sk_buff *ieee80211_probereq_get(struct ieee80211_hw *hw,
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*hdr) +
 			    ie_ssid_len + ie_len);
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer for probe "
-		       "request template\n", sdata->name);
+	if (!skb)
 		return NULL;
-	}
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index ce916ff..1c10802 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -707,11 +707,9 @@ void ieee80211_send_auth(struct ieee80211_sub_if_data *sdata,
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
 			    sizeof(*mgmt) + 6 + extra_len);
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer for auth "
-		       "frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24 + 6);
@@ -864,11 +862,8 @@ struct sk_buff *ieee80211_build_probe_req(struct ieee80211_sub_if_data *sdata,
 
 	/* FIXME: come up with a proper value */
 	buf = kmalloc(200 + ie_len, GFP_KERNEL);
-	if (!buf) {
-		printk(KERN_DEBUG "%s: failed to allocate temporary IE "
-		       "buffer\n", sdata->name);
+	if (!buf)
 		return NULL;
-	}
 
 	/*
 	 * Do not send DS Channel parameter for directed probe requests
diff --git a/net/mac80211/work.c b/net/mac80211/work.c
index 380b9a7..bac3439 100644
--- a/net/mac80211/work.c
+++ b/net/mac80211/work.c
@@ -229,11 +229,9 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata,
 			wk->ie_len + /* extra IEs */
 			9, /* WMM */
 			GFP_KERNEL);
-	if (!skb) {
-		printk(KERN_DEBUG "%s: failed to allocate buffer for assoc "
-		       "frame\n", sdata->name);
+	if (!skb)
 		return;
-	}
+
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	capab = WLAN_CAPABILITY_ESS;
-- 
1.7.6.405.gc1be0
