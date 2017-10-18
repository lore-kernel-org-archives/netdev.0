From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 2/2] net: dsa: lan9303: Add fdb/mdb manipulation
Date: Wed, 18 Oct 2017 12:59:35 +0200
Message-ID: <20171018105935.12489-3-privat@egil-hjelmeland.no>
References: <20171018105935.12489-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171018105935.12489-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add functions for managing the lan9303 ALR (Address Logic
Resolution).

Implement DSA methods: port_fdb_add, port_fdb_del, port_mdb_prepare,
port_mdb_add and port_mdb_del.

Since the lan9303 do not offer reading specific ALR entry, the driver
caches all static entries - in a flat table.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 175 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |   9 +++
 2 files changed, 184 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 8b5202f3c0b0..4177e9d2e8ae 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -19,6 +19,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/if_bridge.h>
+#include <linux/etherdevice.h>
 
 #include "lan9303.h"
 
@@ -499,6 +500,37 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 static const int alrport_2_portmap[] = {1, 2, 4, 0, 3, 5, 6, 7 };
 static const int portmap_2_alrport[] = {3, 0, 1, 4, 2, 5, 6, 7 };
 
+/* ALR: Cache static entries: mac address + port bitmap */
+
+/* Return pointer to first free ALR cache entry, return NULL if none */
+static struct lan9303_alr_cache_entry *
+lan9303_alr_cache_find_free(struct lan9303 *chip)
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
+static struct lan9303_alr_cache_entry *
+lan9303_alr_cache_find_mac(struct lan9303 *chip, const u8 *mac_addr)
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
 /* ALR: Actual register access functions */
 
 /* This function will wait a while until mask & reg == value */
@@ -610,6 +642,76 @@ static void alr_loop_cb_fdb_port_dump(struct lan9303 *chip, u32 dat0,
 	dump_ctx->cb(mac, 0, is_static, dump_ctx->data);
 }
 
+/* ALR: Add/modify/delete ALR entries */
+
+/* Set a static ALR entry. Delete entry if port_map is zero */
+static void lan9303_alr_set_entry(struct lan9303 *chip, const u8 *mac,
+				  u8 port_map, bool stp_override)
+{
+	u32 dat0, dat1, alr_port;
+
+	dev_dbg(chip->dev, "%s(%pM, %d)\n", __func__, mac, port_map);
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
+	lan9303_alr_make_entry_raw(chip, dat0, dat1);
+}
+
+/* Add port to static ALR entry, create new static entry if needed */
+static int lan9303_alr_add_port(struct lan9303 *chip, const u8 *mac,
+				int port, bool stp_override)
+{
+	struct lan9303_alr_cache_entry *entr;
+
+	entr = lan9303_alr_cache_find_mac(chip, mac);
+	if (!entr) { /*New entry */
+		entr = lan9303_alr_cache_find_free(chip);
+		if (!entr)
+			return -ENOSPC;
+		ether_addr_copy(entr->mac_addr, mac);
+	}
+	entr->port_map |= BIT(port);
+	entr->stp_override = stp_override;
+	lan9303_alr_set_entry(chip, mac, entr->port_map, stp_override);
+	return 0;
+}
+
+/* Delete static port from ALR entry, delete entry if last port */
+static int lan9303_alr_del_port(struct lan9303 *chip, const u8 *mac,
+				int port)
+{
+	struct lan9303_alr_cache_entry *entr;
+
+	entr = lan9303_alr_cache_find_mac(chip, mac);
+	if (!entr)
+		return 0;  /* no static entry found */
+		/* Question: Should we delete any learned entry?
+		 * { lan9303_alr_set_entry(chip, mac, 0, false); return 0; }
+		 */
+
+	entr->port_map &= ~BIT(port);
+	if (entr->port_map == 0) /* zero means its free again */
+		eth_zero_addr(&entr->port_map);
+	lan9303_alr_set_entry(chip, mac, entr->port_map, entr->stp_override);
+	return 0;
+}
+
 /* --------------------- Various chip setup ----------------------*/
 
 static int lan9303_disable_processing_port(struct lan9303 *chip,
@@ -1065,6 +1167,30 @@ static void lan9303_port_fast_age(struct dsa_switch *ds, int port)
 	lan9303_alr_loop(chip, alr_loop_cb_del_port_learned, &port);
 }
 
