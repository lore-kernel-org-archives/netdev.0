From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: basic regulatory domain support
Date: Sun,  1 Jul 2007 17:39:06 +0100 (BST)
Message-ID: <20070701163907.39B6B7B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch causes zd1211rw-mac80211 to interpret the regdomain in the
EEPROM and restrict the channels accordingly, like the softmac driver does.

It is understood that mac80211 regulatory domain handling will change
significantly in the not-too-distant future.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/Makefile    |    2 +-
 .../net/wireless/mac80211/zd1211rw/zd_ieee80211.c  |  100 ++++++++++++++++++++
 .../net/wireless/mac80211/zd1211rw/zd_ieee80211.h  |    8 +-
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c    |    8 +-
 4 files changed, 106 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.c

diff --git a/drivers/net/wireless/mac80211/zd1211rw/Makefile b/drivers/net/wireless/mac80211/zd1211rw/Makefile
index 564b863..d3eee56 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/Makefile
+++ b/drivers/net/wireless/mac80211/zd1211rw/Makefile
@@ -3,7 +3,7 @@ obj-$(CONFIG_ZD1211RW_MAC80211) += zd1211rw-mac80211.o
 zd1211rw-mac80211-objs := zd_chip.o zd_mac.o \
 		zd_rf_al2230.o zd_rf_rf2959.o \
 		zd_rf_al7230b.o zd_rf_uw2453.o \
-		zd_rf.o zd_usb.o zd_util.o
+		zd_ieee80211.o zd_rf.o zd_usb.o zd_util.o
 
 ifeq ($(CONFIG_ZD1211RW_MAC80211_DEBUG),y)
 EXTRA_CFLAGS += -DDEBUG
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.c b/drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.c
new file mode 100644
index 0000000..9325ba9
--- /dev/null
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.c
@@ -0,0 +1,100 @@
+/* zd_ieee80211.c
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+/*
+ * In the long term, we'll probably find a better way of handling regulatory
+ * requirements outside of the driver.
+ */
+
+#include <linux/kernel.h>
+#include <net/mac80211.h>
+
+#include "zd_ieee80211.h"
+#include "zd_mac.h"
+
+struct channel_range {
+	u8 regdomain;
+	u8 start;
+	u8 end; /* exclusive (channel must be less than end) */
+};
+
+static const struct channel_range channel_ranges[] = {
+	{ ZD_REGDOMAIN_FCC,		1, 12 },
+	{ ZD_REGDOMAIN_IC,		1, 12 },
+	{ ZD_REGDOMAIN_ETSI,		1, 14 },
+	{ ZD_REGDOMAIN_JAPAN,		1, 14 },
+	{ ZD_REGDOMAIN_SPAIN,		1, 14 },
+	{ ZD_REGDOMAIN_FRANCE,		1, 14 },
+
+	/* Japan originally only had channel 14 available (see CHNL_ID 0x40 in
+	 * 802.11). However, in 2001 the range was extended to include channels
+	 * 1-13. The ZyDAS devices still use the old region code but are
+	 * designed to allow the extra channel access in Japan. */
+	{ ZD_REGDOMAIN_JAPAN_ADD,	1, 15 },
+};
+
+const struct channel_range *zd_channel_range(u8 regdomain)
+{
+	int i;
+	for (i = 0; i < ARRAY_SIZE(channel_ranges); i++) {
+		const struct channel_range *range = &channel_ranges[i];
+		if (range->regdomain == regdomain)
+			return range;
+	}
+	return NULL;
+}
+
+#define CHAN_TO_IDX(chan) ((chan) - 1)
+
+static void unmask_bg_channels(struct ieee80211_hw *dev,
+	const struct channel_range *range,
+	struct ieee80211_hw_mode *mode)
+{
+	u8 channel;
+
+	for (channel = range->start; channel < range->end; channel++) {
+		struct ieee80211_channel *chan =
+			&mode->channels[CHAN_TO_IDX(channel)];
+		chan->flag |= IEEE80211_CHAN_W_SCAN |
+			IEEE80211_CHAN_W_ACTIVE_SCAN |
+			IEEE80211_CHAN_W_IBSS;
+	}
+}
+
+void zd_geo_init(struct ieee80211_hw *dev, u8 regdomain)
+{
+	struct zd_mac *mac = zd_dev_mac(dev);
+	const struct channel_range *range;
+
+	dev_dbg(zd_mac_dev(mac), "regdomain %#02x\n", regdomain);
+
+	range = zd_channel_range(regdomain);
+	if (!range) {
+		/* The vendor driver overrides the regulatory domain and
+		 * allowed channel registers and unconditionally restricts
+		 * available channels to 1-11 everywhere. Match their
+		 * questionable behaviour only for regdomains which we don't
+		 * recognise. */
+		dev_warn(zd_mac_dev(mac), "Unrecognised regulatory domain: "
+			"%#02x. Defaulting to FCC.\n", regdomain);
+		range = zd_channel_range(ZD_REGDOMAIN_FCC);
+	}
+
+	unmask_bg_channels(dev, range, &mac->modes[0]);
+	unmask_bg_channels(dev, range, &mac->modes[1]);
+}
+
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.h b/drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.h
index 87d35df..093005f 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_ieee80211.h
@@ -19,6 +19,8 @@ enum {
 	MAX_CHANNEL24 = 14,
 };
 
+void zd_geo_init(struct ieee80211_hw *dev, u8 regdomain);
+
 #define ZD_PLCP_SERVICE_LENGTH_EXTENSION 0x80
 
 struct ofdm_plcp_header {
@@ -58,10 +60,4 @@ static inline u8 zd_cck_plcp_header_rate(const struct cck_plcp_header *header)
 #define ZD_CCK_SIGNAL_5M5	0x37
 #define ZD_CCK_SIGNAL_11M	0x6e
 
-enum ieee80211_std {
-	IEEE80211B = 0x01,
-	IEEE80211A = 0x02,
-	IEEE80211G = 0x04,
-};
-
 #endif /* _ZD_IEEE80211_H */
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index 8df2165..49633d4 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -153,10 +153,7 @@ int zd_mac_init_hw(struct ieee80211_hw *dev)
 	if (r)
 		goto disable_int;
 
-	/* TODO: waiting for regulatory domain support in mac80211 */
-	/*r = zd_geo_init(zd_mac_to_ieee80211(mac), mac->regdomain);
-	if (r)
-		goto disable_int;*/
+	zd_geo_init(dev, mac->regdomain);
 
 	r = 0;
 disable_int:
@@ -888,7 +885,8 @@ struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf)
 	mac->modes[1].channels = mac->channels;
 
 	dev->flags = IEEE80211_HW_RX_INCLUDES_FCS |
-		     IEEE80211_HW_WEP_INCLUDE_IV;
+		     IEEE80211_HW_WEP_INCLUDE_IV |
+		     IEEE80211_HW_DEFAULT_REG_DOMAIN_CONFIGURED;
 	dev->max_rssi = 100;
 	dev->max_signal = 100;
 
-- 
1.5.2.2
