From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v8 06/10] qede: classification configuration
Date: Mon, 26 Oct 2015 11:02:30 +0200
Message-ID: <1445850154-19322-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1445850154-19322-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:31151 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753499AbbJZJDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 05:03:31 -0400
Received: from pps.filterd (m0045602.ppops.net [127.0.0.1])
	by mx0a-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9Q8r0qn003753
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 02:03:31 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0a-0016ce01.pphosted.com with ESMTP id 1xr94wt1x5-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 02:03:30 -0700
In-Reply-To: <1445850154-19322-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

Add the ability to configure basic classification in driver by
implementing ndo_set_mac_address() and ndo_set_rx_mode().

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |  10 ++
 drivers/net/ethernet/qlogic/qede/qede_main.c | 241 +++++++++++++++++++++++++++
 2 files changed, 251 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 424ef4a..7947942 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -87,6 +87,9 @@ struct qede_dev {
 	struct qed_update_vport_rss_params	rss_params;
 	u16			q_num_rx_buffers; /* Must be a power of two */
 	u16			q_num_tx_buffers; /* Must be a power of two */
+
+	struct delayed_work		sp_task;
+	unsigned long			sp_flags;
 };
 
 enum QEDE_STATE {
@@ -184,6 +187,13 @@ struct qede_fastpath {
 
 #define QEDE_CSUM_ERROR			BIT(0)
 #define QEDE_CSUM_UNNECESSARY		BIT(1)
+
+#define QEDE_SP_RX_MODE		1
+
+union qede_reload_args {
+	u16 mtu;
+};
+
 #define RX_RING_SIZE_POW	13
 #define RX_RING_SIZE		BIT(RX_RING_SIZE_POW)
 #define NUM_RX_BDS_MAX		(RX_RING_SIZE - 1)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index daba118..0351204 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1030,10 +1030,31 @@ static irqreturn_t qede_msix_fp_int(int irq, void *fp_cookie)
 
 static int qede_open(struct net_device *ndev);
 static int qede_close(struct net_device *ndev);
+static int qede_set_mac_addr(struct net_device *ndev, void *p);
+static void qede_set_rx_mode(struct net_device *ndev);
+static void qede_config_rx_mode(struct net_device *ndev);
+
+static int qede_set_ucast_rx_mac(struct qede_dev *edev,
+				 enum qed_filter_xcast_params_type opcode,
+				 unsigned char mac[ETH_ALEN])
+{
+	struct qed_filter_params filter_cmd;
+
+	memset(&filter_cmd, 0, sizeof(filter_cmd));
+	filter_cmd.type = QED_FILTER_TYPE_UCAST;
+	filter_cmd.filter.ucast.type = opcode;
+	filter_cmd.filter.ucast.mac_valid = 1;
+	ether_addr_copy(filter_cmd.filter.ucast.mac, mac);
+
+	return edev->ops->filter_config(edev->cdev, &filter_cmd);
+}
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
 	.ndo_start_xmit = qede_start_xmit,
+	.ndo_set_rx_mode = qede_set_rx_mode,
+	.ndo_set_mac_address = qede_set_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 };
 
@@ -1198,6 +1219,20 @@ err:
 	return -ENOMEM;
 }
 
+static void qede_sp_task(struct work_struct *work)
+{
+	struct qede_dev *edev = container_of(work, struct qede_dev,
+					     sp_task.work);
+	mutex_lock(&edev->qede_lock);
+
+	if (edev->state == QEDE_STATE_OPEN) {
+		if (test_and_clear_bit(QEDE_SP_RX_MODE, &edev->sp_flags))
+			qede_config_rx_mode(edev->ndev);
+	}
+
+	mutex_unlock(&edev->qede_lock);
+}
+
 static void qede_update_pf_params(struct qed_dev *cdev)
 {
 	struct qed_pf_params pf_params;
@@ -1269,6 +1304,9 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	edev->ops->common->set_id(cdev, edev->ndev->name, DRV_MODULE_VERSION);
 
+	INIT_DELAYED_WORK(&edev->sp_task, qede_sp_task);
+	mutex_init(&edev->qede_lock);
+
 	DP_INFO(edev, "Ending successfully qede probe\n");
 
 	return 0;
@@ -1306,6 +1344,7 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 
 	DP_INFO(edev, "Starting qede_remove\n");
 
+	cancel_delayed_work_sync(&edev->sp_task);
 	unregister_netdev(ndev);
 
 	edev->ops->common->set_power_state(cdev, PCI_D0);
@@ -2036,6 +2075,24 @@ static int qede_start_queues(struct qede_dev *edev)
 	return 0;
 }
 
