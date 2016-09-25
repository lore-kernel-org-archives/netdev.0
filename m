From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/53] netfilter: nf_tables: validate maximum value of u32 netlink attributes
Date: Mon, 26 Sep 2016 01:06:38 +0200
Message-ID: <1474844823-2026-29-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54704 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034762AbcIYXHt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:49 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D9FBAC1092
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CAA22DA81A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 95FE0DA84E
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:45 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Garcia Liebana <nevola@gmail.com>

Fetch value and validate u32 netlink attribute. This validation is
usually required when the u32 netlink attributes are being stored in a
field whose size is smaller.

This patch revisits 4da449ae1df9 ("netfilter: nft_exthdr: Add size check
on u8 nft_exthdr attributes").

Fixes: 96518518cc41 ("netfilter: add nftables")
Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  1 +
 net/netfilter/nf_tables_api.c     | 25 +++++++++++++++++++++++++
 net/netfilter/nft_bitwise.c       |  8 +++++++-
 net/netfilter/nft_byteorder.c     | 15 +++++++++++++--
 net/netfilter/nft_cmp.c           |  3 +++
 net/netfilter/nft_exthdr.c        | 12 +++++++-----
 net/netfilter/nft_immediate.c     |  4 ++++
 7 files changed, 60 insertions(+), 8 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index a7a7cebc8d07..5031e072567b 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -145,6 +145,7 @@ static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
 	return type == NFT_DATA_VERDICT ? NFT_REG_VERDICT : NFT_REG_1 * NFT_REG_SIZE / NFT_REG32_SIZE;
 }
 
+unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest);
 unsigned int nft_parse_register(const struct nlattr *attr);
 int nft_dump_register(struct sk_buff *skb, unsigned int attr, unsigned int reg);
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index bd9715e5ff26..b70d3ea1430e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4410,6 +4410,31 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 }
 
 /**
+ *	nft_parse_u32_check - fetch u32 attribute and check for maximum value
+ *
+ *	@attr: netlink attribute to fetch value from
+ *	@max: maximum value to be stored in dest
+ *	@dest: pointer to the variable
+ *
+ *	Parse, check and store a given u32 netlink attribute into variable.
+ *	This function returns -ERANGE if the value goes over maximum value.
+ *	Otherwise a 0 is returned and the attribute value is stored in the
+ *	destination variable.
+ */
+unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
+{
+	int val;
+
+	val = ntohl(nla_get_be32(attr));
+	if (val > max)
+		return -ERANGE;
+
+	*dest = val;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_parse_u32_check);
+
+/**
  *	nft_parse_register - parse a register value from a netlink attribute
  *
  *	@attr: netlink attribute
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index d71cc18fa35d..31c15ed2e5fc 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -52,6 +52,7 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 {
 	struct nft_bitwise *priv = nft_expr_priv(expr);
 	struct nft_data_desc d1, d2;
+	u32 len;
 	int err;
 
 	if (tb[NFTA_BITWISE_SREG] == NULL ||
@@ -61,7 +62,12 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 	    tb[NFTA_BITWISE_XOR] == NULL)
 		return -EINVAL;
 
-	priv->len  = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
+	err = nft_parse_u32_check(tb[NFTA_BITWISE_LEN], U8_MAX, &len);
+	if (err < 0)
+		return err;
+
+	priv->len = len;
+
 	priv->sreg = nft_parse_register(tb[NFTA_BITWISE_SREG]);
 	err = nft_validate_register_load(priv->sreg, priv->len);
 	if (err < 0)
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index b78c28ba465f..ee63d981268d 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -99,6 +99,7 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 			      const struct nlattr * const tb[])
 {
 	struct nft_byteorder *priv = nft_expr_priv(expr);
+	u32 size, len;
 	int err;
 
 	if (tb[NFTA_BYTEORDER_SREG] == NULL ||
@@ -117,7 +118,12 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 		return -EINVAL;
 	}
 
-	priv->size = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_SIZE]));
+	err = nft_parse_u32_check(tb[NFTA_BYTEORDER_SIZE], U8_MAX, &size);
+	if (err < 0)
+		return err;
+
+	priv->size = size;
+
 	switch (priv->size) {
 	case 2:
 	case 4:
@@ -128,7 +134,12 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 	}
 
 	priv->sreg = nft_parse_register(tb[NFTA_BYTEORDER_SREG]);
-	priv->len  = ntohl(nla_get_be32(tb[NFTA_BYTEORDER_LEN]));
+	err = nft_parse_u32_check(tb[NFTA_BYTEORDER_LEN], U8_MAX, &len);
+	if (err < 0)
+		return err;
+
+	priv->len = len;
+
 	err = nft_validate_register_load(priv->sreg, priv->len);
 	if (err < 0)
 		return err;
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index e25b35d70e4d..2e53739812b1 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -84,6 +84,9 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	if (err < 0)
 		return err;
 
+	if (desc.len > U8_MAX)
+		return -ERANGE;
+
 	priv->op  = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
 	priv->len = desc.len;
 	return 0;
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 82c264e40278..a84cf3d66056 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -59,7 +59,7 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
-	u32 offset, len;
+	u32 offset, len, err;
 
 	if (tb[NFTA_EXTHDR_DREG] == NULL ||
 	    tb[NFTA_EXTHDR_TYPE] == NULL ||
@@ -67,11 +67,13 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 	    tb[NFTA_EXTHDR_LEN] == NULL)
 		return -EINVAL;
 
-	offset = ntohl(nla_get_be32(tb[NFTA_EXTHDR_OFFSET]));
-	len = ntohl(nla_get_be32(tb[NFTA_EXTHDR_LEN]));
+	err = nft_parse_u32_check(tb[NFTA_EXTHDR_OFFSET], U8_MAX, &offset);
+	if (err < 0)
+		return err;
 
-	if (offset > U8_MAX || len > U8_MAX)
-		return -ERANGE;
+	err = nft_parse_u32_check(tb[NFTA_EXTHDR_LEN], U8_MAX, &len);
+	if (err < 0)
+		return err;
 
 	priv->type   = nla_get_u8(tb[NFTA_EXTHDR_TYPE]);
 	priv->offset = offset;
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index db3b746858e3..d17018ff54e6 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -53,6 +53,10 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 			    tb[NFTA_IMMEDIATE_DATA]);
 	if (err < 0)
 		return err;
+
+	if (desc.len > U8_MAX)
+		return -ERANGE;
+
 	priv->dlen = desc.len;
 
 	priv->dreg = nft_parse_register(tb[NFTA_IMMEDIATE_DREG]);
-- 
2.1.4
