From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] : CDC EEM driver patch to be applied to 2.6.30 kernel
Date: Sun, 3 May 2009 17:13:58 -0700
Message-ID: <200905031713.58762.david-b@pacbell.net>
References: <3a98b4410904270912g1838b534j2b53561b8caa1543@mail.gmail.com> <20090428.044419.246576457.davem@davemloft.net> <3a98b4410904280747x55be4a51y8043f827b93d0a80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Omar Laazimani <omar.oberthur@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:24476 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753420AbZEDAOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 20:14:05 -0400
In-Reply-To: <3a98b4410904280747x55be4a51y8043f827b93d0a80@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I took a look at your v4 patch against the EEM spec,
and it looks much better.  However, see the appended
patch ... can you verify that this didn't break things?

If this is OK, I can merge these fixups and submit the
resulting patch.

Also, it would be good if you could add (maybe not right
away) the TX side support for zero length EEM packets.
The current behavior for transfers taking exactly N USB
packets isn't strictly conformant.

Thanks.

- Dave

============== CUT HERE
Various fixes in the proposed EEM driver:

 - Framing tweaks:
     * Use ETH_FCS_LEN not EEM_TAIL (trailer is the FCS or 0xdeadbeef)
     * Update hard_header_len to include EEM_HEAD and ETH_FCS_LEN
 - Tighten handling of link layer commands
     * Free "echo" SKBs correctly
     * Insist the reserved bit is zero (per EEM spec)
     * Don't leak SKBs for non-echo commands
     * Stub handling for non-echo commands (some trigger warnings)
 - Zero length EEM packet support:
     * Handle on RX side
     * Add FIXME for TX side
 - Other bugfixes
     * Avoid false increments of rx_error count
     * Check for various bogus packet conditions
     * Make eem_unbind() static
 - Cosmetic
     * Rename the link command utilities
     * Comments
     * Whitespace

---
 drivers/net/usb/cdc_eem.c |  236 ++++++++++++++++++++++++++++----------------
 1 file changed, 153 insertions(+), 83 deletions(-)

--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -31,11 +31,13 @@
 #include <linux/usb/cdc.h>
 #include <linux/usb/usbnet.h>
 
+
 /*
- * This module encapsulates Ethernet frames for transport
- * across the USB bus.
+ * This driver is an implementation of the CDC "Ethernet Emulation
+ * Model" (EEM) specification, which encapsulates Ethernet frames
+ * for transport over USB using a simpler USB device model than the
+ * previous CDC "Ethernet Control Model" (ECM).
  *
- * This driver is a first implementation for CDC EEM specification.
  * For more details, see www.usb.org/developers/devclass_docs/CDC_EEM10.pdf
  *
  * This version has been tested with GIGAntIC WuaoW SIM Smart Card on 2.6.24,
@@ -44,45 +46,34 @@
  * build on 23-April-2009
  */
 
-
-#define EEM_HEAD  2       /* 2 byte header */
-#define EEM_TAIL  4       /* 4 byte crc tail */
-
-#define EEM_MAX_PACKET	(ETH_FRAME_LEN + EEM_HEAD + EEM_TAIL)
-
+#define EEM_HEAD	2		/* 2 byte header */
 
 /*-------------------------------------------------------------------------*/
 
-static void eem_transmit_complete(struct urb *urb)
+static void eem_linkcmd_complete(struct urb *urb)
 {
-	kfree(urb->context);
+	dev_kfree_skb(urb->context);
 	usb_free_urb(urb);
 }
 
-static void eem_transmit(struct usbnet *dev, struct sk_buff *skb)
+static void eem_linkcmd(struct usbnet *dev, struct sk_buff *skb)
 {
 	struct urb		*urb;
 	int			status;
-	struct skb_data		*entry;
-	int			length;
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb)
-		return;
-
-	length = skb->len;
-
-	entry = (struct skb_data *) skb->cb;
-	entry->urb = urb;
-	entry->dev = dev;
-	entry->length = length;
+		goto fail;
 
 	usb_fill_bulk_urb(urb, dev->udev, dev->out,
-			skb->data, skb->len, eem_transmit_complete, skb);
+			skb->data, skb->len, eem_linkcmd_complete, skb);
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status) {
 		usb_free_urb(urb);
+fail:
+		dev_kfree_skb(skb);
+		devwarn(dev, "link cmd failure\n");
 		return;
 	}
 }
@@ -98,10 +89,14 @@ static int eem_bind(struct usbnet *dev, 
 		return status;
 	}
 
+	/* no jumbogram (16K) support for now */
+
+	dev->net->hard_header_len += EEM_HEAD + ETH_FCS_LEN;
+
 	return 0;
 }
 
-void eem_unbind(struct usbnet *dev, struct usb_interface *intf)
+static void eem_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct cdc_state	*info = (void *) &dev->data;
 	struct usb_driver	*driver = driver_of(intf);
@@ -117,7 +112,10 @@ void eem_unbind(struct usbnet *dev, stru
 	}
 }
 