+static int qede_set_mcast_rx_mac(struct qede_dev *edev,
+				 enum qed_filter_xcast_params_type opcode,
+				 unsigned char *mac, int num_macs)
+{
+	struct qed_filter_params filter_cmd;
+	int i;
+
+	memset(&filter_cmd, 0, sizeof(filter_cmd));
+	filter_cmd.type = QED_FILTER_TYPE_MCAST;
+	filter_cmd.filter.mcast.type = opcode;
+	filter_cmd.filter.mcast.num = num_macs;
+
+	for (i = 0; i < num_macs; i++, mac += ETH_ALEN)
+		ether_addr_copy(filter_cmd.filter.mcast.mac[i], mac);
+
+	return edev->ops->filter_config(edev->cdev, &filter_cmd);
+}
+
 enum qede_unload_mode {
 	QEDE_UNLOAD_NORMAL,
 };
@@ -2046,6 +2103,9 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode)
 
 	DP_INFO(edev, "Starting qede unload\n");
 
+	mutex_lock(&edev->qede_lock);
+	edev->state = QEDE_STATE_CLOSED;
+
 	/* Close OS Tx */
 	netif_tx_disable(edev->ndev);
 	netif_carrier_off(edev->ndev);
@@ -2120,6 +2180,9 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	/* Add primary mac and set Rx filters */
 	ether_addr_copy(edev->primary_mac, edev->ndev->dev_addr);
 
+	mutex_lock(&edev->qede_lock);
+	edev->state = QEDE_STATE_OPEN;
+	mutex_unlock(&edev->qede_lock);
 	DP_INFO(edev, "Ending successfully qede load\n");
 
 	return 0;
@@ -2159,3 +2222,181 @@ static int qede_close(struct net_device *ndev)
 
 	return 0;
 }
