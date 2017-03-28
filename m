From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: refactor interrupt moderation code
Date: Tue, 28 Mar 2017 12:14:06 -0700
Message-ID: <20170328191406.GA1027@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0079.outbound.protection.outlook.com ([104.47.40.79]:57888
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755812AbdC1TOV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 15:14:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

Refactor interrupt moderation code for flexibility because parameters are
different for 10G and 25G cards.  Currently parameters (for 10G only) come
from macros compiled-in to the PF and VF drivers; fix it so that parameters
suitable for the card (10G or 25G) come from the NIC firmware via response
to a command.

Also bump up driver version to 1.5.1 to match newer NIC firmware version.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 447 +++++++++++++--------
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  17 -
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |  17 -
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  26 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  13 +-
 5 files changed, 276 insertions(+), 244 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 6eef3b9..fac02ed 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -33,6 +33,19 @@
 
 static int octnet_get_link_stats(struct net_device *netdev);
 
+struct oct_intrmod_context {
+	int octeon_id;
+	wait_queue_head_t wc;
+	int cond;
+	int status;
+};
+
+struct oct_intrmod_resp {
+	u64     rh;
+	struct oct_intrmod_cfg intrmod;
+	u64     status;
+};
+
 struct oct_mdio_cmd_context {
 	int octeon_id;
 	wait_queue_head_t wc;
@@ -1298,95 +1311,103 @@ static int lio_vf_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
-static int lio_get_intr_coalesce(struct net_device *netdev,
-				 struct ethtool_coalesce *intr_coal)
+/* Callback function for intrmod */
+static void octnet_intrmod_callback(struct octeon_device *oct_dev,
+				    u32 status,
+				    void *ptr)
 {
-	struct lio *lio = GET_LIO(netdev);
-	struct octeon_device *oct = lio->oct_dev;
-	struct octeon_instr_queue *iq;
-	struct oct_intrmod_cfg *intrmod_cfg;
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)ptr;
+	struct oct_intrmod_context *ctx;
 
-	intrmod_cfg = &oct->intrmod;
+	ctx  = (struct oct_intrmod_context *)sc->ctxptr;
 
-	switch (oct->chip_id) {
-	case OCTEON_CN23XX_PF_VID:
-	case OCTEON_CN23XX_VF_VID:
-		if (!intrmod_cfg->rx_enable) {
-			intr_coal->rx_coalesce_usecs = intrmod_cfg->rx_usecs;
-			intr_coal->rx_max_coalesced_frames =
-				intrmod_cfg->rx_frames;
-		}
-		if (!intrmod_cfg->tx_enable)
-			intr_coal->tx_max_coalesced_frames =
-				intrmod_cfg->tx_frames;
-		break;
-	case OCTEON_CN68XX:
-	case OCTEON_CN66XX: {
-		struct octeon_cn6xxx *cn6xxx =
-			(struct octeon_cn6xxx *)oct->chip;
+	ctx->status = status;
 
-		if (!intrmod_cfg->rx_enable) {
-			intr_coal->rx_coalesce_usecs =
-				CFG_GET_OQ_INTR_TIME(cn6xxx->conf);
-			intr_coal->rx_max_coalesced_frames =
-				CFG_GET_OQ_INTR_PKT(cn6xxx->conf);
-		}
-		iq = oct->instr_queue[lio->linfo.txpciq[0].s.q_no];
-		intr_coal->tx_max_coalesced_frames = iq->fill_threshold;
-		break;
-	}
-	default:
-		netif_info(lio, drv, lio->netdev, "Unknown Chip !!\n");
+	oct_dev = lio_get_device(ctx->octeon_id);
+
+	WRITE_ONCE(ctx->cond, 1);
+
+	/* This barrier is required to be sure that the response has been
+	 * written fully before waking up the handler
+	 */
+	wmb();
+
+	wake_up_interruptible(&ctx->wc);
+}
+
+/*  get interrupt moderation parameters */
+static int octnet_get_intrmod_cfg(struct lio *lio,
+				  struct oct_intrmod_cfg *intr_cfg)
+{
+	struct octeon_soft_command *sc;
+	struct oct_intrmod_context *ctx;
+	struct oct_intrmod_resp *resp;
+	int retval;
+	struct octeon_device *oct_dev = lio->oct_dev;
+
+	/* Alloc soft command */
+	sc = (struct octeon_soft_command *)
+		octeon_alloc_soft_command(oct_dev,
+					  0,
+					  sizeof(struct oct_intrmod_resp),
+					  sizeof(struct oct_intrmod_context));
+
+	if (!sc)
+		return -ENOMEM;
+
+	resp = (struct oct_intrmod_resp *)sc->virtrptr;
+	memset(resp, 0, sizeof(struct oct_intrmod_resp));
+
+	ctx = (struct oct_intrmod_context *)sc->ctxptr;
+	memset(resp, 0, sizeof(struct oct_intrmod_context));
+	WRITE_ONCE(ctx->cond, 0);
+	ctx->octeon_id = lio_get_device_id(oct_dev);
+	init_waitqueue_head(&ctx->wc);
+
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
+	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC,
+				    OPCODE_NIC_INTRMOD_PARAMS, 0, 0, 0);
+
+	sc->callback = octnet_intrmod_callback;
+	sc->callback_arg = sc;
+	sc->wait_time = 1000;
+
+	retval = octeon_send_soft_command(oct_dev, sc);
+	if (retval == IQ_SEND_FAILED) {
+		octeon_free_soft_command(oct_dev, sc);
 		return -EINVAL;
 	}
-	if (intrmod_cfg->rx_enable) {
-		intr_coal->use_adaptive_rx_coalesce =
-			intrmod_cfg->rx_enable;
-		intr_coal->rate_sample_interval =
-			intrmod_cfg->check_intrvl;
-		intr_coal->pkt_rate_high =
-			intrmod_cfg->maxpkt_ratethr;
-		intr_coal->pkt_rate_low =
-			intrmod_cfg->minpkt_ratethr;
-		intr_coal->rx_max_coalesced_frames_high =
-			intrmod_cfg->rx_maxcnt_trigger;
-		intr_coal->rx_coalesce_usecs_high =
-			intrmod_cfg->rx_maxtmr_trigger;
-		intr_coal->rx_coalesce_usecs_low =
-			intrmod_cfg->rx_mintmr_trigger;
-		intr_coal->rx_max_coalesced_frames_low =
-		    intrmod_cfg->rx_mincnt_trigger;
+
+	/* Sleep on a wait queue till the cond flag indicates that the
+	 * response arrived or timed-out.
+	 */
+	if (sleep_cond(&ctx->wc, &ctx->cond) == -EINTR) {
+		dev_err(&oct_dev->pci_dev->dev, "Wait interrupted\n");
+		goto intrmod_info_wait_intr;
 	}
-	if ((OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct)) &&
-	    (intrmod_cfg->tx_enable)) {
-		intr_coal->use_adaptive_tx_coalesce = intrmod_cfg->tx_enable;
-		intr_coal->tx_max_coalesced_frames_high =
-		    intrmod_cfg->tx_maxcnt_trigger;
-		intr_coal->tx_max_coalesced_frames_low =
-		    intrmod_cfg->tx_mincnt_trigger;
+
+	retval = ctx->status || resp->status;
+	if (retval) {
+		dev_err(&oct_dev->pci_dev->dev,
+			"Get interrupt moderation parameters failed\n");
+		goto intrmod_info_wait_fail;
 	}
-	return 0;
-}
 
-/* Callback function for intrmod */
-static void octnet_intrmod_callback(struct octeon_device *oct_dev,
-				    u32 status,
-				    void *ptr)
-{
-	struct oct_intrmod_cmd *cmd = ptr;
-	struct octeon_soft_command *sc = cmd->sc;
+	octeon_swap_8B_data((u64 *)&resp->intrmod,
+			    (sizeof(struct oct_intrmod_cfg)) / 8);
+	memcpy(intr_cfg, &resp->intrmod, sizeof(struct oct_intrmod_cfg));
+	octeon_free_soft_command(oct_dev, sc);
 
-	oct_dev = cmd->oct_dev;
+	return 0;
 
-	if (status)
-		dev_err(&oct_dev->pci_dev->dev, "intrmod config failed. Status: %llx\n",
-			CVM_CAST64(status));
-	else
-		dev_info(&oct_dev->pci_dev->dev,
-			 "Rx-Adaptive Interrupt moderation enabled:%llx\n",
-			 oct_dev->intrmod.rx_enable);
+intrmod_info_wait_fail:
 
 	octeon_free_soft_command(oct_dev, sc);
+
+intrmod_info_wait_intr:
+
+	return -ENODEV;
 }
 
 /*  Configure interrupt moderation parameters */
@@ -1394,7 +1415,7 @@ static int octnet_set_intrmod_cfg(struct lio *lio,
 				  struct oct_intrmod_cfg *intr_cfg)
 {
 	struct octeon_soft_command *sc;
-	struct oct_intrmod_cmd *cmd;
+	struct oct_intrmod_context *ctx;
 	struct oct_intrmod_cfg *cfg;
 	int retval;
 	struct octeon_device *oct_dev = lio->oct_dev;
@@ -1404,19 +1425,21 @@ static int octnet_set_intrmod_cfg(struct lio *lio,
 		octeon_alloc_soft_command(oct_dev,
 					  sizeof(struct oct_intrmod_cfg),
 					  0,
-					  sizeof(struct oct_intrmod_cmd));
+					  sizeof(struct oct_intrmod_context));
 
 	if (!sc)
 		return -ENOMEM;
 
-	cmd = (struct oct_intrmod_cmd *)sc->ctxptr;
+	ctx = (struct oct_intrmod_context *)sc->ctxptr;
+
+	WRITE_ONCE(ctx->cond, 0);
+	ctx->octeon_id = lio_get_device_id(oct_dev);
+	init_waitqueue_head(&ctx->wc);
+
 	cfg = (struct oct_intrmod_cfg *)sc->virtdptr;
 
 	memcpy(cfg, intr_cfg, sizeof(struct oct_intrmod_cfg));
 	octeon_swap_8B_data((u64 *)cfg, (sizeof(struct oct_intrmod_cfg)) / 8);
-	cmd->sc = sc;
-	cmd->cfg = cfg;
-	cmd->oct_dev = oct_dev;
 
 	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
 
@@ -1424,7 +1447,7 @@ static int octnet_set_intrmod_cfg(struct lio *lio,
 				    OPCODE_NIC_INTRMOD_CFG, 0, 0, 0);
 
 	sc->callback = octnet_intrmod_callback;
-	sc->callback_arg = cmd;
+	sc->callback_arg = sc;
 	sc->wait_time = 1000;
 
 	retval = octeon_send_soft_command(oct_dev, sc);
@@ -1433,7 +1456,29 @@ static int octnet_set_intrmod_cfg(struct lio *lio,
 		return -EINVAL;
 	}
 
-	return 0;
+	/* Sleep on a wait queue till the cond flag indicates that the
+	 * response arrived or timed-out.
+	 */
+	if (sleep_cond(&ctx->wc, &ctx->cond) != -EINTR) {
+		retval = ctx->status;
+		if (retval)
+			dev_err(&oct_dev->pci_dev->dev,
+				"intrmod config failed. Status: %llx\n",
+				CVM_CAST64(retval));
+		else
+			dev_info(&oct_dev->pci_dev->dev,
+				 "Rx-Adaptive Interrupt moderation %s\n",
+				 (intr_cfg->rx_enable) ?
+				 "enabled" : "disabled");
+
+		octeon_free_soft_command(oct_dev, sc);
+
+		return ((retval) ? -ENODEV : 0);
+	}
+
+	dev_err(&oct_dev->pci_dev->dev, "iq/oq config failed\n");
+
+	return -EINTR;
 }
 
 static void
@@ -1590,80 +1635,106 @@ static int octnet_get_link_stats(struct net_device *netdev)
 	return 0;
 }
 
-/* Enable/Disable auto interrupt Moderation */
-static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
-				 *intr_coal)
+static int lio_get_intr_coalesce(struct net_device *netdev,
+				 struct ethtool_coalesce *intr_coal)
 {
-	int ret = 0;
+	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
-	struct oct_intrmod_cfg *intrmod_cfg;
-
-	intrmod_cfg = &oct->intrmod;
+	struct octeon_instr_queue *iq;
+	struct oct_intrmod_cfg intrmod_cfg;
 
-	if (oct->intrmod.rx_enable || oct->intrmod.tx_enable) {
-		if (intr_coal->rate_sample_interval)
-			intrmod_cfg->check_intrvl =
-				intr_coal->rate_sample_interval;
-		else
-			intrmod_cfg->check_intrvl =
-				LIO_INTRMOD_CHECK_INTERVAL;
+	if (octnet_get_intrmod_cfg(lio, &intrmod_cfg))
+		return -ENODEV;
 
-		if (intr_coal->pkt_rate_high)
-			intrmod_cfg->maxpkt_ratethr =
-				intr_coal->pkt_rate_high;
-		else
-			intrmod_cfg->maxpkt_ratethr =
-				LIO_INTRMOD_MAXPKT_RATETHR;
-
-		if (intr_coal->pkt_rate_low)
-			intrmod_cfg->minpkt_ratethr =
-				intr_coal->pkt_rate_low;
-		else
-			intrmod_cfg->minpkt_ratethr =
-				LIO_INTRMOD_MINPKT_RATETHR;
+	switch (oct->chip_id) {
+	case OCTEON_CN23XX_PF_VID:
+	case OCTEON_CN23XX_VF_VID: {
+		if (!intrmod_cfg.rx_enable) {
+			intr_coal->rx_coalesce_usecs = oct->rx_coalesce_usecs;
+			intr_coal->rx_max_coalesced_frames =
+				oct->rx_max_coalesced_frames;
+		}
+		if (!intrmod_cfg.tx_enable)
+			intr_coal->tx_max_coalesced_frames =
+				oct->tx_max_coalesced_frames;
+		break;
 	}
-	if (oct->intrmod.rx_enable) {
-		if (intr_coal->rx_max_coalesced_frames_high)
-			intrmod_cfg->rx_maxcnt_trigger =
-				intr_coal->rx_max_coalesced_frames_high;
-		else
-			intrmod_cfg->rx_maxcnt_trigger =
-				LIO_INTRMOD_RXMAXCNT_TRIGGER;
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX: {
+		struct octeon_cn6xxx *cn6xxx =
+			(struct octeon_cn6xxx *)oct->chip;
 
-		if (intr_coal->rx_coalesce_usecs_high)
-			intrmod_cfg->rx_maxtmr_trigger =
-				intr_coal->rx_coalesce_usecs_high;
-		else
-			intrmod_cfg->rx_maxtmr_trigger =
-				LIO_INTRMOD_RXMAXTMR_TRIGGER;
+		if (!intrmod_cfg.rx_enable) {
+			intr_coal->rx_coalesce_usecs =
+				CFG_GET_OQ_INTR_TIME(cn6xxx->conf);
+			intr_coal->rx_max_coalesced_frames =
+				CFG_GET_OQ_INTR_PKT(cn6xxx->conf);
+		}
+		iq = oct->instr_queue[lio->linfo.txpciq[0].s.q_no];
+		intr_coal->tx_max_coalesced_frames = iq->fill_threshold;
+		break;
+	}
+	default:
+		netif_info(lio, drv, lio->netdev, "Unknown Chip !!\n");
+		return -EINVAL;
+	}
+	if (intrmod_cfg.rx_enable) {
+		intr_coal->use_adaptive_rx_coalesce =
+			intrmod_cfg.rx_enable;
+		intr_coal->rate_sample_interval =
+			intrmod_cfg.check_intrvl;
+		intr_coal->pkt_rate_high =
+			intrmod_cfg.maxpkt_ratethr;
+		intr_coal->pkt_rate_low =
+			intrmod_cfg.minpkt_ratethr;
+		intr_coal->rx_max_coalesced_frames_high =
+			intrmod_cfg.rx_maxcnt_trigger;
+		intr_coal->rx_coalesce_usecs_high =
+			intrmod_cfg.rx_maxtmr_trigger;
+		intr_coal->rx_coalesce_usecs_low =
+			intrmod_cfg.rx_mintmr_trigger;
+		intr_coal->rx_max_coalesced_frames_low =
+			intrmod_cfg.rx_mincnt_trigger;
+	}
+	if ((OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct)) &&
+	    (intrmod_cfg.tx_enable)) {
+		intr_coal->use_adaptive_tx_coalesce =
+			intrmod_cfg.tx_enable;
+		intr_coal->tx_max_coalesced_frames_high =
+			intrmod_cfg.tx_maxcnt_trigger;
+		intr_coal->tx_max_coalesced_frames_low =
+			intrmod_cfg.tx_mincnt_trigger;
+	}
+	return 0;
+}
 
-		if (intr_coal->rx_coalesce_usecs_low)
-			intrmod_cfg->rx_mintmr_trigger =
-				intr_coal->rx_coalesce_usecs_low;
-		else
-			intrmod_cfg->rx_mintmr_trigger =
-				LIO_INTRMOD_RXMINTMR_TRIGGER;
+/* Enable/Disable auto interrupt Moderation */
+static int oct_cfg_adaptive_intr(struct lio *lio,
+				 struct oct_intrmod_cfg *intrmod_cfg,
+				 struct ethtool_coalesce *intr_coal)
+{
+	int ret = 0;
 
-		if (intr_coal->rx_max_coalesced_frames_low)
-			intrmod_cfg->rx_mincnt_trigger =
-				intr_coal->rx_max_coalesced_frames_low;
-		else
-			intrmod_cfg->rx_mincnt_trigger =
-				LIO_INTRMOD_RXMINCNT_TRIGGER;
+	if (intrmod_cfg->rx_enable || intrmod_cfg->tx_enable) {
+		intrmod_cfg->check_intrvl = intr_coal->rate_sample_interval;
+		intrmod_cfg->maxpkt_ratethr = intr_coal->pkt_rate_high;
+		intrmod_cfg->minpkt_ratethr = intr_coal->pkt_rate_low;
 	}
-	if (oct->intrmod.tx_enable) {
-		if (intr_coal->tx_max_coalesced_frames_high)
-			intrmod_cfg->tx_maxcnt_trigger =
-				intr_coal->tx_max_coalesced_frames_high;
-		else
-			intrmod_cfg->tx_maxcnt_trigger =
-				LIO_INTRMOD_TXMAXCNT_TRIGGER;
-		if (intr_coal->tx_max_coalesced_frames_low)
-			intrmod_cfg->tx_mincnt_trigger =
-				intr_coal->tx_max_coalesced_frames_low;
-		else
-			intrmod_cfg->tx_mincnt_trigger =
-				LIO_INTRMOD_TXMINCNT_TRIGGER;
+	if (intrmod_cfg->rx_enable) {
+		intrmod_cfg->rx_maxcnt_trigger =
+			intr_coal->rx_max_coalesced_frames_high;
+		intrmod_cfg->rx_maxtmr_trigger =
+			intr_coal->rx_coalesce_usecs_high;
+		intrmod_cfg->rx_mintmr_trigger =
+			intr_coal->rx_coalesce_usecs_low;
+		intrmod_cfg->rx_mincnt_trigger =
+			intr_coal->rx_max_coalesced_frames_low;
+	}
+	if (intrmod_cfg->tx_enable) {
+		intrmod_cfg->tx_maxcnt_trigger =
+			intr_coal->tx_max_coalesced_frames_high;
+		intrmod_cfg->tx_mincnt_trigger =
+			intr_coal->tx_max_coalesced_frames_low;
 	}
 
 	ret = octnet_set_intrmod_cfg(lio, intrmod_cfg);
@@ -1672,7 +1743,9 @@ static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
 }
 
 static int
-oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
+oct_cfg_rx_intrcnt(struct lio *lio,
+		   struct oct_intrmod_cfg *intrmod,
+		   struct ethtool_coalesce *intr_coal)
 {
 	struct octeon_device *oct = lio->oct_dev;
 	u32 rx_max_coalesced_frames;
@@ -1698,7 +1771,7 @@ oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 		int q_no;
 
 		if (!intr_coal->rx_max_coalesced_frames)
-			rx_max_coalesced_frames = oct->intrmod.rx_frames;
+			rx_max_coalesced_frames = intrmod->rx_frames;
 		else
 			rx_max_coalesced_frames =
 			    intr_coal->rx_max_coalesced_frames;
@@ -1709,17 +1782,18 @@ oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 			    (octeon_read_csr64(
 				 oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(q_no)) &
 			     (0x3fffff00000000UL)) |
-				rx_max_coalesced_frames);
+				(rx_max_coalesced_frames - 1));
 			/*consider setting resend bit*/
 		}
