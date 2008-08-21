From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v3 12/13] cipso: Add support for native local labeling and
	fixup mapping names
Date: Thu, 21 Aug 2008 17:27:09 -0400
Message-ID: <20080821212709.7951.19232.stgit@flek.lan>
References: <20080821210239.7951.59652.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:24102 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874AbYHUV1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:27:14 -0400
In-Reply-To: <20080821210239.7951.59652.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch accomplishes two minor tasks: add a new tag type for local
labeling and rename the CIPSO_V4_MAP_STD define to CIPSO_V4_MAP_TRANS.  The
first change allows CIPSO to support full LSM labels/contexts, not just
MLS attributes.  The second change brings the mapping names inline with
what userspace is using, compatibility is preserved since we don't actually
change the value.

Signed-off-by: XXX
---

 include/net/cipso_ipv4.h         |   13 +++--
 net/ipv4/cipso_ipv4.c            |  107 ++++++++++++++++++++++++++++++++++----
 net/ipv4/ip_options.c            |    2 -
 net/netlabel/netlabel_cipso_v4.c |   14 ++---
 net/netlabel/netlabel_cipso_v4.h |    4 +
 net/netlabel/netlabel_kapi.c     |    4 +
 6 files changed, 118 insertions(+), 26 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index 811febf..9909774 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -45,7 +45,7 @@
 /* known doi values */
 #define CIPSO_V4_DOI_UNKNOWN          0x00000000
 
-/* tag types */
+/* standard tag types */
 #define CIPSO_V4_TAG_INVALID          0
 #define CIPSO_V4_TAG_RBITMAP          1
 #define CIPSO_V4_TAG_ENUM             2
@@ -53,10 +53,14 @@
 #define CIPSO_V4_TAG_PBITMAP          6
 #define CIPSO_V4_TAG_FREEFORM         7
 
+/* non-standard tag types (tags > 127) */
+#define CIPSO_V4_TAG_LOCAL            128
+
 /* doi mapping types */
 #define CIPSO_V4_MAP_UNKNOWN          0
-#define CIPSO_V4_MAP_STD              1
+#define CIPSO_V4_MAP_TRANS            1
 #define CIPSO_V4_MAP_PASS             2
+#define CIPSO_V4_MAP_LOCAL            3
 
 /* limits */
 #define CIPSO_V4_MAX_REM_LVLS         255
@@ -215,7 +219,7 @@ int cipso_v4_skbuff_setattr(struct sk_buff *skb,
 int cipso_v4_skbuff_delattr(struct sk_buff *skb);
 int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 			    struct netlbl_lsm_secattr *secattr);
-int cipso_v4_validate(unsigned char **option);
+int cipso_v4_validate(const struct sk_buff *skb, unsigned char **option);
 #else
 static inline void cipso_v4_error(struct sk_buff *skb,
 				  int error,
@@ -259,7 +263,8 @@ static inline int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 	return -ENOSYS;
 }
 
-static inline int cipso_v4_validate(unsigned char **option)
+static inline int cipso_v4_validate(const struct sk_buff *skb,
+				    unsigned char **option)
 {
 	return -ENOSYS;
 }
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 8387ef4..cc77f12 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -109,6 +109,19 @@ int cipso_v4_rbm_strictvalid = 1;
  * be omitted. */
 #define CIPSO_V4_TAG_RNG_CAT_MAX      8
 
+/* Base length of the local tag (non-standard tag).
+ *  Tag definition (may change between kernel versions)
+ *
+ * 0          8          16         24         32
+ * +----------+----------+----------+----------+
+ * | 10000000 | 00001000 | unused (zero fill)  |
+ * +----------+----------+----------+----------+
+ * |   32-bit secid value (host byte order)    |
+ * +----------+----------+----------+----------+
+ *
+ */
+#define CIPSO_V4_TAG_LOC_BLEN         8
+
 /*
  * Helper Functions
  */
@@ -467,6 +480,10 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
 			if (doi_def->type != CIPSO_V4_MAP_PASS)
 				return -EINVAL;
 			break;
+		case CIPSO_V4_TAG_LOCAL:
+			if (doi_def->type != CIPSO_V4_MAP_LOCAL)
+				return -EINVAL;
+			break;	
 		default:
 			return -EINVAL;
 		}
