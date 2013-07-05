From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netfront: pull on receive skb may need to happen
 earlier
Date: Fri, 5 Jul 2013 15:53:19 +0100
Message-ID: <20130705145319.GB9050@zion.uk.xensource.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, Ian Campbell <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, Dion Kant <g.w.kant@hunenet.nl>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:4179 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757500Ab3GEOxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jul 2013 10:53:21 -0400
Content-Disposition: inline
In-Reply-To: <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 05, 2013 at 10:32:41AM +0100, Jan Beulich wrote:
> Due to commit 3683243b ("xen-netfront: use __pskb_pull_tail to ensure
> linear area is big enough on RX") xennet_fill_frags() may end up
> filling MAX_SKB_FRAGS + 1 fragments in a receive skb, and only reduce
> the fragment count subsequently via __pskb_pull_tail(). That's a
> result of xennet_get_responses() allowing a maximum of one more slot to
> be consumed (and intermediately transformed into a fragment) if the
> head slot has a size less than or equal to RX_COPY_THRESHOLD.
> 
> Hence we need to adjust xennet_fill_frags() to pull earlier if we
> reached the maximum fragment count - due to the described behavior of
> xennet_get_responses() this guarantees that at least the first fragment
> will get completely consumed, and hence the fragment count reduced.
> 
> In order to not needlessly call __pskb_pull_tail() twice, make the
> original call conditional upon the pull target not having been reached
> yet, and defer the newly added one as much as possible (an alternative
> would have been to always call the function right before the call to
> xennet_fill_frags(), but that would imply more frequent cases of
> needing to call it twice).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: stable@vger.kernel.org (3.6 onwards)
> 
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -831,6 +831,15 @@ static RING_IDX xennet_fill_frags(struct
>  			RING_GET_RESPONSE(&np->rx, ++cons);
>  		skb_frag_t *nfrag = &skb_shinfo(nskb)->frags[0];
>  
> +		if (nr_frags == MAX_SKB_FRAGS) {
> +			unsigned int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
> +
> +			BUG_ON(pull_to <= skb_headlen(skb));
> +			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));

skb_headlen is in fact "skb->len - skb->data_len". Looking at the
caller code:

    while loop {
        skb_shinfo(skb)->frags[0].page_offset = rx->offset;
	skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status);
	skb->data_len = rx->status;

	i = xennet_fill_frags(np, skb, &tmpq);

	/*                                                                                                                                             
	 * Truesize is the actual allocation size, even if the                                                                                         
	 * allocation is only partially used.                                                                                                          
	 */
	skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
	skb->len += skb->data_len;
    }

    handle_incoming_packet();

You seem to be altering the behavior of the original code, because in
your patch the skb->len is incremented before use, while in the original
code (which calls skb_headlen in handle_incoming_packet) the skb->len is
correctly set.

> +			nr_frags = shinfo->nr_frags;
> +		}
> +		BUG_ON(nr_frags >= MAX_SKB_FRAGS);
> +
>  		__skb_fill_page_desc(skb, nr_frags,
>  				     skb_frag_page(nfrag),
>  				     rx->offset, rx->status);
> @@ -929,7 +938,8 @@ static int handle_incoming_queue(struct 
>  	while ((skb = __skb_dequeue(rxq)) != NULL) {
>  		int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
>  
> -		__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
> +		if (pull_to > skb_headlen(skb))
> +			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
>  
>  		/* Ethernet work: Delayed to here as it peeks the header. */
>  		skb->protocol = eth_type_trans(skb, dev);
> 
> 
