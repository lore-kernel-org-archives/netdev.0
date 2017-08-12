From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 8/8] liquidio: added support for ethtool --set-ring
 feature
Date: Fri, 11 Aug 2017 18:29:30 -0700
Message-ID: <20170812012930.GA2614@felix-thinkpad.cavium.com>
References: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0081.outbound.protection.outlook.com ([104.47.33.81]:35376
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752016AbdHLB3i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 21:29:38 -0400
Content-Disposition: inline
In-Reply-To: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

added support for ethtool --set-ring feature

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 131 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |   6 +-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |   6 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  13 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  14 +--
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   1 +
 6 files changed, 160 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index b78e296..5ef595d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -642,6 +642,9 @@ lio_ethtool_get_ringparam(struct net_device *netdev,
 	u32 tx_max_pending = 0, rx_max_pending = 0, tx_pending = 0,
 	    rx_pending = 0;
 
+	if (ifstate_check(lio, LIO_IFSTATE_RESETTING))
+		return;
+
 	if (OCTEON_CN6XXX(oct)) {
 		struct octeon_config *conf6x = CHIP_CONF(oct, cn6xxx);
 
@@ -666,6 +669,126 @@ lio_ethtool_get_ringparam(struct net_device *netdev,
 	ering->rx_jumbo_max_pending = 0;
 }
 
+static int lio_reset_queues(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct napi_struct *napi, *n;
+	int i;
+
+	dev_dbg(&oct->pci_dev->dev, "%s:%d ifidx %d\n",
+		__func__, __LINE__, lio->ifidx);
+
+	if (wait_for_pending_requests(oct))
+		dev_err(&oct->pci_dev->dev, "There were pending requests\n");
+
+	if (lio_wait_for_instr_fetch(oct))
+		dev_err(&oct->pci_dev->dev, "IQ had pending instructions\n");
+
+	if (octeon_set_io_queues_off(oct)) {
+		dev_err(&oct->pci_dev->dev, "setting io queues off failed\n");
+		return -1;
+	}
+
+	/* Disable the input and output queues now. No more packets will
+	 * arrive from Octeon.
+	 */
+	oct->fn_list.disable_io_queues(oct);
+	/* Delete NAPI */
+	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+		netif_napi_del(napi);
+
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.oq & BIT_ULL(i)))
+			continue;
+		octeon_delete_droq(oct, i);
+	}
+
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.iq & BIT_ULL(i)))
+			continue;
+		octeon_delete_instr_queue(oct, i);
+	}
+
+	if (oct->fn_list.setup_device_regs(oct)) {
+		dev_err(&oct->pci_dev->dev, "Failed to configure device registers\n");
+		return -1;
+	}
+
+	if (liquidio_setup_io_queues(oct, 0)) {
+		dev_err(&oct->pci_dev->dev, "IO queues initialization failed\n");
+		return -1;
+	}
+
+	/* Enable the input and output queues for this Octeon device */
+	if (oct->fn_list.enable_io_queues(oct)) {
+		dev_err(&oct->pci_dev->dev, "Failed to enable input/output queues");
+		return -1;
+	}
+
+	return 0;
+}
+
+static int lio_ethtool_set_ringparam(struct net_device *netdev,
+				     struct ethtool_ringparam *ering)
+{
+	u32 rx_count, tx_count, rx_count_old, tx_count_old;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	int stopped = 0;
+
+	if (!OCTEON_CN23XX_PF(oct) && !OCTEON_CN23XX_VF(oct))
+		return -EINVAL;
+
+	if ((ering->rx_mini_pending) || (ering->rx_jumbo_pending))
+		return -EINVAL;
+
+	rx_count = clamp_t(u32, ering->rx_pending, CN23XX_MIN_OQ_DESCRIPTORS,
+			   CN23XX_MAX_OQ_DESCRIPTORS);
+	tx_count = clamp_t(u32, ering->tx_pending, CN23XX_MIN_IQ_DESCRIPTORS,
+			   CN23XX_MAX_IQ_DESCRIPTORS);
+
+	rx_count_old = oct->droq[0]->max_count;
+	tx_count_old = oct->instr_queue[0]->max_count;
+
+	if ((rx_count == rx_count_old) && (tx_count == tx_count_old))
+		return 0;
+
+	ifstate_set(lio, LIO_IFSTATE_RESETTING);
+
+	if (netif_running(netdev)) {
+		netdev->netdev_ops->ndo_stop(netdev);
+		stopped = 1;
+	}
+
+	/* Change RX/TX DESCS  count */
+	if (tx_count != tx_count_old)
+		CFG_SET_NUM_TX_DESCS_NIC_IF(octeon_get_conf(oct), lio->ifidx,
+					    tx_count);
+	if (rx_count != rx_count_old)
+		CFG_SET_NUM_RX_DESCS_NIC_IF(octeon_get_conf(oct), lio->ifidx,
+					    rx_count);
+
+	if (lio_reset_queues(netdev))
+		goto err_lio_reset_queues;
+
+	if (stopped)
+		netdev->netdev_ops->ndo_open(netdev);
+
+	ifstate_reset(lio, LIO_IFSTATE_RESETTING);
+
+	return 0;
+
+err_lio_reset_queues:
+	if (tx_count != tx_count_old)
+		CFG_SET_NUM_TX_DESCS_NIC_IF(octeon_get_conf(oct), lio->ifidx,
+					    tx_count_old);
+	if (rx_count != rx_count_old)
+		CFG_SET_NUM_RX_DESCS_NIC_IF(octeon_get_conf(oct), lio->ifidx,
+					    rx_count_old);
+	return -EINVAL;
+}
+
 static u32 lio_get_msglevel(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -784,6 +907,9 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	struct net_device_stats *netstats = &netdev->stats;
 	int i = 0, j;
 
+	if (ifstate_check(lio, LIO_IFSTATE_RESETTING))
+		return;
+
 	netdev->netdev_ops->ndo_get_stats(netdev);
 	octnet_get_link_stats(netdev);
 
@@ -1048,6 +1174,9 @@ static void lio_vf_get_ethtool_stats(struct net_device *netdev,
 	struct octeon_device *oct_dev = lio->oct_dev;
 	int i = 0, j, vj;
 
+	if (ifstate_check(lio, LIO_IFSTATE_RESETTING))
+		return;
+
 	netdev->netdev_ops->ndo_get_stats(netdev);
 	/* sum of oct->droq[oq_no]->stats->rx_pkts_received */
 	data[i++] = CVM_CAST64(netstats->rx_packets);
@@ -2579,6 +2708,7 @@ static const struct ethtool_ops lio_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_drvinfo		= lio_get_drvinfo,
 	.get_ringparam		= lio_ethtool_get_ringparam,
+	.set_ringparam		= lio_ethtool_set_ringparam,
 	.get_channels		= lio_ethtool_get_channels,
 	.set_phys_id		= lio_set_phys_id,
 	.get_eeprom_len		= lio_get_eeprom_len,
@@ -2604,6 +2734,7 @@ static const struct ethtool_ops lio_vf_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_drvinfo		= lio_get_vf_drvinfo,
 	.get_ringparam		= lio_ethtool_get_ringparam,
+	.set_ringparam          = lio_ethtool_set_ringparam,
 	.get_channels		= lio_ethtool_get_channels,
 	.get_strings		= lio_vf_get_strings,
 	.get_ethtool_stats	= lio_vf_get_ethtool_stats,
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index e606d33..5718b60 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -814,7 +814,8 @@ static void print_link_info(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
 
-	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED) {
+	if (!ifstate_check(lio, LIO_IFSTATE_RESETTING) &&
+	    ifstate_check(lio, LIO_IFSTATE_REGISTERED)) {
 		struct oct_link_info *linfo = &lio->linfo;
 
 		if (linfo->link.s.link_up) {
@@ -2517,6 +2518,9 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 
 	oct = lio->oct_dev;
 
+	if (ifstate_check(lio, LIO_IFSTATE_RESETTING))
+		return stats;
+
 	for (i = 0; i < lio->linfo.num_txpciq; i++) {
 		iq_no = lio->linfo.txpciq[i].s.q_no;
 		iq_stats = &oct->instr_queue[iq_no]->stats;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index aa502a8..2fc2da3 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -548,7 +548,8 @@ static void print_link_info(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
 
-	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED) {
+	if (!ifstate_check(lio, LIO_IFSTATE_RESETTING) &&
+	    ifstate_check(lio, LIO_IFSTATE_REGISTERED)) {
 		struct oct_link_info *linfo = &lio->linfo;
 
 		if (linfo->link.s.link_up) {
@@ -1633,6 +1634,9 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 
 	oct = lio->oct_dev;
 
+	if (ifstate_check(lio, LIO_IFSTATE_RESETTING))
+		return stats;
+
 	for (i = 0; i < lio->linfo.num_txpciq; i++) {
 		iq_no = lio->linfo.txpciq[i].s.q_no;
 		iq_stats = &oct->instr_queue[iq_no]->stats;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index f229d79..63bd9c9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -71,13 +71,17 @@
 #define   CN23XX_MAX_RINGS_PER_VF          8
 
 #define   CN23XX_MAX_INPUT_QUEUES	CN23XX_MAX_RINGS_PER_PF
-#define   CN23XX_MAX_IQ_DESCRIPTORS	512
+#define   CN23XX_MAX_IQ_DESCRIPTORS	2048
+#define   CN23XX_DEFAULT_IQ_DESCRIPTORS	512
+#define   CN23XX_MIN_IQ_DESCRIPTORS	128
 #define   CN23XX_DB_MIN                 1
 #define   CN23XX_DB_MAX                 8
 #define   CN23XX_DB_TIMEOUT             1
 
 #define   CN23XX_MAX_OUTPUT_QUEUES	CN23XX_MAX_RINGS_PER_PF
-#define   CN23XX_MAX_OQ_DESCRIPTORS	512
+#define   CN23XX_MAX_OQ_DESCRIPTORS	2048
+#define   CN23XX_DEFAULT_OQ_DESCRIPTORS	512
+#define   CN23XX_MIN_OQ_DESCRIPTORS	128
 #define   CN23XX_OQ_BUF_SIZE		1664
 #define   CN23XX_OQ_PKTSPER_INTR	128
 /*#define CAVIUM_ONLY_CN23XX_RX_PERF*/
@@ -163,6 +167,11 @@
 				((cfg)->misc.oct_link_query_interval)
 #define CFG_GET_IS_SLI_BP_ON(cfg)                ((cfg)->misc.enable_sli_oq_bp)
 
+#define CFG_SET_NUM_RX_DESCS_NIC_IF(cfg, idx, value) \
+				((cfg)->nic_if_cfg[idx].num_rx_descs = value)
+#define CFG_SET_NUM_TX_DESCS_NIC_IF(cfg, idx, value) \
+				((cfg)->nic_if_cfg[idx].num_tx_descs = value)
+
 /* Max IOQs per OCTEON Link */
 #define MAX_IOQS_PER_NICIF              64
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 495cc88..29d53b1 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -418,7 +418,7 @@ static struct octeon_config default_cn23xx_conf = {
 	/** IQ attributes */
 	.iq = {
 		.max_iqs		= CN23XX_CFG_IO_QUEUES,
-		.pending_list_size	= (CN23XX_MAX_IQ_DESCRIPTORS *
+		.pending_list_size	= (CN23XX_DEFAULT_IQ_DESCRIPTORS *
 					   CN23XX_CFG_IO_QUEUES),
 		.instr_type		= OCTEON_64BYTE_INSTR,
 		.db_min			= CN23XX_DB_MIN,
@@ -436,8 +436,8 @@ static struct octeon_config default_cn23xx_conf = {
 	},
 
 	.num_nic_ports				= DEFAULT_NUM_NIC_PORTS_23XX,
-	.num_def_rx_descs			= CN23XX_MAX_OQ_DESCRIPTORS,
-	.num_def_tx_descs			= CN23XX_MAX_IQ_DESCRIPTORS,
+	.num_def_rx_descs			= CN23XX_DEFAULT_OQ_DESCRIPTORS,
+	.num_def_tx_descs			= CN23XX_DEFAULT_IQ_DESCRIPTORS,
 	.def_rx_buf_size			= CN23XX_OQ_BUF_SIZE,
 
 	/* For ethernet interface 0:  Port cfg Attributes */
@@ -455,10 +455,10 @@ static struct octeon_config default_cn23xx_conf = {
 		.num_rxqs			= DEF_RXQS_PER_INTF,
 
 		/* Num of desc for rx rings */
-		.num_rx_descs			= CN23XX_MAX_OQ_DESCRIPTORS,
+		.num_rx_descs			= CN23XX_DEFAULT_OQ_DESCRIPTORS,
 
 		/* Num of desc for tx rings */
-		.num_tx_descs			= CN23XX_MAX_IQ_DESCRIPTORS,
+		.num_tx_descs			= CN23XX_DEFAULT_IQ_DESCRIPTORS,
 
 		/* SKB size, We need not change buf size even for Jumbo frames.
 		 * Octeon can send jumbo frames in 4 consecutive descriptors,
@@ -484,10 +484,10 @@ static struct octeon_config default_cn23xx_conf = {
 		.num_rxqs			= DEF_RXQS_PER_INTF,
 
 		/* Num of desc for rx rings */
-		.num_rx_descs			= CN23XX_MAX_OQ_DESCRIPTORS,
+		.num_rx_descs			= CN23XX_DEFAULT_OQ_DESCRIPTORS,
 
 		/* Num of desc for tx rings */
-		.num_tx_descs			= CN23XX_MAX_IQ_DESCRIPTORS,
+		.num_tx_descs			= CN23XX_DEFAULT_IQ_DESCRIPTORS,
 
 		/* SKB size, We need not change buf size even for Jumbo frames.
 		 * Octeon can send jumbo frames in 4 consecutive descriptors,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index b49b155..d4b3930 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -33,6 +33,7 @@
 #define   LIO_IFSTATE_REGISTERED           0x02
 #define   LIO_IFSTATE_RUNNING              0x04
 #define   LIO_IFSTATE_RX_TIMESTAMP_ENABLED 0x08
+#define   LIO_IFSTATE_RESETTING		   0x10
 
 struct oct_nic_stats_resp {
 	u64     rh;
-- 
2.9.0