@@ -502,7 +519,7 @@ void cipso_v4_doi_free(struct cipso_v4_doi *doi_def)
 		return;
 
 	switch (doi_def->type) {
-	case CIPSO_V4_MAP_STD:
+	case CIPSO_V4_MAP_TRANS:
 		kfree(doi_def->map.std->lvl.cipso);
 		kfree(doi_def->map.std->lvl.local);
 		kfree(doi_def->map.std->cat.cipso);
@@ -673,7 +690,7 @@ static int cipso_v4_map_lvl_valid(const struct cipso_v4_doi *doi_def, u8 level)
 	switch (doi_def->type) {
 	case CIPSO_V4_MAP_PASS:
 		return 0;
-	case CIPSO_V4_MAP_STD:
+	case CIPSO_V4_MAP_TRANS:
 		if (doi_def->map.std->lvl.cipso[level] < CIPSO_V4_INV_LVL)
 			return 0;
 		break;
@@ -702,7 +719,7 @@ static int cipso_v4_map_lvl_hton(const struct cipso_v4_doi *doi_def,
 	case CIPSO_V4_MAP_PASS:
 		*net_lvl = host_lvl;
 		return 0;
-	case CIPSO_V4_MAP_STD:
+	case CIPSO_V4_MAP_TRANS:
 		if (host_lvl < doi_def->map.std->lvl.local_size &&
 		    doi_def->map.std->lvl.local[host_lvl] < CIPSO_V4_INV_LVL) {
 			*net_lvl = doi_def->map.std->lvl.local[host_lvl];
@@ -736,7 +753,7 @@ static int cipso_v4_map_lvl_ntoh(const struct cipso_v4_doi *doi_def,
 	case CIPSO_V4_MAP_PASS:
 		*host_lvl = net_lvl;
 		return 0;
-	case CIPSO_V4_MAP_STD:
+	case CIPSO_V4_MAP_TRANS:
 		map_tbl = doi_def->map.std;
 		if (net_lvl < map_tbl->lvl.cipso_size &&
 		    map_tbl->lvl.cipso[net_lvl] < CIPSO_V4_INV_LVL) {
@@ -773,7 +790,7 @@ static int cipso_v4_map_cat_rbm_valid(const struct cipso_v4_doi *doi_def,
 	switch (doi_def->type) {
 	case CIPSO_V4_MAP_PASS:
 		return 0;
-	case CIPSO_V4_MAP_STD:
+	case CIPSO_V4_MAP_TRANS:
 		cipso_cat_size = doi_def->map.std->cat.cipso_size;
 		cipso_array = doi_def->map.std->cat.cipso;
 		for (;;) {
@@ -821,7 +838,7 @@ static int cipso_v4_map_cat_rbm_hton(const struct cipso_v4_doi *doi_def,
 	u32 host_cat_size = 0;
 	u32 *host_cat_array = NULL;
 
-	if (doi_def->type == CIPSO_V4_MAP_STD) {
+	if (doi_def->type == CIPSO_V4_MAP_TRANS) {
 		host_cat_size = doi_def->map.std->cat.local_size;
 		host_cat_array = doi_def->map.std->cat.local;
 	}
@@ -836,7 +853,7 @@ static int cipso_v4_map_cat_rbm_hton(const struct cipso_v4_doi *doi_def,
 		case CIPSO_V4_MAP_PASS:
 			net_spot = host_spot;
 			break;
-		case CIPSO_V4_MAP_STD:
+		case CIPSO_V4_MAP_TRANS:
 			if (host_spot >= host_cat_size)
 				return -EPERM;
 			net_spot = host_cat_array[host_spot];
@@ -882,7 +899,7 @@ static int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
 	u32 net_cat_size = 0;
 	u32 *net_cat_array = NULL;
 
-	if (doi_def->type == CIPSO_V4_MAP_STD) {
+	if (doi_def->type == CIPSO_V4_MAP_TRANS) {
 		net_cat_size = doi_def->map.std->cat.cipso_size;
 		net_cat_array = doi_def->map.std->cat.cipso;
 	}
@@ -902,7 +919,7 @@ static int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
 		case CIPSO_V4_MAP_PASS:
 			host_spot = net_spot;
 			break;
-		case CIPSO_V4_MAP_STD:
+		case CIPSO_V4_MAP_TRANS:
 			if (net_spot >= net_cat_size)
 				return -EPERM;
 			host_spot = net_cat_array[net_spot];
@@ -1484,6 +1501,54 @@ static int cipso_v4_parsetag_rng(const struct cipso_v4_doi *doi_def,
 }
 
 /**
+ * cipso_v4_gentag_loc - Generate a CIPSO local tag (non-standard)
+ * @doi_def: the DOI definition
+ * @secattr: the security attributes
+ * @buffer: the option buffer
+ * @buffer_len: length of buffer in bytes
+ *
+ * Description:
+ * Generate a CIPSO option using the local tag.  Returns the size of the tag
+ * on success, negative values on failure.
+ *
+ */
+static int cipso_v4_gentag_loc(const struct cipso_v4_doi *doi_def,
+			       const struct netlbl_lsm_secattr *secattr,
+			       unsigned char *buffer,
+			       u32 buffer_len)
+{
+	if (!(secattr->flags & NETLBL_SECATTR_SECID))
+		return -EPERM;
+
+	buffer[0] = 0x80;
+	buffer[1] = 0x08;
+	*(u32 *)&buffer[4] = secattr->attr.secid;
+
+	return 8;
+}
+
+/**
+ * cipso_v4_parsetag_loc - Parse a CIPSO local tag
+ * @doi_def: the DOI definition
+ * @tag: the CIPSO tag
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Parse a CIPSO local tag and return the security attributes in @secattr.
+ * Return zero on success, negatives values on failure.
+ *
+ */
+static int cipso_v4_parsetag_loc(const struct cipso_v4_doi *doi_def,
+				 const unsigned char *tag,
+				 struct netlbl_lsm_secattr *secattr)
+{
+	secattr->attr.secid = *(u32 *)&tag[4];
+	secattr->flags |= NETLBL_SECATTR_SECID;
+
+	return 0;
+}
+
+/**
  * cipso_v4_validate - Validate a CIPSO option
  * @option: the start of the option, on error it is set to point to the error
  *
@@ -1502,7 +1567,7 @@ static int cipso_v4_parsetag_rng(const struct cipso_v4_doi *doi_def,
  *   that is unrecognized."
  *
  */
-int cipso_v4_validate(unsigned char **option)
+int cipso_v4_validate(const struct sk_buff *skb, unsigned char **option)
 {
 	unsigned char *opt = *option;
 	unsigned char *tag;
@@ -1610,6 +1675,19 @@ int cipso_v4_validate(unsigned char **option)
 				goto validate_return_locked;
 			}
 			break;
+		case CIPSO_V4_TAG_LOCAL:
+			/* This is a non-standard tag that we only allow for
+			 * local connections, so if the incoming interface is
+			 * not the loopback device drop the packet. */
+			if (!(skb->dev->flags & IFF_LOOPBACK)) {
+				err_offset = opt_iter;
+				goto validate_return_locked;
+			}
+			if (tag_len != 8) {
+				err_offset = opt_iter + 1;
+				goto validate_return_locked;
+			}
+			break;
 		default:
 			err_offset = opt_iter;
 			goto validate_return_locked;
@@ -1712,6 +1790,12 @@ static int cipso_v4_genopt(unsigned char *buf, u32 buf_len,
 						   &buf[CIPSO_V4_HDR_LEN],
 						   buf_len - CIPSO_V4_HDR_LEN);
 			break;
+		case CIPSO_V4_TAG_LOCAL:
+			ret_val = cipso_v4_gentag_loc(doi_def,
+						   secattr,
+						   &buf[CIPSO_V4_HDR_LEN],
+						   buf_len - CIPSO_V4_HDR_LEN);
+			break;
 		default:
 			return -EPERM;
 		}
@@ -1894,6 +1978,9 @@ static int cipso_v4_getattr(const unsigned char *cipso,
 	case CIPSO_V4_TAG_RANGE:
 		ret_val = cipso_v4_parsetag_rng(doi_def, &cipso[6], secattr);
 		break;
+	case CIPSO_V4_TAG_LOCAL:
+		ret_val = cipso_v4_parsetag_loc(doi_def, &cipso[6], secattr);
+		break;
 	}
 	if (ret_val == 0)
 		secattr->type = NETLBL_NLTYPE_CIPSOV4;
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index be3f18a..2c88da6 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -438,7 +438,7 @@ int ip_options_compile(struct net *net,
 				goto error;
 			}
 			opt->cipso = optptr - iph;
-			if (cipso_v4_validate(&optptr)) {
+			if (cipso_v4_validate(skb, &optptr)) {
 				pp_ptr = optptr;
 				goto error;
 			}
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 7eda219..a6dc5d1 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -132,9 +132,9 @@ static int netlbl_cipsov4_add_common(struct genl_info *info,
  * @info: the Generic NETLINK info block
  *
  * Description:
- * Create a new CIPSO_V4_MAP_STD DOI definition based on the given ADD message
- * and add it to the CIPSO V4 engine.  Return zero on success and non-zero on
- * error.
+ * Create a new CIPSO_V4_MAP_TRANS DOI definition based on the given ADD
+ * message and add it to the CIPSO V4 engine.  Return zero on success and
+ * non-zero on error.
  *
  */
 static int netlbl_cipsov4_add_std(struct genl_info *info)
@@ -164,7 +164,7 @@ static int netlbl_cipsov4_add_std(struct genl_info *info)
 		ret_val = -ENOMEM;
 		goto add_std_failure;
 	}
-	doi_def->type = CIPSO_V4_MAP_STD;
+	doi_def->type = CIPSO_V4_MAP_TRANS;
 
 	ret_val = netlbl_cipsov4_add_common(info, doi_def);
 	if (ret_val != 0)
@@ -393,8 +393,8 @@ static int netlbl_cipsov4_add(struct sk_buff *skb, struct genl_info *info)
 
 	type = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_MTYPE]);
 	switch (type) {
-	case CIPSO_V4_MAP_STD:
-		type_str = "std";
+	case CIPSO_V4_MAP_TRANS:
+		type_str = "trans";
 		ret_val = netlbl_cipsov4_add_std(info);
 		break;
 	case CIPSO_V4_MAP_PASS:
@@ -497,7 +497,7 @@ list_start:
 	nla_nest_end(ans_skb, nla_a);
 
 	switch (doi_def->type) {
-	case CIPSO_V4_MAP_STD:
+	case CIPSO_V4_MAP_TRANS:
 		nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSLVLLST);
 		if (nla_a == NULL) {
 			ret_val = -ENOMEM;
diff --git a/net/netlabel/netlabel_cipso_v4.h b/net/netlabel/netlabel_cipso_v4.h
index 220cb9d..fb3957f 100644
--- a/net/netlabel/netlabel_cipso_v4.h
+++ b/net/netlabel/netlabel_cipso_v4.h
@@ -45,7 +45,7 @@
  *     NLBL_CIPSOV4_A_MTYPE
  *     NLBL_CIPSOV4_A_TAGLST
  *
- *   If using CIPSO_V4_MAP_STD the following attributes are required:
+ *   If using CIPSO_V4_MAP_TRANS the following attributes are required:
  *
  *     NLBL_CIPSOV4_A_MLSLVLLST
  *     NLBL_CIPSOV4_A_MLSCATLST
@@ -76,7 +76,7 @@
  *     NLBL_CIPSOV4_A_MTYPE
  *     NLBL_CIPSOV4_A_TAGLST
  *
- *   If using CIPSO_V4_MAP_STD the following attributes are required:
+ *   If using CIPSO_V4_MAP_TRANS the following attributes are required:
  *
  *     NLBL_CIPSOV4_A_MLSLVLLST
  *     NLBL_CIPSOV4_A_MLSCATLST
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index bf0e1b8..7b233da 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -157,8 +157,8 @@ cfg_cipsov4_add_map_return:
 					      audit_info);
 	if (audit_buf != NULL) {
 		switch (doi_type) {
-		case CIPSO_V4_MAP_STD:
-			type_str = "std";
+		case CIPSO_V4_MAP_TRANS:
+			type_str = "trans";
 			break;
 		case CIPSO_V4_MAP_PASS:
 			type_str = "pass";

