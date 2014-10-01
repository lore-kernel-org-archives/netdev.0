From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next] xfrm: Add sysctl option to enforce
 inbound policies for transport mode
Date: Wed, 1 Oct 2014 11:58:18 +0200
Message-ID: <20141001095818.GD6390@secunet.com>
References: <541815C3.7080509@strongswan.org>
 <20140919092437.GX6390@secunet.com>
 <54296113.3080106@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53703 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944AbaJAJ6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 05:58:40 -0400
Content-Disposition: inline
In-Reply-To: <54296113.3080106@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 03:39:31PM +0200, Tobias Brunner wrote:
> > 
> > commit 8fe7ee2ba983fd89b2555dce5930ffd0f7f6c361
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Thu Oct 23 14:57:11 2003 -0700
> > 
> >     [IPSEC]: Strengthen policy checks.
> > 
> > Maybe Herbert remembers why this was done only for tunnel mode.
> 
> Would be great to hear from Herbert about this.
> 
> > If I read section 5.2.1 of RFC 2401 correct, the inbound policy
> > must be enforced regardless of the mode.
> 
> It looks like the wording changed with RFC 4301.  

RFC 4301 did not yet exist when this code change was made,
so I tried to find the reason for that in RFC 2401.

> The SPD and its
> policies are not mentioned explicitly anymore in section 5.2 (like
> they were in step 3 in section 5.2.1 of RFC 2401).  Instead, packets
> must be matched against the "selectors identified by the SAD entry".
> It's not entirely clear to me whether these selectors are part of the
> SPD or properties of the SAD entries themselves, like the single
> selector that can currently be configured on SAs in the kernel.

It reads like the packets must match against the selectors of the
used SA. That's what we do at the beginning of __xfrm_policy_check().

This was already required in RFC 2401. But there was a matching policy
required too, seems this is not necessary anymore with RFC 4301.

Instead they recommend: "Every SPD SHOULD have a nominal, final entry
that catches anything that is otherwise unmatched, and discards it."

> Also, section 4.4.2 explicitly states that manually keyed SAD entries
> do not necessarily need to have a corresponding SPD entry.  Which might
> make sense for simple host-host (transport mode) SAs, but this wouldn't
> be possible anymore when enforcing inbound policies for transport mode.

Well, this states just that such SAD entries can exist. But does not
say that packets transformed by such a SA are allowed to pass without
matching policy.

> 
> Subject: [PATCH] xfrm: Enforce inbound transport mode policies like those in other modes
> 
> Currently inbound policies for transport mode SAs are not enforced.
> If no policy is found or if the templates don't match this is not
> considered an error for transport mode SAs.

If we find a policy, the templates should match. We need to fix this.
But it seems our policy enforcement for tunnel mode is too strict if
no policy is found. So I think we should leave transport mode as
it is here.
