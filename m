From: Tom Herbert <tom@herbertland.com>
Subject: Hardware support for foo over UDP?
Date: Mon, 16 Mar 2015 09:52:09 -0700
Message-ID: <CALx6S36bovfh_-oFo+PMag0Asato3qyAFdizteAFm9g4=YwFTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:38184 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933213AbbCPQwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 12:52:11 -0400
Received: by igbue6 with SMTP id ue6so47838152igb.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 09:52:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A few months ago the routing area director in IETF chartered a design
team to to look at common issues of protocol encapsulation. This was
motivated by the concern that too many encapsulations are being
defined without common guidelines (e.g. for network virtualization,
BIER, SFC). The output of this team is an Internet-draft
https://datatracker.ietf.org/doc/draft-rtg-dt-encap/ that will be
presented in the routing area working group at Dallas IETF next week.
The draft describes twelve areas that should be considered for
encapsulation protocols, and assumes that UDP encapsulation will be
ubiquitous.

While the draft is primarily intended to provide guidelines for
protocol development, there is a lot of information that can be
applied to implementation. In particular, section 18 describes
"Hardware friendly" considerations. There is discussion about both
switch and host (NIC) side. These have very different requirements and
constraints. For instance, switches don't typically have checksum
capabilities and are not able to perform reassembly (by virtue of
terminating UDP the switch essentially becomes a host per RFC1122 so
these need to be addressed).

On the host side, the first request is that the common NICs offloads
that we've relied on for many years should work with encapsulation.
Specifically, I propose there is an opportunity for NICs to support
offloads for UDP encapsulation in a generic manner. This support could
cover a large class of protocol encapsulations: MPLS/UDP and GRE/UDP
(both about to be standardized), three protocols being proposed in
NVO3 WG in IETF (GUE, Geneve, VXLAN-GPE), SFC/UDP, IPIP/UDP, SIT/UDP,
BIER, LISP, L2TP/UDP. Generic support could also work with layered
encapsulations (for instance GRE over GUE) as well as custom
encapsulations (e.g. 802.11 over UDP). This support is important to
large data center deployments since it is likely that several of the
above encapsulations would be deployed, and so a device that provides
generic support would seem more compelling than one supporting a few
specific variants.

The five common offloads in question are RSS, TX-csum, RX-csum, LSO, and LRO.

RSS is mostly solved by enabling RSS for UDP. IMO this should be
enabled by default in NICs that support it as the historical counter
argument is that this cause OOO for fragmented UDP packets seems to be
a lesser concern. One side note, it would be nice it there was an
option to include IPv6 flow label in the RSS hash to increase amount
of entropy, this is becoming relevant as more data centers transition
to IPv6.

TX-csum and RX-csum are made generic through NETIF_HW_CSUM and
CHECKSUM_UNNECESSARY; we've known this for a long time ;-). These will
work well to offload encapsulated transport checksums.  UDP
encapsulation also allows the opportunity to enable UDP checksum.
We're actually leveraging that to get good performance on legacy HW
using checksum-unnecessary conversion and remote checksum offload in
GUE and VXLAN. It does raise the possibility that someone may want to
explore HW offload of more than one checksum in a packet on transmit.

For LSO (TSO), the stack already demonstrates a generic solution for
segmentation with UDP encapsulation in GSO (__skb_udp_tunnel_segment).
Note that this code does not need to know the encapsulation protocol
or parse the packet to do GSO. As long we don't have any fields in the
encapsulation headers that need to be modified per segment, the bits
between the UDP header and the encapsulated L2/L3 header are just
copied per segment.

LRO is the hardest offload to make generic, a device will need to
parse encapsulation which will also mean that the device needs to know
the port to encapsulation protocol mapping. I don't know if we can
find a better answer here but it might be worth some consideration.

Please take a look at the draft for more detail.

Thanks,
Tom
