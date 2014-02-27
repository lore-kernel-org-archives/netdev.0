From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/5] netfilter: conntrack: optimization,
	remove central spinlock
Date: Thu, 27 Feb 2014 17:41:10 +0100
Message-ID: <20140227163950.24668.55934.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbaB0QlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 11:41:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset change the conntrack locking and provides a huge
performance improvements.

This patchset is based upon Eric Dumazet's proposed patch:
  http://thread.gmane.org/gmane.linux.network/268758/focus=47306
I have in agreement with Eric Dumazet, taken over this patch (and
turned it into a entire patchset).

Primary focus is to remove the central spinlock nf_conntrack_lock.
This requires several steps to be acheived.

Patch01: Trivial cleanups

Patch02: Moves the "special" dying/unconfirmed/template lists to use a
 per cpu spinlock.

Patch03: Is preparing for patch04, as it address a race
 condition. Doing this a seperate patch for reviewers sake.

Patch04: Seperates expect locking from nf_conntrack_lock. The expect
 list is small (default max 256), this it just get a single lock.

Patch05: Finally can remove nf_conntrack_lock, and instead uses an
 array of hashed spinlocks to protect insertions/deletions of
 conntracks into the hash table.  While still allowing dynamic
 resizing of the hash table.


Testing
-------
For expectations I've mostly tested the FTP nf_conntrack_ftp
helper module, by commands:

 for x in `seq 1 300`; do \
   echo $x; \
   echo -e "USER anonymous\nPASS nothing\nPASV" | nc 192.168.42.129 21; \
 done

 wget ftp://192.168.42.129/pub/delete.me.4k -O /dev/null

For overload/DoS testing, I've primarily done, SYN-flood attack testing.
Results on a 24-core E5-2695v2(ES) with 10Gbit/s ixgbe (with tool trafgen)

 Base kernel : New   810.405 conntrack/sec
 Fixed kernel: New 2.233.876 conntrack/sec

Notice other floods attack (SYN+ACK or ACK) can easily be deflected using:
 # iptables -A INPUT -m state --state INVALID -j DROP
 # sysctl -w net/netfilter/nf_conntrack_tcp_loose=0

E.g. this machine can reflect 6.481.463 "invalid" conntrack/sec (from
an ACK-flood).

Perf data:
----------
The nf_conntrack_lock is suffers from huge contention on current
generation servers (8 or more core/threads).  Data from under
SYN-flooding (without a listen socket)

Perf locking congestion is very "visible" on a base kernel:

    -  72.56%  ksoftirqd/6  [kernel.kallsyms]    [k] _raw_spin_lock_bh
       - _raw_spin_lock_bh
          + 25.33% init_conntrack
          + 24.86% nf_ct_delete_from_lists
          + 24.62% __nf_conntrack_confirm
          + 24.38% destroy_conntrack
          + 0.70% tcp_packet
    +   2.21%  ksoftirqd/6  [kernel.kallsyms]    [k] fib_table_lookup
    +   1.15%  ksoftirqd/6  [kernel.kallsyms]    [k] __slab_free
    +   0.77%  ksoftirqd/6  [kernel.kallsyms]    [k] inet_getpeer
    +   0.70%  ksoftirqd/6  [nf_conntrack]       [k] nf_ct_delete
    +   0.55%  ksoftirqd/6  [ip_tables]          [k] ipt_do_table

Perf after the patchset (SYN-flood attack):

+   9.62%  ksoftirqd/6  [kernel.kallsyms]    [k] fib_table_lookup
+   3.78%  ksoftirqd/6  [kernel.kallsyms]    [k] __slab_free
+   2.71%  ksoftirqd/6  [kernel.kallsyms]    [k] inet_getpeer
+   2.55%  ksoftirqd/6  [kernel.kallsyms]    [k] check_leaf
+   2.38%  ksoftirqd/6  [ip_tables]          [k] ipt_do_table
+   2.06%  ksoftirqd/6  [kernel.kallsyms]    [k] __slab_alloc
+   1.94%  ksoftirqd/6  [nf_conntrack]       [k] __nf_conntrack_alloc
-   1.94%  ksoftirqd/6  [kernel.kallsyms]    [k] _raw_spin_lock
   - _raw_spin_lock
      + 90.32% nf_conntrack_double_lock
      + 3.61% get_partial_node
      + 1.81% nf_ct_delete_from_lists
      + 1.68% __nf_conntrack_confirm
      + 1.03% sch_direct_xmit
      + 0.52% scheduler_tick
+   1.86%  ksoftirqd/6  [kernel.kallsyms]    [k] nf_iterate
+   1.80%  ksoftirqd/6  [nf_conntrack]       [k] init_conntrack
+   1.77%  ksoftirqd/6  [kernel.kallsyms]    [k] __neigh_event_send
-   1.70%  ksoftirqd/6  [kernel.kallsyms]    [k] _raw_spin_lock_bh
   - _raw_spin_lock_bh
      + 32.55% nf_ct_del_from_dying_or_unconfirmed_list
      + 25.33% init_conntrack
      + 19.88% tcp_packet
      + 17.97% nf_ct_delete_from_lists
      + 1.62% nf_conntrack_in
      + 1.33% ixgbe_poll
      + 0.74% destroy_conntrack
+   1.64%  ksoftirqd/6  [nf_conntrack]       [k] hash_conntrack_raw
+   1.58%  ksoftirqd/6  [kernel.kallsyms]    [k] __netif_receive_skb_core
+   1.51%  ksoftirqd/6  [nf_conntrack]       [k] __nf_conntrack_find_get
+   1.48%  ksoftirqd/6  [kernel.kallsyms]    [k] __cmpxchg_double_slab
+   1.46%  ksoftirqd/6  [nf_conntrack]       [k] nf_conntrack_in
+   1.45%  ksoftirqd/6  [kernel.kallsyms]    [k] __local_bh_enable_ip


---

Jesper Dangaard Brouer (5):
      netfilter: conntrack: remove central spinlock nf_conntrack_lock
      netfilter: conntrack: seperate expect locking from nf_conntrack_lock
      netfilter: avoid race with exp->master ct
      netfilter: conntrack: spinlock per cpu to protect special lists.
      netfilter: trivial code cleanup and doc changes


 include/net/netfilter/nf_conntrack.h      |   11 +
 include/net/netfilter/nf_conntrack_core.h |    9 +
 include/net/netns/conntrack.h             |   13 +
 net/netfilter/nf_conntrack_core.c         |  427 ++++++++++++++++++++---------
 net/netfilter/nf_conntrack_expect.c       |   36 ++
 net/netfilter/nf_conntrack_h323_main.c    |    4 
 net/netfilter/nf_conntrack_helper.c       |   37 ++-
 net/netfilter/nf_conntrack_netlink.c      |  128 +++++----
 net/netfilter/nf_conntrack_sip.c          |    8 -
 9 files changed, 456 insertions(+), 217 deletions(-)

-- 
