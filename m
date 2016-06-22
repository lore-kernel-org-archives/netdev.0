From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 09/13] liquidio: New statistics support
Date: Tue, 21 Jun 2016 22:53:11 -0700
Message-ID: <1466574795-4306-10-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bl2on0077.outbound.protection.outlook.com ([65.55.169.77]:53336
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751589AbcFVFzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:25 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds extensive support of statistics for data path,
control path and firmware.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 574 ++++++++++++++++++---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  48 +-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  10 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   6 +
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |   4 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  11 +
 6 files changed, 588 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 9c6b58a..2b03095 100644
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
@@ -77,28 +79,109 @@ enum {
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
@@ -516,8 +599,13 @@ lio_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
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
@@ -526,51 +614,245 @@ lio_get_ethtool_stats(struct net_device *netdev,
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
+	struct net_device_stats *netstats = &netdev->stats;
 	int i = 0, j;
 
-	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES(oct); j++) {
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
 		if (!(oct_dev->io_qmask.iq & (1ULL << j)))
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
-	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES(oct); j++) {
+	/* RX */
+	/* for (j = 0; j < oct_dev->num_oqs; j++) { */
+	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES(oct_dev); j++) {
 		if (!(oct_dev->io_qmask.oq & (1ULL << j)))
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
 
@@ -579,26 +861,43 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
 	int num_iq_stats, num_oq_stats, i, j;
+	int num_stats;
 
-	num_iq_stats = ARRAY_SIZE(oct_iq_stats_strings);
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
-		if (!(oct_dev->io_qmask.iq & (1ULL << i)))
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
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
-		if (!(oct_dev->io_qmask.oq & (1ULL << i)))
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
 
@@ -607,8 +906,14 @@ static int lio_get_sset_count(struct net_device *netdev, int sset)
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
@@ -731,6 +1036,155 @@ static int octnet_set_intrmod_cfg(struct lio *lio,
 	return 0;
 }
 
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
+		octeon_free_soft_command(oct_dev, sc);
+		return -EINVAL;
+	}
+
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
+	return 0;
+}
+
 /* Enable/Disable auto interrupt Moderation */
 static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
 				 *intr_coal)
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a1e31ac..9f97d11 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -72,6 +72,9 @@ MODULE_PARM_DESC(console_bitmask,
 
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
+#define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
+	(octeon_dev_ptr->instr_queue[iq_no]->stats.field += count)
+
 static int debug = -1;
 module_param(debug, int, 0644);
 MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
@@ -682,13 +685,24 @@ static inline void txqs_start(struct net_device *netdev)
  */
 static inline void txqs_wake(struct net_device *netdev)
 {
+	struct lio *lio = GET_LIO(netdev);
+
 	if (netif_is_multiqueue(netdev)) {
 		int i;
 
-		for (i = 0; i < netdev->num_tx_queues; i++)
-			if (__netif_subqueue_stopped(netdev, i))
+		for (i = 0; i < netdev->num_tx_queues; i++) {
+			int qno = lio->linfo.txpciq[i %
+				(lio->linfo.num_txpciq)].s.q_no;
+
+			if (__netif_subqueue_stopped(netdev, i)) {
+				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, qno,
+							  tx_restart, 1);
 				netif_wake_subqueue(netdev, i);
+			}
+		}
 	} else {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, lio->txq,
+					  tx_restart, 1);
 		netif_wake_queue(netdev);
 	}
 }
@@ -763,6 +777,8 @@ static inline int check_txq_status(struct lio *lio)
 				continue;
 			if (__netif_subqueue_stopped(lio->netdev, q)) {
 				wake_q(lio->netdev, q);
+				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq,
+							  tx_restart, 1);
 				ret_val++;
 			}
 		}
@@ -770,6 +786,8 @@ static inline int check_txq_status(struct lio *lio)
 		if (octnet_iq_is_full(lio->oct_dev, lio->txq))
 			return 0;
 		wake_q(lio->netdev, lio->txq);
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, lio->txq,
+					  tx_restart, 1);
 		ret_val = 1;
 	}
 	return ret_val;
@@ -981,10 +999,16 @@ static void update_txq_status(struct octeon_device *oct, int iq_num)
 		if (__netif_subqueue_stopped(netdev, iq->q_index) &&
 		    lio->linfo.link.s.link_up &&
 		    (!octnet_iq_is_full(oct, iq_num))) {
+			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
+						  tx_restart, 1);
 			netif_wake_subqueue(netdev, iq->q_index);
 		} else {
-			if (!octnet_iq_is_full(oct, lio->txq))
+			if (!octnet_iq_is_full(oct, lio->txq)) {
+				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev,
+							  lio->txq,
+							  tx_restart, 1);
 				wake_q(netdev, lio->txq);
+			}
 		}
 	}
 }
