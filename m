From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] wimax/i2400m: fix erroneous NETDEV_TX_BUSY use
Date: Wed, 14 Mar 2012 12:21:44 -0700
Message-ID: <1331752904.6022.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:33398 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761382Ab2CNTVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 15:21:46 -0400
Received: by dadp12 with SMTP id p12so3392397dad.11
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 12:21:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A driver start_xmit() method cannot free skb and return NETDEV_TX_BUSY,
since caller is going to reuse freed skb.

In fact netif_tx_stop_queue() / netif_stop_queue() is needed before
returning NETDEV_TX_BUSY or you can trigger a ksoftirqd fatal loop.

In case of memory allocation error, only safe way is to drop the packet
and return NETDEV_TX_OK

Also increments tx_dropped counter

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
---
 drivers/net/wimax/i2400m/netdev.c |   30 +++++++++-------------------
 1 file changed, 10 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c
b/drivers/net/wimax/i2400m/netdev.c
index 64a1106..63e4b70 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -367,38 +367,28 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_buff
*skb,
 {
 	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
 	struct device *dev = i2400m_dev(i2400m);
-	int result;
+	int result = -1;
 
 	d_fnstart(3, dev, "(skb %p net_dev %p)\n", skb, net_dev);
-	if (skb_header_cloned(skb)) {
-		/*
-		 * Make tcpdump/wireshark happy -- if they are
-		 * running, the skb is cloned and we will overwrite
-		 * the mac fields in i2400m_tx_prep_header. Expand
-		 * seems to fix this...
-		 */
-		result = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (result) {
-			result = NETDEV_TX_BUSY;
-			goto error_expand;
-		}
-	}
+
+	if (skb_header_cloned(skb) && 
+	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		goto drop;
 
 	if (i2400m->state == I2400M_SS_IDLE)
 		result = i2400m_net_wake_tx(i2400m, net_dev, skb);
 	else
 		result = i2400m_net_tx(i2400m, net_dev, skb);
-	if (result <  0)
+	if (result <  0) {
+drop:
 		net_dev->stats.tx_dropped++;
-	else {
+	} else {
 		net_dev->stats.tx_packets++;
 		net_dev->stats.tx_bytes += skb->len;
 	}
-	result = NETDEV_TX_OK;
-error_expand:
-	kfree_skb(skb);
+	dev_kfree_skb(skb);
 	d_fnend(3, dev, "(skb %p net_dev %p) = %d\n", skb, net_dev, result);
-	return result;
+	return NETDEV_TX_OK;
 }
 
 
