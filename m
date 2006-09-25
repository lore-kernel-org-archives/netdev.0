From: paul.moore@hp.com
Subject: [PATCH v2 7/8] NetLabel: rework the Netlink attribute handling (part 2)
Date: Mon, 25 Sep 2006 14:04:19 -0400
Message-ID: <20060925180643.211181000@hp.com>
References: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39628 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751429AbWIYSGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:48 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-nlattr_change_p2
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the suggestion of Thomas Graf, rewrite NetLabel's use of Netlink attributes
to better follow the common Netlink attribute usage.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/netlabel/netlabel_cipso_v4.c  |  630 ++++++++++++++++++++++++--------------
 net/netlabel/netlabel_cipso_v4.h  |  235 +++++---------
 net/netlabel/netlabel_mgmt.c      |  535 ++++++++++++++++----------------
 net/netlabel/netlabel_mgmt.h      |  213 ++++--------
 net/netlabel/netlabel_unlabeled.c |   79 ++--
 net/netlabel/netlabel_unlabeled.h |   41 --
 6 files changed, 899 insertions(+), 834 deletions(-)

Index: net-2.6.19/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_cipso_v4.c
+++ net-2.6.19/net/netlabel/netlabel_cipso_v4.c
@@ -41,15 +41,37 @@
 #include "netlabel_user.h"
 #include "netlabel_cipso_v4.h"
 
+/* Argument struct for cipso_v4_doi_walk() */
+struct netlbl_cipsov4_doiwalk_arg {
+	struct netlink_callback *nl_cb;
+	struct sk_buff *skb;
+	u32 seq;
+};
+
 /* NetLabel Generic NETLINK CIPSOv4 family */
 static struct genl_family netlbl_cipsov4_gnl_family = {
 	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_CIPSOV4_NAME,
 	.version = NETLBL_PROTO_VERSION,
-	.maxattr = 0,
+	.maxattr = NLBL_CIPSOV4_A_MAX,
 };
 
+/* NetLabel Netlink attribute policy */
+static struct nla_policy netlbl_cipsov4_genl_policy[NLBL_CIPSOV4_A_MAX + 1] = {
+	[NLBL_CIPSOV4_A_DOI] = { .type = NLA_U32 },
+	[NLBL_CIPSOV4_A_MTYPE] = { .type = NLA_U32 },
+	[NLBL_CIPSOV4_A_TAG] = { .type = NLA_U8 },
+	[NLBL_CIPSOV4_A_TAGLST] = { .type = NLA_NESTED },
+	[NLBL_CIPSOV4_A_MLSLVLLOC] = { .type = NLA_U32 },
+	[NLBL_CIPSOV4_A_MLSLVLREM] = { .type = NLA_U32 },
+	[NLBL_CIPSOV4_A_MLSLVL] = { .type = NLA_NESTED },
+	[NLBL_CIPSOV4_A_MLSLVLLST] = { .type = NLA_NESTED },
+	[NLBL_CIPSOV4_A_MLSCATLOC] = { .type = NLA_U32 },
+	[NLBL_CIPSOV4_A_MLSCATREM] = { .type = NLA_U32 },
+	[NLBL_CIPSOV4_A_MLSCAT] = { .type = NLA_NESTED },
+	[NLBL_CIPSOV4_A_MLSCATLST] = { .type = NLA_NESTED },
+};
 
 /*
  * Helper Functions
@@ -81,6 +103,41 @@ static void netlbl_cipsov4_doi_free(stru
 	kfree(ptr);
 }
 
+/**
+ * netlbl_cipsov4_add_common - Parse the common sections of a ADD message
+ * @info: the Generic NETLINK info block
+ * @doi_def: the CIPSO V4 DOI definition
+ *
+ * Description:
+ * Parse the common sections of a ADD message and fill in the related values
+ * in @doi_def.  Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_cipsov4_add_common(struct genl_info *info,
+				     struct cipso_v4_doi *doi_def)
+{
+	struct nlattr *nla;
+	int nla_rem;
+	u32 iter = 0;
+
+	doi_def->doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
+
+	if (nla_validate_nested(info->attrs[NLBL_CIPSOV4_A_TAGLST],
+				NLBL_CIPSOV4_A_MAX,
+				netlbl_cipsov4_genl_policy) != 0)
+		return -EINVAL;
+
+	nla_for_each_nested(nla, info->attrs[NLBL_CIPSOV4_A_TAGLST], nla_rem)
+		if (nla->nla_type == NLBL_CIPSOV4_A_TAG) {
+			if (iter > CIPSO_V4_TAG_MAXCNT)
+				return -EINVAL;
+			doi_def->tags[iter++] = nla_get_u8(nla);
+		}
+	if (iter < CIPSO_V4_TAG_MAXCNT)
+		doi_def->tags[iter] = CIPSO_V4_TAG_INVALID;
+
+	return 0;
+}
 
 /*
  * NetLabel Command Handlers
@@ -88,9 +145,7 @@ static void netlbl_cipsov4_doi_free(stru
 
 /**
  * netlbl_cipsov4_add_std - Adds a CIPSO V4 DOI definition
- * @doi: the DOI value
- * @msg: the ADD message data
- * @msg_size: the size of the ADD message buffer
+ * @info: the Generic NETLINK info block
  *
  * Description:
  * Create a new CIPSO_V4_MAP_STD DOI definition based on the given ADD message
@@ -98,29 +153,28 @@ static void netlbl_cipsov4_doi_free(stru
  * error.
  *
  */
-static int netlbl_cipsov4_add_std(u32 doi, struct nlattr *msg, size_t msg_size)
+static int netlbl_cipsov4_add_std(struct genl_info *info)
 {
 	int ret_val = -EINVAL;
-	int msg_len = msg_size;
-	u32 num_tags;
-	u32 num_lvls;
-	u32 num_cats;
 	struct cipso_v4_doi *doi_def = NULL;
-	u32 iter;
-	u32 tmp_val_a;
-	u32 tmp_val_b;
-
-	if (msg_len < NETLBL_LEN_U32)
-		goto add_std_failure;
-	num_tags = netlbl_getinc_u32(&msg, &msg_len);
-	if (num_tags == 0 || num_tags > CIPSO_V4_TAG_MAXCNT)
-		goto add_std_failure;
+	struct nlattr *nla_a;
+	struct nlattr *nla_b;
+	int nla_a_rem;
+	int nla_b_rem;
+
+	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
+	    !info->attrs[NLBL_CIPSOV4_A_TAGLST] ||
+	    !info->attrs[NLBL_CIPSOV4_A_MLSLVLLST])
+		return -EINVAL;
+
+	if (nla_validate_nested(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
+				NLBL_CIPSOV4_A_MAX,
+				netlbl_cipsov4_genl_policy) != 0)
+		return -EINVAL;
 
 	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
-	if (doi_def == NULL) {
-		ret_val = -ENOMEM;
-		goto add_std_failure;
-	}
+	if (doi_def == NULL)
+		return -ENOMEM;
 	doi_def->map.std = kzalloc(sizeof(*doi_def->map.std), GFP_KERNEL);
 	if (doi_def->map.std == NULL) {
 		ret_val = -ENOMEM;
@@ -128,28 +182,32 @@ static int netlbl_cipsov4_add_std(u32 do
 	}
 	doi_def->type = CIPSO_V4_MAP_STD;
 
-	for (iter = 0; iter < num_tags; iter++) {
-		if (msg_len < NETLBL_LEN_U8)
-			goto add_std_failure;
-		doi_def->tags[iter] = netlbl_getinc_u8(&msg, &msg_len);
-		switch (doi_def->tags[iter]) {
-		case CIPSO_V4_TAG_RBITMAP:
-			break;
-		default:
-			goto add_std_failure;
-		}
-	}
-	if (iter < CIPSO_V4_TAG_MAXCNT)
-		doi_def->tags[iter] = CIPSO_V4_TAG_INVALID;
-
-	if (msg_len < 6 * NETLBL_LEN_U32)
+	ret_val = netlbl_cipsov4_add_common(info, doi_def);
+	if (ret_val != 0)
 		goto add_std_failure;
 
-	num_lvls = netlbl_getinc_u32(&msg, &msg_len);
-	if (num_lvls == 0)
-		goto add_std_failure;
-	doi_def->map.std->lvl.local_size = netlbl_getinc_u32(&msg, &msg_len);
-	if (doi_def->map.std->lvl.local_size > CIPSO_V4_MAX_LOC_LVLS)
+	nla_for_each_nested(nla_a,
+			    info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
+			    nla_a_rem)
+		if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSLVL) {
+			nla_for_each_nested(nla_b, nla_a, nla_b_rem)
+				switch (nla_b->nla_type) {
+				case NLBL_CIPSOV4_A_MLSLVLLOC:
+					if (nla_get_u32(nla_b) >=
+					    doi_def->map.std->lvl.local_size)
+					     doi_def->map.std->lvl.local_size =
+						     nla_get_u32(nla_b) + 1;
+					break;
+				case NLBL_CIPSOV4_A_MLSLVLREM:
+					if (nla_get_u32(nla_b) >=
+					    doi_def->map.std->lvl.cipso_size)
+					     doi_def->map.std->lvl.cipso_size =
+						     nla_get_u32(nla_b) + 1;
+					break;
+				}
+		}
+	if (doi_def->map.std->lvl.local_size > CIPSO_V4_MAX_LOC_LVLS ||
+	    doi_def->map.std->lvl.cipso_size > CIPSO_V4_MAX_REM_LVLS)
 		goto add_std_failure;
 	doi_def->map.std->lvl.local = kcalloc(doi_def->map.std->lvl.local_size,
 					      sizeof(u32),
@@ -158,9 +216,6 @@ static int netlbl_cipsov4_add_std(u32 do
 		ret_val = -ENOMEM;
 		goto add_std_failure;
 	}
-	doi_def->map.std->lvl.cipso_size = netlbl_getinc_u8(&msg, &msg_len);
-	if (doi_def->map.std->lvl.cipso_size > CIPSO_V4_MAX_REM_LVLS)
-		goto add_std_failure;
 	doi_def->map.std->lvl.cipso = kcalloc(doi_def->map.std->lvl.cipso_size,
 					      sizeof(u32),
 					      GFP_KERNEL);
@@ -168,68 +223,101 @@ static int netlbl_cipsov4_add_std(u32 do
 		ret_val = -ENOMEM;
 		goto add_std_failure;
 	}
+	nla_for_each_nested(nla_a,
+			    info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
+			    nla_a_rem)
+		if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSLVL) {
+			struct nlattr *lvl_loc;
+			struct nlattr *lvl_rem;
+
+			if (nla_validate_nested(nla_a,
+					      NLBL_CIPSOV4_A_MAX,
+					      netlbl_cipsov4_genl_policy) != 0)
+				goto add_std_failure;
+
+			lvl_loc = nla_find_nested(nla_a,
+						  NLBL_CIPSOV4_A_MLSLVLLOC);
+			lvl_rem = nla_find_nested(nla_a,
+						  NLBL_CIPSOV4_A_MLSLVLREM);
+			if (lvl_loc == NULL || lvl_rem == NULL)
+				goto add_std_failure;
+			doi_def->map.std->lvl.local[nla_get_u32(lvl_loc)] =
+				nla_get_u32(lvl_rem);
+			doi_def->map.std->lvl.cipso[nla_get_u32(lvl_rem)] =
+				nla_get_u32(lvl_loc);
+		}
 
