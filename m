From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 1/2] net: dsa: lan9303: Add port_fast_age and port_fdb_dump methods
Date: Wed, 18 Oct 2017 12:59:34 +0200
Message-ID: <20171018105935.12489-2-privat@egil-hjelmeland.no>
References: <20171018105935.12489-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:39844 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751686AbdJRLAS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 07:00:18 -0400
In-Reply-To: <20171018105935.12489-1-privat@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DSA method port_fast_age as a step to STP support.

Add low level functions for accessing the lan9303 ALR (Address Logic
Resolution).

Added DSA method port_fdb_dump

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 159 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |   2 +
 2 files changed, 161 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index fecfe1fe67ea..8b5202f3c0b0 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -124,6 +124,21 @@
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
@@ -478,6 +493,125 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	return 0;
 }
 
+/* ----------------- Address Logic Resolution (ALR)------------------*/
+
+/* Map ALR-port bits to port bitmap, and back*/
+static const int alrport_2_portmap[] = {1, 2, 4, 0, 3, 5, 6, 7 };
+static const int portmap_2_alrport[] = {3, 0, 1, 4, 2, 5, 6, 7 };
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
+		usleep_range(1000, 2000);
+	}
+	return -ETIMEDOUT;
+}
+
+static int lan9303_alr_make_entry_raw(struct lan9303 *chip, u32 dat0, u32 dat1)
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
+typedef void alr_loop_cb_t(struct lan9303 *chip, u32 dat0, u32 dat1,
+			   int portmap, void *ctx);
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
+static void alr_reg_to_mac(u32 dat0, u32 dat1, u8 mac[6])
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
+static void alr_loop_cb_del_port_learned(struct lan9303 *chip, u32 dat0,
+					 u32 dat1, int portmap, void *ctx)
+{
+	int *port = ctx;
+
+	if (((BIT(*port) & portmap) == 0) || (dat1 & ALR_DAT1_STATIC))
+		return;
+
+	/* learned entries has only one port, we can just delete */
+	dat1 &= ~ALR_DAT1_VALID; /* delete entry */
+	lan9303_alr_make_entry_raw(chip, dat0, dat1);
+}
+
+struct port_fdb_dump_ctx {
+	int port;
+	void *data;
+	dsa_fdb_dump_cb_t *cb;
+};
+
+static void alr_loop_cb_fdb_port_dump(struct lan9303 *chip, u32 dat0,
+				      u32 dat1, int portmap, void *ctx)
+{
+	struct port_fdb_dump_ctx *dump_ctx = ctx;
+	u8 mac[ETH_ALEN];
+	bool is_static;
+
+	if ((BIT(dump_ctx->port) & portmap) == 0)
+		return;
+
+	alr_reg_to_mac(dat0, dat1, mac);
+	is_static = !!(dat1 & ALR_DAT1_STATIC);
+	dump_ctx->cb(mac, 0, is_static, dump_ctx->data);
+}
+
+/* --------------------- Various chip setup ----------------------*/
+
 static int lan9303_disable_processing_port(struct lan9303 *chip,
 					   unsigned int port)
 {
@@ -923,6 +1057,29 @@ static void lan9303_port_stp_state_set(struct dsa_switch *ds, int port,
 	/* else: touching SWE_PORT_STATE would break port separation */
 }
 
+static void lan9303_port_fast_age(struct dsa_switch *ds, int port)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(%d)\n", __func__, port);
+	lan9303_alr_loop(chip, alr_loop_cb_del_port_learned, &port);
+}
+
+static int lan9303_port_fdb_dump(struct dsa_switch *ds, int port,
+				 dsa_fdb_dump_cb_t *cb, void *data)
+{
+	struct lan9303 *chip = ds->priv;
+	struct port_fdb_dump_ctx dump_ctx = {
+		.port = port,
+		.data = data,
+		.cb   = cb,
+	};
+
+	dev_dbg(chip->dev, "%s(%d)\n", __func__, port);
+	lan9303_alr_loop(chip, alr_loop_cb_fdb_port_dump, &dump_ctx);
+	return 0;
+}
+
 static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
@@ -937,6 +1094,8 @@ static const struct dsa_switch_ops lan9303_switch_ops = {
 	.port_bridge_join       = lan9303_port_bridge_join,
 	.port_bridge_leave      = lan9303_port_bridge_leave,
 	.port_stp_state_set     = lan9303_port_stp_state_set,
+	.port_fast_age          = lan9303_port_fast_age,
+	.port_fdb_dump          = lan9303_port_fdb_dump,
 };
 
 static int lan9303_register_switch(struct lan9303 *chip)
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index 68ecd544b658..4db323d65741 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -11,6 +11,8 @@ struct lan9303_phy_ops {
 			     int regnum, u16 val);
 };
 
+#define LAN9303_NUM_ALR_RECORDS 512
+
 struct lan9303 {
 	struct device *dev;
 	struct regmap *regmap;
-- 
2.11.0
