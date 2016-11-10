From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/14] Netfilter fixes for net
Date: Thu, 10 Nov 2016 01:23:33 +0100
Message-ID: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37722 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754126AbcKJAYD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:03 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 01E3596200
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E1A76DA807
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:00 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4384ADA7E0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:23:56 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains a larger than usual batch of Netfilter
fixes for your net tree. This series contains a mixture of old bugs and
recently introduced bugs, they are:

1) Fix a crash when using nft_dynset with nft_set_rbtree, which doesn't
   support the set element updates from the packet path. From Liping
   Zhang.

2) Fix leak when nft_expr_clone() fails, from Liping Zhang.

3) Fix a race when inserting new elements to the set hash from the
   packet path, also from Liping.

4) Handle segmented TCP SIP packets properly, basically avoid that the
   INVITE in the allow header create bogus expectations by performing
   stricter SIP message parsing, from Ulrich Weber.

5) nft_parse_u32_check() should return signed integer for errors, from
   John Linville.

6) Fix wrong allocation instead of connlabels, allocate 16 instead of
   32 bytes, from Florian Westphal.

7) Fix compilation breakage when building the ip_vs_sync code with
   CONFIG_OPTIMIZE_INLINING on x86, from Arnd Bergmann.

8) Destroy the new set if the transaction object cannot be allocated,
   also from Liping Zhang.

9) Use device to route duplicated packets via nft_dup only when set by
   the user, otherwise packets may not follow the right route, again
   from Liping.

10) Fix wrong maximum genetlink attribute definition in IPVS, from
    WANG Cong.

11) Ignore untracked conntrack objects from xt_connmark, from Florian
    Westphal.

12) Allow to use conntrack helpers that are registered NFPROTO_UNSPEC
    via CT target, otherwise we cannot use the h.245 helper, from
    Florian.

13) Revisit garbage collection heuristic in the new workqueue-based
    timer approach for conntrack to evict objects earlier, again from
    Florian.

14) Fix crash in nf_tables when inserting an element into a verdict map,
    from Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 67f0160fe34ec5391a428603b9832c9f99d8f3a1:

  MAINTAINERS: Update qlogic networking drivers (2016-10-26 23:29:12 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 58c78e104d937c1f560fb10ed9bb2dcde0db4fcf:

  netfilter: nf_tables: fix oops when inserting an element into a verdict map (2016-11-08 23:53:39 +0100)

----------------------------------------------------------------
Arnd Bergmann (1):
      netfilter: ip_vs_sync: fix bogus maybe-uninitialized warning

Florian Westphal (4):
      netfilter: conntrack: avoid excess memory allocation
      netfilter: connmark: ignore skbs with magic untracked conntrack objects
      netfilter: conntrack: fix CT target for UNSPEC helpers
      netfilter: conntrack: refine gc worker heuristics

John W. Linville (1):
      netfilter: nf_tables: fix type mismatch with error return from nft_parse_u32_check

Liping Zhang (6):
      netfilter: nft_dynset: fix panic if NFT_SET_HASH is not enabled
      netfilter: nf_tables: fix *leak* when expr clone fail
      netfilter: nf_tables: fix race when create new element in dynset
      netfilter: nf_tables: destroy the set if fail to add transaction
      netfilter: nft_dup: do not use sreg_dev if the user doesn't specify it
      netfilter: nf_tables: fix oops when inserting an element into a verdict map

Ulrich Weber (1):
      netfilter: nf_conntrack_sip: extend request line validation

WANG Cong (1):
      ipvs: use IPVS_CMD_ATTR_MAX for family.maxattr

 include/net/netfilter/nf_conntrack_labels.h |  3 +-
 include/net/netfilter/nf_tables.h           |  8 +++--
 net/ipv4/netfilter/nft_dup_ipv4.c           |  6 ++--
 net/ipv6/netfilter/nft_dup_ipv6.c           |  6 ++--
 net/netfilter/ipvs/ip_vs_ctl.c              |  2 +-
 net/netfilter/ipvs/ip_vs_sync.c             |  7 +++--
 net/netfilter/nf_conntrack_core.c           | 49 ++++++++++++++++++++++++-----
 net/netfilter/nf_conntrack_helper.c         | 11 +++++--
 net/netfilter/nf_conntrack_sip.c            |  5 ++-
 net/netfilter/nf_tables_api.c               | 18 ++++++-----
 net/netfilter/nft_dynset.c                  | 19 +++++++----
 net/netfilter/nft_set_hash.c                | 19 ++++++++---
 net/netfilter/nft_set_rbtree.c              |  2 +-
 net/netfilter/xt_connmark.c                 |  4 +--
 14 files changed, 114 insertions(+), 45 deletions(-)
