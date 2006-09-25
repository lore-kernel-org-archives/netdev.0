From: paul.moore@hp.com
Subject: [PATCH v2 6/8] NetLabel: rework the Netlink attribute handling (part 1)
Date: Mon, 25 Sep 2006 14:04:18 -0400
Message-ID: <20060925180642.583395000@hp.com>
References: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:55448 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751415AbWIYSGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:46 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-nlattr_change_p1
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the suggestion of Thomas Graf, rewrite NetLabel's use of Netlink attributes
to better follow the common Netlink attribute usage.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/cipso_ipv4.h           |   16 +-
 include/net/netlabel.h             |   49 --------
 net/ipv4/cipso_ipv4.c              |  203 ++++---------------------------------
 net/netlabel/netlabel_domainhash.c |  183 ++++++---------------------------
 net/netlabel/netlabel_domainhash.h |    6 -
 net/netlabel/netlabel_user.c       |   82 --------------
 net/netlabel/netlabel_user.h       |  141 -------------------------
 7 files changed, 76 insertions(+), 604 deletions(-)

Index: net-2.6.19/include/net/cipso_ipv4.h
===================================================================
--- net-2.6.19.orig/include/net/cipso_ipv4.h
+++ net-2.6.19/include/net/cipso_ipv4.h
@@ -130,8 +130,9 @@ extern int cipso_v4_rbm_strictvalid;
 int cipso_v4_doi_add(struct cipso_v4_doi *doi_def);
 int cipso_v4_doi_remove(u32 doi, void (*callback) (struct rcu_head * head));
 struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi);
-struct sk_buff *cipso_v4_doi_dump_all(size_t headroom);
-struct sk_buff *cipso_v4_doi_dump(u32 doi, size_t headroom);
+int cipso_v4_doi_walk(u32 *skip_cnt,
+		     int (*callback) (struct cipso_v4_doi *doi_def, void *arg),
+	             void *cb_arg);
 int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain);
 int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
 			       const char *domain);
@@ -152,14 +153,11 @@ static inline struct cipso_v4_doi *cipso
 	return NULL;
 }
 
-static inline struct sk_buff *cipso_v4_doi_dump_all(size_t headroom)
+static inline int cipso_v4_doi_walk(u32 *skip_cnt,
+		     int (*callback) (struct cipso_v4_doi *doi_def, void *arg),
+		     void *cb_arg)
 {
-	return NULL;
-}
-
-static inline struct sk_buff *cipso_v4_doi_dump(u32 doi, size_t headroom)
-{
-	return NULL;
+	return 0;
 }
 
 static inline int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def,
Index: net-2.6.19/include/net/netlabel.h
===================================================================
--- net-2.6.19.orig/include/net/netlabel.h
+++ net-2.6.19/include/net/netlabel.h
@@ -57,9 +57,8 @@
  * The payload is dependent on the subsystem specified in the
  * 'nlmsghdr->nlmsg_type' and should be defined below, supporting functions
  * should be defined in the corresponding net/netlabel/netlabel_<subsys>.h|c
- * file.  All of the fields in the NetLabel payload are NETLINK attributes, the
- * length of each field is the length of the NETLINK attribute payload, see
- * include/net/netlink.h for more information on NETLINK attributes.
+ * file.  All of the fields in the NetLabel payload are NETLINK attributes, see
+ * the include/net/netlink.h file for more information on NETLINK attributes.
  *
  */
 
@@ -82,50 +81,6 @@
 #define NETLBL_NLTYPE_UNLABELED         5
 #define NETLBL_NLTYPE_UNLABELED_NAME    "NLBL_UNLBL"
 
