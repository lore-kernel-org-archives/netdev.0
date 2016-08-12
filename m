From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 15/18] liquidio: ethtool and led control support
Date: Fri, 12 Aug 2016 11:20:32 -0700
Message-ID: <1471026035-15323-16-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-sn1nam02on0088.outbound.protection.outlook.com ([104.47.36.88]:33472
	"EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752398AbcHLSVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 14:21:50 -0400
In-Reply-To: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for LED identification and ethtool
based statistics for cn23xx device.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |   6 +
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 385 ++++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   5 +
 4 files changed, 390 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index 33b7589..21b5c90 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -51,6 +51,8 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct);
 int validate_cn23xx_pf_config_info(struct octeon_device *oct,
 				   struct octeon_config *conf23xx);
 
+u32 cn23xx_pf_get_oq_ticks(struct octeon_device *oct, u32 time_intr_in_us);
+
 void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct);
 
 int cn23xx_fw_loaded(struct octeon_device *oct);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index ad1db3f..2551645 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -163,6 +163,12 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 
 	case OCTNET_CMD_GPIO_ACCESS:
 		netif_info(lio, probe, lio->netdev, "LED Flashing visual identification\n");
+
+		break;
+
+	case OCTNET_CMD_ID_ACTIVE:
+		netif_info(lio, probe, lio->netdev, "LED Flashing visual identification\n");
+
 		break;
 
 	case OCTNET_CMD_LRO_ENABLE:
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 16a92b9..1e7d683 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -32,6 +32,7 @@
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
+#include "cn23xx_pf_device.h"
 
 static int octnet_get_link_stats(struct net_device *netdev);
 
@@ -75,6 +76,7 @@ enum {
 
 #define ARRAY_LENGTH(a) (sizeof(a) / sizeof((a)[0]))
 #define OCT_ETHTOOL_REGDUMP_LEN  4096
+#define OCT_ETHTOOL_REGDUMP_LEN_23XX  (4096 * 11)
 #define OCT_ETHTOOL_REGSVER  1
 
 /* statistics of PF */
@@ -259,6 +261,13 @@ lio_ethtool_get_channels(struct net_device *dev,
 		max_tx = CFG_GET_IQ_MAX_Q(conf6x);
 		rx_count = CFG_GET_NUM_RXQS_NIC_IF(conf6x, lio->ifidx);
 		tx_count = CFG_GET_NUM_TXQS_NIC_IF(conf6x, lio->ifidx);
+	} else if (OCTEON_CN23XX_PF(oct)) {
+		struct octeon_config *conf23 = CHIP_FIELD(oct, cn23xx_pf, conf);
+
+		max_rx = CFG_GET_OQ_MAX_Q(conf23);
+		max_tx = CFG_GET_IQ_MAX_Q(conf23);
+		rx_count = CFG_GET_NUM_RXQS_NIC_IF(conf23, lio->ifidx);
+		tx_count = CFG_GET_NUM_TXQS_NIC_IF(conf23, lio->ifidx);
 	}
 
 	channel->max_rx = max_rx;
@@ -332,6 +341,32 @@ static int octnet_gpio_access(struct net_device *netdev, int addr, int val)
 	return 0;
 }
 
+static int octnet_id_active(struct net_device *netdev, int val)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_ID_ACTIVE;
+	nctrl.ncmd.s.param1 = val;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Failed to configure gpio value\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 /* Callback for when mdio command response arrives
  */
 static void octnet_mdio_resp_callback(struct octeon_device *oct,
@@ -475,6 +510,11 @@ static int lio_set_phys_id(struct net_device *netdev,
 						   &value);
 			if (ret)
 				return ret;
+		} else if (oct->chip_id == OCTEON_CN23XX_PF_VID) {
+			octnet_id_active(netdev, LED_IDENTIFICATION_ON);
+
+			/* returns 0 since updates are asynchronous */
+			return 0;
 		} else {
 			return -EINVAL;
 		}
@@ -520,7 +560,10 @@ static int lio_set_phys_id(struct net_device *netdev,
 						   &lio->phy_beacon_val);
 			if (ret)
 				return ret;
+		} else if (oct->chip_id == OCTEON_CN23XX_PF_VID) {
+			octnet_id_active(netdev, LED_IDENTIFICATION_OFF);
 
+			return 0;
 		} else {
 			return -EINVAL;
 		}
