From: paul.moore@hp.com
Subject: [PATCH 2/3] NetLabel: add the enumerated tag to the CIPSOv4 protocol
Date: Wed, 29 Nov 2006 13:18:19 -0500
Message-ID: <20061129182854.123650000@hp.com>
References: <20061129181817.505281000@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:53431 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S967520AbWK2S2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 13:28:55 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_tag_2
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Add support for the enumerated tag (tag type #2) to the CIPSOv4 protocol.

The enumerated tag allows for 15 categories to be specified in a CIPSO option,
where each category is an unsigned 16 bit field with a maximum value of 65534.

See Documentation/netlabel/draft-ietf-cipso-ipsecurity-01.txt for more details.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |  233 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 233 insertions(+)

Index: net-2.6.20_netlabel-cats/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.20_netlabel-cats.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.20_netlabel-cats/net/ipv4/cipso_ipv4.c
@@ -459,6 +459,10 @@ int cipso_v4_doi_add(struct cipso_v4_doi
 			if (iter == 0)
 				return -EINVAL;
 			break;
+		case CIPSO_V4_TAG_ENUM:
+			if (doi_def->type != CIPSO_V4_MAP_PASS)
+				return -EINVAL;
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -940,6 +944,107 @@ static int cipso_v4_map_cat_rbm_ntoh(con
 	return -EINVAL;
 }
 
+/**
+ * cipso_v4_map_cat_enum_valid - Checks to see if the categories are valid
+ * @doi_def: the DOI definition
+ * @enumcat: category list
+ * @enumcat_len: length of the category list in bytes
+ *
+ * Description:
+ * Checks the given categories against the given DOI definition and returns a
+ * negative value if any of the categories do not have a valid mapping and a
+ * zero value if all of the categories are valid.
+ *
+ */
+static int cipso_v4_map_cat_enum_valid(const struct cipso_v4_doi *doi_def,
+				       const unsigned char *enumcat,
+				       u32 enumcat_len)
+{
+	u16 cat;
+	int cat_prev = -1;
+	u32 iter;
+
+	if (doi_def->type != CIPSO_V4_MAP_PASS || enumcat_len & 0x01)
+		return -EFAULT;
+
+	for (iter = 0; iter < enumcat_len; iter += 2) {
+		cat = ntohs(*((__be16 *)&enumcat[iter]));
+		if (cat <= cat_prev)
+			return -EFAULT;
+		cat_prev = cat;
+	}
+
+	return 0;
+}
+
+/**
+ * cipso_v4_map_cat_enum_hton - Perform a category mapping from host to network
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
+static int cipso_v4_map_cat_enum_hton(const struct cipso_v4_doi *doi_def,
+				      const struct netlbl_lsm_secattr *secattr,
+				      unsigned char *net_cat,
+				      u32 net_cat_len)
+{
+	int cat = -1;
+	u32 cat_iter = 0;
+
+	for (;;) {
+		cat = netlbl_secattr_catmap_walk(secattr->mls_cat, cat + 1);
+		if (cat < 0)
+			break;
+		if ((cat_iter + 2) > net_cat_len)
+			return -ENOSPC;
+
+		*((__be16 *)&net_cat[cat_iter]) = htons(cat);
+		cat_iter += 2;
+	}
+
+	return cat_iter;
+}
+
+/**
+ * cipso_v4_map_cat_enum_ntoh - Perform a category mapping from network to host
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
+static int cipso_v4_map_cat_enum_ntoh(const struct cipso_v4_doi *doi_def,
+				      const unsigned char *net_cat,
+				      u32 net_cat_len,
+				      struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	u32 iter;
+
+	for (iter = 0; iter < net_cat_len; iter += 2) {
+		ret_val = netlbl_secattr_catmap_setbit(secattr->mls_cat,
+					    ntohs(*((__be16 *)&net_cat[iter])),
+					    GFP_ATOMIC);
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
@@ -1068,6 +1173,99 @@ static int cipso_v4_parsetag_rbm(const s
 }
 
 /**
+ * cipso_v4_gentag_enum - Generate a CIPSO enumerated tag (type #2)
+ * @doi_def: the DOI definition
+ * @secattr: the security attributes
+ * @buffer: the option buffer
+ * @buffer_len: length of buffer in bytes
+ *
+ * Description:
+ * Generate a CIPSO option using the enumerated tag, tag type #2.  Returns the
+ * size of the tag on success, negative values on failure.
+ *
+ */
+static int cipso_v4_gentag_enum(const struct cipso_v4_doi *doi_def,
+				const struct netlbl_lsm_secattr *secattr,
+				unsigned char *buffer,
+				u32 buffer_len)
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
+		ret_val = cipso_v4_map_cat_enum_hton(doi_def,
+						     secattr,
+						     &buffer[4],
+						     buffer_len - 4);
+		if (ret_val < 0)
+			return ret_val;
+
+		tag_len = 4 + ret_val;
+	} else
+		tag_len = 4;
+
+	buffer[0] = 0x02;
+	buffer[1] = tag_len;
+	buffer[3] = level;
+
+	return tag_len;
+}
+
+/**
+ * cipso_v4_parsetag_enum - Parse a CIPSO enumerated tag
+ * @doi_def: the DOI definition
+ * @tag: the CIPSO tag
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Parse a CIPSO enumerated tag (tag type #2) and return the security
+ * attributes in @secattr.  Return zero on success, negatives values on
+ * failure.
+ *
+ */
+static int cipso_v4_parsetag_enum(const struct cipso_v4_doi *doi_def,
+				  const unsigned char *tag,
+				  struct netlbl_lsm_secattr *secattr)
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
+		ret_val = cipso_v4_map_cat_enum_ntoh(doi_def,
+						     &tag[4],
+						     tag_len - 4,
+						     secattr);
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
@@ -1156,6 +1354,25 @@ int cipso_v4_validate(unsigned char **op
 				}
 			}
 			break;
