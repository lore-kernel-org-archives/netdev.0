From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 3/5] liquidio VF ethtool stats
Date: Thu, 8 Dec 2016 13:00:46 -0800
Message-ID: <1481230848-2393-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0072.outbound.protection.outlook.com ([104.47.42.72]:2178
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753501AbcLHVBU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:01:20 -0500
In-Reply-To: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF ethtool stats

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 512 +++++++++++++++++----
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |  79 ++++
 3 files changed, 495 insertions(+), 98 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
index 6715df3..3f98c73 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -44,5 +44,7 @@ struct octeon_cn23xx_vf {
 
 int cn23xx_setup_octeon_vf_device(struct octeon_device *oct);
 
+u32 cn23xx_vf_get_oq_ticks(struct octeon_device *oct, u32 time_intr_in_us);
+
 void cn23xx_dump_vf_initialized_regs(struct octeon_device *oct);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index e233796..b00c300 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -29,6 +29,7 @@
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
 #include "cn23xx_pf_device.h"
+#include "cn23xx_vf_device.h"
 
 static int octnet_get_link_stats(struct net_device *netdev);
 
@@ -72,6 +73,7 @@ enum {
 
 #define OCT_ETHTOOL_REGDUMP_LEN  4096
 #define OCT_ETHTOOL_REGDUMP_LEN_23XX  (4096 * 11)
+#define OCT_ETHTOOL_REGDUMP_LEN_23XX_VF  (4096 * 2)
 #define OCT_ETHTOOL_REGSVER  1
 
 /* statistics of PF */
@@ -147,6 +149,19 @@ enum {
 	"link_state_changes",
 };
 
+/* statistics of VF */
+static const char oct_vf_stats_strings[][ETH_GSTRING_LEN] = {
+	"rx_packets",
+	"tx_packets",
+	"rx_bytes",
+	"tx_bytes",
+	"rx_errors", /* jabber_err + l2_err+frame_err */
+	"tx_errors", /* fw_err_pko + fw_err_link+fw_err_drop */
+	"rx_dropped", /* total_rcvd - fw_total_rcvd + dmac_drop + fw_err_drop */
+	"tx_dropped",
+	"link_state_changes",
+};
+
 /* statistics of host tx queue */
 static const char oct_iq_stats_strings[][ETH_GSTRING_LEN] = {
 	"packets",		/*oct->instr_queue[iq_no]->stats.tx_done*/
@@ -192,25 +207,28 @@ enum {
 #define OCTNIC_NCMD_AUTONEG_ON  0x1
 #define OCTNIC_NCMD_PHY_ON      0x2
 
-static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int lio_get_link_ksettings(struct net_device *netdev,
+				  struct ethtool_link_ksettings *ecmd)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct oct_link_info *linfo;
+	u32 supported, advertising;
 
 	linfo = &lio->linfo;
 
 	if (linfo->link.s.if_mode == INTERFACE_MODE_XAUI ||
 	    linfo->link.s.if_mode == INTERFACE_MODE_RXAUI ||
 	    linfo->link.s.if_mode == INTERFACE_MODE_XFI) {
-		ecmd->port = PORT_FIBRE;
-		ecmd->supported =
-			(SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE |
-			 SUPPORTED_Pause);
-		ecmd->advertising =
-			(ADVERTISED_10000baseT_Full | ADVERTISED_Pause);
-		ecmd->transceiver = XCVR_EXTERNAL;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		ecmd->base.port = PORT_FIBRE;
+		supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE |
+			     SUPPORTED_Pause);
+		advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_Pause);
+		ethtool_convert_legacy_u32_to_link_mode(
+			ecmd->link_modes.supported, supported);
+		ethtool_convert_legacy_u32_to_link_mode(
+			ecmd->link_modes.advertising, advertising);
+		ecmd->base.autoneg = AUTONEG_DISABLE;
 
 	} else {
 		dev_err(&oct->pci_dev->dev, "Unknown link interface reported %d\n",
@@ -218,11 +236,11 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	}
 
 	if (linfo->link.s.link_up) {
-		ethtool_cmd_speed_set(ecmd, linfo->link.s.speed);
-		ecmd->duplex = linfo->link.s.duplex;
+		ecmd->base.speed = linfo->link.s.speed;
+		ecmd->base.duplex = linfo->link.s.duplex;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		ecmd->base.speed = SPEED_UNKNOWN;
+		ecmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
 	return 0;
@@ -246,6 +264,23 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 }
 
 static void
+lio_get_vf_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	struct octeon_device *oct;
+	struct lio *lio;
+
+	lio = GET_LIO(netdev);
+	oct = lio->oct_dev;
+
+	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
+	strcpy(drvinfo->driver, "liquidio_vf");
+	strcpy(drvinfo->version, LIQUIDIO_VERSION);
+	strncpy(drvinfo->fw_version, oct->fw_info.liquidio_firmware_version,
+		ETHTOOL_FWVERS_LEN);
+	strncpy(drvinfo->bus_info, pci_name(oct->pci_dev), 32);
+}
+
+static void
 lio_ethtool_get_channels(struct net_device *dev,
 			 struct ethtool_channels *channel)
 {
@@ -982,6 +1017,109 @@ static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
 	}
 }
 
+static void lio_vf_get_ethtool_stats(struct net_device *netdev,
+				     struct ethtool_stats *stats
+				     __attribute__((unused)),
+				     u64 *data)
+{
+	struct net_device_stats *netstats = &netdev->stats;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+	int i = 0, j, vj;
+
+	netdev->netdev_ops->ndo_get_stats(netdev);
+	/* sum of oct->droq[oq_no]->stats->rx_pkts_received */
+	data[i++] = CVM_CAST64(netstats->rx_packets);
+	/* sum of oct->instr_queue[iq_no]->stats.tx_done */
+	data[i++] = CVM_CAST64(netstats->tx_packets);
+	/* sum of oct->droq[oq_no]->stats->rx_bytes_received */
+	data[i++] = CVM_CAST64(netstats->rx_bytes);
+	/* sum of oct->instr_queue[iq_no]->stats.tx_tot_bytes */
+	data[i++] = CVM_CAST64(netstats->tx_bytes);
+	data[i++] = CVM_CAST64(netstats->rx_errors);
+	data[i++] = CVM_CAST64(netstats->tx_errors);
+	 /* sum of oct->droq[oq_no]->stats->rx_dropped +
+	  * oct->droq[oq_no]->stats->dropped_nodispatch +
+	  * oct->droq[oq_no]->stats->dropped_toomany +
+	  * oct->droq[oq_no]->stats->dropped_nomem
+	  */
+	data[i++] = CVM_CAST64(netstats->rx_dropped);
+	/* sum of oct->instr_queue[iq_no]->stats.tx_dropped */
+	data[i++] = CVM_CAST64(netstats->tx_dropped);
+	/* lio->link_changes */
+	data[i++] = CVM_CAST64(lio->link_changes);
+
+	for (vj = 0; vj < lio->linfo.num_txpciq; vj++) {
+		j = lio->linfo.txpciq[vj].s.q_no;
+
+		/* packets to network port */
+		/* # of packets tx to network */
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_done);
+		 /* # of bytes tx to network */
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.tx_tot_bytes);
+		/* # of packets dropped */
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.tx_dropped);
+		/* # of tx fails due to queue full */
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.tx_iq_busy);
+		/* XXX gather entries sent */
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.sgentry_sent);
+
+		/* instruction to firmware: data and control */
+		/* # of instructions to the queue */
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.instr_posted);
+		/* # of instructions processed */
+		data[i++] =
+		    CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_processed);
+		/* # of instructions could not be processed */
+		data[i++] =
+		    CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_dropped);
+		/* bytes sent through the queue */
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.bytes_sent);
+		/* tso request */
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_gso);
+		/* vxlan request */
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_vxlan);
+		/* txq restart */
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.tx_restart);
+	}
+
+	/* RX */
+	for (vj = 0; vj < lio->linfo.num_rxpciq; vj++) {
+		j = lio->linfo.rxpciq[vj].s.q_no;
+
+		/* packets send to TCP/IP network stack */
+		/* # of packets to network stack */
+		data[i++] = CVM_CAST64(
+				oct_dev->droq[j]->stats.rx_pkts_received);
+		/* # of bytes to network stack */
+		data[i++] = CVM_CAST64(
+				oct_dev->droq[j]->stats.rx_bytes_received);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem +
+				       oct_dev->droq[j]->stats.dropped_toomany +
+				       oct_dev->droq[j]->stats.rx_dropped);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_nomem);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.dropped_toomany);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.rx_dropped);
+
+		/* control and data path */
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.pkts_received);
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nodispatch);
+
+		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.rx_vxlan);
+		data[i++] =
+		    CVM_CAST64(oct_dev->droq[j]->stats.rx_alloc_failure);
+	}
+}
+
 static void lio_get_priv_flags_strings(struct lio *lio, u8 *data)
 {
 	struct octeon_device *oct_dev = lio->oct_dev;
@@ -989,6 +1127,7 @@ static void lio_get_priv_flags_strings(struct lio *lio, u8 *data)
 
 	switch (oct_dev->chip_id) {
 	case OCTEON_CN23XX_PF_VID:
+	case OCTEON_CN23XX_VF_VID:
 		for (i = 0; i < ARRAY_SIZE(oct_priv_flags_strings); i++) {
 			sprintf(data, "%s", oct_priv_flags_strings[i]);
 			data += ETH_GSTRING_LEN;
@@ -1050,12 +1189,61 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
+static void lio_vf_get_strings(struct net_device *netdev, u32 stringset,
+			       u8 *data)
+{
+	int num_iq_stats, num_oq_stats, i, j;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+	int num_stats;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		num_stats = ARRAY_SIZE(oct_vf_stats_strings);
+		for (j = 0; j < num_stats; j++) {
+			sprintf(data, "%s", oct_vf_stats_strings[j]);
+			data += ETH_GSTRING_LEN;
+		}
+
+		num_iq_stats = ARRAY_SIZE(oct_iq_stats_strings);
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct_dev); i++) {
+			if (!(oct_dev->io_qmask.iq & BIT_ULL(i)))
+				continue;
+			for (j = 0; j < num_iq_stats; j++) {
+				sprintf(data, "tx-%d-%s", i,
+					oct_iq_stats_strings[j]);
+				data += ETH_GSTRING_LEN;
+			}
+		}
+
+		num_oq_stats = ARRAY_SIZE(oct_droq_stats_strings);
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct_dev); i++) {
+			if (!(oct_dev->io_qmask.oq & BIT_ULL(i)))
+				continue;
+			for (j = 0; j < num_oq_stats; j++) {
+				sprintf(data, "rx-%d-%s", i,
+					oct_droq_stats_strings[j]);
+				data += ETH_GSTRING_LEN;
+			}
+		}
+		break;
+
+	case ETH_SS_PRIV_FLAGS:
+		lio_get_priv_flags_strings(lio, data);
+		break;
+	default:
+		netif_info(lio, drv, lio->netdev, "Unknown Stringset !!\n");
+		break;
+	}
+}
+
 static int lio_get_priv_flags_ss_count(struct lio *lio)
 {
 	struct octeon_device *oct_dev = lio->oct_dev;
 
 	switch (oct_dev->chip_id) {
 	case OCTEON_CN23XX_PF_VID:
+	case OCTEON_CN23XX_VF_VID:
 		return ARRAY_SIZE(oct_priv_flags_strings);
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX:
@@ -1083,6 +1271,23 @@ static int lio_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
+static int lio_vf_get_sset_count(struct net_device *netdev, int sset)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct_dev = lio->oct_dev;
+
+	switch (sset) {
+	case ETH_SS_STATS:
+		return (ARRAY_SIZE(oct_vf_stats_strings) +
+			ARRAY_SIZE(oct_iq_stats_strings) * oct_dev->num_iqs +
+			ARRAY_SIZE(oct_droq_stats_strings) * oct_dev->num_oqs);
+	case ETH_SS_PRIV_FLAGS:
+		return lio_get_priv_flags_ss_count(lio);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int lio_get_intr_coalesce(struct net_device *netdev,
 				 struct ethtool_coalesce *intr_coal)
 {
@@ -1095,6 +1300,7 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 
 	switch (oct->chip_id) {
 	case OCTEON_CN23XX_PF_VID:
+	case OCTEON_CN23XX_VF_VID:
 		if (!intrmod_cfg->rx_enable) {
 			intr_coal->rx_coalesce_usecs = intrmod_cfg->rx_usecs;
 			intr_coal->rx_max_coalesced_frames =
@@ -1141,7 +1347,7 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 		intr_coal->rx_max_coalesced_frames_low =
 		    intrmod_cfg->rx_mincnt_trigger;
 	}
-	if (OCTEON_CN23XX_PF(oct) &&
+	if ((OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct)) &&
 	    (intrmod_cfg->tx_enable)) {
 		intr_coal->use_adaptive_tx_coalesce = intrmod_cfg->tx_enable;
 		intr_coal->tx_max_coalesced_frames_high =
@@ -1499,6 +1705,26 @@ static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
 		oct->intrmod.rx_frames = rx_max_coalesced_frames;
 		break;
 	}
+	case OCTEON_CN23XX_VF_VID: {
+		int q_no;
+
+		if (!intr_coal->rx_max_coalesced_frames)
+			rx_max_coalesced_frames = oct->intrmod.rx_frames;
+		else
+			rx_max_coalesced_frames =
+			    intr_coal->rx_max_coalesced_frames;
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			octeon_write_csr64(
+			    oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no),
+			    (octeon_read_csr64(
+				 oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no)) &
+			     (0x3fffff00000000UL)) |
+				rx_max_coalesced_frames);
+			/* consider writing to resend bit here */
+		}
+		oct->intrmod.rx_frames = rx_max_coalesced_frames;
+		break;
+	}
 	default:
 		return -EINVAL;
 	}
@@ -1552,6 +1778,27 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 		oct->intrmod.rx_usecs = rx_coalesce_usecs;
 		break;
 	}
