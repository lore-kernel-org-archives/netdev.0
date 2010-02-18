From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 4/5] xfrm: CONFIG_COMPAT support for x86 architecture
Date: Thu, 18 Feb 2010 10:33:31 +0100
Message-ID: <20100218093331.GC20183@Chamillionaire.breakpoint.cc>
References: <1266252393-20911-1-git-send-email-fw@strlen.de>
 <1266252393-20911-5-git-send-email-fw@strlen.de>
 <1266479858.5564.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:33046 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751450Ab0BRJdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 04:33:32 -0500
Content-Disposition: inline
In-Reply-To: <1266479858.5564.8.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> wrote:
> > +static bool xfrm_msg_compat(const struct sk_buff *skb)
> > +{
> > +	return unlikely(!!NETLINK_CB(skb).msg_compat);
> > +}
> 
> The !! seems pointless but that's not why I'm quoting this here.
> 
> I think this function should only be used in the input path.

Fair enough.  I'll see about introducing "bool compat" arguments
to the functions that currently use this helper in the output path.

> > +static bool xfrm_add_compatskb(struct sk_buff *skb,
> > +                               unsigned int len, gfp_t gfp)
> > +{
> 
> I think this should return the new skb, and I don't think it should set
> the msg_compat flag in the NETLINK_CB.

Right, that would no longer be necessary if xfrm_msg_compat() is
restricted to the input path.

> > +static struct sk_buff *xfrm_get_compatskb(struct sk_buff *skb)
> > +{
> 
> making this no longer needed.
> 

[..]
> Shouldn't that be some sizeof() trickery instead of hardcoding 4?

I'll do that. For x86/x86_64 the delta is always 4 (or 0), though.

> > @@ -700,6 +856,9 @@ static int copy_one_state(struct sk_buff *skb,
> > struct xfrm_state *x, struct xfrm
> >  	size_t len = sizeof(*p);
> >  	int err;
> >  
> > +	if (xfrm_msg_compat(skb))
> > +		len = sizeof(struct compat_xfrm_usersa_info);
> > +
> 
> I really dislike this use though.

Alright, I will add a "bool is_compat" argument instead.

> > @@ -724,6 +883,13 @@ static int dump_one_state(struct xfrm_state *x,
> > int count, void *ptr)
> >  	struct xfrm_dump_info *sp = ptr;
> >  	struct sk_buff *skb = sp->out_skb;
> >  	int ret = copy_one_state(skb, x, sp);
> > +#ifdef CONFIG_COMPAT_FOR_U64_ALIGNMENT
> > +	if (ret == 0) {
> > +		skb = xfrm_get_compatskb(skb);
> > +		if (skb)
> > +			copy_one_state(skb, x, sp);
> > +	}
> > +#endif
> >  	return ret;
> >  }
> 
> And that's really convoluted.

dump_one_state() is called from xfrm_state_walk(), so it has to prepare
both native and compat skb.

The "ifdef" is not necessary; I added it because gcc 4.3.4 did
no longer inline copy_one_state() without them in the
COMPAT_FOR_U64_ALIGNMENT=n case.

> > @@ -753,6 +919,8 @@ static int xfrm_dump_sa(struct sk_buff *skb,
> > struct netlink_callback *cb)
> >  		xfrm_state_walk_init(walk, 0);
> >  	}
> >  
> > +	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > +
> >  	(void) xfrm_state_walk(net, walk, dump_one_state, &info);
> >  
> >  	return skb->len;
> 
> And this just seems wrong -- doesn't that fill _only_ the compat skb
> here then??

No, dump_one_state() calls copy_one_state() twice (once for
skb, once for ->frag_list.

> > @@ -2200,6 +2455,9 @@ static int xfrm_exp_state_notify(struct
> > xfrm_state *x, struct km_event *c)
> >  	if (build_expire(skb, x, c) < 0)
> >  		BUG();
> >  
> > +	if (xfrm_add_compatskb(skb, compat_xfrm_expire_msgsize(), GFP_ATOMIC))
> > +		compat_build_expire(skb_shinfo(skb)->frag_list, x, c);
> 
> This is a good model, although I'd change it to be like this:
> 
> if (cskb = xfrm_add_compatskb(skb, ...))
> compat_build_expire(cskb, x, c);

good point, I'll change this accordingly.

> And I think the code would be a lot clearer if the other user were like
> 
> build_foo(skb, ..., false /* not compat */);
> if ((cskb = xfrm_add_compatskb(skb, ...)))
> build_foo(cskb, ..., true /* compat */);
> 
> instead of all the trickery with setting msg_compat on the output path
> and then checking it again in the fill functions.

Thanks a lot for spending time on reviewing this; I'll make the changes
you suggested.

Florian
