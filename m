From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH] xen-netfront: Avoid deref'ing skbafter it is potentially
 freed.
Date: Mon, 13 Aug 2007 12:54:37 -0700
Message-ID: <46C0B6FD.7020701@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, Keir Fraser <keir@xensource.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:48356 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968071AbXHMT4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 15:56:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

xennet_tx_bug_gc can free the skb before we use it, so make sure we don't.

Jeff, this is -rc material.

Signed-off-by: Keir Fraser <keir@xensource.com>
Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: Jeff Garzik <jeff@garzik.org>

diff -r 8bfc43f6d1b0 drivers/net/xen-netfront.c
--- a/drivers/net/xen-netfront.c	Tue Aug 07 14:26:30 2007 -0700
+++ b/drivers/net/xen-netfront.c	Mon Aug 13 09:39:15 2007 -0700
@@ -566,15 +566,16 @@ static int xennet_start_xmit(struct sk_b
 	if (notify)
 		notify_remote_via_irq(np->netdev->irq);
 
+	np->stats.tx_bytes += skb->len;
+	np->stats.tx_packets++;
+
+	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(dev);
 
 	if (!netfront_tx_slot_available(np))
 		netif_stop_queue(dev);
 
 	spin_unlock_irq(&np->tx_lock);
-
-	np->stats.tx_bytes += skb->len;
-	np->stats.tx_packets++;
 
 	return 0;
 