+	case OCTEON_CN23XX_VF_VID: {
+		u64 time_threshold;
+		int q_no;
+
+		if (!intr_coal->rx_coalesce_usecs)
+			rx_coalesce_usecs = oct->intrmod.rx_usecs;
+		else
+			rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
+
+		time_threshold =
+		    cn23xx_vf_get_oq_ticks(oct, (u32)rx_coalesce_usecs);
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			octeon_write_csr64(
+				oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no),
+				(oct->intrmod.rx_frames |
+				 (time_threshold << 32)));
+			/* consider setting resend bit */
+		}
+		oct->intrmod.rx_usecs = rx_coalesce_usecs;
+		break;
+	}
 	default:
 		return -EINVAL;
 	}
@@ -1573,6 +1820,7 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX:
 		break;
+	case OCTEON_CN23XX_VF_VID:
 	case OCTEON_CN23XX_PF_VID: {
 		int q_no;
 
@@ -1631,6 +1879,7 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 		}
 		break;
 	case OCTEON_CN23XX_PF_VID:
+	case OCTEON_CN23XX_VF_VID:
 		break;
 	default:
 		return -EINVAL;
@@ -1693,86 +1942,6 @@ static int lio_get_ts_info(struct net_device *netdev,
 	return 0;
 }
 
