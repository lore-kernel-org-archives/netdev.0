From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 08/13] net: dsa: lan9303: Added ALR/fdb/mdb handling
Date: Wed, 19 Jul 2017 15:10:08 +0200
Message-ID: <8ea0f6bf186b422f919a23dfe57d9af4@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta5.messagelabs.com ([195.245.231.153]:6776 "EHLO
        mail1.bemta5.messagelabs.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756644AbdGXPoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 11:44:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added functions for accessing / managing the lan9303 ALR (Address Logic
Resolution).

Implemented DSA methods: set_addr, port_fast_age, port_fdb_prepare,
port_fdb_add, port_fdb_del, port_fdb_dump, port_mdb_prepare,
port_mdb_add and port_mdb_del.

Since the lan9303 do not offer reading specific ALR entry, the driver
caches all static entries - in a flat table.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 drivers/net/dsa/lan9303-core.c | 369 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |  11 ++
 2 files changed, 380 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 426a75bd89f4..dc95973d62ed 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -19,6 +19,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/if_bridge.h>
+#include <linux/etherdevice.h>
 
 #include "lan9303.h"
 
@@ -121,6 +122,21 @@
 #define LAN9303_MAC_RX_CFG_2 0x0c01
 #define LAN9303_MAC_TX_CFG_2 0x0c40
 #define LAN9303_SWE_ALR_CMD 0x1800
+# define ALR_CMD_MAKE_ENTRY    BIT(2)
+# define ALR_CMD_GET_FIRST     BIT(1)
+# define ALR_CMD_GET_NEXT      BIT(0)
+#define LAN9303_SWE_ALR_WR_DAT_0 0x1801
+#define LAN9303_SWE_ALR_WR_DAT_1 0x1802
+# define ALR_DAT1_VALID        BIT(26)
+# define ALR_DAT1_END_OF_TABL  BIT(25)
+# define ALR_DAT1_AGE_OVERRID  BIT(25)
+# define ALR_DAT1_STATIC       BIT(24)
+# define ALR_DAT1_PORT_BITOFFS  16
+# define ALR_DAT1_PORT_MASK    (7 << ALR_DAT1_PORT_BITOFFS)
+#define LAN9303_SWE_ALR_RD_DAT_0 0x1805
+#define LAN9303_SWE_ALR_RD_DAT_1 0x1806
+#define LAN9303_SWE_ALR_CMD_STS 0x1808
+# define ALR_STS_MAKE_PEND     BIT(0)
 #define LAN9303_SWE_VLAN_CMD 0x180b
 # define LAN9303_SWE_VLAN_CMD_RNW BIT(5)
 # define LAN9303_SWE_VLAN_CMD_PVIDNVLAN BIT(4)
@@ -473,6 +489,229 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	return 0;
 }
 
