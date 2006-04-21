From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/17] d80211: ask driver for allowed iface combinations
Date: Fri, 21 Apr 2006 22:11:39 +0200 (CEST)
Message-ID: <20060421201139.73DE1482C8@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12935 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932414AbWDUULL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:11 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all combinations of interfaces (in fact, very few combination of
interfaces) are possible to be UP together. When an interface is going UP,
let's ask the driver if this is possible.

Please note that ieee80211_if_init_conf structure is not complete yet - new
fields will need to be added to allow drivers to decide.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h     |   52 ++++++++++++++++++++++++++++++++++++++++++++++
 net/d80211/ieee80211.c   |   30 ++++++++++++++++++++++-----
 net/d80211/ieee80211_i.h |    8 -------
 3 files changed, 77 insertions(+), 13 deletions(-)

77fe239e18433d16747c0851a5ecba6abe76820b
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 75e8e24..44417fc 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -305,6 +305,42 @@ struct ieee80211_conf {
 	u8 pulse_inband_threshold;
 };
 
+/**
+ * enum ieee80211_if_types - types of 802.11 network interface
+ * @IEEE80211_IF_TYPE_AP: interface in AP mode.
+ * @IEEE80211_IF_TYPE_MGMT: special interface for communication with hostap
+ *	daemon. Drivers should never see this type.
+ * @IEEE80211_IF_TYPE_STA: interface in STA (client) mode.
+ * @IEEE80211_IF_TYPE_IBSS: interface in IBSS (ad-hoc) mode.
+ * @IEEE80211_IF_TYPE_MNTR: interface in monitor (rfmon) mode.
+ * @IEEE80211_IF_TYPE_WDS: interface in WDS mode.
+ * @IEEE80211_IF_TYPE_VLAN: not used.
+ */
+enum ieee80211_if_types {
+	IEEE80211_IF_TYPE_AP = 0x00000000,
+	IEEE80211_IF_TYPE_MGMT = 0x00000001,
+	IEEE80211_IF_TYPE_STA = 0x00000002,
+	IEEE80211_IF_TYPE_IBSS = 0x00000003,
+	IEEE80211_IF_TYPE_MNTR = 0x00000004,
+	IEEE80211_IF_TYPE_WDS = 0x5A580211,
+	IEEE80211_IF_TYPE_VLAN = 0x00080211,
+};
+
+/**
+ * struct ieee80211_if_init_conf - initial configuration of an interface
+ * @type: one of &enum ieee80211_if_types constants. Determines the type of
+ *	added/removed interface.
+ * @mac_addr: pointer to MAC address of the interface. This pointer is valid
+ *	until the interface is removed (i.e. it cannot be used after
+ *	remove_interface() callback was called for this interface).
+ *
+ * This structure is used in add_interface() and remove_interface()
+ * callbacks of &struct ieee80211_hw.
+ */
+struct ieee80211_if_init_conf {
+	int type;
+	void *mac_addr;
+};
 
 typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
 ieee80211_key_alg;
@@ -452,6 +488,22 @@ struct ieee80211_hw {
 	 * interrupts and beacon sending. */
 	int (*stop)(struct net_device *dev);
 
+	/* Handler for asking a driver if a new interface can be added (or,
+	 * more exactly, set UP). If the handler returns zero, the interface
+	 * is added. Driver should perform any initialization it needs prior
+	 * to returning zero. By returning non-zero, adding of the interface
+	 * is not permitted. The open() handler is called after
+	 * add_interface() if this is the first device added. At least one
+	 * of open() and add_interface() handler has to be non-NULL. If
+	 * add_interface() is NULL, one STA interface is permitted only. */
+	int (*add_interface)(struct net_device *dev,
+			     struct ieee80211_if_init_conf *conf);
+
+	/* Notify a driver that interface is going down. The stop() handler
+	 * is called prior to this if this is a last interface. */
+	void (*remove_interface)(struct net_device *dev,
+				 struct ieee80211_if_init_conf *conf);
+
 	/* Handler for configuration requests. IEEE 802.11 code calls this
 	 * function to change hardware configuration, e.g., channel. */
 	int (*config)(struct net_device *dev, struct ieee80211_conf *conf);
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index fae9d64..271c4d9 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1828,11 +1828,22 @@ static int ieee80211_open(struct net_dev
 	int res;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (local->hw->add_interface) {
+		struct ieee80211_if_init_conf conf;
 
-        if (local->open_count == 0) {
-		res = local->hw->open(sdata->master);
+		conf.type = sdata->type;
+		conf.mac_addr = dev->dev_addr;
+		res = local->hw->add_interface(sdata->master, &conf);
 		if (res)
 			return res;
+	}
+
+        if (local->open_count == 0) {
+		if (local->hw->open) {
+			res = local->hw->open(sdata->master);
+			if (res)
+				return res;
+		}
 		ieee80211_init_scan(sdata->master);
 	}
         local->open_count++;
@@ -1855,10 +1866,19 @@ static int ieee80211_stop(struct net_dev
 	local->open_count--;
         if (local->open_count == 0) {
 		ieee80211_stop_scan(sdata->master);
-		res = local->hw->stop(sdata->master);
-		if (res)
-			return res;
+		if (local->hw->stop) {
+			res = local->hw->stop(sdata->master);
+			if (res)
+				return res;
+		}
         }
+	if (local->hw->remove_interface) {
+		struct ieee80211_if_init_conf conf;
+
+		conf.type = sdata->type;
+		conf.mac_addr = dev->dev_addr;
+		local->hw->remove_interface(sdata->master, &conf);
+	}
 
 	return 0;
 }
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 9d18c71..d42b6fe 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -256,14 +256,6 @@ #define IEEE80211_AUTH_ALG_LEAP BIT(2)
 };
 
 
-#define IEEE80211_IF_TYPE_AP   0x00000000
-#define IEEE80211_IF_TYPE_MGMT 0x00000001
-#define IEEE80211_IF_TYPE_STA  0x00000002
-#define IEEE80211_IF_TYPE_IBSS 0x00000003
-#define IEEE80211_IF_TYPE_MNTR 0x00000004
-#define IEEE80211_IF_TYPE_WDS  0x5A580211
-#define IEEE80211_IF_TYPE_VLAN 0x00080211
-
 struct ieee80211_sub_if_data {
         struct list_head list;
         unsigned int type;
-- 
1.3.0

