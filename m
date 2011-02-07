From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: [PATCH 2/2] USB CDC NCM errata updates for cdc_ncm host driver
Date: Mon,  7 Feb 2011 20:45:10 +0100
Message-ID: <1297107910-18263-2-git-send-email-alexey.orishko@stericsson.com>
References: <1297107910-18263-1-git-send-email-alexey.orishko@stericsson.com>
Cc: linux-usb@vger.kernel.org, davem@davemloft.net, gregkh@suse.de,
	yauheni.kaliuta@nokia.com,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47139 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab1BGTp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 14:45:59 -0500
In-Reply-To: <1297107910-18263-1-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Specification links:
- CDC NCM errata link:
  http://www.usb.org/developers/devclass_docs/NCM10_012011.zip
- CDC and WMC errata link:
  http://www.usb.org/developers/devclass_docs/CDC1.2_WMC1.1_012011.zip

Changes:
- driver updated to match cdc.h header with errata changes
- added support for USB_CDC_SET_NTB_INPUT_SIZE control request with
  8 byte length
- fixes to comply with specification: send only control requests supported by
  device, set number of datagrams for IN direction, connection speed structure
  update, etc.
- packet loss fixed for tx direction; misleading flag renamed.
- adjusted hard_mtu value.

Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>
---
 drivers/net/usb/cdc_ncm.c |  227 +++++++++++++++++++++++++++++----------------
 1 files changed, 147 insertions(+), 80 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 04e8ce1..7113168 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1,7 +1,7 @@
 /*
  * cdc_ncm.c
  *
- * Copyright (C) ST-Ericsson 2010
+ * Copyright (C) ST-Ericsson 2010-2011
  * Contact: Alexey Orishko <alexey.orishko@stericsson.com>
  * Original author: Hans Petter Selasky <hans.petter.selasky@stericsson.com>
  *
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"17-Jan-2011"
+#define	DRIVER_VERSION				"7-Feb-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -77,6 +77,9 @@
  */
 #define	CDC_NCM_DPT_DATAGRAMS_MAX		32
 
+/* Maximum amount of IN datagrams in NTB */
+#define	CDC_NCM_DPT_DATAGRAMS_IN_MAX		0 /* unlimited */
+
 /* Restart the timer, if amount of datagrams is less than given value */
 #define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
 
@@ -85,11 +88,6 @@
 	(sizeof(struct usb_cdc_ncm_nth16) + sizeof(struct usb_cdc_ncm_ndp16) + \
 	(CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe16))
 
-struct connection_speed_change {
-	__le32	USBitRate; /* holds 3GPP downlink value, bits per second */
-	__le32	DSBitRate; /* holds 3GPP uplink value, bits per second */
-} __attribute__ ((packed));
-
 struct cdc_ncm_data {
 	struct usb_cdc_ncm_nth16 nth16;
 	struct usb_cdc_ncm_ndp16 ndp16;
@@ -198,10 +196,10 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 {
 	struct usb_cdc_notification req;
 	u32 val;
-	__le16 max_datagram_size;
 	u8 flags;
 	u8 iface_no;
 	int err;
+	u16 ntb_fmt_supported;
 
 	iface_no = ctx->control->cur_altsetting->desc.bInterfaceNumber;
 
@@ -223,6 +221,9 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	ctx->tx_remainder = le16_to_cpu(ctx->ncm_parm.wNdpOutPayloadRemainder);
 	ctx->tx_modulus = le16_to_cpu(ctx->ncm_parm.wNdpOutDivisor);
 	ctx->tx_ndp_modulus = le16_to_cpu(ctx->ncm_parm.wNdpOutAlignment);
+	/* devices prior to NCM Errata shall set this field to zero */
+	ctx->tx_max_datagrams = le16_to_cpu(ctx->ncm_parm.wNtbOutMaxDatagrams);
+	ntb_fmt_supported = le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported);
 
 	if (ctx->func_desc != NULL)
 		flags = ctx->func_desc->bmNetworkCapabilities;
@@ -231,22 +232,58 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 
 	pr_debug("dwNtbInMaxSize=%u dwNtbOutMaxSize=%u "
 		 "wNdpOutPayloadRemainder=%u wNdpOutDivisor=%u "
-		 "wNdpOutAlignment=%u flags=0x%x\n",
+		 "wNdpOutAlignment=%u wNtbOutMaxDatagrams=%u flags=0x%x\n",
 		 ctx->rx_max, ctx->tx_max, ctx->tx_remainder, ctx->tx_modulus,
-		 ctx->tx_ndp_modulus, flags);
+		 ctx->tx_ndp_modulus, ctx->tx_max_datagrams, flags);
 
