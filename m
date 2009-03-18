From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] bas_gigaset: correctly allocate USB interrupt transfer buffer
Date: Wed, 18 Mar 2009 16:58:50 +0100 (CET)
Message-ID: <20090318-patch-01.tilman@imap.cc>
Cc: Kolja Waschk <kawk@users.sourceforge.net>,
	Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:45312 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581AbZCRP7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 11:59:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

the following patch corrects a serious bug in the Gigaset driver,
reported by Kolja Waschk, which made the driver unusable on the MIPS
platform. It is not a regression in the proper sense of the word -
the problem has been there since the creation of the Gigaset driver.
(I wonder how we got away with it for so long.) But nevertheless I'd
like to see it included in v2.6.29 if that is still possible. If not,
please let me know so that I can submit it to the -stable branch as
soon as possible.

The patch doesn't apply to v2.6.28 and earlier because of a (trivial)
conflict with commit c8770dc. I'll prepare a separate patch for
2.6.27.x/2.6.28.x as soon as this one is merged in mainline.

Thanks,
Tilman

bas_gigaset: correctly allocate USB interrupt transfer buffer

Every USB transfer buffer has to be allocated individually by kmalloc.

Impact: bugfix, no functional change

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Tested-by: Kolja Waschk <kawk@users.sourceforge.net>
---
 drivers/isdn/gigaset/bas-gigaset.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 18dd8aa..831ddce 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -46,6 +46,9 @@ MODULE_PARM_DESC(cidmode, "Call-ID mode");
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
@@ -657,7 +660,7 @@ static void read_int_callback(struct urb *urb)
 	}
 
 	/* drop incomplete packets even if the missing bytes wouldn't matter */
-	if (unlikely(urb->actual_length < 3)) {
+	if (unlikely(urb->actual_length < IP_MSGSIZE)) {
 		dev_warn(cs->dev, "incomplete interrupt packet (%d bytes)\n",
 			 urb->actual_length);
 		goto resubmit;
@@ -2127,6 +2130,7 @@ static void gigaset_reinitbcshw(struct bc_state *bcs)
 static void gigaset_freecshw(struct cardstate *cs)
 {
 	/* timers, URBs and rcvbuf are disposed of in disconnect */
+	kfree(cs->hw.bas->int_in_buf);
 	kfree(cs->hw.bas);
 	cs->hw.bas = NULL;
 }
@@ -2140,6 +2144,12 @@ static int gigaset_initcshw(struct cardstate *cs)
 		pr_err("out of memory\n");
 		return 0;
 	}
+	ucs->int_in_buf = kmalloc(IP_MSGSIZE, GFP_KERNEL);
+	if (!ucs->int_in_buf) {
+		kfree(ucs);
+		pr_err("out of memory\n");
+		return 0;
+	}
 
 	ucs->urb_cmd_in = NULL;
 	ucs->urb_cmd_out = NULL;
@@ -2292,7 +2302,7 @@ static int gigaset_probe(struct usb_interface *interface,
 	usb_fill_int_urb(ucs->urb_int_in, udev,
 			 usb_rcvintpipe(udev,
 					(endpoint->bEndpointAddress) & 0x0f),
-			 ucs->int_in_buf, 3, read_int_callback, cs,
+			 ucs->int_in_buf, IP_MSGSIZE, read_int_callback, cs,
 			 endpoint->bInterval);
 	if ((rc = usb_submit_urb(ucs->urb_int_in, GFP_KERNEL)) != 0) {
 		dev_err(cs->dev, "could not submit interrupt URB: %s\n",
-- 
1.6.1.rc2

