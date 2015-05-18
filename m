From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Mon, 18 May 2015 09:04:27 +0200
Message-ID: <20150518070427.GC8928@secunet.com>
References: <20150515.123726.1298734930500737780.davem@redhat.com>
 <555645A3.6010509@gmail.com>
 <20150516123457.GB683@gondor.apana.org.au>
 <20150516.171328.1953881469617376252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <alexander.duyck@gmail.com>,
	<alexander.h.duyck@redhat.com>, <netdev@vger.kernel.org>,
	<tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54241 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbbERHEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 03:04:32 -0400
Content-Disposition: inline
In-Reply-To: <20150516.171328.1953881469617376252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 16, 2015 at 05:13:28PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 16 May 2015 20:34:58 +0800
> 
> > On Fri, May 15, 2015 at 12:14:43PM -0700, Alexander Duyck wrote:
> >>
> >> >Yeah, this mark handling via tunnel->parms.o_key looks not so good.
> >> 
> >> So is there any recommendations for an alternative to make it so
> >> that the ipsec endpoint is identified as needing to be encrypted or
> >> decrypted?  If needed I could probably take a day or two to try and
> >> address it as I still have a few other minor things I want to try
> >> and fix such as the MTU configuration for vti/vti6.
> > 
> > I'd like to hear from Steffen as to whether there is anything
> > in userspace that relies on the mark being used in this way by
> > vti.  If not it should be easy to get rid of it and use some
> > field that's not exposed to user-space.  If there is then this
> > would be tricky to resolve.

The policy and state mark must match the tunnels i_key/o_key
on lookup. It is not required to set skb->mark, but we have
to make sure to use the tunnels gre keys as the mark when we
do a policy or state lookup.

> 
> The mark stuff comes from the commit below, and at the time I remember
> pushing back a few times because I was uneasy about applying this
> change:
> 
> ====================
> commit 7263a5187f9e9de45fcb51349cf0e031142c19a1
> Author: Christophe Gouault <christophe.gouault@6wind.com>
> Date:   Tue Oct 8 17:21:22 2013 +0200
> 
>     vti: get rid of nf mark rule in prerouting

This patch added the mark to the skb, but the matching
of the gre keys and the mark was already in the initial
implementation of vti. It used the i_key (instead of
skb->mark) to do the output route lookup.

I never liked this gre key/mark lookup. This should have been
done with a separate lookup key, but I fear we can't change
it without breaking backwards compatibility.
