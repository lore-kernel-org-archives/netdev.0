From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 08:29:40 -0400
Message-ID: <1181219380.4064.55.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
	 <1181172766.4064.83.camel@localhost>
	 <20070606.165215.38711917.davem@davemloft.net>
	 <20070607004712.GE3304@havoc.gtf.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-DXvvKTvBOXR0q+T+rHDd"
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:21592 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbXFGM3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 08:29:45 -0400
Received: by py-out-1112.google.com with SMTP id a29so810538pyi
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 05:29:44 -0700 (PDT)
In-Reply-To: <20070607004712.GE3304@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DXvvKTvBOXR0q+T+rHDd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2007-06-06 at 20:47 -0400, Jeff Garzik wrote:

> 1) you need (a) well-designed hardware _and_ (b) a smart driver writer
> to avoid bottlenecking on internal driver locks.  As you can see we have
> both (a) and (b) for tg3 ;-)  

How about the following patch which fixes #b for e1000 ;->
I think the e1000s challenges are related to the gazillion variations of
boards they support and a little challenge of too many intel cooks.

Auke, why do you need the tx ring lock?

cheers,
jamal

--=-DXvvKTvBOXR0q+T+rHDd
Content-Disposition: attachment; filename=e1000-ntxl
Content-Type: text/x-patch; name=e1000-ntxl; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 16a6edf..4483d0f 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -185,7 +185,6 @@ struct e1000_tx_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
-	spinlock_t tx_lock;
 	uint16_t tdh;
 	uint16_t tdt;
 	boolean_t last_tx_tso;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cf8af92..2dd6bc0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1597,7 +1597,6 @@ setup_tx_desc_die:
 
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
-	spin_lock_init(&txdr->tx_lock);
 
 	return 0;
 }
@@ -3368,14 +3367,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -3383,7 +3377,6 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
-			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
 	}
@@ -3398,7 +3391,6 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tso = e1000_tso(adapter, tx_ring, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_OK;
 	}
 
@@ -3423,7 +3415,6 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* Make sure there is space in the ring for the next send. */
 	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 

--=-DXvvKTvBOXR0q+T+rHDd--

