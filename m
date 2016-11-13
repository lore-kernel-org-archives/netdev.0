From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/39] Netfilter updates for net-next
Date: Sun, 13 Nov 2016 23:24:54 +0100
Message-ID: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47590 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935074AbcKMWZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:25:58 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E86A5A7E92
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:25:56 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C84CADA809
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:25:56 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 04D35DA803
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:25:54 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains a second batch of Netfilter updates for
your net-next tree. This includes a rework of the core hook
infrastructure that improves Netfilter performance by ~15% according to
synthetic benchmarks. Then, a large batch with ipset updates, including
a new hash:ipmac set type, via Jozsef Kadlecsik. This also includes a
couple of assorted updates.

Regarding the core hook infrastructure rework to improve performance,
using this simple drop-all packets ruleset from ingress:

        nft add table netdev x
        nft add chain netdev x y { type filter hook ingress device eth0 priority 0\; }
        nft add rule netdev x y drop

And generating traffic through Jesper Brouer's
samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh script using -i
option. perf report shows nf_tables calls in its top 10:

    17.30%  kpktgend_0   [nf_tables]            [k] nft_do_chain
    15.75%  kpktgend_0   [kernel.vmlinux]       [k] __netif_receive_skb_core
    10.39%  kpktgend_0   [nf_tables_netdev]     [k] nft_do_chain_netdev

I'm measuring here an improvement of ~15% in performance with this
patchset, so we got +2.5Mpps more. I have used my old laptop Intel(R)
Core(TM) i5-3320M CPU @ 2.60GHz 4-cores.

This rework contains more specifically, in strict order, these patches:

1) Remove compile-time debugging from core.

2) Remove obsolete comments that predate the rcu era. These days it is
   well known that a Netfilter hook always runs under rcu_read_lock().

3) Remove threshold handling, this is only used by br_netfilter too.
   We already have specific code to handle this from br_netfilter,
   so remove this code from the core path.

4) Deprecate NF_STOP, as this is only used by br_netfilter.

5) Place nf_state_hook pointer into xt_action_param structure, so
   this structure fits into one single cacheline according to pahole.
   This also implicit affects nftables since it also relies on the
   xt_action_param structure.

6) Move state->hook_entries into nf_queue entry. The hook_entries
   pointer is only required by nf_queue(), so we can store this in the
   queue entry instead.

7) use switch() statement to handle verdict cases.

8) Remove hook_entries field from nf_hook_state structure, this is only
   required by nf_queue, so store it in nf_queue_entry structure.

9) Merge nf_iterate() into nf_hook_slow() that results in a much more
   simple and readable function.

10) Handle NF_REPEAT away from the core, so far the only client is
    nf_conntrack_in() and we can restart the packet processing using a
    simple goto to jump back there when the TCP requires it.
    This update required a second pass to fix fallout, fix from
    Arnd Bergmann.

11) Set random seed from nft_hash when no seed is specified from
    userspace.

12) Simplify nf_tables expression registration, in a much smarter way
    to save lots of boiler plate code, by Liping Zhang.

13) Simplify layer 4 protocol conntrack tracker registration, from
    Davide Caratti.

14) Missing CONFIG_NF_SOCKET_IPV4 dependency for udp4_lib_lookup, due
    to recent generalization of the socket infrastructure, from Arnd
    Bergmann.

15) Then, the ipset batch from Jozsef, he describes it as it follows:

* Cleanup: Remove extra whitespaces in ip_set.h
* Cleanup: Mark some of the helpers arguments as const in ip_set.h
* Cleanup: Group counter helper functions together in ip_set.h
* struct ip_set_skbinfo is introduced instead of open coded fields
  in skbinfo get/init helper funcions.
* Use kmalloc() in comment extension helper instead of kzalloc()
  because it is unnecessary to zero out the area just before
  explicit initialization.
* Cleanup: Split extensions into separate files.
* Cleanup: Separate memsize calculation code into dedicated function.
* Cleanup: group ip_set_put_extensions() and ip_set_get_extensions()
  together.
* Add element count to hash headers by Eric B Munson.
* Add element count to all set types header for uniform output
  across all set types.
* Count non-static extension memory into memsize calculation for
  userspace.
