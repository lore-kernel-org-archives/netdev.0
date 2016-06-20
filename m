From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 02/19] netlabel: Add an address family to domain hash entries.
Date: Mon, 20 Jun 2016 14:36:42 +0100
Message-ID: <1466429819-12707-3-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

The reason is to allow different labelling protocols for
different address families with the same domain.

This requires the addition of an address family attribute
in the netlink communication protocol.  It is used in several
messages:

NLBL_MGMT_C_ADD and NLBL_MGMT_C_ADDDEF take it as an optional
attribute for the unlabelled protocol.  It may be one of AF_INET,
AF_INET6 or AF_UNSPEC (to specify both address families).  If it
is missing, it defaults to AF_UNSPEC.

NLBL_MGMT_C_LISTALL and NLBL_MGMT_C_LISTDEF return it as part of
the enumeration of each item.  Addtionally, it may be sent to
LISTDEF to specify which address family to return.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 net/netlabel/netlabel_domainhash.c | 182 ++++++++++++++++++++++++++++---------
 net/netlabel/netlabel_domainhash.h |   8 +-
 net/netlabel/netlabel_kapi.c       |   6 +-
 net/netlabel/netlabel_mgmt.c       |  29 +++++-
 net/netlabel/netlabel_mgmt.h       |  24 ++++-
 net/netlabel/netlabel_unlabeled.c  |   1 +
 6 files changed, 192 insertions(+), 58 deletions(-)

diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index d4d6640..3b3b304 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -56,7 +56,8 @@ static DEFINE_SPINLOCK(netlbl_domhsh_lock);
 #define netlbl_domhsh_rcu_deref(p) \
 	rcu_dereference_check(p, lockdep_is_held(&netlbl_domhsh_lock))
 static struct netlbl_domhsh_tbl __rcu *netlbl_domhsh;
-static struct netlbl_dom_map __rcu *netlbl_domhsh_def;
+static struct netlbl_dom_map __rcu *netlbl_domhsh_def_ipv4;
+static struct netlbl_dom_map __rcu *netlbl_domhsh_def_ipv6;
 
 /*
  * Domain Hash Table Helper Functions
@@ -126,18 +127,26 @@ static u32 netlbl_domhsh_hash(const char *key)
 	return val & (netlbl_domhsh_rcu_deref(netlbl_domhsh)->size - 1);
 }
 
+static bool netlbl_family_match(u16 f1, u16 f2)
+{
+	return (f1 == f2) || (f1 == AF_UNSPEC) || (f2 == AF_UNSPEC);
+}
+
 /**
  * netlbl_domhsh_search - Search for a domain entry
  * @domain: the domain
+ * @family: the address family
  *
  * Description:
  * Searches the domain hash table and returns a pointer to the hash table
- * entry if found, otherwise NULL is returned.  The caller is responsible for
+ * entry if found, otherwise NULL is returned.  @family may be %AF_UNSPEC
+ * which matches any address family entries.  The caller is responsible for
  * ensuring that the hash table is protected with either a RCU read lock or the
  * hash table lock.
  *
  */
-static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain)
+static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain,
+						   u16 family)
 {
 	u32 bkt;
 	struct list_head *bkt_list;
@@ -147,7 +156,9 @@ static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain)
 		bkt = netlbl_domhsh_hash(domain);
 		bkt_list = &netlbl_domhsh_rcu_deref(netlbl_domhsh)->tbl[bkt];
 		list_for_each_entry_rcu(iter, bkt_list, list)
-			if (iter->valid && strcmp(iter->domain, domain) == 0)
+			if (iter->valid &&
+			    netlbl_family_match(iter->family, family) &&
+			    strcmp(iter->domain, domain) == 0)
 				return iter;
 	}
 
@@ -157,28 +168,37 @@ static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain)
 /**
  * netlbl_domhsh_search_def - Search for a domain entry
  * @domain: the domain
- * @def: return default if no match is found
+ * @family: the address family
  *
  * Description:
  * Searches the domain hash table and returns a pointer to the hash table
  * entry if an exact match is found, if an exact match is not present in the
  * hash table then the default entry is returned if valid otherwise NULL is
- * returned.  The caller is responsible ensuring that the hash table is
+ * returned.  @family may be %AF_UNSPEC which matches any address family
+ * entries.  The caller is responsible ensuring that the hash table is
  * protected with either a RCU read lock or the hash table lock.
  *
  */
-static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain)
+static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain,
+						       u16 family)
 {
 	struct netlbl_dom_map *entry;
 
-	entry = netlbl_domhsh_search(domain);
-	if (entry == NULL) {
-		entry = netlbl_domhsh_rcu_deref(netlbl_domhsh_def);
-		if (entry != NULL && !entry->valid)
-			entry = NULL;
+	entry = netlbl_domhsh_search(domain, family);
+	if (entry != NULL)
+		return entry;
+	if (family == AF_INET || family == AF_UNSPEC) {
+		entry = netlbl_domhsh_rcu_deref(netlbl_domhsh_def_ipv4);
+		if (entry != NULL && entry->valid)
+			return entry;
+	}
+	if (family == AF_INET6 || family == AF_UNSPEC) {
+		entry = netlbl_domhsh_rcu_deref(netlbl_domhsh_def_ipv6);
+		if (entry != NULL && entry->valid)
+			return entry;
 	}
 
-	return entry;
+	return NULL;
 }
 
 /**
@@ -264,13 +284,19 @@ static int netlbl_domhsh_validate(const struct netlbl_dom_map *entry)
 	if (entry == NULL)
 		return -EINVAL;
 
+	if (entry->family != AF_INET && entry->family != AF_INET6 &&
+	    (entry->family != AF_UNSPEC ||
+	     entry->def.type != NETLBL_NLTYPE_UNLABELED))
+		return -EINVAL;
+
 	switch (entry->def.type) {
 	case NETLBL_NLTYPE_UNLABELED:
 		if (entry->def.cipso != NULL || entry->def.addrsel != NULL)
 			return -EINVAL;
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
-		if (entry->def.cipso == NULL)
+		if (entry->family != AF_INET ||
+		    entry->def.cipso == NULL)
 			return -EINVAL;
 		break;
 	case NETLBL_NLTYPE_ADDRSELECT:
@@ -358,15 +384,18 @@ int __init netlbl_domhsh_init(u32 size)
  *
  * Description:
  * Adds a new entry to the domain hash table and handles any updates to the
- * lower level protocol handler (i.e. CIPSO).  Returns zero on success,
- * negative on failure.
+ * lower level protocol handler (i.e. CIPSO).  @entry->family may be set to
+ * %AF_UNSPEC which will add an entry that matches all address families.  This
+ * is only useful for the unlabelled type and will only succeed if there is no
+ * existing entry for any address family with the same domain.  Returns zero
+ * on success, negative on failure.
  *
  */
 int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 		      struct netlbl_audit *audit_info)
 {
 	int ret_val = 0;
-	struct netlbl_dom_map *entry_old;
+	struct netlbl_dom_map *entry_old, *entry_b;
 	struct netlbl_af4list *iter4;
 	struct netlbl_af4list *tmp4;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -385,9 +414,10 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	rcu_read_lock();
 	spin_lock(&netlbl_domhsh_lock);
 	if (entry->domain != NULL)
-		entry_old = netlbl_domhsh_search(entry->domain);
+		entry_old = netlbl_domhsh_search(entry->domain, entry->family);
 	else
-		entry_old = netlbl_domhsh_search_def(entry->domain);
+		entry_old = netlbl_domhsh_search_def(entry->domain,
+						     entry->family);
 	if (entry_old == NULL) {
 		entry->valid = 1;
 
@@ -397,7 +427,41 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 				    &rcu_dereference(netlbl_domhsh)->tbl[bkt]);
 		} else {
 			INIT_LIST_HEAD(&entry->list);
-			rcu_assign_pointer(netlbl_domhsh_def, entry);
+			switch (entry->family) {
+			case AF_INET:
+				rcu_assign_pointer(netlbl_domhsh_def_ipv4,
+						   entry);
+				break;
+			case AF_INET6:
+				rcu_assign_pointer(netlbl_domhsh_def_ipv6,
+						   entry);
+				break;
+			case AF_UNSPEC:
+				if (entry->def.type !=
+				    NETLBL_NLTYPE_UNLABELED) {
+					ret_val = -EINVAL;
+					goto add_return;
+				}
+				entry_b = kzalloc(sizeof(*entry_b), GFP_ATOMIC);
+				if (entry_b == NULL) {
+					ret_val = -ENOMEM;
+					goto add_return;
+				}
+				entry_b->family = AF_INET6;
+				entry_b->def.type = NETLBL_NLTYPE_UNLABELED;
+				entry_b->valid = 1;
+				entry->family = AF_INET;
+				rcu_assign_pointer(netlbl_domhsh_def_ipv4,
+						   entry);
+				rcu_assign_pointer(netlbl_domhsh_def_ipv6,
+						   entry_b);
+				break;
+			default:
+				/* Already checked in
+				 * netlbl_domhsh_validate(). */
+				ret_val = -EINVAL;
+				goto add_return;
+			}
 		}
 
 		if (entry->def.type == NETLBL_NLTYPE_ADDRSELECT) {
@@ -513,10 +577,12 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 	spin_lock(&netlbl_domhsh_lock);
 	if (entry->valid) {
 		entry->valid = 0;
-		if (entry != rcu_dereference(netlbl_domhsh_def))
-			list_del_rcu(&entry->list);
+		if (entry == rcu_dereference(netlbl_domhsh_def_ipv4))
+			RCU_INIT_POINTER(netlbl_domhsh_def_ipv4, NULL);
+		else if (entry == rcu_dereference(netlbl_domhsh_def_ipv6))
+			RCU_INIT_POINTER(netlbl_domhsh_def_ipv6, NULL);
 		else
-			RCU_INIT_POINTER(netlbl_domhsh_def, NULL);
+			list_del_rcu(&entry->list);
 	} else
 		ret_val = -ENOENT;
 	spin_unlock(&netlbl_domhsh_lock);
@@ -583,9 +649,9 @@ int netlbl_domhsh_remove_af4(const char *domain,
 	rcu_read_lock();
 
 	if (domain)
-		entry_map = netlbl_domhsh_search(domain);
+		entry_map = netlbl_domhsh_search(domain, AF_INET);
 	else
-		entry_map = netlbl_domhsh_search_def(domain);
+		entry_map = netlbl_domhsh_search_def(domain, AF_INET);
 	if (entry_map == NULL ||
 	    entry_map->def.type != NETLBL_NLTYPE_ADDRSELECT)
 		goto remove_af4_failure;
@@ -625,25 +691,45 @@ remove_af4_failure:
 /**
  * netlbl_domhsh_remove - Removes an entry from the domain hash table
  * @domain: the domain to remove
+ * @family: address family
  * @audit_info: NetLabel audit information
  *
  * Description:
  * Removes an entry from the domain hash table and handles any updates to the
- * lower level protocol handler (i.e. CIPSO).  Returns zero on success,
- * negative on failure.
+ * lower level protocol handler (i.e. CIPSO).  @family may be %AF_UNSPEC which
+ * removes all address family entries.  Returns zero on success, negative on
+ * failure.
  *
  */
-int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
+int netlbl_domhsh_remove(const char *domain, u16 family,
+			 struct netlbl_audit *audit_info)
 {
-	int ret_val;
+	int ret_val = -EINVAL;
 	struct netlbl_dom_map *entry;
 
 	rcu_read_lock();
-	if (domain)
-		entry = netlbl_domhsh_search(domain);
-	else
-		entry = netlbl_domhsh_search_def(domain);
-	ret_val = netlbl_domhsh_remove_entry(entry, audit_info);
+
+	if (family == AF_INET || family == AF_UNSPEC) {
+		if (domain)
+			entry = netlbl_domhsh_search(domain, AF_INET);
+		else
+			entry = netlbl_domhsh_search_def(domain, AF_INET);
+		ret_val = netlbl_domhsh_remove_entry(entry, audit_info);
+		if (ret_val && ret_val != -ENOENT)
+			goto done;
+	}
+	if (family == AF_INET6 || family == AF_UNSPEC) {
+		int ret_val2;
+
+		if (domain)
+			entry = netlbl_domhsh_search(domain, AF_INET6);
+		else
+			entry = netlbl_domhsh_search_def(domain, AF_INET6);
+		ret_val2 = netlbl_domhsh_remove_entry(entry, audit_info);
+		if (ret_val2 != -ENOENT)
+			ret_val = ret_val2;
+	}
+done:
 	rcu_read_unlock();
 
 	return ret_val;
@@ -651,32 +737,38 @@ int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
 
 /**
  * netlbl_domhsh_remove_default - Removes the default entry from the table
+ * @family: address family
  * @audit_info: NetLabel audit information
  *
  * Description:
- * Removes/resets the default entry for the domain hash table and handles any
- * updates to the lower level protocol handler (i.e. CIPSO).  Returns zero on
- * success, non-zero on failure.
+ * Removes/resets the default entry corresponding to @family from the domain
+ * hash table and handles any updates to the lower level protocol handler
+ * (i.e. CIPSO).  @family may be %AF_UNSPEC which removes all address family
+ * entries.  Returns zero on success, negative on failure.
  *
  */
-int netlbl_domhsh_remove_default(struct netlbl_audit *audit_info)
+int netlbl_domhsh_remove_default(u16 family, struct netlbl_audit *audit_info)
 {
-	return netlbl_domhsh_remove(NULL, audit_info);
+	return netlbl_domhsh_remove(NULL, family, audit_info);
 }
 
 /**
  * netlbl_domhsh_getentry - Get an entry from the domain hash table
  * @domain: the domain name to search for
+ * @family: address family
  *
  * Description:
  * Look through the domain hash table searching for an entry to match @domain,
- * return a pointer to a copy of the entry or NULL.  The caller is responsible
- * for ensuring that rcu_read_[un]lock() is called.
+ * with address family @family, return a pointer to a copy of the entry or
+ * NULL.  The caller is responsible for ensuring that rcu_read_[un]lock() is
+ * called.
  *
  */
-struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain)
+struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain, u16 family)
 {
-	return netlbl_domhsh_search_def(domain);
+	if (family == AF_UNSPEC)
+		return NULL;
+	return netlbl_domhsh_search_def(domain, family);
 }
 
 /**
@@ -696,7 +788,7 @@ struct netlbl_dommap_def *netlbl_domhsh_getentry_af4(const char *domain,
 	struct netlbl_dom_map *dom_iter;
 	struct netlbl_af4list *addr_iter;
 
-	dom_iter = netlbl_domhsh_search_def(domain);
+	dom_iter = netlbl_domhsh_search_def(domain, AF_INET);
 	if (dom_iter == NULL)
 		return NULL;
 
@@ -726,7 +818,7 @@ struct netlbl_dommap_def *netlbl_domhsh_getentry_af6(const char *domain,
 	struct netlbl_dom_map *dom_iter;
 	struct netlbl_af6list *addr_iter;
 
-	dom_iter = netlbl_domhsh_search_def(domain);
+	dom_iter = netlbl_domhsh_search_def(domain, AF_INET6);
 	if (dom_iter == NULL)
 		return NULL;
 
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index 680caf4..56e45ae 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -70,6 +70,7 @@ struct netlbl_domaddr6_map {
 
 struct netlbl_dom_map {
 	char *domain;
+	u16 family;
 	struct netlbl_dommap_def def;
 
 	u32 valid;
@@ -91,9 +92,10 @@ int netlbl_domhsh_remove_af4(const char *domain,
 			     const struct in_addr *addr,
 			     const struct in_addr *mask,
 			     struct netlbl_audit *audit_info);
-int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info);
-int netlbl_domhsh_remove_default(struct netlbl_audit *audit_info);
-struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
+int netlbl_domhsh_remove(const char *domain, u16 family,
+			 struct netlbl_audit *audit_info);
+int netlbl_domhsh_remove_default(u16 family, struct netlbl_audit *audit_info);
+struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain, u16 family);
 struct netlbl_dommap_def *netlbl_domhsh_getentry_af4(const char *domain,
 						     __be32 addr);
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 28cddc8..3b62707 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -72,7 +72,7 @@ int netlbl_cfg_map_del(const char *domain,
 		       struct netlbl_audit *audit_info)
 {
 	if (addr == NULL && mask == NULL) {
-		return netlbl_domhsh_remove(domain, audit_info);
+		return netlbl_domhsh_remove(domain, family, audit_info);
 	} else if (addr != NULL && mask != NULL) {
 		switch (family) {
 		case AF_INET:
@@ -119,6 +119,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 		if (entry->domain == NULL)
 			goto cfg_unlbl_map_add_failure;
 	}
+	entry->family = family;
 
 	if (addr == NULL && mask == NULL)
 		entry->def.type = NETLBL_NLTYPE_UNLABELED;
@@ -345,6 +346,7 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL)
 		goto out_entry;
+	entry->family = AF_INET;
 	if (domain != NULL) {
 		entry->domain = kstrdup(domain, GFP_ATOMIC);
 		if (entry->domain == NULL)
@@ -774,7 +776,7 @@ int netlbl_sock_setattr(struct sock *sk,
 	struct netlbl_dom_map *dom_entry;
 
 	rcu_read_lock();
-	dom_entry = netlbl_domhsh_getentry(secattr->domain);
+	dom_entry = netlbl_domhsh_getentry(secattr->domain, family);
 	if (dom_entry == NULL) {
 		ret_val = -ENOENT;
 		goto socket_setattr_return;
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 13f777f..b2aeb5d 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -72,6 +72,7 @@ static const struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
 	[NLBL_MGMT_A_PROTOCOL] = { .type = NLA_U32 },
 	[NLBL_MGMT_A_VERSION] = { .type = NLA_U32 },
 	[NLBL_MGMT_A_CV4DOI] = { .type = NLA_U32 },
+	[NLBL_MGMT_A_FAMILY] = { .type = NLA_U16 },
 };
 
 /*
@@ -119,6 +120,11 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 
 	switch (entry->def.type) {
 	case NETLBL_NLTYPE_UNLABELED:
+		if (info->attrs[NLBL_MGMT_A_FAMILY])
+			entry->family =
+				nla_get_u16(info->attrs[NLBL_MGMT_A_FAMILY]);
+		else
+			entry->family = AF_UNSPEC;
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
 		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
@@ -128,12 +134,17 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		cipsov4 = cipso_v4_doi_getdef(tmp_val);
 		if (cipsov4 == NULL)
 			goto add_free_domain;
+		entry->family = AF_INET;
 		entry->def.cipso = cipsov4;
 		break;
 	default:
 		goto add_free_domain;
 	}
 
+	if ((entry->family == AF_INET && info->attrs[NLBL_MGMT_A_IPV6ADDR]) ||
+	    (entry->family == AF_INET6 && info->attrs[NLBL_MGMT_A_IPV4ADDR]))
+		goto add_doi_put_def;
+
 	if (info->attrs[NLBL_MGMT_A_IPV4ADDR]) {
 		struct in_addr *addr;
 		struct in_addr *mask;
@@ -178,6 +189,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 			goto add_free_addrmap;
 		}
 
+		entry->family = AF_INET;
 		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
 		entry->def.addrsel = addrmap;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -227,6 +239,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 			goto add_free_addrmap;
 		}
 
+		entry->family = AF_INET6;
 		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
 		entry->def.addrsel = addrmap;
 #endif /* IPv6 */
@@ -278,6 +291,10 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 			return ret_val;
 	}
 
