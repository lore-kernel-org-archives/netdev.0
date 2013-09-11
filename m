From: "David Laight" <David.Laight@ACULAB.COM>
Subject: usbnet transmit path problems
Date: Wed, 11 Sep 2013 10:10:02 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52802 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752311Ab3IKJKy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 05:10:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17012-08 for <netdev@vger.kernel.org>;
 Wed, 11 Sep 2013 10:10:47 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been looking at the code in drivers/net/usb/usbnet.c that
processes tx data after the tx_fixup() function has run.

The code currently looks like:

	usb_fill_bulk_urb (urb, dev->udev, dev->out,
			skb->data, skb->len, tx_complete, skb);
	if (dev->can_dma_sg) {
		if (build_dma_sg(skb, urb) < 0)
			goto drop;
	}
	entry->length = length = urb->transfer_buffer_length;

	/* don't assume the hardware handles USB_ZERO_PACKET
	 * NOTE:  strictly conforming cdc-ether devices should expect
	 * the ZLP here, but ignore the one-byte packet.
	 * NOTE2: CDC NCM specification is different from CDC ECM when
	 * handling ZLP/short packets, so cdc_ncm driver will make short
	 * packet itself if needed.
	 */
	if (length % dev->maxpacket == 0) {
		if (!(info->flags & FLAG_SEND_ZLP)) {
			if (!(info->flags & FLAG_MULTI_PACKET)) {
				urb->transfer_buffer_length++;
				if (skb_tailroom(skb)) {
					skb->data[skb->len] = 0;
					__skb_put(skb, 1);
				}
			}
		} else
			urb->transfer_flags |= URB_ZERO_PACKET;
	}

1) I can't see where skb_linearize() gets called if 'can_dma_sg' is unset.

2) If 'length % dev->maxpacket == 0' for a multi-fragment packet then
   the extra byte isn't added correctly (the code probably falls off
   the end of the scatter-gather list).

3) If 'length % dev->maxpacket == 0' for a single-fragment packet then
   shouldn't there be a check that the skb isn't shared before modifying it?
   Also if there is no tailroom increasing the usb transfer length might
   result in reading an unmapped memory location.

Have I missed something, or is all this code in the wrong order?

4) I read that USB3 has a different scheme for terminating bulk data
   that is a multiple of the packet size.
   Does this mean that the pad byte isn't needed for USB3?
   (Or are USB3 controllers/targets just as buggy?)

	David
