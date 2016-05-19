From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 3/4] liquidio updates and features
Date: Thu, 19 May 2016 11:56:32 -0700
Message-ID: <1463684193-25264-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1463684193-25264-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2on0093.outbound.protection.outlook.com ([207.46.100.93]:40651
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754924AbcESVgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 17:36:23 -0400
In-Reply-To: <1463684193-25264-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is third in series of patches for liquidio ethtool
updates:
Add extensive support of statistics for data path, control and
firmware. Improved support for interrupt moderation.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 975 ++++++++++++++++-----
 1 file changed, 744 insertions(+), 231 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 245c063..8ef0497 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -40,6 +40,8 @@
 #include "cn68xx_device.h"
 #include "liquidio_image.h"
 
+static int octnet_get_link_stats(struct net_device *netdev);
+
 struct oct_mdio_cmd_context {
 	int octeon_id;
 	wait_queue_head_t wc;
@@ -71,39 +73,130 @@ enum {
 	INTERFACE_MODE_RXAUI,
 	INTERFACE_MODE_QSGMII,
 	INTERFACE_MODE_AGL,
+	INTERFACE_MODE_XLAUI,
+	INTERFACE_MODE_XFI,
+	INTERFACE_MODE_10G_KR,
+	INTERFACE_MODE_40G_KR4,
+	INTERFACE_MODE_MIXED,
 };
 
 #define ARRAY_LENGTH(a) (sizeof(a) / sizeof((a)[0]))
 #define OCT_ETHTOOL_REGDUMP_LEN  4096
 #define OCT_ETHTOOL_REGSVER  1
 
+/* statistics of PF */
+static const char oct_stats_strings[][ETH_GSTRING_LEN] = {
+	"rx_packets",
+	"tx_packets",
+	"rx_bytes",
+	"tx_bytes",
+	"rx_errors",	/*jabber_err+l2_err+frame_err */
+	"tx_errors",	/*fw_err_pko+fw_err_link+fw_err_drop */
+	"rx_dropped",   /*st->fromwire.total_rcvd - st->fromwire.fw_total_rcvd
+			*+st->fromwire.dmac_drop + st->fromwire.fw_err_drop
+			*/
+	"tx_dropped",
+
+	"tx_total_sent",
+	"tx_total_fwd",
+	"tx_err_pko",
+	"tx_err_link",
+	"tx_err_drop",
+
+	"tx_tso",
+	"tx_tso_packets",
+	"tx_tso_err",
+
+	"mac_tx_total_pkts",
+	"mac_tx_total_bytes",
+	"mac_tx_mcast_pkts",
+	"mac_tx_bcast_pkts",
+	"mac_tx_ctl_packets",	/*oct->link_stats.fromhost.ctl_sent */
+	"mac_tx_total_collisions",
+	"mac_tx_one_collision",
+	"mac_tx_multi_collison",
+	"mac_tx_max_collision_fail",
+	"mac_tx_max_deferal_fail",
+	"mac_tx_fifo_err",
+	"mac_tx_runts",
+
+	"rx_total_rcvd",
+	"rx_total_fwd",
+	"rx_jabber_err",
+	"rx_l2_err",
+	"rx_frame_err",
+	"rx_err_pko",
+	"rx_err_link",
+	"rx_err_drop",
+
+	"rx_lro_pkts",
+	"rx_lro_bytes",
+	"rx_total_lro",
+
+	"rx_lro_aborts",
+	"rx_lro_aborts_port",
+	"rx_lro_aborts_seq",
+	"rx_lro_aborts_tsval",
+	"rx_lro_aborts_timer",
+	"rx_fwd_rate",
+
+	"mac_rx_total_rcvd",
+	"mac_rx_bytes",
+	"mac_rx_total_bcst",
+	"mac_rx_total_mcst",
+	"mac_rx_runts",
+	"mac_rx_ctl_packets",
+	"mac_rx_fifo_err",
+	"mac_rx_dma_drop",
+	"mac_rx_fcs_err",
+
+	"link_state_changes",
+};
+
+/* statistics of host tx queue */
 static const char oct_iq_stats_strings[][ETH_GSTRING_LEN] = {
-	"Instr posted",
-	"Instr processed",
-	"Instr dropped",
-	"Bytes Sent",
-	"Sgentry_sent",
-	"Inst cntreg",
-	"Tx done",
-	"Tx Iq busy",
-	"Tx dropped",
-	"Tx bytes",
+	"packets",		/*oct->instr_queue[iq_no]->stats.tx_done*/
+	"bytes",		/*oct->instr_queue[iq_no]->stats.tx_tot_bytes*/
+	"dropped",
+	"iq_busy",
+	"sgentry_sent",
+
+	"fw_instr_posted",
+	"fw_instr_processed",
+	"fw_instr_dropped",
+	"fw_bytes_sent",
+
+	"tso",
+	"txq_restart",
 };
 
+/* statistics of host rx queue */
 static const char oct_droq_stats_strings[][ETH_GSTRING_LEN] = {
-	"OQ Pkts Received",
-	"OQ Bytes Received",
-	"Dropped no dispatch",
-	"Dropped nomem",
-	"Dropped toomany",
-	"Stack RX cnt",
-	"Stack RX Bytes",
-	"RX dropped",
+	"packets",		/*oct->droq[oq_no]->stats.rx_pkts_received */
+	"bytes",		/*oct->droq[oq_no]->stats.rx_bytes_received */
+	"dropped",		/*oct->droq[oq_no]->stats.rx_dropped+
+				 *oct->droq[oq_no]->stats.dropped_nodispatch+
+				 *oct->droq[oq_no]->stats.dropped_toomany+
+				 *oct->droq[oq_no]->stats.dropped_nomem
+				 */
+	"dropped_nomem",
+	"dropped_toomany",
+	"fw_dropped",
+	"fw_pkts_received",
+	"fw_bytes_received",
+	"fw_dropped_nodispatch",
+
+	"buffer_alloc_failure",
 };
 
 #define OCTNIC_NCMD_AUTONEG_ON  0x1
 #define OCTNIC_NCMD_PHY_ON      0x2
 
+#ifndef SPEED_UNKNOWN
+#define SPEED_UNKNOWN -1
+#define DUPLEX_UNKNOWN 0xFF
+#endif
+
 static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -112,8 +205,9 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	linfo = &lio->linfo;
 
-	if (linfo->link.s.interface == INTERFACE_MODE_XAUI ||
-	    linfo->link.s.interface == INTERFACE_MODE_RXAUI) {
+	if (linfo->link.s.if_mode == INTERFACE_MODE_XAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_RXAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_XFI) {
 		ecmd->port = PORT_FIBRE;
 		ecmd->supported =
 			(SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE |
@@ -124,10 +218,11 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->autoneg = AUTONEG_DISABLE;
 
 	} else {
-		dev_err(&oct->pci_dev->dev, "Unknown link interface reported\n");
+		dev_err(&oct->pci_dev->dev, "Unknown link interface reported %d\n",
+			linfo->link.s.if_mode);
 	}
 
-	if (linfo->link.s.status) {
+	if (linfo->link.s.link_up) {
 		ethtool_cmd_speed_set(ecmd, linfo->link.s.speed);
 		ecmd->duplex = linfo->link.s.duplex;
 	} else {
@@ -146,13 +241,13 @@ lio_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 
 	lio = GET_LIO(netdev);
 	oct = lio->oct_dev;
-
 	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
 	strcpy(drvinfo->driver, "liquidio");
 	strcpy(drvinfo->version, LIQUIDIO_VERSION);
 	strncpy(drvinfo->fw_version, oct->fw_info.liquidio_firmware_version,
 		ETHTOOL_FWVERS_LEN);
 	strncpy(drvinfo->bus_info, pci_name(oct->pci_dev), 32);
+	drvinfo->regdump_len = OCT_ETHTOOL_REGDUMP_LEN;
 }
 
 static void
@@ -222,23 +317,20 @@ static int octnet_gpio_access(struct net_device *netdev, int addr, int val)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	int ret = 0;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_GPIO_ACCESS;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = addr;
-	nctrl.ncmd.s.param3 = val;
+	nctrl.ncmd.s.param1 = addr;
+	nctrl.ncmd.s.param2 = val;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 100;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Failed to configure gpio value\n");
 		return -EINVAL;
@@ -264,9 +356,9 @@ static void octnet_mdio_resp_callback(struct octeon_device *oct,
 	if (status) {
 		dev_err(&oct->pci_dev->dev, "MIDO instruction failed. Status: %llx\n",
 			CVM_CAST64(status));
-		ACCESS_ONCE(mdio_cmd_ctx->cond) = -1;
+		WRITE_ONCE(mdio_cmd_ctx->cond, -1);
 	} else {
-		ACCESS_ONCE(mdio_cmd_ctx->cond) = 1;
+		WRITE_ONCE(mdio_cmd_ctx->cond, 1);
 	}
 	wake_up_interruptible(&mdio_cmd_ctx->wc);
 }
@@ -297,15 +389,16 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 	mdio_cmd_rsp = (struct oct_mdio_cmd_resp *)sc->virtrptr;
 	mdio_cmd = (struct oct_mdio_cmd *)sc->virtdptr;
 
-	ACCESS_ONCE(mdio_cmd_ctx->cond) = 0;
+	WRITE_ONCE(mdio_cmd_ctx->cond, 0);
 	mdio_cmd_ctx->octeon_id = lio_get_device_id(oct_dev);
 	mdio_cmd->op = op;
 	mdio_cmd->mdio_addr = loc;
 	if (op)
 		mdio_cmd->value1 = *value;
-	mdio_cmd->value2 = lio->linfo.ifidx;
 	octeon_swap_8B_data((u64 *)mdio_cmd, sizeof(struct oct_mdio_cmd) / 8);
 
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
 	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC, OPCODE_NIC_MDIO45,
 				    0, 0, 0);
 
@@ -317,7 +410,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 
 	retval = octeon_send_soft_command(oct_dev, sc);
 
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
 		dev_err(&oct_dev->pci_dev->dev,
 			"octnet_mdio45_access instruction failed status: %x\n",
 			retval);
@@ -335,7 +428,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 			octeon_swap_8B_data((u64 *)(&mdio_cmd_rsp->resp),
 					    sizeof(struct oct_mdio_cmd) / 8);
 
-			if (ACCESS_ONCE(mdio_cmd_ctx->cond) == 1) {
+			if (READ_ONCE(mdio_cmd_ctx->cond) == 1) {
 				if (!op)
 					*value = mdio_cmd_rsp->resp.value1;
 			} else {
@@ -379,22 +472,18 @@ static int lio_set_phys_id(struct net_device *netdev,
 
 			/* Configure Beacon values */
 			value = LIO68XX_LED_BEACON_CFGON;
-			ret =
-				octnet_mdio45_access(lio, 1,
-						     LIO68XX_LED_BEACON_ADDR,
-						     &value);
+			ret = octnet_mdio45_access(lio, 1,
+						   LIO68XX_LED_BEACON_ADDR,
+						   &value);
 			if (ret)
 				return ret;
 
 			value = LIO68XX_LED_CTRL_CFGON;
-			ret =
-				octnet_mdio45_access(lio, 1,
-						     LIO68XX_LED_CTRL_ADDR,
-						     &value);
+			ret = octnet_mdio45_access(lio, 1,
+						   LIO68XX_LED_CTRL_ADDR,
+						   &value);
 			if (ret)
 				return ret;
-		} else {
-			return -EINVAL;
 		}
 		break;
 
@@ -438,7 +527,6 @@ static int lio_set_phys_id(struct net_device *netdev,
 						   &lio->phy_beacon_val);
 			if (ret)
 				return ret;
-
 		} else {
 			return -EINVAL;
 		}
@@ -469,7 +557,7 @@ lio_ethtool_get_ringparam(struct net_device *netdev,
 		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf6x, lio->ifidx);
 	}
 
-	if (lio->mtu > OCTNET_DEFAULT_FRM_SIZE) {
+	if (lio->mtu > OCTNET_DEFAULT_FRM_SIZE - OCTNET_FRM_HEADER_SIZE) {
 		ering->rx_pending = 0;
 		ering->rx_max_pending = 0;
 		ering->rx_mini_pending = 0;
@@ -503,10 +591,10 @@ static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
 	if ((msglvl ^ lio->msg_enable) & NETIF_MSG_HW) {
 		if (msglvl & NETIF_MSG_HW)
 			liquidio_set_feature(netdev,
-					     OCTNET_CMD_VERBOSE_ENABLE);
+					     OCTNET_CMD_VERBOSE_ENABLE, 0);
 		else
 			liquidio_set_feature(netdev,
-					     OCTNET_CMD_VERBOSE_DISABLE);
+					     OCTNET_CMD_VERBOSE_DISABLE, 0);
 	}
 
 	lio->msg_enable = msglvl;
@@ -518,8 +606,13 @@ lio_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 	/* Notes: Not supporting any auto negotiation in these
 	 * drivers. Just report pause frame support.
 	 */
-	pause->tx_pause = 1;
-	pause->rx_pause = 1;    /* TODO: Need to support RX pause frame!!. */
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	pause->autoneg = 0;
+
+	pause->tx_pause = oct->tx_pause;
+	pause->rx_pause = oct->rx_pause;
 }
 
 static void
@@ -528,51 +621,245 @@ lio_get_ethtool_stats(struct net_device *netdev,
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
+	struct net_device_stats *netstats = &netdev->stats;
 	int i = 0, j;
 
-	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES; j++) {
-		if (!(oct_dev->io_qmask.iq & (1UL << j)))
+	netdev->netdev_ops->ndo_get_stats(netdev);
+	octnet_get_link_stats(netdev);
+
+	/*sum of oct->droq[oq_no]->stats->rx_pkts_received */
+	data[i++] = CVM_CAST64(netstats->rx_packets);
+	/*sum of oct->instr_queue[iq_no]->stats.tx_done */
+	data[i++] = CVM_CAST64(netstats->tx_packets);
+	/*sum of oct->droq[oq_no]->stats->rx_bytes_received */
+	data[i++] = CVM_CAST64(netstats->rx_bytes);
+	/*sum of oct->instr_queue[iq_no]->stats.tx_tot_bytes */
+	data[i++] = CVM_CAST64(netstats->tx_bytes);
+	data[i++] = CVM_CAST64(netstats->rx_errors);
+	data[i++] = CVM_CAST64(netstats->tx_errors);
+	/*sum of oct->droq[oq_no]->stats->rx_dropped +
+	 *oct->droq[oq_no]->stats->dropped_nodispatch +
+	 *oct->droq[oq_no]->stats->dropped_toomany +
+	 *oct->droq[oq_no]->stats->dropped_nomem
+	 */
+	data[i++] = CVM_CAST64(netstats->rx_dropped);
+	/*sum of oct->instr_queue[iq_no]->stats.tx_dropped */
+	data[i++] = CVM_CAST64(netstats->tx_dropped);
+
+	/*data[i++] = CVM_CAST64(stats->multicast); */
+	/*data[i++] = CVM_CAST64(stats->collisions); */
+
+	/* firmware tx stats */
+	/*per_core_stats[cvmx_get_core_num()].link_stats[mdata->from_ifidx].
+	 *fromhost.fw_total_sent
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_total_sent);
+	/*per_core_stats[i].link_stats[port].fromwire.fw_total_fwd */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_total_fwd);
+	/*per_core_stats[j].link_stats[i].fromhost.fw_err_pko */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_pko);
+	/*per_core_stats[j].link_stats[i].fromhost.fw_err_link */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_link);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 *fw_err_drop
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_drop);
+
+	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.fw_tso */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_tso);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 *fw_tso_fwd
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_tso_fwd);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 *fw_err_tso
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_tso);
+
+	/* mac tx statistics */
+	/*CVMX_BGXX_CMRX_TX_STAT5 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.total_pkts_sent);
+	/*CVMX_BGXX_CMRX_TX_STAT4 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.total_bytes_sent);
+	/*CVMX_BGXX_CMRX_TX_STAT15 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.mcast_pkts_sent);
+	/*CVMX_BGXX_CMRX_TX_STAT14 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.bcast_pkts_sent);
+	/*CVMX_BGXX_CMRX_TX_STAT17 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.ctl_sent);
+	/*CVMX_BGXX_CMRX_TX_STAT0 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.total_collisions);
+	/*CVMX_BGXX_CMRX_TX_STAT3 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.one_collision_sent);
+	/*CVMX_BGXX_CMRX_TX_STAT2 */
+	data[i++] =
+		CVM_CAST64(oct_dev->link_stats.fromhost.multi_collision_sent);
+	/*CVMX_BGXX_CMRX_TX_STAT0 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.max_collision_fail);
+	/*CVMX_BGXX_CMRX_TX_STAT1 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.max_deferral_fail);
+	/*CVMX_BGXX_CMRX_TX_STAT16 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fifo_err);
+	/*CVMX_BGXX_CMRX_TX_STAT6 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.runts);
+
+	/* RX firmware stats */
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_total_rcvd
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_total_rcvd);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_total_fwd
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_total_fwd);
+	/*per_core_stats[core_id].link_stats[ifidx].fromwire.jabber_err */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.jabber_err);
+	/*per_core_stats[core_id].link_stats[ifidx].fromwire.l2_err */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.l2_err);
+	/*per_core_stats[core_id].link_stats[ifidx].fromwire.frame_err */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.frame_err);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_err_pko
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_err_pko);
+	/*per_core_stats[j].link_stats[i].fromwire.fw_err_link */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_err_link);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
+	 *fromwire.fw_err_drop
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_err_drop);
+
+	/* LRO */
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_lro_pkts
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_pkts);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_lro_octs
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_octs);
+	/*per_core_stats[j].link_stats[i].fromwire.fw_total_lro */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_total_lro);
+	/*per_core_stats[j].link_stats[i].fromwire.fw_lro_aborts */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_lro_aborts_port
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_port);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_lro_aborts_seq
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_seq);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_lro_aborts_tsval
+	 */
+	data[i++] =
+		CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_tsval);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
+	 *fw_lro_aborts_timer
+	 */
+	/* intrmod: packet forward rate */
+	data[i++] =
+		CVM_CAST64(oct_dev->link_stats.fromwire.fw_lro_aborts_timer);
+	/*per_core_stats[j].link_stats[i].fromwire.fw_lro_aborts */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fwd_rate);
+
+	/* mac: link-level stats */
+	/*CVMX_BGXX_CMRX_RX_STAT0 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.total_rcvd);
+	/*CVMX_BGXX_CMRX_RX_STAT1 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.bytes_rcvd);
+	/*CVMX_PKI_STATX_STAT5 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.total_bcst);
+	/*CVMX_PKI_STATX_STAT5 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.total_mcst);
+	/*wqe->word2.err_code or wqe->word2.err_level */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.runts);
+	/*CVMX_BGXX_CMRX_RX_STAT2 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.ctl_rcvd);
+	/*CVMX_BGXX_CMRX_RX_STAT6 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fifo_err);
+	/*CVMX_BGXX_CMRX_RX_STAT4 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.dmac_drop);
+	/*wqe->word2.err_code or wqe->word2.err_level */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fcs_err);
+	/*lio->link_changes*/
+	data[i++] = CVM_CAST64(lio->link_changes);
+
+	/* TX  -- lio_update_stats(lio); */
+	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES(oct_dev); j++) {
+		if (!(oct_dev->io_qmask.iq & (1ULL << j)))
 			continue;
+		/*packets to network port*/
+		/*# of packets tx to network */
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_done);
+		/*# of bytes tx to network */
 		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_posted);
