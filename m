From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 18:25:44 +0100
Message-ID: <20080115182544.98c18d08.dada1@cosmosbay.com>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
	<20080114164727.210047f6@deepthought>
	<20080114185843.0981f0ff@deepthought>
	<20080114210716.4b09c84d@deepthought>
	<478C4EB7.6060807@cosmosbay.com>
	<478C4FBE.5040308@cosmosbay.com>
	<20080115081905.3b8b6f05@deepthought>
	<18316.58111.211387.271534@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40777 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610AbYAORZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 12:25:45 -0500
In-Reply-To: <18316.58111.211387.271534@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jan 2008 17:44:47 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> 
> Stephen Hemminger writes:
> 
>  > Okay, I would rather see the leaf_info explicit inside the leaf, also
>  > your scheme probably breaks if I add two prefixes and then delete the first.
>  > Let me have a go at it.
> 
>  I took Eric's patch a bit further... 
>  
>  Support for delete and dump is needed before any testing at all
>  and maybe some macro for checking and setting FP-leaf's
> 
>  Cheers.
> 					--ro
> 
> 
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 6dab753..f5b276c 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -97,22 +97,32 @@ typedef unsigned int t_key;
>  #define IS_LEAF(n) (n->parent & T_LEAF)
>  
>  struct node {
> -	unsigned long parent;
> -	t_key key;
> +	unsigned long		parent;
> +	t_key			key;
>  };
>  
>  struct leaf {
> -	unsigned long parent;
> -	t_key key;
> -	struct hlist_head list;
> -	struct rcu_head rcu;
> +	unsigned long		parent;
> +	t_key			key;
> +	/*
> +	 * Because we often have only one info per leaf, we embedd one here
> +	 * to save some space and speedup lookups (sharing cache line)
> +	 * a sort of fastpatch leaf (FP-leaf) this indicated a negative of
> +	 * plen_iinfo.
> +	 * Note : not inside a structure so that we dont have holes on 64bit 
> +	 */
> +	int 			plen_iinfo;
> +	struct list_head	falh_iinfo;

yep, I renamed them to einfo_plen & einfo_falh

> +
> +	struct hlist_head	list;
> +	struct rcu_head		rcu;
>  };
>  
>  struct leaf_info {
> -	struct hlist_node hlist;
> -	struct rcu_head rcu;
> -	int plen;
> -	struct list_head falh;
> +	struct hlist_node	hlist;
> +	int			plen;
> +	struct list_head	falh;
> +	struct rcu_head		rcu;
>  };
>  
>  struct tnode {
> @@ -364,11 +374,13 @@ static inline void tnode_free(struct tnode *tn)
>  		call_rcu(&tn->rcu, __tnode_free_rcu);
>  }
>  
> -static struct leaf *leaf_new(void)
> +static struct leaf *leaf_new(int plen)
>  {
>  	struct leaf *l = kmalloc(sizeof(struct leaf),  GFP_KERNEL);
>  	if (l) {
>  		l->parent = T_LEAF;
> +		l->plen_iinfo = plen;
> +		INIT_LIST_HEAD(&l->falh_iinfo);
>  		INIT_HLIST_HEAD(&l->list);
>  	}
>  	return l;
> @@ -890,7 +902,16 @@ static struct leaf_info *find_leaf_info(struct leaf *l, int plen)
>  
>  static inline struct list_head * get_fa_head(struct leaf *l, int plen)
>  {
> -	struct leaf_info *li = find_leaf_info(l, plen);
> +	struct leaf_info *li;
> +
> +	if (l->plen_iinfo >= 0) {
> +		if(l->plen_iinfo == plen)
> +			return &l->falh_iinfo;
> +		else
> +			return NULL;
> +	}

So you think that a leaf cannot have 2 infos, one 'embeded' and one in the list ?


