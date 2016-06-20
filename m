From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [PATCH v4 19/19] netlabel: Implement CALIPSO config functions for
 SMACK.
Date: Mon, 20 Jun 2016 14:36:59 +0100
Message-ID: <1466429819-12707-20-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

SMACK uses similar functions to control CIPSO, these are
the equivalent functions for CALIPSO and follow exactly
the same semantics.

int netlbl_cfg_calipso_add(struct calipso_doi *doi_def,
                           struct netlbl_audit *audit_info)
    Adds a CALIPSO doi.

void netlbl_cfg_calipso_del(u32 doi, struct netlbl_audit *audit_info)
    Removes a CALIPSO doi.

int netlbl_cfg_calipso_map_add(u32 doi, const char *domain,
                               const struct in6_addr *addr,
                               const struct in6_addr *mask,
                               struct netlbl_audit *audit_info)
    Creates a mapping between a domain and a CALIPSO doi.  If
    addr and mask are non-NULL this creates an address-selector
    type mapping.

This also extends netlbl_cfg_map_del() to remove IPv6 address-selector
mappings.

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 include/net/netlabel.h             |  26 +++++++
 net/netlabel/netlabel_domainhash.c |  66 ++++++++++++++++++
 net/netlabel/netlabel_domainhash.h |   8 +++
 net/netlabel/netlabel_kapi.c       | 138 +++++++++++++++++++++++++++++++++++++
 4 files changed, 238 insertions(+)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index a306bc7..efe9806 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -445,6 +445,14 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
 			       const struct in_addr *addr,
 			       const struct in_addr *mask,
 			       struct netlbl_audit *audit_info);
+int netlbl_cfg_calipso_add(struct calipso_doi *doi_def,
+			   struct netlbl_audit *audit_info);
+void netlbl_cfg_calipso_del(u32 doi, struct netlbl_audit *audit_info);
+int netlbl_cfg_calipso_map_add(u32 doi,
+			       const char *domain,
+			       const struct in6_addr *addr,
+			       const struct in6_addr *mask,
+			       struct netlbl_audit *audit_info);
 /*
  * LSM security attribute operations
  */
