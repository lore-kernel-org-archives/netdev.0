From: akpm@osdl.org
Subject: [patch 08/10] bcm43xx: sysfs code cleanup
Date: Tue, 18 Apr 2006 21:04:25 -0700
Message-ID: <200604190405.k3J457Zj008004@shell0.pdx.osdl.net>
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, akpm@osdl.org,
	mb@bu3sch.de, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3276 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750772AbWDSEFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 00:05:47 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Michael Buesch <mb@bu3sch.de>

This cleans up the bcm43xx sysfs code and makes it compliant with the
unwritten sysfs rules (at least I hope so).

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Greg KH <greg@kroah.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/wireless/bcm43xx/bcm43xx.h       |   17 ++
 drivers/net/wireless/bcm43xx/bcm43xx_main.c  |    1 
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c |  115 +++++++++--------
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.h |   16 --
 4 files changed, 82 insertions(+), 67 deletions(-)

diff -puN drivers/net/wireless/bcm43xx/bcm43xx.h~bcm43xx-sysfs-code-cleanup drivers/net/wireless/bcm43xx/bcm43xx.h
--- devel/drivers/net/wireless/bcm43xx/bcm43xx.h~bcm43xx-sysfs-code-cleanup	2006-04-12 18:11:12.000000000 -0700
+++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-04-12 18:11:12.000000000 -0700
@@ -15,7 +15,6 @@
 
 #include "bcm43xx_debugfs.h"
 #include "bcm43xx_leds.h"
-#include "bcm43xx_sysfs.h"
 
 
 #define PFX				KBUILD_MODNAME ": "