+/* ----------------- Address Logic Resolution (ALR)------------------*/
+
+/* Map ALR-port bits to port bitmap, and back*/
+static const int alrport_2_portmap[] = {1, 2, 4, 0, 3, 5, 6, 7 };
+static const int portmap_2_alrport[] = {3, 0, 1, 4, 2, 5, 6, 7 };
+
+/* ALR: Cache static entries: mac address + port bitmap */
+
+/* Return pointer to first free ALR cache entry, return NULL if none */
+static struct lan9303_alr_cache_entry *lan9303_alr_cache_find_free(
+	struct lan9303 *chip)
+{
+	int i;
+	struct lan9303_alr_cache_entry *entr = chip->alr_cache;
+
+	for (i = 0; i < LAN9303_NUM_ALR_RECORDS; i++, entr++)
+		if (entr->port_map == 0)
+			return entr;
+	return NULL;
+}
+
+/* Return pointer to ALR cache entry matching MAC address */
+static struct lan9303_alr_cache_entry *lan9303_alr_cache_find_mac(
+	struct lan9303 *chip,
+	const u8 *mac_addr)
+{
+	int i;
+	struct lan9303_alr_cache_entry *entr = chip->alr_cache;
+
+	BUILD_BUG_ON_MSG(sizeof(struct lan9303_alr_cache_entry) & 1,
+			 "ether_addr_equal require u16 alignment");
+
+	for (i = 0; i < LAN9303_NUM_ALR_RECORDS; i++, entr++)
+		if (ether_addr_equal(entr->mac_addr, mac_addr))
+			return entr;
+	return NULL;
+}
+
+/* ALR: Actual register access functions */
+
+/* This function will wait a while until mask & reg == value */
+/* Otherwise, return timeout */
+static int lan9303_csr_reg_wait(struct lan9303 *chip, int regno,
+				int mask, char value)
+{
+	int i;
+
+	for (i = 0; i < 0x1000; i++) {
+		u32 reg;
+
+		lan9303_read_switch_reg(chip, regno, &reg);
+		if ((reg & mask) == value)
+			return 0;
+	}
+	return -ETIMEDOUT;
+}
+
+static int _lan9303_alr_make_entry_raw(struct lan9303 *chip, u32 dat0, u32 dat1)
+{
+	lan9303_write_switch_reg(
+		chip, LAN9303_SWE_ALR_WR_DAT_0, dat0);
+	lan9303_write_switch_reg(
+		chip, LAN9303_SWE_ALR_WR_DAT_1, dat1);
+	lan9303_write_switch_reg(
+		chip, LAN9303_SWE_ALR_CMD, ALR_CMD_MAKE_ENTRY);
+	lan9303_csr_reg_wait(
+		chip, LAN9303_SWE_ALR_CMD_STS, ALR_STS_MAKE_PEND, 0);
+	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
+	return 0;
+}
+
+typedef void alr_loop_cb_t(
+	struct lan9303 *chip, u32 dat0, u32 dat1, int portmap, void *ctx);
+
+static void lan9303_alr_loop(struct lan9303 *chip, alr_loop_cb_t *cb, void *ctx)
+{
+	int i;
+
+	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, ALR_CMD_GET_FIRST);
+	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
+
+	for (i = 1; i < LAN9303_NUM_ALR_RECORDS; i++) {
+		u32 dat0, dat1;
+		int alrport, portmap;
+
+		lan9303_read_switch_reg(chip, LAN9303_SWE_ALR_RD_DAT_0, &dat0);
+		lan9303_read_switch_reg(chip, LAN9303_SWE_ALR_RD_DAT_1, &dat1);
+		if (dat1 & ALR_DAT1_END_OF_TABL)
+			break;
+
+		alrport = (dat1 & ALR_DAT1_PORT_MASK) >> ALR_DAT1_PORT_BITOFFS;
+		portmap = alrport_2_portmap[alrport];
+
+		cb(chip, dat0, dat1, portmap, ctx);
+
+		lan9303_write_switch_reg(
+			chip, LAN9303_SWE_ALR_CMD, ALR_CMD_GET_NEXT);
+		lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
+	}
+}
+
+/* ALR: lan9303_alr_loop callback functions */
+
+static void _alr_reg_to_mac(u32 dat0, u32 dat1, u8 mac[6])
+{
+	mac[0] = (dat0 >>  0) & 0xff;
+	mac[1] = (dat0 >>  8) & 0xff;
+	mac[2] = (dat0 >> 16) & 0xff;
+	mac[3] = (dat0 >> 24) & 0xff;
+	mac[4] = (dat1 >>  0) & 0xff;
+	mac[5] = (dat1 >>  8) & 0xff;
+}
+
+/* Clear learned (non-static) entry on given port */
+static void alr_loop_cb_del_port_learned(
+	struct lan9303 *chip, u32 dat0, u32 dat1, int portmap, void *ctx)
+{
+	int *port = ctx;
+
+	if (((BIT(*port) & portmap) == 0) || (dat1 & ALR_DAT1_STATIC))
+		return;
+
+	/* learned entries has only one port, we can just delete */
+	dat1 &= ~ALR_DAT1_VALID; /* delete entry */
+	_lan9303_alr_make_entry_raw(chip, dat0, dat1);
+}
+
+struct port_fdb_dump_ctx {
+	int port;
+	struct switchdev_obj_port_fdb *fdb;
+	switchdev_obj_dump_cb_t       *cb;
+};
+
+static void alr_loop_cb_fdb_port_dump(
+	struct lan9303 *chip, u32 dat0, u32 dat1, int portmap, void *ctx)
+{
+	struct port_fdb_dump_ctx *dump_ctx = ctx;
+	struct switchdev_obj_port_fdb *fdb = dump_ctx->fdb;
+	u8 mac[ETH_ALEN];
+
+	if ((BIT(dump_ctx->port) & portmap) == 0)
+		return;
+
+	_alr_reg_to_mac(dat0, dat1, mac);
+	ether_addr_copy(fdb->addr, mac);
+	fdb->vid = 0;
+	fdb->ndm_state = (dat1 & ALR_DAT1_STATIC) ?
+		NUD_NOARP : NUD_REACHABLE;
+	dump_ctx->cb(&fdb->obj);
+}
+
+/* ALR: Add/modify/delete ALR entries */
+
+/* Set a static ALR entry. Delete entry if port_map is zero */
+static void _lan9303_alr_set_entry(struct lan9303 *chip, const u8 *mac,
+				   u8 port_map, bool stp_override)
+{
+	u32 dat0, dat1, alr_port;
+
+	dat1 = ALR_DAT1_STATIC;
+	if (port_map)
+		dat1 |= ALR_DAT1_VALID; /* otherwise no ports: delete entry */
+	if (stp_override)
+		dat1 |= ALR_DAT1_AGE_OVERRID;
+
+	alr_port = portmap_2_alrport[port_map & 7];
+	dat1 &= ~ALR_DAT1_PORT_MASK;
+	dat1 |= alr_port << ALR_DAT1_PORT_BITOFFS;
+
+	dat0 = 0;
+	dat0 |= (mac[0] << 0);
+	dat0 |= (mac[1] << 8);
+	dat0 |= (mac[2] << 16);
+	dat0 |= (mac[3] << 24);
+
+	dat1 |= (mac[4] << 0);
+	dat1 |= (mac[5] << 8);
+
+	dev_dbg(chip->dev, "%s %pM %d %08x %08x\n",
+		__func__, mac, port_map, dat0, dat1);
+	_lan9303_alr_make_entry_raw(chip, dat0, dat1);
+}
+
+/* Add port to static ALR entry, create new static entry if needed */
+static int lan9303_alr_add_port(struct lan9303 *chip, const u8 *mac,
+				int port, bool stp_override)
+{
+	struct lan9303_alr_cache_entry *entr = lan9303_alr_cache_find_mac(
+		chip, mac);
+
+	if (!entr) { /*New entry */
+		entr = lan9303_alr_cache_find_free(chip);
+		if (!entr)
+			return -ENOSPC;
+		ether_addr_copy(entr->mac_addr, mac);
+	}
+	entr->port_map |= BIT(port);
+	entr->stp_override = stp_override;
+	_lan9303_alr_set_entry(chip, mac, entr->port_map, stp_override);
+	return 0;
+}
+
+/* Delete static port from ALR entry, delete entry if last port */
+static int lan9303_alr_del_port(struct lan9303 *chip, const u8 *mac,
+				int port)
+{
+	struct lan9303_alr_cache_entry *entr = lan9303_alr_cache_find_mac(
+		chip, mac);
+
+	if (!entr) { /* no static entry found */
+		/* Should we delete any learned entry?
+		 * _lan9303_alr_set_entry(chip, mac, 0, false);
+		 */
+		return 0;
+	}
+	entr->port_map &= ~BIT(port); /* zero means its free again */
+	if (entr->port_map == 0)
+		eth_zero_addr(&entr->port_map);
+	_lan9303_alr_set_entry(chip, mac, entr->port_map, entr->stp_override);
+	return 0;
+}
+
+/* --------------------- Various chip setup ----------------------*/
 static int lan9303_disable_packet_processing(struct lan9303 *chip,
 					     unsigned int port)
 {
@@ -729,6 +968,14 @@ static int lan9303_setup(struct dsa_switch *ds)
 	return 0;
 }
 
