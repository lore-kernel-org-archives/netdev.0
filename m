From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 2/3] cfg80211: add firmware and hardware version to wiphy
Date: Wed, 30 Sep 2009 21:19:01 -0400
Message-ID: <1254359942-3483-2-git-send-email-linville@tuxdriver.com>
References: <20091001011340.GA3123@tuxdriver.com>
 <1254359942-3483-1-git-send-email-linville@tuxdriver.com>
Cc: netdev@vger.kernel.org, Kalle Valo <kalle.valo@nokia.com>,
	Kalle Valo <kalle.valo@iki.fi>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52860 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755344AbZJABUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 21:20:19 -0400
In-Reply-To: <1254359942-3483-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kalle.valo@nokia.com>

It's useful to provide firmware and hardware version to user space and have a
generic interface to retrieve them. Users can provide the version information
in bug reports etc.

Add fields for firmware and hardware version to struct wiphy.

(Dropped nl80211 bits for now and modified remaining bits in favor of
ethtool. -- JWL)

Cc: Kalle Valo <kalle.valo@nokia.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 include/net/cfg80211.h |    3 +++
 net/wireless/ethtool.c |   23 ++++++++++++++++++++++-
 net/wireless/ethtool.h |    3 +++
 3 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 241ea14..6f4862b 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1142,6 +1142,9 @@ struct wiphy {
 	u32 frag_threshold;
 	u32 rts_threshold;
 
+	char fw_version[ETHTOOL_BUSINFO_LEN];
+	u32 hw_version;
+
 	/* If multiple wiphys are registered and you're handed e.g.
 	 * a regular netdev with assigned ieee80211_ptr, you won't
 	 * know whether it points to a wiphy your driver has registered
diff --git a/net/wireless/ethtool.c b/net/wireless/ethtool.c
index 94ca377..3c59549 100644
--- a/net/wireless/ethtool.c
+++ b/net/wireless/ethtool.c
@@ -4,6 +4,8 @@
 
 const struct ethtool_ops cfg80211_ethtool_ops = {
 	.get_drvinfo = cfg80211_get_drvinfo,
+	.get_regs_len = cfg80211_get_regs_len,
+	.get_regs = cfg80211_get_regs,
 	.get_link = ethtool_op_get_link,
 };
 
@@ -18,10 +20,29 @@ void cfg80211_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strncpy(info->version, UTS_RELEASE, sizeof(info->version));
 	info->version[sizeof(info->version) - 1] = '\0';
 
-	strncpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	if (wdev->wiphy->fw_version[0])
+		strncpy(info->fw_version, wdev->wiphy->fw_version,
+			sizeof(info->fw_version));
+	else
+		strncpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	info->fw_version[sizeof(info->fw_version) - 1] = '\0';
 
 	strncpy(info->bus_info, dev_name(wiphy_dev(wdev->wiphy)),
 		sizeof(info->bus_info));
 	info->bus_info[sizeof(info->bus_info) - 1] = '\0';
 }
+
+int cfg80211_get_regs_len(struct net_device *dev)
+{
+	/* For now, return 0... */
+	return 0;
+}
+
+void cfg80211_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			void *data)
+{
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+
+	regs->version = wdev->wiphy->hw_version;
+	regs->len = 0;
+}
diff --git a/net/wireless/ethtool.h b/net/wireless/ethtool.h
index a51b470..2d4602a 100644
--- a/net/wireless/ethtool.h
+++ b/net/wireless/ethtool.h
@@ -4,6 +4,9 @@
 #include <linux/ethtool.h>
 
 extern void cfg80211_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
+extern int cfg80211_get_regs_len(struct net_device *);
+extern void cfg80211_get_regs(struct net_device *, struct ethtool_regs *,
+				void *);
 
 extern const struct ethtool_ops cfg80211_ethtool_ops;
 
-- 
1.6.2.5

