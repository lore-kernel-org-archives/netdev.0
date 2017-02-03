From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 8/8] net: ethernet: annapurna: add the coalesce helpers to the Alpine driver
Date: Fri,  3 Feb 2017 19:12:16 +0100
Message-ID: <20170203181216.30214-9-antoine.tenart@free-electrons.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        tsahee@annapurnalabs.com, rshitrit@annapurnalabs.com,
        saeed@annapurnalabs.com, barak@annapurnalabs.com,
        talz@annapurnalabs.com, thomas.petazzoni@free-electrons.com,
        arnd@arndb.de
To: netdev@vger.kernel.org, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36482 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdBCSPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:15:13 -0500
In-Reply-To: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the get_coalesce() and set_coalesce() helpers to the Annapurna Labs
Alpine Ethernet driver.
---
 drivers/net/ethernet/annapurna/al_eth.c | 81 +++++++++++++++++++++++++++++++++
 1 file changed, 81 insertions(+)

diff --git a/drivers/net/ethernet/annapurna/al_eth.c b/drivers/net/ethernet/annapurna/al_eth.c
index 674dafdb638a..369a5a7d5cc5 100644
--- a/drivers/net/ethernet/annapurna/al_eth.c
+++ b/drivers/net/ethernet/annapurna/al_eth.c
@@ -2132,6 +2132,9 @@ static void al_eth_config_rx_fwd(struct al_eth_adapter *adapter)
 	al_eth_fsm_table_init(adapter);
 }
 
+static void al_eth_set_coalesce(struct al_eth_adapter *adapter,
+				unsigned int tx_usecs, unsigned int rx_usecs);
+
 static void al_eth_restore_ethtool_params(struct al_eth_adapter *adapter)
 {
 	int i;
@@ -2141,6 +2144,8 @@ static void al_eth_restore_ethtool_params(struct al_eth_adapter *adapter)
 	adapter->tx_usecs = 0;
 	adapter->rx_usecs = 0;
 
+	al_eth_set_coalesce(adapter, tx_usecs, rx_usecs);
+
 	for (i = 0; i < AL_ETH_RX_RSS_TABLE_SIZE; i++)
 		al_eth_thash_table_set(&adapter->hw_adapter, i, 0,
 				       adapter->rss_ind_tbl[i]);
@@ -2364,6 +2369,80 @@ static int al_eth_set_settings(struct net_device *netdev,
 	return rc;
 }
 
+static int al_eth_get_coalesce(struct net_device *net_dev,
+			       struct ethtool_coalesce *coalesce)
+{
+	struct al_eth_adapter *adapter = netdev_priv(net_dev);
+
+	coalesce->tx_coalesce_usecs = adapter->tx_usecs;
+	coalesce->tx_coalesce_usecs_irq = adapter->tx_usecs;
+	coalesce->rx_coalesce_usecs = adapter->rx_usecs;
+	coalesce->rx_coalesce_usecs_irq = adapter->rx_usecs;
+	coalesce->use_adaptive_rx_coalesce = false;
+
+	return 0;
+}
+
+static void al_eth_set_coalesce(struct al_eth_adapter *adapter,
+				unsigned int tx_usecs, unsigned int rx_usecs)
+{
+	struct unit_regs *udma_base = (struct unit_regs *)(adapter->udma_base);
+	int qid;
+
+	if (adapter->tx_usecs != tx_usecs) {
+		uint interval = (tx_usecs + 15) / 16;
+
+		WARN_ON(interval > 255);
+
+		adapter->tx_usecs  = interval * 16;
+		for (qid = 0; qid < adapter->num_tx_queues; qid++)
+			al_iofic_msix_moder_interval_config(
+						&udma_base->gen.interrupt_regs.main_iofic,
+						AL_INT_GROUP_C, qid, interval);
+	}
+	if (adapter->rx_usecs != rx_usecs) {
+		uint interval = (rx_usecs + 15) / 16;
+
+		WARN_ON(interval > 255);
+
+		adapter->rx_usecs  = interval * 16;
+		for (qid = 0; qid < adapter->num_rx_queues; qid++)
+			al_iofic_msix_moder_interval_config(
+						&udma_base->gen.interrupt_regs.main_iofic,
+						AL_INT_GROUP_B, qid, interval);
+	}
+}
+
+static int al_eth_ethtool_set_coalesce(struct net_device *net_dev,
+				       struct ethtool_coalesce *coalesce)
+{
+	struct al_eth_adapter *adapter = netdev_priv(net_dev);
+	unsigned int tx_usecs = adapter->tx_usecs;
+	unsigned int rx_usecs = adapter->rx_usecs;
+
+	if (coalesce->use_adaptive_tx_coalesce)
+		return -EINVAL;
+
+	if (coalesce->rx_coalesce_usecs != rx_usecs)
+		rx_usecs = coalesce->rx_coalesce_usecs;
+	else
+		rx_usecs = coalesce->rx_coalesce_usecs_irq;
+
+	if (coalesce->tx_coalesce_usecs != tx_usecs)
+		tx_usecs = coalesce->tx_coalesce_usecs;
+	else
+		tx_usecs = coalesce->tx_coalesce_usecs_irq;
+
+	if (tx_usecs > (255 * 16))
+		return -EINVAL;
+	if (rx_usecs > (255 * 16))
+		return -EINVAL;
+
+	al_eth_set_coalesce(adapter, tx_usecs, rx_usecs);
+
+	return 0;
+}
+
 static int al_eth_nway_reset(struct net_device *netdev)
 {
 	struct al_eth_adapter *adapter = netdev_priv(netdev);
@@ -2613,6 +2692,8 @@ static const struct ethtool_ops al_eth_ethtool_ops = {
 
 	.nway_reset		= al_eth_nway_reset,
 	.get_link		= ethtool_op_get_link,
+	.get_coalesce		= al_eth_get_coalesce,
+	.set_coalesce		= al_eth_ethtool_set_coalesce,
 	.get_pauseparam		= al_eth_get_pauseparam,
 	.set_pauseparam		= al_eth_set_pauseparam,
 	.get_rxnfc		= al_eth_get_rxnfc,
-- 
2.11.0
