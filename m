From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: [PATCH] locking bug in fib_semantics.c
Date: Thu, 17 Aug 2006 13:36:15 +0400
Message-ID: <20060817093615.GA25553@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:44261 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964779AbWHQJhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 05:37:04 -0400
To: davem@davemloft.net, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

[IPV4]: severe locking bug in fib_semantics.c

The patch is for net-2.6.19, but the bug is present in all the kernels
since yore.

Found in 2.4 by Yixin Pan <yxpan@hotmail.com>. Why do we need lockdep,
when sharp-sighted eyes are available? :-)

> When I read fib_semantics.c of Linux-2.4.32, write_lock(&fib_info_lock) =
> is used in fib_release_info() instead of write_lock_bh(&fib_info_lock).  =
> Is the following case possible: a BH interrupts fib_release_info() while =
> holding the write lock, and calls ip_check_fib_default() which calls =
> read_lock(&fib_info_lock), and spin forever.


Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 4ea6c68..5dfdad5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -159,7 +159,7 @@ void free_fib_info(struct fib_info *fi)
 
 void fib_release_info(struct fib_info *fi)
 {
-	spin_lock(&fib_info_lock);
+	spin_lock_bh(&fib_info_lock);
 	if (fi && --fi->fib_treeref == 0) {
 		hlist_del(&fi->fib_hash);
 		if (fi->fib_prefsrc)
@@ -172,7 +172,7 @@ void fib_release_info(struct fib_info *f
 		fi->fib_dead = 1;
 		fib_info_put(fi);
 	}
-	spin_unlock(&fib_info_lock);
+	spin_unlock_bh(&fib_info_lock);
 }
 
 static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
@@ -598,7 +598,7 @@ static void fib_hash_move(struct hlist_h
 	unsigned int old_size = fib_hash_size;
 	unsigned int i, bytes;
 
-	spin_lock(&fib_info_lock);
+	spin_lock_bh(&fib_info_lock);
 	old_info_hash = fib_info_hash;
 	old_laddrhash = fib_info_laddrhash;
 	fib_hash_size = new_size;
@@ -639,7 +639,7 @@ static void fib_hash_move(struct hlist_h
 	}
 	fib_info_laddrhash = new_laddrhash;
 
-	spin_unlock(&fib_info_lock);
+	spin_unlock_bh(&fib_info_lock);
 
 	bytes = old_size * sizeof(struct hlist_head *);
 	fib_hash_free(old_info_hash, bytes);
@@ -820,7 +820,7 @@ link_it:
 
 	fi->fib_treeref++;
 	atomic_inc(&fi->fib_clntref);
-	spin_lock(&fib_info_lock);
+	spin_lock_bh(&fib_info_lock);
 	hlist_add_head(&fi->fib_hash,
 		       &fib_info_hash[fib_info_hashfn(fi)]);
 	if (fi->fib_prefsrc) {
@@ -839,7 +839,7 @@ link_it:
 		head = &fib_info_devhash[hash];
 		hlist_add_head(&nh->nh_hash, head);
 	} endfor_nexthops(fi)
-	spin_unlock(&fib_info_lock);
+	spin_unlock_bh(&fib_info_lock);
 	return fi;
 
 err_inval:

