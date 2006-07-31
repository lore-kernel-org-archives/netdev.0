From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Mon, 31 Jul 2006 21:30:50 +1000
Message-ID: <20060731113050.GA25972@gondor.apana.org.au>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56337 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932249AbWGaLbE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 07:31:04 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44CDDDF7.70004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 12:39:51PM +0200, Patrick McHardy wrote:
> 
> These are the patches (some variantions tested, but not all) on
> top of Herbert's CHECKSUM_PARTIAL patch. The first one fixes up
> the CHECKSUM_PARTIAL patch for 2.6.18-rc3, the second one fixes
> checksumming in all of netfilter besides ip_queue, the third one
> fixes ip_queue.

Thank you very much for working on this Patrick!

> Its actually not that much, if Herbert is fine with putting the
> CHECKSUM_PARTIAL patch in 2.6.18 I'll do some more testing and
> then I think these can go in as well.

You guys know I'm a coward when it comes to pushing things into rc :)

So I'd rather see a patch to disable the warnings for 2.6.18 so that
the proper fix can be tested more thoroughly.  We should remember that
the 2.6.18 minus the warning is still going to be heaps better in this
regard compared to 2.6.17 where all TSO packets were essentially
discarded due to the incorrect checksum (when the NAT module is loaded).

> [NET]: Fix up CHECKSUM_PARTIAL patch for 2.6.18-rc3
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Please merge this with my earlier patch.  I'm not that fussed about
having my changeset go in :)

> diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_core.c
> index 1741d55..731efbb 100644
> --- a/net/ipv4/netfilter/ip_nat_core.c
> +++ b/net/ipv4/netfilter/ip_nat_core.c
> @@ -443,7 +443,9 @@ int ip_nat_icmp_reply_translation(struct
>  
>  	/* We're actually going to mangle it beyond trivial checksum
>  	   adjustment, so make sure the current checksum is correct. */
> -	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY) {
> +
> +	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY &&
> +	    (*pskb)->ip_summed != CHECKSUM_PARTIAL) {
>  		hdrlen = (*pskb)->nh.iph->ihl * 4;
>  		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
>  						(*pskb)->len - hdrlen, 0)))

Call me picky, but I'd prefer it to actually look like

	switch ((*pskb)->ip_summed) {
	case CHECKSUM_COMPLETE:
		if (!(u16)csum_fold(skb->csum))
			break;
		/* fall through */
	case CHECKSUM_NONE:
		hdrlen = (*pskb)->nh.iph->ihl * 4;
		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
						(*pskb)->len - hdrlen, 0)))
			return 0;
	}

just because we probably won't revisit this code path for another
million years to add this optimisation :)

> diff --git a/net/ipv4/netfilter/ip_nat_helper.c b/net/ipv4/netfilter/ip_nat_helper.c
> index cbcaa45..dd0ddd4 100644
> --- a/net/ipv4/netfilter/ip_nat_helper.c
> +++ b/net/ipv4/netfilter/ip_nat_helper.c
> @@ -165,7 +165,7 @@ ip_nat_mangle_tcp_packet(struct sk_buff 
>  {
>  	struct iphdr *iph;
>  	struct tcphdr *tcph;
> -	int datalen;
> +	int oldlen, datalen;
>  
>  	if (!skb_make_writable(pskb, (*pskb)->len))
>  		return 0;
> @@ -180,13 +180,22 @@ ip_nat_mangle_tcp_packet(struct sk_buff 
>  	iph = (*pskb)->nh.iph;
>  	tcph = (void *)iph + iph->ihl*4;
>  
> +	oldlen = (*pskb)->len - iph->ihl*4;
>  	mangle_contents(*pskb, iph->ihl*4 + tcph->doff*4,
>  			match_offset, match_len, rep_buffer, rep_len);
>  
>  	datalen = (*pskb)->len - iph->ihl*4;
> -	tcph->check = 0;
> -	tcph->check = tcp_v4_check(tcph, datalen, iph->saddr, iph->daddr,
> -				   csum_partial((char *)tcph, datalen, 0));
> +	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
> +		tcph->check = 0;
> +		tcph->check = tcp_v4_check(tcph, datalen,
> +					   iph->saddr, iph->daddr,
> +					   csum_partial((char *)tcph,
> +					   		datalen, 0));
> +	} else
> +		tcph->check = nf_proto_csum_update(*pskb,
> +						   htons(oldlen) ^ 0xFFFF,
> +						   htons(datalen),
> +						   tcph->check, 1);

OK, this is so incredibly clever that I probably won't understand it
until tomorrow :)

> @@ -238,22 +248,30 @@ ip_nat_mangle_udp_packet(struct sk_buff 
>  
>  	iph = (*pskb)->nh.iph;
>  	udph = (void *)iph + iph->ihl*4;
> +
> +	oldlen = (*pskb)->len - iph->ihl*4;
>  	mangle_contents(*pskb, iph->ihl*4 + sizeof(*udph),
>  			match_offset, match_len, rep_buffer, rep_len);
>  
>  	/* update the length of the UDP packet */
> -	udph->len = htons((*pskb)->len - iph->ihl*4);
> +	datalen = (*pskb)->len - iph->ihl*4;
> +	udph->len = htons(datalen);
>  
>  	/* fix udp checksum if udp checksum was previously calculated */
> -	if (udph->check) {
> -		int datalen = (*pskb)->len - iph->ihl * 4;
> +	if (!udph->check)
> +		return 1;

Just a quick thought, what if the partial checksum was zero?

I'm goint to review the rest of your patch tomorrow morning because
I always fall sleep when looking at checksums :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
