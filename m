From: kaber@trash.net
Subject: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Thu, 24 Nov 2011 17:57:11 +0100
Message-ID: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches contain the updated IPv6 NAT patchset forward ported
to 3.2-rc3. Changes since last posting:

- Layer 4 protocol registration has been fixed to work properly with modular
  layer 4 protocol modules

- an inverted condition in the ip6t_NETMAP checkentry function causing
  rule addition to always fail has been fixed

- use of HH_DATA_ALIGN in IPv6 headroom reallocation after rerouting to fix
  unaligned data access on Tile, as suggested by Eric

- nla_policy fix has been moved to a separate patch

The patchset is also available at:

git://github.com/kaber/nf-nat-ipv6.git master

Last open point is IPv6 fragmentation handling, I'll implement my suggested
method of storing the biggest fragment size seen during reassembly in the CB
and using that as a hard limit during refragmentation over the weekend.


Patrick McHardy (18):
      netfilter: nf_nat: export NAT definitions to userspace
      netfilter: nf_nat: use hash random for bysource hash
      netfilter: nf_nat: add missing nla_policy entry for CTA_NAT_PROTO attribute
      netfilter: nat: remove module reference counting from NAT protocols
      netfilter: nf_nat: remove obsolete code from nf_nat_icmp_reply_translation()
      netfilter: nf_nat: remove obsolete check in nf_nat_mangle_udp_packet()
      netfilter: ctnetlink: remove dead NAT code
      netfilter: conntrack: restrict NAT helper invocation to IPv4
      netfilter: nf_nat: add protoff argument to packet mangling functions
      netfilter: add protocol independant NAT core
      netfilter: ipv6: expand skb head in ip6_route_me_harder after oif change
      net: core: add function for incremental IPv6 pseudo header checksum updates
      netfilter: ipv6: add IPv6 NAT support
      netfilter: ip6tables: add MASQUERADE target
      netfilter: ip6tables: add REDIRECT target
      netfilter: ip6tables: add NETMAP target
      netfilter: nf_nat: support IPv6 in FTP NAT helper
      netfilter: nf_nat: support IPv6 in amanda NAT helper

 include/linux/netfilter.h                          |   14 +-
 include/linux/netfilter/Kbuild                     |    1 +
 include/linux/netfilter/nf_conntrack_amanda.h      |    1 +
 include/linux/netfilter/nf_conntrack_ftp.h         |    1 +
 include/linux/netfilter/nf_conntrack_h323.h        |   15 +-
 include/linux/netfilter/nf_conntrack_irc.h         |    1 +
 include/linux/netfilter/nf_conntrack_pptp.h        |    2 +
 include/linux/netfilter/nf_conntrack_sip.h         |   12 +-
 .../linux/netfilter/nf_conntrack_tuple_common.h    |   27 +
 include/linux/netfilter/nf_nat.h                   |   33 +
 include/linux/netfilter/nfnetlink_conntrack.h      |    8 +-
 include/linux/netfilter_ipv4.h                     |    1 -
 include/linux/netfilter_ipv4/Kbuild                |    1 -
 include/linux/netfilter_ipv4/nf_nat.h              |   58 --
 include/net/addrconf.h                             |    2 +-
 include/net/checksum.h                             |    3 +
 include/net/netfilter/nf_conntrack_expect.h        |    2 +-
 include/net/netfilter/nf_conntrack_tuple.h         |    1 -
 include/net/netfilter/nf_nat.h                     |    8 +-
 include/net/netfilter/nf_nat_core.h                |    7 +-
 include/net/netfilter/nf_nat_helper.h              |   11 +-
 include/net/netfilter/nf_nat_l3proto.h             |   52 ++
 include/net/netfilter/nf_nat_l4proto.h             |   72 +++
 include/net/netfilter/nf_nat_protocol.h            |   74 ---
 include/net/netfilter/nf_nat_rule.h                |   15 -
 include/net/netns/conntrack.h                      |    4 +
 include/net/netns/ipv4.h                           |    2 -
 include/net/netns/ipv6.h                           |    1 +
 net/core/secure_seq.c                              |    1 +
 net/core/utils.c                                   |   20 +
 net/ipv4/netfilter.c                               |   37 --
 net/ipv4/netfilter/Kconfig                         |   67 +--
 net/ipv4/netfilter/Makefile                        |   13 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   26 +-
 net/ipv4/netfilter/ipt_NETMAP.c                    |   21 +-
 net/ipv4/netfilter/ipt_REDIRECT.c                  |   23 +-
 .../{nf_nat_standalone.c => iptable_nat.c}         |  266 ++++-----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    8 +-
 net/ipv4/netfilter/nf_nat_h323.c                   |   83 ++--
 net/ipv4/netfilter/nf_nat_irc.c                    |    4 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |  281 +++++++++
 net/ipv4/netfilter/nf_nat_pptp.c                   |   31 +-
 net/ipv4/netfilter/nf_nat_proto_common.c           |  126 ----
 net/ipv4/netfilter/nf_nat_proto_gre.c              |   36 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c             |   26 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |  214 -------
 net/ipv4/netfilter/nf_nat_sip.c                    |  121 ++--
 net/ipv4/netfilter/nf_nat_tftp.c                   |    1 -
 net/ipv6/addrconf.c                                |    2 +-
 net/ipv6/netfilter.c                               |    8 +
 net/ipv6/netfilter/Kconfig                         |   48 ++
 net/ipv6/netfilter/Makefile                        |    7 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c               |  135 +++++
 net/ipv6/netfilter/ip6t_NETMAP.c                   |   94 +++
 net/ipv6/netfilter/ip6t_REDIRECT.c                 |   98 +++
 net/ipv6/netfilter/ip6table_nat.c                  |  319 ++++++++++
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   14 +
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |  285 +++++++++
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c           |   87 +++
 net/netfilter/Kconfig                              |   34 ++
 net/netfilter/Makefile                             |   15 +
 net/netfilter/core.c                               |    5 +
 net/netfilter/ipvs/ip_vs_ftp.c                     |    1 +
 net/netfilter/nf_conntrack_amanda.c                |    5 +-
 net/netfilter/nf_conntrack_core.c                  |    7 +
 net/netfilter/nf_conntrack_ftp.c                   |    3 +-
 net/netfilter/nf_conntrack_h323_main.c             |  232 +++++---
 net/netfilter/nf_conntrack_irc.c                   |    6 +-
 net/netfilter/nf_conntrack_netlink.c               |   30 +-
 net/netfilter/nf_conntrack_pptp.c                  |   18 +-
 net/netfilter/nf_conntrack_proto_tcp.c             |    8 +-
 net/netfilter/nf_conntrack_sip.c                   |  119 +++--
 net/netfilter/nf_conntrack_tftp.c                  |    3 +-
 net/{ipv4 => }/netfilter/nf_nat_amanda.c           |    4 +-
 net/{ipv4 => }/netfilter/nf_nat_core.c             |  621 ++++++++++----------
 net/{ipv4 => }/netfilter/nf_nat_ftp.c              |   33 +-
 net/{ipv4 => }/netfilter/nf_nat_helper.c           |  121 ++---
 net/netfilter/nf_nat_proto_common.c                |  112 ++++
 net/{ipv4 => }/netfilter/nf_nat_proto_dccp.c       |   58 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_sctp.c       |   55 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_tcp.c        |   42 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udp.c        |   44 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udplite.c    |   60 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_unknown.c    |   15 +-
 net/netfilter/xt_nat.c                             |  185 ++++++
 85 files changed, 3132 insertions(+), 1635 deletions(-)

