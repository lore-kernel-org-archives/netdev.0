From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 02/11] firewire net: Introduce fwnet_fifo_{start,stop}()
 helpers.
Date: Fri, 08 Mar 2013 10:42:26 +0900
Message-ID: <51394202.4020703@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39194 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752804Ab3CHBm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:42:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   51 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 35 insertions(+), 16 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index a7a0e82..96f6ee5 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1116,6 +1116,36 @@ static int fwnet_send_packet(struct fwnet_packet_task *ptask)
 	return 0;
 }
 
+static void fwnet_fifo_stop(struct fwnet_device *dev)
+{
+	if (dev->local_fifo == FWNET_NO_FIFO_ADDR)
+		return;
+
+	fw_core_remove_address_handler(&dev->handler);
+	dev->local_fifo = FWNET_NO_FIFO_ADDR;
+}
+
+static int fwnet_fifo_start(struct fwnet_device *dev)
+{
+	int retval;
+
+	if (dev->local_fifo != FWNET_NO_FIFO_ADDR)
+		return 0;
+
+	dev->handler.length = 4096;
+	dev->handler.address_callback = fwnet_receive_packet;
+	dev->handler.callback_data = dev;
+
+	retval = fw_core_add_address_handler(&dev->handler,
+					     &fw_high_memory_region);
+	if (retval < 0)
+		return retval;
+
+	dev->local_fifo = dev->handler.offset;
+
+	return 0;
+}
+
 static int fwnet_broadcast_start(struct fwnet_device *dev)
 {
 	struct fw_iso_context *context;
@@ -1126,18 +1156,9 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	unsigned long offset;
 	unsigned u;
 
-	if (dev->local_fifo == FWNET_NO_FIFO_ADDR) {
-		dev->handler.length = 4096;
-		dev->handler.address_callback = fwnet_receive_packet;
-		dev->handler.callback_data = dev;
-
-		retval = fw_core_add_address_handler(&dev->handler,
-					&fw_high_memory_region);
-		if (retval < 0)
-			goto failed_initial;
-
-		dev->local_fifo = dev->handler.offset;
-	}
+	retval = fwnet_fifo_start(dev);
+	if (retval < 0)
+		goto failed_initial;
 
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
@@ -1219,8 +1240,7 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	fw_iso_context_destroy(context);
 	dev->broadcast_rcv_context = NULL;
  failed_context_create:
-	fw_core_remove_address_handler(&dev->handler);
-	dev->local_fifo = FWNET_NO_FIFO_ADDR;
+	fwnet_fifo_stop(dev);
  failed_initial:
 
 	return retval;
@@ -1600,8 +1620,7 @@ static int fwnet_remove(struct device *_dev)
 	if (list_empty(&dev->peer_list)) {
 		unregister_netdev(net);
 
-		if (dev->local_fifo != FWNET_NO_FIFO_ADDR)
-			fw_core_remove_address_handler(&dev->handler);
+		fwnet_fifo_stop(dev);
 		if (dev->broadcast_rcv_context) {
 			fw_iso_context_stop(dev->broadcast_rcv_context);
 			fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer,
-- 
1.7.9.5
