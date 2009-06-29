From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Mon, 29 Jun 2009 10:08:11 +0200
Message-ID: <4A48766B.8020206@itcare.pl>
References: <19012.37515.146191.198843@robur.slu.se> <20090627192057.GA5041@ami.dom.local> <19015.20051.432572.460207@robur.slu.se> <20090628143511.GA20541@ami.dom.local> <4A478D02.10805@itcare.pl> <4A4790C3.508@itcare.pl> <20090628213602.GA4584@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:35953 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016AbZF2IIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 04:08:11 -0400
In-Reply-To: <20090628213602.GA4584@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> To David Miller:
> since among patches tested negatively by Pawel are current 2 fixes
> from 2.6.31-rc, I hope they weren't sent to -stable yet. Otherwise,
> please withdraw them until they are tested alone. Thanks.
>
> To Pawel:
> On Sun, Jun 28, 2009 at 05:48:19PM +0200, Pawe=B3 Staszewski wrote:
>  =20
>> After apply this patch something is wrong
>>
>> Traffic is not forwarded
>> no info in dmesg / no info from bgp
>> and also i can't connect to bgpd process
>>
>> I revert kernel to past version with first Jarek patch
>>
>>    =20
>
> Since checking this can take time I attach here a patch with only
> changes which are currently in 2.6.31-rc. Of course, this part can be
> broken as well, so it's up to you: if you could try it with caution
> somewhere it would be very helpful; otherwise don't bother.
>
> It could be applied to 2.6.29 with or without this currently working
> patch.
>
>  =20

Ok.
I applied this patch 15mins ago to 2.6.29.5 and now it's working -=20
traffic is forwarded.

Some fib_triestats
cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.29
        Max depth:      6
        Leaves:         277015
        Prefixes:       290493
        Internal nodes: 67115
          1: 35733  2: 13635  3: 9544  4: 4832  5: 2239  6: 1125  7: 5 =
=20
9: 1  18: 1
        Pointers: 686614
Null ptrs: 342485
Total size: 18396  kB

Counters:
---------
gets =3D 3956301
backtracks =3D 192497
semantic match passed =3D 3895955
semantic match miss =3D 133
null node hit=3D 4306948
skipped node resize =3D 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets =3D 3960981
backtracks =3D 2152441
semantic match passed =3D 4757
semantic match miss =3D 0
null node hit=3D 194997
skipped node resize =3D 0