@@ -549,6 +592,13 @@ lio_ethtool_get_ringparam(struct net_device *netdev,
 		rx_max_pending = CN6XXX_MAX_OQ_DESCRIPTORS;
 		rx_pending = CFG_GET_NUM_RX_DESCS_NIC_IF(conf6x, lio->ifidx);
 		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf6x, lio->ifidx);
+	} else if (OCTEON_CN23XX_PF(oct)) {
+		struct octeon_config *conf23 = CHIP_FIELD(oct, cn23xx_pf, conf);
+
+		tx_max_pending = CN23XX_MAX_IQ_DESCRIPTORS;
+		rx_max_pending = CN23XX_MAX_OQ_DESCRIPTORS;
+		rx_pending = CFG_GET_NUM_RX_DESCS_NIC_IF(conf23, lio->ifidx);
+		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf23, lio->ifidx);
 	}
 
 	if (lio->mtu > OCTNET_DEFAULT_FRM_SIZE - OCTNET_FRM_HEADER_SIZE) {
@@ -947,6 +997,16 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 	intrmod_cfg = &oct->intrmod;
 
 	switch (oct->chip_id) {
+	case OCTEON_CN23XX_PF_VID:
+		if (!intrmod_cfg->rx_enable) {
+			intr_coal->rx_coalesce_usecs = intrmod_cfg->rx_usecs;
+			intr_coal->rx_max_coalesced_frames =
+				intrmod_cfg->rx_frames;
+		}
+		if (!intrmod_cfg->tx_enable)
+			intr_coal->tx_max_coalesced_frames =
+				intrmod_cfg->tx_frames;
+		break;
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX: {
 		struct octeon_cn6xxx *cn6xxx =
@@ -982,7 +1042,15 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 		intr_coal->rx_coalesce_usecs_low =
 			intrmod_cfg->rx_mintmr_trigger;
 		intr_coal->rx_max_coalesced_frames_low =
-			intrmod_cfg->rx_mincnt_trigger;
+		    intrmod_cfg->rx_mincnt_trigger;
+	}
+	if (OCTEON_CN23XX_PF(oct) &&
+	    (intrmod_cfg->tx_enable)) {
+		intr_coal->use_adaptive_tx_coalesce = intrmod_cfg->tx_enable;
+		intr_coal->tx_max_coalesced_frames_high =
+		    intrmod_cfg->tx_maxcnt_trigger;
+		intr_coal->tx_max_coalesced_frames_low =
+		    intrmod_cfg->tx_mincnt_trigger;
 	}
 	return 0;
 }
@@ -1059,11 +1127,11 @@ static void
 octnet_nic_stats_callback(struct octeon_device *oct_dev,
 			  u32 status, void *ptr)
 {
-	struct octeon_soft_command  *sc = (struct octeon_soft_command  *)ptr;
-	struct oct_nic_stats_resp *resp = (struct oct_nic_stats_resp *)
-		sc->virtrptr;
-	struct oct_nic_stats_ctrl *ctrl = (struct oct_nic_stats_ctrl *)
-		sc->ctxptr;
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)ptr;
+	struct oct_nic_stats_resp *resp =
+	    (struct oct_nic_stats_resp *)sc->virtrptr;
+	struct oct_nic_stats_ctrl *ctrl =
+	    (struct oct_nic_stats_ctrl *)sc->ctxptr;
 	struct nic_rx_stats *rsp_rstats = &resp->stats.fromwire;
 	struct nic_tx_stats *rsp_tstats = &resp->stats.fromhost;
 
@@ -1313,6 +1381,27 @@ oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 		CFG_SET_OQ_INTR_PKT(cn6xxx->conf, rx_max_coalesced_frames);
 		break;
 	}
+	case OCTEON_CN23XX_PF_VID: {
+		int q_no;
+
+		if (!intr_coal->rx_max_coalesced_frames)
+			rx_max_coalesced_frames = oct->intrmod.rx_frames;
+		else
+			rx_max_coalesced_frames =
+			    intr_coal->rx_max_coalesced_frames;
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			q_no += oct->sriov_info.pf_srn;
+			octeon_write_csr64(
+			    oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(q_no),
+			    (octeon_read_csr64(
+				 oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(q_no)) &
+			     (0x3fffff00000000UL)) |
+				rx_max_coalesced_frames);
+			/*consider setting resend bit*/
+		}
+		oct->intrmod.rx_frames = rx_max_coalesced_frames;
+		break;
+	}
 	default:
 		return -EINVAL;
 	}
