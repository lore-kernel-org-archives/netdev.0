From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fib: convert reader/writer to spinlock
Date: Tue, 8 Aug 2006 11:01:00 -0700
Message-ID: <20060808110100.7fb24faf@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2752 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964960AbWHHSBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 14:01:44 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ther is no point in using a more expensive reader/writer lock
for a low contention lock like the fib_info_lock. The only
reader case is in handling route redirects.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- tcp-rcu.orig/net/ipv4/fib_semantics.c
+++ tcp-rcu/net/ipv4/fib_semantics.c
@@ -49,7 +49,7 @@
 
 #define FSprintk(a...)
 
-static DEFINE_RWLOCK(fib_info_lock);
+static DEFINE_SPINLOCK(fib_info_lock);
 static struct hlist_head *fib_info_hash;
 static struct hlist_head *fib_info_laddrhash;
 static unsigned int fib_hash_size;
@@ -159,7 +159,7 @@ void free_fib_info(struct fib_info *fi)
 
 void fib_release_info(struct fib_info *fi)
 {
-	write_lock(&fib_info_lock);
+	spin_lock(&fib_info_lock);
 	if (fi && --fi->fib_treeref == 0) {
 		hlist_del(&fi->fib_hash);
 		if (fi->fib_prefsrc)
@@ -172,7 +172,7 @@ void fib_release_info(struct fib_info *f
 		fi->fib_dead = 1;
 		fib_info_put(fi);
 	}
-	write_unlock(&fib_info_lock);
+	spin_unlock(&fib_info_lock);
 }
 
 static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
@@ -254,7 +254,7 @@ int ip_fib_check_default(u32 gw, struct 
 	struct fib_nh *nh;
 	unsigned int hash;
 
-	read_lock(&fib_info_lock);
+	spin_lock(&fib_info_lock);
 
 	hash = fib_devindex_hashfn(dev->ifindex);
 	head = &fib_info_devhash[hash];
@@ -262,12 +262,12 @@ int ip_fib_check_default(u32 gw, struct 
 		if (nh->nh_dev == dev &&
 		    nh->nh_gw == gw &&
 		    !(nh->nh_flags&RTNH_F_DEAD)) {
-			read_unlock(&fib_info_lock);
+			spin_unlock(&fib_info_lock);
 			return 0;
 		}
 	}
 
-	read_unlock(&fib_info_lock);
+	spin_unlock(&fib_info_lock);
 
 	return -1;
 }
@@ -598,7 +598,7 @@ static void fib_hash_move(struct hlist_h
 	unsigned int old_size = fib_hash_size;
 	unsigned int i, bytes;
 
-	write_lock(&fib_info_lock);
+	spin_lock(&fib_info_lock);
 	old_info_hash = fib_info_hash;
 	old_laddrhash = fib_info_laddrhash;
 	fib_hash_size = new_size;
@@ -639,7 +639,7 @@ static void fib_hash_move(struct hlist_h
 	}
 	fib_info_laddrhash = new_laddrhash;
 
-	write_unlock(&fib_info_lock);
+	spin_unlock(&fib_info_lock);
 
 	bytes = old_size * sizeof(struct hlist_head *);
 	fib_hash_free(old_info_hash, bytes);
@@ -821,7 +821,7 @@ link_it:
 
 	fi->fib_treeref++;
 	atomic_inc(&fi->fib_clntref);
-	write_lock(&fib_info_lock);
+	spin_lock(&fib_info_lock);
 	hlist_add_head(&fi->fib_hash,
 		       &fib_info_hash[fib_info_hashfn(fi)]);
 	if (fi->fib_prefsrc) {
@@ -840,7 +840,7 @@ link_it:
 		head = &fib_info_devhash[hash];
 		hlist_add_head(&nh->nh_hash, head);
 	} endfor_nexthops(fi)
-	write_unlock(&fib_info_lock);
+	spin_unlock(&fib_info_lock);
 	return fi;
 
 err_inval:
