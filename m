From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/26] Netfilter updates for net-next
Date: Wed,  6 Jul 2016 16:23:42 +0200
Message-ID: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for net-next,
they are:

1) Don't use userspace datatypes in bridge netfilter code, from
   Tobin Harding.

2) Iterate only once over the expectation table when removing the
   helper module, instead of once per-netns, from Florian Westphal.

3) Extra sanitization in xt_hook_ops_alloc() to return error in case
   we ever pass zero hooks, xt_hook_ops_alloc():

4) Handle NFPROTO_INET from the logging core infrastructure, from
   Liping Zhang.

5) Autoload loggers when TRACE target is used from rules, this doesn't
   change the behaviour in case the user already selected nfnetlink_log
   as preferred way to print tracing logs, also from Liping Zhang.

6) Conntrack slabs with SLAB_HWCACHE_ALIGN to allow rearranging fields
   by cache lines, increases the size of entries in 11% per entry.
   From Florian Westphal.

7) Skip zone comparison if CONFIG_NF_CONNTRACK_ZONES=n, from Florian.

8) Remove useless defensive check in nf_logger_find_get() from Shivani
   Bhardwaj.

9) Remove zone extension as place it in the conntrack object, this is
   always include in the hashing and we expect more intensive use of
   zones since containers are in place. Also from Florian Westphal.

10) Owner match now works from any namespace, from Eric Bierdeman.

11) Make sure we only reply with TCP reset to TCP traffic from
    nf_reject_ipv4, patch from Liping Zhang.

12) Introduce --nflog-size to indicate amount of network packet bytes
    that are copied to userspace via log message, from Vishwanath Pai.
    This obsoletes --nflog-range that has never worked, it was designed
    to achieve this but it has never worked.

13) Introduce generic macros for nf_tables object generation masks.

14) Use generation mask in table, chain and set objects in nf_tables.
    This allows fixes interferences with ongoing preparation phase of
    the commit protocol and object listings going on at the same time.
    This update is introduced in three patches, one per object.

15) Check if the object is active in the next generation for element
    deactivation in the rbtree implementation, given that deactivation
    happens from the commit phase path we have to observe the future
    status of the object.

16) Support for deletion of just added elements in the hash set type.

17) Allow to resize hashtable from /proc entry, not only from the
    obscure /sys entry that maps to the module parameter, from Florian
    Westphal.

18) Get rid of NFT_BASECHAIN_DISABLED, this code is not exercised
    anymore since we tear down the ruleset whenever the netdevice
    goes away.

19) Support for matching inverted set lookups, from Arturo Borrero.

20) Simplify the iptables_mangle_hook() by removing a superfluous
    extra branch.

21) Introduce ether_addr_equal_masked() and use it from the netfilter
    codebase, from Joe Perches.

22) Remove references to "Use netfilter MARK value as routing key"
    from the Netfilter Kconfig description given that this toggle
    doesn't exists already for 10 years, from Moritz Sichert.

23) Introduce generic NF_INVF() and use it from the xtables codebase,
    from Joe Perches.

