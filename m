From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net 2/3] udp_offload: Set encapsulation before inner completes.
Date: Mon, 2 May 2016 15:54:02 -0700
Message-ID: <CAKgT0Uf-dvDj2KDnt4GZoMJONMC6LgLBtEUcsO0JJ1jqiFDfaw@mail.gmail.com>
References: <1461968887-4993-1-git-send-email-jarno@ovn.org>
	<1461968887-4993-2-git-send-email-jarno@ovn.org>
	<CAKgT0UcGCgRt5dpG2Y0a6sBar1KF1DkHxdhMbCOYV6qj15D50A@mail.gmail.com>
	<DB78A60B-3899-4767-AD0B-DCDCC65C04E1@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35149 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbcEBWyE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 18:54:04 -0400
Received: by mail-ig0-f179.google.com with SMTP id bi2so99643638igb.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 15:54:03 -0700 (PDT)
In-Reply-To: <DB78A60B-3899-4767-AD0B-DCDCC65C04E1@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 2, 2016 at 2:21 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>
>> On Apr 29, 2016, at 8:46 PM, Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>
>> On Fri, Apr 29, 2016 at 3:28 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>>> UDP tunnel segmentation code relies on the inner offsets being set for
>>> an UDP tunnel GSO packet.  The inner *_complete() functions will set
>>> the inner offsets only if the encapsulation is set before calling
>>> them, but udp_gro_complete() set it only after the inner *_complete()
>>> functions were done.
>>>
>>> Also, remove the setting of the inner_mac_header in udp_gro_complete()
>>> as it was wrongly set to the beginning of the UDP tunnel header rather
>>> than the inner MAC header.
>>>
>>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>>> ---
>>> net/ipv4/udp_offload.c | 8 +++++---
>>> 1 file changed, 5 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>>> index 0ed2daf..e330c0e 100644
>>> --- a/net/ipv4/udp_offload.c
>>> +++ b/net/ipv4/udp_offload.c
>>> @@ -399,6 +399,11 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>>>
>>>        uh->len = newlen;
>>>
>>> +       /* Set encapsulation before calling into inner gro_complete() functions
>>> +        * to make them set up the inner offsets.
>>> +        */
>>> +       skb->encapsulation = 1;
>>> +
>>>        rcu_read_lock();
>>>
>>>        uo_priv = rcu_dereference(udp_offload_base);
>>> @@ -421,9 +426,6 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>>>        if (skb->remcsum_offload)
>>>                skb_shinfo(skb)->gso_type |= SKB_GSO_TUNNEL_REMCSUM;
>>>
>>> -       skb->encapsulation = 1;
>>> -       skb_set_inner_mac_header(skb, nhoff + sizeof(struct udphdr));
>>> -
>>>        return err;
>>> }
>>>
>>> --
>>> 2.7.4
>>>
>>
>> So looking over this I think this patch is just a band-aid and it
>> isn't really fixing much of anything.  For example I cannot see where
>
> It fixes the immediate bug/problem that segmentation of GRO UDP tunnel packet fails due to incorrectly set inner MAC offset and/or missing inner network offset.

The problem is I think this will introduce other issues as there are
now situations where the inner MAC offset never gets set.  For example
did you try testing with GUE carrying either an IPIP or SIT tunnel?

>From what I can tell it looks like you are trying to fix VXLAN and
similar offloads, and Tom is focused on GUE.  What you will probably
need to do is add some code to ipip_gro_complete and sit_gro_complete
so that if skb->encapsulation is set before you call the function it
will set the inner MAC offset to the same offset as the inner network
header.  Otherwise you run the risk of screwing up segmentation
because the UDP tunnel segment code will use the inner mac header
offset when computing the tunnel header length and get it completely
wrong.

>> the inner transport offset is ever set.  From what I can tell it never
>> is.
>>
>
> inner transport offset is set in validate_xmit_skb(), but you are right, it is not set by the GRO complete code path. AFAIK no-one uses it before reaching validate_xmit_skb(), though. The documentation in (net-next) Documentation/networking/segmentation-offloads.txt could be fixed by removing the inner transport header from UDP/GRE tunnel case, as it is not used by either the GRE or UDP tunnel code.

Actually that is an interesting point.  Right now we need to keep the
inner transport header around because that is getting set.  If we were
to enforce the use of csum_start as the inner transport header offset,
then we could assume that transport_header is always the outer-most
transport header.  We might be able to drop a bit of space from the
skbuff by getting rid of it.  If nothing else it means one less header
offset we would have to copy.

- Alex