+static int lan9303_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	struct lan9303 *chip = ds->priv;
+
+	lan9303_alr_add_port(chip, addr, 0, false);
+	return 0;
+}
+
 struct lan9303_mib_desc {
 	unsigned int offset; /* offset of first MAC */
 	const char *name;
@@ -974,9 +1221,123 @@ static void lan9303_port_stp_state_set(struct dsa_switch *ds, int port,
 				      portstate, portmask);
 }
 
+static void lan9303_port_fast_age(struct dsa_switch *ds, int port)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(%d)\n", __func__, port);
+	lan9303_alr_loop(chip, alr_loop_cb_del_port_learned, &port);
+}
+
+static int _lan9303_port_fdb_check(
+	struct lan9303 *chip, const u8 *mac, int vid)
+{
+	if (vid)
+		return -EOPNOTSUPP;
+	if (lan9303_alr_cache_find_mac(chip, mac))
+		return 0;
+	if (!lan9303_alr_cache_find_free(chip))
+		return -ENOSPC;
+	return 0;
+}
+
+static int lan9303_port_fdb_prepare(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_fdb *fdb,
+		struct switchdev_trans *trans)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d, vid %d, %pM)\n",
+		__func__, port, fdb->vid, fdb->addr);
+	return _lan9303_port_fdb_check(chip, fdb->addr, fdb->vid);
+}
+
+static void lan9303_port_fdb_add(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_fdb *fdb,
+		struct switchdev_trans *trans)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d, vid %d, %pM)\n",
+		__func__, port, fdb->vid, fdb->addr);
+	lan9303_alr_add_port(chip, fdb->addr, port, false);
+}
+
+static int lan9303_port_fdb_del(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_fdb *fdb)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d, vid %d, %pM)\n",
+		__func__, port, fdb->vid, fdb->addr);
+	if (fdb->vid)
+		return -EOPNOTSUPP;
+	lan9303_alr_del_port(chip, fdb->addr, port);
+	return 0;
+}
+
+static int lan9303_port_fdb_dump(
+		struct dsa_switch *ds, int port,
+		struct switchdev_obj_port_fdb *fdb,
+		switchdev_obj_dump_cb_t *cb)
+{
+	struct lan9303 *chip = ds->priv;
+	struct port_fdb_dump_ctx dump_ctx = {
+		.port = port,
+		.fdb  = fdb,
+		.cb   = cb,
+	};
+
+	dev_dbg(chip->dev, "%s(%d)\n", __func__, port);
+	lan9303_alr_loop(chip, alr_loop_cb_fdb_port_dump, &dump_ctx);
+	return 0;
+}
+
+static int lan9303_port_mdb_prepare(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_mdb *mdb,
+		struct switchdev_trans *trans)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d, vid %d, %pM)\n",
+		__func__, port, mdb->vid, mdb->addr);
+	return _lan9303_port_fdb_check(chip, mdb->addr, mdb->vid);
+}
+
+static void lan9303_port_mdb_add(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_mdb *mdb,
+		struct switchdev_trans *trans)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d, vid %d, %pM)\n",
+		__func__, port, mdb->vid, mdb->addr);
+	lan9303_alr_add_port(chip, mdb->addr, port, false);
+}
+
+static int lan9303_port_mdb_del(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_mdb *mdb)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d, vid %d, %pM)\n",
+		__func__, port, mdb->vid, mdb->addr);
+	if (mdb->vid)
+		return -EOPNOTSUPP;
+	lan9303_alr_del_port(chip, mdb->addr, port);
+	return 0;
+}
+
 static struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
