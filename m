From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 07/47] Bluetooth: Add btmrvl driver for Marvell Bluetooth devices
Date: Sun, 30 Aug 2009 01:50:21 -0700
Message-ID: <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53263 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbZH3Iv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:58 -0400
In-Reply-To: <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bing Zhao <bzhao@marvell.com>

This driver provides basic definitions and library functions to
support Marvell Bluetooth enabled devices, such as 88W8688 WLAN/BT
combo chip.

This patch incorporates a lot of comments given by
Nicolas Pitre <nico@marvell.com>. Many thanks to Nicolas Pitre.

Signed-off-by: Rahul Tank <rahult@marvell.com>
Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/Kconfig       |   12 +
 drivers/bluetooth/Makefile      |    3 +
 drivers/bluetooth/btmrvl_drv.h  |  138 ++++++++
 drivers/bluetooth/btmrvl_main.c |  714 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 867 insertions(+), 0 deletions(-)
 create mode 100644 drivers/bluetooth/btmrvl_drv.h
 create mode 100644 drivers/bluetooth/btmrvl_main.c

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index 1164837..b049a79 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -170,5 +170,17 @@ config BT_HCIVHCI
 	  Say Y here to compile support for virtual HCI devices into the
 	  kernel or say M to compile it as module (hci_vhci).
 
+config BT_MRVL
+	tristate "Marvell Bluetooth driver support"
+	select FW_LOADER
+	help
+	  The core driver to support Marvell Bluetooth devices.
+
+	  This driver is required if you want to support
+	  Marvell Bluetooth devices, such as 8688.
+
+	  Say Y here to compile Marvell Bluetooth driver
+	  into the kernel or say M to compile it as module.
+
 endmenu
 
diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
index 16930f9..3eff123 100644
--- a/drivers/bluetooth/Makefile
+++ b/drivers/bluetooth/Makefile
@@ -15,6 +15,9 @@ obj-$(CONFIG_BT_HCIBTUART)	+= btuart_cs.o
 obj-$(CONFIG_BT_HCIBTUSB)	+= btusb.o
 obj-$(CONFIG_BT_HCIBTSDIO)	+= btsdio.o
 
+btmrvl-objs			:= btmrvl_main.o
+obj-$(CONFIG_BT_MRVL)		+= btmrvl.o
+
 hci_uart-y				:= hci_ldisc.o
 hci_uart-$(CONFIG_BT_HCIUART_H4)	+= hci_h4.o
 hci_uart-$(CONFIG_BT_HCIUART_BCSP)	+= hci_bcsp.o
