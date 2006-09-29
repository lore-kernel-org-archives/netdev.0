From: paul.moore@hp.com
Subject: [PATCH 1/1] NetLabel: audit fixups due to delayed feedback
Date: Fri, 29 Sep 2006 18:39:50 -0400
Message-ID: <20060929224355.253290000@hp.com>
References: <20060929223948.975556000@hp.com>
Cc: selinux@tycho.nsa.gov, sgrubb@redhat.com,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:38815 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S932122AbWI2Wn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 18:43:57 -0400
To: netdev@vger.kernel.org, linux-audit@redhat.com
Content-Disposition: inline; filename=netlabel-audit_fixups
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some issues Steve Grubb had with the way NetLabel was using the audit
subsystem.  This should make NetLabel more consistent with other kernel
generated audit messages specifying configuration changes.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/linux/audit.h              |   11 ++--
 include/net/cipso_ipv4.h           |    4 -
 include/net/netlabel.h             |    8 +++
 net/ipv4/cipso_ipv4.c              |    4 -
 net/netlabel/netlabel_cipso_v4.c   |   48 +++++++++++++--------
 net/netlabel/netlabel_domainhash.c |   82 +++++++++++++++++++------------------
 net/netlabel/netlabel_domainhash.h |    8 ++-
 net/netlabel/netlabel_mgmt.c       |   27 ++++++++----
 net/netlabel/netlabel_unlabeled.c  |   34 ++++++++++-----
 net/netlabel/netlabel_user.c       |   66 +++--------------------------
 net/netlabel/netlabel_user.h       |   16 ++++++-
 11 files changed, 157 insertions(+), 151 deletions(-)

Index: net-2.6/include/linux/audit.h
===================================================================
--- net-2.6.orig/include/linux/audit.h
+++ net-2.6/include/linux/audit.h
@@ -95,12 +95,11 @@
 #define AUDIT_MAC_POLICY_LOAD	1403	/* Policy file load */
 #define AUDIT_MAC_STATUS	1404	/* Changed enforcing,permissive,off */
 #define AUDIT_MAC_CONFIG_CHANGE	1405	/* Changes to booleans */
-#define AUDIT_MAC_UNLBL_ACCEPT	1406	/* NetLabel: allow unlabeled traffic */
-#define AUDIT_MAC_UNLBL_DENY	1407	/* NetLabel: deny unlabeled traffic */
-#define AUDIT_MAC_CIPSOV4_ADD	1408	/* NetLabel: add CIPSOv4 DOI entry */
-#define AUDIT_MAC_CIPSOV4_DEL	1409	/* NetLabel: del CIPSOv4 DOI entry */
-#define AUDIT_MAC_MAP_ADD	1410	/* NetLabel: add LSM domain mapping */
-#define AUDIT_MAC_MAP_DEL	1411	/* NetLabel: del LSM domain mapping */
+#define AUDIT_MAC_UNLBL_ALLOW	1406	/* NetLabel: allow unlabeled traffic */
+#define AUDIT_MAC_CIPSOV4_ADD	1407	/* NetLabel: add CIPSOv4 DOI entry */
+#define AUDIT_MAC_CIPSOV4_DEL	1408	/* NetLabel: del CIPSOv4 DOI entry */
+#define AUDIT_MAC_MAP_ADD	1409	/* NetLabel: add LSM domain mapping */
+#define AUDIT_MAC_MAP_DEL	1410	/* NetLabel: del LSM domain mapping */
 
 #define AUDIT_FIRST_KERN_ANOM_MSG   1700
 #define AUDIT_LAST_KERN_ANOM_MSG    1799
