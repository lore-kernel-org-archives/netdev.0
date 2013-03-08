From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 03/11] firewire net: Setup broadcast and local fifo
 independently.
Date: Fri, 08 Mar 2013 10:42:38 +0900
Message-ID: <5139420E.5090400@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39201 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759244Ab3CHBmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:42:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 96f6ee5..fbd07eb 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1156,10 +1156,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	unsigned long offset;
 	unsigned u;
 
-	retval = fwnet_fifo_start(dev);
-	if (retval < 0)
-		goto failed_initial;
-
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
 
@@ -1240,8 +1236,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	fw_iso_context_destroy(context);
 	dev->broadcast_rcv_context = NULL;
  failed_context_create:
-	fwnet_fifo_stop(dev);
- failed_initial:
 
 	return retval;
 }
@@ -1260,10 +1254,14 @@ static int fwnet_open(struct net_device *net)
 	struct fwnet_device *dev = netdev_priv(net);
 	int ret;
 
+	ret = fwnet_fifo_start(dev);
+	if (ret)
+		return ret;
+
 	if (dev->broadcast_state == FWNET_BROADCAST_ERROR) {
 		ret = fwnet_broadcast_start(dev);
 		if (ret)
-			return ret;
+			goto out;
 	}
 	netif_start_queue(net);
 
@@ -1272,6 +1270,9 @@ static int fwnet_open(struct net_device *net)
 	spin_unlock_irq(&dev->lock);
 
 	return 0;
+out:
+	fwnet_fifo_stop(dev);
+	return ret;
 }
 
 /* ifdown */
-- 
1.7.9.5