-		data[i++] =
-			CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.instr_processed);
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_tot_bytes);
+		/*# of packets dropped */
 		data[i++] =
-			CVM_CAST64(
-				oct_dev->instr_queue[j]->stats.instr_dropped);
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_dropped);
+		/*# of tx fails due to queue full */
 		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.bytes_sent);
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_iq_busy);
+		/*XXX gather entries sent */
 		data[i++] =
 			CVM_CAST64(oct_dev->instr_queue[j]->stats.sgentry_sent);
+
+		/*instruction to firmware: data and control */
+		/*# of instructions to the queue */
 		data[i++] =
-			readl(oct_dev->instr_queue[j]->inst_cnt_reg);
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_done);
-		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_iq_busy);
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_posted);
+		/*# of instructions processed */
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->
+				       stats.instr_processed);
+		/*# of instructions could not be processed */
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->
+				       stats.instr_dropped);
+		/*bytes sent through the queue */
 		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_dropped);
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.bytes_sent);
+
+		/*tso request*/
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_gso);
+		/*txq restart*/
 		data[i++] =
-			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_tot_bytes);
+			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_restart);
 	}
 
-	/* for (j = 0; j < oct_dev->num_oqs; j++){ */
-	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES; j++) {
-		if (!(oct_dev->io_qmask.oq & (1UL << j)))
+	/* RX */
+	/* for (j = 0; j < oct_dev->num_oqs; j++) { */
+	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES(oct_dev); j++) {
+		if (!(oct_dev->io_qmask.oq & (1ULL << j)))
 			continue;
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.pkts_received);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
-		data[i++] =
-			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nodispatch);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem);
-		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_toomany);
+
+		/*packets send to TCP/IP network stack */
+		/*# of packets to network stack */
 		data[i++] =
 			CVM_CAST64(oct_dev->droq[j]->stats.rx_pkts_received);
+		/*# of bytes to network stack */
 		data[i++] =
 			CVM_CAST64(oct_dev->droq[j]->stats.rx_bytes_received);
+		/*# of packets dropped */
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem +
+				       oct_dev->droq[j]->stats.dropped_toomany +
+				       oct_dev->droq[j]->stats.rx_dropped);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.dropped_toomany);
 		data[i++] =
 			CVM_CAST64(oct_dev->droq[j]->stats.rx_dropped);
+
+		/*control and data path*/
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.pkts_received);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nodispatch);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.rx_alloc_failure);
 	}
 }
 
@@ -581,26 +868,43 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
 	int num_iq_stats, num_oq_stats, i, j;
+	int num_stats;
 
-	num_iq_stats = ARRAY_SIZE(oct_iq_stats_strings);
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-		if (!(oct_dev->io_qmask.iq & (1UL << i)))
-			continue;
-		for (j = 0; j < num_iq_stats; j++) {
-			sprintf(data, "IQ%d %s", i, oct_iq_stats_strings[j]);
+	switch (stringset) {
+	case ETH_SS_STATS:
+		num_stats = ARRAY_SIZE(oct_stats_strings);
+		for (j = 0; j < num_stats; j++) {
+			sprintf(data, "%s", oct_stats_strings[j]);
 			data += ETH_GSTRING_LEN;
 		}
-	}
 
-	num_oq_stats = ARRAY_SIZE(oct_droq_stats_strings);
-	/* for (i = 0; i < oct_dev->num_oqs; i++) { */
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-		if (!(oct_dev->io_qmask.oq & (1UL << i)))
-			continue;
-		for (j = 0; j < num_oq_stats; j++) {
-			sprintf(data, "OQ%d %s", i, oct_droq_stats_strings[j]);
-			data += ETH_GSTRING_LEN;
+		num_iq_stats = ARRAY_SIZE(oct_iq_stats_strings);
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct_dev); i++) {
+			if (!(oct_dev->io_qmask.iq & (1ULL << i)))
+				continue;
+			for (j = 0; j < num_iq_stats; j++) {
+				sprintf(data, "tx-%d-%s", i,
+					oct_iq_stats_strings[j]);
+				data += ETH_GSTRING_LEN;
+			}
 		}
