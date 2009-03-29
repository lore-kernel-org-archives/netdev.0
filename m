From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/2] kaweth: Clean up code
Date: Sun, 29 Mar 2009 18:32:56 -0500
Message-ID: <49d00528.CwoMz3QjGQQs0fvV%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.124]:61436 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbZC2XdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 19:33:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver kaweth yields a -EBUSY error when starting, and a -ETIME
error when shutting down. These errors are avoided, and the RX status
is further checked for other potential errors.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Jeff,

As the listed authors of this driver have not touched it in several years,
I have taken the liberty of sending it to you as networking drivers maintainer.
I hope this is OK.

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
@@ -610,14 +609,30 @@ static void kaweth_usb_receive(struct ur
 	unsigned long flags;
 
 	spin_lock_irqsave(&kaweth->device_lock, flags);
-	if(unlikely(status == -ECONNRESET || status == -ESHUTDOWN))
-	/* we are killed - set a flag and wake the disconnect handler */
-	{
+	if (unlikely(status == -EPIPE)) {
+		kaweth->stats.rx_errors++;
 		kaweth->end = 1;
 		wake_up(&kaweth->term_wait);
+		dbg("Status was -EPIPE.");
 		goto out;
 	}
-
+	if (unlikely(status == -ECONNRESET || status == -ESHUTDOWN)) {
+		/* we are killed - set a flag and wake the disconnect handler */
+		kaweth->end = 1;
+		wake_up(&kaweth->term_wait);
+		dbg("Status was -ECONNRESET or -ESHUTDOWN.");
+		goto out;
+	}
+	if (unlikely(status == -EPROTO || status == -ETIME ||
+		     status == -EILSEQ)) {
+		kaweth->stats.rx_errors++;
+		dbg("Status was -EPROTO, -ETIME, or -EILSEQ.");
+		goto out;
+	}
+	if (unlikely(status == -EOVERFLOW)) {
+		kaweth->stats.rx_errors++;
+		dbg("Status was -EOVERFLOW.");
+	}
 	if (IS_BLOCKED(kaweth->status))
 		goto out;
 
@@ -887,13 +902,16 @@ static void kaweth_set_rx_mode(struct ne
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
@@ -904,13 +922,10 @@ static void kaweth_async_set_rx_mode(str
 				0,
 				KAWETH_CONTROL_TIMEOUT);
 
-	if(result < 0) {
-		err("Failed to set Rx mode: %d", result);
-	}
-	else {
-		dbg("Set Rx mode to %d", packet_filter_bitmap);
-	}
-	}
+	if (result < 0)
+		err("Failed to set Rx mode: 0x%X", result);
+	else
+		dbg("Set Rx mode to 0x%X", packet_filter_bitmap);
 }
 
 /****************************************************************
