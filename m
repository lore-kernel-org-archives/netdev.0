From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 4/9] netfilter: nf_tables: add set extensions
Date: Fri, 30 Jan 2015 07:46:29 +0000
Message-ID: <1422603994-5836-5-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34115 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbbA3Hqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 02:46:49 -0500
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add simple set extension infrastructure for maintaining variable sized
and optional per element data.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tables.h | 109 ++++++++++++++++++++++++++++++++++++++
 net/netfilter/nf_tables_api.c     |  16 ++++++
 2 files changed, 125 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 3ae969e..9f2d073 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -120,6 +120,115 @@ int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
 			   enum nft_data_types type);
 
 /**
+ *	enum nft_set_extensions - set extension type IDs
+ *
+ *	@NFT_SET_EXT_KEY: element key
+ *	@NFT_SET_EXT_DATA: mapping data
+ *	@NFT_SET_EXT_FLAGS: element flags
+ *	@NFT_SET_EXT_NUM: number of extension types
+ */
+enum nft_set_extensions {
+	NFT_SET_EXT_KEY,
+	NFT_SET_EXT_DATA,
+	NFT_SET_EXT_FLAGS,
+	NFT_SET_EXT_NUM
+};
+
+/**
+ *	struct nft_set_ext_type - set extension types
+ *
+ * 	@len: fixed part length of the extension
+ * 	@align: alignment requirements of the extension
+ */
+struct nft_set_ext_type {
+	u8	len;
+	u8	align;
+};
+
+extern const struct nft_set_ext_type nft_set_ext_types[];
+
+static inline u8 nft_set_ext_size(u8 id)
+{
+	return nft_set_ext_types[id].len;
+}
+
+static inline u8 nft_set_ext_offset(u8 size, u8 id)
+{
+	return ALIGN(size, nft_set_ext_types[id].align);
+}
+
+/**
+ *	struct nft_set_ext_tmpl - set extension template
+ *
+ *	@offset: offsets of individual extension types
+ *	@len: length of extension area
+ */
+struct nft_set_ext_tmpl {
+	u8	offset[NFT_SET_EXT_NUM];
+	u8	len;
+};
+
+/**
+ *	struct nft_set_ext - set extensions
+ *
+ *	@offset: offsets of individual extension types
+ *	@data: beginning of extension data
+ */
+struct nft_set_ext {
+	u8	offset[NFT_SET_EXT_NUM];
+	char	data[0];
+};
+
+static inline void nft_set_ext_prepare(struct nft_set_ext_tmpl *tmpl)
+{
+	memset(tmpl, 0, sizeof(*tmpl));
+	tmpl->len = sizeof(struct nft_set_ext);
+}
+
+static inline void nft_set_ext_add(struct nft_set_ext_tmpl *tmpl, u8 id)
+{
+	tmpl->len	 = ALIGN(tmpl->len, nft_set_ext_types[id].align);
+	tmpl->offset[id] = tmpl->len;
+	tmpl->len	+= nft_set_ext_types[id].len;
+}
+
+static inline void nft_set_ext_init(struct nft_set_ext *ext,
+				    const struct nft_set_ext_tmpl *tmpl)
+{
+	memcpy(ext->offset, tmpl->offset, sizeof(ext->offset));
+}
+
+static inline bool __nft_set_ext_exists(const struct nft_set_ext *ext, u8 id)
+{
+	return !!ext->offset[id];
+}
+
+static inline bool nft_set_ext_exists(const struct nft_set_ext *ext, u8 id)
+{
+	return ext && __nft_set_ext_exists(ext, id);
+}
+
+static inline void *nft_set_ext(const struct nft_set_ext *ext, u8 id)
+{
+	return (void *)ext + ext->offset[id];
+}
+
+static inline struct nft_data *nft_set_ext_key(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_KEY);
+}
+
+static inline struct nft_data *nft_set_ext_data(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_DATA);
+}
+
+static inline u8 *nft_set_ext_flags(const struct nft_set_ext *ext)
+{
+	return nft_set_ext(ext, NFT_SET_EXT_FLAGS);
+}
+
+/**
  *	struct nft_set_elem - generic representation of set elements
  *
  *	@cookie: implementation specific element cookie
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 92ba4a0..fbc73a0 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2799,6 +2799,22 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
 		nf_tables_set_destroy(ctx, set);
 }
 
+const struct nft_set_ext_type nft_set_ext_types[] = {
+	[NFT_SET_EXT_KEY]		= {
+		.len	= sizeof(struct nft_data),
+		.align	= __alignof__(struct nft_data),
+	},
+	[NFT_SET_EXT_DATA]		= {
+		.len	= sizeof(struct nft_data),
+		.align	= __alignof__(struct nft_data),
+	},
+	[NFT_SET_EXT_FLAGS]		= {
+		.len	= sizeof(u8),
+		.align	= __alignof__(u8),
+	},
+};
+EXPORT_SYMBOL_GPL(nft_set_ext_types);
+
 /*
  * Set elements
  */
-- 
2.1.0
