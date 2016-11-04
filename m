From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v4 0/9] net: add support for IPv6 Segment Routing
Date: Fri, 4 Nov 2016 11:29:39 +0100
Message-ID: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:60287 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933288AbcKDK2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 06:28:10 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 7C9DB67DB3B
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 11:27:58 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4:
 - Change @cleanup in ipv6_srh_rcv() from int to bool
 - Move checksum helper functions into header file
 - Add common definition for SR TLVs
 - Add comments for HMAC computation algorithm
 - Use rhashtable to store HMAC infos instead of linked list
 - Remove packed attribute for struct sr6_tlv_hmac
 - Use dst cache only if CONFIG_DST_CACHE is enabled

v3:
 - Fix compilation for CONFIG_IPV6={n,m}

v2:
 - Remove packed attribute from sr6 struct and replaced unaligned
   16-bit flags with two 8-bit flags.
 - SR code now included by default. Option CONFIG_IPV6_SEG6_HMAC
   exists for HMAC support (which requires crypto dependencies).
 - Replace "hidden" calls to mutex_{un,}lock to direct calls.
 - Fix reverse xmas tree coding style.
 - Fix cast-from-void*'s.
 - Update skb->csum to account for SR modifications.
 - Add dst_cache in seg6_output.

Segment Routing (SR) is a source routing paradigm, architecturally
defined in draft-ietf-spring-segment-routing-09 [1]. The IPv6 flavor of
SR is defined in draft-ietf-6man-segment-routing-header-02 [2].

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
        __u8    flag_1;
        __u8    flag_2;
        __u8    reserved;

        struct in6_addr segments[0];
};

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

        (2) Control plane support (patches 02..03 and 07..09). These patches enables
            to insert SRH on locally emitted and/or forwarded packets, both with
            encap mode and with inline mode. The SRH insertion is controlled through
            the lightweight tunnels mechanism. Furthermore, patch 08 enables the
            applications to insert an SRH on a per-socket basis, through the
            setsockopt() system call. The mechanism to specify a per-socket
            Routing Header was already defined for RH0 and no special modification
            was performed on this side. However, the code to actually push the RH
            onto the packets had to be adapted for the SRH specifications.
        (3) HMAC support (patches 04..06). These patches adds the support of the
            HMAC TLV verification for the dataplane part, and generation for
            the control plane part. Two hashing algorithms are supported
            (SHA-1 as legacy and SHA-256 as required by the IETF draft), but
            additional algorithms can be easily supported by simply adding an
            entry into an array.

[1] https://tools.ietf.org/html/draft-ietf-spring-segment-routing-09
[2] https://tools.ietf.org/html/draft-ietf-6man-segment-routing-header-02

David Lebrun (9):
  ipv6: implement dataplane support for rthdr type 4 (Segment Routing
    Header)
  ipv6: sr: add code base for control plane support of SR-IPv6
  ipv6: sr: add support for SRH encapsulation and injection with
    lwtunnels
  ipv6: sr: add core files for SR HMAC support
  ipv6: sr: implement API to control SR HMAC structure
  ipv6: sr: add calls to verify and insert HMAC signatures
  ipv6: add source address argument for ipv6_push_nfrag_opts
  ipv6: sr: add support for SRH injection through setsockopt
  ipv6: sr: add documentation file for per-interface sysctls

 Documentation/networking/seg6-sysctl.txt |  18 ++
 include/linux/ipv6.h                     |   4 +
 include/linux/seg6.h                     |   6 +
 include/linux/seg6_genl.h                |   6 +
 include/linux/seg6_hmac.h                |   6 +
 include/linux/seg6_iptunnel.h            |   6 +
 include/net/ipv6.h                       |   3 +-
 include/net/netns/ipv6.h                 |   1 +
 include/net/seg6.h                       |  59 ++++
 include/net/seg6_hmac.h                  |  62 ++++
 include/uapi/linux/ipv6.h                |   3 +
 include/uapi/linux/lwtunnel.h            |   1 +
 include/uapi/linux/seg6.h                |  54 ++++
 include/uapi/linux/seg6_genl.h           |  32 ++
 include/uapi/linux/seg6_hmac.h           |  21 ++
 include/uapi/linux/seg6_iptunnel.h       |  41 +++
 net/core/lwtunnel.c                      |   2 +
 net/ipv6/Kconfig                         |  12 +
 net/ipv6/Makefile                        |   3 +-
 net/ipv6/addrconf.c                      |  28 ++
 net/ipv6/af_inet6.c                      |   9 +-
 net/ipv6/exthdrs.c                       | 258 +++++++++++++++-
 net/ipv6/ip6_output.c                    |   5 +-
 net/ipv6/ip6_tunnel.c                    |   2 +-
 net/ipv6/ipv6_sockglue.c                 |   2 +
 net/ipv6/seg6.c                          | 450 ++++++++++++++++++++++++++++
 net/ipv6/seg6_hmac.c                     | 484 +++++++++++++++++++++++++++++++
 net/ipv6/seg6_iptunnel.c                 | 401 +++++++++++++++++++++++++
 28 files changed, 1967 insertions(+), 12 deletions(-)
 create mode 100644 Documentation/networking/seg6-sysctl.txt
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
2.7.3
