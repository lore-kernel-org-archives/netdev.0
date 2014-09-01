From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 04/12] be2net: Add TX completion error statistics in ethtool
Date: Mon, 1 Sep 2014 11:54:16 +0530
Message-ID: <1409552664-15990-5-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22507 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbaIAGV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:57 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

HW reports TX completion errors in TX completion. This patch adds these
counters to ethtool statistics.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    7 ++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   28 +++++++++++++++
 drivers/net/ethernet/emulex/benet/be_hw.h      |   12 ++++++
 drivers/net/ethernet/emulex/benet/be_main.c    |   45 ++++++++++++++++++++++++
 4 files changed, 92 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d9cd885..d491ac6 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -248,6 +248,13 @@ struct be_tx_stats {
 	ulong tx_jiffies;
 	u32 tx_stops;
 	u32 tx_drv_drops;	/* pkts dropped by driver */
+	/* the error counters are described in be_ethtool.c */
+	u32 tx_hdr_parse_err;
+	u32 tx_dma_err;
+	u32 tx_tso_err;
+	u32 tx_spoof_check_err;
+	u32 tx_qinq_err;
+	u32 tx_internal_parity_err;
 	struct u64_stats_sync sync;
 	struct u64_stats_sync sync_compl;
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index d8d7a4a..3a7ade4 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -157,6 +157,34 @@ static const struct be_ethtool_stat et_rx_stats[] = {
  */
 static const struct be_ethtool_stat et_tx_stats[] = {
 	{DRVSTAT_TX_INFO(tx_compl)}, /* If moving this member see above note */
+	/* This counter is incremented when the HW encounters an error while
+	 * parsing the packet header of an outgoing TX request. This counter is
+	 * applicable only for BE2, BE3 and Skyhawk based adapters.
+	 */
+	{DRVSTAT_TX_INFO(tx_hdr_parse_err)},
+	/* This counter is incremented when an error occurs in the DMA
+	 * operation associated with the TX request from the host to the device.
+	 */
+	{DRVSTAT_TX_INFO(tx_dma_err)},
+	/* This counter is incremented when MAC or VLAN spoof checking is
+	 * enabled on the interface and the TX request fails the spoof check
+	 * in HW.
+	 */
+	{DRVSTAT_TX_INFO(tx_spoof_check_err)},
+	/* This counter is incremented when the HW encounters an error while
+	 * performing TSO offload. This counter is applicable only for Lancer
+	 * adapters.
+	 */
+	{DRVSTAT_TX_INFO(tx_tso_err)},
+	/* This counter is incremented when the HW detects Q-in-Q style VLAN
+	 * tagging in a packet and such tagging is not expected on the outgoing
+	 * interface. This counter is applicable only for Lancer adapters.
+	 */
+	{DRVSTAT_TX_INFO(tx_qinq_err)},
+	/* This counter is incremented when the HW detects parity errors in the
+	 * packet data. This counter is applicable only for Lancer adapters.
+	 */
+	{DRVSTAT_TX_INFO(tx_internal_parity_err)},
 	{DRVSTAT_TX_INFO(tx_bytes)},
 	{DRVSTAT_TX_INFO(tx_pkts)},
 	/* Number of skbs queued for trasmission by the driver */
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 8840c64..295ee08 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -315,6 +315,18 @@ struct be_eth_hdr_wrb {
 	u32 dw[4];
 };
 
+/********* Tx Compl Status Encoding *********/
+#define BE_TX_COMP_HDR_PARSE_ERR	0x2
+#define BE_TX_COMP_NDMA_ERR		0x3
+#define BE_TX_COMP_ACL_ERR		0x5
+
+#define LANCER_TX_COMP_LSO_ERR			0x1
+#define LANCER_TX_COMP_HSW_DROP_MAC_ERR		0x3
+#define LANCER_TX_COMP_HSW_DROP_VLAN_ERR	0x5
+#define LANCER_TX_COMP_QINQ_ERR			0x7
+#define LANCER_TX_COMP_PARITY_ERR		0xb
+#define LANCER_TX_COMP_DMA_ERR			0xd
+
 /* TX Compl Queue Descriptor */
 
 /* Pseudo amap definition for eth_tx_compl in which each bit of the
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 810ce5c..e9658f7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2421,11 +2421,49 @@ loop_continue:
 	return work_done;
 }
 
+static inline void be_update_tx_err(struct be_tx_obj *txo, u32 status)
+{
+	switch (status) {
+	case BE_TX_COMP_HDR_PARSE_ERR:
+		tx_stats(txo)->tx_hdr_parse_err++;
+		break;
+	case BE_TX_COMP_NDMA_ERR:
+		tx_stats(txo)->tx_dma_err++;
+		break;
+	case BE_TX_COMP_ACL_ERR:
+		tx_stats(txo)->tx_spoof_check_err++;
+		break;
+	}
+}
+
+static inline void lancer_update_tx_err(struct be_tx_obj *txo, u32 status)
+{
+	switch (status) {
+	case LANCER_TX_COMP_LSO_ERR:
+		tx_stats(txo)->tx_tso_err++;
+		break;
+	case LANCER_TX_COMP_HSW_DROP_MAC_ERR:
+	case LANCER_TX_COMP_HSW_DROP_VLAN_ERR:
+		tx_stats(txo)->tx_spoof_check_err++;
+		break;
+	case LANCER_TX_COMP_QINQ_ERR:
+		tx_stats(txo)->tx_qinq_err++;
+		break;
+	case LANCER_TX_COMP_PARITY_ERR:
+		tx_stats(txo)->tx_internal_parity_err++;
+		break;
+	case LANCER_TX_COMP_DMA_ERR:
+		tx_stats(txo)->tx_dma_err++;
+		break;
+	}
+}
+
 static bool be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 			  int budget, int idx)
 {
 	struct be_eth_tx_compl *txcp;
 	int num_wrbs = 0, work_done;
+	u32 compl_status;
 
 	for (work_done = 0; work_done < budget; work_done++) {
 		txcp = be_tx_compl_get(&txo->cq);
@@ -2434,6 +2472,13 @@ static bool be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 		num_wrbs += be_tx_compl_process(adapter, txo,
 						GET_TX_COMPL_BITS(wrb_index,
 								  txcp));
+		compl_status = GET_TX_COMPL_BITS(status, txcp);
+		if (compl_status) {
+			if (lancer_chip(adapter))
+				lancer_update_tx_err(txo, compl_status);
+			else
+				be_update_tx_err(txo, compl_status);
+		}
 	}
 
 	if (work_done) {
-- 
1.7.1