-static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
-{
-	struct lio *lio = GET_LIO(netdev);
-	struct octeon_device *oct = lio->oct_dev;
-	struct oct_link_info *linfo;
-	struct octnic_ctrl_pkt nctrl;
-	int ret = 0;
-
-	/* get the link info */
-	linfo = &lio->linfo;
-
-	if (ecmd->autoneg != AUTONEG_ENABLE && ecmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
-
-	if (ecmd->autoneg == AUTONEG_DISABLE && ((ecmd->speed != SPEED_100 &&
-						  ecmd->speed != SPEED_10) ||
-						 (ecmd->duplex != DUPLEX_HALF &&
-						  ecmd->duplex != DUPLEX_FULL)))
-		return -EINVAL;
-
-	/* Ethtool Support is not provided for XAUI, RXAUI, and XFI Interfaces
-	 * as they operate at fixed Speed and Duplex settings
-	 */
-	if (linfo->link.s.if_mode == INTERFACE_MODE_XAUI ||
-	    linfo->link.s.if_mode == INTERFACE_MODE_RXAUI ||
-	    linfo->link.s.if_mode == INTERFACE_MODE_XFI) {
-		dev_info(&oct->pci_dev->dev,
-			 "Autonegotiation, duplex and speed settings cannot be modified.\n");
-		return -EINVAL;
-	}
-
-	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
-
-	nctrl.ncmd.u64 = 0;
-	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_SETTINGS;
-	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
-	nctrl.wait_time = 1000;
-	nctrl.netpndev = (u64)netdev;
-	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
-
-	/* Passing the parameters sent by ethtool like Speed, Autoneg & Duplex
-	 * to SE core application using ncmd.s.more & ncmd.s.param
-	 */
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		/* Autoneg ON */
-		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON |
-				     OCTNIC_NCMD_AUTONEG_ON;
-		nctrl.ncmd.s.param1 = ecmd->advertising;
-	} else {
-		/* Autoneg OFF */
-		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON;
-
-		nctrl.ncmd.s.param2 = ecmd->duplex;
-
-		nctrl.ncmd.s.param1 = ecmd->speed;
-	}
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
-	if (ret < 0) {
-		dev_err(&oct->pci_dev->dev, "Failed to set settings\n");
-		return -1;
-	}
-
-	return 0;
-}
-
-static int lio_nway_reset(struct net_device *netdev)
-{
-	if (netif_running(netdev)) {
-		struct ethtool_cmd ecmd;
-
-		memset(&ecmd, 0, sizeof(struct ethtool_cmd));
-		ecmd.autoneg = 0;
-		ecmd.speed = 0;
-		ecmd.duplex = 0;
-		lio_set_settings(netdev, &ecmd);
-	}
-	return 0;
-}
-
 /* Return register dump len. */
 static int lio_get_regs_len(struct net_device *dev)
 {
@@ -1782,6 +1951,8 @@ static int lio_get_regs_len(struct net_device *dev)
 	switch (oct->chip_id) {
 	case OCTEON_CN23XX_PF_VID:
 		return OCT_ETHTOOL_REGDUMP_LEN_23XX;
+	case OCTEON_CN23XX_VF_VID:
+		return OCT_ETHTOOL_REGDUMP_LEN_23XX_VF;
 	default:
 		return OCT_ETHTOOL_REGDUMP_LEN;
 	}
@@ -2007,6 +2178,123 @@ static int cn23xx_read_csr_reg(char *s, struct octeon_device *oct)
 	return len;
 }
 