+
+static int qede_set_mac_addr(struct net_device *ndev, void *p)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+	struct sockaddr *addr = p;
+	int rc;
+
+	ASSERT_RTNL(); /* @@@TBD To be removed */
+
+	DP_INFO(edev, "Set_mac_addr called\n");
+
+	if (!is_valid_ether_addr(addr->sa_data)) {
+		DP_NOTICE(edev, "The MAC address is not valid\n");
+		return -EFAULT;
+	}
+
+	ether_addr_copy(ndev->dev_addr, addr->sa_data);
+
+	if (!netif_running(ndev))  {
+		DP_NOTICE(edev, "The device is currently down\n");
+		return 0;
+	}
+
+	/* Remove the previous primary mac */
+	rc = qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_DEL,
+				   edev->primary_mac);
+	if (rc)
+		return rc;
+
+	/* Add MAC filter according to the new unicast HW MAC address */
+	ether_addr_copy(edev->primary_mac, ndev->dev_addr);
+	return qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_ADD,
+				      edev->primary_mac);
+}
+
+static int
+qede_configure_mcast_filtering(struct net_device *ndev,
+			       enum qed_filter_rx_mode_type *accept_flags)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+	unsigned char *mc_macs, *temp;
+	struct netdev_hw_addr *ha;
+	int rc = 0, mc_count;
+	size_t size;
+
+	size = 64 * ETH_ALEN;
+
+	mc_macs = kzalloc(size, GFP_KERNEL);
+	if (!mc_macs) {
+		DP_NOTICE(edev,
+			  "Failed to allocate memory for multicast MACs\n");
+		rc = -ENOMEM;
+		goto exit;
+	}
+
+	temp = mc_macs;
+
+	/* Remove all previously configured MAC filters */
+	rc = qede_set_mcast_rx_mac(edev, QED_FILTER_XCAST_TYPE_DEL,
+				   mc_macs, 1);
+	if (rc)
+		goto exit;
+
+	netif_addr_lock_bh(ndev);
+
+	mc_count = netdev_mc_count(ndev);
+	if (mc_count < 64) {
+		netdev_for_each_mc_addr(ha, ndev) {
+			ether_addr_copy(temp, ha->addr);
+			temp += ETH_ALEN;
+		}
+	}
+
+	netif_addr_unlock_bh(ndev);
+
+	/* Check for all multicast @@@TBD resource allocation */
+	if ((ndev->flags & IFF_ALLMULTI) ||
+	    (mc_count > 64)) {
+		if (*accept_flags == QED_FILTER_RX_MODE_TYPE_REGULAR)
+			*accept_flags = QED_FILTER_RX_MODE_TYPE_MULTI_PROMISC;
+	} else {
+		/* Add all multicast MAC filters */
+		rc = qede_set_mcast_rx_mac(edev, QED_FILTER_XCAST_TYPE_ADD,
+					   mc_macs, mc_count);
+	}
+
+exit:
+	kfree(mc_macs);
+	return rc;
+}
+
+static void qede_set_rx_mode(struct net_device *ndev)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	DP_INFO(edev, "qede_set_rx_mode called\n");
+
+	if (edev->state != QEDE_STATE_OPEN) {
+		DP_INFO(edev,
+			"qede_set_rx_mode called while interface is down\n");
+	} else {
+		set_bit(QEDE_SP_RX_MODE, &edev->sp_flags);
+		schedule_delayed_work(&edev->sp_task, 0);
+	}
+}
+
+/* Must be called with qede_lock held */
+static void qede_config_rx_mode(struct net_device *ndev)
+{
+	enum qed_filter_rx_mode_type accept_flags = QED_FILTER_TYPE_UCAST;
+	struct qede_dev *edev = netdev_priv(ndev);
+	struct qed_filter_params rx_mode;
+	unsigned char *uc_macs, *temp;
+	struct netdev_hw_addr *ha;
+	int rc, uc_count;
+	size_t size;
+
+	netif_addr_lock_bh(ndev);
+
+	uc_count = netdev_uc_count(ndev);
+	size = uc_count * ETH_ALEN;
+
+	uc_macs = kzalloc(size, GFP_ATOMIC);
+	if (!uc_macs) {
+		DP_NOTICE(edev, "Failed to allocate memory for unicast MACs\n");
+		netif_addr_unlock_bh(ndev);
+		return;
+	}
+
+	temp = uc_macs;
+	netdev_for_each_uc_addr(ha, ndev) {
+		ether_addr_copy(temp, ha->addr);
+		temp += ETH_ALEN;
+	}
+
+	netif_addr_unlock_bh(ndev);
+
+	/* Configure the struct for the Rx mode */
+	memset(&rx_mode, 0, sizeof(struct qed_filter_params));
+	rx_mode.type = QED_FILTER_TYPE_RX_MODE;
+
+	/* Remove all previous unicast secondary macs and multicast macs
+	 * (configrue / leave the primary mac)
+	 */
+	rc = qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_REPLACE,
+				   edev->primary_mac);
+	if (rc)
+		goto out;
+
+	/* Check for promiscuous */
+	if ((ndev->flags & IFF_PROMISC) ||
+	    (uc_count > 15)) { /* @@@TBD resource allocation - 1 */
+		accept_flags = QED_FILTER_RX_MODE_TYPE_PROMISC;
+	} else {
+		/* Add MAC filters according to the unicast secondary macs */
+		int i;
+
+		temp = uc_macs;
+		for (i = 0; i < uc_count; i++) {
+			rc = qede_set_ucast_rx_mac(edev,
+						   QED_FILTER_XCAST_TYPE_ADD,
+						   temp);
+			if (rc)
+				goto out;
+
+			temp += ETH_ALEN;
+		}
+
+		rc = qede_configure_mcast_filtering(ndev, &accept_flags);
+		if (rc)
+			goto out;
+	}
+
+	rx_mode.filter.accept_flags = accept_flags;
+	edev->ops->filter_config(edev->cdev, &rx_mode);
+out:
+	kfree(uc_macs);
+}
-- 
1.9.3
