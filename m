From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter/IPVS fixes for net
Date: Fri, 19 May 2017 10:33:41 +0200
Message-ID: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43908 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751828AbdESIeR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 04:34:17 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7FEB21DA08B
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 67FFE10078C
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B66C4FF6FB
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:05 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter/IPVS fixes for your net tree,
they are:

1) When using IPVS in direct-routing mode, normal traffic from the LVS
   host to a back-end server is sometimes incorrectly NATed on the way
   back into the LVS host. Patch to fix this from Julian Anastasov.

2) Calm down clang compilation warning in ctnetlink due to type
   mismatch, from Matthias Kaehlcke.

3) Do not re-setup NAT for conntracks that are already confirmed, this
   is fixing a problem that was introduced in the previous nf-next batch.
   Patch from Liping Zhang.

4) Do not allow conntrack helper removal from userspace cthelper
   infrastructure if already in used. This comes with an initial patch
   to introduce nf_conntrack_helper_put() that is required by this fix.
   From Liping Zhang.

5) Zero the pad when copying data to userspace, otherwise iptables fails
   to remove rules. This is a follow up on the patchset that sorts out
   the internal match/target structure pointer leak to userspace. Patch
   from the same author, Willem de Bruijn. This also comes with a build
   failure when CONFIG_COMPAT is not on, coming in the last patch of
   this series.

6) SYNPROXY crashes with conntrack entries that are created via
   ctnetlink, more specifically via conntrackd state sync. Patch from
   Eric Leblond.

7) RCU safe iteration on set element dumping in nf_tables, from
   Liping Zhang.

8) Missing sanitization of immediate date for the bitwise and cmp
   expressions in nf_tables.

9) Refcounting logic for chain and objects from set elements does not
   integrate into the nf_tables 2-phase commit protocol.

10) Missing sanitization of target verdict in ebtables arpreply target,
    from Gao Feng.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 1c4d5f51a812a82de97beee24f48ed05c65ebda5:

  vmxnet3: ensure that adapter is in proper state during force_close (2017-05-12 12:23:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 751a9c763849f5859cb69ea44b0430d00672f637:

  netfilter: xtables: fix build failure from COMPAT_XT_ALIGN outside CONFIG_COMPAT (2017-05-18 13:10:03 +0200)

----------------------------------------------------------------
Eric Leblond (1):
      netfilter: synproxy: fix conntrackd interaction

Gao Feng (1):
      ebtables: arpreply: Add the standard target sanity check

Julian Anastasov (1):
      ipvs: SNAT packet replies only for NATed connections

Liping Zhang (4):
      netfilter: don't setup nat info for confirmed ct
      netfilter: introduce nf_conntrack_helper_put helper function
      netfilter: nfnl_cthelper: reject del request if helper obj is in use
      netfilter: nf_tables: can't assume lock is acquired when dumping set elems

Matthias Kaehlcke (1):
      netfilter: ctnetlink: Make some parameters integer to avoid enum mismatch

Pablo Neira Ayuso (3):
      Merge tag 'ipvs-fixes-for-v4.12' of http://git.kernel.org/.../horms/ipvs
      netfilter: nf_tables: missing sanitization in data from userspace
      netfilter: nf_tables: revisit chain/object refcounting from elements

Willem de Bruijn (2):
      netfilter: xtables: zero padding in data_to_user
      netfilter: xtables: fix build failure from COMPAT_XT_ALIGN outside CONFIG_COMPAT

 include/linux/netfilter/x_tables.h          |   2 +-
 include/linux/netfilter_bridge/ebtables.h   |   5 +
 include/net/netfilter/nf_conntrack_helper.h |   4 +
 include/net/netfilter/nf_tables.h           |   2 +-
 net/bridge/netfilter/ebt_arpreply.c         |   3 +
 net/bridge/netfilter/ebtables.c             |   9 +-
 net/netfilter/ipvs/ip_vs_core.c             |  19 +++-
 net/netfilter/nf_conntrack_helper.c         |  12 +++
 net/netfilter/nf_conntrack_netlink.c        |  11 +-
 net/netfilter/nf_nat_core.c                 |   4 +
 net/netfilter/nf_tables_api.c               | 160 ++++++++++++++++++++++------
 net/netfilter/nfnetlink_cthelper.c          |  17 +--
 net/netfilter/nft_bitwise.c                 |  19 +++-
 net/netfilter/nft_cmp.c                     |  12 ++-
 net/netfilter/nft_ct.c                      |   4 +-
 net/netfilter/nft_immediate.c               |   5 +-
 net/netfilter/nft_range.c                   |   4 +-
 net/netfilter/nft_set_hash.c                |   2 +-
 net/netfilter/x_tables.c                    |  24 +++--
 net/netfilter/xt_CT.c                       |   6 +-
 net/openvswitch/conntrack.c                 |   4 +-
 21 files changed, 249 insertions(+), 79 deletions(-)
