From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 06/19] netlabel: Add support for creating a CALIPSO protocol domain mapping.
Date: Mon, 20 Jun 2016 14:36:46 +0100
Message-ID: <1466429819-12707-7-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:49031 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749AbcFTNyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 09:54:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends the NLBL_MGMT_C_ADD and NLBL_MGMT_C_ADDDEF commands
to accept CALIPSO protocol DOIs.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 net/netlabel/netlabel_domainhash.c | 43 +++++++++++++++++++++++++++++++---
 net/netlabel/netlabel_domainhash.h |  1 +
 net/netlabel/netlabel_mgmt.c       | 47 ++++++++++++++++++++++++++++++++++++--
 net/netlabel/netlabel_mgmt.h       |  3 +++
 4 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 3b3b304..f1dee0d 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -37,10 +37,12 @@
 #include <linux/slab.h>
 #include <net/netlabel.h>
 #include <net/cipso_ipv4.h>
+#include <net/calipso.h>
 #include <asm/bug.h>
 
 #include "netlabel_mgmt.h"
 #include "netlabel_addrlist.h"
+#include "netlabel_calipso.h"
 #include "netlabel_domainhash.h"
 #include "netlabel_user.h"
 
@@ -223,6 +225,7 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
 {
 	struct audit_buffer *audit_buf;
 	struct cipso_v4_doi *cipsov4 = NULL;
+	struct calipso_doi *calipso = NULL;
 	u32 type;
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD, audit_info);
@@ -241,12 +244,14 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
 			struct netlbl_domaddr6_map *map6;
 			map6 = netlbl_domhsh_addr6_entry(addr6);
 			type = map6->def.type;
+			calipso = map6->def.calipso;
 			netlbl_af6list_audit_addr(audit_buf, 0, NULL,
 						  &addr6->addr, &addr6->mask);
 #endif /* IPv6 */
 		} else {
 			type = entry->def.type;
 			cipsov4 = entry->def.cipso;
+			calipso = entry->def.calipso;
 		}
 		switch (type) {
 		case NETLBL_NLTYPE_UNLABELED:
@@ -258,6 +263,12 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
 					 " nlbl_protocol=cipsov4 cipso_doi=%u",
 					 cipsov4->doi);
 			break;
+		case NETLBL_NLTYPE_CALIPSO:
+			BUG_ON(calipso == NULL);
+			audit_log_format(audit_buf,
+					 " nlbl_protocol=calipso calipso_doi=%u",
+					 calipso->doi);
+			break;
 		}
 		audit_log_format(audit_buf, " res=%u", result == 0 ? 1 : 0);
 		audit_log_end(audit_buf);
@@ -291,7 +302,8 @@ static int netlbl_domhsh_validate(const struct netlbl_dom_map *entry)
 
 	switch (entry->def.type) {
 	case NETLBL_NLTYPE_UNLABELED:
-		if (entry->def.cipso != NULL || entry->def.addrsel != NULL)
+		if (entry->def.cipso != NULL || entry->def.calipso != NULL ||
+		    entry->def.addrsel != NULL)
 			return -EINVAL;
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
@@ -299,6 +311,11 @@ static int netlbl_domhsh_validate(const struct netlbl_dom_map *entry)
 		    entry->def.cipso == NULL)
 			return -EINVAL;
 		break;
