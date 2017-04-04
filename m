From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/14] nfp: NSP backend for link configuration operations
Date: Tue,  4 Apr 2017 16:12:34 -0700
Message-ID: <20170404231235.32027-14-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35148 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755317AbdDDXNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:13:04 -0400
Received: by mail-pf0-f174.google.com with SMTP id i5so25012058pfc.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:13:04 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add NSP backend for upcoming link configuration operations.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |   6 +-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |   7 +
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 180 +++++++++++++++++++--
 3 files changed, 179 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 96bb5f6bd87b..4635f42e15b0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -101,7 +101,11 @@ static const struct {
 	int code;
 	const char *msg;
 } nsp_errors[] = {
-	{ 0, "success" } /* placeholder to avoid warnings */
+	{ 6010, "could not map to phy for port" },
+	{ 6011, "not an allowed rate/lanes for port" },
+	{ 6012, "not an allowed rate/lanes for port" },
+	{ 6013, "high/low error, change other port first" },
+	{ 6014, "config not found in flash" },
 };
 
 struct nfp_nsp {
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
index c452ad311993..7d34ff145fd7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
@@ -134,10 +134,17 @@ struct nfp_eth_table {
 struct nfp_eth_table *nfp_eth_read_ports(struct nfp_cpp *cpp);
 struct nfp_eth_table *
 __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp);
+
 int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable);
+int nfp_eth_set_configured(struct nfp_cpp *cpp, unsigned int idx,
+			   bool configed);
 
 struct nfp_nsp *nfp_eth_config_start(struct nfp_cpp *cpp, unsigned int idx);
 int nfp_eth_config_commit_end(struct nfp_nsp *nsp);
 void nfp_eth_config_cleanup_end(struct nfp_nsp *nsp);
 
+int __nfp_eth_set_aneg(struct nfp_nsp *nsp, enum nfp_eth_aneg mode);
+int __nfp_eth_set_speed(struct nfp_nsp *nsp, unsigned int speed);
+int __nfp_eth_set_split(struct nfp_nsp *nsp, unsigned int lanes);
+
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index ca5c041e64a4..639438d8313a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -58,6 +58,7 @@
 
 #define NSP_ETH_PORT_LANES_MASK		cpu_to_le64(NSP_ETH_PORT_LANES)
 
+#define NSP_ETH_STATE_CONFIGURED	BIT_ULL(0)
 #define NSP_ETH_STATE_ENABLED		BIT_ULL(1)
 #define NSP_ETH_STATE_TX_ENABLED	BIT_ULL(2)
 #define NSP_ETH_STATE_RX_ENABLED	BIT_ULL(3)
@@ -67,9 +68,13 @@
 #define NSP_ETH_STATE_OVRD_CHNG		BIT_ULL(22)
 #define NSP_ETH_STATE_ANEG		GENMASK_ULL(25, 23)
 
+#define NSP_ETH_CTRL_CONFIGURED		BIT_ULL(0)
 #define NSP_ETH_CTRL_ENABLED		BIT_ULL(1)
 #define NSP_ETH_CTRL_TX_ENABLED		BIT_ULL(2)
 #define NSP_ETH_CTRL_RX_ENABLED		BIT_ULL(3)
