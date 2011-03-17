From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and avoid TX queue overrun through packet drop
Date: Thu, 17 Mar 2011 15:40:58 +1030
Message-ID: <874o72gwm5.fsf@rustcorp.com.au>
References: <1300320775.3255.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34575 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab1CQLxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 07:53:18 -0400
In-Reply-To: <1300320775.3255.34.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2011 17:12:55 -0700, Shirley Ma <mashirle@us.ibm.com> wrote:
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

This is fascinating... and deeply weird.

OK, what's the difference between calling xmit_skb and ignoring failure,
and this patch which figures out it's going to fail before calling
xmit_skb?

ie. what if you *just* delete this:

> @@ -605,20 +620,6 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	skb_orphan(skb);
>  	nf_reset(skb);
>  
> -	/* Apparently nice girls don't return TX_BUSY; stop the queue
> -	 * before it gets out of hand.  Naturally, this wastes entries. */
> -	if (capacity < 2+MAX_SKB_FRAGS) {
> -		netif_stop_queue(dev);
> -		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
> -			/* More just got used, free them then recheck. */
> -			capacity += free_old_xmit_skbs(vi);
> -			if (capacity >= 2+MAX_SKB_FRAGS) {
> -				netif_start_queue(dev);
> -				virtqueue_disable_cb(vi->svq);
> -			}
> -		}
> -	}
> -
>  	return NETDEV_TX_OK;
>  }

Thanks!
Rusty.