-	/* max count of tx datagrams without terminating NULL entry */
-	ctx->tx_max_datagrams = CDC_NCM_DPT_DATAGRAMS_MAX;
+	/* max count of tx datagrams */
+	if ((ctx->tx_max_datagrams == 0) ||
+			(ctx->tx_max_datagrams > CDC_NCM_DPT_DATAGRAMS_MAX))
+		ctx->tx_max_datagrams = CDC_NCM_DPT_DATAGRAMS_MAX;
 
 	/* verify maximum size of received NTB in bytes */
-	if ((ctx->rx_max <
-	    (CDC_NCM_MIN_HDR_SIZE + CDC_NCM_MIN_DATAGRAM_SIZE)) ||
-	    (ctx->rx_max > CDC_NCM_NTB_MAX_SIZE_RX)) {
+	if (ctx->rx_max < USB_CDC_NCM_NTB_MIN_IN_SIZE) {
+		pr_debug("Using min receive length=%d\n",
+						USB_CDC_NCM_NTB_MIN_IN_SIZE);
+		ctx->rx_max = USB_CDC_NCM_NTB_MIN_IN_SIZE;
+	}
+
+	if (ctx->rx_max > CDC_NCM_NTB_MAX_SIZE_RX) {
 		pr_debug("Using default maximum receive length=%d\n",
 						CDC_NCM_NTB_MAX_SIZE_RX);
 		ctx->rx_max = CDC_NCM_NTB_MAX_SIZE_RX;
 	}
 
+	/* inform device about NTB input size changes */
+	if (ctx->rx_max != le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
+		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
+							USB_RECIP_INTERFACE;
+		req.bNotificationType = USB_CDC_SET_NTB_INPUT_SIZE;
+		req.wValue = 0;
+		req.wIndex = cpu_to_le16(iface_no);
+
+		if (flags & USB_CDC_NCM_NCAP_NTB_INPUT_SIZE) {
+			struct usb_cdc_ncm_ndp_input_size ndp_in_sz;
+
+			req.wLength = 8;
+			ndp_in_sz.dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
+			ndp_in_sz.wNtbInMaxDatagrams =
+					cpu_to_le16(CDC_NCM_DPT_DATAGRAMS_MAX);
+			ndp_in_sz.wReserved = 0;
+			err = cdc_ncm_do_request(ctx, &req, &ndp_in_sz, 0, NULL,
+									1000);
+		} else {
+			__le32 dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
+
+			req.wLength = 4;
+			err = cdc_ncm_do_request(ctx, &req, &dwNtbInMaxSize, 0,
+								NULL, 1000);
+		}
+
+		if (err)
+			pr_debug("Setting NTB Input Size failed\n");
+	}
+
 	/* verify maximum size of transmitted NTB in bytes */
 	if ((ctx->tx_max <
 	    (CDC_NCM_MIN_HDR_SIZE + CDC_NCM_MIN_DATAGRAM_SIZE)) ||
@@ -297,47 +334,84 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	/* additional configuration */
 
 	/* set CRC Mode */
-	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT | USB_RECIP_INTERFACE;
-	req.bNotificationType = USB_CDC_SET_CRC_MODE;
-	req.wValue = cpu_to_le16(USB_CDC_NCM_CRC_NOT_APPENDED);
-	req.wIndex = cpu_to_le16(iface_no);
-	req.wLength = 0;
-
-	err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
-	if (err)
-		pr_debug("Setting CRC mode off failed\n");
+	if (flags & USB_CDC_NCM_NCAP_CRC_MODE) {
+		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
+							USB_RECIP_INTERFACE;
+		req.bNotificationType = USB_CDC_SET_CRC_MODE;
+		req.wValue = cpu_to_le16(USB_CDC_NCM_CRC_NOT_APPENDED);
+		req.wIndex = cpu_to_le16(iface_no);
+		req.wLength = 0;
+
+		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
+		if (err)
+			pr_debug("Setting CRC mode off failed\n");
+	}
 
-	/* set NTB format */
-	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT | USB_RECIP_INTERFACE;
-	req.bNotificationType = USB_CDC_SET_NTB_FORMAT;
-	req.wValue = cpu_to_le16(USB_CDC_NCM_NTB16_FORMAT);
-	req.wIndex = cpu_to_le16(iface_no);
-	req.wLength = 0;
+	/* set NTB format, if both formats are supported */
+	if (ntb_fmt_supported & USB_CDC_NCM_NTH32_SIGN) {
+		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
+							USB_RECIP_INTERFACE;
+		req.bNotificationType = USB_CDC_SET_NTB_FORMAT;
+		req.wValue = cpu_to_le16(USB_CDC_NCM_NTB16_FORMAT);
+		req.wIndex = cpu_to_le16(iface_no);
+		req.wLength = 0;
+
+		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
+		if (err)
+			pr_debug("Setting NTB format to 16-bit failed\n");
+	}
 
-	err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
-	if (err)
-		pr_debug("Setting NTB format to 16-bit failed\n");
+	ctx->max_datagram_size = CDC_NCM_MIN_DATAGRAM_SIZE;
 
 	/* set Max Datagram Size (MTU) */
-	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE;
-	req.bNotificationType = USB_CDC_GET_MAX_DATAGRAM_SIZE;
-	req.wValue = 0;
-	req.wIndex = cpu_to_le16(iface_no);
-	req.wLength = cpu_to_le16(2);
+	if (flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE) {
+		__le16 max_datagram_size;
+		u16 eth_max_sz = le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
+
+		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN |
+							USB_RECIP_INTERFACE;
+		req.bNotificationType = USB_CDC_GET_MAX_DATAGRAM_SIZE;
+		req.wValue = 0;
+		req.wIndex = cpu_to_le16(iface_no);
+		req.wLength = cpu_to_le16(2);
+
+		err = cdc_ncm_do_request(ctx, &req, &max_datagram_size, 0, NULL,
+									1000);
+		if (err) {
+			pr_debug("GET_MAX_DATAGRAM_SIZE failed, use size=%u\n",
+						CDC_NCM_MIN_DATAGRAM_SIZE);
+		} else {
+			ctx->max_datagram_size = le16_to_cpu(max_datagram_size);
+			/* Check Eth descriptor value */
+			if (eth_max_sz < CDC_NCM_MAX_DATAGRAM_SIZE) {
+				if (ctx->max_datagram_size > eth_max_sz)
+					ctx->max_datagram_size = eth_max_sz;
+			} else {
+				if (ctx->max_datagram_size >
+						CDC_NCM_MAX_DATAGRAM_SIZE)
+					ctx->max_datagram_size =
+						CDC_NCM_MAX_DATAGRAM_SIZE;
+			}
 
-	err = cdc_ncm_do_request(ctx, &req, &max_datagram_size, 0, NULL, 1000);
-	if (err) {
-		pr_debug(" GET_MAX_DATAGRAM_SIZE failed, using size=%u\n",
-			 CDC_NCM_MIN_DATAGRAM_SIZE);
-		/* use default */
-		ctx->max_datagram_size = CDC_NCM_MIN_DATAGRAM_SIZE;
-	} else {
-		ctx->max_datagram_size = le16_to_cpu(max_datagram_size);
+			if (ctx->max_datagram_size < CDC_NCM_MIN_DATAGRAM_SIZE)
+				ctx->max_datagram_size =
+					CDC_NCM_MIN_DATAGRAM_SIZE;
+
+			/* if value changed, update device */
+			req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
+							USB_RECIP_INTERFACE;
+			req.bNotificationType = USB_CDC_SET_MAX_DATAGRAM_SIZE;
+			req.wValue = 0;
+			req.wIndex = cpu_to_le16(iface_no);
+			req.wLength = 2;
+			max_datagram_size = cpu_to_le16(ctx->max_datagram_size);
+
+			err = cdc_ncm_do_request(ctx, &req, &max_datagram_size,
+								0, NULL, 1000);
+			if (err)
+				pr_debug("SET_MAX_DATAGRAM_SIZE failed\n");
+		}
 
-		if (ctx->max_datagram_size < CDC_NCM_MIN_DATAGRAM_SIZE)
-			ctx->max_datagram_size = CDC_NCM_MIN_DATAGRAM_SIZE;
-		else if (ctx->max_datagram_size > CDC_NCM_MAX_DATAGRAM_SIZE)
-			ctx->max_datagram_size = CDC_NCM_MAX_DATAGRAM_SIZE;
 	}
 
 	if (ctx->netdev->mtu != (ctx->max_datagram_size - ETH_HLEN))
@@ -466,19 +540,13 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 
 			ctx->ether_desc =
 					(const struct usb_cdc_ether_desc *)buf;
-
 			dev->hard_mtu =
 				le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
 
-			if (dev->hard_mtu <
-			    (CDC_NCM_MIN_DATAGRAM_SIZE - ETH_HLEN))
-				dev->hard_mtu =
-					CDC_NCM_MIN_DATAGRAM_SIZE - ETH_HLEN;
-
-			else if (dev->hard_mtu >
-				 (CDC_NCM_MAX_DATAGRAM_SIZE - ETH_HLEN))
-				dev->hard_mtu =
-					CDC_NCM_MAX_DATAGRAM_SIZE - ETH_HLEN;
+			if (dev->hard_mtu < CDC_NCM_MIN_DATAGRAM_SIZE)
+				dev->hard_mtu =	CDC_NCM_MIN_DATAGRAM_SIZE;
+			else if (dev->hard_mtu > CDC_NCM_MAX_DATAGRAM_SIZE)
+				dev->hard_mtu =	CDC_NCM_MAX_DATAGRAM_SIZE;
 			break;
 
 		case USB_CDC_NCM_TYPE:
@@ -628,13 +696,13 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	u32 offset;
 	u32 last_offset;
 	u16 n = 0;
-	u8 timeout = 0;
+	u8 ready2send = 0;
 
 	/* if there is a remaining skb, it gets priority */
 	if (skb != NULL)
 		swap(skb, ctx->tx_rem_skb);
 	else
-		timeout = 1;
+		ready2send = 1;
 
 	/*
 	 * +----------------+
@@ -682,9 +750,10 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 
 	for (; n < ctx->tx_max_datagrams; n++) {
 		/* check if end of transmit buffer is reached */
-		if (offset >= ctx->tx_max)
+		if (offset >= ctx->tx_max) {
+			ready2send = 1;
 			break;
-
+		}
 		/* compute maximum buffer size */
 		rem = ctx->tx_max - offset;
 
@@ -711,9 +780,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 				}
 				ctx->tx_rem_skb = skb;
 				skb = NULL;
-
-				/* loop one more time */
-				timeout = 1;
+				ready2send = 1;
 			}
 			break;
 		}
