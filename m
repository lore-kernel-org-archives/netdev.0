From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: Fix remote checksum offload with GUE
Date: Tue, 22 Mar 2016 14:45:51 -0700
Message-ID: <CAKgT0UeAiYHX7n4Y8S0QqXSExuzpQCQJvBCNWOtF-uLn8Qnc0g@mail.gmail.com>
References: <1458674365-3944200-1-git-send-email-tom@herbertland.com>
	<CAKgT0UfNrmmG3var3OQ04fPK08nNkip=ZC3EAKXc6PsFeYjFbA@mail.gmail.com>
	<CALx6S37yTDJL7aY66uOHH0jz1oyvJNS8fRMe-H-D9dKpiPVURw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Alex Duyck <aduyck@mirantis.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34632 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbcCVVpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 17:45:52 -0400
Received: by mail-io0-f178.google.com with SMTP id m184so259120395iof.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 14:45:52 -0700 (PDT)
In-Reply-To: <CALx6S37yTDJL7aY66uOHH0jz1oyvJNS8fRMe-H-D9dKpiPVURw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 2:10 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Mar 22, 2016 at 1:20 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Tue, Mar 22, 2016 at 12:19 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> In skb_segment the check of whether or not to perform the checksum on
>>> host was changed to not consider rather remote checksum offload is
>>> in use. In the case that can_checksum_protocol fails the checksum
>>> is computed regardless. __skb_udp_tunnel_segment was modified in a
>>> related patch to add NETIF_F_HW_CSUM into features when grabbing
>>> the enc_features and remote checksum offload is being done. The
>>> problem is that this bit can be cleared in lower GSO layers that
>>> are also doing tunneling (e.g. ipip, GRE when used with GUE),
>>> so when we get to skb_segment that intent has been lost and
>>> can_checksum_protocol fails.
>>
>> So what you are describing sounds like a tunnel in tunnel scenario.
>> It might work better to just skip masking the features if
>> skb->remcsum_offload is set rather than trying to change how we
>> perform the offload.
>>
> To be clear, my patch is restoring the old behavior not implementing a new one.

Yes, but the old behavior could lead to kernel panics under certain
circumstances.

>> I'm pretty sure this will cause data corruption and maybe a kernel
>> panic if Tx checksum offload is disabled.
>>
> Nope, working fine for me.

What are the options you used to create the tunnel?  Did you enable
both remcsum and udpcsum?

> The outer checksum would be computed in
>>> This patch:
>>>
>>> - Restores the check in skb_segment to look at remote checksum offload.
>>> - Removes the code in __skb_udp_tunnel_segment to force the
>>>   NETIF_F_HW_CSUM feature since this is no longer useful with above
>>>   change.
>>> - Removes check for remote checksum offload in gso_reset_checksum.
>>>   A special case should not be needed here.
>>>
>>> Tested: Single netperf STREAM over GUE-ipip
>>>
>>> Before fix:
>>>    5625 Mbps
>>> After fix:
>>>    6410 Mbps
>>>
>>> Fixes: 76443456227097179c1482 ("net: Move GSO csum into SKB_GSO_CB")
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>> ---
>>>  include/linux/skbuff.h |  4 ----
>>>  net/core/skbuff.c      |  5 ++---
>>>  net/ipv4/udp_offload.c | 10 ----------
>>>  3 files changed, 2 insertions(+), 17 deletions(-)
>>>
>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>> index 15d0df9..f6fe8a5 100644
>>> --- a/include/linux/skbuff.h
>>> +++ b/include/linux/skbuff.h
>>> @@ -3615,10 +3615,6 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
>>>
>>>  static inline void gso_reset_checksum(struct sk_buff *skb, __wsum res)
>>>  {
>>> -       /* Do not update partial checksums if remote checksum is enabled. */
>>> -       if (skb->remcsum_offload)
>>> -               return;
>>> -
>>>         SKB_GSO_CB(skb)->csum = res;
>>>         SKB_GSO_CB(skb)->csum_start = skb_checksum_start(skb) - skb->head;
>>>  }
>>
>> I'm pretty sure this part here will break things when you don't have
>> an outer offload enabled.  What NIC did you test this on?  Did you try
>> disabling the Tx checksum support in the hardware to see what would
>> happen?
>>
> Mellanox.
>
> When TX checksum is disabled the outer checksum is computed in
> __skb_udp_tunnel_segment.

Yes, but that uses gso_make_checksum which requires the csum and
csum_start fields be initialized in the SKB_GSO_CB().

>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>> index f044f97..e4eb78d 100644
>>> --- a/net/core/skbuff.c
>>> +++ b/net/core/skbuff.c
>>> @@ -3259,14 +3259,13 @@ skip_fraglist:
>>>                 nskb->truesize += nskb->data_len;
>>>
>>>  perform_csum_check:
>>> -               if (!csum) {
>>> +               if (!csum && !nskb->remcsum_offload) {
>>>                         if (skb_has_shared_frag(nskb)) {
>>>                                 err = __skb_linearize(nskb);
>>>                                 if (err)
>>>                                         goto err;
>>>                         }
>>> -                       if (!nskb->remcsum_offload)
>>> -                               nskb->ip_summed = CHECKSUM_NONE;
>>> +                       nskb->ip_summed = CHECKSUM_NONE;
>>>                         SKB_GSO_CB(nskb)->csum =
>>>                                 skb_checksum(nskb, doffset,
>>>                                              nskb->len - doffset, 0);
>>
>> I'm pretty sure this is going to cause a huge mess if you are
>> requesting remote checksum but cannot perform an outer checksum.  One
>> of the reasons I merged these features together the way I did was
>> because we needed to perform the initial checksum to avoid causing a
>> kernel panic later on.  Otherwise we don't have the SKB_GSO_CB()->csum
>> and SKB_GSO_CB()->csum_start fields populated.
>>
> Nope, if we can't perform outer checksum it is done in the host. I'm
> not seeing any problem.

Are you running remcsum with udpcsum set or is udpcsum not set?  If
you don't set udpcsum it doesn't actually compute an outer checksum
value.

>>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>>> index 8a3405a..f86f1e1 100644
>>> --- a/net/ipv4/udp_offload.c
>>> +++ b/net/ipv4/udp_offload.c
>>> @@ -78,16 +78,6 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>>>
>>>         features &= skb->dev->hw_enc_features;
>>>
>>> -       /* The only checksum offload we care about from here on out is the
>>> -        * outer one so strip the existing checksum feature flags and
>>> -        * instead set the flag based on our outer checksum offload value.
>>> -        */
>>> -       if (remcsum || ufo) {
>>> -               features &= ~NETIF_F_CSUM_MASK;
>>> -               if (!need_csum || offload_csum)
>>> -                       features |= NETIF_F_HW_CSUM;
>>> -       }
>>> -
>>>         /* segment inner packet. */
>>>         segs = gso_inner_segment(skb, features);
>>>         if (IS_ERR_OR_NULL(segs)) {
>>
>> This part breaks UDP fragmentation I am pretty sure.  We need this bit
>> for UFO to avoid having to perform a checksum over the data twice if
>> we are offloading the outer UDP checksum.
>
> The maybe leave this for ufo if it is a problem (please test your
> suppositions!), but this is not good for remcsum offload.

I suspect we are supposed to be setting encap_level to 0 when we set
skb->encapsulation to 0 before processing inner headers in the case of
UDP and GRE tunnel offloads.  I'll try to test and submit something in
the next hour or two.

- Alex
