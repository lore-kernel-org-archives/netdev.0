From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 30/53] netfilter: remove last traces of variable-sized extensions
Date: Mon,  1 May 2017 12:46:57 +0200
Message-ID: <1493635640-24325-31-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

get rid of the (now unused) nf_ct_ext_add_length define and also
rename the function to plain nf_ct_ext_add().

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h |  8 +-------
 net/netfilter/nf_conntrack_extend.c         | 16 +++++++---------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 1c3035dda31f..4ec645c8b647 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -86,13 +86,7 @@ static inline void nf_ct_ext_free(struct nf_conn *ct)
 }
 
 /* Add this type, returns pointer to data or NULL. */
-void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
-			     size_t var_alloc_len, gfp_t gfp);
-
-#define nf_ct_ext_add(ct, id, gfp) \
-	((id##_TYPE *)__nf_ct_ext_add_length((ct), (id), 0, (gfp)))
-#define nf_ct_ext_add_length(ct, id, len, gfp) \
-	((id##_TYPE *)__nf_ct_ext_add_length((ct), (id), (len), (gfp)))
+void *nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp);
 
 #define NF_CT_EXT_F_PREALLOC	0x0001
 
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 008299b7f78f..b5879a9c748d 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -44,8 +44,7 @@ void __nf_ct_ext_destroy(struct nf_conn *ct)
 EXPORT_SYMBOL(__nf_ct_ext_destroy);
 
 static void *
-nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id,
-		 size_t var_alloc_len, gfp_t gfp)
+nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 {
 	unsigned int off, len;
 	struct nf_ct_ext_type *t;
@@ -59,8 +58,8 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id,
 	}
 
 	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
-	len = off + t->len + var_alloc_len;
-	alloc_size = t->alloc_size + var_alloc_len;
+	len = off + t->len;
+	alloc_size = t->alloc_size;
 	rcu_read_unlock();
 
 	*ext = kzalloc(alloc_size, gfp);
@@ -73,8 +72,7 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id,
 	return (void *)(*ext) + off;
 }
 
-void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
-			     size_t var_alloc_len, gfp_t gfp)
+void *nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 {
 	struct nf_ct_ext *old, *new;
 	int newlen, newoff;
@@ -85,7 +83,7 @@ void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
 
 	old = ct->ext;
 	if (!old)
-		return nf_ct_ext_create(&ct->ext, id, var_alloc_len, gfp);
+		return nf_ct_ext_create(&ct->ext, id, gfp);
 
 	if (__nf_ct_ext_exist(old, id))
 		return NULL;
@@ -98,7 +96,7 @@ void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
 	}
 
 	newoff = ALIGN(old->len, t->align);
-	newlen = newoff + t->len + var_alloc_len;
+	newlen = newoff + t->len;
 	rcu_read_unlock();
 
 	new = __krealloc(old, newlen, gfp);
@@ -115,7 +113,7 @@ void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
 	memset((void *)new + newoff, 0, newlen - newoff);
 	return (void *)new + newoff;
 }
-EXPORT_SYMBOL(__nf_ct_ext_add_length);
+EXPORT_SYMBOL(nf_ct_ext_add);
 
 static void update_alloc_size(struct nf_ct_ext_type *type)
 {
-- 
2.1.4

