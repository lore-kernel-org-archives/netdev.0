From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/5] xfrm: CONFIG_COMPAT support for x86 architecture
Date: Thu, 18 Feb 2010 08:57:38 +0100
Message-ID: <1266479858.5564.8.camel@jlt3.sipsolutions.net>
References: <1266252393-20911-1-git-send-email-fw@strlen.de>
	 <1266252393-20911-5-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:60622 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab0BRH5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 02:57:43 -0500
In-Reply-To: <1266252393-20911-5-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-15 at 17:46 +0100, Florian Westphal wrote:

> +static bool xfrm_msg_compat(const struct sk_buff *skb)
> +{
> +	return unlikely(!!NETLINK_CB(skb).msg_compat);
> +}

The !! seems pointless but that's not why I'm quoting this here.

I think this function should only be used in the input path.

> +static bool xfrm_add_compatskb(struct sk_buff *skb,
> +                               unsigned int len, gfp_t gfp)
> +{

I think this should return the new skb, and I don't think it should set
the msg_compat flag in the NETLINK_CB.

> +static struct sk_buff *xfrm_get_compatskb(struct sk_buff *skb)
> +{

making this no longer needed.

> +/*
> + * avoids #ifdefs all over the place. Use of these must be
> conditional via
> + * xfrm_add_compatskb/xfrm_get_compatskb so compiler can remove
> branches.
> + */
> +#define compat_xfrm_user_expire     xfrm_user_expire
> +#define compat_xfrm_user_acquire    xfrm_user_acquire
> +#define compat_xfrm_user_polexpire  xfrm_user_polexpire
> +#define compat_xfrm_userpolicy_info xfrm_userpolicy_info
> +#define compat_xfrm_usersa_info     xfrm_usersa_info
> +#define compat_xfrm_userspi_info    xfrm_userspi_info

Good thing I didn't have to deal with compat _input_ in wireless since I
had killed the netlink input code :))

> +#endif
> +
> +/*
> + * userspace size of some structures is smaller by this amount
> + * due to different u64 alignment on x86 platform.
> + *
> + * Some of the structures need to use the compat_* structure
> definition
> + * when accessing certain members.
> + */
> +static const u8 xfrm_msg_min_compat_pad[XFRM_NR_MSGTYPES] = {
> +	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = 4, /* padding at end */
> +	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = 4, /* padding at end */
> +
> +	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = 4, /* access might need
> compat_ */
> +	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = 4, /* access might need
> compat_ */
> +	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = 4, /* access might need
> compat_ */
> +	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] = 4, /* padding at end */
> +	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = 4, /* padding at end */
> +	[XFRM_MSG_POLEXPIRE   - XFRM_MSG_BASE] = 4, /* access might need
> compat_ */
> +};

Shouldn't that be some sizeof() trickery instead of hardcoding 4?

> +static int get_user_expire_hard(const struct sk_buff *skb,
> +                                const struct xfrm_user_expire *ue)
> +{
> +	if (xfrm_msg_compat(skb)) {
> +		const struct compat_xfrm_user_expire *cmpt;
> +		cmpt = (const struct compat_xfrm_user_expire*) ue;
> +		return cmpt->hard;
> +	}
> +	return ue->hard;
> +}

That looks good to me, good use of the compat helper.

> @@ -700,6 +856,9 @@ static int copy_one_state(struct sk_buff *skb,
> struct xfrm_state *x, struct xfrm
>  	size_t len = sizeof(*p);
>  	int err;
>  
> +	if (xfrm_msg_compat(skb))
> +		len = sizeof(struct compat_xfrm_usersa_info);
> +

I really dislike this use though.

> @@ -724,6 +883,13 @@ static int dump_one_state(struct xfrm_state *x,
> int count, void *ptr)
>  	struct xfrm_dump_info *sp = ptr;
>  	struct sk_buff *skb = sp->out_skb;
>  	int ret = copy_one_state(skb, x, sp);
> +#ifdef CONFIG_COMPAT_FOR_U64_ALIGNMENT
> +	if (ret == 0) {
> +		skb = xfrm_get_compatskb(skb);
> +		if (skb)
> +			copy_one_state(skb, x, sp);
> +	}
> +#endif
>  	return ret;
>  }

And that's really convoluted.

> @@ -753,6 +919,8 @@ static int xfrm_dump_sa(struct sk_buff *skb,
> struct netlink_callback *cb)
>  		xfrm_state_walk_init(walk, 0);
>  	}
>  
> +	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +
>  	(void) xfrm_state_walk(net, walk, dump_one_state, &info);
>  
>  	return skb->len;

And this just seems wrong -- doesn't that fill _only_ the compat skb
here then??

(same thing happens again in this file)

> @@ -2200,6 +2455,9 @@ static int xfrm_exp_state_notify(struct
> xfrm_state *x, struct km_event *c)
>  	if (build_expire(skb, x, c) < 0)
>  		BUG();
>  
> +	if (xfrm_add_compatskb(skb, compat_xfrm_expire_msgsize(), GFP_ATOMIC))
> +		compat_build_expire(skb_shinfo(skb)->frag_list, x, c);

This is a good model, although I'd change it to be like this:

if (cskb = xfrm_add_compatskb(skb, ...))
compat_build_expire(cskb, x, c);

And I think the code would be a lot clearer if the other user were like

build_foo(skb, ..., false /* not compat */);
if ((cskb = xfrm_add_compatskb(skb, ...)))
build_foo(cskb, ..., true /* compat */);

instead of all the trickery with setting msg_compat on the output path
and then checking it again in the fill functions.

So for example:

> @@ -2302,6 +2567,11 @@ static int copy_to_user_xfrm_notify_sa(struct
> sk_buff *skb,
>  	int sizeof_xfrm_usersa_info = sizeof(*p);
>  	int headlen = xfrm_notify_sa_headlen(c);
>  
> +	if (xfrm_msg_compat(skb)) {
> +		headlen = compat_xfrm_notify_sa_headlen(c);
> +		sizeof_xfrm_usersa_info = sizeof(struct compat_xfrm_usersa_info);
> +	}

That'd get a compat parameter, and use it here instead of the
xfrm_msg_compat(skb) check.

> 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
>  	if (nlh == NULL)
>  		goto nla_put_failure;
> @@ -2347,6 +2617,9 @@ static int xfrm_notify_sa(struct xfrm_state *x,
> struct km_event *c)
>  	if (copy_to_user_xfrm_notify_sa(skb, x, c))
>  		goto nla_put_failure;
>  
> +	if (xfrm_add_compatskb(skb, len, GFP_ATOMIC))
> +		copy_to_user_xfrm_notify_sa(skb_shinfo(skb)->frag_list, x, c);

and instead of touching frag_list here, you'd pass the result of
xfrm_add_compatskb().

That way, the use of xfrm_msg_compat() is restricted to the input path,
which I think is much clearer.

johannes 

