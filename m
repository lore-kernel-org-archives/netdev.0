From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: fold name hash properly (v3)
Date: Tue, 10 Nov 2009 09:20:34 -0800
Message-ID: <20091110092034.3d4ee9b0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49457 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbZKJRUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 12:20:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The full_name_hash function does not produce well distributed values in
the lower bits, so most code uses hash_32() to fold it.  This is really
a bug introduced when name hashing was added, back in 2.5 when I added
name hashing.

hash_32 is all that is needed since full_name_hash returns unsigned int
which is only 32 bits on 64 bit platforms.

Also, there is no point in using hash_32 on ifindex, because the is naturally
sequential and usually well distributed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next-2.6

--- a/net/core/dev.c	2009-11-09 22:19:08.731481514 -0800
+++ b/net/core/dev.c	2009-11-10 08:42:23.755003727 -0800
@@ -79,6 +79,7 @@
 #include <linux/cpu.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
+#include <linux/hash.h>
 #include <linux/sched.h>
 #include <linux/mutex.h>
 #include <linux/string.h>
@@ -196,7 +197,7 @@ EXPORT_SYMBOL(dev_base_lock);
 static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
 {
 	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
-	return &net->dev_name_head[hash & (NETDEV_HASHENTRIES - 1)];
+	return &net->dev_name_head[hash_32(hash, NETDEV_HASHBITS)];
 }
 
 static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