-/* NetLabel return codes */
-#define NETLBL_E_OK                     0
-
-/*
- * Helper functions
- */
-
-#define NETLBL_LEN_U8                   nla_total_size(sizeof(u8))
-#define NETLBL_LEN_U16                  nla_total_size(sizeof(u16))
-#define NETLBL_LEN_U32                  nla_total_size(sizeof(u32))
-
-/**
- * netlbl_netlink_alloc_skb - Allocate a NETLINK message buffer
- * @head: the amount of headroom in bytes
- * @body: the desired size (minus headroom) in bytes
- * @gfp_flags: the alloc flags to pass to alloc_skb()
- *
- * Description:
- * Allocate a NETLINK message buffer based on the sizes given in @head and
- * @body.  If @head is greater than zero skb_reserve() is called to reserve
- * @head bytes at the start of the buffer.  Returns a valid sk_buff pointer on
- * success, NULL on failure.
- *
- */
-static inline struct sk_buff *netlbl_netlink_alloc_skb(size_t head,
-						       size_t body,
-						       int gfp_flags)
-{
-	struct sk_buff *skb;
-
-	skb = alloc_skb(NLMSG_ALIGN(head + body), gfp_flags);
-	if (skb == NULL)
-		return NULL;
-	if (head > 0) {
-		skb_reserve(skb, head);
-		if (skb_tailroom(skb) < body) {
-			kfree_skb(skb);
-			return NULL;
-		}
-	}
-
-	return skb;
-}
-
 /*
  * NetLabel - Kernel API for accessing the network packet label mappings.
  *
Index: net-2.6.19/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.19.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.19/net/ipv4/cipso_ipv4.c
@@ -530,197 +530,42 @@ struct cipso_v4_doi *cipso_v4_doi_getdef
 }
 
 /**
- * cipso_v4_doi_dump_all - Dump all the CIPSO DOI definitions into a sk_buff
- * @headroom: the amount of headroom to allocate for the sk_buff
+ * cipso_v4_doi_walk - Iterate through the DOI definitions
+ * @skip_cnt: skip past this number of DOI definitions, updated
+ * @callback: callback for each DOI definition
+ * @cb_arg: argument for the callback function
  *
  * Description:
- * Dump a list of all the configured DOI values into a sk_buff.  The returned
- * sk_buff has room at the front of the sk_buff for @headroom bytes.  See
- * net/netlabel/netlabel_cipso_v4.h for the LISTALL message format.  This
- * function may fail if another process is changing the DOI list at the same
- * time.  Returns a pointer to a sk_buff on success, NULL on error.
+ * Iterate over the DOI definition list, skipping the first @skip_cnt entries.
+ * For each entry call @callback, if @callback returns a negative value stop
+ * 'walking' through the list and return.  Updates the value in @skip_cnt upon
+ * return.  Returns zero on success, negative values on failure.
  *
  */
