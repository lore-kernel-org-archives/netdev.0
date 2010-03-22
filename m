From: David Miller <davem@davemloft.net>
Subject: Re: Gianfar: RX Recycle skb->len error
Date: Sun, 21 Mar 2010 21:46:42 -0700 (PDT)
Message-ID: <20100321.214642.67901344.davem@davemloft.net>
References: <A6A1774AFD79E346AE6D49A33CB294530DC19EB5@EX-BE-017-SFO.shared.themessagecenter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	Sandeep.Kumar@freescale.com
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750896Ab0CVEqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 00:46:20 -0400
In-Reply-To: <A6A1774AFD79E346AE6D49A33CB294530DC19EB5@EX-BE-017-SFO.shared.themessagecenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Date: Sat, 20 Mar 2010 12:54:59 -0700

> We are seeing some random skb data length errors on RX after long-running, full-gigabit traffic.  First, my debugging and solution are based on the following invariant assumption:
> (skb->tail - skb->data) == skb->len
> 
> If this is wrong, please educate.
> 
> After some tracing, here is where the error packets seem to originate:
> 1.  We are cleaning rx, in gfar_clean_rx_ring;
> 2.  A new RX skb is drawn from the rx_recycle queue, and obey the above invariant (so, in gfar_new_skb(), __skb_dequeue returns an skb);
> 3.  At this point skb_reserve is called, which moves data and tail by the same calculated alignamount;
> 4.  So, newskb is not NULL.  However, !(bdp->status & RXBD_LAST) || (bdp->status & RXBD_ERR)) is evaluates to true;
> 5.  Since newskb is not NULL, we arrive at the else if (skb), which is true;
> 6.  skb->data = skb->head + NET_SKB_PAD is applied, and then the skb is requeued for recycling.
> 
> At this point, skb->data != skb->tail, but skb->len == 0.  When this skb is used for the next RX, it is causing issues later when we skb_put trailers, and then trust skb->len.
> 
> I would propose something like:

Thanks for debugging this, some gianfar developers CC:'d.

> @@ -2540,6 +2540,7 @@ 
> 				 * recycle list.
>  				 */
>  				skb->data = skb->head + NET_SKB_PAD;
> +				skb_reset_tail_pointer(skb);
> 				__skb_queue_head(&priv->rx_recycle, skb);
> 			}
> 		} else {

This code is essentially trying to undo skb_reserve()
but as you found it's doing so in a buggy manner.

skb_reserve() adjusts both the 'data' and 'tail' pointers,
but this attempt at a reversal is only modifying 'data'.

Your fix is fine, but really any by-hand modification of
skb->data is a bug, and we should provide an skb_unreserve()
or similar to hide such details away, and use it here.

Anton?
