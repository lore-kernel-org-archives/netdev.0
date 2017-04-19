From: Ansis Atteka <ansisatteka@gmail.com>
Subject: Re: [PATCH net] xfrm: calculate L4 checksums also for GSO case before
 encrypting packets
Date: Tue, 18 Apr 2017 19:10:03 -0700
Message-ID: <CAMQa7Bimd378QJgsv6yBP0ULH+__C9gjjcXa39wx1z7p_9mT=g@mail.gmail.com>
References: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
 <20170411070755.GW5092@secunet.com> <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
 <20170418090919.GD30104@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ansis Atteka <aatteka@ovn.org>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35154 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758734AbdDSCKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 22:10:05 -0400
Received: by mail-it0-f68.google.com with SMTP id e132so1013113ite.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 19:10:04 -0700 (PDT)
In-Reply-To: <20170418090919.GD30104@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 April 2017 at 02:09, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Apr 13, 2017 at 07:45:08PM -0700, Ansis Atteka wrote:
>> On 11 April 2017 at 00:07, Steffen Klassert <steffen.klassert@secunet.com>
>> wrote:
>> >
>> > What's wrong with the checksum provided by the GSO layer and
>> > why we have to do this unconditionally here?
>> >
>>
>> I believe with "GSO layer" you meant the skb_gso_segment() function
>> invocation from xfrm_output_gso()?
>>
>> If so, then the problem with that is that the list of the skb's returned by
>> that function could be in CHECKSUM_PARTIAL state if skb came from a UDP
>> tunnel such as Geneve:
>
> This should not happen. We don't announce checksum capabilities,
> so the GSO layer should generate the full checksum.
>
> __skb_udp_tunnel_segment() and udp4_ufo_fragment() add the
> NETIF_F_HW_CSUM flag to features. This is certainly wrong
> if the packet undergoes an IPsec transformation.
>
> I don't have a testcase for this, so not sure if this is
> your problem. Could you try the (untested) patch below?

I am still seeing the same ESP packet corruption issue with the patch
you attached.

However, after taking pointers from your patch I came up with this one
that may solve this problem once and for all (note, that I was seeing
this bug only with ixgbe NIC that supports tx csum offloads). I hope
it does not break any other IPsec tests that you have.

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index b2be1d9..7812501 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -29,6 +29,7 @@ static struct sk_buff
*__skb_udp_tunnel_segment(struct sk_buff *skb,
        u16 mac_len = skb->mac_len;
        int udp_offset, outer_hlen;
        __wsum partial;
+       bool need_ipsec;

        if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
                goto out;
@@ -62,8 +63,10 @@ static struct sk_buff
*__skb_udp_tunnel_segment(struct sk_buff *skb,

        ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);

+       need_ipsec = skb_dst(skb) && dst_xfrm(skb_dst(skb));
        /* Try to offload checksum if possible */
        offload_csum = !!(need_csum &&
+                         !need_ipsec &&
                          (skb->dev->features &
                           (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
                                      (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM))));
