From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPsec policy database customization proposal
Date: Tue, 8 Jul 2014 13:35:41 +0200
Message-ID: <20140708113541.GT32371@secunet.com>
References: <CADdy8Hq=Pi2PwuA4JLhd2smV7FKSwFLGCDvbCpviSqxhFaKTfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44159 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbaGHLfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 07:35:52 -0400
Content-Disposition: inline
In-Reply-To: <CADdy8Hq=Pi2PwuA4JLhd2smV7FKSwFLGCDvbCpviSqxhFaKTfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 30, 2014 at 02:50:18PM +0200, Christophe Gouault wrote:
> Hi IPsec and network maintainers,
> 
> After proposing a patchset to netdev (xfrm: scalability enhancements
> for policy database) and discussing with Steffen Klassert, we agree on
> the fact that the SPD lookup algorithm needs performance and
> scalability improvements: SPs with non-prefixed selectors are
> optimized through a hash table, but other SPs (the majority) are
> stored in a sorted chained list, which does not scale. Additionally a
> flowcache is used, and is known not to scale.

I'd not say that the flowcache does not scale, it scales quite well
in some situations as it returns a precalculated xfrm bundle (policy
and states) based on a hash. The problem of the flowcache is that it
gets the performance by learning from the network traffic that arrives
and therefore it might be partly controllable by remote entities.

> 
> The bottleneck is the SPD lookup by selector (configuration and lookup itself).
> 
> Unfortunately, there is no all-in-one multi-field classifier that
> would behave well in all situations. However, various classifiers
> exist that are fitted to this or that use case. Therefore, I suggest
> the following approach: adding hooks in the IPsec SPD, so that one can
> dynamically register a custom SPD implementation ("SPD driver") fitted
> to its use case, typically by loading a kernel module.

Can you name some multi-field classifiers with their usecases?
While I think adding such a API is a step in the right direction,
I would like to see that we have known well scaling algorithms
that can replace the current method in some situations. Otherwise
we just add complextiy without any benefit.

> 
> This obviously needs discussion before starting any development, so
> here is a more detailed proposal:
> 
> - Define the minimum handlers to manipulate the SPD lookup by selector (alloc,
>   insert, delete, flush, lookup_bysel, lookup_byflow, destroy...).
> - export a register/unregister function, so that an SPD implementation may
>   register/unregister its handlers.
> - Separate the SPD common code from the SPD lookup by selector code. Keep the
>   policy_all and policy_byidx tables in the common code, extract the current
>   policy_inexact + policy_bydst implementation as an SPD driver. It is the
>   default implementation when no SPD driver is registered.
> - *struct xfrm_policy* must offer a private area for SPD driver data (void * or
>   opaque place holder of fixed size or opaque place holder of size specific to
>   driver implementation).

Please keep in mind that we need to lookup policies and states, so both
lookups need to be reasonably fast for a well scaling IPsec lookup method.

> - since we keep the current implementation as the default, the policy_inexact +
>   policy_bydst database heads (currently stored in netns->xfrm and xfrm_policy
>   link fields (bydst and flo) may remain at their current location.
> - SPD drivers needing some configuration may export their specific
>   configuration API (/proc, netlink...)

No /proc files please, netlink should be ok for that.

> - as a first step, we only support one registered handler at a time.
> - as a first step, an SPD driver can only be loaded or unloaded if the SPD is
>   empty (return EBUSY otherwise).
> 
> Remarks:
> 
> - this architecture is open to later evolutions such as supporting the
>   registration of several handlers, dynamically listing/selecting/switching
>   drivers via netlink messages (to support dynamic change of SPD implementation
>   according to SPD content).
> - loading/unloading or changing SPD drivers with a non empty SPD implies to
>   rebuild the SPD from the SP list. This may lock the SPD for a rather long
>   time.
> 
> I would like your opinion/questions/advices.
> 

Would be good to hear further opinions on this topic...
