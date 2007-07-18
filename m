From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Wed, 18 Jul 2007 11:34:49 -0400
Message-ID: <20070718153449.GA6625@tuxdriver.com>
References: <20070718021607.GB26907@tuxdriver.com> <20070717.201716.112622844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070717.201716.112622844.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 17, 2007 at 08:17:16PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Tue, 17 Jul 2007 22:16:07 -0400
> 
> > A few more for 2.6.23...individual patches available here:
> > 
> >   http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem
> 
> What about this warning which I reported to you right after the last
> merge?  Did this get fixed?
> 
> net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast
> 
> Please fix that up first, then I'll pull from your tree.

Fair enough! :-)

John

---

The following changes since commit 4ad1366376bfef32ec0ffa12d1faa483d6f330bd:
  NeilBrown (1):
        md: change bitmap_unplug and others to void functions

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Daniel Drake (1):
      mac80211: regulatory domain cleanup

Jiri Benc (1):
      mac80211: fix GCC warning on 64bit platforms

Johannes Berg (2):
      mac80211: use debugfs_rename
      mac80211: regdomain.c needs to include ieee80211_i.h

 net/mac80211/Makefile          |    1 +
 net/mac80211/debugfs_netdev.c  |    9 ++-
 net/mac80211/ieee80211.c       |    7 +-
 net/mac80211/ieee80211_i.h     |    5 +-
 net/mac80211/ieee80211_ioctl.c |  133 ---------------------------------
 net/mac80211/regdomain.c       |  158 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 173 insertions(+), 140 deletions(-)
 create mode 100644 net/mac80211/regdomain.c

diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index e9738da..a9c2d07 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -13,6 +13,7 @@ mac80211-objs := \
 	ieee80211_iface.o \
 	ieee80211_rate.o \
 	michael.o \
+	regdomain.o \
 	tkip.o \
 	aes_ccm.o \
 	wme.o \
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index a3e01d7..799a920 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -397,6 +397,8 @@ static int netdev_notify(struct notifier_block * nb,
 			 void *ndev)
 {
 	struct net_device *dev = ndev;
+	struct dentry *dir;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	char buf[10+IFNAMSIZ];
 
 	if (state != NETDEV_CHANGENAME)
@@ -408,10 +410,11 @@ static int netdev_notify(struct notifier_block * nb,
 	if (dev->ieee80211_ptr->wiphy->privid != mac80211_wiphy_privid)
 		return 0;
 
-	/* TODO
 	sprintf(buf, "netdev:%s", dev->name);
-	debugfs_rename(IEEE80211_DEV_TO_SUB_IF(dev)->debugfsdir, buf);
-	*/
+	dir = sdata->debugfsdir;
+	if (!debugfs_rename(dir->d_parent, dir, dir->d_parent, buf))
+		printk(KERN_ERR "mac80211: debugfs: failed to rename debugfs "
+		       "dir to %s\n", buf);
 
 	return 0;
 }
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 2ddf4ef..272aae9 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -4986,8 +4986,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	 * and we need some headroom for passing the frame to monitor
 	 * interfaces, but never both at the same time.
 	 */
-	local->tx_headroom = max(local->hw.extra_tx_headroom,
-				 sizeof(struct ieee80211_tx_status_rtap_hdr));
+	local->tx_headroom = max_t(unsigned, local->hw.extra_tx_headroom,
+				   sizeof(struct ieee80211_tx_status_rtap_hdr));
 
 	debugfs_hw_add(local);
 
@@ -5095,7 +5095,7 @@ int ieee80211_register_hwmode(struct ieee80211_hw *hw,
 	}
 
 	if (!(hw->flags & IEEE80211_HW_DEFAULT_REG_DOMAIN_CONFIGURED))
-		ieee80211_init_client(local->mdev);
+		ieee80211_set_default_regdomain(mode);
 
 	return 0;
 }
@@ -5246,6 +5246,7 @@ static int __init ieee80211_init(void)
 	}
 
 	ieee80211_debugfs_netdev_init();
+	ieee80211_regdomain_init();
 
 	return 0;
 }
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 055a2a9..6f7bae7 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -759,7 +759,6 @@ void ieee80211_update_default_wep_only(struct ieee80211_local *local);
 /* ieee80211_ioctl.c */
 int ieee80211_set_compression(struct ieee80211_local *local,
 			      struct net_device *dev, struct sta_info *sta);