* Cleanup: Remove redundant mtype_expire() arguments, because
  they can be get from other parameters.
* Cleanup: Simplify mtype_expire() for hash types by removing
  one level of intendation.
* Make NLEN compile time constant for hash types.
* Make sure element data size is a multiple of u32 for the hash set
  types.
* Optimize hash creation routine, exit as early as possible.
* Make struct htype per ipset family so nets array becomes fixed size
  and thus simplifies the struct htype allocation.
* Collapse same condition body into a single one.
* Fix reported memory size for hash:* types, base hash bucket structure
  was not taken into account.
* hash:ipmac type support added to ipset by Tomasz Chilinski.
* Use setup_timer() and mod_timer() instead of init_timer()
  by Muhammad Falak R Wani, individually for the set type families.

16) Remove useless connlabel field in struct netns_ct, patch from
    Florian Westphal.

17) xt_find_table_lock() doesn't return ERR_PTR() anymore, so simplify
    {ip,ip6,arp}tables code that uses this.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 17197236d62c44da127be461c63ac5cc2cce1e53:

  enic: set skb->hash type properly (2016-11-02 15:32:53 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to eb1a6bdc28268afa964e4c9f3399961dff9fd691:

  netfilter: x_tables: simplify IS_ERR_OR_NULL to NULL test (2016-11-13 22:26:13 +0100)

----------------------------------------------------------------
Arnd Bergmann (2):
      udp: provide udp{4,6}_lib_lookup for nf_socket_ipv{4,6}
      netfilter: conntrack: fix NF_REPEAT handling

Davide Caratti (1):
      netfilter: conntrack: simplify init/uninit of L4 protocol trackers

Eric B Munson (1):
      netfilter: ipset: Add element count to hash headers

Florian Westphal (1):
      netfilter: conntrack: remove unused netns_ct member

Jozsef Kadlecsik (19):
      netfilter: ipset: Remove extra whitespaces in ip_set.h
      netfilter: ipset: Mark some helper args as const.
      netfilter: ipset: Headers file cleanup
      netfilter: ipset: Improve skbinfo get/init helpers
      netfilter: ipset: Use kmalloc() in comment extension helper
      netfilter: ipset: Split extensions into separate files
      netfilter: ipset: Separate memsize calculation code into dedicated function
      netfilter: ipset: Regroup ip_set_put_extensions and add extern
      netfilter: ipset: Add element count to all set types header
      netfilter: ipset: Count non-static extension memory for userspace
      netfilter: ipset: Remove redundant mtype_expire() arguments
      netfilter: ipset: Simplify mtype_expire() for hash types
      netfilter: ipset: Make NLEN compile time constant for hash types
      netfilter: ipset: Make sure element data size is a multiple of u32
      netfilter: ipset: Optimize hash creation routine
      netfilter: ipset: Make struct htype per ipset family
      netfilter: ipset: Collapse same condition body to a single one
      netfilter: ipset: Fix reported memory size for hash:* types
      netfilter: ipset: use setup_timer() and mod_timer().

Julia Lawall (1):
      netfilter: x_tables: simplify IS_ERR_OR_NULL to NULL test

Liping Zhang (1):
      netfilter: nf_tables: simplify the basic expressions' init routine

Pablo Neira Ayuso (11):
      netfilter: get rid of useless debugging from core
      netfilter: remove comments that predate rcu days
      netfilter: kill NF_HOOK_THRESH() and state->tresh
      netfilter: deprecate NF_STOP
      netfilter: x_tables: move hook state into xt_action_param structure
      netfilter: nf_tables: use hook state from xt_action_param structure
      netfilter: use switch() to handle verdict cases from nf_hook_slow()
      netfilter: remove hook_entries field from nf_hook_state
      netfilter: merge nf_iterate() into nf_hook_slow()
      netfilter: handle NF_REPEAT from nf_conntrack_in()
      netfilter: nft_hash: get random bytes if seed is not specified

Tomasz Chilinski (1):
      netfilter: ipset: hash:ipmac type support added to ipset

kbuild test robot (1):
      netfilter: ipset: hash: fix boolreturn.cocci warnings

 include/linux/netfilter.h                      |  58 ++---
 include/linux/netfilter/ipset/ip_set.h         | 136 ++---------
 include/linux/netfilter/ipset/ip_set_bitmap.h  |   2 +-
 include/linux/netfilter/ipset/ip_set_comment.h |  11 +-
 include/linux/netfilter/ipset/ip_set_counter.h |  75 ++++++
 include/linux/netfilter/ipset/ip_set_skbinfo.h |  46 ++++
 include/linux/netfilter/ipset/ip_set_timeout.h |   4 +-
 include/linux/netfilter/x_tables.h             |  48 +++-
 include/linux/netfilter_ingress.h              |   4 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |  18 +-
 include/net/netfilter/nf_queue.h               |   1 +
 include/net/netfilter/nf_tables.h              |  36 ++-
 include/net/netfilter/nf_tables_core.h         |  33 +--
 include/net/netns/conntrack.h                  |   1 -
 include/uapi/linux/netfilter.h                 |   2 +-
 net/bridge/br_netfilter_hooks.c                |  16 +-
 net/bridge/netfilter/ebt_arpreply.c            |   3 +-
 net/bridge/netfilter/ebt_log.c                 |  11 +-
 net/bridge/netfilter/ebt_nflog.c               |   6 +-
 net/bridge/netfilter/ebt_redirect.c            |   6 +-
 net/bridge/netfilter/ebtable_broute.c          |   2 +-
 net/bridge/netfilter/ebtables.c                |   6 +-
 net/bridge/netfilter/nft_meta_bridge.c         |   2 +-
 net/bridge/netfilter/nft_reject_bridge.c       |  30 ++-
 net/ipv4/netfilter/arp_tables.c                |  26 +-
 net/ipv4/netfilter/ip_tables.c                 |  26 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c            |   3 +-
 net/ipv4/netfilter/ipt_REJECT.c                |   4 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |   4 +-
 net/ipv4/netfilter/ipt_rpfilter.c              |   2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  76 ++----
 net/ipv4/netfilter/nft_dup_ipv4.c              |   2 +-
 net/ipv4/netfilter/nft_fib_ipv4.c              |  14 +-
 net/ipv4/netfilter/nft_masq_ipv4.c             |   4 +-
 net/ipv4/netfilter/nft_redir_ipv4.c            |   3 +-
 net/ipv4/netfilter/nft_reject_ipv4.c           |   4 +-
 net/ipv4/udp.c                                 |   3 +-
 net/ipv6/netfilter/ip6_tables.c                |  26 +-
 net/ipv6/netfilter/ip6t_MASQUERADE.c           |   2 +-
 net/ipv6/netfilter/ip6t_REJECT.c               |  23 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |   4 +-
 net/ipv6/netfilter/ip6t_rpfilter.c             |   3 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  78 ++----
 net/ipv6/netfilter/nft_dup_ipv6.c              |   2 +-
 net/ipv6/netfilter/nft_fib_ipv6.c              |  16 +-
 net/ipv6/netfilter/nft_masq_ipv6.c             |   3 +-
 net/ipv6/netfilter/nft_redir_ipv6.c            |   3 +-
 net/ipv6/netfilter/nft_reject_ipv6.c           |   6 +-
 net/ipv6/udp.c                                 |   3 +-
 net/netfilter/core.c                           |  86 +++----
 net/netfilter/ipset/Kconfig                    |   9 +
 net/netfilter/ipset/Makefile                   |   1 +
 net/netfilter/ipset/ip_set_bitmap_gen.h        |  31 ++-
 net/netfilter/ipset/ip_set_core.c              |  20 +-
 net/netfilter/ipset/ip_set_hash_gen.h          | 254 +++++++++-----------
 net/netfilter/ipset/ip_set_hash_ip.c           |  10 +-
 net/netfilter/ipset/ip_set_hash_ipmac.c        | 315 +++++++++++++++++++++++++
 net/netfilter/ipset/ip_set_hash_ipmark.c       |  10 +-
 net/netfilter/ipset/ip_set_hash_ipport.c       |   6 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   6 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |  10 +-
 net/netfilter/ipset/ip_set_hash_net.c          |   8 +-
 net/netfilter/ipset/ip_set_hash_netiface.c     |  10 +-
 net/netfilter/ipset/ip_set_hash_netnet.c       |   8 +-
 net/netfilter/ipset/ip_set_hash_netport.c      |  10 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c   |  10 +-
 net/netfilter/ipset/ip_set_list_set.c          |  37 ++-
 net/netfilter/nf_conntrack_core.c              |  19 +-
 net/netfilter/nf_conntrack_proto.c             |  85 ++++++-
 net/netfilter/nf_conntrack_proto_dccp.c        |  48 +---
 net/netfilter/nf_conntrack_proto_gre.c         |  11 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |  50 +---
 net/netfilter/nf_conntrack_proto_udplite.c     |  50 +---
 net/netfilter/nf_dup_netdev.c                  |   2 +-
 net/netfilter/nf_internals.h                   |   5 -
 net/netfilter/nf_queue.c                       |  35 ++-
 net/netfilter/nf_tables_core.c                 |  90 +++----
 net/netfilter/nf_tables_trace.c                |   8 +-
 net/netfilter/nfnetlink_queue.c                |   2 +-
 net/netfilter/nft_bitwise.c                    |  13 +-
 net/netfilter/nft_byteorder.c                  |  13 +-
 net/netfilter/nft_cmp.c                        |  13 +-
 net/netfilter/nft_dynset.c                     |  13 +-
 net/netfilter/nft_fib.c                        |   2 +-
 net/netfilter/nft_fib_inet.c                   |   2 +-
 net/netfilter/nft_hash.c                       |   6 +-
 net/netfilter/nft_immediate.c                  |  13 +-
 net/netfilter/nft_log.c                        |   5 +-
 net/netfilter/nft_lookup.c                     |  18 +-
 net/netfilter/nft_meta.c                       |   6 +-
 net/netfilter/nft_payload.c                    |  13 +-
 net/netfilter/nft_queue.c                      |   2 +-
 net/netfilter/nft_range.c                      |  13 +-
 net/netfilter/nft_reject_inet.c                |  18 +-
 net/netfilter/nft_rt.c                         |   4 +-
 net/netfilter/x_tables.c                       |   2 +-
 net/netfilter/xt_AUDIT.c                       |  10 +-
 net/netfilter/xt_LOG.c                         |   6 +-
 net/netfilter/xt_NETMAP.c                      |  20 +-
 net/netfilter/xt_NFLOG.c                       |   6 +-
 net/netfilter/xt_NFQUEUE.c                     |   4 +-
 net/netfilter/xt_REDIRECT.c                    |   4 +-
 net/netfilter/xt_TCPMSS.c                      |   4 +-
 net/netfilter/xt_TEE.c                         |   4 +-
 net/netfilter/xt_TPROXY.c                      |  16 +-
 net/netfilter/xt_addrtype.c                    |  10 +-
 net/netfilter/xt_cluster.c                     |   2 +-
 net/netfilter/xt_connlimit.c                   |   8 +-
 net/netfilter/xt_conntrack.c                   |   8 +-
 net/netfilter/xt_devgroup.c                    |   4 +-
 net/netfilter/xt_dscp.c                        |   2 +-
 net/netfilter/xt_ipvs.c                        |   4 +-
 net/netfilter/xt_nfacct.c                      |   2 +-
 net/netfilter/xt_osf.c                         |  10 +-
 net/netfilter/xt_owner.c                       |   2 +-
 net/netfilter/xt_pkttype.c                     |   4 +-
 net/netfilter/xt_policy.c                      |   4 +-
 net/netfilter/xt_recent.c                      |  10 +-
 net/netfilter/xt_set.c                         |  38 +--
 net/netfilter/xt_socket.c                      |   4 +-
 net/openvswitch/conntrack.c                    |   8 +-
 net/sched/act_ipt.c                            |  12 +-
 net/sched/em_ipset.c                           |  17 +-
 123 files changed, 1351 insertions(+), 1171 deletions(-)
 create mode 100644 include/linux/netfilter/ipset/ip_set_counter.h
 create mode 100644 include/linux/netfilter/ipset/ip_set_skbinfo.h
 create mode 100644 net/netfilter/ipset/ip_set_hash_ipmac.c
