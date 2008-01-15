From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/6] [IPV4] trie: put leaf nodes in a slab cache
Date: Tue, 15 Jan 2008 07:49:39 +0100
Message-ID: <478C5783.6030508@cosmosbay.com>
References: <20080112064646.282104074@linux-foundation.org>	<20080112.205520.55747078.davem@davemloft.net>	<4789A29C.6080000@linux-foundation.org>	<20080112.214417.154179770.davem@davemloft.net>	<20080114125755.6157a3bf@deepthought>	<20080114164450.55f8c9b2@deepthought> <20080114164621.2bc5011f@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:56853 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbYAOGt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:49:56 -0500
In-Reply-To: <20080114164621.2bc5011f@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This improves locality for operations that touch all the leaves.
> Later patch will grow the size of the leaf so it becomes more
> important.
>=20
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
>=20
>=20
> --- a/net/ipv4/fib_trie.c	2008-01-14 12:26:51.000000000 -0800
> +++ b/net/ipv4/fib_trie.c	2008-01-14 13:41:00.000000000 -0800
> @@ -162,6 +162,7 @@ static struct tnode *halve(struct trie *
>  static void tnode_free(struct tnode *tn);
> =20
>  static struct kmem_cache *fn_alias_kmem __read_mostly;
> +static struct kmem_cache *trie_leaf_kmem __read_mostly;
> =20
>  static inline struct tnode *node_parent(struct node *node)
>  {
> @@ -316,7 +317,8 @@ static inline void alias_free_mem_rcu(st
> =20
>  static void __leaf_free_rcu(struct rcu_head *head)
>  {
> -	kfree(container_of(head, struct leaf, rcu));
> +	struct leaf *leaf =3D container_of(head, struct leaf, rcu);
> +	kmem_cache_free(trie_leaf_kmem, leaf);
>  }
> =20
>  static void __leaf_info_free_rcu(struct rcu_head *head)
> @@ -366,7 +368,7 @@ static inline void tnode_free(struct tno
> =20
>  static struct leaf *leaf_new(void)
>  {
> -	struct leaf *l =3D kmalloc(sizeof(struct leaf),  GFP_KERNEL);
> +	struct leaf *l =3D kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
>  	if (l) {
>  		l->parent =3D T_LEAF;
>  		INIT_HLIST_HEAD(&l->list);
> @@ -1927,6 +1929,9 @@ void __init fib_hash_init(void)
>  {
>  	fn_alias_kmem =3D kmem_cache_create("ip_fib_alias", sizeof(struct f=
ib_alias),
>  					  0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> +
> +	trie_leaf_kmem =3D kmem_cache_create("ip_fib_trie", sizeof(struct l=
eaf),
> +					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>  }
> =20

Do we really need HWCACHE_ALIGN ? so many wasted space ...


