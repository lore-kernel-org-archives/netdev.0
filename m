From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v4 0/4] net: Identifier Locator Addressing - Part I
Date: Mon, 17 Aug 2015 13:42:23 -0700
Message-ID: <1439844147-1286627-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58555 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034AbbHQV4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:56:20 -0400
Received: from pps.filterd (m0042983 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7HLr7TV006559
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:56:19 -0700
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-00082601.pphosted.com with ESMTP id 1w92w2rbxp-43
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:56:19 -0700
Received: from pps.reinject (m0042983 [127.0.0.1])
	by pps.reinject (8.14.5/8.14.5) with SMTP id t7HLeCve012925
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:40:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wbp78r6cy-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 13:42:40 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 7ef2d0bc452011e5b5b70002c9931860-1abf32b0 for <netdev@vger.kernel.org>;	Mon,
 17 Aug 2015 13:42:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set provides rudimentary support for Identifier Locator
Addressing or ILA. The basic concept of ILA is that we split an IPv6
address into a 64 bit locator and 64 bit identifier. The identifier is
the identity of an entity in communication ("who"), and the locator
expresses the location of the entity ("where"). Applications
use externally visible address that contains the identifier.
When a packet is actually sent, a translation is done that
overwrites the first 64 bits of the address with a locator.
The packet can then be forwarded over the network to the host where
the addressed entity is located. At the receiver, the reverse
translation is done so the that the application sees the original,
untranslated address. Presumably an external control plane will
provide identifier->locator mappings.

v2:
  - Fix compilation erros when LWT not configured
  - Consolidate ILA into a single ila.c

v3:
  - Change pseudohdr argument od inet_proto_csum_replace functions to
    be a bool

v4:
  - In ila_build_state check locator being in netlink params before
    allocating tunnel state

The data path for ILA is a simple NAT translation that only operates
on the upper 64 bits of a destination address in IPv6 packets. The
basic process is:

   1) Lookup 64 bit identifier (lower 64 bits of destination)
   2) If a match is found
      a) Overwrite locator (upper 64 bits of destination) with
         the new locator
      b) Adjust any checksum that has destination address included in
         pseudo header
   3) Send or receive packet

ILA is a means to implement tunnels or network virtualization without
encapsulation. Since there is no encapsulation involved, we assume that
stateless support in the network for IPv6 (e.g. RSS, ECMP, TSO, etc.)
just works. Also, since we're minimally changing the packet many of
the worries about encapsulation (MTU, checksum, fragmentation) are
not relevant. The downside is that, ILA is not extensible like other
encapsulations (GUE for instance) so it might not be appropriate for
all use cases. Also, this only makes sense to do in IPv6!

A key aspect of ILA is performance. The intent is that ILA would be
used in data centers in virtualizing tasks or jobs. In the fullest
incarnation all intra data center communications might be targeted to
virtual ILA addresses. This is basically adding a new virtualization
capability to the existing services in a datacenter, so there is a
strong expectation is that this does not degrade performance for
existing applications.

Performance seems to be dependent on how ILA is hooked into kernel.
ILA can be implemented under some different models:

  - Mechanically it is a form a stateless DNAT
  - It can be thought of as a type of (source) routing
  - As a functional replacement of encapsulation

In this patch set we hook into the data path using Light Weight
Tunnels (LWT) infrastructure. As part of that, we add support in LWT
to redirect dst input. iproute will be modified to take a new ila encap
type. ILA can be configured like:

# ILA to destination
ip route add 3333:0:0:1:5555:0:2:0/128 \
   encap ila 2001:0:0:2 via 2401:db00:20:911a:face:0:27:0

# Configure local address
ip -6 addr add 3333:0:0:1:5555:0:1:0/128 dev eth0

# ILA translation for local address on input
ip route add table local local 2001:0:0:1:5555:0:1:0/128
   encap ila 3333:0:0:1 dev lo

So sending to destination 3333:0:0:1:5555:0:2:0 will have destination
of 2001:0:0:2:5555:0:2:0 on the wire.

Performance results are below. With ILA we see about a 10% drop in
pps compared to non-ILA. Much of this drop can be attributed to the
loss of early demux on input (translation occurs after it is attempted).
We will address this in the next patch set. Also, IPvlan input path
does not work with ILA since the routing is bypassed-- this will
be addressed in a future patch.

Performance testing:

Performing netperf TCP_RR with 200 clients:

Non-ILA baseline
  84.92% CPU utilization
  1861922.9 tps
  93/163/330 50/90/99% latencies

ILA single destination
  83.16% CPU utilization
  1679683.4 tps				
  105/180/332 50/90/99% latencies

References:

Slides from netconf:
http://vger.kernel.org/netconf2015Herbert-ILA.pdf

Slides from presentation at IETF:
https://www.ietf.org/proceedings/92/slides/slides-92-nvo3-1.pdf

I-D:
https://tools.ietf.org/html/draft-herbert-nvo3-ila-00

Tom Herbert (4):
  lwt: Add support to redirect dst.input
  net: Change pseudohdr argument of inet_proto_csum_replace* to be a
    bool
  net: Add inet_proto_csum_replace_by_diff utility function
  net: Identifier Locator Addressing module

 include/net/checksum.h                   |   8 +-
 include/net/lwtunnel.h                   |  30 ++++-
 include/uapi/linux/ila.h                 |  15 +++
 include/uapi/linux/lwtunnel.h            |   1 +
 net/core/filter.c                        |   2 +-
 net/core/lwtunnel.c                      |  55 ++++++++
 net/core/utils.c                         |  17 ++-
 net/ipv4/netfilter/ipt_ECN.c             |   2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c |   4 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c   |   2 +-
 net/ipv4/route.c                         |   8 +-
 net/ipv6/Kconfig                         |  19 +++
 net/ipv6/Makefile                        |   1 +
 net/ipv6/ila.c                           | 216 +++++++++++++++++++++++++++++++
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c |   4 +-
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c |   2 +-
 net/ipv6/route.c                         |   8 +-
 net/netfilter/nf_conntrack_seqadj.c      |   9 +-
 net/netfilter/nf_nat_proto_dccp.c        |   2 +-
 net/netfilter/nf_nat_proto_tcp.c         |   2 +-
 net/netfilter/nf_nat_proto_udp.c         |   2 +-
 net/netfilter/nf_nat_proto_udplite.c     |   2 +-
 net/netfilter/nf_synproxy_core.c         |   2 +-
 net/netfilter/xt_TCPMSS.c                |   8 +-
 net/netfilter/xt_TCPOPTSTRIP.c           |   2 +-
 net/openvswitch/actions.c                |  12 +-
 net/sched/act_nat.c                      |   7 +-
 27 files changed, 403 insertions(+), 39 deletions(-)
 create mode 100644 include/uapi/linux/ila.h
 create mode 100644 net/ipv6/ila.c

-- 
1.8.1
