From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 00/12] add namespace support for netfilter protos
Date: Tue, 17 Apr 2012 10:56:11 +0800
Message-ID: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:44696 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755313Ab2DQDfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 23:35:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the sysctl of netfilter proto is not isolated, so when 
changing proto's sysctl in container will cause the host's sysctl 
be changed too. it's not expected.

This patch set adds the namespace support for netfilter protos.

impletement four pernet_operations to register sysctl,and disable 
register sysctl when protos are registered.

nf_conntrack_net_proto_ipv4_ops is used to register tcp4(compat),
udp4(compat),icmp(compat),ipv4(compat).
nf_conntrack_net_proto_ipv6_ops is used to register tcp6,udp6 and 
icmpv6.
nf_conntrack_net_proto_sctp_ops is used to register sctp4(compat) 
and sctp6.
nf_conntrack_net_proto_udplite_ops is used to register udplite4
and udplite6

these operations will be registered when module be loaded.

And this will break the cttimeout, because timeout_nlattr_to_obj
function use the orig timeout(such as tcp_timeouts) to set timeouts.

I will fix this in my next patch.

Gao feng (12):
  netfilter: add struct netns_ct_proto to support netfilter namespace
  netfilter: don't register sysctl when register proto
  netfilter: generic proto sysctl support for net namespace
  netfilter: tcp proto sysctl support for net namespace
  netfilter: udp proto sysctl support for net namespace
  netfilter: icmp proto sysctl support for net namespace
  netfilter: icmpv6 proto sysctl support for net
  netfilter: ipv4 sysctl support for net namespace
  netfilter: ipv6 sysctl support for net namespace
  netfilter: sctp proto sysctl support for net namespace
  netfilter: udplite proto sysctl support for net
  netfilter: export necessary function for generic proto

 include/linux/netfilter/nf_conntrack_udp.h     |   10 +
 include/linux/netfilter/nf_conntrack_udplite.h |   10 +
 include/net/netfilter/nf_conntrack_core.h      |    3 +
 include/net/netfilter/nf_conntrack_l3proto.h   |    6 -
 include/net/netfilter/nf_conntrack_l4proto.h   |   38 +++-
 include/net/netns/conntrack.h                  |   37 ++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   96 ++++++++-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  116 +++++++++-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   48 ++++
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   54 ++++-
 net/netfilter/nf_conntrack_core.c              |    6 +
 net/netfilter/nf_conntrack_proto.c             |  109 ++--------
 net/netfilter/nf_conntrack_proto_generic.c     |   93 ++++++++-
 net/netfilter/nf_conntrack_proto_sctp.c        |  205 +++++++++++++++---
 net/netfilter/nf_conntrack_proto_tcp.c         |  275 ++++++++++++++++++++----
 net/netfilter/nf_conntrack_proto_udp.c         |  160 ++++++++++++--
 net/netfilter/nf_conntrack_proto_udplite.c     |   83 ++++++--
 17 files changed, 1096 insertions(+), 253 deletions(-)
 create mode 100644 include/linux/netfilter/nf_conntrack_udp.h
 create mode 100644 include/linux/netfilter/nf_conntrack_udplite.h

-- 
1.7.7.6
