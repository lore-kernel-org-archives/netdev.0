From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: guard the size of the nf_ct_ext
Date: Mon, 15 Nov 2010 14:15:49 +0800
Message-ID: <1289801749-8993-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We'd better guard the size of the nf_ct_ext, as the nf_ct_ext.len is u8.
If the size is bigger than 255, a warning will be printed.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nf_conntrack_extend.c |   41 +++++++++++++++++++++++++++++-------
 1 file changed, 34 insertions(+), 7 deletions(-)
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index bd82450..6a404f9 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -8,6 +8,7 @@
  *      as published by the Free Software Foundation; either version
  *      2 of the License, or (at your option) any later version.
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
@@ -98,6 +99,11 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 	newlen = newoff + t->len;
 	rcu_read_unlock();
 
+	if (unlikely(newlen > 255)) {
+		pr_warn_ratelimited("the size of nf_ct_ext is %d, "
+				    "bigger than 255\n", newlen);
+		return NULL;
+	}
 	new = __krealloc(old, newlen, gfp);
 	if (!new)
 		return NULL;
@@ -125,9 +131,9 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 }
 EXPORT_SYMBOL(__nf_ct_ext_add);
 
-static void update_alloc_size(struct nf_ct_ext_type *type)
+static bool update_alloc_size(struct nf_ct_ext_type *type)
 {
-	int i, j;
+	int i, j, alloc_size;
 	struct nf_ct_ext_type *t1, *t2;
 	enum nf_ct_ext_id min = 0, max = NF_CT_EXT_NUM - 1;
 
@@ -153,16 +159,24 @@ static void update_alloc_size(struct nf_ct_ext_type *type)
 			    (t2->flags & NF_CT_EXT_F_PREALLOC) == 0)
 				continue;
 
-			t1->alloc_size = ALIGN(t1->alloc_size, t2->align)
-					 + t2->len;
+			alloc_size = ALIGN(t1->alloc_size, t2->align) + t2->len;
+			if (unlikely(alloc_size > 255)) {
+				pr_warn("the size of nf_ct_ext is %d, "
+					"bigger than 255\n", alloc_size);
+				return false;
+			}
+			t1->alloc_size = alloc_size;
 		}
 	}
+
+	return true;
 }
 
 /* This MUST be called in process context. */
 int nf_ct_extend_register(struct nf_ct_ext_type *type)
 {
 	int ret = 0;
+	int alloc_size;
 
 	mutex_lock(&nf_ct_ext_type_mutex);
 	if (nf_ct_ext_types[type->id]) {
@@ -172,13 +186,26 @@ int nf_ct_extend_register(struct nf_ct_ext_type *type)
 
 	/* This ensures that nf_ct_ext_create() can allocate enough area
 	   before updating alloc_size */
-	type->alloc_size = ALIGN(sizeof(struct nf_ct_ext), type->align)
-			   + type->len;
+	alloc_size = ALIGN(sizeof(struct nf_ct_ext), type->align) + type->len;
+	if (unlikely(alloc_size > 255)) {
+		pr_warn("the size of nf_ct_ext is %d, bigger than 255\n",
+			alloc_size);
+		ret = -EINVAL;
+		goto out;
+	}
+	type->alloc_size = alloc_size;
 	rcu_assign_pointer(nf_ct_ext_types[type->id], type);
-	update_alloc_size(type);
+	if (!update_alloc_size(type))
+		goto err;
 out:
 	mutex_unlock(&nf_ct_ext_type_mutex);
 	return ret;
+err:
+	rcu_assign_pointer(nf_ct_ext_types[type->id], NULL);
+	update_alloc_size(type);
+	mutex_unlock(&nf_ct_ext_type_mutex);
+	rcu_barrier();
+	return -EINVAL;
 }
 EXPORT_SYMBOL_GPL(nf_ct_extend_register);
 
