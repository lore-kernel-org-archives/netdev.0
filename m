From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] mac80211: Deinline drv_sta_state
Date: Wed, 15 Jul 2015 14:56:05 +0200
Message-ID: <1436964966-2441-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Michal Kazior <michal.kazior@tieto.com>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this .config: http://busybox.net/~vda/kernel_config,
after deinlining the function size is 3132 bytes and there are
7 callsites.

Total size reduction: about 20 kbytes.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: John Linville <linville@tuxdriver.com>
CC: Michal Kazior <michal.kazior@tieto.com>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 net/mac80211/Makefile     |  1 +
 net/mac80211/driver-ops.c | 41 +++++++++++++++++++++++++++++++++++++++++
 net/mac80211/driver-ops.h | 29 ++---------------------------
 3 files changed, 44 insertions(+), 27 deletions(-)
 create mode 100644 net/mac80211/driver-ops.c

diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 3275f01..783e891 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -3,6 +3,7 @@ obj-$(CONFIG_MAC80211) += mac80211.o
 # mac80211 objects
 mac80211-y := \
 	main.o status.o \
+	driver-ops.o \
 	sta_info.o \
 	wep.o \
 	wpa.o \
diff --git a/net/mac80211/driver-ops.c b/net/mac80211/driver-ops.c
new file mode 100644
index 0000000..267c3b1
--- /dev/null
+++ b/net/mac80211/driver-ops.c
@@ -0,0 +1,41 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <net/mac80211.h>
+#include "ieee80211_i.h"
+#include "trace.h"
+#include "driver-ops.h"
+
+__must_check
+int drv_sta_state(struct ieee80211_local *local,
+		  struct ieee80211_sub_if_data *sdata,
+		  struct sta_info *sta,
+		  enum ieee80211_sta_state old_state,
+		  enum ieee80211_sta_state new_state)
+{
+	int ret = 0;
+
+	might_sleep();
+
+	sdata = get_bss_sdata(sdata);
+	if (!check_sdata_in_driver(sdata))
+		return -EIO;
+
+	trace_drv_sta_state(local, sdata, &sta->sta, old_state, new_state);
+	if (local->ops->sta_state) {
+		ret = local->ops->sta_state(&local->hw, &sdata->vif, &sta->sta,
+					    old_state, new_state);
+	} else if (old_state == IEEE80211_STA_AUTH &&
+		   new_state == IEEE80211_STA_ASSOC) {
+		ret = drv_sta_add(local, sdata, &sta->sta);
+		if (ret == 0)
+			sta->uploaded = true;
+	} else if (old_state == IEEE80211_STA_ASSOC &&
+		   new_state == IEEE80211_STA_AUTH) {
+		drv_sta_remove(local, sdata, &sta->sta);
+	}
+	trace_drv_return_int(local, ret);
+	return ret;
+}
diff --git a/net/mac80211/driver-ops.h b/net/mac80211/driver-ops.h
index 32a2e70..02d9133 100644
--- a/net/mac80211/driver-ops.h
+++ b/net/mac80211/driver-ops.h
@@ -573,37 +573,12 @@ static inline void drv_sta_pre_rcu_remove(struct ieee80211_local *local,
 	trace_drv_return_void(local);
 }
 
-static inline __must_check
+__must_check
 int drv_sta_state(struct ieee80211_local *local,
 		  struct ieee80211_sub_if_data *sdata,
 		  struct sta_info *sta,
 		  enum ieee80211_sta_state old_state,
-		  enum ieee80211_sta_state new_state)
-{
-	int ret = 0;
-
-	might_sleep();
-
-	sdata = get_bss_sdata(sdata);
-	if (!check_sdata_in_driver(sdata))
-		return -EIO;
-
-	trace_drv_sta_state(local, sdata, &sta->sta, old_state, new_state);
-	if (local->ops->sta_state) {
-		ret = local->ops->sta_state(&local->hw, &sdata->vif, &sta->sta,
-					    old_state, new_state);
-	} else if (old_state == IEEE80211_STA_AUTH &&
-		   new_state == IEEE80211_STA_ASSOC) {
-		ret = drv_sta_add(local, sdata, &sta->sta);
-		if (ret == 0)
-			sta->uploaded = true;
-	} else if (old_state == IEEE80211_STA_ASSOC &&
-		   new_state == IEEE80211_STA_AUTH) {
-		drv_sta_remove(local, sdata, &sta->sta);
-	}
-	trace_drv_return_int(local, ret);
-	return ret;
-}
+		  enum ieee80211_sta_state new_state);
 
 static inline void drv_sta_rc_update(struct ieee80211_local *local,
 				     struct ieee80211_sub_if_data *sdata,
-- 
1.8.1.4
