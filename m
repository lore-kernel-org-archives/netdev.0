From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 5/9] netfilter: conntrack: small refactoring of
 conntrack seq_printf
Date: Tue, 3 May 2016 20:12:50 +0200
Message-ID: <20160503181250.GA4508@salvia>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <1461863628-23350-6-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461863628-23350-6-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 07:13:44PM +0200, Florian Westphal wrote:
> The iteration process is lockless, so we test if the conntrack object is
> eligible for printing (e.g. is AF_INET) after obtaining the reference
> count.
> 
> Once we put all conntracks into same hash table we might see more
> entries that need to be skipped.
> 
> So add a helper and first perform the test in a lockless fashion
> for fast skip.
> 
> Once we obtain the reference count, just repeat the check.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   | 24 +++++++++++++++++-----
>  1 file changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> index f0dfe92..483cf79 100644
> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> @@ -114,6 +114,19 @@ static inline void ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
>  }
>  #endif
>  
> +static bool ct_seq_should_skip(const struct nf_conn *ct,
> +			       const struct nf_conntrack_tuple_hash *hash)
> +{
> +	/* we only want to print DIR_ORIGINAL */
> +	if (NF_CT_DIRECTION(hash))
> +		return true;
> +
> +	if (nf_ct_l3num(ct) != AF_INET)
> +		return true;
> +
> +	return false;
> +}
> +
>  static int ct_seq_show(struct seq_file *s, void *v)
>  {
>  	struct nf_conntrack_tuple_hash *hash = v;
> @@ -123,14 +136,15 @@ static int ct_seq_show(struct seq_file *s, void *v)
>  	int ret = 0;
>  
>  	NF_CT_ASSERT(ct);
> -	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
> +	if (ct_seq_should_skip(ct, hash))
>  		return 0;
>  
> +	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
> +		return 0;
>  
> -	/* we only want to print DIR_ORIGINAL */
> -	if (NF_CT_DIRECTION(hash))
> -		goto release;
> -	if (nf_ct_l3num(ct) != AF_INET)
> +	/* check if we raced w. object reuse */
> +	if (!nf_ct_is_confirmed(ct) ||

This refactoring includes this new check, is this intentional?

> +	    ct_seq_should_skip(ct, hash))
>  		goto release;
>  
>  	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
> -- 
> 2.7.3
> 
