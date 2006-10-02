From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/8] d80211: rename rate_control.h to ieee80211_rate.h
Date: Mon,  2 Oct 2006 20:26:07 +0200 (CEST)
Message-ID: <20061002182607.2C97F47F4F@silver.suse.cz>
References: <20061002202530.235763132.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41159 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965246AbWJBSYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 14:24:55 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20061002202530.235763132.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rate_control.h is not a header for rate_control.c as the name suggests.
Furthermore, we want to introduce ieee80211_rate.c which implements some
things defined in rate_control.h.

This patch renames rate_control.h to ieee80211_rate.h.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |    2 -
 net/d80211/ieee80211_ioctl.c |    2 -
 net/d80211/ieee80211_rate.h  |  154 ++++++++++++++++++++++++++++++++++++++++++
 net/d80211/ieee80211_scan.c  |    2 -
 net/d80211/ieee80211_sta.c   |    2 -
 net/d80211/ieee80211_sysfs.c |    2 -
 net/d80211/rate_control.c    |    2 -
 net/d80211/rate_control.h    |  154 ------------------------------------------
 net/d80211/sta_info.c        |    2 -
 9 files changed, 161 insertions(+), 161 deletions(-)
 create mode 100644 net/d80211/ieee80211_rate.h
 delete mode 100644 net/d80211/rate_control.h

f0ab1336dc23b25ed00a7a26ec0ba0b9a1a96cdf
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index b30bd80..b138eb0 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -25,7 +25,7 @@ #include <net/d80211.h>
 #include <net/d80211_common.h>
 #include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
-#include "rate_control.h"
+#include "ieee80211_rate.h"
 #include "wep.h"
 #include "wpa.h"
 #include "tkip.h"
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 445adad..36759e4 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -23,7 +23,7 @@ #include <net/d80211.h>
 #include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "hostapd_ioctl.h"
-#include "rate_control.h"
+#include "ieee80211_rate.h"
 #include "wpa.h"
 #include "aes_ccm.h"
 
