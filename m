From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/7] batman-adv: Use common Jenkins Hash implementation
Date: Tue,  9 Jun 2015 12:50:14 +0200
Message-ID: <1433847020-1427-2-git-send-email-antonio@meshcoding.com>
References: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:25232 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326AbbFIKw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 06:52:26 -0400
In-Reply-To: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

An unoptimized version of the Jenkins one-at-a-time hash function is used
and partially copied all over the code wherever an hashtable is used.
Instead the optimized version shared between the whole kernel should be
used to reduce code duplication and use better optimized code.

Only the DAT code must use the old implementation because it is used as
distributed hash function which has to be common for all nodes.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bridge_loop_avoidance.c | 16 ++++------------
 net/batman-adv/distributed-arp-table.c | 17 +++++++++++++++--
 net/batman-adv/hash.h                  | 22 ----------------------
 net/batman-adv/main.h                  |  1 +
 net/batman-adv/network-coding.c        | 10 ++--------
 net/batman-adv/originator.h            | 13 +------------
 net/batman-adv/translation-table.c     |  8 ++------
 7 files changed, 25 insertions(+), 62 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index fa941cd..f2ac903 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -42,12 +42,8 @@ static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
 	struct batadv_bla_claim *claim = (struct batadv_bla_claim *)data;
 	uint32_t hash = 0;
 
-	hash = batadv_hash_bytes(hash, &claim->addr, sizeof(claim->addr));
-	hash = batadv_hash_bytes(hash, &claim->vid, sizeof(claim->vid));
-
-	hash += (hash << 3);
-	hash ^= (hash >> 11);
-	hash += (hash << 15);
+	hash = jhash(&claim->addr, sizeof(claim->addr), hash);
+	hash = jhash(&claim->vid, sizeof(claim->vid), hash);
 
 	return hash % size;
 }
@@ -59,12 +55,8 @@ static inline uint32_t batadv_choose_backbone_gw(const void *data,
 	const struct batadv_bla_claim *claim = (struct batadv_bla_claim *)data;
 	uint32_t hash = 0;
 
-	hash = batadv_hash_bytes(hash, &claim->addr, sizeof(claim->addr));
-	hash = batadv_hash_bytes(hash, &claim->vid, sizeof(claim->vid));
-
-	hash += (hash << 3);
-	hash ^= (hash >> 11);
-	hash += (hash << 15);
+	hash = jhash(&claim->addr, sizeof(claim->addr), hash);
+	hash = jhash(&claim->vid, sizeof(claim->vid), hash);
 
 	return hash % size;
 }
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index da1742d..2e6198e 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -206,9 +206,22 @@ static uint32_t batadv_hash_dat(const void *data, uint32_t size)
 {
 	uint32_t hash = 0;
 	const struct batadv_dat_entry *dat = data;
+	const unsigned char *key;
+	uint32_t i;
 
-	hash = batadv_hash_bytes(hash, &dat->ip, sizeof(dat->ip));
-	hash = batadv_hash_bytes(hash, &dat->vid, sizeof(dat->vid));
+	key = (const unsigned char *)&dat->ip;
+	for (i = 0; i < sizeof(dat->ip); i++) {
+		hash += key[i];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
+
+	key = (const unsigned char *)&dat->vid;
+	for (i = 0; i < sizeof(dat->vid); i++) {
+		hash += key[i];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
 
 	hash += (hash << 3);
 	hash ^= (hash >> 11);
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 379e32a..bcf427c 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -80,28 +80,6 @@ static inline void batadv_hash_delete(struct batadv_hashtable *hash,
 }
 
 /**
- *	batadv_hash_bytes - hash some bytes and add them to the previous hash
- *	@hash: previous hash value
- *	@data: data to be hashed
- *	@size: number of bytes to be hashed
- *
- *	Returns the new hash value.
- */
-static inline uint32_t batadv_hash_bytes(uint32_t hash, const void *data,
-					 uint32_t size)
-{
-	const unsigned char *key = data;
-	int i;
-
-	for (i = 0; i < size; i++) {
-		hash += key[i];
-		hash += (hash << 10);
-		hash ^= (hash >> 6);
-	}
-	return hash;
-}
-
-/**
  *	batadv_hash_add - adds data to the hashtable
  *	@hash: storage hash table
  *	@compare: callback to determine if 2 hash elements are identical
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index af0a336..985d017 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -174,6 +174,7 @@ enum batadv_uev_type {
 #include <linux/workqueue.h>	/* workqueue */
 #include <linux/percpu.h>
 #include <linux/slab.h>
+#include <linux/jhash.h>
 #include <net/sock.h>		/* struct sock */
 #include <net/addrconf.h>	/* ipv6 address stuff */
 #include <linux/ip.h>
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index b984bc4..fb54319a 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -453,14 +453,8 @@ static uint32_t batadv_nc_hash_choose(const void *data, uint32_t size)
 	const struct batadv_nc_path *nc_path = data;
 	uint32_t hash = 0;
 
-	hash = batadv_hash_bytes(hash, &nc_path->prev_hop,
-				 sizeof(nc_path->prev_hop));
-	hash = batadv_hash_bytes(hash, &nc_path->next_hop,
-				 sizeof(nc_path->next_hop));
-
-	hash += (hash << 3);
-	hash ^= (hash >> 11);
-	hash += (hash << 15);
+	hash = jhash(&nc_path->prev_hop, sizeof(nc_path->prev_hop), hash);
+	hash = jhash(&nc_path->next_hop, sizeof(nc_path->next_hop), hash);
 
 	return hash % size;
 }
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 9133914..0b716fe 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -75,20 +75,9 @@ void batadv_orig_node_vlan_free_ref(struct batadv_orig_node_vlan *orig_vlan);
  */
 static inline uint32_t batadv_choose_orig(const void *data, uint32_t size)
 {
-	const unsigned char *key = data;
 	uint32_t hash = 0;
-	size_t i;
-
-	for (i = 0; i < 6; i++) {
-		hash += key[i];
-		hash += (hash << 10);
-		hash ^= (hash >> 6);
-	}
-
-	hash += (hash << 3);
-	hash ^= (hash >> 11);
-	hash += (hash << 15);
 
+	hash = jhash(data, ETH_ALEN, hash);
 	return hash % size;
 }
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b098e53..fe9f824 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -67,12 +67,8 @@ static inline uint32_t batadv_choose_tt(const void *data, uint32_t size)
 	uint32_t hash = 0;
 
 	tt = (struct batadv_tt_common_entry *)data;
-	hash = batadv_hash_bytes(hash, &tt->addr, ETH_ALEN);
-	hash = batadv_hash_bytes(hash, &tt->vid, sizeof(tt->vid));
-
-	hash += (hash << 3);
-	hash ^= (hash >> 11);
-	hash += (hash << 15);
+	hash = jhash(&tt->addr, ETH_ALEN, hash);
+	hash = jhash(&tt->vid, sizeof(tt->vid), hash);
 
 	return hash % size;
 }
-- 
2.4.2
