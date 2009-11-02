From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [PATCH net-next] iwmc3200bt: Add iwmc3200 bluetooth driver
Date: Tue,  3 Nov 2009 01:36:30 +0200
Message-ID: <1257204990-18669-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: guy.cohen@intel.com, ron.rindjunsky@intel.com,
	Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, marcel@holtmann.org, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-mmc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40411 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757208AbZKBXgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 18:36:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Intel Wireless MultiCom 3200 SDIO BT driver
IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
wmc3200bt is derived from btsdio driver

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/bluetooth/Kconfig      |   16 ++
 drivers/bluetooth/Makefile     |    2 +
 drivers/bluetooth/iwmc3200bt.c |  553 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 571 insertions(+), 0 deletions(-)
 create mode 100644 drivers/bluetooth/iwmc3200bt.c

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index 652367a..e520889 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -195,5 +195,21 @@ config BT_MRVL_SDIO
 	  Say Y here to compile support for Marvell BT-over-SDIO driver
 	  into the kernel or say M to compile it as module.
 
+config BT_IWMC3200
+        tristate "Intel Wireless MultiCom 3200 SDIO BT driver"
+        depends on IWMC3200TOP && EXPERIMENTAL
+        help
+          Intel Wireless MultiCom 3200 SDIO Bluetooth driver
+
+	  Say Y here to compile support for IWMC3200 SDIO BT driver
+	  into the kernel or say M to compile it as module.
+
+config BT_IWMC3200_DEBUG
+        bool "Enable verbose debugging for iwmc3200bt"
+        depends on BT_IWMC3200
+        help
+	  Say Y here to enable IWMC3200 SDIO BT driver
+	  verbose debugging
+
 endmenu
 
diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
index b3f57d2..975036e 100644
--- a/drivers/bluetooth/Makefile
+++ b/drivers/bluetooth/Makefile
@@ -21,6 +21,8 @@ obj-$(CONFIG_BT_MRVL_SDIO)	+= btmrvl_sdio.o
 btmrvl-y			:= btmrvl_main.o
 btmrvl-$(CONFIG_DEBUG_FS)	+= btmrvl_debugfs.o
 
+obj-$(CONFIG_BT_IWMC3200)	+= iwmc3200bt.o
+
 hci_uart-y				:= hci_ldisc.o
 hci_uart-$(CONFIG_BT_HCIUART_H4)	+= hci_h4.o
 hci_uart-$(CONFIG_BT_HCIUART_BCSP)	+= hci_bcsp.o
