From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPSEC]: Make xfrm_lookup flags argument a
 bit-field
Date: Wed, 12 Dec 2007 10:43:42 -0800 (PST)
Message-ID: <20071212.104342.206132994.davem@davemloft.net>
References: <20071212012552.GA20618@gondor.apana.org.au>
	<E1J2GrH-0005SK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53483
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750920AbXLLSnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:43:43 -0500
In-Reply-To: <E1J2GrH-0005SK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Dec 2007 09:57:59 +0800

> [IPSEC]: Make xfrm_lookup flags argument a bit-field
> 
> This patch introduces an enum for bits in the flags argument of xfrm_lookup.
> This is so that we can cram more information into it later.
> 
> Since all current users use just the values 0 and 1, XFRM_LOOKUP_WAIT has
> been added with the value 1 << 0 to represent the current meaning of flags.
> 
> The test in __xfrm_lookup has been changed accordingly.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Begrudgingly, I've applied this, but only to make the merging of your
work easier.  I think this flag is totally wrong and you need to
fix this up.

This value is not an __xfrm_lookup() flag at all, and this issue would
have been clear had you tried to fix up the __xfrm_lookup() call
sites.  There is no point in adding the named constant, if you keep
the magic constants around, so it's wrong that you didn't hit all
the call sites when you added this flag.

This flag propages from a level before __xfrm_lookup() in many cases,
therefore it is a generic route lookup flag, not an XFRM layer
specific one.  ip_route_output_flow() is one of several example cases.

It is going to get even more ugly when you add the other XFRM lookup
flag in the followon changeset.  Now we'll have a mixture of the magic
constants '1' and '0', the named version XFRM_LOOKUP_WAIT, and this
new XFRM_LOOKUP_* flag for reverse resolution.

These values all exist in different contextual namespaces, yet you are
allocating and naming them purely from the context of __xfrm_lookup()
and that just isn't right.
