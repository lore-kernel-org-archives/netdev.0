From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] Convert network devices to use struct device instead of
 class_device
Date: Wed, 14 Feb 2007 00:40:00 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0702140036350.855@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:11907 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134AbXBNGoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 01:44:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert network devices to use struct device instead of class_device.  Greg
missed this one in his cleanup path.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

---

Jeff,

Sorry my mailer was completely screwed.  I thought I had fixed the
settings to turn of flowed text.  I think this was why the patches I've
been sending haven't been applying.  You can also get this fix from the
following git tree:

master.kernel.org/pub/scm/linux/kernel/git/galak/powerpc.git gfar

Please apply since this is causing compile errors

- k

commit 4409d28140d9a6e6e3f4f1fdaf7234c4b965d954
tree b12acbebc292de5146c89ba274eea38237ec7f91
parent ec2f9d1331f658433411c58077871e1eef4ee1b4
author Kumar Gala <galak@kernel.crashing.org> Mon, 12 Feb 2007 23:40:06 -0600
committer Kumar Gala <galak@kernel.crashing.org> Mon, 12 Feb 2007 23:40:06 -0600

 drivers/net/gianfar_sysfs.c |  108 ++++++++++++++++++++++---------------------
 1 files changed, 55 insertions(+), 53 deletions(-)

diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 9dd387f..6e2166a 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -39,13 +39,15 @@
 #include "gianfar.h"

 #define GFAR_ATTR(_name) \
-static ssize_t gfar_show_##_name(struct class_device *cdev, char *buf); \
-static ssize_t gfar_set_##_name(struct class_device *cdev, \
+static ssize_t gfar_show_##_name(struct device *dev, \
+	 struct device_attribute *attr, char *buf); \
+static ssize_t gfar_set_##_name(struct device *dev, \
+		struct device_attribute *attr, \
 		const char *buf, size_t count); \
-static CLASS_DEVICE_ATTR(_name, 0644, gfar_show_##_name, gfar_set_##_name)
+static DEVICE_ATTR(_name, 0644, gfar_show_##_name, gfar_set_##_name)

 #define GFAR_CREATE_FILE(_dev, _name) \
-	class_device_create_file(&_dev->class_dev, &class_device_attr_##_name)
+	device_create_file(&_dev->dev, &dev_attr_##_name)

 GFAR_ATTR(bd_stash);
 GFAR_ATTR(rx_stash_size);
@@ -54,29 +56,28 @@ GFAR_ATTR(fifo_threshold);
 GFAR_ATTR(fifo_starve);
 GFAR_ATTR(fifo_starve_off);

-#define to_net_dev(cd) container_of(cd, struct net_device, class_dev)
-
-static ssize_t gfar_show_bd_stash(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_bd_stash(struct device *dev,
+				  struct device_attribute *attr, char *buf)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

-	return sprintf(buf, "%s\n", priv->bd_stash_en? "on" : "off");
+	return sprintf(buf, "%s\n", priv->bd_stash_en ? "on" : "off");
 }

-static ssize_t gfar_set_bd_stash(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_bd_stash(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	int new_setting = 0;
 	u32 temp;
 	unsigned long flags;

 	/* Find out the new setting */
-	if (!strncmp("on", buf, count-1) || !strncmp("1", buf, count-1))
+	if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
 		new_setting = 1;
-	else if (!strncmp("off", buf, count-1) || !strncmp("0", buf, count-1))
+	else if (!strncmp("off", buf, count - 1)
+		 || !strncmp("0", buf, count - 1))
 		new_setting = 0;
 	else
 		return count;
@@ -100,19 +101,19 @@ static ssize_t gfar_set_bd_stash(struct class_device *cdev,
 	return count;
 }

-static ssize_t gfar_show_rx_stash_size(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_rx_stash_size(struct device *dev,
+				       struct device_attribute *attr, char *buf)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

 	return sprintf(buf, "%d\n", priv->rx_stash_size);
 }

-static ssize_t gfar_set_rx_stash_size(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_rx_stash_size(struct device *dev,
+				      struct device_attribute *attr,
+				      const char *buf, size_t count)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	unsigned int length = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -146,21 +147,21 @@ static ssize_t gfar_set_rx_stash_size(struct class_device *cdev,
 	return count;
 }

-
 /* Stashing will only be enabled when rx_stash_size != 0 */
-static ssize_t gfar_show_rx_stash_index(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_rx_stash_index(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

 	return sprintf(buf, "%d\n", priv->rx_stash_index);
 }

-static ssize_t gfar_set_rx_stash_index(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_rx_stash_index(struct device *dev,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	unsigned short index = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -184,19 +185,20 @@ static ssize_t gfar_set_rx_stash_index(struct class_device *cdev,
 	return count;
 }

-static ssize_t gfar_show_fifo_threshold(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_fifo_threshold(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

 	return sprintf(buf, "%d\n", priv->fifo_threshold);
 }

-static ssize_t gfar_set_fifo_threshold(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_fifo_threshold(struct device *dev,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	unsigned int length = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -218,20 +220,19 @@ static ssize_t gfar_set_fifo_threshold(struct class_device *cdev,
 	return count;
 }

-static ssize_t gfar_show_fifo_starve(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_fifo_starve(struct device *dev,
+				     struct device_attribute *attr, char *buf)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

 	return sprintf(buf, "%d\n", priv->fifo_starve);
 }

-
-static ssize_t gfar_set_fifo_starve(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_fifo_starve(struct device *dev,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	unsigned int num = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -253,19 +254,20 @@ static ssize_t gfar_set_fifo_starve(struct class_device *cdev,
 	return count;
 }

-static ssize_t gfar_show_fifo_starve_off(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_fifo_starve_off(struct device *dev,
+					 struct device_attribute *attr,
+					 char *buf)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

 	return sprintf(buf, "%d\n", priv->fifo_starve_off);
 }

-static ssize_t gfar_set_fifo_starve_off(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_fifo_starve_off(struct device *dev,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
 {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	unsigned int num = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
