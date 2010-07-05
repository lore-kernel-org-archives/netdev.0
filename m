From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v2 3/9] atm/adummy: add syfs DEVICE_ATTR to change signal
Date: Mon,  5 Jul 2010 10:45:55 +0200
Message-ID: <1278319561-23548-4-git-send-email-karl@hiramoto.org>
References: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:39429 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743Ab0GEIrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 04:47:11 -0400
Received: from homiemail-a30.g.dreamhost.com (caiajhbdcbhh.dreamhost.com [208.97.132.177])
	by hapkido.dreamhost.com (Postfix) with ESMTP id E0293179F1E
	for <netdev@vger.kernel.org>; Mon,  5 Jul 2010 01:47:11 -0700 (PDT)
In-Reply-To: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
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

