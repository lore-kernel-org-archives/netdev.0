From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Wed, 16 Dec 2009 21:30:39 +0800
Message-ID: <20091216133039.GB18327@gondor.apana.org.au>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, mst@redhat.com,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59430 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933775AbZLPNay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 08:30:54 -0500
Content-Disposition: inline
In-Reply-To: <200912162315.38802.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 11:15:38PM +1030, Rusty Russell wrote:
> 
> virtio_net: use NAPI for xmit (UNTESTED)
> 
> This is closer to the way tg3 and ixgbe do it: use the NAPI framework to
> free transmitted packets.  It neatens things a little as well.

Looks good to me.

> @@ -544,15 +552,16 @@ again:
>  
>  	/* Apparently nice girls don't return TX_BUSY; stop the queue
>  	 * before it gets out of hand.  Naturally, this wastes entries. */
> -	if (capacity < 2+MAX_SKB_FRAGS) {
> -		netif_stop_queue(dev);
> -		if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq))) {
> -			/* More just got used, free them then recheck. */
> -			capacity += free_old_xmit_skbs(vi);
> -			if (capacity >= 2+MAX_SKB_FRAGS) {
> -				netif_start_queue(dev);
> -				vi->svq->vq_ops->disable_cb(vi->svq);
> -			}
> +	if (unlikely(capacity < 2+MAX_SKB_FRAGS)) {
> +		/* Free old skbs; might make more capacity. */
> +		vi->capacity = capacity + free_old_xmit_skbs(vi);
> +		if (unlikely(vi->capacity < 2+MAX_SKB_FRAGS)) {
> +			/* Make sure virtnet_xmit_poll sees updated capacity */
> +			wmb();

You only need smp_wmb() since this is protecting against the
guest only as opposed to the host.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
