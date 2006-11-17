From: paul.moore@hp.com
Subject: [PATCH 04/13] NetLabel: make netlbl_lsm_secattr struct easier/quicker to understand
Date: Fri, 17 Nov 2006 17:38:46 -0500
Message-ID: <20061117224333.169893000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:52121 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1755987AbWKQWnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:35 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-secattr_update
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The existing netlbl_lsm_secattr struct required the LSM to check all of the
fields to determine if any security attributes were present resulting in a lot
of work in the common case of no attributes.  This patch adds a 'flags' field
which is used to indicate which attributes are present in the structure; this
should allow the LSM to do a quick comparison to determine if the structure
holds any security attributes.

Example:

 if (netlbl_lsm_secattr->flags)
	/* security attributes present */
 else
	/* NO security attributes present */

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/netlabel.h         |   13 +++++++++++--
 net/ipv4/cipso_ipv4.c          |   22 ++++++++++++++--------
 net/netlabel/netlabel_kapi.c   |    5 ++++-
 security/selinux/ss/services.c |   24 ++++++++++++++++--------
 4 files changed, 45 insertions(+), 19 deletions(-)

Index: net-2.6.20_netlabel-base-work/include/net/netlabel.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/include/net/netlabel.h
+++ net-2.6.20_netlabel-base-work/include/net/netlabel.h
@@ -111,11 +111,17 @@ struct netlbl_lsm_cache {
 	void (*free) (const void *data);
 	void *data;
 };