+	.set_addr = lan9303_set_addr,
 	.phy_read = lan9303_phy_read,
 	.phy_write = lan9303_phy_write,
 	.adjust_link = lan9303_adjust_link,
@@ -988,6 +1349,14 @@ static struct dsa_switch_ops lan9303_switch_ops = {
 	.port_bridge_join       = lan9303_port_bridge_join,
 	.port_bridge_leave      = lan9303_port_bridge_leave,
 	.port_stp_state_set     = lan9303_port_stp_state_set,
+	.port_fast_age          = lan9303_port_fast_age,
+	.port_fdb_prepare       = lan9303_port_fdb_prepare,
+	.port_fdb_add           = lan9303_port_fdb_add,
+	.port_fdb_del           = lan9303_port_fdb_del,
+	.port_fdb_dump          = lan9303_port_fdb_dump,
+	.port_mdb_prepare       = lan9303_port_mdb_prepare,
+	.port_mdb_add           = lan9303_port_mdb_add,
+	.port_mdb_del           = lan9303_port_mdb_del,
 };
 
 static int lan9303_register_switch(struct lan9303 *chip)
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index 2d74d02c9cef..f714addbf1e2 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -11,6 +11,13 @@ struct lan9303_phy_ops {
 			     int regnum, u16 val);
 };
 
+#define LAN9303_NUM_ALR_RECORDS 512
+struct lan9303_alr_cache_entry {
+	u8  mac_addr[ETH_ALEN];
+	u8  port_map;           /* Bitmap of ports. Zero if unused entry */
+	u8  stp_override;       /* non zero if set ALR_DAT1_AGE_OVERRID */
+};
+
 struct lan9303 {
 	struct device *dev;
 	struct regmap *regmap;
@@ -22,6 +29,10 @@ struct lan9303 {
 	struct mutex indirect_mutex; /* protect indexed register access */
 	const struct lan9303_phy_ops *ops;
 	bool is_bridged; /* true if port 1 and 2 is bridged */
+	/* LAN9303 do not offer reading specific ALR entry. Cache all
+	 * static entries in a flat table
+	 **/
+	struct lan9303_alr_cache_entry alr_cache[LAN9303_NUM_ALR_RECORDS];
 };
 
 extern const struct regmap_access_table lan9303_register_set;
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