+
+		num_oq_stats = ARRAY_SIZE(oct_droq_stats_strings);
+		/* for (i = 0; i < oct_dev->num_oqs; i++) { */
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct_dev); i++) {
+			if (!(oct_dev->io_qmask.oq & (1ULL << i)))
+				continue;
+			for (j = 0; j < num_oq_stats; j++) {
+				sprintf(data, "rx-%d-%s", i,
+					oct_droq_stats_strings[j]);
+				data += ETH_GSTRING_LEN;
+			}
+		}
+		break;
+
+	default:
+		netif_info(lio, drv, lio->netdev, "Unknown Stringset !!\n");
+		break;
 	}
 }
 
@@ -609,8 +913,14 @@ static int lio_get_sset_count(struct net_device *netdev, int sset)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
 
-	return (ARRAY_SIZE(oct_iq_stats_strings) * oct_dev->num_iqs) +
-	       (ARRAY_SIZE(oct_droq_stats_strings) * oct_dev->num_oqs);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return (ARRAY_SIZE(oct_stats_strings) +
+			ARRAY_SIZE(oct_iq_stats_strings) * oct_dev->num_iqs +
+			ARRAY_SIZE(oct_droq_stats_strings) * oct_dev->num_oqs);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static int lio_get_intr_coalesce(struct net_device *netdev,
@@ -618,50 +928,49 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	struct octeon_instr_queue *iq;
 	struct oct_intrmod_cfg *intrmod_cfg;
 
 	intrmod_cfg = &oct->intrmod;
 
 	switch (oct->chip_id) {
-	/* case OCTEON_CN73XX: Todo */
-	/*      break; */
 	case OCTEON_CN68XX:
-	case OCTEON_CN66XX:
-		if (!intrmod_cfg->intrmod_enable) {
+	case OCTEON_CN66XX: {
+		struct octeon_cn6xxx *cn6xxx =
+			(struct octeon_cn6xxx *)oct->chip;
+
+		if (!intrmod_cfg->rx_enable) {
 			intr_coal->rx_coalesce_usecs =
 				CFG_GET_OQ_INTR_TIME(cn6xxx->conf);
 			intr_coal->rx_max_coalesced_frames =
 				CFG_GET_OQ_INTR_PKT(cn6xxx->conf);
-		} else {
-			intr_coal->use_adaptive_rx_coalesce =
-				intrmod_cfg->intrmod_enable;
-			intr_coal->rate_sample_interval =
-				intrmod_cfg->intrmod_check_intrvl;
-			intr_coal->pkt_rate_high =
-				intrmod_cfg->intrmod_maxpkt_ratethr;
-			intr_coal->pkt_rate_low =
-				intrmod_cfg->intrmod_minpkt_ratethr;
-			intr_coal->rx_max_coalesced_frames_high =
-				intrmod_cfg->intrmod_maxcnt_trigger;
-			intr_coal->rx_coalesce_usecs_high =
-				intrmod_cfg->intrmod_maxtmr_trigger;
-			intr_coal->rx_coalesce_usecs_low =
-				intrmod_cfg->intrmod_mintmr_trigger;
-			intr_coal->rx_max_coalesced_frames_low =
-				intrmod_cfg->intrmod_mincnt_trigger;
 		}
-
-		iq = oct->instr_queue[lio->linfo.txpciq[0]];
+		iq = oct->instr_queue[lio->linfo.txpciq[0].s.q_no];
 		intr_coal->tx_max_coalesced_frames = iq->fill_threshold;
 		break;
-
+	}
 	default:
 		netif_info(lio, drv, lio->netdev, "Unknown Chip !!\n");
 		return -EINVAL;
 	}
-
+	if (intrmod_cfg->rx_enable) {
+		intr_coal->use_adaptive_rx_coalesce =
+			intrmod_cfg->rx_enable;
+		intr_coal->rate_sample_interval =
+			intrmod_cfg->check_intrvl;
+		intr_coal->pkt_rate_high =
+			intrmod_cfg->maxpkt_ratethr;
+		intr_coal->pkt_rate_low =
+			intrmod_cfg->minpkt_ratethr;
+		intr_coal->rx_max_coalesced_frames_high =
+			intrmod_cfg->rx_maxcnt_trigger;
+		intr_coal->rx_coalesce_usecs_high =
+			intrmod_cfg->rx_maxtmr_trigger;
+		intr_coal->rx_coalesce_usecs_low =
+			intrmod_cfg->rx_mintmr_trigger;
+		intr_coal->rx_max_coalesced_frames_low =
+			intrmod_cfg->rx_mincnt_trigger;
+	}
 	return 0;
 }
 
@@ -681,19 +990,20 @@ static void octnet_intrmod_callback(struct octeon_device *oct_dev,
 	else
 		dev_info(&oct_dev->pci_dev->dev,
 			 "Rx-Adaptive Interrupt moderation enabled:%llx\n",
-			 oct_dev->intrmod.intrmod_enable);
+			 oct_dev->intrmod.rx_enable);
 
 	octeon_free_soft_command(oct_dev, sc);
 }
 
 /*  Configure interrupt moderation parameters */