+	case NETLBL_NLTYPE_CALIPSO:
+		if (entry->family != AF_INET6 ||
+		    entry->def.calipso == NULL)
+			return -EINVAL;
+		break;
 	case NETLBL_NLTYPE_ADDRSELECT:
 		netlbl_af4list_foreach(iter4, &entry->def.addrsel->list4) {
 			map4 = netlbl_domhsh_addr4_entry(iter4);
@@ -320,6 +337,12 @@ static int netlbl_domhsh_validate(const struct netlbl_dom_map *entry)
 			map6 = netlbl_domhsh_addr6_entry(iter6);
 			switch (map6->def.type) {
 			case NETLBL_NLTYPE_UNLABELED:
+				if (map6->def.calipso != NULL)
+					return -EINVAL;
+				break;
+			case NETLBL_NLTYPE_CALIPSO:
+				if (map6->def.calipso == NULL)
+					return -EINVAL;
 				break;
 			default:
 				return -EINVAL;
@@ -599,6 +622,10 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 	if (ret_val == 0) {
 		struct netlbl_af4list *iter4;
 		struct netlbl_domaddr4_map *map4;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct netlbl_af6list *iter6;
+		struct netlbl_domaddr6_map *map6;
+#endif /* IPv6 */
 
 		switch (entry->def.type) {
 		case NETLBL_NLTYPE_ADDRSELECT:
@@ -607,12 +634,22 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 				map4 = netlbl_domhsh_addr4_entry(iter4);
 				cipso_v4_doi_putdef(map4->def.cipso);
 			}
-			/* no need to check the IPv6 list since we currently
-			 * support only unlabeled protocols for IPv6 */
+#if IS_ENABLED(CONFIG_IPV6)
+			netlbl_af6list_foreach_rcu(iter6,
+					     &entry->def.addrsel->list6) {
+				map6 = netlbl_domhsh_addr6_entry(iter6);
+				calipso_doi_putdef(map6->def.calipso);
+			}
+#endif /* IPv6 */
 			break;
 		case NETLBL_NLTYPE_CIPSOV4:
 			cipso_v4_doi_putdef(entry->def.cipso);
 			break;
+#if IS_ENABLED(CONFIG_IPV6)
+		case NETLBL_NLTYPE_CALIPSO:
+			calipso_doi_putdef(entry->def.calipso);
+			break;
+#endif /* IPv6 */
 		}
 		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
 	}
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index 56e45ae..b7ddb6e 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -51,6 +51,7 @@ struct netlbl_dommap_def {
 	union {
 		struct netlbl_domaddr_map *addrsel;
 		struct cipso_v4_doi *cipso;
+		struct calipso_doi *calipso;
 	};
 };
 #define netlbl_domhsh_addr4_entry(iter) \
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 975b1e9..f85d0e0 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -41,8 +41,10 @@
 #include <net/ipv6.h>
 #include <net/netlabel.h>
 #include <net/cipso_ipv4.h>
+#include <net/calipso.h>
 #include <linux/atomic.h>
 
+#include "netlabel_calipso.h"
 #include "netlabel_domainhash.h"
 #include "netlabel_user.h"
 #include "netlabel_mgmt.h"
@@ -73,6 +75,7 @@ static const struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
 	[NLBL_MGMT_A_VERSION] = { .type = NLA_U32 },
 	[NLBL_MGMT_A_CV4DOI] = { .type = NLA_U32 },
 	[NLBL_MGMT_A_FAMILY] = { .type = NLA_U16 },
+	[NLBL_MGMT_A_CLPDOI] = { .type = NLA_U32 },
 };
 
 /*
@@ -96,6 +99,9 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 	int ret_val = -EINVAL;
 	struct netlbl_domaddr_map *addrmap = NULL;
 	struct cipso_v4_doi *cipsov4 = NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct calipso_doi *calipso = NULL;
+#endif
 	u32 tmp_val;
 	struct netlbl_dom_map *entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 
@@ -137,6 +143,19 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		entry->family = AF_INET;
 		entry->def.cipso = cipsov4;
 		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case NETLBL_NLTYPE_CALIPSO:
+		if (!info->attrs[NLBL_MGMT_A_CLPDOI])
+			goto add_free_domain;
+
+		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CLPDOI]);
+		calipso = calipso_doi_getdef(tmp_val);
+		if (calipso == NULL)
+			goto add_free_domain;
+		entry->family = AF_INET6;
+		entry->def.calipso = calipso;
+		break;
+#endif /* IPv6 */
 	default:
 		goto add_free_domain;
 	}
@@ -232,6 +251,8 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		map->list.mask = *mask;
 		map->list.valid = 1;
 		map->def.type = entry->def.type;
+		if (calipso)
+			map->def.calipso = calipso;
 
 		ret_val = netlbl_af6list_add(&map->list, &addrmap->list6);
 		if (ret_val != 0) {
@@ -255,6 +276,9 @@ add_free_addrmap:
 	kfree(addrmap);
 add_doi_put_def:
 	cipso_v4_doi_putdef(cipsov4);
+#if IS_ENABLED(CONFIG_IPV6)
+	calipso_doi_putdef(calipso);
+#endif
 add_free_domain:
 	kfree(entry->domain);
 add_free_entry:
@@ -357,6 +381,15 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 			if (ret_val != 0)
 				return ret_val;
 
+			switch (map6->def.type) {
+			case NETLBL_NLTYPE_CALIPSO:
+				ret_val = nla_put_u32(skb, NLBL_MGMT_A_CLPDOI,
+						      map6->def.calipso->doi);
+				if (ret_val != 0)
+					return ret_val;
+				break;
+			}
+
 			nla_nest_end(skb, nla_b);
 		}
 #endif /* IPv6 */
@@ -364,15 +397,25 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 		nla_nest_end(skb, nla_a);
 		break;
 	case NETLBL_NLTYPE_UNLABELED:
-		ret_val = nla_put_u32(skb,NLBL_MGMT_A_PROTOCOL,entry->def.type);
+		ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL,
+				      entry->def.type);
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = nla_put_u32(skb,NLBL_MGMT_A_PROTOCOL,entry->def.type);
+		ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL,
+				      entry->def.type);
 		if (ret_val != 0)
 			return ret_val;
 		ret_val = nla_put_u32(skb, NLBL_MGMT_A_CV4DOI,
 				      entry->def.cipso->doi);
 		break;
+	case NETLBL_NLTYPE_CALIPSO:
+		ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL,
+				      entry->def.type);
+		if (ret_val != 0)
+			return ret_val;
+		ret_val = nla_put_u32(skb, NLBL_MGMT_A_CLPDOI,
+				      entry->def.calipso->doi);
+		break;
 	}
 
 	return ret_val;
diff --git a/net/netlabel/netlabel_mgmt.h b/net/netlabel/netlabel_mgmt.h
index f368dc0..ea01e42 100644
--- a/net/netlabel/netlabel_mgmt.h
+++ b/net/netlabel/netlabel_mgmt.h
@@ -223,6 +223,9 @@ enum {
 	NLBL_MGMT_A_FAMILY,
 	/* (NLA_U16)
 	 * The address family */
+	NLBL_MGMT_A_CLPDOI,
+	/* (NLA_U32)
+	 * the CALIPSO DOI value */
 	__NLBL_MGMT_A_MAX,
 };
 #define NLBL_MGMT_A_MAX (__NLBL_MGMT_A_MAX - 1)
-- 
2.7.4
