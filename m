From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v3 07/13] netlabel: Add network address selectors to the
	NetLabel/LSM domain mapping
Date: Thu, 21 Aug 2008 17:26:33 -0400
Message-ID: <20080821212633.7951.35137.stgit@flek.lan>
References: <20080821210239.7951.59652.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:33700 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbYHUV0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:26:41 -0400
In-Reply-To: <20080821210239.7951.59652.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the NetLabel traffic labeling capabilities to individual
packets based not only on the LSM domain but the by the destination address
as well.  The changes here only affect the core NetLabel infrastructre,
changes to the NetLabel KAPI and individial protocol engines are also
required but are split out into a different patch to ease review.

Signed-off-by: XXX
---

 include/net/netlabel.h             |    7 -
 net/netlabel/netlabel_addrlist.c   |  130 ++++++++++++
 net/netlabel/netlabel_addrlist.h   |   15 +
 net/netlabel/netlabel_domainhash.c |  286 +++++++++++++++++++++++----
 net/netlabel/netlabel_domainhash.h |   38 +++-
 net/netlabel/netlabel_kapi.c       |    7 +
 net/netlabel/netlabel_mgmt.c       |  387 +++++++++++++++++++++++++++---------
 net/netlabel/netlabel_mgmt.h       |   59 +++++
 net/netlabel/netlabel_unlabeled.c  |   96 +--------
 9 files changed, 801 insertions(+), 224 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index e16db09..0729f8c 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -9,7 +9,7 @@
  */
 
 /*
- * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006, 2008
  *
  * This program is free software;  you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -72,8 +72,9 @@ struct cipso_v4_doi;
 /* NetLabel NETLINK protocol version
  *  1: initial version
  *  2: added static labels for unlabeled connections
+ *  3: network selectors added to the NetLabel/LSM domain mapping
  */
-#define NETLBL_PROTO_VERSION            2
+#define NETLBL_PROTO_VERSION            3
 
 /* NetLabel NETLINK types/families */
 #define NETLBL_NLTYPE_NONE              0
@@ -87,6 +88,8 @@ struct cipso_v4_doi;
 #define NETLBL_NLTYPE_CIPSOV6_NAME      "NLBL_CIPSOv6"
 #define NETLBL_NLTYPE_UNLABELED         5
 #define NETLBL_NLTYPE_UNLABELED_NAME    "NLBL_UNLBL"
+#define NETLBL_NLTYPE_ADDRSELECT        6
+#define NETLBL_NLTYPE_ADDRSELECT_NAME   "NLBL_ADRSEL"
 
 /*
  * NetLabel - Kernel API for accessing the network packet label mappings.
diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index dd928aa..d583da7 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -39,6 +39,7 @@
 #include <linux/ipv6.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <linux/audit.h>
 
 #include "netlabel_addrlist.h"
 
@@ -69,6 +70,32 @@ struct netlbl_af4list *netlbl_af4list_search(__be32 addr,
 	return NULL;
 }
 
+/**
+ * netlbl_af4list_search_exact - Search for an exact IPv4 address entry
+ * @addr: IPv4 address
+ * @mask: IPv4 address mask
+ * @head: the list head
+ *
+ * Description:
+ * Searches the IPv4 address list given by @head.  If an exact match if found
+ * it is returned, otherwise NULL is returned.  The caller is responsible for
+ * calling the rcu_read_[un]lock() functions.
+ *
+ */
+struct netlbl_af4list *netlbl_af4list_search_exact(__be32 addr,
+						   __be32 mask,
+						   struct list_head *head)
+{
+	struct netlbl_af4list *iter;
+
+	list_for_each_entry_rcu(iter, head, list)
+		if (iter->valid && iter->addr == addr && iter->mask == mask)
+			return iter;
+
+	return NULL;
+}
+
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 /**
  * netlbl_af6list_search - Search for a matching IPv6 address entry
@@ -93,6 +120,33 @@ struct netlbl_af6list *netlbl_af6list_search(const struct in6_addr *addr,
 
 	return NULL;
 }
+
+/**
+ * netlbl_af6list_search_exact - Search for an exact IPv6 address entry
+ * @addr: IPv6 address
+ * @mask: IPv6 address mask
+ * @head: the list head
+ *
+ * Description:
+ * Searches the IPv6 address list given by @head.  If an exact match if found
+ * it is returned, otherwise NULL is returned.  The caller is responsible for
+ * calling the rcu_read_[un]lock() functions.
+ *
+ */
+struct netlbl_af6list *netlbl_af6list_search_exact(const struct in6_addr *addr,
+						   const struct in6_addr *mask,
+						   struct list_head *head)
+{
+	struct netlbl_af6list *iter;
+
+	list_for_each_entry_rcu(iter, head, list)
+		if (iter->valid &&
+		    ipv6_addr_equal(&iter->addr, addr) &&
+		    ipv6_addr_equal(&iter->mask, mask))
+			return iter;
+
+	return NULL;
+}
 #endif /* IPv6 */
 
 /**
@@ -256,3 +310,79 @@ struct netlbl_af6list *netlbl_af6list_remove(const struct in6_addr *addr,
 	return NULL;
 }
 #endif /* IPv6 */
+
+/*
+ * Audit Helper Functions
+ */
+
+/**
+ * netlbl_af4list_audit_addr - Audit an IPv4 address
+ * @audit_buf: audit buffer
+ * @src: true if source address, false if destination
+ * @dev: network interface
+ * @addr: IP address
+ * @mask: IP address mask
+ *
+ * Description:
+ * Write the IPv4 address and address mask, if necessary, to @audit_buf.
+ *
+ */
+void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
+					int src, const char *dev,
+					__be32 addr, __be32 mask)
+{
+	u32 mask_val = ntohl(mask);
+	char *dir = (src ? "src" : "dst" );
+
+	if (dev != NULL)
+		audit_log_format(audit_buf, " netif=%s", dev);
+	audit_log_format(audit_buf, " %s=" NIPQUAD_FMT, dir, NIPQUAD(addr));
+	if (mask_val != 0xffffffff) {
+		u32 mask_len = 0;
+		while (mask_val > 0) {
+			mask_val <<= 1;
+			mask_len++;
+		}
+		audit_log_format(audit_buf, " %s_prefixlen=%d", dir, mask_len);
+	}
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+/**
+ * netlbl_af6list_audit_addr - Audit an IPv6 address
+ * @audit_buf: audit buffer
+ * @src: true if source address, false if destination
+ * @dev: network interface
+ * @addr: IP address
+ * @mask: IP address mask
+ *
+ * Description:
+ * Write the IPv6 address and address mask, if necessary, to @audit_buf.
+ *
+ */
+void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
+				 int src,
+				 const char *dev,
+				 const struct in6_addr *addr,
+				 const struct in6_addr *mask)
+{
+	char *dir = (src ? "src" : "dst" );
+
+	if (dev != NULL)
+		audit_log_format(audit_buf, " netif=%s", dev);
+	audit_log_format(audit_buf, " %s=" NIP6_FMT, dir, NIP6(*addr));
+	if (ntohl(mask->s6_addr32[3]) != 0xffffffff) {
+		u32 mask_len = 0;
+		u32 mask_val;
+		int iter = -1;
+		while (ntohl(mask->s6_addr32[++iter]) == 0xffffffff)
+			mask_len += 32;
+		mask_val = ntohl(mask->s6_addr32[iter]);
+		while (mask_val > 0) {
+			mask_val <<= 1;
+			mask_len++;
+		}
+		audit_log_format(audit_buf, " %s_prefixlen=%d", dir, mask_len);
+	}
+}
+#endif /* IPv6 */
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index d521762..7840f95 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -36,6 +36,7 @@
 #include <linux/rcupdate.h>
 #include <linux/list.h>
 #include <linux/in6.h>
