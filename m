From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 2/4] fib_semantics: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 18:02:39 +0900
Message-ID: <007d01c8300b$18be5740$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:16738 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754211AbXKZJCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 04:02:47 -0500
Received: by rv-out-0910.google.com with SMTP id k20so461211rvb
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 01:02:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fib_semantics: kmalloc + memset conversion to kzalloc

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

Thanks.
Joonwoo

---
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1351a26..87a1e72 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -605,10 +605,15 @@ static inline unsigned int fib_laddr_hashfn(__be32 val)
 static struct hlist_head *fib_hash_alloc(int bytes)
 {
 	if (bytes <= PAGE_SIZE)
-		return kmalloc(bytes, GFP_KERNEL);
-	else
-		return (struct hlist_head *)
+		return kzalloc(bytes, GFP_KERNEL);
+	else {
+		struct hlist_head *hash;
+		hash = (struct hlist_head *)
 			__get_free_pages(GFP_KERNEL, get_order(bytes));
+		if (hash)
+			memset(hash, 0, bytes);
+		return hash;
+	}
 }
 
 static void fib_hash_free(struct hlist_head *hash, int bytes)
@@ -712,12 +717,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		if (!new_info_hash || !new_laddrhash) {
 			fib_hash_free(new_info_hash, bytes);
 			fib_hash_free(new_laddrhash, bytes);
-		} else {
-			memset(new_info_hash, 0, bytes);
-			memset(new_laddrhash, 0, bytes);
-
+		} else
 			fib_hash_move(new_info_hash, new_laddrhash, new_size);
-		}
 
 		if (!fib_hash_size)
 			goto failure;
---

