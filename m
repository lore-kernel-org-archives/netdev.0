From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1 2/6] netlabel: Replace protocol/NetLabel linking with
	refrerence counts
Date: Fri, 08 Aug 2008 16:53:01 -0400
Message-ID: <20080808205301.21077.66315.stgit@flek>
References: <20080808203542.21077.37084.stgit@flek>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080808203542.21077.37084.stgit@flek>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetLabel has always had a list of backpointers in the CIPSO DOI definition
structure which pointed to the NetLabel LSM domain mapping structures which
referenced the CIPSO DOI struct.  The rationale for this was that when an
administrator removed a CIPSO DOI from the system all of the associated
NetLabel LSM domain mappings should be removed as well; a list of
backpointers made this a simple operation.

Unfortunately, while the backpointers did make the removal easier they were
a bit of a mess from an implementation point of view which was making
further development difficult.  Since the removal of a CIPSO DOI is a
realtively rare event it seems to make sense to remove this backpointer
list as the optimization was hurting us more then it was helping.  However,
we still need to be able to track when a CIPSO DOI definition is being used
so replace the backpointer list with a reference count.  In order to
preserve the current functionality of removing the associated LSM domain
mappings when a CIPSO DOI is removed we walk the LSM domain mapping table,
removing the relevant entries.

Signed-off-by: XXX
---

 include/net/cipso_ipv4.h           |    8 +-
 include/net/netlabel.h             |    2 
 net/ipv4/cipso_ipv4.c              |  165 +++++++++---------------------------
 net/netlabel/netlabel_cipso_v4.c   |   46 +++++++++-
 net/netlabel/netlabel_domainhash.c |   93 ++++++++++----------
 net/netlabel/netlabel_domainhash.h |    2 
 net/netlabel/netlabel_kapi.c       |   30 +++----
 net/netlabel/netlabel_mgmt.c       |   24 +----
 security/smack/smackfs.c           |   15 +++
 9 files changed, 164 insertions(+), 221 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a6bb945..d0416bf 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -40,6 +40,7 @@
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <net/netlabel.h>
+#include <asm/atomic.h>
 
 /* known doi values */
 #define CIPSO_V4_DOI_UNKNOWN          0x00000000
@@ -79,10 +80,11 @@ struct cipso_v4_doi {
 	} map;
 	u8 tags[CIPSO_V4_TAG_MAXCNT];
 
+	atomic_t refcount;
+
 	u32 valid;
 	struct list_head list;
 	struct rcu_head rcu;
-	struct list_head dom_list;
 };
 
 /* Standard CIPSO mapping table */
@@ -132,12 +134,10 @@ int cipso_v4_doi_remove(u32 doi,
 			struct netlbl_audit *audit_info,
 			void (*callback) (struct rcu_head * head));
 struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi);
+void cipso_v4_doi_putdef(struct cipso_v4_doi *doi_def);
 int cipso_v4_doi_walk(u32 *skip_cnt,
 		     int (*callback) (struct cipso_v4_doi *doi_def, void *arg),
 	             void *cb_arg);