+#include <linux/audit.h>
 
 /* XXX - needs documentation */
 struct netlbl_af4list {
@@ -104,6 +105,12 @@ struct netlbl_af4list *netlbl_af4list_remove(__be32 addr, __be32 mask,
 void netlbl_af4list_remove_entry(struct netlbl_af4list *entry);
 struct netlbl_af4list *netlbl_af4list_search(__be32 addr,
 					     struct list_head *head);
+struct netlbl_af4list *netlbl_af4list_search_exact(__be32 addr,
+						   __be32 mask,
+						   struct list_head *head);
+void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
+			       int src, const char *dev,
+			       __be32 addr, __be32 mask);
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 
@@ -157,6 +164,14 @@ struct netlbl_af6list *netlbl_af6list_remove(const struct in6_addr *addr,
 void netlbl_af6list_remove_entry(struct netlbl_af6list *entry);
 struct netlbl_af6list *netlbl_af6list_search(const struct in6_addr *addr,
 					     struct list_head *head);
+struct netlbl_af6list *netlbl_af6list_search_exact(const struct in6_addr *addr,
+						   const struct in6_addr *mask,
+						   struct list_head *head);
+void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
+			       int src,
+			       const char *dev,
+			       const struct in6_addr *addr,
+			       const struct in6_addr *mask);
 #endif /* IPV6 */
 
 #endif
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 8fa0d5f..e8ef2e4 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -11,7 +11,7 @@
  */
 
 /*
- * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006, 2008
  *
  * This program is free software;  you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -40,6 +40,7 @@
 #include <asm/bug.h>
 
 #include "netlabel_mgmt.h"
+#include "netlabel_addrlist.h"
 #include "netlabel_domainhash.h"
 #include "netlabel_user.h"
 
@@ -72,8 +73,26 @@ static struct netlbl_dom_map *netlbl_domhsh_def = NULL;
 static void netlbl_domhsh_free_entry(struct rcu_head *entry)
 {
 	struct netlbl_dom_map *ptr;
+	struct netlbl_af4list *iter4;
+	struct netlbl_af4list *tmp4;
+	struct netlbl_af6list *iter6;
+	struct netlbl_af6list *tmp6;
 
 	ptr = container_of(entry, struct netlbl_dom_map, rcu);
+	if (ptr->type == NETLBL_NLTYPE_ADDRSELECT) {
+		netlbl_af4list_foreach_safe(iter4, tmp4,
+					    &ptr->type_def.addrsel->list4) {
+			netlbl_af4list_remove_entry(iter4);
+			kfree(netlbl_domhsh_addr4_entry(iter4));
+		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		netlbl_af6list_foreach_safe(iter6, tmp6,
+					    &ptr->type_def.addrsel->list6) {
+			netlbl_af6list_remove_entry(iter6);
+			kfree(netlbl_domhsh_addr6_entry(iter6));
+		}
+#endif /* IPv6 */
+	}
 	kfree(ptr->domain);
 	kfree(ptr);
 }
@@ -156,6 +175,69 @@ static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain)
 	return entry;
 }
 
+/**
+ * netlbl_domhsh_audit_add - Generate an audit entry for an add event
+ * @entry: the entry being added
+ * @addr4: the IPv4 address information
+ * @addr6: the IPv6 address information
+ * @result: the result code
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * Generate an audit record for adding a new NetLabel/LSM mapping entry with
+ * the given information.  Caller is responsibile for holding the necessary
+ * locks.
+ *
+ */
+static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
+				    struct netlbl_af4list *addr4,
+				    struct netlbl_af6list *addr6,
+				    int result,
+				    struct netlbl_audit *audit_info)
+{
+	struct audit_buffer *audit_buf;
+	struct cipso_v4_doi *cipsov4 = NULL;
+	u32 type;
+
+	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD, audit_info);
+	if (audit_buf != NULL) {
+		audit_log_format(audit_buf, " nlbl_domain=%s",
+				 entry->domain ? entry->domain : "(default)");
+		if (addr4 != NULL) {
+			struct netlbl_domaddr4_map *map4;
+			map4 = netlbl_domhsh_addr4_entry(addr4);
+			type = map4->type;
+			cipsov4 = map4->type_def.cipsov4;
+			netlbl_af4list_audit_addr(audit_buf, 0, NULL,
+						  addr4->addr, addr4->mask);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		} else if (addr6 != NULL) {
+			struct netlbl_domaddr6_map *map6;
+			map6 = netlbl_domhsh_addr6_entry(addr6);
+			type = map6->type;
+			netlbl_af6list_audit_addr(audit_buf, 0, NULL,
+						  &addr6->addr, &addr6->mask);
+#endif /* IPv6 */
+		} else {
+			type = entry->type;
+			cipsov4 = entry->type_def.cipsov4;
+		}
+		switch (type) {
+		case NETLBL_NLTYPE_UNLABELED:
+			audit_log_format(audit_buf, " nlbl_protocol=unlbl");
+			break;
+		case NETLBL_NLTYPE_CIPSOV4:
+			BUG_ON(cipsov4 == NULL);
+			audit_log_format(audit_buf,
+					 " nlbl_protocol=cipsov4 cipso_doi=%u",
+					 cipsov4->doi);
+			break;
+		}
+		audit_log_format(audit_buf, " res=%u", result == 0 ? 1 : 0);
+		audit_log_end(audit_buf);
+	}
+}
+
 /*
  * Domain Hash Table Functions
  */
