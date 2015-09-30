From: <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
Subject: [PATCH] Bluetooth: hci_smd: Qualcomm WCNSS HCI driver
Date: Wed, 30 Sep 2015 16:03:00 -0700
Message-ID: <1443654180-29416-1-git-send-email-bjorn.andersson@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fengwei Yin <fengwei.yin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>

The Qualcomm WCNSS chip provides two SMD channels to the BT core; one
for command and one for event packets. This driver exposes the two
channels as a hci device.

Signed-off-by: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
---
 drivers/bluetooth/Kconfig   |  11 +++
 drivers/bluetooth/Makefile  |   1 +
 drivers/bluetooth/hci_smd.c | 222 ++++++++++++++++++++++++++++++++++++++++++++
 include/net/bluetooth/hci.h |   1 +
 4 files changed, 235 insertions(+)
 create mode 100644 drivers/bluetooth/hci_smd.c

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index 3d480d8c6111..1a2658f373b5 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -62,6 +62,17 @@ config BT_HCIBTSDIO
 	  Say Y here to compile support for Bluetooth SDIO devices into the
 	  kernel or say M to compile it as module (btsdio).
 
+config BT_HCISMD
+	tristate "HCI Qualcomm SMD driver"
+	depends on QCOM_SMD
+	help
+	  Qualcomm SMD HCI driver.
+	  This driver is used to bridge HCI data onto the shared memory
+	  channels to the WCNSS core.
+
+	  Say Y here to compile support for HCI over Qualcomm SMD into the
+	  kernelor say M to compile as a module.
+
 config BT_HCIUART
 	tristate "HCI UART driver"
 	depends on TTY
diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
index 07c9cf381e5a..43c7dc8641ff 100644
--- a/drivers/bluetooth/Makefile
+++ b/drivers/bluetooth/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_BT_HCIBTUART)	+= btuart_cs.o
 
 obj-$(CONFIG_BT_HCIBTUSB)	+= btusb.o
 obj-$(CONFIG_BT_HCIBTSDIO)	+= btsdio.o
+obj-$(CONFIG_BT_HCISMD)		+= hci_smd.o
 
 obj-$(CONFIG_BT_INTEL)		+= btintel.o
 obj-$(CONFIG_BT_ATH3K)		+= ath3k.o