diff --git a/drivers/bluetooth/btmrvl_drv.h b/drivers/bluetooth/btmrvl_drv.h
new file mode 100644
index 0000000..9ad71f4
--- /dev/null
+++ b/drivers/bluetooth/btmrvl_drv.h
@@ -0,0 +1,138 @@
+/*
+ * Marvell Bluetooth driver: global definitions & declarations
+ *
+ * Copyright (C) 2009, Marvell International Ltd.
+ *
+ * This software file (the "File") is distributed by Marvell International
+ * Ltd. under the terms of the GNU General Public License Version 2, June 1991
+ * (the "License").  You may use, redistribute and/or modify this File in
+ * accordance with the terms and conditions of the License, a copy of which
+ * is available by writing to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or on the
+ * worldwide web at http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
+ *
+ *
+ * THE FILE IS DISTRIBUTED AS-IS, WITHOUT WARRANTY OF ANY KIND, AND THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE
+ * ARE EXPRESSLY DISCLAIMED.  The License provides additional details about
+ * this warranty disclaimer.
+ *
+ */
+
+#ifndef _BTMRVL_DRV_H_
+#define _BTMRVL_DRV_H_
+
+#include <linux/kthread.h>
+#include <linux/bitops.h>
+#include <net/bluetooth/bluetooth.h>
+
+#define BTM_HEADER_LEN			4
+#define BTM_DEV_NAME_LEN		32
+#define BTM_UPLD_SIZE			2312
+
+/* Time to wait until Host Sleep state change in millisecond */
+#define WAIT_UNTIL_HS_STATE_CHANGED	5000
+/* Time to wait for command response in millisecond */
+#define WAIT_UNTIL_CMD_RESP		5000
+
+struct btmrvl_thread {
+	struct task_struct *task;
+	wait_queue_head_t wait_q;
+	void *priv;
+};
+
+struct btmrvl_device {
+	char name[BTM_DEV_NAME_LEN];
+	void *card;
+	struct hci_dev *hcidev;
+
+	u8 tx_dnld_rdy;
+
+	u8 psmode;
+	u8 pscmd;
+	u8 hsmode;
+	u8 hscmd;
+
+	/* Low byte is gap, high byte is GPIO */
+	u16 gpio_gap;
+
+	u8 hscfgcmd;
+	u8 sendcmdflag;
+};
+
+struct btmrvl_adapter {
+	u32 int_count;
+	struct sk_buff_head tx_queue;
+	u8 psmode;
+	u8 ps_state;
+	u8 hs_state;
+	u8 wakeup_tries;
+	wait_queue_head_t cmd_wait_q;
+	u8 cmd_complete;
+};
+
+struct btmrvl_private {
+	struct btmrvl_device btmrvl_dev;
+	struct btmrvl_adapter *adapter;
+	struct btmrvl_thread main_thread;
+	int (*hw_host_to_card) (struct btmrvl_private *priv,
+				u8 *payload, u16 nb);
+	int (*hw_wakeup_firmware) (struct btmrvl_private *priv);
+	spinlock_t driver_lock;		/* spinlock used by driver */
+};
+
+#define MRVL_VENDOR_PKT			0xFE
+
+/* Bluetooth commands  */
+#define BT_CMD_AUTO_SLEEP_MODE		0x23
+#define BT_CMD_HOST_SLEEP_CONFIG	0x59
+#define BT_CMD_HOST_SLEEP_ENABLE	0x5A
+#define BT_CMD_MODULE_CFG_REQ		0x5B
+
+/* Sub-commands: Module Bringup/Shutdown Request */
+#define MODULE_BRINGUP_REQ		0xF1
+#define MODULE_SHUTDOWN_REQ		0xF2
+
+#define BT_EVENT_POWER_STATE		0x20
+
+/* Bluetooth Power States */
+#define BT_PS_ENABLE			0x02
+#define BT_PS_DISABLE			0x03
+#define BT_PS_SLEEP			0x01
+
+#define OGF				0x3F
+
+/* Host Sleep states */
+#define HS_ACTIVATED			0x01
+#define HS_DEACTIVATED			0x00
+
+/* Power Save modes */
+#define PS_SLEEP			0x01
+#define PS_AWAKE			0x00
+
+struct btmrvl_cmd {
+	__le16 ocf_ogf;
+	u8 length;
+	u8 data[4];
+} __attribute__ ((packed));
+
+struct btmrvl_event {
+	u8 ec;		/* event counter */
+	u8 length;
+	u8 data[4];
+} __attribute__ ((packed));
+
+/* Prototype of global function */
+
+struct btmrvl_private *btmrvl_add_card(void *card);
+int btmrvl_remove_card(struct btmrvl_private *priv);
+
+void btmrvl_interrupt(struct btmrvl_private *priv);
+
+void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb);
+int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb);
+
+int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd);
+int btmrvl_prepare_command(struct btmrvl_private *priv);
+
+#endif /* _BTMRVL_DRV_H_ */
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
new file mode 100644
index 0000000..11c2f2c
--- /dev/null
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -0,0 +1,714 @@
+/**
+ * Marvell Bluetooth driver
+ *
+ * Copyright (C) 2009, Marvell International Ltd.
+ *
+ * This software file (the "File") is distributed by Marvell International
+ * Ltd. under the terms of the GNU General Public License Version 2, June 1991
+ * (the "License").  You may use, redistribute and/or modify this File in
+ * accordance with the terms and conditions of the License, a copy of which
+ * is available by writing to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or on the
+ * worldwide web at http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
+ *
+ *
+ * THE FILE IS DISTRIBUTED AS-IS, WITHOUT WARRANTY OF ANY KIND, AND THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE
+ * ARE EXPRESSLY DISCLAIMED.  The License provides additional details about
+ * this warranty disclaimer.
+ **/
+
+#include <net/bluetooth/bluetooth.h>
+#include <net/bluetooth/hci_core.h>
+
+#include "btmrvl_drv.h"
+
+#define VERSION "1.0"
+
+/*
+ * This function is called by interface specific interrupt handler.
+ * It updates Power Save & Host Sleep states, and wakes up the main
+ * thread.
+ */
+void btmrvl_interrupt(struct btmrvl_private *priv)
+{
+	BT_DBG("Enter");
+
+	priv->adapter->ps_state = PS_AWAKE;
+
+	priv->adapter->wakeup_tries = 0;
+
+	priv->adapter->int_count++;
+
+	wake_up_interruptible(&priv->main_thread.wait_q);
+
+	BT_DBG("Leave");
+}
+EXPORT_SYMBOL_GPL(btmrvl_interrupt);
+
+void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb)
+{
+	struct hci_event_hdr *hdr = (struct hci_event_hdr *)skb->data;
+	struct hci_ev_cmd_complete *ec;
+	u16 opcode, ocf;
+
+	BT_DBG("Enter");
+
+	if (hdr->evt == HCI_EV_CMD_COMPLETE) {
+		ec = (struct hci_ev_cmd_complete *)(skb->data +
+						    HCI_EVENT_HDR_SIZE);
+		opcode = __le16_to_cpu(ec->opcode);
+		ocf = hci_opcode_ocf(opcode);
+		if ((ocf == BT_CMD_MODULE_CFG_REQ) &&
+		    (priv->btmrvl_dev.sendcmdflag)) {
+			priv->btmrvl_dev.sendcmdflag = false;
+			priv->adapter->cmd_complete = true;
+			wake_up_interruptible(&priv->adapter->cmd_wait_q);
+		}
+	}
+
+	BT_DBG("Leave");
+}
+EXPORT_SYMBOL_GPL(btmrvl_check_evtpkt);
+
+int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
+{
+	struct btmrvl_adapter *adapter = priv->adapter;
+	u8 ret = 0;
+	struct btmrvl_event *event;
+
+	BT_DBG("Enter");
+
+	event = (struct btmrvl_event *) skb->data;
+	if (event->ec != 0xff) {
+		BT_DBG("Not Marvell Event=%x", event->ec);
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	switch (event->data[0]) {
+	case BT_CMD_AUTO_SLEEP_MODE:
+		if (!event->data[2]) {
+			if (event->data[1] == BT_PS_ENABLE)
+				adapter->psmode = 1;
+			else
+				adapter->psmode = 0;
+			BT_DBG("PS Mode:%s",
+				(adapter->psmode) ? "Enable" : "Disable");
+		} else {
+			BT_DBG("PS Mode command failed");
+		}
+		break;
+
+	case BT_CMD_HOST_SLEEP_CONFIG:
+		if (!event->data[3])
+			BT_DBG("gpio=%x, gap=%x", event->data[1],
+				event->data[2]);
+		else
+			BT_DBG("HSCFG command failed");
+		break;
+
+	case BT_CMD_HOST_SLEEP_ENABLE:
+		if (!event->data[1]) {
+			adapter->hs_state = HS_ACTIVATED;
+			if (adapter->psmode)
+				adapter->ps_state = PS_SLEEP;
+			wake_up_interruptible(&adapter->cmd_wait_q);
+			BT_DBG("HS ACTIVATED!");
+		} else {
+			BT_DBG("HS Enable failed");
+		}
+		break;
+
+	case BT_CMD_MODULE_CFG_REQ:
+		if ((priv->btmrvl_dev.sendcmdflag) &&
+			(event->data[1] == MODULE_BRINGUP_REQ)) {
+			BT_DBG("EVENT:%s", (event->data[2]) ?
+				"Bring-up failed" : "Bring-up succeed");
+		} else if ((priv->btmrvl_dev.sendcmdflag) &&
+			(event->data[1] == MODULE_SHUTDOWN_REQ)) {
+			BT_DBG("EVENT:%s", (event->data[2]) ?
+				"Shutdown failed" : "Shutdown succeed");
+		} else {
+			BT_DBG("BT_CMD_MODULE_CFG_REQ resp for APP");
+			ret = -EINVAL;
+		}
+		break;
+
+	case BT_EVENT_POWER_STATE:
+		if (event->data[1] == BT_PS_SLEEP)
+			adapter->ps_state = PS_SLEEP;
+		BT_DBG("EVENT:%s",
+			(adapter->ps_state) ? "PS_SLEEP" : "PS_AWAKE");
+		break;
+
+	default:
+		BT_DBG("Unknown Event=%d", event->data[0]);
+		ret = -EINVAL;
+		break;
+	}
+
+exit:
+	if (!ret)
+		kfree_skb(skb);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(btmrvl_process_event);
+
+int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
+{
+	struct sk_buff *skb = NULL;
+	u8 ret = 0;
+	struct btmrvl_cmd *cmd;
+
+	BT_DBG("Enter");
+
+	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
+	if (skb == NULL) {
+		BT_ERR("No free skb");
+		ret = -ENOMEM;
+		goto exit;
+	}
+
+	cmd = (struct btmrvl_cmd *) skb->tail;
+	cmd->ocf_ogf = cpu_to_le16((OGF << 10) | BT_CMD_MODULE_CFG_REQ);
+	cmd->length = 1;
+	cmd->data[0] = subcmd;
+
+	bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
+
+	skb_put(skb, sizeof(*cmd));
+	skb->dev = (void *)priv->btmrvl_dev.hcidev;
+	skb_queue_head(&priv->adapter->tx_queue, skb);
+
+	priv->btmrvl_dev.sendcmdflag = true;
+
+	priv->adapter->cmd_complete = false;
+
+	BT_DBG("Queue module cfg Command");
+
+	wake_up_interruptible(&priv->main_thread.wait_q);
+
+	if (!wait_event_interruptible_timeout(
+			priv->adapter->cmd_wait_q,
+			priv->adapter->cmd_complete,
+			msecs_to_jiffies(WAIT_UNTIL_CMD_RESP))) {
+		ret = -ETIMEDOUT;
+		BT_ERR("module_cfg_cmd(%x): timeout: %d",
+			subcmd, priv->btmrvl_dev.sendcmdflag);
+	}
+
+	BT_DBG("module cfg Command done");
+
+exit:
+	BT_DBG("Leave");
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(btmrvl_send_module_cfg_cmd);
+
+static int btmrvl_enable_hs(struct btmrvl_private *priv)
+{
+	struct sk_buff *skb = NULL;
+	u8 ret = 0;
+	struct btmrvl_cmd *cmd;
+
+	BT_DBG("Enter");
+
+	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
+	if (skb == NULL) {
+		BT_ERR("No free skb");
+		ret = -ENOMEM;
+		goto exit;
+	}
+
+	cmd = (struct btmrvl_cmd *) skb->tail;
+	cmd->ocf_ogf = cpu_to_le16((OGF << 10) | BT_CMD_HOST_SLEEP_ENABLE);
+	cmd->length = 0;
+
+	bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
+
+	skb_put(skb, sizeof(*cmd));
+	skb->dev = (void *)priv->btmrvl_dev.hcidev;
+	skb_queue_head(&priv->adapter->tx_queue, skb);
+
+	BT_DBG("Queue hs enable Command");
+
+	wake_up_interruptible(&priv->main_thread.wait_q);
+
+	if (!wait_event_interruptible_timeout(
+			priv->adapter->cmd_wait_q,
+			priv->adapter->hs_state,
+			msecs_to_jiffies(WAIT_UNTIL_HS_STATE_CHANGED))) {
+		ret = -ETIMEDOUT;
+		BT_ERR("timeout: %d, %d,%d",
+			priv->adapter->hs_state,
+			priv->adapter->ps_state,
+			priv->adapter->wakeup_tries);
+	}
+
+exit:
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+int btmrvl_prepare_command(struct btmrvl_private *priv)
+{
+	struct sk_buff *skb = NULL;
+	u8 ret = 0;
+	struct btmrvl_cmd *cmd;
+
+	BT_DBG("Enter");
+
+	if (priv->btmrvl_dev.hscfgcmd) {
+		priv->btmrvl_dev.hscfgcmd = 0;
+
+		skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
+		if (skb == NULL) {
+			BT_ERR("No free skb");
+			ret = -ENOMEM;
+			goto exit;
+		}
+
+		cmd = (struct btmrvl_cmd *) skb->tail;
+		cmd->ocf_ogf = cpu_to_le16((OGF << 10) |
+						BT_CMD_HOST_SLEEP_CONFIG);
+		cmd->length = 2;
+		cmd->data[0] = (priv->btmrvl_dev.gpio_gap & 0xff00) >> 8;
+		cmd->data[1] = (u8) (priv->btmrvl_dev.gpio_gap & 0x00ff);
+
+		bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
+
+		skb_put(skb, sizeof(*cmd));
+		skb->dev = (void *)priv->btmrvl_dev.hcidev;
+		skb_queue_head(&priv->adapter->tx_queue, skb);
+
+		BT_DBG("Queue HSCFG Command, gpio=0x%x, gap=0x%x",
+		       cmd->data[0], cmd->data[1]);
+	}
+
+	if (priv->btmrvl_dev.pscmd) {
+		priv->btmrvl_dev.pscmd = 0;
+
+		skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
+		if (skb == NULL) {
+			BT_ERR("No free skb");
+			ret = -ENOMEM;
+			goto exit;
+		}
+
+		cmd = (struct btmrvl_cmd *) skb->tail;
+		cmd->ocf_ogf = cpu_to_le16((OGF << 10) |
+						BT_CMD_AUTO_SLEEP_MODE);
+		cmd->length = 1;
+
+		if (priv->btmrvl_dev.psmode)
+			cmd->data[0] = BT_PS_ENABLE;
+		else
+			cmd->data[0] = BT_PS_DISABLE;
+
+		bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
+
+		skb_put(skb, sizeof(*cmd));
+		skb->dev = (void *)priv->btmrvl_dev.hcidev;
+		skb_queue_head(&priv->adapter->tx_queue, skb);
+
+		BT_DBG("Queue PSMODE Command:%d", cmd->data[0]);
+	}
+
+	if (priv->btmrvl_dev.hscmd) {
+		priv->btmrvl_dev.hscmd = 0;
+
+		if (priv->btmrvl_dev.hsmode) {
+			ret = btmrvl_enable_hs(priv);
+		} else {
+			ret = priv->hw_wakeup_firmware(priv);
+			priv->adapter->hs_state = HS_DEACTIVATED;
+		}
+	}
+
+exit:
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
+{
+	u8 ret = 0;
+
+	BT_DBG("Enter");
+
+	if (!skb || !skb->data) {
+		BT_DBG("Leave");
+		return -EINVAL;
+	}
+
+	if (!skb->len || ((skb->len + BTM_HEADER_LEN) > BTM_UPLD_SIZE)) {
+		BT_ERR("Tx Error: Bad skb length %d : %d",
+			skb->len, BTM_UPLD_SIZE);
+		BT_DBG("Leave");
+		return -EINVAL;
+	}
+
+	if (skb_headroom(skb) < BTM_HEADER_LEN) {
+		struct sk_buff *tmp = skb;
+
+		skb = skb_realloc_headroom(skb, BTM_HEADER_LEN);
+		if (!skb) {
+			BT_ERR("Tx Error: realloc_headroom failed %d",
+				BTM_HEADER_LEN);
+			skb = tmp;
+			BT_DBG("Leave");
+			return -EINVAL;
+		}
+
+		kfree_skb(tmp);
+	}
+
+	skb_push(skb, BTM_HEADER_LEN);
+
+	/* header type: byte[3]
+	 * HCI_COMMAND = 1, ACL_DATA = 2, SCO_DATA = 3, 0xFE = Vendor
+	 * header length: byte[2][1][0]
+	 */
+
+	skb->data[0] = (skb->len & 0x0000ff);
+	skb->data[1] = (skb->len & 0x00ff00) >> 8;
+	skb->data[2] = (skb->len & 0xff0000) >> 16;
+	skb->data[3] = bt_cb(skb)->pkt_type;
+
+	if (priv->hw_host_to_card)
+		ret = priv->hw_host_to_card(priv, skb->data, skb->len);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static void btmrvl_init_adapter(struct btmrvl_private *priv)
+{
+	BT_DBG("Enter");
+
+	skb_queue_head_init(&priv->adapter->tx_queue);
+
+	priv->adapter->ps_state = PS_AWAKE;
+
+	init_waitqueue_head(&priv->adapter->cmd_wait_q);
+
+	BT_DBG("Leave");
+}
+
+static void btmrvl_free_adapter(struct btmrvl_private *priv)
+{
+	BT_DBG("Enter");
+
+	skb_queue_purge(&priv->adapter->tx_queue);
+
+	kfree(priv->adapter);
+
+	priv->adapter = NULL;
+
+	BT_DBG("Leave");
+}
+
+static int
+btmrvl_ioctl(struct hci_dev *hdev, unsigned int cmd, unsigned long arg)
+{
+	BT_DBG("Enter");
+
+	BT_DBG("Leave");
+
+	return -ENOIOCTLCMD;
+}
+
+static void btmrvl_destruct(struct hci_dev *hdev)
+{
+	BT_DBG("Enter");
+
+	BT_DBG("Leave");
+}
+
+static int btmrvl_send_frame(struct sk_buff *skb)
+{
+	struct hci_dev *hdev = (struct hci_dev *)skb->dev;
+	struct btmrvl_private *priv = NULL;
+
+	BT_DBG("Enter: type=%d, len=%d", skb->pkt_type, skb->len);
+
+	if (!hdev || !hdev->driver_data) {
+		BT_ERR("Frame for unknown HCI device");
+		BT_DBG("Leave");
+		return -ENODEV;
+	}
+
+	priv = (struct btmrvl_private *)hdev->driver_data;
+	if (!test_bit(HCI_RUNNING, &hdev->flags)) {
+		BT_ERR("Failed testing HCI_RUNING, flags=%lx", hdev->flags);
+		print_hex_dump_bytes("data: ", DUMP_PREFIX_OFFSET,
+					skb->data, skb->len);
+		BT_DBG("Leave");
+		return -EBUSY;
+	}
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
+	}
+
+	skb_queue_tail(&priv->adapter->tx_queue, skb);
+
+	wake_up_interruptible(&priv->main_thread.wait_q);
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+static int btmrvl_flush(struct hci_dev *hdev)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) hdev->driver_data;
+
+	BT_DBG("Enter");
+
+	skb_queue_purge(&priv->adapter->tx_queue);
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+static int btmrvl_close(struct hci_dev *hdev)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) hdev->driver_data;
+
+	BT_DBG("Enter");
+
+	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags)) {
+		BT_DBG("Leave");
+		return 0;
+	}
+
+	skb_queue_purge(&priv->adapter->tx_queue);
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+static int btmrvl_open(struct hci_dev *hdev)
+{
+	BT_DBG("Enter");
+
+	set_bit(HCI_RUNNING, &hdev->flags);
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+/*
+ * This function handles the event generated by firmware, rx data
+ * received from firmware, and tx data sent from kernel.
+ */
+static int btmrvl_service_main_thread(void *data)
+{
+	struct btmrvl_thread *thread = data;
+	struct btmrvl_private *priv = thread->priv;
+	struct btmrvl_adapter *adapter = priv->adapter;
+	wait_queue_t wait;
+	struct sk_buff *skb;
+	ulong flags;
+
+	BT_DBG("Enter");
+
+	init_waitqueue_entry(&wait, current);
+
+	current->flags |= PF_NOFREEZE;
+
+	for (;;) {
+		add_wait_queue(&thread->wait_q, &wait);
+
+		set_current_state(TASK_INTERRUPTIBLE);
+
+		if (adapter->wakeup_tries ||
+		    ((!adapter->int_count) &&
+		     (!priv->btmrvl_dev.tx_dnld_rdy ||
+		      skb_queue_empty(&adapter->tx_queue)))) {
+			BT_DBG("main_thread is sleeping...");
+			schedule();
+		}
+
+		set_current_state(TASK_RUNNING);
+
+		remove_wait_queue(&thread->wait_q, &wait);
+
+		BT_DBG("main_thread woke up");
+
+		if (kthread_should_stop()) {
+			BT_DBG("main_thread: break from main thread");
+			break;
+		}
+
+		spin_lock_irqsave(&priv->driver_lock, flags);
+		if (adapter->int_count) {
+			adapter->int_count = 0;
+		} else if ((adapter->ps_state == PS_SLEEP) &&
+			   !skb_queue_empty(&adapter->tx_queue)) {
+			spin_unlock_irqrestore(&priv->driver_lock, flags);
+			adapter->wakeup_tries++;
+			priv->hw_wakeup_firmware(priv);
+			continue;
+		}
+		spin_unlock_irqrestore(&priv->driver_lock, flags);
+
+		if (adapter->ps_state == PS_SLEEP)
+			continue;
+
+		if (!priv->btmrvl_dev.tx_dnld_rdy)
+			continue;
+
+		skb = skb_dequeue(&adapter->tx_queue);
+		if (skb) {
+			if (btmrvl_tx_pkt(priv, skb))
+				priv->btmrvl_dev.hcidev->stat.err_tx++;
+			else
+				priv->btmrvl_dev.hcidev->stat.byte_tx
+					+= skb->len;
+
+			kfree_skb(skb);
+		}
+	}
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+struct btmrvl_private *btmrvl_add_card(void *card)
+{
+	struct hci_dev *hdev = NULL;
+	struct btmrvl_private *priv = NULL;
+	int ret;
+
+	BT_DBG("Enter");
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		BT_ERR("Can not allocate priv");
+		goto err_priv;
+	}
+
+	priv->adapter = kzalloc(sizeof(*priv->adapter), GFP_KERNEL);
+	if (!priv->adapter) {
+		BT_ERR("Allocate buffer for btmrvl_adapter failed!");
+		goto err_adapter;
+	}
+
+	btmrvl_init_adapter(priv);
+
+	hdev = hci_alloc_dev();
+	if (!hdev) {
+		BT_ERR("Can not allocate HCI device");
+		goto err_hdev;
+	}
+
+	BT_DBG("Starting kthread...");
+	priv->main_thread.priv = priv;
+	spin_lock_init(&priv->driver_lock);
+
+	init_waitqueue_head(&priv->main_thread.wait_q);
+	priv->main_thread.task = kthread_run(btmrvl_service_main_thread,
+		&priv->main_thread, "btmrvl_main_service");
+
+	priv->btmrvl_dev.hcidev = hdev;
+	priv->btmrvl_dev.card = card;
+
+	hdev->driver_data = priv;
+
+	priv->btmrvl_dev.tx_dnld_rdy = true;
+
+	hdev->type = HCI_SDIO;
+	hdev->open = btmrvl_open;
+	hdev->close = btmrvl_close;
+	hdev->flush = btmrvl_flush;
+	hdev->send = btmrvl_send_frame;
+	hdev->destruct = btmrvl_destruct;
+	hdev->ioctl = btmrvl_ioctl;
+	hdev->owner = THIS_MODULE;
+
+	ret = hci_register_dev(hdev);
+	if (ret < 0) {
+		BT_ERR("Can not register HCI device");
+		goto err_hci_register_dev;
+	}
+
+	BT_DBG("Leave");
+	return priv;
+
+err_hci_register_dev:
+	/* Stop the thread servicing the interrupts */
+	kthread_stop(priv->main_thread.task);
+
+	hci_free_dev(hdev);
+
+err_hdev:
+	btmrvl_free_adapter(priv);
+
+err_adapter:
+	kfree(priv);
+
+err_priv:
+	BT_DBG("Leave");
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(btmrvl_add_card);
+
+int btmrvl_remove_card(struct btmrvl_private *priv)
+{
+	struct hci_dev *hdev;
+
+	BT_DBG("Enter");
+
+	hdev = priv->btmrvl_dev.hcidev;
+
+	wake_up_interruptible(&priv->adapter->cmd_wait_q);
+
+	kthread_stop(priv->main_thread.task);
+
+	hci_unregister_dev(hdev);
+
+	hci_free_dev(hdev);
+
+	priv->btmrvl_dev.hcidev = NULL;
+
+	btmrvl_free_adapter(priv);
+
+	kfree(priv);
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(btmrvl_remove_card);
+
+MODULE_AUTHOR("Marvell International Ltd.");
+MODULE_DESCRIPTION("Marvell Bluetooth Driver v" VERSION);
+MODULE_VERSION(VERSION);
+MODULE_LICENSE("GPL v2");
-- 
1.6.2.5

