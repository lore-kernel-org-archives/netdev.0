From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NETLINK : kzalloc() conversion
Date: Tue, 11 Dec 2007 06:40:18 +0100
Message-ID: <475E22C2.9050700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050706030902030602040404"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55777 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbXLKFk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 00:40:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050706030902030602040404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

nl_pid_hash_alloc() is renamed to nl_pid_hash_zalloc().
It is now returning zeroed memory to its callers.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------050706030902030602040404
Content-Type: text/plain;
 name="netlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink.patch"

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2e02b19..dbd7cad 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -237,13 +237,14 @@ found:
 	return sk;
 }
 
-static inline struct hlist_head *nl_pid_hash_alloc(size_t size)
+static inline struct hlist_head *nl_pid_hash_zalloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
-		return kmalloc(size, GFP_ATOMIC);
+		return kzalloc(size, GFP_ATOMIC);
 	else
 		return (struct hlist_head *)
-			__get_free_pages(GFP_ATOMIC, get_order(size));
+			__get_free_pages(GFP_ATOMIC | __GFP_ZERO,
+					 get_order(size));
 }
 
 static inline void nl_pid_hash_free(struct hlist_head *table, size_t size)
@@ -272,11 +273,10 @@ static int nl_pid_hash_rehash(struct nl_pid_hash *hash, int grow)
 		size *= 2;
 	}
 
-	table = nl_pid_hash_alloc(size);
+	table = nl_pid_hash_zalloc(size);
 	if (!table)
 		return 0;
 
-	memset(table, 0, size);
 	otable = hash->table;
 	hash->table = table;
 	hash->mask = mask;
@@ -1919,7 +1919,7 @@ static int __init netlink_proto_init(void)
 	for (i = 0; i < MAX_LINKS; i++) {
 		struct nl_pid_hash *hash = &nl_table[i].hash;
 
-		hash->table = nl_pid_hash_alloc(1 * sizeof(*hash->table));
+		hash->table = nl_pid_hash_zalloc(1 * sizeof(*hash->table));
 		if (!hash->table) {
 			while (i-- > 0)
 				nl_pid_hash_free(nl_table[i].hash.table,
@@ -1927,7 +1927,6 @@ static int __init netlink_proto_init(void)
 			kfree(nl_table);
 			goto panic;
 		}
-		memset(hash->table, 0, 1 * sizeof(*hash->table));
 		hash->max_shift = order;
 		hash->shift = 0;
 		hash->mask = 0;

--------------050706030902030602040404--