-		oct->intrmod.rx_frames = rx_max_coalesced_frames;
+		intrmod->rx_frames = rx_max_coalesced_frames;
+		oct->rx_max_coalesced_frames = rx_max_coalesced_frames;
 		break;
 	}
 	case OCTEON_CN23XX_VF_VID: {
 		int q_no;
 
 		if (!intr_coal->rx_max_coalesced_frames)
-			rx_max_coalesced_frames = oct->intrmod.rx_frames;
+			rx_max_coalesced_frames = intrmod->rx_frames;
 		else
 			rx_max_coalesced_frames =
 			    intr_coal->rx_max_coalesced_frames;
@@ -1730,9 +1804,10 @@ oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 				 oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no)) &
 			     (0x3fffff00000000UL)) |
 				rx_max_coalesced_frames);
-			/* consider writing to resend bit here */
+			/*consider writing to resend bit here*/
 		}
-		oct->intrmod.rx_frames = rx_max_coalesced_frames;
+		intrmod->rx_frames = rx_max_coalesced_frames;
+		oct->rx_max_coalesced_frames = rx_max_coalesced_frames;
 		break;
 	}
 	default:
@@ -1742,6 +1817,7 @@ oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 }
 
 static int oct_cfg_rx_intrtime(struct lio *lio,
+			       struct oct_intrmod_cfg *intrmod,
 			       struct ethtool_coalesce *intr_coal)
 {
 	struct octeon_device *oct = lio->oct_dev;
@@ -1772,7 +1848,7 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 		int q_no;
 
 		if (!intr_coal->rx_coalesce_usecs)
-			rx_coalesce_usecs = oct->intrmod.rx_usecs;
+			rx_coalesce_usecs = intrmod->rx_usecs;
 		else
 			rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
 		time_threshold =
@@ -1781,11 +1857,12 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 			q_no += oct->sriov_info.pf_srn;
 			octeon_write_csr64(oct,
 					   CN23XX_SLI_OQ_PKT_INT_LEVELS(q_no),
-					   (oct->intrmod.rx_frames |
-					    (time_threshold << 32)));
+					   (intrmod->rx_frames |
+					    ((u64)time_threshold << 32)));
 			/*consider writing to resend bit here*/
 		}
