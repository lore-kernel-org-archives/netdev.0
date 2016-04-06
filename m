From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/17] mlxsw: spectrum: Add support for PAUSE frames
Date: Wed,  6 Apr 2016 17:10:14 +0200
Message-ID: <1459955416-23786-16-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33636 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbcDFPKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:43 -0400
Received: by mail-wm0-f66.google.com with SMTP id i204so14158636wmd.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:42 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a packet ingress the switch it's placed in its assigned priority
group (PG) buffer in the port's headroom buffer while it goes through
the switch's pipeline. After going through the pipeline - which
determines its egress port(s) and traffic class - it's moved to the
switch's shared buffer awaiting transmission.

However, some packets are not eligible to enter the shared buffer due to
exceeded quotas or insufficient space. Marking their associated PGs as
lossless will cause the packets to accumulate in the PG buffer. Another
reason for packets accumulation are complicated pipelines (e.g.
involving a lot of ACLs).

To prevent packets from being dropped a user can enable PAUSE frames on
the port. This will mark all the active PGs as lossless and set their
size according to the maximum delay, as it's not configured by user.

                         +----------------+   +
                         |                |   |
                         |                |   |
                         |                |   |
                         |                |   |
                         |                |   |
                         |                |   | Delay
                         |                |   |
                         |                |   |
                         |                |   |
                         |                |   |
                         |                |   |
    Xon/Xoff threshold   +----------------+   +
                         |                |   |
                         |                |   | 2 * MTU
                         |                |   |
                         +----------------+   +

The delay (612 [Cells]) was calculated according to worst-case scenario
involving maximum MTU and 100m cables.

After marking the PGs as lossless the device is configured to respect
incoming PAUSE frames (Rx PAUSE) and generate PAUSE frames (Tx PAUSE)
according to user's settings.

Whenever the port's headroom configuration changes we take into account
the PAUSE configuration, so that we correctly set the PG's type (lossy /
lossless), size and threshold. This can happen when:

a) The port's MTU changes, as it directly affects the PG's size.

b) A PG is created following user configuration, by binding a priority
to it.

Note that the relevant SUPPORTED flags were already mistakenly set by
the driver before this commit.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 85 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 17 ++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c |  3 +-
 3 files changed, 95 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 5f4d44e..086682e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -450,15 +450,23 @@ static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static void mlxsw_sp_pg_buf_pack(char *pbmc_pl, int pg_index, int mtu)
+static void mlxsw_sp_pg_buf_pack(char *pbmc_pl, int pg_index, int mtu,
+				 bool pause_en)
 {
 	u16 pg_size = 2 * MLXSW_SP_BYTES_TO_CELLS(mtu);
 
-	mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pg_index, pg_size);
+	if (pause_en) {
+		u16 pg_pause_size = pg_size + MLXSW_SP_PAUSE_DELAY;
+
+		mlxsw_reg_pbmc_lossless_buffer_pack(pbmc_pl, pg_index,
+						    pg_pause_size, pg_size);
+	} else {
+		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pg_index, pg_size);
+	}
 }
 
 int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
-				 u8 *prio_tc)
+				 u8 *prio_tc, bool pause_en)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char pbmc_pl[MLXSW_REG_PBMC_LEN];
@@ -481,14 +489,14 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 
 		if (!configure)
 			continue;
-		mlxsw_sp_pg_buf_pack(pbmc_pl, i, mtu);
+		mlxsw_sp_pg_buf_pack(pbmc_pl, i, mtu, pause_en);
 	}
 
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
 }
 
 static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				      int mtu)
+				      int mtu, bool pause_en)
 {
 	u8 def_prio_tc[IEEE_8021QAZ_MAX_TCS] = {0};
 	bool dcb_en = !!mlxsw_sp_port->dcb.ets;
@@ -496,15 +504,17 @@ static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	prio_tc = dcb_en ? mlxsw_sp_port->dcb.ets->prio_tc : def_prio_tc;
 
-	return __mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu, prio_tc);
+	return __mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu, prio_tc,
+					    pause_en);
 }
 
 static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	bool pause_en = mlxsw_sp_port_is_pause_en(mlxsw_sp_port);
 	int err;
 
-	err = mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu);
+	err = mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu, pause_en);
 	if (err)
 		return err;
 	err = mlxsw_sp_port_mtu_set(mlxsw_sp_port, mtu);
@@ -514,7 +524,7 @@ static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
 	return 0;
 
 err_port_mtu_set:
-	mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu);
+	mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu, pause_en);
 	return err;
 }
 
@@ -993,6 +1003,63 @@ static void mlxsw_sp_port_get_drvinfo(struct net_device *dev,
 		sizeof(drvinfo->bus_info));
 }
 