diff --git a/drivers/bluetooth/hci_smd.c b/drivers/bluetooth/hci_smd.c
new file mode 100644
index 000000000000..e5748da2f902
--- /dev/null
+++ b/drivers/bluetooth/hci_smd.c
@@ -0,0 +1,222 @@
+/*
+ * Copyright (c) 2015, Sony Mobile Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/soc/qcom/smd.h>
+#include <net/bluetooth/bluetooth.h>
+#include <net/bluetooth/hci_core.h>
+#include <net/bluetooth/hci.h>
+
+static struct {
+	struct qcom_smd_channel *acl_channel;
+	struct qcom_smd_channel *cmd_channel;
+
+	struct hci_dev *hci;
+} smd_hci;
+
+static int smd_hci_recv(unsigned type, const void *data, size_t count)
+{
+	struct sk_buff *skb;
+	void *buf;
+	int ret;
+
+	skb = bt_skb_alloc(count, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	buf = skb_put(skb, count);
+	memcpy_fromio(buf, data, count);
+
+	skb->dev = (void *)smd_hci.hci;
+	bt_cb(skb)->pkt_type = type;
+	skb_orphan(skb);
+
+	ret = hci_recv_frame(smd_hci.hci, skb);
+	if (ret < 0)
+		kfree_skb(skb);
+
+	return ret;
+}
+
+static int smd_hci_acl_callback(struct qcom_smd_device *qsdev,
+				const void *data,
+				size_t count)
+{
+	return smd_hci_recv(HCI_ACLDATA_PKT, data, count);
+}
+
+static int smd_hci_cmd_callback(struct qcom_smd_device *qsdev,
+				const void *data,
+				size_t count)
+{
+	return smd_hci_recv(HCI_EVENT_PKT, data, count);
+}
+
+static int smd_hci_send(struct hci_dev *hdev, struct sk_buff *skb)
+{
+	int ret;
+
+	switch (bt_cb(skb)->pkt_type) {
+	case HCI_ACLDATA_PKT:
+	case HCI_SCODATA_PKT:
+		ret = qcom_smd_send(smd_hci.acl_channel, skb->data, skb->len);
+		break;
+	case HCI_COMMAND_PKT:
+		ret = qcom_smd_send(smd_hci.cmd_channel, skb->data, skb->len);
+		break;
+	default:
+		ret = -ENODEV;
+		break;
+	}
+
+	kfree_skb(skb);
+
+	return ret;
+}
+
+static int smd_hci_open(struct hci_dev *hci)
+{
+	return 0;
+}
+
+static int smd_hci_close(struct hci_dev *hci)
+{
+	return 0;
+}
+
+static int smd_hci_set_bdaddr(struct hci_dev *hci,
+			      const bdaddr_t *bdaddr)
+{
+	u8 buf[12];
+
+	buf[0] = 0x0b;
+	buf[1] = 0xfc;
+	buf[2] = 0x9;
+	buf[3] = 0x1;
+	buf[4] = 0x2;
+	buf[5] = sizeof(bdaddr_t);
+	memcpy(buf + 6, bdaddr, sizeof(bdaddr_t));
+
+	return qcom_smd_send(smd_hci.cmd_channel, buf, sizeof(buf));
+}
+
+static int smd_hci_register(void)
+{
+	struct hci_dev *hci;
+	int ret;
+
+	if (smd_hci.hci)
+		return 0;
+
+	/* Wait for both channels to probe before registering */
+	if (!smd_hci.acl_channel || !smd_hci.cmd_channel)
+		return 0;
+
+	hci = hci_alloc_dev();
+	if (!hci)
+		return -ENOMEM;
+
+	hci->bus = HCI_SMD;
+	hci->open = smd_hci_open;
+	hci->close = smd_hci_close;
+	hci->send = smd_hci_send;
+	hci->set_bdaddr = smd_hci_set_bdaddr;
+
+	ret = hci_register_dev(hci);
+	if (ret < 0) {
+		hci_free_dev(hci);
+		return ret;
+	}
+
+	smd_hci.hci = hci;
+
+	return 0;
+}
+
+static void smd_hci_unregister(void)
+{
+	/* Only unregister on the first remove call */
+	if (!smd_hci.hci)
+		return;
+
+	hci_unregister_dev(smd_hci.hci);
+	hci_free_dev(smd_hci.hci);
+	smd_hci.hci = NULL;
+}
+
+static int smd_hci_acl_probe(struct qcom_smd_device *sdev)
+{
+	smd_hci.acl_channel = sdev->channel;
+	smd_hci_register();
+
+	return 0;
+}
+
+static int smd_hci_cmd_probe(struct qcom_smd_device *sdev)
+{
+	smd_hci.cmd_channel = sdev->channel;
+	smd_hci_register();
+
+	return 0;
+}
+
+static void smd_hci_acl_remove(struct qcom_smd_device *sdev)
+{
+	smd_hci.acl_channel = NULL;
+	smd_hci_unregister();
+}
+
+static void smd_hci_cmd_remove(struct qcom_smd_device *sdev)
+{
+	smd_hci.cmd_channel = NULL;
+	smd_hci_unregister();
+}
+
+static const struct qcom_smd_id smd_hci_acl_match[] = {
+	{ .name = "APPS_RIVA_BT_ACL" },
+	{}
+};
+
+static const struct qcom_smd_id smd_hci_cmd_match[] = {
+	{ .name = "APPS_RIVA_BT_CMD" },
+	{}
+};
+
+static struct qcom_smd_driver smd_hci_acl_driver = {
+	.probe = smd_hci_acl_probe,
+	.remove = smd_hci_acl_remove,
+	.callback = smd_hci_acl_callback,
+	.smd_match_table = smd_hci_acl_match,
+	.driver  = {
+		.name  = "qcom_smd_hci_acl",
+		.owner = THIS_MODULE,
+	},
+};
+
+static struct qcom_smd_driver smd_hci_cmd_driver = {
+	.probe = smd_hci_cmd_probe,
+	.remove = smd_hci_cmd_remove,
+	.callback = smd_hci_cmd_callback,
+	.smd_match_table = smd_hci_cmd_match,
+	.driver  = {
+		.name  = "qcom_smd_hci_cmd",
+		.owner = THIS_MODULE,
+	},
+};
+
+module_qcom_smd_driver(smd_hci_acl_driver);
+module_qcom_smd_driver(smd_hci_cmd_driver);
+
+MODULE_DESCRIPTION("Qualcomm SMD HCI driver");
+MODULE_LICENSE("GPL v2");
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index 7ca6690355ea..ee5b2dd922f6 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -58,6 +58,7 @@
 #define HCI_RS232	4
 #define HCI_PCI		5
 #define HCI_SDIO	6
+#define HCI_SMD		7
 
 /* HCI controller types */
 #define HCI_BREDR	0x00
-- 
2.4.2
