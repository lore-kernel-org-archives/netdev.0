From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Mon, 4 Sep 2017 09:15:42 -0700
Message-ID: <CALx6S37wcp1om0Dwr1=-6jF=HkAuZj313pLJ7sVhgsyJ4yZDjg@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
 <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com> <87pob6bmjv.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35257 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753764AbdIDQPn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 12:15:43 -0400
Received: by mail-qk0-f169.google.com with SMTP id r141so3328879qke.2
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2017 09:15:43 -0700 (PDT)
In-Reply-To: <87pob6bmjv.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 4, 2017 at 6:50 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Tom Herbert <tom@herbertland.com> writes:
>
>> An encapsulator sets the UDP source port to be the flow entropy of the
>> packet being encapsulated. So when the packet traverses the network
>> devices can base their hash just on the canonical 5-tuple which is
>> sufficient for ECMP and RSS. IPv6 flow label is even better since the
>> middleboxes don't even need to look at the transport header, a packet
>> is steered based on the 3-tuple of addresses and flow label. In the
>> Linux stack,  udp_flow_src_port is used by UDP encapsulations to set
>> the source port. Flow label is similarly set by ip6_make_flowlabel.
>> Both of these functions use the skb->hash which is computed by calling
>> flow dissector at most once per packet (if the packet was received
>> with an L4 HW hash or locally originated on a connection the hash does
>> not need to be computed).
>
> This would require the MPLS stack copying the flowlabel of IPv6
> connections between MPLS routers over their whole lifetime in the MPLS
> network. The same would hold for MPLS encapsulated inside UDP, the
> source port needs to be kept constant. This is very impractical. The
> hash for the flow label can often not be recomputed by interim routers,
> because they might lack the knowledge of the upper layer protocol.
>
Hannes,

When the flow label is set the packet will traverse the network and be
ECMP routed regardless of whether the payload is MPLS at anything
else-- the important characteristic is that network devices don't need
to know how to parse MPLS (or GRE, or IPIP, or L2TP, ESP, or ...) to
provide good ECMP. At a source the flow label or UDP source port needs
to be generated. That can be based on DPI, derived from the MPLS
entropy label, use SPI in ESP, etc. I don't see anything special about
MPLS in this regard.

> UDP source port entropy still has the problem that we don't respect the
> source port as RSS entropy by default in network cards, because of
> possible fragmentation and thus possible reordering of packets. GRE does
> not have this problem and is way easier to identify by hardware.
>
> Basically we need to tell network cards that they can use specific
> destination UDP ports where we allow the source port to be used in RSS
> hash calculation. I don't see how this is any easier than just using GRE
> with a defined protocol field? I do like the combination of ipv6
> flowlabel + GRE.
>
No, we don't any more want port specific configuration in NICs! The
NIC should just fallback to 3-tuple hash when it see MF or offset set
in IPv4 header. But even if it doesn't implement this, receiving OOO
fragments is hardly the end of the world-- IP packets are always
allowed to be received OOO. If something breaks because in order
delivery is assumed then that is the bug that needs to be fixed. So at
best handling fragmentation in this manner is proposed om
optimization whose benefits will pale to getting good ECMP and RSS
when encapsulation is in use.

> Btw. people are using the GRE Key as additional entropy without looking
> into the GRE payload.
>
Sure some are, but the GRE key is not defined to be flow entropy so
it's not ubiquitous it used for that so it gives sufficient entropy or
is even constant per flow. GRE/UDP (RFC8086) was primarily written to
allow a more consistent method (as was RFC7510 for doing MPLS/UDP).

Tom
