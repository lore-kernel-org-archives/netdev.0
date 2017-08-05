From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 0/5] ipv6: sr: add support for advanced local segment processing
Date: Sat, 5 Aug 2017 12:38:23 +0200
Message-ID: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:37174 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdHEKi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 06:38:29 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp3.sgsi.ucl.ac.be (Postfix) with ESMTPS id D1E5767DCAB
        for <netdev@vger.kernel.org>; Sat,  5 Aug 2017 12:38:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: use EXPORT_SYMBOL_GPL

The current implementation of IPv6 SR supports SRH insertion/encapsulation
and basic segment endpoint behavior (i.e., processing of an SRH contained in
a packet whose active segment (IPv6 DA) is routed to the local node). This
behavior simply consists of updating the DA to the next segment and forwarding
the packet accordingly. This processing is realised for all such packets,
regardless of the active segment.

The most recent specifications of IPv6 SR [1] [2] extend the SRH processing
features as follows. Each segment endpoint defines a MyLocalSID table.
This table maps segments to operations to perform. For each ingress IPv6
packet whose DA is part of a given prefix, the segment endpoint looks
up the active segment (i.e., the IPv6 DA) in the MyLocalSID table and
applies the corresponding operation. Such specifications enable to specify
arbitrary operations besides the basic SRH processing and allow for a more
fine-grained classification.

This patch series implements those extended specifications by leveraging
a new type of lightweight tunnel, seg6local. The MyLocalSID table is
simply an arbitrary routing table (using CONFIG_IPV6_MULTIPLE_TABLES). The
following commands would assign the prefix fc00::/64 to the MyLocalSID
table, map the segment fc00::42 to the regular SRH processing function
(named "End"), and drop all packets received with an undefined active
segment:

ip -6 rule add fc00::/64 lookup 100
ip -6 route add fc00::42 encap seg6local action End dev eth0 table 100
ip -6 route add blackhole default table 100

As another example, the following command would assign the segment
fc00::1234 to the regular SRH processing function, except that the
processed packet must be forwarded to the next-hop fc42::1 (this operation
is named "End.X"):

ip -6 route add fc00::1234 encap seg6local action End.X nh6 fc42::1 dev eth0 table 100

Those two basic operations (End and End.X) are defined in [1]. A more
extensive list of advanced operations is defined in [2].

The first two patches of the series are preliminary work that remove an
assumption about initial SRH format, and export the two functions used to
insert and encapsulate an SRH onto packets. The third patch defines the
new seg6local lightweight tunnel and implement the core functions. The
fourth patch implements the operations needed to handle the newly defined
rtnetlink attributes. The fifth patch implements a few SRH processing
operations, including End and End.X.

[1] https://tools.ietf.org/html/draft-ietf-6man-segment-routing-header-07
[2] https://tools.ietf.org/html/draft-filsfils-spring-srv6-network-programming-01

David Lebrun (5):
  ipv6: sr: allow SRH insertion with arbitrary segments_left value
  ipv6: sr: export SRH insertion functions
  ipv6: sr: define core operations for seg6local lightweight tunnel
  ipv6: sr: add rtnetlink functions for seg6local action parameters
  ipv6: sr: implement several seg6local actions

 include/linux/seg6_local.h      |   6 +
 include/net/seg6.h              |   4 +
 include/uapi/linux/lwtunnel.h   |   1 +
 include/uapi/linux/seg6_local.h |  68 ++++
 net/core/lwtunnel.c             |   2 +
 net/ipv6/Kconfig                |  15 +-
 net/ipv6/Makefile               |   2 +-
 net/ipv6/exthdrs.c              |   4 +-
 net/ipv6/seg6.c                 |   7 +-
 net/ipv6/seg6_iptunnel.c        |  12 +-
 net/ipv6/seg6_local.c           | 766 ++++++++++++++++++++++++++++++++++++++++
 11 files changed, 862 insertions(+), 25 deletions(-)
 create mode 100644 include/linux/seg6_local.h
 create mode 100644 include/uapi/linux/seg6_local.h
 create mode 100644 net/ipv6/seg6_local.c

-- 
2.10.2
