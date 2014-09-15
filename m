From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/5 RFC net-next] rhashtable: Parallel atomic insert/deletion & deferred expansion
Date: Mon, 15 Sep 2014 14:17:59 +0200
Message-ID: <cover.1410782841.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, john.r.fastabend@intel.com,
	kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is still work in progress but I wanted to share this as soon as the
direction where this is heading to becomes clear.

 * Patch 1: Remove gfp_t awareness
 * Patch 2: Enhance selftest to catch traversal miscount
 * Patch 3: Nulls marker convertion
 * Patch 4: Add spin_lock_bh_nested()
 * Patch 5: Per bucket spinlock, deferred expansion/shrinking

Paul, Eric, John, Dave: Let me know how far off this is from what you had
in mind.

Opens: 
 * I'm in particular interested in the feasibility of the side effect
   regarding recent insertion visibility in bucket traversals (see below).
   I think current users of rhashtable can live with it but it might be
   worth to offer a synchronous expansion alternative at some point.

   If anybody has a better alternative I'm definitely interested to hear
   about it.

 * Convert inet hashtable over to this and see if it is missing anything.

 * Own worker thread as we might eventually sleep for multiple grace
   periods?

 * Yes, some of the rcu_assign_pointer() can probably be replaced with
   RCU_INIT_POINTER().

Converts the single linked list to us a nulls marker. Reserves 4 bits to
distinguish list membership. Stores a full 27 bit hash as the default
marker. This allows the marker to stay valid even if the stable expands
or shrinks.

Introduces an array of spinlocks to protect bucket mutations. The number
of spinlocks per CPU is configurable and selected based on the hash of
the bucket. This allows for parallel insertions and removals of entries
which do not share a lock.

The patch also defers expansion and shrinking to a worker queue which
allow insertion and removal from atomic context. Insertions and
deletions may occur in parallel to it and are only held up briefly
while the particular bucket is linked or unzipped.

Mutations of the bucket table pointer is protected by a new mutex taken
during expansion and shrinking, read access to that pointer for insertion
and deletion is RCU protected.

In the event of an expansion or shrinking, the new bucket table allocated
is exposed as a so called future table right away. Lookups, deletions, and
insertions will briefly use both tables. The future table becomes the main
table after an RCU grace period and initial relinking was performed which
guarantees that no new insertions occur on the old table and all entries
can be found.

The side effect of this is that during that RCU grace period, a bucket
traversal using any rht_for_each() variant on the main table will not see
any insertions performed during the RCU grace period which would at that
point land in the future table. The lookup will see them as it searches
both tables if needed.

Thomas Graf (5):
  rhashtable: Remove gfp_flags from insert and remove functions
  rhashtable: Check for count misatch in selftest
  rhashtable: Convert to nulls list
  spinlock: Add spin_lock_bh_nested()
  rhashtable: Per bucket locks & expansion/shrinking in work queue

 include/linux/list_nulls.h       |   3 +-
 include/linux/rhashtable.h       | 241 +++++++++++------
 include/linux/spinlock.h         |   8 +
 include/linux/spinlock_api_smp.h |   2 +
 include/linux/spinlock_api_up.h  |   1 +
 kernel/locking/spinlock.c        |   8 +
 lib/rhashtable.c                 | 539 ++++++++++++++++++++++++++-------------
 net/netfilter/nft_hash.c         |  69 ++---
 net/netlink/af_netlink.c         |  18 +-
 net/netlink/diag.c               |   4 +-
 10 files changed, 604 insertions(+), 289 deletions(-)

-- 
1.9.3
