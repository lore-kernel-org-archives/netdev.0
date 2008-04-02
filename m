From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] sc92031: start transmit return value bugfix
Date: Wed, 2 Apr 2008 10:11:11 -0700
Message-ID: <20080402101111.7f01a18c@extreme>
References: <bug-10380-10286@http.bugzilla.kernel.org/>
 <20080402091435.39f99428.akpm@linux-foundation.org>
 <20080402094923.185f15dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@sharkbay.at
To: Jeff Garzik <jgarzik@pobox.com>,
	Cesar Eduardo Barros <cesarb@cesarb.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59992 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754886AbYDBRNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 13:13:23 -0400
In-Reply-To: <20080402094923.185f15dc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any negative return value from start_xmit is interpreted as NETDEV_TX_LOCK
which is not what this driver wants. It should return 0 (NETDEV_TX_OK)
when it consumes a packet.

Also, use skb_padto() as the generic way to pad small frames.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sc92031.c	2008-04-02 09:50:22.000000000 -0700
+++ b/drivers/net/sc92031.c	2008-04-02 09:53:15.000000000 -0700
@@ -947,16 +947,16 @@ static struct net_device_stats *sc92031_
 
 static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int err = 0;
 	struct sc92031_priv *priv = netdev_priv(dev);
 	void __iomem *port_base = priv->port_base;
-
 	unsigned len;
 	unsigned entry;
 	u32 tx_status;
 
+	if (skb_padto(skb, ETH_ZLEN))
+		return NETDEV_TX_OK;
+
 	if (unlikely(skb->len > TX_BUF_SIZE)) {
-		err = -EMSGSIZE;
 		dev->stats.tx_dropped++;
 		goto out;
 	}
@@ -964,7 +964,6 @@ static int sc92031_start_xmit(struct sk_
 	spin_lock(&priv->lock);
 
 	if (unlikely(!netif_carrier_ok(dev))) {
-		err = -ENOLINK;
 		dev->stats.tx_dropped++;
 		goto out_unlock;
 	}
@@ -976,11 +975,6 @@ static int sc92031_start_xmit(struct sk_
 	skb_copy_and_csum_dev(skb, priv->tx_bufs + entry * TX_BUF_SIZE);
 
 	len = skb->len;
-	if (unlikely(len < ETH_ZLEN)) {
-		memset(priv->tx_bufs + entry * TX_BUF_SIZE + len,
-				0, ETH_ZLEN - len);
-		len = ETH_ZLEN;
-	}
 
 	wmb();
 
@@ -1007,7 +1001,7 @@ out_unlock:
 out:
 	dev_kfree_skb(skb);
 
-	return err;
+	return NETDEV_TX_OK;
 }
 
 static int sc92031_open(struct net_device *dev)
