From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [RFC v2 net-next 08/10] qede: Add support for link
Date: Thu, 17 Sep 2015 17:23:57 +0300
Message-ID: <1442499839-22762-9-git-send-email-Yuval.Mintz@qlogic.com>
References: <1442499839-22762-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54635 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751918AbbIQOZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 10:25:12 -0400
Received: from pps.filterd (m0085408.ppops.net [127.0.0.1])
	by mx0b-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t8HEKu7N026436
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 07:25:09 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0b-0016ce01.pphosted.com with ESMTP id 1wvk1nre5w-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 07:25:09 -0700
In-Reply-To: <1442499839-22762-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

This adds basic link functionality to qede - driver still doesn't provide
users with an API to change any link property, but it does request qed to
initialize the link using default configuration, and registers a callback
that allows it to get link notifications.

This patch adds the ability of the driver to set the carrier as active and
to enable traffic as a result of async. link notifications.
Following this patch, driver should be capable of running traffic.

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 47 ++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 7b3c3d8..8cb1bb5 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -87,6 +87,7 @@ static int qede_probe(struct pci_dev *pdev, const struct pci_device_id *id);
 static void qede_remove(struct pci_dev *pdev);
 static int qede_alloc_rx_buffer(struct qede_dev *edev,
 				struct qede_rx_queue *rxq);
+static void qede_link_update(void *dev, struct qed_link_output *link);
 
 static struct pci_driver qede_pci_driver = {
 	.name = "qede",
@@ -95,6 +96,12 @@ static struct pci_driver qede_pci_driver = {
 	.remove = qede_remove,
 };
 
+static struct qed_eth_cb_ops qede_ll_ops = {
+	{
+		.link_update = qede_link_update,
+	},
+};
+
 static int qede_netdev_event(struct notifier_block *this, unsigned long event,
 			     void *ptr)
 {
@@ -1304,6 +1311,8 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	edev->ops->common->set_id(cdev, edev->ndev->name, DRV_MODULE_VERSION);
 
+	edev->ops->register_ops(cdev, &qede_ll_ops, edev);
+
 	INIT_DELAYED_WORK(&edev->sp_task, qede_sp_task);
 	mutex_init(&edev->qede_lock);
 
@@ -2088,6 +2097,7 @@ enum qede_unload_mode {
 
 static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode)
 {
+	struct qed_link_params link_params;
 	int rc;
 
 	DP_INFO(edev, "Starting qede unload\n");
@@ -2099,6 +2109,10 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode)
 	netif_tx_disable(edev->ndev);
 	netif_carrier_off(edev->ndev);
 
+	/* Reset the link */
+	memset(&link_params, 0, sizeof(link_params));
+	link_params.link_up = false;
+	edev->ops->common->set_link(edev->cdev, &link_params);
 	rc = qede_stop_queues(edev);
 	if (rc) {
 		qede_sync_free_irqs(edev);
@@ -2129,6 +2143,8 @@ enum qede_load_mode {
 
 static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 {
+	struct qed_link_params link_params;
+	struct qed_link_output link_output;
 	int			rc;
 
 	DP_INFO(edev, "Starting qede load\n");
@@ -2172,6 +2188,17 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	mutex_lock(&edev->qede_lock);
 	edev->state = QEDE_STATE_OPEN;
 	mutex_unlock(&edev->qede_lock);
+
+	/* Ask for link-up using current configuration */
+	memset(&link_params, 0, sizeof(link_params));
+	link_params.link_up = true;
+	edev->ops->common->set_link(edev->cdev, &link_params);
+
+	/* Query whether link is already-up */
+	memset(&link_output, 0, sizeof(link_output));
+	edev->ops->common->get_link(edev->cdev, &link_output);
+	qede_link_update(edev, &link_output);
+
 	DP_INFO(edev, "Ending successfully qede load\n");
 
 	return 0;
@@ -2217,6 +2244,26 @@ static int qede_close(struct net_device *ndev)
 	return 0;
 }
 
+static void qede_link_update(void *dev, struct qed_link_output *link)
+{
+	struct qede_dev *edev = dev;
+
+	if (!netif_running(edev->ndev)) {
+		DP_VERBOSE(edev, NETIF_MSG_LINK, "Interface is not running\n");
+		return;
+	}
+
+	if (link->link_up) {
+		DP_NOTICE(edev, "Link is up\n");
+		netif_tx_start_all_queues(edev->ndev);
+		netif_carrier_on(edev->ndev);
+	} else {
+		DP_NOTICE(edev, "Link is down\n");
+		netif_tx_disable(edev->ndev);
+		netif_carrier_off(edev->ndev);
+	}
+}
+
 static int qede_set_mac_addr(struct net_device *ndev, void *p)
 {
 	struct qede_dev *edev = netdev_priv(ndev);
-- 
1.9.3
