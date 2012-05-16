From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/2] wireless: remove wext sysfs
Date: Wed, 16 May 2012 23:40:18 +0200
Message-ID: <20120516214048.608319597@sipsolutions.net>
References: <20120516214017.936343357@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:41678 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759444Ab2EPV4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 17:56:09 -0400
Content-Disposition: inline; filename=003-wext-remove-sysfs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The only user of this was hal prior to its 0.5.12
release which happened over two years ago, so I'm
sure this can be removed without issues.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 Documentation/feature-removal-schedule.txt |    9 ---
 net/core/net-sysfs.c                       |   74 -----------------------------
 net/wireless/Kconfig                       |   13 -----
 3 files changed, 96 deletions(-)

--- a/Documentation/feature-removal-schedule.txt	2012-05-15 20:14:44.000000000 +0200
+++ b/Documentation/feature-removal-schedule.txt	2012-05-15 20:14:51.000000000 +0200
@@ -242,15 +242,6 @@ Who:	Ravikiran Thirumalai <kiran@scalex8
 
 ---------------------------
 
-What:	Code that is now under CONFIG_WIRELESS_EXT_SYSFS
-	(in net/core/net-sysfs.c)
-When:	3.5
-Why:	Over 1K .text/.data size reduction, data is available in other
-	ways (ioctls)
-Who:	Johannes Berg <johannes@sipsolutions.net>
-
----------------------------
-
 What:	sysfs ui for changing p4-clockmod parameters
 When:	September 2009
 Why:	See commits 129f8ae9b1b5be94517da76009ea956e89104ce8 and
--- a/net/core/net-sysfs.c	2012-05-15 20:14:44.000000000 +0200
+++ b/net/core/net-sysfs.c	2012-05-15 20:14:51.000000000 +0200
@@ -417,72 +417,6 @@ static struct attribute_group netstat_gr
 	.name  = "statistics",
 	.attrs  = netstat_attrs,
 };
-
-#ifdef CONFIG_WIRELESS_EXT_SYSFS
-/* helper function that does all the locking etc for wireless stats */
-static ssize_t wireless_show(struct device *d, char *buf,
-			     ssize_t (*format)(const struct iw_statistics *,
-					       char *))
-{
-	struct net_device *dev = to_net_dev(d);
-	const struct iw_statistics *iw;
-	ssize_t ret = -EINVAL;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-	if (dev_isalive(dev)) {
-		iw = get_wireless_stats(dev);
-		if (iw)
-			ret = (*format)(iw, buf);
-	}
-	rtnl_unlock();
-
-	return ret;
-}
-
-/* show function template for wireless fields */
-#define WIRELESS_SHOW(name, field, format_string)			\
-static ssize_t format_iw_##name(const struct iw_statistics *iw, char *buf) \
-{									\
-	return sprintf(buf, format_string, iw->field);			\
-}									\
-static ssize_t show_iw_##name(struct device *d,				\
-			      struct device_attribute *attr, char *buf)	\
-{									\
-	return wireless_show(d, buf, format_iw_##name);			\
-}									\
-static DEVICE_ATTR(name, S_IRUGO, show_iw_##name, NULL)
-
-WIRELESS_SHOW(status, status, fmt_hex);
-WIRELESS_SHOW(link, qual.qual, fmt_dec);
-WIRELESS_SHOW(level, qual.level, fmt_dec);
-WIRELESS_SHOW(noise, qual.noise, fmt_dec);
-WIRELESS_SHOW(nwid, discard.nwid, fmt_dec);
-WIRELESS_SHOW(crypt, discard.code, fmt_dec);
-WIRELESS_SHOW(fragment, discard.fragment, fmt_dec);
-WIRELESS_SHOW(misc, discard.misc, fmt_dec);
-WIRELESS_SHOW(retries, discard.retries, fmt_dec);
-WIRELESS_SHOW(beacon, miss.beacon, fmt_dec);
-
-static struct attribute *wireless_attrs[] = {
-	&dev_attr_status.attr,
-	&dev_attr_link.attr,
-	&dev_attr_level.attr,
-	&dev_attr_noise.attr,
-	&dev_attr_nwid.attr,
-	&dev_attr_crypt.attr,
-	&dev_attr_fragment.attr,
-	&dev_attr_retries.attr,
-	&dev_attr_misc.attr,
-	&dev_attr_beacon.attr,
-	NULL
-};
-
-static struct attribute_group wireless_group = {
-	.name = "wireless",
-	.attrs = wireless_attrs,
-};
-#endif
 #endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_RPS
@@ -1463,14 +1397,6 @@ int netdev_register_kobject(struct net_d
 		groups++;
 
 	*groups++ = &netstat_group;
-#ifdef CONFIG_WIRELESS_EXT_SYSFS
-	if (net->ieee80211_ptr)
-		*groups++ = &wireless_group;
-#ifdef CONFIG_WIRELESS_EXT
-	else if (net->wireless_handlers)
-		*groups++ = &wireless_group;
-#endif
-#endif
 #endif /* CONFIG_SYSFS */
 
 	error = device_add(dev);
--- a/net/wireless/Kconfig	2012-05-15 20:14:44.000000000 +0200
+++ b/net/wireless/Kconfig	2012-05-15 20:14:51.000000000 +0200
@@ -119,19 +119,6 @@ config CFG80211_WEXT
 	  Enable this option if you need old userspace for wireless
 	  extensions with cfg80211-based drivers.
 
-config WIRELESS_EXT_SYSFS
-	bool "Wireless extensions sysfs files"
-	depends on WEXT_CORE && SYSFS
-	help
-	  This option enables the deprecated wireless statistics
-	  files in /sys/class/net/*/wireless/. The same information
-	  is available via the ioctls as well.
-
-	  Say N. If you know you have ancient tools requiring it,
-	  like very old versions of hal (prior to 0.5.12 release),
-	  say Y and update the tools as soon as possible as this
-	  option will be removed soon.
-
 config LIB80211
 	tristate "Common routines for IEEE802.11 drivers"
 	default n
