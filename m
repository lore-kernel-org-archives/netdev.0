From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/53] Netfilter updates for net-next
Date: Mon, 26 Sep 2016 01:06:10 +0200
Message-ID: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54498 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941055AbcIYXHV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:21 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CA373B6C75
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:17 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B1121DA81C
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:17 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EA02CDA81B
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next
tree, they are:

1) Consolidate GRE protocol tracker using new GRE protocol definitions,
   patches from Gao Feng.

2) Properly parse continuation lines in SIP helper, update allowed
   characters in Call-ID header and allow tabs in SIP headers as
   specified by RFC3261, from Marco Angaroni.

3) Remove useless code in FTP conntrack helper, also from Gao Feng.

4) Add number generation expression for nf_tables, with random and
   incremental generators. This also includes specific offset to add
   to the result, patches from Laura Garcia Liebana. Liping Zhang
   follows with a fix to avoid a race in this new expression.

5) Fix new quota expression inversion logic, added in the previous
   pull request.

6) Missing validation of queue configuration in nft_queue, patch
   from Liping Zhang.

7) Remove unused ctl_table_path, as part of the deprecation of the
   ip_conntrack sysctl interface coming in the previous batch.
   Again from Liping Zhang.

8) Add offset attribute to nft_hash expression, so we can generate
   any output from a specific base offset. Moreover, check for
   possible overflow, patches from Laura Garcia.

9) Allow to invert dynamic set insertion from packet path, to check
   for overflows in case the set is full.

10) Revisit nft_set_pktinfo*() logic from nf_tables to ensure
    proper initialization of layer 4 protocol. Consolidate pktinfo
    structure initialization for bridge and netdev families.

11) Do not inconditionally drop IPv6 packets that we cannot parse
    transport protocol for ip6 and inet families, let the user decide
    on this via ruleset policy.

12) Get rid of gotos in __nf_ct_try_assign_helper().

13) Check for return value in register_netdevice_notifier() and
    nft_register_chain_type(), patches from Gao Feng.

14) Get rid of CONFIG_IP6_NF_IPTABLES dependency in nf_queue
    infrastructure that is common to nf_tables, from Liping Zhang.

15) Disable 'found' and 'searched' stats that are updates from the
    packet hotpath, not very useful these days.

16) Validate maximum value of u32 netlink attributes in nf_tables,
    this introduces nft_parse_u32_check(). From Laura Garcia.

17) Add missing code to integrate nft_queue with maps, patch from
    Liping Zhang. This also includes missing support ranges in
    nft_queue bridge family.

18) Fix check in nft_payload_fast_eval() that ensure that we don't
    go over the skbuff data boundary, from Liping Zhang.

19) Check if transport protocol is set from nf_tables tracing and
    payload expression. Again from Liping Zhang.

20) Use net_get_random_once() whenever possible, from Gao Feng.

21) Replace hardcoded value by sizeof() in xt_helper, from Gao Feng.

22) Remove superfluous check for found element in nft_lookup.

23) Simplify TCPMSS logic to check for minimum MTU, from Gao Feng.

24) Replace double linked list by single linked list in Netfilter
    core hook infrastructure, patchset from Aaron Conole. This
    includes several patches to prepare this update.

25) Fix wrong sequence adjustment of TCP RST with no ACK, from
    Gao Feng.

26) Relax check for direction attribute in nft_ct for layer 3 and 4
    protocol fields, from Liping Zhang.

27) Add new revision for hashlimit to support higher pps of upto 1
    million, from Vishwanath Pai.

28) Evict stale entries in nf_conntrack when reading entries from
    /proc/net/nf_conntrack, from Florian Westphal.

29) Fix transparent match for IPv6 request sockets, from Krisztian
    Kovacs.

30) Add new range expression for nf_tables.

31) Add missing code to support for flags in nft_log. Expose NF_LOG_*
    flags via uapi and use it from the generic logging infrastructure,
    instead of using xt specific definitions, from Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit fe0acb5fcb7fe8cb3d68bbdb8459865c972d8f83:

  Merge branch '40GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue (2016-09-25 06:01:05 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to f20fbc0717f9f007c94b2641134b19228d0ce9ed:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2016-09-25 23:34:19 +0200)

----------------------------------------------------------------
Aaron Conole (5):
      netfilter: call nf_hook_ingress with rcu_read_lock
      netfilter: Remove explicit rcu_read_lock in nf_hook_slow
      netfilter: Only allow sane values in nf_register_net_hook
      netfilter: nf_queue: whitespace cleanup
      netfilter: replace list_head with single linked list

Florian Westphal (4):
      netfilter: conntrack: remove packet hotpath stats
      netfilter: bridge: add and use br_nf_hook_thresh
      netfilter: call nf_hook_state_init with rcu_read_lock held
      netfilter: evict stale entries when user reads /proc/net/nf_conntrack

