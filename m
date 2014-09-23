From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] netfilter: nft_rbtree: no need for spinlock from
 set destroy path
Date: Tue, 23 Sep 2014 02:52:37 -0700
Message-ID: <1411465957.26859.179.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
	 <1411464288-18069-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36032 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222AbaIWJwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 05:52:39 -0400
In-Reply-To: <1411464288-18069-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-23 at 11:24 +0200, Pablo Neira Ayuso wrote:
> The sets are released from the rcu callback, after the rule is removed
> from the chain list, which implies that nfnetlink cannot update the
> rbtree and no packets are walking on the set anymore. Thus, we can get
> rid of the spinlock in the set destroy path there.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Reviewied-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/netfilter/nft_rbtree.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
> index e1836ff..46214f2 100644
> --- a/net/netfilter/nft_rbtree.c
> +++ b/net/netfilter/nft_rbtree.c
> @@ -234,13 +234,11 @@ static void nft_rbtree_destroy(const struct nft_set *set)
>  	struct nft_rbtree_elem *rbe;
>  	struct rb_node *node;
>  
> -	spin_lock_bh(&nft_rbtree_lock);
>  	while ((node = priv->root.rb_node) != NULL) {
>  		rb_erase(node, &priv->root);
>  		rbe = rb_entry(node, struct nft_rbtree_elem, node);
>  		nft_rbtree_elem_destroy(set, rbe);
>  	}
> -	spin_unlock_bh(&nft_rbtree_lock);
>  }
>  
>  static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,

BTW, do you know if destroying an rbtree is faster this way, or using
rb_first() ?

Most cases I see in the kernel use a rb_first instead of taking the
root.

Examples : (its not an exhaustive list)

net/netfilter/xt_connlimit.c:402
net/sched/sch_netem.c:380
net/sched/sch_fq.c:519
drivers/infiniband/hw/mlx4/cm.c:439
drivers/iommu/iova.c:324
drivers/md/dm-thin.c:1491
drivers/mtd/mtdswap.c:625
drivers/mtd/ubi/attach.c:636

This might be better for large trees, to get better cache locality,
but I have no experimental data.
