From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 6/6] networking: add and use skb_put_u8()
Date: Fri, 16 Jun 2017 14:29:24 +0200
Message-ID: <20170616122924.3557-7-johannes@sipsolutions.net>
References: <20170616122924.3557-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:32960 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753471AbdFPM3d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 08:29:33 -0400
In-Reply-To: <20170616122924.3557-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Joe and Bjørn suggested that it'd be nicer to not have the
cast in the fairly common case of doing
	*(u8 *)skb_put(skb, 1) = c;

Add skb_put_u8() for this case, and use it across the code,
using the following spatch:

    @@
    expression SKB, C, S;
    typedef u8;
    identifier fn = {skb_put};
    fresh identifier fn2 = fn ## "_u8";
    @@
    - *(u8 *)fn(SKB, S) = C;
    + fn2(SKB, C);

Note that due to the "S", the spatch isn't perfect, it should
have checked that S is 1, but there's also places that use a
sizeof expression like sizeof(var) or sizeof(u8) etc. Turns
out that nobody ever did something like
	*(u8 *)skb_put(skb, 2) = c;

which would be wrong anyway since the second byte wouldn't be
initialized.

Suggested-by: Joe Perches <joe@perches.com>
Suggested-by: Bjørn Mork <bjorn@mork.no>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/bluetooth/bluecard_cs.c   |  2 +-
 drivers/bluetooth/bt3c_cs.c       |  2 +-
 drivers/bluetooth/btuart_cs.c     |  2 +-
 drivers/bluetooth/btusb.c         |  6 +++---
 drivers/bluetooth/dtl1_cs.c       |  4 ++--
 drivers/bluetooth/hci_bcm.c       |  6 +++---
 drivers/bluetooth/hci_intel.c     |  2 +-
 drivers/bluetooth/hci_nokia.c     |  2 +-
 drivers/bluetooth/hci_qca.c       |  2 +-
 drivers/bluetooth/hci_vhci.c      |  4 ++--
 drivers/isdn/capi/capi.c          |  4 ++--
 drivers/isdn/gigaset/asyncdata.c  | 22 +++++++++++-----------
 drivers/isdn/i4l/isdn_bsdcomp.c   |  7 ++++---
 drivers/isdn/i4l/isdn_x25iface.c  |  4 ++--
 drivers/net/hamradio/scc.c        |  4 ++--
 drivers/net/usb/cdc_ncm.c         |  2 +-
 drivers/net/usb/net1080.c         |  2 +-
 drivers/net/usb/zaurus.c          |  8 ++++----
 drivers/nfc/fdp/i2c.c             |  2 +-
 drivers/nfc/microread/i2c.c       |  4 ++--
 drivers/nfc/microread/microread.c |  4 ++--
 drivers/nfc/nfcmrvl/fw_dnld.c     |  4 ++--
 drivers/nfc/pn533/pn533.c         | 32 ++++++++++++++++----------------
 drivers/nfc/pn544/i2c.c           |  6 +++---
 drivers/nfc/port100.c             |  4 ++--
 drivers/nfc/st21nfca/i2c.c        |  6 +++---
 drivers/nfc/st95hf/core.c         |  2 +-
 include/linux/skbuff.h            |  5 +++++
 net/bluetooth/hci_sock.c          |  2 +-
 net/bluetooth/hidp/core.c         |  2 +-
 net/decnet/dn_nsp_out.c           | 12 ++++++------
 net/nfc/digital_core.c            |  4 ++--
 net/nfc/digital_dep.c             |  2 +-
 net/nfc/digital_technology.c      | 12 ++++++------
 net/nfc/hci/core.c                |  2 +-
 net/nfc/hci/llc_shdlc.c           |  4 ++--
 net/nfc/nci/hci.c                 |  2 +-
 net/nfc/nci/spi.c                 |  8 ++++----
 net/nfc/nci/uart.c                |  2 +-
 39 files changed, 106 insertions(+), 100 deletions(-)

diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 39a05b0c8998..d4b0b655dde6 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -448,7 +448,7 @@ static void bluecard_receive(struct bluecard_info *info,
 
 		} else {
 
-			*(u8 *)skb_put(info->rx_skb, 1) = buf[i];
+			skb_put_u8(info->rx_skb, buf[i]);
 			info->rx_count--;
 
 			if (info->rx_count == 0) {
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index be2d431aa366..32dcac017395 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -282,7 +282,7 @@ static void bt3c_receive(struct bt3c_info *info)
 
 			__u8 x = inb(iobase + DATA_L);
 
-			*(u8 *)skb_put(info->rx_skb, 1) = x;
+			skb_put_u8(info->rx_skb, x);
 			inb(iobase + DATA_H);
 			info->rx_count--;
 
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 80b64e9684a3..7df79bb12350 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -233,7 +233,7 @@ static void btuart_receive(struct btuart_info *info)
 
 		} else {
 
-			*(u8 *)skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
+			skb_put_u8(info->rx_skb, inb(iobase + UART_RX));
 			info->rx_count--;
 
 			if (info->rx_count == 0) {
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index ba207c787605..fa24d693af24 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -1844,7 +1844,7 @@ static int inject_cmd_complete(struct hci_dev *hdev, __u16 opcode)
 	evt->ncmd = 0x01;
 	evt->opcode = cpu_to_le16(opcode);
 
-	*(u8 *)skb_put(skb, 1) = 0x00;
+	skb_put_u8(skb, 0x00);
 
 	hci_skb_pkt_type(skb) = HCI_EVENT_PKT;
 
@@ -2767,8 +2767,8 @@ static struct urb *alloc_diag_urb(struct hci_dev *hdev, bool enable)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	*(u8 *)skb_put(skb, 1) = 0xf0;
-	*(u8 *)skb_put(skb, 1) = enable;
+	skb_put_u8(skb, 0xf0);
+	skb_put_u8(skb, enable);
 
 	pipe = usb_sndbulkpipe(data->udev, data->diag_tx_ep->bEndpointAddress);
 
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 6c5a3aa566a4..2adfe4fade76 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -226,7 +226,7 @@ static void dtl1_receive(struct dtl1_info *info)
 			}
 		}
 
-		*(u8 *)skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
+		skb_put_u8(info->rx_skb, inb(iobase + UART_RX));
 		nsh = (struct nsh *)info->rx_skb->data;
 
 		info->rx_count--;
@@ -414,7 +414,7 @@ static int dtl1_hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	skb_reserve(s, NSHL);
 	skb_copy_from_linear_data(skb, skb_put(s, skb->len), skb->len);
 	if (skb->len & 0x0001)
-		*(u8 *)skb_put(s, 1) = 0;	/* PAD */
+		skb_put_u8(s, 0);	/* PAD */
 
 	/* Prepend skb with Nokia frame header and queue */
 	memcpy(skb_push(s, NSHL), &nsh, NSHL);
diff --git a/drivers/bluetooth/hci_bcm.c b/drivers/bluetooth/hci_bcm.c
index c1c4048ee37d..d2e9e2d1b014 100644
--- a/drivers/bluetooth/hci_bcm.c
+++ b/drivers/bluetooth/hci_bcm.c
@@ -262,9 +262,9 @@ static int bcm_set_diag(struct hci_dev *hdev, bool enable)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = BCM_LM_DIAG_PKT;
-	*(u8 *)skb_put(skb, 1) = 0xf0;
-	*(u8 *)skb_put(skb, 1) = enable;
+	skb_put_u8(skb, BCM_LM_DIAG_PKT);
+	skb_put_u8(skb, 0xf0);
+	skb_put_u8(skb, enable);
 
 	skb_queue_tail(&bcm->txq, skb);
 	hci_uart_tx_wakeup(hu);
diff --git a/drivers/bluetooth/hci_intel.c b/drivers/bluetooth/hci_intel.c
index ee97c465e32e..aad07e40ea4f 100644
--- a/drivers/bluetooth/hci_intel.c
+++ b/drivers/bluetooth/hci_intel.c
@@ -470,7 +470,7 @@ static int inject_cmd_complete(struct hci_dev *hdev, __u16 opcode)
 	evt->ncmd = 0x01;
 	evt->opcode = cpu_to_le16(opcode);
 
-	*(u8 *)skb_put(skb, 1) = 0x00;
+	skb_put_u8(skb, 0x00);
 
 	hci_skb_pkt_type(skb) = HCI_EVENT_PKT;
 
diff --git a/drivers/bluetooth/hci_nokia.c b/drivers/bluetooth/hci_nokia.c
index 072a77a61e67..181a15b549e5 100644
--- a/drivers/bluetooth/hci_nokia.c
+++ b/drivers/bluetooth/hci_nokia.c
@@ -532,7 +532,7 @@ static int nokia_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 		err = skb_pad(skb, 1);
 		if (err)
 			return err;
-		*(u8 *)skb_put(skb, 1) = 0x00;
+		skb_put_u8(skb, 0x00);
 	}
 
 	skb_queue_tail(&btdev->txq, skb);
diff --git a/drivers/bluetooth/hci_qca.c b/drivers/bluetooth/hci_qca.c
index e2c88515340a..392f412b4575 100644
--- a/drivers/bluetooth/hci_qca.c
+++ b/drivers/bluetooth/hci_qca.c
@@ -215,7 +215,7 @@ static int send_hci_ibs_cmd(u8 cmd, struct hci_uart *hu)
 	}
 
 	/* Assign HCI_IBS type */
-	*(u8 *)skb_put(skb, 1) = cmd;
+	skb_put_u8(skb, cmd);
 
 	skb_queue_tail(&qca->txq, skb);
 
diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index 1ef9c427a2d8..e6f6dbc04131 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -146,8 +146,8 @@ static int __vhci_create_device(struct vhci_data *data, __u8 opcode)
 
 	hci_skb_pkt_type(skb) = HCI_VENDOR_PKT;
 
-	*(u8 *)skb_put(skb, 1) = 0xff;
-	*(u8 *)skb_put(skb, 1) = opcode;
+	skb_put_u8(skb, 0xff);
+	skb_put_u8(skb, opcode);
 	put_unaligned_le16(hdev->id, skb_put(skb, 2));
 	skb_queue_tail(&data->readq, skb);
 
diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 96f586d34d2d..dde8f46bc254 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1082,7 +1082,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	skb = mp->outskb;
 	if (skb) {
 		if (skb_tailroom(skb) > 0) {
-			*(u8 *)skb_put(skb, 1) = ch;
+			skb_put_u8(skb, ch);
 			goto unlock_out;
 		}
 		mp->outskb = NULL;
@@ -1094,7 +1094,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	skb = alloc_skb(CAPI_DATA_B3_REQ_LEN + CAPI_MAX_BLKSIZE, GFP_ATOMIC);
 	if (skb) {
 		skb_reserve(skb, CAPI_DATA_B3_REQ_LEN);
-		*(u8 *)skb_put(skb, 1) = ch;
+		skb_put_u8(skb, ch);
 		mp->outskb = skb;
 	} else {
 		printk(KERN_ERR "capinc_put_char: char %u lost\n", ch);
diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index 03ac9fbfe318..4caecdcc6f29 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -492,33 +492,33 @@ static struct sk_buff *HDLC_Encode(struct sk_buff *skb)
 	hdlc_skb->mac_len = skb->mac_len;
 
 	/* Add flag sequence in front of everything.. */
-	*(u8 *)skb_put(hdlc_skb, 1) = PPP_FLAG;
+	skb_put_u8(hdlc_skb, PPP_FLAG);
 
 	/* Perform byte stuffing while copying data. */
 	while (skb->len--) {
 		if (muststuff(*skb->data)) {
-			*(u8 *)skb_put(hdlc_skb, 1) = PPP_ESCAPE;
-			*(u8 *)skb_put(hdlc_skb, 1) = (*skb->data++) ^ PPP_TRANS;
+			skb_put_u8(hdlc_skb, PPP_ESCAPE);
+			skb_put_u8(hdlc_skb, (*skb->data++) ^ PPP_TRANS);
 		} else
-			*(u8 *)skb_put(hdlc_skb, 1) = *skb->data++;
+			skb_put_u8(hdlc_skb, *skb->data++);
 	}
 
 	/* Finally add FCS (byte stuffed) and flag sequence */
 	c = (fcs & 0x00ff);	/* least significant byte first */
 	if (muststuff(c)) {
-		*(u8 *)skb_put(hdlc_skb, 1) = PPP_ESCAPE;
+		skb_put_u8(hdlc_skb, PPP_ESCAPE);
 		c ^= PPP_TRANS;
 	}
-	*(u8 *)skb_put(hdlc_skb, 1) = c;
+	skb_put_u8(hdlc_skb, c);
 
 	c = ((fcs >> 8) & 0x00ff);
 	if (muststuff(c)) {
-		*(u8 *)skb_put(hdlc_skb, 1) = PPP_ESCAPE;
+		skb_put_u8(hdlc_skb, PPP_ESCAPE);
 		c ^= PPP_TRANS;
 	}
-	*(u8 *)skb_put(hdlc_skb, 1) = c;
+	skb_put_u8(hdlc_skb, c);
 
-	*(u8 *)skb_put(hdlc_skb, 1) = PPP_FLAG;
+	skb_put_u8(hdlc_skb, PPP_FLAG);
 
 	dev_kfree_skb_any(skb);
 	return hdlc_skb;
@@ -561,8 +561,8 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb)
 	while (len--) {
 		c = bitrev8(*cp++);
 		if (c == DLE_FLAG)
-			*(u8 *)skb_put(iraw_skb, 1) = c;
-		*(u8 *)skb_put(iraw_skb, 1) = c;
+			skb_put_u8(iraw_skb, c);
+		skb_put_u8(iraw_skb, c);
 	}
 	dev_kfree_skb_any(skb);
 	return iraw_skb;
diff --git a/drivers/isdn/i4l/isdn_bsdcomp.c b/drivers/isdn/i4l/isdn_bsdcomp.c
index 6ade0916da4e..3035210a6119 100644
--- a/drivers/isdn/i4l/isdn_bsdcomp.c
+++ b/drivers/isdn/i4l/isdn_bsdcomp.c
@@ -602,7 +602,8 @@ static int bsd_compress(void *state, struct sk_buff *skb_in, struct sk_buff *skb
 	 * Do not emit a completely useless byte of ones.
 	 */
 	if (bitno < 32 && skb_out && skb_tailroom(skb_out) > 0)
-		*(u8 *)skb_put(skb_out, 1) = (unsigned char)((accm | (0xff << (bitno - 8))) >> 24);
+		skb_put_u8(skb_out,
+			   (unsigned char)((accm | (0xff << (bitno - 8))) >> 24));
 
 	/*
 	 * Increase code size if we would have without the packet
@@ -698,7 +699,7 @@ static int bsd_decompress(void *state, struct sk_buff *skb_in, struct sk_buff *s
 	db->bytes_out += ilen;
 
 	if (skb_tailroom(skb_out) > 0)
-		*(u8 *)skb_put(skb_out, 1) = 0;
+		skb_put_u8(skb_out, 0);
 	else
 		return DECOMP_ERR_NOMEM;
 
@@ -816,7 +817,7 @@ static int bsd_decompress(void *state, struct sk_buff *skb_in, struct sk_buff *s
 #endif
 
 		if (extra)		/* the KwKwK case again */
-			*(u8 *)skb_put(skb_out, 1) = finchar;
+			skb_put_u8(skb_out, finchar);
 
 		/*
 		 * If not first code in a packet, and
diff --git a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x25iface.c
index e33fa3073f74..48bfbcb4a09d 100644
--- a/drivers/isdn/i4l/isdn_x25iface.c
+++ b/drivers/isdn/i4l/isdn_x25iface.c
@@ -224,7 +224,7 @@ static int isdn_x25iface_connect_ind(struct concap_proto *cprot)
 
 	skb = dev_alloc_skb(1);
 	if (skb) {
-		*(u8 *)skb_put(skb, 1) = X25_IFACE_CONNECT;
+		skb_put_u8(skb, X25_IFACE_CONNECT);
 		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
@@ -253,7 +253,7 @@ static int isdn_x25iface_disconn_ind(struct concap_proto *cprot)
 	*state_p = WAN_DISCONNECTED;
 	skb = dev_alloc_skb(1);
 	if (skb) {
-		*(u8 *)skb_put(skb, 1) = X25_IFACE_DISCONNECT;
+		skb_put_u8(skb, X25_IFACE_DISCONNECT);
 		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 140a209f22ab..295f267b73ea 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -540,7 +540,7 @@ static inline void scc_rxint(struct scc_channel *scc)
 		}
 		
 		scc->rx_buff = skb;
-		*(u8 *)skb_put(skb, 1) = 0;	/* KISS data */
+		skb_put_u8(skb, 0);	/* KISS data */
 	}
 	
 	if (skb->len >= scc->stat.bufsize)
@@ -555,7 +555,7 @@ static inline void scc_rxint(struct scc_channel *scc)
 		return;
 	}
 
