From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/9] Netfilter/IPVS fixes for net
Date: Fri,  8 Sep 2017 19:45:39 +0200
Message-ID: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54454 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756614AbdIHRp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 13:45:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 3A1918D0505
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 291C3B5026
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:27 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter/IPVS fixes for your net tree,
they are:

1) Fix SCTP connection setup when IPVS module is loaded and any scheduler
   is registered, from Xin Long.

2) Don't create a SCTP connection from SCTP ABORT packets, also from
   Xin Long.

3) WARN_ON() and drop packet, instead of BUG_ON() races when calling
   nf_nat_setup_info(). This is specifically a longstanding problem
   when br_netfilter with conntrack support is in place, patch from
   Florian Westphal.

4) Avoid softlock splats via iptables-restore, also from Florian.

5) Revert NAT hashtable conversion to rhashtable, semantics of rhlist
   are different from our simple NAT hashtable, this has been causing
   problems in the recent Linux kernel releases. From Florian.

6) Add per-bucket spinlock for NAT hashtable, so at least we restore
   one of the benefits we got from the previous rhashtable conversion.

7) Fix incorrect hashtable size in memory allocation in xt_hashlimit,
   from Zhizhou Tian.

8) Fix build/link problems with hashlimit and 32-bit arches, to address
   recent fallout from a new hashlimit mode, from Vishwanath Pai.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 8e0deed92406d93ae0365cb8a6134db5721e7aca:

  tipc: remove unnecessary call to dev_net() (2017-09-06 21:25:52 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 90c4ae4e2c1da9f1eaf846136861af43d4c1ff34:

  netfilter: xt_hashlimit: fix build error caused by 64bit division (2017-09-08 18:55:53 +0200)

----------------------------------------------------------------
Florian Westphal (5):
      netfilter: nf_nat: don't bug when mapping already exists
      netfilter: xtables: add scheduling opportunity in get_counters
      netfilter: nat: Revert "netfilter: nat: convert nat bysrc hash to rhashtable"
      netfilter: nat: use keyed locks
      netfilter: core: remove erroneous warn_on

Vishwanath Pai (1):
      netfilter: xt_hashlimit: fix build error caused by 64bit division

Xin Long (2):
      netfilter: ipvs: fix the issue that sctp_conn_schedule drops non-INIT packet
      netfilter: ipvs: do not create conn for ABORT packet in sctp_conn_schedule

Zhizhou Tian (1):
      netfilter: xt_hashlimit: alloc hashtable with right size

 include/net/netfilter/nf_conntrack.h  |   3 +-
 include/net/netfilter/nf_nat.h        |   1 -
 net/ipv4/netfilter/arp_tables.c       |   1 +
 net/ipv4/netfilter/ip_tables.c        |   1 +
 net/ipv6/netfilter/ip6_tables.c       |   1 +
 net/netfilter/core.c                  |   2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   8 +-
 net/netfilter/nf_nat_core.c           | 146 ++++++++++++++++------------------
 net/netfilter/xt_hashlimit.c          |  16 ++--
 9 files changed, 88 insertions(+), 91 deletions(-)
