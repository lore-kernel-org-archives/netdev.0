From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] about "net: orphan frags on receive" insanity
Date: Wed, 26 Jun 2013 12:44:34 -0700
Message-ID: <1372275874.3301.206.camel@edumazet-glaptop>
References: <1372235039.3301.126.camel@edumazet-glaptop>
	 <20130626095642.GA20982@redhat.com>
	 <1372241543.3301.157.camel@edumazet-glaptop>
	 <20130626185614.GA10713@redhat.com>
	 <1372273764.3301.200.camel@edumazet-glaptop>
	 <20130626192202.GB10713@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:47399 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab3FZToW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 15:44:22 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so7689269eaj.17
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 12:44:20 -0700 (PDT)
In-Reply-To: <20130626192202.GB10713@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 22:22 +0300, Michael S. Tsirkin wrote:

> The point is we don't know the final destination of the packet
> until it's going through the stack.
> 
> We don't want to trigger a copy for all data we get from tun:
> we only want to do this if the data has a chance to get
> queued somewhere indefinitely.

I think you missed my point.

I am pretty sure it should be done from netif_rx(), not from
__netif_receive_skb_core()
so that modern NIC devices do not have to pay this extra cost.

# size net/core/dev_*.o
   text	   data	    bss	    dec	    hex	filename
  41928	    963	    752	  43643	   aa7b	net/core/dev_before.o
  41579	    963	    752	  43294	   a91e	net/core/dev_after.o

Untested patch :

diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..3730318 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1646,8 +1646,6 @@ static inline int deliver_skb(struct sk_buff *skb,
 			      struct packet_type *pt_prev,
 			      struct net_device *orig_dev)
 {
-	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
-		return -ENOMEM;
 	atomic_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
@@ -3133,6 +3131,9 @@ int netif_rx(struct sk_buff *skb)
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
+	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		return NET_RX_DROP;
+
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	trace_netif_rx(skb);
@@ -3498,10 +3499,7 @@ ncls:
 	}
 
 	if (pt_prev) {
-		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
-			goto drop;
-		else
-			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
 drop:
 		atomic_long_inc(&skb->dev->rx_dropped);
