From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 14:07:53 +0400
Message-ID: <20070927100753.GA22323@2ka.mipt.ru>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57581 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930AbXI0KIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 06:08:55 -0400
Content-Disposition: inline
In-Reply-To: <20070927093358.GA15357@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 05:33:58PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > +config NET_ACT_NAT
> > > +        tristate "Stateless NAT"
> > > +        depends on NET_CLS_ACT
> > > +        select NETFILTER
> > 
> > Argh... People usually do not understand such jokes :)
> > What about not using netfilter helpers and just move them to the
> > accessible header so that no additional slow path would ever be enabled?
> 
> Sure.  However, as it is it's just including the netfilter core
> which does not mean the inclusion of connection trakcing.  It's
> only connection tracking that *may* (so don't flame me for this :)
> pose a scalability problem.

It forces all inpuit/pre/post/forward hooks to be enbled not as a direct
function call, but as additional lookups. And unability to remove
netfilter from config. And just because of couple of checksum helpers...

> > > +++ b/net/sched/act_nat.c
> > ...
> > > +#define NAT_TAB_MASK	15
> > 
> > This really wants to be configurable at least via module parameter.
> > 
> > > +static struct tcf_common *tcf_nat_ht[NAT_TAB_MASK + 1];
> > > +static u32 nat_idx_gen;
> > > +static DEFINE_RWLOCK(nat_lock);
> > 
> > > +static struct tcf_hashinfo nat_hash_info = {
> > > +	.htab	=	tcf_nat_ht,
> > > +	.hmask	=	NAT_TAB_MASK,
> > > +	.lock	=	&nat_lock,
> > > +};
> > 
> > When I read this I swear I heard 'I want to be RCU'.
> > But that is another task.
> 
> Yes there are a lot of clean-up's that can be done for all
> actions.  You're most welcome to send patches in this area.
> 
> > > +		tcph = (void *)(skb_network_header(skb) + ihl);
> > 
> > Were you too lazy to write struct tcphdr here and in other places? :)
> 
> Unfortunately it doesn't work.  For prerouting, we've not
> entered the IP stack yet so the transport header isn't set.

I meant instead of dereferencing to void * it should be struct tcphdr *.

-- 
	Evgeniy Polyakov