diff --git a/net/d80211/ieee80211_rate.h b/net/d80211/ieee80211_rate.h
new file mode 100644
index 0000000..e1c9e05
--- /dev/null
+++ b/net/d80211/ieee80211_rate.h
@@ -0,0 +1,154 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005, Devicescape Software, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef IEEE80211_RATE_H
+#define IEEE80211_RATE_H
+
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <net/d80211.h>
+#include "ieee80211_i.h"
+#include "sta_info.h"
+
+#define RATE_CONTROL_NUM_DOWN 20
+#define RATE_CONTROL_NUM_UP   15
+
+
+struct rate_control_extra {
+	/* values from rate_control_get_rate() to the caller: */
+	struct ieee80211_rate *probe; /* probe with this rate, or NULL for no
+				       * probing */
+	int startidx, endidx, rateidx;
+	struct ieee80211_rate *nonerp;
+	int nonerp_idx;
+
+	/* parameters from the caller to rate_control_get_rate(): */
+	int mgmt_data; /* this is data frame that is used for management
+			* (e.g., IEEE 802.1X EAPOL) */
+	u16 ethertype;
+};
+
+
+struct rate_control_ops {
+	const char *name;
+	void (*tx_status)(struct net_device *dev, struct sk_buff *skb,
+			  struct ieee80211_tx_status *status);
+	struct ieee80211_rate *
+	(*get_rate)(struct net_device *dev, struct sk_buff *skb,
+		    struct rate_control_extra *extra);
+	void (*rate_init)(struct ieee80211_local *local, struct sta_info *sta);
+	void (*clear)(void *priv);
+
+	void * (*alloc)(struct ieee80211_local *local);
+	void (*free)(void *priv);
+	void * (*alloc_sta)(void);
+	void (*free_sta)(void *priv);
+
+	int (*add_attrs)(void *priv, struct kobject *kobj);
+	void (*remove_attrs)(void *priv, struct kobject *kobj);
+	int (*add_sta_attrs)(void *priv, struct kobject *kobj);
+	void (*remove_sta_attrs)(void *priv, struct kobject *kobj);
+};
+
+
+int ieee80211_rate_control_register(struct rate_control_ops *ops);
+void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
+
+
+static inline void rate_control_tx_status(struct net_device *dev,
+					  struct sk_buff *skb,
+					  struct ieee80211_tx_status *status)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	local->rate_ctrl->tx_status(dev, skb, status);
+}
+
+
+static inline struct ieee80211_rate *
+rate_control_get_rate(struct net_device *dev, struct sk_buff *skb,
+		      struct rate_control_extra *extra)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	return local->rate_ctrl->get_rate(dev, skb, extra);
+}
+
+
+static inline void rate_control_rate_init(struct ieee80211_local *local,
+					  struct sta_info *sta)
+{
+	local->rate_ctrl->rate_init(local, sta);
+}
+
+
+static inline void rate_control_clear(struct ieee80211_local *local)
+{
+	local->rate_ctrl->clear(local->rate_ctrl_priv);
+}
+
+
+static inline void * rate_control_alloc(struct ieee80211_local *local)
+{
+	return local->rate_ctrl->alloc(local);
+}
+
+
+static inline void rate_control_free(struct ieee80211_local *local)
+{
+	if (!local->rate_ctrl || !local->rate_ctrl_priv)
+		return;
+	local->rate_ctrl->free(local->rate_ctrl_priv);
+	local->rate_ctrl_priv = NULL;
+}
+
+
+static inline void * rate_control_alloc_sta(struct ieee80211_local *local)
+{
+	return local->rate_ctrl->alloc_sta();
+}
+
+
+static inline void rate_control_free_sta(struct ieee80211_local *local,
+					 void *priv)
+{
+	local->rate_ctrl->free_sta(priv);
+}
+
+static inline int rate_control_add_attrs(struct ieee80211_local *local,
+					 void *priv, struct kobject *kobj)
+{
+	if (local->rate_ctrl->add_attrs)
+		return local->rate_ctrl->add_attrs(priv, kobj);
+	return 0;
+}
+
+static inline void rate_control_remove_attrs(struct ieee80211_local *local,
+					     void *priv, struct kobject *kobj)
+{
+	if (local->rate_ctrl->remove_attrs)
+		local->rate_ctrl->remove_attrs(priv, kobj);
+}
+
+static inline int rate_control_add_sta_attrs(struct ieee80211_local *local,
+					     void *priv, struct kobject *kobj)
+{
+	if (local->rate_ctrl->add_sta_attrs)
+		return local->rate_ctrl->add_sta_attrs(priv, kobj);
+	return 0;
+}
+
+static inline void rate_control_remove_sta_attrs(struct ieee80211_local *local,
+						 void *priv,
+						 struct kobject *kobj)
+{
+	if (local->rate_ctrl->remove_sta_attrs)
+		local->rate_ctrl->remove_sta_attrs(priv, kobj);
+}
+
+#endif /* IEEE80211_RATE_H */
diff --git a/net/d80211/ieee80211_scan.c b/net/d80211/ieee80211_scan.c
index 8ed1e39..0774e9a 100644
--- a/net/d80211/ieee80211_scan.c
+++ b/net/d80211/ieee80211_scan.c
@@ -14,7 +14,7 @@ #include <linux/skbuff.h>
 
 #include <net/d80211.h>
 #include "ieee80211_i.h"