+static int cn23xx_vf_read_csr_reg(char *s, struct octeon_device *oct)
+{
+	int len = 0;
+	u32 reg;
+	int i;
+
+	/* PCI  Window Registers */
+
+	len += sprintf(s + len, "\n\t Octeon CSR Registers\n\n");
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_OQ_BUFF_INFO_SIZE(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_OUT_SIZE): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_IQ_INSTR_COUNT64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT_IN_DONE%d_CNTS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_OQ_PKTS_CREDIT(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_SLIST_BAOFF_DBELL): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_OQ_SIZE(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_SLIST_FIFO_RSIZE): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_OQ_PKT_CONTROL(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d__OUTPUT_CONTROL): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_OQ_BASE_ADDR64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_SLIST_BADDR): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_INT_LEVELS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_OQ_PKTS_SENT(i);
+		len += sprintf(s + len, "\n[%08x] (SLI_PKT%d_CNTS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = 0x100c0 + i * CN23XX_VF_OQ_OFFSET;
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_ERROR_INFO): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = 0x100d0 + i * CN23XX_VF_IQ_OFFSET;
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_VF_INT_SUM): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_IQ_PKT_CONTROL64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_INPUT_CONTROL): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_IQ_BASE_ADDR64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_INSTR_BADDR): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_IQ_DOORBELL(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_INSTR_BAOFF_DBELL): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_IQ_SIZE(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_INSTR_FIFO_RSIZE): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < (oct->sriov_info.rings_per_vf); i++) {
+		reg = CN23XX_VF_SLI_IQ_INSTR_COUNT64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT_IN_DONE%d_CNTS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	return len;
+}
+
 static int cn6xxx_read_csr_reg(char *s, struct octeon_device *oct)
 {
 	u32 reg;
@@ -2153,6 +2441,10 @@ static void lio_get_regs(struct net_device *dev,
 		memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN_23XX);
 		len += cn23xx_read_csr_reg(regbuf + len, oct);
 		break;
+	case OCTEON_CN23XX_VF_VID:
+		memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN_23XX_VF);
+		len += cn23xx_vf_read_csr_reg(regbuf + len, oct);
+		break;
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX:
 		memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN);
