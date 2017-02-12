From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/21] netfilter: nf_tables: add bitmap set type
Date: Sun, 12 Feb 2017 20:42:40 +0100
Message-ID: <1486928573-24773-9-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60440 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751375AbdBLTnR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:17 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 54989BA6F8
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 38514DA84C
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EB35BDA850
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:12 +0100 (CET)
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new bitmap set type. This bitmap uses two bits to
represent one element. These two bits determine the element state in the
current and the future generation that fits into the nf_tables commit
protocol. When dumping elements back to userspace, the two bits are
expanded into a struct nft_set_ext object.

If no NFTA_SET_DESC_SIZE is specified, the existing automatic set
backend selection prefers bitmap over hash in case of keys whose size is
<= 16 bit. If the set size is know, the bitmap set type is selected if
with 16 bit kets and more than 390 elements in the set, otherwise the
hash table set implementation is used.

For 8 bit keys, the bitmap consumes 66 bytes. For 16 bit keys, the
bitmap takes 16388 bytes.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig          |   6 +
 net/netfilter/Makefile         |   1 +
 net/netfilter/nft_set_bitmap.c | 314 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 321 insertions(+)
 create mode 100644 net/netfilter/nft_set_bitmap.c

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index dfbe9deeb8c4..ea479ed43373 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -509,6 +509,12 @@ config NFT_SET_HASH
 	  This option adds the "hash" set type that is used to build one-way
 	  mappings between matchings and actions.
 
+config NFT_SET_BITMAP
+	tristate "Netfilter nf_tables bitmap set module"
+	help
+	  This option adds the "bitmap" set type that is used to build sets
+	  whose keys are smaller or equal to 16 bits.
+
 config NFT_COUNTER
 	tristate "Netfilter nf_tables counter module"
 	help
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 6b3034f12661..c9b78e7b342f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -93,6 +93,7 @@ obj-$(CONFIG_NFT_REJECT) 	+= nft_reject.o
 obj-$(CONFIG_NFT_REJECT_INET)	+= nft_reject_inet.o
 obj-$(CONFIG_NFT_SET_RBTREE)	+= nft_set_rbtree.o
 obj-$(CONFIG_NFT_SET_HASH)	+= nft_set_hash.o
+obj-$(CONFIG_NFT_SET_BITMAP)	+= nft_set_bitmap.o
 obj-$(CONFIG_NFT_COUNTER)	+= nft_counter.o
 obj-$(CONFIG_NFT_LOG)		+= nft_log.o
 obj-$(CONFIG_NFT_MASQ)		+= nft_masq.o
