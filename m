From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 1 Aug 2006 22:29:16 +1000
Message-ID: <20060801122916.GA6177@gondor.apana.org.au>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:27922 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750934AbWHAM32
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 08:29:28 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44CE4DCA.8000609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 08:36:58PM +0200, Patrick McHardy wrote:
>
> [NETFILTER]: Get rid of HW checksum invalidation
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

It all looks great except for the csum update function.

> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 5d29d5e..a7c42c8 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -222,6 +222,29 @@ copy_skb:
>  }
>  EXPORT_SYMBOL(skb_make_writable);
>  
> +u_int16_t nf_csum_update(u_int32_t oldval, u_int32_t newval, u_int16_t csum)
> +{
> +	u_int32_t diff[] = { oldval, newval };
> +
> +	return csum_fold(csum_partial((char *)diff, sizeof(diff),
> +				      csum ^ 0xFFFF));
> +}
> +EXPORT_SYMBOL(nf_csum_update);
> +
> +u_int16_t nf_proto_csum_update(struct sk_buff *skb,
> +			       u_int32_t oldval, u_int32_t newval,
> +			       u_int16_t csum, int pseudohdr)
> +{
> +	if (skb->ip_summed != CHECKSUM_PARTIAL) {
> +		csum = nf_csum_update(oldval, newval, csum);
> +		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)

Shouldn't that be !pseudohdr?

> +			skb->csum = nf_csum_update(oldval, newval, skb->csum);
								   ^^^^^^^^^

This is a 32-bit quantity so nf_csum_update should eat a 32-bit quantity
as well.  Also, this checksum is not inverted so you need

			skb->csum = ~nf_csum_update(oldval, newval, ~skb->csum);

Of course nf_csum_update will need ~csum instead of csum^0xffff.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
