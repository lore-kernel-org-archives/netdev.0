From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: bcm_sf2: Implement FDB operations
Date: Fri,  3 Jun 2016 17:05:23 -0700
Message-ID: <1464998733-10405-4-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33578 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbcFDAFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:49 -0400
Received: by mail-pa0-f65.google.com with SMTP id di3so6951290pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:48 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the FDB add, delete, and dump operations. The add and
delete operations are implemented using directed ARL operations using
the specified MAC address and consist in a read operation, write and
readback operation.

The dump operation consists in using the ARL search and software
filtering entries which are not for the desired port.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 236 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2.h      |  56 ++++++++++
 drivers/net/dsa/bcm_sf2_regs.h |  43 ++++++++
 3 files changed, 335 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 9d56515f4c4d..4f32b8a530bf 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -25,6 +25,8 @@
 #include <linux/ethtool.h>
 #include <linux/if_bridge.h>
 #include <linux/brcmphy.h>
+#include <linux/etherdevice.h>
+#include <net/switchdev.h>
 
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
@@ -555,6 +557,236 @@ static int bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+/* Address Resolution Logic routines */
+static int bcm_sf2_arl_op_wait(struct bcm_sf2_priv *priv)
+{
+	unsigned int timeout = 10;
+	u32 reg;
+
+	do {
+		reg = core_readl(priv, CORE_ARLA_RWCTL);
+		if (!(reg & ARL_STRTDN))
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	return -ETIMEDOUT;
+}
+
+static int bcm_sf2_arl_rw_op(struct bcm_sf2_priv *priv, unsigned int op)
+{
+	u32 cmd;
+
+	if (op > ARL_RW)
+		return -EINVAL;
+
+	cmd = core_readl(priv, CORE_ARLA_RWCTL);
+	cmd &= ~IVL_SVL_SELECT;
+	cmd |= ARL_STRTDN;
+	if (op)
+		cmd |= ARL_RW;
+	else
+		cmd &= ~ARL_RW;
+	core_writel(priv, cmd, CORE_ARLA_RWCTL);
+
+	return bcm_sf2_arl_op_wait(priv);
+}
+
+static int bcm_sf2_arl_read(struct bcm_sf2_priv *priv, u64 mac,
+			    u16 vid, struct bcm_sf2_arl_entry *ent, u8 *idx,
+			    bool is_valid)
+{
+	unsigned int i;
+	int ret;
+
+	ret = bcm_sf2_arl_op_wait(priv);
+	if (ret)
+		return ret;
+
+	/* Read the 4 bins */
+	for (i = 0; i < 4; i++) {
+		u64 mac_vid;
+		u32 fwd_entry;
+
+		mac_vid = core_readq(priv, CORE_ARLA_MACVID_ENTRY(i));
+		fwd_entry = core_readl(priv, CORE_ARLA_FWD_ENTRY(i));
+		bcm_sf2_arl_to_entry(ent, mac_vid, fwd_entry);
+
+		if (ent->is_valid && is_valid) {
+			*idx = i;
+			return 0;
+		}
+
+		/* This is the MAC we just deleted */
+		if (!is_valid && (mac_vid & mac))
+			return 0;
+	}
+
+	return -ENOENT;
+}
+
+static int bcm_sf2_arl_op(struct bcm_sf2_priv *priv, int op, int port,
+			  const unsigned char *addr, u16 vid, bool is_valid)
+{
+	struct bcm_sf2_arl_entry ent;
+	u32 fwd_entry;
+	u64 mac, mac_vid = 0;
+	u8 idx = 0;
+	int ret;
+
+	/* Convert the array into a 64-bit MAC */
+	mac = bcm_sf2_mac_to_u64(addr);
+
+	/* Perform a read for the given MAC and VID */
+	core_writeq(priv, mac, CORE_ARLA_MAC);
+	core_writel(priv, vid, CORE_ARLA_VID);
+
+	/* Issue a read operation for this MAC */
+	ret = bcm_sf2_arl_rw_op(priv, 1);
+	if (ret)
+		return ret;
+
+	ret = bcm_sf2_arl_read(priv, mac, vid, &ent, &idx, is_valid);
+	/* If this is a read, just finish now */
+	if (op)
+		return ret;
+
+	/* We could not find a matching MAC, so reset to a new entry */
+	if (ret) {
+		fwd_entry = 0;
+		idx = 0;
+	}
+
+	memset(&ent, 0, sizeof(ent));
+	ent.port = port;
+	ent.is_valid = is_valid;
+	ent.vid = vid;
+	ent.is_static = true;
+	memcpy(ent.mac, addr, ETH_ALEN);
+	bcm_sf2_arl_from_entry(&mac_vid, &fwd_entry, &ent);
+
+	core_writeq(priv, mac_vid, CORE_ARLA_MACVID_ENTRY(idx));
+	core_writel(priv, fwd_entry, CORE_ARLA_FWD_ENTRY(idx));
+
+	ret = bcm_sf2_arl_rw_op(priv, 0);
+	if (ret)
+		return ret;
+
+	/* Re-read the entry to check */
+	return bcm_sf2_arl_read(priv, mac, vid, &ent, &idx, is_valid);
+}
+
+static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, int port,
+				  const struct switchdev_obj_port_fdb *fdb,
+				  struct switchdev_trans *trans)
+{
+	/* We do not need to do anything specific here yet */
+	return 0;
+}
+
+static int bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
+			      const struct switchdev_obj_port_fdb *fdb,
+			      struct switchdev_trans *trans)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true);
+}
+
+static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
+			      const struct switchdev_obj_port_fdb *fdb)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
+}
+
+static int bcm_sf2_arl_search_wait(struct bcm_sf2_priv *priv)
+{
+	unsigned timeout = 1000;
+	u32 reg;
+
+	do {
+		reg = core_readl(priv, CORE_ARLA_SRCH_CTL);
+		if (!(reg & ARLA_SRCH_STDN))
+			return 0;
+
+		if (reg & ARLA_SRCH_VLID)
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	return -ETIMEDOUT;
+}
+
+static void bcm_sf2_arl_search_rd(struct bcm_sf2_priv *priv, u8 idx,
+				  struct bcm_sf2_arl_entry *ent)
+{
+	u64 mac_vid;
+	u32 fwd_entry;
+
+	mac_vid = core_readq(priv, CORE_ARLA_SRCH_RSLT_MACVID(idx));
+	fwd_entry = core_readl(priv, CORE_ARLA_SRCH_RSLT(idx));
+	bcm_sf2_arl_to_entry(ent, mac_vid, fwd_entry);
+}
+
+static int bcm_sf2_sw_fdb_copy(struct net_device *dev, int port,
+			       const struct bcm_sf2_arl_entry *ent,
+			       struct switchdev_obj_port_fdb *fdb,
+			       int (*cb)(struct switchdev_obj *obj))
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
+static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, int port,
+			       struct switchdev_obj_port_fdb *fdb,
+			       int (*cb)(struct switchdev_obj *obj))
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct net_device *dev = ds->ports[port];
+	struct bcm_sf2_arl_entry results[2];
+	unsigned int count = 0;
+	int ret;
+
+	/* Start search operation */
+	core_writel(priv, ARLA_SRCH_STDN, CORE_ARLA_SRCH_CTL);
+
+	do {
+		ret = bcm_sf2_arl_search_wait(priv);
+		if (ret)
+			return ret;
+
+		/* Read both entries, then return their values back */
+		bcm_sf2_arl_search_rd(priv, 0, &results[0]);
+		ret = bcm_sf2_sw_fdb_copy(dev, port, &results[0], fdb, cb);
+		if (ret)
+			return ret;
+
+		bcm_sf2_arl_search_rd(priv, 1, &results[1]);
+		ret = bcm_sf2_sw_fdb_copy(dev, port, &results[1], fdb, cb);
+		if (ret)
+			return ret;
+
+		if (!results[0].is_valid && !results[1].is_valid)
+			break;
+
+	} while (count++ < CORE_ARLA_NUM_ENTRIES);
+
+	return 0;
+}
+
 static irqreturn_t bcm_sf2_switch_0_isr(int irq, void *dev_id)
 {
 	struct bcm_sf2_priv *priv = dev_id;
@@ -1076,6 +1308,10 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_join_bridge	= bcm_sf2_sw_br_join,
 	.port_leave_bridge	= bcm_sf2_sw_br_leave,
 	.port_stp_update	= bcm_sf2_sw_br_set_stp_state,
+	.port_fdb_prepare	= bcm_sf2_sw_fdb_prepare,
+	.port_fdb_add		= bcm_sf2_sw_fdb_add,
+	.port_fdb_del		= bcm_sf2_sw_fdb_del,
+	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
 };
 
 static int __init bcm_sf2_init(void)
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 789d7b7737da..cc98abc0aaf3 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -19,6 +19,8 @@
 #include <linux/mutex.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
