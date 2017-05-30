From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/4] net/flow_dissector: add support for
 dissection of misc ip header fields
Date: Tue, 30 May 2017 15:10:29 +0200
Message-ID: <20170530131029.GD1838@nanopsycho>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
 <1495718679-20693-2-git-send-email-ogerlitz@mellanox.com>
 <CALx6S36uJrFA+TO7RDaRAxZi0vuEEc90_TnWP8a2yNP+V3X2qQ@mail.gmail.com>
 <CAJ3xEMgsYi_=0Sv7Wd9GajN5Oym3dKdw3QNDpU9jJR+T6z3Pmw@mail.gmail.com>
 <CALx6S35LoybyU-NN8RTk4YMOmuOZTkJeZ6GVBnWbX6rtd2uM6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33895 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdE3NKc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 09:10:32 -0400
Received: by mail-wr0-f195.google.com with SMTP id 6so4124560wrb.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 06:10:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35LoybyU-NN8RTk4YMOmuOZTkJeZ6GVBnWbX6rtd2uM6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 27, 2017 at 07:18:45PM CEST, tom@herbertland.com wrote:
>On Sat, May 27, 2017 at 9:31 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Thu, May 25, 2017 at 7:22 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Thu, May 25, 2017 at 6:24 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>>> Add support for dissection of ip tos and ttl and ipv6 traffic-class
>>>> and hoplimit. Both are dissected into the same struct.
>>
>>>> Uses similar call to ip dissection function as with tcp, arp and others.
>>
>>
>>>> +/**
>>>> + * struct flow_dissector_key_ip:
>>>> + * @tos: tos
>>>> + * @ttl: ttl
>>>> + */
>>>> +struct flow_dissector_key_ip {
>>>> +       __u8    tos;
>>>> +       __u8    ttl;
>>>> +};
>>>> --- a/net/core/flow_dissector.c
>>>> +++ b/net/core/flow_dissector.c
>>
>>>> +static void
>>>> +__skb_flow_dissect_ipv4(const struct sk_buff *skb,
>>>> +                       struct flow_dissector *flow_dissector,
>>>> +                       void *target_container, void *data, const struct iphdr *iph)
>>>> +{
>>>> +       struct flow_dissector_key_ip *key_ip;
>>>> +
>>>> +       if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_IP))
>>>> +               return;
>>>> +
>>>> +       key_ip = skb_flow_dissector_target(flow_dissector,
>>>> +                                          FLOW_DISSECTOR_KEY_IP,
>>>> +                                          target_container);
>>>> +       key_ip->tos = iph->tos;
>>>> +       key_ip->ttl = iph->ttl;
>>>
>>> In an encapsulation this returns the tos and ttl of the encapsulated
>>> packet. Is that really useful to the caller? Seems more likely that
>>> they need the outer tos and ttl for forwarding.
>>
>> In what we are dealing with, classification is carried after the
>> packet is decapsulated by the shared tunnel device. So even today,e.g
>> for the src/dst IP, the dissection is carried on what were the inner
>> fields before decap.
>>
>Or,
>
>I think the problem is I don't know what you're dealing with. The only
>thing I can derive from the commit log is that tos and ttl are being
>extracted, but I don't know why they are needed. I do know this is
>adding complexity to an already overly complex function, and this
>introduces new conditionals and code into the primary use case of
>flow_dissector which is to create a key for deriving skb->hash. I
>don't see that the cost of this patch has been justified.

Tom, we have been over this multiple times. The decision DaveM made at
the time I was pushing cls_flower was to have one shared dissection code
(I originally had a separate dissector inside cls_flower). And I
agree with that decision. It was a bit painful to work out the
flow_dissector in a generic way, but it was worth the efford.

So when we need to dissect something new for cls_flower, we put it here.
flow_dissector is now miles away from being just a plain
"creator of the key to derive skb->hash".

Jiří
