From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 22/47] Bluetooth: Fix incorrect alignment in Marvell BT-over-SDIO driver
Date: Sun, 30 Aug 2009 01:50:36 -0700
Message-ID: <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
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
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53304 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbZH3IwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:17 -0400
In-Reply-To: <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bing Zhao <bzhao@marvell.com>

The driver uses "u32" for alignment check and calculation which
works only on 32-bit system. It will crash the 64-bit system.
Replace "u32" with "unsigned long" to fix this issue.

Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_sdio.c |   12 +++++++-----
 drivers/bluetooth/btmrvl_sdio.h |    3 ++-
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 224af53..1cfa8b4 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -481,12 +481,14 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 		goto exit;
 	}
 
-	if ((u32) skb->data & (BTSDIO_DMA_ALIGN - 1)) {
-		skb_put(skb, (u32) skb->data & (BTSDIO_DMA_ALIGN - 1));
-		skb_pull(skb, (u32) skb->data & (BTSDIO_DMA_ALIGN - 1));
+	if ((unsigned long) skb->data & (BTSDIO_DMA_ALIGN - 1)) {
+		skb_put(skb, (unsigned long) skb->data &
+					(BTSDIO_DMA_ALIGN - 1));
+		skb_pull(skb, (unsigned long) skb->data &
+					(BTSDIO_DMA_ALIGN - 1));
 	}
 
-	payload = skb->tail;
+	payload = skb->data;
 
 	ret = sdio_readsb(card->func, payload, card->ioport,
 			  buf_block_len * blksz);
@@ -773,7 +775,7 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 	}
 
 	buf = payload;
-	if ((u32) payload & (BTSDIO_DMA_ALIGN - 1)) {
+	if ((unsigned long) payload & (BTSDIO_DMA_ALIGN - 1)) {
 		tmpbufsz = ALIGN_SZ(nb, BTSDIO_DMA_ALIGN);
 		tmpbuf = kmalloc(tmpbufsz, GFP_KERNEL);
 		memset(tmpbuf, 0, tmpbufsz);
diff --git a/drivers/bluetooth/btmrvl_sdio.h b/drivers/bluetooth/btmrvl_sdio.h
index 2dd284e..27329f1 100644
--- a/drivers/bluetooth/btmrvl_sdio.h
+++ b/drivers/bluetooth/btmrvl_sdio.h
@@ -104,4 +104,5 @@ struct btmrvl_sdio_device {
 
 /* Macros for Data Alignment : address */
 #define ALIGN_ADDR(p, a)	\
-	((((u32)(p)) + (((u32)(a)) - 1)) & ~(((u32)(a)) - 1))
+	((((unsigned long)(p)) + (((unsigned long)(a)) - 1)) & \
+					~(((unsigned long)(a)) - 1))
-- 
1.6.2.5

