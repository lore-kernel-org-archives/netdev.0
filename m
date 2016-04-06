From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/17] mlxsw: spectrum: Add IEEE 802.1Qbb PFC support
Date: Wed,  6 Apr 2016 17:10:16 +0200
Message-ID: <1459955416-23786-18-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35176 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbcDFPKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:41 -0400
Received: by mail-wm0-f67.google.com with SMTP id a140so14165192wma.2
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:40 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Implement the appropriate DCB ops and allow a user to configure certain
traffic classes as lossless.

The operation configures PFC for both the egress (respecting PFC frames)
and ingress (sending PFC frames) parts of the port.

At egress, when a PFC frame is received for a PFC enabled priority, then
all the priorities mapped to the same TC are stopped.

At ingress, the priority group (PG) buffers to which the enabled PFC
priorities are mapped are configured to be lossless. PFC frames will be
transmitted when the Xoff threshold is crossed.

The user-supplied delay parameter is used to determine the PG's size
according to the following formula:

PG_SIZE = PG_SIZE_LOSSY + delay * CELL_FACTOR + MTU

In the worst case scenario the delay will be made up of packets that
are all of size CELL_SIZE + 1, which means each packet will require
almost twice its true size when buffered in the switch. We therefore
multiply this value by the "cell factor", which is close to 2.

Another MTU is added in case the transmitting host already started
transmitting a maximum length frame when the PFC packet was received.

As with PAUSE enabled ports, when the port's MTU is changed both the
PGs' size and threshold are adjusted accordingly.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  10 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  30 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  12 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 117 ++++++++++++++++++++-
 4 files changed, 158 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 84aacb3..28f5b99 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2442,6 +2442,16 @@ MLXSW_ITEM32(reg, pfcc, aprx, 0x0C, 30, 1);
  */
 MLXSW_ITEM32(reg, pfcc, pfcrx, 0x0C, 16, 8);
 
+#define MLXSW_REG_PFCC_ALL_PRIO 0xFF
+
+static inline void mlxsw_reg_pfcc_prio_pack(char *payload, u8 pfc_en)
+{
+	mlxsw_reg_pfcc_prio_mask_tx_set(payload, MLXSW_REG_PFCC_ALL_PRIO);
+	mlxsw_reg_pfcc_prio_mask_rx_set(payload, MLXSW_REG_PFCC_ALL_PRIO);
+	mlxsw_reg_pfcc_pfctx_set(payload, pfc_en);
+	mlxsw_reg_pfcc_pfcrx_set(payload, pfc_en);
+}
+
 static inline void mlxsw_reg_pfcc_pack(char *payload, u8 local_port)
 {
 	MLXSW_REG_ZERO(pfcc, payload);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 36a94a9..507263a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -451,24 +451,27 @@ static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 }
 
 static void mlxsw_sp_pg_buf_pack(char *pbmc_pl, int pg_index, int mtu,
-				 bool pause_en)
+				 bool pause_en, bool pfc_en, u16 delay)
 {
 	u16 pg_size = 2 * MLXSW_SP_BYTES_TO_CELLS(mtu);
 
-	if (pause_en) {
-		u16 pg_pause_size = pg_size + MLXSW_SP_PAUSE_DELAY;
+	delay = pfc_en ? mlxsw_sp_pfc_delay_get(mtu, delay) :
+			 MLXSW_SP_PAUSE_DELAY;
 
+	if (pause_en || pfc_en)
 		mlxsw_reg_pbmc_lossless_buffer_pack(pbmc_pl, pg_index,
-						    pg_pause_size, pg_size);
-	} else {
+						    pg_size + delay, pg_size);
+	else
 		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pg_index, pg_size);
-	}
 }
 
 int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
-				 u8 *prio_tc, bool pause_en)
+				 u8 *prio_tc, bool pause_en,
+				 struct ieee_pfc *my_pfc)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u8 pfc_en = !!my_pfc ? my_pfc->pfc_en : 0;
+	u16 delay = !!my_pfc ? my_pfc->delay : 0;
 	char pbmc_pl[MLXSW_REG_PBMC_LEN];
 	int i, j, err;
 
@@ -479,9 +482,11 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
 		bool configure = false;