-int ieee80211_init_client(struct net_device *dev);
 int ieee80211_set_channel(struct ieee80211_local *local, int channel, int freq);
 /* ieee80211_sta.c */
 void ieee80211_sta_timer(unsigned long data);
@@ -798,6 +797,10 @@ void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata);
 int ieee80211_if_add_mgmt(struct ieee80211_local *local);
 void ieee80211_if_del_mgmt(struct ieee80211_local *local);
 
+/* regdomain.c */
+void ieee80211_regdomain_init(void);
+void ieee80211_set_default_regdomain(struct ieee80211_hw_mode *mode);
+
 /* for wiphy privid */
 extern void *mac80211_wiphy_privid;
 
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 5918dd0..d0e1ab5 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -27,20 +27,6 @@
 #include "aes_ccm.h"
 #include "debugfs_key.h"
 
-static int ieee80211_regdom = 0x10; /* FCC */
-module_param(ieee80211_regdom, int, 0444);
-MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");
-
-/*
- * If firmware is upgraded by the vendor, additional channels can be used based
- * on the new Japanese regulatory rules. This is indicated by setting
- * ieee80211_japan_5ghz module parameter to one when loading the 80211 kernel
- * module.
- */
-static int ieee80211_japan_5ghz /* = 0 */;
-module_param(ieee80211_japan_5ghz, int, 0444);
-MODULE_PARM_DESC(ieee80211_japan_5ghz, "Vendor-updated firmware for 5 GHz");
-
 static void ieee80211_set_hw_encryption(struct net_device *dev,
 					struct sta_info *sta, u8 addr[ETH_ALEN],
 					struct ieee80211_key *key)
@@ -412,125 +398,6 @@ static int ieee80211_ioctl_giwrange(struct net_device *dev,
 }
 
 