@@ -213,50 +295,104 @@ int __init netlbl_domhsh_init(u32 size)
 int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 		      struct netlbl_audit *audit_info)
 {
-	int ret_val;
-	u32 bkt;
-	struct audit_buffer *audit_buf;
-
-	entry->valid = 1;
-	INIT_RCU_HEAD(&entry->rcu);
+	int ret_val = 0;
+	struct netlbl_dom_map *entry_old;
+	struct netlbl_af4list *iter4;
+	struct netlbl_af6list *iter6;
 
 	rcu_read_lock();
+
 	spin_lock(&netlbl_domhsh_lock);
-	if (entry->domain != NULL) {
-		bkt = netlbl_domhsh_hash(entry->domain);
-		if (netlbl_domhsh_search(entry->domain) == NULL)
+	if (entry->domain != NULL)
+		entry_old = netlbl_domhsh_search(entry->domain);
+	else
+		entry_old = netlbl_domhsh_search_def(entry->domain);
+	if (entry_old == NULL) {
+		entry->valid = 1;
+		INIT_RCU_HEAD(&entry->rcu);
+
+		if (entry->domain != NULL) {
+			u32 bkt = netlbl_domhsh_hash(entry->domain);
 			list_add_tail_rcu(&entry->list,
 				    &rcu_dereference(netlbl_domhsh)->tbl[bkt]);
-		else
-			ret_val = -EEXIST;
-	} else {
-		INIT_LIST_HEAD(&entry->list);
-		if (rcu_dereference(netlbl_domhsh_def) == NULL)
+		} else {
+			INIT_LIST_HEAD(&entry->list);
 			rcu_assign_pointer(netlbl_domhsh_def, entry);
-		else
-			ret_val = -EEXIST;
-	}
-	spin_unlock(&netlbl_domhsh_lock);
-	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD, audit_info);
-	if (audit_buf != NULL) {
-		audit_log_format(audit_buf,
-				 " nlbl_domain=%s",
-				 entry->domain ? entry->domain : "(default)");
-		switch (entry->type) {
-		case NETLBL_NLTYPE_UNLABELED:
-			audit_log_format(audit_buf, " nlbl_protocol=unlbl");
-			break;
-		case NETLBL_NLTYPE_CIPSOV4:
-			audit_log_format(audit_buf,
-					 " nlbl_protocol=cipsov4 cipso_doi=%u",
-					 entry->type_def.cipsov4->doi);
-			break;
 		}
-		audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
-		audit_log_end(audit_buf);
-	}
-	rcu_read_unlock();
 
+		if (entry->type == NETLBL_NLTYPE_ADDRSELECT) {
+			netlbl_af4list_foreach_rcu(iter4,
+					       &entry->type_def.addrsel->list4)
+				netlbl_domhsh_audit_add(entry, iter4, NULL,
+							ret_val, audit_info);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+			netlbl_af6list_foreach_rcu(iter6,
+					       &entry->type_def.addrsel->list6)
+				netlbl_domhsh_audit_add(entry, NULL, iter6,
+							ret_val, audit_info);
+#endif /* IPv6 */
+		} else
+			netlbl_domhsh_audit_add(entry, NULL, NULL,
+						ret_val, audit_info);
+	} else if (entry_old->type == NETLBL_NLTYPE_ADDRSELECT &&
+		   entry->type == NETLBL_NLTYPE_ADDRSELECT) {
+		struct netlbl_af4list *tmp4;
+		struct netlbl_af6list *tmp6;
+		struct list_head *old_list4;
+		struct list_head *old_list6;
+
+		old_list4 = &entry_old->type_def.addrsel->list4;
+		old_list6 = &entry_old->type_def.addrsel->list6;
+
+		/* we only allow the addition of address selectors if all of
+		 * the selectors do not exist in the existing domain map */
+		netlbl_af4list_foreach_rcu(iter4, 
+					   &entry->type_def.addrsel->list4)
+			if (netlbl_af4list_search_exact(iter4->addr,
+							iter4->mask,
+							old_list4)) {
+				ret_val = -EEXIST;
+				goto add_return;
+			}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		netlbl_af6list_foreach_rcu(iter6,
+					   &entry->type_def.addrsel->list6)
+			if (netlbl_af6list_search_exact(&iter6->addr,
+							&iter6->mask,
+							old_list6)) {
+				ret_val = -EEXIST;
+				goto add_return;
+			}
+#endif /* IPv6 */
+
+		netlbl_af4list_foreach_safe(iter4, tmp4,
+					    &entry->type_def.addrsel->list4) {
+			netlbl_af4list_remove_entry(iter4);
+			iter4->valid = 1;
+			ret_val = netlbl_af4list_add(iter4, old_list4);
+			netlbl_domhsh_audit_add(entry_old, iter4, NULL,
+						ret_val, audit_info);
+			if (ret_val != 0)
+				goto add_return;
+		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		netlbl_af6list_foreach_safe(iter6, tmp6,
+					    &entry->type_def.addrsel->list6) {
+			netlbl_af6list_remove_entry(iter6);
+			iter6->valid = 1;
+			ret_val = netlbl_af6list_add(iter6, old_list6);
+			netlbl_domhsh_audit_add(entry_old, NULL, iter6,
+						ret_val, audit_info);
+			if (ret_val != 0)
+				goto add_return;
+		}
+#endif /* IPv6 */
+	} else
+		ret_val = -EINVAL;
+
+add_return:
+	spin_unlock(&netlbl_domhsh_lock);
+	rcu_read_unlock();
 	return ret_val;
 }
 
@@ -319,7 +455,19 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 	}
 
 	if (ret_val == 0) {
+		struct netlbl_af4list *iter4;
+		struct netlbl_domaddr4_map *map4;
+
 		switch (entry->type) {
+		case NETLBL_NLTYPE_ADDRSELECT:
+			netlbl_af4list_foreach_rcu(iter4,
+					     &entry->type_def.addrsel->list4) {
+				map4 = netlbl_domhsh_addr4_entry(iter4);
+				cipso_v4_doi_putdef(map4->type_def.cipsov4);
+			}
+			/* no need to check the IPv6 list since we currently
+			 * support only unlabeled protocols for IPv6 */
+			break;
 		case NETLBL_NLTYPE_CIPSOV4:
 			cipso_v4_doi_putdef(entry->type_def.cipsov4);
 			break;
@@ -388,6 +536,70 @@ struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain)
 }
 
 /**
+ * netlbl_domhsh_getentry_af4 - Get an entry from the domain hash table
+ * @domain: the domain name to search for
+ * @addr: the IP address to search for
+ *
+ * Description:
+ * Look through the domain hash table searching for an entry to match @domain
+ * and @addr, return a pointer to a copy of the entry or NULL.  The caller is
+ * responsible for ensuring that rcu_read_[un]lock() is called.
+ *
+ */
+struct netlbl_domaddr4_map *netlbl_domhsh_getentry_af4(const char *domain,
+						       __be32 addr)
+{
+	struct netlbl_dom_map *dom_iter;
+	struct netlbl_af4list *addr_iter;
+
+	dom_iter = netlbl_domhsh_search_def(domain);
+	if (dom_iter == NULL)
+		return NULL;
+	if (dom_iter->type != NETLBL_NLTYPE_ADDRSELECT)
+		return NULL;
+
+	addr_iter = netlbl_af4list_search(addr,
+					  &dom_iter->type_def.addrsel->list4);
+	if (addr_iter == NULL)
+		return NULL;
+	
+	return netlbl_domhsh_addr4_entry(addr_iter);
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+/**
+ * netlbl_domhsh_getentry_af6 - Get an entry from the domain hash table
+ * @domain: the domain name to search for
+ * @addr: the IP address to search for
+ *
+ * Description:
+ * Look through the domain hash table searching for an entry to match @domain
+ * and @addr, return a pointer to a copy of the entry or NULL.  The caller is
+ * responsible for ensuring that rcu_read_[un]lock() is called.
+ *
+ */
+struct netlbl_domaddr6_map *netlbl_domhsh_getentry_af6(const char *domain,
+						   const struct in6_addr *addr)
+{
+	struct netlbl_dom_map *dom_iter;
+	struct netlbl_af6list *addr_iter;
+
+	dom_iter = netlbl_domhsh_search_def(domain);
+	if (dom_iter == NULL)
+		return NULL;
+	if (dom_iter->type != NETLBL_NLTYPE_ADDRSELECT)
+		return NULL;
+
+	addr_iter = netlbl_af6list_search(addr,
+					  &dom_iter->type_def.addrsel->list6);
+	if (addr_iter == NULL)
+		return NULL;
+	
+	return netlbl_domhsh_addr6_entry(addr_iter);
+}
+#endif /* IPv6 */
+
+/**
  * netlbl_domhsh_walk - Iterate through the domain mapping hash table
  * @skip_bkt: the number of buckets to skip at the start
  * @skip_chain: the number of entries to skip in the first iterated bucket
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index afcc41a..bfcb676 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -11,7 +11,7 @@
  */
 
 /*
- * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006, 2008
  *
  * This program is free software;  you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -36,16 +36,43 @@
 #include <linux/rcupdate.h>
 #include <linux/list.h>
 
+#include "netlabel_addrlist.h"
+
 /* Domain hash table size */
 /* XXX - currently this number is an uneducated guess */
 #define NETLBL_DOMHSH_BITSIZE       7
 
-/* Domain mapping definition struct */
+/* Domain mapping definition structures */
+#define netlbl_domhsh_addr4_entry(iter) \
+	container_of(iter, struct netlbl_domaddr4_map, list)
+struct netlbl_domaddr4_map {
+	u32 type;
+	union {
+		struct cipso_v4_doi *cipsov4;
+	} type_def;
+
+	struct netlbl_af4list list;
+};
+#define netlbl_domhsh_addr6_entry(iter) \
+	container_of(iter, struct netlbl_domaddr6_map, list)
+struct netlbl_domaddr6_map {
+	u32 type;
+
+	/* NOTE: no 'type_def' union needed at present since we don't currently
+	 *       support any IPv6 labeling protocols */
+
+	struct netlbl_af6list list;
+};
+struct netlbl_domaddr_map {
+	struct list_head list4;
+	struct list_head list6;
+};
 struct netlbl_dom_map {
 	char *domain;
 	u32 type;
 	union {
 		struct cipso_v4_doi *cipsov4;
+		struct netlbl_domaddr_map *addrsel;
 	} type_def;
 
 	u32 valid;
@@ -66,9 +93,16 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info);
 int netlbl_domhsh_remove_default(struct netlbl_audit *audit_info);
 struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
+struct netlbl_domaddr4_map *netlbl_domhsh_getentry_af4(const char *domain,
+						       __be32 addr);
 int netlbl_domhsh_walk(u32 *skip_bkt,
 		     u32 *skip_chain,
 		     int (*callback) (struct netlbl_dom_map *entry, void *arg),
 		     void *cb_arg);
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+struct netlbl_domaddr6_map *netlbl_domhsh_getentry_af6(const char *domain,
+						  const struct in6_addr *addr);
+#endif /* IPv6 */
+
 #endif
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 28cadee..1f0286c 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -420,7 +420,9 @@ int netlbl_enabled(void)
  * Attach the correct label to the given socket using the security attributes
  * specified in @secattr.  This function requires exclusive access to @sk,
  * which means it either needs to be in the process of being created or locked.
- * Returns zero on success, negative values on failure.
+ * Returns zero on success, -EDESTADDRREQ if the domain is configured to use
+ * network address selectors (can't blindly label the socket), and negative
+ * values on all other failures.
  *
  */
 int netlbl_sock_setattr(struct sock *sk,
@@ -434,6 +436,9 @@ int netlbl_sock_setattr(struct sock *sk,
 	if (dom_entry == NULL)
 		goto socket_setattr_return;
 	switch (dom_entry->type) {
+	case NETLBL_NLTYPE_ADDRSELECT:
+		ret_val = -EDESTADDRREQ;
+		break;
 	case NETLBL_NLTYPE_CIPSOV4:
 		ret_val = cipso_v4_sock_setattr(sk,
 						dom_entry->type_def.cipsov4,
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index c4e18c7..cdbe812 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -10,7 +10,7 @@
  */
 
 /*
- * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006, 2008
  *
  * This program is free software;  you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -32,9 +32,13 @@
 #include <linux/socket.h>
 #include <linux/string.h>
 #include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/in6.h>
 #include <net/sock.h>
 #include <net/netlink.h>
 #include <net/genetlink.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
 #include <net/netlabel.h>
 #include <net/cipso_ipv4.h>
 #include <asm/atomic.h>
@@ -71,80 +75,326 @@ static const struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
 };
 
 /*
- * NetLabel Command Handlers
+ * Helper Functions
  */
 
 /**
  * netlbl_mgmt_add - Handle an ADD message
- * @skb: the NETLINK buffer
  * @info: the Generic NETLINK info block
+ * @audit_info: NetLabel audit information
  *
  * Description:
- * Process a user generated ADD message and add the domains from the message
- * to the hash table.  See netlabel.h for a description of the message format.
- * Returns zero on success, negative values on failure.
+ * Helper function for the ADD and ADDDEF messages to add the domain mappings
+ * from the message to the hash table.  See netlabel.h for a description of the
+ * message format.  Returns zero on success, negative values on failure.
  *
  */
-static int netlbl_mgmt_add(struct sk_buff *skb, struct genl_info *info)
+static int netlbl_mgmt_add_common(struct genl_info *info,
+				  struct netlbl_audit *audit_info)
 {
 	int ret_val = -EINVAL;
 	struct netlbl_dom_map *entry = NULL;
-	size_t tmp_size;
+	struct netlbl_domaddr_map *addrmap = NULL;
+	struct cipso_v4_doi *cipsov4 = NULL;
 	u32 tmp_val;
-	struct netlbl_audit audit_info;
-
-	if (!info->attrs[NLBL_MGMT_A_DOMAIN] ||
-	    !info->attrs[NLBL_MGMT_A_PROTOCOL])
-		goto add_failure;
-
-	netlbl_netlink_auditinfo(skb, &audit_info);
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (entry == NULL) {
 		ret_val = -ENOMEM;
 		goto add_failure;
 	}
-	tmp_size = nla_len(info->attrs[NLBL_MGMT_A_DOMAIN]);
-	entry->domain = kmalloc(tmp_size, GFP_KERNEL);
-	if (entry->domain == NULL) {
-		ret_val = -ENOMEM;
-		goto add_failure;
-	}
 	entry->type = nla_get_u32(info->attrs[NLBL_MGMT_A_PROTOCOL]);
-	nla_strlcpy(entry->domain, info->attrs[NLBL_MGMT_A_DOMAIN], tmp_size);
+	if (info->attrs[NLBL_MGMT_A_DOMAIN]) {
+		size_t tmp_size = nla_len(info->attrs[NLBL_MGMT_A_DOMAIN]);
+		entry->domain = kmalloc(tmp_size, GFP_KERNEL);
+		if (entry->domain == NULL) {
+			ret_val = -ENOMEM;
+			goto add_failure;
+		}
+		nla_strlcpy(entry->domain,
+			    info->attrs[NLBL_MGMT_A_DOMAIN], tmp_size);
+	}
+
+	/* NOTE: internally we allow/use a entry->type value of
+	 *       NETLBL_NLTYPE_ADDRSELECT but we don't currently allow users
+	 *       to pass that as a protocol value because we need to know the
+	 *       "real" protocol */
 
 	switch (entry->type) {
 	case NETLBL_NLTYPE_UNLABELED:
-		ret_val = netlbl_domhsh_add(entry, &audit_info);
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
 		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
 			goto add_failure;
 
 		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
-		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
-		if (entry->type_def.cipsov4 == NULL)
+		cipsov4 = cipso_v4_doi_getdef(tmp_val);
+		if (cipsov4 == NULL)
 			goto add_failure;
-		ret_val = netlbl_domhsh_add(entry, &audit_info);
-		if (ret_val != 0)
-			cipso_v4_doi_putdef(entry->type_def.cipsov4);
+		entry->type_def.cipsov4 = cipsov4;
 		break;
 	default:
 		goto add_failure;
 	}
+	if ((info->attrs[NLBL_MGMT_A_IPV4ADDR] &&
+	     info->attrs[NLBL_MGMT_A_IPV4MASK]) ||
+	    (info->attrs[NLBL_MGMT_A_IPV6ADDR] &&
+	     info->attrs[NLBL_MGMT_A_IPV6MASK])) {
+		addrmap = kzalloc(sizeof(*addrmap), GFP_KERNEL);
+		if (addrmap == NULL) {
+			ret_val = -ENOMEM;
+			goto add_failure;
+		}
+		INIT_LIST_HEAD(&addrmap->list4);
+		INIT_LIST_HEAD(&addrmap->list6);
+
+		if (info->attrs[NLBL_MGMT_A_IPV4ADDR]) {
+			struct in_addr *addr;
+			struct in_addr *mask;
+			struct netlbl_domaddr4_map *map;
+
+			if (nla_len(info->attrs[NLBL_MGMT_A_IPV4ADDR]) !=
+			    sizeof(struct in_addr)) {
+				ret_val = -EINVAL;
+				goto add_failure;
+			}
+			if (nla_len(info->attrs[NLBL_MGMT_A_IPV4MASK]) !=
+			    sizeof(struct in_addr)) {
+				ret_val = -EINVAL;
+				goto add_failure;
+			}
+			addr = nla_data(info->attrs[NLBL_MGMT_A_IPV4ADDR]);
+			mask = nla_data(info->attrs[NLBL_MGMT_A_IPV4MASK]);
+
+			map = kzalloc(sizeof(*map), GFP_KERNEL);
+			if (map == NULL) {
+				ret_val = -ENOMEM;
+				goto add_failure;
+			}
+			map->list.addr = addr->s_addr & mask->s_addr;
+			map->list.mask = mask->s_addr;
+			map->list.valid = 1;
+			map->type = entry->type;
+			if (cipsov4)
+				map->type_def.cipsov4 = cipsov4;
+
+			ret_val = netlbl_af4list_add(&map->list,
+						     &addrmap->list4);
+			if (ret_val != 0) {
+				/* XXX - cleanup map in case of failure? */
+				goto add_failure;
+			}
+		} else {
+			struct in6_addr *addr;
+			struct in6_addr *mask;
+			struct netlbl_domaddr6_map *map;
+
+			if (nla_len(info->attrs[NLBL_MGMT_A_IPV6ADDR]) !=
+			    sizeof(struct in6_addr)) {
+				ret_val = -EINVAL;
+				goto add_failure;
+			}
+			if (nla_len(info->attrs[NLBL_MGMT_A_IPV6MASK]) !=
+			    sizeof(struct in6_addr)) {
+				ret_val = -EINVAL;
+				goto add_failure;
+			}
+			addr = nla_data(info->attrs[NLBL_MGMT_A_IPV6ADDR]);
+			mask = nla_data(info->attrs[NLBL_MGMT_A_IPV6MASK]);
+
+			map = kzalloc(sizeof(*map), GFP_KERNEL);
+			if (map == NULL) {
+				ret_val = -ENOMEM;
+				goto add_failure;
+			}
+			ipv6_addr_copy(&map->list.addr, addr);
+			map->list.addr.s6_addr32[0] &= mask->s6_addr32[0];
+			map->list.addr.s6_addr32[1] &= mask->s6_addr32[1];
+			map->list.addr.s6_addr32[2] &= mask->s6_addr32[2];
+			map->list.addr.s6_addr32[3] &= mask->s6_addr32[3];
+			ipv6_addr_copy(&map->list.mask, mask);
+			map->list.valid = 1;
+			map->type = entry->type;
+
+			ret_val = netlbl_af6list_add(&map->list,
+						     &addrmap->list6);
+			if (ret_val != 0) {
+				/* XXX - cleanup map in case of failure? */
+				goto add_failure;
+			}
+		}
+
+		entry->type = NETLBL_NLTYPE_ADDRSELECT;
+		entry->type_def.addrsel = addrmap;
+	}
+
+	ret_val = netlbl_domhsh_add(entry, audit_info);
 	if (ret_val != 0)
 		goto add_failure;
 
 	return 0;
 
 add_failure:
+	if (cipsov4)
+		cipso_v4_doi_putdef(cipsov4);
 	if (entry)
 		kfree(entry->domain);
+	kfree(addrmap);
 	kfree(entry);
 	return ret_val;
 }
 
 /**
+ * netlbl_mgmt_listentry - List a NetLabel/LSM domain map entry
+ * @skb: the NETLINK buffer
+ * @entry: the map entry
+ *
+ * Description:
+ * This function is a helper function used by the LISTALL and LISTDEF command
+ * handlers.  The caller is responsibile for ensuring that the RCU read lock
+ * is held.  Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_listentry(struct sk_buff *skb,
+				 struct netlbl_dom_map *entry)
+{
+	int ret_val;
+	struct nlattr *nla_a;
+	struct nlattr *nla_b;
+	struct netlbl_af4list *iter4;
+	struct netlbl_af6list *iter6;
+
+	if (entry->domain != NULL) {
+		ret_val = nla_put_string(skb,
+					 NLBL_MGMT_A_DOMAIN, entry->domain);
+		if (ret_val != 0)
+			return ret_val;
+	}
+
+	switch (entry->type) {
+	case NETLBL_NLTYPE_ADDRSELECT:
+		nla_a = nla_nest_start(skb, NLBL_MGMT_A_SELECTORLIST);
+		if (nla_a == NULL)
+			return -ENOMEM;
+
+		netlbl_af4list_foreach_rcu(iter4,
+					   &entry->type_def.addrsel->list4) {
+			struct netlbl_domaddr4_map *map4;
+			struct in_addr addr_struct;
+
+			nla_b = nla_nest_start(skb, NLBL_MGMT_A_ADDRSELECTOR);
+			if (nla_b == NULL)
+				return -ENOMEM;
+
+			addr_struct.s_addr = iter4->addr;
+			ret_val = nla_put(skb, NLBL_MGMT_A_IPV4ADDR,
+					  sizeof(struct in_addr),
+					  &addr_struct);
+			if (ret_val != 0)
+				return ret_val;
+			addr_struct.s_addr = iter4->mask;
+			ret_val = nla_put(skb, NLBL_MGMT_A_IPV4MASK,
+					  sizeof(struct in_addr),
+					  &addr_struct);
+			if (ret_val != 0)
+				return ret_val;
+			map4 = netlbl_domhsh_addr4_entry(iter4);
+			ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL,
+					      map4->type);
+			if (ret_val != 0)
+				return ret_val;
+			switch(map4->type) {
+			case NETLBL_NLTYPE_CIPSOV4:
+				ret_val = nla_put_u32(skb, NLBL_MGMT_A_CV4DOI,
+						  map4->type_def.cipsov4->doi);
+				if (ret_val != 0)
+					return ret_val;
+				break;
+			}
+
+			nla_nest_end(skb, nla_b);
+		}
+		netlbl_af6list_foreach_rcu(iter6,
+					   &entry->type_def.addrsel->list6) {
+			struct netlbl_domaddr6_map *map6;
+
+			nla_b = nla_nest_start(skb, NLBL_MGMT_A_ADDRSELECTOR);
+			if (nla_b == NULL)
+				return -ENOMEM;
+
+			ret_val = nla_put(skb, NLBL_MGMT_A_IPV6ADDR,
+					  sizeof(struct in6_addr),
+					  &iter6->addr);
+			if (ret_val != 0)
+				return ret_val;
+			ret_val = nla_put(skb, NLBL_MGMT_A_IPV6MASK,
+					  sizeof(struct in6_addr),
+					  &iter6->mask);
+			if (ret_val != 0)
+				return ret_val;
+			map6 = netlbl_domhsh_addr6_entry(iter6);
+			ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL,
+					      map6->type);
+			if (ret_val != 0)
+				return ret_val;
+
+			nla_nest_end(skb, nla_b);
+		}
+
+		nla_nest_end(skb, nla_a);
+		break;
+	case NETLBL_NLTYPE_UNLABELED:
+		ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL, entry->type);
+		break;
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL, entry->type);
+		if (ret_val != 0)
+			return ret_val;
+		ret_val = nla_put_u32(skb, NLBL_MGMT_A_CV4DOI,
+				      entry->type_def.cipsov4->doi);
+		break;
+	}
+
+	return ret_val;
+}
+
+/*
+ * NetLabel Command Handlers
+ */
+
+/**
+ * netlbl_mgmt_add - Handle an ADD message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated ADD message and add the domains from the message
+ * to the hash table.  See netlabel.h for a description of the message format.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_add(struct sk_buff *skb, struct genl_info *info)
+{
+	struct netlbl_audit audit_info;
+
+	if ((!info->attrs[NLBL_MGMT_A_DOMAIN]) ||
+	    (!info->attrs[NLBL_MGMT_A_PROTOCOL]) ||
+	    (info->attrs[NLBL_MGMT_A_IPV4ADDR] &&
+	     info->attrs[NLBL_MGMT_A_IPV6ADDR]) ||
+	    (info->attrs[NLBL_MGMT_A_IPV4MASK] &&
+	     info->attrs[NLBL_MGMT_A_IPV6MASK]) ||
+	    ((info->attrs[NLBL_MGMT_A_IPV4ADDR] != NULL) ^
+	     (info->attrs[NLBL_MGMT_A_IPV4MASK] != NULL)) ||
+	    ((info->attrs[NLBL_MGMT_A_IPV6ADDR] != NULL) ^
+	     (info->attrs[NLBL_MGMT_A_IPV6MASK] != NULL))) 
+		return -EINVAL;
+
+	netlbl_netlink_auditinfo(skb, &audit_info);
+
+	return netlbl_mgmt_add_common(info, &audit_info);
+}
+
+/**
  * netlbl_mgmt_remove - Handle a REMOVE message
  * @skb: the NETLINK buffer
  * @info: the Generic NETLINK info block
@@ -192,23 +442,9 @@ static int netlbl_mgmt_listall_cb(struct netlbl_dom_map *entry, void *arg)
 	if (data == NULL)
 		goto listall_cb_failure;
 
-	ret_val = nla_put_string(cb_arg->skb,
-				 NLBL_MGMT_A_DOMAIN,
-				 entry->domain);
-	if (ret_val != 0)
-		goto listall_cb_failure;
-	ret_val = nla_put_u32(cb_arg->skb, NLBL_MGMT_A_PROTOCOL, entry->type);
+	ret_val = netlbl_mgmt_listentry(cb_arg->skb, entry);
 	if (ret_val != 0)
 		goto listall_cb_failure;
-	switch (entry->type) {
-	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = nla_put_u32(cb_arg->skb,
-				      NLBL_MGMT_A_CV4DOI,
-				      entry->type_def.cipsov4->doi);
-		if (ret_val != 0)
-			goto listall_cb_failure;
-		break;
-	}
 
 	cb_arg->seq++;
 	return genlmsg_end(cb_arg->skb, data);
@@ -262,50 +498,22 @@ static int netlbl_mgmt_listall(struct sk_buff *skb,
  */
 static int netlbl_mgmt_adddef(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret_val = -EINVAL;
-	struct netlbl_dom_map *entry = NULL;
-	u32 tmp_val;
 	struct netlbl_audit audit_info;
 
-	if (!info->attrs[NLBL_MGMT_A_PROTOCOL])
-		goto adddef_failure;
+	if ((!info->attrs[NLBL_MGMT_A_PROTOCOL]) ||
+	    (info->attrs[NLBL_MGMT_A_IPV4ADDR] &&
+	     info->attrs[NLBL_MGMT_A_IPV6ADDR]) ||
+	    (info->attrs[NLBL_MGMT_A_IPV4MASK] &&
+	     info->attrs[NLBL_MGMT_A_IPV6MASK]) ||
+	    ((info->attrs[NLBL_MGMT_A_IPV4ADDR] != NULL) ^
+	     (info->attrs[NLBL_MGMT_A_IPV4MASK] != NULL)) ||
+	    ((info->attrs[NLBL_MGMT_A_IPV6ADDR] != NULL) ^
+	     (info->attrs[NLBL_MGMT_A_IPV6MASK] != NULL))) 
+		return -EINVAL;
 
 	netlbl_netlink_auditinfo(skb, &audit_info);
 
-	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
-	if (entry == NULL) {
-		ret_val = -ENOMEM;
-		goto adddef_failure;
-	}
-	entry->type = nla_get_u32(info->attrs[NLBL_MGMT_A_PROTOCOL]);
-
-	switch (entry->type) {
-	case NETLBL_NLTYPE_UNLABELED:
-		ret_val = netlbl_domhsh_add_default(entry, &audit_info);
-		break;
-	case NETLBL_NLTYPE_CIPSOV4:
-		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
-			goto adddef_failure;
-
-		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
-		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
-		if (entry->type_def.cipsov4 == NULL)
-			goto adddef_failure;
-		ret_val = netlbl_domhsh_add_default(entry, &audit_info);
-		if (ret_val != 0)
-			cipso_v4_doi_putdef(entry->type_def.cipsov4);
-		break;
-	default:
-		goto adddef_failure;
-	}
-	if (ret_val != 0)
-		goto adddef_failure;
-
-	return 0;
-
-adddef_failure:
-	kfree(entry);
-	return ret_val;
+	return netlbl_mgmt_add_common(info, &audit_info);
 }
 
 /**
@@ -359,19 +567,10 @@ static int netlbl_mgmt_listdef(struct sk_buff *skb, struct genl_info *info)
 		ret_val = -ENOENT;
 		goto listdef_failure_lock;
 	}
-	ret_val = nla_put_u32(ans_skb, NLBL_MGMT_A_PROTOCOL, entry->type);
-	if (ret_val != 0)
-		goto listdef_failure_lock;
-	switch (entry->type) {
-	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = nla_put_u32(ans_skb,
-				      NLBL_MGMT_A_CV4DOI,
-				      entry->type_def.cipsov4->doi);
-		if (ret_val != 0)
-			goto listdef_failure_lock;
-		break;
-	}
+	ret_val = netlbl_mgmt_listentry(ans_skb, entry);
 	rcu_read_unlock();
+	if (ret_val != 0)
+		goto listdef_failure;
 
 	genlmsg_end(ans_skb, data);
 	return genlmsg_reply(ans_skb, info);
diff --git a/net/netlabel/netlabel_mgmt.h b/net/netlabel/netlabel_mgmt.h
index a43bff1..05d9643 100644
--- a/net/netlabel/netlabel_mgmt.h
+++ b/net/netlabel/netlabel_mgmt.h
@@ -45,6 +45,16 @@
  *     NLBL_MGMT_A_DOMAIN
  *     NLBL_MGMT_A_PROTOCOL
  *
+ *   If IPv4 is specified the following attributes are required:
+ *
+ *     NLBL_MGMT_A_IPV4ADDR
+ *     NLBL_MGMT_A_IPV4MASK
+ *
+ *   If IPv6 is specified the following attributes are required:
+ *
+ *     NLBL_MGMT_A_IPV6ADDR
+ *     NLBL_MGMT_A_IPV6MASK
+ *
  *   If using NETLBL_NLTYPE_CIPSOV4 the following attributes are required:
  *
  *     NLBL_MGMT_A_CV4DOI
@@ -68,13 +78,24 @@
  *   Required attributes:
  *
  *     NLBL_MGMT_A_DOMAIN
+ *
+ *   If the IP address selectors are not used the following attribute is
+ *   required:
+ *
  *     NLBL_MGMT_A_PROTOCOL
  *
- *   If using NETLBL_NLTYPE_CIPSOV4 the following attributes are required:
+ *   If the IP address selectors are used then the following attritbute is
+ *   required:
+ *
+ *     NLBL_MGMT_A_SELECTORLIST
+ *
+ *   If the mapping is using the NETLBL_NLTYPE_CIPSOV4 type then the following
+ *   attributes are required:
  *
  *     NLBL_MGMT_A_CV4DOI
  *
- *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
+ *   If the mapping is using the NETLBL_NLTYPE_UNLABELED type no other
+ *   attributes are required.
  *
  * o ADDDEF:
  *   Sent by an application to set the default domain mapping for the NetLabel
@@ -100,15 +121,23 @@
  *   application there is no payload.  On success the kernel should send a
  *   response using the following format.
  *
- *   Required attributes:
+ *   If the IP address selectors are not used the following attribute is
+ *   required:
  *
  *     NLBL_MGMT_A_PROTOCOL
  *
- *   If using NETLBL_NLTYPE_CIPSOV4 the following attributes are required:
+ *   If the IP address selectors are used then the following attritbute is
+ *   required:
+ *
+ *     NLBL_MGMT_A_SELECTORLIST
+ *
+ *   If the mapping is using the NETLBL_NLTYPE_CIPSOV4 type then the following
+ *   attributes are required:
  *
  *     NLBL_MGMT_A_CV4DOI
  *
- *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
+ *   If the mapping is using the NETLBL_NLTYPE_UNLABELED type no other
+ *   attributes are required.
  *
  * o PROTOCOLS:
  *   Sent by an application to request a list of configured NetLabel protocols
@@ -162,6 +191,26 @@ enum {
 	NLBL_MGMT_A_CV4DOI,
 	/* (NLA_U32)
 	 * the CIPSOv4 DOI value */
+	NLBL_MGMT_A_IPV6ADDR,
+	/* (NLA_BINARY, struct in6_addr)
+	 * an IPv6 address */
+	NLBL_MGMT_A_IPV6MASK,
+	/* (NLA_BINARY, struct in6_addr)
+	 * an IPv6 address mask */
+	NLBL_MGMT_A_IPV4ADDR,
+	/* (NLA_BINARY, struct in_addr)
+	 * an IPv4 address */
+	NLBL_MGMT_A_IPV4MASK,
+	/* (NLA_BINARY, struct in_addr)
+	 * and IPv4 address mask */
+	NLBL_MGMT_A_ADDRSELECTOR,
+	/* (NLA_NESTED)
+	 * an IP address selector, must contain an address, mask, and protocol
+	 * attribute plus any protocol specific attributes */
+	NLBL_MGMT_A_SELECTORLIST,
+	/* (NLA_NESTED)
+	 * the selector list, there must be at least one
+	 * NLBL_MGMT_A_ADDRSELECTOR attribute */
 	__NLBL_MGMT_A_MAX,
 };
 #define NLBL_MGMT_A_MAX (__NLBL_MGMT_A_MAX - 1)
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 4a28549..8a87378 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -146,76 +146,6 @@ static const struct nla_policy netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1
 };
 
 /*
- * Audit Helper Functions
- */
-
-/**
- * netlbl_unlabel_audit_addr4 - Audit an IPv4 address
- * @audit_buf: audit buffer
- * @dev: network interface
- * @addr: IP address
- * @mask: IP address mask
- *
- * Description:
- * Write the IPv4 address and address mask, if necessary, to @audit_buf.
- *
- */
-static void netlbl_unlabel_audit_addr4(struct audit_buffer *audit_buf,
-				     const char *dev,
-				     __be32 addr, __be32 mask)
-{
-	u32 mask_val = ntohl(mask);
-
-	if (dev != NULL)
-		audit_log_format(audit_buf, " netif=%s", dev);
-	audit_log_format(audit_buf, " src=" NIPQUAD_FMT, NIPQUAD(addr));
-	if (mask_val != 0xffffffff) {
-		u32 mask_len = 0;
-		while (mask_val > 0) {
-			mask_val <<= 1;
-			mask_len++;
-		}
-		audit_log_format(audit_buf, " src_prefixlen=%d", mask_len);
-	}
-}
-
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-/**
- * netlbl_unlabel_audit_addr6 - Audit an IPv6 address
- * @audit_buf: audit buffer
- * @dev: network interface
- * @addr: IP address
- * @mask: IP address mask
- *
- * Description:
- * Write the IPv6 address and address mask, if necessary, to @audit_buf.
- *
- */
-static void netlbl_unlabel_audit_addr6(struct audit_buffer *audit_buf,
-				     const char *dev,
-				     const struct in6_addr *addr,
-				     const struct in6_addr *mask)
-{
-	if (dev != NULL)
-		audit_log_format(audit_buf, " netif=%s", dev);
-	audit_log_format(audit_buf, " src=" NIP6_FMT, NIP6(*addr));
-	if (ntohl(mask->s6_addr32[3]) != 0xffffffff) {
-		u32 mask_len = 0;
-		u32 mask_val;
-		int iter = -1;
-		while (ntohl(mask->s6_addr32[++iter]) == 0xffffffff)
-			mask_len += 32;
-		mask_val = ntohl(mask->s6_addr32[iter]);
-		while (mask_val > 0) {
-			mask_val <<= 1;
-			mask_len++;
-		}
-		audit_log_format(audit_buf, " src_prefixlen=%d", mask_len);
-	}
-}
-#endif /* IPv6 */
-
-/*
  * Unlabeled Connection Hash Table Functions
  */
 
@@ -567,10 +497,10 @@ static int netlbl_unlhsh_add(struct net *net,
 		mask4 = (struct in_addr *)mask;
 		ret_val = netlbl_unlhsh_add_addr4(iface, addr4, mask4, secid);
 		if (audit_buf != NULL)
-			netlbl_unlabel_audit_addr4(audit_buf,
-						   dev_name,
-						   addr4->s_addr,
-						   mask4->s_addr);
+			netlbl_af4list_audit_addr(audit_buf, 1,
+						  dev_name,
+						  addr4->s_addr,
+						  mask4->s_addr);
 		break;
 	}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -581,9 +511,9 @@ static int netlbl_unlhsh_add(struct net *net,
 		mask6 = (struct in6_addr *)mask;
 		ret_val = netlbl_unlhsh_add_addr6(iface, addr6, mask6, secid);
 		if (audit_buf != NULL)
-			netlbl_unlabel_audit_addr6(audit_buf,
-						   dev_name,
-						   addr6, mask6);
+			netlbl_af6list_audit_addr(audit_buf, 1,
+						  dev_name,
+						  addr6, mask6);
 		break;
 	}
 #endif /* IPv6 */
@@ -648,9 +578,9 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 					      audit_info);
 	if (audit_buf != NULL) {
 		dev = dev_get_by_index(net, iface->ifindex);
-		netlbl_unlabel_audit_addr4(audit_buf,
-					   (dev != NULL ? dev->name : NULL),
-					   addr->s_addr, mask->s_addr);
+		netlbl_af4list_audit_addr(audit_buf, 1,
+					  (dev != NULL ? dev->name : NULL),
+					  addr->s_addr, mask->s_addr);
 		if (dev != NULL)
 			dev_put(dev);
 		if (entry && security_secid_to_secctx(entry->secid,
@@ -708,9 +638,9 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 					      audit_info);
 	if (audit_buf != NULL) {
 		dev = dev_get_by_index(net, iface->ifindex);
-		netlbl_unlabel_audit_addr6(audit_buf,
-					   (dev != NULL ? dev->name : NULL),
-					   addr, mask);
+		netlbl_af6list_audit_addr(audit_buf, 1,
+					  (dev != NULL ? dev->name : NULL),
+					  addr, mask);
 		if (dev != NULL)
 			dev_put(dev);
 		if (entry && security_secid_to_secctx(entry->secid,