-struct sk_buff *cipso_v4_doi_dump_all(size_t headroom)
+int cipso_v4_doi_walk(u32 *skip_cnt,
+		     int (*callback) (struct cipso_v4_doi *doi_def, void *arg),
+		     void *cb_arg)
 {
-	struct sk_buff *skb = NULL;
-	struct cipso_v4_doi *iter;
+	int ret_val = -ENOENT;
 	u32 doi_cnt = 0;
-	ssize_t buf_len;
+	struct cipso_v4_doi *iter_doi;
 
-	buf_len = NETLBL_LEN_U32;
 	rcu_read_lock();
-	list_for_each_entry_rcu(iter, &cipso_v4_doi_list, list)
-		if (iter->valid) {
-			doi_cnt += 1;
-			buf_len += 2 * NETLBL_LEN_U32;
-		}
-
-	skb = netlbl_netlink_alloc_skb(headroom, buf_len, GFP_ATOMIC);
-	if (skb == NULL)
-		goto doi_dump_all_failure;
-
-	if (nla_put_u32(skb, NLA_U32, doi_cnt) != 0)
-		goto doi_dump_all_failure;
-	buf_len -= NETLBL_LEN_U32;
-	list_for_each_entry_rcu(iter, &cipso_v4_doi_list, list)
-		if (iter->valid) {
-			if (buf_len < 2 * NETLBL_LEN_U32)
-				goto doi_dump_all_failure;
-			if (nla_put_u32(skb, NLA_U32, iter->doi) != 0)
-				goto doi_dump_all_failure;
-			if (nla_put_u32(skb, NLA_U32, iter->type) != 0)
-				goto doi_dump_all_failure;
-			buf_len -= 2 * NETLBL_LEN_U32;
-		}
-	rcu_read_unlock();
-
-	return skb;
-
-doi_dump_all_failure:
-	rcu_read_unlock();
-	kfree(skb);
-	return NULL;
-}
-
-/**
- * cipso_v4_doi_dump - Dump a CIPSO DOI definition into a sk_buff
- * @doi: the DOI value
- * @headroom: the amount of headroom to allocate for the sk_buff
- *
- * Description:
- * Lookup the DOI definition matching @doi and dump it's contents into a
- * sk_buff.  The returned sk_buff has room at the front of the sk_buff for
- * @headroom bytes.  See net/netlabel/netlabel_cipso_v4.h for the LIST message
- * format.  This function may fail if another process is changing the DOI list
- * at the same time.  Returns a pointer to a sk_buff on success, NULL on error.
- *
- */
-struct sk_buff *cipso_v4_doi_dump(u32 doi, size_t headroom)
-{
-	struct sk_buff *skb = NULL;
-	struct cipso_v4_doi *iter;
-	u32 tag_cnt = 0;
-	u32 lvl_cnt = 0;
-	u32 cat_cnt = 0;
-	ssize_t buf_len;
-	ssize_t tmp;
-
-	rcu_read_lock();
-	iter = cipso_v4_doi_getdef(doi);
-	if (iter == NULL)
-		goto doi_dump_failure;
-	buf_len = NETLBL_LEN_U32;
-	switch (iter->type) {
-	case CIPSO_V4_MAP_PASS:
-		buf_len += NETLBL_LEN_U32;
-		while(tag_cnt < CIPSO_V4_TAG_MAXCNT &&
-		      iter->tags[tag_cnt] != CIPSO_V4_TAG_INVALID) {
-			tag_cnt += 1;
-			buf_len += NETLBL_LEN_U8;
-		}
-		break;
-	case CIPSO_V4_MAP_STD:
-		buf_len += 3 * NETLBL_LEN_U32;
-		while (tag_cnt < CIPSO_V4_TAG_MAXCNT &&
-		       iter->tags[tag_cnt] != CIPSO_V4_TAG_INVALID) {
-			tag_cnt += 1;
-			buf_len += NETLBL_LEN_U8;
-		}
-		for (tmp = 0; tmp < iter->map.std->lvl.local_size; tmp++)
-			if (iter->map.std->lvl.local[tmp] !=
-			    CIPSO_V4_INV_LVL) {
-				lvl_cnt += 1;
-				buf_len += NETLBL_LEN_U32 + NETLBL_LEN_U8;
+	list_for_each_entry_rcu(iter_doi, &cipso_v4_doi_list, list)
+		if (iter_doi->valid) {
+			if (doi_cnt++ < *skip_cnt)
+				continue;
+			ret_val = callback(iter_doi, cb_arg);
+			if (ret_val < 0) {
+				doi_cnt--;
+				goto doi_walk_return;
 			}
-		for (tmp = 0; tmp < iter->map.std->cat.local_size; tmp++)
-			if (iter->map.std->cat.local[tmp] !=
-			    CIPSO_V4_INV_CAT) {
-				cat_cnt += 1;
-				buf_len += NETLBL_LEN_U32 + NETLBL_LEN_U16;
-			}
-		break;
-	}
-
-	skb = netlbl_netlink_alloc_skb(headroom, buf_len, GFP_ATOMIC);
-	if (skb == NULL)
-		goto doi_dump_failure;
-
-	if (nla_put_u32(skb, NLA_U32, iter->type) != 0)
-		goto doi_dump_failure;
-	buf_len -= NETLBL_LEN_U32;
-	if (iter != cipso_v4_doi_getdef(doi))
-		goto doi_dump_failure;
-	switch (iter->type) {
-	case CIPSO_V4_MAP_PASS:
-		if (nla_put_u32(skb, NLA_U32, tag_cnt) != 0)
-			goto doi_dump_failure;
-		buf_len -= NETLBL_LEN_U32;
-		for (tmp = 0;
-		     tmp < CIPSO_V4_TAG_MAXCNT &&
-			     iter->tags[tmp] != CIPSO_V4_TAG_INVALID;
-		     tmp++) {
-			if (buf_len < NETLBL_LEN_U8)
-				goto doi_dump_failure;
-			if (nla_put_u8(skb, NLA_U8, iter->tags[tmp]) != 0)
-				goto doi_dump_failure;
-			buf_len -= NETLBL_LEN_U8;
-		}
-		break;
-	case CIPSO_V4_MAP_STD:
-		if (nla_put_u32(skb, NLA_U32, tag_cnt) != 0)
-			goto doi_dump_failure;
-		if (nla_put_u32(skb, NLA_U32, lvl_cnt) != 0)
-			goto doi_dump_failure;
-		if (nla_put_u32(skb, NLA_U32, cat_cnt) != 0)
-			goto doi_dump_failure;
-		buf_len -= 3 * NETLBL_LEN_U32;
-		for (tmp = 0;
-		     tmp < CIPSO_V4_TAG_MAXCNT &&
-			     iter->tags[tmp] != CIPSO_V4_TAG_INVALID;
-		     tmp++) {
-			if (buf_len < NETLBL_LEN_U8)
-				goto doi_dump_failure;
-			if (nla_put_u8(skb, NLA_U8, iter->tags[tmp]) != 0)
-				goto doi_dump_failure;
-			buf_len -= NETLBL_LEN_U8;
 		}
-		for (tmp = 0; tmp < iter->map.std->lvl.local_size; tmp++)
-			if (iter->map.std->lvl.local[tmp] !=
-			    CIPSO_V4_INV_LVL) {
-				if (buf_len < NETLBL_LEN_U32 + NETLBL_LEN_U8)
-					goto doi_dump_failure;
-				if (nla_put_u32(skb, NLA_U32, tmp) != 0)
-					goto doi_dump_failure;
-				if (nla_put_u8(skb,
-					   NLA_U8,
-					   iter->map.std->lvl.local[tmp]) != 0)
-					goto doi_dump_failure;
-				buf_len -= NETLBL_LEN_U32 + NETLBL_LEN_U8;
-			}
-		for (tmp = 0; tmp < iter->map.std->cat.local_size; tmp++)
-			if (iter->map.std->cat.local[tmp] !=
-			    CIPSO_V4_INV_CAT) {
-				if (buf_len < NETLBL_LEN_U32 + NETLBL_LEN_U16)
-					goto doi_dump_failure;
-				if (nla_put_u32(skb, NLA_U32, tmp) != 0)
-					goto doi_dump_failure;
-				if (nla_put_u16(skb,
-					   NLA_U16,
-					   iter->map.std->cat.local[tmp]) != 0)
-					goto doi_dump_failure;
-				buf_len -= NETLBL_LEN_U32 + NETLBL_LEN_U16;
-			}
-		break;
-	}
-	rcu_read_unlock();
 
-	return skb;
-
-doi_dump_failure:
+doi_walk_return:
 	rcu_read_unlock();
-	kfree(skb);
-	return NULL;
+	*skip_cnt = doi_cnt;
+	return ret_val;
 }
 
 /**
Index: net-2.6.19/net/netlabel/netlabel_domainhash.c
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_domainhash.c
+++ net-2.6.19/net/netlabel/netlabel_domainhash.c
@@ -354,160 +354,51 @@ struct netlbl_dom_map *netlbl_domhsh_get
 }
 
 /**
- * netlbl_domhsh_dump - Dump the domain hash table into a sk_buff
+ * netlbl_domhsh_walk - Iterate through the domain mapping hash table
+ * @skip_bkt: the number of buckets to skip at the start
+ * @skip_chain: the number of entries to skip in the first iterated bucket
+ * @callback: callback for each entry
+ * @cb_arg: argument for the callback function
  *
  * Description:
- * Dump the domain hash table into a buffer suitable for returning to an
- * application in response to a NetLabel management DOMAIN message.  This
- * function may fail if another process is growing the hash table at the same
- * time.  The returned sk_buff has room at the front of the sk_buff for
- * @headroom bytes.  See netlabel.h for the DOMAIN message format.  Returns a
- * pointer to a sk_buff on success, NULL on error.
+ * Interate over the domain mapping hash table, skipping the first @skip_bkt
+ * buckets and @skip_chain entries.  For each entry in the table call
+ * @callback, if @callback returns a negative value stop 'walking' through the
+ * table and return.  Updates the values in @skip_bkt and @skip_chain on
+ * return.  Returns zero on succcess, negative values on failure.
  *
  */
-struct sk_buff *netlbl_domhsh_dump(size_t headroom)
+int netlbl_domhsh_walk(u32 *skip_bkt,
+		     u32 *skip_chain,
+		     int (*callback) (struct netlbl_dom_map *entry, void *arg),
+		     void *cb_arg)
 {
-	struct sk_buff *skb = NULL;
-	ssize_t buf_len;
-	u32 bkt_iter;
-	u32 dom_cnt = 0;
-	struct netlbl_domhsh_tbl *hsh_tbl;
-	struct netlbl_dom_map *list_iter;
-	ssize_t tmp_len;
+	int ret_val = -ENOENT;
+	u32 iter_bkt;
+	struct netlbl_dom_map *iter_entry;
+	u32 chain_cnt = 0;
 
-	buf_len = NETLBL_LEN_U32;
 	rcu_read_lock();
-	hsh_tbl = rcu_dereference(netlbl_domhsh);
-	for (bkt_iter = 0; bkt_iter < hsh_tbl->size; bkt_iter++)
-		list_for_each_entry_rcu(list_iter,
-					&hsh_tbl->tbl[bkt_iter], list) {
-			buf_len += NETLBL_LEN_U32 +
-				nla_total_size(strlen(list_iter->domain) + 1);
-			switch (list_iter->type) {
-			case NETLBL_NLTYPE_UNLABELED:
-				break;
-			case NETLBL_NLTYPE_CIPSOV4:
-				buf_len += 2 * NETLBL_LEN_U32;
-				break;
+	for (iter_bkt = *skip_bkt;
+	     iter_bkt < rcu_dereference(netlbl_domhsh)->size;
+	     iter_bkt++, chain_cnt = 0) {
+		list_for_each_entry_rcu(iter_entry,
+					&netlbl_domhsh->tbl[iter_bkt],
+					list)
+			if (iter_entry->valid) {
+				if (chain_cnt++ < *skip_chain)
+					continue;
+				ret_val = callback(iter_entry, cb_arg);
+				if (ret_val < 0) {
+					chain_cnt--;
+					goto walk_return;
+				}
 			}
-			dom_cnt++;
-		}
+	}
 
-	skb = netlbl_netlink_alloc_skb(headroom, buf_len, GFP_ATOMIC);
-	if (skb == NULL)
-		goto dump_failure;
-
-	if (nla_put_u32(skb, NLA_U32, dom_cnt) != 0)
-		goto dump_failure;
-	buf_len -= NETLBL_LEN_U32;
-	hsh_tbl = rcu_dereference(netlbl_domhsh);
-	for (bkt_iter = 0; bkt_iter < hsh_tbl->size; bkt_iter++)
-		list_for_each_entry_rcu(list_iter,
-					&hsh_tbl->tbl[bkt_iter], list) {
-			tmp_len = nla_total_size(strlen(list_iter->domain) +
-						 1);
-			if (buf_len < NETLBL_LEN_U32 + tmp_len)
-				goto dump_failure;
-			if (nla_put_string(skb,
-					   NLA_STRING,
-					   list_iter->domain) != 0)
-				goto dump_failure;
-			if (nla_put_u32(skb, NLA_U32, list_iter->type) != 0)
-				goto dump_failure;
-			buf_len -= NETLBL_LEN_U32 + tmp_len;
-			switch (list_iter->type) {
-			case NETLBL_NLTYPE_UNLABELED:
-				break;
-			case NETLBL_NLTYPE_CIPSOV4:
-				if (buf_len < 2 * NETLBL_LEN_U32)
-					goto dump_failure;
-				if (nla_put_u32(skb,
-				       NLA_U32,
-				       list_iter->type_def.cipsov4->type) != 0)
-					goto dump_failure;
-				if (nla_put_u32(skb,
-				       NLA_U32,
-				       list_iter->type_def.cipsov4->doi) != 0)
-					goto dump_failure;
-				buf_len -= 2 * NETLBL_LEN_U32;
-				break;
-			}
-		}
-	rcu_read_unlock();
-
-	return skb;
-
-dump_failure:
-	rcu_read_unlock();
-	kfree_skb(skb);
-	return NULL;
-}
-
-/**
- * netlbl_domhsh_dump_default - Dump the default domain mapping into a sk_buff
- *
- * Description:
- * Dump the default domain mapping into a buffer suitable for returning to an
- * application in response to a NetLabel management DEFDOMAIN message.  This
- * function may fail if another process is changing the default domain mapping
- * at the same time.  The returned sk_buff has room at the front of the
- * skb_buff for @headroom bytes.  See netlabel.h for the DEFDOMAIN message
- * format.  Returns a pointer to a sk_buff on success, NULL on error.
- *
- */
-struct sk_buff *netlbl_domhsh_dump_default(size_t headroom)
-{
-	struct sk_buff *skb;
-	ssize_t buf_len;
-	struct netlbl_dom_map *entry;
-
-	buf_len = NETLBL_LEN_U32;
-	rcu_read_lock();
-	entry = rcu_dereference(netlbl_domhsh_def);
-	if (entry != NULL)
-		switch (entry->type) {
-		case NETLBL_NLTYPE_UNLABELED:
-			break;
-		case NETLBL_NLTYPE_CIPSOV4:
-			buf_len += 2 * NETLBL_LEN_U32;
-			break;
-		}
-
-	skb = netlbl_netlink_alloc_skb(headroom, buf_len, GFP_ATOMIC);
-	if (skb == NULL)
-		goto dump_default_failure;
-
-	if (entry != rcu_dereference(netlbl_domhsh_def))
-		goto dump_default_failure;
-	if (entry != NULL) {
-		if (nla_put_u32(skb, NLA_U32, entry->type) != 0)
-			goto dump_default_failure;
-		buf_len -= NETLBL_LEN_U32;
-		switch (entry->type) {
-		case NETLBL_NLTYPE_UNLABELED:
-			break;
-		case NETLBL_NLTYPE_CIPSOV4:
-			if (buf_len < 2 * NETLBL_LEN_U32)
-				goto dump_default_failure;
-			if (nla_put_u32(skb,
-					NLA_U32,
-					entry->type_def.cipsov4->type) != 0)
-				goto dump_default_failure;
-			if (nla_put_u32(skb,
-					NLA_U32,
-					entry->type_def.cipsov4->doi) != 0)
-				goto dump_default_failure;
-			buf_len -= 2 * NETLBL_LEN_U32;
-			break;
-		}
-	} else
-		nla_put_u32(skb, NLA_U32, NETLBL_NLTYPE_NONE);
-	rcu_read_unlock();
-
-	return skb;
-
-dump_default_failure:
+walk_return:
 	rcu_read_unlock();
-	kfree_skb(skb);
-	return NULL;
+	*skip_bkt = iter_bkt;
+	*skip_chain = chain_cnt;
+	return ret_val;
 }
Index: net-2.6.19/net/netlabel/netlabel_domainhash.h
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_domainhash.h
+++ net-2.6.19/net/netlabel/netlabel_domainhash.h
@@ -61,7 +61,9 @@ int netlbl_domhsh_add(struct netlbl_dom_
 int netlbl_domhsh_add_default(struct netlbl_dom_map *entry);
 int netlbl_domhsh_remove_default(void);
 struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
-struct sk_buff *netlbl_domhsh_dump(size_t headroom);
-struct sk_buff *netlbl_domhsh_dump_default(size_t headroom);
+int netlbl_domhsh_walk(u32 *skip_bkt,
+		     u32 *skip_chain,
+		     int (*callback) (struct netlbl_dom_map *entry, void *arg),
+		     void *cb_arg);
 
 #endif
Index: net-2.6.19/net/netlabel/netlabel_user.c
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_user.c
+++ net-2.6.19/net/netlabel/netlabel_user.c
@@ -74,85 +74,3 @@ int netlbl_netlink_init(void)
 
 	return 0;
 }
-
-/*
- * NetLabel Common Protocol Functions
- */
-
-/**
- * netlbl_netlink_send_ack - Send an ACK message
- * @info: the generic NETLINK information
- * @genl_family: the generic NETLINK family ID value
- * @ack_cmd: the generic NETLINK family ACK command value
- * @ret_code: return code to use
- *
- * Description:
- * This function sends an ACK message to the sender of the NETLINK message
- * specified by @info.
- *
- */
-void netlbl_netlink_send_ack(const struct genl_info *info,
-			     u32 genl_family,
-			     u8 ack_cmd,
-			     u32 ret_code)
-{
-	size_t data_size;
-	struct sk_buff *skb;
-
-	data_size = GENL_HDRLEN + 2 * NETLBL_LEN_U32;
-	skb = netlbl_netlink_alloc_skb(0, data_size, GFP_KERNEL);
-	if (skb == NULL)
-		return;
-
-	if (netlbl_netlink_hdr_put(skb,
-				   info->snd_pid,
-				   0,
-				   genl_family,
-				   ack_cmd) == NULL)
-		goto send_ack_failure;
-
-	if (nla_put_u32(skb, NLA_U32, info->snd_seq) != 0)
-		goto send_ack_failure;
-	if (nla_put_u32(skb, NLA_U32, ret_code) != 0)
-		goto send_ack_failure;
-
-	netlbl_netlink_snd(skb, info->snd_pid);
-	return;
-
-send_ack_failure:
-	kfree_skb(skb);
-}
-
-/*
- * NETLINK I/O Functions
- */
-
-/**
- * netlbl_netlink_snd - Send a NetLabel message
- * @skb: NetLabel message
- * @pid: destination PID
- *
- * Description:
- * Sends a unicast NetLabel message over the NETLINK socket.
- *
- */
-int netlbl_netlink_snd(struct sk_buff *skb, u32 pid)
-{
-	return genlmsg_unicast(skb, pid);
-}
-
-/**
- * netlbl_netlink_snd - Send a NetLabel message
- * @skb: NetLabel message
- * @pid: sending PID
- * @group: multicast group id
- *
- * Description:
- * Sends a multicast NetLabel message over the NETLINK socket to all members
- * of @group except @pid.
- *
- */
-int netlbl_netlink_snd_multicast(struct sk_buff *skb, u32 pid, u32 group)
-{
-	return genlmsg_multicast(skb, pid, group, GFP_KERNEL);
-}
Index: net-2.6.19/net/netlabel/netlabel_user.h
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_user.h
+++ net-2.6.19/net/netlabel/netlabel_user.h
@@ -41,72 +41,6 @@
 /* NetLabel NETLINK helper functions */
 
 /**
- * netlbl_netlink_cap_check - Check the NETLINK msg capabilities
- * @skb: the NETLINK buffer
- * @req_cap: the required capability
- *
- * Description:
- * Check the NETLINK buffer's capabilities against the required capabilities.
- * Returns zero on success, negative values on failure.
- *
- */
-static inline int netlbl_netlink_cap_check(const struct sk_buff *skb,
-					   kernel_cap_t req_cap)
-{
-	if (cap_raised(NETLINK_CB(skb).eff_cap, req_cap))
-		return 0;
-	return -EPERM;
-}
-
-/**
- * netlbl_getinc_u8 - Read a u8 value from a nlattr stream and move on
- * @nla: the attribute
- * @rem_len: remaining length
- *
- * Description:
- * Return a u8 value pointed to by @nla and advance it to the next attribute.
- *
- */
-static inline u8 netlbl_getinc_u8(struct nlattr **nla, int *rem_len)
-{
-	u8 val = nla_get_u8(*nla);
-	*nla = nla_next(*nla, rem_len);
-	return val;
-}
-
-/**
- * netlbl_getinc_u16 - Read a u16 value from a nlattr stream and move on
- * @nla: the attribute
- * @rem_len: remaining length
- *
- * Description:
- * Return a u16 value pointed to by @nla and advance it to the next attribute.
- *
- */
-static inline u16 netlbl_getinc_u16(struct nlattr **nla, int *rem_len)
-{
-	u16 val = nla_get_u16(*nla);
-	*nla = nla_next(*nla, rem_len);
-	return val;
-}
-
-/**
- * netlbl_getinc_u32 - Read a u32 value from a nlattr stream and move on
- * @nla: the attribute
- * @rem_len: remaining length
- *
- * Description:
- * Return a u32 value pointed to by @nla and advance it to the next attribute.
- *
- */
-static inline u32 netlbl_getinc_u32(struct nlattr **nla, int *rem_len)
-{
-	u32 val = nla_get_u32(*nla);
-	*nla = nla_next(*nla, rem_len);
-	return val;
-}
-
-/**
  * netlbl_netlink_hdr_put - Write the NETLINK buffers into a sk_buff
  * @skb: the packet
  * @pid: the PID of the receipient
@@ -124,6 +58,7 @@ static inline void *netlbl_netlink_hdr_p
 					   u32 pid,
 					   u32 seq,
 					   int type,
+					   int flags,
 					   u8 cmd)
 {
 	return genlmsg_put(skb,
@@ -131,85 +66,13 @@ static inline void *netlbl_netlink_hdr_p
 			   seq,
 			   type,
 			   0,
-			   0,
+			   flags,
 			   cmd,
 			   NETLBL_PROTO_VERSION);
 }
 
-/**
- * netlbl_netlink_hdr_push - Write the NETLINK buffers into a sk_buff
- * @skb: the packet
- * @pid: the PID of the receipient
- * @seq: the sequence number
- * @type: the generic NETLINK message family type
- * @cmd: command
- *
- * Description:
- * Write both a NETLINK nlmsghdr structure and a Generic NETLINK genlmsghdr
- * struct to the packet.
- *
- */
-static inline void netlbl_netlink_hdr_push(struct sk_buff *skb,
-					   u32 pid,
-					   u32 seq,
-					   int type,
-					   u8 cmd)
-
-{
-	struct nlmsghdr *nlh;
-	struct genlmsghdr *hdr;
-
-	nlh = (struct nlmsghdr *)skb_push(skb, NLMSG_SPACE(GENL_HDRLEN));
-	nlh->nlmsg_type = type;
-	nlh->nlmsg_len = skb->len;
-	nlh->nlmsg_flags = 0;
-	nlh->nlmsg_pid = pid;
-	nlh->nlmsg_seq = seq;
-
-	hdr = nlmsg_data(nlh);
-	hdr->cmd = cmd;
-	hdr->version = NETLBL_PROTO_VERSION;
-	hdr->reserved = 0;
-}
-
-/**
- * netlbl_netlink_payload_len - Return the length of the payload
- * @skb: the NETLINK buffer
- *
- * Description:
- * This function returns the length of the NetLabel payload.
- *
- */
-static inline u32 netlbl_netlink_payload_len(const struct sk_buff *skb)
-{
-	return nlmsg_len((struct nlmsghdr *)skb->data) - GENL_HDRLEN;
-}
-
-/**
- * netlbl_netlink_payload_data - Returns a pointer to the start of the payload
- * @skb: the NETLINK buffer
- *
- * Description:
- * This function returns a pointer to the start of the NetLabel payload.
- *
- */
-static inline void *netlbl_netlink_payload_data(const struct sk_buff *skb)
-{
-  return (unsigned char *)nlmsg_data((struct nlmsghdr *)skb->data) +
-	  GENL_HDRLEN;
-}
-
-/* NetLabel common protocol functions */
-
-void netlbl_netlink_send_ack(const struct genl_info *info,
-			     u32 genl_family,
-			     u8 ack_cmd,
-			     u32 ret_code);
-
 /* NetLabel NETLINK I/O functions */
 
 int netlbl_netlink_init(void);
-int netlbl_netlink_snd(struct sk_buff *skb, u32 pid);
-int netlbl_netlink_snd_multicast(struct sk_buff *skb, u32 pid, u32 group);
 
 #endif

--
paul moore
linux security @ hp
