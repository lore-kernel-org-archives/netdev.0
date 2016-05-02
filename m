From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net 2/3] udp_offload: Set encapsulation before inner completes.
Date: Mon, 2 May 2016 14:21:05 -0700
Message-ID: <DB78A60B-3899-4767-AD0B-DCDCC65C04E1@ovn.org>
References: <1461968887-4993-1-git-send-email-jarno@ovn.org> <1461968887-4993-2-git-send-email-jarno@ovn.org> <CAKgT0UcGCgRt5dpG2Y0a6sBar1KF1DkHxdhMbCOYV6qj15D50A@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35723 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953AbcEBVVJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 17:21:09 -0400
Received: by mail-pa0-f66.google.com with SMTP id zy2so48805pac.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 14:21:09 -0700 (PDT)
In-Reply-To: <CAKgT0UcGCgRt5dpG2Y0a6sBar1KF1DkHxdhMbCOYV6qj15D50A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Apr 29, 2016, at 8:46 PM, Alexander Duyck <alexander.duyck@gmail.com> wrote:
> 
> On Fri, Apr 29, 2016 at 3:28 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> UDP tunnel segmentation code relies on the inner offsets being set for
>> an UDP tunnel GSO packet.  The inner *_complete() functions will set
>> the inner offsets only if the encapsulation is set before calling
>> them, but udp_gro_complete() set it only after the inner *_complete()
>> functions were done.
>> 
>> Also, remove the setting of the inner_mac_header in udp_gro_complete()
>> as it was wrongly set to the beginning of the UDP tunnel header rather
>> than the inner MAC header.
>> 
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> net/ipv4/udp_offload.c | 8 +++++---
>> 1 file changed, 5 insertions(+), 3 deletions(-)
>> 
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index 0ed2daf..e330c0e 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -399,6 +399,11 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>> 
>>        uh->len = newlen;
>> 
>> +       /* Set encapsulation before calling into inner gro_complete() functions
>> +        * to make them set up the inner offsets.
>> +        */
>> +       skb->encapsulation = 1;
>> +
>>        rcu_read_lock();
>> 
>>        uo_priv = rcu_dereference(udp_offload_base);
>> @@ -421,9 +426,6 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>>        if (skb->remcsum_offload)
>>                skb_shinfo(skb)->gso_type |= SKB_GSO_TUNNEL_REMCSUM;
>> 
>> -       skb->encapsulation = 1;
>> -       skb_set_inner_mac_header(skb, nhoff + sizeof(struct udphdr));
>> -
>>        return err;
>> }
>> 
>> --
>> 2.7.4
>> 
> 
> So looking over this I think this patch is just a band-aid and it
> isn't really fixing much of anything.  For example I cannot see where

It fixes the immediate bug/problem that segmentation of GRO UDP tunnel packet fails due to incorrectly set inner MAC offset and/or missing inner network offset.

> the inner transport offset is ever set.  From what I can tell it never
> is.
> 

inner transport offset is set in validate_xmit_skb(), but you are right, it is not set by the GRO complete code path. AFAIK no-one uses it before reaching validate_xmit_skb(), though. The documentation in (net-next) Documentation/networking/segmentation-offloads.txt could be fixed by removing the inner transport header from UDP/GRE tunnel case, as it is not used by either the GRE or UDP tunnel code.

  Jarno

> What we probably need to do is the same thing we currently do in the
> transmit path itself.  We need to record all the headers on the way up
> so that we end up with the network and transport headers matching the
> inner headers, then when we complete the inner-most tunnel we set the
> inner headers and set skb->encapsulation.  Then on the way down we
> start overwriting the outer header offsets when skb->encapsulation is
> set.  That way we don't have to worry about screwing things up for
> headers like GRE/GUE because the GRE can write the inner header
> offsets, set skb->encapsulation, and then we only overwrite the outer
> headers all the way down because with skb->encapsulation set we know
> we are only dealing with outer headers because the inner header values
> have been written.
> 
> - Alex
