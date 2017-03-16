From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 9/9] net, ipv4: convert fib_info.fib_clntref from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:31 +0200
Message-ID: <1489688611-4542-10-git-send-email-elena.reshetova@intel.com>
References: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9412 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753645AbdCPSYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 14:24:16 -0400
In-Reply-To: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
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
index 368bb40..55d2694 100644
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
@@ -407,12 +408,12 @@ void free_fib_info(struct fib_info *fi);
 
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
index 317026a..9c361bd 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1174,7 +1174,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 	fi->fib_treeref++;
-	atomic_inc(&fi->fib_clntref);
+	refcount_set(&fi->fib_clntref, 1);
 	spin_lock_bh(&fib_info_lock);
 	hlist_add_head(&fi->fib_hash,
 		       &fib_info_hash[fib_info_hashfn(fi)]);
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2f0d823..d3bbe6e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1543,7 +1543,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			}
 
 			if (!(fib_flags & FIB_LOOKUP_NOREF))
-				atomic_inc(&fi->fib_clntref);
+				refcount_inc(&fi->fib_clntref);
 
 			res->prefixlen = KEYLENGTH - fa->fa_slen;
 			res->nh_sel = nhsel;
-- 
2.7.4