@@ -756,7 +823,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 		ctx->tx_curr_last_offset = last_offset;
 		goto exit_no_skb;
 
-	} else if ((n < ctx->tx_max_datagrams) && (timeout == 0)) {
+	} else if ((n < ctx->tx_max_datagrams) && (ready2send == 0)) {
 		/* wait for more frames */
 		/* push variables */
 		ctx->tx_curr_skb = skb_out;
@@ -813,7 +880,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 					cpu_to_le16(sizeof(ctx->tx_ncm.nth16));
 	ctx->tx_ncm.nth16.wSequence = cpu_to_le16(ctx->tx_seq);
 	ctx->tx_ncm.nth16.wBlockLength = cpu_to_le16(last_offset);
-	ctx->tx_ncm.nth16.wFpIndex = ALIGN(sizeof(struct usb_cdc_ncm_nth16),
+	ctx->tx_ncm.nth16.wNdpIndex = ALIGN(sizeof(struct usb_cdc_ncm_nth16),
 							ctx->tx_ndp_modulus);
 
 	memcpy(skb_out->data, &(ctx->tx_ncm.nth16), sizeof(ctx->tx_ncm.nth16));
@@ -825,13 +892,13 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	rem = sizeof(ctx->tx_ncm.ndp16) + ((ctx->tx_curr_frame_num + 1) *
 					sizeof(struct usb_cdc_ncm_dpe16));
 	ctx->tx_ncm.ndp16.wLength = cpu_to_le16(rem);
-	ctx->tx_ncm.ndp16.wNextFpIndex = 0; /* reserved */
+	ctx->tx_ncm.ndp16.wNextNdpIndex = 0; /* reserved */
 
-	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wFpIndex,
+	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wNdpIndex,
 						&(ctx->tx_ncm.ndp16),
 						sizeof(ctx->tx_ncm.ndp16));
 
-	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wFpIndex +
+	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wNdpIndex +
 					sizeof(ctx->tx_ncm.ndp16),
 					&(ctx->tx_ncm.dpe16),
 					(ctx->tx_curr_frame_num + 1) *
@@ -961,7 +1028,7 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 		goto error;
 	}
 
