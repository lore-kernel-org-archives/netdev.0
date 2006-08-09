From: Steven Whitehouse <steve@chygwyn.com>
Subject: [DECnet] Convert rwlock to spinlock
Date: Wed, 9 Aug 2006 11:06:33 +0100
Message-ID: <20060809100633.GB23935@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Patrick Caulfield <patrick@tykepenguin.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from souterrain.chygwyn.com ([194.39.143.233]:29865 "EHLO
	souterrain.chygwyn.com") by vger.kernel.org with ESMTP
	id S1030620AbWHIKC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 06:02:28 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[This is also in the DECnet git tree]

As per Stephen Hemminger's recent patch to ipv4/fib_semantics.c this
is the same change but for DECnet.

Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

---

 net/decnet/dn_fib.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

ec32d8512a0878f0f48155bdd01f439c6bb80883
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 846df39..ed5fb5c 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -59,7 +59,7 @@ extern int dn_cache_dump(struct sk_buff 
 
 static DEFINE_SPINLOCK(dn_fib_multipath_lock);
 static struct dn_fib_info *dn_fib_info_list;
-static DEFINE_RWLOCK(dn_fib_info_lock);
+static DEFINE_SPINLOCK(dn_fib_info_lock);
 
 static struct
 {
@@ -97,7 +97,7 @@ void dn_fib_free_info(struct dn_fib_info
 
 void dn_fib_release_info(struct dn_fib_info *fi)
 {
-	write_lock(&dn_fib_info_lock);
+	spin_lock(&dn_fib_info_lock);
 	if (fi && --fi->fib_treeref == 0) {
 		if (fi->fib_next)
 			fi->fib_next->fib_prev = fi->fib_prev;
@@ -108,7 +108,7 @@ void dn_fib_release_info(struct dn_fib_i
 		fi->fib_dead = 1;
 		dn_fib_info_put(fi);
 	}
-	write_unlock(&dn_fib_info_lock);
+	spin_unlock(&dn_fib_info_lock);
 }
 
 static inline int dn_fib_nh_comp(const struct dn_fib_info *fi, const struct dn_fib_info *ofi)
@@ -379,13 +379,13 @@ link_it:
 
 	fi->fib_treeref++;
 	atomic_inc(&fi->fib_clntref);
-	write_lock(&dn_fib_info_lock);
+	spin_lock(&dn_fib_info_lock);
 	fi->fib_next = dn_fib_info_list;
 	fi->fib_prev = NULL;
 	if (dn_fib_info_list)
 		dn_fib_info_list->fib_prev = fi;
 	dn_fib_info_list = fi;
-	write_unlock(&dn_fib_info_lock);
+	spin_unlock(&dn_fib_info_lock);
 	return fi;
 
 err_inval:
-- 
1.2.2

