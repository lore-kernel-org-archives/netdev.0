From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Mon, 04 Sep 2017 15:50:12 +0200
Message-ID: <87pob6bmjv.fsf@stressinduktion.org>
References: <20170830230409.15176-1-saeedm@mellanox.com>
        <87fuc7ong0.fsf@stressinduktion.org>
        <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
        <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
        <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
        <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
        <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49615 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753566AbdIDNuP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 09:50:15 -0400
In-Reply-To: <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
        (Tom Herbert's message of "Sun, 3 Sep 2017 08:43:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> writes:

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

This would require the MPLS stack copying the flowlabel of IPv6
connections between MPLS routers over their whole lifetime in the MPLS
network. The same would hold for MPLS encapsulated inside UDP, the
source port needs to be kept constant. This is very impractical. The
hash for the flow label can often not be recomputed by interim routers,
because they might lack the knowledge of the upper layer protocol.

UDP source port entropy still has the problem that we don't respect the
source port as RSS entropy by default in network cards, because of
possible fragmentation and thus possible reordering of packets. GRE does
not have this problem and is way easier to identify by hardware.

Basically we need to tell network cards that they can use specific
destination UDP ports where we allow the source port to be used in RSS
hash calculation. I don't see how this is any easier than just using GRE
with a defined protocol field? I do like the combination of ipv6
flowlabel + GRE.

Btw. people are using the GRE Key as additional entropy without looking
into the GRE payload.

Bye,
Hannes