Index: net-2.6/include/net/cipso_ipv4.h
===================================================================
--- net-2.6.orig/include/net/cipso_ipv4.h
+++ net-2.6/include/net/cipso_ipv4.h
@@ -129,7 +129,7 @@ extern int cipso_v4_rbm_strictvalid;
 #ifdef CONFIG_NETLABEL
 int cipso_v4_doi_add(struct cipso_v4_doi *doi_def);
 int cipso_v4_doi_remove(u32 doi,
-			u32 audit_secid,
+			struct netlbl_audit *audit_info,
 			void (*callback) (struct rcu_head * head));
 struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi);
 int cipso_v4_doi_walk(u32 *skip_cnt,
@@ -145,7 +145,7 @@ static inline int cipso_v4_doi_add(struc
 }
 
 static inline int cipso_v4_doi_remove(u32 doi,
-				    u32 audit_secid,
+				    struct netlbl_audit *audit_info,
 				    void (*callback) (struct rcu_head * head))
 {
 	return 0;
Index: net-2.6/include/net/netlabel.h
===================================================================
--- net-2.6.orig/include/net/netlabel.h
+++ net-2.6/include/net/netlabel.h
@@ -92,11 +92,17 @@
  *
  */
 
+/* NetLabel audit information */
+struct netlbl_audit {
+	u32 secid;
+	uid_t loginuid;
+};
+
 /* Domain mapping definition struct */
 struct netlbl_dom_map;
 
 /* Domain mapping operations */
-int netlbl_domhsh_remove(const char *domain, u32 audit_secid);
+int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info);
 
 /* LSM security attributes */
 struct netlbl_lsm_cache {
Index: net-2.6/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6/net/ipv4/cipso_ipv4.c
@@ -485,7 +485,7 @@ doi_add_failure_rlock:
  *
  */
 int cipso_v4_doi_remove(u32 doi,
-			u32 audit_secid,
+			struct netlbl_audit *audit_info,
 			void (*callback) (struct rcu_head * head))
 {
 	struct cipso_v4_doi *doi_def;
@@ -506,7 +506,7 @@ int cipso_v4_doi_remove(u32 doi,
 		list_for_each_entry_rcu(dom_iter, &doi_def->dom_list, list)
 			if (dom_iter->valid)
 				netlbl_domhsh_remove(dom_iter->domain,
-						     audit_secid);
+						     audit_info);
 		cipso_v4_cache_invalidate();
 		rcu_read_unlock();
 
Index: net-2.6/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.orig/net/netlabel/netlabel_cipso_v4.c
+++ net-2.6/net/netlabel/netlabel_cipso_v4.c
@@ -384,11 +384,15 @@ static int netlbl_cipsov4_add(struct sk_
 	u32 doi;
 	const char *type_str = "(unknown)";
 	struct audit_buffer *audit_buf;
+	struct netlbl_audit audit_info;
 
 	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
 	    !info->attrs[NLBL_CIPSOV4_A_MTYPE])
 		return -EINVAL;
 
+	doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
+	netlbl_netlink_auditinfo(skb, &audit_info);
+
 	type = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_MTYPE]);
 	switch (type) {
 	case CIPSO_V4_MAP_STD:
@@ -401,13 +405,14 @@ static int netlbl_cipsov4_add(struct sk_
 		break;
 	}
 
-	if (ret_val == 0) {
-		doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
-		audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_ADD,
-						      NETLINK_CB(skb).sid);
-		audit_log_format(audit_buf, " doi=%u type=%s", doi, type_str);
-		audit_log_end(audit_buf);
-	}
+	audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_ADD,
+					      &audit_info);
+	audit_log_format(audit_buf,
+			 " cipso_doi=%u cipso_type=%s res=%u",
+			 doi,
+			 type_str,
+			 ret_val == 0 ? 1 : 0);
+	audit_log_end(audit_buf);
 
 	return ret_val;
 }
