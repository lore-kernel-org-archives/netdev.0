From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 9/9] net, ipv4: convert fib_info.fib_clntref from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 09:35:02 +0300
Message-ID: <1499150102-7478-10-git-send-email-elena.reshetova@intel.com>
References: <1499150102-7478-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:51828 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752415AbdGDGfm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Jul 2017 02:35:42 -0400
In-Reply-To: <1499150102-7478-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/ip_fib.h     | 7 ++++---
 net/ipv4/fib_semantics.c | 2 +-
 net/ipv4/fib_trie.c      | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 3dbfd5e..41d580c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -23,6 +23,7 @@
 #include <net/inetpeer.h>
 #include <linux/percpu.h>
 #include <linux/notifier.h>
+#include <linux/refcount.h>
 
 struct fib_config {
 	u8			fc_dst_len;
@@ -105,7 +106,7 @@ struct fib_info {
 	struct hlist_node	fib_lhash;
 	struct net		*fib_net;
 	int			fib_treeref;
-	atomic_t		fib_clntref;
+	refcount_t		fib_clntref;
 	unsigned int		fib_flags;
 	unsigned char		fib_dead;
 	unsigned char		fib_protocol;
@@ -430,12 +431,12 @@ void free_fib_info(struct fib_info *fi);
 
 static inline void fib_info_hold(struct fib_info *fi)
 {
-	atomic_inc(&fi->fib_clntref);
+	refcount_inc(&fi->fib_clntref);
 }
 
 static inline void fib_info_put(struct fib_info *fi)
 {
-	if (atomic_dec_and_test(&fi->fib_clntref))
+	if (refcount_dec_and_test(&fi->fib_clntref))
 		free_fib_info(fi);
 }
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index ff47ea1..22210010 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1253,7 +1253,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 	}
 
 	fi->fib_treeref++;
-	atomic_inc(&fi->fib_clntref);
+	refcount_set(&fi->fib_clntref, 1);
 	spin_lock_bh(&fib_info_lock);
 	hlist_add_head(&fi->fib_hash,
 		       &fib_info_hash[fib_info_hashfn(fi)]);
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d56659e..64668c6 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1463,7 +1463,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			}
 
 			if (!(fib_flags & FIB_LOOKUP_NOREF))
-				atomic_inc(&fi->fib_clntref);
+				refcount_inc(&fi->fib_clntref);
 
 			res->prefix = htonl(n->key);
 			res->prefixlen = KEYLENGTH - fa->fa_slen;
-- 
2.7.4
