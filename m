From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (TAKE 4) 3/6] firewire net: Allocate address handler
 before registering net_device.
Date: Tue, 26 Mar 2013 03:25:57 +0900
Message-ID: <515096B5.4000204@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	stephan.gatzka@gmail.com, yoshfuji@linux-ipv6.org
To: davem@davemloft.net, stefanr@s5r6.in-berlin.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58085 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932830Ab3CYSZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 14:25:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate FIFO address before registering net_device.
This is preparation to change the pseudo hardware address format
for firewire devices to include the offset of the FIFO for receipt
of unicast datagrams, instead of mangling ARP/NDP messages in the
driver layer.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 7c2e16a..72536e7 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1286,13 +1286,9 @@ static int fwnet_open(struct net_device *net)
 	struct fwnet_device *dev = netdev_priv(net);
 	int ret;
 
-	ret = fwnet_fifo_start(dev);
-	if (ret)
-		return ret;
-
 	ret = fwnet_broadcast_start(dev);
 	if (ret)
-		goto out;
+		return ret;
 
 	netif_start_queue(net);
 
@@ -1301,9 +1297,6 @@ static int fwnet_open(struct net_device *net)
 	spin_unlock_irq(&dev->lock);
 
 	return 0;
-out:
-	fwnet_fifo_stop(dev);
-	return ret;
 }
 
 /* ifdown */
@@ -1312,9 +1305,7 @@ static int fwnet_stop(struct net_device *net)
 	struct fwnet_device *dev = netdev_priv(net);
 
 	netif_stop_queue(net);
-
 	fwnet_broadcast_stop(dev);
-	fwnet_fifo_stop(dev);
 
 	return 0;
 }
@@ -1593,6 +1584,11 @@ static int fwnet_probe(struct device *_dev)
 	dev->card = card;
 	dev->netdev = net;
 
+	ret = fwnet_fifo_start(dev);
+	if (ret < 0)
+		goto out;
+	dev->local_fifo = dev->handler.offset;
+
 	/*
 	 * Use the RFC 2734 default 1500 octets or the maximum payload
 	 * as initial MTU
@@ -1616,10 +1612,10 @@ static int fwnet_probe(struct device *_dev)
 	if (ret && allocated_netdev) {
 		unregister_netdev(net);
 		list_del(&dev->dev_link);
-	}
  out:
-	if (ret && allocated_netdev)
+		fwnet_fifo_stop(dev);
 		free_netdev(net);
+	}
 
 	mutex_unlock(&fwnet_device_mutex);
 
@@ -1660,6 +1656,8 @@ static int fwnet_remove(struct device *_dev)
 	if (list_empty(&dev->peer_list)) {
 		unregister_netdev(net);
 
+		fwnet_fifo_stop(dev);
+
 		for (i = 0; dev->queued_datagrams && i < 5; i++)
 			ssleep(1);
 		WARN_ON(dev->queued_datagrams);
-- 
1.7.9.5
