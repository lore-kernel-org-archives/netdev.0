From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH v2 0/3 net-next] Lockless netlink_lookup() with new concurrent hash table
Date: Fri,  1 Aug 2014 00:56:00 +0200
Message-ID: <cover.1406846586.git.tgraf@suug.ch>
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	challa@noironetworks.com, walpole@cs.pdx.edu, dev@openvswitch.org,
	tklauser@distanz.ch, netfilter-devel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50149 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbaGaW4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 18:56:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 net/netfilter/nft_hash.c   | 291 +++--------------
 net/netlink/af_netlink.c   | 285 ++++++----------
 net/netlink/af_netlink.h   |  18 +-
 net/netlink/diag.c         |  11 +-
 8 files changed, 1190 insertions(+), 435 deletions(-)
 create mode 100644 include/linux/rhashtable.h
 create mode 100644 lib/rhashtable.c

-- 
1.9.3
