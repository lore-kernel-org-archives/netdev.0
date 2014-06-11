From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: add skb allocation flags to pskb_copy
Date: Wed, 11 Jun 2014 12:09:14 -0700 (PDT)
Message-ID: <20140611.120914.1187135773039853303.davem@davemloft.net>
References: <1402477954-1267-1-git-send-email-octavian.purdila@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1725AC13@AcuExch.aculab.com>
	<CAE1zotKXQwk89QLmc-PWMO69qgUgTVmbQTbc2EzbTXCF61tyXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
	christoph.paasch@uclouvain.be, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, mareklindner@neomailbox.ch,
	sw@simonwunderlich.de, antonio@meshcoding.com, marcel@holtmann.org,
	gustavo@padovan.org, johan.hedberg@gmail.com,
	arvid.brodin@alten.se, kaber@trash.net, pablo@netfilter.org,
	kadlec@blackhole.kfki.hu, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, sameo@linux.intel.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	andrew.hendry@gmail.com, edumazet@google.com
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbaFKTJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 15:09:19 -0400
In-Reply-To: <CAE1zotKXQwk89QLmc-PWMO69qgUgTVmbQTbc2EzbTXCF61tyXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Wed, 11 Jun 2014 12:59:26 +0300

> On Wed, Jun 11, 2014 at 12:22 PM, David Laight <David.Laight@aculab.com> wrote:
>> From: Octavian Purdila
>>> There are several instances where a pskb_copy or __pskb_copy is
>>> immediately followed by an skb_clone. Add a new parameter to allow the
>>> skb to be allocated from the fclone cache and thus speed up subsequent
>>> skb_clone calls.
>> ...
>>> @@ -2233,9 +2233,9 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
>>>  }
>>>
>>>  static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
>>> -                                     gfp_t gfp_mask)
>>> +                                     gfp_t gfp_mask, bool fclone)
>>>  {
>>> -     return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
>>> +     return __pskb_copy(skb, skb_headroom(skb), gfp_mask, fclone);
>> ...
>>
>> Why not add:
>> static inline struct sk_buff *pskb_copy_for_clone(struct sk_buff *skb,
>>                                         gfp_t gfp_mask)
>> {
>>         return __pskb_copy(skb, skb_headroom(skb), gfp_mask, true);
>> }
>>
>> So that only some of the call sites need changing.
>> The different function name is probably easier to grok than a Boolean
>> parameter.
>>
> 
> Hi David,
> 
> Since cloning a copy seems to be more frequent then one would thought,
> I think that explicitly adding the option will force people to think
> about allocating from the fclone cache.
> 
> But I don't care much either way, so if people think a new function is
> better I will rework the patch.

Actually you can do this in a way that makes the patch simpler.

Keep __pskb_copy()'s signature as is, and make it do something like:

	__pskb_copy_clone(skb, gfp_mask, false);

And then make the aforementioned pskb_copy_for_clone() which is:

	__pskb_copy_clone(skb, gfp_mask, true);

Then most of the call sites don't need to be touched at all.  You only
change the ones that want the new semantics.
