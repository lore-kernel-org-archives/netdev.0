From: kaber@trash.net
Subject: [PATCH 22/28] netfilter: nf_conntrack_extend: introduce __nf_ct_ext_exist()
Date: Mon,  2 Aug 2010 21:57:39 +0200
Message-ID: <1280779065-9333-23-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

some users of nf_ct_ext_exist() know ct->ext isn't NULL. For these users, the
check for ct->ext isn't necessary, the function __nf_ct_ext_exist() can be
used instead.

the type of the return value of nf_ct_ext_exist() is changed to bool.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack_extend.h |    9 +++++++--
 net/netfilter/nf_conntrack_extend.c         |   22 ++++++++++++----------
 2 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 32d15bd..0772d29 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -28,9 +28,14 @@ struct nf_ct_ext {
 	char data[0];
 };
 
-static inline int nf_ct_ext_exist(const struct nf_conn *ct, u8 id)
+static inline bool __nf_ct_ext_exist(const struct nf_ct_ext *ext, u8 id)
 {
-	return (ct->ext && ct->ext->offset[id]);
+	return !!ext->offset[id];
+}
+
+static inline bool nf_ct_ext_exist(const struct nf_conn *ct, u8 id)
+{
+	return (ct->ext && __nf_ct_ext_exist(ct->ext, id));
 }
 
 static inline void *__nf_ct_ext_find(const struct nf_conn *ct, u8 id)
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index fdc8fb4..7dcf7a4 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -23,9 +23,10 @@ void __nf_ct_ext_destroy(struct nf_conn *ct)
 {
 	unsigned int i;
 	struct nf_ct_ext_type *t;
+	struct nf_ct_ext *ext = ct->ext;
 
 	for (i = 0; i < NF_CT_EXT_NUM; i++) {
-		if (!nf_ct_ext_exist(ct, i))
+		if (!__nf_ct_ext_exist(ext, i))
 			continue;
 
 		rcu_read_lock();
@@ -73,44 +74,45 @@ static void __nf_ct_ext_free_rcu(struct rcu_head *head)
 
 void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 {
-	struct nf_ct_ext *new;
+	struct nf_ct_ext *old, *new;
 	int i, newlen, newoff;
 	struct nf_ct_ext_type *t;
 
 	/* Conntrack must not be confirmed to avoid races on reallocation. */
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
 
-	if (!ct->ext)
+	old = ct->ext;
+	if (!old)
 		return nf_ct_ext_create(&ct->ext, id, gfp);
 
-	if (nf_ct_ext_exist(ct, id))
+	if (__nf_ct_ext_exist(old, id))
 		return NULL;
 
 	rcu_read_lock();
 	t = rcu_dereference(nf_ct_ext_types[id]);
 	BUG_ON(t == NULL);
 
-	newoff = ALIGN(ct->ext->len, t->align);
+	newoff = ALIGN(old->len, t->align);
 	newlen = newoff + t->len;
 	rcu_read_unlock();
 
-	new = __krealloc(ct->ext, newlen, gfp);
+	new = __krealloc(old, newlen, gfp);
 	if (!new)
 		return NULL;
 
-	if (new != ct->ext) {
+	if (new != old) {
 		for (i = 0; i < NF_CT_EXT_NUM; i++) {
-			if (!nf_ct_ext_exist(ct, i))
+			if (!__nf_ct_ext_exist(old, i))
 				continue;
 
 			rcu_read_lock();
 			t = rcu_dereference(nf_ct_ext_types[i]);
 			if (t && t->move)
 				t->move((void *)new + new->offset[i],
-					(void *)ct->ext + ct->ext->offset[i]);
+					(void *)old + old->offset[i]);
 			rcu_read_unlock();
 		}
-		call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu);
+		call_rcu(&old->rcu, __nf_ct_ext_free_rcu);
 		ct->ext = new;
 	}
 
-- 
1.7.1

