From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 2/5] drivers: net: ethernet: cpsw: change cpts_active_slave to active_slave
Date: Tue, 12 Mar 2013 14:46:35 +0530
Message-ID: <1363079798-18147-3-git-send-email-mugunthanvnm@ti.com>
References: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60523 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932349Ab3CLJRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 05:17:19 -0400
In-Reply-To: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change cpts_active_slave to active_slave so that the same DT property
can be used to ethtool and SIOCGMIIPHY.

CC: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    7 ++++---
 arch/arm/boot/dts/am33xx.dtsi                  |    2 +-
 drivers/net/ethernet/ti/cpsw.c                 |   10 +++++-----
 include/linux/platform_data/cpsw.h             |    2 +-
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 8e49c42..4f2ca6b 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -15,7 +15,8 @@ Required properties:
 - mac_control		: Specifies Default MAC control register content
 			  for the specific platform
 - slaves		: Specifies number for slaves
-- cpts_active_slave	: Specifies the slave to use for time stamping
+- active_slave		: Specifies the slave to use for time stamping,
+			  ethtool and SIOCGMIIPHY
 - cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
 - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
 
@@ -52,7 +53,7 @@ Examples:
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
-		cpts_active_slave = <0>;
+		active_slave = <0>;
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
@@ -78,7 +79,7 @@ Examples:
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
-		cpts_active_slave = <0>;
+		active_slave = <0>;
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 0957645..91fe4f1 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -349,7 +349,7 @@
 			rx_descs = <64>;
 			mac_control = <0x20>;
 			slaves = <2>;
-			cpts_active_slave = <0>;
+			active_slave = <0>;
 			cpts_clock_mult = <0x80000000>;
 			cpts_clock_shift = <29>;
 			reg = <0x4a100000 0x800
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 01ffbc4..98aa17a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -942,7 +942,7 @@ static void cpsw_ndo_change_rx_flags(struct net_device *ndev, int flags)
 
 static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 {
-	struct cpsw_slave *slave = &priv->slaves[priv->data.cpts_active_slave];
+	struct cpsw_slave *slave = &priv->slaves[priv->data.active_slave];
 	u32 ts_en, seq_id;
 
 	if (!priv->cpts->tx_enable && !priv->cpts->rx_enable) {
@@ -971,7 +971,7 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	if (priv->data.dual_emac)
 		slave = &priv->slaves[priv->emac_port];
 	else
-		slave = &priv->slaves[priv->data.cpts_active_slave];
+		slave = &priv->slaves[priv->data.active_slave];
 
 	ctrl = slave_read(slave, CPSW2_CONTROL);
 	ctrl &= ~CTRL_ALL_TS_MASK;
@@ -1282,12 +1282,12 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->slaves = prop;
 
-	if (of_property_read_u32(node, "cpts_active_slave", &prop)) {
-		pr_err("Missing cpts_active_slave property in the DT.\n");
+	if (of_property_read_u32(node, "active_slave", &prop)) {
+		pr_err("Missing active_slave property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
-	data->cpts_active_slave = prop;
+	data->active_slave = prop;
 
 	if (of_property_read_u32(node, "cpts_clock_mult", &prop)) {
 		pr_err("Missing cpts_clock_mult property in the DT.\n");
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index 798fb80..bb3cd58 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -30,7 +30,7 @@ struct cpsw_platform_data {
 	u32	channels;	/* number of cpdma channels (symmetric) */
 	u32	slaves;		/* number of slave cpgmac ports */
 	struct cpsw_slave_data	*slave_data;
-	u32	cpts_active_slave; /* time stamping slave */
+	u32	active_slave; /* time stamping, ethtool and SIOCGMIIPHY slave */
 	u32	cpts_clock_mult;  /* convert input clock ticks to nanoseconds */
 	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
 	u32	ale_entries;	/* ale table size */
-- 
1.7.9.5
