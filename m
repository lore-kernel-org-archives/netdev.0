From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/35] Netfilter/IPVS updates for net-next
Date: Sat, 17 Oct 2015 13:32:35 +0200
Message-ID: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS updates for your net-next
tree. Most relevantly, updates for the nfnetlink_log to integrate with
conntrack, fixes for cttimeout and improvements for nf_queue core, they are:

1) Remove useless ifdef around static inline function in IPVS, from
   Eric W. Biederman.

2) Simplify the conntrack support for nfnetlink_queue: Merge
   nfnetlink_queue_ct.c file into nfnetlink_queue_core.c, then rename it back
   to nfnetlink_queue.c

3) Use y2038 safe timestamp from nfnetlink_queue.

4) Get rid of dead function definition in nf_conntrack, from Flavio
   Leitner.

5) Attach conntrack support for nfnetlink_log.c, from Ken-ichirou MATSUZAWA.
   This adds a new NETFILTER_NETLINK_GLUE_CT Kconfig switch that
   controls enabling both nfqueue and nflog integration with conntrack.
   The userspace application can request this via NFULNL_CFG_F_CONNTRACK
   configuration flag.

6) Remove unused netns variables in IPVS, from Eric W. Biederman and
   Simon Horman.

7) Put back the refcount on the cttimeout object from xt_CT.

8) Fix crash on cttimeout policy object removal. We have to flush out
   the cttimeout extension area of the conntrack not to refer to an unexisting
   object that was just removed.

9) Make sure rcu_callback completion before removing nfnetlink_cttimeout
   module removal.

10) Fix compilation warning in br_netfilter when no nf_defrag_ipv4 and
    nf_defrag_ipv6 are enabled. Patch from Arnd Bergmann.

11) Autoload ctnetlink dependencies when NFULNL_CFG_F_CONNTRACK is
    requested. Again from Ken-ichirou MATSUZAWA.

12) Don't use pointer to previous hook when reinjecting traffic via
    nf_queue with NF_REPEAT verdict since it may be already gone. This
    also avoids a deadloop if the userspace application keeps returning
    NF_REPEAT.

13) A bunch of cleanups for netfilter IPv4 and IPv6 code from Ian Morris.

14) Consolidate logger instance existence check in nfulnl_recv_config().

15) Fix broken atomicity when applying configuration updates to logger
    instances in nfnetlink_log.

16) Get rid of the .owner attribute in our hook object. We don't need
    this anymore since we're dropping pending packets that have escaped
    from the kernel when unremoving the hook. Patch from Florian Westphal.

17) Remove unnecessary rcu_read_lock() from nf_reinject code, we always
    assume RCU read side lock from .call_rcu in nfnetlink. Also from Florian.

