From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 08/47] Bluetooth: Add Marvell BT-over-SDIO driver
Date: Sun, 30 Aug 2009 01:50:22 -0700
Message-ID: <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53270 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbZH3Iv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:59 -0400
In-Reply-To: <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bing Zhao <bzhao@marvell.com>

This driver supports Marvell Bluetooth enabled devices with SDIO
interface. Currently only SD8688 chip is supported.

The helper/firmware images of SD8688 can be downloaded from this tree:
git://git.infradead.org/users/dwmw2/linux-firmware.git

This patch incorporates a lot of comments given by
Nicolas Pitre <nico@marvell.com>. Many thanks to Nicolas Pitre.

Signed-off-by: Rahul Tank <rahult@marvell.com>
Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/Kconfig       |   13 +
 drivers/bluetooth/Makefile      |    1 +
 drivers/bluetooth/btmrvl_sdio.c | 1128 +++++++++++++++++++++++++++++++++++++++
 drivers/bluetooth/btmrvl_sdio.h |  113 ++++
 4 files changed, 1255 insertions(+), 0 deletions(-)
 create mode 100644 drivers/bluetooth/btmrvl_sdio.c
 create mode 100644 drivers/bluetooth/btmrvl_sdio.h

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index b049a79..8c89bd4 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -182,5 +182,18 @@ config BT_MRVL
 	  Say Y here to compile Marvell Bluetooth driver
 	  into the kernel or say M to compile it as module.
 
+config BT_MRVL_SDIO
+	tristate "Marvell BT-over-SDIO driver"
+	depends on BT_MRVL && MMC
+	help
+	  The driver for Marvell Bluetooth chipsets with SDIO interface.
+
+	  This driver is required if you want to use Marvell Bluetooth
+	  devices with SDIO interface. Currently only SD8688 chipset is
+	  supported.
+
+	  Say Y here to compile support for Marvell BT-over-SDIO driver
+	  into the kernel or say M to compile it as module.
+
 endmenu
 
diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
index 3eff123..2dc12e7 100644
--- a/drivers/bluetooth/Makefile
+++ b/drivers/bluetooth/Makefile
@@ -17,6 +17,7 @@ obj-$(CONFIG_BT_HCIBTSDIO)	+= btsdio.o
 
 btmrvl-objs			:= btmrvl_main.o
 obj-$(CONFIG_BT_MRVL)		+= btmrvl.o
