From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/50] Netfilter/IPVS updates for net-next
Date: Wed,  7 Dec 2016 22:52:06 +0100
Message-ID: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60036 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933165AbcLGVxL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:11 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CC895D164C
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B3E81DA85D
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 820B7DA801
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:02 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains a large Netfilter update for net-next,
to summarise:

1) Add support for stateful objects. This series provides a nf_tables
   native alternative to the extended accounting infrastructure for
   nf_tables. Two initial stateful objects are supported: counters and
   quotas. Objects are identified by a user-defined name, you can fetch
   and reset them anytime. You can also use a maps to allow fast lookups
   using any arbitrary key combination. More info at:

   http://marc.info/?l=netfilter-devel&m=148029128323837&w=2

2) On-demand registration of nf_conntrack and defrag hooks per netns.
   Register nf_conntrack hooks if we have a stateful ruleset, ie.
   state-based filtering or NAT. The new nf_conntrack_default_on sysctl
   enables this from newly created netnamespaces. Default behaviour is not
   modified. Patches from Florian Westphal.

3) Allocate 4k chunks and then use these for x_tables counter allocation
   requests, this improves ruleset load time and also datapath ruleset
   evaluation, patches from Florian Westphal.

4) Add support for ebpf to the existing x_tables bpf extension.
   From Willem de Bruijn.

5) Update layer 4 checksum if any of the pseudoheader fields is updated.
   This provides a limited form of 1:1 stateless NAT that make sense in
   specific scenario, eg. load balancing.

6) Add support to flush sets in nf_tables. This series comes with a new
   set->ops->deactivate_one() indirection given that we have to walk
   over the list of set elements, then deactivate them one by one.
   The existing set->ops->deactivate() performs an element lookup that
   we don't need.

7) Two patches to avoid cloning packets, thus speed up packet forwarding
   via nft_fwd from ingress. From Florian Westphal.

8) Two IPVS patches via Simon Horman: Decrement ttl in all modes to
   prevent infinite loops, patch from Dwip Banerjee. And one minor
   refactoring from Gao feng.

9) Revisit recent log support for nf_tables netdev families: One patch
   to ensure that we correctly handle non-ethernet packets. Another
   patch to add missing logger definition for netdev. Patches from
   Liping Zhang.

10) Three patches for nft_fib, one to address insufficient register
    initialization and another to solve incorrect (although harmless)
    byteswap operation. Moreover update xt_rpfilter and nft_fib to match
    lbcast packets with zeronet as source, eg. DHCP Discover packets
    (0.0.0.0 -> 255.255.255.255). Also from Liping Zhang.

11) Built-in DCCP, SCTP and UDPlite conntrack and NAT support, from
    Davide Caratti. While DCCP is rather hopeless lately, and UDPlite has
    been broken in many-cast mode for some little time, let's give them a
    chance by placing them at the same level as other existing protocols.
    Thus, users don't explicitly have to modprobe support for this and
    NAT rules work for them. Some people point to the lack of support in
    SOHO Linux-based routers that make deployment of new protocols harder.
    I guess other middleboxes outthere on the Internet are also to blame.
    Anyway, let's see if this has any impact in the midrun.

12) Skip software SCTP software checksum calculation if the NIC comes
    with SCTP checksum offload support. From Davide Caratti.

13) Initial core factoring to prepare conversion to hook array. Three
    patches from Aaron Conole.

14) Gao Feng made a wrong conversion to switch in the xt_multiport
    extension in a patch coming in the previous batch. Fix it in this
    batch.

15) Get vmalloc call in sync with kmalloc flags to avoid a warning
    and likely OOM killer intervention from x_tables. From Marcelo
    Ricardo Leitner.

