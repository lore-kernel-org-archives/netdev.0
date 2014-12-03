From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter updates for net-next
Date: Wed,  3 Dec 2014 13:55:30 +0100
Message-ID: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following batch contains netfilter updates for net-next. Basically,
enhancements for xt_recent, skip zeroing of timer in conntrack, fix
linking problem with recent redirect support for nf_tables, ipset
updates and a couple of cleanups. More specifically, they are:

1) Rise maximum number per IP address to be remembered in xt_recent
   while retaining backward compatibility, from Florian Westphal.

2) Skip zeroing timer area in nf_conn objects, also from Florian.

3) Inspect IPv4 and IPv6 traffic from the bridge to allow filtering using
   using meta l4proto and transport layer header, from Alvaro Neira.

4) Fix linking problems in the new redirect support when CONFIG_IPV6=n
   and IP6_NF_IPTABLES=n.

And ipset updates from Jozsef Kadlecsik:

5) Support updating element extensions when the set is full (fixes
   netfilter bugzilla id 880).

6) Fix set match with 32-bits userspace / 64-bits kernel.

7) Indicate explicitly when /0 networks are supported in ipset.

8) Simplify cidr handling for hash:*net* types.

9) Allocate the proper size of memory when /0 networks are supported.

10) Explicitly add padding elements to hash:net,net and hash:net,port,
    because the elements must be u32 sized for the used hash function.

Jozsef is also cooking ipset RCU conversion which should land soon if
they reach the merge window in time.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 3a611e26e958b0372d2e7600b87bbb4a84c7704b:

  net/smsc911x: Add minimal runtime PM support (2014-11-24 16:41:50 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to cac3763967362ace7996532ad3933f493a928a1b:

  netfilter: ipset: Explicitly add padding elements to hash:net, net and hash:net, port, net (2014-12-03 12:43:36 +0100)

----------------------------------------------------------------
Alvaro Neira (2):
      netfilter: nf_tables_bridge: export nft_reject_ip*hdr_validate functions
      netfilter: nf_tables_bridge: set the pktinfo for IPv4/IPv6 traffic

Florian Westphal (2):
      netfilter: xt_recent: relax ip_pkt_list_tot restrictions
      netfilter: conntrack: avoid zeroing timer

Jozsef Kadlecsik (6):
      netfilter: ipset: Support updating extensions when the set is full
      netfilter: ipset: Alignment problem between 64bit kernel 32bit userspace
      netfilter: ipset: Indicate when /0 networks are supported
      netfilter: ipset: Simplify cidr handling for hash:*net* types
      netfilter: ipset: Allocate the proper size of memory when /0 networks are supported
      netfilter: ipset: Explicitly add padding elements to hash:net, net and hash:net, port, net

Pablo Neira Ayuso (1):
      netfilter: combine IPv4 and IPv6 nf_nat_redirect code in one module

Steven Noonan (1):
      netfilter: nf_log_ipv6: correct typo in module description

 include/net/netfilter/ipv4/nf_nat_redirect.h       |    9 --
 include/net/netfilter/ipv6/nf_nat_redirect.h       |    8 --
 include/net/netfilter/nf_conntrack.h               |   15 +--
 include/net/netfilter/nf_nat_redirect.h            |   12 +++
 include/net/netfilter/nf_tables_bridge.h           |    7 ++
 include/uapi/linux/netfilter/ipset/ip_set.h        |    8 +-
 include/uapi/linux/netfilter/xt_set.h              |   13 ++-
 net/bridge/netfilter/nf_tables_bridge.c            |   88 ++++++++++++++++-
 net/bridge/netfilter/nft_reject_bridge.c           |   52 +---------
 net/ipv4/netfilter/Kconfig                         |    8 +-
 net/ipv4/netfilter/Makefile                        |    1 -
 net/ipv4/netfilter/nft_redir_ipv4.c                |    2 +-
 net/ipv6/netfilter/Kconfig                         |    8 +-
 net/ipv6/netfilter/Makefile                        |    1 -
 net/ipv6/netfilter/nf_log_ipv6.c                   |    2 +-
 net/ipv6/netfilter/nf_nat_redirect_ipv6.c          |   75 ---------------
 net/ipv6/netfilter/nft_redir_ipv6.c                |    2 +-
 net/netfilter/Kconfig                              |   10 +-
 net/netfilter/Makefile                             |    1 +
 net/netfilter/ipset/ip_set_hash_gen.h              |  101 +++++++++-----------
 net/netfilter/ipset/ip_set_hash_netiface.c         |    1 +
 net/netfilter/ipset/ip_set_hash_netnet.c           |    2 +
 net/netfilter/ipset/ip_set_hash_netportnet.c       |    2 +
 net/netfilter/nf_conntrack_core.c                  |   11 +--
 .../nf_nat_redirect.c}                             |   47 ++++++++-
 net/netfilter/xt_REDIRECT.c                        |    3 +-
 net/netfilter/xt_recent.c                          |   64 +++++++++----
 net/netfilter/xt_set.c                             |   73 +++++++++++++-
 28 files changed, 372 insertions(+), 254 deletions(-)
 delete mode 100644 include/net/netfilter/ipv4/nf_nat_redirect.h
 delete mode 100644 include/net/netfilter/ipv6/nf_nat_redirect.h
 create mode 100644 include/net/netfilter/nf_nat_redirect.h
 create mode 100644 include/net/netfilter/nf_tables_bridge.h
 delete mode 100644 net/ipv6/netfilter/nf_nat_redirect_ipv6.c
 rename net/{ipv4/netfilter/nf_nat_redirect_ipv4.c => netfilter/nf_nat_redirect.c} (67%)
