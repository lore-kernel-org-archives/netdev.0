From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 5/6] ipv6: Call xfrm6_xlat_addr from ipv6_rcv
Date: Wed, 30 Sep 2015 11:40:55 -0700
Message-ID: <CALx6S36My3jVm=_PgKYVqdJ7b8ccDPQhhgWW59wfekK7kTe+5Q@mail.gmail.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
	<1443565043-1287886-6-git-send-email-tom@herbertland.com>
	<20150930090617.GF7701@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34195 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932495AbbI3Sk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:40:56 -0400
Received: by igcpb10 with SMTP id pb10so53775igc.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:40:55 -0700 (PDT)
In-Reply-To: <20150930090617.GF7701@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 2:06 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Tue, Sep 29, 2015 at 03:17:22PM -0700, Tom Herbert wrote:
>> Call before performing NF_HOOK and routing in order to perform address
>> translation in the receive path.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>>  net/ipv6/ip6_input.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
>> index 9075acf..06dac55 100644
>> --- a/net/ipv6/ip6_input.c
>> +++ b/net/ipv6/ip6_input.c
>> @@ -183,6 +183,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
>>       /* Must drop socket now because of tproxy. */
>>       skb_orphan(skb);
>>
>> +     /* Translate destination address before routing */
>> +     xfrm6_xlat_addr(skb);
>> +
>
> This shows that xfrm is not the right place to add this. The existing
> xfrm hooks are located at the same place as your current LWT hooks are.
>
> You could use the existing xfrm hooks similar to xfrm tunnel modes.
> This reinserts the transformed packet back into layer2, but I guess
> this is not what you want.
>
> I'm currently paying with a GRO codepath for IPsec to get the
> packets transformed early. If you can do your address translation
> that early, it could be an option too. This clearly depends on
> enabled GRO at the receiving device, but you would still have
> the LWT hook as a fallback.
>
GRO probably doesn't help here. ILA already works with GRO, and
performing translation for every segment instead of just once for the
GRO packet would be unnecessary overhead. Besides, that still doesn't
address the problem of how to hook in a lookup and translation
function in the data path.

>>       return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
>>                      net, NULL, skb, dev, NULL,
>>                      ip6_rcv_finish);
>
> Or, try to use the netfilter hook that seems to be at the right
> place at least.
>
My original patch did hook into nf so it didn't require any change to
IP data path. The suggested alternatives were to use iptables or nft,
but the overhead of is too great for these to be useful for as a
performance optimization. The problem is that any additional lookup
added for this purpose only makes sense if it is significantly cheaper
than the cost of doing a route lookup (the part that can be eliminated
by early demux), and needs to have near zero impact on unrelated
traffic.

Tom
