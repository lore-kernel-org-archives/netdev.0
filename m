From: Alexander Aring <alex.aring@gmail.com>
Subject: [RFCv2 bluetooth-next 3/3] 6lowpan: iphc: add support for stateful compression
Date: Tue, 17 Nov 2015 23:33:14 +0100
Message-ID: <1447799594-6050-4-git-send-email-alex.aring@gmail.com>
References: <1447799594-6050-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de, Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:32832 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbbKQWgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 17:36:44 -0500
In-Reply-To: <1447799594-6050-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduce support for IPHC stateful address compression. It
will offer three debugfs per interface entries, which are:

 - dci_table: destination context indentifier table
 - sci_table: source context indentifier table
 - mcast_sci_table: multicast context identifier table

Example to setup a context id:

A "cat /sys/kernel/debug/6lowpan/lowpan0/dci_table" will display all
contexts which are available. Example:

ID ipv6-address/prefix-length                  state
0  0000:0000:0000:0000:0000:0000:0000:0000/000 0
1  0000:0000:0000:0000:0000:0000:0000:0000/000 0
2  0000:0000:0000:0000:0000:0000:0000:0000/000 0
3  0000:0000:0000:0000:0000:0000:0000:0000/000 0
4  0000:0000:0000:0000:0000:0000:0000:0000/000 0
5  0000:0000:0000:0000:0000:0000:0000:0000/000 0
6  0000:0000:0000:0000:0000:0000:0000:0000/000 0
7  0000:0000:0000:0000:0000:0000:0000:0000/000 0
8  0000:0000:0000:0000:0000:0000:0000:0000/000 0
9  0000:0000:0000:0000:0000:0000:0000:0000/000 0
10 0000:0000:0000:0000:0000:0000:0000:0000/000 0
11 0000:0000:0000:0000:0000:0000:0000:0000/000 0
12 0000:0000:0000:0000:0000:0000:0000:0000/000 0
13 0000:0000:0000:0000:0000:0000:0000:0000/000 0
14 0000:0000:0000:0000:0000:0000:0000:0000/000 0
15 0000:0000:0000:0000:0000:0000:0000:0000/000 0

For setting a context e.g. context id 0, context 2001::, prefix-length
64.

Hint: Simple copy one line and then maniuplate it.

echo "0 2001:0000:0000:0000:0000:0000:0000:0000/64 1" >
/sys/kernel/debug/6lowpan/lowpan0/dci_table

The state will display currently if the context is disabled(0) or
enabled(1).

On transmit side:

The IPHC code will automatically search for a context which would be
match for the address. Then it will be use the context which the
best compression, means the longest prefix which match will be used.

Example:

2001::/126 vs 2001::/127 - the 2001::/127 can be full compressed if the
last bit of the address which has the prefix 2001::/127 is the same like
the IID from the Encapsulating Header. A context ID can also be a
2001::1/128, which is then a full ipv6 address.

On Receive side:

If there is a context defined (when CID not available then it's the
default context 0) then it will be used, if the header doesn't set
SAC or DAC bit thens, it will be dropped.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/6lowpan.h   |  62 ++++++
 net/6lowpan/6lowpan_i.h |   3 +
 net/6lowpan/Kconfig     |   1 +
 net/6lowpan/core.c      |  17 ++
 net/6lowpan/debugfs.c   | 109 +++++++++++
 net/6lowpan/iphc.c      | 500 ++++++++++++++++++++++++++++++++++++++++++------
 6 files changed, 635 insertions(+), 57 deletions(-)

diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
index e484898..6e8d30e 100644
--- a/include/net/6lowpan.h
+++ b/include/net/6lowpan.h
@@ -75,6 +75,8 @@
 #define LOWPAN_IPHC_MAX_HC_BUF_LEN	(sizeof(struct ipv6hdr) +	\
 					 LOWPAN_IPHC_MAX_HEADER_LEN +	\
 					 LOWPAN_NHC_MAX_HDR_LEN)
+/* SCI/DCI is 4 bit width, so we have maximum 16 entries */
+#define LOWPAN_IPHC_CI_TABLE_SIZE	(1 << 4)
 
 #define LOWPAN_DISPATCH_IPV6		0x41 /* 01000001 = 65 */
 #define LOWPAN_DISPATCH_IPHC		0x60 /* 011xxxxx = ... */
@@ -98,9 +100,45 @@ enum lowpan_lltypes {
 	LOWPAN_LLTYPE_IEEE802154,
 };
 