+#define NSP_ETH_CTRL_SET_RATE		BIT_ULL(4)
+#define NSP_ETH_CTRL_SET_LANES		BIT_ULL(5)
+#define NSP_ETH_CTRL_SET_ANEG		BIT_ULL(6)
 
 enum nfp_eth_raw {
 	NSP_ETH_RAW_PORT = 0,
@@ -100,21 +105,38 @@ union eth_table_entry {
 	__le64 raw[NSP_ETH_NUM_RAW];
 };
 
-static unsigned int nfp_eth_rate(enum nfp_eth_rate rate)
+static const struct {
+	enum nfp_eth_rate rate;
+	unsigned int speed;
+} nsp_eth_rate_tbl[] = {
+	{ RATE_INVALID,	0, },
+	{ RATE_10M,	SPEED_10, },
+	{ RATE_100M,	SPEED_100, },
+	{ RATE_1G,	SPEED_1000, },
+	{ RATE_10G,	SPEED_10000, },
+	{ RATE_25G,	SPEED_25000, },
+};
+
+static unsigned int nfp_eth_rate2speed(enum nfp_eth_rate rate)
 {
-	unsigned int rate_xlate[] = {
-		[RATE_INVALID]		= 0,
-		[RATE_10M]		= SPEED_10,
-		[RATE_100M]		= SPEED_100,
-		[RATE_1G]		= SPEED_1000,
-		[RATE_10G]		= SPEED_10000,
-		[RATE_25G]		= SPEED_25000,
-	};
+	int i;
 
-	if (rate >= ARRAY_SIZE(rate_xlate))
-		return 0;
+	for (i = 0; i < ARRAY_SIZE(nsp_eth_rate_tbl); i++)
+		if (nsp_eth_rate_tbl[i].rate == rate)
+			return nsp_eth_rate_tbl[i].speed;
+
+	return 0;
+}
+
+static unsigned int nfp_eth_speed2rate(unsigned int speed)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(nsp_eth_rate_tbl); i++)
+		if (nsp_eth_rate_tbl[i].speed == speed)
+			return nsp_eth_rate_tbl[i].rate;
 
-	return rate_xlate[rate];
+	return RATE_INVALID;
 }
 
 static void nfp_eth_copy_mac_reverse(u8 *dst, const u8 *src)
@@ -145,7 +167,7 @@ nfp_eth_port_translate(struct nfp_nsp *nsp, const union eth_table_entry *src,
 	dst->tx_enabled = FIELD_GET(NSP_ETH_STATE_TX_ENABLED, state);
 	dst->rx_enabled = FIELD_GET(NSP_ETH_STATE_RX_ENABLED, state);
 
-	rate = nfp_eth_rate(FIELD_GET(NSP_ETH_STATE_RATE, state));
+	rate = nfp_eth_rate2speed(FIELD_GET(NSP_ETH_STATE_RATE, state));
 	dst->speed = dst->lanes * rate;
 
 	dst->interface = FIELD_GET(NSP_ETH_STATE_INTERFACE, state);
@@ -392,3 +414,135 @@ int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable)
 
 	return nfp_eth_config_commit_end(nsp);
 }
