From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/7] net: Add skb_get_hash_perturb
Date: Wed, 29 Apr 2015 12:51:03 -0700
Message-ID: <CALx6S34TsL8vB_KVxXA90WLMaq3d2o+CL=99U6WzqHogPMyxjw@mail.gmail.com>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
	<1430281661-2271966-2-git-send-email-tom@herbertland.com>
	<20150429075947.GB30392@breakpoint.cc>
	<1430306370.3711.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:34073 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbbD2TvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:51:04 -0400
Received: by iedfl3 with SMTP id fl3so57470946ied.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 12:51:04 -0700 (PDT)
In-Reply-To: <1430306370.3711.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 4:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-04-29 at 09:59 +0200, Florian Westphal wrote:
>> Tom Herbert <tom@herbertland.com> wrote:
>> > This is used to get the skb->hash and then perturb it for a local use.
>> >
>> > Signed-off-by: Tom Herbert <tom@herbertland.com>
>> > ---
>> >  include/linux/skbuff.h | 15 +++++++++++++++
>> >  1 file changed, 15 insertions(+)
>> >
>> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> > index 66e374d..b706889 100644
>> > --- a/include/linux/skbuff.h
>> > +++ b/include/linux/skbuff.h
>> > @@ -17,6 +17,7 @@
>> >  #include <linux/kernel.h>
>> >  #include <linux/kmemcheck.h>
>> >  #include <linux/compiler.h>
>> > +#include <linux/jhash.h>
>> >  #include <linux/time.h>
>> >  #include <linux/bug.h>
>> >  #include <linux/cache.h>
>> > @@ -927,6 +928,20 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
>> >     return skb->hash;
>> >  }
>> >
>> > +static inline __u32 skb_get_hash_perturb(struct sk_buff *skb,
>> > +                                    u32 perturb)
>> > +{
>> > +   u32 hash = skb_get_hash(skb);
>> > +
>> > +   if (likely(hash)) {
>> > +           hash = jhash_1word((__force __u32) hash, perturb);
>>
>> Whats this perturb for?
>>
>> perturb is supposed to make sure that if you have
>>
>> flow1, flow2 where hash(flow1, perturb) == hash(flow2, perturb)
>> the collision will be temporary and go away once perturb changes.
>>
>> If you perturb after hashing, such collision is permanent.
>>
>> So I think this either should flow_dissect + hash in software,
>> or just use skb_get_hash without perturb.
>
> Yes, I mentioned this several times to Tom in the various past attempts.
>
> Also, this stuff means that sfq will call jhash twice instead of once,
> unless skb->hash is already populated before sfq enqueue.
>
> If the goal is to extend skb to include a flow_keys_digest instead of
> u32 hash, lets state this right now ;)
>
> I think I already suggested to add a 'perturb' parameter to
> skb_get_hash() to use in place of hashrnd (found in
> net/core/flow_dissector.c)
>
Okay, I'll do this. We can try to optimize out the calls to
flow_dissector some other time.

> If hash is Toeplitz based and provided by a NIC, I doubt a jhash()
> perturbation will get anything better.
>
>
>
>
