From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v3 3/3] netlabel: Less function calls in netlbl_mgmt_add_common()
 after error detection
Date: Mon, 02 Feb 2015 12:06:39 +0100
Message-ID: <54CF5A3F.6080600@users.sourceforge.net>
References: <54CD4B5F.9010502@users.sourceforge.net>	<CAHC9VhQ5C32zRqG0emVUoMmuvBsV+TXvdNn+54iVyCPBNk9dDQ@mail.gmail.com>	<54CDFCDA.9010802@users.sourceforge.net> <20150201.123054.366525761630045391.davem@davemloft.net> <54CF4FEC.2010906@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:54327 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933041AbbBBLGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 06:06:48 -0500
In-Reply-To: <54CF4FEC.2010906@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 2 Feb 2015 11:00:24 +0100

The functions "cipso_v4_doi_putdef" and "kfree" could be called in some cases
by the netlbl_mgmt_add_common() function during error handling even if the
passed variables contained still a null pointer.

* This implementation detail could be improved by adjustments for jump labels.

* Let us return immediately after the first failed function call according to
  the current Linux coding style convention.

* Let us delete also an unnecessary check for the variable "entry" there.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Acked-by: Paul Moore <paul@paul-moore.com>
---
 net/netlabel/netlabel_mgmt.c | 49 ++++++++++++++++++++++----------------------
 1 file changed, 24 insertions(+), 25 deletions(-)

diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index f5807f5..7044074 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -93,23 +93,20 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 				  struct netlbl_audit *audit_info)
 {
 	int ret_val = -EINVAL;
-	struct netlbl_dom_map *entry = NULL;
 	struct netlbl_domaddr_map *addrmap = NULL;
 	struct cipso_v4_doi *cipsov4 = NULL;
 	u32 tmp_val;
+	struct netlbl_dom_map *entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 
-	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
-	if (entry == NULL) {
-		ret_val = -ENOMEM;
-		goto add_failure;
-	}
+	if (!entry)
+		return -ENOMEM;
 	entry->def.type = nla_get_u32(info->attrs[NLBL_MGMT_A_PROTOCOL]);
 	if (info->attrs[NLBL_MGMT_A_DOMAIN]) {
 		size_t tmp_size = nla_len(info->attrs[NLBL_MGMT_A_DOMAIN]);
 		entry->domain = kmalloc(tmp_size, GFP_KERNEL);
 		if (entry->domain == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto add_free_entry;
 		}
 		nla_strlcpy(entry->domain,
 			    info->attrs[NLBL_MGMT_A_DOMAIN], tmp_size);
@@ -125,16 +122,16 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
 		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
-			goto add_failure;
+			goto add_free_domain;
 
 		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
 		cipsov4 = cipso_v4_doi_getdef(tmp_val);
 		if (cipsov4 == NULL)
-			goto add_failure;
+			goto add_free_domain;
 		entry->def.cipso = cipsov4;
 		break;
 	default:
-		goto add_failure;
+		goto add_free_domain;
 	}
 
 	if (info->attrs[NLBL_MGMT_A_IPV4ADDR]) {
@@ -145,7 +142,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		addrmap = kzalloc(sizeof(*addrmap), GFP_KERNEL);
 		if (addrmap == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto add_doi_put_def;
 		}
 		INIT_LIST_HEAD(&addrmap->list4);
 		INIT_LIST_HEAD(&addrmap->list6);
@@ -153,12 +150,12 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV4ADDR]) !=
 		    sizeof(struct in_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV4MASK]) !=
 		    sizeof(struct in_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 		addr = nla_data(info->attrs[NLBL_MGMT_A_IPV4ADDR]);
 		mask = nla_data(info->attrs[NLBL_MGMT_A_IPV4MASK]);
@@ -166,7 +163,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		map = kzalloc(sizeof(*map), GFP_KERNEL);
 		if (map == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 		map->list.addr = addr->s_addr & mask->s_addr;
 		map->list.mask = mask->s_addr;
@@ -178,7 +175,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		ret_val = netlbl_af4list_add(&map->list, &addrmap->list4);
 		if (ret_val != 0) {
 			kfree(map);
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 
 		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
@@ -192,7 +189,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		addrmap = kzalloc(sizeof(*addrmap), GFP_KERNEL);
 		if (addrmap == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto add_doi_put_def;
 		}
 		INIT_LIST_HEAD(&addrmap->list4);
 		INIT_LIST_HEAD(&addrmap->list6);
@@ -200,12 +197,12 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV6ADDR]) !=
 		    sizeof(struct in6_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV6MASK]) !=
 		    sizeof(struct in6_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 		addr = nla_data(info->attrs[NLBL_MGMT_A_IPV6ADDR]);
 		mask = nla_data(info->attrs[NLBL_MGMT_A_IPV6MASK]);
@@ -213,7 +210,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		map = kzalloc(sizeof(*map), GFP_KERNEL);
 		if (map == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 		map->list.addr = *addr;
 		map->list.addr.s6_addr32[0] &= mask->s6_addr32[0];
@@ -227,7 +224,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		ret_val = netlbl_af6list_add(&map->list, &addrmap->list6);
 		if (ret_val != 0) {
 			kfree(map);
-			goto add_failure;
+			goto add_free_addrmap;
 		}
 
 		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
@@ -237,15 +234,17 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 
 	ret_val = netlbl_domhsh_add(entry, audit_info);
 	if (ret_val != 0)
-		goto add_failure;
+		goto add_free_addrmap;
 
 	return 0;
 
-add_failure:
-	cipso_v4_doi_putdef(cipsov4);
-	if (entry)
-		kfree(entry->domain);
+add_free_addrmap:
 	kfree(addrmap);
+add_doi_put_def:
+	cipso_v4_doi_putdef(cipsov4);
+add_free_domain:
+	kfree(entry->domain);
+add_free_entry:
 	kfree(entry);
 	return ret_val;
 }
-- 
2.2.2
