From: "Marius B. Kotsbak" <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net/usb: kalmia: Various fixes for better support of non-x86 architectures.
Date: Wed, 22 Jun 2011 17:26:16 +0200
Message-ID: <1308756376-9920-1-git-send-email-marius@kotsbak.com>
References: <20110619.155755.1854488306547854947.davem@davemloft.net>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110619.155755.1854488306547854947.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

-Support for big endian.
-Do not use USB buffers at the stack.
-Safer/more efficient code for local constants.

Signed-off-by: Marius B. Kotsbak <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/kalmia.c |   40 ++++++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
index d965fb1..d4edeb2 100644
--- a/drivers/net/usb/kalmia.c
+++ b/drivers/net/usb/kalmia.c
@@ -100,27 +100,35 @@ kalmia_send_init_packet(struct usbnet *dev, u8 *init_msg, u8 init_msg_len,
 static int
 kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
 {
-	char init_msg_1[] =
+	const static char init_msg_1[] =
 		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
 		0x00, 0x00 };
-	char init_msg_2[] =
+	const static char init_msg_2[] =
 		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
 		0x00, 0x00 };
-	char receive_buf[28];
+	const static int buflen = 28;
+	char *usb_buf;
 	int status;
 
-	status = kalmia_send_init_packet(dev, init_msg_1, sizeof(init_msg_1)
-		/ sizeof(init_msg_1[0]), receive_buf, 24);
+	usb_buf = kmalloc(buflen, GFP_DMA | GFP_KERNEL);
+	if (!usb_buf)
+		return -ENOMEM;
+
+	memcpy(usb_buf, init_msg_1, 12);
+	status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_1)
+		/ sizeof(init_msg_1[0]), usb_buf, 24);
 	if (status != 0)
 		return status;
 
-	status = kalmia_send_init_packet(dev, init_msg_2, sizeof(init_msg_2)
-		/ sizeof(init_msg_2[0]), receive_buf, 28);
+	memcpy(usb_buf, init_msg_2, 12);
+	status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_2)
+		/ sizeof(init_msg_2[0]), usb_buf, 28);
 	if (status != 0)
 		return status;
 
-	memcpy(ethernet_addr, receive_buf + 10, ETH_ALEN);
+	memcpy(ethernet_addr, usb_buf + 10, ETH_ALEN);
 
+	kfree(usb_buf);
 	return status;
 }
 
@@ -190,7 +198,8 @@ kalmia_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	dev_kfree_skb_any(skb);
 	skb = skb2;
 
-	done: header_start = skb_push(skb, KALMIA_HEADER_LENGTH);
+done:
+	header_start = skb_push(skb, KALMIA_HEADER_LENGTH);
 	ether_type_1 = header_start[KALMIA_HEADER_LENGTH + 12];
 	ether_type_2 = header_start[KALMIA_HEADER_LENGTH + 13];
 
@@ -201,9 +210,8 @@ kalmia_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	header_start[0] = 0x57;
 	header_start[1] = 0x44;
 	content_len = skb->len - KALMIA_HEADER_LENGTH;
-	header_start[2] = (content_len & 0xff); /* low byte */
-	header_start[3] = (content_len >> 8); /* high byte */
 
+	put_unaligned_le16(content_len, &header_start[2]);
 	header_start[4] = ether_type_1;
 	header_start[5] = ether_type_2;
 
@@ -231,13 +239,13 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	 * Our task here is to strip off framing, leaving skb with one
 	 * data frame for the usbnet framework code to process.
 	 */
-	const u8 HEADER_END_OF_USB_PACKET[] =
+	const static u8 HEADER_END_OF_USB_PACKET[] =
 		{ 0x57, 0x5a, 0x00, 0x00, 0x08, 0x00 };
-	const u8 EXPECTED_UNKNOWN_HEADER_1[] =
+	const static u8 EXPECTED_UNKNOWN_HEADER_1[] =
 		{ 0x57, 0x43, 0x1e, 0x00, 0x15, 0x02 };
-	const u8 EXPECTED_UNKNOWN_HEADER_2[] =
+	const static u8 EXPECTED_UNKNOWN_HEADER_2[] =
 		{ 0x57, 0x50, 0x0e, 0x00, 0x00, 0x00 };
-	u8 i = 0;
+	int i = 0;
 
 	/* incomplete header? */
 	if (skb->len < KALMIA_HEADER_LENGTH)
@@ -285,7 +293,7 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		/* subtract start header and end header */
 		usb_packet_length = skb->len - (2 * KALMIA_HEADER_LENGTH);
-		ether_packet_length = header_start[2] + (header_start[3] << 8);
+		ether_packet_length = get_unaligned_le16(&header_start[2]);
 		skb_pull(skb, KALMIA_HEADER_LENGTH);
 
 		/* Some small packets misses end marker */
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
