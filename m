From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: IPsec policy database customization proposal
Date: Wed, 16 Jul 2014 09:35:41 +0200
Message-ID: <CADdy8Hps=2Xfs5TTgSQZtCKTCmL32AyxbuCeT59s3MmRZF6Bbg@mail.gmail.com>
References: <CADdy8Hq=Pi2PwuA4JLhd2smV7FKSwFLGCDvbCpviSqxhFaKTfg@mail.gmail.com>
	<20140708113541.GT32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:65452 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbaGPHfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 03:35:42 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so3787507igb.3
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 00:35:41 -0700 (PDT)
In-Reply-To: <20140708113541.GT32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

thanks for your answer,

2014-07-08 13:35 GMT+02:00 Steffen Klassert <steffen.klassert@secunet.com>
:
> On Mon, Jun 30, 2014 at 02:50:18PM +0200, Christophe Gouault wrote:
>> Hi IPsec and network maintainers,
>>
>> After proposing a patchset to netdev (xfrm: scalability enhancements
>> for policy database) and discussing with Steffen Klassert, we agree on
>> the fact that the SPD lookup algorithm needs performance and
>> scalability improvements: SPs with non-prefixed selectors are
>> optimized through a hash table, but other SPs (the majority) are
>> stored in a sorted chained list, which does not scale. Additionally a
>> flowcache is used, and is known not to scale.
>
> I'd not say that the flowcache does not scale, it scales quite well
> in some situations as it returns a precalculated xfrm bundle (policy
> and states) based on a hash. The problem of the flowcache is that it
> gets the performance by learning from the network traffic that arrives
> and therefore it might be partly controllable by remote entities.
>
>>
>> The bottleneck is the SPD lookup by selector (configuration and lookup itself).
>>
>> Unfortunately, there is no all-in-one multi-field classifier that
>> would behave well in all situations. However, various classifiers
>> exist that are fitted to this or that use case. Therefore, I suggest
>> the following approach: adding hooks in the IPsec SPD, so that one can
>> dynamically register a custom SPD implementation ("SPD driver") fitted
>> to its use case, typically by loading a kernel module.
>
> Can you name some multi-field classifiers with their usecases?
> While I think adding such a API is a step in the right direction,
> I would like to see that we have known well scaling algorithms
> that can replace the current method in some situations. Otherwise
> we just add complextiy without any benefit.

There are several multi-field classification algorithms, but few seem
adapted to SPD/SAD lookup:

- linear search
- hierarchical tries
- set-pruning tries
- grid-of-tries
- bit-vector linear search
- cross-producting
- recursive flow classification (RFC)
- decision-tree approach (HiCuts)
- ...

They all suffer from at least one of these issues:

- update time grows too fast with number of rules
- memory consumption grows too fast with number of rules
- memory or update time is unpredictible
- no incremental update
- algorithm too complex to tune
- some are limited to 2 dimensions (e.g. src@ and dst@)

Several of them may be very efficient with a limited number of rules,
but none really scales.

In brief, I agree that the complexity added by SPD replacement hooks
is probably not worth, considering the few algorithm replacement
candidates.

In my humble opinion, the patchset I initially proposed (xfrm:
scalability enhancements for policy database) is a good trade-off: it
is just an extension of the current algorithm, that relaxes conditions
on hashable SPs. It is scalable, it enables to address a large variety
of use cases and it defaults to the current algorithm. And it
drastically improves update and lookup performance of average or big
SPDs, as long as you set good prefix thresholds.

As far as I understand, the only things that concerned you about the
patchset were:

- using /proc to configure the algorithm, you prefer netlink.
- adding a configuration API that could potentially be later
deprecated. My feeling is that the choice of a brand new SPD algorithm
will not happen before long.
- calculation of thresholds is not automatic. As I already suggested,
it may be configured by a daemon if an automatic system is needed.

What if I rework the patchset and replace the configuration via /proc
by a configuration by netlink:

- supporting message XFRM_MSG_NEWSPDINFO from userland, with
  attribute XFRMA_SPD_HTHRESH
- adding XFRMA_SPD_HTHRESH attribute to XFRM_MSG_NEWSPDINFO messages
from the kernel in reply to XFRM_MSG_GETSPDINFO?

Best Regards,
Christophe

>> This obviously needs discussion before starting any development, so
>> here is a more detailed proposal:
>>
>> - Define the minimum handlers to manipulate the SPD lookup by selector (alloc,
>>   insert, delete, flush, lookup_bysel, lookup_byflow, destroy...).
>> - export a register/unregister function, so that an SPD implementation may
>>   register/unregister its handlers.
>> - Separate the SPD common code from the SPD lookup by selector code. Keep the
>>   policy_all and policy_byidx tables in the common code, extract the current
>>   policy_inexact + policy_bydst implementation as an SPD driver. It is the
>>   default implementation when no SPD driver is registered.
>> - *struct xfrm_policy* must offer a private area for SPD driver data (void * or
>>   opaque place holder of fixed size or opaque place holder of size specific to
>>   driver implementation).
>
> Please keep in mind that we need to lookup policies and states, so both
> lookups need to be reasonably fast for a well scaling IPsec lookup method.
>
>> - since we keep the current implementation as the default, the policy_inexact +
>>   policy_bydst database heads (currently stored in netns->xfrm and xfrm_policy
>>   link fields (bydst and flo) may remain at their current location.
>> - SPD drivers needing some configuration may export their specific
>>   configuration API (/proc, netlink...)
>
> No /proc files please, netlink should be ok for that.
>
>> - as a first step, we only support one registered handler at a time.
>> - as a first step, an SPD driver can only be loaded or unloaded if the SPD is
>>   empty (return EBUSY otherwise).
>>
>> Remarks:
>>
>> - this architecture is open to later evolutions such as supporting the
>>   registration of several handlers, dynamically listing/selecting/switching
>>   drivers via netlink messages (to support dynamic change of SPD implementation
>>   according to SPD content).
>> - loading/unloading or changing SPD drivers with a non empty SPD implies to
>>   rebuild the SPD from the SP list. This may lock the SPD for a rather long
>>   time.
>>
>> I would like your opinion/questions/advices.
>>
>
> Would be good to hear further opinions on this topic...