-	num_cats = netlbl_getinc_u32(&msg, &msg_len);
-	doi_def->map.std->cat.local_size = netlbl_getinc_u32(&msg, &msg_len);
-	if (doi_def->map.std->cat.local_size > CIPSO_V4_MAX_LOC_CATS)
-		goto add_std_failure;
-	doi_def->map.std->cat.local = kcalloc(doi_def->map.std->cat.local_size,
+	if (info->attrs[NLBL_CIPSOV4_A_MLSCATLST]) {
+		if (nla_validate_nested(info->attrs[NLBL_CIPSOV4_A_MLSCATLST],
+					NLBL_CIPSOV4_A_MAX,
+					netlbl_cipsov4_genl_policy) != 0)
+			goto add_std_failure;
+
+		nla_for_each_nested(nla_a,
+				    info->attrs[NLBL_CIPSOV4_A_MLSCATLST],
+				    nla_a_rem)
+			if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSCAT) {
+				if (nla_validate_nested(nla_a,
+					      NLBL_CIPSOV4_A_MAX,
+					      netlbl_cipsov4_genl_policy) != 0)
+					goto add_std_failure;
+				nla_for_each_nested(nla_b, nla_a, nla_b_rem)
+					switch (nla_b->nla_type) {
+					case NLBL_CIPSOV4_A_MLSCATLOC:
+						if (nla_get_u32(nla_b) >=
+					      doi_def->map.std->cat.local_size)
+					     doi_def->map.std->cat.local_size =
+						     nla_get_u32(nla_b) + 1;
+						break;
+					case NLBL_CIPSOV4_A_MLSCATREM:
+						if (nla_get_u32(nla_b) >=
+					      doi_def->map.std->cat.cipso_size)
+					     doi_def->map.std->cat.cipso_size =
+						     nla_get_u32(nla_b) + 1;
+						break;
+					}
+			}
+		if (doi_def->map.std->cat.local_size > CIPSO_V4_MAX_LOC_CATS ||
+		    doi_def->map.std->cat.cipso_size > CIPSO_V4_MAX_REM_CATS)
+			goto add_std_failure;
+		doi_def->map.std->cat.local = kcalloc(
+			                      doi_def->map.std->cat.local_size,
 					      sizeof(u32),
 					      GFP_KERNEL);
-	if (doi_def->map.std->cat.local == NULL) {
-		ret_val = -ENOMEM;
-		goto add_std_failure;
-	}
-	doi_def->map.std->cat.cipso_size = netlbl_getinc_u16(&msg, &msg_len);
-	if (doi_def->map.std->cat.cipso_size > CIPSO_V4_MAX_REM_CATS)
-		goto add_std_failure;
-	doi_def->map.std->cat.cipso = kcalloc(doi_def->map.std->cat.cipso_size,
+		if (doi_def->map.std->cat.local == NULL) {
+			ret_val = -ENOMEM;
+			goto add_std_failure;
+		}
+		doi_def->map.std->cat.cipso = kcalloc(
+			                      doi_def->map.std->cat.cipso_size,
 					      sizeof(u32),
 					      GFP_KERNEL);
-	if (doi_def->map.std->cat.cipso == NULL) {
-		ret_val = -ENOMEM;
-		goto add_std_failure;
-	}
-
-	if (msg_len <
-	    num_lvls * (NETLBL_LEN_U32 + NETLBL_LEN_U8) +
-	    num_cats * (NETLBL_LEN_U32 + NETLBL_LEN_U16))
-		goto add_std_failure;
-
-	for (iter = 0; iter < doi_def->map.std->lvl.cipso_size; iter++)
-		doi_def->map.std->lvl.cipso[iter] = CIPSO_V4_INV_LVL;
-	for (iter = 0; iter < doi_def->map.std->lvl.local_size; iter++)
-		doi_def->map.std->lvl.local[iter] = CIPSO_V4_INV_LVL;
-	for (iter = 0; iter < doi_def->map.std->cat.cipso_size; iter++)
-		doi_def->map.std->cat.cipso[iter] = CIPSO_V4_INV_CAT;
-	for (iter = 0; iter < doi_def->map.std->cat.local_size; iter++)
-		doi_def->map.std->cat.local[iter] = CIPSO_V4_INV_CAT;
-
-	for (iter = 0; iter < num_lvls; iter++) {
-		tmp_val_a = netlbl_getinc_u32(&msg, &msg_len);
-		tmp_val_b = netlbl_getinc_u8(&msg, &msg_len);
-
-		if (tmp_val_a >= doi_def->map.std->lvl.local_size ||
-		    tmp_val_b >= doi_def->map.std->lvl.cipso_size)
-			goto add_std_failure;
-
-		doi_def->map.std->lvl.cipso[tmp_val_b] = tmp_val_a;
-		doi_def->map.std->lvl.local[tmp_val_a] = tmp_val_b;
-	}
-
-	for (iter = 0; iter < num_cats; iter++) {
-		tmp_val_a = netlbl_getinc_u32(&msg, &msg_len);
-		tmp_val_b = netlbl_getinc_u16(&msg, &msg_len);
-
-		if (tmp_val_a >= doi_def->map.std->cat.local_size ||
-		    tmp_val_b >= doi_def->map.std->cat.cipso_size)
+		if (doi_def->map.std->cat.cipso == NULL) {
+			ret_val = -ENOMEM;
 			goto add_std_failure;
-
-		doi_def->map.std->cat.cipso[tmp_val_b] = tmp_val_a;
-		doi_def->map.std->cat.local[tmp_val_a] = tmp_val_b;
+		}
+		nla_for_each_nested(nla_a,
+				    info->attrs[NLBL_CIPSOV4_A_MLSCATLST],
+				    nla_a_rem)
+			if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSCAT) {
+				struct nlattr *cat_loc;
+				struct nlattr *cat_rem;
+
+				cat_loc = nla_find_nested(nla_a,
+						     NLBL_CIPSOV4_A_MLSCATLOC);
+				cat_rem = nla_find_nested(nla_a,
+						     NLBL_CIPSOV4_A_MLSCATREM);
+				if (cat_loc == NULL || cat_rem == NULL)
+					goto add_std_failure;
+				doi_def->map.std->cat.local[
+				                        nla_get_u32(cat_loc)] =
+					nla_get_u32(cat_rem);
+				doi_def->map.std->cat.cipso[
+					                nla_get_u32(cat_rem)] =
+					nla_get_u32(cat_loc);
+			}
 	}
 
-	doi_def->doi = doi;
 	ret_val = cipso_v4_doi_add(doi_def);
 	if (ret_val != 0)
 		goto add_std_failure;
@@ -243,9 +331,7 @@ add_std_failure:
 
 /**
  * netlbl_cipsov4_add_pass - Adds a CIPSO V4 DOI definition
- * @doi: the DOI value
- * @msg: the ADD message data
- * @msg_size: the size of the ADD message buffer
+ * @info: the Generic NETLINK info block
  *
  * Description:
  * Create a new CIPSO_V4_MAP_PASS DOI definition based on the given ADD message
@@ -253,52 +339,31 @@ add_std_failure:
  * error.
  *
  */
-static int netlbl_cipsov4_add_pass(u32 doi,
-				   struct nlattr *msg,
-				   size_t msg_size)
+static int netlbl_cipsov4_add_pass(struct genl_info *info)
 {
-	int ret_val = -EINVAL;
-	int msg_len = msg_size;
-	u32 num_tags;
+	int ret_val;
 	struct cipso_v4_doi *doi_def = NULL;
-	u32 iter;
 
-	if (msg_len < NETLBL_LEN_U32)
-		goto add_pass_failure;
-	num_tags = netlbl_getinc_u32(&msg, &msg_len);
-	if (num_tags == 0 || num_tags > CIPSO_V4_TAG_MAXCNT)
-		goto add_pass_failure;
+	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
+	    !info->attrs[NLBL_CIPSOV4_A_TAGLST])
+		return -EINVAL;
 
 	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
-	if (doi_def == NULL) {
-		ret_val = -ENOMEM;
-		goto add_pass_failure;
-	}
+	if (doi_def == NULL)
+		return -ENOMEM;
 	doi_def->type = CIPSO_V4_MAP_PASS;
 
-	for (iter = 0; iter < num_tags; iter++) {
-		if (msg_len < NETLBL_LEN_U8)
-			goto add_pass_failure;
-		doi_def->tags[iter] = netlbl_getinc_u8(&msg, &msg_len);
-		switch (doi_def->tags[iter]) {
-		case CIPSO_V4_TAG_RBITMAP:
-			break;
-		default:
-			goto add_pass_failure;
-		}
-	}
-	if (iter < CIPSO_V4_TAG_MAXCNT)
-		doi_def->tags[iter] = CIPSO_V4_TAG_INVALID;
+	ret_val = netlbl_cipsov4_add_common(info, doi_def);
+	if (ret_val != 0)
+		goto add_pass_failure;
 
-	doi_def->doi = doi;
 	ret_val = cipso_v4_doi_add(doi_def);
 	if (ret_val != 0)
 		goto add_pass_failure;
 	return 0;
 
 add_pass_failure:
-	if (doi_def)
-		netlbl_cipsov4_doi_free(&doi_def->rcu);
+	netlbl_cipsov4_doi_free(&doi_def->rcu);
 	return ret_val;
 }
 
@@ -316,34 +381,21 @@ static int netlbl_cipsov4_add(struct sk_
 
 {
 	int ret_val = -EINVAL;
-	u32 doi;
 	u32 map_type;
-	int msg_len = netlbl_netlink_payload_len(skb);
-	struct nlattr *msg = netlbl_netlink_payload_data(skb);
-
-	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
-	if (ret_val != 0)
-		goto add_return;
 
-	if (msg_len < 2 * NETLBL_LEN_U32)
-		goto add_return;
+	if (!info->attrs[NLBL_CIPSOV4_A_MTYPE])
+		return -EINVAL;
 
-	doi = netlbl_getinc_u32(&msg, &msg_len);
-	map_type = netlbl_getinc_u32(&msg, &msg_len);
+	map_type = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_MTYPE]);
 	switch (map_type) {
 	case CIPSO_V4_MAP_STD:
-		ret_val = netlbl_cipsov4_add_std(doi, msg, msg_len);
+		ret_val = netlbl_cipsov4_add_std(info);
 		break;
 	case CIPSO_V4_MAP_PASS:
-		ret_val = netlbl_cipsov4_add_pass(doi, msg, msg_len);
+		ret_val = netlbl_cipsov4_add_pass(info);
 		break;
 	}
 
-add_return:
-	netlbl_netlink_send_ack(info,
-				netlbl_cipsov4_gnl_family.id,
-				NLBL_CIPSOV4_C_ACK,
-				-ret_val);
 	return ret_val;
 }
 
@@ -353,84 +405,239 @@ add_return:
  * @info: the Generic NETLINK info block
  *
  * Description:
