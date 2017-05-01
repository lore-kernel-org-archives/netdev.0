From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 43/53] netfilter: conntrack: handle initial extension alloc via krealloc
Date: Mon,  1 May 2017 12:47:10 +0200
Message-ID: <1493635640-24325-44-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49696 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378998AbdEAKs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 104A6210580
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:04 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 00C6AFF14D
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:04 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C7213FF2D7
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:01 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

krealloc(NULL, ..) is same as kmalloc(), so we can avoid special-casing
the initial allocation after the prealloc removal (we had to use
->alloc_len as the initial allocation size).

This also means we do not zero the preallocated memory anymore; only
offsets[].  Existing code makes sure the new (used) extension space gets
zeroed out.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_extend.c | 51 +++++++++++--------------------------
 1 file changed, 15 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 5c66816eb965..68ae1be08ed8 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -44,49 +44,24 @@ void __nf_ct_ext_destroy(struct nf_conn *ct)
 }
 EXPORT_SYMBOL(__nf_ct_ext_destroy);
 
-static void *
-nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
-{
-	unsigned int off, len, alloc;
-	struct nf_ct_ext_type *t;
-
-	rcu_read_lock();
-	t = rcu_dereference(nf_ct_ext_types[id]);
-	if (!t) {
-		rcu_read_unlock();
-		return NULL;
-	}
-
-	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
-	len = off + t->len;
-	rcu_read_unlock();
-
-	alloc = max(len, NF_CT_EXT_PREALLOC);
-	*ext = kzalloc(alloc, gfp);
-	if (!*ext)
-		return NULL;
-
-	(*ext)->offset[id] = off;
-	(*ext)->len = len;
-
-	return (void *)(*ext) + off;
-}
-
 void *nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 {
+	unsigned int newlen, newoff, oldlen, alloc;
 	struct nf_ct_ext *old, *new;
-	int newlen, newoff;
 	struct nf_ct_ext_type *t;
 
 	/* Conntrack must not be confirmed to avoid races on reallocation. */
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
 
 	old = ct->ext;
-	if (!old)
-		return nf_ct_ext_create(&ct->ext, id, gfp);
 
-	if (__nf_ct_ext_exist(old, id))
-		return NULL;
+	if (old) {
+		if (__nf_ct_ext_exist(old, id))
+			return NULL;
+		oldlen = old->len;
+	} else {
+		oldlen = sizeof(*new);
+	}
 
 	rcu_read_lock();
 	t = rcu_dereference(nf_ct_ext_types[id]);
@@ -95,15 +70,19 @@ void *nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 		return NULL;
 	}
 
-	newoff = ALIGN(old->len, t->align);
+	newoff = ALIGN(oldlen, t->align);
 	newlen = newoff + t->len;
 	rcu_read_unlock();
 
-	new = __krealloc(old, newlen, gfp);
+	alloc = max(newlen, NF_CT_EXT_PREALLOC);
+	new = __krealloc(old, alloc, gfp);
 	if (!new)
 		return NULL;
 
-	if (new != old) {
+	if (!old) {
+		memset(new->offset, 0, sizeof(new->offset));
+		ct->ext = new;
+	} else if (new != old) {
 		kfree_rcu(old, rcu);
 		rcu_assign_pointer(ct->ext, new);
 	}
-- 
2.1.4