+	ret_val = nla_put_u16(skb, NLBL_MGMT_A_FAMILY, entry->family);
+	if (ret_val != 0)
+		return ret_val;
+
 	switch (entry->def.type) {
 	case NETLBL_NLTYPE_ADDRSELECT:
 		nla_a = nla_nest_start(skb, NLBL_MGMT_A_SELECTORLIST);
@@ -418,7 +435,7 @@ static int netlbl_mgmt_remove(struct sk_buff *skb, struct genl_info *info)
 	netlbl_netlink_auditinfo(skb, &audit_info);
 
 	domain = nla_data(info->attrs[NLBL_MGMT_A_DOMAIN]);
-	return netlbl_domhsh_remove(domain, &audit_info);
+	return netlbl_domhsh_remove(domain, AF_UNSPEC, &audit_info);
 }
 
 /**
@@ -536,7 +553,7 @@ static int netlbl_mgmt_removedef(struct sk_buff *skb, struct genl_info *info)
 
 	netlbl_netlink_auditinfo(skb, &audit_info);
 
-	return netlbl_domhsh_remove_default(&audit_info);
+	return netlbl_domhsh_remove_default(AF_UNSPEC, &audit_info);
 }
 
 /**
@@ -556,6 +573,12 @@ static int netlbl_mgmt_listdef(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *ans_skb = NULL;
 	void *data;
 	struct netlbl_dom_map *entry;
+	u16 family;
+
+	if (info->attrs[NLBL_MGMT_A_FAMILY])
+		family = nla_get_u16(info->attrs[NLBL_MGMT_A_FAMILY]);
+	else
+		family = AF_INET;
 
 	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
@@ -566,7 +589,7 @@ static int netlbl_mgmt_listdef(struct sk_buff *skb, struct genl_info *info)
 		goto listdef_failure;
 
 	rcu_read_lock();
-	entry = netlbl_domhsh_getentry(NULL);
+	entry = netlbl_domhsh_getentry(NULL, family);
 	if (entry == NULL) {
 		ret_val = -ENOENT;
 		goto listdef_failure_lock;
diff --git a/net/netlabel/netlabel_mgmt.h b/net/netlabel/netlabel_mgmt.h
index 8b6e1ab..f368dc0 100644
--- a/net/netlabel/netlabel_mgmt.h
+++ b/net/netlabel/netlabel_mgmt.h
@@ -58,7 +58,10 @@
  *
  *     NLBL_MGMT_A_CV4DOI
  *
- *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
+ *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required,
+ *   however the following attribute may optionally be sent:
+ *
+ *     NLBL_MGMT_A_FAMILY
  *
  * o REMOVE:
  *   Sent by an application to remove a domain mapping from the NetLabel
@@ -77,6 +80,7 @@
  *   Required attributes:
  *
  *     NLBL_MGMT_A_DOMAIN
+ *     NLBL_MGMT_A_FAMILY
  *
  *   If the IP address selectors are not used the following attribute is
  *   required:
@@ -108,7 +112,10 @@
  *
  *     NLBL_MGMT_A_CV4DOI
  *
- *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
+ *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required,
+ *   however the following attribute may optionally be sent:
+ *
+ *     NLBL_MGMT_A_FAMILY
  *
  * o REMOVEDEF:
  *   Sent by an application to remove the default domain mapping from the
@@ -117,13 +124,17 @@
  * o LISTDEF:
  *   This message can be sent either from an application or by the kernel in
  *   response to an application generated LISTDEF message.  When sent by an
- *   application there is no payload.  On success the kernel should send a
- *   response using the following format.
+ *   application there may be an optional payload.
  *
- *   If the IP address selectors are not used the following attribute is
+ *     NLBL_MGMT_A_FAMILY
+ *
+ *   On success the kernel should send a response using the following format:
+ *
+ *   If the IP address selectors are not used the following attributes are
  *   required:
  *
  *     NLBL_MGMT_A_PROTOCOL
+ *     NLBL_MGMT_A_FAMILY
  *
  *   If the IP address selectors are used then the following attritbute is
  *   required:
@@ -209,6 +220,9 @@ enum {
 	/* (NLA_NESTED)
 	 * the selector list, there must be at least one
 	 * NLBL_MGMT_A_ADDRSELECTOR attribute */
+	NLBL_MGMT_A_FAMILY,
+	/* (NLA_U16)
+	 * The address family */
 	__NLBL_MGMT_A_MAX,
 };
 #define NLBL_MGMT_A_MAX (__NLBL_MGMT_A_MAX - 1)
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index ca590d2..4528cff 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1537,6 +1537,7 @@ int __init netlbl_unlabel_defconf(void)
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (entry == NULL)
 		return -ENOMEM;
+	entry->family = AF_UNSPEC;
 	entry->def.type = NETLBL_NLTYPE_UNLABELED;
 	ret_val = netlbl_domhsh_add_default(entry, &audit_info);
 	if (ret_val != 0)
-- 
2.7.4

