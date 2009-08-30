From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 16/47] Bluetooth: Fix complicated assignment of firmware for Marvell devices
Date: Sun, 30 Aug 2009 01:50:30 -0700
Message-ID: <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53293 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbZH3IwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:10 -0400
In-Reply-To: <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell Bluetooth SDIO driver has a really complicated concept on how
firmware names are assigned to specific device ids. Fix that by doing a
proper structure and assign it to the module device table.

And while at it fix various coding style weirdness that is still present
in this driver.

Signed-off-by: Marcel Holtman <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_sdio.c |   90 ++++++++++++++++----------------------
 drivers/bluetooth/btmrvl_sdio.h |    1 -
 2 files changed, 38 insertions(+), 53 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 8f13e7b..867ebe4 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -31,10 +31,6 @@
 
 #define VERSION "1.0"
 
-#ifndef SDIO_DEVICE_ID_MARVELL_8688BT
-#define SDIO_DEVICE_ID_MARVELL_8688BT		0x9105
-#endif
-
 /* The btmrvl_sdio_remove() callback function is called
  * when user removes this module from kernel space or ejects
  * the card from the slot. The driver handles these 2 cases
@@ -51,21 +47,21 @@
  */
 static u8 user_rmmod;
 
-static const struct sdio_device_id btmrvl_sdio_ids[] = {
-	{SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, SDIO_DEVICE_ID_MARVELL_8688BT)},
-	{0, 0, 0, 0}
+static const struct btmrvl_sdio_device btmrvl_sdio_sd6888 = {
+	.helper		= "sd8688_helper.bin",
+	.firmware	= "sd8688.bin",
 };
 
-MODULE_DEVICE_TABLE(sdio, btmrvl_sdio_ids);
+static const struct sdio_device_id btmrvl_sdio_ids[] = {
+	/* Marvell SD8688 Bluetooth device */
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x9105),
+			.driver_data = (unsigned long) &btmrvl_sdio_sd6888 },
 
-static struct btmrvl_sdio_device btmrvl_sdio_devices[] = {
-	{
-		.dev_id = SDIO_DEVICE_ID_MARVELL_8688BT,
-		.helper = "sd8688_helper.bin",
-		.firmware = "sd8688.bin",
-	},
+	{ }	/* Terminating entry */
 };
 
+MODULE_DEVICE_TABLE(sdio, btmrvl_sdio_ids);
+
 static int btmrvl_sdio_get_rx_unit(struct btmrvl_sdio_card *card)
 {
 	u8 reg;
@@ -125,7 +121,7 @@ static int btmrvl_sdio_read_rx_len(struct btmrvl_sdio_card *card, u16 *dat)
 }
 
 static int btmrvl_sdio_enable_host_int_mask(struct btmrvl_sdio_card *card,
-						u8 mask)
+								u8 mask)
 {
 	int ret;
 
@@ -143,7 +139,7 @@ static int btmrvl_sdio_enable_host_int_mask(struct btmrvl_sdio_card *card,
 }
 
 static int btmrvl_sdio_disable_host_int_mask(struct btmrvl_sdio_card *card,
-						u8 mask)
+								u8 mask)
 {
 	int ret;
 	u8 host_int_mask;
@@ -203,7 +199,7 @@ done:
 }
 
 static int btmrvl_sdio_verify_fw_download(struct btmrvl_sdio_card *card,
-						int pollnum)
+								int pollnum)
 {
 	int ret = -ETIMEDOUT;
 	u16 firmwarestat;
@@ -242,10 +238,10 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	BT_DBG("Enter");
 
 	ret = request_firmware(&fw_helper, card->helper,
-				&card->func->dev);
+						&card->func->dev);
 	if ((ret < 0) || !fw_helper) {
 		BT_ERR("request_firmware(helper) failed, error code = %d",
-			ret);
+									ret);
 		ret = -ENOENT;
 		goto done;
 	}
@@ -254,7 +250,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	helperlen = fw_helper->size;
 
 	BT_DBG("Downloading helper image (%d bytes), block size %d bytes",
-		helperlen, SDIO_BLOCK_SIZE);
+						helperlen, SDIO_BLOCK_SIZE);
 
 	tmphlprbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
 
@@ -301,10 +297,8 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 				tx_len);
 
 		/* Now send the data */
-		ret = sdio_writesb(card->func, card->ioport,
-				   helperbuf,
-				   FIRMWARE_TRANSFER_NBLOCK *
-				   SDIO_BLOCK_SIZE);
+		ret = sdio_writesb(card->func, card->ioport, helperbuf,
+				FIRMWARE_TRANSFER_NBLOCK * SDIO_BLOCK_SIZE);
 		if (ret < 0) {
 			BT_ERR("IO error during helper download @ %d",
 				hlprblknow);
@@ -319,7 +313,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	memset(helperbuf, 0x0, SDIO_BLOCK_SIZE);
 
 	ret = sdio_writesb(card->func, card->ioport, helperbuf,
-			 SDIO_BLOCK_SIZE);
+							SDIO_BLOCK_SIZE);
 	if (ret < 0) {
 		BT_ERR("IO error in writing helper image EOF block");
 		goto done;
@@ -352,10 +346,10 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	BT_DBG("Enter");
 
 	ret = request_firmware(&fw_firmware, card->firmware,
-				&card->func->dev);
+							&card->func->dev);
 	if ((ret < 0) || !fw_firmware) {
 		BT_ERR("request_firmware(firmware) failed, error code = %d",
-			ret);
+									ret);
 		ret = -ENOENT;
 		goto done;
 	}
