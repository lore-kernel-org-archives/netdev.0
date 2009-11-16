From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-11-16
Date: Mon, 16 Nov 2009 11:26:55 -0500
Message-ID: <20091116162655.GD14410@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

One last(?) set of fixes intended for 2.6.32...

The biggest is a revert of the patch that added cfg80211 support
to ipw2200.  It was ill conceived and inadvertantly caused problems
for ipw2100.  There are fixes available now, but they are just as
big as the revert -- I'll restage them for 2.6.33.  There is little
activity in ipw2200, so it the revert should be set.  Plus, I've
tested the revert locally.

There is also a warning fix for where p54usb was using stack memory for
DMA.  And finally, two small MAINTAINERS fixes.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit d01032e4fd33110f9f3a085a36cb819c1dfc5827:
  Wey-Yi Guy (1):
        iwlwifi: Fix issue on file transfer stalled in HT mode

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Gertjan van Wingerde (1):
      rt2x00: Update MAINTAINERS

Joe Perches (1):
      MAINTAINERS: RFKILL - Fix pattern entry missing colon

John W. Linville (1):
      Revert "libipw: initiate cfg80211 API conversion"

Larry Finger (1):
      p54usb: Remove DMA buffer from stack

 MAINTAINERS                                  |    3 +-
 drivers/net/wireless/ipw2x00/ipw2100.c       |    6 +-
 drivers/net/wireless/ipw2x00/ipw2200.c       |  141 +++++---------------------
 drivers/net/wireless/ipw2x00/libipw.h        |    8 +-
 drivers/net/wireless/ipw2x00/libipw_module.c |   42 +-------
 drivers/net/wireless/p54/p54usb.c            |   10 ++-
 6 files changed, 45 insertions(+), 165 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index b37e0cd..887b50b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4281,6 +4281,7 @@ F:	drivers/video/aty/aty128fb.c
 RALINK RT2X00 WIRELESS LAN DRIVER
 P:	rt2x00 project
 M:	Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+M:	Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org (moderated for non-subscribers)
 W:	http://rt2x00.serialmonkey.com/
@@ -4368,7 +4369,7 @@ RFKILL
 M:	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 S:	Maintained
-F	Documentation/rfkill.txt
+F:	Documentation/rfkill.txt
 F:	net/rfkill/
 
 RISCOM8 DRIVER
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 240cff1..6e2fc0c 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6029,7 +6029,7 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 	struct ipw2100_priv *priv;
 	struct net_device *dev;
 
-	dev = alloc_ieee80211(sizeof(struct ipw2100_priv), 0);
+	dev = alloc_ieee80211(sizeof(struct ipw2100_priv));
 	if (!dev)
 		return NULL;
 	priv = libipw_priv(dev);
@@ -6342,7 +6342,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 		sysfs_remove_group(&pci_dev->dev.kobj,
 				   &ipw2100_attribute_group);
 
-		free_ieee80211(dev, 0);
+		free_ieee80211(dev);
 		pci_set_drvdata(pci_dev, NULL);
 	}
 
@@ -6400,7 +6400,7 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 		if (dev->base_addr)
 			iounmap((void __iomem *)dev->base_addr);
 
-		free_ieee80211(dev, 0);
+		free_ieee80211(dev);
 	}
 
 	pci_release_regions(pci_dev);
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 8d58e6e..0d30a9e 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -103,25 +103,6 @@ static int antenna = CFG_SYS_ANTENNA_BOTH;
 static int rtap_iface = 0;     /* def: 0 -- do not create rtap interface */
 #endif
 
-static struct ieee80211_rate ipw2200_rates[] = {
-	{ .bitrate = 10 },
-	{ .bitrate = 20, .flags = IEEE80211_RATE_SHORT_PREAMBLE },
-	{ .bitrate = 55, .flags = IEEE80211_RATE_SHORT_PREAMBLE },
-	{ .bitrate = 110, .flags = IEEE80211_RATE_SHORT_PREAMBLE },
-	{ .bitrate = 60 },
-	{ .bitrate = 90 },
-	{ .bitrate = 120 },
-	{ .bitrate = 180 },
-	{ .bitrate = 240 },
-	{ .bitrate = 360 },
-	{ .bitrate = 480 },
-	{ .bitrate = 540 }
-};
-
-#define ipw2200_a_rates		(ipw2200_rates + 4)
-#define ipw2200_num_a_rates	8
-#define ipw2200_bg_rates	(ipw2200_rates + 0)
-#define ipw2200_num_bg_rates	12
 
 #ifdef CONFIG_IPW2200_QOS
 static int qos_enable = 0;
@@ -8673,6 +8654,24 @@ static int ipw_sw_reset(struct ipw_priv *priv, int option)
  *
  */
 
