From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: dsa: b53: Implement ARL add/del/dump operations
Date: Thu,  9 Jun 2016 18:23:55 -0700
Message-ID: <1465521837-30193-4-git-send-email-f.fainelli@gmail.com>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	jon.mason@broadcom.com, hemal.shah@broadcom.com,
	bandaru.viswanath@broadcom.com, michael.chan@broadcom.com,
	jogo@openwrt.org, cphealy@gmail.com, ardeleanalex@gmail.com,
	jiri@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33636 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbcFJBYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 21:24:09 -0400
Received: by mail-pf0-f195.google.com with SMTP id c74so3875692pfb.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 18:24:09 -0700 (PDT)
In-Reply-To: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for FDB add/delete/dump using the ARL read/write logic and
the ARL search logic for faster dumps. The code is made flexible enough
it could support devices with a different register layout like BCM5325
and BCM5365 which have fewer number of entries or pack values into a
single 64 bits register.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 261 +++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/b53/b53_priv.h   |  57 +++++++++
 drivers/net/dsa/b53/b53_regs.h   |  64 ++++++++++
 3 files changed, 382 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 6f0337d6dfa4..a9f1de407f57 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -26,7 +26,9 @@
 #include <linux/module.h>
 #include <linux/platform_data/b53.h>
 #include <linux/phy.h>
+#include <linux/etherdevice.h>
 #include <net/dsa.h>
+#include <net/switchdev.h>
 
 #include "b53_regs.h"
 #include "b53_priv.h"
@@ -777,6 +779,246 @@ static void b53_adjust_link(struct dsa_switch *ds, int port,
 	}
 }
 
