From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net 2/2] xdp: disallow use of native and generic hook at
 once
Date: Wed, 10 May 2017 14:07:54 -0700
Message-ID: <20170510140754.739e4123@cakuba.netronome.com>
References: <cover.1494379046.git.daniel@iogearbox.net>
        <f8405a8769dca09a0f21d11eab3793e30f608531.1494379046.git.daniel@iogearbox.net>
        <20170509201842.2ed5e330@cakuba.netronome.com>
        <5912DF16.7050603@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:45132 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750930AbdEJVIM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 10 May 2017 17:08:12 -0400
In-Reply-To: <5912DF16.7050603@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 May 2017 11:36:22 +0200, Daniel Borkmann wrote:
> On 05/10/2017 05:18 AM, Jakub Kicinski wrote:
> > On Wed, 10 May 2017 03:31:31 +0200, Daniel Borkmann wrote:  
> >> @@ -6851,6 +6851,32 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
> >>   }
> >>   EXPORT_SYMBOL(dev_change_proto_down);
> >>
> >> +bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)  
> >
> > Out of curiosity - the leading underscores refer to caller having to
> > hold rtnl?  I assume they are not needed in the function below because
> > it's static?  
> 
> I think I don't quite follow the last question, but it probably makes
> sense to add an ASSERT_RTNL() into dev_xdp_attached() inline helper to
> make it clearly visible to callers of this api.

Sorry, I missed you have a dev_xdp_attached() defined in the header,
hence the confusion.

> >> +{
> >> +	struct netdev_xdp xdp;
> >> +
> >> +	memset(&xdp, 0, sizeof(xdp));
> >> +	xdp.command = XDP_QUERY_PROG;  
> >
> > Probably personal preference, but seems like designated struct
> > initializer would do quite nicely here and save the memset :)  
> 
> I had that initially, but I recalled that gcc < 4.6 does not handle this
> style for the initialization of anonymous struct/union properly (e.g.,
> we fixed that in iproute2 as well). Andrew Morton still uses gcc 4.4.4
> and occasionally sends kernel fixes, so we might end up like this anyway.

Ah, good to know!

> >> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> >> index dda9f16..99320f0 100644
> >> --- a/net/core/rtnetlink.c
> >> +++ b/net/core/rtnetlink.c
> >> @@ -1251,24 +1251,20 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
> >>   {
> >>   	struct nlattr *xdp;
> >>   	u32 xdp_flags = 0;
> >> -	u8 val = 0;
> >>   	int err;
> >> +	u8 val;
> >>
> >>   	xdp = nla_nest_start(skb, IFLA_XDP);
> >>   	if (!xdp)
> >>   		return -EMSGSIZE;
> >> +
> >>   	if (rcu_access_pointer(dev->xdp_prog)) {
> >>   		xdp_flags = XDP_FLAGS_SKB_MODE;
> >>   		val = 1;
> >> -	} else if (dev->netdev_ops->ndo_xdp) {
> >> -		struct netdev_xdp xdp_op = {};
> >> -
> >> -		xdp_op.command = XDP_QUERY_PROG;
> >> -		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
> >> -		if (err)
> >> -			goto err_cancel;
> >> -		val = xdp_op.prog_attached;
> >> +	} else {
> >> +		val = dev_xdp_attached(dev);
> >> 	}  
> >
> > Would it make sense to set xdp_flags to XDP_FLAGS_DRV_MODE here to keep
> > things symmetrical?  I know you are just preserving existing behaviour
> > but it may seem slightly arbitrary to a new comer to report one of the
> > very similarly named flags in the dump but not the other.  
> 
> I thought about it, it's kind of redundant information since
> IFLA_XDP_ATTACHED attribute w/o IFLA_XDP_FLAGS attribute today
> says that it's native already. It might look strange if we add
> also XDP_FLAGS_DRV_MODE there, since it doesn't give anything
> new. I rather see it similar to XDP_FLAGS_UPDATE_IF_NOEXIST flag
> that is for updating fd only, but I don't really have a strong
> opinion on this though. I could add it to the respin if preferred.

XDP_FLAGS_UPDATE_IF_NOEXIST is indeed the precedent which makes things
a bit murky.  There are no reasonably useful semantics for IF_NOEXIST
on dump :(  Note that meaning of SKB_MODE flag shifts slightly between
set and dump IIUC.  At set time it means:
 "force installation at the generic hook",
at dump time it means:
 "installed at generic hook - regardless of whether the flag was set at
  installation time",

So I would argue that DRV_MODE flag is closer to SKB_MODE not only by
name but also by semantics, and it would be cool if we could keep the
semantics close on dump as well as set.

I understand the counter argument that from user space perspective it
would make things slightly more complicated because there would be two
conditions in which driver hook is used:
 1) DRV_MODE set on dump;
 2) flags attribute not present (old kernel).

I'm concerned about number 2).  We can't simply depend on SKB_MODE
not being set because we may add more *_MODE flags in the future.  So
doing:

if (flags & SKB_MODE)
	printf("skb-mode");
else
	printf("drv-mode");

is not correct.  The flags attribute must not be present at all (think
HW_MODE flag).  But going further there can also be non-MODE flags,
like, say.. NEVER_TX, and then there may be flags present in dump,
and if SKB_MODE isn't be set, the mode could be some new MODE user space
doesn't understand, or it could be DRV_MODE+a new non-MODE flag... no
way to tell :S