@@ -383,10 +377,10 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	offset = 0;
 	do {
 		ret = btmrvl_sdio_poll_card_status(card,
-					    CARD_IO_READY | DN_LD_CARD_RDY);
+					CARD_IO_READY | DN_LD_CARD_RDY);
 		if (ret < 0) {
 			BT_ERR("FW download with helper poll status"
-				" timeout @ %d", offset);
+						" timeout @ %d", offset);
 			goto done;
 		}
 
@@ -427,7 +421,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 			break;
 		else if (len > BTM_UPLD_SIZE) {
 			BT_ERR("FW download failure @%d, invalid length %d",
-				offset, len);
+								offset, len);
 			ret = -EINVAL;
 			goto done;
 		}
@@ -465,9 +459,9 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 
 		if (ret < 0) {
 			BT_ERR("FW download, writesb(%d) failed @%d",
-				count, offset);
+							count, offset);
 			sdio_writeb(card->func, HOST_CMD53_FIN, CONFIG_REG,
-					&ret);
+									&ret);
 			if (ret)
 				BT_ERR("writeb failed (CFG)");
 		}
@@ -520,7 +514,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	buf_block_len = (buf_len + blksz - 1) / blksz;
 
 	if (buf_len <= SDIO_HEADER_LEN
-	    || (buf_block_len * blksz) > ALLOC_BUF_SIZE) {
+			|| (buf_block_len * blksz) > ALLOC_BUF_SIZE) {
 		BT_ERR("invalid packet length: %d", buf_len);
 		ret = -EINVAL;
 		goto exit;
@@ -528,7 +522,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 
 	/* Allocate buffer */
 	skb = bt_skb_alloc(buf_block_len * blksz + BTSDIO_DMA_ALIGN,
-				GFP_ATOMIC);
+								GFP_ATOMIC);
 	if (skb == NULL) {
 		BT_ERR("No free skb");
 		goto exit;
@@ -588,7 +582,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	default:
 		BT_ERR("Unknow packet type:%d", type);
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, payload,
-					blksz * buf_block_len);
+						blksz * buf_block_len);
 
 		kfree_skb(skb);
 		skb = NULL;
@@ -691,9 +685,9 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 
 static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 {
-	int ret = 0, i;
-	u8 reg;
 	struct sdio_func *func;
+	u8 reg;
+	int ret = 0;
 
 	BT_DBG("Enter");
 
@@ -705,20 +699,6 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 
 	func = card->func;
 
-	for (i = 0; i < ARRAY_SIZE(btmrvl_sdio_devices); i++) {
-		if (func->device == btmrvl_sdio_devices[i].dev_id)
-			break;
-	}
-
-	if (i == ARRAY_SIZE(btmrvl_sdio_devices)) {
-		BT_ERR("Error: unknown device id 0x%x", func->device);
-		ret = -EINVAL;
-		goto failed;
-	}
-
-	card->helper = btmrvl_sdio_devices[i].helper;
-	card->firmware = btmrvl_sdio_devices[i].firmware;
-
 	sdio_claim_host(func);
 
 	ret = sdio_enable_func(func);
@@ -983,7 +963,7 @@ static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
 }
 
 static int btmrvl_sdio_probe(struct sdio_func *func,
-			     const struct sdio_device_id *id)
+					const struct sdio_device_id *id)
 {
 	int ret = 0;
 	struct btmrvl_private *priv = NULL;
@@ -1002,6 +982,12 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 
 	card->func = func;
 
+	if (id->driver_data) {
+		struct btmrvl_sdio_device *data = (void *) id->driver_data;
+		card->helper   = data->helper;
+		card->firmware = data->firmware;
+	}
+
 	if (btmrvl_sdio_register_dev(card) < 0) {
 		BT_ERR("Failed to register BT device!");
 		ret = -ENODEV;
diff --git a/drivers/bluetooth/btmrvl_sdio.h b/drivers/bluetooth/btmrvl_sdio.h
index 6beb340..2dd284e 100644
--- a/drivers/bluetooth/btmrvl_sdio.h
+++ b/drivers/bluetooth/btmrvl_sdio.h
@@ -90,7 +90,6 @@ struct btmrvl_sdio_card {
 };
 
 struct btmrvl_sdio_device {
-	unsigned short dev_id;
 	const char *helper;
 	const char *firmware;
 };
-- 
1.6.2.5