@@ -561,6 +569,24 @@ static inline int netlbl_cfg_cipsov4_map_add(u32 doi,
 {
 	return -ENOSYS;
 }
+static inline int netlbl_cfg_calipso_add(struct calipso_doi *doi_def,
+					 struct netlbl_audit *audit_info)
+{
+	return -ENOSYS;
+}
+static inline void netlbl_cfg_calipso_del(u32 doi,
+					  struct netlbl_audit *audit_info)
+{
+	return;
+}
+static inline int netlbl_cfg_calipso_map_add(u32 doi,
+					     const char *domain,
+					     const struct in6_addr *addr,
+					     const struct in6_addr *mask,
+					     struct netlbl_audit *audit_info)
+{
+	return -ENOSYS;
+}
 static inline int netlbl_catmap_walk(struct netlbl_lsm_catmap *catmap,
 				     u32 offset)
 {
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index f1dee0d..41d0e95 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -725,6 +725,72 @@ remove_af4_failure:
 	return -ENOENT;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+/**
+ * netlbl_domhsh_remove_af6 - Removes an address selector entry
+ * @domain: the domain
+ * @addr: IPv6 address
+ * @mask: IPv6 address mask
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * Removes an individual address selector from a domain mapping and potentially
+ * the entire mapping if it is empty.  Returns zero on success, negative values
+ * on failure.
+ *
+ */
+int netlbl_domhsh_remove_af6(const char *domain,
+			     const struct in6_addr *addr,
+			     const struct in6_addr *mask,
+			     struct netlbl_audit *audit_info)
+{
+	struct netlbl_dom_map *entry_map;
+	struct netlbl_af6list *entry_addr;
+	struct netlbl_af4list *iter4;
+	struct netlbl_af6list *iter6;
+	struct netlbl_domaddr6_map *entry;
+
+	rcu_read_lock();
+
+	if (domain)
+		entry_map = netlbl_domhsh_search(domain, AF_INET6);
+	else
+		entry_map = netlbl_domhsh_search_def(domain, AF_INET6);
+	if (entry_map == NULL ||
+	    entry_map->def.type != NETLBL_NLTYPE_ADDRSELECT)
+		goto remove_af6_failure;
+
+	spin_lock(&netlbl_domhsh_lock);
+	entry_addr = netlbl_af6list_remove(addr, mask,
+					   &entry_map->def.addrsel->list6);
+	spin_unlock(&netlbl_domhsh_lock);
+
+	if (entry_addr == NULL)
+		goto remove_af6_failure;
+	netlbl_af4list_foreach_rcu(iter4, &entry_map->def.addrsel->list4)
+		goto remove_af6_single_addr;
+	netlbl_af6list_foreach_rcu(iter6, &entry_map->def.addrsel->list6)
+		goto remove_af6_single_addr;
+	/* the domain mapping is empty so remove it from the mapping table */
+	netlbl_domhsh_remove_entry(entry_map, audit_info);
+
+remove_af6_single_addr:
+	rcu_read_unlock();
+	/* yick, we can't use call_rcu here because we don't have a rcu head
+	 * pointer but hopefully this should be a rare case so the pause
+	 * shouldn't be a problem */
+	synchronize_rcu();
+	entry = netlbl_domhsh_addr6_entry(entry_addr);
+	calipso_doi_putdef(entry->def.calipso);
+	kfree(entry);
+	return 0;
+
+remove_af6_failure:
+	rcu_read_unlock();
+	return -ENOENT;
+}
+#endif /* IPv6 */
+
 /**
  * netlbl_domhsh_remove - Removes an entry from the domain hash table
  * @domain: the domain to remove
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index b7ddb6e..1f92477 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -93,6 +93,10 @@ int netlbl_domhsh_remove_af4(const char *domain,
 			     const struct in_addr *addr,
 			     const struct in_addr *mask,
 			     struct netlbl_audit *audit_info);
+int netlbl_domhsh_remove_af6(const char *domain,
+			     const struct in6_addr *addr,
+			     const struct in6_addr *mask,
+			     struct netlbl_audit *audit_info);
 int netlbl_domhsh_remove(const char *domain, u16 family,
 			 struct netlbl_audit *audit_info);
 int netlbl_domhsh_remove_default(u16 family, struct netlbl_audit *audit_info);
@@ -102,6 +106,10 @@ struct netlbl_dommap_def *netlbl_domhsh_getentry_af4(const char *domain,
 #if IS_ENABLED(CONFIG_IPV6)
 struct netlbl_dommap_def *netlbl_domhsh_getentry_af6(const char *domain,
 						   const struct in6_addr *addr);
+int netlbl_domhsh_remove_af6(const char *domain,
+			     const struct in6_addr *addr,
+			     const struct in6_addr *mask,
+			     struct netlbl_audit *audit_info);
 #endif /* IPv6 */
 
 int netlbl_domhsh_walk(u32 *skip_bkt,
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index d534731..21c2153 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -80,6 +80,11 @@ int netlbl_cfg_map_del(const char *domain,
 		case AF_INET:
 			return netlbl_domhsh_remove_af4(domain, addr, mask,
 							audit_info);
+#if IS_ENABLED(CONFIG_IPV6)
+		case AF_INET6:
+			return netlbl_domhsh_remove_af6(domain, addr, mask,
+							audit_info);
+#endif /* IPv6 */
 		default:
 			return -EPFNOSUPPORT;
 		}
@@ -403,6 +408,139 @@ out_entry:
 	return ret_val;
 }
 
+/**
+ * netlbl_cfg_calipso_add - Add a new CALIPSO DOI definition
+ * @doi_def: CALIPSO DOI definition
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * Add a new CALIPSO DOI definition as defined by @doi_def.  Returns zero on
+ * success and negative values on failure.
+ *
+ */
+int netlbl_cfg_calipso_add(struct calipso_doi *doi_def,
+			   struct netlbl_audit *audit_info)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	return calipso_doi_add(doi_def, audit_info);
+#else /* IPv6 */
+	return -ENOSYS;
+#endif /* IPv6 */
+}
+
+/**
+ * netlbl_cfg_calipso_del - Remove an existing CALIPSO DOI definition
+ * @doi: CALIPSO DOI
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * Remove an existing CALIPSO DOI definition matching @doi.  Returns zero on
+ * success and negative values on failure.
+ *
+ */
+void netlbl_cfg_calipso_del(u32 doi, struct netlbl_audit *audit_info)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	calipso_doi_remove(doi, audit_info);
+#endif /* IPv6 */
+}
+
+/**
+ * netlbl_cfg_calipso_map_add - Add a new CALIPSO DOI mapping
+ * @doi: the CALIPSO DOI
+ * @domain: the domain mapping to add
+ * @addr: IP address
+ * @mask: IP address mask
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * Add a new NetLabel/LSM domain mapping for the given CALIPSO DOI to the
+ * NetLabel subsystem.  A @domain value of NULL adds a new default domain
+ * mapping.  Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_cfg_calipso_map_add(u32 doi,
+			       const char *domain,
+			       const struct in6_addr *addr,
+			       const struct in6_addr *mask,
+			       struct netlbl_audit *audit_info)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	int ret_val = -ENOMEM;
+	struct calipso_doi *doi_def;
+	struct netlbl_dom_map *entry;
+	struct netlbl_domaddr_map *addrmap = NULL;
+	struct netlbl_domaddr6_map *addrinfo = NULL;
+
+	doi_def = calipso_doi_getdef(doi);
+	if (doi_def == NULL)
+		return -ENOENT;
+
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
+	if (entry == NULL)
+		goto out_entry;
+	entry->family = AF_INET6;
+	if (domain != NULL) {
+		entry->domain = kstrdup(domain, GFP_ATOMIC);
+		if (entry->domain == NULL)
+			goto out_domain;
+	}
+
+	if (addr == NULL && mask == NULL) {
+		entry->def.calipso = doi_def;
+		entry->def.type = NETLBL_NLTYPE_CALIPSO;
+	} else if (addr != NULL && mask != NULL) {
+		addrmap = kzalloc(sizeof(*addrmap), GFP_ATOMIC);
+		if (addrmap == NULL)
+			goto out_addrmap;
+		INIT_LIST_HEAD(&addrmap->list4);
+		INIT_LIST_HEAD(&addrmap->list6);
+
+		addrinfo = kzalloc(sizeof(*addrinfo), GFP_ATOMIC);
+		if (addrinfo == NULL)
+			goto out_addrinfo;
+		addrinfo->def.calipso = doi_def;
+		addrinfo->def.type = NETLBL_NLTYPE_CALIPSO;
+		addrinfo->list.addr = *addr;
+		addrinfo->list.addr.s6_addr32[0] &= mask->s6_addr32[0];
+		addrinfo->list.addr.s6_addr32[1] &= mask->s6_addr32[1];
+		addrinfo->list.addr.s6_addr32[2] &= mask->s6_addr32[2];
+		addrinfo->list.addr.s6_addr32[3] &= mask->s6_addr32[3];
+		addrinfo->list.mask = *mask;
+		addrinfo->list.valid = 1;
+		ret_val = netlbl_af6list_add(&addrinfo->list, &addrmap->list6);
+		if (ret_val != 0)
+			goto cfg_calipso_map_add_failure;
+
+		entry->def.addrsel = addrmap;
+		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
+	} else {
+		ret_val = -EINVAL;
+		goto out_addrmap;
+	}
+
+	ret_val = netlbl_domhsh_add(entry, audit_info);
+	if (ret_val != 0)
+		goto cfg_calipso_map_add_failure;
+
+	return 0;
+
+cfg_calipso_map_add_failure:
+	kfree(addrinfo);
+out_addrinfo:
+	kfree(addrmap);
+out_addrmap:
+	kfree(entry->domain);
+out_domain:
+	kfree(entry);
+out_entry:
+	calipso_doi_putdef(doi_def);
+	return ret_val;
+#else /* IPv6 */
+	return -ENOSYS;
+#endif /* IPv6 */
+}
+
 /*
  * Security Attribute Functions
  */
-- 
2.7.4

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
