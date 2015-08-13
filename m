From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/3] net: Identifier Locator Addressing - Part I
Date: Thu, 13 Aug 2015 09:54:00 -0700
Message-ID: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tgraf@suug.ch>, <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:21966 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753944AbbHMQzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 12:55:18 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7DGt0MS006660
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:55:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1w8xuu02un-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:55:17 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 f7b8ee2a41db11e598780002c99293a0-33ff42b0 for <netdev@vger.kernel.org>;	Thu,
 13 Aug 2015 09:54:31 -0700
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

Tom Herbert (3):
  lwt: Add support to redirect dst.input
  net: Add inet_proto_csum_replace_by_diff utility function
  net: Identifier Locator Addressing module

 include/net/checksum.h        |   2 +
 include/net/lwtunnel.h        |  25 +++++++-
 include/uapi/linux/ila.h      |  15 +++++
 include/uapi/linux/lwtunnel.h |   1 +
 net/core/lwtunnel.c           |  55 +++++++++++++++++
 net/core/utils.c              |  13 +++++
 net/ipv4/route.c              |   8 ++-
 net/ipv6/Kconfig              |  18 ++++++
 net/ipv6/Makefile             |   1 +
 net/ipv6/ila/Makefile         |   7 +++
 net/ipv6/ila/ila.h            |  50 ++++++++++++++++
 net/ipv6/ila/ila_lwt.c        | 133 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ila/ila_main.c       |  69 ++++++++++++++++++++++
 net/ipv6/route.c              |   8 ++-
 14 files changed, 402 insertions(+), 3 deletions(-)
 create mode 100644 include/uapi/linux/ila.h
 create mode 100644 net/ipv6/ila/Makefile
 create mode 100644 net/ipv6/ila/ila.h
 create mode 100644 net/ipv6/ila/ila_lwt.c
 create mode 100644 net/ipv6/ila/ila_main.c

-- 
1.8.1