+
+/**
+ * nfp_eth_set_configured() - set PHY module configured control bit
+ * @cpp:	NFP CPP handle
+ * @idx:	NFP chip-wide port index
+ * @configed:	Desired state
+ *
+ * Set the ifup/ifdown state on the PHY.
+ *
+ * Return: 0 or -ERRNO.
+ */
+int nfp_eth_set_configured(struct nfp_cpp *cpp, unsigned int idx, bool configed)
+{
+	union eth_table_entry *entries;
+	struct nfp_nsp *nsp;
+	u64 reg;
+
+	nsp = nfp_eth_config_start(cpp, idx);
+	if (IS_ERR(nsp))
+		return PTR_ERR(nsp);
+
+	entries = nfp_nsp_config_entries(nsp);
+
+	/* Check if we are already in requested state */
+	reg = le64_to_cpu(entries[idx].state);
+	if (configed != FIELD_GET(NSP_ETH_STATE_CONFIGURED, reg)) {
+		reg = le64_to_cpu(entries[idx].control);
+		reg &= ~NSP_ETH_CTRL_CONFIGURED;
+		reg |= FIELD_PREP(NSP_ETH_CTRL_CONFIGURED, configed);
+		entries[idx].control = cpu_to_le64(reg);
+
+		nfp_nsp_config_set_modified(nsp, true);
+	}
+
+	return nfp_eth_config_commit_end(nsp);
+}
+
+/* Force inline, FIELD_* macroes require masks to be compilation-time known */
+static __always_inline int
+nfp_eth_set_bit_config(struct nfp_nsp *nsp, unsigned int raw_idx,
+		       const u64 mask, unsigned int val, const u64 ctrl_bit)
+{
+	union eth_table_entry *entries = nfp_nsp_config_entries(nsp);
+	unsigned int idx = nfp_nsp_config_idx(nsp);
+	u64 reg;
+
+	/* Note: set features were added in ABI 0.14 but the error
+	 *	 codes were initially not populated correctly.
+	 */
+	if (nfp_nsp_get_abi_ver_minor(nsp) < 17) {
+		nfp_err(nfp_nsp_cpp(nsp),
+			"set operations not supported, please update flash\n");
+		return -EOPNOTSUPP;
+	}
+
+	/* Check if we are already in requested state */
+	reg = le64_to_cpu(entries[idx].raw[raw_idx]);
+	if (val == FIELD_GET(mask, reg))
+		return 0;
+
+	reg &= ~mask;
+	reg |= FIELD_PREP(mask, val);
+	entries[idx].raw[raw_idx] = cpu_to_le64(reg);
+
+	entries[idx].control |= cpu_to_le64(ctrl_bit);
+
+	nfp_nsp_config_set_modified(nsp, true);
+
+	return 0;
+}
+
+/**
+ * __nfp_eth_set_aneg() - set PHY autonegotiation control bit
+ * @nsp:	NFP NSP handle returned from nfp_eth_config_start()
+ * @mode:	Desired autonegotiation mode
+ *
+ * Allow/disallow PHY module to advertise/perform autonegotiation.
+ * Will write to hwinfo overrides in the flash (persistent config).
+ *
+ * Return: 0 or -ERRNO.
+ */
+int __nfp_eth_set_aneg(struct nfp_nsp *nsp, enum nfp_eth_aneg mode)
+{
+	return nfp_eth_set_bit_config(nsp, NSP_ETH_RAW_STATE,
+				      NSP_ETH_STATE_ANEG, mode,
+				      NSP_ETH_CTRL_SET_ANEG);
+}
+
+/**
+ * __nfp_eth_set_speed() - set interface speed/rate
+ * @nsp:	NFP NSP handle returned from nfp_eth_config_start()
+ * @speed:	Desired speed (per lane)
+ *
+ * Set lane speed.  Provided @speed value should be subport speed divided
+ * by number of lanes this subport is spanning (i.e. 10000 for 40G, 25000 for
+ * 50G, etc.)
+ * Will write to hwinfo overrides in the flash (persistent config).
+ *
+ * Return: 0 or -ERRNO.
+ */
+int __nfp_eth_set_speed(struct nfp_nsp *nsp, unsigned int speed)
+{
+	enum nfp_eth_rate rate;
+
+	rate = nfp_eth_speed2rate(speed);
+	if (rate == RATE_INVALID) {
+		nfp_warn(nfp_nsp_cpp(nsp),
+			 "could not find matching lane rate for speed %u\n",
+			 speed);
+		return -EINVAL;
+	}
+
+	return nfp_eth_set_bit_config(nsp, NSP_ETH_RAW_STATE,
+				      NSP_ETH_STATE_RATE, rate,
+				      NSP_ETH_CTRL_SET_RATE);
+}
+
+/**
+ * __nfp_eth_set_split() - set interface lane split
+ * @nsp:	NFP NSP handle returned from nfp_eth_config_start()
+ * @lanes:	Desired lanes per port
+ *
+ * Set number of lanes in the port.
+ * Will write to hwinfo overrides in the flash (persistent config).
+ *
+ * Return: 0 or -ERRNO.
+ */
+int __nfp_eth_set_split(struct nfp_nsp *nsp, unsigned int lanes)
+{
+	return nfp_eth_set_bit_config(nsp, NSP_ETH_RAW_PORT, NSP_ETH_PORT_LANES,
+				      lanes, NSP_ETH_CTRL_SET_LANES);
+}
-- 
2.11.0
