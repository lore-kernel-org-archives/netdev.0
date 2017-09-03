From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Sun, 3 Sep 2017 19:17:08 +0300
Message-ID: <CAJ3xEMiNKVZnPcqDavmRduQjJRZSOZTFYOP1-ghpREXegLaB-A@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com> <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35493 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753076AbdICQRK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 12:17:10 -0400
Received: by mail-oi0-f43.google.com with SMTP id n18so30486932oig.2
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 09:17:09 -0700 (PDT)
In-Reply-To: <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 3, 2017 at 6:43 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Sat, Sep 2, 2017 at 9:11 PM, Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:
>> On Sat, Sep 2, 2017 at 6:37 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Sat, Sep 2, 2017 at 6:32 PM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>> Hi Saeed,
>>>>
>>>> On Sun, Sep 3, 2017, at 01:01, Saeed Mahameed wrote:
>>>>> On Thu, Aug 31, 2017 at 6:51 AM, Hannes Frederic Sowa
>>>>> <hannes@stressinduktion.org> wrote:
>>>>> > Saeed Mahameed <saeedm@mellanox.com> writes:
>>>>> >
>>>>> >> The first patch from Gal and Ariel provides the mlx5 driver support for
>>>>> >> ConnectX capability to perform IP version identification and matching in
>>>>> >> order to distinguish between IPv4 and IPv6 without the need to specify the
>>>>> >> encapsulation type, thus perform RSS in MPLS automatically without
>>>>> >> specifying MPLS ethertyoe. This patch will also serve for inner GRE IPv4/6
>>>>> >> classification for inner GRE RSS.
>>>>> >
>>>>> > I don't think this is legal at all or did I misunderstood something?
>>>>> >
>>>>> > <https://tools.ietf.org/html/rfc3032#section-2.2>
>>>>>
>>>>> It seems you misunderstood the cover letter.  The HW will still
>>>>> identify MPLS (IPv4/IPv6) packets using a new bit we specify in the HW
>>>>> steering rules rather than adding new specific rules with  {MPLS
>>>>> ethertype} X {IPv4,IPv6} to classify MPLS IPv{4,6} traffic, Same
>>>>> functionality a better and general way to approach it.
>>>>> Bottom line the hardware is capable of processing MPLS headers and
>>>>> perform RSS on the inner packet (IPv4/6) without the need of the
>>>>> driver to provide precise steering MPLS rules.
>>>>
>>>> Sorry, I think I am still confused.
>>>>
>>>> I just want to make sure that you don't use the first nibble after the
>>>> mpls bottom of stack label in any way as an indicator if that is an IPv4
>>>> or IPv6 packet by default. It can be anything. The forward equivalence
>>>> class tells the stack which protocol you see.
>>>>
>>>> If you match on the first nibble behind the MPLS bottom of stack label
>>>> the '4' or '6' respectively could be part of a MAC address with its
>>>> first nibble being 4 or 6, because the particular pseudowire is EoMPLS
>>>> and uses no control world.
>>>>
>>>> I wanted to mention it, because with addition of e.g. VPLS this could
>>>> cause problems down the road and should at least be controllable? It is
>>>> probably better to use Entropy Labels in future.
>>>>
>>> Or just use IPv6 with flow label for RSS (or MPLS/UDP, GRE/UDP if you
>>> prefer) then all this protocol specific DPI for RSS just goes away ;-)

>> How does MPLS/UDP or GRE/UDP RSS works without protocol specific DPI ?
>> unlike vxlan those protocols are not over UDP and you can't just play
>> with the outer header udp src port, or do you ?
>> Can you elaborate ?

> An encapsulator sets the UDP source port to be the flow entropy of the
> packet being encapsulated. So when the packet traverses the network
> devices can base their hash just on the canonical 5-tuple which is
> sufficient for ECMP and RSS. IPv6 flow label is even better since the
> middleboxes don't even need to look at the transport header, a packet
> is steered based on the 3-tuple of addresses and flow label. In the
> Linux stack,  udp_flow_src_port is used by UDP encapsulations to set
> the source port. Flow label is similarly set by ip6_make_flowlabel.
> Both of these functions use the skb->hash which is computed by calling
> flow dissector at most once per packet (if the packet was received
> with an L4 HW hash or locally originated on a connection the hash does
> not need to be computed).

Hi Tom,

Re all sorts of udp encap, sure, we're all on the less-is-more thing and just
RSS-ing on the ip+udp encap header.

For GRE, I was trying to fight back that rss-ing on inner, but as
Saeed commented,
we didn't see something simple through which the HW can do spreading. To make
sure I follow, you are saying that if this is gre6 tunneling

net-next.git]# git grep -p ip6_make_flowlabel net/ include/linux/ include/net/
include/net/ipv6.h=static inline void iph_to_flow_copy_v6addrs(struct
flow_keys *flow,
include/net/ipv6.h:static inline __be32 ip6_make_flowlabel(struct net
*net, struct sk_buff *skb,
include/net/ipv6.h=static inline void ip6_set_txhash(struct sock *sk) { }
include/net/ipv6.h:static inline __be32 ip6_make_flowlabel(struct net
*net, struct sk_buff *skb,
net/ipv6/ip6_gre.c=static int ip6gre_header(struct sk_buff *skb,
struct net_device *dev,
net/ipv6/ip6_gre.c:                  ip6_make_flowlabel(dev_net(dev), skb,
net/ipv6/ip6_output.c=int ip6_xmit(const struct sock *sk, struct
sk_buff *skb, struct flowi6 *fl6,
net/ipv6/ip6_output.c:  ip6_flow_hdr(hdr, tclass,
ip6_make_flowlabel(net, skb, fl6->flowlabel,
net/ipv6/ip6_output.c=struct sk_buff *__ip6_make_skb(struct sock *sk,
net/ipv6/ip6_output.c:               ip6_make_flowlabel(net, skb,
fl6->flowlabel,
net/ipv6/ip6_tunnel.c=int ip6_tnl_xmit(struct sk_buff *skb, struct
net_device *dev, __u8 dsfield,
net/ipv6/ip6_tunnel.c:               ip6_make_flowlabel(net, skb,
fl6->flowlabel, true, fl6));

the sender side (ip6_tnl_xmit?) will set the IPv6 flow label in a
similar manner done by udp_flow_src_port? and
if the receiver side hashes on L3 IPv6 src/dst/flow label we'll get
spreading? nice!

Still, what do we do with IPv4 GRE tunnels? and what do we do with HW
which isn't capable to RSS on flow label?

> Please look at https://people.netfilter.org/pablo/netdev0.1/papers/UDP-Encapsulation-in-Linux.pdf
> as well as Davem's "Less is More" presentation which highlights the
> virtues of protocol generic HW mechanisms
> (https://www.youtube.com/watch?v=6VgmazGwL_Y).
