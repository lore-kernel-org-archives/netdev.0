From: David Miller <davem@davemloft.net>
Subject: Re: speaking of stacks
Date: Thu, 03 Apr 2008 14:18:15 -0700 (PDT)
Message-ID: <20080403.141815.218859276.davem@davemloft.net>
References: <1206969356.4424.120.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joern@lazybastard.org,
	herbert@gondor.apana.org.au
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755562AbYDCVSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 17:18:15 -0400
In-Reply-To: <1206969356.4424.120.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 31 Mar 2008 09:15:56 -0400

> 
> All this talk about stacks got me thirsty.
> Heres something thats a mystery to me; probably very basic
> when doing static check analysis (kernel make checkstack)
> 
> I have ipsec turned on in the linus git tree kernel and
> net/xfrm/xfrm_user.c::xfrm_get_policy() shows up as one of
> the top offenders. Eyeballing reveals that
> struct xfrm_policy seems to be the offender 
> in the else {} after if (p->index) in that function.
> That seems understandable - once variable "tmp" is declared it goes
> on the stack and it is freakin huge. 
> However, checkstack only seems to catch it if i have the
> line "memset(&tmp, 0, sizeof(struct xfrm_policy))". If i remove
> that line - even though tmp is on the stack - checkstack doesnt catch
> it.
> 
> What gives?

You probably have most of the security infrastructure turned
off, therefore GCC can see that 'tmp' is basically unused
and can therefore be totally eliminated.

The memset() call makes 'tmp' get passed by reference to
another function, and thus become used.

This whole song and dance here is for SELINUX to set only
the policy->security, so that we can pass that back down
into the subsequent xfrm_policy_bysel_ctx().

The thing to do is to rearrange these security layer hooks
so that they take a "struct xfrm_sec_ctx **" instead of
a full policy pointer.

Then the code would look like:

		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
		struct xfrm_sec_ctx *ctx;

		err = verify_sec_ctx_len(attrs);
		if (err)
			return err;

		if (rt) {
			struct xfrm_user_sec_ctx *uctx = nla_data(rt);

			if ((err = security_xfrm_policy_alloc(&ctx, uctx)))
				return err;
		}
		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx,
					   delete, &err);
		security_xfrm_policy_free(ctx);

And thus the xfrm_policy wouldn't need to be on the stack
any longer.