diff --git a/drivers/bluetooth/iwmc3200bt.c b/drivers/bluetooth/iwmc3200bt.c
new file mode 100644
index 0000000..5aed7a3
--- /dev/null
+++ b/drivers/bluetooth/iwmc3200bt.c
@@ -0,0 +1,553 @@
+/*
+ *  ibtsdio - Intel Wireless MultiCom 3200 Bluetooth SDIO Driver
+ *  drivers/bluetooth/ibtsdio.c
+ *
+ *  Copyright (C) 2009 Intel Corporation. All rights reserved.
+ *
+ *  Based on  drivers/bluetooth/btsdio.c
+ *  Copyright (C) 2007  Cambridge Silicon Radio Ltd.
+ *  Copyright (C) 2007  Marcel Holtmann <marcel@holtmann.org>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/sched.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+
+#include <linux/mmc/sdio_ids.h>
+#include <linux/mmc/sdio_func.h>
+
+#include <net/bluetooth/bluetooth.h>
+#include <net/bluetooth/hci_core.h>
+
+
+#ifdef CONFIG_BT_IWMC3200_DEBUG
+#define IBT_DBG(func, fmt, arg...) \
+	dev_dbg(&((func)->dev), "%s: " fmt "\n" , __func__ , ## arg)
+#define IBT_ERR(func, fmt, arg...) \
+	dev_err(&((func)->dev), "%s: " fmt "\n" , __func__ , ## arg)
+#define IBT_DUMP(func, buf, size) do {					\
+	char prefix_str[30 + 1];					\
+	scnprintf(prefix_str, 30, "%s %s",				\
+		dev_driver_string(&((func)->dev)),			\
+		dev_name(&((func)->dev)));				\
+	print_hex_dump(KERN_DEBUG, prefix_str, DUMP_PREFIX_OFFSET,	\
+			16, 1, buf, size, false);			\
+} while (0)
+
+#define VD "-d"
+#else
+#define IBT_DBG(func, fmt, arg...)
+#define IBT_ERR(func, fmt, arg...)
+#define IBT_DUMP(func, buf, size)
+#define VD
+#endif /* CONFIG_BT_IWMC3200_DEBUG */
+
+#ifdef REPOSITORY_LABEL
+#define RL REPOSITORY_LABEL
+#else
+#define RL local
+#endif
+
+
+#define IWMCBT_VERSION "0.1.6"
+
+#define DRIVER_VERSION IWMCBT_VERSION "-"  __stringify(RL) VD
+
+
+#define IWMC_BT_SDIO_DEVID (0x1406)
+
+static const struct sdio_device_id btsdio_table[] = {
+	/* IWMC3200BT (0x1406) */
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL, 0x1406)},
+	{ }	/* Terminating entry */
+};
+
+MODULE_DEVICE_TABLE(sdio, btsdio_table);
+
+struct btsdio_data {
+	struct hci_dev   *hdev;
+	struct sdio_func *func;
+
+	struct work_struct work;
+
+	struct sk_buff_head txq;
+	unsigned char tx_buf[2048];
+	unsigned char rx_buf[2048];
+};
+
+#define REG_RDAT     0x00	/* Receiver Data */
+#define REG_TDAT     0x00	/* Transmitter Data */
+#define REG_PC_RRT   0x10	/* Read Packet Control */
+#define REG_PC_WRT   0x11	/* Write Packet Control */
+#define REG_RTC_STAT 0x12	/* Retry Control Status */
+#define REG_RTC_SET  0x12	/* Retry Control Set */
+#define REG_INTRD    0x13	/* Interrupt Indication */
+#define REG_CL_INTRD 0x13	/* Interrupt Clear */
+#define REG_EN_INTRD 0x14	/* Interrupt Enable */
+#define REG_MD_STAT  0x20	/* Bluetooth Mode Status */
+#define REG_H2D_COUNT_L  0x2C
+#define REG_H2D_COUNT_H  0x2D
+
+#ifdef CONFIG_BT_IWMC3200_DEBUG
+static char *type_names[] = {
+	"Illegal",
+	"HCI_COMMAND_PKT",
+	"HCI_ACLDATA_PKT",
+	"HCI_SCODATA_PKT",
+	"HCI_EVENT_PKT"
+};
+#endif /* CONFIG_BT_IWMC3200_DEBUG  */
+
+
+static int btsdio_tx_packet(struct btsdio_data *data, struct sk_buff *skb)
+{
+	int err;
+	int hdr_sz = 7, pkt_sz = 0;
+
+	IBT_DBG(data->func, "%s", data->hdev->name);
+	memset(data->tx_buf, 0, 2048);
+
+	/* Prepend Type-A header */
+	skb_push(skb, 4);
+	skb->data[0] = (skb->len & 0x0000ff);
+	skb->data[1] = (skb->len & 0x00ff00) >> 8;
+	skb->data[2] = (skb->len & 0xff0000) >> 16;
+	skb->data[3] = bt_cb(skb)->pkt_type;
+
+	hdr_sz = 4 + 3; /* (4) btsdio header  + (3) hci cmd hdr */
+	memcpy(data->tx_buf, skb->data, hdr_sz);
+
+	IBT_DBG(data->func, "requested to send packet of type %s\n",
+		type_names[data->tx_buf[3]]);
+	if (bt_cb(skb)->pkt_type == HCI_ACLDATA_PKT) {
+		data->tx_buf[7] = skb->data[7];
+		hdr_sz++;
+	}
+	memcpy(data->tx_buf + 8, skb->data + hdr_sz, skb->len - hdr_sz);
+	pkt_sz = ALIGN(skb->len, 256);
+	IBT_DBG(data->func, "padded size to send %d bytes\n", pkt_sz);
+	IBT_DUMP(data->func, data->tx_buf, pkt_sz);
+
+	err = sdio_writesb(data->func, REG_TDAT, data->tx_buf, pkt_sz);
+	if (err < 0) {
+		IBT_ERR(data->func, "sdio_writesb exited with error %d\n", err);
+		skb_pull(skb, 4);
+		sdio_writeb(data->func, 0x01, REG_PC_WRT, NULL);
+		return err;
+	}
+	IBT_DBG(data->func, "sdio_writesb exited with success %d\n", err);
+	data->hdev->stat.byte_tx += skb->len;
+	kfree_skb(skb);
+
+	return 0;
+}
+
+static void btsdio_work(struct work_struct *work)
+{
+	struct btsdio_data *data = container_of(work, struct btsdio_data, work);
+	struct sk_buff *skb;
+	int err;
+
+	IBT_DBG(data->func, "%s", data->hdev->name);
+
+	sdio_claim_host(data->func);
+
+	while ((skb = skb_dequeue(&data->txq))) {
+		err = btsdio_tx_packet(data, skb);
+		if (err < 0) {
+			data->hdev->stat.err_tx++;
+			skb_queue_head(&data->txq, skb);
+			break;
+		}
+	}
+
+	sdio_release_host(data->func);
+}
+
+static int btsdio_rx_packet(struct btsdio_data *data, int padded_len)
+{
+	struct sk_buff *skb;
+	int err, len, hdr_sz;
+
+	IBT_DBG(data->func, "%s", data->hdev->name);
+
+	memset(data->rx_buf, 0, 2048);
+	err = sdio_readsb(data->func, data->rx_buf,
+			  REG_RDAT, padded_len);
+	if (err < 0) {
+		IBT_ERR(data->func, "%s with error %d\n", __func__, err);
+		return err;
+	}
+	IBT_DUMP(data->func, data->rx_buf, padded_len);
+
+	len = data->rx_buf[0] | (data->rx_buf[1] << 8) | (data->rx_buf[2] << 16);
+	len -= 4;
+	skb = bt_skb_alloc(len, GFP_KERNEL);
+	/* Out of memory. Prepare a read retry and just
+	 * return with the expectation that the next time
+	 * we're called we'll have more memory. */
+	if (!skb)
+		return -ENOMEM;
+
+	if (data->rx_buf[3] == HCI_EVENT_PKT)
+		hdr_sz = HCI_EVENT_HDR_SIZE;
+	else if (data->rx_buf[3] == HCI_SCODATA_PKT)
+		hdr_sz = HCI_SCO_HDR_SIZE;
+	else if (data->rx_buf[3] == HCI_ACLDATA_PKT)
+		hdr_sz = HCI_ACL_HDR_SIZE;
+	else {
+		IBT_ERR(data->func, "Wrong packet type %d \n", data->rx_buf[3]);
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+	IBT_DBG(data->func, "copying hci header of %d bytes\n", hdr_sz);
+	memcpy(skb_put(skb, hdr_sz), data->rx_buf + 4, hdr_sz);
+	IBT_DUMP(data->func, skb->data, skb->len);
+	len -= hdr_sz;
+	IBT_DBG(data->func, "copying payload of %d bytes\n", len);
+	memcpy(skb_put(skb, len), data->rx_buf + 4 + 4, len);
+	data->hdev->stat.byte_rx += len + hdr_sz;
+	IBT_DBG(data->func, "Data before hci_recv_frame\n");
+	IBT_DUMP(data->func, skb->data, skb->len);
+	skb->dev = (void *)data->hdev;
+	bt_cb(skb)->pkt_type = data->rx_buf[3];
+	err = hci_recv_frame(skb);
+	if (err < 0) {
+		IBT_ERR(data->func,
+			"hci_recv_frame exited with error %d\n", err);
+		return err;
+	}
+	IBT_DBG(data->func, "hci_recv_frame exited with success %d\n", err);
+	sdio_writeb(data->func, 0x00, REG_PC_RRT, NULL);
+	return 0;
+}
+
+static void btsdio_interrupt(struct sdio_func *func)
+{
+	struct btsdio_data *data = sdio_get_drvdata(func);
+	int intrd, err;
+	int padded_len = 0;
+	unsigned int val1, val2;
+
+	IBT_DBG(data->func, "%s", data->hdev->name);
+
+	intrd = sdio_readb(func, REG_INTRD, NULL);
+	if (intrd & 0x01) {
+		/* in IWMC_BT we need to read the transfer length
+		 * before interrupt clearing */
+		val1 = sdio_readb(data->func, REG_H2D_COUNT_L, &err);
+		IBT_DBG(data->func, "%s to read len1,"
+			" reg_addr=%x ret=%d val=%x\n",
+			err ? "Failed" : "Succeeded",
+			REG_H2D_COUNT_L, err, err ? 0xff : val1);
+		if (err == 0) {
+			val2 = sdio_readb(data->func, REG_H2D_COUNT_H, &err);
+			IBT_DBG(data->func, "%s to read len2,"
+				" reg_addr=%x ret=%d val=%x\n",
+				err ? "Failed" : "Succeeded",
+				REG_H2D_COUNT_H, err, err ? 0xff : val2);
+			if (err == 0)
+				padded_len  = val1 + (val2 << 8);
+		}
+
+		sdio_writeb(func, 0x01, REG_CL_INTRD, NULL);
+
+		if (err || btsdio_rx_packet(data, padded_len) < 0) {
+			data->hdev->stat.err_rx++;
+			sdio_writeb(data->func, 0x01, REG_PC_RRT, NULL);
+		}
+	}
+}
+
+static int btsdio_open(struct hci_dev *hdev)
+{
+	struct btsdio_data *data = hdev->driver_data;
+	int err;
+
+	IBT_DBG(data->func, "%s", hdev->name);
+
+	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
+		return 0;
+
+	sdio_claim_host(data->func);
+
+#if 0
+	err = sdio_enable_func(data->func);
+	if (err < 0) {
+		clear_bit(HCI_RUNNING, &hdev->flags);
+		goto release;
+	}
+#endif
+
+	err = sdio_claim_irq(data->func, btsdio_interrupt);
+	if (err < 0) {
+		sdio_disable_func(data->func);
+		clear_bit(HCI_RUNNING, &hdev->flags);
+		goto release;
+	}
+
+	if (data->func->class == SDIO_CLASS_BT_B)
+		sdio_writeb(data->func, 0x00, REG_MD_STAT, NULL);
+
+	sdio_writeb(data->func, 0x01, REG_EN_INTRD, NULL);
+
+release:
+	sdio_release_host(data->func);
+
+	return err;
+}
+
+static int btsdio_close(struct hci_dev *hdev)
+{
+	struct btsdio_data *data = hdev->driver_data;
+
+	IBT_DBG(data->func, "%s", hdev->name);
+
+	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
+		return 0;
+
+	sdio_claim_host(data->func);
+
+	sdio_writeb(data->func, 0x00, REG_EN_INTRD, NULL);
+
+	sdio_release_irq(data->func);
+
+	sdio_release_host(data->func);
+
+	return 0;
+}
+
+static int btsdio_flush(struct hci_dev *hdev)
+{
+	struct btsdio_data *data = hdev->driver_data;
+
+	IBT_DBG(data->func, "%s", hdev->name);
+
+	skb_queue_purge(&data->txq);
+
+	return 0;
+}
+
+static int btsdio_send_frame(struct sk_buff *skb)
+{
+	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
+	struct btsdio_data *data = hdev->driver_data;
+
+	IBT_DBG(data->func, "%s", hdev->name);
+
+	if (!test_bit(HCI_RUNNING, &hdev->flags))
+		return -EBUSY;
+
+	switch (bt_cb(skb)->pkt_type) {
+	case HCI_COMMAND_PKT:
+		hdev->stat.cmd_tx++;
+		break;
+
+	case HCI_ACLDATA_PKT:
+		hdev->stat.acl_tx++;
+		break;
+
+	case HCI_SCODATA_PKT:
+		hdev->stat.sco_tx++;
+		break;
+
+	default:
+		return -EILSEQ;
+	}
+
+	skb_queue_tail(&data->txq, skb);
+
+	schedule_work(&data->work);
+
+	return 0;
+}
+
+static void btsdio_destruct(struct hci_dev *hdev)
+{
+	struct btsdio_data *data = hdev->driver_data;
+
+	IBT_DBG(data->func, "%s", hdev->name);
+
+	kfree(data);
+}
+
+static int btsdio_probe(struct sdio_func *func,
+			const struct sdio_device_id *id)
+{
+	struct btsdio_data *data;
+	struct hci_dev *hdev;
+	struct sdio_func_tuple *tuple = func->tuples;
+	int err;
+
+	IBT_DBG(func, "id %p class 0x%04x", id, func->class);
+
+	while (tuple) {
+		IBT_DBG(func, "code 0x%x size %d",
+			tuple->code, tuple->size);
+		tuple = tuple->next;
+	}
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	data->func = func;
+
+
+	sdio_claim_host(data->func);
+	/* FIXME: Remove after it is fixed in the Boot ROM upgrade */
+	func->enable_timeout = 10;
+	err = sdio_enable_func(data->func);
+	sdio_release_host(data->func);
+	if (err < 0) {
+		kfree(data);
+		return -ENODEV;
+	}
+
+
+	INIT_WORK(&data->work, btsdio_work);
+
+	skb_queue_head_init(&data->txq);
+
+	hdev = hci_alloc_dev();
+	if (!hdev) {
+		kfree(data);
+		return -ENOMEM;
+	}
+
+	hdev->type = HCI_SDIO;
+	hdev->driver_data = data;
+
+	data->hdev = hdev;
+
+	SET_HCIDEV_DEV(hdev, &func->dev);
+
+	hdev->open     = btsdio_open;
+	hdev->close    = btsdio_close;
+	hdev->flush    = btsdio_flush;
+	hdev->send     = btsdio_send_frame;
+	hdev->destruct = btsdio_destruct;
+
+	hdev->owner = THIS_MODULE;
+
+	err = hci_register_dev(hdev);
+	if (err < 0) {
+		hci_free_dev(hdev);
+		kfree(data);
+		return err;
+	}
+
+	sdio_set_drvdata(func, data);
+
+	return 0;
+}
+
+static void btsdio_remove(struct sdio_func *func)
+{
+	struct btsdio_data *data = sdio_get_drvdata(func);
+	struct hci_dev *hdev;
+
+	IBT_DBG(data->func, "remove");
+
+	if (!data)
+		return;
+
+	hdev = data->hdev;
+
+	sdio_set_drvdata(func, NULL);
+
+	sdio_claim_host(func);
+
+	sdio_disable_func(func);
+
+	sdio_release_host(func);
+
+	hci_unregister_dev(hdev);
+
+	hci_free_dev(hdev);
+}
+
+/* Note that the macro CONFIG_BTSDIO_PM is deliberately not defined in the
+ * config file. In order to use it, the macro should be defined or changed to
+ * CONFIG_PM.
+ */
+#ifdef CONFIG_BTSDIO_PM
+static int btsdio_suspend(struct sdio_func *func, pm_message_t msg)
+{
+	struct btsdio_data *data = sdio_get_drvdata(func);
+
+	IBT_DBG(data->func, "suspend");
+
+	if (!data)
+		return -EINVAL;
+
+	btsdio_close(data->hdev);
+	return 0;
+}
+
+static int btsdio_resume(struct sdio_func *func)
+{
+	struct btsdio_data *data = sdio_get_drvdata(func);
+
+	IBT_DBG(data->func, "resume");
+
+	if (!data)
+		return -EINVAL;
+
+	btsdio_open(data->hdev);
+	return 0;
+}
+#endif /* CONFIG_BTSDIO_PM */
+
+static struct sdio_driver btsdio_driver = {
+	.name		= "ibtsdio",
+	.probe		= btsdio_probe,
+	.remove		= btsdio_remove,
+	.id_table	= btsdio_table,
+#ifdef CONFIG_BTSDIO_PM
+	.suspend	= btsdio_suspend,
+	.resume		= btsdio_resume,
+#endif 	/* CONFIG_BTSDIO_PM */
+};
+
+static int __init btsdio_init(void)
+{
+	printk(KERN_INFO "IWMC Bluetooth SDIO driver ver %s", DRIVER_VERSION);
+
+	return sdio_register_driver(&btsdio_driver);
+}
+
+static void __exit btsdio_exit(void)
+{
+	sdio_unregister_driver(&btsdio_driver);
+}
+
+module_init(btsdio_init);
+module_exit(btsdio_exit);
+
+MODULE_AUTHOR("Gregory Paskar <gregory.paskar@intel.com>");
+MODULE_DESCRIPTION("IWMC Bluetooth SDIO driver ver " DRIVER_VERSION);
+MODULE_VERSION(DRIVER_VERSION);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ibtsdio");
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