- * Process a user generated LIST message and respond accordingly.  Returns
- * zero on success and negative values on error.
+ * Process a user generated LIST message and respond accordingly.  While the
+ * response message generated by the kernel is straightforward, determining
+ * before hand the size of the buffer to allocate is not (we have to generate
+ * the message to know the size).  In order to keep this function sane what we
+ * do is allocate a buffer of NLMSG_GOODSIZE and try to fit the response in
+ * that size, if we fail then we restart with a larger buffer and try again.
+ * We continue in this manner until we hit a limit of failed attempts then we
+ * give up and just send an error message.  Returns zero on success and
+ * negative values on error.
  *
  */
 static int netlbl_cipsov4_list(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret_val = -EINVAL;
+	int ret_val;
+	struct sk_buff *ans_skb = NULL;
+	u32 nlsze_mult = 1;
+	void *data;
 	u32 doi;
-	struct nlattr *msg = netlbl_netlink_payload_data(skb);
-	struct sk_buff *ans_skb;
+	struct nlattr *nla_a;
+	struct nlattr *nla_b;
+	struct cipso_v4_doi *doi_def;
+	u32 iter;
 
-	if (netlbl_netlink_payload_len(skb) != NETLBL_LEN_U32)
+	if (!info->attrs[NLBL_CIPSOV4_A_DOI]) {
+		ret_val = -EINVAL;
 		goto list_failure;
+	}
 
-	doi = nla_get_u32(msg);
-	ans_skb = cipso_v4_doi_dump(doi, NLMSG_SPACE(GENL_HDRLEN));
+list_start:
+	ans_skb = nlmsg_new(NLMSG_GOODSIZE * nlsze_mult, GFP_KERNEL);
 	if (ans_skb == NULL) {
 		ret_val = -ENOMEM;
 		goto list_failure;
 	}
-	netlbl_netlink_hdr_push(ans_skb,
-				info->snd_pid,
-				0,
-				netlbl_cipsov4_gnl_family.id,
-				NLBL_CIPSOV4_C_LIST);
+	data = netlbl_netlink_hdr_put(ans_skb,
+				      info->snd_pid,
+				      info->snd_seq,
+				      netlbl_cipsov4_gnl_family.id,
+				      0,
+				      NLBL_CIPSOV4_C_LIST);
+	if (data == NULL) {
+		ret_val = -ENOMEM;
+		goto list_failure;
+	}
+
+	doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
+
+	rcu_read_lock();
+	doi_def = cipso_v4_doi_getdef(doi);
+	if (doi_def == NULL) {
+		ret_val = -EINVAL;
+		goto list_failure;
+	}
+
+	ret_val = nla_put_u32(ans_skb, NLBL_CIPSOV4_A_MTYPE, doi_def->type);
+	if (ret_val != 0)
+		goto list_failure_lock;
+
+	nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_TAGLST);
+	if (nla_a == NULL) {
+		ret_val = -ENOMEM;
+		goto list_failure_lock;
+	}
+	for (iter = 0;
+	     iter < CIPSO_V4_TAG_MAXCNT &&
+	       doi_def->tags[iter] != CIPSO_V4_TAG_INVALID;
+	     iter++) {
+		ret_val = nla_put_u8(ans_skb,
+				     NLBL_CIPSOV4_A_TAG,
+				     doi_def->tags[iter]);
+		if (ret_val != 0)
+			goto list_failure_lock;
+	}
+	nla_nest_end(ans_skb, nla_a);
+
+	switch (doi_def->type) {
+	case CIPSO_V4_MAP_STD:
+		nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSLVLLST);
+		if (nla_a == NULL) {
+			ret_val = -ENOMEM;
+			goto list_failure_lock;
+		}
+		for (iter = 0;
+		     iter < doi_def->map.std->lvl.local_size;
+		     iter++) {
+			if (doi_def->map.std->lvl.local[iter] ==
+			    CIPSO_V4_INV_LVL)
+				continue;
+
+			nla_b = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSLVL);
+			if (nla_b == NULL) {
+				ret_val = -ENOMEM;
+				goto list_retry;
+			}
+			ret_val = nla_put_u32(ans_skb,
+					      NLBL_CIPSOV4_A_MLSLVLLOC,
+					      iter);
+			if (ret_val != 0)
+				goto list_retry;
+			ret_val = nla_put_u32(ans_skb,
+					    NLBL_CIPSOV4_A_MLSLVLREM,
+					    doi_def->map.std->lvl.local[iter]);
+			if (ret_val != 0)
+				goto list_retry;
+			nla_nest_end(ans_skb, nla_b);
+		}
+		nla_nest_end(ans_skb, nla_a);
+
+		nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSCATLST);
+		if (nla_a == NULL) {
+			ret_val = -ENOMEM;
+			goto list_retry;
+		}
+		for (iter = 0;
+		     iter < doi_def->map.std->cat.local_size;
+		     iter++) {
+			if (doi_def->map.std->cat.local[iter] ==
+			    CIPSO_V4_INV_CAT)
+				continue;
+
+			nla_b = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSCAT);
+			if (nla_b == NULL) {
+				ret_val = -ENOMEM;
+				goto list_retry;
+			}
+			ret_val = nla_put_u32(ans_skb,
+					      NLBL_CIPSOV4_A_MLSCATLOC,
+					      iter);
+			if (ret_val != 0)
+				goto list_retry;
+			ret_val = nla_put_u32(ans_skb,
+					    NLBL_CIPSOV4_A_MLSCATREM,
+					    doi_def->map.std->cat.local[iter]);
+			if (ret_val != 0)
+				goto list_retry;
+			nla_nest_end(ans_skb, nla_b);
+		}
+		nla_nest_end(ans_skb, nla_a);
+
+		break;
+	}
+	rcu_read_unlock();
+
+	genlmsg_end(ans_skb, data);
 
-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
 	if (ret_val != 0)
 		goto list_failure;
 
 	return 0;
 
+list_retry:
+	/* XXX - this limit is a guesstimate */
+	if (nlsze_mult < 4) {
+		rcu_read_unlock();
+		kfree_skb(ans_skb);
+		nlsze_mult++;
+		goto list_start;
+	}
+list_failure_lock:
+	rcu_read_unlock();
 list_failure:
-	netlbl_netlink_send_ack(info,
-				netlbl_cipsov4_gnl_family.id,
-				NLBL_CIPSOV4_C_ACK,
-				-ret_val);
+	kfree_skb(ans_skb);
+	return ret_val;
+}
+
+/**
+ * netlbl_cipsov4_listall_cb - cipso_v4_doi_walk() callback for LISTALL
+ * @doi_def: the CIPSOv4 DOI definition
+ * @arg: the netlbl_cipsov4_doiwalk_arg structure
+ *
+ * Description:
+ * This function is designed to be used as a callback to the
+ * cipso_v4_doi_walk() function for use in generating a response for a LISTALL
+ * message.  Returns the size of the message on success, negative values on
+ * failure.
+ *
+ */
+static int netlbl_cipsov4_listall_cb(struct cipso_v4_doi *doi_def, void *arg)
+{
+	int ret_val = -ENOMEM;
+	struct netlbl_cipsov4_doiwalk_arg *cb_arg = arg;
+	void *data;
+
+	data = netlbl_netlink_hdr_put(cb_arg->skb,
+				      NETLINK_CB(cb_arg->nl_cb->skb).pid,
+				      cb_arg->seq,
+				      netlbl_cipsov4_gnl_family.id,
+				      NLM_F_MULTI,
+				      NLBL_CIPSOV4_C_LISTALL);
+	if (data == NULL)
+		goto listall_cb_failure;
+
+	ret_val = nla_put_u32(cb_arg->skb, NLBL_CIPSOV4_A_DOI, doi_def->doi);
+	if (ret_val != 0)
+		goto listall_cb_failure;
+	ret_val = nla_put_u32(cb_arg->skb,
+			      NLBL_CIPSOV4_A_MTYPE,
+			      doi_def->type);
+	if (ret_val != 0)
+		goto listall_cb_failure;
+
+	return genlmsg_end(cb_arg->skb, data);
+
+listall_cb_failure:
+	genlmsg_cancel(cb_arg->skb, data);
 	return ret_val;
 }
 
 /**
  * netlbl_cipsov4_listall - Handle a LISTALL message
  * @skb: the NETLINK buffer
- * @info: the Generic NETLINK info block
+ * @cb: the NETLINK callback
  *
  * Description:
  * Process a user generated LISTALL message and respond accordingly.  Returns
  * zero on success and negative values on error.
  *
  */