-	*(u8 *)skb_put(skb, 1) = Inb(scc->data);
+	skb_put_u8(skb, Inb(scc->data));
 }
 
 
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4d4837a0645b..bcb974707118 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1250,7 +1250,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 		skb_put_zero(skb_out, padding_count);
 	} else if (skb_out->len < ctx->tx_max &&
 		   (skb_out->len % dev->maxpacket) == 0) {
-		*(u8 *)skb_put(skb_out, 1) = 0;	/* force short packet */
+		skb_put_u8(skb_out, 0);	/* force short packet */
 	}
 
 	/* set final frame length */
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index be53ff30b7b5..18a13aa5fcbb 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -473,7 +473,7 @@ net1080_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 
 	/* maybe pad; then trailer */
 	if (!((skb->len + sizeof *trailer) & 0x01))
-		*(u8 *)skb_put(skb, 1) = PAD_BYTE;
+		skb_put_u8(skb, PAD_BYTE);
 	trailer = skb_put(skb, sizeof *trailer);
 	put_unaligned(header->packet_id, &trailer->packet_id);
 #if 0
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index dc3cd03763af..9c2196c3fd11 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -74,10 +74,10 @@ zaurus_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 		fcs = crc32_le(~0, skb->data, skb->len);
 		fcs = ~fcs;
 
-		*(u8 *)skb_put(skb, 1) = fcs       & 0xff;
-		*(u8 *)skb_put(skb, 1) = (fcs>> 8) & 0xff;
-		*(u8 *)skb_put(skb, 1) = (fcs>>16) & 0xff;
-		*(u8 *)skb_put(skb, 1) = (fcs>>24) & 0xff;
+		skb_put_u8(skb, fcs & 0xff);
+		skb_put_u8(skb, (fcs >> 8) & 0xff);
+		skb_put_u8(skb, (fcs >> 16) & 0xff);
+		skb_put_u8(skb, (fcs >> 24) & 0xff);
 	}
 	return skb;
 }
diff --git a/drivers/nfc/fdp/i2c.c b/drivers/nfc/fdp/i2c.c
index d5781aa0f791..e0baec848ff2 100644
--- a/drivers/nfc/fdp/i2c.c
+++ b/drivers/nfc/fdp/i2c.c
@@ -86,7 +86,7 @@ static void fdp_nci_i2c_add_len_lrc(struct sk_buff *skb)
 	for (i = 0; i < len + 2; i++)
 		lrc ^= skb->data[i];
 
-	*(u8 *)skb_put(skb, 1) = lrc;
+	skb_put_u8(skb, lrc);
 }
 
 static void fdp_nci_i2c_remove_len_lrc(struct sk_buff *skb)
diff --git a/drivers/nfc/microread/i2c.c b/drivers/nfc/microread/i2c.c
index 386cc61d95b9..b668b7b9a61e 100644
--- a/drivers/nfc/microread/i2c.c
+++ b/drivers/nfc/microread/i2c.c
@@ -75,7 +75,7 @@ static void microread_i2c_add_len_crc(struct sk_buff *skb)
 	for (i = 0; i < skb->len; i++)
 		crc = crc ^ skb->data[i];
 
-	*(u8 *)skb_put(skb, 1) = crc;
+	skb_put_u8(skb, crc);
 }
 
 static void microread_i2c_remove_len_crc(struct sk_buff *skb)
@@ -173,7 +173,7 @@ static int microread_i2c_read(struct microread_i2c_phy *phy,
 		goto flush;
 	}
 
