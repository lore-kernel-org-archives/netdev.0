From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] about "net: orphan frags on receive" insanity
Date: Thu, 27 Jun 2013 10:09:10 +0300
Message-ID: <20130627070910.GA5489@redhat.com>
References: <1372235039.3301.126.camel@edumazet-glaptop>
 <20130626095642.GA20982@redhat.com>
 <1372241543.3301.157.camel@edumazet-glaptop>
 <20130626185614.GA10713@redhat.com>
 <1372273764.3301.200.camel@edumazet-glaptop>
 <20130626192202.GB10713@redhat.com>
 <1372275874.3301.206.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022Ab3F0HIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 03:08:23 -0400
Content-Disposition: inline
In-Reply-To: <1372275874.3301.206.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 12:44:34PM -0700, Eric Dumazet wrote:
> On Wed, 2013-06-26 at 22:22 +0300, Michael S. Tsirkin wrote:
> 
> > The point is we don't know the final destination of the packet
> > until it's going through the stack.
> > 
> > We don't want to trigger a copy for all data we get from tun:
> > we only want to do this if the data has a chance to get
> > queued somewhere indefinitely.
> 
> I think you missed my point.
> 
> I am pretty sure it should be done from netif_rx(), not from
> __netif_receive_skb_core()
> so that modern NIC devices do not have to pay this extra cost.

Yres, this is exactly what I thought you meant, but as I said,
this approach disables tun zero copy.
The point of the current code is to copy only if there
are any host protocols that consume the skb.

> # size net/core/dev_*.o
>    text	   data	    bss	    dec	    hex	filename
>   41928	    963	    752	  43643	   aa7b	net/core/dev_before.o
>   41579	    963	    752	  43294	   a91e	net/core/dev_after.o

So we have a lot of code like this:
                if (pt_prev) {
                        ret = deliver_skb(skb, pt_prev, orig_dev);
                }
                pt_prev = NULL;
and this is what created all this.

But in practice pt_prev is set when we have multiple
consumers for a packet - this is the standard path:
        if (pt_prev) {
                if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
                        goto drop;
                else
                        ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
        }
So I think calls to deliver_skb
are not all that common - we should not make gcc inline
them so aggressively, let it make its own decisions.

Here's an alternative patch:


diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..03cb51c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1642,9 +1642,9 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
-static inline int deliver_skb(struct sk_buff *skb,
-			      struct packet_type *pt_prev,
-			      struct net_device *orig_dev)
+static int deliver_skb(struct sk_buff *skb,
+		       struct packet_type *pt_prev,
+		       struct net_device *orig_dev)
 {
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		return -ENOMEM;


This gives us more than half the gain of your patch
without breaking tun zero copy.

[mst@robin linux]$ size net/core/dev_orig.o 
   text    data     bss     dec     hex filename
  47357    1270     720   49347    c0c3 net/core/dev_orig.o
[mst@robin linux]$ size net/core/dev.o
   text    data     bss     dec     hex filename
  47105    1270     720   49095    bfc7 net/core/dev.o

Maybe we should tag calls to if (pt_prev) before deliver_skb
as unlikely, this will move this code further from the hot path -
this needs some testing.



> Untested patch :
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fc1e289..3730318 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1646,8 +1646,6 @@ static inline int deliver_skb(struct sk_buff *skb,
>  			      struct packet_type *pt_prev,
>  			      struct net_device *orig_dev)
>  {
> -	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> -		return -ENOMEM;
>  	atomic_inc(&skb->users);
>  	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>  }
> @@ -3133,6 +3131,9 @@ int netif_rx(struct sk_buff *skb)

this is basically assuming tun will use netif_rx forever,
but I think it's quite possible that we'll
switch it to napi down the road.

>  	if (netpoll_rx(skb))
>  		return NET_RX_DROP;
>  
> +	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> +		return NET_RX_DROP;
> +
>  	net_timestamp_check(netdev_tstamp_prequeue, skb);
>  
>  	trace_netif_rx(skb);

And this chunk means all tun data is immediately copied before
it's passed to net core, in effect, no zero copy transmit.

> @@ -3498,10 +3499,7 @@ ncls:
>  	}
>  
>  	if (pt_prev) {
> -		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> -			goto drop;
> -		else
> -			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> +		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>  	} else {
>  drop:
>  		atomic_long_inc(&skb->dev->rx_dropped);
>
