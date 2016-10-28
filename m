From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded ICMP errors from offending packet
Date: Fri, 28 Oct 2016 10:32:16 +0200
Message-ID: <87a8dox4a7.fsf@redhat.com>
References: <CALx6S35BrV_KTgbwSKc-CiW4RRwHinKXJNhB+gmU9kQgvfTC+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38810 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758800AbcJ1IcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 04:32:20 -0400
Received: by mail-wm0-f42.google.com with SMTP id n67so97266413wme.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 01:32:19 -0700 (PDT)
In-reply-to: <CALx6S35BrV_KTgbwSKc-CiW4RRwHinKXJNhB+gmU9kQgvfTC+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 10:35 PM GMT, Tom Herbert wrote:
> On Mon, Oct 24, 2016 at 2:28 AM, Jakub Sitnicki <jkbs@redhat.com> wrote:
>> Same as for the transmit path, let's do our best to ensure that received
>> ICMP errors that may be subject to forwarding will be routed the same
>> path as flow that triggered the error, if it was going in the opposite
>> direction.
>>
> Unfortunately our ability to do this is generally quite limited. This
> patch will select the route for multipath, but I don't believe sets
> the same link in LAG and definitely can't help switches doing ECMP to
> route the ICMP packet in the same way as the flow would be. Did you
> see a problem that warrants solving this case?

The motivation here is to bring IPv6 ECMP routing on par with IPv4 to
enable its wider use, targeting anycast services. Forwarding ICMP errors
back to the source host, at the L3 layer, is what we thought would be a
step forward.

Similar to change in IPv4 routing introduced in commit 79a131592dbb
("ipv4: ICMP packet inspection for multipath", [1]) we do our best at
L3, leaving any potential problems with LAG at lower layer (L2)
unaddressed.

>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 1184c2b..c0f38ea 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c

[...]

>> @@ -1168,6 +1192,8 @@ void ip6_route_input(struct sk_buff *skb)
>>         tun_info = skb_tunnel_info(skb);
>>         if (tun_info && !(tun_info->mode & IP_TUNNEL_INFO_TX))
>>                 fl6.flowi6_tun_key.tun_id = tun_info->key.tun_id;
>> +       if (unlikely(fl6.flowi6_proto == IPPROTO_ICMPV6))
>> +               fl6.mp_hash = ip6_multipath_icmp_hash(skb);
>
> I will point out that this is only

Sorry, looks like part of your reply got cut short. Could you repost?

-Jakub

[1] https://git.kernel.org/torvalds/c/79a131592dbb81a2dba208622a2ffbfc53f28bc0
