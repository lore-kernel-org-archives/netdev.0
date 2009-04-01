From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/2 V3] kaweth: Clean up code
Date: Wed, 01 Apr 2009 10:29:35 -0500
Message-ID: <49d3885f.OXwftgx2/UvY0Tex%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:45841 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbZDAP3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 11:29:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver kaweth yields a -EBUSY error when starting, and a -ETIME
error when shutting down. These errors are avoided, and the RX status
is further checked for other potential errors.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

DaveM,

This is 2.6.31 material as the imain change is to eliminate two trivial
log messages.

Larry
---

Index: wireless-testing/drivers/net/usb/kaweth.c
===================================================================
--- wireless-testing.orig/drivers/net/usb/kaweth.c
+++ wireless-testing/drivers/net/usb/kaweth.c
@@ -31,7 +31,6 @@
  ****************************************************************/
 
 /* TODO:
- * Fix in_interrupt() problem
  * Develop test procedures for USB net interfaces
  * Run test procedures
  * Fix bugs from previous two steps
@@ -606,14 +605,30 @@ static void kaweth_usb_receive(struct ur
 
 	struct sk_buff *skb;
 
-	if(unlikely(status == -ECONNRESET || status == -ESHUTDOWN))
-	/* we are killed - set a flag and wake the disconnect handler */
-	{
+	if (unlikely(status == -EPIPE)) {
+		kaweth->stats.rx_errors++;
 		kaweth->end = 1;
 		wake_up(&kaweth->term_wait);
+		dbg("Status was -EPIPE.");
 		return;
 	}
-
+	if (unlikely(status == -ECONNRESET || status == -ESHUTDOWN)) {
+		/* we are killed - set a flag and wake the disconnect handler */
+		kaweth->end = 1;
+		wake_up(&kaweth->term_wait);
+		dbg("Status was -ECONNRESET or -ESHUTDOWN.");
+		return;
+	}
+	if (unlikely(status == -EPROTO || status == -ETIME ||
+		     status == -EILSEQ)) {
+		kaweth->stats.rx_errors++;
+		dbg("Status was -EPROTO, -ETIME, or -EILSEQ.");
+		return;
+	}
+	if (unlikely(status == -EOVERFLOW)) {
+		kaweth->stats.rx_errors++;
+		dbg("Status was -EOVERFLOW.");
+	}
 	spin_lock(&kaweth->device_lock);
 	if (IS_BLOCKED(kaweth->status)) {
 		spin_unlock(&kaweth->device_lock);
@@ -883,13 +898,16 @@ static void kaweth_set_rx_mode(struct ne
  ****************************************************************/
 static void kaweth_async_set_rx_mode(struct kaweth_device *kaweth)
 {
+	int result;
 	__u16 packet_filter_bitmap = kaweth->packet_filter_bitmap;
+
 	kaweth->packet_filter_bitmap = 0;
 	if (packet_filter_bitmap == 0)
 		return;
 
-	{
-	int result;
+	if (in_interrupt())
+		return;
+
 	result = kaweth_control(kaweth,
 				usb_sndctrlpipe(kaweth->dev, 0),
 				KAWETH_COMMAND_SET_PACKET_FILTER,
@@ -906,7 +924,6 @@ static void kaweth_async_set_rx_mode(str
 	else {
 		dbg("Set Rx mode to %d", packet_filter_bitmap);
 	}
-	}
 }
 
 /****************************************************************
