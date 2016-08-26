From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC 0/9] add support for IPv6 Segment Routing
Date: Fri, 26 Aug 2016 17:52:38 +0200
Message-ID: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34049 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751559AbcHZQOV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 12:14:21 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 7315367DDBC
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:52:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Segment Routing (SR) is a source routing paradigm, architecturally
defined in draft-ietf-spring-segment-routing-09 [1]. The IPv6 flavor of
SR is defined in draft-ietf-6man-segment-routing-header-01 [2].

The main idea is that an SR-enabled packet contains a list of segments,
which represent mandatory waypoints. Each waypoint is called a segment
endpoint. The SR-enabled packet is routed normally (e.g. shortest path)
between the segment endpoints. A node that inserts an SRH into a packet
is called an ingress node, and a node that is the last segment endpoint
is called an egress node.

>From an IPv6 viewpoint, an SR-enabled packet contains an IPv6 extension
header, which is a Routing Header type 4, defined as follows:

struct ipv6_sr_hdr {
        __u8    nexthdr;
        __u8    hdrlen;
        __u8    type;
        __u8    segments_left;
        __u8    first_segment;
        __be16  flags;
        __u8    reserved;

        struct in6_addr segments[0];
} __attribute__((packed));

The first 4 bytes of the SRH is consistent with the Routing Header
definition in RFC 2460. The type is set to `4' (SRH).

Each segment is encoded as an IPv6 address. The segments are encoded in
reverse order: segments[0] is the last segment of the path, and
segments[first_segment] is the first segment of the path.

segments[segments_left] points to the currently active segment and
segments_left is decremented at each segment endpoint.

There exist two ways for a packet to receive an SRH, we call them
encap mode and inline mode. In the encap mode, the packet is encapsulated
in an outer IPv6 header that contains the SRH. The inner (original) packet
is not modified. A virtual tunnel is thus created between the ingress node
(the node that encapsulates) and the egress node (the last segment of the path).
Once an encapsulated SR packet reaches the egress node, the node decapsulates
the packet and performs a routing decision on the inner packet. This kind of
SRH insertion is intended to use for routers that encapsulates in-transit
packet.

The second SRH insertion method, the inline mode, acts by directly inserting
the SRH right after the IPv6 header of the original packet. For this method,
if a particular flag (SR6_FLAG_CLEANUP) is set, then the penultimate segment
endpoint must strip the SRH from the packet before forwarding it to the last
segment endpoint. This insertion method is intended to use for endhosts,
however it is also used for in-transit packets by some industry actors.

Finally, the SRH may contain TLVs after the segments list. Several types of
TLVs are defined, but we currently consider only the HMAC TLV. This TLV is
an answer to the deprecation of the RH0 and enables to ensure the authenticity
and integrity of the SRH. The HMAC text contains the flags, the first_segment
index, the full list of segments, and the source address of the packet. While
SR is intended to use mostly within a single administrative domain, the HMAC
TLV allows to verify SR packets coming from an untrusted source.

This patches series implements support for the IPv6 flavor of SR and is
logically divided into the following components:

	(1) Data plane support (patch 01). This patch adds a function
	    in net/ipv6/exthdrs.c to handle the Routing Header type 4.
	    It enables the kernel to act as a segment endpoint, by supporting
	    the following operations: decrementation of the segments_left field,
	    cleanup flag support (removal of the SRH if we are the penultimate
	    segment endpoint) and decapsulation of the inner packet as an egress
	    node.
	(2) Control plane support (patches 02-04 and 08-09). These patches enables
	    to insert SRH on locally emitted and/or forwarded packets, both with
	    encap mode and with inline mode. The SRH insertion is controlled through
	    the lightweight tunnels mechanism. Furthermore, patch 09 enables the
	    applications to insert an SRH on a per-socket basis, through the
	    setsockopt() system call. The mechanism to specify a per-socket
	    Routing Header was already defined for RH0 and no special modification
	    was performed on this side. However, the code to actually push the RH
	    onto the packets had to be adapted for the SRH specifications.
	(3) HMAC support (patches 05-07). These patches adds the support of the
	    HMAC TLV verification for the dataplane part, and generation for
	    the control plane part. Two hashing algorithms are supported
	    (SHA-1 as legacy and SHA-256 as required by the IETF draft), but
	    additional algorithms can be easily supported by simply adding an
	    entry into an array.

[1] https://tools.ietf.org/html/draft-ietf-spring-segment-routing-09
[2] https://tools.ietf.org/html/draft-ietf-6man-segment-routing-header-01

Any comment on the architecture, API and implementation would be very welcome.

Regards,

David Lebrun (9):
  ipv6: implement dataplane support for rthdr type 4 (Segment Routing
    Header)
  ipv6: sr: add code base for control plane support of SR-IPv6
  ipv6: route: export symbol ip6_route_input
  ipv6: sr: add support for SRH encapsulation and injection with
    lwtunnels
  ipv6: sr: add core files for SR HMAC support
  ipv6: sr: implement API to control SR HMAC structures
  ipv6: sr: add calls to verify and insert HMAC signatures
  ipv6: add source address argument for ipv6_push_nfrag_opts
  ipv6: sr: add support for SRH injection through setsockopt

 include/linux/ipv6.h               |   6 +
 include/linux/seg6.h               |   6 +
 include/linux/seg6_genl.h          |   6 +
 include/linux/seg6_hmac.h          |   6 +
 include/linux/seg6_iptunnel.h      |   6 +
 include/net/ipv6.h                 |   3 +-
 include/net/netns/ipv6.h           |   3 +
 include/net/seg6.h                 |  64 ++++++
 include/net/seg6_hmac.h            |  62 ++++++
 include/uapi/linux/ipv6.h          |   3 +
 include/uapi/linux/lwtunnel.h      |   1 +
 include/uapi/linux/seg6.h          |  46 ++++
 include/uapi/linux/seg6_genl.h     |  32 +++
 include/uapi/linux/seg6_hmac.h     |  20 ++
 include/uapi/linux/seg6_iptunnel.h |  33 +++
 net/core/lwtunnel.c                |   2 +
 net/ipv6/Kconfig                   |  38 ++++
 net/ipv6/Makefile                  |   3 +
 net/ipv6/addrconf.c                |  36 ++++
 net/ipv6/exthdrs.c                 | 225 ++++++++++++++++++-
 net/ipv6/ip6_output.c              |   5 +-
 net/ipv6/ip6_tunnel.c              |   2 +-
 net/ipv6/ipv6_sockglue.c           |   4 +
 net/ipv6/route.c                   |   1 +
 net/ipv6/seg6.c                    | 391 +++++++++++++++++++++++++++++++++
 net/ipv6/seg6_hmac.c               | 432 +++++++++++++++++++++++++++++++++++++
 net/ipv6/seg6_iptunnel.c           | 330 ++++++++++++++++++++++++++++
 27 files changed, 1756 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/seg6.h
 create mode 100644 include/linux/seg6_genl.h
 create mode 100644 include/linux/seg6_hmac.h
 create mode 100644 include/linux/seg6_iptunnel.h
 create mode 100644 include/net/seg6.h
 create mode 100644 include/net/seg6_hmac.h
 create mode 100644 include/uapi/linux/seg6.h
 create mode 100644 include/uapi/linux/seg6_genl.h
 create mode 100644 include/uapi/linux/seg6_hmac.h
 create mode 100644 include/uapi/linux/seg6_iptunnel.h
 create mode 100644 net/ipv6/seg6.c
 create mode 100644 net/ipv6/seg6_hmac.c
 create mode 100644 net/ipv6/seg6_iptunnel.c

-- 
2.3.6