@@ -668,20 +673,25 @@ static int netlbl_cipsov4_remove(struct 
 	int ret_val = -EINVAL;
 	u32 doi = 0;
 	struct audit_buffer *audit_buf;
+	struct netlbl_audit audit_info;
 
-	if (info->attrs[NLBL_CIPSOV4_A_DOI]) {
-		doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
-		ret_val = cipso_v4_doi_remove(doi,
-					      NETLINK_CB(skb).sid,
-					      netlbl_cipsov4_doi_free);
-	}
+	if (!info->attrs[NLBL_CIPSOV4_A_DOI])
+		return -EINVAL;
 
-	if (ret_val == 0) {
-		audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_DEL,
-						      NETLINK_CB(skb).sid);
-		audit_log_format(audit_buf, " doi=%u", doi);
-		audit_log_end(audit_buf);
-	}
+	doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
+	netlbl_netlink_auditinfo(skb, &audit_info);
+
+	ret_val = cipso_v4_doi_remove(doi,
+				      &audit_info,
+				      netlbl_cipsov4_doi_free);
+
+	audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_DEL,
+					      &audit_info);
+	audit_log_format(audit_buf,
+			 " cipso_doi=%u res=%u",
+			 doi,
+			 ret_val == 0 ? 1 : 0);
+	audit_log_end(audit_buf);
 
 	return ret_val;
 }
Index: net-2.6/net/netlabel/netlabel_domainhash.c
===================================================================
--- net-2.6.orig/net/netlabel/netlabel_domainhash.c
+++ net-2.6/net/netlabel/netlabel_domainhash.c
@@ -188,7 +188,7 @@ int netlbl_domhsh_init(u32 size)
 /**
  * netlbl_domhsh_add - Adds a entry to the domain hash table
  * @entry: the entry to add
- * @audit_secid: the LSM secid to use in the audit message
+ * @audit_info: NetLabel audit information
  *
  * Description:
  * Adds a new entry to the domain hash table and handles any updates to the
@@ -196,7 +196,8 @@ int netlbl_domhsh_init(u32 size)
  * negative on failure.
  *
  */
-int netlbl_domhsh_add(struct netlbl_dom_map *entry, u32 audit_secid)
+int netlbl_domhsh_add(struct netlbl_dom_map *entry,
+		      struct netlbl_audit *audit_info)
 {
 	int ret_val;
 	u32 bkt;
@@ -241,26 +242,26 @@ int netlbl_domhsh_add(struct netlbl_dom_
 		spin_unlock(&netlbl_domhsh_def_lock);
 	} else
 		ret_val = -EINVAL;
-	if (ret_val == 0) {
-		if (entry->domain != NULL)
-			audit_domain = entry->domain;
-		else
-			audit_domain = "(default)";
-		audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD,
-						      audit_secid);
-		audit_log_format(audit_buf, " domain=%s", audit_domain);
-		switch (entry->type) {
-		case NETLBL_NLTYPE_UNLABELED:
-			audit_log_format(audit_buf, " protocol=unlbl");
-			break;
-		case NETLBL_NLTYPE_CIPSOV4:
-			audit_log_format(audit_buf,
-					 " protocol=cipsov4 doi=%u",
-					 entry->type_def.cipsov4->doi);
-			break;
-		}
-		audit_log_end(audit_buf);
+
+	if (entry->domain != NULL)
+		audit_domain = entry->domain;
+	else
+		audit_domain = "(default)";
+	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD, audit_info);
+	audit_log_format(audit_buf, " nlbl_domain=%s", audit_domain);
+	switch (entry->type) {
+	case NETLBL_NLTYPE_UNLABELED:
+		audit_log_format(audit_buf, " nlbl_protocol=unlbl");
+		break;
+	case NETLBL_NLTYPE_CIPSOV4:
+		audit_log_format(audit_buf,
+				 " nlbl_protocol=cipsov4 cipso_doi=%u",
+				 entry->type_def.cipsov4->doi);
+		break;
 	}