+#include <linux/types.h>
+#include <linux/bitops.h>
 
 #include <net/dsa.h>
 
@@ -50,6 +52,60 @@ struct bcm_sf2_port_status {
 	u32 vlan_ctl_mask;
 };
 
+struct bcm_sf2_arl_entry {
+	u8 port;
+	u8 mac[ETH_ALEN];
+	u16 vid;
+	u8 is_valid:1;
+	u8 is_age:1;
+	u8 is_static:1;
+};
+
+static inline void bcm_sf2_mac_from_u64(u64 src, u8 *dst)
+{
+	unsigned int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		dst[ETH_ALEN - 1 - i] = (src >> (8 * i)) & 0xff;
+}
+
+static inline u64 bcm_sf2_mac_to_u64(const u8 *src)
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
+static inline void bcm_sf2_arl_to_entry(struct bcm_sf2_arl_entry *ent,
+					u64 mac_vid, u32 fwd_entry)
+{
+	memset(ent, 0, sizeof(*ent));
+	ent->port = fwd_entry & PORTID_MASK;
+	ent->is_valid = !!(fwd_entry & ARL_VALID);
+	ent->is_age = !!(fwd_entry & ARL_AGE);
+	ent->is_static = !!(fwd_entry & ARL_STATIC);
+	bcm_sf2_mac_from_u64(mac_vid, ent->mac);
+	ent->vid = mac_vid >> VID_SHIFT;
+}
+
+static inline void bcm_sf2_arl_from_entry(u64 *mac_vid, u32 *fwd_entry,
+					  const struct bcm_sf2_arl_entry *ent)
+{
+	*mac_vid = bcm_sf2_mac_to_u64(ent->mac);
+	*mac_vid |= (u64)(ent->vid & VID_MASK) << VID_SHIFT;
+	*fwd_entry = ent->port & PORTID_MASK;
+	if (ent->is_valid)
+		*fwd_entry |= ARL_VALID;
+	if (ent->is_static)
+		*fwd_entry |= ARL_STATIC;
+	if (ent->is_age)
+		*fwd_entry |= ARL_AGE;
+}
+
 struct bcm_sf2_priv {
 	/* Base registers, keep those in order with BCM_SF2_REGS_NAME */
 	void __iomem			*core;
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index fa4e6e78c9ea..97780d43b5c0 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -231,6 +231,49 @@
 #define CORE_BRCM_HDR_RX_DIS		0x0980
 #define CORE_BRCM_HDR_TX_DIS		0x0988
 
+#define CORE_ARLA_NUM_ENTRIES		1024
+
+#define CORE_ARLA_RWCTL			0x1400
+#define  ARL_RW				(1 << 0)
+#define  IVL_SVL_SELECT			(1 << 6)
+#define  ARL_STRTDN			(1 << 7)
+
+#define CORE_ARLA_MAC			0x1408
+#define CORE_ARLA_VID			0x1420
+#define  ARLA_VIDTAB_INDX_MASK		0x1fff
+
+#define CORE_ARLA_MACVID0		0x1440
+#define  MAC_MASK			0xffffffffff
+#define  VID_SHIFT			48
+#define  VID_MASK			0xfff
+
+#define CORE_ARLA_FWD_ENTRY0		0x1460
+#define  PORTID_MASK			0x1ff
+#define  ARL_CON_SHIFT			9
+#define  ARL_CON_MASK			0x3
+#define  ARL_PRI_SHIFT			11
+#define  ARL_PRI_MASK			0x7
+#define  ARL_AGE			(1 << 14)
+#define  ARL_STATIC			(1 << 15)
+#define  ARL_VALID			(1 << 16)
+
+#define CORE_ARLA_MACVID_ENTRY(x)	(CORE_ARLA_MACVID0 + ((x) * 0x40))
+#define CORE_ARLA_FWD_ENTRY(x)		(CORE_ARLA_FWD_ENTRY0 + ((x) * 0x40))
+
+#define CORE_ARLA_SRCH_CTL		0x1540
+#define  ARLA_SRCH_VLID			(1 << 0)
+#define  IVL_SVL_SELECT			(1 << 6)
+#define  ARLA_SRCH_STDN			(1 << 7)
+
+#define CORE_ARLA_SRCH_ADR		0x1544
+#define  ARLA_SRCH_ADR_VALID		(1 << 15)
+
+#define CORE_ARLA_SRCH_RSLT_0_MACVID	0x1580
+#define CORE_ARLA_SRCH_RSLT_0		0x15a0
+
+#define CORE_ARLA_SRCH_RSLT_MACVID(x)	(CORE_ARLA_SRCH_RSLT_0_MACVID + ((x) * 0x40))
+#define CORE_ARLA_SRCH_RSLT(x)		(CORE_ARLA_SRCH_RSLT_0 + ((x) * 0x40))
+
 #define CORE_MEM_PSM_VDD_CTRL		0x2380
 #define  P_TXQ_PSM_VDD_SHIFT		2
 #define  P_TXQ_PSM_VDD_MASK		0x3
-- 
2.1.0