24) Setting logger to NONE via /proc was not working unless explicit
    nul-termination was included in the string. This fixes seems to
    leave the former behaviour there, so we don't break backward.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 2fb7ea455d57e22110c54fc2de0656b6f744263c:

  Merge branch 'vrf-local' (2016-06-06 15:19:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to c6ac37d8d8843fb1fdc34e4a2a41a4f027ab670c:

  netfilter: nf_log: fix error on write NONE to logger choice sysctl (2016-07-05 14:57:57 +0200)

----------------------------------------------------------------
Arturo Borrero (1):
      netfilter: nf_tables: add support for inverted logic in nft_lookup

Eric W. Biederman (1):
      netfilter: Allow xt_owner in any user namespace

Florian Westphal (5):
      netfilter: helper: avoid extra expectation iterations on unregister
      netfilter: conntrack: align nf_conn on cacheline boundary
      netfilter: make comparision helpers stub functions in ZONES=n case
      netfilter: move zone info into struct nf_conn
      netfilter: conntrack: allow increasing bucket size via sysctl too

Joe Perches (2):
      etherdevice.h & bridge: netfilter: Add and use ether_addr_equal_masked
      netfilter: Convert FWINV<[foo]> macros and uses to NF_INVF

Liping Zhang (3):
      netfilter: nf_log: handle NFPROTO_INET properly in nf_logger_[find_get|put]
      netfilter: xt_TRACE: add explicitly nf_logger_find_get call
      netfilter: nf_reject_ipv4: don't send tcp RST if the packet is non-TCP

Moritz Sichert (1):
      netfilter: Remove references to obsolete CONFIG_IP_ROUTE_FWMARK

Pablo Neira Ayuso (8):
      netfilter: nf_tables: add generic macros to check for generation mask
      netfilter: nf_tables: add generation mask to tables
      netfilter: nf_tables: add generation mask to chains
      netfilter: nf_tables: add generation mask to sets
      netfilter: nft_rbtree: check for next generation when deactivating elements
      netfilter: nft_hash: support deletion of inactive elements
      netfilter: nf_tables: get rid of NFT_BASECHAIN_DISABLED
      netfilter: x_tables: simplify ip{6}table_mangle_hook()

Pavel Tikhomirov (1):
      netfilter: nf_log: fix error on write NONE to logger choice sysctl

Shivani Bhardwaj (1):
      netfilter: nf_log: Remove NULL check

Tobin C Harding (1):
      bridge: netfilter: checkpatch data type fixes

Vishwanath Pai (1):
      netfilter: xt_NFLOG: nflog-range does not truncate packets

Xiubo Li (1):
      netfilter: x_tables: fix possible ZERO_SIZE_PTR pointer dereferencing error.

 Documentation/networking/nf_conntrack-sysctl.txt |   3 +-
 include/linux/etherdevice.h                      |  23 ++
 include/linux/netfilter/x_tables.h               |   4 +
 include/linux/netfilter_bridge/ebtables.h        |   2 -
 include/net/netfilter/nf_conntrack.h             |   4 +
 include/net/netfilter/nf_conntrack_extend.h      |   4 -
 include/net/netfilter/nf_conntrack_zones.h       |  45 +--
 include/net/netfilter/nf_log.h                   |   7 +
 include/net/netfilter/nf_tables.h                |  43 ++-
 include/uapi/linux/netfilter/nf_tables.h         |   6 +
 include/uapi/linux/netfilter/xt_NFLOG.h          |   6 +-
 net/bridge/netfilter/ebt_802_3.c                 |   6 +-
 net/bridge/netfilter/ebt_arp.c                   |  43 ++-
 net/bridge/netfilter/ebt_ip.c                    |  28 +-
 net/bridge/netfilter/ebt_ip6.c                   |  41 +--
 net/bridge/netfilter/ebt_stp.c                   |  97 +++---
 net/bridge/netfilter/ebtables.c                  |  32 +-
 net/ipv4/netfilter/arp_tables.c                  |  41 ++-
 net/ipv4/netfilter/ip_tables.c                   |  20 +-
 net/ipv4/netfilter/iptable_mangle.c              |   4 -
 net/ipv4/netfilter/nf_reject_ipv4.c              |   3 +
 net/ipv6/netfilter/ip6_tables.c                  |  16 +-
 net/ipv6/netfilter/ip6table_mangle.c             |   4 -
 net/netfilter/Kconfig                            |  10 +-
 net/netfilter/nf_conntrack_core.c                |  76 ++---
 net/netfilter/nf_conntrack_helper.c              |  61 ++--
 net/netfilter/nf_conntrack_standalone.c          |  36 ++-
 net/netfilter/nf_log.c                           |  33 +-
 net/netfilter/nf_tables_api.c                    | 366 ++++++++++++-----------
 net/netfilter/nfnetlink_log.c                    |   9 +-
 net/netfilter/nft_dynset.c                       |   7 +-
 net/netfilter/nft_hash.c                         |   6 +-
 net/netfilter/nft_log.c                          |  21 +-
 net/netfilter/nft_lookup.c                       |  43 ++-
 net/netfilter/nft_rbtree.c                       |   2 +-
 net/netfilter/x_tables.c                         |   3 +
 net/netfilter/xt_NFLOG.c                         |   3 +
 net/netfilter/xt_TRACE.c                         |  25 +-
 net/netfilter/xt_owner.c                         |  41 ++-
 net/netfilter/xt_tcpudp.c                        |   7 +-
 40 files changed, 699 insertions(+), 532 deletions(-)