-static int netlbl_cipsov4_listall(struct sk_buff *skb, struct genl_info *info)
+static int netlbl_cipsov4_listall(struct sk_buff *skb,
+				  struct netlink_callback *cb)
 {
-	int ret_val = -EINVAL;
-	struct sk_buff *ans_skb;
+	struct netlbl_cipsov4_doiwalk_arg cb_arg;
+	int doi_skip = cb->args[0];
 
-	ans_skb = cipso_v4_doi_dump_all(NLMSG_SPACE(GENL_HDRLEN));
-	if (ans_skb == NULL) {
-		ret_val = -ENOMEM;
-		goto listall_failure;
-	}
-	netlbl_netlink_hdr_push(ans_skb,
-				info->snd_pid,
-				0,
-				netlbl_cipsov4_gnl_family.id,
-				NLBL_CIPSOV4_C_LISTALL);
+	cb_arg.nl_cb = cb;
+	cb_arg.skb = skb;
+	cb_arg.seq = cb->nlh->nlmsg_seq;
 
-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
-	if (ret_val != 0)
-		goto listall_failure;
-
-	return 0;
+	cipso_v4_doi_walk(&doi_skip, netlbl_cipsov4_listall_cb, &cb_arg);
 
-listall_failure:
-	netlbl_netlink_send_ack(info,
-				netlbl_cipsov4_gnl_family.id,
-				NLBL_CIPSOV4_C_ACK,
-				-ret_val);
-	return ret_val;
+	cb->args[0] = doi_skip;
+	return skb->len;
 }
 
 /**
@@ -445,27 +652,14 @@ listall_failure:
  */
 static int netlbl_cipsov4_remove(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret_val;
+	int ret_val = -EINVAL;
 	u32 doi;
-	struct nlattr *msg = netlbl_netlink_payload_data(skb);
 
-	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
-	if (ret_val != 0)
-		goto remove_return;
-
-	if (netlbl_netlink_payload_len(skb) != NETLBL_LEN_U32) {
-		ret_val = -EINVAL;
-		goto remove_return;
+	if (info->attrs[NLBL_CIPSOV4_A_DOI]) {
+		doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
+		ret_val = cipso_v4_doi_remove(doi, netlbl_cipsov4_doi_free);
 	}
 
-	doi = nla_get_u32(msg);
-	ret_val = cipso_v4_doi_remove(doi, netlbl_cipsov4_doi_free);
-
-remove_return:
-	netlbl_netlink_send_ack(info,
-				netlbl_cipsov4_gnl_family.id,
-				NLBL_CIPSOV4_C_ACK,
-				-ret_val);
 	return ret_val;
 }
 
@@ -475,14 +669,16 @@ remove_return:
 
 static struct genl_ops netlbl_cipsov4_genl_c_add = {
 	.cmd = NLBL_CIPSOV4_C_ADD,
-	.flags = 0,
+	.flags = GENL_ADMIN_PERM,
+	.policy = netlbl_cipsov4_genl_policy,
 	.doit = netlbl_cipsov4_add,
 	.dumpit = NULL,
 };
 
 static struct genl_ops netlbl_cipsov4_genl_c_remove = {
 	.cmd = NLBL_CIPSOV4_C_REMOVE,
-	.flags = 0,
+	.flags = GENL_ADMIN_PERM,
+	.policy = netlbl_cipsov4_genl_policy,
 	.doit = netlbl_cipsov4_remove,
 	.dumpit = NULL,
 };
@@ -490,6 +686,7 @@ static struct genl_ops netlbl_cipsov4_ge
 static struct genl_ops netlbl_cipsov4_genl_c_list = {
 	.cmd = NLBL_CIPSOV4_C_LIST,
 	.flags = 0,
+	.policy = netlbl_cipsov4_genl_policy,
 	.doit = netlbl_cipsov4_list,
 	.dumpit = NULL,
 };
@@ -497,8 +694,9 @@ static struct genl_ops netlbl_cipsov4_ge
 static struct genl_ops netlbl_cipsov4_genl_c_listall = {
 	.cmd = NLBL_CIPSOV4_C_LISTALL,
 	.flags = 0,
-	.doit = netlbl_cipsov4_listall,
-	.dumpit = NULL,
+	.policy = netlbl_cipsov4_genl_policy,
+	.doit = NULL,
+	.dumpit = netlbl_cipsov4_listall,
 };
 
 /*
Index: net-2.6.19/net/netlabel/netlabel_cipso_v4.h
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_cipso_v4.h
+++ net-2.6.19/net/netlabel/netlabel_cipso_v4.h
@@ -34,175 +34,71 @@
 #include <net/netlabel.h>
 
 /*
- * The following NetLabel payloads are supported by the CIPSO subsystem, all
- * of which are preceeded by the nlmsghdr struct.
- *
- * o ACK:
- *   Sent by the kernel in response to an applications message, applications
- *   should never send this message.
- *
- *   +----------------------+-----------------------+
- *   | seq number (32 bits) | return code (32 bits) |
- *   +----------------------+-----------------------+
- *
- *     seq number:  the sequence number of the original message, taken from the
- *                  nlmsghdr structure
- *     return code: return value, based on errno values
+ * The following NetLabel payloads are supported by the CIPSO subsystem.
  *
  * o ADD:
- *   Sent by an application to add a new DOI mapping table, after completion
- *   of the task the kernel should ACK this message.
+ *   Sent by an application to add a new DOI mapping table.
+ *
+ *   Required attributes:
+ *
+ *     NLBL_CIPSOV4_A_DOI
+ *     NLBL_CIPSOV4_A_MTYPE
+ *     NLBL_CIPSOV4_A_TAGLST
  *
- *   +---------------+--------------------+---------------------+
- *   | DOI (32 bits) | map type (32 bits) | tag count (32 bits) | ...
- *   +---------------+--------------------+---------------------+
- *
- *   +-----------------+
- *   | tag #X (8 bits) | ... repeated
- *   +-----------------+
- *
- *   +-------------- ---- --- -- -
- *   | mapping data
- *   +-------------- ---- --- -- -
- *
- *     DOI:          the DOI value
- *     map type:     the mapping table type (defined in the cipso_ipv4.h header
- *                   as CIPSO_V4_MAP_*)
- *     tag count:    the number of tags, must be greater than zero
- *     tag:          the CIPSO tag for the DOI, tags listed first are given
- *                   higher priorirty when sending packets
- *     mapping data: specific to the map type (see below)
- *
- *   CIPSO_V4_MAP_STD
- *
- *   +------------------+-----------------------+----------------------+
- *   | levels (32 bits) | max l level (32 bits) | max r level (8 bits) | ...
- *   +------------------+-----------------------+----------------------+
- *
- *   +----------------------+---------------------+---------------------+
- *   | categories (32 bits) | max l cat (32 bits) | max r cat (16 bits) | ...
- *   +----------------------+---------------------+---------------------+
- *
- *   +--------------------------+-------------------------+
- *   | local level #X (32 bits) | CIPSO level #X (8 bits) | ... repeated
- *   +--------------------------+-------------------------+
- *
- *   +-----------------------------+-----------------------------+
- *   | local category #X (32 bits) | CIPSO category #X (16 bits) | ... repeated
- *   +-----------------------------+-----------------------------+
- *
- *     levels:         the number of level mappings
- *     max l level:    the highest local level
- *     max r level:    the highest remote/CIPSO level
- *     categories:     the number of category mappings
- *     max l cat:      the highest local category
- *     max r cat:      the highest remote/CIPSO category
- *     local level:    the local part of a level mapping
- *     CIPSO level:    the remote/CIPSO part of a level mapping
- *     local category: the local part of a category mapping
- *     CIPSO category: the remote/CIPSO part of a category mapping
+ *   If using CIPSO_V4_MAP_STD the following attributes are required:
  *
- *   CIPSO_V4_MAP_PASS
+ *     NLBL_CIPSOV4_A_MLSLVLLST
+ *     NLBL_CIPSOV4_A_MLSCATLST
  *
- *   No mapping data is needed for this map type.
+ *   If using CIPSO_V4_MAP_PASS no additional attributes are required.
  *
  * o REMOVE:
  *   Sent by an application to remove a specific DOI mapping table from the
- *   CIPSO V4 system.  The kernel should ACK this message.
+ *   CIPSO V4 system.
  *
- *   +---------------+
- *   | DOI (32 bits) |
- *   +---------------+
+ *   Required attributes:
  *
- *     DOI:          the DOI value
+ *     NLBL_CIPSOV4_A_DOI
  *
  * o LIST:
- *   Sent by an application to list the details of a DOI definition.  The
- *   kernel should send an ACK on error or a response as indicated below.  The
- *   application generated message format is shown below.
- *
- *   +---------------+
- *   | DOI (32 bits) |
- *   +---------------+
+ *   Sent by an application to list the details of a DOI definition.  On
+ *   success the kernel should send a response using the following format.
  *
- *     DOI:          the DOI value
+ *   Required attributes:
+ *
+ *     NLBL_CIPSOV4_A_DOI
  *
  *   The valid response message format depends on the type of the DOI mapping,
- *   the known formats are shown below.
+ *   the defined formats are shown below.
+ *
+ *   Required attributes:
+ *
+ *     NLBL_CIPSOV4_A_MTYPE
+ *     NLBL_CIPSOV4_A_TAGLST
  *
- *   +--------------------+
- *   | map type (32 bits) | ...
- *   +--------------------+
- *
- *     map type:       the DOI mapping table type (defined in the cipso_ipv4.h
- *                     header as CIPSO_V4_MAP_*)
- *
- *   (map type == CIPSO_V4_MAP_STD)
- *
- *   +----------------+------------------+----------------------+
- *   | tags (32 bits) | levels (32 bits) | categories (32 bits) | ...
- *   +----------------+------------------+----------------------+
- *
- *   +-----------------+
- *   | tag #X (8 bits) | ... repeated
- *   +-----------------+
- *
- *   +--------------------------+-------------------------+
- *   | local level #X (32 bits) | CIPSO level #X (8 bits) | ... repeated
- *   +--------------------------+-------------------------+
- *
- *   +-----------------------------+-----------------------------+
- *   | local category #X (32 bits) | CIPSO category #X (16 bits) | ... repeated
- *   +-----------------------------+-----------------------------+
- *
- *     tags:           the number of CIPSO tag types
- *     levels:         the number of level mappings
- *     categories:     the number of category mappings
- *     tag:            the tag number, tags listed first are given higher
- *                     priority when sending packets
- *     local level:    the local part of a level mapping
- *     CIPSO level:    the remote/CIPSO part of a level mapping
- *     local category: the local part of a category mapping
- *     CIPSO category: the remote/CIPSO part of a category mapping
- *
- *   (map type == CIPSO_V4_MAP_PASS)
- *
- *   +----------------+
- *   | tags (32 bits) | ...
- *   +----------------+
- *
- *   +-----------------+
- *   | tag #X (8 bits) | ... repeated
- *   +-----------------+
- *
- *     tags:           the number of CIPSO tag types
- *     tag:            the tag number, tags listed first are given higher
- *                     priority when sending packets
+ *   If using CIPSO_V4_MAP_STD the following attributes are required:
+ *
+ *     NLBL_CIPSOV4_A_MLSLVLLST
+ *     NLBL_CIPSOV4_A_MLSCATLST
+ *
+ *   If using CIPSO_V4_MAP_PASS no additional attributes are required.
  *
  * o LISTALL:
  *   This message is sent by an application to list the valid DOIs on the
- *   system.  There is no payload and the kernel should respond with an ACK
- *   or the following message.
+ *   system.  When sent by an application there is no payload and the
+ *   NLM_F_DUMP flag should be set.  The kernel should respond with a series of
+ *   the following messages.
+ *
+ *   Required attributes:
  *
- *   +---------------------+------------------+-----------------------+
- *   | DOI count (32 bits) | DOI #X (32 bits) | map type #X (32 bits) |
- *   +---------------------+------------------+-----------------------+
- *
- *   +-----------------------+
- *   | map type #X (32 bits) | ...
- *   +-----------------------+
- *
- *     DOI count:      the number of DOIs
- *     DOI:            the DOI value
- *     map type:       the DOI mapping table type (defined in the cipso_ipv4.h
- *                     header as CIPSO_V4_MAP_*)
+ *    NLBL_CIPSOV4_A_DOI
+ *    NLBL_CIPSOV4_A_MTYPE
  *
  */
 
 /* NetLabel CIPSOv4 commands */
 enum {
 	NLBL_CIPSOV4_C_UNSPEC,
-	NLBL_CIPSOV4_C_ACK,
 	NLBL_CIPSOV4_C_ADD,
 	NLBL_CIPSOV4_C_REMOVE,
 	NLBL_CIPSOV4_C_LIST,
@@ -211,6 +107,59 @@ enum {
 };
 #define NLBL_CIPSOV4_C_MAX (__NLBL_CIPSOV4_C_MAX - 1)
 
+/* NetLabel CIPSOv4 attributes */
+enum {
+	NLBL_CIPSOV4_A_UNSPEC,
+	NLBL_CIPSOV4_A_DOI,
+	/* (NLA_U32)
+	 * the DOI value */
+	NLBL_CIPSOV4_A_MTYPE,
+	/* (NLA_U32)
+	 * the mapping table type (defined in the cipso_ipv4.h header as
+	 * CIPSO_V4_MAP_*) */
+	NLBL_CIPSOV4_A_TAG,
+	/* (NLA_U8)
+	 * a CIPSO tag type, meant to be used within a NLBL_CIPSOV4_A_TAGLST
+	 * attribute */
+	NLBL_CIPSOV4_A_TAGLST,
+	/* (NLA_NESTED)
+	 * the CIPSO tag list for the DOI, there must be at least one
+	 * NLBL_CIPSOV4_A_TAG attribute, tags listed first are given higher
+	 * priorirty when sending packets */
+	NLBL_CIPSOV4_A_MLSLVLLOC,
+	/* (NLA_U32)
+	 * the local MLS sensitivity level */
+	NLBL_CIPSOV4_A_MLSLVLREM,
+	/* (NLA_U32)
+	 * the remote MLS sensitivity level */
+	NLBL_CIPSOV4_A_MLSLVL,
+	/* (NLA_NESTED)
+	 * a MLS sensitivity level mapping, must contain only one attribute of
+	 * each of the following types: NLBL_CIPSOV4_A_MLSLVLLOC and
+	 * NLBL_CIPSOV4_A_MLSLVLREM */
+	NLBL_CIPSOV4_A_MLSLVLLST,
+	/* (NLA_NESTED)
+	 * the CIPSO level mappings, there must be at least one
+	 * NLBL_CIPSOV4_A_MLSLVL attribute */
+	NLBL_CIPSOV4_A_MLSCATLOC,
+	/* (NLA_U32)
+	 * the local MLS category */
+	NLBL_CIPSOV4_A_MLSCATREM,
+	/* (NLA_U32)
+	 * the remote MLS category */
+	NLBL_CIPSOV4_A_MLSCAT,
+	/* (NLA_NESTED)
+	 * a MLS category mapping, must contain only one attribute of each of
+	 * the following types: NLBL_CIPSOV4_A_MLSCATLOC and
+	 * NLBL_CIPSOV4_A_MLSCATREM */
+	NLBL_CIPSOV4_A_MLSCATLST,
+	/* (NLA_NESTED)
+	 * the CIPSO category mappings, there must be at least one
+	 * NLBL_CIPSOV4_A_MLSCAT attribute */
+	__NLBL_CIPSOV4_A_MAX,
+};
+#define NLBL_CIPSOV4_A_MAX (__NLBL_CIPSOV4_A_MAX - 1)
+
 /* NetLabel protocol functions */
 int netlbl_cipsov4_genl_init(void);
 
Index: net-2.6.19/net/netlabel/netlabel_mgmt.c
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_mgmt.c
+++ net-2.6.19/net/netlabel/netlabel_mgmt.c
@@ -42,15 +42,29 @@
 #include "netlabel_user.h"
 #include "netlabel_mgmt.h"
 
+/* Argument struct for netlbl_domhsh_walk() */
+struct netlbl_domhsh_walk_arg {
+	struct netlink_callback *nl_cb;
+	struct sk_buff *skb;
+	u32 seq;
+};
+
 /* NetLabel Generic NETLINK CIPSOv4 family */
 static struct genl_family netlbl_mgmt_gnl_family = {
 	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_MGMT_NAME,
 	.version = NETLBL_PROTO_VERSION,
-	.maxattr = 0,
+	.maxattr = NLBL_MGMT_A_MAX,
 };
 
+/* NetLabel Netlink attribute policy */
+static struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
+	[NLBL_MGMT_A_DOMAIN] = { .type = NLA_NUL_STRING },
+	[NLBL_MGMT_A_PROTOCOL] = { .type = NLA_U32 },
+	[NLBL_MGMT_A_VERSION] = { .type = NLA_U32 },
+	[NLBL_MGMT_A_CV4DOI] = { .type = NLA_U32 },
+};
 
 /*
  * NetLabel Command Handlers
@@ -70,97 +84,62 @@ static struct genl_family netlbl_mgmt_gn
 static int netlbl_mgmt_add(struct sk_buff *skb, struct genl_info *info)
 {
 	int ret_val = -EINVAL;
-	struct nlattr *msg_ptr = netlbl_netlink_payload_data(skb);
-	int msg_len = netlbl_netlink_payload_len(skb);
-	u32 count;
 	struct netlbl_dom_map *entry = NULL;
-	u32 iter;
+	size_t tmp_size;
 	u32 tmp_val;
-	int tmp_size;
 
-	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
-	if (ret_val != 0)
+	if (!info->attrs[NLBL_MGMT_A_DOMAIN] ||
+	    !info->attrs[NLBL_MGMT_A_PROTOCOL])
 		goto add_failure;
 
-	if (msg_len < NETLBL_LEN_U32)
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (entry == NULL) {
+		ret_val = -ENOMEM;
 		goto add_failure;
-	count = netlbl_getinc_u32(&msg_ptr, &msg_len);
+	}
+	tmp_size = nla_len(info->attrs[NLBL_MGMT_A_DOMAIN]);
+	entry->domain = kmalloc(tmp_size, GFP_KERNEL);
+	if (entry->domain == NULL) {
+		ret_val = -ENOMEM;
+		goto add_failure;
+	}
+	entry->type = nla_get_u32(info->attrs[NLBL_MGMT_A_PROTOCOL]);
+	nla_strlcpy(entry->domain, info->attrs[NLBL_MGMT_A_DOMAIN], tmp_size);
 
-	for (iter = 0; iter < count && msg_len > 0; iter++, entry = NULL) {
-		if (msg_len <= 0) {
-			ret_val = -EINVAL;
-			goto add_failure;
-		}
-		entry = kzalloc(sizeof(*entry), GFP_KERNEL);
-		if (entry == NULL) {
-			ret_val = -ENOMEM;
-			goto add_failure;
-		}
-		tmp_size = nla_len(msg_ptr);
-		if (tmp_size <= 0 || tmp_size > msg_len) {
-			ret_val = -EINVAL;
-			goto add_failure;
-		}
-		entry->domain = kmalloc(tmp_size, GFP_KERNEL);
-		if (entry->domain == NULL) {
-			ret_val = -ENOMEM;
+	switch (entry->type) {
+	case NETLBL_NLTYPE_UNLABELED:
+		ret_val = netlbl_domhsh_add(entry);
+		break;
+	case NETLBL_NLTYPE_CIPSOV4:
+		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
 			goto add_failure;
-		}
-		nla_strlcpy(entry->domain, msg_ptr, tmp_size);
-		entry->domain[tmp_size - 1] = '\0';
-		msg_ptr = nla_next(msg_ptr, &msg_len);
 
-		if (msg_len < NETLBL_LEN_U32) {
-			ret_val = -EINVAL;
-			goto add_failure;
-		}
-		tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
-		entry->type = tmp_val;
-		switch (tmp_val) {
-		case NETLBL_NLTYPE_UNLABELED:
-			ret_val = netlbl_domhsh_add(entry);
-			break;
-		case NETLBL_NLTYPE_CIPSOV4:
-			if (msg_len < NETLBL_LEN_U32) {
-				ret_val = -EINVAL;
-				goto add_failure;
-			}
-			tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
-			/* We should be holding a rcu_read_lock() here
-			 * while we hold the result but since the entry
-			 * will always be deleted when the CIPSO DOI
-			 * is deleted we aren't going to keep the lock. */
-			rcu_read_lock();
-			entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
-			if (entry->type_def.cipsov4 == NULL) {
-				rcu_read_unlock();
-				ret_val = -EINVAL;
-				goto add_failure;
-			}
-			ret_val = netlbl_domhsh_add(entry);
+		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
+		/* We should be holding a rcu_read_lock() here while we hold
+		 * the result but since the entry will always be deleted when
+		 * the CIPSO DOI is deleted we aren't going to keep the
+		 * lock. */
+		rcu_read_lock();
+		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
+		if (entry->type_def.cipsov4 == NULL) {
 			rcu_read_unlock();
-			break;
-		default:
-			ret_val = -EINVAL;
-		}
-		if (ret_val != 0)
 			goto add_failure;
+		}
+		ret_val = netlbl_domhsh_add(entry);
+		rcu_read_unlock();
+		break;
+	default:
+		goto add_failure;
 	}
