From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 3/3][ROUTE] Convert rt_hash_lock_init() macro into
 function
Date: Wed, 05 Dec 2007 20:09:27 +0300
Message-ID: <4756DB47.7050403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52060 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbXLERJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 12:09:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need in having this function exist in a form
of macro. Properly formatted function looks much better.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3b9c430..6714bbc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -235,16 +235,25 @@ struct rt_hash_bucket {
 
 static spinlock_t	*rt_hash_locks;
 # define rt_hash_lock_addr(slot) &rt_hash_locks[(slot) & (RT_HASH_LOCK_SZ - 1)]
-# define rt_hash_lock_init()	{ \
-		int i; \
-		rt_hash_locks = kmalloc(sizeof(spinlock_t) * RT_HASH_LOCK_SZ, GFP_KERNEL); \
-		if (!rt_hash_locks) panic("IP: failed to allocate rt_hash_locks\n"); \
-		for (i = 0; i < RT_HASH_LOCK_SZ; i++) \
-			spin_lock_init(&rt_hash_locks[i]); \
-		}
+
+static __init void rt_hash_lock_init(void)
+{
+	int i;
+
+	rt_hash_locks = kmalloc(sizeof(spinlock_t) * RT_HASH_LOCK_SZ,
+			GFP_KERNEL);
+	if (!rt_hash_locks)
+		panic("IP: failed to allocate rt_hash_locks\n");
+
+	for (i = 0; i < RT_HASH_LOCK_SZ; i++)
+		spin_lock_init(&rt_hash_locks[i]);
+}
 #else
 # define rt_hash_lock_addr(slot) NULL
-# define rt_hash_lock_init()
+
+static inline void rt_hash_lock_init(void)
+{
+}
 #endif
 
 static struct rt_hash_bucket 	*rt_hash_table;
-- 
1.5.3.4

