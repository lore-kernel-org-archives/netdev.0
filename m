From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 14/14] ip4ip6: Support for GSO/GRO
Date: Thu, 5 May 2016 10:48:36 -0700
Message-ID: <CAKgT0Ue3QA=6rYBoPA0qFYBd-CD_-Q8U6BvDppxwHbK_js1TeQ@mail.gmail.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
	<1462410164-1953217-15-git-send-email-tom@herbertland.com>
	<1462411229.13075.13.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAKgT0UciiUQMfPodReb3MyX-Y+X9do9vGmz5kwcttQtsLJVRRA@mail.gmail.com>
	<CALx6S37w8526zZNLbguatYkDv63iJaGyht2BYCfym=-XoPTxEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:32807 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbcEERsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 13:48:37 -0400
Received: by mail-io0-f171.google.com with SMTP id f89so91722273ioi.0
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 10:48:36 -0700 (PDT)
In-Reply-To: <CALx6S37w8526zZNLbguatYkDv63iJaGyht2BYCfym=-XoPTxEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 5, 2016 at 9:48 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Wed, May 4, 2016 at 8:26 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Wed, May 4, 2016 at 6:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Wed, 2016-05-04 at 18:02 -0700, Tom Herbert wrote:
>>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>>> ---
>>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>>> index 928b456..6a811fa 100644
>>>> --- a/include/linux/skbuff.h
>>>> +++ b/include/linux/skbuff.h
>>>> @@ -484,6 +484,8 @@ enum {
>>>>       SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
>>>>
>>>>       SKB_GSO_IP6IP6 = 1 << 15,
>>>> +
>>>> +     SKB_GSO_IP4IP6 = 1 << 16,
>>>>  };
>>>>
>>>
>>> Houston, we have a problem.
>>>
>>> gso_type is 16bit (unsigned short), or maybe I missed something ?
>>>
>>> struct skb_shared_info {
>>>         unsigned char   nr_frags;
>>>         __u8            tx_flags;
>>>         unsigned short  gso_size;
>>>         unsigned short  gso_segs;
>>>         unsigned short  gso_type; <<-->>
>>
>> No, I am pretty sure you have it right.  We are out of bits.
>>
>> Also it seems like we are generating a number of duplicate entries.
>> What is the difference between IP6IP6 and SIT over IPv6?  I'm not
>> really seeing the difference.
>>
>> I'm wondering if maybe we shouldn't look at the possibly using the
>> IPIP and SIT bits to instead indicate that the frame is encapsulated
>> in an outer IPv4 or outer IPv6 header since we already have TCPV4 and
>> TCPV6 to indicate if the inner network type is a V4 or V6.  Then there
>> is no need for this patch set to introduce any new tunnel types to be
>> segmented since all cases should be covered.  As far as I can tell
>> SKB_GSO_IPIP/SIT were never really being tested against anyway so we
>> might want to go the IPIPV4 IPIPV6 route instead as that is probably
>> closer to what most device limitations would be.
>>
> My worry is that the current public interface means IPIP is IPv4 over
> IPv4, and SIT means IPv6 over IPv4. There are some drivers advertising
> offload support for these so I don't think we safely redefine
> SKB_GSO_IPIP/SIT.

The group is pretty small, and they all advertise support for SIT and
IPIP.  Even if they don't support an outer IPv6 tunnel it just means
we are essentially combining the 2 bits into 1.

In the case of the Intel drivers that advertise support for it they
could support the change without any issue since the use the header
pointers to set the offsets of the inner and outer headers and don't
care if they are v4 or v6.

> For finding more bits in gso_type there are some SKB_GOS_* that are
> not really types at all but more flags. I'm going try to turn
> SKB_GSO_DODGY into a skbuff for the purposes here. We'll still have
> the problem of running out bits next time a new type is added (maybe
> SKB_GSO_SCTP?) but can probably make room for one or two more. Longer
> term I think the the solution is too eliminate gso_type altogether as
> we are once again running into the problem of trying to indicate a
> combinatorial set of constraints and complex layering in a just few
> flag bits.

Still, I don't think there is much gain to be had by specifying the
inner network type twice, once in the outer tunnel segmentation type,
and then again in the inner TCP segmentation type.  That is why I was
thinking it would be better to just specify an IPIPV4 and IPIPV6 since
then you can run v4 or v6 on the inside and let TSOV4 or TSOV6 in the
hw_enc_features take care of specifying if you can support inner IPV6
or not.

- Alex