@@ -2183,7 +2475,7 @@ static int lio_set_priv_flags(struct net_device *netdev, u32 flags)
 }
 
 static const struct ethtool_ops lio_ethtool_ops = {
-	.get_settings		= lio_get_settings,
+	.get_link_ksettings	= lio_get_link_ksettings,
 	.get_link		= ethtool_op_get_link,
 	.get_drvinfo		= lio_get_drvinfo,
 	.get_ringparam		= lio_ethtool_get_ringparam,
@@ -2200,8 +2492,26 @@ static int lio_set_priv_flags(struct net_device *netdev, u32 flags)
 	.get_msglevel		= lio_get_msglevel,
 	.set_msglevel		= lio_set_msglevel,
 	.get_sset_count		= lio_get_sset_count,
-	.nway_reset		= lio_nway_reset,
-	.set_settings		= lio_set_settings,
+	.get_coalesce		= lio_get_intr_coalesce,
+	.set_coalesce		= lio_set_intr_coalesce,
+	.get_priv_flags		= lio_get_priv_flags,
+	.set_priv_flags		= lio_set_priv_flags,
+	.get_ts_info		= lio_get_ts_info,
+};
+
+static const struct ethtool_ops lio_vf_ethtool_ops = {
+	.get_link_ksettings	= lio_get_link_ksettings,
+	.get_link		= ethtool_op_get_link,
+	.get_drvinfo		= lio_get_vf_drvinfo,
+	.get_ringparam		= lio_ethtool_get_ringparam,
+	.get_channels		= lio_ethtool_get_channels,
+	.get_strings		= lio_vf_get_strings,
+	.get_ethtool_stats	= lio_vf_get_ethtool_stats,
+	.get_regs_len		= lio_get_regs_len,
+	.get_regs		= lio_get_regs,
+	.get_msglevel		= lio_get_msglevel,
+	.set_msglevel		= lio_set_msglevel,
+	.get_sset_count		= lio_vf_get_sset_count,
 	.get_coalesce		= lio_get_intr_coalesce,
 	.set_coalesce		= lio_set_intr_coalesce,
 	.get_priv_flags		= lio_get_priv_flags,
@@ -2211,5 +2521,11 @@ static int lio_set_priv_flags(struct net_device *netdev, u32 flags)
 
 void liquidio_set_ethtool_ops(struct net_device *netdev)
 {
-	netdev->ethtool_ops = &lio_ethtool_ops;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	if (OCTEON_CN23XX_VF(oct))
+		netdev->ethtool_ops = &lio_vf_ethtool_ops;
+	else
+		netdev->ethtool_ops = &lio_ethtool_ops;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 5d1023b..97e9b6b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1824,6 +1824,56 @@ static int liquidio_set_mac(struct net_device *netdev, void *p)
 }
 
 /**
+ * \brief Net device get_stats
+ * @param netdev network device
+ */
+static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct net_device_stats *stats = &netdev->stats;
+	u64 pkts = 0, drop = 0, bytes = 0;
+	struct oct_droq_stats *oq_stats;
+	struct oct_iq_stats *iq_stats;
+	struct octeon_device *oct;
+	int i, iq_no, oq_no;
+
+	oct = lio->oct_dev;
+
+	for (i = 0; i < lio->linfo.num_txpciq; i++) {
+		iq_no = lio->linfo.txpciq[i].s.q_no;
+		iq_stats = &oct->instr_queue[iq_no]->stats;
+		pkts += iq_stats->tx_done;
+		drop += iq_stats->tx_dropped;
+		bytes += iq_stats->tx_tot_bytes;
+	}
+
+	stats->tx_packets = pkts;
+	stats->tx_bytes = bytes;
+	stats->tx_dropped = drop;
+
+	pkts = 0;
+	drop = 0;
+	bytes = 0;
+
+	for (i = 0; i < lio->linfo.num_rxpciq; i++) {
+		oq_no = lio->linfo.rxpciq[i].s.q_no;
+		oq_stats = &oct->droq[oq_no]->stats;
+		pkts += oq_stats->rx_pkts_received;
+		drop += (oq_stats->rx_dropped +
+			 oq_stats->dropped_nodispatch +
+			 oq_stats->dropped_toomany +
+			 oq_stats->dropped_nomem);
+		bytes += oq_stats->rx_bytes_received;
+	}
+
+	stats->rx_bytes = bytes;
+	stats->rx_packets = pkts;
+	stats->rx_dropped = drop;
+
+	return stats;
+}
+
+/**
  * \brief Net device change_mtu
  * @param netdev network device
  */
