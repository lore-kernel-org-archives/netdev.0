From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next 0/6] net: Identifier Locator Addressing
Date: Wed, 3 Jun 2015 12:58:16 -0700
Message-ID: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <agartrell@fb.com>, <maheshb@google.com>,
	<tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56417 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754182AbbFCT6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:58:40 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t53Jwd0K021926
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2015 12:58:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ut80jg0md-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:58:39 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 ec7483fa0a2a11e59d570002c9521c9e-a55d5280 for <netdev@vger.kernel.org>;	Wed,
 03 Jun 2015 12:58:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set provides rudimentary support for Identifier Locator
Addresssing or ILA. The basic concept of ILA is that we split and IPv6
in to a 64 bit locator and 64 bit identifier. The identifier is the
identity of an entity in communication ("who") and the locator
expresses a the location of the entity ("where"). Applications
use externally visible address that contains the identifier.
When a packet is actually sent, a translation is done that
overwrites the first 64 bits of the address with a locator.
The packet can the be forwarded over the network to the host where
the addressed entity is located. At the receiver, the reverse
transation is done so the that the application sees the original,
untranslated address. Presumably an external control plane will
provide identfier->locator mapping.

The data path for ILA is a simple NAT translation that only operates
on the upper 64 bits of a destination address in IPv6 packets. The
basic process is:

   1) Lookup 64 bit identifier (lower 64 bits of destination) in a table
   2) If a match is found
      a) Overwrite locator (upper 64 bits of destination) with
         new locator
      b) Adjust any checksum that has destination address included in
         pseudo header
   3) Send or receive packet

ILA is a means to implement tunnels or network virtualization without
encapsulation. Since there is no encapsulation involved, we assume that
statelss support in the network for IPv6 (e.g. RSS, ECMP, TSO, etc.)
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
strong expectation is that this does not degrade performance
for applications.

Performance seems to be dependent on how ILA is hooked into kernel.
This patch set includes IPtables, hacked up IPvlan, and a "special
route" that calls directly into ILA module from where PRE and
POST routing NF_HOOKs are. The best of these performance-wise
is the special hook which seems to be ~2-3% loss of performance
compared to native non-ILA. The other two are ~5% loss. My hope is
to get a solution with <1% performance loss.

Performance testing:

Performing netperf TCP_RR with 200 clients:

Non-ILA baselin
  83.95% CPU utilization
  1729209.7 99.3 178.6 363.9

Special route
  84.63% CPU utilization
  1685847.2 tps				-2.5%
  102/182/367 50/90/99% latencies

IPVL hook
  84.78% CPU utilization
  1638595.9				-5.5%
  106/187/374 50/90/99% latencies

IPtables
  85.10% CPU utilization
  1634015.5 tps				-5.8%
  105/188/380 50/90/99% latencies

References:

Slides from netfconf:
http://vger.kernel.org/netconf2015Herbert-ILA.pdf

Slides from presentation at IETF:
https://www.ietf.org/proceedings/92/slides/slides-92-nvo3-1.pdf

I-D:
https://tools.ietf.org/html/draft-herbert-nvo3-ila-00

Also, ILA is very much liek ILNP data plane.


Tom Herbert (6):
  net: Checksum functions to replace 8 bytes at a time
  net: Identfier Locator Addressing module
  net: Special routing hook
  net: ILA use special route hook
  net: ILA iptables target
  ipvlan: Call ILA in incoming and outgoing receive paths

 drivers/net/ipvlan/ipvlan.h      |   1 +
 drivers/net/ipvlan/ipvlan_core.c |  27 ++-
 drivers/net/ipvlan/ipvlan_main.c |   4 +
 include/net/checksum.h           |   3 +
 include/net/ila.h                |   7 +
 include/net/ip6_route.h          |  22 ++
 net/core/utils.c                 |  19 ++
 net/ipv6/Kconfig                 |   8 +
 net/ipv6/Makefile                |   1 +
 net/ipv6/ila.c                   | 509 +++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_input.c             |   3 +
 net/ipv6/ip6_output.c            |  24 +-
 net/ipv6/route.c                 |  51 ++++
 net/ipv6/xfrm6_input.c           |   4 +
 net/netfilter/Kconfig            |  11 +
 net/netfilter/Makefile           |   1 +
 net/netfilter/xt_ILA.c           |  82 +++++++
 17 files changed, 767 insertions(+), 10 deletions(-)
 create mode 100644 include/net/ila.h
 create mode 100644 net/ipv6/ila.c
 create mode 100644 net/netfilter/xt_ILA.c

-- 
1.8.1
