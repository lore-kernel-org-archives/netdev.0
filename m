From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next v5 0/3] Lockless netlink_lookup() with
	new concurrent hash table
Date: Sat,  2 Aug 2014 11:47:43 +0200
Message-ID: <cover.1406971567.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Netlink sockets are maintained in a hash table to allow efficient lookup
via the port ID for unicast messages. However, lookups currently require
a read lock to be taken. This series adds a new generic, resizable,
scalable, concurrent hash table based on the paper referenced in the first
patch. It then makes use of the new data type to implement lockless
netlink_lookup().

Patch 3/3 to convert nft_hash is included for reference but should be
merged via the netfilter tree. Inclusion in this series is to provide
context for the suggested API.

Against net-next since the initial user of the new hash table is in net/

Changes:
v4-v5:
 - use GFP_KERNEL to alloc Netlink buckets as suggested by Nikolay
   Aleksandrov
 - free nft hash element on removal as spotted by Nikolay Aleksandrov
   and Patrick McHardy
v3-v4:
 - fixed wrong shift assignment placement as spotted by Nikolay Aleksandrov
 - reverted default size of nft_hash to 4 as requested by Patrick McHardy,
   default size for other hash tables remains at 64 if no hint is given
 - fixed copyright as requested by Patrick McHardy
v2-v3:
 - fixed typo in nft_hash_destroy() when passing rhashtable handle
v1-v2:
 - fixed traversal off-by-one as spotted by Tobias Klauser
 - removed unlikely() from BUG_ON() as spotted by Josh Triplett
 - new 3rd patch to convert nft_hash to rhashtable
 - make rhashtable_insert() return void
 - nl_sk_hash_lock must be a mutex
 - fixed wrong name of rht_shrink_below_30()
 - exported symbols rht_grow_above_75() and rht_shrink_below_30()
 - allow table freeing with RCU callback

Thomas Graf (3):
  lib: Resizable, Scalable, Concurrent Hash Table
  netlink: Convert netlink_lookup() to use RCU protected hash table
  nftables: Convert nft_hash to use generic rhashtable

 include/linux/rhashtable.h | 213 ++++++++++++
 lib/Kconfig.debug          |   8 +
 lib/Makefile               |   2 +-
 lib/rhashtable.c           | 797 +++++++++++++++++++++++++++++++++++++++++++++
 net/netfilter/nft_hash.c   | 291 ++++-------------
 net/netlink/af_netlink.c   | 285 ++++++----------
 net/netlink/af_netlink.h   |  18 +-
 net/netlink/diag.c         |  11 +-
 8 files changed, 1193 insertions(+), 432 deletions(-)
 create mode 100644 include/linux/rhashtable.h
 create mode 100644 lib/rhashtable.c

-- 
1.9.3
