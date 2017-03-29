From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] Netfilter fixes for net
Date: Wed, 29 Mar 2017 14:14:02 +0200
Message-ID: <1490789650-7294-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains a rather large update with Netfilter
fixes, specifically targeted to incorrect RCU usage in several spots and
the userspace conntrack helper infrastructure (nfnetlink_cthelper),
more specifically they are:

1) expect_class_max is incorrect set via cthelper, as in kernel semantics
   mandate that this represents the array of expectation classes minus 1.
   Patch from Liping Zhang.

2) Expectation policy updates via cthelper are currently broken for several
   reasons: This code allows illegal changes in the policy such as changing
   the number of expeciation classes, it is leaking the updated policy and
   such update occurs with no RCU protection at all. Fix this by adding a
   new nfnl_cthelper_update_policy() that describes what is really legal on
   the update path.

3) Fix several memory leaks in cthelper, from Jeffy Chen.

4) synchronize_rcu() is missing in the removal path of several modules,
   this may lead to races since CPU may still be running on code that has
   just gone. Also from Liping Zhang.

5) Don't use the helper hashtable from cthelper, it is not safe to walk
   over those bits without the helper mutex. Fix this by introducing a
   new independent list for userspace helpers. From Liping Zhang.

6) nf_ct_extend_unregister() needs synchronize_rcu() to make sure no
   packets are walking on any conntrack extension that is gone after
   module removal, again from Liping.

7) nf_nat_snmp may crash if we fail to unregister the helper due to
   accidental leftover code, from Gao Feng.

8) Fix leak in nfnetlink_queue with secctx support, from Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit db7f00b8dba6d687b6ab1f2e9309acfd214fcb4b:

  tcp: tcp_get_info() should read tcp_time_stamp later (2017-03-16 21:37:13 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 77c1c03c5b8ef28e55bb0aff29b1e006037ca645:

  netfilter: nfnetlink_queue: fix secctx memory leak (2017-03-29 12:20:50 +0200)

----------------------------------------------------------------
Gao Feng (1):
      netfilter: nf_nat_snmp: Fix panic when snmp_trap_helper fails to register

Jeffy Chen (1):
      netfilter: nfnl_cthelper: Fix memory leak

Liping Zhang (5):
      netfilter: nfnl_cthelper: fix incorrect helper->expect_class_max
      netfilter: invoke synchronize_rcu after set the _hook_ to NULL
      netfilter: nfnl_cthelper: fix a race when walk the nf_ct_helper_hash table
      netfilter: nf_ct_ext: fix possible panic after nf_ct_extend_unregister
      netfilter: nfnetlink_queue: fix secctx memory leak

Pablo Neira Ayuso (1):
      netfilter: nfnl_cthelper: fix runtime expectation policy updates

 net/ipv4/netfilter/nf_nat_snmp_basic.c |  20 +--
 net/netfilter/nf_conntrack_ecache.c    |   2 +
 net/netfilter/nf_conntrack_extend.c    |  13 +-
 net/netfilter/nf_conntrack_netlink.c   |   1 +
 net/netfilter/nf_nat_core.c            |   2 +
 net/netfilter/nfnetlink_cthelper.c     | 287 +++++++++++++++++++++------------
 net/netfilter/nfnetlink_cttimeout.c    |   2 +-
 net/netfilter/nfnetlink_queue.c        |   9 +-
 8 files changed, 206 insertions(+), 130 deletions(-)
