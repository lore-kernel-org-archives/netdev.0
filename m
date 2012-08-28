From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/19] netfilter: IPv6 NAT
Date: Tue, 28 Aug 2012 23:48:40 +0200
Message-ID: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59142 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397Ab2H1VtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 17:49:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches contain the latest version of IPv6 NAT rebased on
top of nf-next.git. Since the last posting an issue with IPVS and the
IPv6 fragmentation improvements have been fixed by Jesper, as well as
some minor cosmetic changes done myself. I consider these patches ready
for merging now.

Please pull from:

git://github.com/kaber/nf-next-ipv6-nat.git master

Thanks.


Jesper Dangaard Brouer (1):
      Cleaning up the IPv6 MTU checking in the IPVS xmit code, by using     a common helper function __mtu_check_toobig_v6().

Pablo Neira Ayuso (2):
      netfilter: nf_nat: support IPv6 in IRC NAT helper
      netfilter: nf_nat: support IPv6 in TFTP NAT helper

Patrick McHardy (16):
      ipv4: fix path MTU discovery with connection tracking
      netfilter: nf_conntrack_ipv6: improve fragmentation handling
      netfilter: nf_conntrack_ipv6: fix tracking of ICMPv6 error messages containing fragments
      netfilter: nf_conntrack: restrict NAT helper invocation to IPv4
      netfilter: nf_nat: add protoff argument to packet mangling functions
      netfilter: add protocol independent NAT core
      netfilter: ipv6: expand skb head in ip6_route_me_harder after oif change
      net: core: add function for incremental IPv6 pseudo header checksum updates
      netfilter: ipv6: add IPv6 NAT support
      netfilter: ip6tables: add MASQUERADE target
      netfilter: ip6tables: add REDIRECT target
      netfilter: ip6tables: add NETMAP target
      netfilter: nf_nat: support IPv6 in FTP NAT helper
      netfilter: nf_nat: support IPv6 in amanda NAT helper
      netfilter: nf_nat: support IPv6 in SIP NAT helper
      netfilter: ip6tables: add stateless IPv6-to-IPv6 Network Prefix Translation target

 include/linux/ipv6.h                               |    1 +
 include/linux/netfilter.h                          |   14 +-
 include/linux/netfilter/nf_conntrack_amanda.h      |    1 +
 include/linux/netfilter/nf_conntrack_ftp.h         |    1 +
 include/linux/netfilter/nf_conntrack_h323.h        |   15 +-
 include/linux/netfilter/nf_conntrack_irc.h         |    1 +
 include/linux/netfilter/nf_conntrack_pptp.h        |    2 +
 include/linux/netfilter/nf_conntrack_sip.h         |   21 +-
 include/linux/netfilter/nf_nat.h                   |    8 +
 include/linux/netfilter/nfnetlink_conntrack.h      |    8 +-
 include/linux/netfilter_ipv4.h                     |    1 -
 include/linux/netfilter_ipv6/Kbuild                |    1 +
 include/linux/netfilter_ipv6/ip6t_NPT.h            |   16 +
 include/net/addrconf.h                             |    2 +-
 include/net/checksum.h                             |    3 +
 include/net/inet_frag.h                            |    2 +
 include/net/ip.h                                   |    2 +
 include/net/netfilter/nf_conntrack_expect.h        |    2 +-
 include/net/netfilter/nf_nat.h                     |    6 +-
 include/net/netfilter/nf_nat_core.h                |    5 +-
 include/net/netfilter/nf_nat_helper.h              |   11 +-
 include/net/netfilter/nf_nat_l3proto.h             |   52 ++
 include/net/netfilter/nf_nat_l4proto.h             |   72 +++
 include/net/netfilter/nf_nat_protocol.h            |   67 --
 include/net/netfilter/nf_nat_rule.h                |   15 -
 include/net/netns/conntrack.h                      |    4 +
 include/net/netns/ipv4.h                           |    2 -
 include/net/netns/ipv6.h                           |    1 +
 net/core/secure_seq.c                              |    1 +
 net/core/utils.c                                   |   20 +
 net/ipv4/ip_fragment.c                             |    8 +-
 net/ipv4/ip_output.c                               |    4 +-
 net/ipv4/netfilter.c                               |   37 --
 net/ipv4/netfilter/Kconfig                         |   69 +--
 net/ipv4/netfilter/Makefile                        |   16 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   18 +-
 net/ipv4/netfilter/ipt_NETMAP.c                    |   15 +-
 net/ipv4/netfilter/ipt_REDIRECT.c                  |   15 +-
 .../{nf_nat_standalone.c => iptable_nat.c}         |  264 ++++----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    8 +-
 net/ipv4/netfilter/nf_nat_h323.c                   |   71 ++-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |  281 ++++++++
 net/ipv4/netfilter/nf_nat_pptp.c                   |   21 +-
 net/ipv4/netfilter/nf_nat_proto_gre.c              |   30 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c             |   24 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |  214 -------
 net/ipv6/addrconf.c                                |    2 +-
 net/ipv6/ip6_output.c                              |    7 +-
 net/ipv6/netfilter.c                               |    8 +
 net/ipv6/netfilter/Kconfig                         |   54 ++
 net/ipv6/netfilter/Makefile                        |    8 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c               |  135 ++++
 net/ipv6/netfilter/ip6t_NETMAP.c                   |   94 +++
 net/ipv6/netfilter/ip6t_NPT.c                      |  165 +++++
 net/ipv6/netfilter/ip6t_REDIRECT.c                 |   98 +++
 net/ipv6/netfilter/ip6table_nat.c                  |  321 ++++++++++
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |  137 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c            |   19 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |  287 +++++++++
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c           |   90 +++
 net/netfilter/Kconfig                              |   49 ++
 net/netfilter/Makefile                             |   18 +
 net/netfilter/core.c                               |    5 +
 net/netfilter/ipvs/ip_vs_ftp.c                     |    1 +
 net/netfilter/ipvs/ip_vs_xmit.c                    |   28 +-
 net/netfilter/nf_conntrack_amanda.c                |    5 +-
 net/netfilter/nf_conntrack_core.c                  |    6 +
 net/netfilter/nf_conntrack_ftp.c                   |    3 +-
 net/netfilter/nf_conntrack_h323_main.c             |  232 +++++---
 net/netfilter/nf_conntrack_irc.c                   |    3 +-
 net/netfilter/nf_conntrack_netlink.c               |   35 +-
 net/netfilter/nf_conntrack_pptp.c                  |   18 +-
 net/netfilter/nf_conntrack_proto_tcp.c             |    8 +-
 net/netfilter/nf_conntrack_sip.c                   |  143 +++--
 net/{ipv4 => }/netfilter/nf_nat_amanda.c           |    4 +-
 net/{ipv4 => }/netfilter/nf_nat_core.c             |  675 +++++++++++---------
 net/{ipv4 => }/netfilter/nf_nat_ftp.c              |   34 +-
 net/{ipv4 => }/netfilter/nf_nat_helper.c           |  109 ++--
 net/{ipv4 => }/netfilter/nf_nat_irc.c              |   10 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_common.c     |   54 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_dccp.c       |   56 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_sctp.c       |   53 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_tcp.c        |   40 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udp.c        |   42 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udplite.c    |   58 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_unknown.c    |   16 +-
 net/{ipv4 => }/netfilter/nf_nat_sip.c              |  270 +++++----
 net/{ipv4 => }/netfilter/nf_nat_tftp.c             |    1 -
 net/netfilter/xt_nat.c                             |  170 +++++
 89 files changed, 3461 insertions(+), 1562 deletions(-)
