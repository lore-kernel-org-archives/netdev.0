From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Sun, 3 Sep 2017 08:43:27 -0700
Message-ID: <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com> <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35944 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752915AbdICPn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 11:43:29 -0400
Received: by mail-qk0-f179.google.com with SMTP id o63so15210754qkb.3
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 08:43:28 -0700 (PDT)
In-Reply-To: <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 2, 2017 at 9:11 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Sat, Sep 2, 2017 at 6:37 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Sat, Sep 2, 2017 at 6:32 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>> Hi Saeed,
>>>
>>> On Sun, Sep 3, 2017, at 01:01, Saeed Mahameed wrote:
>>>> On Thu, Aug 31, 2017 at 6:51 AM, Hannes Frederic Sowa
>>>> <hannes@stressinduktion.org> wrote:
>>>> > Saeed Mahameed <saeedm@mellanox.com> writes:
>>>> >
>>>> >> The first patch from Gal and Ariel provides the mlx5 driver support for
>>>> >> ConnectX capability to perform IP version identification and matching in
>>>> >> order to distinguish between IPv4 and IPv6 without the need to specify the
>>>> >> encapsulation type, thus perform RSS in MPLS automatically without
>>>> >> specifying MPLS ethertyoe. This patch will also serve for inner GRE IPv4/6
>>>> >> classification for inner GRE RSS.
>>>> >
>>>> > I don't think this is legal at all or did I misunderstood something?
>>>> >
>>>> > <https://tools.ietf.org/html/rfc3032#section-2.2>
>>>>
>>>> It seems you misunderstood the cover letter.  The HW will still
>>>> identify MPLS (IPv4/IPv6) packets using a new bit we specify in the HW
>>>> steering rules rather than adding new specific rules with  {MPLS
>>>> ethertype} X {IPv4,IPv6} to classify MPLS IPv{4,6} traffic, Same
>>>> functionality a better and general way to approach it.
>>>> Bottom line the hardware is capable of processing MPLS headers and
>>>> perform RSS on the inner packet (IPv4/6) without the need of the
>>>> driver to provide precise steering MPLS rules.
>>>
>>> Sorry, I think I am still confused.
>>>
>>> I just want to make sure that you don't use the first nibble after the
>>> mpls bottom of stack label in any way as an indicator if that is an IPv4
>>> or IPv6 packet by default. It can be anything. The forward equivalence
>>> class tells the stack which protocol you see.
>>>
>>> If you match on the first nibble behind the MPLS bottom of stack label
>>> the '4' or '6' respectively could be part of a MAC address with its
>>> first nibble being 4 or 6, because the particular pseudowire is EoMPLS
>>> and uses no control world.
>>>
>>> I wanted to mention it, because with addition of e.g. VPLS this could
>>> cause problems down the road and should at least be controllable? It is
>>> probably better to use Entropy Labels in future.
>>>
>> Or just use IPv6 with flow label for RSS (or MPLS/UDP, GRE/UDP if you
>> prefer) then all this protocol specific DPI for RSS just goes away ;-)
>
> Hi Tom,
>
> How does MPLS/UDP or GRE/UDP RSS works without protocol specific DPI ?
> unlike vxlan those protocols are not over UDP and you can't just play
> with the outer header udp src port, or do you ?
>
> Can you elaborate ?
>
Hi Saeed,

An encapsulator sets the UDP source port to be the flow entropy of the
packet being encapsulated. So when the packet traverses the network
devices can base their hash just on the canonical 5-tuple which is
sufficient for ECMP and RSS. IPv6 flow label is even better since the
middleboxes don't even need to look at the transport header, a packet
is steered based on the 3-tuple of addresses and flow label. In the
Linux stack,  udp_flow_src_port is used by UDP encapsulations to set
the source port. Flow label is similarly set by ip6_make_flowlabel.
Both of these functions use the skb->hash which is computed by calling
flow dissector at most once per packet (if the packet was received
with an L4 HW hash or locally originated on a connection the hash does
not need to be computed).

Please look at https://people.netfilter.org/pablo/netdev0.1/papers/UDP-Encapsulation-in-Linux.pdf
as well as Davem's "Less is More" presentation which highlights the
virtues of protocol generic HW mechanisms
(https://www.youtube.com/watch?v=6VgmazGwL_Y).

Tom