diff --git a/net/netfilter/nft_set_bitmap.c b/net/netfilter/nft_set_bitmap.c
new file mode 100644
index 000000000000..97f9649bcc7e
--- /dev/null
+++ b/net/netfilter/nft_set_bitmap.c
@@ -0,0 +1,314 @@
+/*
+ * Copyright (c) 2017 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+
+/* This bitmap uses two bits to represent one element. These two bits determine
+ * the element state in the current and the future generation.
+ *
+ * An element can be in three states. The generation cursor is represented using
+ * the ^ character, note that this cursor shifts on every succesful transaction.
+ * If no transaction is going on, we observe all elements are in the following
+ * state:
+ *
+ * 11 = this element is active in the current generation. In case of no updates,
+ * ^    it stays active in the next generation.
+ * 00 = this element is inactive in the current generation. In case of no
+ * ^    updates, it stays inactive in the next generation.
+ *
+ * On transaction handling, we observe these two temporary states:
+ *
+ * 01 = this element is inactive in the current generation and it becomes active
+ * ^    in the next one. This happens when the element is inserted but commit
+ *      path has not yet been executed yet, so activation is still pending. On
+ *      transaction abortion, the element is removed.
+ * 10 = this element is active in the current generation and it becomes inactive
+ * ^    in the next one. This happens when the element is deactivated but commit
+ *      path has not yet been executed yet, so removal is still pending. On
+ *      transation abortion, the next generation bit is reset to go back to
+ *      restore its previous state.
+ */
+struct nft_bitmap {
+	u16	bitmap_size;
+	u8	bitmap[];
+};
+
+static inline void nft_bitmap_location(u32 key, u32 *idx, u32 *off)
+{
+	u32 k = (key << 1);
+
+	*idx = k / BITS_PER_BYTE;
+	*off = k % BITS_PER_BYTE;
+}
+
+/* Fetch the two bits that represent the element and check if it is active based
+ * on the generation mask.
+ */
+static inline bool
+nft_bitmap_active(const u8 *bitmap, u32 idx, u32 off, u8 genmask)
+{
+	return (bitmap[idx] & (0x3 << off)) & (genmask << off);
+}
+
+static bool nft_bitmap_lookup(const struct net *net, const struct nft_set *set,
+			      const u32 *key, const struct nft_set_ext **ext)
+{
+	const struct nft_bitmap *priv = nft_set_priv(set);
+	u8 genmask = nft_genmask_cur(net);
+	u32 idx, off;
+
+	nft_bitmap_location(*key, &idx, &off);
+
+	return nft_bitmap_active(priv->bitmap, idx, off, genmask);
+}
+
+static int nft_bitmap_insert(const struct net *net, const struct nft_set *set,
+			     const struct nft_set_elem *elem,
+			     struct nft_set_ext **_ext)
+{
+	struct nft_bitmap *priv = nft_set_priv(set);
+	struct nft_set_ext *ext = elem->priv;
+	u8 genmask = nft_genmask_next(net);
+	u32 idx, off;
+
+	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	if (nft_bitmap_active(priv->bitmap, idx, off, genmask))
+		return -EEXIST;
+
+	/* Enter 01 state. */
+	priv->bitmap[idx] |= (genmask << off);
+
+	return 0;
+}
+
+static void nft_bitmap_remove(const struct net *net,
+			      const struct nft_set *set,
+			      const struct nft_set_elem *elem)
+{
+	struct nft_bitmap *priv = nft_set_priv(set);
+	struct nft_set_ext *ext = elem->priv;
+	u8 genmask = nft_genmask_next(net);
+	u32 idx, off;
+
+	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	/* Enter 00 state. */
+	priv->bitmap[idx] &= ~(genmask << off);
+}
+
+static void nft_bitmap_activate(const struct net *net,
+				const struct nft_set *set,
+				const struct nft_set_elem *elem)
+{
+	struct nft_bitmap *priv = nft_set_priv(set);
+	struct nft_set_ext *ext = elem->priv;
+	u8 genmask = nft_genmask_next(net);
+	u32 idx, off;
+
+	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	/* Enter 11 state. */
+	priv->bitmap[idx] |= (genmask << off);
+}
+
+static bool nft_bitmap_flush(const struct net *net,
+			     const struct nft_set *set, void *ext)
+{
+	struct nft_bitmap *priv = nft_set_priv(set);
+	u8 genmask = nft_genmask_next(net);
+	u32 idx, off;
+
+	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	/* Enter 10 state, similar to deactivation. */
+	priv->bitmap[idx] &= ~(genmask << off);
+
+	return true;
+}
+
+static struct nft_set_ext *nft_bitmap_ext_alloc(const struct nft_set *set,
+						const struct nft_set_elem *elem)
+{
+	struct nft_set_ext_tmpl tmpl;
+	struct nft_set_ext *ext;
+
+	nft_set_ext_prepare(&tmpl);
+	nft_set_ext_add_length(&tmpl, NFT_SET_EXT_KEY, set->klen);
+
+	ext = kzalloc(tmpl.len, GFP_KERNEL);
+	if (!ext)
+		return NULL;
+
+	nft_set_ext_init(ext, &tmpl);
+	memcpy(nft_set_ext_key(ext), elem->key.val.data, set->klen);
+
+	return ext;
+}
+
+static void *nft_bitmap_deactivate(const struct net *net,
+				   const struct nft_set *set,
+				   const struct nft_set_elem *elem)
+{
+	struct nft_bitmap *priv = nft_set_priv(set);
+	u8 genmask = nft_genmask_next(net);
+	struct nft_set_ext *ext;
+	u32 idx, off, key = 0;
+
+	memcpy(&key, elem->key.val.data, set->klen);
+	nft_bitmap_location(key, &idx, &off);
+
+	if (!nft_bitmap_active(priv->bitmap, idx, off, genmask))
+		return NULL;
+
+	/* We have no real set extension since this is a bitmap, allocate this
+	 * dummy object that is released from the commit/abort path.
+	 */
+	ext = nft_bitmap_ext_alloc(set, elem);
+	if (!ext)
+		return NULL;
+
+	/* Enter 10 state. */
+	priv->bitmap[idx] &= ~(genmask << off);
+
+	return ext;
+}
+
+static void nft_bitmap_walk(const struct nft_ctx *ctx,
+			    struct nft_set *set,
+			    struct nft_set_iter *iter)
+{
+	const struct nft_bitmap *priv = nft_set_priv(set);
+	struct nft_set_ext_tmpl tmpl;
+	struct nft_set_elem elem;
+	struct nft_set_ext *ext;
+	int idx, off;
+	u16 key;
+
+	nft_set_ext_prepare(&tmpl);
+	nft_set_ext_add_length(&tmpl, NFT_SET_EXT_KEY, set->klen);
+
+	for (idx = 0; idx < priv->bitmap_size; idx++) {
+		for (off = 0; off < BITS_PER_BYTE; off += 2) {
+			if (iter->count < iter->skip)
+				goto cont;
+
+			if (!nft_bitmap_active(priv->bitmap, idx, off,
+					       iter->genmask))
+				goto cont;
+
+			ext = kzalloc(tmpl.len, GFP_KERNEL);
+			if (!ext) {
+				iter->err = -ENOMEM;
+				return;
+			}
+			nft_set_ext_init(ext, &tmpl);
+			key = ((idx * BITS_PER_BYTE) + off) >> 1;
+			memcpy(nft_set_ext_key(ext), &key, set->klen);
+
+			elem.priv = ext;
+			iter->err = iter->fn(ctx, set, iter, &elem);
+
+			/* On set flush, this dummy extension object is released
+			 * from the commit/abort path.
+			 */
+			if (!iter->flush)
+				kfree(ext);
+
+			if (iter->err < 0)
+				return;
+cont:
+			iter->count++;
+		}
+	}
+}
+
+/* The bitmap size is pow(2, key length in bits) / bits per byte. This is
+ * multiplied by two since each element takes two bits. For 8 bit keys, the
+ * bitmap consumes 66 bytes. For 16 bit keys, 16388 bytes.
+ */
+static inline u32 nft_bitmap_size(u32 klen)
+{
+	return ((2 << ((klen * BITS_PER_BYTE) - 1)) / BITS_PER_BYTE) << 1;
+}
+
+static inline u32 nft_bitmap_total_size(u32 klen)
+{
+	return sizeof(struct nft_bitmap) + nft_bitmap_size(klen);
+}
+
+static unsigned int nft_bitmap_privsize(const struct nlattr * const nla[])
+{
+	u32 klen = ntohl(nla_get_be32(nla[NFTA_SET_KEY_LEN]));
+
+	return nft_bitmap_total_size(klen);
+}
+
+static int nft_bitmap_init(const struct nft_set *set,
+			 const struct nft_set_desc *desc,
+			 const struct nlattr * const nla[])
+{
+	struct nft_bitmap *priv = nft_set_priv(set);
+
+	priv->bitmap_size = nft_bitmap_total_size(set->klen);
+
+	return 0;
+}
+
+static void nft_bitmap_destroy(const struct nft_set *set)
+{
+}
+
+static bool nft_bitmap_estimate(const struct nft_set_desc *desc, u32 features,
+				struct nft_set_estimate *est)
+{
+	/* Make sure bitmaps we don't get bitmaps larger than 16 Kbytes. */
+	if (desc->klen > 2)
+		return false;
+
+	est->size   = nft_bitmap_total_size(desc->klen);
+	est->lookup = NFT_SET_CLASS_O_1;
+	est->space  = NFT_SET_CLASS_O_1;
+
+	return true;
+}
+
+static struct nft_set_ops nft_bitmap_ops __read_mostly = {
+	.privsize	= nft_bitmap_privsize,
+	.estimate	= nft_bitmap_estimate,
+	.init		= nft_bitmap_init,
+	.destroy	= nft_bitmap_destroy,
+	.insert		= nft_bitmap_insert,
+	.remove		= nft_bitmap_remove,
+	.deactivate	= nft_bitmap_deactivate,
+	.flush		= nft_bitmap_flush,
+	.activate	= nft_bitmap_activate,
+	.lookup		= nft_bitmap_lookup,
+	.walk		= nft_bitmap_walk,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_bitmap_module_init(void)
+{
+	return nft_register_set(&nft_bitmap_ops);
+}
+
+static void __exit nft_bitmap_module_exit(void)
+{
+	nft_unregister_set(&nft_bitmap_ops);
+}
+
+module_init(nft_bitmap_module_init);
+module_exit(nft_bitmap_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_SET();
-- 
2.1.4
