From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3] bridge: simpler hash with salt
Date: Tue, 20 Mar 2007 14:17:09 -0700
Message-ID: <20070320141709.4ebb79ec@dxpl.pdx.osdl.net>
References: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60764 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753368AbXCTVUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 17:20:13 -0400
In-Reply-To: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of hashing the whole Ethernet address, it should be faster
to just use the last 4 bytes. Add a random salt value to the hash
to make it more difficult to construct worst case DoS hash chains.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/bridge/br_fdb.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

--- skge-dev.orig/net/bridge/br_fdb.c
+++ skge-dev/net/bridge/br_fdb.c
@@ -20,19 +20,24 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/jhash.h>
+#include <linux/random.h>
 #include <asm/atomic.h>
+#include <asm/unaligned.h>
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		      const unsigned char *addr);
 
+static u32 fdb_salt __read_mostly;
+
 void __init br_fdb_init(void)
 {
 	br_fdb_cache = kmem_cache_create("bridge_fdb_cache",
 					 sizeof(struct net_bridge_fdb_entry),
 					 0,
 					 SLAB_HWCACHE_ALIGN, NULL, NULL);
+	get_random_bytes(&fdb_salt, sizeof(fdb_salt));
 }
 
 void __exit br_fdb_fini(void)
@@ -44,24 +49,26 @@ void __exit br_fdb_fini(void)
 /* if topology_changing then use forward_delay (default 15 sec)
  * otherwise keep longer (default 5 minutes)
  */
-static __inline__ unsigned long hold_time(const struct net_bridge *br)
+static inline unsigned long hold_time(const struct net_bridge *br)
 {
 	return br->topology_change ? br->forward_delay : br->ageing_time;
 }
 
-static __inline__ int has_expired(const struct net_bridge *br,
+static inline int has_expired(const struct net_bridge *br,
 				  const struct net_bridge_fdb_entry *fdb)
 {
 	return !fdb->is_static
 		&& time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
 }
 
-static __inline__ int br_mac_hash(const unsigned char *mac)
+static inline int br_mac_hash(const unsigned char *mac)
 {
-	return jhash(mac, ETH_ALEN, 0) & (BR_HASH_SIZE - 1);
+	/* use 1 byte of OUI cnd 3 bytes of NIC */
+	u32 key = get_unaligned((u32 *)(mac + 2));
+	return jhash_1word(key, fdb_salt) & (BR_HASH_SIZE - 1);
 }
 
-static __inline__ void fdb_delete(struct net_bridge_fdb_entry *f)
+static inline void fdb_delete(struct net_bridge_fdb_entry *f)
 {
 	hlist_del_rcu(&f->hlist);
 	br_fdb_put(f);