-		oct->intrmod.rx_usecs = rx_coalesce_usecs;
+		intrmod->rx_usecs = rx_coalesce_usecs;
+		oct->rx_coalesce_usecs = rx_coalesce_usecs;
 		break;
 	}
 	case OCTEON_CN23XX_VF_VID: {
@@ -1793,7 +1870,7 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 		int q_no;
 
 		if (!intr_coal->rx_coalesce_usecs)
-			rx_coalesce_usecs = oct->intrmod.rx_usecs;
+			rx_coalesce_usecs = intrmod->rx_usecs;
 		else
 			rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
 
@@ -1802,11 +1879,12 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
 			octeon_write_csr64(
 				oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no),
-				(oct->intrmod.rx_frames |
-				 (time_threshold << 32)));
-			/* consider setting resend bit */
+				(intrmod->rx_frames |
+				 ((u64)time_threshold << 32)));
+			/*consider setting resend bit*/
 		}
-		oct->intrmod.rx_usecs = rx_coalesce_usecs;
+		intrmod->rx_usecs = rx_coalesce_usecs;
+		oct->rx_coalesce_usecs = rx_coalesce_usecs;
 		break;
 	}
 	default:
@@ -1817,8 +1895,9 @@ static int oct_cfg_rx_intrtime(struct lio *lio,
 }
 
 static int
