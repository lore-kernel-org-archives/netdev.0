From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 14/14] ip4ip6: Support for GSO/GRO
Date: Wed, 4 May 2016 20:26:06 -0700
Message-ID: <CAKgT0UciiUQMfPodReb3MyX-Y+X9do9vGmz5kwcttQtsLJVRRA@mail.gmail.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
	<1462410164-1953217-15-git-send-email-tom@herbertland.com>
	<1462411229.13075.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37723 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562AbcEED0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:26:07 -0400
Received: by mail-ig0-f182.google.com with SMTP id s8so4187199ign.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:26:06 -0700 (PDT)
In-Reply-To: <1462411229.13075.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 6:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-05-04 at 18:02 -0700, Tom Herbert wrote:
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 928b456..6a811fa 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -484,6 +484,8 @@ enum {
>>       SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
>>
>>       SKB_GSO_IP6IP6 = 1 << 15,
>> +
>> +     SKB_GSO_IP4IP6 = 1 << 16,
>>  };
>>
>
> Houston, we have a problem.
>
> gso_type is 16bit (unsigned short), or maybe I missed something ?
>
> struct skb_shared_info {
>         unsigned char   nr_frags;
>         __u8            tx_flags;
>         unsigned short  gso_size;
>         unsigned short  gso_segs;
>         unsigned short  gso_type; <<-->>

No, I am pretty sure you have it right.  We are out of bits.

Also it seems like we are generating a number of duplicate entries.
What is the difference between IP6IP6 and SIT over IPv6?  I'm not
really seeing the difference.

I'm wondering if maybe we shouldn't look at the possibly using the
IPIP and SIT bits to instead indicate that the frame is encapsulated
in an outer IPv4 or outer IPv6 header since we already have TCPV4 and
TCPV6 to indicate if the inner network type is a V4 or V6.  Then there
is no need for this patch set to introduce any new tunnel types to be
segmented since all cases should be covered.  As far as I can tell
SKB_GSO_IPIP/SIT were never really being tested against anyway so we
might want to go the IPIPV4 IPIPV6 route instead as that is probably
closer to what most device limitations would be.

- Alex
