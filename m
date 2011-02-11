From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO/GSO hiding PMTU?
Date: Fri, 11 Feb 2011 17:41:38 +1100
Message-ID: <20110211064138.GB29940@gondor.apana.org.au>
References: <20110210.145555.39165146.davem@davemloft.net> <20110210235022.GA25293@gondor.apana.org.au> <20110210.222216.104050992.davem@davemloft.net> <20110210.223544.189709102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110210.223544.189709102.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 10, 2011 at 10:35:44PM -0800, David Miller wrote:
>
> Herbert how does this look for now?

This should work.

> Of course, we need to do something similar in all kinds of other spots.
> 
> Even places like bridging :-/

Yeah every place that does skb->len and skb_is_gso checks will need
this.

> +static bool send_frag_needed(struct sk_buff *skb, struct rtable *rt)
> +{
> +	unsigned int len_to_check = skb->len;
> +
> +	if (skb_is_gso(skb)) {
> +		unsigned int gso_size = skb_shinfo(skb)->gso_size;
> +		unsigned int ihl = ip_hdr(skb)->ihl * 4;
> +		struct tcphdr th_stack, *th;
> +
> +		if (WARN_ON_ONCE(ip_hdr(skb)->protocol != IPPROTO_TCP))
> +			return false;
> +
> +		th = skb_header_pointer(skb, ihl, sizeof(th_stack),
> +					&th_stack);
> +		if (!th)
> +			return false;
> +
> +		len_to_check = gso_size + ihl + (th->doff * 4);

I think we need to do some length verifications here because for
a malicious guest-generated packet the TCP header may not be present.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