-oct_cfg_tx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal
-		   __attribute__((unused)))
+oct_cfg_tx_intrcnt(struct lio *lio,
+		   struct oct_intrmod_cfg *intrmod,
+		   struct ethtool_coalesce *intr_coal)
 {
 	struct octeon_device *oct = lio->oct_dev;
 	u32 iq_intr_pkt;
@@ -1845,12 +1924,13 @@ oct_cfg_tx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal
 			val = readq(inst_cnt_reg);
 			/*clear wmark and count.dont want to write count back*/
 			val = (val & 0xFFFF000000000000ULL) |
-			      ((u64)iq_intr_pkt
+			      ((u64)(iq_intr_pkt - 1)
 			       << CN23XX_PKT_IN_DONE_WMARK_BIT_POS);
 			writeq(val, inst_cnt_reg);
 			/*consider setting resend bit*/
 		}
-		oct->intrmod.tx_frames = iq_intr_pkt;
+		intrmod->tx_frames = iq_intr_pkt;
+		oct->tx_max_coalesced_frames = iq_intr_pkt;
 		break;
 	}
 	default:
@@ -1865,6 +1945,7 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 	struct lio *lio = GET_LIO(netdev);
 	int ret;
 	struct octeon_device *oct = lio->oct_dev;
+	struct oct_intrmod_cfg intrmod = {0};
 	u32 j, q_no;
 	int db_max, db_min;
 
