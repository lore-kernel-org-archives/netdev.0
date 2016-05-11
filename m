From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 08/14] qede: Add VF support
Date: Wed, 11 May 2016 16:36:19 +0300
Message-ID: <1462973785-32532-9-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:20382 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932581AbcEKNhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:37:09 -0400
In-Reply-To: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a PCI callback for `sriov_configure' and a new PCI device id for
the VF [+ Some minor changes to accomodate differences between PF and VF
at the qede].
Following this, VF creation should be possible and the entire subset of
existing PF functionality that's allow to VFs should be supported.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  4 ++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 43 +++++++++++++++++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 52 +++++++++++++++++++++----
 3 files changed, 90 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index ff3ac0c..47d6b22 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -112,6 +112,10 @@ struct qede_dev {
 	u32				dp_module;
 	u8				dp_level;
 
+	u32 flags;
+#define QEDE_FLAG_IS_VF	BIT(0)
+#define IS_VF(edev)	(!!((edev)->flags & QEDE_FLAG_IS_VF))
+
 	const struct qed_eth_ops	*ops;
 
 	struct qed_dev_eth_info	dev_info;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 0d04f16..1bc7535 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -151,6 +151,8 @@ static void qede_get_strings_stats(struct qede_dev *edev, u8 *buf)
 	int i, j, k;
 
 	for (i = 0, j = 0; i < QEDE_NUM_STATS; i++) {
+		if (IS_VF(edev) && qede_stats_arr[i].pf_only)
+			continue;
 		strcpy(buf + j * ETH_GSTRING_LEN,
 		       qede_stats_arr[i].string);
 		j++;
@@ -194,8 +196,11 @@ static void qede_get_ethtool_stats(struct net_device *dev,
 
 	mutex_lock(&edev->qede_lock);
 
-	for (sidx = 0; sidx < QEDE_NUM_STATS; sidx++)
+	for (sidx = 0; sidx < QEDE_NUM_STATS; sidx++) {
+		if (IS_VF(edev) && qede_stats_arr[sidx].pf_only)
+			continue;
 		buf[cnt++] = QEDE_STATS_DATA(edev, sidx);
+	}
 
 	for (sidx = 0; sidx < QEDE_NUM_RQSTATS; sidx++) {
 		buf[cnt] = 0;
@@ -214,6 +219,13 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 
 	switch (stringset) {
 	case ETH_SS_STATS:
+		if (IS_VF(edev)) {
+			int i;
+
+			for (i = 0; i < QEDE_NUM_STATS; i++)
+				if (qede_stats_arr[i].pf_only)
+					num_stats--;
+		}
 		return num_stats + QEDE_NUM_RQSTATS;
 	case ETH_SS_PRIV_FLAGS:
 		return QEDE_PRI_FLAG_LEN;
@@ -1142,7 +1154,34 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.self_test = qede_self_test,
 };
 
+static const struct ethtool_ops qede_vf_ethtool_ops = {
+	.get_settings = qede_get_settings,
+	.get_drvinfo = qede_get_drvinfo,
+	.get_msglevel = qede_get_msglevel,
+	.set_msglevel = qede_set_msglevel,
+	.get_link = qede_get_link,
+	.get_ringparam = qede_get_ringparam,
+	.set_ringparam = qede_set_ringparam,
+	.get_strings = qede_get_strings,
+	.get_ethtool_stats = qede_get_ethtool_stats,
+	.get_priv_flags = qede_get_priv_flags,
+	.get_sset_count = qede_get_sset_count,
+	.get_rxnfc = qede_get_rxnfc,
+	.set_rxnfc = qede_set_rxnfc,
+	.get_rxfh_indir_size = qede_get_rxfh_indir_size,
+	.get_rxfh_key_size = qede_get_rxfh_key_size,
+	.get_rxfh = qede_get_rxfh,
+	.set_rxfh = qede_set_rxfh,
+	.get_channels = qede_get_channels,
+	.set_channels = qede_set_channels,
+};
+
 void qede_set_ethtool_ops(struct net_device *dev)
 {
-	dev->ethtool_ops = &qede_ethtool_ops;
+	struct qede_dev *edev = netdev_priv(dev);
+
+	if (IS_VF(edev))
+		dev->ethtool_ops = &qede_vf_ethtool_ops;
+	else
+		dev->ethtool_ops = &qede_ethtool_ops;
 }
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 04b15ad..57e3426 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -63,6 +63,7 @@ static const struct qed_eth_ops *qed_ops;
 #define CHIP_NUM_57980S_100		0x1644
 #define CHIP_NUM_57980S_50		0x1654
 #define CHIP_NUM_57980S_25		0x1656
+#define CHIP_NUM_57980S_IOV		0x1664
 
 #ifndef PCI_DEVICE_ID_NX2_57980E
 #define PCI_DEVICE_ID_57980S_40		CHIP_NUM_57980S_40
@@ -71,15 +72,22 @@ static const struct qed_eth_ops *qed_ops;
 #define PCI_DEVICE_ID_57980S_100	CHIP_NUM_57980S_100
 #define PCI_DEVICE_ID_57980S_50		CHIP_NUM_57980S_50
 #define PCI_DEVICE_ID_57980S_25		CHIP_NUM_57980S_25
+#define PCI_DEVICE_ID_57980S_IOV	CHIP_NUM_57980S_IOV
 #endif
 
+enum qede_pci_private {
+	QEDE_PRIVATE_PF,
+	QEDE_PRIVATE_VF
+};
+
 static const struct pci_device_id qede_pci_tbl[] = {
-	{ PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_40), 0 },
-	{ PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_10), 0 },
-	{ PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_MF), 0 },
-	{ PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_100), 0 },
-	{ PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_50), 0 },
-	{ PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_25), 0 },
+	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_40), QEDE_PRIVATE_PF},
+	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_10), QEDE_PRIVATE_PF},
+	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_MF), QEDE_PRIVATE_PF},
+	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_100), QEDE_PRIVATE_PF},
+	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_50), QEDE_PRIVATE_PF},
+	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_25), QEDE_PRIVATE_PF},
+	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_IOV), QEDE_PRIVATE_VF},
 	{ 0 }
 };
 
@@ -94,11 +102,25 @@ static int qede_alloc_rx_buffer(struct qede_dev *edev,
 				struct qede_rx_queue *rxq);
 static void qede_link_update(void *dev, struct qed_link_output *link);
 
+#ifdef CONFIG_QED_SRIOV
+static int qede_sriov_configure(struct pci_dev *pdev, int num_vfs_param)
+{
+	struct qede_dev *edev = netdev_priv(pci_get_drvdata(pdev));
+
+	DP_VERBOSE(edev, QED_MSG_IOV, "Requested %d VFs\n", num_vfs_param);
+
+	return edev->ops->iov->configure(edev->cdev, num_vfs_param);
+}
+#endif
+
 static struct pci_driver qede_pci_driver = {
 	.name = "qede",
 	.id_table = qede_pci_tbl,
 	.probe = qede_probe,
 	.remove = qede_remove,
+#ifdef CONFIG_QED_SRIOV
+	.sriov_configure = qede_sriov_configure,
+#endif
 };
 
 static struct qed_eth_cb_ops qede_ll_ops = {
@@ -2336,6 +2358,9 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 		goto err2;
 	}
 
+	if (is_vf)
+		edev->flags |= QEDE_FLAG_IS_VF;
+
 	qede_init_ndev(edev);
 
 	rc = register_netdev(edev->ndev);
@@ -2367,12 +2392,24 @@ err0:
 
 static int qede_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
+	bool is_vf = false;
 	u32 dp_module = 0;
 	u8 dp_level = 0;
 
+	switch ((enum qede_pci_private)id->driver_data) {
+	case QEDE_PRIVATE_VF:
+		if (debug & QED_LOG_VERBOSE_MASK)
+			dev_err(&pdev->dev, "Probing a VF\n");
+		is_vf = true;
+		break;
+	default:
+		if (debug & QED_LOG_VERBOSE_MASK)
+			dev_err(&pdev->dev, "Probing a PF\n");
+	}
+
 	qede_config_debug(debug, &dp_module, &dp_level);
 
-	return __qede_probe(pdev, dp_module, dp_level, false,
+	return __qede_probe(pdev, dp_module, dp_level, is_vf,
 			    QEDE_PROBE_NORMAL);
 }
 
@@ -3069,6 +3106,7 @@ static int qede_start_queues(struct qede_dev *edev)
 	struct qed_dev *cdev = edev->cdev;
 	struct qed_update_vport_params vport_update_params;
 	struct qed_queue_start_common_params q_params;
+	struct qed_dev_info *qed_info = &edev->dev_info.common;
 	struct qed_start_vport_params start = {0};
 	bool reset_rss_indir = false;
 
-- 
1.9.3
