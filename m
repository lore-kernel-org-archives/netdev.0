From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/9] Netfilter fixes for net
Date: Mon, 28 Mar 2016 19:57:53 +0200
Message-ID: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50819 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbcC1R6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 13:58:11 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 60387E8397
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1617BDA8F7
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:09 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0837ADA8FA
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:07 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for you net tree,
they are:

1) There was a race condition between parallel save/swap and delete,
   which resulted a kernel crash due to the increase ref for save, swap,
   wrong ref decrease operations. Reported and fixed by Vishwanath Pai.

2) OVS should call into CT NAT for packets of new expected connections only
   when the conntrack state is persisted with the 'commit' option to the
   OVS CT action. From Jarno Rajahalme.

3) Resolve kconfig dependencies with new OVS NAT support. From Arnd Bergmann.

4) Early validation of entry->target_offset to make sure it doesn't take us
   out from the blob, from Florian Westphal.

5) Again early validation of entry->next_offset to make sure it doesn't take
   out from the blob, also from Florian.

6) Check that entry->target_offset is always of of sizeof(struct xt_entry)
   for unconditional entries, when checking both from check_underflow()
   and when checking for loops in mark_source_chains(), again from
   Florian.

7) Fix inconsistent behaviour in nfnetlink_queue when
   NFQA_CFG_F_FAIL_OPEN is set and netlink_unicast() fails due to buffer
   overrun, we have to reinject the packet as the user expects.

8) Enforce nul-terminated table names from getsockopt GET_ENTRIES
   requests.

9) Don't assume skb->sk is set from nft_bridge_reject and synproxy,
   this fixes a recent update of the code to namespaceify
   ip_default_ttl, patch from Liping Zhang.

This batch comes with four patches to validate x_tables blobs coming
from userspace. CONFIG_USERNS exposes the x_tables interface to
unpriviledged users and to be honest this interface never received the
attention for this move away from the CAP_NET_ADMIN domain. Florian is
working on another round with more patches with more sanity checks, so
expect a bit more Netfilter fixes in this development cycle than usual.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit d7be81a5916bdb1d904803958e5991a16f7ae4b2:

  ravb: fix software timestamping (2016-03-27 22:41:37 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 29421198c3a860092e27c2ad8499dfe603398817:

  netfilter: ipv4: fix NULL dereference (2016-03-28 17:59:29 +0200)

----------------------------------------------------------------
Arnd Bergmann (1):
      openvswitch: call only into reachable nf-nat code

Florian Westphal (3):
      netfilter: x_tables: validate e->target_offset early
      netfilter: x_tables: make sure e->next_offset covers remaining blob size
      netfilter: x_tables: fix unconditional helper

Jarno Rajahalme (1):
      openvswitch: Fix checking for new expected connections.

Liping Zhang (1):
      netfilter: ipv4: fix NULL dereference

Pablo Neira Ayuso (2):
      netfilter: nfnetlink_queue: honor NFQA_CFG_F_FAIL_OPEN when netlink unicast fails
      netfilter: x_tables: enforce nul-terminated table name from getsockopt GET_ENTRIES

Vishwanath Pai (1):
      netfilter: ipset: fix race condition in ipset save, swap and delete

 include/linux/netfilter/ipset/ip_set.h   |  4 +++
 net/bridge/netfilter/ebtables.c          |  4 +++
 net/bridge/netfilter/nft_reject_bridge.c | 20 ++++++------
 net/ipv4/netfilter/arp_tables.c          | 43 +++++++++++++------------
 net/ipv4/netfilter/ip_tables.c           | 48 ++++++++++++++--------------
 net/ipv4/netfilter/ipt_SYNPROXY.c        | 54 +++++++++++++++++---------------
 net/ipv6/netfilter/ip6_tables.c          | 48 ++++++++++++++--------------
 net/netfilter/ipset/ip_set_bitmap_gen.h  |  2 +-
 net/netfilter/ipset/ip_set_core.c        | 33 ++++++++++++++++---
 net/netfilter/ipset/ip_set_hash_gen.h    |  2 +-
 net/netfilter/ipset/ip_set_list_set.c    |  2 +-
 net/netfilter/nfnetlink_queue.c          |  7 ++++-
 net/openvswitch/Kconfig                  |  4 ++-
 net/openvswitch/conntrack.c              | 21 +++++++------
 14 files changed, 170 insertions(+), 122 deletions(-)
