From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter updates for next-net (part 2)
Date: Mon,  4 Sep 2017 22:11:02 +0200
Message-ID: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42118 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754005AbdIDULX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 16:11:23 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 105E3532F88
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 22:10:55 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 02B78B502E
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 22:10:55 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for net-next. This
patchset includes updates for nf_tables, removal of
CONFIG_NETFILTER_DEBUG and a new mode for xt_hashlimit. More
specifically, they:

1) Add new rate match mode for hashlimit, this introduces a new revision
   for this match. The idea is to stop matching packets until ratelimit
   criteria stands true. Patch from Vishwanath Pai.

2) Add ->select_ops indirection to nf_tables named objects, so we can
   choose between different flavours of the same object type, patch from
   Pablo M. Bermudo.

3) Shorter function names in nft_limit, basically:
   s/nft_limit_pkt_bytes/nft_limit_bytes, also from Pablo M. Bermudo.

4) Add new stateful limit named object type, this allows us to create
   limit policies that you can identify via name, also from Pablo.

5) Remove unused hooknum parameter in conntrack ->packet indirection.
   From Florian Westphal.

6) Patches to remove CONFIG_NETFILTER_DEBUG and macros such as
   IP_NF_ASSERT and IP_NF_ASSERT. From Varsha Rao.

7) Add nf_tables_updchain() helper function and use it from
   nf_tables_newchain() to make it more maintainable. Similarly,
   add nf_tables_addchain() and use it too.

8) Add new netlink NLM_F_NONREC flag, this flag should only be used for
   deletion requests, specifically, to support non-recursive deletion.
   Based on what we discussed during NFWS'17 in Faro.

9) Use NLM_F_NONREC from table and sets in nf_tables.

10) Support for recursive chain deletion. Table and set deletion
    commands come with an implicit content flush on deletion, while
    chains do not. This patch addresses this inconsistency by adding
    the code to perform recursive chain deletions. This also comes with
    the bits to deal with the new NLM_F_NONREC netlink flag.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks a lot!

----------------------------------------------------------------

The following changes since commit 3cf2e08f5ace79d57c8edba06deb59b25bd1dd33:

  Merge branch 'nfp-refactor-app-init-and-minor-flower-fixes' (2017-09-03 21:22:05 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 9dee1474121550b20542321f9e0579801c6b587c:

  netfilter: nf_tables: support for recursive chain deletion (2017-09-04 17:34:55 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: remove unused hooknum arg from packet functions

Pablo M. Bermudo Garay (3):
      netfilter: nf_tables: add select_ops for stateful objects
      netfilter: nft_limit: replace pkt_bytes with bytes
      netfilter: nft_limit: add stateful object type

Pablo Neira Ayuso (5):
      netfilter: nf_tables: add nf_tables_updchain()
      netfilter: nf_tables: add nf_tables_addchain()
      netlink: add NLM_F_NONREC flag for deletion requests
      netfilter: nf_tables: use NLM_F_NONREC for deletion requests
      netfilter: nf_tables: support for recursive chain deletion

Varsha Rao (2):
      net: Replace NF_CT_ASSERT() with WARN_ON().
      net: Remove CONFIG_NETFILTER_DEBUG and _ASSERT() macros.

Vishwanath Pai (1):
      netfilter: xt_hashlimit: add rate match mode

 arch/parisc/configs/c3000_defconfig            |   1 -
 arch/sh/configs/se7751_defconfig               |   1 -
 include/linux/netfilter/xt_hashlimit.h         |   3 +-
 include/net/netfilter/nf_conntrack.h           |   8 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |   1 -
 include/net/netfilter/nf_tables.h              |  35 ++-
 include/uapi/linux/netfilter/nf_tables.h       |   3 +-
 include/uapi/linux/netfilter/xt_hashlimit.h    |  36 ++-
 include/uapi/linux/netlink.h                   |   3 +
 net/Kconfig                                    |   7 -
 net/bridge/netfilter/ebtables.c                |  20 +-
 net/ipv4/netfilter/ip_tables.c                 |  12 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   3 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |   6 +-
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c    |   8 +-
 net/ipv6/netfilter/ip6_tables.c                |  12 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   8 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |   6 +-
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c    |   4 +-
 net/netfilter/nf_conntrack_core.c              |  13 +-
 net/netfilter/nf_conntrack_expect.c            |   4 +-
 net/netfilter/nf_conntrack_extend.c            |   2 +-
 net/netfilter/nf_conntrack_proto_dccp.c        |   2 +-
 net/netfilter/nf_conntrack_proto_generic.c     |   1 -
 net/netfilter/nf_conntrack_proto_gre.c         |   1 -
 net/netfilter/nf_conntrack_proto_sctp.c        |   1 -
 net/netfilter/nf_conntrack_proto_tcp.c         |   1 -
 net/netfilter/nf_conntrack_proto_udp.c         |   1 -
 net/netfilter/nf_conntrack_standalone.c        |   6 +-
 net/netfilter/nf_nat_core.c                    |   4 +-
 net/netfilter/nf_nat_redirect.c                |   6 +-
 net/netfilter/nf_tables_api.c                  | 403 ++++++++++++++-----------
 net/netfilter/nft_counter.c                    |  20 +-
 net/netfilter/nft_ct.c                         |  18 +-
 net/netfilter/nft_limit.c                      | 148 ++++++++-
 net/netfilter/nft_objref.c                     |   7 +-
 net/netfilter/nft_quota.c                      |  20 +-
 net/netfilter/xt_NETMAP.c                      |   8 +-
 net/netfilter/xt_hashlimit.c                   | 277 +++++++++++++++--
 net/netfilter/xt_nat.c                         |  20 +-
 40 files changed, 788 insertions(+), 352 deletions(-)