-int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain);
-int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
-			       const char *domain);
 #else
 static inline int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
 {
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index e4d2d6b..6b93921 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -354,7 +354,7 @@ int netlbl_cfg_unlbl_add_map(const char *domain,
 			     struct netlbl_audit *audit_info);
 int netlbl_cfg_cipsov4_add(struct cipso_v4_doi *doi_def,
 			   struct netlbl_audit *audit_info);
-int netlbl_cfg_cipsov4_add_map(struct cipso_v4_doi *doi_def,
+int netlbl_cfg_cipsov4_add_map(u32 doi,
 			       const char *domain,
 			       struct netlbl_audit *audit_info);
 int netlbl_cfg_cipsov4_del(u32 doi, struct netlbl_audit *audit_info);
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 2c0e457..cdd0f6d 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -47,17 +47,7 @@
 #include <asm/bug.h>
 #include <asm/unaligned.h>
 
-struct cipso_v4_domhsh_entry {
-	char *domain;
-	u32 valid;
-	struct list_head list;
-	struct rcu_head rcu;
-};
-
 /* List of available DOI definitions */
-/* XXX - Updates should be minimal so having a single lock for the
- * cipso_v4_doi_list and the cipso_v4_doi_list->dom_list should be
- * okay. */
 /* XXX - This currently assumes a minimal number of different DOIs in use,
  * if in practice there are a lot of different DOIs this list should
  * probably be turned into a hash table or something similar so we
@@ -194,25 +184,6 @@ static void cipso_v4_bitmap_setbit(unsigned char *bitmap,
 }
 
 /**
- * cipso_v4_doi_domhsh_free - Frees a domain list entry
- * @entry: the entry's RCU field
- *
- * Description:
- * This function is designed to be used as a callback to the call_rcu()
- * function so that the memory allocated to a domain list entry can be released
- * safely.
- *
- */
-static void cipso_v4_doi_domhsh_free(struct rcu_head *entry)
-{
-	struct cipso_v4_domhsh_entry *ptr;
-
-	ptr = container_of(entry, struct cipso_v4_domhsh_entry, rcu);
-	kfree(ptr->domain);
-	kfree(ptr);
-}
-
-/**
  * cipso_v4_cache_entry_free - Frees a cache entry
  * @entry: the entry to free
  *
@@ -502,8 +473,8 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
 	}
 
 	doi_def->valid = 1;
+	atomic_set(&doi_def->refcount, 0);
 	INIT_RCU_HEAD(&doi_def->rcu);
-	INIT_LIST_HEAD(&doi_def->dom_list);
 
 	spin_lock(&cipso_v4_doi_list_lock);
 	if (cipso_v4_doi_search(doi_def->doi) != NULL)
@@ -536,42 +507,63 @@ int cipso_v4_doi_remove(u32 doi,
 			void (*callback) (struct rcu_head * head))
 {
 	struct cipso_v4_doi *doi_def;
-	struct cipso_v4_domhsh_entry *dom_iter;
 
 	spin_lock(&cipso_v4_doi_list_lock);
 	doi_def = cipso_v4_doi_search(doi);
-	if (doi_def != NULL) {
-		doi_def->valid = 0;
-		list_del_rcu(&doi_def->list);
+	if (doi_def == NULL) {
 		spin_unlock(&cipso_v4_doi_list_lock);
-		rcu_read_lock();
-		list_for_each_entry_rcu(dom_iter, &doi_def->dom_list, list)
-			if (dom_iter->valid)
-				netlbl_cfg_map_del(dom_iter->domain,
-						   audit_info);
-		rcu_read_unlock();
-		cipso_v4_cache_invalidate();
-		call_rcu(&doi_def->rcu, callback);
-		return 0;
+		return -ENOENT;
+	}
+	if (atomic_read(&doi_def->refcount) > 0) {
+		spin_unlock(&cipso_v4_doi_list_lock);
+		return -EBUSY;
 	}
+	doi_def->valid = 0;
+	list_del_rcu(&doi_def->list);
 	spin_unlock(&cipso_v4_doi_list_lock);
 
-	return -ENOENT;
+	cipso_v4_cache_invalidate();
+	call_rcu(&doi_def->rcu, callback);
+
+	return 0;
 }
 
 /**
- * cipso_v4_doi_getdef - Returns a pointer to a valid DOI definition
+ * cipso_v4_doi_getdef - Returns a reference to a valid DOI definition
  * @doi: the DOI value
  *
  * Description:
  * Searches for a valid DOI definition and if one is found it is returned to
  * the caller.  Otherwise NULL is returned.  The caller must ensure that
- * rcu_read_lock() is held while accessing the returned definition.
+ * rcu_read_lock() is held while accessing the returned definition and the DOI
+ * definition reference count is decremented when the caller is done.
  *
  */
 struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi)
 {
-	return cipso_v4_doi_search(doi);
+	struct cipso_v4_doi *doi_def;
+
+	rcu_read_lock();
+	doi_def = cipso_v4_doi_search(doi);
+	if (doi_def)
+		atomic_inc(&doi_def->refcount);
+	rcu_read_unlock();
+
+	return doi_def;
+}
+
+/**
+ * cipso_v4_doi_putdef - Releases a reference for the given DOI definition
+ * @doi_def: the DOI definition
+ *
+ * Description:
+ * Releases a DOI definition reference obtained from cipso_v4_doi_getdef().
+ *
+ */
+void cipso_v4_doi_putdef(struct cipso_v4_doi *doi_def)
+{
+	if (doi_def)
+		atomic_dec(&doi_def->refcount);
 }
 
 /**
@@ -613,85 +605,6 @@ doi_walk_return:
 	return ret_val;
 }
 
-/**
- * cipso_v4_doi_domhsh_add - Adds a domain entry to a DOI definition
- * @doi_def: the DOI definition
- * @domain: the domain to add
- *
- * Description:
- * Adds the @domain to the DOI specified by @doi_def, this function
- * should only be called by external functions (i.e. NetLabel).  This function
- * does allocate memory.  Returns zero on success, negative values on failure.
- *
- */
-int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain)
-{
-	struct cipso_v4_domhsh_entry *iter;
-	struct cipso_v4_domhsh_entry *new_dom;
-
-	new_dom = kzalloc(sizeof(*new_dom), GFP_KERNEL);
-	if (new_dom == NULL)
-		return -ENOMEM;
-	if (domain) {
-		new_dom->domain = kstrdup(domain, GFP_KERNEL);
-		if (new_dom->domain == NULL) {
-			kfree(new_dom);
-			return -ENOMEM;
-		}
-	}
-	new_dom->valid = 1;
-	INIT_RCU_HEAD(&new_dom->rcu);
-
-	spin_lock(&cipso_v4_doi_list_lock);
-	list_for_each_entry(iter, &doi_def->dom_list, list)
-		if (iter->valid &&
-		    ((domain != NULL && iter->domain != NULL &&
-		      strcmp(iter->domain, domain) == 0) ||
-		     (domain == NULL && iter->domain == NULL))) {
-			spin_unlock(&cipso_v4_doi_list_lock);
-			kfree(new_dom->domain);
-			kfree(new_dom);
-			return -EEXIST;
-		}
-	list_add_tail_rcu(&new_dom->list, &doi_def->dom_list);
-	spin_unlock(&cipso_v4_doi_list_lock);
-
-	return 0;
-}
-
-/**
- * cipso_v4_doi_domhsh_remove - Removes a domain entry from a DOI definition
- * @doi_def: the DOI definition
- * @domain: the domain to remove
- *
- * Description:
- * Removes the @domain from the DOI specified by @doi_def, this function
- * should only be called by external functions (i.e. NetLabel).   Returns zero
- * on success and negative values on error.
- *
- */
-int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
-			       const char *domain)
-{
-	struct cipso_v4_domhsh_entry *iter;
-
-	spin_lock(&cipso_v4_doi_list_lock);
-	list_for_each_entry(iter, &doi_def->dom_list, list)
-		if (iter->valid &&
-		    ((domain != NULL && iter->domain != NULL &&
-		      strcmp(iter->domain, domain) == 0) ||
-		     (domain == NULL && iter->domain == NULL))) {
-			iter->valid = 0;
-			list_del_rcu(&iter->list);
-			spin_unlock(&cipso_v4_doi_list_lock);
-			call_rcu(&iter->rcu, cipso_v4_doi_domhsh_free);
-			return 0;
-		}
-	spin_unlock(&cipso_v4_doi_list_lock);
-
-	return -ENOENT;
-}
-
 /*
  * Label Mapping Functions
  */
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 0aec318..309b5dc 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -43,6 +43,7 @@
 #include "netlabel_user.h"
 #include "netlabel_cipso_v4.h"
 #include "netlabel_mgmt.h"
