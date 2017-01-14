From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 05/10] drivers: base: Add device_find_class()
Date: Sat, 14 Jan 2017 13:47:08 -0800
Message-ID: <20170114214713.28109-6-f.fainelli@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM
        SUB-ARCHITECTURES), linux-kernel@vger.kernel.org (open list),
        gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34291 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752222AbdANVre (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 16:47:34 -0500
In-Reply-To: <20170114214713.28109-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper function to lookup a device reference given a class name.
This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
make it more generic.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/base/core.c    | 19 +++++++++++++++++++
 include/linux/device.h |  1 +
 2 files changed, 20 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 020ea7f05520..3dd6047c10d8 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -2065,6 +2065,25 @@ struct device *device_find_child(struct device *parent, void *data,
 }
 EXPORT_SYMBOL_GPL(device_find_child);
 
+static int dev_is_class(struct device *dev, void *class)
+{
+	if (dev->class != NULL && !strcmp(dev->class->name, class))
+		return 1;
+
+	return 0;
+}
+
+struct device *device_find_class(struct device *parent, char *class)
+{
+	if (dev_is_class(parent, class)) {
+		get_device(parent);
+		return parent;
+	}
+
+	return device_find_child(parent, class, dev_is_class);
+}
+EXPORT_SYMBOL_GPL(device_find_class);
+
 int __init devices_init(void)
 {
 	devices_kset = kset_create_and_add("devices", &device_uevent_ops, NULL);
diff --git a/include/linux/device.h b/include/linux/device.h
index 491b4c0ca633..8d37f5ecb972 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1120,6 +1120,7 @@ extern int device_for_each_child_reverse(struct device *dev, void *data,
 		     int (*fn)(struct device *dev, void *data));
 extern struct device *device_find_child(struct device *dev, void *data,
 				int (*match)(struct device *dev, void *data));
+extern struct device *device_find_class(struct device *parent, char *class);
 extern int device_rename(struct device *dev, const char *new_name);
 extern int device_move(struct device *dev, struct device *new_parent,
 		       enum dpm_order dpm_order);
-- 
2.9.3
