From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 15:13:38 +0100
Message-ID: <20080111141338.GD2708@ff.dom.local>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080110235111.GF9586@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:11312 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831AbYAKOH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 09:07:28 -0500
Received: by fk-out-0910.google.com with SMTP id z23so822022fkz.5
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 06:07:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080110235111.GF9586@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 03:51:11PM -0800, Paul E. McKenney wrote:
> On Fri, Jan 11, 2008 at 12:10:42AM +0100, Jarek Poplawski wrote:
> > Eric Dumazet wrote, On 01/09/2008 11:37 AM:
> > ...
> > > [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
> > ...
> > > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > > index d337706..28484f3 100644
> > > --- a/net/ipv4/route.c
> > > +++ b/net/ipv4/route.c
> > > @@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
> > >  			break;
> > >  		rcu_read_unlock_bh();
> > >  	}
> > > -	return r;
> > > +	return rcu_dereference(r);
> > >  }
> > >  
> > >  static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
> > >  {
> > > -	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
> > > +	struct rt_cache_iter_state *st = seq->private;
> > >  
> > >  	r = r->u.dst.rt_next;
> > >  	while (!r) {
> > > @@ -298,7 +298,7 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
> > >  		rcu_read_lock_bh();
> > >  		r = rt_hash_table[st->bucket].chain;
> > >  	}
> > > -	return r;
> > > +	return rcu_dereference(r);
> > >  }
> > 
> > It seems this optimization could've a side effect: if during such a
> > loop updates are done, and r is seen !NULL during while() check, but
> > NULL after rcu_dereference(), the listing/counting could stop too
> > soon. So, IMHO, probably the first version of this patch is more
> > reliable. (Or alternatively additional check is needed before return.)
> 
> Looks to me like "r" is a local variable (argument list), so there
> should not be any possibility of it being changed by some other
> task, right?

It seems words could be stronger than then logic (in some cases)...
After forgetting what's dereference usually for, it's all right!

Thanks,
Jarek P.