Gao Feng (10):
      netfilter: gre: Use consistent GRE_* macros instead of ones defined by netfilter.
      netfilter: gre: Use consistent GRE and PTTP header structure instead of the ones defined by netfilter
      netfilter: ftp: Remove the useless dlen==0 condition check in find_pattern
      netfilter: ftp: Remove the useless code
      netfilter: Add the missed return value check of register_netdevice_notifier
      netfilter: Add the missed return value check of nft_register_chain_type
      netfilter: Enhance the codes used to get random once
      netfilter: xt_helper: Use sizeof(variable) instead of literal number
      netfilter: xt_TCPMSS: Refactor the codes to decrease one condition check and more readable
      netfilter: seqadj: Fix the wrong ack adjust for the RST packet without ack

KOVACS Krisztian (1):
      netfilter: xt_socket: fix transparent match for IPv6 request sockets

Laura Garcia Liebana (5):
      netfilter: nft_numgen: rename until attribute by modulus
      netfilter: nft_hash: Add hash offset value
      netfilter: nft_hash: fix hash overflow validation
      netfilter: nft_numgen: add number generation offset
      netfilter: nf_tables: validate maximum value of u32 netlink attributes

Liping Zhang (12):
      netfilter: nft_queue: check the validation of queues_total and queuenum
      netfilter: nf_conntrack: remove unused ctl_table_path member in nf_conntrack_l3proto
      netfilter: nf_queue: get rid of dependency on IP6_NF_IPTABLES
      netfilter: nft_numgen: fix race between num generate and store it
      netfilter: nft_queue: add _SREG_QNUM attr to select the queue number
      netfilter: nf_queue: improve queue range support for bridge family
      netfilter: nf_tables: improve nft payload fast eval
      netfilter: nf_tables: check tprot_set first when we use xt.thoff
      netfilter: nft_ct: unnecessary to require dir when use ct l3proto/protocol
      netfilter: nft_ct: report error if mark and dir specified simultaneously
      netfilter: nft_log: complete NFTA_LOG_FLAGS attr support
      netfilter: nf_log: get rid of XT_LOG_* macros

Marco Angaroni (3):
      netfilter: nf_ct_sip: correct parsing of continuation lines in SIP headers
      netfilter: nf_ct_sip: correct allowed characters in Call-ID SIP header
      netfilter: nf_ct_sip: allow tab character in SIP headers

Pablo Neira (1):
      netfilter: nf_conntrack: simplify __nf_ct_try_assign_helper() return logic

Pablo Neira Ayuso (11):
      netfilter: nft_quota: fix overquota logic
      netfilter: nft_quota: introduce nft_overquota()
      netfilter: nft_dynset: allow to invert match criteria
      netfilter: nf_tables: ensure proper initialization of nft_pktinfo fields
      netfilter: nf_tables_ipv6: setup pktinfo transport field on failure to parse
      netfilter: introduce nft_set_pktinfo_{ipv4, ipv6}_validate()
      netfilter: nf_tables_bridge: use nft_set_pktinfo_ipv{4, 6}_validate
      netfilter: nf_tables: don't drop IPv6 packets that cannot parse transport
      netfilter: nft_lookup: remove superfluous element found check
      netfilter: nf_tables: add range expression
      Merge branch 'master' of git://git.kernel.org/.../davem/net-next

