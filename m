From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 19:32:31 +0100
Message-ID: <20080115193231.626896dd.dada1@cosmosbay.com>
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
	<20080115182544.98c18d08.dada1@cosmosbay.com>
	<20080115094753.32e35823@deepthought>
	<20080115191031.7ce7219b.dada1@cosmosbay.com>
	<20080115101543.44c29fa7@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:41521 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbYAOScc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 13:32:32 -0500
In-Reply-To: <20080115101543.44c29fa7@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jan 2008 10:15:43 -0800
Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:

> On Tue, 15 Jan 2008 19:10:31 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > On Tue, 15 Jan 2008 09:47:53 -0800
> > Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:
> > 
> > > This is how I did it:
> > > 
> > > --- a/net/ipv4/fib_trie.c	2008-01-15 09:14:53.000000000 -0800
> > > +++ b/net/ipv4/fib_trie.c	2008-01-15 09:21:48.000000000 -0800
> > > @@ -101,13 +101,6 @@ struct node {
> > >  	t_key key;
> > >  };
> > >  
> > > -struct leaf {
> > > -	unsigned long parent;
> > > -	t_key key;
> > > -	struct hlist_head list;
> > > -	struct rcu_head rcu;
> > > -};
> > > -
> > >  struct leaf_info {
> > >  	struct hlist_node hlist;
> > >  	struct rcu_head rcu;
> > > @@ -115,6 +108,13 @@ struct leaf_info {
> > >  	struct list_head falh;
> > >  };
> > >  
> > > +struct leaf {
> > > +	unsigned long parent;
> > > +	t_key key;
> > > +	struct hlist_head list;
> > > +	struct rcu_head rcu;
> > > +};
> > 
> > I like this :)
> > 
> > Your design is clean, but we waste some space (rcu in leaf_info "included"), we probably can do a litle bit better
> > (moving rcu at the end of leaf_info, and kmem_cache_create("ip_fib_trie", sizeof(struct leaf) + sizeof(struct_leaf_info) - sizeof(struct rcu_head))
> > 
> >  
> > > -	trie_leaf_kmem = kmem_cache_create("ip_fib_trie", sizeof(struct leaf),
> > > +	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
> > > +					   sizeof(struct leaf) + sizeof(struct leaf_info),
> > >  					   0, SLAB_PANIC, NULL);
> > >  }
> > >  
> > > 
> > 
> > Thank you
> 
> Having multiple RCU links is a waste. I started on code that just splice's the
> leaf_info's off to a free_list and then do a mass free after and RCU barrier.
> 
> For the normal case of just freeing a leaf, it could just walk the chain
> in the RCU free of the leaf.

Well, If you take this path, we can also copy the leaf itself, and
just use a variable size array of infos[], no more list, and maximal locality

kmalloc(sizeof(leaf) + nb_infos * sizeof(info))

(Still we can use a kmem cache for nb_infos=1 leaves)