-	temp = le16_to_cpu(ctx->rx_ncm.nth16.wFpIndex);
+	temp = le16_to_cpu(ctx->rx_ncm.nth16.wNdpIndex);
 	if ((temp + sizeof(ctx->rx_ncm.ndp16)) > actlen) {
 		pr_debug("invalid DPT16 index\n");
 		goto error;
@@ -1048,10 +1115,10 @@ error:
 
 static void
 cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
-		     struct connection_speed_change *data)
+		     struct usb_cdc_speed_change *data)
 {
-	uint32_t rx_speed = le32_to_cpu(data->USBitRate);
-	uint32_t tx_speed = le32_to_cpu(data->DSBitRate);
+	uint32_t rx_speed = le32_to_cpu(data->DLBitRRate);
+	uint32_t tx_speed = le32_to_cpu(data->ULBitRate);
 
 	/*
 	 * Currently the USB-NET API does not support reporting the actual
@@ -1092,7 +1159,7 @@ static void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
 	/* test for split data in 8-byte chunks */
 	if (test_and_clear_bit(EVENT_STS_SPLIT, &dev->flags)) {
 		cdc_ncm_speed_change(ctx,
-		      (struct connection_speed_change *)urb->transfer_buffer);
+		      (struct usb_cdc_speed_change *)urb->transfer_buffer);
 		return;
 	}
 
@@ -1120,12 +1187,12 @@ static void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
 		break;
 
 	case USB_CDC_NOTIFY_SPEED_CHANGE:
-		if (urb->actual_length <
-		    (sizeof(*event) + sizeof(struct connection_speed_change)))
+		if (urb->actual_length < (sizeof(*event) +
+					sizeof(struct usb_cdc_speed_change)))
 			set_bit(EVENT_STS_SPLIT, &dev->flags);
 		else
 			cdc_ncm_speed_change(ctx,
-				(struct connection_speed_change *) &event[1]);
+				(struct usb_cdc_speed_change *) &event[1]);
 		break;
 
 	default:
-- 
1.7.4