@@ -1115,6 +1139,9 @@ static int liquidio_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return -ENOMEM;
 	}
 
+	oct_dev->rx_pause = 1;
+	oct_dev->tx_pause = 1;
+
 	dev_dbg(&oct_dev->pci_dev->dev, "Device is ready\n");
 
 	return 0;
@@ -1468,8 +1495,10 @@ static inline int check_txq_state(struct lio *lio, struct sk_buff *skb)
 	if (octnet_iq_is_full(lio->oct_dev, iq))
 		return 0;
 
-	if (__netif_subqueue_stopped(lio->netdev, q))
+	if (__netif_subqueue_stopped(lio->netdev, q)) {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq, tx_restart, 1);
 		wake_q(lio->netdev, q);
+	}
 	return 1;
 }
 
@@ -2382,6 +2411,10 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 
 		break;
 
+	case OCTNET_CMD_SET_FLOW_CTL:
+		netif_info(lio, probe, lio->netdev, "Set RX/TX flow control parameters\n");
+		break;
+
 	default:
 		dev_err(&oct->pci_dev->dev, "%s Unknown cmd %d\n", __func__,
 			nctrl->ncmd.s.cmd);
@@ -2976,7 +3009,9 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (skb_shinfo(skb)->gso_size) {
 		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
 		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
+		stats->tx_gso++;
 	}
+
 	/* HW insert VLAN tag */
 	if (skb_vlan_tag_present(skb)) {
 		irh->priority = skb_vlan_tag_get(skb) >> 13;
@@ -2999,7 +3034,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	netif_trans_update(netdev);
 
-	stats->tx_done++;
+	if (skb_shinfo(skb)->gso_size)
+		stats->tx_done += skb_shinfo(skb)->gso_segs;
+	else
+		stats->tx_done++;
 	stats->tx_tot_bytes += skb->len;
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index b5ab704..4dc8e54 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -736,10 +736,16 @@ struct nic_rx_stats {
 	u64 fw_err_pko;
 	u64 fw_err_link;
 	u64 fw_err_drop;
+
+	/* LRO */
 	u64 fw_lro_pkts;   /* Number of packets that are LROed      */
 	u64 fw_lro_octs;   /* Number of octets that are LROed       */
 	u64 fw_total_lro;  /* Number of LRO packets formed          */
 	u64 fw_lro_aborts; /* Number of times lRO of packet aborted */
+	u64 fw_lro_aborts_port;
+	u64 fw_lro_aborts_seq;
+	u64 fw_lro_aborts_tsval;
+	u64 fw_lro_aborts_timer;
 	/* intrmod: packet forward rate */
 	u64 fwd_rate;
 };
@@ -763,9 +769,13 @@ struct nic_tx_stats {
 	/* firmware stats */
 	u64 fw_total_sent;
 	u64 fw_total_fwd;
+	u64 fw_total_fwd_bytes;
 	u64 fw_err_pko;
 	u64 fw_err_link;
 	u64 fw_err_drop;
+	u64 fw_err_tso;
+	u64 fw_tso;		/* number of tso requests */
+	u64 fw_tso_fwd;		/* number of packets segmented in tso */
 };
 
 struct oct_link_stats {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index ceb905d..95b4eb7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -394,6 +394,12 @@ struct octeon_device {
 	struct cavium_wk console_poll_work[MAX_OCTEON_MAPS];
 
 	void *priv;
+
+	int rx_pause;
+	int tx_pause;
+
+	struct oct_link_stats link_stats; /*stastics from firmware*/
+
 };
 
 #define  OCT_DRV_ONLINE 1
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 69d5b91..caa2b4f 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -65,6 +65,10 @@ struct oct_iq_stats {
 	u64 tx_iq_busy;/**< Numof times this iq was found to be full. */
 	u64 tx_dropped;/**< Numof pkts dropped dueto xmitpath errors. */
 	u64 tx_tot_bytes;/**< Total count of bytes sento to network. */
+	u64 tx_gso;  /* count of tso */
+	u64 tx_dmamap_fail;
+	u64 tx_restart;
+	/*u64 tx_timeout_count;*/
 };
 
 #define OCT_IQ_STATS_SIZE   (sizeof(struct oct_iq_stats))
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 9c14484..b481edc 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -30,6 +30,17 @@
 #include <linux/dma-mapping.h>
 #include <linux/ptp_clock_kernel.h>
 
+struct oct_nic_stats_resp {
+	u64     rh;
+	struct oct_link_stats stats;
+	u64     status;
+};
+
+struct oct_nic_stats_ctrl {
+	struct completion complete;
+	struct net_device *netdev;
+};
+
 /** LiquidIO per-interface network private data */
 struct lio {
 	/** State of the interface. Rx/Tx happens only in the RUNNING state.  */
-- 
1.8.3.1