@@ -2325,6 +2375,7 @@ static void liquidio_del_vxlan_port(struct net_device *netdev,
 	.ndo_open		= liquidio_open,
 	.ndo_stop		= liquidio_stop,
 	.ndo_start_xmit		= liquidio_xmit,
+	.ndo_get_stats		= liquidio_get_stats,
 	.ndo_set_mac_address	= liquidio_set_mac,
 	.ndo_set_rx_mode	= liquidio_set_mcast_list,
 	.ndo_tx_timeout		= liquidio_tx_timeout,
@@ -2614,6 +2665,13 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			goto setup_nic_dev_fail;
 		}
 
+		/* Register ethtool support */
+		liquidio_set_ethtool_ops(netdev);
+		if (lio->oct_dev->chip_id == OCTEON_CN23XX_VF_VID)
+			octeon_dev->priv_flags = OCT_PRIV_FLAG_DEFAULT;
+		else
+			octeon_dev->priv_flags = 0x0;
+
 		if (netdev->features & NETIF_F_LRO)
 			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
 					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
@@ -2679,6 +2737,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
  */
 static int liquidio_init_nic_module(struct octeon_device *oct)
 {
+	struct oct_intrmod_cfg *intrmod_cfg;
 	int num_nic_ports = 1;
 	int i, retval = 0;
 
@@ -2700,6 +2759,26 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 		goto octnet_init_failure;
 	}
 