16) Update Arturo Borrero's email address in all source code headers.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit adc176c5472214971d77c1a61c83db9b01e9cdc7:

  ipv6 addrconf: Implemented enhanced DAD (RFC7527) (2016-12-03 23:21:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 73c25fb139337ac4fe1695ae3c056961855594db:

  netfilter: nft_quota: allow to restore consumed quota (2016-12-07 14:40:53 +0100)

----------------------------------------------------------------
Aaron Conole (3):
      netfilter: introduce accessor functions for hook entries
      netfilter: decouple nf_hook_entry and nf_hook_ops
      netfilter: convert while loops to for loops

Arturo Borrero Gonzalez (1):
      netfilter: update Arturo Borrero Gonzalez email address

Davide Caratti (8):
      netfilter: built-in NAT support for DCCP
      netfilter: built-in NAT support for SCTP
      netfilter: built-in NAT support for UDPlite
      netfilter: nf_conntrack_tuple_common.h: fix #include
      netfilter: conntrack: built-in support for DCCP
      netfilter: conntrack: built-in support for SCTP
      netfilter: conntrack: built-in support for UDPlite
      netfilter: nat: skip checksum on offload SCTP packets

Dwip Banerjee (1):
      ipvs: Decrement ttl

Florian Westphal (12):
      netfilter: conntrack: remove unused init_net hook
      netfilter: add and use nf_ct_netns_get/put
      netfilter: nat: add dependencies on conntrack module
      netfilter: nf_tables: add conntrack dependencies for nat/masq/redir expressions
      netfilter: conntrack: register hooks in netns when needed by ruleset
      netfilter: conntrack: add nf_conntrack_default_on sysctl
      netfilter: defrag: only register defrag functionality if needed
      netfilter: x_tables: pass xt_counters struct instead of packet counter
      netfilter: x_tables: pass xt_counters struct to counter allocator
      netfilter: x_tables: pack percpu counter allocations
      netfilter: ingress: translate 0 nf_hook_slow retval to -1
      netfilter: add and use nf_fwd_netdev_egress

Gao Feng (2):
      ipvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc) || svc == NULL
      netfilter: xt_multiport: Fix wrong unmatch result with multiple ports

Liping Zhang (5):
      netfilter: nf_log: do not assume ethernet header in netdev family
      netfilter: nfnetlink_log: add "nf-logger-5-1" module alias name
      netfilter: nft_fib: convert htonl to ntohl properly
      netfilter: nft_fib_ipv4: initialize *dest to zero
      netfilter: rpfilter: bypass ipv4 lbcast packets with zeronet source

Marcelo Ricardo Leitner (1):
      netfilter: x_tables: avoid warn and OOM killer on vmalloc call

Pablo Neira Ayuso (17):
      Merge tag 'ipvs-for-v4.10' of https://git.kernel.org/.../horms/ipvs-next
      netfilter: nft_payload: layer 4 checksum adjustment for pseudoheader fields
      netfilter: nf_tables: add stateful objects
      netfilter: nft_counter: add stateful object type
      netfilter: nft_quota: add stateful object type
      netfilter: nf_tables: add stateful object reference expression
      netfilter: nft_quota: dump consumed quota
      netfilter: nf_tables: atomic dump and reset for stateful objects
      netfilter: nf_tables: notify internal updates of stateful objects
      netfilter: nft_quota: add depleted flag for objects
      netfilter: nf_tables: add stateful object reference to set elements
      netfilter: nft_objref: support for stateful object maps
      netfilter: nf_tables: allow to filter stateful object dumps by type
      netfilter: nf_tables: constify struct nft_ctx * parameter in nft_trans_alloc()
      netfilter: nft_set: introduce nft_{hash, rbtree}_deactivate_one()
      netfilter: nf_tables: support for set flushing
      netfilter: nft_quota: allow to restore consumed quota

