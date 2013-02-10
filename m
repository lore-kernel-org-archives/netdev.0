From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next (TAKE 3) 4/6] firewire net: Allocate address handler
 before registering net_device.
Date: Mon, 11 Feb 2013 02:47:09 +0900
Message-ID: <5117DD1D.9050802@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: stephan.gatzka@gmail.com, davem@davemloft.net,
	stefanr@s5r6.in-berlin.de, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38873 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756012Ab3BJRrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 12:47:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we are going to embedding our FIFO address into our pseudo HW
address, let's allocate FIFO address before registering net_device.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   37 +++++++++++++++++--------------------
 1 file changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2c263de..851aef0 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1124,19 +1124,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
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
-
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
 
@@ -1217,9 +1204,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	fw_iso_context_destroy(context);
 	dev->broadcast_rcv_context = NULL;
  failed_context_create:
-	fw_core_remove_address_handler(&dev->handler);
- failed_initial:
-	dev->local_fifo = FWNET_NO_FIFO_ADDR;
 
 	return retval;
 }
@@ -1536,6 +1520,15 @@ static int fwnet_probe(struct device *_dev)
 	dev->card = card;
 	dev->netdev = net;
 
+	dev->handler.length = 4096;
+	dev->handler.address_callback = fwnet_receive_packet;
+	dev->handler.callback_data = dev;
+
+	ret = fw_core_add_address_handler(&dev->handler, &fw_high_memory_region);
+	if (ret < 0)
+		goto out;
+	dev->local_fifo = dev->handler.offset;
+
 	/*
 	 * Use the RFC 2734 default 1500 octets or the maximum payload
 	 * as initial MTU
@@ -1559,10 +1552,13 @@ static int fwnet_probe(struct device *_dev)
 	if (ret && allocated_netdev) {
 		unregister_netdev(net);
 		list_del(&dev->dev_link);
-	}
  out:
-	if (ret && allocated_netdev)
+		if (dev->local_fifo != FWNET_NO_FIFO_ADDR) {
+			fw_core_remove_address_handler(&dev->handler);
+			dev->local_fifo = FWNET_NO_FIFO_ADDR;
+		}
 		free_netdev(net);
+	}
 
 	mutex_unlock(&fwnet_device_mutex);
 
@@ -1603,8 +1599,9 @@ static int fwnet_remove(struct device *_dev)
 	if (list_empty(&dev->peer_list)) {
 		unregister_netdev(net);
 
-		if (dev->local_fifo != FWNET_NO_FIFO_ADDR)
-			fw_core_remove_address_handler(&dev->handler);
+		fw_core_remove_address_handler(&dev->handler);
+		dev->local_fifo = FWNET_NO_FIFO_ADDR;
+
 		if (dev->broadcast_rcv_context) {
 			fw_iso_context_stop(dev->broadcast_rcv_context);
 			fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer,
-- 
1.7.9.5
