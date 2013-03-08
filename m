From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 10/11] firewire net: Introduce fwnet_broadcast_stop()
 to destroy broadcast resources.
Date: Fri, 08 Mar 2013 10:45:50 +0900
Message-ID: <513942CE.7050904@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39298 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760120Ab3CHBpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:45:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   68 +++++++++++++++++++++++++-----------------------
 1 file changed, 36 insertions(+), 32 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 21210fb..ca41446 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1146,6 +1146,32 @@ static int fwnet_fifo_start(struct fwnet_device *dev)
 	return 0;
 }
 
+static void __fwnet_broadcast_stop(struct fwnet_device *dev)
+{
+	unsigned u;
+
+	if (dev->broadcast_state != FWNET_BROADCAST_ERROR) {
+		for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++)
+			kunmap(dev->broadcast_rcv_buffer.pages[u]);
+		fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer, dev->card);
+	}
+	if (dev->broadcast_rcv_context) {
+		fw_iso_context_destroy(dev->broadcast_rcv_context);
+		dev->broadcast_rcv_context = NULL;
+	}
+	kfree(dev->broadcast_rcv_buffer_ptrs);
+	dev->broadcast_rcv_buffer_ptrs = NULL;
+	dev->broadcast_state = FWNET_BROADCAST_ERROR;
+}
+
+static void fwnet_broadcast_stop(struct fwnet_device *dev)
+{
+	if (dev->broadcast_state == FWNET_BROADCAST_ERROR)
+		return;
+	fw_iso_context_stop(dev->broadcast_rcv_context);
+	__fwnet_broadcast_stop(dev);
+}
+
 static int fwnet_broadcast_start(struct fwnet_device *dev)
 {
 	struct fw_iso_context *context;
@@ -1166,7 +1192,7 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	ptrptr = kmalloc(sizeof(void *) * num_packets, GFP_KERNEL);
 	if (!ptrptr) {
 		retval = -ENOMEM;
-		goto failed_ptrs_alloc;
+		goto failed;
 	}
 	dev->broadcast_rcv_buffer_ptrs = ptrptr;
 
@@ -1176,13 +1202,15 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 					fwnet_receive_broadcast, dev);
 	if (IS_ERR(context)) {
 		retval = PTR_ERR(context);
-		goto failed_context_create;
+		goto failed;
 	}
 
 	retval = fw_iso_buffer_init(&dev->broadcast_rcv_buffer, dev->card,
 				    FWNET_ISO_PAGE_COUNT, DMA_FROM_DEVICE);
 	if (retval < 0)
-		goto failed_buffer_init;
+		goto failed;
+
+	dev->broadcast_state = FWNET_BROADCAST_STOPPED;
 
 	for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++) {
 		void *ptr;
@@ -1206,7 +1234,7 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 		retval = fw_iso_context_queue(context, &packet,
 				&dev->broadcast_rcv_buffer, offset);
 		if (retval < 0)
-			goto failed_rcv_queue;
+			goto failed;
 
 		offset += max_receive;
 	}
@@ -1216,7 +1244,7 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	retval = fw_iso_context_start(context, -1, 0,
 			FW_ISO_CONTEXT_MATCH_ALL_TAGS); /* ??? sync */
 	if (retval < 0)
-		goto failed_rcv_queue;
+		goto failed;
 
 	/* FIXME: adjust it according to the min. speed of all known peers? */
 	dev->broadcast_xmt_max_payload = IEEE1394_MAX_PAYLOAD_S100
@@ -1225,18 +1253,8 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 
 	return 0;
 
- failed_rcv_queue:
-	for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++)
-		kunmap(dev->broadcast_rcv_buffer.pages[u]);
-	fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer, dev->card);
- failed_buffer_init:
-	fw_iso_context_destroy(context);
-	dev->broadcast_rcv_context = NULL;
- failed_context_create:
-	kfree(dev->broadcast_rcv_buffer_ptrs);
-	dev->broadcast_rcv_buffer_ptrs = NULL;
- failed_ptrs_alloc:
-
+ failed:
+	__fwnet_broadcast_stop(dev);
 	return retval;
 }
 
@@ -1621,22 +1639,8 @@ static int fwnet_remove(struct device *_dev)
 		unregister_netdev(net);
 
 		fwnet_fifo_stop(dev);
-		if (dev->broadcast_rcv_context) {
-			unsigned u;
-
-			fw_iso_context_stop(dev->broadcast_rcv_context);
+		fwnet_broadcast_stop(dev);
 
-			for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++)
-				kunmap(dev->broadcast_rcv_buffer.pages[u]);
-
-			fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer,
-					      dev->card);
-			fw_iso_context_destroy(dev->broadcast_rcv_context);
-			dev->broadcast_rcv_context = NULL;
-			kfree(dev->broadcast_rcv_buffer_ptrs);
-			dev->broadcast_rcv_buffer_ptrs = NULL;
-			dev->broadcast_state = FWNET_BROADCAST_ERROR;
-		}
 		for (i = 0; dev->queued_datagrams && i < 5; i++)
 			ssleep(1);
 		WARN_ON(dev->queued_datagrams);
-- 
1.7.9.5