-struct ieee80211_channel_range {
-	short start_freq;
-	short end_freq;
-	unsigned char power_level;
-	unsigned char antenna_max;
-};
-
-static const struct ieee80211_channel_range ieee80211_fcc_channels[] = {
-	{ 2412, 2462, 27, 6 } /* IEEE 802.11b/g, channels 1..11 */,
-	{ 5180, 5240, 17, 6 } /* IEEE 802.11a, channels 36..48 */,
-	{ 5260, 5320, 23, 6 } /* IEEE 802.11a, channels 52..64 */,
-	{ 5745, 5825, 30, 6 } /* IEEE 802.11a, channels 149..165, outdoor */,
-	{ 0 }
-};
-
-static const struct ieee80211_channel_range ieee80211_mkk_channels[] = {
-	{ 2412, 2472, 20, 6 } /* IEEE 802.11b/g, channels 1..13 */,
-	{ 5170, 5240, 20, 6 } /* IEEE 802.11a, channels 34..48 */,
-	{ 5260, 5320, 20, 6 } /* IEEE 802.11a, channels 52..64 */,
-	{ 0 }
-};
-
-
-static const struct ieee80211_channel_range *channel_range =
-	ieee80211_fcc_channels;
-
-
-static void ieee80211_unmask_channel(struct net_device *dev, int mode,
-				     struct ieee80211_channel *chan)
-{
-	int i;
-
-	chan->flag = 0;
-
-	if (ieee80211_regdom == 64 &&
-	    (mode == MODE_ATHEROS_TURBO || mode == MODE_ATHEROS_TURBOG)) {
-		/* Do not allow Turbo modes in Japan. */
-		return;
-	}
-
-	for (i = 0; channel_range[i].start_freq; i++) {
-		const struct ieee80211_channel_range *r = &channel_range[i];
-		if (r->start_freq <= chan->freq && r->end_freq >= chan->freq) {
-			if (ieee80211_regdom == 64 && !ieee80211_japan_5ghz &&
-			    chan->freq >= 5260 && chan->freq <= 5320) {
-				/*
-				 * Skip new channels in Japan since the
-				 * firmware was not marked having been upgraded
-				 * by the vendor.
-				 */
-				continue;
-			}
-
-			if (ieee80211_regdom == 0x10 &&
-			    (chan->freq == 5190 || chan->freq == 5210 ||
-			     chan->freq == 5230)) {
-				    /* Skip MKK channels when in FCC domain. */
-				    continue;
-			}
-
-			chan->flag |= IEEE80211_CHAN_W_SCAN |
-				IEEE80211_CHAN_W_ACTIVE_SCAN |
-				IEEE80211_CHAN_W_IBSS;
-			chan->power_level = r->power_level;
-			chan->antenna_max = r->antenna_max;
-
-			if (ieee80211_regdom == 64 &&
-			    (chan->freq == 5170 || chan->freq == 5190 ||
-			     chan->freq == 5210 || chan->freq == 5230)) {
-				/*
-				 * New regulatory rules in Japan have backwards
-				 * compatibility with old channels in 5.15-5.25
-				 * GHz band, but the station is not allowed to
-				 * use active scan on these old channels.
-				 */
-				chan->flag &= ~IEEE80211_CHAN_W_ACTIVE_SCAN;
-			}
-
-			if (ieee80211_regdom == 64 &&
-			    (chan->freq == 5260 || chan->freq == 5280 ||
-			     chan->freq == 5300 || chan->freq == 5320)) {
-				/*
-				 * IBSS is not allowed on 5.25-5.35 GHz band
-				 * due to radar detection requirements.
-				 */
-				chan->flag &= ~IEEE80211_CHAN_W_IBSS;
-			}
-
-			break;
-		}
-	}
-}
-
-
-static int ieee80211_unmask_channels(struct net_device *dev)
-{
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_hw_mode *mode;
-	int c;
-
-	list_for_each_entry(mode, &local->modes_list, list) {
-		for (c = 0; c < mode->num_channels; c++) {
-			ieee80211_unmask_channel(dev, mode->mode,
-						 &mode->channels[c]);
-		}
-	}
-	return 0;
-}
-
-
-int ieee80211_init_client(struct net_device *dev)
-{
-	if (ieee80211_regdom == 0x40)
-		channel_range = ieee80211_mkk_channels;
-	ieee80211_unmask_channels(dev);
-	return 0;
-}
-
-
 static int ieee80211_ioctl_siwmode(struct net_device *dev,
 				   struct iw_request_info *info,
 				   __u32 *mode, char *extra)