+	audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
+	audit_log_end(audit_buf);
+
 	rcu_read_unlock();
 
 	if (ret_val != 0) {
@@ -279,7 +280,7 @@ int netlbl_domhsh_add(struct netlbl_dom_
 /**
  * netlbl_domhsh_add_default - Adds the default entry to the domain hash table
  * @entry: the entry to add
- * @audit_secid: the LSM secid to use in the audit message
+ * @audit_info: NetLabel audit information
  *
  * Description:
  * Adds a new default entry to the domain hash table and handles any updates
@@ -287,15 +288,16 @@ int netlbl_domhsh_add(struct netlbl_dom_
  * negative on failure.
  *
  */
-int netlbl_domhsh_add_default(struct netlbl_dom_map *entry, u32 audit_secid)
+int netlbl_domhsh_add_default(struct netlbl_dom_map *entry,
+			      struct netlbl_audit *audit_info)
 {
-	return netlbl_domhsh_add(entry, audit_secid);
+	return netlbl_domhsh_add(entry, audit_info);
 }
 
 /**
  * netlbl_domhsh_remove - Removes an entry from the domain hash table
  * @domain: the domain to remove
- * @audit_secid: the LSM secid to use in the audit message
+ * @audit_info: NetLabel audit information
  *
  * Description:
  * Removes an entry from the domain hash table and handles any updates to the
@@ -303,7 +305,7 @@ int netlbl_domhsh_add_default(struct net
  * negative on failure.
  *
  */
-int netlbl_domhsh_remove(const char *domain, u32 audit_secid)
+int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
 {
 	int ret_val = -ENOENT;
 	struct netlbl_dom_map *entry;
@@ -345,18 +347,20 @@ int netlbl_domhsh_remove(const char *dom
 			ret_val = -ENOENT;
 		spin_unlock(&netlbl_domhsh_def_lock);
 	}
-	if (ret_val == 0) {
-		if (entry->domain != NULL)
-			audit_domain = entry->domain;
-		else
-			audit_domain = "(default)";
-		audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_DEL,
-						      audit_secid);
-		audit_log_format(audit_buf, " domain=%s", audit_domain);
-		audit_log_end(audit_buf);
 
+	if (entry->domain != NULL)
+		audit_domain = entry->domain;
+	else
+		audit_domain = "(default)";
+	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_DEL, audit_info);
+	audit_log_format(audit_buf,
+			 " nlbl_domain=%s res=%u",
+			 audit_domain,
+			 ret_val == 0 ? 1 : 0);
+	audit_log_end(audit_buf);
+
+	if (ret_val == 0)
 		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
-	}
 
 remove_return:
 	rcu_read_unlock();
@@ -365,7 +369,7 @@ remove_return:
 
 /**
  * netlbl_domhsh_remove_default - Removes the default entry from the table
- * @audit_secid: the LSM secid to use in the audit message
+ * @audit_info: NetLabel audit information
  *
  * Description:
  * Removes/resets the default entry for the domain hash table and handles any
@@ -373,9 +377,9 @@ remove_return:
  * success, non-zero on failure.
  *
  */
-int netlbl_domhsh_remove_default(u32 audit_secid)
+int netlbl_domhsh_remove_default(struct netlbl_audit *audit_info)
 {
-	return netlbl_domhsh_remove(NULL, audit_secid);
+	return netlbl_domhsh_remove(NULL, audit_info);
 }
 
 /**
Index: net-2.6/net/netlabel/netlabel_domainhash.h
===================================================================
--- net-2.6.orig/net/netlabel/netlabel_domainhash.h
+++ net-2.6/net/netlabel/netlabel_domainhash.h
@@ -57,9 +57,11 @@ struct netlbl_dom_map {
 int netlbl_domhsh_init(u32 size);
 
 /* Manipulate the domain hash table */
-int netlbl_domhsh_add(struct netlbl_dom_map *entry, u32 audit_secid);
-int netlbl_domhsh_add_default(struct netlbl_dom_map *entry, u32 audit_secid);
-int netlbl_domhsh_remove_default(u32 audit_secid);
+int netlbl_domhsh_add(struct netlbl_dom_map *entry,
+		      struct netlbl_audit *audit_info);
+int netlbl_domhsh_add_default(struct netlbl_dom_map *entry,
+			      struct netlbl_audit *audit_info);
+int netlbl_domhsh_remove_default(struct netlbl_audit *audit_info);
 struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
 int netlbl_domhsh_walk(u32 *skip_bkt,
 		     u32 *skip_chain,
Index: net-2.6/net/netlabel/netlabel_mgmt.c
===================================================================
--- net-2.6.orig/net/netlabel/netlabel_mgmt.c
+++ net-2.6/net/netlabel/netlabel_mgmt.c
@@ -87,11 +87,14 @@ static int netlbl_mgmt_add(struct sk_buf
 	struct netlbl_dom_map *entry = NULL;
 	size_t tmp_size;
 	u32 tmp_val;
+	struct netlbl_audit audit_info;
 
 	if (!info->attrs[NLBL_MGMT_A_DOMAIN] ||
 	    !info->attrs[NLBL_MGMT_A_PROTOCOL])
 		goto add_failure;
 
+	netlbl_netlink_auditinfo(skb, &audit_info);
+
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (entry == NULL) {
 		ret_val = -ENOMEM;
@@ -108,7 +111,7 @@ static int netlbl_mgmt_add(struct sk_buf
 
 	switch (entry->type) {
 	case NETLBL_NLTYPE_UNLABELED:
-		ret_val = netlbl_domhsh_add(entry, NETLINK_CB(skb).sid);
+		ret_val = netlbl_domhsh_add(entry, &audit_info);
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
 		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
@@ -125,7 +128,7 @@ static int netlbl_mgmt_add(struct sk_buf
 			rcu_read_unlock();
 			goto add_failure;
 		}
-		ret_val = netlbl_domhsh_add(entry, NETLINK_CB(skb).sid);
+		ret_val = netlbl_domhsh_add(entry, &audit_info);
 		rcu_read_unlock();
 		break;
 	default:
@@ -156,12 +159,15 @@ add_failure:
 static int netlbl_mgmt_remove(struct sk_buff *skb, struct genl_info *info)
 {
 	char *domain;
+	struct netlbl_audit audit_info;
 
 	if (!info->attrs[NLBL_MGMT_A_DOMAIN])
 		return -EINVAL;
 
+	netlbl_netlink_auditinfo(skb, &audit_info);
+
 	domain = nla_data(info->attrs[NLBL_MGMT_A_DOMAIN]);
-	return netlbl_domhsh_remove(domain, NETLINK_CB(skb).sid);
+	return netlbl_domhsh_remove(domain, &audit_info);
 }
 
 /**
@@ -264,10 +270,13 @@ static int netlbl_mgmt_adddef(struct sk_
 	int ret_val = -EINVAL;
 	struct netlbl_dom_map *entry = NULL;
 	u32 tmp_val;
+	struct netlbl_audit audit_info;
 
 	if (!info->attrs[NLBL_MGMT_A_PROTOCOL])
 		goto adddef_failure;
 
+	netlbl_netlink_auditinfo(skb, &audit_info);
+
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (entry == NULL) {
 		ret_val = -ENOMEM;
@@ -277,8 +286,7 @@ static int netlbl_mgmt_adddef(struct sk_
 
 	switch (entry->type) {
 	case NETLBL_NLTYPE_UNLABELED:
-		ret_val = netlbl_domhsh_add_default(entry,
-						    NETLINK_CB(skb).sid);
+		ret_val = netlbl_domhsh_add_default(entry, &audit_info);
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
 		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
@@ -295,8 +303,7 @@ static int netlbl_mgmt_adddef(struct sk_
 			rcu_read_unlock();
 			goto adddef_failure;
 		}
-		ret_val = netlbl_domhsh_add_default(entry,
-						    NETLINK_CB(skb).sid);
+		ret_val = netlbl_domhsh_add_default(entry, &audit_info);
 		rcu_read_unlock();
 		break;
 	default:
@@ -324,7 +331,11 @@ adddef_failure:
  */
 static int netlbl_mgmt_removedef(struct sk_buff *skb, struct genl_info *info)
 {
-	return netlbl_domhsh_remove_default(NETLINK_CB(skb).sid);
+	struct netlbl_audit audit_info;
+
+	netlbl_netlink_auditinfo(skb, &audit_info);
+
+	return netlbl_domhsh_remove_default(&audit_info);
 }
 
 /**
Index: net-2.6/net/netlabel/netlabel_unlabeled.c
===================================================================
--- net-2.6.orig/net/netlabel/netlabel_unlabeled.c
+++ net-2.6/net/netlabel/netlabel_unlabeled.c
@@ -70,18 +70,25 @@ static struct nla_policy netlbl_unlabel_
 /**
  * netlbl_unlabel_acceptflg_set - Set the unlabeled accept flag
  * @value: desired value
- * @audit_secid: the LSM secid to use in the audit message
+ * @audit_info: NetLabel audit information
  *
  * Description:
  * Set the value of the unlabeled accept flag to @value.
  *
  */
-static void netlbl_unlabel_acceptflg_set(u8 value, u32 audit_secid)
+static void netlbl_unlabel_acceptflg_set(u8 value,
+					 struct netlbl_audit *audit_info)
 {
+	struct audit_buffer *audit_buf;
+	u8 old_val;
+
+	old_val = atomic_read(&netlabel_unlabel_accept_flg);
 	atomic_set(&netlabel_unlabel_accept_flg, value);
-	netlbl_audit_nomsg((value ?
-			    AUDIT_MAC_UNLBL_ACCEPT : AUDIT_MAC_UNLBL_DENY),
-			   audit_secid);
+
+	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_ALLOW,
+					      audit_info);
+	audit_log_format(audit_buf, " unlbl_accept=%u old=%u", value, old_val);
+	audit_log_end(audit_buf);
 }
 
 /*
@@ -101,12 +108,13 @@ static void netlbl_unlabel_acceptflg_set
 static int netlbl_unlabel_accept(struct sk_buff *skb, struct genl_info *info)
 {
 	u8 value;
+	struct netlbl_audit audit_info;
 
 	if (info->attrs[NLBL_UNLABEL_A_ACPTFLG]) {
 		value = nla_get_u8(info->attrs[NLBL_UNLABEL_A_ACPTFLG]);
 		if (value == 1 || value == 0) {
-			netlbl_unlabel_acceptflg_set(value,
-						     NETLINK_CB(skb).sid);
+			netlbl_netlink_auditinfo(skb, &audit_info);
+			netlbl_unlabel_acceptflg_set(value, &audit_info);
 			return 0;
 		}
 	}
@@ -250,19 +258,23 @@ int netlbl_unlabel_defconf(void)
 {
 	int ret_val;
 	struct netlbl_dom_map *entry;
-	u32 secid;
+	struct netlbl_audit audit_info;
 
-	security_task_getsecid(current, &secid);
+	/* Only the kernel is allowed to call this function and the only time
+	 * it is called is at bootup before the audit subsystem is reporting
+	 * messages so don't worry to much about these values. */
+	security_task_getsecid(current, &audit_info.secid);
+	audit_info.loginuid = 0;
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (entry == NULL)
 		return -ENOMEM;
 	entry->type = NETLBL_NLTYPE_UNLABELED;
-	ret_val = netlbl_domhsh_add_default(entry, secid);
+	ret_val = netlbl_domhsh_add_default(entry, &audit_info);
 	if (ret_val != 0)
 		return ret_val;
 
-	netlbl_unlabel_acceptflg_set(1, secid);
+	netlbl_unlabel_acceptflg_set(1, &audit_info);
 
 	return 0;
 }
Index: net-2.6/net/netlabel/netlabel_user.c
===================================================================
--- net-2.6.orig/net/netlabel/netlabel_user.c
+++ net-2.6/net/netlabel/netlabel_user.c
@@ -85,7 +85,7 @@ int netlbl_netlink_init(void)
 /**
  * netlbl_audit_start_common - Start an audit message
  * @type: audit message type
- * @secid: LSM context ID
+ * @audit_info: NetLabel audit information
  *
  * Description:
  * Start an audit message using the type specified in @type and fill the audit
@@ -93,14 +93,11 @@ int netlbl_netlink_init(void)
  * a pointer to the audit buffer on success, NULL on failure.
  *
  */
-struct audit_buffer *netlbl_audit_start_common(int type, u32 secid)
+struct audit_buffer *netlbl_audit_start_common(int type,
+					       struct netlbl_audit *audit_info)
 {
 	struct audit_context *audit_ctx = current->audit_context;
 	struct audit_buffer *audit_buf;
-	uid_t audit_loginuid;
-	const char *audit_tty;
-	char audit_comm[sizeof(current->comm)];
-	struct vm_area_struct *vma;
 	char *secctx;
 	u32 secctx_len;
 
@@ -108,60 +105,13 @@ struct audit_buffer *netlbl_audit_start_
 	if (audit_buf == NULL)
 		return NULL;
 
-	audit_loginuid = audit_get_loginuid(audit_ctx);
-	if (current->signal &&
-	    current->signal->tty &&
-	    current->signal->tty->name)
-		audit_tty = current->signal->tty->name;
-	else
-		audit_tty = "(none)";
-	get_task_comm(audit_comm, current);
+	audit_log_format(audit_buf, "netlabel: auid=%u", audit_info->loginuid);
 
-	audit_log_format(audit_buf,
-			 "netlabel: auid=%u uid=%u tty=%s pid=%d",
-			 audit_loginuid,
-			 current->uid,
-			 audit_tty,
-			 current->pid);
-	audit_log_format(audit_buf, " comm=");
-	audit_log_untrustedstring(audit_buf, audit_comm);
-	if (current->mm) {
-		down_read(&current->mm->mmap_sem);
-		vma = current->mm->mmap;
-		while (vma) {
-			if ((vma->vm_flags & VM_EXECUTABLE) &&
-			    vma->vm_file) {
-				audit_log_d_path(audit_buf,
-						 " exe=",
-						 vma->vm_file->f_dentry,
-						 vma->vm_file->f_vfsmnt);
-				break;
-			}
-			vma = vma->vm_next;
-		}
-		up_read(&current->mm->mmap_sem);
-	}
-
-	if (secid != 0 &&
-	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0)
+	if (audit_info->secid != 0 &&
+	    security_secid_to_secctx(audit_info->secid,
+				     &secctx,
+				     &secctx_len) == 0)
 		audit_log_format(audit_buf, " subj=%s", secctx);
 
 	return audit_buf;
 }
-
-/**
- * netlbl_audit_nomsg - Send an audit message without additional text
- * @type: audit message type
- * @secid: LSM context ID
- *
- * Description:
- * Send an audit message with only the common NetLabel audit fields.
- *
- */
-void netlbl_audit_nomsg(int type, u32 secid)
-{
-	struct audit_buffer *audit_buf;
-
-	audit_buf = netlbl_audit_start_common(type, secid);
-	audit_log_end(audit_buf);
-}
Index: net-2.6/net/netlabel/netlabel_user.h
===================================================================
--- net-2.6.orig/net/netlabel/netlabel_user.h
+++ net-2.6/net/netlabel/netlabel_user.h
@@ -72,13 +72,25 @@ static inline void *netlbl_netlink_hdr_p
 			   NETLBL_PROTO_VERSION);
 }
 
+/**
+ * netlbl_netlink_auditinfo - Fetch the audit information from a NETLINK msg
+ * @skb: the packet
+ * @audit_info: NetLabel audit information
+ */
+static inline void netlbl_netlink_auditinfo(struct sk_buff *skb,
+					    struct netlbl_audit *audit_info)
+{
+	audit_info->secid = NETLINK_CB(skb).sid;
+	audit_info->loginuid = NETLINK_CB(skb).loginuid;
+}
+
 /* NetLabel NETLINK I/O functions */
 
 int netlbl_netlink_init(void);
 
 /* NetLabel Audit Functions */
 
-struct audit_buffer *netlbl_audit_start_common(int type, u32 secid);
-void netlbl_audit_nomsg(int type, u32 secid);
+struct audit_buffer *netlbl_audit_start_common(int type,
+					      struct netlbl_audit *audit_info);
 
 #endif

--
paul moore
linux security @ hp
