From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 07/11] firewire net: Omit checking dev->broadcast_rcv_context
 in fwnet_broadcast_start().
Date: Fri, 08 Mar 2013 10:43:25 +0900
Message-ID: <5139423D.5010409@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39231 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755826Ab3CHBn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:43:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev->broadcast_rcv_context is always non-NULL if dev->broadcast_state is
not FWNET_BROADCAST_ERROR.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   57 ++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 31 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index efed4a6..d8cb6ac 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1154,6 +1154,7 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	unsigned max_receive;
 	struct fw_iso_packet packet;
 	unsigned long offset;
+	void **ptrptr;
 	unsigned u;
 
 	if (dev->broadcast_state != FWNET_BROADCAST_ERROR)
@@ -1162,42 +1163,36 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
 
-	if (!dev->broadcast_rcv_context) {
-		void **ptrptr;
-
-		context = fw_iso_context_create(dev->card,
-		    FW_ISO_CONTEXT_RECEIVE, IEEE1394_BROADCAST_CHANNEL,
-		    dev->card->link_speed, 8, fwnet_receive_broadcast, dev);
-		if (IS_ERR(context)) {
-			retval = PTR_ERR(context);
-			goto failed_context_create;
-		}
+	context = fw_iso_context_create(dev->card, FW_ISO_CONTEXT_RECEIVE,
+					IEEE1394_BROADCAST_CHANNEL,
+					dev->card->link_speed, 8,
+					fwnet_receive_broadcast, dev);
+	if (IS_ERR(context)) {
+		retval = PTR_ERR(context);
+		goto failed_context_create;
+	}
 
-		retval = fw_iso_buffer_init(&dev->broadcast_rcv_buffer,
-		    dev->card, FWNET_ISO_PAGE_COUNT, DMA_FROM_DEVICE);
-		if (retval < 0)
-			goto failed_buffer_init;
+	retval = fw_iso_buffer_init(&dev->broadcast_rcv_buffer, dev->card,
+				    FWNET_ISO_PAGE_COUNT, DMA_FROM_DEVICE);
+	if (retval < 0)
+		goto failed_buffer_init;
 
-		ptrptr = kmalloc(sizeof(void *) * num_packets, GFP_KERNEL);
-		if (!ptrptr) {
-			retval = -ENOMEM;
-			goto failed_ptrs_alloc;
-		}
+	ptrptr = kmalloc(sizeof(void *) * num_packets, GFP_KERNEL);
+	if (!ptrptr) {
+		retval = -ENOMEM;
+		goto failed_ptrs_alloc;
+	}
 
-		dev->broadcast_rcv_buffer_ptrs = ptrptr;
-		for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++) {
-			void *ptr;
-			unsigned v;
+	dev->broadcast_rcv_buffer_ptrs = ptrptr;
+	for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++) {
+		void *ptr;
+		unsigned v;
 
-			ptr = kmap(dev->broadcast_rcv_buffer.pages[u]);
-			for (v = 0; v < num_packets / FWNET_ISO_PAGE_COUNT; v++)
-				*ptrptr++ = (void *)
-						((char *)ptr + v * max_receive);
-		}
-		dev->broadcast_rcv_context = context;
-	} else {
-		context = dev->broadcast_rcv_context;
+		ptr = kmap(dev->broadcast_rcv_buffer.pages[u]);
+		for (v = 0; v < num_packets / FWNET_ISO_PAGE_COUNT; v++)
+			*ptrptr++ = (void *) ((char *)ptr + v * max_receive);
 	}
+	dev->broadcast_rcv_context = context;
 
 	packet.payload_length = max_receive;
 	packet.interrupt = 1;
-- 
1.7.9.5