@@ -638,8 +637,6 @@ struct bcm43xx_key {
 };
 
 struct bcm43xx_private {
-	struct bcm43xx_sysfs sysfs;
-
 	struct ieee80211_device *ieee;
 	struct ieee80211softmac_device *softmac;
 
@@ -772,6 +769,20 @@ struct bcm43xx_private * bcm43xx_priv(st
 	return ieee80211softmac_priv(dev);
 }
 
+struct device;
+
+static inline
+struct bcm43xx_private * dev_to_bcm(struct device *dev)
+{
+	struct net_device *net_dev;
+	struct bcm43xx_private *bcm;
+
+	net_dev = dev_get_drvdata(dev);
+	bcm = bcm43xx_priv(net_dev);
+
+	return bcm;
+}
+
 
 /* Helper function, which returns a boolean.
  * TRUE, if PIO is used; FALSE, if DMA is used.
diff -puN drivers/net/wireless/bcm43xx/bcm43xx_main.c~bcm43xx-sysfs-code-cleanup drivers/net/wireless/bcm43xx/bcm43xx_main.c
--- devel/drivers/net/wireless/bcm43xx/bcm43xx_main.c~bcm43xx-sysfs-code-cleanup	2006-04-12 18:11:12.000000000 -0700
+++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-04-12 18:11:12.000000000 -0700
@@ -52,6 +52,7 @@
 #include "bcm43xx_wx.h"
 #include "bcm43xx_ethtool.h"
 #include "bcm43xx_xmit.h"
+#include "bcm43xx_sysfs.h"
 
 
 MODULE_DESCRIPTION("Broadcom BCM43xx wireless driver");
diff -puN drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c~bcm43xx-sysfs-code-cleanup drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
--- devel/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c~bcm43xx-sysfs-code-cleanup	2006-04-12 18:11:12.000000000 -0700
+++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-04-12 18:11:12.000000000 -0700
@@ -71,14 +71,46 @@ static int get_boolean(const char *buf, 
 	return -EINVAL;
 }
 
+static int sprom2hex(const u16 *sprom, char *buf, size_t buf_len)
+{
+	int i, pos = 0;
+
+	for (i = 0; i < BCM43xx_SPROM_SIZE; i++) {
+		pos += snprintf(buf + pos, buf_len - pos - 1,
+				"%04X", swab16(sprom[i]) & 0xFFFF);
+	}
+	pos += snprintf(buf + pos, buf_len - pos - 1, "\n");
+
+	return pos + 1;
+}
+
+static int hex2sprom(u16 *sprom, const char *dump, size_t len)
+{
+	char tmp[5] = { 0 };
+	int cnt = 0;
+	unsigned long parsed;
+
+	if (len < BCM43xx_SPROM_SIZE * sizeof(u16) * 2)
+		return -EINVAL;
+
+	while (cnt < BCM43xx_SPROM_SIZE) {
+		memcpy(tmp, dump, 4);
+		dump += 4;
+		parsed = simple_strtoul(tmp, NULL, 16);
+		sprom[cnt++] = swab16((u16)parsed);
+	}
+
+	return 0;
+}
+
 static ssize_t bcm43xx_attr_sprom_show(struct device *dev,
 				       struct device_attribute *attr,
 				       char *buf)
 {
-	struct bcm43xx_private *bcm = devattr_to_bcm(attr, attr_sprom);
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	u16 *sprom;
 	unsigned long flags;
-	int i, err;
+	int err;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -91,55 +123,53 @@ static ssize_t bcm43xx_attr_sprom_show(s
 	bcm43xx_lock_mmio(bcm, flags);
 	assert(bcm->initialized);
 	err = bcm43xx_sprom_read(bcm, sprom);
-	if (!err) {
-		for (i = 0; i < BCM43xx_SPROM_SIZE; i++) {
-			buf[i * 2] = sprom[i] & 0x00FF;
-			buf[i * 2 + 1] = (sprom[i] & 0xFF00) >> 8;
-		}
-	}
+	if (!err)
+		err = sprom2hex(sprom, buf, PAGE_SIZE);
 	bcm43xx_unlock_mmio(bcm, flags);
 	kfree(sprom);
 
-	return err ? err : BCM43xx_SPROM_SIZE * sizeof(u16);
+	return err;
 }
 
 static ssize_t bcm43xx_attr_sprom_store(struct device *dev,
 					struct device_attribute *attr,
 					const char *buf, size_t count)
 {
-	struct bcm43xx_private *bcm = devattr_to_bcm(attr, attr_sprom);
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	u16 *sprom;
 	unsigned long flags;
-	int i, err;
+	int err;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (count != BCM43xx_SPROM_SIZE * sizeof(u16))
-		return -EINVAL;
 	sprom = kmalloc(BCM43xx_SPROM_SIZE * sizeof(*sprom),
 			GFP_KERNEL);
 	if (!sprom)
 		return -ENOMEM;
-	for (i = 0; i < BCM43xx_SPROM_SIZE; i++) {
-		sprom[i] = buf[i * 2] & 0xFF;
-		sprom[i] |= ((u16)(buf[i * 2 + 1] & 0xFF)) << 8;
-	}
+	err = hex2sprom(sprom, buf, count);
+	if (err)
+		goto out_kfree;
 	bcm43xx_lock_mmio(bcm, flags);
 	assert(bcm->initialized);
 	err = bcm43xx_sprom_write(bcm, sprom);
 	bcm43xx_unlock_mmio(bcm, flags);
+out_kfree:
 	kfree(sprom);
 
 	return err ? err : count;
 
 }
 
+static DEVICE_ATTR(sprom, 0600,
+		   bcm43xx_attr_sprom_show,
+		   bcm43xx_attr_sprom_store);
+
 static ssize_t bcm43xx_attr_interfmode_show(struct device *dev,
 					    struct device_attribute *attr,
 					    char *buf)
 {
-	struct bcm43xx_private *bcm = devattr_to_bcm(attr, attr_interfmode);
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	ssize_t count = 0;
@@ -175,7 +205,7 @@ static ssize_t bcm43xx_attr_interfmode_s
 					     struct device_attribute *attr,
 					     const char *buf, size_t count)
 {
-	struct bcm43xx_private *bcm = devattr_to_bcm(attr, attr_interfmode);
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	int mode;
@@ -215,11 +245,15 @@ static ssize_t bcm43xx_attr_interfmode_s
 	return err ? err : count;
 }
 
+static DEVICE_ATTR(interference, 0644,
+		   bcm43xx_attr_interfmode_show,
+		   bcm43xx_attr_interfmode_store);
+
 static ssize_t bcm43xx_attr_preamble_show(struct device *dev,
 					  struct device_attribute *attr,
 					  char *buf)
 {
-	struct bcm43xx_private *bcm = devattr_to_bcm(attr, attr_preamble);
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	ssize_t count;
@@ -245,7 +279,7 @@ static ssize_t bcm43xx_attr_preamble_sto
 					   struct device_attribute *attr,
 					   const char *buf, size_t count)
 {
-	struct bcm43xx_private *bcm = devattr_to_bcm(attr, attr_preamble);
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	int value;
@@ -267,56 +301,41 @@ static ssize_t bcm43xx_attr_preamble_sto
 	return err ? err : count;
 }
 
+static DEVICE_ATTR(shortpreamble, 0644,
+		   bcm43xx_attr_preamble_show,
+		   bcm43xx_attr_preamble_store);
+
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
 {
 	struct device *dev = &bcm->pci_dev->dev;
-	struct bcm43xx_sysfs *sysfs = &bcm->sysfs;
 	int err;
 
 	assert(bcm->initialized);
 
-	sysfs->attr_sprom.attr.name = "sprom";
-	sysfs->attr_sprom.attr.owner = THIS_MODULE;
-	sysfs->attr_sprom.attr.mode = 0600;
-	sysfs->attr_sprom.show = bcm43xx_attr_sprom_show;
-	sysfs->attr_sprom.store = bcm43xx_attr_sprom_store;
-	err = device_create_file(dev, &sysfs->attr_sprom);
+	err = device_create_file(dev, &dev_attr_sprom);
 	if (err)
 		goto out;
-
-	sysfs->attr_interfmode.attr.name = "interference";
-	sysfs->attr_interfmode.attr.owner = THIS_MODULE;
-	sysfs->attr_interfmode.attr.mode = 0600;
-	sysfs->attr_interfmode.show = bcm43xx_attr_interfmode_show;
-	sysfs->attr_interfmode.store = bcm43xx_attr_interfmode_store;
-	err = device_create_file(dev, &sysfs->attr_interfmode);
+	err = device_create_file(dev, &dev_attr_interference);
 	if (err)
 		goto err_remove_sprom;
-
-	sysfs->attr_preamble.attr.name = "shortpreamble";
-	sysfs->attr_preamble.attr.owner = THIS_MODULE;
-	sysfs->attr_preamble.attr.mode = 0600;
-	sysfs->attr_preamble.show = bcm43xx_attr_preamble_show;
-	sysfs->attr_preamble.store = bcm43xx_attr_preamble_store;
-	err = device_create_file(dev, &sysfs->attr_preamble);
+	err = device_create_file(dev, &dev_attr_shortpreamble);
 	if (err)
 		goto err_remove_interfmode;
 
 out:
 	return err;
 err_remove_interfmode:
-	device_remove_file(dev, &sysfs->attr_interfmode);
+	device_remove_file(dev, &dev_attr_interference);
 err_remove_sprom:
-	device_remove_file(dev, &sysfs->attr_sprom);
+	device_remove_file(dev, &dev_attr_sprom);
 	goto out;
 }
 
 void bcm43xx_sysfs_unregister(struct bcm43xx_private *bcm)
 {
 	struct device *dev = &bcm->pci_dev->dev;
-	struct bcm43xx_sysfs *sysfs = &bcm->sysfs;
 
-	device_remove_file(dev, &sysfs->attr_preamble);
-	device_remove_file(dev, &sysfs->attr_interfmode);
-	device_remove_file(dev, &sysfs->attr_sprom);
+	device_remove_file(dev, &dev_attr_shortpreamble);
+	device_remove_file(dev, &dev_attr_interference);
+	device_remove_file(dev, &dev_attr_sprom);
 }
diff -puN drivers/net/wireless/bcm43xx/bcm43xx_sysfs.h~bcm43xx-sysfs-code-cleanup drivers/net/wireless/bcm43xx/bcm43xx_sysfs.h
--- devel/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.h~bcm43xx-sysfs-code-cleanup	2006-04-12 18:11:12.000000000 -0700
+++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.h	2006-04-12 18:11:12.000000000 -0700
@@ -1,22 +1,6 @@
 #ifndef BCM43xx_SYSFS_H_
 #define BCM43xx_SYSFS_H_
 
-#include <linux/device.h>
-
-
-struct bcm43xx_sysfs {
-	struct device_attribute attr_sprom;
-	struct device_attribute attr_interfmode;
-	struct device_attribute attr_preamble;
-};
-
-#define devattr_to_bcm(attr, attr_name)	({				\
-	struct bcm43xx_sysfs *__s; struct bcm43xx_private *__p;		\
-	__s = container_of((attr), struct bcm43xx_sysfs, attr_name);	\
-	__p = container_of(__s, struct bcm43xx_private, sysfs);		\
-	__p;								\
-					})
-
 struct bcm43xx_private;
 
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm);
_