+enum lowpan_iphc_ctx_states {
+	LOWPAN_IPHC_CTX_STATE_DISABLED,
+	LOWPAN_IPHC_CTX_STATE_ENABLED,
+
+	__LOWPAN_IPHC_CTX_STATE_INVALID,
+	LOWPAN_IPHC_CTX_STATE_MAX = __LOWPAN_IPHC_CTX_STATE_INVALID - 1,
+};
+
+struct lowpan_iphc_ctx {
+	enum lowpan_iphc_ctx_states state;
+	u8 id;
+	struct in6_addr addr;
+	u8 prefix_len;
+};
+
+struct lowpan_iphc_ctx_ops {
+	bool (*valid_prefix)(const struct lowpan_iphc_ctx *ctx);
+	int (*update)(struct lowpan_iphc_ctx *table,
+		      const struct lowpan_iphc_ctx *ctx);
+	struct lowpan_iphc_ctx *(*get_by_id)(const struct net_device *dev,
+					     struct lowpan_iphc_ctx *table,
+					     u8 id);
+	struct lowpan_iphc_ctx *(*get_by_addr)(const struct net_device *dev,
+					       struct lowpan_iphc_ctx *table,
+					       const struct in6_addr *addr);
+};
+
+struct lowpan_iphc_ctx_table {
+	spinlock_t lock;
+	const struct lowpan_iphc_ctx_ops *ops;
+	struct lowpan_iphc_ctx table[LOWPAN_IPHC_CI_TABLE_SIZE];
+};
+
 struct lowpan_priv {
 	enum lowpan_lltypes lltype;
 	struct dentry *iface_debugfs;
+	struct lowpan_iphc_ctx_table iphc_dci;
+	struct lowpan_iphc_ctx_table iphc_sci;
+	struct lowpan_iphc_ctx_table iphc_mcast_dci;
 
 	/* must be last */
 	u8 priv[0] __aligned(sizeof(void *));
@@ -125,6 +163,30 @@ struct lowpan_802154_cb *lowpan_802154_cb(const struct sk_buff *skb)
 	return (struct lowpan_802154_cb *)skb->cb;
 }
 
