From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/4] net/flow_dissector: add support for
 dissection of misc ip header fields
Date: Sat, 27 May 2017 10:18:45 -0700
Message-ID: <CALx6S35LoybyU-NN8RTk4YMOmuOZTkJeZ6GVBnWbX6rtd2uM6Q@mail.gmail.com>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
 <1495718679-20693-2-git-send-email-ogerlitz@mellanox.com> <CALx6S36uJrFA+TO7RDaRAxZi0vuEEc90_TnWP8a2yNP+V3X2qQ@mail.gmail.com>
 <CAJ3xEMgsYi_=0Sv7Wd9GajN5Oym3dKdw3QNDpU9jJR+T6z3Pmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35804 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbdE0RSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 13:18:47 -0400
Received: by mail-wr0-f194.google.com with SMTP id j27so2950322wre.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 10:18:47 -0700 (PDT)
In-Reply-To: <CAJ3xEMgsYi_=0Sv7Wd9GajN5Oym3dKdw3QNDpU9jJR+T6z3Pmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 27, 2017 at 9:31 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Thu, May 25, 2017 at 7:22 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Thu, May 25, 2017 at 6:24 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>> Add support for dissection of ip tos and ttl and ipv6 traffic-class
>>> and hoplimit. Both are dissected into the same struct.
>
>>> Uses similar call to ip dissection function as with tcp, arp and others.
>
>
>>> +/**
>>> + * struct flow_dissector_key_ip:
>>> + * @tos: tos
>>> + * @ttl: ttl
>>> + */
>>> +struct flow_dissector_key_ip {
>>> +       __u8    tos;
>>> +       __u8    ttl;
>>> +};
>>> --- a/net/core/flow_dissector.c
>>> +++ b/net/core/flow_dissector.c
>
>>> +static void
>>> +__skb_flow_dissect_ipv4(const struct sk_buff *skb,
>>> +                       struct flow_dissector *flow_dissector,
>>> +                       void *target_container, void *data, const struct iphdr *iph)
>>> +{
>>> +       struct flow_dissector_key_ip *key_ip;
>>> +
>>> +       if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_IP))
>>> +               return;
>>> +
>>> +       key_ip = skb_flow_dissector_target(flow_dissector,
>>> +                                          FLOW_DISSECTOR_KEY_IP,
>>> +                                          target_container);
>>> +       key_ip->tos = iph->tos;
>>> +       key_ip->ttl = iph->ttl;
>>
>> In an encapsulation this returns the tos and ttl of the encapsulated
>> packet. Is that really useful to the caller? Seems more likely that
>> they need the outer tos and ttl for forwarding.
>
> In what we are dealing with, classification is carried after the
> packet is decapsulated by the shared tunnel device. So even today,e.g
> for the src/dst IP, the dissection is carried on what were the inner
> fields before decap.
>
Or,

I think the problem is I don't know what you're dealing with. The only
thing I can derive from the commit log is that tos and ttl are being
extracted, but I don't know why they are needed. I do know this is
adding complexity to an already overly complex function, and this
introduces new conditionals and code into the primary use case of
flow_dissector which is to create a key for deriving skb->hash. I
don't see that the cost of this patch has been justified.

Tom

> When we did the the flower patches for being able to classify on both
> the inner and outer fields (say outer src/dst ip, tunnel key) for what
> related to the  macs/ips/ports/etc -- I don't think we touched the
> existing dissection, I will look on that to see if I am wrong..