+	if (ret_val != 0)
+		goto add_failure;
 
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				NETLBL_E_OK);
 	return 0;
 
 add_failure:
 	if (entry)
 		kfree(entry->domain);
 	kfree(entry);
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
 	return ret_val;
 }
 
@@ -176,90 +155,101 @@ add_failure:
  */
 static int netlbl_mgmt_remove(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret_val = -EINVAL;
-	struct nlattr *msg_ptr = netlbl_netlink_payload_data(skb);
-	int msg_len = netlbl_netlink_payload_len(skb);
-	u32 count;
-	u32 iter;
-	int tmp_size;
-	unsigned char *domain;
-
-	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
-	if (ret_val != 0)
-		goto remove_return;
-
-	if (msg_len < NETLBL_LEN_U32)
-		goto remove_return;
-	count = netlbl_getinc_u32(&msg_ptr, &msg_len);
-
-	for (iter = 0; iter < count && msg_len > 0; iter++) {
-		if (msg_len <= 0) {
-			ret_val = -EINVAL;
-			goto remove_return;
-		}
-		tmp_size = nla_len(msg_ptr);
-		domain = nla_data(msg_ptr);
-		if (tmp_size <= 0 || tmp_size > msg_len ||
-		    domain[tmp_size - 1] != '\0') {
-			ret_val = -EINVAL;
-			goto remove_return;
-		}
-		ret_val = netlbl_domhsh_remove(domain);
-		if (ret_val != 0)
-			goto remove_return;
-		msg_ptr = nla_next(msg_ptr, &msg_len);
-	}
+	char *domain;
 
-	ret_val = 0;
+	if (!info->attrs[NLBL_MGMT_A_DOMAIN])
+		return -EINVAL;
 
-remove_return:
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
-	return ret_val;
+	domain = nla_data(info->attrs[NLBL_MGMT_A_DOMAIN]);
+	return netlbl_domhsh_remove(domain);
 }
 
 /**
- * netlbl_mgmt_list - Handle a LIST message
- * @skb: the NETLINK buffer
- * @info: the Generic NETLINK info block
+ * netlbl_mgmt_listall_cb - netlbl_domhsh_walk() callback for LISTALL
+ * @entry: the domain mapping hash table entry
+ * @arg: the netlbl_domhsh_walk_arg structure
  *
  * Description:
- * Process a user generated LIST message and dumps the domain hash table in a
- * form suitable for use in a kernel generated LIST message.  Returns zero on
- * success, negative values on failure.
+ * This function is designed to be used as a callback to the
+ * netlbl_domhsh_walk() function for use in generating a response for a LISTALL
+ * message.  Returns the size of the message on success, negative values on
+ * failure.
  *
  */