-#include "rate_control.h"
+#include "ieee80211_rate.h"
 
 
 /* Maximum number of seconds to wait for the traffic load to get below
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 159474f..3ea75ee 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -28,7 +28,7 @@ #include <asm/delay.h>
 #include <net/d80211.h>
 #include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
-#include "rate_control.h"
+#include "ieee80211_rate.h"
 #include "hostapd_ioctl.h"
 
 #define IEEE80211_AUTH_TIMEOUT (HZ / 5)
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index bb93723..f9d0e12 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -14,7 +14,7 @@ #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
-#include "rate_control.h"
+#include "ieee80211_rate.h"
 
 #define to_ieee80211_local(class)	container_of(class, struct ieee80211_local, class_dev)
 #define to_net_dev(class)		container_of(class, struct net_device, class_dev)
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 30c31ee..90326a8 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -17,7 +17,7 @@ #include <linux/compiler.h>
 
 #include <net/d80211.h>
 #include "ieee80211_i.h"
-#include "rate_control.h"
+#include "ieee80211_rate.h"
 
 
 /* This is a minimal implementation of TX rate controlling that can be used
diff --git a/net/d80211/rate_control.h b/net/d80211/rate_control.h
deleted file mode 100644
index 08a8add..0000000
--- a/net/d80211/rate_control.h
+++ /dev/null
@@ -1,154 +0,0 @@
-/*
- * Copyright 2002-2005, Instant802 Networks, Inc.
- * Copyright 2005, Devicescape Software, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef RATE_CONTROL
-#define RATE_CONTROL
-
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
-#include <linux/types.h>
-#include <net/d80211.h>
-#include "ieee80211_i.h"
-#include "sta_info.h"
-
-#define RATE_CONTROL_NUM_DOWN 20
-#define RATE_CONTROL_NUM_UP   15
-
-
-struct rate_control_extra {
-	/* values from rate_control_get_rate() to the caller: */
-	struct ieee80211_rate *probe; /* probe with this rate, or NULL for no
-				       * probing */
-	int startidx, endidx, rateidx;
-	struct ieee80211_rate *nonerp;
-	int nonerp_idx;
-
-	/* parameters from the caller to rate_control_get_rate(): */
-	int mgmt_data; /* this is data frame that is used for management
-			* (e.g., IEEE 802.1X EAPOL) */
-	u16 ethertype;
-};
-
-
-struct rate_control_ops {
-	const char *name;
-	void (*tx_status)(struct net_device *dev, struct sk_buff *skb,
-			  struct ieee80211_tx_status *status);
-	struct ieee80211_rate *
-	(*get_rate)(struct net_device *dev, struct sk_buff *skb,
-		    struct rate_control_extra *extra);
-	void (*rate_init)(struct ieee80211_local *local, struct sta_info *sta);
-	void (*clear)(void *priv);
-
-	void * (*alloc)(struct ieee80211_local *local);
-	void (*free)(void *priv);
-	void * (*alloc_sta)(void);
-	void (*free_sta)(void *priv);
-
-	int (*add_attrs)(void *priv, struct kobject *kobj);
-	void (*remove_attrs)(void *priv, struct kobject *kobj);
-	int (*add_sta_attrs)(void *priv, struct kobject *kobj);
-	void (*remove_sta_attrs)(void *priv, struct kobject *kobj);
-};
-
-
-int ieee80211_rate_control_register(struct rate_control_ops *ops);
-void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
-
-
-static inline void rate_control_tx_status(struct net_device *dev,
-					  struct sk_buff *skb,
-					  struct ieee80211_tx_status *status)
-{
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-	local->rate_ctrl->tx_status(dev, skb, status);
-}
-
-
-static inline struct ieee80211_rate *
-rate_control_get_rate(struct net_device *dev, struct sk_buff *skb,
-		      struct rate_control_extra *extra)
-{
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-	return local->rate_ctrl->get_rate(dev, skb, extra);
-}
-
-
-static inline void rate_control_rate_init(struct ieee80211_local *local,
-					  struct sta_info *sta)
-{
-	local->rate_ctrl->rate_init(local, sta);
-}
-
-
-static inline void rate_control_clear(struct ieee80211_local *local)
-{
-	local->rate_ctrl->clear(local->rate_ctrl_priv);
-}
-
-
-static inline void * rate_control_alloc(struct ieee80211_local *local)
-{
-	return local->rate_ctrl->alloc(local);
-}
-
-
-static inline void rate_control_free(struct ieee80211_local *local)
-{
-	if (!local->rate_ctrl || !local->rate_ctrl_priv)
-		return;
-	local->rate_ctrl->free(local->rate_ctrl_priv);
-	local->rate_ctrl_priv = NULL;
-}
-
-
-static inline void * rate_control_alloc_sta(struct ieee80211_local *local)
-{
-	return local->rate_ctrl->alloc_sta();
-}
-
-
-static inline void rate_control_free_sta(struct ieee80211_local *local,
-					 void *priv)
-{
-	local->rate_ctrl->free_sta(priv);
-}
-
-static inline int rate_control_add_attrs(struct ieee80211_local *local,
-					 void *priv, struct kobject *kobj)
-{
-	if (local->rate_ctrl->add_attrs)
-		return local->rate_ctrl->add_attrs(priv, kobj);
-	return 0;
-}
-
-static inline void rate_control_remove_attrs(struct ieee80211_local *local,
-					     void *priv, struct kobject *kobj)
-{
-	if (local->rate_ctrl->remove_attrs)
-		local->rate_ctrl->remove_attrs(priv, kobj);
-}
-
-static inline int rate_control_add_sta_attrs(struct ieee80211_local *local,
-					     void *priv, struct kobject *kobj)
-{
-	if (local->rate_ctrl->add_sta_attrs)
-		return local->rate_ctrl->add_sta_attrs(priv, kobj);
-	return 0;
-}
-
-static inline void rate_control_remove_sta_attrs(struct ieee80211_local *local,
-						 void *priv,
-						 struct kobject *kobj)
-{
-	if (local->rate_ctrl->remove_sta_attrs)
-		local->rate_ctrl->remove_sta_attrs(priv, kobj);
-}
-
-#endif /* RATE_CONTROL */
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index a326c4a..6a1a466 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -17,7 +17,7 @@ #include <linux/if_arp.h>
 
 #include <net/d80211.h>
 #include "ieee80211_i.h"
-#include "rate_control.h"
+#include "ieee80211_rate.h"
 #include "sta_info.h"
 
 
-- 
1.3.0

