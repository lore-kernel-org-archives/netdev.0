From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Thu, 10 Jan 2008 15:51:11 -0800
Message-ID: <20080110235111.GF9586@linux.vnet.ibm.com>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:58230 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318AbYAJXvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 18:51:14 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0ANpDfC025150
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 18:51:13 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0ANpDTM094620
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 16:51:13 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0ANpCqq022699
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 16:51:13 -0700
Content-Disposition: inline
In-Reply-To: <20080110231042.GA3199@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 12:10:42AM +0100, Jarek Poplawski wrote:
> Eric Dumazet wrote, On 01/09/2008 11:37 AM:
> ...
> > [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
> ...
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index d337706..28484f3 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
> >  			break;
> >  		rcu_read_unlock_bh();
> >  	}
> > -	return r;
> > +	return rcu_dereference(r);
> >  }
> >  
> >  static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
> >  {
> > -	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
> > +	struct rt_cache_iter_state *st = seq->private;
> >  
> >  	r = r->u.dst.rt_next;
> >  	while (!r) {
> > @@ -298,7 +298,7 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
> >  		rcu_read_lock_bh();
> >  		r = rt_hash_table[st->bucket].chain;
> >  	}
> > -	return r;
> > +	return rcu_dereference(r);
> >  }
> 
> It seems this optimization could've a side effect: if during such a
> loop updates are done, and r is seen !NULL during while() check, but
> NULL after rcu_dereference(), the listing/counting could stop too
> soon. So, IMHO, probably the first version of this patch is more
> reliable. (Or alternatively additional check is needed before return.)

Looks to me like "r" is a local variable (argument list), so there
should not be any possibility of it being changed by some other
task, right?

							Thanx, Paul