-
+/*
+ * EEM permits packing multiple Ethernet frames into USB transfers
+ * (a "bundle"), but for TX we don't try to do that.
+ */
 static struct sk_buff *eem_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 				       gfp_t flags)
 {
@@ -125,19 +123,19 @@ static struct sk_buff *eem_tx_fixup(stru
 	u16		len = skb->len;
 	u32		crc = 0;
 
-	/* EEM packet header format:
-	 * b0..13:	length of ethernet frame
-	 * b14:		bmCRC
-	 * b15:		bmType
+	/* FIXME when ((len + EEM_HEAD + ETH_FCS_LEN) % dev->maxpacket)
+	 * is zero, stick two bytes of zero length EEM packet on the end
+	 * (so the framework won't add invalid single byte padding).
 	 */
+
 	if (!skb_cloned(skb)) {
 		int	headroom = skb_headroom(skb);
 		int	tailroom = skb_tailroom(skb);
 
-		if ((tailroom >= EEM_TAIL) && (headroom >= EEM_HEAD))
+		if ((tailroom >= ETH_FCS_LEN) && (headroom >= EEM_HEAD))
 			goto done;
 
-		if ((headroom + tailroom) > (EEM_TAIL + EEM_HEAD)) {
+		if ((headroom + tailroom) > (ETH_FCS_LEN + EEM_HEAD)) {
 			skb->data = memmove(skb->head +
 					EEM_HEAD,
 					skb->data,
@@ -147,7 +145,7 @@ static struct sk_buff *eem_tx_fixup(stru
 		}
 	}
 
-	skb2 = skb_copy_expand(skb, EEM_HEAD, EEM_TAIL, flags);
+	skb2 = skb_copy_expand(skb, EEM_HEAD, ETH_FCS_LEN, flags);
 	if (!skb2)
 		return NULL;
 
@@ -155,11 +153,17 @@ static struct sk_buff *eem_tx_fixup(stru
 	skb = skb2;
 
 done:
+	/* we don't use the "no Ethernet CRC" option */
 	crc = crc32_le(~0, skb->data, skb->len);
 	crc = ~crc;
 
 	put_unaligned_le32(crc, skb_put(skb, 4));
 
+	/* EEM packet header format:
+	 * b0..13:	length of ethernet frame
+	 * b14:		bmCRC (1 == valid Ethernet CRC)
+	 * b15:		bmType (0 == data)
+	 */
 	len = skb->len;
 	put_unaligned_le16(BIT(14) | len, skb_push(skb, 2));
 
@@ -168,12 +172,26 @@ done:
 
 static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
-	struct sk_buff	*skb2 = NULL;
-	u32 		crc;
-	u16		len, header;
-	u16 		bmEEMCmd;
-
+	/*
+	 * Our task here is to strip off framing, leaving skb with one
+	 * data frame for the usbnet framework code to process.  But we
+	 * may have received multiple EEM payloads, or command payloads.
+	 * So we must process _everything_ as if it's a header, except
+	 * maybe the last data payload
+	 *
+	 * REVISIT the framework needs updating so that when we consume
+	 * all payloads (the last or only message was a command, or a
+	 * zero length EEM packet) that is not accounted as an rx_error.
+	 */
 	do {
+		struct sk_buff	*skb2 = NULL;
+		u16		header;
+		u16		len = 0;
+
+		/* incomplete EEM header? */
+		if (skb->len < EEM_HEAD)
+			return 0;
+
 		/*
 		 * EEM packet header format:
 		 * b0..14:	EEM type dependant (Data or Command)
@@ -186,78 +204,130 @@ static int eem_rx_fixup(struct usbnet *d
 		 * The bmType bit helps to denote when EEM
 		 * packet is data or command :
 		 *	bmType = 0	: EEM data payload
-		 *	bmType = 1	: EEM command
+		 *	bmType = 1	: EEM (link) command
 		 */
 		if (header & BIT(15)) {
+			u16	bmEEMCmd;
+
 			/*
-			 * EEM command packet:
+			 * EEM (link) command packet:
 			 * b0..10:	bmEEMCmdParam
 			 * b11..13:	bmEEMCmd
-			 * b14:		bmReserved (0 by default)
-			 * b15:		1
+			 * b14:		bmReserved (must be 0)
+			 * b15:		1 (EEM command)
 			 */
+			if (header & BIT(14)) {
+				devdbg(dev, "reserved command %04x\n", header);
+				continue;
+			}
 
-			skb2 = skb_clone(skb, GFP_ATOMIC);
-			if (unlikely(!skb2))
-				goto Continue;
+			bmEEMCmd = (header >> 11) & 0x7;
+			switch (bmEEMCmd) {
 
-			bmEEMCmd = (BIT(11) & header)
-				| (BIT(12) & header)
-				| (BIT(13) & header);
+			/* Responding to echo requests is mandatory. */
+			case 0:		/* Echo command */
+				len = header & 0x7FF;
+
+				/* bogus command? */
+				if (skb->len < len)
+					return 0;
+
+				skb2 = skb_clone(skb, GFP_ATOMIC);
+				if (unlikely(!skb2))
+					goto next;
+				skb_trim(skb2, len);
+				put_unaligned_le16(BIT(15) | (1 << 11) | len,
+						skb_push(skb2, 2));
+				eem_linkcmd(dev, skb2);
+				break;
 
 			/*
-			 * Only answer to Echo command. Host may
-			 * choose to ignore other commands (see CDC EEM spec.)
+			 * Host may choose to ignore hints.
+			 *  - suspend: peripheral ready to suspend
+			 *  - response: suggest N millisec polling
+			 *  - response complete: suggest N sec polling
 			 */
-			if (bmEEMCmd == 0) { /* Echo command */
-				len = header & 0x7FF;
-				skb_trim(skb2, len);
-				put_unaligned_le16(BIT(15) | BIT(11) | len
-						, skb_push(skb2, 2));
-				eem_transmit(dev, skb2);
-			} else
-				len = 0; /* length of other commands */
+			case 2:		/* Suspend hint */
+			case 3:		/* Response hint */
+			case 4:		/* Response complete hint */
+				continue;
+
+			/*
+			 * Hosts should never receive host-to-peripheral
+			 * or reserved command codes; or responses to
+			 * echo commands we didn't sent.
+			 */
+			case 1:		/* Echo response */
+			case 5:		/* Tickle */
+			case 6:		/* reserved */
+			case 7:		/* reserved */
+				devwarn(dev, "unexpected link command %d\n",
+						bmEEMCmd);
+				continue;
+			}
 
 		} else {
+			u32	crc, crc2;
+			int	is_last;
+
+			/* zero length EEM packet? */
+			if (header == 0)
+				continue;
+
 			/*
 			 * EEM data packet header :
 			 * b0..13:	length of ethernet frame
 			 * b14:		bmCRC
-			 * b15:		0
+			 * b15:		0 (EEM data)
 			 */
 			len = header & 0x3FFF;
 
-			skb2 = skb_clone(skb, GFP_ATOMIC);
-			if (unlikely(!skb2))
-				goto Continue;
+			/* bogus EEM payload? */
+			if (skb->len < len)
+				return 0;
 
-			crc = get_unaligned_le32(skb2->data + len - EEM_TAIL);
-			skb_trim(skb2, len - EEM_TAIL);
+			/* bogus ethernet frame? */
+			if (len < (ETH_HLEN + ETH_FCS_LEN))
+				goto next;
 
 			/*
-			 * The bmCRC helps to denote when the CRC
-			 * field contains a calculated CRC :
+			 * Unless this is the last EEM payload, we need
+			 * to keep "skb" for further processing instead
+			 * of letting the framework handle it.
+			 */
+			is_last = (len == skb->len);
+			if (is_last)
+				skb2 = skb;
+			else {
+				skb2 = skb_clone(skb, GFP_ATOMIC);
+				if (unlikely(!skb2))
+					return 0;
+			}
+
+			crc = get_unaligned_le32(skb2->data + len - ETH_FCS_LEN);
+			skb_trim(skb2, len - ETH_FCS_LEN);
+
+			/*
+			 * The bmCRC helps to denote when the CRC field in
+			 * the Ethernet frame contains a calculated CRC:
 			 *	bmCRC = 1	: CRC is calculated
 			 *	bmCRC = 0	: CRC = 0xDEADBEEF
 			 */
-			if (header & BIT(14)) {
-				u32 crc2;
-				crc2 = crc32_le(~0, skb2->data, len);
-				crc2 = ~crc2;
-				if (unlikely(crc != crc2)) {
-					dev->stats.rx_errors++;
-					goto Continue;
-				}
-			} else {
-				if (unlikely(crc != 0xdeadbeef)) {
-					dev->stats.rx_errors++;
-					goto Continue;
-				}
-			}
+			if (header & BIT(14))
+				crc2 = ~crc32_le(~0, skb2->data, len);
+			else
+				crc2 = 0xdeadbeef;
 
-			usbnet_skb_return(dev, skb2);
+			if (is_last)
+				return crc == crc2;
+
+			if (unlikely(crc != crc2)) {
+				dev->stats.rx_errors++;
+			} else
+				usbnet_skb_return(dev, skb2);
 		}
-Continue:
+
+next:
 		skb_pull(skb, len);
 	} while (skb->len);
 
@@ -269,7 +339,7 @@ static const struct driver_info	eem_info
 	.flags =	FLAG_ETHER,
 	.bind =		eem_bind,
 	.unbind =	eem_unbind,
-	.rx_fixup = 	eem_rx_fixup,
+	.rx_fixup =	eem_rx_fixup,
 	.tx_fixup =	eem_tx_fixup,
 };
 
@@ -307,6 +377,6 @@ static void __exit eem_exit(void)
 }
 module_exit(eem_exit);
 
-MODULE_AUTHOR("Omar Laazimani <omar.oberthur <at> gmail.com>");
+MODULE_AUTHOR("Omar Laazimani <omar.oberthur@gmail.com>");
 MODULE_DESCRIPTION("USB CDC EEM");
 MODULE_LICENSE("GPL");