+static int lan9303_port_fdb_add(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(%d, %pM, %d)\n", __func__, port, addr, vid);
+	if (vid)
+		return -EOPNOTSUPP;
+	return lan9303_alr_add_port(chip, addr, port, false);
+}
+
+static int lan9303_port_fdb_del(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid)
+
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(%d, %pM, %d)\n", __func__, port, addr, vid);
+	if (vid)
+		return -EOPNOTSUPP;
+	lan9303_alr_del_port(chip, addr, port);
+	return 0;
+}
+
 static int lan9303_port_fdb_dump(struct dsa_switch *ds, int port,
 				 dsa_fdb_dump_cb_t *cb, void *data)
 {
@@ -1080,6 +1206,50 @@ static int lan9303_port_fdb_dump(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static int lan9303_port_mdb_prepare(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_mdb *mdb,
+		struct switchdev_trans *trans)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(%d, %pM, %d)\n", __func__, port, mdb->addr,
+		mdb->vid);
+	if (mdb->vid)
+		return -EOPNOTSUPP;
+	if (lan9303_alr_cache_find_mac(chip, mdb->addr))
+		return 0;
+	if (!lan9303_alr_cache_find_free(chip))
+		return -ENOSPC;
+	return 0;
+}
+
+static void lan9303_port_mdb_add(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_mdb *mdb,
+		struct switchdev_trans *trans)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(%d, %pM, %d)\n", __func__, port, mdb->addr,
+		mdb->vid);
+	lan9303_alr_add_port(chip, mdb->addr, port, false);
+}
+
+static int lan9303_port_mdb_del(
+		struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_mdb *mdb)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(%d, %pM, %d)\n", __func__, port, mdb->addr,
+		mdb->vid);
+	if (mdb->vid)
+		return -EOPNOTSUPP;
+	lan9303_alr_del_port(chip, mdb->addr, port);
+	return 0;
+}
+
 static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
@@ -1095,7 +1265,12 @@ static const struct dsa_switch_ops lan9303_switch_ops = {
 	.port_bridge_leave      = lan9303_port_bridge_leave,
 	.port_stp_state_set     = lan9303_port_stp_state_set,
 	.port_fast_age          = lan9303_port_fast_age,
+	.port_fdb_add           = lan9303_port_fdb_add,
+	.port_fdb_del           = lan9303_port_fdb_del,
 	.port_fdb_dump          = lan9303_port_fdb_dump,
+	.port_mdb_prepare       = lan9303_port_mdb_prepare,
+	.port_mdb_add           = lan9303_port_mdb_add,
+	.port_mdb_del           = lan9303_port_mdb_del,
 };
 
 static int lan9303_register_switch(struct lan9303 *chip)
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index 4db323d65741..d807b1be35f2 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -12,6 +12,11 @@ struct lan9303_phy_ops {
 };
 
 #define LAN9303_NUM_ALR_RECORDS 512
+struct lan9303_alr_cache_entry {
+	u8  mac_addr[ETH_ALEN];
+	u8  port_map;           /* Bitmap of ports. Zero if unused entry */
+	u8  stp_override;       /* non zero if set ALR_DAT1_AGE_OVERRID */
+};
 
 struct lan9303 {
 	struct device *dev;
@@ -25,6 +30,10 @@ struct lan9303 {
 	const struct lan9303_phy_ops *ops;
 	bool is_bridged; /* true if port 1 and 2 are bridged */
 	u32 swe_port_state; /* remember SWE_PORT_STATE while not bridged */
+	/* LAN9303 do not offer reading specific ALR entry. Cache all
+	 * static entries in a flat table
+	 **/
+	struct lan9303_alr_cache_entry alr_cache[LAN9303_NUM_ALR_RECORDS];
 };
 
 extern const struct regmap_access_table lan9303_register_set;
-- 
2.11.0