+/* Address Resolution Logic routines */
+static int b53_arl_op_wait(struct b53_device *dev)
+{
+	unsigned int timeout = 10;
+	u8 reg;
+
+	do {
+		b53_read8(dev, B53_ARLIO_PAGE, B53_ARLTBL_RW_CTRL, &reg);
+		if (!(reg & ARLTBL_START_DONE))
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	dev_warn(dev->dev, "timeout waiting for ARL to finish: 0x%02x\n", reg);
+
+	return -ETIMEDOUT;
+}
+
+static int b53_arl_rw_op(struct b53_device *dev, unsigned int op)
+{
+	u8 reg;
+
+	if (op > ARLTBL_RW)
+		return -EINVAL;
+
+	b53_read8(dev, B53_ARLIO_PAGE, B53_ARLTBL_RW_CTRL, &reg);
+	reg |= ARLTBL_START_DONE;
+	if (op)
+		reg |= ARLTBL_RW;
+	else
+		reg &= ~ARLTBL_RW;
+	b53_write8(dev, B53_ARLIO_PAGE, B53_ARLTBL_RW_CTRL, reg);
+
+	return b53_arl_op_wait(dev);
+}
+
+static int b53_arl_read(struct b53_device *dev, u64 mac,
+			u16 vid, struct b53_arl_entry *ent, u8 *idx,
+			bool is_valid)
+{
+	unsigned int i;
+	int ret;
+
+	ret = b53_arl_op_wait(dev);
+	if (ret)
+		return ret;
+
+	/* Read the bins */
+	for (i = 0; i < dev->num_arl_entries; i++) {
+		u64 mac_vid;
+		u32 fwd_entry;
+
+		b53_read64(dev, B53_ARLIO_PAGE,
+			   B53_ARLTBL_MAC_VID_ENTRY(i), &mac_vid);
+		b53_read32(dev, B53_ARLIO_PAGE,
+			   B53_ARLTBL_DATA_ENTRY(i), &fwd_entry);
+		b53_arl_to_entry(ent, mac_vid, fwd_entry);
+
+		if (!(fwd_entry & ARLTBL_VALID))
+			continue;
+		if ((mac_vid & ARLTBL_MAC_MASK) != mac)
+			continue;
+		*idx = i;
+	}
+
+	return -ENOENT;
+}
+
+static int b53_arl_op(struct b53_device *dev, int op, int port,
+		      const unsigned char *addr, u16 vid, bool is_valid)
+{
+	struct b53_arl_entry ent;
+	u32 fwd_entry;
+	u64 mac, mac_vid = 0;
+	u8 idx = 0;
+	int ret;
+
+	/* Convert the array into a 64-bit MAC */
+	mac = b53_mac_to_u64(addr);
+
+	/* Perform a read for the given MAC and VID */
+	b53_write48(dev, B53_ARLIO_PAGE, B53_MAC_ADDR_IDX, mac);
+	b53_write16(dev, B53_ARLIO_PAGE, B53_VLAN_ID_IDX, vid);
+
+	/* Issue a read operation for this MAC */
+	ret = b53_arl_rw_op(dev, 1);
+	if (ret)
+		return ret;
+
+	ret = b53_arl_read(dev, mac, vid, &ent, &idx, is_valid);
+	/* If this is a read, just finish now */
+	if (op)
+		return ret;
+
+	/* We could not find a matching MAC, so reset to a new entry */
+	if (ret) {
+		fwd_entry = 0;
+		idx = 1;
+	}
+
+	memset(&ent, 0, sizeof(ent));
+	ent.port = port;
+	ent.is_valid = is_valid;
+	ent.vid = vid;
+	ent.is_static = true;
+	memcpy(ent.mac, addr, ETH_ALEN);
+	b53_arl_from_entry(&mac_vid, &fwd_entry, &ent);
+
+	b53_write64(dev, B53_ARLIO_PAGE,
+		    B53_ARLTBL_MAC_VID_ENTRY(idx), mac_vid);
+	b53_write32(dev, B53_ARLIO_PAGE,
+		    B53_ARLTBL_DATA_ENTRY(idx), fwd_entry);
+
+	return b53_arl_rw_op(dev, 0);
+}
+
+static int b53_fdb_prepare(struct dsa_switch *ds, int port,
+			   const struct switchdev_obj_port_fdb *fdb,
+			   struct switchdev_trans *trans)
+{
+	struct b53_device *priv = ds_to_priv(ds);
+
+	/* 5325 and 5365 require some more massaging, but could
+	 * be supported eventually
+	 */
+	if (is5325(priv) || is5365(priv))
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
+static void b53_fdb_add(struct dsa_switch *ds, int port,
+			const struct switchdev_obj_port_fdb *fdb,
+			struct switchdev_trans *trans)
+{
+	struct b53_device *priv = ds_to_priv(ds);
+
+	if (b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
+		pr_err("%s: failed to add MAC address\n", __func__);
+}
+
+static int b53_fdb_del(struct dsa_switch *ds, int port,
+		       const struct switchdev_obj_port_fdb *fdb)
+{
+	struct b53_device *priv = ds_to_priv(ds);
+
+	return b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
+}
+
+static int b53_arl_search_wait(struct b53_device *dev)
+{
+	unsigned int timeout = 1000;
+	u8 reg;
+
+	do {
+		b53_read8(dev, B53_ARLIO_PAGE, B53_ARL_SRCH_CTL, &reg);
+		if (!(reg & ARL_SRCH_STDN))
+			return 0;
+
+		if (reg & ARL_SRCH_VLID)
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	return -ETIMEDOUT;
+}
+
+static void b53_arl_search_rd(struct b53_device *dev, u8 idx,
+			      struct b53_arl_entry *ent)
+{
+	u64 mac_vid;
+	u32 fwd_entry;
+
+	b53_read64(dev, B53_ARLIO_PAGE,
+		   B53_ARL_SRCH_RSTL_MACVID(idx), &mac_vid);
+	b53_read32(dev, B53_ARLIO_PAGE,
+		   B53_ARL_SRCH_RSTL(idx), &fwd_entry);
+	b53_arl_to_entry(ent, mac_vid, fwd_entry);
+}
+
+static int b53_fdb_copy(struct net_device *dev, int port,
+			const struct b53_arl_entry *ent,
+			struct switchdev_obj_port_fdb *fdb,
+			int (*cb)(struct switchdev_obj *obj))
+{
+	if (!ent->is_valid)
+		return 0;
+
+	if (port != ent->port)
+		return 0;
+
+	ether_addr_copy(fdb->addr, ent->mac);
+	fdb->vid = ent->vid;
+	fdb->ndm_state = ent->is_static ? NUD_NOARP : NUD_REACHABLE;
+
+	return cb(&fdb->obj);
+}
+
+static int b53_fdb_dump(struct dsa_switch *ds, int port,
+			struct switchdev_obj_port_fdb *fdb,
+			int (*cb)(struct switchdev_obj *obj))
+{
+	struct b53_device *priv = ds_to_priv(ds);
+	struct net_device *dev = ds->ports[port].netdev;
+	struct b53_arl_entry results[2];
+	unsigned int count = 0;
+	int ret;
+	u8 reg;
+
+	/* Start search operation */
+	reg = ARL_SRCH_STDN;
+	b53_write8(priv, B53_ARLIO_PAGE, B53_ARL_SRCH_CTL, reg);
+
+	do {
+		ret = b53_arl_search_wait(priv);
+		if (ret)
+			return ret;
+
+		b53_arl_search_rd(priv, 0, &results[0]);
+		ret = b53_fdb_copy(dev, port, &results[0], fdb, cb);
+		if (ret)
+			return ret;
+
+		if (priv->num_arl_entries > 2) {
+			b53_arl_search_rd(priv, 1, &results[1]);
+			ret = b53_fdb_copy(dev, port, &results[1], fdb, cb);
+			if (ret)
+				return ret;
+
+			if (!results[0].is_valid && !results[1].is_valid)
+				break;
+		}
+
+	} while (count++ < 1024);
+
+	return 0;
+}
+
 static struct dsa_switch_driver b53_switch_ops = {
 	.tag_protocol		= DSA_TAG_PROTO_NONE,
 	.setup			= b53_setup,
@@ -789,6 +1031,10 @@ static struct dsa_switch_driver b53_switch_ops = {
 	.adjust_link		= b53_adjust_link,
 	.port_enable		= b53_enable_port,
 	.port_disable		= b53_disable_port,
+	.port_fdb_prepare	= b53_fdb_prepare,
+	.port_fdb_dump		= b53_fdb_dump,
+	.port_fdb_add		= b53_fdb_add,
+	.port_fdb_del		= b53_fdb_del,
 };
 
 struct b53_chip_data {
@@ -798,6 +1044,7 @@ struct b53_chip_data {
 	u16 enabled_ports;
 	u8 cpu_port;
 	u8 vta_regs[3];
+	u8 arl_entries;
 	u8 duplex_reg;
 	u8 jumbo_pm_reg;
 	u8 jumbo_size_reg;
@@ -816,6 +1063,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM5325",
 		.vlans = 16,
 		.enabled_ports = 0x1f,
+		.arl_entries = 2,
 		.cpu_port = B53_CPU_PORT_25,
 		.duplex_reg = B53_DUPLEX_STAT_FE,
 	},
@@ -824,6 +1072,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM5365",
 		.vlans = 256,
 		.enabled_ports = 0x1f,
+		.arl_entries = 2,
 		.cpu_port = B53_CPU_PORT_25,
 		.duplex_reg = B53_DUPLEX_STAT_FE,
 	},
@@ -832,6 +1081,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM5395",
 		.vlans = 4096,
 		.enabled_ports = 0x1f,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT,
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -843,6 +1093,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM5397",
 		.vlans = 4096,
 		.enabled_ports = 0x1f,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT,
 		.vta_regs = B53_VTA_REGS_9798,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -854,6 +1105,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM5398",
 		.vlans = 4096,
 		.enabled_ports = 0x7f,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT,
 		.vta_regs = B53_VTA_REGS_9798,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -865,6 +1117,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53115",
 		.vlans = 4096,
 		.enabled_ports = 0x1f,
+		.arl_entries = 4,
 		.vta_regs = B53_VTA_REGS,
 		.cpu_port = B53_CPU_PORT,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -887,6 +1140,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53128",
 		.vlans = 4096,
 		.enabled_ports = 0x1ff,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT,
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -898,6 +1152,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM63xx",
 		.vlans = 4096,
 		.enabled_ports = 0, /* pdata must provide them */
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT,
 		.vta_regs = B53_VTA_REGS_63XX,
 		.duplex_reg = B53_DUPLEX_STAT_63XX,
@@ -909,6 +1164,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53010",
 		.vlans = 4096,
 		.enabled_ports = 0x1f,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -920,6 +1176,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53011",
 		.vlans = 4096,
 		.enabled_ports = 0x1bf,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -931,6 +1188,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53012",
 		.vlans = 4096,
 		.enabled_ports = 0x1bf,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -942,6 +1200,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53018",
 		.vlans = 4096,
 		.enabled_ports = 0x1f,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -953,6 +1212,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53019",
 		.vlans = 4096,
 		.enabled_ports = 0x1f,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
@@ -982,6 +1242,7 @@ static int b53_switch_init(struct b53_device *dev)
 			ds->drv = &b53_switch_ops;
 			dev->cpu_port = chip->cpu_port;
 			dev->num_vlans = chip->vlans;
+			dev->num_arl_entries = chip->arl_entries;
 			break;
 		}
 	}
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index c4844155546b..1ee4e8016642 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -24,6 +24,8 @@
 #include <linux/phy.h>
 #include <net/dsa.h>
 
+#include "b53_regs.h"
+
 struct b53_device;
 
 struct b53_io_ops {
@@ -81,6 +83,7 @@ struct b53_device {
 	u8 jumbo_pm_reg;
 	u8 jumbo_size_reg;
 	int reset_gpio;
+	u8 num_arl_entries;
 
 	/* used ports mask */
 	u16 enabled_ports;
@@ -296,6 +299,60 @@ static inline int b53_write64(struct b53_device *dev, u8 page, u8 reg,
 	return ret;
 }
 
+struct b53_arl_entry {
+	u8 port;
+	u8 mac[ETH_ALEN];
+	u16 vid;
+	u8 is_valid:1;
+	u8 is_age:1;
+	u8 is_static:1;
+};
+
+static inline void b53_mac_from_u64(u64 src, u8 *dst)
+{
+	unsigned int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		dst[ETH_ALEN - 1 - i] = (src >> (8 * i)) & 0xff;
+}
+
+static inline u64 b53_mac_to_u64(const u8 *src)
+{
+	unsigned int i;
+	u64 dst = 0;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		dst |= (u64)src[ETH_ALEN - 1 - i] << (8 * i);
+
+	return dst;
+}
+
+static inline void b53_arl_to_entry(struct b53_arl_entry *ent,
+				    u64 mac_vid, u32 fwd_entry)
+{
+	memset(ent, 0, sizeof(*ent));
+	ent->port = fwd_entry & ARLTBL_DATA_PORT_ID_MASK;
+	ent->is_valid = !!(fwd_entry & ARLTBL_VALID);
+	ent->is_age = !!(fwd_entry & ARLTBL_AGE);
+	ent->is_static = !!(fwd_entry & ARLTBL_STATIC);
+	b53_mac_from_u64(mac_vid, ent->mac);
+	ent->vid = mac_vid >> ARLTBL_VID_S;
+}
+
+static inline void b53_arl_from_entry(u64 *mac_vid, u32 *fwd_entry,
+				      const struct b53_arl_entry *ent)
+{
+	*mac_vid = b53_mac_to_u64(ent->mac);
+	*mac_vid |= (u64)(ent->vid & ARLTBL_VID_MASK) << ARLTBL_VID_S;
+	*fwd_entry = ent->port & ARLTBL_DATA_PORT_ID_MASK;
+	if (ent->is_valid)
+		*fwd_entry |= ARLTBL_VALID;
+	if (ent->is_static)
+		*fwd_entry |= ARLTBL_STATIC;
+	if (ent->is_age)
+		*fwd_entry |= ARLTBL_AGE;
+}
+
 #ifdef CONFIG_BCM47XX
 
 #include <linux/version.h>
diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index ccf8af7717d3..441d2b4121c4 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -227,6 +227,70 @@
 #define   VTE_UNTAG			(0x1ff << 9)
 
 /*************************************************************************
+ * ARL I/O Registers
+ *************************************************************************/
+
+/* ARL Table Read/Write Register (8 bit) */
+#define B53_ARLTBL_RW_CTRL		0x00
+#define    ARLTBL_RW			BIT(0)
+#define    ARLTBL_START_DONE		BIT(7)
+
+/* MAC Address Index Register (48 bit) */
+#define B53_MAC_ADDR_IDX		0x02
+
+/* VLAN ID Index Register (16 bit) */
+#define B53_VLAN_ID_IDX			0x08
+
+/* ARL Table MAC/VID Entry N Registers (64 bit)
+ *
+ * BCM5325 and BCM5365 share most definitions below
+ */
+#define B53_ARLTBL_MAC_VID_ENTRY(n)	(0x10 * (n))
+#define   ARLTBL_MAC_MASK		0xffffffffffff
+#define   ARLTBL_VID_S			48
+#define   ARLTBL_VID_MASK_25		0xff
+#define   ARLTBL_VID_MASK		0xfff
+#define   ARLTBL_DATA_PORT_ID_S_25	48
+#define   ARLTBL_DATA_PORT_ID_MASK_25	0xf
+#define   ARLTBL_AGE_25			BIT(61)
+#define   ARLTBL_STATIC_25		BIT(62)
+#define   ARLTBL_VALID_25		BIT(63)
+
+/* ARL Table Data Entry N Registers (32 bit) */
+#define B53_ARLTBL_DATA_ENTRY(n)	((0x10 * (n)) + 0x08)
+#define   ARLTBL_DATA_PORT_ID_MASK	0x1ff
+#define   ARLTBL_TC(tc)			((3 & tc) << 11)
+#define   ARLTBL_AGE			BIT(14)
+#define   ARLTBL_STATIC			BIT(15)
+#define   ARLTBL_VALID			BIT(16)
+
+/* ARL Search Control Register (8 bit) */
+#define B53_ARL_SRCH_CTL		0x50
+#define B53_ARL_SRCH_CTL_25		0x20
+#define   ARL_SRCH_VLID			BIT(0)
+#define   ARL_SRCH_STDN			BIT(7)
+
+/* ARL Search Address Register (16 bit) */
+#define B53_ARL_SRCH_ADDR		0x51
+#define B53_ARL_SRCH_ADDR_25		0x22
+#define B53_ARL_SRCH_ADDR_65		0x24
+#define  ARL_ADDR_MASK			GENMASK(14, 0)
+
+/* ARL Search MAC/VID Result (64 bit) */
+#define B53_ARL_SRCH_RSTL_0_MACVID	0x60
+
+/* Single register search result on 5325 */
+#define B53_ARL_SRCH_RSTL_0_MACVID_25	0x24
+/* Single register search result on 5365 */
+#define B53_ARL_SRCH_RSTL_0_MACVID_65	0x30
+
+/* ARL Search Data Result (32 bit) */
+#define B53_ARL_SRCH_RSTL_0		0x68
+
+#define B53_ARL_SRCH_RSTL_MACVID(x)	(B53_ARL_SRCH_RSTL_0_MACVID + ((x) * 0x10))
+#define B53_ARL_SRCH_RSTL(x)		(B53_ARL_SRCH_RSTL_0 + ((x) * 0x10))
+
+/*************************************************************************
  * Port VLAN Registers
  *************************************************************************/
 
-- 
2.7.4