@@ -1883,8 +1964,8 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 		} else {
 			dev_err(&oct->pci_dev->dev,
 				"LIQUIDIO: Invalid tx-frames:%d. Range is min:%d max:%d\n",
-				intr_coal->tx_max_coalesced_frames, db_min,
-				db_max);
+				intr_coal->tx_max_coalesced_frames,
+				db_min, db_max);
 			return -EINVAL;
 		}
 		break;
@@ -1895,24 +1976,36 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 		return -EINVAL;
 	}
 
-	oct->intrmod.rx_enable = intr_coal->use_adaptive_rx_coalesce ? 1 : 0;
-	oct->intrmod.tx_enable = intr_coal->use_adaptive_tx_coalesce ? 1 : 0;
+	intrmod.rx_enable = intr_coal->use_adaptive_rx_coalesce ? 1 : 0;
+	intrmod.tx_enable = intr_coal->use_adaptive_tx_coalesce ? 1 : 0;
+	intrmod.rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
+	intrmod.rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
+	intrmod.tx_frames = CFG_GET_IQ_INTR_PKT(octeon_get_conf(oct));
 
-	ret = oct_cfg_adaptive_intr(lio, intr_coal);
+	ret = oct_cfg_adaptive_intr(lio, &intrmod, intr_coal);
 
 	if (!intr_coal->use_adaptive_rx_coalesce) {
-		ret = oct_cfg_rx_intrtime(lio, intr_coal);
+		ret = oct_cfg_rx_intrtime(lio, &intrmod, intr_coal);
 		if (ret)
 			goto ret_intrmod;
 
-		ret = oct_cfg_rx_intrcnt(lio, intr_coal);
+		ret = oct_cfg_rx_intrcnt(lio, &intrmod, intr_coal);
 		if (ret)
 			goto ret_intrmod;
+	} else {
+		oct->rx_coalesce_usecs =
+			CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
+		oct->rx_max_coalesced_frames =
+			CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
 	}
