From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] netlabel: Less function calls in netlbl_mgmt_add_common()
 after error detection
Date: Sat, 31 Jan 2015 22:38:39 +0100
Message-ID: <54CD4B5F.9010502@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <54CD45B6.6010703@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CD45B6.6010703@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 31 Jan 2015 21:55:48 +0100

The functions "cipso_v4_doi_putdef" and "kfree" could be called in some cases
by the netlbl_mgmt_add_common() function during error handling even if the
passed variables contained still a null pointer.

* This implementation detail could be improved by adjustments for jump labels.

* Let us return immediately after the first failed function call according to
  the current Linux coding style convention.

* Let us delete also an unnecessary check for the variable "entry" there.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/netlabel/netlabel_mgmt.c | 46 ++++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index f5807f5..17f1ed5 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -99,17 +99,15 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 	u32 tmp_val;
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
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
+			goto free_entry;
 		}
 		nla_strlcpy(entry->domain,
 			    info->attrs[NLBL_MGMT_A_DOMAIN], tmp_size);
@@ -125,16 +123,16 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
 		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
-			goto add_failure;
+			goto free_domain;
 
 		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
 		cipsov4 = cipso_v4_doi_getdef(tmp_val);
 		if (cipsov4 == NULL)
-			goto add_failure;
+			goto free_domain;
 		entry->def.cipso = cipsov4;
 		break;
 	default:
-		goto add_failure;
+		goto free_domain;
 	}
 
 	if (info->attrs[NLBL_MGMT_A_IPV4ADDR]) {
@@ -145,7 +143,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		addrmap = kzalloc(sizeof(*addrmap), GFP_KERNEL);
 		if (addrmap == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto doi_put_def;
 		}
 		INIT_LIST_HEAD(&addrmap->list4);
 		INIT_LIST_HEAD(&addrmap->list6);
@@ -153,12 +151,12 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV4ADDR]) !=
 		    sizeof(struct in_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto free_address_map;
 		}
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV4MASK]) !=
 		    sizeof(struct in_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto free_address_map;
 		}
 		addr = nla_data(info->attrs[NLBL_MGMT_A_IPV4ADDR]);
 		mask = nla_data(info->attrs[NLBL_MGMT_A_IPV4MASK]);
@@ -166,7 +164,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		map = kzalloc(sizeof(*map), GFP_KERNEL);
 		if (map == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto free_address_map;
 		}
 		map->list.addr = addr->s_addr & mask->s_addr;
 		map->list.mask = mask->s_addr;
@@ -178,7 +176,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		ret_val = netlbl_af4list_add(&map->list, &addrmap->list4);
 		if (ret_val != 0) {
 			kfree(map);
-			goto add_failure;
+			goto free_address_map;
 		}
 
 		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
@@ -192,7 +190,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		addrmap = kzalloc(sizeof(*addrmap), GFP_KERNEL);
 		if (addrmap == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto doi_put_def;
 		}
 		INIT_LIST_HEAD(&addrmap->list4);
 		INIT_LIST_HEAD(&addrmap->list6);
@@ -200,12 +198,12 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV6ADDR]) !=
 		    sizeof(struct in6_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto free_address_map;
 		}
 		if (nla_len(info->attrs[NLBL_MGMT_A_IPV6MASK]) !=
 		    sizeof(struct in6_addr)) {
 			ret_val = -EINVAL;
-			goto add_failure;
+			goto free_address_map;
 		}
 		addr = nla_data(info->attrs[NLBL_MGMT_A_IPV6ADDR]);
 		mask = nla_data(info->attrs[NLBL_MGMT_A_IPV6MASK]);
@@ -213,7 +211,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		map = kzalloc(sizeof(*map), GFP_KERNEL);
 		if (map == NULL) {
 			ret_val = -ENOMEM;
-			goto add_failure;
+			goto free_address_map;
 		}
 		map->list.addr = *addr;
 		map->list.addr.s6_addr32[0] &= mask->s6_addr32[0];
@@ -227,7 +225,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		ret_val = netlbl_af6list_add(&map->list, &addrmap->list6);
 		if (ret_val != 0) {
 			kfree(map);
-			goto add_failure;
+			goto free_address_map;
 		}
 
 		entry->def.type = NETLBL_NLTYPE_ADDRSELECT;
@@ -237,15 +235,17 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 
 	ret_val = netlbl_domhsh_add(entry, audit_info);
 	if (ret_val != 0)
-		goto add_failure;
+		goto free_address_map;
 
 	return 0;
 
-add_failure:
-	cipso_v4_doi_putdef(cipsov4);
-	if (entry)
-		kfree(entry->domain);
+free_address_map:
 	kfree(addrmap);
+doi_put_def:
+	cipso_v4_doi_putdef(cipsov4);
+free_domain:
+	kfree(entry->domain);
+free_entry:
 	kfree(entry);
 	return ret_val;
 }
-- 
2.2.2