+static inline int lowpan_ctx_update(struct lowpan_iphc_ctx_table *t,
+				    const struct lowpan_iphc_ctx *ctx)
+{
+	if (!t->ops->valid_prefix(ctx))
+		return -EINVAL;
+
+	return t->ops->update(t->table, ctx);
+}
+
+static inline struct lowpan_iphc_ctx *
+lowpan_ctx_by_id(const struct net_device *dev, struct lowpan_iphc_ctx_table *t,
+		 u8 id)
+{
+	return t->ops->get_by_id(dev, t->table, id);
+}
+
+static inline struct lowpan_iphc_ctx *
+lowpan_ctx_by_addr(const struct net_device *dev,
+		   struct lowpan_iphc_ctx_table *t,
+		   const struct in6_addr *addr)
+{
+	return t->ops->get_by_addr(dev, t->table, addr);
+}
+
 #ifdef DEBUG
 /* print data in line */
 static inline void raw_dump_inline(const char *caller, char *msg,
diff --git a/net/6lowpan/6lowpan_i.h b/net/6lowpan/6lowpan_i.h
index 33b2605..1312340 100644
--- a/net/6lowpan/6lowpan_i.h
+++ b/net/6lowpan/6lowpan_i.h
@@ -3,6 +3,9 @@
 
 #include <linux/netdevice.h>
 
+extern const struct lowpan_iphc_ctx_ops iphc_ctx_unicast_ops;
+extern const struct lowpan_iphc_ctx_ops iphc_ctx_mcast_ops;
+
 #ifdef CONFIG_6LOWPAN_DEBUGFS
 int lowpan_dev_debugfs_init(struct net_device *dev);
 void lowpan_dev_debugfs_uninit(struct net_device *dev);
diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
index 01c901c..7ecedd7 100644
--- a/net/6lowpan/Kconfig
+++ b/net/6lowpan/Kconfig
@@ -8,6 +8,7 @@ menuconfig 6LOWPAN
 config 6LOWPAN_DEBUGFS
 	bool "6LoWPAN debugfs support"
 	depends on 6LOWPAN
+	depends on DEBUG_FS
 	---help---
 	  This enables 6LoWPAN debugfs support. For example to manipulate
 	  IPHC context information at runtime.
diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
index fe58509..d354c5b 100644
--- a/net/6lowpan/core.c
+++ b/net/6lowpan/core.c
@@ -19,6 +19,8 @@
 
 int lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
 {
+	int i;
+
 	dev->addr_len = EUI64_ADDR_LEN;
 	dev->type = ARPHRD_6LOWPAN;
 	dev->mtu = IPV6_MIN_MTU;
@@ -26,6 +28,21 @@ int lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
 
 	lowpan_priv(dev)->lltype = lltype;
 
+	spin_lock_init(&lowpan_priv(dev)->iphc_dci.lock);
+	lowpan_priv(dev)->iphc_dci.ops = &iphc_ctx_unicast_ops;
+
+	spin_lock_init(&lowpan_priv(dev)->iphc_sci.lock);
+	lowpan_priv(dev)->iphc_sci.ops = &iphc_ctx_unicast_ops;
+
+	spin_lock_init(&lowpan_priv(dev)->iphc_mcast_dci.lock);
+	lowpan_priv(dev)->iphc_mcast_dci.ops = &iphc_ctx_mcast_ops;
+
+	for (i = 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
+		lowpan_priv(dev)->iphc_dci.table[i].id = i;
+		lowpan_priv(dev)->iphc_sci.table[i].id = i;
+		lowpan_priv(dev)->iphc_mcast_dci.table[i].id = i;
+	}
+
 	return lowpan_dev_debugfs_init(dev);
 }
 EXPORT_SYMBOL(lowpan_netdev_setup);
diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c
index b0a26fd..d6481eb 100644
--- a/net/6lowpan/debugfs.c
+++ b/net/6lowpan/debugfs.c
@@ -18,15 +18,124 @@
 
 static struct dentry *lowpan_debugfs;
 
+static int lowpan_context_show(struct seq_file *file, void *offset)
+{
+	struct lowpan_iphc_ctx_table *t = file->private;
+	int i;
+
+	seq_printf(file, "%-2s %-43s %s\n", "ID", "ipv6-address/prefix-length",
+		   "state");
+
+	spin_lock_bh(&t->lock);
+	for (i = 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
+		seq_printf(file,
+			   "%-2d %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%03d %d\n",
+			   t->table[i].id,
+			   be16_to_cpu(t->table[i].addr.s6_addr16[0]),
+			   be16_to_cpu(t->table[i].addr.s6_addr16[1]),
+			   be16_to_cpu(t->table[i].addr.s6_addr16[2]),
+			   be16_to_cpu(t->table[i].addr.s6_addr16[3]),
+			   be16_to_cpu(t->table[i].addr.s6_addr16[4]),
+			   be16_to_cpu(t->table[i].addr.s6_addr16[5]),
+			   be16_to_cpu(t->table[i].addr.s6_addr16[6]),
+			   be16_to_cpu(t->table[i].addr.s6_addr16[7]),
+			   t->table[i].prefix_len, t->table[i].state);
+	}
+	spin_unlock_bh(&t->lock);
+
+	return 0;
+}
+
+static int lowpan_context_dbgfs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, lowpan_context_show, inode->i_private);
+}
+
+static ssize_t lowpan_context_dbgfs_write(struct file *fp,
+					  const char __user *user_buf,
+					  size_t count, loff_t *ppos)
+{
+	char buf[128] = { };
+	struct seq_file *file = fp->private_data;
+	struct lowpan_iphc_ctx_table *t = file->private;
+	struct lowpan_iphc_ctx ctx;
+	int status = count, n, id, state, i, prefix_len, ret;
+	unsigned int addr[8];
+
+	if (copy_from_user(&buf, user_buf, min_t(size_t, sizeof(buf) - 1,
+						 count))) {
+		status = -EFAULT;
+		goto out;
+	}
+
+	n = sscanf(buf, "%d %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%d %d",
+		   &id, &addr[0], &addr[1], &addr[2], &addr[3], &addr[4],
+		   &addr[5], &addr[6], &addr[7], &prefix_len, &state);
+	if (n != 11) {
+		status = -EIO;
+		goto out;
+	}
+
+	if (id > LOWPAN_IPHC_CI_TABLE_SIZE - 1 ||
+	    state > LOWPAN_IPHC_CTX_STATE_MAX || prefix_len > 128) {
+		status = -EINVAL;
+		goto out;
+	}
+
+	ctx.id = id;
+	ctx.state = state;
+	ctx.prefix_len = prefix_len;
+
+	for (i = 0; i < 8; i++)
+		ctx.addr.s6_addr16[i] = cpu_to_be16(addr[i] & 0xffff);
+
+	spin_lock_bh(&t->lock);
+	ret = lowpan_ctx_update(t, &ctx);
+	if (ret < 0)
+		status = ret;
+	spin_unlock_bh(&t->lock);
+
+out:
+	return status;
+}
+
+const struct file_operations lowpan_context_fops = {
+	.open		= lowpan_context_dbgfs_open,
+	.read		= seq_read,
+	.write		= lowpan_context_dbgfs_write,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 int lowpan_dev_debugfs_init(struct net_device *dev)
 {
 	struct lowpan_priv *lpriv = lowpan_priv(dev);
+	static struct dentry *dentry;
 
 	/* creating the root */
 	lpriv->iface_debugfs = debugfs_create_dir(dev->name, lowpan_debugfs);
 	if (!lpriv->iface_debugfs)
 		goto fail;
 
+	dentry = debugfs_create_file("dci_table", 0664, lpriv->iface_debugfs,
+				     &lowpan_priv(dev)->iphc_dci,
+				     &lowpan_context_fops);
+	if (!dentry)
+		goto fail;
+
+	dentry = debugfs_create_file("sci_table", 0664, lpriv->iface_debugfs,
+				     &lowpan_priv(dev)->iphc_sci,
+				     &lowpan_context_fops);
+	if (!dentry)
+		goto fail;
+
+	dentry = debugfs_create_file("mcast_dci_table", 0664,
+				     lpriv->iface_debugfs,
+				     &lowpan_priv(dev)->iphc_mcast_dci,
+				     &lowpan_context_fops);
+	if (!dentry)
+		goto fail;
+
 	return 0;
 
 fail:
diff --git a/net/6lowpan/iphc.c b/net/6lowpan/iphc.c
index 346b5c1..5974ea5 100644
--- a/net/6lowpan/iphc.c
+++ b/net/6lowpan/iphc.c
@@ -56,6 +56,7 @@
 /* special link-layer handling */
 #include <net/mac802154.h>
 
+#include "6lowpan_i.h"
 #include "nhc.h"
 
 /* Values of fields within the IPHC encoding first byte */
@@ -147,6 +148,9 @@
 	 (((a)->s6_addr16[6]) == 0) &&		\
 	 (((a)->s6_addr[14]) == 0))
 
+#define LOWPAN_IPHC_CID_DCI(cid)	(cid & 0x0f)
+#define LOWPAN_IPHC_CID_SCI(cid)	((cid & 0xf0) >> 4)
+
 static inline void iphc_uncompress_eui64_lladdr(struct in6_addr *ipaddr,
 						const void *lladdr)
 {
@@ -259,30 +263,59 @@ static int uncompress_addr(struct sk_buff *skb, const struct net_device *dev,
 /* Uncompress address function for source context
  * based address(non-multicast).
  */
-static int uncompress_context_based_src_addr(struct sk_buff *skb,
-					     struct in6_addr *ipaddr,
-					     u8 address_mode)
+static int uncompress_ctx_addr(struct sk_buff *skb,
+			       const struct net_device *dev,
+			       const struct lowpan_iphc_ctx *ctx,
+			       struct in6_addr *ipaddr, u8 address_mode,
+			       const void *lladdr)
 {
+	bool fail;
+
 	switch (address_mode) {
-	case LOWPAN_IPHC_SAM_00:
-		/* unspec address ::
+	/* SAM and DAM are the same here */
+	case LOWPAN_IPHC_DAM_00:
+		fail = false;
+		/* SAM_00 -> unspec address ::
 		 * Do nothing, address is already ::
+		 *
+		 * DAM 00 -> reserved should never occur.
 		 */
 		break;
 	case LOWPAN_IPHC_SAM_01:
-		/* TODO */
+	case LOWPAN_IPHC_DAM_01:
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[8], 8);
+		ipv6_addr_prefix_cpy(ipaddr, &ctx->addr, ctx->prefix_len);
+		break;
 	case LOWPAN_IPHC_SAM_10:
-		/* TODO */
+	case LOWPAN_IPHC_DAM_10:
+		ipaddr->s6_addr[11] = 0xFF;
+		ipaddr->s6_addr[12] = 0xFE;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[14], 2);
+		ipv6_addr_prefix_cpy(ipaddr, &ctx->addr, ctx->prefix_len);
+		break;
 	case LOWPAN_IPHC_SAM_11:
-		/* TODO */
-		netdev_warn(skb->dev, "SAM value 0x%x not supported\n",
-			    address_mode);
-		return -EINVAL;
+	case LOWPAN_IPHC_DAM_11:
+		fail = false;
+		switch (lowpan_priv(dev)->lltype) {
+		case LOWPAN_LLTYPE_IEEE802154:
+			iphc_uncompress_802154_lladdr(ipaddr, lladdr);
+			break;
+		default:
+			iphc_uncompress_eui64_lladdr(ipaddr, lladdr);
+			break;
+		}
+		ipv6_addr_prefix_cpy(ipaddr, &ctx->addr, ctx->prefix_len);
+		break;
 	default:
 		pr_debug("Invalid sam value: 0x%x\n", address_mode);
 		return -EINVAL;
 	}
 
+	if (fail) {
+		pr_debug("Failed to fetch skb data\n");
+		return -EIO;
+	}
+
 	raw_dump_inline(NULL,
 			"Reconstructed context based ipv6 src addr is",
 			ipaddr->s6_addr, 16);
@@ -346,6 +379,33 @@ static int lowpan_uncompress_multicast_daddr(struct sk_buff *skb,
 	return 0;
 }
 
+static int lowpan_uncompress_multicast_ctx_daddr(struct sk_buff *skb,
+						 struct lowpan_iphc_ctx *ctx,
+						 struct in6_addr *ipaddr,
+						 u8 address_mode)
+{
+	struct in6_addr network_pfx = {};
+	bool fail;
+
+	if (address_mode != LOWPAN_IPHC_DAM_00)
+		return -EINVAL;
+
+	ipaddr->s6_addr[0] = 0xFF;
+	fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[1], 2);
+	fail |= lowpan_fetch_skb(skb, &ipaddr->s6_addr[12], 4);
+	/* take prefix_len and network prefix from the context */
+	ipaddr->s6_addr[3] = ctx->prefix_len;
+	/* get network prefix to copy into multicast address */
+	ipv6_addr_prefix(&network_pfx, &ctx->addr, ctx->prefix_len);
+	/* setting network prefix */
+	memcpy(&ipaddr->s6_addr[4], &network_pfx, 8);
+
+	if (fail < 0)
+		return -EIO;
+
+	return 0;
+}
+
 /* get the ecn values from iphc tf format and set it to ipv6hdr */
 static inline void lowpan_iphc_tf_set_ecn(struct ipv6hdr *hdr, const u8 *tf)
 {
@@ -459,7 +519,8 @@ int lowpan_header_decompress(struct sk_buff *skb, const struct net_device *dev,
 			     const void *daddr, const void *saddr)
 {
 	struct ipv6hdr hdr = {};
-	u8 iphc0, iphc1;
+	struct lowpan_iphc_ctx *ci;
+	u8 iphc0, iphc1, cid = 0;
 	int err;
 
 	raw_dump_table(__func__, "raw skb data dump uncompressed",
@@ -469,12 +530,14 @@ int lowpan_header_decompress(struct sk_buff *skb, const struct net_device *dev,
 	    lowpan_fetch_skb(skb, &iphc1, sizeof(iphc1)))
 		return -EINVAL;
 
-	/* another if the CID flag is set */
-	if (iphc1 & LOWPAN_IPHC_CID)
-		return -ENOTSUPP;
-
 	hdr.version = 6;
 
+	/* default CID = 0, another if the CID flag is set */
+	if (iphc1 & LOWPAN_IPHC_CID) {
+		if (lowpan_fetch_skb(skb, &cid, sizeof(cid)))
+			return -EINVAL;
+	}
+
 	err = lowpan_iphc_tf_decompress(skb, &hdr,
 					iphc0 & LOWPAN_IPHC_TF_MASK);
 	if (err < 0)
@@ -500,10 +563,18 @@ int lowpan_header_decompress(struct sk_buff *skb, const struct net_device *dev,
 	}
 
 	if (iphc1 & LOWPAN_IPHC_SAC) {
-		/* Source address context based uncompression */
+		spin_lock_bh(&lowpan_priv(dev)->iphc_sci.lock);
+		ci = lowpan_ctx_by_id(dev, &lowpan_priv(dev)->iphc_sci,
+				      LOWPAN_IPHC_CID_SCI(cid));
+		if (!ci) {
+			spin_unlock_bh(&lowpan_priv(dev)->iphc_sci.lock);
+			return -EINVAL;
+		}
+
 		pr_debug("SAC bit is set. Handle context based source address.\n");
-		err = uncompress_context_based_src_addr(skb, &hdr.saddr,
-							iphc1 & LOWPAN_IPHC_SAM_MASK);
+		err = uncompress_ctx_addr(skb, dev, ci, &hdr.saddr,
+					  iphc1 & LOWPAN_IPHC_SAM_MASK, saddr);
+		spin_unlock_bh(&lowpan_priv(dev)->iphc_sci.lock);
 	} else {
 		/* Source address uncompression */
 		pr_debug("source address stateless compression\n");
@@ -515,27 +586,54 @@ int lowpan_header_decompress(struct sk_buff *skb, const struct net_device *dev,
 	if (err)
 		return -EINVAL;
 
-	/* check for Multicast Compression */
-	if (iphc1 & LOWPAN_IPHC_M) {
-		if (iphc1 & LOWPAN_IPHC_DAC) {
-			pr_debug("dest: context-based mcast compression\n");
-			/* TODO: implement this */
-		} else {
-			err = lowpan_uncompress_multicast_daddr(skb, &hdr.daddr,
-								iphc1 & LOWPAN_IPHC_DAM_MASK);
+	switch (iphc1 & (LOWPAN_IPHC_M | LOWPAN_IPHC_DAC)) {
+	case LOWPAN_IPHC_M | LOWPAN_IPHC_DAC:
+		spin_lock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
+		ci = lowpan_ctx_by_id(dev, &lowpan_priv(dev)->iphc_mcast_dci,
+				      LOWPAN_IPHC_CID_DCI(cid));
+		if (!ci) {
+			spin_unlock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
+			return -EINVAL;
+		}
 
-			if (err)
-				return -EINVAL;
+		/* multicast with context */
+		pr_debug("dest: context-based mcast compression\n");
+		err = lowpan_uncompress_multicast_ctx_daddr(skb, ci,
+							    &hdr.daddr,
+							    iphc1 & LOWPAN_IPHC_DAM_MASK);
+		spin_unlock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
+		break;
+	case LOWPAN_IPHC_M:
+		/* multicast */
+		err = lowpan_uncompress_multicast_daddr(skb, &hdr.daddr,
+							iphc1 & LOWPAN_IPHC_DAM_MASK);
+		break;
+	case LOWPAN_IPHC_DAC:
+		spin_lock_bh(&lowpan_priv(dev)->iphc_dci.lock);
+		ci = lowpan_ctx_by_id(dev, &lowpan_priv(dev)->iphc_dci,
+				      LOWPAN_IPHC_CID_DCI(cid));
+		if (!ci) {
+			spin_unlock_bh(&lowpan_priv(dev)->iphc_dci.lock);
+			return -EINVAL;
 		}
-	} else {
+
+		/* Destination address context based uncompression */
+		pr_debug("DAC bit is set. Handle context based destination address.\n");
+		err = uncompress_ctx_addr(skb, dev, ci, &hdr.daddr,
+					  iphc1 & LOWPAN_IPHC_DAM_MASK, daddr);
+		spin_unlock_bh(&lowpan_priv(dev)->iphc_dci.lock);
+		break;
+	default:
 		err = uncompress_addr(skb, dev, &hdr.daddr,
 				      iphc1 & LOWPAN_IPHC_DAM_MASK, daddr);
 		pr_debug("dest: stateless compression mode %d dest %pI6c\n",
 			 iphc1 & LOWPAN_IPHC_DAM_MASK, &hdr.daddr);
-		if (err)
-			return -EINVAL;
+		break;
 	}
 
+	if (err)
+		return -EINVAL;
+
 	/* Next header data uncompression */
 	if (iphc0 & LOWPAN_IPHC_NH) {
 		err = lowpan_nhc_do_uncompression(skb, dev, &hdr);
@@ -585,6 +683,60 @@ static const u8 lowpan_iphc_dam_to_sam_value[] = {
 	[LOWPAN_IPHC_DAM_11] = LOWPAN_IPHC_SAM_11,
 };
 
+static u8 lowpan_compress_ctx_addr(u8 **hc_ptr, const struct in6_addr *ipaddr,
+				   const struct lowpan_iphc_ctx *ctx,
+				   const unsigned char *lladdr, bool sam)
+{
+	struct in6_addr tmp = {};
+	u8 dam;
+
+	/* check for SAM/DAM = 11 */
+	memcpy(&tmp.s6_addr[8], lladdr, 8);
+	/* second bit-flip (Universe/Local)
+	 * is done according RFC2464
+	 */
+	tmp.s6_addr[8] ^= 0x02;
+	/* context information are always used */
+	ipv6_addr_prefix_cpy(&tmp, &ctx->addr, ctx->prefix_len);
+	if (ipv6_addr_equal(&tmp, ipaddr)) {
+		dam = LOWPAN_IPHC_DAM_11;
+		goto out;
+	}
+
+	memset(&tmp, 0, sizeof(tmp));
+	/* check for SAM/DAM = 01 */
+	tmp.s6_addr[11] = 0xFF;
+	tmp.s6_addr[12] = 0xFE;
+	memcpy(&tmp.s6_addr[14], &ipaddr->s6_addr[14], 2);
+	/* context information are always used */
+	ipv6_addr_prefix_cpy(&tmp, &ctx->addr, ctx->prefix_len);
+	if (ipv6_addr_equal(&tmp, ipaddr)) {
+		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr[14], 2);
+		dam = LOWPAN_IPHC_DAM_10;
+		goto out;
+	}
+
+	memset(&tmp, 0, sizeof(tmp));
+	/* check for SAM/DAM = 10, should always match */
+	memcpy(&tmp.s6_addr[8], &ipaddr->s6_addr[8], 8);
+	/* context information are always used */
+	ipv6_addr_prefix_cpy(&tmp, &ctx->addr, ctx->prefix_len);
+	if (ipv6_addr_equal(&tmp, ipaddr)) {
+		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr[8], 8);
+		dam = LOWPAN_IPHC_DAM_01;
+		goto out;
+	}
+
+	WARN_ON_ONCE("context found but no address mode matched\n");
+	return -EINVAL;
+out:
+
+	if (sam)
+		return lowpan_iphc_dam_to_sam_value[dam];
+	else
+		return dam;
+}
+
 static u8 lowpan_compress_addr_64(u8 **hc_ptr, const struct in6_addr *ipaddr,
 				  const unsigned char *lladdr, bool sam)
 {
@@ -708,6 +860,21 @@ static u8 lowpan_iphc_tf_compress(u8 **hc_ptr, const struct ipv6hdr *hdr)
 	return val;
 }
 
+static u8 lowpan_iphc_mcast_ctx_addr_compress(u8 **hc_ptr,
+					      const struct lowpan_iphc_ctx *ctx,
+					      const struct in6_addr *ipaddr)
+{
+	u8 data[6];
+
+	/* flags/scope, reserved (RIID) */
+	memcpy(data, &ipaddr->s6_addr[1], 2);
+	/* group ID */
+	memcpy(&data[1], &ipaddr->s6_addr[11], 4);
+	lowpan_push_hc_data(hc_ptr, data, 6);
+
+	return LOWPAN_IPHC_DAM_00;
+}
+
 static u8 lowpan_iphc_mcast_addr_compress(u8 **hc_ptr,
 					  const struct in6_addr *ipaddr)
 {
@@ -742,10 +909,11 @@ static u8 lowpan_iphc_mcast_addr_compress(u8 **hc_ptr,
 int lowpan_header_compress(struct sk_buff *skb, const struct net_device *dev,
 			   const void *daddr, const void *saddr)
 {
-	u8 iphc0, iphc1, *hc_ptr;
+	u8 iphc0, iphc1, *hc_ptr, cid = 0;
 	struct ipv6hdr *hdr;
 	u8 head[LOWPAN_IPHC_MAX_HC_BUF_LEN] = {};
-	int ret, addr_type;
+	struct lowpan_iphc_ctx *dci, *sci, dci_entry, sci_entry;
+	int ret, ipv6_daddr_type, ipv6_saddr_type;
 
 	if (skb->protocol != htons(ETH_P_IPV6))
 		return -EINVAL;
@@ -769,14 +937,47 @@ int lowpan_header_compress(struct sk_buff *skb, const struct net_device *dev,
 	iphc0 = LOWPAN_DISPATCH_IPHC;
 	iphc1 = 0;
 
-	/* TODO: context lookup */
-
 	raw_dump_inline(__func__, "saddr", saddr, EUI64_ADDR_LEN);
 	raw_dump_inline(__func__, "daddr", daddr, EUI64_ADDR_LEN);
 
 	raw_dump_table(__func__, "sending raw skb network uncompressed packet",
 		       skb->data, skb->len);
 
+	ipv6_daddr_type = ipv6_addr_type(&hdr->daddr);
+	if (ipv6_daddr_type & IPV6_ADDR_MULTICAST) {
+		spin_lock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
+		dci = lowpan_ctx_by_addr(dev, &lowpan_priv(dev)->iphc_mcast_dci,
+					 &hdr->daddr);
+		if (dci) {
+			memcpy(&dci_entry, dci, sizeof(*dci));
+			cid |= dci->id;
+		}
+		spin_unlock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
+	} else {
+		spin_lock_bh(&lowpan_priv(dev)->iphc_dci.lock);
+		dci = lowpan_ctx_by_addr(dev, &lowpan_priv(dev)->iphc_dci,
+					 &hdr->daddr);
+		if (dci) {
+			memcpy(&dci_entry, dci, sizeof(*dci));
+			cid |= dci->id;
+		}
+		spin_unlock_bh(&lowpan_priv(dev)->iphc_dci.lock);
+	}
+
+	spin_lock_bh(&lowpan_priv(dev)->iphc_sci.lock);
+	sci = lowpan_ctx_by_addr(dev, &lowpan_priv(dev)->iphc_sci,
+				 &hdr->saddr);
+	if (sci) {
+		memcpy(&sci_entry, sci, sizeof(*sci));
+		cid |= (sci->id << 4);
+	}
+	spin_unlock_bh(&lowpan_priv(dev)->iphc_sci.lock);
+
+	if (sci || dci) {
+		iphc1 |= LOWPAN_IPHC_CID;
+		lowpan_push_hc_data(&hc_ptr, &cid, sizeof(cid));
+	}
+
 	/* Traffic Class, Flow Label compression */
 	iphc0 |= lowpan_iphc_tf_compress(&hc_ptr, hdr);
 
@@ -813,39 +1014,63 @@ int lowpan_header_compress(struct sk_buff *skb, const struct net_device *dev,
 				    sizeof(hdr->hop_limit));
 	}
 
-	addr_type = ipv6_addr_type(&hdr->saddr);
+	ipv6_saddr_type = ipv6_addr_type(&hdr->saddr);
 	/* source address compression */
-	if (addr_type == IPV6_ADDR_ANY) {
+	if (ipv6_saddr_type == IPV6_ADDR_ANY) {
 		pr_debug("source address is unspecified, setting SAC\n");
 		iphc1 |= LOWPAN_IPHC_SAC;
 	} else {
-		if (addr_type & IPV6_ADDR_LINKLOCAL) {
-			iphc1 |= lowpan_compress_addr_64(&hc_ptr, &hdr->saddr,
-							 saddr, true);
-			pr_debug("source address unicast link-local %pI6c iphc1 0x%02x\n",
-				 &hdr->saddr, iphc1);
+		if (sci) {
+			iphc1 |= lowpan_compress_ctx_addr(&hc_ptr, &hdr->saddr,
+							  &sci_entry, saddr,
+							  true);
+			iphc1 |= LOWPAN_IPHC_SAC;
 		} else {
-			pr_debug("send the full source address\n");
-			lowpan_push_hc_data(&hc_ptr, hdr->saddr.s6_addr, 16);
+			if (ipv6_saddr_type & IPV6_ADDR_LINKLOCAL) {
+				iphc1 |= lowpan_compress_addr_64(&hc_ptr,
+								 &hdr->saddr,
+								 saddr, true);
+				pr_debug("source address unicast link-local %pI6c iphc1 0x%02x\n",
+					 &hdr->saddr, iphc1);
+			} else {
+				pr_debug("send the full source address\n");
+				lowpan_push_hc_data(&hc_ptr,
+						    hdr->saddr.s6_addr, 16);
+			}
 		}
 	}
 
-	addr_type = ipv6_addr_type(&hdr->daddr);
 	/* destination address compression */
-	if (addr_type & IPV6_ADDR_MULTICAST) {
+	if (ipv6_daddr_type & IPV6_ADDR_MULTICAST) {
 		pr_debug("destination address is multicast: ");
-		iphc1 |= LOWPAN_IPHC_M;
-		iphc1 |= lowpan_iphc_mcast_addr_compress(&hc_ptr, &hdr->daddr);
+		if (dci) {
+			iphc1 |= lowpan_iphc_mcast_ctx_addr_compress(&hc_ptr,
+								     &dci_entry,
+								     &hdr->daddr);
+		} else {
+			iphc1 |= LOWPAN_IPHC_M;
+			iphc1 |= lowpan_iphc_mcast_addr_compress(&hc_ptr,
+								 &hdr->daddr);
+		}
 	} else {
-		if (addr_type & IPV6_ADDR_LINKLOCAL) {
-			/* TODO: context lookup */
-			iphc1 |= lowpan_compress_addr_64(&hc_ptr, &hdr->daddr,
-							 daddr, false);
-			pr_debug("dest address unicast link-local %pI6c "
-				 "iphc1 0x%02x\n", &hdr->daddr, iphc1);
+		if (dci) {
+			iphc1 |= lowpan_compress_ctx_addr(&hc_ptr, &hdr->daddr,
+							  &dci_entry, daddr,
+							  false);
+			iphc1 |= LOWPAN_IPHC_DAC;
 		} else {
-			pr_debug("dest address unicast %pI6c\n", &hdr->daddr);
-			lowpan_push_hc_data(&hc_ptr, hdr->daddr.s6_addr, 16);
+			if (ipv6_daddr_type & IPV6_ADDR_LINKLOCAL) {
+				iphc1 |= lowpan_compress_addr_64(&hc_ptr,
+								 &hdr->daddr,
+								 daddr, false);
+				pr_debug("dest address unicast link-local %pI6c iphc1 0x%02x\n",
+					 &hdr->daddr, iphc1);
+			} else {
+				pr_debug("dest address unicast %pI6c\n",
+					 &hdr->daddr);
+				lowpan_push_hc_data(&hc_ptr,
+						    hdr->daddr.s6_addr, 16);
+			}
 		}
 	}
 
@@ -871,3 +1096,164 @@ int lowpan_header_compress(struct sk_buff *skb, const struct net_device *dev,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(lowpan_header_compress);
+
+static bool lowpan_iphc_ctx_valid_prefix(const struct lowpan_iphc_ctx *ctx)
+{
+	/* prefix which are smaller than 64 bits are not valid, users
+	 * may mean than a prefix which is filled with zero until 64th bit.
+	 * Refere rfc6282 "Any remaining bits are zero." The remaining bits
+	 * in this case where are the prefix(< 64) ends until IID starts.
+	 */
+	if (ctx->prefix_len < 64)
+		return false;
+
+	return true;
+}
+
+static bool
+lowpan_iphc_mcast_ctx_valid_prefix(const struct lowpan_iphc_ctx *ctx)
+{
+	/* network prefix for multicast is at maximum 64 bits long */
+	if (ctx->prefix_len > 64)
+		return false;
+
+	return true;
+}
+
+static int lowpan_iphc_ctx_update(struct lowpan_iphc_ctx *table,
+				  const struct lowpan_iphc_ctx *ctx)
+{
+	int ret = 0, i;
+
+	switch (ctx->state) {
+	case LOWPAN_IPHC_CTX_STATE_DISABLED:
+		/* we don't care about if disabled */
+		break;
+	case LOWPAN_IPHC_CTX_STATE_ENABLED:
+		for (i = 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
+			if (ctx->prefix_len != table[i].prefix_len)
+				continue;
+
+			if (ipv6_prefix_equal(&ctx->addr, &table[i].addr,
+					      ctx->prefix_len)) {
+				switch (table[i].state) {
+				case LOWPAN_IPHC_CTX_STATE_ENABLED:
+					ret = -EEXIST;
+					goto out;
+				default:
+					break;
+				}
+			}
+		}
+		break;
+	default:
+		break;
+	}
+
+	memcpy(&table[ctx->id], ctx, sizeof(*ctx));
+
+out:
+	return ret;
+}
+
+static struct lowpan_iphc_ctx *
+lowpan_iphc_ctx_get_by_id(const struct net_device *dev,
+			  struct lowpan_iphc_ctx *table, u8 id)
+{
+	struct lowpan_iphc_ctx *ret = NULL;
+
+	WARN_ON_ONCE(id > LOWPAN_IPHC_CI_TABLE_SIZE);
+
+	switch (table[id].state) {
+	case LOWPAN_IPHC_CTX_STATE_ENABLED:
+		ret = &table[id];
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static struct lowpan_iphc_ctx *
+lowpan_iphc_ctx_get_by_addr(const struct net_device *dev,
+			    struct lowpan_iphc_ctx *table,
+			    const struct in6_addr *addr)
+{
+	struct lowpan_iphc_ctx *ret = NULL;
+	struct in6_addr addr_prefix;
+	int i;
+
+	for (i = 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
+		ipv6_addr_prefix(&addr_prefix, addr, table[i].prefix_len);
+
+		if (ipv6_prefix_equal(&addr_prefix, &table[i].addr,
+				      table[i].prefix_len)) {
+			switch (table[i].state) {
+			case LOWPAN_IPHC_CTX_STATE_ENABLED:
+				/* remember first match */
+				if (!ret) {
+					ret = &table[i];
+					continue;
+				}
+
+				/* get the context with longest prefix_len */
+				if (table[i].prefix_len > ret->prefix_len)
+					ret = &table[i];
+				break;
+			default:
+				break;
+			}
+		}
+	}
+
+	return ret;
+}
+
+static struct lowpan_iphc_ctx *
+lowpan_iphc_ctx_get_by_mcast_addr(const struct net_device *dev,
+				  struct lowpan_iphc_ctx *table,
+				  const struct in6_addr *addr)
+{
+	struct lowpan_iphc_ctx *ret = NULL;
+	struct in6_addr addr_mcast, network_pfx = {};
+	int i;
+
+	/* init mcast address with  */
+	memcpy(&addr_mcast, addr, sizeof(*addr));
+
+	for (i = 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
+		/* setting plen */
+		addr_mcast.s6_addr[3] = table[i].prefix_len;
+		/*  get network prefix to copy into multicast address */
+		ipv6_addr_prefix(&network_pfx, &table[i].addr,
+				 table[i].prefix_len);
+		/* setting network prefix */
+		memcpy(&addr_mcast.s6_addr[4], &network_pfx, 8);
+
+		if (ipv6_addr_equal(addr, &addr_mcast)) {
+			switch (table[i].state) {
+			case LOWPAN_IPHC_CTX_STATE_ENABLED:
+				return &table[i];
+			default:
+				break;
+			}
+		}
+	}
+
+	return ret;
+}
+
+const struct lowpan_iphc_ctx_ops iphc_ctx_unicast_ops = {
+	.valid_prefix = lowpan_iphc_ctx_valid_prefix,
+	.update = lowpan_iphc_ctx_update,
+	.get_by_id = lowpan_iphc_ctx_get_by_id,
+	.get_by_addr = lowpan_iphc_ctx_get_by_addr,
+};
+
+const struct lowpan_iphc_ctx_ops iphc_ctx_mcast_ops = {
+	.valid_prefix = lowpan_iphc_mcast_ctx_valid_prefix,
+	.update = lowpan_iphc_ctx_update,
+	.get_by_id = lowpan_iphc_ctx_get_by_id,
+	.get_by_addr = lowpan_iphc_ctx_get_by_mcast_addr,
+};
-- 
2.6.1