+
 	if (!intr_coal->use_adaptive_tx_coalesce) {
-		ret = oct_cfg_tx_intrcnt(lio, intr_coal);
+		ret = oct_cfg_tx_intrcnt(lio, &intrmod, intr_coal);
 		if (ret)
 			goto ret_intrmod;
+	} else {
+		oct->tx_max_coalesced_frames =
+			CFG_GET_IQ_INTR_PKT(octeon_get_conf(oct));
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b06be91d..b222919 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -4320,7 +4320,6 @@ static int liquidio_enable_sriov(struct pci_dev *dev, int num_vfs)
  */
 static int liquidio_init_nic_module(struct octeon_device *oct)
 {
-	struct oct_intrmod_cfg *intrmod_cfg;
 	int i, retval = 0;
 	int num_nic_ports = CFG_GET_NUM_NIC_PORTS(octeon_get_conf(oct));
 
@@ -4345,22 +4344,6 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 
 	liquidio_ptp_init(oct);
 
-	/* Initialize interrupt moderation params */
-	intrmod_cfg = &((struct octeon_device *)oct)->intrmod;
-	intrmod_cfg->rx_enable = 1;
-	intrmod_cfg->check_intrvl = LIO_INTRMOD_CHECK_INTERVAL;
-	intrmod_cfg->maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
-	intrmod_cfg->minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
-	intrmod_cfg->rx_maxcnt_trigger = LIO_INTRMOD_RXMAXCNT_TRIGGER;
-	intrmod_cfg->rx_maxtmr_trigger = LIO_INTRMOD_RXMAXTMR_TRIGGER;
-	intrmod_cfg->rx_mintmr_trigger = LIO_INTRMOD_RXMINTMR_TRIGGER;
-	intrmod_cfg->rx_mincnt_trigger = LIO_INTRMOD_RXMINCNT_TRIGGER;
-	intrmod_cfg->tx_enable = 1;
-	intrmod_cfg->tx_maxcnt_trigger = LIO_INTRMOD_TXMAXCNT_TRIGGER;
-	intrmod_cfg->tx_mincnt_trigger = LIO_INTRMOD_TXMINCNT_TRIGGER;
-	intrmod_cfg->rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
-	intrmod_cfg->rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
-	intrmod_cfg->tx_frames = CFG_GET_IQ_INTR_PKT(octeon_get_conf(oct));
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
 
 	return retval;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 68794fa..89fd81a 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -3057,7 +3057,6 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
  */
 static int liquidio_init_nic_module(struct octeon_device *oct)
 {
-	struct oct_intrmod_cfg *intrmod_cfg;
 	int num_nic_ports = 1;
 	int i, retval = 0;
 
@@ -3079,22 +3078,6 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 		goto octnet_init_failure;
 	}
 
-	/* Initialize interrupt moderation params */
-	intrmod_cfg = &((struct octeon_device *)oct)->intrmod;
-	intrmod_cfg->rx_enable = 1;
-	intrmod_cfg->check_intrvl = LIO_INTRMOD_CHECK_INTERVAL;
-	intrmod_cfg->maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
-	intrmod_cfg->minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
-	intrmod_cfg->rx_maxcnt_trigger = LIO_INTRMOD_RXMAXCNT_TRIGGER;
-	intrmod_cfg->rx_maxtmr_trigger = LIO_INTRMOD_RXMAXTMR_TRIGGER;
-	intrmod_cfg->rx_mintmr_trigger = LIO_INTRMOD_RXMINTMR_TRIGGER;
-	intrmod_cfg->rx_mincnt_trigger = LIO_INTRMOD_RXMINCNT_TRIGGER;
-	intrmod_cfg->tx_enable = 1;
-	intrmod_cfg->tx_maxcnt_trigger = LIO_INTRMOD_TXMAXCNT_TRIGGER;
-	intrmod_cfg->tx_mincnt_trigger = LIO_INTRMOD_TXMINCNT_TRIGGER;
-	intrmod_cfg->rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
-	intrmod_cfg->rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
-	intrmod_cfg->tx_frames = CFG_GET_IQ_INTR_PKT(octeon_get_conf(oct));
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
 
 	return retval;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 17c9aff..8ea2323 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -27,7 +27,7 @@
 
 #define LIQUIDIO_PACKAGE ""
 #define LIQUIDIO_BASE_MAJOR_VERSION 1
-#define LIQUIDIO_BASE_MINOR_VERSION 4
+#define LIQUIDIO_BASE_MINOR_VERSION 5
 #define LIQUIDIO_BASE_MICRO_VERSION 1
 #define LIQUIDIO_BASE_VERSION   __stringify(LIQUIDIO_BASE_MAJOR_VERSION) "." \
 				__stringify(LIQUIDIO_BASE_MINOR_VERSION)
@@ -83,6 +83,7 @@ enum octeon_tag_type {
 #define OPCODE_NIC_INTRMOD_CFG         0x08
 #define OPCODE_NIC_IF_CFG              0x09
 #define OPCODE_NIC_VF_DRV_NOTICE       0x0A
+#define OPCODE_NIC_INTRMOD_PARAMS      0x0B
 #define VF_DRV_LOADED                  1
 #define VF_DRV_REMOVED                -1
 #define VF_DRV_MACADDR_CHANGED         2
@@ -851,29 +852,6 @@ struct oct_mdio_cmd {
 
 #define OCT_LINK_STATS_SIZE   (sizeof(struct oct_link_stats))
 
-/* intrmod: max. packet rate threshold */
-#define LIO_INTRMOD_MAXPKT_RATETHR	196608
-/* intrmod: min. packet rate threshold */
-#define LIO_INTRMOD_MINPKT_RATETHR	9216
-/* intrmod: max. packets to trigger interrupt */
-#define LIO_INTRMOD_RXMAXCNT_TRIGGER	384
-/* intrmod: min. packets to trigger interrupt */
-#define LIO_INTRMOD_RXMINCNT_TRIGGER	0
-/* intrmod: max. time to trigger interrupt */
-#define LIO_INTRMOD_RXMAXTMR_TRIGGER	128
-/* 66xx:intrmod: min. time to trigger interrupt
- * (value of 1 is optimum for TCP_RR)
- */
-#define LIO_INTRMOD_RXMINTMR_TRIGGER	1
-
-/* intrmod: max. packets to trigger interrupt */
-#define LIO_INTRMOD_TXMAXCNT_TRIGGER	64
-/* intrmod: min. packets to trigger interrupt */
-#define LIO_INTRMOD_TXMINCNT_TRIGGER	0
-
-/* intrmod: poll interval in seconds */
-#define LIO_INTRMOD_CHECK_INTERVAL  1
-
 struct oct_intrmod_cfg {
 	u64 rx_enable;
 	u64 tx_enable;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 8c5d33e..dab35bf 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -453,9 +453,6 @@ struct octeon_device {
 	/** List of dispatch functions */
 	struct octeon_dispatch_list dispatch;
 
-	/* Interrupt Moderation */
-	struct oct_intrmod_cfg intrmod;
-
 	u32 int_status;
 
 	u64 droq_intr;
@@ -541,6 +538,10 @@ struct octeon_device {
 	u32 priv_flags;
 
 	void *watchdog_task;
+
+	u32 rx_coalesce_usecs;
+	u32 rx_max_coalesced_frames;
+	u32 tx_max_coalesced_frames;
 };
 
 #define  OCT_DRV_ONLINE 1
@@ -554,12 +555,6 @@ struct octeon_device {
 #define CHIP_CONF(oct, TYPE)             \
 	(((struct octeon_ ## TYPE  *)((oct)->chip))->conf)
 
-struct oct_intrmod_cmd {
-	struct octeon_device *oct_dev;
-	struct octeon_soft_command *sc;
-	struct oct_intrmod_cfg *cfg;
-};
-
 /*------------------ Function Prototypes ----------------------*/
 
 /** Initialize device list memory */
