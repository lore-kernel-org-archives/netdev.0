From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] ucode debug status via sysfs for wireless-2.6
Date: Wed, 06 Sep 2006 20:34:34 -0500
Message-ID: <44FF772A.5000301@lwfinger.net>
References: <20060904205340.GB3726@tuba> <200609042256.54629.mb@bu3sch.de> <20060905181232.GA4733@tuba>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030905060807020708050404"
Cc: Martin Langer <martin-langer@gmx.de>,
	Michael Buesch <mb@bu3sch.de>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:64910 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S965289AbWIGBel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 21:34:41 -0400
To: John Linville <linville@tuxdriver.com>
In-Reply-To: <20060905181232.GA4733@tuba>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030905060807020708050404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

John,

Please apply this patch by Martin Langer to wireless-2.6. It must follow the patch to "Add firmware 
version printout to wireless-2.6 (bcm43xx-softmac)". As originally submitted, the patch was 
appropriate for an obsolete version of bcm43xx-softmac, but I have updated and tested.

Thanks,

Larry

This patch prints out the ucode debug status to sysfs. So, users can
watch the microcode status of their hardware.

Signed-off-by: Martin Langer <martin-langer@gmx.de>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

=========================================

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 62fd7e2..7c2163e 100644
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -311,6 +311,7 @@
  #define BCM43xx_UCODE_PATCHLEVEL        0x0002
  #define BCM43xx_UCODE_DATE              0x0004
  #define BCM43xx_UCODE_TIME              0x0006
+#define BCM43xx_UCODE_STATUS            0x0040

  /* MicrocodeFlagsBitfield (addr + lo-word values?)*/
  #define BCM43xx_UCODEFLAGS_OFFSET	0x005E
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -373,6 +373,56 @@ static DEVICE_ATTR(phymode, 0644,
  		   bcm43xx_attr_phymode_show,
  		   bcm43xx_attr_phymode_store);

+static ssize_t bcm43xx_attr_microcode_show(struct device *dev,
+					   struct device_attribute *attr,
+					   char *buf)
+{
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
+	ssize_t count = 0;
+	u16 status;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	mutex_lock(&(bcm)->mutex);
+	status = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODE_STATUS);
+
+	switch (status) {
+	case 0x0000:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (invalid)\n",
+				 status);
+		break;
+	case 0x0001:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (init)\n",
+				 status);
+		break;
+	case 0x0002:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (active)\n",
+				 status);
+		break;
+	case 0x0003:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (suspended)\n",
+				 status);
+		break;
+	case 0x0004:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (asleep)\n",
+				 status);
+		break;
+	default:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (unknown)\n",
+				 status);
+		break;
+	}
+	mutex_unlock(&(bcm)->mutex);
+
+	return count;
+}
+
+static DEVICE_ATTR(microcodestatus, 0444,
+		   bcm43xx_attr_microcode_show,
+		   NULL);
+
  int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
  {
  	struct device *dev = &bcm->pci_dev->dev;
@@ -392,9 +442,14 @@ int bcm43xx_sysfs_register(struct bcm43x
  	err = device_create_file(dev, &dev_attr_phymode);
  	if (err)
  		goto err_remove_shortpreamble;
+	err = device_create_file(dev, &dev_attr_microcodestatus);
+	if (err)
+		goto err_remove_phymode;

  out:
  	return err;
+err_remove_phymode:
+	device_remove_file(dev, &dev_attr_phymode);
  err_remove_shortpreamble:
  	device_remove_file(dev, &dev_attr_shortpreamble);
  err_remove_interfmode:
@@ -408,6 +463,7 @@ void bcm43xx_sysfs_unregister(struct bcm
  {
  	struct device *dev = &bcm->pci_dev->dev;

+	device_remove_file(dev, &dev_attr_microcodestatus);
  	device_remove_file(dev, &dev_attr_phymode);
  	device_remove_file(dev, &dev_attr_shortpreamble);
  	device_remove_file(dev, &dev_attr_interference);



===========

--------------030905060807020708050404
Content-Type: text/plain;
 name="patch_ucode_debug"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_ucode_debug"

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 62fd7e2..7c2163e 100644
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -311,6 +311,7 @@
 #define BCM43xx_UCODE_PATCHLEVEL        0x0002
 #define BCM43xx_UCODE_DATE              0x0004
 #define BCM43xx_UCODE_TIME              0x0006
+#define BCM43xx_UCODE_STATUS            0x0040
 
 /* MicrocodeFlagsBitfield (addr + lo-word values?)*/
 #define BCM43xx_UCODEFLAGS_OFFSET	0x005E
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -373,6 +373,56 @@ static DEVICE_ATTR(phymode, 0644,
 		   bcm43xx_attr_phymode_show,
 		   bcm43xx_attr_phymode_store);
 
+static ssize_t bcm43xx_attr_microcode_show(struct device *dev,
+					   struct device_attribute *attr,
+					   char *buf)
+{
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
+	ssize_t count = 0;
+	u16 status;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	mutex_lock(&(bcm)->mutex);
+	status = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODE_STATUS);
+
+	switch (status) {
+	case 0x0000:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (invalid)\n",
+				 status);
+		break;
+	case 0x0001:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (init)\n",
+				 status);
+		break;
+	case 0x0002:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (active)\n",
+				 status);
+		break;
+	case 0x0003:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (suspended)\n",
+				 status);
+		break;
+	case 0x0004:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (asleep)\n",
+				 status);
+		break;
+	default:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (unknown)\n",
+				 status);
+		break;
+	}
+	mutex_unlock(&(bcm)->mutex);
+
+	return count;
+}
+
+static DEVICE_ATTR(microcodestatus, 0444,
+		   bcm43xx_attr_microcode_show,
+		   NULL);
+
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
 {
 	struct device *dev = &bcm->pci_dev->dev;
@@ -392,9 +442,14 @@ int bcm43xx_sysfs_register(struct bcm43x
 	err = device_create_file(dev, &dev_attr_phymode);
 	if (err)
 		goto err_remove_shortpreamble;
+	err = device_create_file(dev, &dev_attr_microcodestatus);
+	if (err)
+		goto err_remove_phymode;
 
 out:
 	return err;
+err_remove_phymode:
+	device_remove_file(dev, &dev_attr_phymode);
 err_remove_shortpreamble:
 	device_remove_file(dev, &dev_attr_shortpreamble);
 err_remove_interfmode:
@@ -408,6 +463,7 @@ void bcm43xx_sysfs_unregister(struct bcm
 {
 	struct device *dev = &bcm->pci_dev->dev;
 
+	device_remove_file(dev, &dev_attr_microcodestatus);
 	device_remove_file(dev, &dev_attr_phymode);
 	device_remove_file(dev, &dev_attr_shortpreamble);
 	device_remove_file(dev, &dev_attr_interference);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3141,7 +3141,7 @@ static void do_periodic_work(struct bcm4
 		bcm43xx_periodic_every15sec(bcm);
 	bcm->periodic_state = state + 1;
 
-	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
+	schedule_delayed_work(&bcm->periodic_work, HZ * 3);
 }
 
 /* Estimate a "Badness" value based on the periodic work


--------------030905060807020708050404--
