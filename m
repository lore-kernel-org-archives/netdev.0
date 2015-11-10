From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf 2/2] netfilter: nf_tables: add clone interface to
 expression operations
Date: Tue, 10 Nov 2015 18:30:34 +0000
Message-ID: <20151110183034.GE25929@macbook.localdomain>
References: <1447173390-2993-1-git-send-email-pablo@netfilter.org>
 <1447173390-2993-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447173390-2993-3-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.11, Pablo Neira Ayuso wrote:
> With the conversion of the counter expressions to make it percpu, we
> need to clone the percpu memory area, otherwise we crash when using
> counters from flow tables.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  include/net/netfilter/nf_tables.h | 16 +++++++++++--
>  net/netfilter/nft_counter.c       | 49 ++++++++++++++++++++++++++++++++-------
>  net/netfilter/nft_dynset.c        |  5 ++--
>  3 files changed, 58 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
> index c9149cc..c186457 100644
> --- a/include/net/netfilter/nf_tables.h
> +++ b/include/net/netfilter/nf_tables.h
> @@ -630,6 +630,8 @@ struct nft_expr_ops {
>  	int				(*validate)(const struct nft_ctx *ctx,
>  						    const struct nft_expr *expr,
>  						    const struct nft_data **data);
> +	int				(*clone)(struct nft_expr *dst,
> +						 const struct nft_expr *src);

The functions and data needed during runtime are deliberately kept together
at the beginning of the structure to avoid having to read the entire thing.
So I'd say this shoud go after ->eval().

> @@ -660,10 +662,20 @@ void nft_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr);
>  int nft_expr_dump(struct sk_buff *skb, unsigned int attr,
>  		  const struct nft_expr *expr);
>  
> -static inline void nft_expr_clone(struct nft_expr *dst, struct nft_expr *src)
> +static inline int nft_expr_clone(struct nft_expr *dst, struct nft_expr *src)
>  {
> +	int err;
> +
>  	__module_get(src->ops->type->owner);
> -	memcpy(dst, src, src->ops->size);
> +	if (src->ops->clone) {
> +		memcpy(dst, src, sizeof(*src));

Why copy if we clone? The function should do a full initialization if it is
present I would say.

> +		err = src->ops->clone(dst, src);
> +		if (err < 0)
> +			return err;
> +	} else {
> +		memcpy(dst, src, src->ops->size);
> +	}
> +	return 0;
>  }
>  