Vishwanath Pai (2):
      netfilter: xt_hashlimit: Prepare for revision 2
      netfilter: xt_hashlimit: Create revision 2 to support higher pps rates

 include/linux/netdevice.h                          |   2 +-
 include/linux/netfilter.h                          |  61 ++--
 include/linux/netfilter/nf_conntrack_common.h      |   4 -
 include/linux/netfilter/nf_conntrack_proto_gre.h   |  64 +---
 include/linux/netfilter_ingress.h                  |  18 +-
 include/net/netfilter/br_netfilter.h               |   6 +
 include/net/netfilter/nf_conntrack_l3proto.h       |   4 -
 include/net/netfilter/nf_log.h                     |  11 +-
 include/net/netfilter/nf_queue.h                   |  69 +++--
 include/net/netfilter/nf_tables.h                  |  19 ++
 include/net/netfilter/nf_tables_bridge.h           |   7 -
 include/net/netfilter/nf_tables_core.h             |   3 +
 include/net/netfilter/nf_tables_ipv4.h             |  43 +++
 include/net/netfilter/nf_tables_ipv6.h             |  53 +++-
 include/net/netns/netfilter.h                      |   2 +-
 include/uapi/linux/if_tunnel.h                     |   1 +
 include/uapi/linux/netfilter/nf_log.h              |  12 +
 include/uapi/linux/netfilter/nf_tables.h           |  45 ++-
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |   8 +-
 include/uapi/linux/netfilter/xt_hashlimit.h        |  23 ++
 net/bridge/br_netfilter_hooks.c                    |  53 +++-
 net/bridge/br_netfilter_ipv6.c                     |  12 +-
 net/bridge/netfilter/ebt_log.c                     |   2 +-
 net/bridge/netfilter/ebt_redirect.c                |   2 +-
 net/bridge/netfilter/ebtables.c                    |   2 +-
 net/bridge/netfilter/nf_tables_bridge.c            |  92 +-----
 net/bridge/netfilter/nft_reject_bridge.c           |  44 ++-
 net/core/dev.c                                     |   7 +-
 net/ipv4/netfilter/ip_tables.c                     |   2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |   2 +-
 net/ipv4/netfilter/nf_log_arp.c                    |   2 +-
 net/ipv4/netfilter/nf_log_ipv4.c                   |  10 +-
 net/ipv4/netfilter/nf_nat_proto_gre.c              |  13 +-
 net/ipv4/netfilter/nf_tables_arp.c                 |   7 +-
 net/ipv4/netfilter/nf_tables_ipv4.c                |   5 +-
 net/ipv4/tcp_input.c                               |   1 +
 net/ipv4/tcp_ipv4.c                                |   1 -
 net/ipv6/netfilter/ip6_tables.c                    |   2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |   2 +-
 net/ipv6/netfilter/nf_log_ipv6.c                   |  18 +-
 net/ipv6/netfilter/nf_tables_ipv6.c                |   9 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c          |   4 +-
 net/netfilter/Makefile                             |   3 +-
 net/netfilter/core.c                               | 152 +++++----
 net/netfilter/nf_conntrack_core.c                  |  16 +-
 net/netfilter/nf_conntrack_ftp.c                   |  15 +-
 net/netfilter/nf_conntrack_h323_main.c             |   2 +-
 net/netfilter/nf_conntrack_helper.c                |  17 +-
 net/netfilter/nf_conntrack_netlink.c               |   6 +-
 net/netfilter/nf_conntrack_proto_gre.c             |  14 +-
 net/netfilter/nf_conntrack_seqadj.c                |  20 +-
 net/netfilter/nf_conntrack_sip.c                   |  10 +-
 net/netfilter/nf_conntrack_standalone.c            |  13 +-
 net/netfilter/nf_internals.h                       |  10 +-
 net/netfilter/nf_log_common.c                      |   4 +-
 net/netfilter/nf_queue.c                           |  18 +-
 net/netfilter/nf_tables_api.c                      |  25 ++
 net/netfilter/nf_tables_core.c                     |  16 +-
 net/netfilter/nf_tables_inet.c                     |   5 +-
 net/netfilter/nf_tables_netdev.c                   | 101 ++----
 net/netfilter/nf_tables_trace.c                    |  20 +-
 net/netfilter/nfnetlink_cthelper.c                 |   2 +-
 net/netfilter/nfnetlink_log.c                      |   8 +-
 net/netfilter/nfnetlink_queue.c                    |  19 +-
 net/netfilter/nft_bitwise.c                        |   8 +-
 net/netfilter/nft_byteorder.c                      |  15 +-
 net/netfilter/nft_cmp.c                            |   3 +
 net/netfilter/nft_ct.c                             |  21 +-
 net/netfilter/nft_dynset.c                         |  20 +-
 net/netfilter/nft_exthdr.c                         |  12 +-
 net/netfilter/nft_hash.c                           |  17 +-
 net/netfilter/nft_immediate.c                      |   4 +
 net/netfilter/nft_log.c                            |   9 +-
 net/netfilter/nft_lookup.c                         |   2 +-
 net/netfilter/nft_meta.c                           |   2 +
 net/netfilter/nft_numgen.c                         |  54 ++--
 net/netfilter/nft_payload.c                        |   4 +
 net/netfilter/nft_queue.c                          | 113 ++++++-
 net/netfilter/nft_quota.c                          |   8 +-
 net/netfilter/nft_range.c                          | 138 +++++++++
 net/netfilter/xt_RATEEST.c                         |   6 +-
 net/netfilter/xt_TCPMSS.c                          |  12 +-
 net/netfilter/xt_TEE.c                             |   8 +-
 net/netfilter/xt_connlimit.c                       |   8 +-
 net/netfilter/xt_hashlimit.c                       | 339 ++++++++++++++++-----
 net/netfilter/xt_helper.c                          |   4 +-
 net/netfilter/xt_recent.c                          |   7 +-
 89 files changed, 1381 insertions(+), 680 deletions(-)
 delete mode 100644 include/net/netfilter/nf_tables_bridge.h
 create mode 100644 include/uapi/linux/netfilter/nf_log.h
 create mode 100644 net/netfilter/nft_range.c
