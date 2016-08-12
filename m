From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 18/18] liquidio:CN23XX pause frame support
Date: Fri, 12 Aug 2016 11:20:35 -0700
Message-ID: <1471026035-15323-19-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0040.outbound.protection.outlook.com ([104.47.41.40]:7366
	"EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752365AbcHLSyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 14:54:09 -0400
In-Reply-To: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for pause frame and priv flag for cn23xx
device.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 110 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  12 ++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  11 ++-
 3 files changed, 126 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 1e7d683..a64eedf 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -190,6 +190,10 @@ static const char oct_droq_stats_strings[][ETH_GSTRING_LEN] = {
 	"buffer_alloc_failure",
 };
 
+/* LiquidIO driver private flags */
+static const char oct_priv_flags_strings[][ETH_GSTRING_LEN] = {
+};
+
 #define OCTNIC_NCMD_AUTONEG_ON  0x1
 #define OCTNIC_NCMD_PHY_ON      0x2
 
@@ -659,6 +663,69 @@ lio_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 	pause->rx_pause = oct->rx_pause;
 }
 
+static int
+lio_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
+{
+	/* Notes: Not supporting any auto negotiation in these
+	 * drivers.
+	 */
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	struct oct_link_info *linfo = &lio->linfo;
+
+	int ret = 0;
+
+	if (oct->chip_id != OCTEON_CN23XX_PF_VID)
+		return -EINVAL;
+
+	if (linfo->link.s.duplex == 0) {
+		/*no flow control for half duplex*/
+		if (pause->rx_pause || pause->tx_pause)
+			return -EINVAL;
+	}
+
+	/*do not support autoneg of link flow control*/
+	if (pause->autoneg == AUTONEG_ENABLE)
+		return -EINVAL;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_FLOW_CTL;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	if (pause->rx_pause) {
+		/*enable rx pause*/
+		nctrl.ncmd.s.param1 = 1;
+	} else {
+		/*disable rx pause*/
+		nctrl.ncmd.s.param1 = 0;
+	}
+
+	if (pause->tx_pause) {
+		/*enable tx pause*/
+		nctrl.ncmd.s.param2 = 1;
+	} else {
+		/*disable tx pause*/
+		nctrl.ncmd.s.param2 = 0;
+	}
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Failed to set pause parameter\n");
+		return -EINVAL;
+	}
+
+	oct->rx_pause = pause->rx_pause;
+	oct->tx_pause = pause->tx_pause;
+
+	return 0;
+}
+
 static void
 lio_get_ethtool_stats(struct net_device *netdev,
 		      struct ethtool_stats *stats  __attribute__((unused)),
@@ -926,6 +993,27 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	}
 }
 
+static void lio_get_priv_flags_strings(struct lio *lio, u8 *data)
+{
+	struct octeon_device *oct_dev = lio->oct_dev;
+	int i;
+
+	switch (oct_dev->chip_id) {
+	case OCTEON_CN23XX_PF_VID:
+		for (i = 0; i < ARRAY_SIZE(oct_priv_flags_strings); i++) {
+			sprintf(data, "%s", oct_priv_flags_strings[i]);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX:
+		break;
+	default:
+		netif_info(lio, drv, lio->netdev, "Unknown Chip !!\n");
+		break;
+	}
+}
+
 static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -965,12 +1053,31 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 		}
 		break;
 
+	case ETH_SS_PRIV_FLAGS:
+		lio_get_priv_flags_strings(lio, data);
+		break;
 	default:
 		netif_info(lio, drv, lio->netdev, "Unknown Stringset !!\n");
 		break;
 	}
 }
 