-static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
+static int octnet_set_intrmod_cfg(struct lio *lio,
+				  struct oct_intrmod_cfg *intr_cfg)
 {
 	struct octeon_soft_command *sc;
 	struct oct_intrmod_cmd *cmd;
 	struct oct_intrmod_cfg *cfg;
 	int retval;
-	struct octeon_device *oct_dev = (struct octeon_device *)oct;
+	struct octeon_device *oct_dev = lio->oct_dev;
 
 	/* Alloc soft command */
 	sc = (struct octeon_soft_command *)
@@ -714,6 +1024,8 @@ static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
 	cmd->cfg = cfg;
 	cmd->oct_dev = oct_dev;
 
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
 	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC,
 				    OPCODE_NIC_INTRMOD_CFG, 0, 0, 0);
 
@@ -722,17 +1034,166 @@ static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
 	sc->wait_time = 1000;
 
 	retval = octeon_send_soft_command(oct_dev, sc);
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
+		octeon_free_soft_command(oct_dev, sc);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+void
+octnet_nic_stats_callback(struct octeon_device *oct_dev,
+			  u32 status, void *ptr)
+{
+	struct octeon_soft_command  *sc = (struct octeon_soft_command  *)ptr;
+	struct oct_nic_stats_resp *resp = (struct oct_nic_stats_resp *)
+		sc->virtrptr;
+	struct oct_nic_stats_ctrl *ctrl = (struct oct_nic_stats_ctrl *)
+		sc->ctxptr;
+	struct nic_rx_stats *rsp_rstats = &resp->stats.fromwire;
+	struct nic_tx_stats *rsp_tstats = &resp->stats.fromhost;
+
+	struct nic_rx_stats *rstats = &oct_dev->link_stats.fromwire;
+	struct nic_tx_stats *tstats = &oct_dev->link_stats.fromhost;
+
+	if ((status != OCTEON_REQUEST_TIMEOUT) && !resp->status) {
+		octeon_swap_8B_data((u64 *)&resp->stats,
+				    (sizeof(struct oct_link_stats)) >> 3);
+
+		/* RX link-level stats */
+		rstats->total_rcvd = rsp_rstats->total_rcvd;
+		rstats->bytes_rcvd = rsp_rstats->bytes_rcvd;
+		rstats->total_bcst = rsp_rstats->total_bcst;
+		rstats->total_mcst = rsp_rstats->total_mcst;
+		rstats->runts      = rsp_rstats->runts;
+		rstats->ctl_rcvd   = rsp_rstats->ctl_rcvd;
+		/* Accounts for over/under-run of buffers */
+		rstats->fifo_err  = rsp_rstats->fifo_err;
+		rstats->dmac_drop = rsp_rstats->dmac_drop;
+		rstats->fcs_err   = rsp_rstats->fcs_err;
+		rstats->jabber_err = rsp_rstats->jabber_err;
+		rstats->l2_err    = rsp_rstats->l2_err;
+		rstats->frame_err = rsp_rstats->frame_err;
+
+		/* RX firmware stats */
+		rstats->fw_total_rcvd = rsp_rstats->fw_total_rcvd;
+		rstats->fw_total_fwd = rsp_rstats->fw_total_fwd;
+		rstats->fw_err_pko = rsp_rstats->fw_err_pko;
+		rstats->fw_err_link = rsp_rstats->fw_err_link;
+		rstats->fw_err_drop = rsp_rstats->fw_err_drop;
+		/* Number of packets that are LROed      */
+		rstats->fw_lro_pkts = rsp_rstats->fw_lro_pkts;
+		/* Number of octets that are LROed       */
+		rstats->fw_lro_octs = rsp_rstats->fw_lro_octs;
+		/* Number of LRO packets formed          */
+		rstats->fw_total_lro = rsp_rstats->fw_total_lro;
+		/* Number of times lRO of packet aborted */
+		rstats->fw_lro_aborts = rsp_rstats->fw_lro_aborts;
+		rstats->fw_lro_aborts_port = rsp_rstats->fw_lro_aborts_port;
+		rstats->fw_lro_aborts_seq = rsp_rstats->fw_lro_aborts_seq;
+		rstats->fw_lro_aborts_tsval = rsp_rstats->fw_lro_aborts_tsval;
+		rstats->fw_lro_aborts_timer = rsp_rstats->fw_lro_aborts_timer;
+		/* intrmod: packet forward rate */
+		rstats->fwd_rate = rsp_rstats->fwd_rate;
+
+		/* TX link-level stats */
+		tstats->total_pkts_sent = rsp_tstats->total_pkts_sent;
+		tstats->total_bytes_sent = rsp_tstats->total_bytes_sent;
+		tstats->mcast_pkts_sent = rsp_tstats->mcast_pkts_sent;
+		tstats->bcast_pkts_sent = rsp_tstats->bcast_pkts_sent;
+		tstats->ctl_sent = rsp_tstats->ctl_sent;
+		/* Packets sent after one collision*/
+		tstats->one_collision_sent = rsp_tstats->one_collision_sent;
+		/* Packets sent after multiple collision*/
+		tstats->multi_collision_sent = rsp_tstats->multi_collision_sent;
+		/* Packets not sent due to max collisions */
+		tstats->max_collision_fail = rsp_tstats->max_collision_fail;
+		/* Packets not sent due to max deferrals */
+		tstats->max_deferral_fail = rsp_tstats->max_deferral_fail;
+		/* Accounts for over/under-run of buffers */
+		tstats->fifo_err = rsp_tstats->fifo_err;
+		tstats->runts = rsp_tstats->runts;
+		/* Total number of collisions detected */
+		tstats->total_collisions = rsp_tstats->total_collisions;
+
+		/* firmware stats */
+		tstats->fw_total_sent = rsp_tstats->fw_total_sent;
+		tstats->fw_total_fwd = rsp_tstats->fw_total_fwd;
+		tstats->fw_err_pko = rsp_tstats->fw_err_pko;
+		tstats->fw_err_link = rsp_tstats->fw_err_link;
+		tstats->fw_err_drop = rsp_tstats->fw_err_drop;
+		tstats->fw_tso = rsp_tstats->fw_tso;
+		tstats->fw_tso_fwd = rsp_tstats->fw_tso_fwd;
+		tstats->fw_err_tso = rsp_tstats->fw_err_tso;
+		resp->status = 1;
+	} else {
+		resp->status = -1;
+	}
+	complete(&ctrl->complete);
+}
+
+/*  Configure interrupt moderation parameters */
+static int octnet_get_link_stats(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+
+	struct octeon_soft_command *sc;
+	struct oct_nic_stats_ctrl *ctrl;
+	struct oct_nic_stats_resp *resp;
+
+	int retval;
+
+	/* Alloc soft command */
+	sc = (struct octeon_soft_command *)
+		octeon_alloc_soft_command(oct_dev,
+					  0,
+					  sizeof(struct oct_nic_stats_resp),
+					  sizeof(struct octnic_ctrl_pkt));
+
+	if (!sc)
+		return -ENOMEM;
+
+	resp = (struct oct_nic_stats_resp *)sc->virtrptr;
+	memset(resp, 0, sizeof(struct oct_nic_stats_resp));
+
+	ctrl = (struct oct_nic_stats_ctrl *)sc->ctxptr;
+	memset(ctrl, 0, sizeof(struct oct_nic_stats_ctrl));
+	ctrl->netdev = netdev;
+	init_completion(&ctrl->complete);
+
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
+	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC,
+				    OPCODE_NIC_PORT_STATS, 0, 0, 0);
+
+	sc->callback = octnet_nic_stats_callback;
+	sc->callback_arg = sc;
+	sc->wait_time = 500;	/*in milli seconds*/
+
+	retval = octeon_send_soft_command(oct_dev, sc);
+	if (retval == IQ_SEND_FAILED) {
 		octeon_free_soft_command(oct_dev, sc);
 		return -EINVAL;
 	}
 
