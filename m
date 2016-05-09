From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/36] Netfilter updates for net-next
Date: Mon,  9 May 2016 20:46:18 +0200
Message-ID: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45669 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbcEISrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:06 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5C6ECE8E83
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 455DE134705
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 958E8134703
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:46:59 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following large patchset contains Netfilter updates for your
net-next tree. My initial intention was to send you this in two goes but
when I looked back twice I already had this burden on top of me.

Several updates for IPVS from Marco Angaroni:

1) Allow SIP connections originating from real-servers to be load
   balanced by the SIP persistence engine as is already implemented
   in the other direction.

2) Release connections immediately for One-packet-scheduling (OPS)
   in IPVS, instead of making it via timer and rcu callback.

3) Skip deleting conntracks for each one packet in OPS, and don't call
   nf_conntrack_alter_reply() since no reply is expected.

4) Enable drop on exhaustion for OPS + SIP persistence.

Miscelaneous conntrack updates from Florian Westphal, including fix for
hash resize:

5) Move conntrack generation counter out of conntrack pernet structure
   since this is only used by the init_ns to allow hash resizing.

6) Use get_random_once() from packet path to collect hash random seed
    instead of our compound.

7) Don't disable BH from ____nf_conntrack_find() for statistics,
   use NF_CT_STAT_INC_ATOMIC() instead.

8) Fix lookup race during conntrack hash resizing.

9) Introduce clash resolution on conntrack insertion for connectionless
   protocol.

Then, Florian's netns rework to get rid of per-netns conntrack table,
thus we use one single table for them all. There was consensus on this
change during the NFWS 2015 and, on top of that, it has recently been
pointed as a source of multiple problems from unpriviledged netns:

11) Use a single conntrack hashtable for all namespaces. Include netns
    in object comparisons and make it part of the hash calculation.
    Adapt early_drop() to consider netns.

12) Use single expectation and NAT hashtable for all namespaces.

13) Use a single slab cache for all namespaces for conntrack objects.

14) Skip full table scanning from nf_ct_iterate_cleanup() if the pernet
    conntrack counter tells us the table is empty (ie. equals zero).

Fixes for nf_tables interval set element handling, support to set
conntrack connlabels and allow set names up to 32 bytes.

15) Parse element flags from element deletion path and pass it up to the
    backend set implementation.

16) Allow adjacent intervals in the rbtree set type for dynamic interval
    updates.

17) Add support to set connlabel from nf_tables, from Florian Westphal.

18) Allow set names up to 32 bytes in nf_tables.

Several x_tables fixes and updates:

19) Fix incorrect use of IS_ERR_VALUE() in x_tables, original patch
    from Andrzej Hajda.

And finally, miscelaneous netfilter updates such as:

20) Disable automatic helper assignment by default. Note this proc knob
    was introduced by a9006892643a ("netfilter: nf_ct_helper: allow to
    disable automatic helper assignment") 4 years ago to start moving
    towards explicit conntrack helper configuration via iptables CT
    target.

21) Get rid of obsolete and inconsistent debugging instrumentation
    in x_tables.