@@ -1345,6 +1434,27 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 		CFG_SET_OQ_INTR_TIME(cn6xxx->conf, rx_coalesce_usecs);
 		break;
 	}
+	case OCTEON_CN23XX_PF_VID: {
+		u64 time_threshold;
+		int q_no;
+
+		if (!intr_coal->rx_coalesce_usecs)
+			rx_coalesce_usecs = oct->intrmod.rx_usecs;
+		else
+			rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
+		time_threshold =
+		    cn23xx_pf_get_oq_ticks(oct, (u32)rx_coalesce_usecs);
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			q_no += oct->sriov_info.pf_srn;
+			octeon_write_csr64(oct,
+					   CN23XX_SLI_OQ_PKT_INT_LEVELS(q_no),
+					   (oct->intrmod.rx_frames |
+					    ((u64)time_threshold << 32)));
+			/*consider writing to resend bit here*/
+		}
+		oct->intrmod.rx_usecs = rx_coalesce_usecs;
+		break;
+	}
 	default:
 		return -EINVAL;
 	}
@@ -1357,12 +1467,37 @@ oct_cfg_tx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal
 		   __attribute__((unused)))
 {
 	struct octeon_device *oct = lio->oct_dev;
+	u32 iq_intr_pkt;
+	void __iomem *inst_cnt_reg;
+	u64 val;
 
 	/* Config Cnt based interrupt values */
 	switch (oct->chip_id) {
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX:
 		break;
+	case OCTEON_CN23XX_PF_VID: {
+		int q_no;
+
+		if (!intr_coal->tx_max_coalesced_frames)
+			iq_intr_pkt = CN23XX_DEF_IQ_INTR_THRESHOLD &
+				      CN23XX_PKT_IN_DONE_WMARK_MASK;
+		else
+			iq_intr_pkt = intr_coal->tx_max_coalesced_frames &
+				      CN23XX_PKT_IN_DONE_WMARK_MASK;
+		for (q_no = 0; q_no < oct->num_iqs; q_no++) {
+			inst_cnt_reg = (oct->instr_queue[q_no])->inst_cnt_reg;
+			val = readq(inst_cnt_reg);
+			/*clear wmark and count.dont want to write count back*/
+			val = (val & 0xFFFF000000000000ULL) |
+			      ((u64)iq_intr_pkt
+			       << CN23XX_PKT_IN_DONE_WMARK_BIT_POS);
+			writeq(val, inst_cnt_reg);
+			/*consider setting resend bit*/
+		}
+		oct->intrmod.tx_frames = iq_intr_pkt;
+		break;
+	}
 	default:
 		return -EINVAL;
 	}
@@ -1398,6 +1533,8 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 			return -EINVAL;
 		}
 		break;
+	case OCTEON_CN23XX_PF_VID:
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -1540,9 +1677,237 @@ static int lio_nway_reset(struct net_device *netdev)
 }
 
 /* Return register dump len. */