+#include "netlabel_domainhash.h"
 
 /* Argument struct for cipso_v4_doi_walk() */
 struct netlbl_cipsov4_doiwalk_arg {
@@ -51,6 +52,12 @@ struct netlbl_cipsov4_doiwalk_arg {
 	u32 seq;
 };
 
+/* Argument struct for netlbl_domhsh_walk() */
+struct netlbl_domhsh_walk_arg {
+	struct netlbl_audit *audit_info;
+	u32 doi;
+};
+
 /* NetLabel Generic NETLINK CIPSOv4 family */
 static struct genl_family netlbl_cipsov4_gnl_family = {
 	.id = GENL_ID_GENERATE,
@@ -668,6 +675,29 @@ static int netlbl_cipsov4_listall(struct sk_buff *skb,
 }
 
 /**
+ * netlbl_cipsov4_remove_cb - netlbl_cipsov4_remove() callback for REMOVE
+ * @entry: LSM domain mapping entry
+ * @arg: the netlbl_domhsh_walk_arg structure
+ *
+ * Description:
+ * This function is intended for use by netlbl_cipsov4_remove() as the callback
+ * for the netlbl_domhsh_walk() function; it removes LSM domain map entries
+ * which are associated with the CIPSO DOI specified in @arg.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static int netlbl_cipsov4_remove_cb(struct netlbl_dom_map *entry, void *arg)
+{
+	struct netlbl_domhsh_walk_arg *cb_arg = arg;
+
+	if (entry->type == NETLBL_NLTYPE_CIPSOV4 &&
+	    entry->type_def.cipsov4->doi == cb_arg->doi)
+		return netlbl_domhsh_remove_entry(entry, cb_arg->audit_info);
+
+	return 0;
+}
+
+/**
  * netlbl_cipsov4_remove - Handle a REMOVE message
  * @skb: the NETLINK buffer
  * @info: the Generic NETLINK info block
@@ -681,6 +711,7 @@ static int netlbl_cipsov4_remove(struct sk_buff *skb, struct genl_info *info)
 {
 	int ret_val = -EINVAL;
 	u32 doi = 0;
+	struct netlbl_domhsh_walk_arg cb_arg;
 	struct audit_buffer *audit_buf;
 	struct netlbl_audit audit_info;
 
@@ -690,11 +721,16 @@ static int netlbl_cipsov4_remove(struct sk_buff *skb, struct genl_info *info)
 	doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
 	netlbl_netlink_auditinfo(skb, &audit_info);
 
-	ret_val = cipso_v4_doi_remove(doi,
-				      &audit_info,
-				      netlbl_cipsov4_doi_free);
-	if (ret_val == 0)
-		atomic_dec(&netlabel_mgmt_protocount);
+	cb_arg.doi = doi;
+	cb_arg.audit_info = &audit_info;
+	ret_val = netlbl_domhsh_walk(0, 0, netlbl_cipsov4_remove_cb, &cb_arg);
+	if (ret_val == 0) {
+		ret_val = cipso_v4_doi_remove(doi,
+					      &audit_info,
+					      netlbl_cipsov4_doi_free);
+		if (ret_val == 0)
+			atomic_dec(&netlabel_mgmt_protocount);
+	}
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_DEL,
 					      &audit_info);
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 643c032..1df4d6c 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -217,20 +217,6 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	u32 bkt;
 	struct audit_buffer *audit_buf;
 
-	switch (entry->type) {
-	case NETLBL_NLTYPE_UNLABELED:
-		ret_val = 0;
-		break;
-	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = cipso_v4_doi_domhsh_add(entry->type_def.cipsov4,
-						  entry->domain);
-		break;
-	default:
-		return -EINVAL;
-	}
-	if (ret_val != 0)
-		return ret_val;
-
 	entry->valid = 1;
 	INIT_RCU_HEAD(&entry->rcu);
 
@@ -271,16 +257,6 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	}
 	rcu_read_unlock();
 
-	if (ret_val != 0) {
-		switch (entry->type) {
-		case NETLBL_NLTYPE_CIPSOV4:
-			if (cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
-						       entry->domain) != 0)
-				BUG();
-			break;
-		}
-	}
-
 	return ret_val;
 }
 
@@ -302,35 +278,26 @@ int netlbl_domhsh_add_default(struct netlbl_dom_map *entry,
 }
 
 /**
- * netlbl_domhsh_remove - Removes an entry from the domain hash table
- * @domain: the domain to remove
+ * netlbl_domhsh_remove_entry - Removes a given entry from the domain table
+ * @entry: the entry to remove
  * @audit_info: NetLabel audit information
  *
  * Description:
  * Removes an entry from the domain hash table and handles any updates to the
- * lower level protocol handler (i.e. CIPSO).  Returns zero on success,
- * negative on failure.
+ * lower level protocol handler (i.e. CIPSO).  Caller is responsible for
+ * ensuring that the RCU read lock is held.  Returns zero on success, negative
+ * on failure.
  *
  */
-int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
+int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
+			       struct netlbl_audit *audit_info)
 {
-	int ret_val = -ENOENT;
-	struct netlbl_dom_map *entry;
+	int ret_val = 0;
 	struct audit_buffer *audit_buf;
 
-	rcu_read_lock();
-	if (domain)
-		entry = netlbl_domhsh_search(domain);
-	else
-		entry = netlbl_domhsh_search_def(domain);
 	if (entry == NULL)
-		goto remove_return;
-	switch (entry->type) {
-	case NETLBL_NLTYPE_CIPSOV4:
-		cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
-					   entry->domain);
-		break;
-	}
+		return -ENOENT;
+
 	spin_lock(&netlbl_domhsh_lock);
 	if (entry->valid) {
 		entry->valid = 0;
@@ -338,9 +305,16 @@ int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
 			list_del_rcu(&entry->list);
 		else
 			rcu_assign_pointer(netlbl_domhsh_def, NULL);
-		ret_val = 0;
-	}
+	} else
+		ret_val = -ENOENT;
 	spin_unlock(&netlbl_domhsh_lock);