+obj-$(CONFIG_BT_MRVL_SDIO)	+= btmrvl_sdio.o
 
 hci_uart-y				:= hci_ldisc.o
 hci_uart-$(CONFIG_BT_HCIUART_H4)	+= hci_h4.o
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
new file mode 100644
index 0000000..8f13e7b
--- /dev/null
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -0,0 +1,1128 @@
+/**
+ * Marvell BT-over-SDIO driver: SDIO interface related functions.
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
+#include <linux/firmware.h>
+
+#include <linux/mmc/sdio_ids.h>
+#include <linux/mmc/sdio_func.h>
+
+#include <net/bluetooth/bluetooth.h>
+#include <net/bluetooth/hci_core.h>
+
+#include "btmrvl_drv.h"
+#include "btmrvl_sdio.h"
+
+#define VERSION "1.0"
+
+#ifndef SDIO_DEVICE_ID_MARVELL_8688BT
+#define SDIO_DEVICE_ID_MARVELL_8688BT		0x9105
+#endif
+
+/* The btmrvl_sdio_remove() callback function is called
+ * when user removes this module from kernel space or ejects
+ * the card from the slot. The driver handles these 2 cases
+ * differently.
+ * If the user is removing the module, a MODULE_SHUTDOWN_REQ
+ * command is sent to firmware and interrupt will be disabled.
+ * If the card is removed, there is no need to send command
+ * or disable interrupt.
+ *
+ * The variable 'user_rmmod' is used to distinguish these two
+ * scenarios. This flag is initialized as FALSE in case the card
+ * is removed, and will be set to TRUE for module removal when
+ * module_exit function is called.
+ */
+static u8 user_rmmod;
+
+static const struct sdio_device_id btmrvl_sdio_ids[] = {
+	{SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, SDIO_DEVICE_ID_MARVELL_8688BT)},
+	{0, 0, 0, 0}
+};
+
+MODULE_DEVICE_TABLE(sdio, btmrvl_sdio_ids);
+
+static struct btmrvl_sdio_device btmrvl_sdio_devices[] = {
+	{
+		.dev_id = SDIO_DEVICE_ID_MARVELL_8688BT,
+		.helper = "sd8688_helper.bin",
+		.firmware = "sd8688.bin",
+	},
+};
+
+static int btmrvl_sdio_get_rx_unit(struct btmrvl_sdio_card *card)
+{
+	u8 reg;
+	int ret;
+
+	BT_DBG("Enter");
+
+	reg = sdio_readb(card->func, CARD_RX_UNIT_REG, &ret);
+	if (!ret)
+		card->rx_unit = reg;
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_read_fw_status(struct btmrvl_sdio_card *card, u16 *dat)
+{
+	int ret;
+	u8 fws0, fws1;
+
+	BT_DBG("Enter");
+
+	*dat = 0;
+
+	fws0 = sdio_readb(card->func, CARD_FW_STATUS0_REG, &ret);
+
+	if (!ret)
+		fws1 = sdio_readb(card->func, CARD_FW_STATUS1_REG, &ret);
+
+	if (ret) {
+		BT_DBG("Leave");
+		return -EIO;
+	}
+
+	*dat = (((u16) fws1) << 8) | fws0;
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+static int btmrvl_sdio_read_rx_len(struct btmrvl_sdio_card *card, u16 *dat)
+{
+	int ret;
+	u8 reg;
+
+	BT_DBG("Enter");
+
+	reg = sdio_readb(card->func, CARD_RX_LEN_REG, &ret);
+	if (!ret)
+		*dat = (u16) reg << card->rx_unit;
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_enable_host_int_mask(struct btmrvl_sdio_card *card,
+						u8 mask)
+{
+	int ret;
+
+	BT_DBG("Enter");
+
+	sdio_writeb(card->func, mask, HOST_INT_MASK_REG, &ret);
+	if (ret) {
+		BT_ERR("Unable to enable the host interrupt!");
+		ret = -EIO;
+	}
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_disable_host_int_mask(struct btmrvl_sdio_card *card,
+						u8 mask)
+{
+	int ret;
+	u8 host_int_mask;
+
+	BT_DBG("Enter");
+
+	host_int_mask = sdio_readb(card->func, HOST_INT_MASK_REG, &ret);
+	if (ret) {
+		ret = -EIO;
+		goto done;
+	}
+
+	host_int_mask &= ~mask;
+
+	sdio_writeb(card->func, host_int_mask, HOST_INT_MASK_REG, &ret);
+	if (ret < 0) {
+		BT_ERR("Unable to disable the host interrupt!");
+		ret = -EIO;
+		goto done;
+	}
+
+	ret = 0;
+
+done:
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_poll_card_status(struct btmrvl_sdio_card *card, u8 bits)
+{
+	unsigned int tries;
+	int ret;
+	u8 status;
+
+	BT_DBG("Enter");
+
+	for (tries = 0; tries < MAX_POLL_TRIES * 1000; tries++) {
+		status = sdio_readb(card->func, CARD_STATUS_REG, &ret);
+		if (ret)
+			goto failed;
+		if ((status & bits) == bits)
+			goto done;
+
+		udelay(1);
+	}
+
+	ret = -ETIMEDOUT;
+
+failed:
+	BT_ERR("FAILED! ret=%d", ret);
+
+done:
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_verify_fw_download(struct btmrvl_sdio_card *card,
+						int pollnum)
+{
+	int ret = -ETIMEDOUT;
+	u16 firmwarestat;
+	unsigned int tries;
+
+	BT_DBG("Enter");
+
+	 /* Wait for firmware to become ready */
+	for (tries = 0; tries < pollnum; tries++) {
+		if (btmrvl_sdio_read_fw_status(card, &firmwarestat) < 0)
+			continue;
+
+		if (firmwarestat == FIRMWARE_READY) {
+			ret = 0;
+			break;
+		} else {
+			msleep(10);
+		}
+	}
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
+{
+	const struct firmware *fw_helper = NULL;
+	const u8 *helper = NULL;
+	int ret;
+	void *tmphlprbuf = NULL;
+	int tmphlprbufsz, hlprblknow, helperlen;
+	u8 *helperbuf;
+	u32 tx_len;
+
+	BT_DBG("Enter");
+
+	ret = request_firmware(&fw_helper, card->helper,
+				&card->func->dev);
+	if ((ret < 0) || !fw_helper) {
+		BT_ERR("request_firmware(helper) failed, error code = %d",
+			ret);
+		ret = -ENOENT;
+		goto done;
+	}
+
+	helper = fw_helper->data;
+	helperlen = fw_helper->size;
+
+	BT_DBG("Downloading helper image (%d bytes), block size %d bytes",
+		helperlen, SDIO_BLOCK_SIZE);
+
+	tmphlprbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
+
+	tmphlprbuf = kmalloc(tmphlprbufsz, GFP_KERNEL);
+	if (!tmphlprbuf) {
+		BT_ERR("Unable to allocate buffer for helper."
+			" Terminating download");
+		ret = -ENOMEM;
+		goto done;
+	}
+
+	memset(tmphlprbuf, 0, tmphlprbufsz);
+
+	helperbuf = (u8 *) ALIGN_ADDR(tmphlprbuf, BTSDIO_DMA_ALIGN);
+
+	/* Perform helper data transfer */
+	tx_len = (FIRMWARE_TRANSFER_NBLOCK * SDIO_BLOCK_SIZE)
+			- SDIO_HEADER_LEN;
+	hlprblknow = 0;
+
+	do {
+		ret = btmrvl_sdio_poll_card_status(card,
+					    CARD_IO_READY | DN_LD_CARD_RDY);
+		if (ret < 0) {
+			BT_ERR("Helper download poll status timeout @ %d",
+				hlprblknow);
+			goto done;
+		}
+
+		/* Check if there is more data? */
+		if (hlprblknow >= helperlen)
+			break;
+
+		if (helperlen - hlprblknow < tx_len)
+			tx_len = helperlen - hlprblknow;
+
+		/* Little-endian */
+		helperbuf[0] = ((tx_len & 0x000000ff) >> 0);
+		helperbuf[1] = ((tx_len & 0x0000ff00) >> 8);
+		helperbuf[2] = ((tx_len & 0x00ff0000) >> 16);
+		helperbuf[3] = ((tx_len & 0xff000000) >> 24);
+
+		memcpy(&helperbuf[SDIO_HEADER_LEN], &helper[hlprblknow],
+				tx_len);
+
+		/* Now send the data */
+		ret = sdio_writesb(card->func, card->ioport,
+				   helperbuf,
+				   FIRMWARE_TRANSFER_NBLOCK *
+				   SDIO_BLOCK_SIZE);
+		if (ret < 0) {
+			BT_ERR("IO error during helper download @ %d",
+				hlprblknow);
+			goto done;
+		}
+
+		hlprblknow += tx_len;
+	} while (true);
+
+	BT_DBG("Transferring helper image EOF block");
+
+	memset(helperbuf, 0x0, SDIO_BLOCK_SIZE);
+
+	ret = sdio_writesb(card->func, card->ioport, helperbuf,
+			 SDIO_BLOCK_SIZE);
+	if (ret < 0) {
+		BT_ERR("IO error in writing helper image EOF block");
+		goto done;
+	}
+
+	ret = 0;
+
+done:
+	kfree(tmphlprbuf);
+	if (fw_helper)
+		release_firmware(fw_helper);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
+{
+	const struct firmware *fw_firmware = NULL;
+	const u8 *firmware = NULL;
+	int firmwarelen, tmpfwbufsz, ret;
+	unsigned int tries, offset;
+	u8 base0, base1;
+	void *tmpfwbuf = NULL;
+	u8 *fwbuf;
+	u16 len;
+	int txlen = 0, tx_blocks = 0, count = 0;
+
+	BT_DBG("Enter");
+
+	ret = request_firmware(&fw_firmware, card->firmware,
+				&card->func->dev);
+	if ((ret < 0) || !fw_firmware) {
+		BT_ERR("request_firmware(firmware) failed, error code = %d",
+			ret);
+		ret = -ENOENT;
+		goto done;
+	}
+
+	firmware = fw_firmware->data;
+	firmwarelen = fw_firmware->size;
+
+	BT_DBG("Downloading FW image (%d bytes)", firmwarelen);
+
+	tmpfwbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
+	tmpfwbuf = kmalloc(tmpfwbufsz, GFP_KERNEL);
+	if (!tmpfwbuf) {
+		BT_ERR("Unable to allocate buffer for firmware."
+		       " Terminating download");
+		ret = -ENOMEM;
+		goto done;
+	}
+
+	memset(tmpfwbuf, 0, tmpfwbufsz);
+
+	/* Ensure aligned firmware buffer */
+	fwbuf = (u8 *) ALIGN_ADDR(tmpfwbuf, BTSDIO_DMA_ALIGN);
+
+	/* Perform firmware data transfer */
+	offset = 0;
+	do {
+		ret = btmrvl_sdio_poll_card_status(card,
+					    CARD_IO_READY | DN_LD_CARD_RDY);
+		if (ret < 0) {
+			BT_ERR("FW download with helper poll status"
+				" timeout @ %d", offset);
+			goto done;
+		}
+
+		/* Check if there is more data ? */
+		if (offset >= firmwarelen)
+			break;
+
+		for (tries = 0; tries < MAX_POLL_TRIES; tries++) {
+			base0 = sdio_readb(card->func,
+					SQ_READ_BASE_ADDRESS_A0_REG, &ret);
+			if (ret) {
+				BT_ERR("BASE0 register read failed:"
+					" base0 = 0x%04X(%d)."
+					" Terminating download",
+					base0, base0);
+				ret = -EIO;
+				goto done;
+			}
+			base1 = sdio_readb(card->func,
+					SQ_READ_BASE_ADDRESS_A1_REG, &ret);
+			if (ret) {
+				BT_ERR("BASE1 register read failed:"
+					" base1 = 0x%04X(%d)."
+					" Terminating download",
+					base1, base1);
+				ret = -EIO;
+				goto done;
+			}
+
+			len = (((u16) base1) << 8) | base0;
+			if (len)
+				break;
+
+			udelay(10);
+		}
+
+		if (!len)
+			break;
+		else if (len > BTM_UPLD_SIZE) {
+			BT_ERR("FW download failure @%d, invalid length %d",
+				offset, len);
+			ret = -EINVAL;
+			goto done;
+		}
+
+		txlen = len;
+
+		if (len & BIT(0)) {
+			count++;
+			if (count > MAX_WRITE_IOMEM_RETRY) {
+				BT_ERR("FW download failure @%d, "
+					"over max retry count", offset);
+				ret = -EIO;
+				goto done;
+			}
+			BT_ERR("FW CRC error indicated by the helper: "
+				"len = 0x%04X, txlen = %d", len, txlen);
+			len &= ~BIT(0);
+			/* Set txlen to 0 so as to resend from same offset */
+			txlen = 0;
+		} else {
+			count = 0;
+
+			/* Last block ? */
+			if (firmwarelen - offset < txlen)
+				txlen = firmwarelen - offset;
+
+			tx_blocks =
+			    (txlen + SDIO_BLOCK_SIZE - 1) / SDIO_BLOCK_SIZE;
+
+			memcpy(fwbuf, &firmware[offset], txlen);
+		}
+
+		ret = sdio_writesb(card->func, card->ioport, fwbuf,
+					tx_blocks * SDIO_BLOCK_SIZE);
+
+		if (ret < 0) {
+			BT_ERR("FW download, writesb(%d) failed @%d",
+				count, offset);
+			sdio_writeb(card->func, HOST_CMD53_FIN, CONFIG_REG,
+					&ret);
+			if (ret)
+				BT_ERR("writeb failed (CFG)");
+		}
+
+		offset += txlen;
+	} while (true);
+
+	BT_DBG("FW download over, size %d bytes", offset);
+
+	ret = 0;
+
+done:
+	kfree(tmpfwbuf);
+
+	if (fw_firmware)
+		release_firmware(fw_firmware);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
+{
+	u16 buf_len = 0;
+	int ret, buf_block_len, blksz;
+	struct sk_buff *skb = NULL;
+	u32 type;
+	u8 *payload = NULL;
+	struct hci_dev *hdev = priv->btmrvl_dev.hcidev;
+	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
+
+	BT_DBG("Enter");
+
+	if (!card || !card->func) {
+		BT_ERR("card or function is NULL!");
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	/* Read the length of data to be transferred */
+	ret = btmrvl_sdio_read_rx_len(card, &buf_len);
+	if (ret < 0) {
+		BT_ERR("read rx_len failed");
+		ret = -EIO;
+		goto exit;
+	}
+
+	blksz = SDIO_BLOCK_SIZE;
+	buf_block_len = (buf_len + blksz - 1) / blksz;
+
+	if (buf_len <= SDIO_HEADER_LEN
+	    || (buf_block_len * blksz) > ALLOC_BUF_SIZE) {
+		BT_ERR("invalid packet length: %d", buf_len);
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	/* Allocate buffer */
+	skb = bt_skb_alloc(buf_block_len * blksz + BTSDIO_DMA_ALIGN,
+				GFP_ATOMIC);
+	if (skb == NULL) {
+		BT_ERR("No free skb");
+		goto exit;
+	}
+
+	if ((u32) skb->data & (BTSDIO_DMA_ALIGN - 1)) {
+		skb_put(skb, (u32) skb->data & (BTSDIO_DMA_ALIGN - 1));
+		skb_pull(skb, (u32) skb->data & (BTSDIO_DMA_ALIGN - 1));
+	}
+
+	payload = skb->tail;
+
+	ret = sdio_readsb(card->func, payload, card->ioport,
+			  buf_block_len * blksz);
+	if (ret < 0) {
+		BT_ERR("readsb failed: %d", ret);
+		ret = -EIO;
+		goto exit;
+	}
+
+	/* This is SDIO specific header length: byte[2][1][0], type: byte[3]
+	 * (HCI_COMMAND = 1, ACL_DATA = 2, SCO_DATA = 3, 0xFE = Vendor)
+	 */
+
+	buf_len = payload[0];
+	buf_len |= (u16) payload[1] << 8;
+	type = payload[3];
+
+	switch (type) {
+	case HCI_ACLDATA_PKT:
+	case HCI_SCODATA_PKT:
+	case HCI_EVENT_PKT:
+		bt_cb(skb)->pkt_type = type;
+		skb->dev = (void *)hdev;
+		skb_put(skb, buf_len);
+		skb_pull(skb, SDIO_HEADER_LEN);
+
+		if (type == HCI_EVENT_PKT)
+			btmrvl_check_evtpkt(priv, skb);
+
+		hci_recv_frame(skb);
+		hdev->stat.byte_rx += buf_len;
+		break;
+
+	case MRVL_VENDOR_PKT:
+		bt_cb(skb)->pkt_type = HCI_VENDOR_PKT;
+		skb->dev = (void *)hdev;
+		skb_put(skb, buf_len);
+		skb_pull(skb, SDIO_HEADER_LEN);
+
+		if (btmrvl_process_event(priv, skb))
+			hci_recv_frame(skb);
+
+		hdev->stat.byte_rx += buf_len;
+		break;
+
+	default:
+		BT_ERR("Unknow packet type:%d", type);
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, payload,
+					blksz * buf_block_len);
+
+		kfree_skb(skb);
+		skb = NULL;
+		break;
+	}
+
+exit:
+	if (ret) {
+		hdev->stat.err_rx++;
+		if (skb)
+			kfree_skb(skb);
+	}
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_get_int_status(struct btmrvl_private *priv, u8 * ireg)
+{
+	int ret;
+	u8 sdio_ireg = 0;
+	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
+
+	BT_DBG("Enter");
+
+	*ireg = 0;
+
+	sdio_ireg = sdio_readb(card->func, HOST_INTSTATUS_REG, &ret);
+	if (ret) {
+		BT_ERR("sdio_readb: read int status register failed");
+		ret = -EIO;
+		goto done;
+	}
+
+	if (sdio_ireg != 0) {
+		/*
+		 * DN_LD_HOST_INT_STATUS and/or UP_LD_HOST_INT_STATUS
+		 * Clear the interrupt status register and re-enable the
+		 * interrupt.
+		 */
+		BT_DBG("sdio_ireg = 0x%x", sdio_ireg);
+
+		sdio_writeb(card->func, ~(sdio_ireg) & (DN_LD_HOST_INT_STATUS |
+							UP_LD_HOST_INT_STATUS),
+			    HOST_INTSTATUS_REG, &ret);
+		if (ret) {
+			BT_ERR("sdio_writeb: clear int status register "
+				"failed");
+			ret = -EIO;
+			goto done;
+		}
+	}
+
+	if (sdio_ireg & DN_LD_HOST_INT_STATUS) {
+		if (priv->btmrvl_dev.tx_dnld_rdy)
+			BT_DBG("tx_done already received: "
+				" int_status=0x%x", sdio_ireg);
+		else
+			priv->btmrvl_dev.tx_dnld_rdy = true;
+	}
+
+	if (sdio_ireg & UP_LD_HOST_INT_STATUS)
+		btmrvl_sdio_card_to_host(priv);
+
+	*ireg = sdio_ireg;
+
+	ret = 0;
+
+done:
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static void btmrvl_sdio_interrupt(struct sdio_func *func)
+{
+	struct btmrvl_private *priv;
+	struct hci_dev *hcidev;
+	struct btmrvl_sdio_card *card;
+	u8 ireg = 0;
+
+	BT_DBG("Enter");
+
+	card = sdio_get_drvdata(func);
+	if (card && card->priv) {
+		priv = card->priv;
+		hcidev = priv->btmrvl_dev.hcidev;
+
+		if (btmrvl_sdio_get_int_status(priv, &ireg))
+			BT_ERR("reading HOST_INT_STATUS_REG failed");
+		else
+			BT_DBG("HOST_INT_STATUS_REG %#x", ireg);
+
+		btmrvl_interrupt(priv);
+	}
+
+	BT_DBG("Leave");
+}
+
+static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
+{
+	int ret = 0, i;
+	u8 reg;
+	struct sdio_func *func;
+
+	BT_DBG("Enter");
+
+	if (!card || !card->func) {
+		BT_ERR("Error: card or function is NULL!");
+		ret = -EINVAL;
+		goto failed;
+	}
+
+	func = card->func;
+
+	for (i = 0; i < ARRAY_SIZE(btmrvl_sdio_devices); i++) {
+		if (func->device == btmrvl_sdio_devices[i].dev_id)
+			break;
+	}
+
+	if (i == ARRAY_SIZE(btmrvl_sdio_devices)) {
+		BT_ERR("Error: unknown device id 0x%x", func->device);
+		ret = -EINVAL;
+		goto failed;
+	}
+
+	card->helper = btmrvl_sdio_devices[i].helper;
+	card->firmware = btmrvl_sdio_devices[i].firmware;
+
+	sdio_claim_host(func);
+
+	ret = sdio_enable_func(func);
+	if (ret) {
+		BT_ERR("sdio_enable_func() failed: ret=%d", ret);
+		ret = -EIO;
+		goto release_host;
+	}
+
+	ret = sdio_claim_irq(func, btmrvl_sdio_interrupt);
+	if (ret) {
+		BT_ERR("sdio_claim_irq failed: ret=%d", ret);
+		ret = -EIO;
+		goto disable_func;
+	}
+
+	ret = sdio_set_block_size(card->func, SDIO_BLOCK_SIZE);
+	if (ret) {
+		BT_ERR("cannot set SDIO block size");
+		ret = -EIO;
+		goto release_irq;
+	}
+
+	reg = sdio_readb(func, IO_PORT_0_REG, &ret);
+	if (ret < 0) {
+		ret = -EIO;
+		goto release_irq;
+	}
+
+	card->ioport = reg;
+
+	reg = sdio_readb(func, IO_PORT_1_REG, &ret);
+	if (ret < 0) {
+		ret = -EIO;
+		goto release_irq;
+	}
+
+	card->ioport |= (reg << 8);
+
+	reg = sdio_readb(func, IO_PORT_2_REG, &ret);
+	if (ret < 0) {
+		ret = -EIO;
+		goto release_irq;
+	}
+
+	card->ioport |= (reg << 16);
+
+	BT_DBG("SDIO FUNC%d IO port: 0x%x", func->num, card->ioport);
+
+	sdio_set_drvdata(func, card);
+
+	sdio_release_host(func);
+
+	BT_DBG("Leave");
+	return 0;
+
+release_irq:
+	sdio_release_irq(func);
+
+disable_func:
+	sdio_disable_func(func);
+
+release_host:
+	sdio_release_host(func);
+
+failed:
+	BT_DBG("Leave");
+	return ret;
+}
+
+static int btmrvl_sdio_unregister_dev(struct btmrvl_sdio_card *card)
+{
+	BT_DBG("Enter");
+
+	if (card && card->func) {
+		sdio_claim_host(card->func);
+		sdio_release_irq(card->func);
+		sdio_disable_func(card->func);
+		sdio_release_host(card->func);
+		sdio_set_drvdata(card->func, NULL);
+	}
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+static int btmrvl_sdio_enable_host_int(struct btmrvl_sdio_card *card)
+{
+	int ret;
+
+	BT_DBG("Enter");
+
+	if (!card || !card->func) {
+		BT_DBG("Leave");
+		return -EINVAL;
+	}
+
+	sdio_claim_host(card->func);
+
+	ret = btmrvl_sdio_enable_host_int_mask(card, HIM_ENABLE);
+
+	btmrvl_sdio_get_rx_unit(card);
+
+	sdio_release_host(card->func);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_disable_host_int(struct btmrvl_sdio_card *card)
+{
+	int ret;
+
+	BT_DBG("Enter");
+
+	if (!card || !card->func) {
+		BT_DBG("Leave");
+		return -EINVAL;
+	}
+
+	sdio_claim_host(card->func);
+
+	ret = btmrvl_sdio_disable_host_int_mask(card, HIM_DISABLE);
+
+	sdio_release_host(card->func);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
+				u8 *payload, u16 nb)
+{
+	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
+	int ret = 0;
+	int buf_block_len;
+	int blksz;
+	int i = 0;
+	u8 *buf = NULL;
+	void *tmpbuf = NULL;
+	int tmpbufsz;
+
+	BT_DBG("Enter");
+
+	if (!card || !card->func) {
+		BT_ERR("card or function is NULL!");
+		BT_DBG("Leave");
+		return -EINVAL;
+	}
+
+	buf = payload;
+	if ((u32) payload & (BTSDIO_DMA_ALIGN - 1)) {
+		tmpbufsz = ALIGN_SZ(nb, BTSDIO_DMA_ALIGN);
+		tmpbuf = kmalloc(tmpbufsz, GFP_KERNEL);
+		memset(tmpbuf, 0, tmpbufsz);
+		buf = (u8 *) ALIGN_ADDR(tmpbuf, BTSDIO_DMA_ALIGN);
+		memcpy(buf, payload, nb);
+	}
+
+	blksz = SDIO_BLOCK_SIZE;
+	buf_block_len = (nb + blksz - 1) / blksz;
+
+	sdio_claim_host(card->func);
+
+	do {
+		/* Transfer data to card */
+		ret = sdio_writesb(card->func, card->ioport, buf,
+				   buf_block_len * blksz);
+		if (ret < 0) {
+			i++;
+			BT_ERR("i=%d writesb failed: %d", i, ret);
+			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
+						payload, nb);
+			ret = -EIO;
+			if (i > MAX_WRITE_IOMEM_RETRY)
+				goto exit;
+		}
+	} while (ret);
+
+	priv->btmrvl_dev.tx_dnld_rdy = false;
+
+exit:
+	sdio_release_host(card->func);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
+{
+	int ret = 0;
+
+	BT_DBG("Enter");
+
+	if (!card || !card->func) {
+		BT_ERR("card or function is NULL!");
+		BT_DBG("Leave");
+		return -EINVAL;
+	}
+	sdio_claim_host(card->func);
+
+	if (!btmrvl_sdio_verify_fw_download(card, 1)) {
+		BT_DBG("Firmware already downloaded!");
+		goto done;
+	}
+
+	ret = btmrvl_sdio_download_helper(card);
+	if (ret) {
+		BT_ERR("Failed to download helper!");
+		ret = -EIO;
+		goto done;
+	}
+
+	if (btmrvl_sdio_download_fw_w_helper(card)) {
+		BT_ERR("Failed to download firmware!");
+		ret = -EIO;
+		goto done;
+	}
+
+	if (btmrvl_sdio_verify_fw_download(card, MAX_POLL_TRIES)) {
+		BT_ERR("FW failed to be active in time!");
+		ret = -ETIMEDOUT;
+		goto done;
+	}
+
+done:
+	sdio_release_host(card->func);
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
+{
+	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
+	int ret = 0;
+
+	BT_DBG("Enter");
+
+	if (!card || !card->func) {
+		BT_ERR("card or function is NULL!");
+		BT_DBG("Leave");
+		return -EINVAL;
+	}
+
+	sdio_claim_host(card->func);
+
+	sdio_writeb(card->func, HOST_POWER_UP, CONFIG_REG, &ret);
+
+	sdio_release_host(card->func);
+
+	BT_DBG("wake up firmware");
+
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static int btmrvl_sdio_probe(struct sdio_func *func,
+			     const struct sdio_device_id *id)
+{
+	int ret = 0;
+	struct btmrvl_private *priv = NULL;
+	struct btmrvl_sdio_card *card = NULL;
+
+	BT_DBG("Enter");
+
+	BT_INFO("vendor=0x%x, device=0x%x, class=%d, fn=%d",
+			id->vendor, id->device, id->class, func->num);
+
+	card = kzalloc(sizeof(*card), GFP_KERNEL);
+	if (!card) {
+		ret = -ENOMEM;
+		goto done;
+	}
+
+	card->func = func;
+
+	if (btmrvl_sdio_register_dev(card) < 0) {
+		BT_ERR("Failed to register BT device!");
+		ret = -ENODEV;
+		goto free_card;
+	}
+
+	/* Disable the interrupts on the card */
+	btmrvl_sdio_disable_host_int(card);
+
+	if (btmrvl_sdio_download_fw(card)) {
+		BT_ERR("Downloading firmware failed!");
+		ret = -ENODEV;
+		goto unreg_dev;
+	}
+
+	msleep(100);
+
+	btmrvl_sdio_enable_host_int(card);
+
+	priv = btmrvl_add_card(card);
+	if (!priv) {
+		BT_ERR("Initializing card failed!");
+		ret = -ENODEV;
+		goto disable_host_int;
+	}
+
+	card->priv = priv;
+
+	/* Initialize the interface specific function pointers */
+	priv->hw_host_to_card = btmrvl_sdio_host_to_card;
+	priv->hw_wakeup_firmware = btmrvl_sdio_wakeup_fw;
+
+	strncpy(priv->btmrvl_dev.name, "btmrvl_sdio0",
+			sizeof(priv->btmrvl_dev.name));
+
+	btmrvl_send_module_cfg_cmd(priv, MODULE_BRINGUP_REQ);
+
+	BT_DBG("Leave");
+
+	return 0;
+
+disable_host_int:
+	btmrvl_sdio_disable_host_int(card);
+unreg_dev:
+	btmrvl_sdio_unregister_dev(card);
+free_card:
+	kfree(card);
+done:
+	BT_DBG("Leave");
+
+	return ret;
+}
+
+static void btmrvl_sdio_remove(struct sdio_func *func)
+{
+	struct btmrvl_sdio_card *card;
+
+	BT_DBG("Enter");
+
+	if (func) {
+		card = sdio_get_drvdata(func);
+		if (card) {
+			/* Send SHUTDOWN command & disable interrupt
+			 * if user removes the module.
+			 */
+			if (user_rmmod) {
+				btmrvl_send_module_cfg_cmd(card->priv,
+							MODULE_SHUTDOWN_REQ);
+				btmrvl_sdio_disable_host_int(card);
+			}
+			BT_DBG("unregester dev");
+			btmrvl_sdio_unregister_dev(card);
+			btmrvl_remove_card(card->priv);
+			kfree(card);
+		}
+	}
+
+	BT_DBG("Leave");
+}
+
+static struct sdio_driver bt_mrvl_sdio = {
+	.name		= "btmrvl_sdio",
+	.id_table	= btmrvl_sdio_ids,
+	.probe		= btmrvl_sdio_probe,
+	.remove		= btmrvl_sdio_remove,
+};
+
+static int btmrvl_sdio_init_module(void)
+{
+	BT_DBG("Enter");
+
+	if (sdio_register_driver(&bt_mrvl_sdio) != 0) {
+		BT_ERR("SDIO Driver Registration Failed");
+		BT_DBG("Leave");
+		return -ENODEV;
+	}
+
+	/* Clear the flag in case user removes the card. */
+	user_rmmod = 0;
+
+	BT_DBG("Leave");
+
+	return 0;
+}
+
+static void btmrvl_sdio_exit_module(void)
+{
+	BT_DBG("Enter");
+
+	/* Set the flag as user is removing this module. */
+	user_rmmod = 1;
+
+	sdio_unregister_driver(&bt_mrvl_sdio);
+
+	BT_DBG("Leave");
+}
+
+module_init(btmrvl_sdio_init_module);
+module_exit(btmrvl_sdio_exit_module);
+
+MODULE_AUTHOR("Marvell International Ltd.");
+MODULE_DESCRIPTION("Marvell BT-over-SDIO Driver v" VERSION);
+MODULE_VERSION(VERSION);
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/bluetooth/btmrvl_sdio.h b/drivers/bluetooth/btmrvl_sdio.h
new file mode 100644
index 0000000..08bef33
--- /dev/null
+++ b/drivers/bluetooth/btmrvl_sdio.h
@@ -0,0 +1,113 @@
+/**
+ * Marvell BT-over-SDIO driver: SDIO interface related definitions
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
+ **/
+
+#ifndef _BTMRVL_SDIO_H_
+#define _BTMRVL_SDIO_H_
+
+#define SDIO_HEADER_LEN			4
+
+/* SD block size can not bigger than 64 due to buf size limit in firmware */
+/* define SD block size for data Tx/Rx */
+#define SDIO_BLOCK_SIZE			64
+
+/* Number of blocks for firmware transfer */
+#define FIRMWARE_TRANSFER_NBLOCK	2
+
+/* This is for firmware specific length */
+#define FW_EXTRA_LEN			36
+
+#define MRVDRV_SIZE_OF_CMD_BUFFER       (2 * 1024)
+
+#define MRVDRV_BT_RX_PACKET_BUFFER_SIZE \
+	(HCI_MAX_FRAME_SIZE + FW_EXTRA_LEN)
+
+#define ALLOC_BUF_SIZE	(((max_t (int, MRVDRV_BT_RX_PACKET_BUFFER_SIZE, \
+			MRVDRV_SIZE_OF_CMD_BUFFER) + SDIO_HEADER_LEN \
+			+ SDIO_BLOCK_SIZE - 1) / SDIO_BLOCK_SIZE) \
+			* SDIO_BLOCK_SIZE)
+
+/* The number of times to try when polling for status */
+#define MAX_POLL_TRIES			100
+
+/* Max retry number of CMD53 write */
+#define MAX_WRITE_IOMEM_RETRY		2
+
+/* Host Control Registers */
+#define IO_PORT_0_REG			0x00
+#define IO_PORT_1_REG			0x01
+#define IO_PORT_2_REG			0x02
+
+#define CONFIG_REG			0x03
+#define HOST_POWER_UP			BIT(1)
+#define HOST_CMD53_FIN			BIT(2)
+
+#define HOST_INT_MASK_REG		0x04
+#define HIM_DISABLE			0xff
+#define HIM_ENABLE			(BIT(0) | BIT(1))
+
+#define HOST_INTSTATUS_REG		0x05
+#define UP_LD_HOST_INT_STATUS		BIT(0)
+#define DN_LD_HOST_INT_STATUS		BIT(1)
+
+/* Card Control Registers */
+#define SQ_READ_BASE_ADDRESS_A0_REG  	0x10
+#define SQ_READ_BASE_ADDRESS_A1_REG  	0x11
+
+#define CARD_STATUS_REG              	0x20
+#define DN_LD_CARD_RDY               	BIT(0)
+#define CARD_IO_READY              	BIT(3)
+
+#define CARD_FW_STATUS0_REG		0x40
+#define CARD_FW_STATUS1_REG		0x41
+#define FIRMWARE_READY			0xfedc
+
+#define CARD_RX_LEN_REG			0x42
+#define CARD_RX_UNIT_REG		0x43
+
+
+struct btmrvl_sdio_card {
+	struct sdio_func *func;
+	u32 ioport;
+	const char *helper;
+	const char *firmware;
+	u8 rx_unit;
+	struct btmrvl_private *priv;
+};
+
+struct btmrvl_sdio_device {
+	unsigned short dev_id;
+	const char *helper;
+	const char *firmware;
+};
+
+
+/* Platform specific DMA alignment */
+#define BTSDIO_DMA_ALIGN		8
+
+/* Macros for Data Alignment : size */
+#define ALIGN_SZ(p, a)	\
+	(((p) + ((a) - 1)) & ~((a) - 1))
+
+/* Macros for Data Alignment : address */
+#define ALIGN_ADDR(p, a)	\
+	((((u32)(p)) + (((u32)(a)) - 1)) & ~(((u32)(a)) - 1))
+
+#endif /* _BTMRVL_SDIO_H_ */
-- 
1.6.2.5

