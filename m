From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/10] Netfilter fixes for net
Date: Wed, 15 Mar 2017 18:01:02 +0100
Message-ID: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37608 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752578AbdCORBm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 13:01:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 146511324D0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 01C1ADA86D
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2DD72DA878
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:16 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree, a
rather large batch of fixes targeted to nf_tables, conntrack and bridge
netfilter. More specifically, they are:

1) Don't track fragmented packets if the socket option IP_NODEFRAG is set.
   From Florian Westphal.

2) SCTP protocol tracker assumes that ICMP error messages contain the
   checksum field, what results in packet drops. From Ying Xue.

3) Fix inconsistent handling of AH traffic from nf_tables.

4) Fix new bitmap set representation with big endian. Fix mismatches in
   nf_tables due to incorrect big endian handling too. Both patches
   from Liping Zhang.

5) Bridge netfilter doesn't honor maximum fragment size field, cap to
   largest fragment seen. From Florian Westphal.

6) Fake conntrack entry needs to be aligned to 8 bytes since the 3 LSB
   bits are now used to store the ctinfo. From Steven Rostedt.

7) Fix element comments with the bitmap set type. Revert the flush
   field in the nft_set_iter structure, not required anymore after
   fixing up element comments.

8) Missing error on invalid conntrack direction from nft_ct, also from
   Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 8d70eeb84ab277377c017af6a21d0a337025dede:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-03-04 17:31:39 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 4494dbc6dec37817f2cc2aa7604039a9e87ada18:

  netfilter: nft_ct: do cleanup work when NFTA_CT_DIRECTION is invalid (2017-03-15 17:15:54 +0100)

----------------------------------------------------------------
Florian Westphal (2):
      netfilter: don't track fragmented packets
      netfilter: bridge: honor frag_max_size when refragmenting

Liping Zhang (3):
      netfilter: nft_set_bitmap: fetch the element key based on the set->klen
      netfilter: nf_tables: fix mismatch in big-endian system
      netfilter: nft_ct: do cleanup work when NFTA_CT_DIRECTION is invalid

Pablo Neira Ayuso (3):
      netfilter: nf_tables: set pktinfo->thoff at AH header if found
      netfilter: nft_set_bitmap: keep a list of dummy elements
      Revert "netfilter: nf_tables: add flush field to struct nft_set_iter"

Steven Rostedt (VMware) (1):
      netfilter: Force fake conntrack entry to be at least 8 bytes aligned

Ying Xue (1):
      netfilter: nf_nat_sctp: fix ICMP packet to be dropped accidently

 include/net/netfilter/nf_conntrack.h           |   2 +-
 include/net/netfilter/nf_tables.h              |  30 ++++-
 include/net/netfilter/nf_tables_ipv6.h         |   6 +-
 net/bridge/br_netfilter_hooks.c                |  12 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   4 +
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |   5 -
 net/ipv4/netfilter/nft_masq_ipv4.c             |   8 +-
 net/ipv4/netfilter/nft_redir_ipv4.c            |   8 +-
 net/ipv6/netfilter/nft_masq_ipv6.c             |   8 +-
 net/ipv6/netfilter/nft_redir_ipv6.c            |   8 +-
 net/netfilter/nf_conntrack_core.c              |   6 +-
 net/netfilter/nf_nat_proto_sctp.c              |  13 +-
 net/netfilter/nf_tables_api.c                  |   4 -
 net/netfilter/nft_ct.c                         |  21 ++--
 net/netfilter/nft_meta.c                       |  40 +++---
 net/netfilter/nft_nat.c                        |   8 +-
 net/netfilter/nft_set_bitmap.c                 | 165 ++++++++++++-------------
 17 files changed, 194 insertions(+), 154 deletions(-)