+	if (ret_val == 0) {
+		switch (entry->type) {
+		case NETLBL_NLTYPE_CIPSOV4:
+			cipso_v4_doi_putdef(entry->type_def.cipsov4);
+			break;
+		}
+	}
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_DEL, audit_info);
 	if (audit_buf != NULL) {
@@ -351,14 +325,39 @@ int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
 		audit_log_end(audit_buf);
 	}
 
-remove_return:
-	rcu_read_unlock();
 	if (ret_val == 0)
 		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
 	return ret_val;
 }
 
 /**
+ * netlbl_domhsh_remove - Removes an entry from the domain hash table
+ * @domain: the domain to remove
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * Removes an entry from the domain hash table and handles any updates to the
+ * lower level protocol handler (i.e. CIPSO).  Returns zero on success,
+ * negative on failure.
+ *
+ */
+int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
+{
+	int ret_val;
+	struct netlbl_dom_map *entry;
+
+	rcu_read_lock();
+	if (domain)
+		entry = netlbl_domhsh_search(domain);
+	else
+		entry = netlbl_domhsh_search_def(domain);
+	ret_val = netlbl_domhsh_remove_entry(entry, audit_info);
+	rcu_read_unlock();
+
+	return ret_val;
+}
+
+/**
  * netlbl_domhsh_remove_default - Removes the default entry from the table
  * @audit_info: NetLabel audit information
  *
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index 8220990..afcc41a 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -61,6 +61,8 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 		      struct netlbl_audit *audit_info);
 int netlbl_domhsh_add_default(struct netlbl_dom_map *entry,
 			      struct netlbl_audit *audit_info);
+int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
+			       struct netlbl_audit *audit_info);
 int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info);
 int netlbl_domhsh_remove_default(struct netlbl_audit *audit_info);
 struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 39793a1..e77f281 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -147,7 +147,7 @@ int netlbl_cfg_cipsov4_add(struct cipso_v4_doi *doi_def,
 }
 
 /**
- * netlbl_cfg_cipsov4_add_map - Add a new CIPSOv4 DOI definition and mapping
+ * netlbl_cfg_cipsov4_add_map - Add a new CIPSOv4 DOI mapping
  * @doi_def: the DOI definition
  * @domain: the domain mapping to add
  * @audit_info: NetLabel audit information
@@ -159,7 +159,7 @@ int netlbl_cfg_cipsov4_add(struct cipso_v4_doi *doi_def,
  * failure.
  *
  */
