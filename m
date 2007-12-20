From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [IPSEC]: Avoid undefined shift operation when testing
	algorithm ID
Date: Thu, 20 Dec 2007 08:58:57 +0100
Message-ID: <20071220075857.GA1924@ff.dom.local>
References: <20071220042937.GA18679@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:18649 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbXLTHxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 02:53:38 -0500
Received: by ug-out-1314.google.com with SMTP id z38so421625ugc.16
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 23:53:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071220042937.GA18679@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20-12-2007 05:29, Herbert Xu wrote:
> Hi Dave:
> 
> I had wanted to fix this for ages but kept putting it off and then
> forgetting about it :) So before I forget again,
> 
> [IPSEC]: Avoid undefined shift operation when testing algorithm ID
> 
> The aalgos/ealgos fields are only 32 bits wide.  However, af_key tries
> to test them with the expression 1 << id where id can be as large as
> 253.  This produces different behaviour on different architectures.
> 
> The following patch explicitly checks whether ID is greater than 31
> and fails the check if that's the case.
> 
> We cannot easily extend the mask to be longer than 32 bits due to
> exposure to user-space.  Besides, this whole interface is obsolete
> anyway in favour of the xfrm_user interface which doesn't use this
> bit mask in templates (well not within the kernel anyway).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 878039b..26d5e63 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -2784,12 +2784,22 @@ static struct sadb_msg *pfkey_get_base_msg(struct sk_buff *skb, int *errp)
>  
>  static inline int aalg_tmpl_set(struct xfrm_tmpl *t, struct xfrm_algo_desc *d)
>  {
> -	return t->aalgos & (1 << d->desc.sadb_alg_id);
> +	unsigned int id = d->desc.sadb_alg_id;
> +
> +	if (id >= sizeof(t->aalgos) * 8)
> +		return 0;
> +
> +	return (t->aalgos >> id) & 1;
>  }

Hi,

you probably have forgotten to mention in the changelog the returned
value is changed to 0/1 btw?

But, since you've mentioned different architectures, maybe it's the
good moment to find out why you and/or Linux doesn't seem to use
something like CHAR_BIT instead of this 8?

Thanks,
Jarek P.