18) Use static inline function instead of macros to define NF_HOOK() and
    NF_HOOK_COND() when no netfilter support in on, from Arnd Bergmann.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit e96f78ab2703f3b0d512f6b469bc685d2ef20475:

  tcp/dccp: add SLAB_DESTROY_BY_RCU flag for request sockets (2015-10-03 13:25:20 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to c8d71d08aa23679f56e7072358383442c6ede352:

  netfilter: ipv4: whitespace around operators (2015-10-16 19:19:23 +0200)

----------------------------------------------------------------
Arnd Bergmann (2):
      netfilter: bridge: avoid unused label warning
      netfilter: turn NF_HOOK into an inline function

David Ahern (1):
      ipvs: Remove possibly unused variable from ip_vs_out

Eric W. Biederman (1):
      ipvs: Don't protect ip_vs_addr_is_unicast with CONFIG_SYSCTL

Flavio Leitner (1):
      netfilter: remove dead code

Florian Westphal (4):
      netfilter: nfqueue: don't use prev pointer
      netfilter: remove hook owner refcounting
      netfilter: make nf_queue_entry_get_refs return void
      netfilter: nf_queue: remove rcu_read_lock calls

Ian Morris (12):
      netfilter: ip6_tables: label placement
      netfilter: ip6_tables: function definition layout
      netfilter: ipv6: code indentation
      netfilter: ipv6: whitespace around operators
      netfilter: ip6_tables: ternary operator layout
      netfilter: ip6_tables: improve if statements
      netfilter: ipv6: pointer cast layout
      netfilter: ipv4: label placement
      netfilter: ipv4: ternary operator layout
      netfilter: ipv4: function definition layout
      netfilter: ipv4: code indentation
      netfilter: ipv4: whitespace around operators

Ken-ichirou MATSUZAWA (5):
      netfilter: nfnetlink_queue: rename related to nfqueue attaching conntrack info
      netfilter: Kconfig rename QUEUE_CT to GLUE_CT
      netfilter: ctnetlink: add const qualifier to nfnl_hook.get_ct
      netfilter: nfnetlink_log: allow to attach conntrack
      netfilter: nfnetlink_log: autoload nf_conntrack_netlink module NFQA_CFG_F_CONNTRACK config flag

Pablo Neira (1):
      netfilter: nfnetlink_log: validate dependencies to avoid breaking atomicity

Pablo Neira Ayuso (9):
      netfilter: nfnetlink_queue: get rid of nfnetlink_queue_ct.c
      netfilter: rename nfnetlink_queue_core.c to nfnetlink_queue.c
      Merge tag 'ipvs3-for-v4.4' of https://git.kernel.org/.../horms/ipvs-next
      netfilter: nfnetlink_queue: use y2038 safe timestamp
      netfilter: xt_CT: don't put back reference to timeout policy object
      netfilter: conntrack: fix crash on timeout object removal
      nfnetlink_cttimeout: add rcu_barrier() on module removal
      Merge tag 'ipvs4-for-v4.4' of https://git.kernel.org/.../horms/ipvs-next
      netfilter: nfnetlink_log: consolidate check for instance in nfulnl_recv_config()

Simon Horman (1):
      ipvs: Remove possibly unused variables from ip_vs_conn_net_{init,cleanup}

 include/linux/netfilter.h                          |  36 +++++--
 include/net/netfilter/nf_conntrack.h               |   4 -
 include/net/netfilter/nf_conntrack_timeout.h       |  25 +++--
 include/net/netfilter/nf_queue.h                   |   2 +-
 include/net/netfilter/nfnetlink_queue.h            |  51 ----------
 include/uapi/linux/netfilter/nfnetlink_log.h       |   3 +
 net/bridge/br_netfilter_hooks.c                    |  23 +----
 net/bridge/netfilter/ebtable_filter.c              |   3 -
 net/bridge/netfilter/ebtable_nat.c                 |   3 -
 net/decnet/dn_route.c                              |   2 -
 net/ipv4/netfilter/arp_tables.c                    |  12 +--
 net/ipv4/netfilter/ip_tables.c                     |  20 ++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |   8 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |   4 +-
 net/ipv4/netfilter/ipt_ah.c                        |   2 +-
 net/ipv4/netfilter/iptable_nat.c                   |   4 -
 net/ipv4/netfilter/iptable_security.c              |   2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   6 --
 net/ipv4/netfilter/nf_defrag_ipv4.c                |   2 -
 net/ipv4/netfilter/nf_nat_snmp_basic.c             |   2 +-
 net/ipv6/netfilter/ip6_tables.c                    |  22 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |   4 +-
 net/ipv6/netfilter/ip6table_nat.c                  |   4 -
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   6 --
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |   4 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c            |   4 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c          |   2 -
 net/ipv6/netfilter/nf_reject_ipv6.c                |   4 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c          |   6 +-
 net/netfilter/Kconfig                              |  15 +--
 net/netfilter/Makefile                             |   2 -
 net/netfilter/core.c                               |  11 +-
 net/netfilter/ipvs/ip_vs_conn.c                    |  13 +--
 net/netfilter/ipvs/ip_vs_core.c                    |  17 +---
 net/netfilter/nf_conntrack_core.c                  |  12 ++-
 net/netfilter/nf_conntrack_netlink.c               |  98 +++++++++++++-----
 net/netfilter/nf_queue.c                           |  38 ++-----
 net/netfilter/nf_tables_api.c                      |   1 -
 net/netfilter/nfnetlink_cttimeout.c                |  34 +++++++
 net/netfilter/nfnetlink_log.c                      |  83 +++++++++------
 .../{nfnetlink_queue_core.c => nfnetlink_queue.c}  |  70 +++++++++----
 net/netfilter/nfnetlink_queue_ct.c                 | 113 ---------------------
 net/netfilter/x_tables.c                           |   1 -
 net/netfilter/xt_CT.c                              |   7 +-
 security/selinux/hooks.c                           |   5 -
 security/smack/smack_netfilter.c                   |   2 -
 46 files changed, 348 insertions(+), 444 deletions(-)
 delete mode 100644 include/net/netfilter/nfnetlink_queue.h
 rename net/netfilter/{nfnetlink_queue_core.c => nfnetlink_queue.c} (95%)
 delete mode 100644 net/netfilter/nfnetlink_queue_ct.c
