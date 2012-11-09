From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH] kaweth:BQL support
Date: Fri,  9 Nov 2012 13:19:47 +0100
Message-ID: <1352463587-23899-1-git-send-email-oliver@neukum.org>
Cc: Oliver Neukum <oliver@neukum.org>, Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:42854 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab2KIMTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 07:19:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the callbacks for the statistics necessary for BQL

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/kaweth.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index afb117c..f30e07f 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -715,6 +715,7 @@ static int kaweth_open(struct net_device *net)
 		usb_kill_urb(kaweth->rx_urb);
 		goto err_out;
 	}
+	netdev_reset_queue(net);
 	kaweth->opened = 1;
 
 	netif_start_queue(net);
@@ -783,6 +784,7 @@ static void kaweth_usb_transmit_complete(struct urb *urb)
 {
 	struct kaweth_device *kaweth = urb->context;
 	struct sk_buff *skb = kaweth->tx_skb;
+	struct net_device *net = kaweth->net;
 	int status = urb->status;
 
 	if (unlikely(status != 0))
@@ -790,7 +792,8 @@ static void kaweth_usb_transmit_complete(struct urb *urb)
 			dev_dbg(&urb->dev->dev, "%s: TX status %d.\n",
 				kaweth->net->name, status);
 
-	netif_wake_queue(kaweth->net);
+	netif_wake_queue(net);
+	netdev_completed_queue(net, 1, skb->len - 2);
 	dev_kfree_skb_irq(skb);
 }
 
@@ -854,6 +857,7 @@ skip:
 	{
 		kaweth->stats.tx_packets++;
 		kaweth->stats.tx_bytes += skb->len;
+		netdev_sent_queue(net, skb->len - 2);
 	}
 
 	spin_unlock_irq(&kaweth->device_lock);
-- 
1.7.7