+static int ipw_wx_get_name(struct net_device *dev,
+			   struct iw_request_info *info,
+			   union iwreq_data *wrqu, char *extra)
+{
+	struct ipw_priv *priv = libipw_priv(dev);
+	mutex_lock(&priv->mutex);
+	if (priv->status & STATUS_RF_KILL_MASK)
+		strcpy(wrqu->name, "radio off");
+	else if (!(priv->status & STATUS_ASSOCIATED))
+		strcpy(wrqu->name, "unassociated");
+	else
+		snprintf(wrqu->name, IFNAMSIZ, "IEEE 802.11%c",
+			 ipw_modes[priv->assoc_request.ieee_mode]);
+	IPW_DEBUG_WX("Name: %s\n", wrqu->name);
+	mutex_unlock(&priv->mutex);
+	return 0;
+}
+
 static int ipw_set_channel(struct ipw_priv *priv, u8 channel)
 {
 	if (channel == 0) {
@@ -9972,7 +9971,7 @@ static int ipw_wx_sw_reset(struct net_device *dev,
 /* Rebase the WE IOCTLs to zero for the handler array */
 #define IW_IOCTL(x) [(x)-SIOCSIWCOMMIT]
 static iw_handler ipw_wx_handlers[] = {
-	IW_IOCTL(SIOCGIWNAME) = (iw_handler) cfg80211_wext_giwname,
+	IW_IOCTL(SIOCGIWNAME) = ipw_wx_get_name,
 	IW_IOCTL(SIOCSIWFREQ) = ipw_wx_set_freq,
 	IW_IOCTL(SIOCGIWFREQ) = ipw_wx_get_freq,
 	IW_IOCTL(SIOCSIWMODE) = ipw_wx_set_mode,
@@ -11416,100 +11415,16 @@ static void ipw_bg_down(struct work_struct *work)
 /* Called by register_netdev() */
 static int ipw_net_init(struct net_device *dev)
 {
-	int i, rc = 0;
 	struct ipw_priv *priv = libipw_priv(dev);
-	const struct libipw_geo *geo = libipw_get_geo(priv->ieee);
-	struct wireless_dev *wdev = &priv->ieee->wdev;
 	mutex_lock(&priv->mutex);
 
 	if (ipw_up(priv)) {
-		rc = -EIO;
-		goto out;
-	}
-
-	memcpy(wdev->wiphy->perm_addr, priv->mac_addr, ETH_ALEN);
-
-	/* fill-out priv->ieee->bg_band */
-	if (geo->bg_channels) {
-		struct ieee80211_supported_band *bg_band = &priv->ieee->bg_band;
-
-		bg_band->band = IEEE80211_BAND_2GHZ;
-		bg_band->n_channels = geo->bg_channels;
-		bg_band->channels =
-			kzalloc(geo->bg_channels *
-				sizeof(struct ieee80211_channel), GFP_KERNEL);
-		/* translate geo->bg to bg_band.channels */
-		for (i = 0; i < geo->bg_channels; i++) {
-			bg_band->channels[i].band = IEEE80211_BAND_2GHZ;
-			bg_band->channels[i].center_freq = geo->bg[i].freq;
-			bg_band->channels[i].hw_value = geo->bg[i].channel;
-			bg_band->channels[i].max_power = geo->bg[i].max_power;
-			if (geo->bg[i].flags & LIBIPW_CH_PASSIVE_ONLY)
-				bg_band->channels[i].flags |=
-					IEEE80211_CHAN_PASSIVE_SCAN;
-			if (geo->bg[i].flags & LIBIPW_CH_NO_IBSS)
-				bg_band->channels[i].flags |=
-					IEEE80211_CHAN_NO_IBSS;
-			if (geo->bg[i].flags & LIBIPW_CH_RADAR_DETECT)
-				bg_band->channels[i].flags |=
-					IEEE80211_CHAN_RADAR;
-			/* No equivalent for LIBIPW_CH_80211H_RULES,
-			   LIBIPW_CH_UNIFORM_SPREADING, or
-			   LIBIPW_CH_B_ONLY... */
-		}
-		/* point at bitrate info */
-		bg_band->bitrates = ipw2200_bg_rates;
-		bg_band->n_bitrates = ipw2200_num_bg_rates;
-
-		wdev->wiphy->bands[IEEE80211_BAND_2GHZ] = bg_band;
-	}
-
-	/* fill-out priv->ieee->a_band */
-	if (geo->a_channels) {
-		struct ieee80211_supported_band *a_band = &priv->ieee->a_band;
-
-		a_band->band = IEEE80211_BAND_5GHZ;
-		a_band->n_channels = geo->a_channels;
-		a_band->channels =
-			kzalloc(geo->a_channels *
-				sizeof(struct ieee80211_channel), GFP_KERNEL);
-		/* translate geo->bg to a_band.channels */
-		for (i = 0; i < geo->a_channels; i++) {
-			a_band->channels[i].band = IEEE80211_BAND_2GHZ;
-			a_band->channels[i].center_freq = geo->a[i].freq;
-			a_band->channels[i].hw_value = geo->a[i].channel;
-			a_band->channels[i].max_power = geo->a[i].max_power;
-			if (geo->a[i].flags & LIBIPW_CH_PASSIVE_ONLY)
-				a_band->channels[i].flags |=
-					IEEE80211_CHAN_PASSIVE_SCAN;
-			if (geo->a[i].flags & LIBIPW_CH_NO_IBSS)
-				a_band->channels[i].flags |=
-					IEEE80211_CHAN_NO_IBSS;
-			if (geo->a[i].flags & LIBIPW_CH_RADAR_DETECT)
-				a_band->channels[i].flags |=
-					IEEE80211_CHAN_RADAR;
-			/* No equivalent for LIBIPW_CH_80211H_RULES,
-			   LIBIPW_CH_UNIFORM_SPREADING, or
-			   LIBIPW_CH_B_ONLY... */
-		}
-		/* point at bitrate info */
-		a_band->bitrates = ipw2200_a_rates;
-		a_band->n_bitrates = ipw2200_num_a_rates;
-
-		wdev->wiphy->bands[IEEE80211_BAND_5GHZ] = a_band;
-	}
-
-	set_wiphy_dev(wdev->wiphy, &priv->pci_dev->dev);
-
-	/* With that information in place, we can now register the wiphy... */
-	if (wiphy_register(wdev->wiphy)) {
-		rc = -EIO;
-		goto out;
+		mutex_unlock(&priv->mutex);
+		return -EIO;
 	}
 
-out:
 	mutex_unlock(&priv->mutex);
-	return rc;
+	return 0;
 }
 
 /* PCI driver stuff */
@@ -11640,7 +11555,7 @@ static int ipw_prom_alloc(struct ipw_priv *priv)
 	if (priv->prom_net_dev)
 		return -EPERM;
 
-	priv->prom_net_dev = alloc_ieee80211(sizeof(struct ipw_prom_priv), 1);
+	priv->prom_net_dev = alloc_ieee80211(sizeof(struct ipw_prom_priv));
 	if (priv->prom_net_dev == NULL)
 		return -ENOMEM;
 
@@ -11659,7 +11574,7 @@ static int ipw_prom_alloc(struct ipw_priv *priv)
 
 	rc = register_netdev(priv->prom_net_dev);
 	if (rc) {
-		free_ieee80211(priv->prom_net_dev, 1);
+		free_ieee80211(priv->prom_net_dev);
 		priv->prom_net_dev = NULL;
 		return rc;
 	}
@@ -11673,7 +11588,7 @@ static void ipw_prom_free(struct ipw_priv *priv)
 		return;
 
 	unregister_netdev(priv->prom_net_dev);
-	free_ieee80211(priv->prom_net_dev, 1);
+	free_ieee80211(priv->prom_net_dev);
 
 	priv->prom_net_dev = NULL;
 }
@@ -11701,7 +11616,7 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 	struct ipw_priv *priv;
 	int i;
 
-	net_dev = alloc_ieee80211(sizeof(struct ipw_priv), 0);
+	net_dev = alloc_ieee80211(sizeof(struct ipw_priv));
 	if (net_dev == NULL) {
 		err = -ENOMEM;
 		goto out;
@@ -11849,7 +11764,7 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
       out_free_ieee80211:
-	free_ieee80211(priv->net_dev, 0);
+	free_ieee80211(priv->net_dev);
       out:
 	return err;
 }
@@ -11916,7 +11831,7 @@ static void __devexit ipw_pci_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	free_ieee80211(priv->net_dev, 0);
+	free_ieee80211(priv->net_dev);
 	free_firmware();
 }
 
diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/ipw2x00/libipw.h
index bf45391..1e334ff 100644
--- a/drivers/net/wireless/ipw2x00/libipw.h
+++ b/drivers/net/wireless/ipw2x00/libipw.h
@@ -31,7 +31,6 @@
 #include <linux/ieee80211.h>
 
 #include <net/lib80211.h>
-#include <net/cfg80211.h>
 
 #define LIBIPW_VERSION "git-1.1.13"
 
@@ -784,15 +783,12 @@ struct libipw_geo {
 
 struct libipw_device {
 	struct net_device *dev;
-	struct wireless_dev wdev;
 	struct libipw_security sec;
 
 	/* Bookkeeping structures */
 	struct libipw_stats ieee_stats;
 
 	struct libipw_geo geo;
-	struct ieee80211_supported_band bg_band;
-	struct ieee80211_supported_band a_band;
 
 	/* Probe / Beacon management */
 	struct list_head network_free_list;
@@ -1018,8 +1014,8 @@ static inline int libipw_is_cck_rate(u8 rate)
 }
 
 /* ieee80211.c */
-extern void free_ieee80211(struct net_device *dev, int monitor);
-extern struct net_device *alloc_ieee80211(int sizeof_priv, int monitor);
+extern void free_ieee80211(struct net_device *dev);
+extern struct net_device *alloc_ieee80211(int sizeof_priv);
 extern int libipw_change_mtu(struct net_device *dev, int new_mtu);
 
 extern void libipw_networks_age(struct libipw_device *ieee,
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index a0e9f6a..eb2b608 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -62,9 +62,6 @@ MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 
-struct cfg80211_ops libipw_config_ops = { };
-void *libipw_wiphy_privid = &libipw_wiphy_privid;
-
 static int libipw_networks_allocate(struct libipw_device *ieee)
 {
 	if (ieee->networks)
@@ -143,7 +140,7 @@ int libipw_change_mtu(struct net_device *dev, int new_mtu)
 }
 EXPORT_SYMBOL(libipw_change_mtu);
 
-struct net_device *alloc_ieee80211(int sizeof_priv, int monitor)
+struct net_device *alloc_ieee80211(int sizeof_priv)
 {
 	struct libipw_device *ieee;
 	struct net_device *dev;
@@ -160,31 +157,10 @@ struct net_device *alloc_ieee80211(int sizeof_priv, int monitor)
 
 	ieee->dev = dev;
 
-	if (!monitor) {
-		ieee->wdev.wiphy = wiphy_new(&libipw_config_ops, 0);
-		if (!ieee->wdev.wiphy) {
-			LIBIPW_ERROR("Unable to allocate wiphy.\n");
-			goto failed_free_netdev;
-		}
-
-		ieee->dev->ieee80211_ptr = &ieee->wdev;
-		ieee->wdev.iftype = NL80211_IFTYPE_STATION;
-
-		/* Fill-out wiphy structure bits we know...  Not enough info
-		   here to call set_wiphy_dev or set MAC address or channel info
-		   -- have to do that in ->ndo_init... */
-		ieee->wdev.wiphy->privid = libipw_wiphy_privid;
-
-		ieee->wdev.wiphy->max_scan_ssids = 1;
-		ieee->wdev.wiphy->max_scan_ie_len = 0;
-		ieee->wdev.wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION)
-						| BIT(NL80211_IFTYPE_ADHOC);
-	}
-
 	err = libipw_networks_allocate(ieee);
 	if (err) {
 		LIBIPW_ERROR("Unable to allocate beacon storage: %d\n", err);
-		goto failed_free_wiphy;
+		goto failed_free_netdev;
 	}
 	libipw_networks_initialize(ieee);
 
@@ -217,31 +193,19 @@ struct net_device *alloc_ieee80211(int sizeof_priv, int monitor)
 
 	return dev;
 
-failed_free_wiphy:
-	if (!monitor)
-		wiphy_free(ieee->wdev.wiphy);
 failed_free_netdev:
 	free_netdev(dev);
 failed:
 	return NULL;
 }
 
-void free_ieee80211(struct net_device *dev, int monitor)
+void free_ieee80211(struct net_device *dev)
 {
 	struct libipw_device *ieee = netdev_priv(dev);
 
 	lib80211_crypt_info_free(&ieee->crypt_info);
 
 	libipw_networks_free(ieee);
-
-	/* free cfg80211 resources */
-	if (!monitor) {
-		wiphy_unregister(ieee->wdev.wiphy);
-		kfree(ieee->a_band.channels);
-		kfree(ieee->bg_band.channels);
-		wiphy_free(ieee->wdev.wiphy);
-	}
-
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 17e1995..92af9b9 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -426,12 +426,16 @@ static const char p54u_romboot_3887[] = "~~~~";
 static int p54u_firmware_reset_3887(struct ieee80211_hw *dev)
 {
 	struct p54u_priv *priv = dev->priv;
-	u8 buf[4];
+	u8 *buf;
 	int ret;
 
-	memcpy(&buf, p54u_romboot_3887, sizeof(buf));
+	buf = kmalloc(4, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+	memcpy(buf, p54u_romboot_3887, 4);
 	ret = p54u_bulk_msg(priv, P54U_PIPE_DATA,
-			    buf, sizeof(buf));
+			    buf, 4);
+	kfree(buf);
 	if (ret)
 		dev_err(&priv->udev->dev, "(p54usb) unable to jump to "
 			"boot ROM (%d)!\n", ret);
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
