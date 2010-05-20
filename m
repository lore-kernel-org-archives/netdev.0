From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 15:01:03 +1000
Message-ID: <20100520050103.GB7291@gondor.apana.org.au>
References: <4BF4517F.1010206@athenacr.com> <20100519.195533.22536631.davem@davemloft.net> <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274331255.2658.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:56533 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752891Ab0ETFBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 01:01:18 -0400
Content-Disposition: inline
In-Reply-To: <1274331255.2658.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 06:54:15AM +0200, Eric Dumazet wrote:
>
> > @@ -1064,6 +1091,9 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
> >  		sock_lock_init(sk);
> >  		sock_net_set(sk, get_net(net));
> >  		atomic_set(&sk->sk_wmem_alloc, 1);
> > +
> > +		if (!in_interrupt())
> > +			sk->sk_classid = task_cls_classid(current);
> 
> It means we cache current classid of this process.
> 
> Can it change later ?

Please read my patchset description.  I explained everything there.

> > @@ -112,6 +108,10 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
> >  	struct cls_cgroup_head *head = tp->root;
> >  	u32 classid;
> >  
> > +	rcu_read_lock();
> > +	classid = task_cls_state(current)->classid;
> > +	rcu_read_unlock();
> > +
> 
> It would be more readable to use :

Sure, however, I'm just moving the existing code around, so I
wanted it to be exactly the same.  Clean-ups should be done as
a follow-up, feel free to do this if you like.

> > @@ -122,12 +122,12 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
> >  	 * calls by looking at the number of nested bh disable calls because
> >  	 * softirqs always disables bh.
> >  	 */
> > -	if (softirq_count() != SOFTIRQ_OFFSET)
> > -		return -1;
> > -
> > -	rcu_read_lock();
> > -	classid = task_cls_state(current)->classid;
> > -	rcu_read_unlock();
> > +	if (softirq_count() != SOFTIRQ_OFFSET) {
> 
> Why do we still need this previous test ?

You didn't read my patchset description at all, did you? :)

This patchset is trying to fix the issue at hand with the minimum
amount of changes to current behaviour.  Once we're happy with the
new semantics, we can get rid of the softirq stuff.

That will be done in a later patch to minimise the risks.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
