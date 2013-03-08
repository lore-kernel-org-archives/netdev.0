From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 09/11] firewire net: Allocate dev->broadcast_rcv_buffer_ptrs
 early.
Date: Fri, 08 Mar 2013 10:43:55 +0900
Message-ID: <5139425B.2040107@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39249 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755826Ab3CHBn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:43:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 0dc2fdf..21210fb 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1163,6 +1163,13 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
 
+	ptrptr = kmalloc(sizeof(void *) * num_packets, GFP_KERNEL);
+	if (!ptrptr) {
+		retval = -ENOMEM;
+		goto failed_ptrs_alloc;
+	}
+	dev->broadcast_rcv_buffer_ptrs = ptrptr;
+
 	context = fw_iso_context_create(dev->card, FW_ISO_CONTEXT_RECEIVE,
 					IEEE1394_BROADCAST_CHANNEL,
 					dev->card->link_speed, 8,
@@ -1177,13 +1184,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	if (retval < 0)
 		goto failed_buffer_init;
 
-	ptrptr = kmalloc(sizeof(void *) * num_packets, GFP_KERNEL);
-	if (!ptrptr) {
-		retval = -ENOMEM;
-		goto failed_ptrs_alloc;
-	}
-
-	dev->broadcast_rcv_buffer_ptrs = ptrptr;
 	for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++) {
 		void *ptr;
 		unsigned v;
@@ -1226,16 +1226,16 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	return 0;
 
  failed_rcv_queue:
-	kfree(dev->broadcast_rcv_buffer_ptrs);
-	dev->broadcast_rcv_buffer_ptrs = NULL;
 	for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++)
 		kunmap(dev->broadcast_rcv_buffer.pages[u]);
- failed_ptrs_alloc:
 	fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer, dev->card);
  failed_buffer_init:
 	fw_iso_context_destroy(context);
 	dev->broadcast_rcv_context = NULL;
  failed_context_create:
+	kfree(dev->broadcast_rcv_buffer_ptrs);
+	dev->broadcast_rcv_buffer_ptrs = NULL;
+ failed_ptrs_alloc:
 
 	return retval;
 }
@@ -1626,8 +1626,6 @@ static int fwnet_remove(struct device *_dev)
 
 			fw_iso_context_stop(dev->broadcast_rcv_context);
 
-			kfree(dev->broadcast_rcv_buffer_ptrs);
-			dev->broadcast_rcv_buffer_ptrs = NULL;
 			for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++)
 				kunmap(dev->broadcast_rcv_buffer.pages[u]);
 
@@ -1635,6 +1633,8 @@ static int fwnet_remove(struct device *_dev)
 					      dev->card);
 			fw_iso_context_destroy(dev->broadcast_rcv_context);
 			dev->broadcast_rcv_context = NULL;
+			kfree(dev->broadcast_rcv_buffer_ptrs);
+			dev->broadcast_rcv_buffer_ptrs = NULL;
 			dev->broadcast_state = FWNET_BROADCAST_ERROR;
 		}
 		for (i = 0; dev->queued_datagrams && i < 5; i++)
-- 
1.7.9.5
