From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 1/3] wireless: implement basic ethtool support for cfg80211 devices
Date: Wed, 30 Sep 2009 21:19:00 -0400
Message-ID: <1254359942-3483-1-git-send-email-linville@tuxdriver.com>
References: <20091001011340.GA3123@tuxdriver.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kalle.valo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091001011340.GA3123-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 net/wireless/Makefile  |    2 +-
 net/wireless/core.c    |    3 +++
 net/wireless/ethtool.c |   27 +++++++++++++++++++++++++++
 net/wireless/ethtool.h |   10 ++++++++++
 4 files changed, 41 insertions(+), 1 deletions(-)
 create mode 100644 net/wireless/ethtool.c
 create mode 100644 net/wireless/ethtool.h

diff --git a/net/wireless/Makefile b/net/wireless/Makefile
index c814150..f07c8dc 100644
--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -10,7 +10,7 @@ obj-$(CONFIG_WEXT_SPY) += wext-spy.o
 obj-$(CONFIG_WEXT_PRIV) += wext-priv.o
 
 cfg80211-y += core.o sysfs.o radiotap.o util.o reg.o scan.o nl80211.o
-cfg80211-y += mlme.o ibss.o sme.o chan.o
+cfg80211-y += mlme.o ibss.o sme.o chan.o ethtool.o
 cfg80211-$(CONFIG_CFG80211_DEBUGFS) += debugfs.o
 cfg80211-$(CONFIG_CFG80211_WEXT) += wext-compat.o wext-sme.o
 
diff --git a/net/wireless/core.c b/net/wireless/core.c
index c761532..faada5c 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -21,6 +21,7 @@
 #include "sysfs.h"
 #include "debugfs.h"
 #include "wext-compat.h"
+#include "ethtool.h"
 
 /* name for sysfs, %d is appended */
 #define PHY_NAME "phy"
@@ -683,6 +684,8 @@ static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
 				wdev->wext.ps = false;
 			}
 #endif
+		if (!dev->ethtool_ops)
+			dev->ethtool_ops = &cfg80211_ethtool_ops;
 		break;
 	case NETDEV_GOING_DOWN:
 		switch (wdev->iftype) {
diff --git a/net/wireless/ethtool.c b/net/wireless/ethtool.c
new file mode 100644
index 0000000..94ca377
--- /dev/null
+++ b/net/wireless/ethtool.c
@@ -0,0 +1,27 @@
+#include <linux/utsrelease.h>
+#include <net/cfg80211.h>
+#include "ethtool.h"
+
+const struct ethtool_ops cfg80211_ethtool_ops = {
+	.get_drvinfo = cfg80211_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+};
+
+void cfg80211_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+
+	strncpy(info->driver, wiphy_dev(wdev->wiphy)->driver->name,
+		sizeof(info->driver));
+	info->driver[sizeof(info->driver) - 1] = '\0';
+
+	strncpy(info->version, UTS_RELEASE, sizeof(info->version));
+	info->version[sizeof(info->version) - 1] = '\0';
+
+	strncpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	info->fw_version[sizeof(info->fw_version) - 1] = '\0';
+
+	strncpy(info->bus_info, dev_name(wiphy_dev(wdev->wiphy)),
+		sizeof(info->bus_info));
+	info->bus_info[sizeof(info->bus_info) - 1] = '\0';
+}
diff --git a/net/wireless/ethtool.h b/net/wireless/ethtool.h
new file mode 100644
index 0000000..a51b470
--- /dev/null
+++ b/net/wireless/ethtool.h
@@ -0,0 +1,10 @@
+#ifndef __CFG80211_ETHTOOL__
+#define __CFG80211_ETHTOOL__
+
+#include <linux/ethtool.h>
+
+extern void cfg80211_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
+
+extern const struct ethtool_ops cfg80211_ethtool_ops;
+
+#endif /* __CFG80211_ETHTOOL__ */
-- 
1.6.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
