From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Set the correct RTNL family for multicast netconf
 messages
Date: Thu, 27 Jun 2013 18:33:42 -0700
Message-ID: <20130627183342.4b9c5598@nehalam.linuxnetplumber.net>
References: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com>
	<20130628012307.GB15799@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sven-Thorsten Dietrich <sven@vyatta.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Davison <Mike.Davison@vyatta.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628012307.GB15799@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Jun 2013 03:23:07 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Thu, Jun 27, 2013 at 04:44:47PM -0700, Sven-Thorsten Dietrich wrote:
> > diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> > index dfc39d4..695858b 100644
> > --- a/net/ipv4/devinet.c
> > +++ b/net/ipv4/devinet.c
> > @@ -1705,7 +1705,16 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
> >  		return -EMSGSIZE;
> >  
> >  	ncm = nlmsg_data(nlh);
> > -	ncm->ncm_family = AF_INET;
> > +
> > +	switch (type) {
> > +		case NETCONFA_MC_FORWARDING:
> > +			ncm->ncm_family = RTNL_FAMILY_IPMR;
> > +			break;
> > +
> > +		default:
> > +			ncm->ncm_family = AF_INET;
> > +			break;
> > +	}
> >  
> >  	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
> >  		goto nla_put_failure;
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 4ab4c38..a177da4 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -492,7 +492,16 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
> >  		return -EMSGSIZE;
> >  
> >  	ncm = nlmsg_data(nlh);
> > -	ncm->ncm_family = AF_INET6;
> > +
> > +	switch (type) {
> > +		case NETCONFA_MC_FORWARDING:
> > +			ncm->ncm_family = RTNL_FAMILY_IP6MR;
> > +			break;
> > +
> > +		default:
> > +			ncm->ncm_family = AF_INET6;
> > +			break;
> > +	}
> >  
> 
> Hm, are you sure? NETCONFA_MC_FORWARDING is of type RTM_NEWNETCONF
> and expects ncm_family to be either AF_INET or AF_INET6 (at least in
> iproute2/ipmonitor.c).
> 

I agree with Sven on this, looks like the recent addition of netconf
configuration to netlink didn't embrace how multicast is handled in kernel.

Multicast forwarding is a routing related configuration value.
All the multicast routing events come in as special family RTNL_FAMILY_IPMR
(see net/ipv4/ipmr.c function ipmr_fill_route). I would expect that multicast
routing daemons would like to be able to use special family to listen for
all multicast related changes (and not see non-multicast events).


Minor nit: the patch is formatted incorrectly (case should line up with switch).
