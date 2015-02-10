From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH 3/3] nft_hash: introduce init_size set parameter
Date: Mon,  9 Feb 2015 19:48:31 -0500
Message-ID: <1423529311-26050-4-git-send-email-johunt@akamai.com>
References: <1423529311-26050-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay06.akamai.com ([96.6.114.98]:42875 "EHLO
	prod-mail-xrelay06.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756110AbbBJAsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 19:48:52 -0500
In-Reply-To: <1423529311-26050-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently nft_hash is using desc->size to both set a ceiling on the number of
entries a set can have, and as the nelem_hint for rhashtable. This not correct
since nelem_hint defines the # of initial buckets for the set to use. It is not
used to enforce a maximum size on the table. That's done through max_shift.

This creates a new parameter 'init_size' to pass as the nelem_hint to rhashtable
as the # of buckets you would like to initialize the table with.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 include/net/netfilter/nf_tables.h        |    4 +++-
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c            |    4 ++++
 net/netfilter/nft_hash.c                 |    2 +-
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 9eaaa78..2c9130d 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -153,12 +153,14 @@ struct nft_set_iter {
  *
  *	@klen: key length
  *	@dlen: data length
- *	@size: number of set elements
+ *	@size: max number of set elements
+ *	@init_size: initial set size
  */
 struct nft_set_desc {
 	unsigned int		klen;
 	unsigned int		dlen;
 	unsigned int		size;
+	unsigned int		init_size;
 };
 
 /**
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 832bc46..63e53eb 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -230,10 +230,12 @@ enum nft_set_policies {
  * enum nft_set_desc_attributes - set element description
  *
  * @NFTA_SET_DESC_SIZE: number of elements in set (NLA_U32)
+ * @NFTA_SET_DESC_INIT_SIZE: initial set size (NLA_U32)
  */
 enum nft_set_desc_attributes {
 	NFTA_SET_DESC_UNSPEC,
 	NFTA_SET_DESC_SIZE,
+	NFTA_SET_DESC_INIT_SIZE,
 	__NFTA_SET_DESC_MAX
 };
 #define NFTA_SET_DESC_MAX	(__NFTA_SET_DESC_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 199fd0f..275f41b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2211,6 +2211,7 @@ static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
 
 static const struct nla_policy nft_set_desc_policy[NFTA_SET_DESC_MAX + 1] = {
 	[NFTA_SET_DESC_SIZE]		= { .type = NLA_U32 },
+	[NFTA_SET_DESC_INIT_SIZE]	= { .type = NLA_U32 },
 };
 
 static int nft_ctx_init_from_setattr(struct nft_ctx *ctx,
@@ -2552,6 +2553,9 @@ static int nf_tables_set_desc_parse(const struct nft_ctx *ctx,
 	if (da[NFTA_SET_DESC_SIZE] != NULL)
 		desc->size = ntohl(nla_get_be32(da[NFTA_SET_DESC_SIZE]));
 
+	if (da[NFTA_SET_DESC_INIT_SIZE] != NULL)
+		desc->init_size = ntohl(nla_get_be32(da[NFTA_SET_DESC_INIT_SIZE]));
+
 	return 0;
 }
 
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 08ec179..e03d1c6 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -190,7 +190,7 @@ static int nft_hash_init(const struct nft_set *set,
 {
 	struct rhashtable *priv = nft_set_priv(set);
 	struct rhashtable_params params = {
-		.nelem_hint = desc->size ? : NFT_HASH_ELEMENT_HINT,
+		.nelem_hint = desc->init_size ? : NFT_HASH_ELEMENT_HINT,
 		.head_offset = offsetof(struct nft_hash_elem, node),
 		.key_offset = offsetof(struct nft_hash_elem, key),
 		.key_len = set->klen,
-- 
1.7.9.5
