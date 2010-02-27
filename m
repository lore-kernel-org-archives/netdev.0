From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 7/9] Bluetooth: Add controller types for BR/EDR and 802.11 AMP
Date: Sat, 27 Feb 2010 23:38:36 +0100
Message-ID: <943da25d95c7e8fd8c39dbf09e030f5da46f5d85.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
 <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
 <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
 <c13854cef4751000b968d4e8ac95796562d5b96f.1267276098.git.marcel@holtmann.org>
 <ca325f698996c1a0770a67f41e7dc97a007d8bc2.1267276098.git.marcel@holtmann.org>
 <b914a250e7b390c713b36a9405a39c4c11abad80.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54700 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936368Ab0B0WkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:24 -0500
In-Reply-To: <b914a250e7b390c713b36a9405a39c4c11abad80.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the Bluetooth 3.0 specification and the introduction of alternate
MAC/PHY (AMP) support, it is required to differentiate between primary
BR/EDR controllers and 802.11 AMP controllers. So introduce a special
type inside HCI device for differentiation.

For now all AMP controllers will be treated as raw devices until an
AMP manager has been implemented.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci.h      |    4 ++++
 include/net/bluetooth/hci_core.h |    1 +
 net/bluetooth/hci_core.c         |    6 +++++-
 net/bluetooth/hci_sysfs.c        |   20 ++++++++++++++++++++
 4 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index 3350a66..fc0c502 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -52,6 +52,10 @@
 #define HCI_PCI		5
 #define HCI_SDIO	6
 
+/* HCI controller types */
+#define HCI_BREDR	0x00
+#define HCI_80211	0x01
+
 /* HCI device quirks */
 enum {
 	HCI_QUIRK_NO_RESET,
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 4c94c1e..ce3c99e 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -71,6 +71,7 @@ struct hci_dev {
 	unsigned long	flags;
 	__u16		id;
 	__u8		bus;
+	__u8		dev_type;
 	bdaddr_t	bdaddr;
 	__u8		dev_name[248];
 	__u8		dev_class[3];
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 4b62ed0..4ad2319 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -491,6 +491,10 @@ int hci_dev_open(__u16 dev)
 	if (test_bit(HCI_QUIRK_RAW_DEVICE, &hdev->quirks))
 		set_bit(HCI_RAW, &hdev->flags);
 
+	/* Treat all non BR/EDR controllers as raw devices for now */
+	if (hdev->dev_type != HCI_BREDR)
+		set_bit(HCI_RAW, &hdev->flags);
+
 	if (hdev->open(hdev)) {
 		ret = -EIO;
 		goto done;
@@ -797,7 +801,7 @@ int hci_get_dev_info(void __user *arg)
 
 	strcpy(di.name, hdev->name);
 	di.bdaddr   = hdev->bdaddr;
-	di.type     = hdev->bus;
+	di.type     = (hdev->bus & 0x0f) | (hdev->dev_type << 4);
 	di.flags    = hdev->flags;
 	di.pkt_type = hdev->pkt_type;
 	di.acl_mtu  = hdev->acl_mtu;
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index f9d93f9..1a79a6c 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -192,12 +192,30 @@ static inline char *host_bustostr(int bus)
 	}
 }
 
+static inline char *host_typetostr(int type)
+{
+	switch (type) {
+	case HCI_BREDR:
+		return "BR/EDR";
+	case HCI_80211:
+		return "802.11";
+	default:
+		return "UNKNOWN";
+	}
+}
+
 static ssize_t show_bus(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct hci_dev *hdev = dev_get_drvdata(dev);
 	return sprintf(buf, "%s\n", host_bustostr(hdev->bus));
 }
 
+static ssize_t show_type(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct hci_dev *hdev = dev_get_drvdata(dev);
+	return sprintf(buf, "%s\n", host_typetostr(hdev->dev_type));
+}
+
 static ssize_t show_name(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct hci_dev *hdev = dev_get_drvdata(dev);
@@ -334,6 +352,7 @@ static ssize_t store_sniff_min_interval(struct device *dev, struct device_attrib
 }
 
 static DEVICE_ATTR(bus, S_IRUGO, show_bus, NULL);
+static DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
 static DEVICE_ATTR(name, S_IRUGO, show_name, NULL);
 static DEVICE_ATTR(class, S_IRUGO, show_class, NULL);
 static DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
@@ -351,6 +370,7 @@ static DEVICE_ATTR(sniff_min_interval, S_IRUGO | S_IWUSR,
 
 static struct attribute *bt_host_attrs[] = {
 	&dev_attr_bus.attr,
+	&dev_attr_type.attr,
 	&dev_attr_name.attr,
 	&dev_attr_class.attr,
 	&dev_attr_address.attr,
-- 
1.6.6