+	wait_for_completion_timeout(&ctrl->complete, msecs_to_jiffies(1000));
+
+	if (resp->status != 1) {
+		octeon_free_soft_command(oct_dev, sc);
+
+		return -EINVAL;
+	}
+
+	octeon_free_soft_command(oct_dev, sc);
+
 	return 0;
 }
 
 /* Enable/Disable auto interrupt Moderation */
 static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
-				 *intr_coal, int adaptive)
+				 *intr_coal)
 {
 	int ret = 0;
 	struct octeon_device *oct = lio->oct_dev;
@@ -740,59 +1201,73 @@ static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
 
 	intrmod_cfg = &oct->intrmod;
 
-	if (adaptive) {
+	if (oct->intrmod.rx_enable || oct->intrmod.tx_enable) {
 		if (intr_coal->rate_sample_interval)
-			intrmod_cfg->intrmod_check_intrvl =
+			intrmod_cfg->check_intrvl =
 				intr_coal->rate_sample_interval;
 		else
-			intrmod_cfg->intrmod_check_intrvl =
+			intrmod_cfg->check_intrvl =
 				LIO_INTRMOD_CHECK_INTERVAL;
 
 		if (intr_coal->pkt_rate_high)
-			intrmod_cfg->intrmod_maxpkt_ratethr =
+			intrmod_cfg->maxpkt_ratethr =
 				intr_coal->pkt_rate_high;
 		else
-			intrmod_cfg->intrmod_maxpkt_ratethr =
+			intrmod_cfg->maxpkt_ratethr =
 				LIO_INTRMOD_MAXPKT_RATETHR;
 
 		if (intr_coal->pkt_rate_low)
-			intrmod_cfg->intrmod_minpkt_ratethr =
+			intrmod_cfg->minpkt_ratethr =
 				intr_coal->pkt_rate_low;
 		else
-			intrmod_cfg->intrmod_minpkt_ratethr =
+			intrmod_cfg->minpkt_ratethr =
 				LIO_INTRMOD_MINPKT_RATETHR;
-
+	}
+	if (oct->intrmod.rx_enable) {
 		if (intr_coal->rx_max_coalesced_frames_high)
-			intrmod_cfg->intrmod_maxcnt_trigger =
+			intrmod_cfg->rx_maxcnt_trigger =
 				intr_coal->rx_max_coalesced_frames_high;
 		else
-			intrmod_cfg->intrmod_maxcnt_trigger =
-				LIO_INTRMOD_MAXCNT_TRIGGER;
+			intrmod_cfg->rx_maxcnt_trigger =
+				LIO_INTRMOD_RXMAXCNT_TRIGGER;
 
 		if (intr_coal->rx_coalesce_usecs_high)
-			intrmod_cfg->intrmod_maxtmr_trigger =
+			intrmod_cfg->rx_maxtmr_trigger =
 				intr_coal->rx_coalesce_usecs_high;
 		else
-			intrmod_cfg->intrmod_maxtmr_trigger =
-				LIO_INTRMOD_MAXTMR_TRIGGER;
+			intrmod_cfg->rx_maxtmr_trigger =
+				LIO_INTRMOD_RXMAXTMR_TRIGGER;
 
 		if (intr_coal->rx_coalesce_usecs_low)
-			intrmod_cfg->intrmod_mintmr_trigger =
+			intrmod_cfg->rx_mintmr_trigger =
 				intr_coal->rx_coalesce_usecs_low;
 		else
-			intrmod_cfg->intrmod_mintmr_trigger =
-				LIO_INTRMOD_MINTMR_TRIGGER;
+			intrmod_cfg->rx_mintmr_trigger =
+				LIO_INTRMOD_RXMINTMR_TRIGGER;
 
 		if (intr_coal->rx_max_coalesced_frames_low)
-			intrmod_cfg->intrmod_mincnt_trigger =
+			intrmod_cfg->rx_mincnt_trigger =
 				intr_coal->rx_max_coalesced_frames_low;
 		else
-			intrmod_cfg->intrmod_mincnt_trigger =
-				LIO_INTRMOD_MINCNT_TRIGGER;
+			intrmod_cfg->rx_mincnt_trigger =
+				LIO_INTRMOD_RXMINCNT_TRIGGER;
+	}
+	if (oct->intrmod.tx_enable) {
+		if (intr_coal->tx_max_coalesced_frames_high)
+			intrmod_cfg->tx_maxcnt_trigger =
+				intr_coal->tx_max_coalesced_frames_high;
+		else
+			intrmod_cfg->tx_maxcnt_trigger =
+				LIO_INTRMOD_TXMAXCNT_TRIGGER;
+		if (intr_coal->tx_max_coalesced_frames_low)
+			intrmod_cfg->tx_mincnt_trigger =
+				intr_coal->tx_max_coalesced_frames_low;
+		else
+			intrmod_cfg->tx_mincnt_trigger =
+				LIO_INTRMOD_TXMINCNT_TRIGGER;
 	}
 
-	intrmod_cfg->intrmod_enable = adaptive;
-	ret = octnet_set_intrmod_cfg(oct, intrmod_cfg);
+	ret = octnet_set_intrmod_cfg(lio, intrmod_cfg);
 
 	return ret;
 }
@@ -800,54 +1275,81 @@ static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
 static int
 oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 {
-	int ret;
 	struct octeon_device *oct = lio->oct_dev;
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	u32 rx_max_coalesced_frames;
 
-	if (!intr_coal->rx_max_coalesced_frames)
-		rx_max_coalesced_frames = CN6XXX_OQ_INTR_PKT;
-	else
-		rx_max_coalesced_frames = intr_coal->rx_max_coalesced_frames;
-
-	/* Disable adaptive interrupt modulation */
-	ret = oct_cfg_adaptive_intr(lio, intr_coal, 0);
-	if (ret)
-		return ret;
-
 	/* Config Cnt based interrupt values */
-	octeon_write_csr(oct, CN6XXX_SLI_OQ_INT_LEVEL_PKTS,
-			 rx_max_coalesced_frames);
-	CFG_SET_OQ_INTR_PKT(cn6xxx->conf, rx_max_coalesced_frames);
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX: {
+		struct octeon_cn6xxx *cn6xxx =
+			(struct octeon_cn6xxx *)oct->chip;
+
+		if (!intr_coal->rx_max_coalesced_frames)
+			rx_max_coalesced_frames = CN6XXX_OQ_INTR_PKT;
+		else
+			rx_max_coalesced_frames =
+				intr_coal->rx_max_coalesced_frames;
+		octeon_write_csr(oct, CN6XXX_SLI_OQ_INT_LEVEL_PKTS,
+				 rx_max_coalesced_frames);
+		CFG_SET_OQ_INTR_PKT(cn6xxx->conf, rx_max_coalesced_frames);
+		break;
+	}
+	default:
+		return -EINVAL;
+	}
 	return 0;
 }
 
 static int oct_cfg_rx_intrtime(struct lio *lio, struct ethtool_coalesce
 			       *intr_coal)
 {
-	int ret;
 	struct octeon_device *oct = lio->oct_dev;
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	u32 time_threshold, rx_coalesce_usecs;
 
-	if (!intr_coal->rx_coalesce_usecs)
-		rx_coalesce_usecs = CN6XXX_OQ_INTR_TIME;
-	else
-		rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
+	/* Config Time based interrupt values */
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX: {
+		struct octeon_cn6xxx *cn6xxx =
+			(struct octeon_cn6xxx *)oct->chip;
+		if (!intr_coal->rx_coalesce_usecs)
+			rx_coalesce_usecs = CN6XXX_OQ_INTR_TIME;
+		else
+			rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
 
-	/* Disable adaptive interrupt modulation */
-	ret = oct_cfg_adaptive_intr(lio, intr_coal, 0);
-	if (ret)
-		return ret;
+		time_threshold = lio_cn6xxx_get_oq_ticks(oct,
+							 rx_coalesce_usecs);
+		octeon_write_csr(oct,
+				 CN6XXX_SLI_OQ_INT_LEVEL_TIME,
+				 time_threshold);
 
-	/* Config Time based interrupt values */
-	time_threshold = lio_cn6xxx_get_oq_ticks(oct, rx_coalesce_usecs);
-	octeon_write_csr(oct, CN6XXX_SLI_OQ_INT_LEVEL_TIME, time_threshold);
-	CFG_SET_OQ_INTR_TIME(cn6xxx->conf, rx_coalesce_usecs);
+		CFG_SET_OQ_INTR_TIME(cn6xxx->conf, rx_coalesce_usecs);
+		break;
+	}
+	default:
+		return -EINVAL;
+	}
 
 	return 0;
 }
 
