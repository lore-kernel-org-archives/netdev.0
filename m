From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter updates for net-next
Date: Tue,  1 Nov 2016 22:26:21 +0100
Message-ID: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next
tree. This includes better integration with the routing subsystem for
nf_tables, explicit notrack support and smaller updates. More
specifically, they are:

1) Add fib lookup expression for nf_tables, from Florian Westphal. This
   new expression provides a native replacement for iptables addrtype
   and rp_filter matches. This is more flexible though, since we can
   populate the kernel flowi representation to inquire fib to
   accomodate new usecases, such as RTBH through skb mark.

2) Introduce rt expression for nf_tables, from Anders K. Pedersen. This
   new expression allow you to access skbuff route metadata, more
   specifically nexthop and classid fields.

3) Add notrack support for nf_tables, to skip conntracking, requested by
   many users already.

4) Add boilerplate code to allow to use nf_log infrastructure from
   nf_tables ingress.

5) Allow to mangle pkttype from nf_tables prerouting chain, to emulate
   the xtables cluster match, from Liping Zhang.

6) Move socket lookup code into generic nf_socket_* infrastructure so
   we can provide a native replacement for the xtables socket match.

7) Make sure nfnetlink_queue data that is updated on every packets is
   placed in a different cache from read-only data, from Florian Westphal.

8) Handle NF_STOLEN from nf_tables core, also from Florian Westphal.

9) Start round robin number generation in nft_numgen from zero,
   instead of n-1, for consistency with xtables statistics match,
   patch from Liping Zhang.

10) Set GFP_NOWARN flag in skbuff netlink allocations in nfnetlink_log,
    given we retry with a smaller allocation on failure, from Calvin Owens.

11) Cleanup xt_multiport to use switch(), from Gao feng.

12) Remove superfluous check in nft_immediate and nft_cmp, from
    Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 432490f9d455fb842d70219f22d9d2c812371676:

  net: ip, diag -- Add diag interface for raw sockets (2016-10-23 19:35:24 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 886bc50348fd69972baa4616ce95b7dc9ff8afe7:

  netfilter: nf_queue: place volatile data in own cacheline (2016-11-01 20:50:33 +0100)

----------------------------------------------------------------
Anders K. Pedersen (1):
      netfilter: nf_tables: introduce routing expression

Calvin Owens (1):
      netfilter: nfnetlink_log: Use GFP_NOWARN for skb allocation

Florian Westphal (3):
      netfilter: nf_tables: allow expressions to return STOLEN
      netfilter: nf_tables: add fib expression
      netfilter: nf_queue: place volatile data in own cacheline

Gao Feng (1):
      netfilter: xt_multiport: Use switch case instead of multiple condition checks

Liping Zhang (3):
      netfilter: nft_numgen: start round robin from zero
      netfilter: nft_meta: permit pkttype mangling in ip/ip6 prerouting
      netfilter: nf_tables: remove useless U8_MAX validation

Pablo Neira Ayuso (3):
      netfilter: nft_ct: add notrack support
      netfilter: nf_log: add packet logging for netdev family
      netfilter: move socket lookup infrastructure to nf_socket_ipv{4,6}.c

 include/net/netfilter/nf_log.h           |   5 +
 include/net/netfilter/nf_socket.h        |  27 +++
 include/net/netfilter/nft_fib.h          |  31 ++++
 include/uapi/linux/netfilter/nf_tables.h |  63 +++++++
 net/bridge/netfilter/Kconfig             |   1 +
 net/bridge/netfilter/nf_log_bridge.c     |  16 +-
 net/ipv4/netfilter/Kconfig               |  14 ++
 net/ipv4/netfilter/Makefile              |   3 +
 net/ipv4/netfilter/nf_socket_ipv4.c      | 163 +++++++++++++++++
 net/ipv4/netfilter/nft_fib_ipv4.c        | 238 ++++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig               |  14 ++
 net/ipv6/netfilter/Makefile              |   3 +
 net/ipv6/netfilter/nf_socket_ipv6.c      | 151 +++++++++++++++
 net/ipv6/netfilter/nft_fib_ipv6.c        | 275 ++++++++++++++++++++++++++++
 net/netfilter/Kconfig                    |  26 ++-
 net/netfilter/Makefile                   |   6 +
 net/netfilter/nf_log_common.c            |  27 +++
 net/netfilter/nf_log_netdev.c            |  80 ++++++++
 net/netfilter/nf_tables_core.c           |   1 +
 net/netfilter/nfnetlink_log.c            |   2 +-
 net/netfilter/nfnetlink_queue.c          |   2 +-
 net/netfilter/nft_cmp.c                  |   3 -
 net/netfilter/nft_ct.c                   |  50 ++++-
 net/netfilter/nft_fib.c                  | 159 ++++++++++++++++
 net/netfilter/nft_fib_inet.c             |  82 +++++++++
 net/netfilter/nft_immediate.c            |   3 -
 net/netfilter/nft_meta.c                 |   5 +
 net/netfilter/nft_numgen.c               |   2 +-
 net/netfilter/nft_rt.c                   | 153 ++++++++++++++++
 net/netfilter/xt_multiport.c             |  40 ++--
 net/netfilter/xt_socket.c                | 305 +------------------------------
 31 files changed, 1610 insertions(+), 340 deletions(-)
 create mode 100644 include/net/netfilter/nf_socket.h
 create mode 100644 include/net/netfilter/nft_fib.h
 create mode 100644 net/ipv4/netfilter/nf_socket_ipv4.c
 create mode 100644 net/ipv4/netfilter/nft_fib_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_socket_ipv6.c
 create mode 100644 net/ipv6/netfilter/nft_fib_ipv6.c
 create mode 100644 net/netfilter/nf_log_netdev.c
 create mode 100644 net/netfilter/nft_fib.c
 create mode 100644 net/netfilter/nft_fib_inet.c
 create mode 100644 net/netfilter/nft_rt.c