-static int netlbl_mgmt_list(struct sk_buff *skb, struct genl_info *info)
+static int netlbl_mgmt_listall_cb(struct netlbl_dom_map *entry, void *arg)
 {
 	int ret_val = -ENOMEM;
-	struct sk_buff *ans_skb;
-
-	ans_skb = netlbl_domhsh_dump(NLMSG_SPACE(GENL_HDRLEN));
-	if (ans_skb == NULL)
-		goto list_failure;
-	netlbl_netlink_hdr_push(ans_skb,
-				info->snd_pid,
-				0,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_LIST);
+	struct netlbl_domhsh_walk_arg *cb_arg = arg;
+	void *data;
 
-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	data = netlbl_netlink_hdr_put(cb_arg->skb,
+				      NETLINK_CB(cb_arg->nl_cb->skb).pid,
+				      cb_arg->seq,
+				      netlbl_mgmt_gnl_family.id,
+				      NLM_F_MULTI,
+				      NLBL_MGMT_C_LISTALL);
+	if (data == NULL)
+		goto listall_cb_failure;
+
+	ret_val = nla_put_string(cb_arg->skb,
+				 NLBL_MGMT_A_DOMAIN,
+				 entry->domain);
+	if (ret_val != 0)
+		goto listall_cb_failure;
+	ret_val = nla_put_u32(cb_arg->skb, NLBL_MGMT_A_PROTOCOL, entry->type);
 	if (ret_val != 0)
-		goto list_failure;
+		goto listall_cb_failure;
+	switch (entry->type) {
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = nla_put_u32(cb_arg->skb,
+				      NLBL_MGMT_A_CV4DOI,
+				      entry->type_def.cipsov4->doi);
+		if (ret_val != 0)
+			goto listall_cb_failure;
+		break;
+	}
 
-	return 0;
+	cb_arg->seq++;
+	return genlmsg_end(cb_arg->skb, data);
 
-list_failure:
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
+listall_cb_failure:
+	genlmsg_cancel(cb_arg->skb, data);
 	return ret_val;
 }
 
 /**
+ * netlbl_mgmt_listall - Handle a LISTALL message
+ * @skb: the NETLINK buffer
+ * @cb: the NETLINK callback
+ *
+ * Description:
+ * Process a user generated LISTALL message and dumps the domain hash table in
+ * a form suitable for use in a kernel generated LISTALL message.  Returns zero
+ * on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_listall(struct sk_buff *skb,
+			       struct netlink_callback *cb)
+{
+	struct netlbl_domhsh_walk_arg cb_arg;
+	u32 skip_bkt = cb->args[0];
+	u32 skip_chain = cb->args[1];
+
+	cb_arg.nl_cb = cb;
+	cb_arg.skb = skb;
+	cb_arg.seq = cb->nlh->nlmsg_seq;
+
+	netlbl_domhsh_walk(&skip_bkt,
+			   &skip_chain,
+			   netlbl_mgmt_listall_cb,
+			   &cb_arg);
+
+	cb->args[0] = skip_bkt;
+	cb->args[1] = skip_chain;
+	return skb->len;
+}
+
+/**
  * netlbl_mgmt_adddef - Handle an ADDDEF message
  * @skb: the NETLINK buffer
  * @info: the Generic NETLINK info block
@@ -272,68 +262,51 @@ list_failure:
 static int netlbl_mgmt_adddef(struct sk_buff *skb, struct genl_info *info)
 {
 	int ret_val = -EINVAL;
-	struct nlattr *msg_ptr = netlbl_netlink_payload_data(skb);
-	int msg_len = netlbl_netlink_payload_len(skb);
 	struct netlbl_dom_map *entry = NULL;
 	u32 tmp_val;
 
-	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
-	if (ret_val != 0)
-		goto adddef_failure;
-
-	if (msg_len < NETLBL_LEN_U32)
+	if (!info->attrs[NLBL_MGMT_A_PROTOCOL])
 		goto adddef_failure;
-	tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (entry == NULL) {
 		ret_val = -ENOMEM;
 		goto adddef_failure;
 	}
+	entry->type = nla_get_u32(info->attrs[NLBL_MGMT_A_PROTOCOL]);
 
-	entry->type = tmp_val;
 	switch (entry->type) {
 	case NETLBL_NLTYPE_UNLABELED:
 		ret_val = netlbl_domhsh_add_default(entry);
 		break;
 	case NETLBL_NLTYPE_CIPSOV4:
-		if (msg_len < NETLBL_LEN_U32) {
-			ret_val = -EINVAL;
+		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
 			goto adddef_failure;
-		}
-		tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
-		/* We should be holding a rcu_read_lock here while we
-		 * hold the result but since the entry will always be
-		 * deleted when the CIPSO DOI is deleted we are going
-		 * to skip the lock. */
+
+		tmp_val = nla_get_u32(info->attrs[NLBL_MGMT_A_CV4DOI]);
+		/* We should be holding a rcu_read_lock() here while we hold
+		 * the result but since the entry will always be deleted when
+		 * the CIPSO DOI is deleted we aren't going to keep the
+		 * lock. */
 		rcu_read_lock();
 		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
 		if (entry->type_def.cipsov4 == NULL) {
 			rcu_read_unlock();
-			ret_val = -EINVAL;
 			goto adddef_failure;
 		}
 		ret_val = netlbl_domhsh_add_default(entry);
 		rcu_read_unlock();
 		break;
 	default:
-		ret_val = -EINVAL;
+		goto adddef_failure;
 	}
 	if (ret_val != 0)
 		goto adddef_failure;
 
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				NETLBL_E_OK);
 	return 0;
 
 adddef_failure:
 	kfree(entry);
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
 	return ret_val;
 }
 
@@ -349,20 +322,7 @@ adddef_failure:
  */
 static int netlbl_mgmt_removedef(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret_val;
-
-	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
-	if (ret_val != 0)
-		goto removedef_return;
-
-	ret_val = netlbl_domhsh_remove_default();
-
-removedef_return:
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
-	return ret_val;
+	return netlbl_domhsh_remove_default();
 }
 
 /**
@@ -379,85 +339,128 @@ removedef_return:
 static int netlbl_mgmt_listdef(struct sk_buff *skb, struct genl_info *info)
 {
 	int ret_val = -ENOMEM;
-	struct sk_buff *ans_skb;
+	struct sk_buff *ans_skb = NULL;
+	void *data;
+	struct netlbl_dom_map *entry;
 
-	ans_skb = netlbl_domhsh_dump_default(NLMSG_SPACE(GENL_HDRLEN));
+	ans_skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
+		return -ENOMEM;
+	data = netlbl_netlink_hdr_put(ans_skb,
+				      info->snd_pid,
+				      info->snd_seq,
+				      netlbl_mgmt_gnl_family.id,
+				      0,
+				      NLBL_MGMT_C_LISTDEF);
+	if (data == NULL)
 		goto listdef_failure;
-	netlbl_netlink_hdr_push(ans_skb,
-				info->snd_pid,
-				0,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_LISTDEF);
 
-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	rcu_read_lock();
+	entry = netlbl_domhsh_getentry(NULL);
+	if (entry == NULL) {
+		ret_val = -ENOENT;
+		goto listdef_failure_lock;
+	}
+	ret_val = nla_put_u32(ans_skb, NLBL_MGMT_A_PROTOCOL, entry->type);
 	if (ret_val != 0)
-		goto listdef_failure;
+		goto listdef_failure_lock;
+	switch (entry->type) {
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = nla_put_u32(ans_skb,
+				      NLBL_MGMT_A_CV4DOI,
+				      entry->type_def.cipsov4->doi);
+		if (ret_val != 0)
+			goto listdef_failure_lock;
+		break;
+	}
+	rcu_read_unlock();
 
+	genlmsg_end(ans_skb, data);
+
+	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
+	if (ret_val != 0)
+		goto listdef_failure;
 	return 0;
 
+listdef_failure_lock:
+	rcu_read_unlock();
 listdef_failure:
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
+	kfree_skb(ans_skb);
 	return ret_val;
 }
 
 /**
- * netlbl_mgmt_modules - Handle a MODULES message
- * @skb: the NETLINK buffer
- * @info: the Generic NETLINK info block
+ * netlbl_mgmt_protocols_cb - Write an individual PROTOCOL message response
+ * @skb: the skb to write to
+ * @seq: the NETLINK sequence number
+ * @cb: the NETLINK callback
+ * @protocol: the NetLabel protocol to use in the message
  *
  * Description:
- * Process a user generated MODULES message and respond accordingly.
+ * This function is to be used in conjunction with netlbl_mgmt_protocols() to
+ * answer a application's PROTOCOLS message.  Returns the size of the message
+ * on success, negative values on failure.
  *
  */
-static int netlbl_mgmt_modules(struct sk_buff *skb, struct genl_info *info)
+static int netlbl_mgmt_protocols_cb(struct sk_buff *skb,
+				    struct netlink_callback *cb,
+				    u32 protocol)
 {
 	int ret_val = -ENOMEM;
-	size_t data_size;
-	u32 mod_count;
-	struct sk_buff *ans_skb = NULL;
+	void *data;
 
-	/* unlabeled + cipsov4 */
-	mod_count = 2;
+	data = netlbl_netlink_hdr_put(skb,
+				      NETLINK_CB(cb->skb).pid,
+				      cb->nlh->nlmsg_seq,
+				      netlbl_mgmt_gnl_family.id,
+				      NLM_F_MULTI,
+				      NLBL_MGMT_C_PROTOCOLS);
+	if (data == NULL)
+		goto protocols_cb_failure;
 
-	data_size = GENL_HDRLEN + NETLBL_LEN_U32 + mod_count * NETLBL_LEN_U32;
-	ans_skb = netlbl_netlink_alloc_skb(0, data_size, GFP_KERNEL);
-	if (ans_skb == NULL)
-		goto modules_failure;
+	ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL, protocol);
+	if (ret_val != 0)
+		goto protocols_cb_failure;
 
-	if (netlbl_netlink_hdr_put(ans_skb,
-				   info->snd_pid,
-				   0,
-				   netlbl_mgmt_gnl_family.id,
-				   NLBL_MGMT_C_MODULES) == NULL)
-		goto modules_failure;
+	return genlmsg_end(skb, data);
 
-	ret_val = nla_put_u32(ans_skb, NLA_U32, mod_count);
-	if (ret_val != 0)
-		goto modules_failure;
-	ret_val = nla_put_u32(ans_skb, NLA_U32, NETLBL_NLTYPE_UNLABELED);
-	if (ret_val != 0)
-		goto modules_failure;
-	ret_val = nla_put_u32(ans_skb, NLA_U32, NETLBL_NLTYPE_CIPSOV4);
-	if (ret_val != 0)
-		goto modules_failure;
+protocols_cb_failure:
+	genlmsg_cancel(skb, data);
+	return ret_val;
+}
 