+#define NETLBL_SECATTR_NONE             0x00000000
+#define NETLBL_SECATTR_DOMAIN           0x00000001
+#define NETLBL_SECATTR_CACHE            0x00000002
+#define NETLBL_SECATTR_MLS_LVL          0x00000004
+#define NETLBL_SECATTR_MLS_CAT          0x00000008
 struct netlbl_lsm_secattr {
+	u32 flags;
+
 	char *domain;
 
 	u32 mls_lvl;
-	u32 mls_lvl_vld;
 	unsigned char *mls_cat;
 	size_t mls_cat_len;
 
@@ -174,7 +180,10 @@ static inline void netlbl_secattr_cache_
  */
 static inline void netlbl_secattr_init(struct netlbl_lsm_secattr *secattr)
 {
-	memset(secattr, 0, sizeof(*secattr));
+	secattr->flags = 0;
+	secattr->domain = NULL;
+	secattr->mls_cat = NULL;
+	secattr->cache = NULL;
 }
 
 /**
Index: net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
@@ -319,6 +319,7 @@ static int cipso_v4_cache_check(const un
 			entry->activity += 1;
 			atomic_inc(&entry->lsm_data->refcount);
 			secattr->cache = entry->lsm_data;
+			secattr->flags |= NETLBL_SECATTR_CACHE;
 			if (prev_entry == NULL) {
 				spin_unlock_bh(&cipso_v4_cache[bkt].lock);
 				return 0;
@@ -992,12 +993,15 @@ static int cipso_v4_gentag_rbm(const str
 			       unsigned char **buffer,
 			       u32 *buffer_len)
 {
-	int ret_val = -EPERM;
+	int ret_val;
 	unsigned char *buf = NULL;
 	u32 buf_len;
 	u32 level;
 
-	if (secattr->mls_cat) {
+	if ((secattr->flags & NETLBL_SECATTR_MLS_LVL) == 0)
+		return -EPERM;
+
+	if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
 		buf = kzalloc(CIPSO_V4_HDR_LEN + 4 + CIPSO_V4_TAG1_CAT_LEN,
 			      GFP_ATOMIC);
 		if (buf == NULL)
@@ -1014,10 +1018,10 @@ static int cipso_v4_gentag_rbm(const str
 		/* This will send packets using the "optimized" format when
 		 * possibile as specified in  section 3.4.2.6 of the
 		 * CIPSO draft. */
-		if (cipso_v4_rbm_optfmt && (ret_val > 0 && ret_val < 10))
-			ret_val = 10;
-
-		buf_len = 4 + ret_val;
+		if (cipso_v4_rbm_optfmt && ret_val > 0 && ret_val <= 10)
+			buf_len = 14;
+		else
+			buf_len = 4 + ret_val;
 	} else {
 		buf = kzalloc(CIPSO_V4_HDR_LEN + 4, GFP_ATOMIC);
 		if (buf == NULL)
@@ -1071,7 +1075,7 @@ static int cipso_v4_parsetag_rbm(const s
 	if (ret_val != 0)
 		return ret_val;
 	secattr->mls_lvl = level;
-	secattr->mls_lvl_vld = 1;
+	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
 
 	if (tag_len > 4) {
 		switch (doi_def->type) {
@@ -1095,8 +1099,10 @@ static int cipso_v4_parsetag_rbm(const s
 		if (ret_val < 0) {
 			kfree(secattr->mls_cat);
 			return ret_val;
+		} else if (ret_val > 0) {
+			secattr->mls_cat_len = ret_val;
+			secattr->flags |= NETLBL_SECATTR_MLS_CAT;
 		}
-		secattr->mls_cat_len = ret_val;
 	}
 
 	return 0;
Index: net-2.6.20_netlabel-base-work/net/netlabel/netlabel_kapi.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/netlabel/netlabel_kapi.c
+++ net-2.6.20_netlabel-base-work/net/netlabel/netlabel_kapi.c
@@ -62,6 +62,9 @@ int netlbl_socket_setattr(const struct s
 	int ret_val = -ENOENT;
 	struct netlbl_dom_map *dom_entry;
 
+	if ((secattr->flags & NETLBL_SECATTR_DOMAIN) == 0)
+		return -ENOENT;
+
 	rcu_read_lock();
 	dom_entry = netlbl_domhsh_getentry(secattr->domain);
 	if (dom_entry == NULL)
@@ -200,7 +203,7 @@ void netlbl_cache_invalidate(void)
 int netlbl_cache_add(const struct sk_buff *skb,
 		     const struct netlbl_lsm_secattr *secattr)
 {
-	if (secattr->cache == NULL)
+	if ((secattr->flags & NETLBL_SECATTR_CACHE) == 0)
 		return -ENOMSG;
 
 	if (CIPSO_V4_OPTEXIST(skb))
Index: net-2.6.20_netlabel-base-work/security/selinux/ss/services.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/ss/services.c
+++ net-2.6.20_netlabel-base-work/security/selinux/ss/services.c
@@ -2209,8 +2209,6 @@ static void selinux_netlbl_cache_add(str
 	cache = kzalloc(sizeof(*cache),	GFP_ATOMIC);
 	if (cache == NULL)
 		goto netlbl_cache_add_return;
-	secattr.cache->free = selinux_netlbl_cache_free;
-	secattr.cache->data = (void *)cache;
 
 	cache->type = NETLBL_CACHE_T_MLS;
 	if (ebitmap_cpy(&cache->data.mls_label.level[0].cat,
@@ -2223,6 +2221,10 @@ static void selinux_netlbl_cache_add(str
 	cache->data.mls_label.level[0].sens = ctx->range.level[0].sens;
 	cache->data.mls_label.level[1].sens = ctx->range.level[0].sens;
 
+	secattr.cache->free = selinux_netlbl_cache_free;
+	secattr.cache->data = (void *)cache;
+	secattr.flags = NETLBL_SECATTR_CACHE;
+
 	netlbl_cache_add(skb, &secattr);
 
 netlbl_cache_add_return:
@@ -2268,7 +2270,7 @@ static int selinux_netlbl_secattr_to_sid
 
 	POLICY_RDLOCK;
 
-	if (secattr->cache) {
+	if (secattr->flags & NETLBL_SECATTR_CACHE) {
 		cache = NETLBL_CACHE(secattr->cache->data);
 		switch (cache->type) {
 		case NETLBL_CACHE_T_SID:
@@ -2301,7 +2303,7 @@ static int selinux_netlbl_secattr_to_sid
 		default:
 			goto netlbl_secattr_to_sid_return;
 		}
-	} else if (secattr->mls_lvl_vld) {
+	} else if (secattr->flags & NETLBL_SECATTR_MLS_LVL) {
 		ctx = sidtab_search(&sidtab, base_sid);
 		if (ctx == NULL)
 			goto netlbl_secattr_to_sid_return;
@@ -2310,7 +2312,7 @@ static int selinux_netlbl_secattr_to_sid
 		ctx_new.role = ctx->role;
 		ctx_new.type = ctx->type;
 		mls_import_lvl(&ctx_new, secattr->mls_lvl, secattr->mls_lvl);
-		if (secattr->mls_cat) {
+		if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
 			if (mls_import_cat(&ctx_new,
 					   secattr->mls_cat,
 					   secattr->mls_cat_len,
@@ -2369,11 +2371,13 @@ static int selinux_netlbl_skbuff_getsid(
 
 	netlbl_secattr_init(&secattr);
 	rc = netlbl_skbuff_getattr(skb, &secattr);
-	if (rc == 0)
+	if (rc == 0 && secattr.flags != NETLBL_SECATTR_NONE)
 		rc = selinux_netlbl_secattr_to_sid(skb,
 						   &secattr,
 						   base_sid,
 						   sid);
+	else
+		*sid = SECSID_NULL;
 	netlbl_secattr_destroy(&secattr);
 
 	return rc;
@@ -2410,7 +2414,6 @@ static int selinux_netlbl_socket_setsid(
 	secattr.domain = kstrdup(policydb.p_type_val_to_name[ctx->type - 1],
 				 GFP_ATOMIC);
 	mls_export_lvl(ctx, &secattr.mls_lvl, NULL);
-	secattr.mls_lvl_vld = 1;
 	rc = mls_export_cat(ctx,
 			    &secattr.mls_cat,
 			    &secattr.mls_cat_len,
@@ -2419,6 +2422,10 @@ static int selinux_netlbl_socket_setsid(
 	if (rc != 0)
 		goto netlbl_socket_setsid_return;
 
+	secattr.flags |= NETLBL_SECATTR_DOMAIN | NETLBL_SECATTR_MLS_LVL;
+	if (secattr.mls_cat)
+		secattr.flags |= NETLBL_SECATTR_MLS_CAT;
+
 	rc = netlbl_socket_setattr(sock, &secattr);
 	if (rc == 0)
 		sksec->nlbl_state = NLBL_LABELED;
@@ -2519,6 +2526,7 @@ void selinux_netlbl_sock_graft(struct so
 
 	netlbl_secattr_init(&secattr);
 	if (netlbl_sock_getattr(sk, &secattr) == 0 &&
+	    secattr.flags != NETLBL_SECATTR_NONE &&
 	    selinux_netlbl_secattr_to_sid(NULL,
 					  &secattr,
 					  SECINITSID_UNLABELED,
@@ -2711,7 +2719,7 @@ int selinux_netlbl_socket_setsockopt(str
 	    sksec->nlbl_state == NLBL_LABELED) {
 		netlbl_secattr_init(&secattr);
 		rc = netlbl_socket_getattr(sock, &secattr);
-		if (rc == 0 && (secattr.cache || secattr.mls_lvl_vld))
+		if (rc == 0 && secattr.flags != NETLBL_SECATTR_NONE)
 			rc = -EACCES;
 		netlbl_secattr_destroy(&secattr);
 	}

--
paul moore
linux security @ hp
