From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Thu, 02 Jul 2009 00:17:19 +0200
Message-ID: <4A4BE06F.3090608@itcare.pl>
References: <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030101060308060309090900"
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:37302 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401AbZGAWRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 18:17:20 -0400
In-Reply-To: <20090701110407.GC12715@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030101060308060309090900
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Jarek Poplawski pisze:
> On Wed, Jul 01, 2009 at 10:13:33AM +0000, Jarek Poplawski wrote:
>   
>> On Wed, Jul 01, 2009 at 11:43:04AM +0200, Pawe³ Staszewski wrote:
>> ...
>>     
>>> Yes on on previous patches there was / no warnings / no oopses or lockups
>>>
>>> But now i apply this patch and i make more testing.
>>> First boot with start of bgpd and - traffic is not forwarded
>>> So i start to search and make only some routes (static without bgpd)  
>>> thru this host
>>> And all is working for this host when i make all by static routes.
>>>
>>> So i change a little my bgp configuration and make default route to only  
>>> one of my iBGP peers and start bgpd process
>>> All is working and what is weird is number of routes in kernel table.
>>> Kernel is learning routes from bgpd but very slowly - really very slowly.
>>>       
>> Pawel, this is really very helpful! So, this is (probably) only about
>> timing, not wrong memory freeing. On the other hand this test was only
>> for inserts. Btw., if you didn't start the second test, you can skip
>> it. I have to rethink this.
>>     
>
> So, after your findings I'm about to recommend sending to -stable
> 3 patches from net-2.6, with additional lowering of threshold_root
> settings, but it would be nice if you could give it a try with
> CONFIG_PREEMPT instead of CONFIG_PREEMPT_NONE (if it doesn't break
> your other apps!) It is expected to work this time...;-) Maybe a
> bit slower.
>
>   
Patch applied to 2.6.29.5 with CONFIG_PREEMPT_NONE
And working :)

fib_triestats in attached file

I think I can test it with PREEMPT enabled but first i must make some 
other tests of my apps that are on server.

Regards
Pawe³ Staszewski

> Thanks,
> Jarek P.
> --------> (all-in-one preempt fixes to apply with vanilla 2.6.29.x)
>
> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> --- a/net/ipv4/fib_trie.c	2009-07-01 06:17:08.000000000 +0000
> +++ b/net/ipv4/fib_trie.c	2009-07-01 10:43:44.000000000 +0000
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
>  
>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
> @@ -313,8 +316,8 @@ static inline void check_tnode(const str
>  
>  static const int halve_threshold = 25;
>  static const int inflate_threshold = 50;
> -static const int halve_threshold_root = 8;
> -static const int inflate_threshold_root = 15;
> +static const int halve_threshold_root = 15;
> +static const int inflate_threshold_root = 25;
>  
>  
>  static void __alias_free_mem(struct rcu_head *head)
> @@ -385,6 +388,24 @@ static inline void tnode_free(struct tno
>  		call_rcu(&tn->rcu, __tnode_free_rcu);
>  }
>  
> +static void tnode_free_safe(struct tnode *tn)
> +{
> +	BUG_ON(IS_LEAF(tn));
> +	tn->tnode_free = tnode_free_head;
> +	tnode_free_head = tn;
> +}
> +
> +static void tnode_free_flush(void)
> +{
> +	struct tnode *tn;
> +
> +	while ((tn = tnode_free_head)) {
> +		tnode_free_head = tn->tnode_free;
> +		tn->tnode_free = NULL;
> +		tnode_free(tn);
> +	}
> +}
> +
>  static struct leaf *leaf_new(void)
>  {
>  	struct leaf *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
> @@ -495,7 +516,7 @@ static struct node *resize(struct trie *
>  
>  	/* No children */
>  	if (tn->empty_children == tnode_child_length(tn)) {
> -		tnode_free(tn);
> +		tnode_free_safe(tn);
>  		return NULL;
>  	}
>  	/* One child */
> @@ -509,7 +530,7 @@ static struct node *resize(struct trie *
>  
>  			/* compress one level */
>  			node_set_parent(n, NULL);
> -			tnode_free(tn);
> +			tnode_free_safe(tn);
>  			return n;
>  		}
>  	/*
> @@ -670,7 +691,7 @@ static struct node *resize(struct trie *
>  			/* compress one level */
>  
>  			node_set_parent(n, NULL);
> -			tnode_free(tn);
> +			tnode_free_safe(tn);
>  			return n;
>  		}
>  
> @@ -756,7 +777,7 @@ static struct tnode *inflate(struct trie
>  			put_child(t, tn, 2*i, inode->child[0]);
>  			put_child(t, tn, 2*i+1, inode->child[1]);
>  
> -			tnode_free(inode);
> +			tnode_free_safe(inode);
>  			continue;
>  		}
>  
> @@ -801,9 +822,9 @@ static struct tnode *inflate(struct trie
>  		put_child(t, tn, 2*i, resize(t, left));
>  		put_child(t, tn, 2*i+1, resize(t, right));
>  
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
>  
> -static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
> +static void trie_rebalance(struct trie *t, struct tnode *tn)
>  {
>  	int wasfull;
> -	t_key cindex, key = tn->key;
> +	t_key cindex, key;
>  	struct tnode *tp;
>  
> +	key = tn->key;
> +
>  	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {
>  		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
>  		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
> @@ -999,6 +1022,10 @@ static struct node *trie_rebalance(struc
>  
>  		tp = node_parent((struct node *) tn);
>  		if (!tp)
> +			rcu_assign_pointer(t->trie, (struct node *)tn);
> +
> +		tnode_free_flush();
> +		if (!tp)
>  			break;
>  		tn = tp;
>  	}
> @@ -1007,7 +1034,10 @@ static struct node *trie_rebalance(struc
>  	if (IS_TNODE(tn))
>  		tn = (struct tnode *)resize(t, (struct tnode *)tn);
>  
> -	return (struct node *)tn;
> +	rcu_assign_pointer(t->trie, (struct node *)tn);
> +	tnode_free_flush();
> +
> +	return;
>  }
>  
>  /* only used from updater-side */
> @@ -1155,7 +1185,7 @@ static struct list_head *fib_insert_node
>  
>  	/* Rebalance the trie */
>  
> -	rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
> +	trie_rebalance(t, tp);
>  done:
>  	return fa_head;
>  }
> @@ -1575,7 +1605,7 @@ static void trie_leaf_remove(struct trie
>  	if (tp) {
>  		t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
>  		put_child(t, (struct tnode *)tp, cindex, NULL);
> -		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
> +		trie_rebalance(t, tp);
>  	} else
>  		rcu_assign_pointer(t->trie, NULL);
>  
>
>
>   


--------------030101060308060309090900
Content-Type: text/plain;
 name="fib_triestats.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_triestats.txt"

cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.44
        Max depth:      6
        Leaves:         277395
        Prefixes:       290874
        Internal nodes: 66711
          1: 32915  2: 14668  3: 10752  4: 4913  5: 2197  6: 895  7: 367  8: 3  17: 1
        Pointers: 595526
Null ptrs: 251421
Total size: 18044  kB

Counters:
---------
gets = 2705388
backtracks = 137797
semantic match passed = 2658993
semantic match miss = 87
null node hit= 1980950
skipped node resize = 0

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
gets = 2709741
backtracks = 1584810
semantic match passed = 4417
semantic match miss = 0
null node hit= 192688
skipped node resize = 0

--------------030101060308060309090900--