-	*(u8 *)skb_put(*skb, 1) = len;
+	skb_put_u8(*skb, len);
 
 	r = i2c_master_recv(client, skb_put(*skb, len), len);
 	if (r != len) {
diff --git a/drivers/nfc/microread/microread.c b/drivers/nfc/microread/microread.c
index 38a979eacc29..e5d5d2d97409 100644
--- a/drivers/nfc/microread/microread.c
+++ b/drivers/nfc/microread/microread.c
@@ -441,8 +441,8 @@ static int microread_im_transceive(struct nfc_hci_dev *hdev,
 
 		crc = crc_ccitt(0xffff, skb->data, skb->len);
 		crc = ~crc;
-		*(u8 *)skb_put(skb, 1) = crc & 0xff;
-		*(u8 *)skb_put(skb, 1) = crc >> 8;
+		skb_put_u8(skb, crc & 0xff);
+		skb_put_u8(skb, crc >> 8);
 		break;
 	case MICROREAD_GATE_ID_MREAD_NFC_T3:
 		control_bits = 0xDB;
diff --git a/drivers/nfc/nfcmrvl/fw_dnld.c b/drivers/nfc/nfcmrvl/fw_dnld.c
index 788599de9d8a..f9f000c546d1 100644
--- a/drivers/nfc/nfcmrvl/fw_dnld.c
+++ b/drivers/nfc/nfcmrvl/fw_dnld.c
@@ -292,7 +292,7 @@ static int process_state_fw_dnld(struct nfcmrvl_private *priv,
 			out_skb = alloc_lc_skb(priv, 1);
 			if (!out_skb)
 				return -ENOMEM;
-			*(u8 *)skb_put(out_skb, 1) = 0xBF;
+			skb_put_u8(out_skb, 0xBF);
 			nci_send_frame(priv->ndev, out_skb);
 			priv->fw_dnld.substate = SUBSTATE_WAIT_NACK_CREDIT;
 			return 0;
@@ -301,7 +301,7 @@ static int process_state_fw_dnld(struct nfcmrvl_private *priv,
 		out_skb = alloc_lc_skb(priv, 1);
 		if (!out_skb)
 			return -ENOMEM;
-		*(u8 *)skb_put(out_skb, 1) = HELPER_ACK_PACKET_FORMAT;
+		skb_put_u8(out_skb, HELPER_ACK_PACKET_FORMAT);
 		nci_send_frame(priv->ndev, out_skb);
 		priv->fw_dnld.substate = SUBSTATE_WAIT_ACK_CREDIT;
 		break;
diff --git a/drivers/nfc/pn533/pn533.c b/drivers/nfc/pn533/pn533.c
index 6a711b5b9490..c8a8f5badb5b 100644
--- a/drivers/nfc/pn533/pn533.c
+++ b/drivers/nfc/pn533/pn533.c
@@ -1032,7 +1032,7 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 		return NULL;
 
 	/* DEP support only */
-	*(u8 *)skb_put(skb, 1) = PN533_INIT_TARGET_DEP;
+	skb_put_u8(skb, PN533_INIT_TARGET_DEP);
 
 	/* MIFARE params */
 	skb_put_data(skb, mifare_params, 6);
@@ -1046,12 +1046,12 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 	memcpy(nfcid3, felica, 8);
 
 	/* General bytes */
-	*(u8 *)skb_put(skb, 1) = gbytes_len;
+	skb_put_u8(skb, gbytes_len);
 
 	gb = skb_put_data(skb, gbytes, gbytes_len);
 
 	/* Len Tk */
-	*(u8 *)skb_put(skb, 1) = 0;
+	skb_put_u8(skb, 0);
 
 	return skb;
 }
@@ -1280,8 +1280,8 @@ static void pn533_wq_rf(struct work_struct *work)
 	if (!skb)
 		return;
 
-	*(u8 *)skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD;
-	*(u8 *)skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD_AUTO_RFCA;
+	skb_put_u8(skb, PN533_CFGITEM_RF_FIELD);
+	skb_put_u8(skb, PN533_CFGITEM_RF_FIELD_AUTO_RFCA);
 
 	rc = pn533_send_cmd_async(dev, PN533_CMD_RF_CONFIGURATION, skb,
 				  pn533_rf_complete, NULL);
@@ -1375,8 +1375,8 @@ static int pn533_poll_dep(struct nfc_dev *nfc_dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = 0x01;  /* Active */
-	*(u8 *)skb_put(skb, 1) = 0x02;  /* 424 kbps */
+	skb_put_u8(skb, 0x01);  /* Active */
+	skb_put_u8(skb, 0x02);  /* 424 kbps */
 
 	next = skb_put(skb, 1);  /* Next */
 	*next = 0;
@@ -1620,8 +1620,8 @@ static int pn533_activate_target_nfcdep(struct pn533 *dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, sizeof(u8)) = 1; /* TG */
-	*(u8 *)skb_put(skb, sizeof(u8)) = 0; /* Next */
+	skb_put_u8(skb, 1); /* TG */
+	skb_put_u8(skb, 0); /* Next */
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_IN_ATR, skb);
 	if (IS_ERR(resp))
@@ -1737,7 +1737,7 @@ static void pn533_deactivate_target(struct nfc_dev *nfc_dev,
 	if (!skb)
 		return;
 
-	*(u8 *)skb_put(skb, 1) = 1; /* TG*/
+	skb_put_u8(skb, 1); /* TG*/
 
 	rc = pn533_send_cmd_async(dev, PN533_CMD_IN_RELEASE, skb,
 				  pn533_deactivate_target_complete, NULL);
@@ -1848,8 +1848,8 @@ static int pn533_dep_link_up(struct nfc_dev *nfc_dev, struct nfc_target *target,
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = !comm_mode;  /* ActPass */
-	*(u8 *)skb_put(skb, 1) = 0x02;  /* 424 kbps */
+	skb_put_u8(skb, !comm_mode);  /* ActPass */
+	skb_put_u8(skb, 0x02);  /* 424 kbps */
 
 	next = skb_put(skb, 1);  /* Next */
 	*next = 0;
@@ -2274,7 +2274,7 @@ static void pn533_wq_mi_recv(struct work_struct *work)
 			break;
 		}
 	default:
-		*(u8 *)skb_put(skb, sizeof(u8)) =  1; /*TG*/
+		skb_put_u8(skb, 1); /*TG*/
 
 		rc = pn533_send_cmd_direct_async(dev,
 						 PN533_CMD_IN_DATA_EXCHANGE,
@@ -2370,7 +2370,7 @@ static int pn533_set_configuration(struct pn533 *dev, u8 cfgitem, u8 *cfgdata,
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, sizeof(cfgitem)) = cfgitem;
+	skb_put_u8(skb, cfgitem);
 	skb_put_data(skb, cfgdata, cfgdata_len);
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_RF_CONFIGURATION, skb);
@@ -2415,7 +2415,7 @@ static int pn533_pasori_fw_reset(struct pn533 *dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, sizeof(u8)) = 0x1;
+	skb_put_u8(skb, 0x1);
 
 	resp = pn533_send_cmd_sync(dev, 0x18, skb);
 	if (IS_ERR(resp))
@@ -2454,7 +2454,7 @@ static int pn532_sam_configuration(struct nfc_dev *nfc_dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = 0x01;
+	skb_put_u8(skb, 0x01);
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_SAM_CONFIGURATION, skb);
 	if (IS_ERR(resp))
diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index b7be6c25b7e6..fedde9d46ab6 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -287,8 +287,8 @@ static void pn544_hci_i2c_add_len_crc(struct sk_buff *skb)
 
 	crc = crc_ccitt(0xffff, skb->data, skb->len);
 	crc = ~crc;
-	*(u8 *)skb_put(skb, 1) = crc & 0xff;
-	*(u8 *)skb_put(skb, 1) = crc >> 8;
+	skb_put_u8(skb, crc & 0xff);
+	skb_put_u8(skb, crc >> 8);
 }
 
 static void pn544_hci_i2c_remove_len_crc(struct sk_buff *skb)
@@ -391,7 +391,7 @@ static int pn544_hci_i2c_read(struct pn544_i2c_phy *phy, struct sk_buff **skb)
 		goto flush;
 	}
 
-	*(u8 *)skb_put(*skb, 1) = len;
+	skb_put_u8(*skb, len);
 
 	r = i2c_master_recv(client, skb_put(*skb, len), len);
 	if (r != len) {
diff --git a/drivers/nfc/port100.c b/drivers/nfc/port100.c
index 5fa3cf0fabd6..bb43cebda9dc 100644
--- a/drivers/nfc/port100.c
+++ b/drivers/nfc/port100.c
@@ -991,7 +991,7 @@ static int port100_set_command_type(struct port100 *dev, u8 command_type)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, sizeof(u8)) = command_type;
+	skb_put_u8(skb, command_type);
 
 	resp = port100_send_cmd_sync(dev, PORT100_CMD_SET_COMMAND_TYPE, skb);
 	if (IS_ERR(resp))
@@ -1059,7 +1059,7 @@ static int port100_switch_rf(struct nfc_digital_dev *ddev, bool on)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = on ? 1 : 0;
+	skb_put_u8(skb, on ? 1 : 0);
 
 	/* Cancel the last command if the device is being switched off */
 	if (!on)
diff --git a/drivers/nfc/st21nfca/i2c.c b/drivers/nfc/st21nfca/i2c.c
index 396cdafb3e36..4bff76baa341 100644
--- a/drivers/nfc/st21nfca/i2c.c
+++ b/drivers/nfc/st21nfca/i2c.c
@@ -177,10 +177,10 @@ static void st21nfca_hci_add_len_crc(struct sk_buff *skb)
 	crc = ~crc;
 
 	tmp = crc & 0x00ff;
-	*(u8 *)skb_put(skb, 1) = tmp;
+	skb_put_u8(skb, tmp);
 
 	tmp = (crc >> 8) & 0x00ff;
-	*(u8 *)skb_put(skb, 1) = tmp;
+	skb_put_u8(skb, tmp);
 }
 
 static void st21nfca_hci_remove_len_crc(struct sk_buff *skb)
@@ -214,7 +214,7 @@ static int st21nfca_hci_i2c_write(void *phy_id, struct sk_buff *skb)
 	st21nfca_hci_add_len_crc(skb);
 
 	/* add ST21NFCA_SOF_EOF on tail */
-	*(u8 *)skb_put(skb, 1) = ST21NFCA_SOF_EOF;
+	skb_put_u8(skb, ST21NFCA_SOF_EOF);
 	/* add ST21NFCA_SOF_EOF on head */
 	*(u8 *)skb_push(skb, 1) = ST21NFCA_SOF_EOF;
 
diff --git a/drivers/nfc/st95hf/core.c b/drivers/nfc/st95hf/core.c
index 168adcc46cb8..2b26f762fbc3 100644
--- a/drivers/nfc/st95hf/core.c
+++ b/drivers/nfc/st95hf/core.c
@@ -949,7 +949,7 @@ static int st95hf_in_send_cmd(struct nfc_digital_dev *ddev,
 	switch (stcontext->current_rf_tech) {
 	case NFC_DIGITAL_RF_TECH_106A:
 		len_data_to_tag = skb->len + 1;
-		*(u8 *)skb_put(skb, 1) = stcontext->sendrcv_trflag;
+		skb_put_u8(skb, stcontext->sendrcv_trflag);
 		break;
 	case NFC_DIGITAL_RF_TECH_106B:
 	case NFC_DIGITAL_RF_TECH_ISO15693:
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 46bd514e719c..852feacf4bbf 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1923,6 +1923,11 @@ static inline void *skb_put_data(struct sk_buff *skb, const void *data,
 	return tmp;
 }
 
+static inline void skb_put_u8(struct sk_buff *skb, u8 val)
+{
+	*(u8 *)skb_put(skb, 1) = val;
+}
+
 void *skb_push(struct sk_buff *skb, unsigned int len);
 static inline void *__skb_push(struct sk_buff *skb, unsigned int len)
 {
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index cdb5c1a7481e..65d734c165bd 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -517,7 +517,7 @@ static struct sk_buff *create_monitor_ctrl_open(struct sock *sk)
 	put_unaligned_le16(format, skb_put(skb, 2));
 	skb_put_data(skb, ver, sizeof(ver));
 	put_unaligned_le32(flags, skb_put(skb, 4));
-	*(u8 *)skb_put(skb, 1) = TASK_COMM_LEN;
+	skb_put_u8(skb, TASK_COMM_LEN);
 	skb_put_data(skb, hci_pi(sk)->comm, TASK_COMM_LEN);
 
 	__net_timestamp(skb);
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index c0d0832a023d..961f7f53e178 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -112,7 +112,7 @@ static int hidp_send_message(struct hidp_session *session, struct socket *sock,
 		return -ENOMEM;
 	}
 
-	*(u8 *)skb_put(skb, 1) = hdr;
+	skb_put_u8(skb, hdr);
 	if (data && size > 0)
 		skb_put_data(skb, data, size);
 
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 7e054b2f270a..66f035e476ea 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -530,7 +530,7 @@ void dn_send_conn_conf(struct sock *sk, gfp_t gfp)
 	msg->info = scp->info_loc;
 	msg->segsize = cpu_to_le16(scp->segsize_loc);
 
-	*(u8 *)skb_put(skb, 1) = len;
+	skb_put_u8(skb, len);
 
 	if (len > 0)
 		skb_put_data(skb, scp->conndata_out.opt_data, len);
@@ -686,25 +686,25 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 	if (scp->peer.sdn_flags & SDF_UICPROXY)
 		menuver |= DN_MENUVER_UIC;
 
-	*(u8 *)skb_put(skb, 1) = menuver;	/* Menu Version		*/
+	skb_put_u8(skb, menuver);	/* Menu Version		*/
 
 	aux = scp->accessdata.acc_userl;
-	*(u8 *)skb_put(skb, 1) = aux;
+	skb_put_u8(skb, aux);
 	if (aux > 0)
 		skb_put_data(skb, scp->accessdata.acc_user, aux);
 
 	aux = scp->accessdata.acc_passl;
-	*(u8 *)skb_put(skb, 1) = aux;
+	skb_put_u8(skb, aux);
 	if (aux > 0)
 		skb_put_data(skb, scp->accessdata.acc_pass, aux);
 
 	aux = scp->accessdata.acc_accl;
-	*(u8 *)skb_put(skb, 1) = aux;
+	skb_put_u8(skb, aux);
 	if (aux > 0)
 		skb_put_data(skb, scp->accessdata.acc_acc, aux);
 
 	aux = (__u8)le16_to_cpu(scp->conndata_out.opt_optl);
-	*(u8 *)skb_put(skb, 1) = aux;
+	skb_put_u8(skb, aux);
 	if (aux > 0)
 		skb_put_data(skb, scp->conndata_out.opt_data, aux);
 
diff --git a/net/nfc/digital_core.c b/net/nfc/digital_core.c
index fec47a7d0092..ebeace7a8278 100644
--- a/net/nfc/digital_core.c
+++ b/net/nfc/digital_core.c
@@ -74,8 +74,8 @@ void digital_skb_add_crc(struct sk_buff *skb, crc_func_t crc_func, u16 init,
 	if (msb_first)
 		crc = __fswab16(crc);
 
-	*(u8 *)skb_put(skb, 1) = crc & 0xFF;
-	*(u8 *)skb_put(skb, 1) = (crc >> 8) & 0xFF;
+	skb_put_u8(skb, crc & 0xFF);
+	skb_put_u8(skb, (crc >> 8) & 0xFF);
 }
 
 int digital_skb_check_crc(struct sk_buff *skb, crc_func_t crc_func,
diff --git a/net/nfc/digital_dep.c b/net/nfc/digital_dep.c
index f948fc2099d2..74ccc2dd79d0 100644
--- a/net/nfc/digital_dep.c
+++ b/net/nfc/digital_dep.c
@@ -654,7 +654,7 @@ static int digital_in_send_rtox(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = rtox;
+	skb_put_u8(skb, rtox);
 
 	skb_push(skb, sizeof(struct digital_dep_req_res));
 
diff --git a/net/nfc/digital_technology.c b/net/nfc/digital_technology.c
index 492204e440ec..3cc3448da524 100644
--- a/net/nfc/digital_technology.c
+++ b/net/nfc/digital_technology.c
@@ -266,8 +266,8 @@ static int digital_in_send_rats(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = DIGITAL_RATS_BYTE1;
-	*(u8 *)skb_put(skb, 1) = DIGITAL_RATS_PARAM;
+	skb_put_u8(skb, DIGITAL_RATS_BYTE1);
+	skb_put_u8(skb, DIGITAL_RATS_PARAM);
 
 	rc = digital_in_send_cmd(ddev, skb, 30, digital_in_recv_ats,
 				 target);
@@ -470,8 +470,8 @@ static int digital_in_send_sdd_req(struct nfc_digital_dev *ddev,
 	else
 		sel_cmd = DIGITAL_CMD_SEL_REQ_CL3;
 
-	*(u8 *)skb_put(skb, sizeof(u8)) = sel_cmd;
-	*(u8 *)skb_put(skb, sizeof(u8)) = DIGITAL_SDD_REQ_SEL_PAR;
+	skb_put_u8(skb, sel_cmd);
+	skb_put_u8(skb, DIGITAL_SDD_REQ_SEL_PAR);
 
 	return digital_in_send_cmd(ddev, skb, 30, digital_in_recv_sdd_res,
 				   target);
@@ -541,7 +541,7 @@ int digital_in_send_sens_req(struct nfc_digital_dev *ddev, u8 rf_tech)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, sizeof(u8)) = DIGITAL_CMD_SENS_REQ;
+	skb_put_u8(skb, DIGITAL_CMD_SENS_REQ);
 
 	rc = digital_in_send_cmd(ddev, skb, 30, digital_in_recv_sens_res, NULL);
 	if (rc)
@@ -937,7 +937,7 @@ static int digital_tg_send_sel_res(struct nfc_digital_dev *ddev)
 	if (!skb)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = DIGITAL_SEL_RES_NFC_DEP;
+	skb_put_u8(skb, DIGITAL_SEL_RES_NFC_DEP);
 
 	if (!DIGITAL_DRV_CAPS_TG_CRC(ddev))
 		digital_skb_add_crc_a(skb);
diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index 7b2bdda1514c..b740fef0acc5 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -874,7 +874,7 @@ static void nfc_hci_recv_from_llc(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 			return;
 		}
 
-		*(u8 *)skb_put(hcp_skb, NFC_HCI_HCP_PACKET_HEADER_LEN) = pipe;
+		skb_put_u8(hcp_skb, pipe);
 
 		skb_queue_walk(&hdev->rx_hcp_frags, frag_skb) {
 			msg_len = frag_skb->len - NFC_HCI_HCP_PACKET_HEADER_LEN;
diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index 5bd4529279f5..17e59a009ce6 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -382,8 +382,8 @@ static int llc_shdlc_connect_initiate(struct llc_shdlc *shdlc)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	*(u8 *)skb_put(skb, 1) = SHDLC_MAX_WINDOW;
-	*(u8 *)skb_put(skb, 1) = SHDLC_SREJ_SUPPORT ? 1 : 0;
+	skb_put_u8(skb, SHDLC_MAX_WINDOW);
+	skb_put_u8(skb, SHDLC_SREJ_SUPPORT ? 1 : 0);
 
 	return llc_shdlc_send_u_frame(shdlc, skb, U_FRAME_RSET);
 }
diff --git a/net/nfc/nci/hci.c b/net/nfc/nci/hci.c
index 3f93df58d9f1..ddfc52ac1f9b 100644
--- a/net/nfc/nci/hci.c
+++ b/net/nfc/nci/hci.c
@@ -472,7 +472,7 @@ void nci_hci_data_received_cb(void *context,
 			return;
 		}
 
-		*(u8 *)skb_put(hcp_skb, NCI_HCI_HCP_PACKET_HEADER_LEN) = pipe;
+		skb_put_u8(hcp_skb, pipe);
 
 		skb_queue_walk(&ndev->hci_dev->rx_hcp_frags, frag_skb) {
 			msg_len = frag_skb->len - NCI_HCI_HCP_PACKET_HEADER_LEN;
diff --git a/net/nfc/nci/spi.c b/net/nfc/nci/spi.c
index 3b4512731a2f..452f4c16b7a9 100644
--- a/net/nfc/nci/spi.c
+++ b/net/nfc/nci/spi.c
@@ -86,8 +86,8 @@ int nci_spi_send(struct nci_spi *nspi,
 		u16 crc;
 
 		crc = crc_ccitt(CRC_INIT, skb->data, skb->len);
-		*(u8 *)skb_put(skb, 1) = crc >> 8;
-		*(u8 *)skb_put(skb, 1) = crc & 0xFF;
+		skb_put_u8(skb, crc >> 8);
+		skb_put_u8(skb, crc & 0xFF);
 	}
 
 	if (write_handshake_completion)	{
@@ -172,8 +172,8 @@ static int send_acknowledge(struct nci_spi *nspi, u8 acknowledge)
 	hdr[3] = 0;
 
 	crc = crc_ccitt(CRC_INIT, skb->data, skb->len);
-	*(u8 *)skb_put(skb, 1) = crc >> 8;
-	*(u8 *)skb_put(skb, 1) = crc & 0xFF;
+	skb_put_u8(skb, crc >> 8);
+	skb_put_u8(skb, crc & 0xFF);
 
 	ret = __nci_spi_send(nspi, skb, 0);
 
diff --git a/net/nfc/nci/uart.c b/net/nfc/nci/uart.c
index 442f8eadfc76..8d104c1db628 100644
--- a/net/nfc/nci/uart.c
+++ b/net/nfc/nci/uart.c
@@ -355,7 +355,7 @@ static int nci_uart_default_recv_buf(struct nci_uart *nu, const u8 *data,
 
 		/* Eat byte after byte till full packet header is received */
 		if (nu->rx_skb->len < NCI_CTRL_HDR_SIZE) {
-			*(u8 *)skb_put(nu->rx_skb, 1) = *data++;
+			skb_put_u8(nu->rx_skb, *data++);
 			--count;
 			continue;
 		}
-- 
2.11.0
