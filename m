From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 41/53] netfilter: conntrack: remove prealloc support
Date: Mon,  1 May 2017 12:47:08 +0200
Message-ID: <1493635640-24325-42-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49646 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378993AbdEAKs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6E6A7210574
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5BFE0468
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2F895FF2C8
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:00 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

It was used by the nat extension, but since commit
7c9664351980 ("netfilter: move nat hlist_head to nf_conn") its only needed
for connections that use MASQUERADE target or a nat helper.

Also it seems a lot easier to preallocate a fixed size instead.

With default settings, conntrack first adds ecache extension (sysctl
defaults to 1), so we get 40(ct extension header) + 24 (ecache) == 64 byte
on x86_64 for initial allocation.

Followup patches can constify the extension structs and avoid
the initial zeroing of the entire extension area.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h |  6 ----
 net/netfilter/nf_conntrack_extend.c         | 49 +++--------------------------
 net/netfilter/nf_nat_core.c                 |  1 -
 3 files changed, 4 insertions(+), 52 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 5fc908dc9f32..dd776bf9e2fa 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -88,21 +88,15 @@ static inline void nf_ct_ext_free(struct nf_conn *ct)
 /* Add this type, returns pointer to data or NULL. */
 void *nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp);
 
-#define NF_CT_EXT_F_PREALLOC	0x0001
-
 struct nf_ct_ext_type {
 	/* Destroys relationships (can be NULL). */
 	void (*destroy)(struct nf_conn *ct);
 
 	enum nf_ct_ext_id id;
 
-	unsigned int flags;
-
 	/* Length and min alignment. */
 	u8 len;
 	u8 align;
-	/* initial size of nf_ct_ext. */
-	u8 alloc_size;
 };
 
 int nf_ct_extend_register(struct nf_ct_ext_type *type);
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index b5879a9c748d..2e4b41bc67a0 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -18,6 +18,7 @@
 
 static struct nf_ct_ext_type __rcu *nf_ct_ext_types[NF_CT_EXT_NUM];
 static DEFINE_MUTEX(nf_ct_ext_type_mutex);
+#define NF_CT_EXT_PREALLOC	128u /* conntrack events are on by default */
 
 void __nf_ct_ext_destroy(struct nf_conn *ct)
 {
@@ -46,9 +47,8 @@ EXPORT_SYMBOL(__nf_ct_ext_destroy);
 static void *
 nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 {
-	unsigned int off, len;
+	unsigned int off, len, alloc;
 	struct nf_ct_ext_type *t;
-	size_t alloc_size;
 
 	rcu_read_lock();
 	t = rcu_dereference(nf_ct_ext_types[id]);
@@ -59,10 +59,10 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 
 	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
 	len = off + t->len;
-	alloc_size = t->alloc_size;
 	rcu_read_unlock();
 
-	*ext = kzalloc(alloc_size, gfp);
+	alloc = max(len, NF_CT_EXT_PREALLOC);
+	*ext = kzalloc(alloc, gfp);
 	if (!*ext)
 		return NULL;
 
@@ -115,41 +115,6 @@ void *nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 }
 EXPORT_SYMBOL(nf_ct_ext_add);
 
-static void update_alloc_size(struct nf_ct_ext_type *type)
-{
-	int i, j;
-	struct nf_ct_ext_type *t1, *t2;
-	enum nf_ct_ext_id min = 0, max = NF_CT_EXT_NUM - 1;
-
-	/* unnecessary to update all types */
-	if ((type->flags & NF_CT_EXT_F_PREALLOC) == 0) {
-		min = type->id;
-		max = type->id;
-	}
-
-	/* This assumes that extended areas in conntrack for the types
-	   whose NF_CT_EXT_F_PREALLOC bit set are allocated in order */
-	for (i = min; i <= max; i++) {
-		t1 = rcu_dereference_protected(nf_ct_ext_types[i],
-				lockdep_is_held(&nf_ct_ext_type_mutex));
-		if (!t1)
-			continue;
-
-		t1->alloc_size = ALIGN(sizeof(struct nf_ct_ext), t1->align) +
-				 t1->len;
-		for (j = 0; j < NF_CT_EXT_NUM; j++) {
-			t2 = rcu_dereference_protected(nf_ct_ext_types[j],
-				lockdep_is_held(&nf_ct_ext_type_mutex));
-			if (t2 == NULL || t2 == t1 ||
-			    (t2->flags & NF_CT_EXT_F_PREALLOC) == 0)
-				continue;
-
-			t1->alloc_size = ALIGN(t1->alloc_size, t2->align)
-					 + t2->len;
-		}
-	}
-}
-
 /* This MUST be called in process context. */
 int nf_ct_extend_register(struct nf_ct_ext_type *type)
 {
@@ -161,12 +126,7 @@ int nf_ct_extend_register(struct nf_ct_ext_type *type)
 		goto out;
 	}
 
-	/* This ensures that nf_ct_ext_create() can allocate enough area
-	   before updating alloc_size */
-	type->alloc_size = ALIGN(sizeof(struct nf_ct_ext), type->align)
-			   + type->len;
 	rcu_assign_pointer(nf_ct_ext_types[type->id], type);
-	update_alloc_size(type);
 out:
 	mutex_unlock(&nf_ct_ext_type_mutex);
 	return ret;
@@ -178,7 +138,6 @@ void nf_ct_extend_unregister(struct nf_ct_ext_type *type)
 {
 	mutex_lock(&nf_ct_ext_type_mutex);
 	RCU_INIT_POINTER(nf_ct_ext_types[type->id], NULL);
-	update_alloc_size(type);
 	mutex_unlock(&nf_ct_ext_type_mutex);
 	synchronize_rcu();
 }
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 9cbf49f9c1b7..86eeacbb4793 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -717,7 +717,6 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
 	.align		= __alignof__(struct nf_conn_nat),
 	.destroy	= nf_nat_cleanup_conntrack,
 	.id		= NF_CT_EXT_NAT,
-	.flags		= NF_CT_EXT_F_PREALLOC,
 };
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
-- 
2.1.4