+	/* Initialize interrupt moderation params */
+	intrmod_cfg = &((struct octeon_device *)oct)->intrmod;
+	intrmod_cfg->rx_enable = 1;
+	intrmod_cfg->check_intrvl = LIO_INTRMOD_CHECK_INTERVAL;
+	intrmod_cfg->maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
+	intrmod_cfg->minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
+	intrmod_cfg->rx_maxcnt_trigger = LIO_INTRMOD_RXMAXCNT_TRIGGER;
+	intrmod_cfg->rx_maxtmr_trigger = LIO_INTRMOD_RXMAXTMR_TRIGGER;
+	intrmod_cfg->rx_mintmr_trigger = LIO_INTRMOD_RXMINTMR_TRIGGER;
+	intrmod_cfg->rx_mincnt_trigger = LIO_INTRMOD_RXMINCNT_TRIGGER;
+	intrmod_cfg->tx_enable = 1;
+	intrmod_cfg->tx_maxcnt_trigger = LIO_INTRMOD_TXMAXCNT_TRIGGER;
+	intrmod_cfg->tx_mincnt_trigger = LIO_INTRMOD_TXMINCNT_TRIGGER;
+	intrmod_cfg->rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
+	intrmod_cfg->rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
+	intrmod_cfg->tx_frames = CFG_GET_IQ_INTR_PKT(octeon_get_conf(oct));
+	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
+
+	return retval;
+
 octnet_init_failure:
 
 	oct->ifcount = 0;
-- 
1.8.3.1