22) Remove unnecessary check for null after ip6_route_output().

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 15cfd40771e18a4e9b788c64c9db2606f958b93d:

  hv_netvsc: Fix the list processing for network change event (2016-04-24 23:27:58 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 0c5366b3a8c77fd6d67b763c5a76dfdc314e7726:

  netfilter: conntrack: use single slab cache (2016-05-09 16:45:50 +0200)

----------------------------------------------------------------
Florian Westphal (19):
      netfilter: conntrack: move generation seqcnt out of netns_ct
      netfilter: conntrack: use get_random_once for nat and expectations
      netfilter: conntrack: use get_random_once for conntrack hash seed
      netfilter: nftables: add connlabel set support
      netfilter: conntrack: keep BH enabled during lookup
      netfilter: conntrack: fix lookup race during hash resize
      netfilter: conntrack: don't attempt to iterate over empty table
      netfilter: conntrack: use nf_ct_key_equal() in more places
      netfilter: conntrack: small refactoring of conntrack seq_printf
      netfilter: conntrack: check netns when comparing conntrack objects
      netfilter: conntrack: make netns address part of hash
      netfilter: conntrack: use a single hashtable for all namespaces
      netfilter: conntrack: consider ct netns in early_drop logic
      netfilter: conntrack: check netns when walking expect hash
      netfilter: conntrack: make netns address part of expect hash
      netfilter: conntrack: use a single expectation table for all namespaces
      netfilter: conntrack: make netns address part of nat bysrc hash
      netfilter: conntrack: use a single nat bysource table for all namespaces
      netfilter: conntrack: use single slab cache

Liping Zhang (1):
      netfilter: ip6t_SYNPROXY: unnecessary to check whether ip6_route_output returns NULL

Marco Angaroni (4):
      ipvs: handle connections started by real-servers
      ipvs: optimize release of connections in OPS mode
      ipvs: don't alter conntrack in OPS mode
      ipvs: make drop_entry protection effective for SIP-pe

Pablo Neira Ayuso (14):
      netfilter: nf_tables: introduce nft_setelem_parse_flags() helper
      netfilter: nf_tables: parse element flags from nft_del_setelem()
      netfilter: nft_rbtree: introduce nft_rbtree_interval_end() helper
      netfilter: nft_rbtree: allow adjacent intervals with dynamic updates
      netfilter: nf_ct_helper: disable automatic helper assignment
      Merge tag 'ipvs-for-v4.7' of https://git.kernel.org/.../horms/ipvs-next
      netfilter: fix IS_ERR_VALUE usage
      netfilter: conntrack: __nf_ct_l4proto_find() always returns valid pointer
      netfilter: conntrack: introduce nf_ct_acct_update()
      netfilter: conntrack: introduce clash resolution on insertion race
      openvswitch: __nf_ct_l{3,4}proto_find() always return a valid pointer
      netfilter: x_tables: get rid of old and inconsistent debugging
      netfilter: nf_tables: allow set names up to 32 bytes
      Merge tag 'ipvs2-for-v4.7' of https://git.kernel.org/.../horms/ipvs-next

 include/linux/netfilter/x_tables.h                 |   6 +-
 include/net/ip_vs.h                                |  17 +
 include/net/netfilter/nf_conntrack.h               |   2 -
 include/net/netfilter/nf_conntrack_core.h          |   1 +
 include/net/netfilter/nf_conntrack_expect.h        |   1 +
 include/net/netfilter/nf_conntrack_l4proto.h       |   3 +
 include/net/netfilter/nf_tables.h                  |   2 +-
 include/net/netns/conntrack.h                      |  10 -
 include/uapi/linux/netfilter/nf_tables.h           |   1 +
 net/ipv4/netfilter/arp_tables.c                    | 223 ++---------
 net/ipv4/netfilter/ip_tables.c                     | 250 +++----------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   2 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |  47 ++-
 net/ipv6/netfilter/ip6_tables.c                    | 235 +++---------
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |   2 +-
 net/netfilter/ipvs/ip_vs_conn.c                    |  51 ++-
 net/netfilter/ipvs/ip_vs_core.c                    | 162 +++++++-
 net/netfilter/ipvs/ip_vs_ctl.c                     |  46 ++-
 net/netfilter/ipvs/ip_vs_nfct.c                    |   4 +
 net/netfilter/ipvs/ip_vs_pe_sip.c                  |  15 +
 net/netfilter/nf_conntrack_core.c                  | 415 +++++++++++----------
 net/netfilter/nf_conntrack_expect.c                |  83 +++--
 net/netfilter/nf_conntrack_helper.c                |  12 +-
 net/netfilter/nf_conntrack_netlink.c               |  29 +-
 net/netfilter/nf_conntrack_proto_udp.c             |   2 +
 net/netfilter/nf_conntrack_proto_udplite.c         |   2 +
 net/netfilter/nf_conntrack_standalone.c            |  13 +-
 net/netfilter/nf_nat_core.c                        |  39 +-
 net/netfilter/nf_tables_api.c                      |  78 +++-
 net/netfilter/nfnetlink_cttimeout.c                |   6 +-
 net/netfilter/nft_ct.c                             |  30 ++
 net/netfilter/nft_rbtree.c                         |  49 ++-
 net/openvswitch/conntrack.c                        |   8 -
 33 files changed, 916 insertions(+), 930 deletions(-)
