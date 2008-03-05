From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH] netfilter: replace horrible hack with ksize()
Date: Wed, 5 Mar 2008 23:20:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

There's a horrible slab abuse in net/netfilter/nf_conntrack_extend.c that 
can be replaced with a call to ksize().

Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/net/netfilter/nf_conntrack_extend.h |    1 -
 net/netfilter/nf_conntrack_extend.c         |   19 +++----------------
 2 files changed, 3 insertions(+), 17 deletions(-)

Index: linux-2.6/include/net/netfilter/nf_conntrack_extend.h
===================================================================
--- linux-2.6.orig/include/net/netfilter/nf_conntrack_extend.h
+++ linux-2.6/include/net/netfilter/nf_conntrack_extend.h
@@ -17,7 +17,6 @@ enum nf_ct_ext_id
 struct nf_ct_ext {
 	u8 offset[NF_CT_EXT_NUM];
 	u8 len;
-	u8 real_len;
 	char data[0];
 };
 
Index: linux-2.6/net/netfilter/nf_conntrack_extend.c
===================================================================
--- linux-2.6.orig/net/netfilter/nf_conntrack_extend.c
+++ linux-2.6/net/netfilter/nf_conntrack_extend.c
@@ -19,14 +19,6 @@
 static struct nf_ct_ext_type *nf_ct_ext_types[NF_CT_EXT_NUM];
 static DEFINE_MUTEX(nf_ct_ext_type_mutex);
 
-/* Horrible trick to figure out smallest amount worth kmallocing. */
-#define CACHE(x) (x) + 0 *
-enum {
-	NF_CT_EXT_MIN_SIZE =
-#include <linux/kmalloc_sizes.h>
-	1 };
-#undef CACHE
-
 void __nf_ct_ext_destroy(struct nf_conn *ct)
 {
 	unsigned int i;
@@ -53,7 +45,7 @@ EXPORT_SYMBOL(__nf_ct_ext_destroy);
 static void *
 nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 {
-	unsigned int off, len, real_len;
+	unsigned int off, len;
 	struct nf_ct_ext_type *t;
 
 	rcu_read_lock();
@@ -61,16 +53,14 @@ nf_ct_ext_create(struct nf_ct_ext **ext,
 	BUG_ON(t == NULL);
 	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
 	len = off + t->len;
-	real_len = t->alloc_size;
 	rcu_read_unlock();
 
-	*ext = kzalloc(real_len, gfp);
+	*ext = kzalloc(t->alloc_size, gfp);
 	if (!*ext)
 		return NULL;
 
 	(*ext)->offset[id] = off;
 	(*ext)->len = len;
-	(*ext)->real_len = real_len;
 
 	return (void *)(*ext) + off;
 }
@@ -95,7 +85,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct
 	newlen = newoff + t->len;
 	rcu_read_unlock();
 
-	if (newlen >= ct->ext->real_len) {
+	if (newlen >= ksize(ct->ext)) {
 		new = kmalloc(newlen, gfp);
 		if (!new)
 			return NULL;
@@ -114,7 +104,6 @@ void *__nf_ct_ext_add(struct nf_conn *ct
 			rcu_read_unlock();
 		}
 		kfree(ct->ext);
-		new->real_len = newlen;
 		ct->ext = new;
 	}
 
@@ -156,8 +145,6 @@ static void update_alloc_size(struct nf_
 			t1->alloc_size = ALIGN(t1->alloc_size, t2->align)
 					 + t2->len;
 		}
-		if (t1->alloc_size < NF_CT_EXT_MIN_SIZE)
-			t1->alloc_size = NF_CT_EXT_MIN_SIZE;
 	}
 }
 
