From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net 2/3] udp_offload: Set encapsulation before inner completes.
Date: Mon, 2 May 2016 14:00:15 -0700
Message-ID: <66798AAC-EDAE-4D51-88F1-7712638F3593@ovn.org>
References: <1461968887-4993-1-git-send-email-jarno@ovn.org> <1461968887-4993-2-git-send-email-jarno@ovn.org> <CALx6S35N7PtaERFCs27X5GuqUZKYkPFeG8ZQB=0uGpydw+ABEg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33618 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171AbcEBVAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 17:00:20 -0400
Received: by mail-pf0-f196.google.com with SMTP id y7so23585pfb.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 14:00:19 -0700 (PDT)
In-Reply-To: <CALx6S35N7PtaERFCs27X5GuqUZKYkPFeG8ZQB=0uGpydw+ABEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Apr 29, 2016, at 6:42 PM, Tom Herbert <tom@herbertland.com> wrote:
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
> How did you test this? Do you have a test case for the problem?
> 

I faced this problem when developing UDP tunnel offloads for virtio_net. Basically the GRO of encapsulated packets on the rx side should produce the same inner offsets that the original encapsulation did on the tx side. __skb_udp_tunnel_segment() has this line:

        int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);

which is intended to capture both the UDP header and the tunneling protocol header (e.g., UDP + variable length GENEVE header). So, if the inner MAC header is incorrectly set the segmentation would not work as expected.

> The general problem is that skb->encapsulation is the indicator that
> the inner offsets are valid, but there are many instances where we set
> skb->encapsulation independently of setting the inner headers. It
> would be nice if setting the flag and setting the inner headers were
> somehow unified.
> 

Agree, it was rather tedious to trace the call flow to figure out what is going on.

  Jarno

> Thanks,
> Tom
> 
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
