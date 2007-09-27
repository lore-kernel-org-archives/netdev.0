From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 17:33:58 +0800
Message-ID: <20070927093358.GA15357@gondor.apana.org.au>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3980 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751083AbXI0JeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 05:34:10 -0400
Content-Disposition: inline
In-Reply-To: <20070927092512.GD29329@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 01:25:12PM +0400, Evgeniy Polyakov wrote:
>
> Couple of comments below.

Thanks Evgeniey :)

> > --- a/net/sched/Kconfig
> > +++ b/net/sched/Kconfig
> > @@ -447,6 +447,17 @@ config NET_ACT_IPT
> >  	  To compile this code as a module, choose M here: the
> >  	  module will be called ipt.
> >
> > +config NET_ACT_NAT
> > +        tristate "Stateless NAT"
> > +        depends on NET_CLS_ACT
> > +        select NETFILTER
> 
> Argh... People usually do not understand such jokes :)
> What about not using netfilter helpers and just move them to the
> accessible header so that no additional slow path would ever be enabled?

Sure.  However, as it is it's just including the netfilter core
which does not mean the inclusion of connection trakcing.  It's
only connection tracking that *may* (so don't flame me for this :)
pose a scalability problem.

> > +        ---help---
> > +	  Say Y here to do stateless NAT on IPv4 packets.  You should use
> > +	  netfilter for NAT unless you know what you are doing.
> > +
> > +	  To compile this code as a module, choose M here: the
> > +	  module will be called ipt.
> > +
> 
> Modile will be called 'nat' I believe.

Good catch, now you know where I copied it from :)

> > +++ b/net/sched/act_nat.c
> ...
> > +#define NAT_TAB_MASK	15
> 
> This really wants to be configurable at least via module parameter.
> 
> > +static struct tcf_common *tcf_nat_ht[NAT_TAB_MASK + 1];
> > +static u32 nat_idx_gen;
> > +static DEFINE_RWLOCK(nat_lock);
> 
> > +static struct tcf_hashinfo nat_hash_info = {
> > +	.htab	=	tcf_nat_ht,
> > +	.hmask	=	NAT_TAB_MASK,
> > +	.lock	=	&nat_lock,
> > +};
> 
> When I read this I swear I heard 'I want to be RCU'.
> But that is another task.

Yes there are a lot of clean-up's that can be done for all
actions.  You're most welcome to send patches in this area.

> > +		tcph = (void *)(skb_network_header(skb) + ihl);
> 
> Were you too lazy to write struct tcphdr here and in other places? :)

Unfortunately it doesn't work.  For prerouting, we've not
entered the IP stack yet so the transport header isn't set.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
