From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: use domain based selectors when address based
 selectors are not available
Date: Fri, 02 Aug 2013 14:45:08 -0400
Message-ID: <20130802184508.22429.94026.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetLabel has the ability to selectively assign network security labels
to outbound traffic based on either the LSM's "domain" (different for
each LSM), the network destination, or a combination of both.  Depending
on the type of traffic, local or forwarded, and the type of traffic
selector, domain or address based, different hooks are used to label the
traffic; the goal being minimal overhead.

Unfortunately, there is a bug such that a system using NetLabel domain
based traffic selectors does not correctly label outbound local traffic
that is not assigned to a socket.  The issue is that in these cases
the associated NetLabel hook only looks at the address based selectors
and not the domain based selectors.  This patch corrects this by
checking both the domain and address based selectors so that the correct
labeling is applied, regardless of the configuration type.

In order to acomplish this fix, this patch also simplifies some of the
NetLabel domainhash structures to use a more common outbound traffic
mapping type: struct netlbl_dommap_def.  This simplifies some of the code
in this patch and paves the way for further simplifications in the
future.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/netlabel/netlabel_cipso_v4.c   |    4 +
 net/netlabel/netlabel_domainhash.c |  104 +++++++++++++++++-------------------
 net/netlabel/netlabel_domainhash.h |   46 ++++++++--------
 net/netlabel/netlabel_kapi.c       |   88 ++++++++++++------------------
 net/netlabel/netlabel_mgmt.c       |   44 +++++++--------
 net/netlabel/netlabel_unlabeled.c  |    2 -
 6 files changed, 130 insertions(+), 158 deletions(-)

diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index c15042f..a110064 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -691,8 +691,8 @@ static int netlbl_cipsov4_remove_cb(struct netlbl_dom_map *entry, void *arg)
 {
 	struct netlbl_domhsh_walk_arg *cb_arg = arg;
 
-	if (entry->type == NETLBL_NLTYPE_CIPSOV4 &&
-	    entry->type_def.cipsov4->doi == cb_arg->doi)
+	if (entry->def.type == NETLBL_NLTYPE_CIPSOV4 &&
+	    entry->def.cipso->doi == cb_arg->doi)
 		return netlbl_domhsh_remove_entry(entry, cb_arg->audit_info);
 
 	return 0;
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 6bb1d42..85d842e 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -84,15 +84,15 @@ static void netlbl_domhsh_free_entry(struct rcu_head *entry)
 #endif /* IPv6 */
 
 	ptr = container_of(entry, struct netlbl_dom_map, rcu);
-	if (ptr->type == NETLBL_NLTYPE_ADDRSELECT) {
+	if (ptr->def.type == NETLBL_NLTYPE_ADDRSELECT) {
 		netlbl_af4list_foreach_safe(iter4, tmp4,
-					    &ptr->type_def.addrsel->list4) {
+					    &ptr->def.addrsel->list4) {
 			netlbl_af4list_remove_entry(iter4);
 			kfree(netlbl_domhsh_addr4_entry(iter4));
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		netlbl_af6list_foreach_safe(iter6, tmp6,
-					    &ptr->type_def.addrsel->list6) {
+					    &ptr->def.addrsel->list6) {
 			netlbl_af6list_remove_entry(iter6);
 			kfree(netlbl_domhsh_addr6_entry(iter6));
 		}
@@ -213,21 +213,21 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
 		if (addr4 != NULL) {
 			struct netlbl_domaddr4_map *map4;
 			map4 = netlbl_domhsh_addr4_entry(addr4);
-			type = map4->type;
-			cipsov4 = map4->type_def.cipsov4;
+			type = map4->def.type;
+			cipsov4 = map4->def.cipso;
 			netlbl_af4list_audit_addr(audit_buf, 0, NULL,
 						  addr4->addr, addr4->mask);
 #if IS_ENABLED(CONFIG_IPV6)
 		} else if (addr6 != NULL) {
 			struct netlbl_domaddr6_map *map6;
 			map6 = netlbl_domhsh_addr6_entry(addr6);
-			type = map6->type;
+			type = map6->def.type;
 			netlbl_af6list_audit_addr(audit_buf, 0, NULL,
 						  &addr6->addr, &addr6->mask);
 #endif /* IPv6 */
 		} else {
-			type = entry->type;
-			cipsov4 = entry->type_def.cipsov4;
+			type = entry->def.type;
+			cipsov4 = entry->def.cipso;
 		}
 		switch (type) {
 		case NETLBL_NLTYPE_UNLABELED:
@@ -265,26 +265,25 @@ static int netlbl_domhsh_validate(const struct netlbl_dom_map *entry)
 	if (entry == NULL)
 		return -EINVAL;
 
-	switch (entry->type) {
+	switch (entry->def.type) {
 	case NETLBL_NLTYPE_UNLABELED:
-		if (entry->type_def.cipsov4 != NULL ||
-		    entry->type_def.addrsel != NULL)
+		if (entry->def.cipso != NULL || entry->def.addrsel != NULL)
 			return -EINVAL;
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
-		if (entry->type_def.cipsov4 == NULL)
+		if (entry->def.cipso == NULL)
 			return -EINVAL;
 		break;
 	case NETLBL_NLTYPE_ADDRSELECT:
-		netlbl_af4list_foreach(iter4, &entry->type_def.addrsel->list4) {
+		netlbl_af4list_foreach(iter4, &entry->def.addrsel->list4) {
 			map4 = netlbl_domhsh_addr4_entry(iter4);
-			switch (map4->type) {
+			switch (map4->def.type) {
 			case NETLBL_NLTYPE_UNLABELED:
-				if (map4->type_def.cipsov4 != NULL)
+				if (map4->def.cipso != NULL)
 					return -EINVAL;
 				break;
 			case NETLBL_NLTYPE_CIPSOV4:
-				if (map4->type_def.cipsov4 == NULL)
+				if (map4->def.cipso == NULL)
 					return -EINVAL;
 				break;
 			default:
@@ -292,9 +291,9 @@ static int netlbl_domhsh_validate(const struct netlbl_dom_map *entry)
 			}
 		}
 #if IS_ENABLED(CONFIG_IPV6)
-		netlbl_af6list_foreach(iter6, &entry->type_def.addrsel->list6) {
+		netlbl_af6list_foreach(iter6, &entry->def.addrsel->list6) {
 			map6 = netlbl_domhsh_addr6_entry(iter6);
-			switch (map6->type) {
+			switch (map6->def.type) {
 			case NETLBL_NLTYPE_UNLABELED:
 				break;
 			default:
@@ -402,32 +401,31 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 			rcu_assign_pointer(netlbl_domhsh_def, entry);
 		}
 
-		if (entry->type == NETLBL_NLTYPE_ADDRSELECT) {
+		if (entry->def.type == NETLBL_NLTYPE_ADDRSELECT) {
 			netlbl_af4list_foreach_rcu(iter4,
-					       &entry->type_def.addrsel->list4)
+						   &entry->def.addrsel->list4)
 				netlbl_domhsh_audit_add(entry, iter4, NULL,
 							ret_val, audit_info);
 #if IS_ENABLED(CONFIG_IPV6)
 			netlbl_af6list_foreach_rcu(iter6,
-					       &entry->type_def.addrsel->list6)
+						   &entry->def.addrsel->list6)
 				netlbl_domhsh_audit_add(entry, NULL, iter6,
 							ret_val, audit_info);
 #endif /* IPv6 */
 		} else
 			netlbl_domhsh_audit_add(entry, NULL, NULL,
 						ret_val, audit_info);
-	} else if (entry_old->type == NETLBL_NLTYPE_ADDRSELECT &&
-		   entry->type == NETLBL_NLTYPE_ADDRSELECT) {
+	} else if (entry_old->def.type == NETLBL_NLTYPE_ADDRSELECT &&
+		   entry->def.type == NETLBL_NLTYPE_ADDRSELECT) {
 		struct list_head *old_list4;
 		struct list_head *old_list6;
 
-		old_list4 = &entry_old->type_def.addrsel->list4;
-		old_list6 = &entry_old->type_def.addrsel->list6;
+		old_list4 = &entry_old->def.addrsel->list4;
+		old_list6 = &entry_old->def.addrsel->list6;
 
 		/* we only allow the addition of address selectors if all of
 		 * the selectors do not exist in the existing domain map */
-		netlbl_af4list_foreach_rcu(iter4,
-					   &entry->type_def.addrsel->list4)
+		netlbl_af4list_foreach_rcu(iter4, &entry->def.addrsel->list4)
 			if (netlbl_af4list_search_exact(iter4->addr,
 							iter4->mask,
 							old_list4)) {
@@ -435,8 +433,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 				goto add_return;
 			}
 #if IS_ENABLED(CONFIG_IPV6)
-		netlbl_af6list_foreach_rcu(iter6,
-					   &entry->type_def.addrsel->list6)
+		netlbl_af6list_foreach_rcu(iter6, &entry->def.addrsel->list6)
 			if (netlbl_af6list_search_exact(&iter6->addr,
 							&iter6->mask,
 							old_list6)) {
@@ -446,7 +443,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 #endif /* IPv6 */
 
 		netlbl_af4list_foreach_safe(iter4, tmp4,
-					    &entry->type_def.addrsel->list4) {
+					    &entry->def.addrsel->list4) {
 			netlbl_af4list_remove_entry(iter4);
 			iter4->valid = 1;
 			ret_val = netlbl_af4list_add(iter4, old_list4);
@@ -457,7 +454,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		netlbl_af6list_foreach_safe(iter6, tmp6,
-					    &entry->type_def.addrsel->list6) {
+					    &entry->def.addrsel->list6) {
 			netlbl_af6list_remove_entry(iter6);
 			iter6->valid = 1;
 			ret_val = netlbl_af6list_add(iter6, old_list6);
@@ -538,18 +535,18 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 		struct netlbl_af4list *iter4;
 		struct netlbl_domaddr4_map *map4;
 
-		switch (entry->type) {
+		switch (entry->def.type) {
 		case NETLBL_NLTYPE_ADDRSELECT:
 			netlbl_af4list_foreach_rcu(iter4,
-					     &entry->type_def.addrsel->list4) {
+					     &entry->def.addrsel->list4) {
 				map4 = netlbl_domhsh_addr4_entry(iter4);
-				cipso_v4_doi_putdef(map4->type_def.cipsov4);
+				cipso_v4_doi_putdef(map4->def.cipso);
 			}
 			/* no need to check the IPv6 list since we currently
 			 * support only unlabeled protocols for IPv6 */
 			break;
 		case NETLBL_NLTYPE_CIPSOV4:
-			cipso_v4_doi_putdef(entry->type_def.cipsov4);
+			cipso_v4_doi_putdef(entry->def.cipso);
 			break;
 		}
 		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
@@ -590,20 +587,21 @@ int netlbl_domhsh_remove_af4(const char *domain,
 		entry_map = netlbl_domhsh_search(domain);
 	else
 		entry_map = netlbl_domhsh_search_def(domain);
-	if (entry_map == NULL || entry_map->type != NETLBL_NLTYPE_ADDRSELECT)
+	if (entry_map == NULL ||
+	    entry_map->def.type != NETLBL_NLTYPE_ADDRSELECT)
 		goto remove_af4_failure;
 
 	spin_lock(&netlbl_domhsh_lock);
 	entry_addr = netlbl_af4list_remove(addr->s_addr, mask->s_addr,
-					   &entry_map->type_def.addrsel->list4);
+					   &entry_map->def.addrsel->list4);
 	spin_unlock(&netlbl_domhsh_lock);
 
 	if (entry_addr == NULL)
 		goto remove_af4_failure;
-	netlbl_af4list_foreach_rcu(iter4, &entry_map->type_def.addrsel->list4)
+	netlbl_af4list_foreach_rcu(iter4, &entry_map->def.addrsel->list4)
 		goto remove_af4_single_addr;
 #if IS_ENABLED(CONFIG_IPV6)
-	netlbl_af6list_foreach_rcu(iter6, &entry_map->type_def.addrsel->list6)
+	netlbl_af6list_foreach_rcu(iter6, &entry_map->def.addrsel->list6)
 		goto remove_af4_single_addr;
 #endif /* IPv6 */
 	/* the domain mapping is empty so remove it from the mapping table */
@@ -616,7 +614,7 @@ remove_af4_single_addr:
 	 * shouldn't be a problem */
 	synchronize_rcu();
 	entry = netlbl_domhsh_addr4_entry(entry_addr);
-	cipso_v4_doi_putdef(entry->type_def.cipsov4);
+	cipso_v4_doi_putdef(entry->def.cipso);
 	kfree(entry);
 	return 0;
 
@@ -693,8 +691,8 @@ struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain)
  * responsible for ensuring that rcu_read_[un]lock() is called.
  *
  */
-struct netlbl_domaddr4_map *netlbl_domhsh_getentry_af4(const char *domain,
-						       __be32 addr)
+struct netlbl_dommap_def *netlbl_domhsh_getentry_af4(const char *domain,
+						     __be32 addr)
 {
 	struct netlbl_dom_map *dom_iter;
 	struct netlbl_af4list *addr_iter;
@@ -702,15 +700,13 @@ struct netlbl_domaddr4_map *netlbl_domhsh_getentry_af4(const char *domain,
 	dom_iter = netlbl_domhsh_search_def(domain);
 	if (dom_iter == NULL)
 		return NULL;
-	if (dom_iter->type != NETLBL_NLTYPE_ADDRSELECT)
-		return NULL;
 
-	addr_iter = netlbl_af4list_search(addr,
-					  &dom_iter->type_def.addrsel->list4);
+	if (dom_iter->def.type != NETLBL_NLTYPE_ADDRSELECT)
+		return &dom_iter->def;
+	addr_iter = netlbl_af4list_search(addr, &dom_iter->def.addrsel->list4);
 	if (addr_iter == NULL)
 		return NULL;
-
-	return netlbl_domhsh_addr4_entry(addr_iter);
+	return &(netlbl_domhsh_addr4_entry(addr_iter)->def);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -725,7 +721,7 @@ struct netlbl_domaddr4_map *netlbl_domhsh_getentry_af4(const char *domain,
  * responsible for ensuring that rcu_read_[un]lock() is called.
  *
  */
-struct netlbl_domaddr6_map *netlbl_domhsh_getentry_af6(const char *domain,
+struct netlbl_dommap_def *netlbl_domhsh_getentry_af6(const char *domain,
 						   const struct in6_addr *addr)
 {
 	struct netlbl_dom_map *dom_iter;
@@ -734,15 +730,13 @@ struct netlbl_domaddr6_map *netlbl_domhsh_getentry_af6(const char *domain,
 	dom_iter = netlbl_domhsh_search_def(domain);
 	if (dom_iter == NULL)
 		return NULL;
-	if (dom_iter->type != NETLBL_NLTYPE_ADDRSELECT)
-		return NULL;
 
-	addr_iter = netlbl_af6list_search(addr,
-					  &dom_iter->type_def.addrsel->list6);
+	if (dom_iter->def.type != NETLBL_NLTYPE_ADDRSELECT)
+		return &dom_iter->def;
+	addr_iter = netlbl_af6list_search(addr, &dom_iter->def.addrsel->list6);
 	if (addr_iter == NULL)
 		return NULL;
-
-	return netlbl_domhsh_addr6_entry(addr_iter);
+	return &(netlbl_domhsh_addr6_entry(addr_iter)->def);
 }
 #endif /* IPv6 */
 
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index 90872c4..b9be0ee 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -43,37 +43,35 @@
 #define NETLBL_DOMHSH_BITSIZE       7
 
 /* Domain mapping definition structures */
+struct netlbl_domaddr_map {
+	struct list_head list4;
+	struct list_head list6;
+};
+struct netlbl_dommap_def {
+	u32 type;
+	union {
+		struct netlbl_domaddr_map *addrsel;
+		struct cipso_v4_doi *cipso;
+	};
+};
 #define netlbl_domhsh_addr4_entry(iter) \
 	container_of(iter, struct netlbl_domaddr4_map, list)
 struct netlbl_domaddr4_map {
-	u32 type;
-	union {
-		struct cipso_v4_doi *cipsov4;
-	} type_def;
+	struct netlbl_dommap_def def;
 
 	struct netlbl_af4list list;
 };
 #define netlbl_domhsh_addr6_entry(iter) \
 	container_of(iter, struct netlbl_domaddr6_map, list)
 struct netlbl_domaddr6_map {
-	u32 type;
-
-	/* NOTE: no 'type_def' union needed at present since we don't currently
-	 *       support any IPv6 labeling protocols */
+	struct netlbl_dommap_def def;
 
 	struct netlbl_af6list list;
 };
-struct netlbl_domaddr_map {
-	struct list_head list4;
-	struct list_head list6;
-};
+
 struct netlbl_dom_map {
 	char *domain;
-	u32 type;
-	union {
-		struct cipso_v4_doi *cipsov4;
-		struct netlbl_domaddr_map *addrsel;
-	} type_def;
+	struct netlbl_dommap_def def;
 
 	u32 valid;
 	struct list_head list;
@@ -97,16 +95,16 @@ int netlbl_domhsh_remove_af4(const char *domain,
 int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info);
 int netlbl_domhsh_remove_default(struct netlbl_audit *audit_info);
 struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
-struct netlbl_domaddr4_map *netlbl_domhsh_getentry_af4(const char *domain,
-						       __be32 addr);
+struct netlbl_dommap_def *netlbl_domhsh_getentry_af4(const char *domain,
+						     __be32 addr);
+#if IS_ENABLED(CONFIG_IPV6)
+struct netlbl_dommap_def *netlbl_domhsh_getentry_af6(const char *domain,
+						   const struct in6_addr *addr);
+#endif /* IPv6 */
+
 int netlbl_domhsh_walk(u32 *skip_bkt,
 		     u32 *skip_chain,
 		     int (*callback) (struct netlbl_dom_map *entry, void *arg),
 		     void *cb_arg);
 
-#if IS_ENABLED(CONFIG_IPV6)
-struct netlbl_domaddr6_map *netlbl_domhsh_getentry_af6(const char *domain,
-						  const struct in6_addr *addr);
-#endif /* IPv6 */
-
 #endif
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 7c94aed..96a458e 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -122,7 +122,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 	}
 
 	if (addr == NULL && mask == NULL)
-		entry->type = NETLBL_NLTYPE_UNLABELED;
+		entry->def.type = NETLBL_NLTYPE_UNLABELED;
 	else if (addr != NULL && mask != NULL) {
 		addrmap = kzalloc(sizeof(*addrmap), GFP_ATOMIC);
 		if (addrmap == NULL)
@@ -137,7 +137,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			map4 = kzalloc(sizeof(*map4), GFP_ATOMIC);
 			if (map4 == NULL)
 				goto cfg_unlbl_map_add_failure;
-			map4->type = NETLBL_NLTYPE_UNLABELED;
+			map4->def.type = NETLBL_NLTYPE_UNLABELED;
 			map4->list.addr = addr4->s_addr & mask4->s_addr;
 			map4->list.mask = mask4->s_addr;
 			map4->list.valid = 1;
@@ -154,7 +154,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			map6 = kzalloc(sizeof(*map6), GFP_ATOMIC);
 			if (map6 == NULL)
 				goto cfg_unlbl_map_add_failure;
-			map6->type = NETLBL_NLTYPE_UNLABELED;
+			map6->def.type = NETLBL_NLTYPE_UNLABELED;
 			map6->list.addr = *addr6;
 			map6->list.addr.s6_addr32[0] &= mask6->s6_addr32[0];
 			map6->list.addr.s6_addr32[1] &= mask6->s6_addr32[1];
@@ -174,8 +174,8 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			break;
 		}
 
-		entry->type_def.addrsel = addrmap;
-		entry->type = NETLBL_NLTYPE_ADDRSELECT;
+		entry->def.addrsel = addrmap;
+		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
 	} else {
 		ret_val = -EINVAL;
 		goto cfg_unlbl_map_add_failure;
@@ -355,8 +355,8 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
 	}
 
 	if (addr == NULL && mask == NULL) {
-		entry->type_def.cipsov4 = doi_def;
-		entry->type = NETLBL_NLTYPE_CIPSOV4;
+		entry->def.cipso = doi_def;
+		entry->def.type = NETLBL_NLTYPE_CIPSOV4;
 	} else if (addr != NULL && mask != NULL) {
 		addrmap = kzalloc(sizeof(*addrmap), GFP_ATOMIC);
 		if (addrmap == NULL)
@@ -367,8 +367,8 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
 		addrinfo = kzalloc(sizeof(*addrinfo), GFP_ATOMIC);
 		if (addrinfo == NULL)
 			goto out_addrinfo;
-		addrinfo->type_def.cipsov4 = doi_def;
-		addrinfo->type = NETLBL_NLTYPE_CIPSOV4;
+		addrinfo->def.cipso = doi_def;
+		addrinfo->def.type = NETLBL_NLTYPE_CIPSOV4;
 		addrinfo->list.addr = addr->s_addr & mask->s_addr;
 		addrinfo->list.mask = mask->s_addr;
 		addrinfo->list.valid = 1;
@@ -376,8 +376,8 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
 		if (ret_val != 0)
 			goto cfg_cipsov4_map_add_failure;
 
-		entry->type_def.addrsel = addrmap;
-		entry->type = NETLBL_NLTYPE_ADDRSELECT;
+		entry->def.addrsel = addrmap;
+		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
 	} else {
 		ret_val = -EINVAL;
 		goto out_addrmap;
@@ -657,14 +657,14 @@ int netlbl_sock_setattr(struct sock *sk,
 	}
 	switch (family) {
 	case AF_INET:
-		switch (dom_entry->type) {
+		switch (dom_entry->def.type) {
 		case NETLBL_NLTYPE_ADDRSELECT:
 			ret_val = -EDESTADDRREQ;
 			break;
 		case NETLBL_NLTYPE_CIPSOV4:
 			ret_val = cipso_v4_sock_setattr(sk,
-						    dom_entry->type_def.cipsov4,
-						    secattr);
+							dom_entry->def.cipso,
+							secattr);
 			break;
 		case NETLBL_NLTYPE_UNLABELED:
 			ret_val = 0;
@@ -754,23 +754,22 @@ int netlbl_conn_setattr(struct sock *sk,
 {
 	int ret_val;
 	struct sockaddr_in *addr4;
-	struct netlbl_domaddr4_map *af4_entry;
+	struct netlbl_dommap_def *entry;
 
 	rcu_read_lock();
 	switch (addr->sa_family) {
 	case AF_INET:
 		addr4 = (struct sockaddr_in *)addr;
-		af4_entry = netlbl_domhsh_getentry_af4(secattr->domain,
-						       addr4->sin_addr.s_addr);
-		if (af4_entry == NULL) {
+		entry = netlbl_domhsh_getentry_af4(secattr->domain,
+						   addr4->sin_addr.s_addr);
+		if (entry == NULL) {
 			ret_val = -ENOENT;
 			goto conn_setattr_return;
 		}
-		switch (af4_entry->type) {
+		switch (entry->type) {
 		case NETLBL_NLTYPE_CIPSOV4:
 			ret_val = cipso_v4_sock_setattr(sk,
-						   af4_entry->type_def.cipsov4,
-						   secattr);
+							entry->cipso, secattr);
 			break;
 		case NETLBL_NLTYPE_UNLABELED:
 			/* just delete the protocols we support for right now
@@ -812,36 +811,21 @@ int netlbl_req_setattr(struct request_sock *req,
 		       const struct netlbl_lsm_secattr *secattr)
 {
 	int ret_val;
-	struct netlbl_dom_map *dom_entry;
-	struct netlbl_domaddr4_map *af4_entry;
-	u32 proto_type;
-	struct cipso_v4_doi *proto_cv4;
+	struct netlbl_dommap_def *entry;
 
 	rcu_read_lock();
-	dom_entry = netlbl_domhsh_getentry(secattr->domain);
-	if (dom_entry == NULL) {
-		ret_val = -ENOENT;
-		goto req_setattr_return;
-	}
 	switch (req->rsk_ops->family) {
 	case AF_INET:
-		if (dom_entry->type == NETLBL_NLTYPE_ADDRSELECT) {
-			struct inet_request_sock *req_inet = inet_rsk(req);
-			af4_entry = netlbl_domhsh_getentry_af4(secattr->domain,
-							    req_inet->rmt_addr);
-			if (af4_entry == NULL) {
-				ret_val = -ENOENT;
-				goto req_setattr_return;
-			}
-			proto_type = af4_entry->type;
-			proto_cv4 = af4_entry->type_def.cipsov4;
-		} else {
-			proto_type = dom_entry->type;
-			proto_cv4 = dom_entry->type_def.cipsov4;
+		entry = netlbl_domhsh_getentry_af4(secattr->domain,
+						   inet_rsk(req)->rmt_addr);
+		if (entry == NULL) {
+			ret_val = -ENOENT;
+			goto req_setattr_return;
 		}
-		switch (proto_type) {
+		switch (entry->type) {
 		case NETLBL_NLTYPE_CIPSOV4:
-			ret_val = cipso_v4_req_setattr(req, proto_cv4, secattr);
+			ret_val = cipso_v4_req_setattr(req,
+						       entry->cipso, secattr);
 			break;
 		case NETLBL_NLTYPE_UNLABELED:
 			/* just delete the protocols we support for right now
@@ -899,23 +883,21 @@ int netlbl_skbuff_setattr(struct sk_buff *skb,
 {
 	int ret_val;
 	struct iphdr *hdr4;
-	struct netlbl_domaddr4_map *af4_entry;
+	struct netlbl_dommap_def *entry;
 
 	rcu_read_lock();
 	switch (family) {
 	case AF_INET:
 		hdr4 = ip_hdr(skb);
-		af4_entry = netlbl_domhsh_getentry_af4(secattr->domain,
-						       hdr4->daddr);
-		if (af4_entry == NULL) {
+		entry = netlbl_domhsh_getentry_af4(secattr->domain,hdr4->daddr);
+		if (entry == NULL) {
 			ret_val = -ENOENT;
 			goto skbuff_setattr_return;
 		}
-		switch (af4_entry->type) {
+		switch (entry->type) {
 		case NETLBL_NLTYPE_CIPSOV4:
-			ret_val = cipso_v4_skbuff_setattr(skb,
-						   af4_entry->type_def.cipsov4,
-						   secattr);
+			ret_val = cipso_v4_skbuff_setattr(skb, entry->cipso,
+							  secattr);
 			break;
 		case NETLBL_NLTYPE_UNLABELED:
 			/* just delete the protocols we support for right now
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index c5384ff..dd1c37d 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -104,7 +104,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		ret_val = -ENOMEM;
 		goto add_failure;
 	}
-	entry->type = nla_get_u32(info->attrs[NLBL_MGMT_A_PROTOCOL]);
+	entry->def.type = nla_get_u32(info->attrs[NLBL_MGMT_A_PROTOCOL]);
 	if (info->attrs[NLBL_MGMT_A_DOMAIN]) {
 		size_t tmp_size = nla_len(info->attrs[NLBL_MGMT_A_DOMAIN]);
 		entry->domain = kmalloc(tmp_size, GFP_KERNEL);
@@ -116,12 +116,12 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 			    info->attrs[NLBL_MGMT_A_DOMAIN], tmp_size);
 	}
 
-	/* NOTE: internally we allow/use a entry->type value of
+	/* NOTE: internally we allow/use a entry->def.type value of
 	 *       NETLBL_NLTYPE_ADDRSELECT but we don't currently allow users
 	 *       to pass that as a protocol value because we need to know the
 	 *       "real" protocol */
 
-	switch (entry->type) {
+	switch (entry->def.type) {
 	case NETLBL_NLTYPE_UNLABELED:
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
@@ -132,7 +132,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		cipsov4 = cipso_v4_doi_getdef(tmp_val);
 		if (cipsov4 == NULL)
 			goto add_failure;
-		entry->type_def.cipsov4 = cipsov4;
+		entry->def.cipso = cipsov4;
 		break;
 	default:
 		goto add_failure;
@@ -172,9 +172,9 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		map->list.addr = addr->s_addr & mask->s_addr;
 		map->list.mask = mask->s_addr;
 		map->list.valid = 1;
-		map->type = entry->type;
+		map->def.type = entry->def.type;
 		if (cipsov4)
-			map->type_def.cipsov4 = cipsov4;
+			map->def.cipso = cipsov4;
 
 		ret_val = netlbl_af4list_add(&map->list, &addrmap->list4);
 		if (ret_val != 0) {
@@ -182,8 +182,8 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 			goto add_failure;
 		}
 
-		entry->type = NETLBL_NLTYPE_ADDRSELECT;
-		entry->type_def.addrsel = addrmap;
+		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
+		entry->def.addrsel = addrmap;
 #if IS_ENABLED(CONFIG_IPV6)
 	} else if (info->attrs[NLBL_MGMT_A_IPV6ADDR]) {
 		struct in6_addr *addr;
@@ -223,7 +223,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		map->list.addr.s6_addr32[3] &= mask->s6_addr32[3];
 		map->list.mask = *mask;
 		map->list.valid = 1;
-		map->type = entry->type;
+		map->def.type = entry->def.type;
 
 		ret_val = netlbl_af6list_add(&map->list, &addrmap->list6);
 		if (ret_val != 0) {
@@ -231,8 +231,8 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 			goto add_failure;
 		}
 
-		entry->type = NETLBL_NLTYPE_ADDRSELECT;
-		entry->type_def.addrsel = addrmap;
+		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
+		entry->def.addrsel = addrmap;
 #endif /* IPv6 */
 	}
 
@@ -281,14 +281,13 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 			return ret_val;
 	}
 
-	switch (entry->type) {
+	switch (entry->def.type) {
 	case NETLBL_NLTYPE_ADDRSELECT:
 		nla_a = nla_nest_start(skb, NLBL_MGMT_A_SELECTORLIST);
 		if (nla_a == NULL)
 			return -ENOMEM;
 
-		netlbl_af4list_foreach_rcu(iter4,
-					   &entry->type_def.addrsel->list4) {
+		netlbl_af4list_foreach_rcu(iter4, &entry->def.addrsel->list4) {
 			struct netlbl_domaddr4_map *map4;
 			struct in_addr addr_struct;
 
@@ -310,13 +309,13 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 				return ret_val;
 			map4 = netlbl_domhsh_addr4_entry(iter4);
 			ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL,
-					      map4->type);
+					      map4->def.type);
 			if (ret_val != 0)
 				return ret_val;
-			switch (map4->type) {
+			switch (map4->def.type) {
 			case NETLBL_NLTYPE_CIPSOV4:
 				ret_val = nla_put_u32(skb, NLBL_MGMT_A_CV4DOI,
-						  map4->type_def.cipsov4->doi);
+						      map4->def.cipso->doi);
 				if (ret_val != 0)
 					return ret_val;
 				break;
@@ -325,8 +324,7 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 			nla_nest_end(skb, nla_b);
 		}
 #if IS_ENABLED(CONFIG_IPV6)
-		netlbl_af6list_foreach_rcu(iter6,
-					   &entry->type_def.addrsel->list6) {
+		netlbl_af6list_foreach_rcu(iter6, &entry->def.addrsel->list6) {
 			struct netlbl_domaddr6_map *map6;
 
 			nla_b = nla_nest_start(skb, NLBL_MGMT_A_ADDRSELECTOR);
@@ -345,7 +343,7 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 				return ret_val;
 			map6 = netlbl_domhsh_addr6_entry(iter6);
 			ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL,
-					      map6->type);
+					      map6->def.type);
 			if (ret_val != 0)
 				return ret_val;
 
@@ -356,14 +354,14 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 		nla_nest_end(skb, nla_a);
 		break;
 	case NETLBL_NLTYPE_UNLABELED:
-		ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL, entry->type);
+		ret_val = nla_put_u32(skb,NLBL_MGMT_A_PROTOCOL,entry->def.type);
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL, entry->type);
+		ret_val = nla_put_u32(skb,NLBL_MGMT_A_PROTOCOL,entry->def.type);
 		if (ret_val != 0)
 			return ret_val;
 		ret_val = nla_put_u32(skb, NLBL_MGMT_A_CV4DOI,
-				      entry->type_def.cipsov4->doi);
+				      entry->def.cipso->doi);
 		break;
 	}
 
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index af35319..8f08974 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1541,7 +1541,7 @@ int __init netlbl_unlabel_defconf(void)
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (entry == NULL)
 		return -ENOMEM;
-	entry->type = NETLBL_NLTYPE_UNLABELED;
+	entry->def.type = NETLBL_NLTYPE_UNLABELED;
 	ret_val = netlbl_domhsh_add_default(entry, &audit_info);
 	if (ret_val != 0)
 		return ret_val;

