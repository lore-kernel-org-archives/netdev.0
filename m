From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: macvlan: Fix device ref leak when purging bc_queue
Date: Thu, 20 Apr 2017 20:55:12 +0800
Message-ID: <20170420125512.GA9113@gondor.apana.org.au>
References: <1492618528011.11322@Dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Clifford.Wichmann@dell.com,
        netdev@vger.kernel.org
To: Joe.Ghalam@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:36838 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S941359AbdDTM4W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 08:56:22 -0400
Content-Disposition: inline
In-Reply-To: <1492618528011.11322@Dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a parent macvlan device is destroyed we end up purging its
broadcast queue without dropping the device reference count on
the packet source device.  This causes the source device to linger.

This patch drops that reference count.

Fixes: 260916dfb48c ("macvlan: Fix potential use-after free for...")
Reported-by: Joe Ghalam <Joe.Ghalam@dell.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9261722..b34eaaa 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1139,6 +1139,7 @@ static int macvlan_port_create(struct net_device *dev)
 static void macvlan_port_destroy(struct net_device *dev)
 {
 	struct macvlan_port *port = macvlan_port_get_rtnl(dev);
+	struct sk_buff *skb;
 
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
@@ -1147,7 +1148,15 @@ static void macvlan_port_destroy(struct net_device *dev)
 	 * but we need to cancel it and purge left skbs if any.
 	 */
 	cancel_work_sync(&port->bc_work);
-	__skb_queue_purge(&port->bc_queue);
+
+	while ((skb = __skb_dequeue(&port->bc_queue))) {
+		const struct macvlan_dev *src = MACVLAN_SKB_CB(skb)->src;
+
+		if (src)
+			dev_put(src->dev);
+
+		kfree_skb(skb);
+	}
 
 	kfree(port);
 }
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