> Thanks,
> Jarek P.
> --- (for 2.6.29.x, .28 or .27)
>
> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> --- a/net/ipv4/fib_trie.c	2009-06-27 20:25:06.000000000 +0200
> +++ b/net/ipv4/fib_trie.c	2009-06-28 23:06:02.000000000 +0200
> @@ -123,6 +123,7 @@ struct tnode {
>  	union {
>  		struct rcu_head rcu;
>  		struct work_struct work;
> +		struct tnode *tnode_free;
>  	};
>  	struct node *child[0];
>  };
> @@ -161,6 +162,8 @@ static void tnode_put_child_reorg(struct
>  static struct node *resize(struct trie *t, struct tnode *tn);
>  static struct tnode *inflate(struct trie *t, struct tnode *tn);
>  static struct tnode *halve(struct trie *t, struct tnode *tn);
> +/* tnodes to free after resize(); protected by RTNL */
> +static struct tnode *tnode_free_head;
> =20
>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
> @@ -385,6 +388,24 @@ static inline void tnode_free(struct tno
>  		call_rcu(&tn->rcu, __tnode_free_rcu);
>  }
> =20
> +static void tnode_free_safe(struct tnode *tn)
> +{
> +	BUG_ON(IS_LEAF(tn));
> +	tn->tnode_free =3D tnode_free_head;
> +	tnode_free_head =3D tn;
> +}
> +
> +static void tnode_free_flush(void)
> +{
> +	struct tnode *tn;
> +
> +	while ((tn =3D tnode_free_head)) {
> +		tnode_free_head =3D tn->tnode_free;
> +		tn->tnode_free =3D NULL;
> +		tnode_free(tn);
> +	}
> +}
> +
>  static struct leaf *leaf_new(void)
>  {
>  	struct leaf *l =3D kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
> @@ -495,7 +516,7 @@ static struct node *resize(struct trie *
> =20
>  	/* No children */
>  	if (tn->empty_children =3D=3D tnode_child_length(tn)) {
> -		tnode_free(tn);
> +		tnode_free_safe(tn);
>  		return NULL;
>  	}
>  	/* One child */
> @@ -509,7 +530,7 @@ static struct node *resize(struct trie *
> =20
>  			/* compress one level */
>  			node_set_parent(n, NULL);
> -			tnode_free(tn);
> +			tnode_free_safe(tn);
>  			return n;
>  		}
>  	/*
> @@ -670,7 +691,7 @@ static struct node *resize(struct trie *
>  			/* compress one level */
> =20
>  			node_set_parent(n, NULL);
> -			tnode_free(tn);
> +			tnode_free_safe(tn);
>  			return n;
>  		}
> =20
> @@ -756,7 +777,7 @@ static struct tnode *inflate(struct trie
>  			put_child(t, tn, 2*i, inode->child[0]);
>  			put_child(t, tn, 2*i+1, inode->child[1]);
> =20
> -			tnode_free(inode);
> +			tnode_free_safe(inode);
>  			continue;
>  		}
> =20
> @@ -801,9 +822,9 @@ static struct tnode *inflate(struct trie
>  		put_child(t, tn, 2*i, resize(t, left));
>  		put_child(t, tn, 2*i+1, resize(t, right));
> =20
> -		tnode_free(inode);
> +		tnode_free_safe(inode);
>  	}
> -	tnode_free(oldtnode);
> +	tnode_free_safe(oldtnode);
>  	return tn;
>  nomem:
>  	{
> @@ -885,7 +906,7 @@ static struct tnode *halve(struct trie *
>  		put_child(t, newBinNode, 1, right);
>  		put_child(t, tn, i/2, resize(t, newBinNode));
>  	}
> -	tnode_free(oldtnode);
> +	tnode_free_safe(oldtnode);
>  	return tn;
>  nomem:
>  	{
> @@ -983,12 +1004,14 @@ fib_find_node(struct trie *t, u32 key)
>  	return NULL;
>  }
> =20
> -static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
> +static void trie_rebalance(struct trie *t, struct tnode *tn)
>  {
>  	int wasfull;
> -	t_key cindex, key =3D tn->key;
> +	t_key cindex, key;
>  	struct tnode *tp;
> =20
> +	key =3D tn->key;
> +
>  	while (tn !=3D NULL && (tp =3D node_parent((struct node *)tn)) !=3D=
 NULL) {
>  		cindex =3D tkey_extract_bits(key, tp->pos, tp->bits);
>  		wasfull =3D tnode_full(tp, tnode_get_child(tp, cindex));
> @@ -998,6 +1021,7 @@ static struct node *trie_rebalance(struc
>  				      (struct node *)tn, wasfull);
> =20
>  		tp =3D node_parent((struct node *) tn);
> +		tnode_free_flush();
>  		if (!tp)
>  			break;
>  		tn =3D tp;
> @@ -1007,7 +1031,10 @@ static struct node *trie_rebalance(struc
>  	if (IS_TNODE(tn))
>  		tn =3D (struct tnode *)resize(t, (struct tnode *)tn);
> =20
> -	return (struct node *)tn;
> +	rcu_assign_pointer(t->trie, (struct node *)tn);
> +	tnode_free_flush();
> +
> +	return;
>  }
> =20
>  /* only used from updater-side */
> @@ -1155,7 +1182,7 @@ static struct list_head *fib_insert_node
> =20
>  	/* Rebalance the trie */
> =20
> -	rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
> +	trie_rebalance(t, tp);
>  done:
>  	return fa_head;
>  }
> @@ -1575,7 +1602,7 @@ static void trie_leaf_remove(struct trie
>  	if (tp) {
>  		t_key cindex =3D tkey_extract_bits(l->key, tp->pos, tp->bits);
>  		put_child(t, (struct tnode *)tp, cindex, NULL);
> -		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
> +		trie_rebalance(t, tp);
>  	} else
>  		rcu_assign_pointer(t->trie, NULL);
> =20
>
>
>
>  =20