Willem de Bruijn (1):
      netfilter: xt_bpf: support ebpf

 Documentation/networking/nf_conntrack-sysctl.txt   |  11 +
 include/linux/netfilter.h                          |  31 +-
 include/linux/netfilter/nf_conntrack_dccp.h        |   2 +-
 include/linux/netfilter/x_tables.h                 |  38 +-
 include/linux/netfilter_ingress.h                  |   7 +-
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h     |   9 +
 include/net/netfilter/ipv4/nf_defrag_ipv4.h        |   3 +-
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h     |   9 +
 include/net/netfilter/ipv6/nf_defrag_ipv6.h        |   3 +-
 include/net/netfilter/nf_conntrack.h               |   4 +
 include/net/netfilter/nf_conntrack_l3proto.h       |  16 +-
 include/net/netfilter/nf_dup_netdev.h              |   1 +
 include/net/netfilter/nf_log.h                     |   4 +-
 include/net/netfilter/nf_nat_l4proto.h             |   9 +
 include/net/netfilter/nf_tables.h                  | 101 ++-
 include/net/netfilter/nf_tables_core.h             |   1 +
 include/net/netns/conntrack.h                      |  43 ++
 include/net/netns/netfilter.h                      |   6 +
 .../linux/netfilter/nf_conntrack_tuple_common.h    |   3 +
 include/uapi/linux/netfilter/nf_tables.h           |  70 ++
 include/uapi/linux/netfilter/xt_bpf.h              |  21 +
 net/bridge/br_netfilter_hooks.c                    |   8 +-
 net/bridge/netfilter/nf_log_bridge.c               |   3 +-
 net/ipv4/netfilter/arp_tables.c                    |  16 +-
 net/ipv4/netfilter/ip_tables.c                     |  16 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |   4 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   8 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |   4 +-
 net/ipv4/netfilter/ipt_rpfilter.c                  |   8 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |  71 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c                |  41 +-
 net/ipv4/netfilter/nft_fib_ipv4.c                  |  17 +-
 net/ipv4/netfilter/nft_masq_ipv4.c                 |  11 +-
 net/ipv4/netfilter/nft_redir_ipv4.c                |  11 +-
 net/ipv6/netfilter/ip6_tables.c                    |  17 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |   4 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |  70 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c          |  42 +-
 net/ipv6/netfilter/nft_fib_ipv6.c                  |   2 +-
 net/ipv6/netfilter/nft_masq_ipv6.c                 |  11 +-
 net/ipv6/netfilter/nft_redir_ipv6.c                |  11 +-
 net/netfilter/Kconfig                              |  30 +-
 net/netfilter/Makefile                             |  18 +-
 net/netfilter/core.c                               |  16 +-
 net/netfilter/ipvs/ip_vs_ctl.c                     |   2 +-
 net/netfilter/ipvs/ip_vs_xmit.c                    |  54 ++
 net/netfilter/nf_conntrack_proto.c                 |  73 ++-
 net/netfilter/nf_conntrack_proto_dccp.c            |  79 +--
 net/netfilter/nf_conntrack_proto_sctp.c            |  76 +--
 net/netfilter/nf_conntrack_proto_udplite.c         |  79 +--
 net/netfilter/nf_conntrack_standalone.c            |  10 +
 net/netfilter/nf_dup_netdev.c                      |  33 +-
 net/netfilter/nf_log_common.c                      |   3 +-
 net/netfilter/nf_log_netdev.c                      |   3 +-
 net/netfilter/nf_nat_core.c                        |  12 +
 net/netfilter/nf_nat_proto_dccp.c                  |  36 +-
 net/netfilter/nf_nat_proto_sctp.c                  |  40 +-
 net/netfilter/nf_nat_proto_udplite.c               |  35 +-
 net/netfilter/nf_queue.c                           |   5 +-
 net/netfilter/nf_tables_api.c                      | 718 ++++++++++++++++++++-
 net/netfilter/nfnetlink_log.c                      |   1 +
 net/netfilter/nft_counter.c                        | 186 +++++-
 net/netfilter/nft_ct.c                             |  26 +-
 net/netfilter/nft_fib.c                            |   2 +-
 net/netfilter/nft_fwd_netdev.c                     |   4 +-
 net/netfilter/nft_masq.c                           |   6 +-
 net/netfilter/nft_nat.c                            |  11 +-
 net/netfilter/nft_objref.c                         | 226 +++++++
 net/netfilter/nft_payload.c                        | 107 ++-
 net/netfilter/nft_quota.c                          | 158 ++++-
 net/netfilter/nft_redir.c                          |   6 +-
 net/netfilter/nft_set_hash.c                       |  25 +-
 net/netfilter/nft_set_rbtree.c                     |  12 +-
 net/netfilter/x_tables.c                           |  58 +-
 net/netfilter/xt_CONNSECMARK.c                     |   4 +-
 net/netfilter/xt_CT.c                              |   6 +-
 net/netfilter/xt_NETMAP.c                          |  11 +-
 net/netfilter/xt_REDIRECT.c                        |  12 +-
 net/netfilter/xt_TPROXY.c                          |  15 +-
 net/netfilter/xt_bpf.c                             |  96 ++-
 net/netfilter/xt_connbytes.c                       |   4 +-
 net/netfilter/xt_connlabel.c                       |   6 +-
 net/netfilter/xt_connlimit.c                       |   6 +-
 net/netfilter/xt_connmark.c                        |   8 +-
 net/netfilter/xt_conntrack.c                       |   4 +-
 net/netfilter/xt_helper.c                          |   4 +-
 net/netfilter/xt_multiport.c                       |  26 +-
 net/netfilter/xt_nat.c                             |  18 +-
 net/netfilter/xt_socket.c                          |  33 +-
 net/netfilter/xt_state.c                           |   4 +-
 90 files changed, 2513 insertions(+), 661 deletions(-)
 create mode 100644 net/netfilter/nft_objref.c