-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
-	if (ret_val != 0)
-		goto modules_failure;
+/**
+ * netlbl_mgmt_protocols - Handle a PROTOCOLS message
+ * @skb: the NETLINK buffer
+ * @cb: the NETLINK callback
+ *
+ * Description:
+ * Process a user generated PROTOCOLS message and respond accordingly.
+ *
+ */
+static int netlbl_mgmt_protocols(struct sk_buff *skb,
+				 struct netlink_callback *cb)
+{
+	u32 protos_sent = cb->args[0];
 
-	return 0;
+	if (protos_sent == 0) {
+		if (netlbl_mgmt_protocols_cb(skb,
+					     cb,
+					     NETLBL_NLTYPE_UNLABELED) < 0)
+			goto protocols_return;
+		protos_sent++;
+	}
+	if (protos_sent == 1) {
+		if (netlbl_mgmt_protocols_cb(skb,
+					     cb,
+					     NETLBL_NLTYPE_CIPSOV4) < 0)
+			goto protocols_return;
+		protos_sent++;
+	}
 
-modules_failure:
-	kfree_skb(ans_skb);
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
-	return ret_val;
+protocols_return:
+	cb->args[0] = protos_sent;
+	return skb->len;
 }
 
 /**
@@ -474,35 +477,35 @@ static int netlbl_mgmt_version(struct sk
 {
 	int ret_val = -ENOMEM;
 	struct sk_buff *ans_skb = NULL;
+	void *data;
 
-	ans_skb = netlbl_netlink_alloc_skb(0,
-					   GENL_HDRLEN + NETLBL_LEN_U32,
-					   GFP_KERNEL);
+	ans_skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
-		goto version_failure;
-	if (netlbl_netlink_hdr_put(ans_skb,
-				   info->snd_pid,
-				   0,
-				   netlbl_mgmt_gnl_family.id,
-				   NLBL_MGMT_C_VERSION) == NULL)
+		return -ENOMEM;
+	data = netlbl_netlink_hdr_put(ans_skb,
+				      info->snd_pid,
+				      info->snd_seq,
+				      netlbl_mgmt_gnl_family.id,
+				      0,
+				      NLBL_MGMT_C_VERSION);
+	if (data == NULL)
 		goto version_failure;
 
-	ret_val = nla_put_u32(ans_skb, NLA_U32, NETLBL_PROTO_VERSION);
+	ret_val = nla_put_u32(ans_skb,
+			      NLBL_MGMT_A_VERSION,
+			      NETLBL_PROTO_VERSION);
 	if (ret_val != 0)
 		goto version_failure;
 
-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	genlmsg_end(ans_skb, data);
+
+	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
 	if (ret_val != 0)
 		goto version_failure;
-
 	return 0;
 
 version_failure:
 	kfree_skb(ans_skb);
-	netlbl_netlink_send_ack(info,
-				netlbl_mgmt_gnl_family.id,
-				NLBL_MGMT_C_ACK,
-				-ret_val);
 	return ret_val;
 }
 
@@ -513,35 +516,40 @@ version_failure:
 
 static struct genl_ops netlbl_mgmt_genl_c_add = {
 	.cmd = NLBL_MGMT_C_ADD,
-	.flags = 0,
+	.flags = GENL_ADMIN_PERM,
+	.policy = netlbl_mgmt_genl_policy,
 	.doit = netlbl_mgmt_add,
 	.dumpit = NULL,
 };
 
 static struct genl_ops netlbl_mgmt_genl_c_remove = {
 	.cmd = NLBL_MGMT_C_REMOVE,
-	.flags = 0,
+	.flags = GENL_ADMIN_PERM,
+	.policy = netlbl_mgmt_genl_policy,
 	.doit = netlbl_mgmt_remove,
 	.dumpit = NULL,
 };
 
-static struct genl_ops netlbl_mgmt_genl_c_list = {
-	.cmd = NLBL_MGMT_C_LIST,
+static struct genl_ops netlbl_mgmt_genl_c_listall = {
+	.cmd = NLBL_MGMT_C_LISTALL,
 	.flags = 0,
-	.doit = netlbl_mgmt_list,
-	.dumpit = NULL,
+	.policy = netlbl_mgmt_genl_policy,
+	.doit = NULL,
+	.dumpit = netlbl_mgmt_listall,
 };
 
 static struct genl_ops netlbl_mgmt_genl_c_adddef = {
 	.cmd = NLBL_MGMT_C_ADDDEF,
-	.flags = 0,
+	.flags = GENL_ADMIN_PERM,
+	.policy = netlbl_mgmt_genl_policy,
 	.doit = netlbl_mgmt_adddef,
 	.dumpit = NULL,
 };
 
 static struct genl_ops netlbl_mgmt_genl_c_removedef = {
 	.cmd = NLBL_MGMT_C_REMOVEDEF,
-	.flags = 0,
+	.flags = GENL_ADMIN_PERM,
+	.policy = netlbl_mgmt_genl_policy,
 	.doit = netlbl_mgmt_removedef,
 	.dumpit = NULL,
 };
@@ -549,20 +557,23 @@ static struct genl_ops netlbl_mgmt_genl_
 static struct genl_ops netlbl_mgmt_genl_c_listdef = {
 	.cmd = NLBL_MGMT_C_LISTDEF,
 	.flags = 0,
+	.policy = netlbl_mgmt_genl_policy,
 	.doit = netlbl_mgmt_listdef,
 	.dumpit = NULL,
 };
 
-static struct genl_ops netlbl_mgmt_genl_c_modules = {
-	.cmd = NLBL_MGMT_C_MODULES,
+static struct genl_ops netlbl_mgmt_genl_c_protocols = {
+	.cmd = NLBL_MGMT_C_PROTOCOLS,
 	.flags = 0,
-	.doit = netlbl_mgmt_modules,
-	.dumpit = NULL,
+	.policy = netlbl_mgmt_genl_policy,
+	.doit = NULL,
+	.dumpit = netlbl_mgmt_protocols,
 };
 
 static struct genl_ops netlbl_mgmt_genl_c_version = {
 	.cmd = NLBL_MGMT_C_VERSION,
 	.flags = 0,
+	.policy = netlbl_mgmt_genl_policy,
 	.doit = netlbl_mgmt_version,
 	.dumpit = NULL,
 };
@@ -596,7 +607,7 @@ int netlbl_mgmt_genl_init(void)
 	if (ret_val != 0)
 		return ret_val;
 	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
-				    &netlbl_mgmt_genl_c_list);
+				    &netlbl_mgmt_genl_c_listall);
 	if (ret_val != 0)
 		return ret_val;
 	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
@@ -612,7 +623,7 @@ int netlbl_mgmt_genl_init(void)
 	if (ret_val != 0)
 		return ret_val;
 	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
-				    &netlbl_mgmt_genl_c_modules);
+				    &netlbl_mgmt_genl_c_protocols);
 	if (ret_val != 0)
 		return ret_val;
 	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
Index: net-2.6.19/net/netlabel/netlabel_mgmt.h
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_mgmt.h
+++ net-2.6.19/net/netlabel/netlabel_mgmt.h
@@ -34,212 +34,137 @@
 #include <net/netlabel.h>
 
 /*
- * The following NetLabel payloads are supported by the management interface,
- * all of which are preceeded by the nlmsghdr struct.
- *
- * o ACK:
- *   Sent by the kernel in response to an applications message, applications
- *   should never send this message.
- *
- *   +----------------------+-----------------------+
- *   | seq number (32 bits) | return code (32 bits) |
- *   +----------------------+-----------------------+
- *
- *     seq number:  the sequence number of the original message, taken from the
- *                  nlmsghdr structure
- *     return code: return value, based on errno values
+ * The following NetLabel payloads are supported by the management interface.
  *
  * o ADD:
  *   Sent by an application to add a domain mapping to the NetLabel system.
- *   The kernel should respond with an ACK.
- *
- *   +-------------------+
- *   | domains (32 bits) | ...
- *   +-------------------+
- *
- *     domains: the number of domains in the message
- *
- *   +--------------------------+-------------------------+
- *   | domain string (variable) | protocol type (32 bits) | ...
- *   +--------------------------+-------------------------+
- *
- *   +-------------- ---- --- -- -
- *   | mapping data                ... repeated
- *   +-------------- ---- --- -- -
- *
- *     domain string: the domain string, NULL terminated
- *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
- *     mapping data:  specific to the map type (see below)
  *
- *   NETLBL_NLTYPE_UNLABELED
+ *   Required attributes:
  *
- *     No mapping data for this protocol type.
+ *     NLBL_MGMT_A_DOMAIN
+ *     NLBL_MGMT_A_PROTOCOL
  *
- *   NETLBL_NLTYPE_CIPSOV4
+ *   If using NETLBL_NLTYPE_CIPSOV4 the following attributes are required:
  *
- *   +---------------+
- *   | doi (32 bits) |
- *   +---------------+
+ *     NLBL_MGMT_A_CV4DOI
  *
- *     doi:  the CIPSO DOI value
+ *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
  *
  * o REMOVE:
  *   Sent by an application to remove a domain mapping from the NetLabel
- *   system.  The kernel should ACK this message.
+ *   system.
  *
- *   +-------------------+
- *   | domains (32 bits) | ...
- *   +-------------------+
+ *   Required attributes:
  *
- *     domains: the number of domains in the message
+ *     NLBL_MGMT_A_DOMAIN
  *
- *   +--------------------------+
- *   | domain string (variable) | ...
- *   +--------------------------+
- *
- *     domain string: the domain string, NULL terminated
- *
- * o LIST:
+ * o LISTALL:
  *   This message can be sent either from an application or by the kernel in
- *   response to an application generated LIST message.  When sent by an
- *   application there is no payload.  The kernel should respond to a LIST
- *   message either with a LIST message on success or an ACK message on
- *   failure.
- *
- *   +-------------------+
- *   | domains (32 bits) | ...
- *   +-------------------+
- *
- *     domains: the number of domains in the message
- *
- *   +--------------------------+
- *   | domain string (variable) | ...
- *   +--------------------------+
- *
- *   +-------------------------+-------------- ---- --- -- -
- *   | protocol type (32 bits) | mapping data                ... repeated
- *   +-------------------------+-------------- ---- --- -- -
+ *   response to an application generated LISTALL message.  When sent by an
+ *   application there is no payload and the NLM_F_DUMP flag should be set.
+ *   The kernel should respond with a series of the following messages.
  *
- *     domain string: the domain string, NULL terminated
- *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
- *     mapping data:  specific to the map type (see below)
+ *   Required attributes:
  *
- *   NETLBL_NLTYPE_UNLABELED
+ *     NLBL_MGMT_A_DOMAIN
+ *     NLBL_MGMT_A_PROTOCOL
  *
- *     No mapping data for this protocol type.
+ *   If using NETLBL_NLTYPE_CIPSOV4 the following attributes are required:
  *
- *   NETLBL_NLTYPE_CIPSOV4
+ *     NLBL_MGMT_A_CV4DOI
  *
- *   +----------------+---------------+
- *   | type (32 bits) | doi (32 bits) |
- *   +----------------+---------------+
- *
- *     type: the CIPSO mapping table type (defined in the cipso_ipv4.h header
- *           as CIPSO_V4_MAP_*)
- *     doi:  the CIPSO DOI value
+ *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
  *
  * o ADDDEF:
  *   Sent by an application to set the default domain mapping for the NetLabel
- *   system.  The kernel should respond with an ACK.
- *
- *   +-------------------------+-------------- ---- --- -- -
- *   | protocol type (32 bits) | mapping data                ... repeated
- *   +-------------------------+-------------- ---- --- -- -
- *
- *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
- *     mapping data:  specific to the map type (see below)
+ *   system.
  *
- *   NETLBL_NLTYPE_UNLABELED
+ *   Required attributes:
  *
- *     No mapping data for this protocol type.
+ *     NLBL_MGMT_A_PROTOCOL
  *
- *   NETLBL_NLTYPE_CIPSOV4
+ *   If using NETLBL_NLTYPE_CIPSOV4 the following attributes are required:
  *
- *   +---------------+
- *   | doi (32 bits) |
- *   +---------------+
+ *     NLBL_MGMT_A_CV4DOI
  *
- *     doi:  the CIPSO DOI value
+ *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
  *
  * o REMOVEDEF:
  *   Sent by an application to remove the default domain mapping from the
- *   NetLabel system, there is no payload.  The kernel should ACK this message.
+ *   NetLabel system, there is no payload.
  *
  * o LISTDEF:
  *   This message can be sent either from an application or by the kernel in
  *   response to an application generated LISTDEF message.  When sent by an
- *   application there is no payload.  The kernel should respond to a
- *   LISTDEF message either with a LISTDEF message on success or an ACK message
- *   on failure.
- *
- *   +-------------------------+-------------- ---- --- -- -
- *   | protocol type (32 bits) | mapping data                ... repeated
- *   +-------------------------+-------------- ---- --- -- -
- *
- *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
- *     mapping data:  specific to the map type (see below)
- *
- *   NETLBL_NLTYPE_UNLABELED
+ *   application there is no payload.  On success the kernel should send a
+ *   response using the following format.
  *
- *     No mapping data for this protocol type.
+ *   Required attributes:
  *
- *   NETLBL_NLTYPE_CIPSOV4
+ *     NLBL_MGMT_A_PROTOCOL
  *
- *   +----------------+---------------+
- *   | type (32 bits) | doi (32 bits) |
- *   +----------------+---------------+
+ *   If using NETLBL_NLTYPE_CIPSOV4 the following attributes are required:
  *
- *     type: the CIPSO mapping table type (defined in the cipso_ipv4.h header
- *           as CIPSO_V4_MAP_*)
- *     doi:  the CIPSO DOI value
+ *     NLBL_MGMT_A_CV4DOI
  *
- * o MODULES:
- *   Sent by an application to request a list of configured NetLabel modules
- *   in the kernel.  When sent by an application there is no payload.
+ *   If using NETLBL_NLTYPE_UNLABELED no other attributes are required.
  *
- *   +-------------------+
- *   | modules (32 bits) | ...
- *   +-------------------+
+ * o PROTOCOLS:
+ *   Sent by an application to request a list of configured NetLabel protocols
+ *   in the kernel.  When sent by an application there is no payload and the
+ *   NLM_F_DUMP flag should be set.  The kernel should respond with a series of
+ *   the following messages.
  *
- *     modules: the number of modules in the message, if this is an application
- *              generated message and the value is zero then return a list of
- *              the configured modules
+ *   Required attributes:
  *
- *   +------------------+
- *   | module (32 bits) | ... repeated
- *   +------------------+
- *
- *     module: the module number as defined by NETLBL_NLTYPE_*
+ *     NLBL_MGMT_A_PROTOCOL
  *
  * o VERSION:
- *   Sent by an application to request the NetLabel version string.  When sent
- *   by an application there is no payload.  This message type is also used by
- *   the kernel to respond to an VERSION request.
- *
- *   +-------------------+
- *   | version (32 bits) |
- *   +-------------------+
+ *   Sent by an application to request the NetLabel version.  When sent by an
+ *   application there is no payload.  This message type is also used by the
+ *   kernel to respond to an VERSION request.
+ *
+ *   Required attributes:
  *
- *     version: the protocol version number
+ *     NLBL_MGMT_A_VERSION
  *
  */
 
 /* NetLabel Management commands */
 enum {
 	NLBL_MGMT_C_UNSPEC,
-	NLBL_MGMT_C_ACK,
 	NLBL_MGMT_C_ADD,
 	NLBL_MGMT_C_REMOVE,
-	NLBL_MGMT_C_LIST,
+	NLBL_MGMT_C_LISTALL,
 	NLBL_MGMT_C_ADDDEF,
 	NLBL_MGMT_C_REMOVEDEF,
 	NLBL_MGMT_C_LISTDEF,
-	NLBL_MGMT_C_MODULES,
+	NLBL_MGMT_C_PROTOCOLS,
 	NLBL_MGMT_C_VERSION,
 	__NLBL_MGMT_C_MAX,
 };
 #define NLBL_MGMT_C_MAX (__NLBL_MGMT_C_MAX - 1)
 
