From: David Miller <davem@davemloft.net>
Subject: Re: ipgre rss is broken since gro
Date: Mon, 10 Dec 2012 14:02:44 -0500 (EST)
Message-ID: <20121210.140244.19820255229467909.davem@davemloft.net>
References: <CANn89iKtWuN=CRn-JBzmmo8jCCJQhZjAT8jA+9dgfmup99O03g@mail.gmail.com>
	<504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
	<1355158471.27891.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, edumazet@google.com, netdev@vger.kernel.org,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab2LJTCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 14:02:47 -0500
In-Reply-To: <1355158471.27891.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Dec 2012 08:54:31 -0800

> I believe performance problem might come from the
> skb_set_queue_mapping(skb, 0); in __skb_tunnel_rx()
> 
> So all packets are queued into a single GRO queue, instead of being
> split as intended in multiple queues.
> 
> I cant find why we must clear queue_mapping, so could you try :

Tom says:

commit 693019e90ca45d881109d32c0c6d29adf03f6447
Author: Tom Herbert <therbert@google.com>
Date:   Thu Sep 23 11:19:54 2010 +0000

    net: reset skb queue mapping when rx'ing over tunnel
    
    Reset queue mapping when an skb is reentering the stack via a tunnel.
    On second pass, the queue mapping from the original device is no
    longer valid.
    
    Signed-off-by: Tom Herbert <therbert@google.com>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/dst.h b/include/net/dst.h
index 81d1413..0238650 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -242,6 +242,7 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
 	skb->rxhash = 0;
+	skb_set_queue_mapping(skb, 0);
 	skb_dst_drop(skb);
 	nf_reset(skb);
 }