-int netlbl_cfg_cipsov4_add_map(struct cipso_v4_doi *doi_def,
+int netlbl_cfg_cipsov4_add_map(u32 doi,
 			       const char *domain,
 			       struct netlbl_audit *audit_info)
 {
@@ -175,30 +175,24 @@ int netlbl_cfg_cipsov4_add_map(struct cipso_v4_doi *doi_def,
 			goto cfg_cipsov4_add_map_failure;
 	}
 	entry->type = NETLBL_NLTYPE_CIPSOV4;
-	entry->type_def.cipsov4 = doi_def;
-
-	/* Grab a RCU read lock here so nothing happens to the doi_def variable
-	 * between adding it to the CIPSOv4 protocol engine and adding a
-	 * domain mapping for it. */
+	entry->type_def.cipsov4 = cipso_v4_doi_getdef(doi);
+	if (entry->type_def.cipsov4 == NULL) {
+		ret_val = -ENOENT;
+		goto cfg_cipsov4_add_map_failure;
+	}
 
-	rcu_read_lock();
-	ret_val = netlbl_cfg_cipsov4_add(doi_def, audit_info);
-	if (ret_val != 0)
-		goto cfg_cipsov4_add_map_failure_unlock;
 	ret_val = netlbl_domhsh_add(entry, audit_info);
 	if (ret_val != 0)
-		goto cfg_cipsov4_add_map_failure_remove_doi;
-	rcu_read_unlock();
+		goto cfg_cipsov4_add_map_failure;
 
 	return 0;
 
-cfg_cipsov4_add_map_failure_remove_doi:
-	cipso_v4_doi_remove(doi_def->doi, audit_info, netlbl_cipsov4_doi_free);
-cfg_cipsov4_add_map_failure_unlock:
-	rcu_read_unlock();
 cfg_cipsov4_add_map_failure:
-	if (entry != NULL)
+	if (entry != NULL) {
+		if (entry->type_def.cipsov4 != NULL)
+			cipso_v4_doi_putdef(entry->type_def.cipsov4);
 		kfree(entry->domain);
+	}
 	kfree(entry);
 	return ret_val;
 }
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 44be5d5..c4e18c7 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -122,18 +122,12 @@ static int netlbl_mgmt_add(struct sk_buff *skb, struct genl_info *info)
 			goto add_failure;
 
 		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
-		/* We should be holding a rcu_read_lock() here while we hold
-		 * the result but since the entry will always be deleted when
-		 * the CIPSO DOI is deleted we aren't going to keep the
-		 * lock. */
-		rcu_read_lock();
 		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
-		if (entry->type_def.cipsov4 == NULL) {
-			rcu_read_unlock();
+		if (entry->type_def.cipsov4 == NULL)
 			goto add_failure;
-		}
 		ret_val = netlbl_domhsh_add(entry, &audit_info);
-		rcu_read_unlock();
+		if (ret_val != 0)
+			cipso_v4_doi_putdef(entry->type_def.cipsov4);
 		break;
 	default:
 		goto add_failure;
@@ -294,18 +288,12 @@ static int netlbl_mgmt_adddef(struct sk_buff *skb, struct genl_info *info)
 			goto adddef_failure;
 
 		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
-		/* We should be holding a rcu_read_lock() here while we hold
-		 * the result but since the entry will always be deleted when
-		 * the CIPSO DOI is deleted we aren't going to keep the
-		 * lock. */
-		rcu_read_lock();
 		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
-		if (entry->type_def.cipsov4 == NULL) {
-			rcu_read_unlock();
+		if (entry->type_def.cipsov4 == NULL)
 			goto adddef_failure;
-		}
 		ret_val = netlbl_domhsh_add_default(entry, &audit_info);
-		rcu_read_unlock();
+		if (ret_val != 0)
+			cipso_v4_doi_putdef(entry->type_def.cipsov4);
 		break;
 	default:
 		goto adddef_failure;
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index 271a835..8d031ca 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -342,10 +342,21 @@ static void smk_cipso_doi(void)
 	for (rc = 1; rc < CIPSO_V4_TAG_MAXCNT; rc++)
 		doip->tags[rc] = CIPSO_V4_TAG_INVALID;
 
-	rc = netlbl_cfg_cipsov4_add_map(doip, NULL, &audit_info);
-	if (rc != 0)
+	rc = netlbl_cfg_cipsov4_add(doip, &audit_info);
+	if (rc != 0) {
 		printk(KERN_WARNING "%s:%d add rc = %d\n",
+		       __func__, __LINE__, rc);	
+		goto err;
+	}
+	rc = netlbl_cfg_cipsov4_add_map(doip->doi, NULL, &audit_info);
+	if (rc != 0) {
+		printk(KERN_WARNING "%s:%d add_map rc = %d\n",
 		       __func__, __LINE__, rc);
+		goto err;
+	}
+
+err:
+	kfree(doip);
 }
 
 /**