+static int lio_get_priv_flags_ss_count(struct lio *lio)
+{
+	struct octeon_device *oct_dev = lio->oct_dev;
+
+	switch (oct_dev->chip_id) {
+	case OCTEON_CN23XX_PF_VID:
+		return ARRAY_SIZE(oct_priv_flags_strings);
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX:
+		return -EOPNOTSUPP;
+	default:
+		netif_info(lio, drv, lio->netdev, "Unknown Chip !!\n");
+		return -EOPNOTSUPP;
+	}
+}
+
 static int lio_get_sset_count(struct net_device *netdev, int sset)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -981,6 +1088,8 @@ static int lio_get_sset_count(struct net_device *netdev, int sset)
 		return (ARRAY_SIZE(oct_stats_strings) +
 			ARRAY_SIZE(oct_iq_stats_strings) * oct_dev->num_iqs +
 			ARRAY_SIZE(oct_droq_stats_strings) * oct_dev->num_oqs);
+	case ETH_SS_PRIV_FLAGS:
+		return lio_get_priv_flags_ss_count(lio);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -2097,6 +2206,7 @@ static const struct ethtool_ops lio_ethtool_ops = {
 	.get_strings		= lio_get_strings,
 	.get_ethtool_stats	= lio_get_ethtool_stats,
 	.get_pauseparam		= lio_get_pauseparam,
+	.set_pauseparam		= lio_set_pauseparam,
 	.get_regs_len		= lio_get_regs_len,
 	.get_regs		= lio_get_regs,
 	.get_msglevel		= lio_get_msglevel,
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a5ba8f6..5701a1f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2178,7 +2178,7 @@ static void if_cfg_callback(struct octeon_device *oct,
 	struct liquidio_if_cfg_context *ctx;
 
 	resp = (struct liquidio_if_cfg_resp *)sc->virtrptr;
-	ctx  = (struct liquidio_if_cfg_context *)sc->ctxptr;
+	ctx = (struct liquidio_if_cfg_context *)sc->ctxptr;
 
 	oct = lio_get_device(ctx->octeon_id);
 	if (resp->status)
@@ -3923,7 +3923,10 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		/* Register ethtool support */
 		liquidio_set_ethtool_ops(netdev);
-		octeon_dev->priv_flags = 0x0;
+		if (lio->oct_dev->chip_id == OCTEON_CN23XX_PF_VID)
+			octeon_dev->priv_flags = OCT_PRIV_FLAG_DEFAULT;
+		else
+			octeon_dev->priv_flags = 0x0;
 
 		if (netdev->features & NETIF_F_LRO)
 			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
@@ -4003,8 +4006,7 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 	/* run port_config command for each port */
 	oct->ifcount = num_nic_ports;
 
-	memset(oct->props, 0,
-	       sizeof(struct octdev_props) * num_nic_ports);
+	memset(oct->props, 0, sizeof(struct octdev_props) * num_nic_ports);
 
 	for (i = 0; i < MAX_OCTEON_LINKS; i++)
 		oct->props[i].gmxport = -1;
@@ -4020,7 +4022,7 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 	/* Initialize interrupt moderation params */
 	intrmod_cfg = &((struct octeon_device *)oct)->intrmod;
 	intrmod_cfg->rx_enable = 1;
-	intrmod_cfg->check_intrvl =   LIO_INTRMOD_CHECK_INTERVAL;
+	intrmod_cfg->check_intrvl = LIO_INTRMOD_CHECK_INTERVAL;
 	intrmod_cfg->maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
 	intrmod_cfg->minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
 	intrmod_cfg->rx_maxcnt_trigger = LIO_INTRMOD_RXMAXCNT_TRIGGER;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 773eb09..a86fe2b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -757,8 +757,15 @@ enum {
 	OCT_PRIV_FLAG_TX_BYTES = 0, /* Tx interrupts by pending byte count */
 };
 
-static inline void lio_set_priv_flag(struct octeon_device *octdev, u32 flag,
-				     u32 val)
+#define OCT_PRIV_FLAG_DEFAULT 0x0
+
+static inline u32 lio_get_priv_flag(struct octeon_device *octdev, u32 flag)
+{
+	return !!(octdev->priv_flags & (0x1 << flag));
+}
+
+static inline void lio_set_priv_flag(struct octeon_device *octdev,
+				     u32 flag, u32 val)
 {
 	if (val)
 		octdev->priv_flags |= (0x1 << flag);
-- 
1.8.3.1
