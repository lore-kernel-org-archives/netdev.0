From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/9] nftables: nft_rbtree: fix locking
Date: Fri, 30 Jan 2015 11:52:17 +0100
Message-ID: <20150130105217.GA4093@salvia>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-4-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, davem@davemloft.net,
	David.Laight@ACULAB.COM, ying.xue@windriver.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48189 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760931AbbA3KtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2015 05:49:17 -0500
Content-Disposition: inline
In-Reply-To: <1422603994-5836-4-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

On Fri, Jan 30, 2015 at 07:46:28AM +0000, Patrick McHardy wrote:
> Fix a race condition and unnecessary locking:
> 
> * the root rb_node must only be accessed under the lock in nft_rbtree_lookup()
> * the lock is not needed in lookup functions in netlink contexts
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---
>  net/netfilter/nft_rbtree.c | 12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
> index 46214f2..417796f 100644
> --- a/net/netfilter/nft_rbtree.c
> +++ b/net/netfilter/nft_rbtree.c
> @@ -37,10 +37,11 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
>  {
>  	const struct nft_rbtree *priv = nft_set_priv(set);
>  	const struct nft_rbtree_elem *rbe, *interval = NULL;
> -	const struct rb_node *parent = priv->root.rb_node;
> +	const struct rb_node *parent;
>  	int d;
>  
>  	spin_lock_bh(&nft_rbtree_lock);
> +	parent = priv->root.rb_node;

Good catch.

>  	while (parent != NULL) {
>  		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
>  
> @@ -158,7 +159,6 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
>  	struct nft_rbtree_elem *rbe;
>  	int d;
>  
> -	spin_lock_bh(&nft_rbtree_lock);
>  	while (parent != NULL) {
>  		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
>  
> @@ -173,11 +173,9 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
>  			    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
>  				nft_data_copy(&elem->data, rbe->data);
>  			elem->flags = rbe->flags;
> -			spin_unlock_bh(&nft_rbtree_lock);
>  			return 0;
>  		}
>  	}
> -	spin_unlock_bh(&nft_rbtree_lock);
>  	return -ENOENT;

this chunk looks fine to me, we always hold the nfnetlink mutex.

>  }
> @@ -190,7 +188,6 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
>  	struct nft_set_elem elem;
>  	struct rb_node *node;
>  
> -	spin_lock_bh(&nft_rbtree_lock);
>  	for (node = rb_first(&priv->root); node != NULL; node = rb_next(node)) {
>  		if (iter->count < iter->skip)
>  			goto cont;
> @@ -203,14 +200,11 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
>  		elem.flags = rbe->flags;
>  
>  		iter->err = iter->fn(ctx, set, iter, &elem);
> -		if (iter->err < 0) {
> -			spin_unlock_bh(&nft_rbtree_lock);
> +		if (iter->err < 0)
>  			return;
> -		}
>  cont:
>  		iter->count++;
>  	}
> -	spin_unlock_bh(&nft_rbtree_lock);
>  }
>  

I think that _walk still needs the lock there. This is called from
nf_tables_dump_set() for each recvmsg() in netlink, and IIRC unlike
rtnetlink the dump path in nfnetlink is lockless.
