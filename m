From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 00/15] netfilter: add namespace support for netfilter proto
Date: Tue, 29 May 2012 15:04:08 +0800
Message-ID: <1338275063-11711-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:18604 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab2E2Hh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 03:37:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the sysctl of netfilter proto is not isolated, so when
changing proto's sysctl in container will cause the host's sysctl
be changed too. it's not expected.

This patch set adds the namespace support for netfilter protos.

impletement four pernet_operations to register sysctl and initial
pernet data for proto.

-ipv4_net_ops is used to register tcp4(compat),
 udp4(compat),icmp(compat),ipv4(compat).
-ipv6_net_ops is used to register tcp6,udp6 and icmpv6.
-sctp_net_ops is used to register sctp4(compat) and sctp6.
-udplite_net_ops is used to register udplite4 and udplite6

extern l[3,4]proto (sysctl) register functions to make them support
namespace.

finailly add namespace support for cttimeout.

Changes from v3:
	delete l4proto.compat field, use l4proto.l3proto and init_net
	to identify if this l4proto need do compat.

	re-split patchset,make the structure go together with the code uses it
	fix some code style problem.
	
	add functions nf_conntrack_l[3,4]proto_(un)register_net to make
	code more clearer.
	
	delete unrequired export of couple of symbols	.

	change nf_conntrack_proto_init to register nf_conntrack_proto_generic,
	and delete nf_conntrack_proto_generic_init,fini.

	add functions *_kmemdup_(compat_)sysctl_table to make code more clearer.

Changes from v2:
	re-split patchset to make compilation success.

Gao feng (15):
  netfilter: add namespace support for l4proto
  netfilter: add namespace support for l3proto
  netfilter: add namespace support for l4proto_generic
  netfilter: add namespace support for l4proto_tcp
  netfilter: add namespace support for l4proto_udp
  netfilter: add namespace support for l4proto_icmp
  netfilter: add namespace support for l4proto_icmpv6
  netfilter: add namespace support for l3proto_ipv4
  netfilter: add namespace support for l3proto_ipv6
  netfilter: add namespace support for l4proto_sctp
  netfilter: add namespace support for l4proto_udplite
  netfilter: adjust l4proto_dccp to the nf_conntrack_l4proto_register
  netfilter: adjust l4proto_gre4 to the nf_conntrack_l4proto_register
  netfilter: cleanup sysctl for l4proto and l3proto
  netfilter: add namespace support for cttimeout

 include/net/netfilter/nf_conntrack_core.h      |    4 +-
 include/net/netfilter/nf_conntrack_l3proto.h   |   11 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |   22 +-
 include/net/netns/conntrack.h                  |   55 +++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  123 ++++++++----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   52 ++++--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   88 +++++---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   36 +++-
 net/netfilter/nf_conntrack_core.c              |   17 +-
 net/netfilter/nf_conntrack_proto.c             |  272 +++++++++++++++++-------
 net/netfilter/nf_conntrack_proto_dccp.c        |  138 ++++++------
 net/netfilter/nf_conntrack_proto_generic.c     |   52 ++++--
 net/netfilter/nf_conntrack_proto_gre.c         |   64 ++++--
 net/netfilter/nf_conntrack_proto_sctp.c        |  195 +++++++++++++----
 net/netfilter/nf_conntrack_proto_tcp.c         |  181 ++++++++++++----
 net/netfilter/nf_conntrack_proto_udp.c         |  123 ++++++++---
 net/netfilter/nf_conntrack_proto_udplite.c     |  121 ++++++++---
 net/netfilter/nfnetlink_cttimeout.c            |   13 +-
 18 files changed, 1112 insertions(+), 455 deletions(-)

-- 
1.7.7.6