+		bool pfc = false;
 
 		for (j = 0; j < IEEE_8021QAZ_MAX_TCS; j++) {
 			if (prio_tc[j] == i) {
+				pfc = pfc_en & BIT(j);
 				configure = true;
 				break;
 			}
@@ -489,7 +494,7 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 
 		if (!configure)
 			continue;
-		mlxsw_sp_pg_buf_pack(pbmc_pl, i, mtu, pause_en);
+		mlxsw_sp_pg_buf_pack(pbmc_pl, i, mtu, pause_en, pfc, delay);
 	}
 
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
@@ -500,12 +505,14 @@ static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	u8 def_prio_tc[IEEE_8021QAZ_MAX_TCS] = {0};
 	bool dcb_en = !!mlxsw_sp_port->dcb.ets;
+	struct ieee_pfc *my_pfc;
 	u8 *prio_tc;
 
 	prio_tc = dcb_en ? mlxsw_sp_port->dcb.ets->prio_tc : def_prio_tc;
+	my_pfc = dcb_en ? mlxsw_sp_port->dcb.pfc : NULL;
 
 	return __mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu, prio_tc,
-					    pause_en);
+					    pause_en, my_pfc);
 }
 
 static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
@@ -1032,6 +1039,11 @@ static int mlxsw_sp_port_set_pauseparam(struct net_device *dev,
 	bool pause_en = pause->tx_pause || pause->rx_pause;
 	int err;
 
+	if (mlxsw_sp_port->dcb.pfc && mlxsw_sp_port->dcb.pfc->pfc_en) {
+		netdev_err(dev, "PFC already enabled on port\n");
+		return -EINVAL;
+	}
+
 	if (pause->autoneg) {
 		netdev_err(dev, "PAUSE frames autonegotiation isn't supported\n");
 		return -EINVAL;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index f4b53dd..47610a5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -72,6 +72,14 @@
  */
 #define MLXSW_SP_PAUSE_DELAY 612
 
+#define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
+
+static inline u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
+{
+	delay = MLXSW_SP_BYTES_TO_CELLS(DIV_ROUND_UP(delay, BITS_PER_BYTE));
+	return MLXSW_SP_CELL_FACTOR * delay + MLXSW_SP_BYTES_TO_CELLS(mtu);
+}
+
 struct mlxsw_sp_port;
 
 struct mlxsw_sp_upper {
@@ -183,6 +191,7 @@ struct mlxsw_sp_port {
 	struct {
 		struct ieee_ets *ets;
 		struct ieee_maxrate *maxrate;
+		struct ieee_pfc *pfc;
 	} dcb;
 	/* 802.1Q bridge VLANs */
 	unsigned long *active_vlans;
@@ -295,7 +304,8 @@ int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 int mlxsw_sp_port_prio_tc_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			      u8 switch_prio, u8 tclass);
 int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
-				 u8 *prio_tc, bool pause_en);
+				 u8 *prio_tc, bool pause_en,
+				 struct ieee_pfc *my_pfc);
 int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				  enum mlxsw_reg_qeec_hr hr, u8 index,
 				  u8 next_index, u32 maxrate);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 8786424..0b32366 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -34,6 +34,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/string.h>
+#include <linux/bitops.h>
 #include <net/dcbnl.h>
 
 #include "spectrum.h"
@@ -151,7 +152,8 @@ static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	 * traffic is still directed to them.
 	 */
 	err = __mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu,
-					   ets->prio_tc, pause_en);
+					   ets->prio_tc, pause_en,
+					   mlxsw_sp_port->dcb.pfc);
 	if (err) {
 		netdev_err(dev, "Failed to configure port's headroom\n");
 		return err;
@@ -291,11 +293,101 @@ err_port_ets_maxrate_set:
 	return err;
 }
 
