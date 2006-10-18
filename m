From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 9/18] d80211: rate_control: do not use atomic allocations when not necessary
Date: Wed, 18 Oct 2006 17:49:32 +0200 (CEST)
Message-ID: <20061018154932.CFF0447F84@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:15010 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161204AbWJRPtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:07 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow GFP_KERNEL to be used for allocations of sta entries triggered from
the user space.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    2 +-
 net/d80211/ieee80211_rate.h  |    7 ++++---
 net/d80211/ieee80211_sta.c   |    4 ++--
 net/d80211/rc80211_simple.c  |    4 ++--
 net/d80211/sta_info.c        |    8 +++-----
 net/d80211/sta_info.h        |    2 +-
 6 files changed, 13 insertions(+), 14 deletions(-)

034b87e99c85b243b94c6955bbdce94825dd6b1f
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index ff6718b..cded685 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -277,7 +277,7 @@ static int ieee80211_ioctl_add_sta(struc
 	sta = sta_info_get(local, param->sta_addr);
 
 	if (!sta) {
-		sta = sta_info_add(local, dev, param->sta_addr);
+		sta = sta_info_add(local, dev, param->sta_addr, GFP_KERNEL);
 		if (!sta)
 			return -ENOMEM;
         }
diff --git a/net/d80211/ieee80211_rate.h b/net/d80211/ieee80211_rate.h
index 60e4879..04c7465 100644
--- a/net/d80211/ieee80211_rate.h
+++ b/net/d80211/ieee80211_rate.h
@@ -52,7 +52,7 @@ struct rate_control_ops {
 
 	void *(*alloc)(struct ieee80211_local *local);
 	void (*free)(void *priv);
-	void *(*alloc_sta)(void *priv);
+	void *(*alloc_sta)(void *priv, gfp_t gfp);
 	void (*free_sta)(void *priv, void *priv_sta);
 
 	int (*add_attrs)(void *priv, struct kobject *kobj);
@@ -112,9 +112,10 @@ static inline void rate_control_clear(st
 	ref->ops->clear(ref->priv);
 }
 
-static inline void *rate_control_alloc_sta(struct rate_control_ref *ref)
+static inline void *rate_control_alloc_sta(struct rate_control_ref *ref,
+					   gfp_t gfp)
 {
-	return ref->ops->alloc_sta(ref->priv);
+	return ref->ops->alloc_sta(ref->priv, gfp);
 }
 
 static inline void rate_control_free_sta(struct rate_control_ref *ref,
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index ed6747a..480e9c9 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1158,7 +1158,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 	/* Add STA entry for the AP */
 	sta = sta_info_get(local, ifsta->bssid);
 	if (!sta) {
-		sta = sta_info_add(local, dev, ifsta->bssid);
+		sta = sta_info_add(local, dev, ifsta->bssid, GFP_ATOMIC);
 		if (!sta) {
 			printk(KERN_DEBUG "%s: failed to add STA entry for the"
 			       " AP\n", dev->name);
@@ -2832,7 +2832,7 @@ struct sta_info * ieee80211_ibss_add_sta
 	printk(KERN_DEBUG "%s: Adding new IBSS station " MAC_FMT " (dev=%s)\n",
 	       dev->name, MAC_ARG(addr), sta_dev->name);
 
-	sta = sta_info_add(local, dev, addr);
+	sta = sta_info_add(local, dev, addr, GFP_ATOMIC);
 	if (!sta)
 		return NULL;
 
diff --git a/net/d80211/rc80211_simple.c b/net/d80211/rc80211_simple.c
index 055a167..3634d00 100644
--- a/net/d80211/rc80211_simple.c
+++ b/net/d80211/rc80211_simple.c
@@ -305,11 +305,11 @@ static void rate_control_simple_clear(vo
 }
 
 
-static void * rate_control_simple_alloc_sta(void *priv)
+static void * rate_control_simple_alloc_sta(void *priv, gfp_t gfp)
 {
 	struct sta_rate_control *rctrl;
 
-	rctrl = kzalloc(sizeof(*rctrl), GFP_ATOMIC);
+	rctrl = kzalloc(sizeof(*rctrl), gfp);
 
 	return rctrl;
 }
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index a177d2f..c18365b 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -130,16 +130,14 @@ void sta_info_release(struct kobject *ko
 
 
 struct sta_info * sta_info_add(struct ieee80211_local *local,
-			       struct net_device *dev, u8 *addr)
+			       struct net_device *dev, u8 *addr, gfp_t gfp)
 {
 	struct sta_info *sta;
 
-	sta = kmalloc(sizeof(*sta), GFP_ATOMIC);
+	sta = kzalloc(sizeof(*sta), gfp);
 	if (!sta)
 		return NULL;
 
-	memset(sta, 0, sizeof(*sta));
-
 	if (kobject_set_name(&sta->kobj, MAC_FMT, MAC_ARG(addr))) {
 		kfree(sta);
 		return NULL;
@@ -148,7 +146,7 @@ struct sta_info * sta_info_add(struct ie
 	kobject_init(&sta->kobj);
 
 	sta->rate_ctrl = rate_control_get(local->rate_ctrl);
-	sta->rate_ctrl_priv = rate_control_alloc_sta(sta->rate_ctrl);
+	sta->rate_ctrl_priv = rate_control_alloc_sta(sta->rate_ctrl, gfp);
 	if (!sta->rate_ctrl_priv) {
 		rate_control_put(sta->rate_ctrl);
 		kobject_put(&sta->kobj);
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 9bd7e0d..ed1a104 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -133,7 +133,7 @@ struct sta_info * sta_info_get(struct ie
 int sta_info_min_txrate_get(struct ieee80211_local *local);
 void sta_info_put(struct sta_info *sta);
 struct sta_info * sta_info_add(struct ieee80211_local *local,
-			       struct net_device *dev, u8 *addr);
+			       struct net_device *dev, u8 *addr, gfp_t gfp);
 void sta_info_free(struct sta_info *sta, int locked);
 void sta_info_release(struct kobject *kobj);
 void sta_info_init(struct ieee80211_local *local);
-- 
1.3.0