diff --git a/net/mac80211/regdomain.c b/net/mac80211/regdomain.c
new file mode 100644
index 0000000..b697a2a
--- /dev/null
+++ b/net/mac80211/regdomain.c
@@ -0,0 +1,158 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005-2006, Devicescape Software, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/*
+ * This regulatory domain control implementation is known to be incomplete
+ * and confusing. mac80211 regulatory domain control will be significantly
+ * reworked in the not-too-distant future.
+ *
+ * For now, drivers wishing to control which channels are and aren't available
+ * are advised as follows:
+ *  - set the IEEE80211_HW_DEFAULT_REG_DOMAIN_CONFIGURED flag
+ *  - continue to include *ALL* possible channels in the modes registered
+ *    through ieee80211_register_hwmode()
+ *  - for each allowable ieee80211_channel structure registered in the above
+ *    call, set the flag member to some meaningful value such as
+ *    IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |
+ *    IEEE80211_CHAN_W_IBSS.
+ *  - leave flag as 0 for non-allowable channels
+ *
+ * The usual implementation is for a driver to read a device EEPROM to
+ * determine which regulatory domain it should be operating under, then
+ * looking up the allowable channels in a driver-local table, then performing
+ * the above.
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <net/mac80211.h>
+#include "ieee80211_i.h"
+
+static int ieee80211_regdom = 0x10; /* FCC */
+module_param(ieee80211_regdom, int, 0444);
+MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");
+
+/*
+ * If firmware is upgraded by the vendor, additional channels can be used based
+ * on the new Japanese regulatory rules. This is indicated by setting
+ * ieee80211_japan_5ghz module parameter to one when loading the 80211 kernel
+ * module.
+ */
+static int ieee80211_japan_5ghz /* = 0 */;
+module_param(ieee80211_japan_5ghz, int, 0444);
+MODULE_PARM_DESC(ieee80211_japan_5ghz, "Vendor-updated firmware for 5 GHz");
+
+
+struct ieee80211_channel_range {
+	short start_freq;
+	short end_freq;
+	unsigned char power_level;
+	unsigned char antenna_max;
+};
+
+static const struct ieee80211_channel_range ieee80211_fcc_channels[] = {
+	{ 2412, 2462, 27, 6 } /* IEEE 802.11b/g, channels 1..11 */,
+	{ 5180, 5240, 17, 6 } /* IEEE 802.11a, channels 36..48 */,
+	{ 5260, 5320, 23, 6 } /* IEEE 802.11a, channels 52..64 */,
+	{ 5745, 5825, 30, 6 } /* IEEE 802.11a, channels 149..165, outdoor */,
+	{ 0 }
+};
+
+static const struct ieee80211_channel_range ieee80211_mkk_channels[] = {
+	{ 2412, 2472, 20, 6 } /* IEEE 802.11b/g, channels 1..13 */,
+	{ 5170, 5240, 20, 6 } /* IEEE 802.11a, channels 34..48 */,
+	{ 5260, 5320, 20, 6 } /* IEEE 802.11a, channels 52..64 */,
+	{ 0 }
+};
+
+
+static const struct ieee80211_channel_range *channel_range =
+	ieee80211_fcc_channels;
+
+
+static void ieee80211_unmask_channel(int mode, struct ieee80211_channel *chan)
+{
+	int i;
+
+	chan->flag = 0;
+
+	if (ieee80211_regdom == 64 &&
+	    (mode == MODE_ATHEROS_TURBO || mode == MODE_ATHEROS_TURBOG)) {
+		/* Do not allow Turbo modes in Japan. */
+		return;
+	}
+
+	for (i = 0; channel_range[i].start_freq; i++) {
+		const struct ieee80211_channel_range *r = &channel_range[i];
+		if (r->start_freq <= chan->freq && r->end_freq >= chan->freq) {
+			if (ieee80211_regdom == 64 && !ieee80211_japan_5ghz &&
+			    chan->freq >= 5260 && chan->freq <= 5320) {
+				/*
+				 * Skip new channels in Japan since the
+				 * firmware was not marked having been upgraded
+				 * by the vendor.
+				 */
+				continue;
+			}
+
+			if (ieee80211_regdom == 0x10 &&
+			    (chan->freq == 5190 || chan->freq == 5210 ||
+			     chan->freq == 5230)) {
+				    /* Skip MKK channels when in FCC domain. */
+				    continue;
+			}
+
+			chan->flag |= IEEE80211_CHAN_W_SCAN |
+				IEEE80211_CHAN_W_ACTIVE_SCAN |
+				IEEE80211_CHAN_W_IBSS;
+			chan->power_level = r->power_level;
+			chan->antenna_max = r->antenna_max;
+
+			if (ieee80211_regdom == 64 &&
+			    (chan->freq == 5170 || chan->freq == 5190 ||
+			     chan->freq == 5210 || chan->freq == 5230)) {
+				/*
+				 * New regulatory rules in Japan have backwards
+				 * compatibility with old channels in 5.15-5.25
+				 * GHz band, but the station is not allowed to
+				 * use active scan on these old channels.
+				 */
+				chan->flag &= ~IEEE80211_CHAN_W_ACTIVE_SCAN;
+			}
+
+			if (ieee80211_regdom == 64 &&
+			    (chan->freq == 5260 || chan->freq == 5280 ||
+			     chan->freq == 5300 || chan->freq == 5320)) {
+				/*
+				 * IBSS is not allowed on 5.25-5.35 GHz band
+				 * due to radar detection requirements.
+				 */
+				chan->flag &= ~IEEE80211_CHAN_W_IBSS;
+			}
+
+			break;
+		}
+	}
+}
+
+
+void ieee80211_set_default_regdomain(struct ieee80211_hw_mode *mode)
+{
+	int c;
+	for (c = 0; c < mode->num_channels; c++)
+		ieee80211_unmask_channel(mode->mode, &mode->channels[c]);
+}
+
+
+void ieee80211_regdomain_init(void)
+{
+	if (ieee80211_regdom == 0x40)
+		channel_range = ieee80211_mkk_channels;
+}
+
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
