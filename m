From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v5 net-next 09/14] ip6_tun: Add infrastructure for doing encapsulation
Date: Mon, 16 May 2016 13:16:50 -0700
Message-ID: <CAKgT0Ufm8D9u0zn859RzUSrU9K45hLyZt3f_w1O5daySZOWhog@mail.gmail.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-10-git-send-email-tom@herbertland.com>
	<CAKgT0UfyVkdYMDAwNcycR4pnW-7GTeu4a-oiCnnXn6oOQt3nUw@mail.gmail.com>
	<CALx6S35_EykxGm-S83cuCZFp6yaesqbLWgTxKQfdNr2WfBP8Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37055 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbcEPUQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 16:16:51 -0400
Received: by mail-ig0-f182.google.com with SMTP id s8so45854707ign.0
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 13:16:51 -0700 (PDT)
In-Reply-To: <CALx6S35_EykxGm-S83cuCZFp6yaesqbLWgTxKQfdNr2WfBP8Ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 12:28 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, May 16, 2016 at 12:24 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Sun, May 15, 2016 at 4:42 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> Add encap_hlen and ip_tunnel_encap structure to ip6_tnl. Add functions
>>> for getting encap hlen, setting up encap on a tunnel, performing
>>> encapsulation operation.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>> ---
>>>  include/net/ip6_tunnel.h  | 58 ++++++++++++++++++++++++++++++
>>>  net/ipv4/ip_tunnel_core.c |  5 +++
>>>  net/ipv6/ip6_tunnel.c     | 89 +++++++++++++++++++++++++++++++++++++++++------
>>>  3 files changed, 141 insertions(+), 11 deletions(-)
>>
>> So a bisect is pointing to this patch as causing a regression in IPv6
>> GRE throughput from 20 Gb/s to .04 Mb/s
>>
>> <...>
>>
>>> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
>>> index e79330f..9f0ea85 100644
>>> --- a/net/ipv6/ip6_tunnel.c
>>> +++ b/net/ipv6/ip6_tunnel.c
>>> @@ -1010,7 +1010,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>>>         struct dst_entry *dst = NULL, *ndst = NULL;
>>>         struct net_device *tdev;
>>>         int mtu;
>>> -       unsigned int max_headroom = sizeof(struct ipv6hdr);
>>> +       unsigned int max_headroom = sizeof(struct ipv6hdr) + t->hlen;
>>>         int err = -1;
>>>
>>>         /* NBMA tunnel */
>>> @@ -1063,7 +1063,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>>>                                      t->parms.name);
>>>                 goto tx_err_dst_release;
>>>         }
>>> -       mtu = dst_mtu(dst) - sizeof(*ipv6h);
>>> +       mtu = dst_mtu(dst) - sizeof(*ipv6h) - t->hlen;
>>>         if (encap_limit >= 0) {
>>>                 max_headroom += 8;
>>>                 mtu -= 8;
>>
>> So I am pretty sure this bit here is causing the regression.  Your skb
>> already has a GRE header added and it is included in skb->len.  In the
>> tests just below here you are comparing skb->len to mtu, but you now
>> have the GRE header included twice so it is going to fail.  Odds are
>> this should be t->encap_hlen, and not t->hlen.
>>
> Good catch! Fixing now...

Actually I think the one other case above for max_headroom probably
should be encap_hlen as well.  After all we don't need to allocate
headroom for something we have already placed in the skb.

I'm still digging into the patch set.  If I find anything else I will
let you know.  I'm hoping to be able to test ip6ip6 hardware tunnel
offloads by the end of today.

- Alex
