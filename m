From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 3/4] fib_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 18:02:40 +0900
Message-ID: <007e01c8300b$1a1f46d0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:16738 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259AbXKZJCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 04:02:48 -0500
Received: by rv-out-0910.google.com with SMTP id k20so461211rvb
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 01:02:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fib_hash: kmalloc + memset conversion to kzalloc

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

Thanks.
Joonwoo

---
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 527a6e0..2874fe7 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -102,10 +102,14 @@ static struct hlist_head *fz_hash_alloc(int divisor)
 	unsigned long size = divisor * sizeof(struct hlist_head);
 
 	if (size <= PAGE_SIZE) {
-		return kmalloc(size, GFP_KERNEL);
+		return kzalloc(size, GFP_KERNEL);
 	} else {
-		return (struct hlist_head *)
+		struct hlist_head *hash;
+		hash = (struct hlist_head *)
 			__get_free_pages(GFP_KERNEL, get_order(size));
+		if (hash)
+			memset(hash, 0, size);
+		return hash;
 	}
 }
 
@@ -174,8 +178,6 @@ static void fn_rehash_zone(struct fn_zone *fz)
 	ht = fz_hash_alloc(new_divisor);
 
 	if (ht)	{
-		memset(ht, 0, new_divisor * sizeof(struct hlist_head));
-
 		write_lock_bh(&fib_hash_lock);
 		old_ht = fz->fz_hash;
 		fz->fz_hash = ht;
@@ -219,7 +221,6 @@ fn_new_zone(struct fn_hash *table, int z)
 		kfree(fz);
 		return NULL;
 	}
-	memset(fz->fz_hash, 0, fz->fz_divisor * sizeof(struct hlist_head *));
 	fz->fz_order = z;
 	fz->fz_mask = inet_make_mask(z);
 
---