+static void mlxsw_sp_port_get_pauseparam(struct net_device *dev,
+					 struct ethtool_pauseparam *pause)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+
+	pause->rx_pause = mlxsw_sp_port->link.rx_pause;
+	pause->tx_pause = mlxsw_sp_port->link.tx_pause;
+}
+
+static int mlxsw_sp_port_pause_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				   struct ethtool_pauseparam *pause)
+{
+	char pfcc_pl[MLXSW_REG_PFCC_LEN];
+
+	mlxsw_reg_pfcc_pack(pfcc_pl, mlxsw_sp_port->local_port);
+	mlxsw_reg_pfcc_pprx_set(pfcc_pl, pause->rx_pause);
+	mlxsw_reg_pfcc_pptx_set(pfcc_pl, pause->tx_pause);
+
+	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(pfcc),
+			       pfcc_pl);
+}
+
+static int mlxsw_sp_port_set_pauseparam(struct net_device *dev,
+					struct ethtool_pauseparam *pause)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	bool pause_en = pause->tx_pause || pause->rx_pause;
+	int err;
+
+	if (pause->autoneg) {
+		netdev_err(dev, "PAUSE frames autonegotiation isn't supported\n");
+		return -EINVAL;
+	}
+
+	err = mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu, pause_en);
+	if (err) {
+		netdev_err(dev, "Failed to configure port's headroom\n");
+		return err;
+	}
+
+	err = mlxsw_sp_port_pause_set(mlxsw_sp_port, pause);
+	if (err) {
+		netdev_err(dev, "Failed to set PAUSE parameters\n");
+		goto err_port_pause_configure;
+	}
+
+	mlxsw_sp_port->link.rx_pause = pause->rx_pause;
+	mlxsw_sp_port->link.tx_pause = pause->tx_pause;
+
+	return 0;
+
+err_port_pause_configure:
+	pause_en = mlxsw_sp_port_is_pause_en(mlxsw_sp_port);
+	mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu, pause_en);
+	return err;
+}
+
 struct mlxsw_sp_port_hw_stats {
 	char str[ETH_GSTRING_LEN];
 	u64 (*getter)(char *payload);
@@ -1476,6 +1543,8 @@ static int mlxsw_sp_port_set_settings(struct net_device *dev,
 static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 	.get_drvinfo		= mlxsw_sp_port_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_pauseparam		= mlxsw_sp_port_get_pauseparam,
+	.set_pauseparam		= mlxsw_sp_port_set_pauseparam,
 	.get_strings		= mlxsw_sp_port_get_strings,
 	.set_phys_id		= mlxsw_sp_port_set_phys_id,
 	.get_ethtool_stats	= mlxsw_sp_port_get_stats,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 9e1e4fe..f4b53dd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -67,6 +67,11 @@
 
 #define MLXSW_SP_BYTES_TO_CELLS(b) DIV_ROUND_UP(b, MLXSW_SP_BYTES_PER_CELL)
 
+/* Maximum delay buffer needed in case of PAUSE frames, in cells.
+ * Assumes 100m cable and maximum MTU.
+ */
+#define MLXSW_SP_PAUSE_DELAY 612
+
 struct mlxsw_sp_port;
 
 struct mlxsw_sp_upper {
@@ -172,6 +177,10 @@ struct mlxsw_sp_port {
 		u16 vid;
 	} vport;
 	struct {
+		u8 tx_pause:1,
+		   rx_pause:1;
+	} link;
+	struct {
 		struct ieee_ets *ets;
 		struct ieee_maxrate *maxrate;
 	} dcb;
@@ -183,6 +192,12 @@ struct mlxsw_sp_port {
 	struct devlink_port devlink_port;
 };
 
+static inline bool
+mlxsw_sp_port_is_pause_en(const struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	return mlxsw_sp_port->link.tx_pause || mlxsw_sp_port->link.rx_pause;
+}
+
 static inline struct mlxsw_sp_port *
 mlxsw_sp_port_lagged_get(struct mlxsw_sp *mlxsw_sp, u16 lag_id, u8 port_index)
 {
@@ -280,7 +295,7 @@ int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 int mlxsw_sp_port_prio_tc_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			      u8 switch_prio, u8 tclass);
 int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
-				 u8 *prio_tc);
+				 u8 *prio_tc, bool pause_en);
 int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				  enum mlxsw_reg_qeec_hr hr, u8 index,
 				  u8 next_index, u32 maxrate);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 257e2d4..8786424 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -142,6 +142,7 @@ static int mlxsw_sp_port_pg_destroy(struct mlxsw_sp_port *mlxsw_sp_port,
 static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				      struct ieee_ets *ets)
 {
+	bool pause_en = mlxsw_sp_port_is_pause_en(mlxsw_sp_port);
 	struct ieee_ets *my_ets = mlxsw_sp_port->dcb.ets;
 	struct net_device *dev = mlxsw_sp_port->dev;
 	int err;
@@ -150,7 +151,7 @@ static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	 * traffic is still directed to them.
 	 */
 	err = __mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu,
-					   ets->prio_tc);
+					   ets->prio_tc, pause_en);
 	if (err) {
 		netdev_err(dev, "Failed to configure port's headroom\n");
 		return err;
-- 
2.5.5