+static int
+oct_cfg_tx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
+{
+	struct octeon_device *oct = lio->oct_dev;
+
+	/* Config Cnt based interrupt values */
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX:
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static int lio_set_intr_coalesce(struct net_device *netdev,
 				 struct ethtool_coalesce *intr_coal)
 {
@@ -855,59 +1357,48 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 	int ret;
 	struct octeon_device *oct = lio->oct_dev;
 	u32 j, q_no;
+	int db_max, db_min;
 
-	if ((intr_coal->tx_max_coalesced_frames >= CN6XXX_DB_MIN) &&
-	    (intr_coal->tx_max_coalesced_frames <= CN6XXX_DB_MAX)) {
-		for (j = 0; j < lio->linfo.num_txpciq; j++) {
-			q_no = lio->linfo.txpciq[j];
-			oct->instr_queue[q_no]->fill_threshold =
-				intr_coal->tx_max_coalesced_frames;
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX:
+		db_min = CN6XXX_DB_MIN;
+		db_max = CN6XXX_DB_MAX;
+		if ((intr_coal->tx_max_coalesced_frames >= db_min) &&
+		    (intr_coal->tx_max_coalesced_frames <= db_max)) {
+			for (j = 0; j < lio->linfo.num_txpciq; j++) {
+				q_no = lio->linfo.txpciq[j].s.q_no;
+				oct->instr_queue[q_no]->fill_threshold =
+					intr_coal->tx_max_coalesced_frames;
+			}
+		} else {
+			dev_err(&oct->pci_dev->dev,
+				"LIQUIDIO: Invalid tx-frames:%d. Range is min:%d max:%d\n",
+				intr_coal->tx_max_coalesced_frames, db_min,
+				db_max);
+			return -EINVAL;
 		}
-	} else {
-		dev_err(&oct->pci_dev->dev,
-			"LIQUIDIO: Invalid tx-frames:%d. Range is min:%d max:%d\n",
-			intr_coal->tx_max_coalesced_frames, CN6XXX_DB_MIN,
-			CN6XXX_DB_MAX);
+		break;
+	default:
 		return -EINVAL;
 	}
 
-	/* User requested adaptive-rx on */
-	if (intr_coal->use_adaptive_rx_coalesce) {
-		ret = oct_cfg_adaptive_intr(lio, intr_coal, 1);
-		if (ret)
-			goto ret_intrmod;
-	}
+	oct->intrmod.rx_enable = intr_coal->use_adaptive_rx_coalesce ? 1 : 0;
+	oct->intrmod.tx_enable = intr_coal->use_adaptive_tx_coalesce ? 1 : 0;
+
+	ret = oct_cfg_adaptive_intr(lio, intr_coal);
 
-	/* User requested adaptive-rx off and rx coalesce */
-	if ((intr_coal->rx_coalesce_usecs) &&
-	    (!intr_coal->use_adaptive_rx_coalesce)) {
+	if (!intr_coal->use_adaptive_rx_coalesce) {
 		ret = oct_cfg_rx_intrtime(lio, intr_coal);
 		if (ret)
 			goto ret_intrmod;
-	}
 
-	/* User requested adaptive-rx off and rx coalesce */
-	if ((intr_coal->rx_max_coalesced_frames) &&
-	    (!intr_coal->use_adaptive_rx_coalesce)) {
 		ret = oct_cfg_rx_intrcnt(lio, intr_coal);
 		if (ret)
 			goto ret_intrmod;
 	}
-
-	/* User requested adaptive-rx off, so use default coalesce params */
-	if ((!intr_coal->rx_max_coalesced_frames) &&
-	    (!intr_coal->use_adaptive_rx_coalesce) &&
-	    (!intr_coal->rx_coalesce_usecs)) {
-		dev_info(&oct->pci_dev->dev,
-			 "Turning off adaptive-rx interrupt moderation\n");
-		dev_info(&oct->pci_dev->dev,
-			 "Using RX Coalesce Default values rx_coalesce_usecs:%d rx_max_coalesced_frames:%d\n",
-			 CN6XXX_OQ_INTR_TIME, CN6XXX_OQ_INTR_PKT);
-		ret = oct_cfg_rx_intrtime(lio, intr_coal);
-		if (ret)
-			goto ret_intrmod;
-
-		ret = oct_cfg_rx_intrcnt(lio, intr_coal);
+	if (!intr_coal->use_adaptive_tx_coalesce) {
+		ret = oct_cfg_tx_intrcnt(lio, intr_coal);
 		if (ret)
 			goto ret_intrmod;
 	}
@@ -923,23 +1414,28 @@ static int lio_get_ts_info(struct net_device *netdev,
 	struct lio *lio = GET_LIO(netdev);
 
 	info->so_timestamping =
+#ifdef PTP_HARDWARE_TIMESTAMPING
 		SOF_TIMESTAMPING_TX_HARDWARE |
-		SOF_TIMESTAMPING_TX_SOFTWARE |
 		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE |
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+#endif
 		SOF_TIMESTAMPING_RX_SOFTWARE |
-		SOF_TIMESTAMPING_SOFTWARE | SOF_TIMESTAMPING_RAW_HARDWARE;
+		SOF_TIMESTAMPING_SOFTWARE;
 
 	if (lio->ptp_clock)
 		info->phc_index = ptp_clock_index(lio->ptp_clock);
 	else
 		info->phc_index = -1;
 
+#ifdef PTP_HARDWARE_TIMESTAMPING
 	info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
 
 	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
 			   (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
 			   (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
 			   (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
+#endif
 
 	return 0;
 }
@@ -950,7 +1446,6 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	struct octeon_device *oct = lio->oct_dev;
 	struct oct_link_info *linfo;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	int ret = 0;
 
 	/* get the link info */
@@ -965,12 +1460,14 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 						  ecmd->duplex != DUPLEX_FULL)))
 		return -EINVAL;
 
-	/* Ethtool Support is not provided for XAUI and RXAUI Interfaces
+	/* Ethtool Support is not provided for XAUI, RXAUI, and XFI Interfaces
 	 * as they operate at fixed Speed and Duplex settings
 	 */
-	if (linfo->link.s.interface == INTERFACE_MODE_XAUI ||
-	    linfo->link.s.interface == INTERFACE_MODE_RXAUI) {
-		dev_info(&oct->pci_dev->dev, "XAUI IFs settings cannot be modified.\n");
+	if (linfo->link.s.if_mode == INTERFACE_MODE_XAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_RXAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_XFI) {
+		dev_info(&oct->pci_dev->dev,
+			 "Autonegotiation, duplex and speed settings cannot be modified.\n");
 		return -EINVAL;
 	}
 
@@ -978,9 +1475,9 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_SETTINGS;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 1000;
 	nctrl.netpndev = (u64)netdev;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
 	/* Passing the parameters sent by ethtool like Speed, Autoneg & Duplex
@@ -990,19 +1487,17 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		/* Autoneg ON */
 		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON |
 				     OCTNIC_NCMD_AUTONEG_ON;
-		nctrl.ncmd.s.param2 = ecmd->advertising;
+		nctrl.ncmd.s.param1 = ecmd->advertising;
 	} else {
 		/* Autoneg OFF */
 		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON;
 
-		nctrl.ncmd.s.param3 = ecmd->duplex;
+		nctrl.ncmd.s.param2 = ecmd->duplex;
 
-		nctrl.ncmd.s.param2 = ecmd->speed;
+		nctrl.ncmd.s.param1 = ecmd->speed;
 	}
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Failed to set settings\n");
 		return -1;
@@ -1170,13 +1665,12 @@ static void lio_get_regs(struct net_device *dev,
 	int len = 0;
 	struct octeon_device *oct = lio->oct_dev;
 
-	memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN);
 	regs->version = OCT_ETHTOOL_REGSVER;
 
 	switch (oct->chip_id) {
-	/* case OCTEON_CN73XX: Todo */
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX:
+		memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN);
 		len += cn6xxx_read_csr_reg(regbuf + len, oct);
 		len += cn6xxx_read_config_reg(regbuf + len, oct);
 		break;
@@ -1186,6 +1680,23 @@ static void lio_get_regs(struct net_device *dev,
 	}
 }
 
+static u32 lio_get_priv_flags(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	return lio->oct_dev->priv_flags;
+}
+
+static int lio_set_priv_flags(struct net_device *netdev, u32 flags)
+{
+	struct lio *lio = GET_LIO(netdev);
+	bool intr_by_tx_bytes = !!(flags & (0x1 << OCT_PRIV_FLAG_TX_BYTES));
+
+	lio_set_priv_flag(lio->oct_dev, OCT_PRIV_FLAG_TX_BYTES,
+			  intr_by_tx_bytes);
+	return 0;
+}
+
 static const struct ethtool_ops lio_ethtool_ops = {
 	.get_settings		= lio_get_settings,
 	.get_link		= ethtool_op_get_link,
@@ -1207,6 +1718,8 @@ static const struct ethtool_ops lio_ethtool_ops = {
 	.set_settings		= lio_set_settings,
 	.get_coalesce		= lio_get_intr_coalesce,
 	.set_coalesce		= lio_set_intr_coalesce,
+	.get_priv_flags		= lio_get_priv_flags,
+	.set_priv_flags		= lio_set_priv_flags,
 	.get_ts_info		= lio_get_ts_info,
 };
 
-- 
1.8.3.1
