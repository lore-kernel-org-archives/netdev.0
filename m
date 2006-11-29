From: paul.moore@hp.com
Subject: [PATCH 3/3] NetLabel: add the ranged tag to the CIPSOv4 protocol
Date: Wed, 29 Nov 2006 13:18:20 -0500
Message-ID: <20061129182854.816890000@hp.com>
References: <20061129181817.505281000@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:40870 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S967522AbWK2S25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 13:28:57 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_tag_5
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Add support for the ranged tag (tag type #5) to the CIPSOv4 protocol.

The ranged tag allows for seven, or eight if zero is the lowest category,
category ranges to be specified in a CIPSO option.  Each range is specified by
two unsigned 16 bit fields, each with a maximum value of 65534.  The two values
specify the start and end of the category range; if the start of the category
range is zero then it is omitted.

See Documentation/netlabel/draft-ietf-cipso-ipsecurity-01.txt for more details.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |  268 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 268 insertions(+)

Index: net-2.6.20_netlabel-cats/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.20_netlabel-cats.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.20_netlabel-cats/net/ipv4/cipso_ipv4.c
@@ -455,6 +455,10 @@ int cipso_v4_doi_add(struct cipso_v4_doi
 		switch (doi_def->tags[iter]) {
 		case CIPSO_V4_TAG_RBITMAP:
 			break;
+		case CIPSO_V4_TAG_RANGE:
+			if (doi_def->type != CIPSO_V4_MAP_PASS)
+				return -EINVAL;
+			break;
 		case CIPSO_V4_TAG_INVALID:
 			if (iter == 0)
 				return -EINVAL;
@@ -1045,6 +1049,148 @@ static int cipso_v4_map_cat_enum_ntoh(co
 	return 0;
 }
 
+/**
+ * cipso_v4_map_cat_rng_valid - Checks to see if the categories are valid
+ * @doi_def: the DOI definition
+ * @rngcat: category list
+ * @rngcat_len: length of the category list in bytes
+ *
+ * Description:
+ * Checks the given categories against the given DOI definition and returns a
+ * negative value if any of the categories do not have a valid mapping and a
+ * zero value if all of the categories are valid.
+ *
+ */
+static int cipso_v4_map_cat_rng_valid(const struct cipso_v4_doi *doi_def,
+				      const unsigned char *rngcat,
+				      u32 rngcat_len)
+{
+	u16 cat_high;
+	u16 cat_low;
+	u32 cat_prev = CIPSO_V4_MAX_REM_CATS + 1;
+	u32 iter;
+
+	if (doi_def->type != CIPSO_V4_MAP_PASS || rngcat_len & 0x01)
+		return -EFAULT;
+
+	for (iter = 0; iter < rngcat_len; iter += 4) {
+		cat_high = ntohs(*((__be16 *)&rngcat[iter]));
+		if ((iter + 4) <= rngcat_len)
+			cat_low = ntohs(*((__be16 *)&rngcat[iter + 2]));
+		else
+			cat_low = 0;
+
+		if (cat_high > cat_prev)
+			return -EFAULT;
+
+		cat_prev = cat_low;
+	}
+
+	return 0;
+}
+
+/**
+ * cipso_v4_map_cat_rng_hton - Perform a category mapping from host to network
+ * @doi_def: the DOI definition
+ * @secattr: the security attributes
+ * @net_cat: the zero'd out category list in network/CIPSO format
+ * @net_cat_len: the length of the CIPSO category list in bytes
+ *
+ * Description:
+ * Perform a label mapping to translate a local MLS category bitmap to the
+ * correct CIPSO category list using the given DOI definition.   Returns the
+ * size in bytes of the network category bitmap on success, negative values
+ * otherwise.
+ *
+ */
+static int cipso_v4_map_cat_rng_hton(const struct cipso_v4_doi *doi_def,
+				     const struct netlbl_lsm_secattr *secattr,
+				     unsigned char *net_cat,
+				     u32 net_cat_len)
+{
+	/* The constant '16' is not random, it is the maximum number of
+	 * high/low category range pairs as permitted by the CIPSO draft based
+	 * on a maximum IPv4 header length of 60 bytes - the BUG_ON() assertion
+	 * does a sanity check to make sure we don't overflow the array. */
+	int iter = -1;
+	u16 array[16];
+	u32 array_cnt = 0;
+	u32 cat_size = 0;
+
+	BUG_ON(net_cat_len > 30);
+
+	for (;;) {
+		iter = netlbl_secattr_catmap_walk(secattr->mls_cat, iter + 1);
+		if (iter < 0)
+			break;
+		cat_size += (iter == 0 ? 0 : sizeof(u16));
+		if (cat_size > net_cat_len)
+			return -ENOSPC;
+		array[array_cnt++] = iter;
+
+		iter = netlbl_secattr_catmap_walk_rng(secattr->mls_cat, iter);
+		if (iter < 0)
+			return -EFAULT;
+		cat_size += sizeof(u16);
+		if (cat_size > net_cat_len)
+			return -ENOSPC;
+		array[array_cnt++] = iter;
+	}
+
+	for (iter = 0; array_cnt > 0;) {
+		*((__be16 *)&net_cat[iter]) = htons(array[--array_cnt]);
+		iter += 2;
+		array_cnt--;
+		if (array[array_cnt] != 0) {
+			*((__be16 *)&net_cat[iter]) = htons(array[array_cnt]);
+			iter += 2;
+		}
+	}
+
+	return cat_size;
+}
+
+/**
+ * cipso_v4_map_cat_rng_ntoh - Perform a category mapping from network to host
+ * @doi_def: the DOI definition
+ * @net_cat: the category list in network/CIPSO format
+ * @net_cat_len: the length of the CIPSO bitmap in bytes
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Perform a label mapping to translate a CIPSO category list to the correct
+ * local MLS category bitmap using the given DOI definition.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static int cipso_v4_map_cat_rng_ntoh(const struct cipso_v4_doi *doi_def,
+				     const unsigned char *net_cat,
+				     u32 net_cat_len,
+				     struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	u32 net_iter;
+	u16 cat_low;
+	u16 cat_high;
+
+	for(net_iter = 0; net_iter < net_cat_len; net_iter += 4) {
+		cat_high = ntohs(*((__be16 *)&net_cat[net_iter]));
+		if ((net_iter + 4) <= net_cat_len)
+			cat_low = ntohs(*((__be16 *)&net_cat[net_iter + 2]));
+		else
+			cat_low = 0;
+
+		ret_val = netlbl_secattr_catmap_setrng(secattr->mls_cat,
+						       cat_low,
+						       cat_high,
+						       GFP_ATOMIC);
+		if (ret_val != 0)
+			return ret_val;
+	}
+
+	return 0;
+}
+
 /*
  * Protocol Handling Functions
  */
@@ -1266,6 +1412,98 @@ static int cipso_v4_parsetag_enum(const 
 }
 
 /**
+ * cipso_v4_gentag_rng - Generate a CIPSO ranged tag (type #5)
+ * @doi_def: the DOI definition
+ * @secattr: the security attributes
+ * @buffer: the option buffer
+ * @buffer_len: length of buffer in bytes
+ *
+ * Description:
+ * Generate a CIPSO option using the ranged tag, tag type #5.  Returns the
+ * size of the tag on success, negative values on failure.
+ *
+ */
+static int cipso_v4_gentag_rng(const struct cipso_v4_doi *doi_def,
+			       const struct netlbl_lsm_secattr *secattr,
+			       unsigned char *buffer,
+			       u32 buffer_len)
+{
+	int ret_val;
+	u32 tag_len;
+	u32 level;
+
+	if (!(secattr->flags & NETLBL_SECATTR_MLS_LVL))
+		return -EPERM;
+
+	ret_val = cipso_v4_map_lvl_hton(doi_def, secattr->mls_lvl, &level);
+	if (ret_val != 0)
+		return ret_val;
+
+	if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
+		ret_val = cipso_v4_map_cat_rng_hton(doi_def,
+						    secattr,
+						    &buffer[4],
+						    buffer_len - 4);
+		if (ret_val < 0)
+			return ret_val;
+
+		tag_len = 4 + ret_val;
+	} else
+		tag_len = 4;
+
+	buffer[0] = 0x05;
+	buffer[1] = tag_len;
+	buffer[3] = level;
+
+	return tag_len;
+}
+
+/**
+ * cipso_v4_parsetag_rng - Parse a CIPSO ranged tag
+ * @doi_def: the DOI definition
+ * @tag: the CIPSO tag
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Parse a CIPSO ranged tag (tag type #5) and return the security attributes
+ * in @secattr.  Return zero on success, negatives values on failure.
+ *
+ */
+static int cipso_v4_parsetag_rng(const struct cipso_v4_doi *doi_def,
+				 const unsigned char *tag,
+				 struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	u8 tag_len = tag[1];
+	u32 level;
+
+	ret_val = cipso_v4_map_lvl_ntoh(doi_def, tag[3], &level);
+	if (ret_val != 0)
+		return ret_val;
+	secattr->mls_lvl = level;
+	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
+
+	if (tag_len > 4) {
+		secattr->mls_cat = netlbl_secattr_catmap_alloc(GFP_ATOMIC);
+		if (secattr->mls_cat == NULL)
+			return -ENOMEM;
+
+		ret_val = cipso_v4_map_cat_rng_ntoh(doi_def,
+						    &tag[4],
+						    tag_len - 4,
+						    secattr);
+		if (ret_val != 0) {
+			netlbl_secattr_catmap_free(secattr->mls_cat);
+			return ret_val;
+		}
+
+		secattr->flags |= NETLBL_SECATTR_MLS_CAT;
+	}
+
+	return 0;
+}
+
+/**
  * cipso_v4_validate - Validate a CIPSO option
  * @option: the start of the option, on error it is set to point to the error
  *
@@ -1373,6 +1611,25 @@ int cipso_v4_validate(unsigned char **op
 				goto validate_return_locked;
 			}
 			break;
+		case CIPSO_V4_TAG_RANGE:
+			if (tag_len < 4) {
+				err_offset = opt_iter + 1;
+				goto validate_return_locked;
+			}
+
+			if (cipso_v4_map_lvl_valid(doi_def,
+						   tag[3]) < 0) {
+				err_offset = opt_iter + 3;
+				goto validate_return_locked;
+			}
+			if (tag_len > 4 &&
+			    cipso_v4_map_cat_rng_valid(doi_def,
+						       &tag[4],
+						       tag_len - 4) < 0) {
+				err_offset = opt_iter + 4;
+				goto validate_return_locked;
+			}
+			break;
 		default:
 			err_offset = opt_iter;
 			goto validate_return_locked;
@@ -1492,6 +1749,12 @@ int cipso_v4_socket_setattr(const struct
 						   &buf[CIPSO_V4_HDR_LEN],
 						   buf_len - CIPSO_V4_HDR_LEN);
 			break;
+		case CIPSO_V4_TAG_RANGE:
+			ret_val = cipso_v4_gentag_rng(doi_def,
+						   secattr,
+						   &buf[CIPSO_V4_HDR_LEN],
+						   buf_len - CIPSO_V4_HDR_LEN);
+			break;
 		default:
 			ret_val = -EPERM;
 			goto socket_setattr_failure;
@@ -1593,6 +1856,11 @@ int cipso_v4_sock_getattr(struct sock *s
 						 &cipso_ptr[6],
 						 secattr);
 		break;
+	case CIPSO_V4_TAG_RANGE:
+		ret_val = cipso_v4_parsetag_rng(doi_def,
+						&cipso_ptr[6],
+						secattr);
+		break;
 	}
 	rcu_read_unlock();
 

--
paul moore
linux security @ hp
