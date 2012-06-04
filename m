From: pablo@netfilter.org
Subject: [PATCH 2/7] netfilter: nf_ct_ext: support variable length extensions
Date: Mon,  4 Jun 2012 14:21:20 +0200
Message-ID: <1338812485-4232-3-git-send-email-pablo@netfilter.org>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

We can now define conntrack extensions of variable size. This
patch is useful to get rid of these unions:

union nf_conntrack_help
union nf_conntrack_proto
union nf_conntrack_nat_help

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h |    7 ++++++-
 net/netfilter/nf_conntrack_extend.c         |   16 +++++++++-------
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 96755c3..ecedd5f 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -79,11 +79,16 @@ static inline void nf_ct_ext_free(struct nf_conn *ct)
 		kfree(ct->ext);
 }
 
+void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
+			     size_t var_alloc_len, gfp_t gfp);
+
 /* Add this type, returns pointer to data or NULL. */
 void *
 __nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp);
 #define nf_ct_ext_add(ct, id, gfp) \
-	((id##_TYPE *)__nf_ct_ext_add((ct), (id), (gfp)))
+	((id##_TYPE *)__nf_ct_ext_add_length((ct), (id), 0, (gfp)))
+#define nf_ct_ext_add_length(ct, id, len, gfp) \
+	((id##_TYPE *)__nf_ct_ext_add_length((ct), (id), (len), (gfp)))
 
 #define NF_CT_EXT_F_PREALLOC	0x0001
 
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 641ff5f..1a95459 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -44,7 +44,8 @@ void __nf_ct_ext_destroy(struct nf_conn *ct)
 EXPORT_SYMBOL(__nf_ct_ext_destroy);
 
 static void *
-nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
+nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id,
+		 size_t var_alloc_len, gfp_t gfp)
 {
 	unsigned int off, len;
 	struct nf_ct_ext_type *t;
@@ -54,8 +55,8 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 	t = rcu_dereference(nf_ct_ext_types[id]);
 	BUG_ON(t == NULL);
 	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
-	len = off + t->len;
-	alloc_size = t->alloc_size;
+	len = off + t->len + var_alloc_len;
+	alloc_size = t->alloc_size + var_alloc_len;
 	rcu_read_unlock();
 
 	*ext = kzalloc(alloc_size, gfp);
@@ -68,7 +69,8 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 	return (void *)(*ext) + off;
 }
 
-void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
+void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
+			     size_t var_alloc_len, gfp_t gfp)
 {
 	struct nf_ct_ext *old, *new;
 	int i, newlen, newoff;
@@ -79,7 +81,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 
 	old = ct->ext;
 	if (!old)
-		return nf_ct_ext_create(&ct->ext, id, gfp);
+		return nf_ct_ext_create(&ct->ext, id, var_alloc_len, gfp);
 
 	if (__nf_ct_ext_exist(old, id))
 		return NULL;
@@ -89,7 +91,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 	BUG_ON(t == NULL);
 
 	newoff = ALIGN(old->len, t->align);
-	newlen = newoff + t->len;
+	newlen = newoff + t->len + var_alloc_len;
 	rcu_read_unlock();
 
 	new = __krealloc(old, newlen, gfp);
@@ -117,7 +119,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 	memset((void *)new + newoff, 0, newlen - newoff);
 	return (void *)new + newoff;
 }
-EXPORT_SYMBOL(__nf_ct_ext_add);
+EXPORT_SYMBOL(__nf_ct_ext_add_length);
 
 static void update_alloc_size(struct nf_ct_ext_type *type)
 {
-- 
1.7.10

