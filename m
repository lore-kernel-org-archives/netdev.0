From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/14] Netfilter fixes for net
Date: Thu, 26 Jan 2017 17:37:53 +0100
Message-ID: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48246 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752702AbdAZQjU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 11:39:20 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 79BB0764A
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6C56B18FDBF
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1A044A7DB4
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:17 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains a large batch with Netfilter fixes for
your net tree, they are:

1) Two patches to solve conntrack garbage collector cpu hogging, one to
   remove GC_MAX_EVICTS and another to look at the ratio (scanned entries
   vs. evicted entries) to make a decision on whether to reduce or not
   the scanning interval. From Florian Westphal.

2) Two patches to fix incorrect set element counting if NLM_F_EXCL is
   is not set. Moreover, don't decrenent set->nelems from abort patch
   if -ENFILE which leaks a spare slot in the set. This includes a
   patch to deconstify the set walk callback to update set->ndeact.

3) Two fixes for the fwmark_reflect sysctl feature: Propagate mark to
   reply packets both from nf_reject and local stack, from Pau Espin Pedrol.

4) Fix incorrect handling of loopback traffic in rpfilter and nf_tables
   fib expression, from Liping Zhang.

5) Fix oops on stateful objects netlink dump, when no filter is specified.
   Also from Liping Zhang.

6) Fix a build error if proc is not available in ipt_CLUSTERIP, related
   to fix that was applied in the previous batch for net. From Arnd Bergmann.

7) Fix lack of string validation in table, chain, set and stateful
   object names in nf_tables, from Liping Zhang. Moreover, restrict
   maximum log prefix length to 127 bytes, otherwise explicitly bail
   out.

8) Two patches to fix spelling and typos in nf_tables uapi header file
   and Kconfig, patches from Alexander Alemayhu and William Breathitt Gray.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks a lot!

----------------------------------------------------------------

The following changes since commit 03430fa10b99e95e3a15eb7c00978fb1652f3b24:

  Merge branch 'bcm_sf2-fixes' (2017-01-08 22:01:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to b2c11e4b9536ebab6b39929e1fe15f57039ab445:

  netfilter: nf_tables: bump set->ndeact on set flush (2017-01-24 21:46:59 +0100)

----------------------------------------------------------------
Alexander Alemayhu (1):
      netfilter: nf_tables: fix spelling mistakes

Arnd Bergmann (1):
      netfilter: ipt_CLUSTERIP: fix build error without procfs

Florian Westphal (2):
      netfilter: conntrack: remove GC_MAX_EVICTS break
      netfilter: conntrack: refine gc worker heuristics, redux

Liping Zhang (4):
      netfilter: rpfilter: fix incorrect loopback packet judgment
      netfilter: nf_tables: fix possible oops when dumping stateful objects
      netfilter: nf_tables: validate the name size when possible
      netfilter: nft_log: restrict the log prefix length to 127

Pablo Neira Ayuso (3):
      netfilter: nf_tables: fix set->nelems counting with no NLM_F_EXCL
      netfilter: nf_tables: deconstify walk callback function
      netfilter: nf_tables: bump set->ndeact on set flush

Pau Espin Pedrol (2):
      netfilter: use fwmark_reflect in nf_send_reset
      tcp: fix mark propagation with fwmark_reflect enabled

William Breathitt Gray (1):
      netfilter: Fix typo in NF_CONNTRACK Kconfig option description

 include/net/netfilter/nf_tables.h        |  6 +--
 include/net/netfilter/nft_fib.h          |  6 +++
 include/uapi/linux/netfilter/nf_log.h    |  2 +
 include/uapi/linux/netfilter/nf_tables.h |  4 +-
 net/ipv4/ip_output.c                     |  1 +
 net/ipv4/netfilter/ipt_CLUSTERIP.c       |  7 +++-
 net/ipv4/netfilter/ipt_rpfilter.c        |  8 ++--
 net/ipv4/netfilter/nf_reject_ipv4.c      |  2 +
 net/ipv4/netfilter/nft_fib_ipv4.c        | 15 +++----
 net/ipv6/netfilter/ip6t_rpfilter.c       |  8 ++--
 net/ipv6/netfilter/nf_reject_ipv6.c      |  3 ++
 net/ipv6/netfilter/nft_fib_ipv6.c        | 13 ++-----
 net/ipv6/tcp_ipv6.c                      |  1 +
 net/netfilter/Kconfig                    |  2 +-
 net/netfilter/nf_conntrack_core.c        | 44 ++++++++++-----------
 net/netfilter/nf_log.c                   |  1 -
 net/netfilter/nf_tables_api.c            | 67 +++++++++++++++++++-------------
 net/netfilter/nft_dynset.c               |  3 +-
 net/netfilter/nft_log.c                  |  3 +-
 net/netfilter/nft_lookup.c               |  3 +-
 net/netfilter/nft_objref.c               |  6 ++-
 net/netfilter/nft_set_hash.c             |  2 +-
 net/netfilter/nft_set_rbtree.c           |  2 +-
 23 files changed, 116 insertions(+), 93 deletions(-)