+/* NetLabel Management attributes */
+enum {
+	NLBL_MGMT_A_UNSPEC,
+	NLBL_MGMT_A_DOMAIN,
+	/* (NLA_NUL_STRING)
+	 * the NULL terminated LSM domain string */
+	NLBL_MGMT_A_PROTOCOL,
+	/* (NLA_U32)
+	 * the NetLabel protocol type (defined by NETLBL_NLTYPE_*) */
+	NLBL_MGMT_A_VERSION,
+	/* (NLA_U32)
+	 * the NetLabel protocol version number (defined by
+	 * NETLBL_PROTO_VERSION) */
+	NLBL_MGMT_A_CV4DOI,
+	/* (NLA_U32)
+	 * the CIPSOv4 DOI value */
+	__NLBL_MGMT_A_MAX,
+};
+#define NLBL_MGMT_A_MAX (__NLBL_MGMT_A_MAX - 1)
+
 /* NetLabel protocol functions */
 int netlbl_mgmt_genl_init(void);
 
Index: net-2.6.19/net/netlabel/netlabel_unlabeled.c
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_unlabeled.c
+++ net-2.6.19/net/netlabel/netlabel_unlabeled.c
@@ -55,9 +55,13 @@ static struct genl_family netlbl_unlabel
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_UNLABELED_NAME,
 	.version = NETLBL_PROTO_VERSION,
-	.maxattr = 0,
+	.maxattr = NLBL_UNLABEL_A_MAX,
 };
 
+/* NetLabel Netlink attribute policy */
+static struct nla_policy netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1] = {
+	[NLBL_UNLABEL_A_ACPTFLG] = { .type = NLA_U8 },
+};
 
 /*
  * NetLabel Command Handlers
@@ -75,31 +79,18 @@ static struct genl_family netlbl_unlabel
  */
 static int netlbl_unlabel_accept(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret_val;
-	struct nlattr *data = netlbl_netlink_payload_data(skb);
-	u32 value;
-
-	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
-	if (ret_val != 0)
-		return ret_val;
+	int ret_val = -EINVAL;
+	u8 value;
 
-	if (netlbl_netlink_payload_len(skb) == NETLBL_LEN_U32) {
-		value = nla_get_u32(data);
+	if (info->attrs[NLBL_UNLABEL_A_ACPTFLG]) {
+		value = nla_get_u8(info->attrs[NLBL_UNLABEL_A_ACPTFLG]);
 		if (value == 1 || value == 0) {
 			atomic_set(&netlabel_unlabel_accept_flg, value);
-			netlbl_netlink_send_ack(info,
-						netlbl_unlabel_gnl_family.id,
-						NLBL_UNLABEL_C_ACK,
-						NETLBL_E_OK);
-			return 0;
+			ret_val = 0;
 		}
 	}
 
-	netlbl_netlink_send_ack(info,
-				netlbl_unlabel_gnl_family.id,
-				NLBL_UNLABEL_C_ACK,
-				EINVAL);
-	return -EINVAL;
+	return ret_val;
 }
 
 /**
@@ -114,39 +105,39 @@ static int netlbl_unlabel_accept(struct 
  */
 static int netlbl_unlabel_list(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret_val = -ENOMEM;
+	int ret_val = -EINVAL;
 	struct sk_buff *ans_skb;
+	void *data;
 
-	ans_skb = netlbl_netlink_alloc_skb(0,
-					   GENL_HDRLEN + NETLBL_LEN_U32,
-					   GFP_KERNEL);
+	ans_skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
 		goto list_failure;
-
-	if (netlbl_netlink_hdr_put(ans_skb,
-				   info->snd_pid,
-				   0,
-				   netlbl_unlabel_gnl_family.id,
-				   NLBL_UNLABEL_C_LIST) == NULL)
+	data = netlbl_netlink_hdr_put(ans_skb,
+				      info->snd_pid,
+				      info->snd_seq,
+				      netlbl_unlabel_gnl_family.id,
+				      0,
+				      NLBL_UNLABEL_C_LIST);
+	if (data == NULL) {
+		ret_val = -ENOMEM;
 		goto list_failure;
+	}
 
-	ret_val = nla_put_u32(ans_skb,
-			      NLA_U32,
-			      atomic_read(&netlabel_unlabel_accept_flg));
+	ret_val = nla_put_u8(ans_skb,
+			     NLBL_UNLABEL_A_ACPTFLG,
+			     atomic_read(&netlabel_unlabel_accept_flg));
 	if (ret_val != 0)
 		goto list_failure;
 
-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	genlmsg_end(ans_skb, data);
+
+	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
 	if (ret_val != 0)
 		goto list_failure;
-
 	return 0;
 
 list_failure:
-	netlbl_netlink_send_ack(info,
-				netlbl_unlabel_gnl_family.id,
-				NLBL_UNLABEL_C_ACK,
-				-ret_val);
+	kfree(ans_skb);
 	return ret_val;
 }
 
@@ -157,7 +148,8 @@ list_failure:
 
 static struct genl_ops netlbl_unlabel_genl_c_accept = {
 	.cmd = NLBL_UNLABEL_C_ACCEPT,
-	.flags = 0,
+	.flags = GENL_ADMIN_PERM,
+	.policy = netlbl_unlabel_genl_policy,
 	.doit = netlbl_unlabel_accept,
 	.dumpit = NULL,
 };
@@ -165,6 +157,7 @@ static struct genl_ops netlbl_unlabel_ge
 static struct genl_ops netlbl_unlabel_genl_c_list = {
 	.cmd = NLBL_UNLABEL_C_LIST,
 	.flags = 0,
+	.policy = netlbl_unlabel_genl_policy,
 	.doit = netlbl_unlabel_list,
 	.dumpit = NULL,
 };
@@ -218,10 +211,8 @@ int netlbl_unlabel_genl_init(void)
  */
 int netlbl_unlabel_getattr(struct netlbl_lsm_secattr *secattr)
 {
-	if (atomic_read(&netlabel_unlabel_accept_flg) == 1) {
-		memset(secattr, 0, sizeof(*secattr));
-		return 0;
-	}
+	if (atomic_read(&netlabel_unlabel_accept_flg) == 1)
+		return netlbl_secattr_init(secattr);
 
 	return -ENOMSG;
 }
Index: net-2.6.19/net/netlabel/netlabel_unlabeled.h
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_unlabeled.h
+++ net-2.6.19/net/netlabel/netlabel_unlabeled.h
@@ -36,56 +36,47 @@
 /*
  * The following NetLabel payloads are supported by the Unlabeled subsystem.
  *
- * o ACK:
- *   Sent by the kernel in response to an applications message, applications
- *   should never send this message.
- *
- *   +----------------------+-----------------------+
- *   | seq number (32 bits) | return code (32 bits) |
- *   +----------------------+-----------------------+
- *
- *     seq number:  the sequence number of the original message, taken from the
- *                  nlmsghdr structure
- *     return code: return value, based on errno values
- *
  * o ACCEPT
  *   This message is sent from an application to specify if the kernel should
  *   allow unlabled packets to pass if they do not match any of the static
  *   mappings defined in the unlabeled module.
  *
- *   +-----------------+
- *   | allow (32 bits) |
- *   +-----------------+
+ *   Required attributes:
  *
- *     allow: if true (1) then allow the packets to pass, if false (0) then
- *            reject the packets
+ *     NLBL_UNLABEL_A_ACPTFLG
  *
  * o LIST
  *   This message can be sent either from an application or by the kernel in
  *   response to an application generated LIST message.  When sent by an
  *   application there is no payload.  The kernel should respond to a LIST
- *   message either with a LIST message on success or an ACK message on
- *   failure.
+ *   message with a LIST message on success.
  *
- *   +-----------------------+
- *   | accept flag (32 bits) |
- *   +-----------------------+
+ *   Required attributes:
  *
- *     accept flag: if true (1) then unlabeled packets are allowed to pass,
- *                  if false (0) then unlabeled packets are rejected
+ *     NLBL_UNLABEL_A_ACPTFLG
  *
  */
 
 /* NetLabel Unlabeled commands */
 enum {
 	NLBL_UNLABEL_C_UNSPEC,
-	NLBL_UNLABEL_C_ACK,
 	NLBL_UNLABEL_C_ACCEPT,
 	NLBL_UNLABEL_C_LIST,
 	__NLBL_UNLABEL_C_MAX,
 };
 #define NLBL_UNLABEL_C_MAX (__NLBL_UNLABEL_C_MAX - 1)
 
+/* NetLabel Unlabeled attributes */
+enum {
+	NLBL_UNLABEL_A_UNSPEC,
+	NLBL_UNLABEL_A_ACPTFLG,
+	/* (NLA_U8)
+	 * if true then unlabeled packets are allowed to pass, else unlabeled
+	 * packets are rejected */
+	__NLBL_UNLABEL_A_MAX,
+};
+#define NLBL_UNLABEL_A_MAX (__NLBL_UNLABEL_A_MAX - 1)
+
 /* NetLabel protocol functions */
 int netlbl_unlabel_genl_init(void);
 

--
paul moore
linux security @ hp
