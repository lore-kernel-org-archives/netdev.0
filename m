From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 08/11] firewire net: Fix leakage of kmap for broadcast
 receive buffer.
Date: Fri, 08 Mar 2013 10:43:37 +0900
Message-ID: <51394249.50305@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39240 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755826Ab3CHBni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:43:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index d8cb6ac..0dc2fdf 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1228,6 +1228,8 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
  failed_rcv_queue:
 	kfree(dev->broadcast_rcv_buffer_ptrs);
 	dev->broadcast_rcv_buffer_ptrs = NULL;
+	for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++)
+		kunmap(dev->broadcast_rcv_buffer.pages[u]);
  failed_ptrs_alloc:
 	fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer, dev->card);
  failed_buffer_init:
@@ -1620,10 +1622,15 @@ static int fwnet_remove(struct device *_dev)
 
 		fwnet_fifo_stop(dev);
 		if (dev->broadcast_rcv_context) {
+			unsigned u;
+
 			fw_iso_context_stop(dev->broadcast_rcv_context);
 
 			kfree(dev->broadcast_rcv_buffer_ptrs);
 			dev->broadcast_rcv_buffer_ptrs = NULL;
+			for (u = 0; u < FWNET_ISO_PAGE_COUNT; u++)
+				kunmap(dev->broadcast_rcv_buffer.pages[u]);
+
 			fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer,
 					      dev->card);
 			fw_iso_context_destroy(dev->broadcast_rcv_context);
-- 
1.7.9.5
