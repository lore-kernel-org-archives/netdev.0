From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH libnftnl] table: add netdev family support
Date: Mon, 25 May 2015 14:46:43 +0200
Message-ID: <1432558004-13481-5-git-send-email-pablo@netfilter.org>
References: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56571 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbbEYMlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 08:41:55 -0400
In-Reply-To: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the new 'netdev' family tables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/buffer.h                    |    1 +
 include/libnftnl/table.h            |    1 +
 include/linux/netfilter.h           |    8 ++++++++
 include/linux/netfilter/nf_tables.h |    2 ++
 src/chain.c                         |    6 ++++++
 src/table.c                         |   37 +++++++++++++++++++++++++++++++++--
 6 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/include/buffer.h b/include/buffer.h
index 52942ed..38b6136 100644
--- a/include/buffer.h
+++ b/include/buffer.h
@@ -41,6 +41,7 @@ int nft_buf_reg(struct nft_buf *b, int type, union nft_data_reg *reg,
 #define CHAIN			"chain"
 #define CODE			"code"
 #define DATA			"data"
+#define DEVICE			"device"
 #define DIR			"dir"
 #define DREG			"dreg"
 #define EXTHDR_TYPE		"exthdr_type"
diff --git a/include/libnftnl/table.h b/include/libnftnl/table.h
index fac79e7..16df5fa 100644
--- a/include/libnftnl/table.h
+++ b/include/libnftnl/table.h
@@ -22,6 +22,7 @@ enum {
 	NFT_TABLE_ATTR_FAMILY,
 	NFT_TABLE_ATTR_FLAGS,
 	NFT_TABLE_ATTR_USE,
+	NFT_TABLE_ATTR_DEV,
 	__NFT_TABLE_ATTR_MAX
 };
 #define NFT_TABLE_ATTR_MAX (__NFT_TABLE_ATTR_MAX - 1)
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index be0bc18..18075f9 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -32,6 +32,7 @@
 #define NF_DROP_ERR(x) (((-x) << 16) | NF_DROP)
 
 /* only for userspace compatibility */
+#ifndef __KERNEL__
 /* Generic cache responses from hook functions.
    <= 0x2000 is used for protocol-flags. */
 #define NFC_UNKNOWN 0x4000
@@ -39,6 +40,7 @@
 
 /* NF_VERDICT_BITS should be 8 now, but userspace might break if this changes */
 #define NF_VERDICT_BITS 16
+#endif
 
 enum nf_inet_hooks {
 	NF_INET_PRE_ROUTING,
@@ -49,11 +51,17 @@ enum nf_inet_hooks {
 	NF_INET_NUMHOOKS
 };
 
+enum nf_dev_hooks {
+	NF_NETDEV_INGRESS,
+	NF_NETDEV_NUMHOOKS
+};
+
 enum {
 	NFPROTO_UNSPEC =  0,
 	NFPROTO_INET   =  1,
 	NFPROTO_IPV4   =  2,
 	NFPROTO_ARP    =  3,
+	NFPROTO_NETDEV =  5,
 	NFPROTO_BRIDGE =  7,
 	NFPROTO_IPV6   = 10,
 	NFPROTO_DECNET = 12,
diff --git a/include/linux/netfilter/nf_tables.h b/include/linux/netfilter/nf_tables.h
index 5fa1cd0..89a671e 100644
--- a/include/linux/netfilter/nf_tables.h
+++ b/include/linux/netfilter/nf_tables.h
@@ -146,12 +146,14 @@ enum nft_table_flags {
  * @NFTA_TABLE_NAME: name of the table (NLA_STRING)
  * @NFTA_TABLE_FLAGS: bitmask of enum nft_table_flags (NLA_U32)
  * @NFTA_TABLE_USE: number of chains in this table (NLA_U32)
+ * @NFTA_TABLE_DEV: net device name (NLA_STRING)
  */
 enum nft_table_attributes {
 	NFTA_TABLE_UNSPEC,
 	NFTA_TABLE_NAME,
 	NFTA_TABLE_FLAGS,
 	NFTA_TABLE_USE,
+	NFTA_TABLE_DEV,
 	__NFTA_TABLE_MAX
 };
 #define NFTA_TABLE_MAX		(__NFTA_TABLE_MAX - 1)
diff --git a/src/chain.c b/src/chain.c
index 84851e0..74e5925 100644
--- a/src/chain.c
+++ b/src/chain.c
@@ -76,6 +76,12 @@ static const char *nft_hooknum2str(int family, int hooknum)
 			return "forward";
 		}
 		break;
+	case NFPROTO_NETDEV:
+		switch (hooknum) {
+		case NF_NETDEV_INGRESS:
+			return "ingress";
+		}
+		break;
 	}
 	return "unknown";
 }
diff --git a/src/table.c b/src/table.c
index ab0a8ea..f748d6d 100644
--- a/src/table.c
+++ b/src/table.c
@@ -32,6 +32,7 @@ struct nft_table {
 	const char	*name;
 	uint32_t	family;
 	uint32_t	table_flags;
+	const char	*dev;
 	uint32_t	use;
 	uint32_t	flags;
 };
@@ -74,6 +75,12 @@ void nft_table_attr_unset(struct nft_table *t, uint16_t attr)
 		break;
 	case NFT_TABLE_ATTR_USE:
 		break;
+	case NFT_TABLE_ATTR_DEV:
+		if (t->dev) {
+			xfree(t->dev);
+			t->dev = NULL;
+		}
+		break;
 	}
 	t->flags &= ~(1 << attr);
 }
