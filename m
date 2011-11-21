From: kaber@trash.net
Subject: [RFC PATCH 00/17] netfilter: IPv6 NAT
Date: Mon, 21 Nov 2011 06:45:52 +0100
Message-ID: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61042 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab1KUFqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:46:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches contain an implementation of IPv6 NAT for netfilter.
During the last netfilter workshop it was agreed that there are legitimate
use cases for IPv6 NAT and since vendors are going to (and already have)
implement it anyways, its better to have one well tested implementation
everyone can use than having everyone implement it on his own.

The implementation remodels the existing IPv4-only code to provide a layer
3 independant NAT core with layer 3 specific modules for IPv4 and IPv6.
The SNAT/DNAT targets are changed to support IPv6, additionally IPv6
specific versions of the MASQUERADE/REDIRECT/NETMAP targets are included.

For testing purposes the FTP and amanda NAT helpers have been converted
to support IPv6, the SIP helper has also been converted but is not yet
included in this patchset since it still needs a bit more work.

There are two remaining open issues in this patchset:

- IPv6 fragment handling. Currently IPv6 conntrack reassembles the original
  packet from all its fragments, passes the reassembled packet though
  conntrack, associates all individual fragments with the conntrack entry
  of the reassembled packet and drops the reassembled packet. Conntrack
  helpers only see the individual fragments. For NAT helpers to operate
  properly, they need to receive the entire reassembled packet from
  conntrack helpers. In order to be able to mangle the payload, we also
  can't drop the reassembled packet but need to send it out, potentially
  refragmenting it previously.

  In order to not break PMTUD as done in IPv4 conntrack/NAT, the best
  choice seems to be to store the biggest fragment size seen during
  reassembly in the CB of the reassembled packet and use that as a hard
  limit during reassembly. As mentioned before, this is currently not done,
  any other suggestions are welcome.

- NAT protocol registration needs to be reworked slightly, currently
  modular built protocols don't work properly ATM.

The patchset is based on 3.1 and contains three parts:

- minor cleanups and improvements not directly related to IPv6 NAT
- preparatory patches for IPv6 NAT
- NAT core, IPv6 NAT, new IPv6 NAT targets and NAT helpers

I'll forward port it to the current kernel during the week and post an
updated patchset. I'll also try to split up the patches a bit more since
especially the main patch (add protocol independant NAT core) is quite
large. Userspace patches also still need to be split up, patches will
follow shortly.

Comments welcome.


Patrick McHardy (17):
      netfilter: nf_nat: use hash random for bysource hash
      netfilter: nat: remove module reference counting from NAT protocols
      netfilter: nf_nat: export NAT definitions to userspace
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
 include/net/addrconf.h                             |    2 +-
 include/net/checksum.h                             |    3 +
 include/net/netfilter/nf_conntrack_expect.h        |    2 +-
 include/net/netfilter/nf_conntrack_tuple.h         |   26 -
 include/net/netfilter/nf_nat.h                     |   32 +-
 include/net/netfilter/nf_nat_core.h                |    7 +-
 include/net/netfilter/nf_nat_helper.h              |   11 +-
 include/net/netfilter/nf_nat_l3proto.h             |   52 ++
 include/net/netfilter/nf_nat_l4proto.h             |   73 +++
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
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   23 +-
 net/ipv4/netfilter/ipt_NETMAP.c                    |   21 +-
 net/ipv4/netfilter/ipt_REDIRECT.c                  |   23 +-
 .../{nf_nat_standalone.c => iptable_nat.c}         |  265 ++++-----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    8 +-
 net/ipv4/netfilter/nf_nat_h323.c                   |   83 ++--
 net/ipv4/netfilter/nf_nat_irc.c                    |    4 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |  281 +++++++++
 net/ipv4/netfilter/nf_nat_pptp.c                   |   31 +-
 net/ipv4/netfilter/nf_nat_proto_common.c           |  125 ----
 net/ipv4/netfilter/nf_nat_proto_gre.c              |   37 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c             |   27 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |  214 -------
 net/ipv4/netfilter/nf_nat_sip.c                    |  121 +++--
 net/ipv4/netfilter/nf_nat_tftp.c                   |    1 -
 net/ipv6/addrconf.c                                |    2 +-
 net/ipv6/netfilter.c                               |    7 +
 net/ipv6/netfilter/Kconfig                         |   48 ++
 net/ipv6/netfilter/Makefile                        |    7 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c               |  133 +++++
 net/ipv6/netfilter/ip6t_NETMAP.c                   |   94 +++
 net/ipv6/netfilter/ip6t_REDIRECT.c                 |   98 +++
 net/ipv6/netfilter/ip6table_nat.c                  |  318 ++++++++++
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   14 +
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |  285 +++++++++
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c           |   88 +++
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
 net/{ipv4 => }/netfilter/nf_nat_core.c             |  617 ++++++++++----------
 net/{ipv4 => }/netfilter/nf_nat_ftp.c              |   33 +-
 net/{ipv4 => }/netfilter/nf_nat_helper.c           |  121 ++---
 net/netfilter/nf_nat_proto_common.c                |  111 ++++
 net/{ipv4 => }/netfilter/nf_nat_proto_dccp.c       |   43 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_sctp.c       |   41 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_tcp.c        |   42 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udp.c        |   44 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udplite.c    |   46 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_unknown.c    |   15 +-
 net/netfilter/xt_nat.c                             |  185 ++++++
 83 files changed, 3081 insertions(+), 1623 deletions(-)
