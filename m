From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: fix a race in nf_ct_ext_create()
Date: Tue, 31 Aug 2010 08:51:37 -0700
Message-ID: <20100831155137.GE2421@linux.vnet.ibm.com>
References: <1283269682.2550.111.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:49653 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359Ab0HaPvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 11:51:45 -0400
Content-Disposition: inline
In-Reply-To: <1283269682.2550.111.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 31, 2010 at 05:48:02PM +0200, Eric Dumazet wrote:
> As soon as rcu_read_unlock() is called, there is no guarantee current
> thread can safely derefence t pointer, rcu protected.
> 
> Fix is to copy t->alloc_size in a temporary variable.

Yow!!!  Good catch!!!

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/netfilter/nf_conntrack_extend.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
> index 7dcf7a4..8d9e4c9 100644
> --- a/net/netfilter/nf_conntrack_extend.c
> +++ b/net/netfilter/nf_conntrack_extend.c
> @@ -48,15 +48,17 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
>  {
>  	unsigned int off, len;
>  	struct nf_ct_ext_type *t;
> +	size_t alloc_size;
> 
>  	rcu_read_lock();
>  	t = rcu_dereference(nf_ct_ext_types[id]);
>  	BUG_ON(t == NULL);
>  	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
>  	len = off + t->len;
> +	alloc_size = t->alloc_size;
>  	rcu_read_unlock();
> 
> -	*ext = kzalloc(t->alloc_size, gfp);
> +	*ext = kzalloc(alloc_size, gfp);
>  	if (!*ext)
>  		return NULL;
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
