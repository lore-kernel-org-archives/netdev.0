From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 2/2] mac80211: Use rhltable instead of rhashtable
Date: Mon, 19 Sep 2016 19:00:10 +0800
Message-ID: <E1blwJ0-0003NG-MH@gondolin.me.apana.org.au>
References: <20160919105854.GA12892@gondor.apana.org.au>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com, Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56882 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753857AbcISLAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 07:00:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mac80211 currently uses rhashtable with insecure_elasticity set
to true.  The latter is because of duplicate objects.  What's
more, mac80211 walks the rhashtable chains by hand which is broken
as rhashtable may contain multiple tables due to resizing or
rehashing.

This patch fixes it by converting it to the newly added rhltable
interface which is designed for use with duplicate objects.

With rhltable a lookup returns a list of objects instead of a
single one.  This is then fed into the existing for_each_sta_info
macro.

This patch also deletes the sta_addr_hash function since rhashtable
defaults to jhash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/mac80211/ieee80211_i.h |    2 -
 net/mac80211/rx.c          |    7 +-----
 net/mac80211/sta_info.c    |   52 ++++++++++++++++++---------------------------
 net/mac80211/sta_info.h    |   19 ++++++----------
 net/mac80211/status.c      |    7 +-----
 5 files changed, 33 insertions(+), 54 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index f56d342..1a52cd4 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1208,7 +1208,7 @@ struct ieee80211_local {
 	spinlock_t tim_lock;
 	unsigned long num_sta;
 	struct list_head sta_list;
-	struct rhashtable sta_hash;
+	struct rhltable sta_hash;
 	struct timer_list sta_cleanup;
 	int sta_generation;
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 9dce3b1..5e26dc6 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -3940,7 +3940,7 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 	__le16 fc;
 	struct ieee80211_rx_data rx;
 	struct ieee80211_sub_if_data *prev;
-	struct rhash_head *tmp;
+	struct rhlist_head *tmp;
 	int err = 0;
 
 	fc = ((struct ieee80211_hdr *)skb->data)->frame_control;
@@ -3983,13 +3983,10 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 		goto out;
 	} else if (ieee80211_is_data(fc)) {
 		struct sta_info *sta, *prev_sta;
-		const struct bucket_table *tbl;
 
 		prev_sta = NULL;
 
-		tbl = rht_dereference_rcu(local->sta_hash.tbl, &local->sta_hash);
-
-		for_each_sta_info(local, tbl, hdr->addr2, sta, tmp) {
+		for_each_sta_info(local, hdr->addr2, sta, tmp) {
 			if (!prev_sta) {
 				prev_sta = sta;
 				continue;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 19f14c9..198d0bd 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -67,12 +67,10 @@
 
 static const struct rhashtable_params sta_rht_params = {
 	.nelem_hint = 3, /* start small */
-	.insecure_elasticity = true, /* Disable chain-length checks. */
 	.automatic_shrinking = true,
 	.head_offset = offsetof(struct sta_info, hash_node),
 	.key_offset = offsetof(struct sta_info, addr),
 	.key_len = ETH_ALEN,
-	.hashfn = sta_addr_hash,
 	.max_size = CONFIG_MAC80211_STA_HASH_MAX_SIZE,
 };
 
@@ -80,8 +78,8 @@ static const struct rhashtable_params sta_rht_params = {
 static int sta_info_hash_del(struct ieee80211_local *local,
 			     struct sta_info *sta)
 {
-	return rhashtable_remove_fast(&local->sta_hash, &sta->hash_node,
-				      sta_rht_params);
+	return rhltable_remove(&local->sta_hash, &sta->hash_node,
+			       sta_rht_params);
 }
 
 static void __cleanup_single_sta(struct sta_info *sta)
@@ -157,19 +155,22 @@ static void cleanup_single_sta(struct sta_info *sta)
 	sta_info_free(local, sta);
 }
 
+struct rhlist_head *sta_info_hash_lookup(struct ieee80211_local *local,
+					 const u8 *addr)
+{
+	return rhltable_lookup(&local->sta_hash, addr, sta_rht_params);
+}
+
 /* protected by RCU */
 struct sta_info *sta_info_get(struct ieee80211_sub_if_data *sdata,
 			      const u8 *addr)
 {
 	struct ieee80211_local *local = sdata->local;
+	struct rhlist_head *tmp;
 	struct sta_info *sta;
-	struct rhash_head *tmp;
-	const struct bucket_table *tbl;
 
 	rcu_read_lock();
-	tbl = rht_dereference_rcu(local->sta_hash.tbl, &local->sta_hash);
-
-	for_each_sta_info(local, tbl, addr, sta, tmp) {
+	for_each_sta_info(local, addr, sta, tmp) {
 		if (sta->sdata == sdata) {
 			rcu_read_unlock();
 			/* this is safe as the caller must already hold
@@ -190,14 +191,11 @@ struct sta_info *sta_info_get_bss(struct ieee80211_sub_if_data *sdata,
 				  const u8 *addr)
 {
 	struct ieee80211_local *local = sdata->local;
+	struct rhlist_head *tmp;
 	struct sta_info *sta;
-	struct rhash_head *tmp;
-	const struct bucket_table *tbl;
 
 	rcu_read_lock();
-	tbl = rht_dereference_rcu(local->sta_hash.tbl, &local->sta_hash);
-
-	for_each_sta_info(local, tbl, addr, sta, tmp) {
+	for_each_sta_info(local, addr, sta, tmp) {
 		if (sta->sdata == sdata ||
 		    (sta->sdata->bss && sta->sdata->bss == sdata->bss)) {
 			rcu_read_unlock();
@@ -263,8 +261,8 @@ void sta_info_free(struct ieee80211_local *local, struct sta_info *sta)
 static int sta_info_hash_add(struct ieee80211_local *local,
 			     struct sta_info *sta)
 {
-	return rhashtable_insert_fast(&local->sta_hash, &sta->hash_node,
-				      sta_rht_params);
+	return rhltable_insert(&local->sta_hash, &sta->hash_node,
+			       sta_rht_params);
 }
 
 static void sta_deliver_ps_frames(struct work_struct *wk)
@@ -450,9 +448,9 @@ static int sta_info_insert_check(struct sta_info *sta)
 		    is_multicast_ether_addr(sta->sta.addr)))
 		return -EINVAL;
 
-	/* Strictly speaking this isn't necessary as we hold the mutex, but
-	 * the rhashtable code can't really deal with that distinction. We
-	 * do require the mutex for correctness though.
+	/* The RCU read lock is required by rhashtable due to
+	 * asynchronous resize/rehash.  We also require the mutex
+	 * for correctness.
 	 */
 	rcu_read_lock();
 	lockdep_assert_held(&sdata->local->sta_mtx);
@@ -1040,16 +1038,11 @@ static void sta_info_cleanup(unsigned long data)
 		  round_jiffies(jiffies + STA_INFO_CLEANUP_INTERVAL));
 }
 
-u32 sta_addr_hash(const void *key, u32 length, u32 seed)
-{
-	return jhash(key, ETH_ALEN, seed);
-}
-
 int sta_info_init(struct ieee80211_local *local)
 {
 	int err;
 
-	err = rhashtable_init(&local->sta_hash, &sta_rht_params);
+	err = rhltable_init(&local->sta_hash, &sta_rht_params);
 	if (err)
 		return err;
 
@@ -1065,7 +1058,7 @@ int sta_info_init(struct ieee80211_local *local)
 void sta_info_stop(struct ieee80211_local *local)
 {
 	del_timer_sync(&local->sta_cleanup);
-	rhashtable_destroy(&local->sta_hash);
+	rhltable_destroy(&local->sta_hash);
 }
 
 
@@ -1135,17 +1128,14 @@ struct ieee80211_sta *ieee80211_find_sta_by_ifaddr(struct ieee80211_hw *hw,
 						   const u8 *localaddr)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	struct rhlist_head *tmp;
 	struct sta_info *sta;
-	struct rhash_head *tmp;
-	const struct bucket_table *tbl;
-
-	tbl = rht_dereference_rcu(local->sta_hash.tbl, &local->sta_hash);
 
 	/*
 	 * Just return a random station if localaddr is NULL
 	 * ... first in list.
 	 */
-	for_each_sta_info(local, tbl, addr, sta, tmp) {
+	for_each_sta_info(local, addr, sta, tmp) {
 		if (localaddr &&
 		    !ether_addr_equal(sta->sdata->vif.addr, localaddr))
 			continue;
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 0556be3..d347ab5 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -452,7 +452,7 @@ struct sta_info {
 	/* General information, mostly static */
 	struct list_head list, free_list;
 	struct rcu_head rcu_head;
-	struct rhash_head hash_node;
+	struct rhlist_head hash_node;
 	u8 addr[ETH_ALEN];
 	struct ieee80211_local *local;
 	struct ieee80211_sub_if_data *sdata;
@@ -635,6 +635,9 @@ rcu_dereference_protected_tid_tx(struct sta_info *sta, int tid)
  */
 #define STA_INFO_CLEANUP_INTERVAL (10 * HZ)
 
+struct rhlist_head *sta_info_hash_lookup(struct ieee80211_local *local,
+					 const u8 *addr);
+
 /*
  * Get a STA info, must be under RCU read lock.
  */
@@ -644,17 +647,9 @@ struct sta_info *sta_info_get(struct ieee80211_sub_if_data *sdata,
 struct sta_info *sta_info_get_bss(struct ieee80211_sub_if_data *sdata,
 				  const u8 *addr);
 
-u32 sta_addr_hash(const void *key, u32 length, u32 seed);
-
-#define _sta_bucket_idx(_tbl, _a)					\
-	rht_bucket_index(_tbl, sta_addr_hash(_a, ETH_ALEN, (_tbl)->hash_rnd))
-
-#define for_each_sta_info(local, tbl, _addr, _sta, _tmp)		\
-	rht_for_each_entry_rcu(_sta, _tmp, tbl, 			\
-			       _sta_bucket_idx(tbl, _addr),		\
-			       hash_node)				\
-	/* compare address and run code only if it matches */		\
-	if (ether_addr_equal(_sta->addr, (_addr)))
+#define for_each_sta_info(local, _addr, _sta, _tmp)			\
+	rhl_for_each_entry_rcu(_sta, _tmp,				\
+			       sta_info_hash_lookup(local, _addr), hash_node)
 
 /*
  * Get STA info by index, BROKEN!
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index a2a6826..6361709 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -740,8 +740,8 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	__le16 fc;
 	struct ieee80211_supported_band *sband;
+	struct rhlist_head *tmp;
 	struct sta_info *sta;
-	struct rhash_head *tmp;
 	int retry_count;
 	int rates_idx;
 	bool send_to_cooked;
@@ -749,7 +749,6 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 	struct ieee80211_bar *bar;
 	int shift = 0;
 	int tid = IEEE80211_NUM_TIDS;
-	const struct bucket_table *tbl;
 
 	rates_idx = ieee80211_tx_get_rates(hw, info, &retry_count);
 
@@ -758,9 +757,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 	sband = local->hw.wiphy->bands[info->band];
 	fc = hdr->frame_control;
 
-	tbl = rht_dereference_rcu(local->sta_hash.tbl, &local->sta_hash);
-
-	for_each_sta_info(local, tbl, hdr->addr1, sta, tmp) {
+	for_each_sta_info(local, hdr->addr1, sta, tmp) {
 		/* skip wrong virtual interface */
 		if (!ether_addr_equal(hdr->addr2, sta->sdata->vif.addr))
 			continue;
