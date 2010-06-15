From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: udp: Fix bogus UFO packet generation
Date: Tue, 15 Jun 2010 15:15:30 +0300
Message-ID: <20100615121530.GC2361@redhat.com>
References: <20100615115225.GA7239@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab0FOMUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 08:20:09 -0400
Content-Disposition: inline
In-Reply-To: <20100615115225.GA7239@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 09:52:25PM +1000, Herbert Xu wrote:
> Hi:
> 
> udp: Fix bogus UFO packet generation
> 
> It has been reported that the new UFO software fallback path
> fails under certain conditions with NFS.  I tracked the problem
> down to the generation of UFO packets that are smaller than the
> MTU.  The software fallback path simply discards these packets.
> 
> This patch fixes the problem by not generating such packets on
> the UFO path.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

FWIW
Reviewed-by: Michael S. Tsirkin <mst@redhat.com>


> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 9a4a6c9..041d41d 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -873,8 +873,10 @@ int ip_append_data(struct sock *sk,
>  	    !exthdrlen)
>  		csummode = CHECKSUM_PARTIAL;
>  
> +	skb = skb_peek_tail(&sk->sk_write_queue);
> +
>  	inet->cork.length += length;
> -	if (((length> mtu) || !skb_queue_empty(&sk->sk_write_queue)) &&
> +	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
>  	    (sk->sk_protocol == IPPROTO_UDP) &&
>  	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
>  		err = ip_ufo_append_data(sk, getfrag, from, length, hh_len,
> @@ -892,7 +894,7 @@ int ip_append_data(struct sock *sk,
>  	 * adding appropriate IP header.
>  	 */
>  
> -	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
> +	if (!skb)
>  		goto alloc_new_skb;
>  
>  	while (length > 0) {
> @@ -1121,7 +1123,8 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
>  		return -EINVAL;
>  
>  	inet->cork.length += size;
> -	if ((sk->sk_protocol == IPPROTO_UDP) &&
> +	if ((size + skb->len > mtu) &&
> +	    (sk->sk_protocol == IPPROTO_UDP) &&
>  	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
>  		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
>  		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
