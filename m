From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v5 3/9] atm/adummy: add syfs DEVICE_ATTR to change signal
Date: Fri,  9 Jul 2010 08:55:32 +0200
Message-ID: <1278658538-6769-4-git-send-email-karl@hiramoto.org>
References: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcaid.dreamhost.com ([208.97.132.83]:35207 "EHLO
	homiemail-a64.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753673Ab0GIGzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:55:52 -0400
In-Reply-To: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/atm/adummy.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/adummy.c b/drivers/atm/adummy.c
index 6d44f07..46b9476 100644
--- a/drivers/atm/adummy.c
+++ b/drivers/atm/adummy.c
@@ -40,6 +40,42 @@ struct adummy_dev {
 
 static LIST_HEAD(adummy_devs);
 
+static ssize_t __set_signal(struct device *dev,
+		struct device_attribute *attr,
+		const char *buf, size_t len)
+{
+	struct atm_dev *atm_dev = container_of(dev, struct atm_dev, class_dev);
+	int signal;
+
+	if (sscanf(buf, "%d", &signal) == 1) {
+
+		if (signal < ATM_PHY_SIG_LOST || signal > ATM_PHY_SIG_FOUND)
+			signal = ATM_PHY_SIG_UNKNOWN;
+
+		atm_dev_signal_change(atm_dev, signal);
+		return 1;
+	}
+	return -EINVAL;
+}
+
+static ssize_t __show_signal(struct device *dev,
+	struct device_attribute *attr, char *buf)
+{
+	struct atm_dev *atm_dev = container_of(dev, struct atm_dev, class_dev);
+	return sprintf(buf, "%d\n", atm_dev->signal);
+}
+static DEVICE_ATTR(signal, 0644, __show_signal, __set_signal);
+
+static struct attribute *adummy_attrs[] = {
+	&dev_attr_signal.attr,
+	NULL
+};
+
+static struct attribute_group adummy_group_attrs = {
+	.name = NULL, /* We want them in dev's root folder */
+	.attrs = adummy_attrs
+};
+
 static int __init
 adummy_start(struct atm_dev *dev)
 {
@@ -128,6 +164,9 @@ static int __init adummy_init(void)
 	adummy_dev->atm_dev = atm_dev;
 	atm_dev->dev_data = adummy_dev;
 
+	if (sysfs_create_group(&atm_dev->class_dev.kobj, &adummy_group_attrs))
+		dev_err(&atm_dev->class_dev, "Could not register attrs for adummy\n");
+
 	if (adummy_start(atm_dev)) {
 		printk(KERN_ERR DEV_LABEL ": adummy_start() failed\n");
 		err = -ENODEV;
-- 
1.7.1

