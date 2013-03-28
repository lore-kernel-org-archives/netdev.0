From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Thu, 28 Mar 2013 19:57:21 +0100
Message-ID: <20130328185721.GA20223@order.stressinduktion.org>
References: <20130327155238.15203.6688.stgit@dragon> <20130327155601.15203.25289.stgit@dragon> <1364405159.15753.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37111 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab3C1S5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:57:23 -0400
Content-Disposition: inline
In-Reply-To: <1364405159.15753.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 27, 2013 at 10:25:59AM -0700, Eric Dumazet wrote:
> On Wed, 2013-03-27 at 16:56 +0100, Jesper Dangaard Brouer wrote:
> > This patch implements per hash bucket locking for the frag queue
> > hash.  This removes two write locks, and the only remaining write
> > lock is for protecting hash rebuild.  This essentially reduce the
> > readers-writer lock to a rebuild lock.
> > 
> 
> > @@ -226,27 +247,32 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
> >  		struct inet_frag_queue *qp_in, struct inet_frags *f,
> >  		void *arg)
> >  {
> > +	struct inet_frag_bucket *hb;
> >  	struct inet_frag_queue *qp;
> >  #ifdef CONFIG_SMP
> >  #endif
> >  	unsigned int hash;
> >  
> > -	write_lock(&f->lock);
> > +	read_lock(&f->lock); /* Protects against hash rebuild */
> >  	/*
> >  	 * While we stayed w/o the lock other CPU could update
> >  	 * the rnd seed, so we need to re-calculate the hash
> >  	 * chain. Fortunatelly the qp_in can be used to get one.
> >  	 */
> >  	hash = f->hashfn(qp_in);
> > +	hb = &f->hash[hash];
> > +	spin_lock_bh(&hb->chain_lock);
> > +
> >  #ifdef CONFIG_SMP
> >  	/* With SMP race we have to recheck hash table, because
> >  	 * such entry could be created on other cpu, while we
> > -	 * promoted read lock to write lock.
> > +	 * released the hash bucket lock.
> >  	 */
> > -	hlist_for_each_entry(qp, &f->hash[hash], list) {
> > +	hlist_for_each_entry(qp, &hb->chain, list) {
> >  		if (qp->net == nf && f->match(qp, arg)) {
> >  			atomic_inc(&qp->refcnt);
> > -			write_unlock(&f->lock);
> > +			spin_unlock_bh(&hb->chain_lock);
> > +			read_unlock(&f->lock);
> >  			qp_in->last_in |= INET_FRAG_COMPLETE;
> >  			inet_frag_put(qp_in, f);
> >  			return qp;
> > @@ -258,8 +284,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
> >  		atomic_inc(&qp->refcnt);
> >  
> >  	atomic_inc(&qp->refcnt);
> > -	hlist_add_head(&qp->list, &f->hash[hash]);
> > -	write_unlock(&f->lock);
> > +	hlist_add_head(&qp->list, &hb->chain);
> > +	hb->chain_len++;
> > +	spin_unlock_bh(&hb->chain_lock);
> > +	read_unlock(&f->lock);
> >  	inet_frag_lru_add(nf, qp);
> >  	return qp;
> >  }
> 
> 
> I am not sure why you added _bh suffix to spin_lock()/spin_unlock()
> here ?

I assume that it has to do with the usage of this code in
ipv6/netfilter/nf_conntrack_reasm.c, which could be invoked from process
context, if I read it correctly.