+static int mlxsw_sp_port_pfc_cnt_get(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u8 prio)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct ieee_pfc *my_pfc = mlxsw_sp_port->dcb.pfc;
+	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
+	int err;
+
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port,
+			     MLXSW_REG_PPCNT_PRIO_CNT, prio);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
+	if (err)
+		return err;
+
+	my_pfc->requests[prio] = mlxsw_reg_ppcnt_tx_pause_get(ppcnt_pl);
+	my_pfc->indications[prio] = mlxsw_reg_ppcnt_rx_pause_get(ppcnt_pl);
+
+	return 0;
+}
+
+static int mlxsw_sp_dcbnl_ieee_getpfc(struct net_device *dev,
+				      struct ieee_pfc *pfc)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err, i;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_pfc_cnt_get(mlxsw_sp_port, i);
+		if (err) {
+			netdev_err(dev, "Failed to get PFC count for priority %d\n",
+				   i);
+			return err;
+		}
+	}
+
+	memcpy(pfc, mlxsw_sp_port->dcb.pfc, sizeof(*pfc));
+
+	return 0;
+}
+
+static int mlxsw_sp_port_pfc_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				 struct ieee_pfc *pfc)
+{
+	char pfcc_pl[MLXSW_REG_PFCC_LEN];
+
+	mlxsw_reg_pfcc_pack(pfcc_pl, mlxsw_sp_port->local_port);
+	mlxsw_reg_pfcc_prio_pack(pfcc_pl, pfc->pfc_en);
+
+	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(pfcc),
+			       pfcc_pl);
+}
+
+static int mlxsw_sp_dcbnl_ieee_setpfc(struct net_device *dev,
+				      struct ieee_pfc *pfc)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err;
+
+	if (mlxsw_sp_port->link.tx_pause || mlxsw_sp_port->link.rx_pause) {
+		netdev_err(dev, "PAUSE frames already enabled on port\n");
+		return -EINVAL;
+	}
+
+	err = __mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu,
+					   mlxsw_sp_port->dcb.ets->prio_tc,
+					   false, pfc);
+	if (err) {
+		netdev_err(dev, "Failed to configure port's headroom for PFC\n");
+		return err;
+	}
+
+	err = mlxsw_sp_port_pfc_set(mlxsw_sp_port, pfc);
+	if (err) {
+		netdev_err(dev, "Failed to configure PFC\n");
+		goto err_port_pfc_set;
+	}
+
+	memcpy(mlxsw_sp_port->dcb.pfc, pfc, sizeof(*pfc));
+
+	return 0;
+
+err_port_pfc_set:
+	__mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu,
+				     mlxsw_sp_port->dcb.ets->prio_tc, false,
+				     mlxsw_sp_port->dcb.pfc);
+	return err;
+}
+
 static const struct dcbnl_rtnl_ops mlxsw_sp_dcbnl_ops = {
 	.ieee_getets		= mlxsw_sp_dcbnl_ieee_getets,
 	.ieee_setets		= mlxsw_sp_dcbnl_ieee_setets,
 	.ieee_getmaxrate	= mlxsw_sp_dcbnl_ieee_getmaxrate,
 	.ieee_setmaxrate	= mlxsw_sp_dcbnl_ieee_setmaxrate,
+	.ieee_getpfc		= mlxsw_sp_dcbnl_ieee_getpfc,
+	.ieee_setpfc		= mlxsw_sp_dcbnl_ieee_setpfc,
 
 	.getdcbx		= mlxsw_sp_dcbnl_getdcbx,
 	.setdcbx		= mlxsw_sp_dcbnl_setdcbx,
@@ -338,6 +430,23 @@ static void mlxsw_sp_port_maxrate_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 	kfree(mlxsw_sp_port->dcb.maxrate);
 }
 
+static int mlxsw_sp_port_pfc_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	mlxsw_sp_port->dcb.pfc = kzalloc(sizeof(*mlxsw_sp_port->dcb.pfc),
+					 GFP_KERNEL);
+	if (!mlxsw_sp_port->dcb.pfc)
+		return -ENOMEM;
+
+	mlxsw_sp_port->dcb.pfc->pfc_cap = IEEE_8021QAZ_MAX_TCS;
+
+	return 0;
+}
+
+static void mlxsw_sp_port_pfc_fini(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	kfree(mlxsw_sp_port->dcb.pfc);
+}
+
 int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	int err;
@@ -348,11 +457,16 @@ int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	err = mlxsw_sp_port_maxrate_init(mlxsw_sp_port);
 	if (err)
 		goto err_port_maxrate_init;
+	err = mlxsw_sp_port_pfc_init(mlxsw_sp_port);
+	if (err)
+		goto err_port_pfc_init;
 
 	mlxsw_sp_port->dev->dcbnl_ops = &mlxsw_sp_dcbnl_ops;
 
 	return 0;
 
+err_port_pfc_init:
+	mlxsw_sp_port_maxrate_fini(mlxsw_sp_port);
 err_port_maxrate_init:
 	mlxsw_sp_port_ets_fini(mlxsw_sp_port);
 	return err;
@@ -360,6 +474,7 @@ err_port_maxrate_init:
 
 void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 {
+	mlxsw_sp_port_pfc_fini(mlxsw_sp_port);
 	mlxsw_sp_port_maxrate_fini(mlxsw_sp_port);
 	mlxsw_sp_port_ets_fini(mlxsw_sp_port);
 }
-- 
2.5.5