-static int lio_get_regs_len(struct net_device *dev __attribute__((unused)))
+static int lio_get_regs_len(struct net_device *dev)
 {
-	return OCT_ETHTOOL_REGDUMP_LEN;
+	struct lio *lio = GET_LIO(dev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	switch (oct->chip_id) {
+	case OCTEON_CN23XX_PF_VID:
+		return OCT_ETHTOOL_REGDUMP_LEN_23XX;
+	default:
+		return OCT_ETHTOOL_REGDUMP_LEN;
+	}
+}
+
+static int cn23xx_read_csr_reg(char *s, struct octeon_device *oct)
+{
+	u32 reg;
+	u8 pf_num = oct->pf_num;
+	int len = 0;
+	int i;
+
+	/* PCI  Window Registers */
+
+	len += sprintf(s + len, "\n\t Octeon CSR Registers\n\n");
+
+	/*0x29030 or 0x29040*/
+	reg = CN23XX_SLI_PKT_MAC_RINFO64(oct->pcie_port, oct->pf_num);
+	len += sprintf(s + len,
+		       "\n[%08x] (SLI_PKT_MAC%d_PF%d_RINFO): %016llx\n",
+		       reg, oct->pcie_port, oct->pf_num,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*0x27080 or 0x27090*/
+	reg = CN23XX_SLI_MAC_PF_INT_ENB64(oct->pcie_port, oct->pf_num);
+	len +=
+	    sprintf(s + len, "\n[%08x] (SLI_MAC%d_PF%d_INT_ENB): %016llx\n",
+		    reg, oct->pcie_port, oct->pf_num,
+		    (u64)octeon_read_csr64(oct, reg));
+
+	/*0x27000 or 0x27010*/
+	reg = CN23XX_SLI_MAC_PF_INT_SUM64(oct->pcie_port, oct->pf_num);
+	len +=
+	    sprintf(s + len, "\n[%08x] (SLI_MAC%d_PF%d_INT_SUM): %016llx\n",
+		    reg, oct->pcie_port, oct->pf_num,
+		    (u64)octeon_read_csr64(oct, reg));
+
+	/*0x29120*/
+	reg = 0x29120;
+	len += sprintf(s + len, "\n[%08x] (SLI_PKT_MEM_CTL): %016llx\n", reg,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*0x27300*/
+	reg = 0x27300 + oct->pcie_port * CN23XX_MAC_INT_OFFSET +
+	      (oct->pf_num) * CN23XX_PF_INT_OFFSET;
+	len += sprintf(
+	    s + len, "\n[%08x] (SLI_MAC%d_PF%d_PKT_VF_INT): %016llx\n", reg,
+	    oct->pcie_port, oct->pf_num, (u64)octeon_read_csr64(oct, reg));
+
+	/*0x27200*/
+	reg = 0x27200 + oct->pcie_port * CN23XX_MAC_INT_OFFSET +
+	      (oct->pf_num) * CN23XX_PF_INT_OFFSET;
+	len += sprintf(s + len,
+		       "\n[%08x] (SLI_MAC%d_PF%d_PP_VF_INT): %016llx\n",
+		       reg, oct->pcie_port, oct->pf_num,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*29130*/
+	reg = CN23XX_SLI_PKT_CNT_INT;
+	len += sprintf(s + len, "\n[%08x] (SLI_PKT_CNT_INT): %016llx\n", reg,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*0x29140*/
+	reg = CN23XX_SLI_PKT_TIME_INT;
+	len += sprintf(s + len, "\n[%08x] (SLI_PKT_TIME_INT): %016llx\n", reg,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*0x29160*/
+	reg = 0x29160;
+	len += sprintf(s + len, "\n[%08x] (SLI_PKT_INT): %016llx\n", reg,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*0x29180*/
+	reg = CN23XX_SLI_OQ_WMARK;
+	len += sprintf(s + len, "\n[%08x] (SLI_PKT_OUTPUT_WMARK): %016llx\n",
+		       reg, (u64)octeon_read_csr64(oct, reg));
+
+	/*0x291E0*/
+	reg = CN23XX_SLI_PKT_IOQ_RING_RST;
+	len += sprintf(s + len, "\n[%08x] (SLI_PKT_RING_RST): %016llx\n", reg,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*0x29210*/
+	reg = CN23XX_SLI_GBL_CONTROL;
+	len += sprintf(s + len,
+		       "\n[%08x] (SLI_PKT_GBL_CONTROL): %016llx\n", reg,
+		       (u64)octeon_read_csr64(oct, reg));
+
+	/*0x29220*/
+	reg = 0x29220;
+	len += sprintf(s + len, "\n[%08x] (SLI_PKT_BIST_STATUS): %016llx\n",
+		       reg, (u64)octeon_read_csr64(oct, reg));
+
+	/*PF only*/
+	if (pf_num == 0) {
+		/*0x29260*/
+		reg = CN23XX_SLI_OUT_BP_EN_W1S;
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT_OUT_BP_EN_W1S):  %016llx\n",
+			       reg, (u64)octeon_read_csr64(oct, reg));
+	} else if (pf_num == 1) {
+		/*0x29270*/
+		reg = CN23XX_SLI_OUT_BP_EN2_W1S;
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT_OUT_BP_EN2_W1S): %016llx\n",
+			       reg, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_OQ_BUFF_INFO_SIZE(i);
+		len +=
+		    sprintf(s + len, "\n[%08x] (SLI_PKT%d_OUT_SIZE): %016llx\n",
+			    reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x10040*/
+	for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_IQ_INSTR_COUNT64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT_IN_DONE%d_CNTS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x10080*/
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_OQ_PKTS_CREDIT(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_SLIST_BAOFF_DBELL): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x10090*/
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_OQ_SIZE(i);
+		len += sprintf(
+		    s + len, "\n[%08x] (SLI_PKT%d_SLIST_FIFO_RSIZE): %016llx\n",
+		    reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x10050*/
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_OQ_PKT_CONTROL(i);
+		len += sprintf(
+			s + len,
+			"\n[%08x] (SLI_PKT%d__OUTPUT_CONTROL): %016llx\n",
+			reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x10070*/
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_OQ_BASE_ADDR64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_SLIST_BADDR): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x100a0*/
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_OQ_PKT_INT_LEVELS(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_INT_LEVELS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x100b0*/
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = CN23XX_SLI_OQ_PKTS_SENT(i);
+		len += sprintf(s + len, "\n[%08x] (SLI_PKT%d_CNTS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	/*0x100c0*/
+	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
+		reg = 0x100c0 + i * CN23XX_OQ_OFFSET;
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT%d_ERROR_INFO): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+
+		/*0x10000*/
+		for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++) {
+			reg = CN23XX_SLI_IQ_PKT_CONTROL64(i);
+			len += sprintf(
+				s + len,
+				"\n[%08x] (SLI_PKT%d_INPUT_CONTROL): %016llx\n",
+				reg, i, (u64)octeon_read_csr64(oct, reg));
+		}
+
+		/*0x10010*/
+		for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++) {
+			reg = CN23XX_SLI_IQ_BASE_ADDR64(i);
+			len += sprintf(
+			    s + len,
+			    "\n[%08x] (SLI_PKT%d_INSTR_BADDR): %016llx\n", reg,
+			    i, (u64)octeon_read_csr64(oct, reg));
+		}
+
+		/*0x10020*/
+		for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++) {
+			reg = CN23XX_SLI_IQ_DOORBELL(i);
+			len += sprintf(
+			    s + len,
+			    "\n[%08x] (SLI_PKT%d_INSTR_BAOFF_DBELL): %016llx\n",
+			    reg, i, (u64)octeon_read_csr64(oct, reg));
+		}
+
+		/*0x10030*/
+		for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++) {
+			reg = CN23XX_SLI_IQ_SIZE(i);
+			len += sprintf(
+			    s + len,
+			    "\n[%08x] (SLI_PKT%d_INSTR_FIFO_RSIZE): %016llx\n",
+			    reg, i, (u64)octeon_read_csr64(oct, reg));
+		}
+
+		/*0x10040*/
+		for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++)
+			reg = CN23XX_SLI_IQ_INSTR_COUNT64(i);
+		len += sprintf(s + len,
+			       "\n[%08x] (SLI_PKT_IN_DONE%d_CNTS): %016llx\n",
+			       reg, i, (u64)octeon_read_csr64(oct, reg));
+	}
+
+	return len;
 }
 
 static int cn6xxx_read_csr_reg(char *s, struct octeon_device *oct)
@@ -1687,6 +2052,10 @@ static void lio_get_regs(struct net_device *dev,
 	regs->version = OCT_ETHTOOL_REGSVER;
 
 	switch (oct->chip_id) {
+	case OCTEON_CN23XX_PF_VID:
+		memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN_23XX);
+		len += cn23xx_read_csr_reg(regbuf + len, oct);
+		break;
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX:
 		memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN);
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index acd0153..47a9cbf 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -234,6 +234,9 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_ADD_VLAN_FILTER  0x17
 #define   OCTNET_CMD_DEL_VLAN_FILTER  0x18
 #define   OCTNET_CMD_VXLAN_PORT_CONFIG 0x19
+
+#define   OCTNET_CMD_ID_ACTIVE         0x1a
+
 #define   OCTNET_CMD_VXLAN_PORT_ADD    0x0
 #define   OCTNET_CMD_VXLAN_PORT_DEL    0x1
 #define   OCTNET_CMD_RXCSUM_ENABLE     0x0
@@ -830,6 +833,8 @@ struct oct_link_stats {
 #define VITESSE_PHY_GPIO_DRIVEOFF 0x4
 #define VITESSE_PHY_GPIO_HIGH     0x2
 #define VITESSE_PHY_GPIO_LOW      0x3
+#define LED_IDENTIFICATION_ON     0x1
+#define LED_IDENTIFICATION_OFF    0x0
 
 struct oct_mdio_cmd {
 	u64 op;
-- 
1.8.3.1