@@ -108,6 +115,12 @@ void nft_table_attr_set_data(struct nft_table *t, uint16_t attr,
 	case NFT_TABLE_ATTR_USE:
 		t->use = *((uint32_t *)data);
 		break;
+	case NFT_TABLE_ATTR_DEV:
+		if (t->dev)
+			xfree(t->dev);
+
+		t->dev = strdup(data);
+		break;
 	}
 	t->flags |= (1 << attr);
 }
@@ -155,6 +168,8 @@ const void *nft_table_attr_get_data(struct nft_table *t, uint16_t attr,
 	case NFT_TABLE_ATTR_USE:
 		*data_len = sizeof(uint32_t);
 		return &t->use;
+	case NFT_TABLE_ATTR_DEV:
+		return t->dev;
 	}
 	return NULL;
 }
@@ -193,6 +208,8 @@ void nft_table_nlmsg_build_payload(struct nlmsghdr *nlh, const struct nft_table
 		mnl_attr_put_strz(nlh, NFTA_TABLE_NAME, t->name);
 	if (t->flags & (1 << NFT_TABLE_ATTR_FLAGS))
 		mnl_attr_put_u32(nlh, NFTA_TABLE_FLAGS, htonl(t->table_flags));
+	if (t->flags & (1 << NFT_TABLE_ATTR_DEV))
+		mnl_attr_put_str(nlh, NFTA_TABLE_DEV, t->dev);
 }
 EXPORT_SYMBOL(nft_table_nlmsg_build_payload);
 
@@ -206,6 +223,7 @@ static int nft_table_parse_attr_cb(const struct nlattr *attr, void *data)
 
 	switch(type) {
 	case NFTA_TABLE_NAME:
+	case NFTA_TABLE_DEV:
 		if (mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
 			abi_breakage();
 		break;
@@ -240,6 +258,10 @@ int nft_table_nlmsg_parse(const struct nlmsghdr *nlh, struct nft_table *t)
 		t->use = ntohl(mnl_attr_get_u32(tb[NFTA_TABLE_USE]));
 		t->flags |= (1 << NFT_TABLE_ATTR_USE);
 	}
+	if (tb[NFTA_TABLE_DEV]) {
+		t->dev = strdup(mnl_attr_get_str(tb[NFTA_TABLE_DEV]));
+		t->flags |= (1 << NFT_TABLE_ATTR_DEV);
+	}
 
 	t->family = nfg->nfgen_family;
 	t->flags |= (1 << NFT_TABLE_ATTR_FAMILY);
@@ -252,7 +274,7 @@ EXPORT_SYMBOL(nft_table_nlmsg_parse);
 int nft_mxml_table_parse(mxml_node_t *tree, struct nft_table *t,
 			 struct nft_parse_err *err)
 {
-	const char *name;
+	const char *name, *dev;
 	int family;
 	uint32_t flags, use;
 
@@ -270,6 +292,11 @@ int nft_mxml_table_parse(mxml_node_t *tree, struct nft_table *t,
 			       &flags, NFT_TYPE_U32, NFT_XML_MAND, err) == 0)
 		nft_table_attr_set_u32(t, NFT_TABLE_ATTR_FLAGS, flags);
 
+	dev = nft_mxml_str_parse(tree, "device", MXML_DESCEND_FIRST,
+				 NFT_XML_MAND, err);
+	if (dev != NULL)
+		nft_table_attr_set_str(t, NFT_TABLE_ATTR_DEV, dev);
+
 	if (nft_mxml_num_parse(tree, "use", MXML_DESCEND, BASE_DEC,
 			       &use, NFT_TYPE_U32, NFT_XML_MAND, err) == 0)
 		nft_table_attr_set_u32(t, NFT_TABLE_ATTR_USE, use);
@@ -303,7 +330,7 @@ int nft_jansson_parse_table(struct nft_table *t, json_t *tree,
 {
 	json_t *root;
 	uint32_t flags, use;
-	const char *str;
+	const char *str, *dev;
 	int family;
 
 	root = nft_jansson_get_node(tree, "table", err);
@@ -321,6 +348,10 @@ int nft_jansson_parse_table(struct nft_table *t, json_t *tree,
 				  err) == 0)
 		nft_table_attr_set_u32(t, NFT_TABLE_ATTR_FLAGS, flags);
 
+	dev = nft_jansson_parse_str(root, "device", err);
+	if (dev != NULL)
+		nft_table_attr_set_str(t, NFT_TABLE_ATTR_DEV, dev);
+
 	if (nft_jansson_parse_val(root, "use", NFT_TYPE_U32, &use, err) == 0)
 		nft_table_attr_set_u32(t, NFT_TABLE_ATTR_USE, use);
 
@@ -404,6 +435,8 @@ static int nft_table_export(char *buf, size_t size, struct nft_table *t,
 		nft_buf_str(&b, type, nft_family2str(t->family), FAMILY);
 	if (t->flags & (1 << NFT_TABLE_ATTR_FLAGS))
 		nft_buf_u32(&b, type, t->table_flags, FLAGS);
+	if (t->flags & (1 << NFT_TABLE_ATTR_DEV))
+		nft_buf_str(&b, type, t->dev, DEVICE);
 	if (t->flags & (1 << NFT_TABLE_ATTR_USE))
 		nft_buf_u32(&b, type, t->use, USE);
 
-- 
1.7.10.4
