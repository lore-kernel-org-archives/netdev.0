From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2.6.27/28-stable] bas_gigaset: correctly allocate USB interrupt transfer buffer
Date: Mon, 23 Mar 2009 22:47:06 +0100 (CET)
Message-ID: <20090323-patch-01.tilman@imap.cc>
Cc: Kolja Waschk <kawk@users.sourceforge.net>,
	Hansjoerg Lipp <hjlipp@web.de>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:39340 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711AbZCWVxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 17:53:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg,

the following patch backports the Gigaset driver bugfix merged for
2.6.29 as commit 170ebf85160dd128e1c4206cc197cce7d1424705 to both
v2.6.27.x and v2.6.28.x. I would appreciate to see it included in
your stable series.

Thanks,
Tilman

bas_gigaset: correctly allocate USB interrupt transfer buffer

commit 170ebf85160dd128e1c4206cc197cce7d1424705 upstream.

Every USB transfer buffer has to be allocated individually by kmalloc.

Impact: bugfix, no functional change

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Tested-by: Kolja Waschk <kawk@users.sourceforge.net>
---
 drivers/isdn/gigaset/bas-gigaset.c |   15 +++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

--- a/drivers/isdn/gigaset/bas-gigaset.c	2008-12-25 00:26:37.000000000 +0100
+++ b/drivers/isdn/gigaset/bas-gigaset.c	2009-03-17 23:38:30.000000000 +0100
@@ -46,6 +46,9 @@ MODULE_PARM_DESC(cidmode, "Call-ID mode"
 /* length limit according to Siemens 3070usb-protokoll.doc ch. 2.1 */
 #define IF_WRITEBUF 264
 
+/* interrupt pipe message size according to ibid. ch. 2.2 */
+#define IP_MSGSIZE 3
+
 /* Values for the Gigaset 307x */
 #define USB_GIGA_VENDOR_ID      0x0681
 #define USB_3070_PRODUCT_ID     0x0001
@@ -110,7 +113,7 @@ struct bas_cardstate {
 	unsigned char		*rcvbuf;	/* AT reply receive buffer */
 
 	struct urb		*urb_int_in;	/* URB for interrupt pipe */
-	unsigned char		int_in_buf[3];
+	unsigned char		*int_in_buf;
 
 	spinlock_t		lock;		/* locks all following */
 	int			basstate;	/* bitmap (BS_*) */
@@ -657,7 +660,7 @@ static void read_int_callback(struct urb
 	}
 
 	/* drop incomplete packets even if the missing bytes wouldn't matter */
-	if (unlikely(urb->actual_length < 3)) {
+	if (unlikely(urb->actual_length < IP_MSGSIZE)) {
 		dev_warn(cs->dev, "incomplete interrupt packet (%d bytes)\n",
 			 urb->actual_length);
 		goto resubmit;
@@ -2127,6 +2130,7 @@ static void gigaset_reinitbcshw(struct b
 static void gigaset_freecshw(struct cardstate *cs)
 {
 	/* timers, URBs and rcvbuf are disposed of in disconnect */
+	kfree(cs->hw.bas->int_in_buf);
 	kfree(cs->hw.bas);
 	cs->hw.bas = NULL;
 }
@@ -2138,6 +2142,11 @@ static int gigaset_initcshw(struct cards
 	cs->hw.bas = ucs = kmalloc(sizeof *ucs, GFP_KERNEL);
 	if (!ucs)
 		return 0;
+	ucs->int_in_buf = kmalloc(IP_MSGSIZE, GFP_KERNEL);
+	if (!ucs->int_in_buf) {
+		kfree(ucs);
+		return 0;
+	}
 
 	ucs->urb_cmd_in = NULL;
 	ucs->urb_cmd_out = NULL;
@@ -2290,7 +2299,7 @@ static int gigaset_probe(struct usb_inte
 	usb_fill_int_urb(ucs->urb_int_in, udev,
 			 usb_rcvintpipe(udev,
 					(endpoint->bEndpointAddress) & 0x0f),
-			 ucs->int_in_buf, 3, read_int_callback, cs,
+			 ucs->int_in_buf, IP_MSGSIZE, read_int_callback, cs,
 			 endpoint->bInterval);
 	if ((rc = usb_submit_urb(ucs->urb_int_in, GFP_KERNEL)) != 0) {
 		dev_err(cs->dev, "could not submit interrupt URB: %s\n",