+		case CIPSO_V4_TAG_ENUM:
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
+			    cipso_v4_map_cat_enum_valid(doi_def,
+							&tag[4],
+							tag_len - 4) < 0) {
+				err_offset = opt_iter + 4;
+				goto validate_return_locked;
+			}
+			break;
 		default:
 			err_offset = opt_iter;
 			goto validate_return_locked;
@@ -1269,6 +1486,12 @@ int cipso_v4_socket_setattr(const struct
 						   &buf[CIPSO_V4_HDR_LEN],
 						   buf_len - CIPSO_V4_HDR_LEN);
 			break;
+		case CIPSO_V4_TAG_ENUM:
+			ret_val = cipso_v4_gentag_enum(doi_def,
+						   secattr,
+						   &buf[CIPSO_V4_HDR_LEN],
+						   buf_len - CIPSO_V4_HDR_LEN);
+			break;
 		default:
 			ret_val = -EPERM;
 			goto socket_setattr_failure;
@@ -1365,6 +1588,11 @@ int cipso_v4_sock_getattr(struct sock *s
 						&cipso_ptr[6],
 						secattr);
 		break;
+	case CIPSO_V4_TAG_ENUM:
+		ret_val = cipso_v4_parsetag_enum(doi_def,
+						 &cipso_ptr[6],
+						 secattr);
+		break;
 	}
 	rcu_read_unlock();
 
@@ -1431,6 +1659,11 @@ int cipso_v4_skbuff_getattr(const struct
 						&cipso_ptr[6],
 						secattr);
 		break;
+	case CIPSO_V4_TAG_ENUM:
+		ret_val = cipso_v4_parsetag_enum(doi_def,
+						 &cipso_ptr[6],
+						 secattr);
+		break;
 	}
 
 skbuff_getattr_return:

--
paul moore
linux security @ hp
