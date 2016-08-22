From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 11/18] liquidio: link and control commands
Date: Sun, 21 Aug 2016 17:12:38 -0700
Message-ID: <1471824765-26473-12-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bn3nam01on0063.outbound.protection.outlook.com ([104.47.33.63]:26776
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753360AbcHVA3o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:29:44 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds work queue support for link status and
control commands.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  5 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 70 ++++++++++++++++++++--
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  4 ++
 3 files changed, 71 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 809179c..5fb444d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -156,10 +156,9 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 		dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
 			 netdev->name, netdev->mtu,
 			 nctrl->ncmd.s.param1);
-		rtnl_lock();
 		netdev->mtu = nctrl->ncmd.s.param1;
-		call_netdevice_notifiers(NETDEV_CHANGEMTU, netdev);
-		rtnl_unlock();
+		queue_delayed_work(lio->link_status_wq.wq,
+				   &lio->link_status_wq.wk.work, 0);
 		break;
 
 	case OCTNET_CMD_GPIO_ACCESS:
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index c33c5a1..1bdaa2d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -859,6 +859,48 @@ static void print_link_info(struct net_device *netdev)
 }
 
 /**
+ * \brief Routine to notify MTU change
+ * @param work work_struct data structure
+ */
+static void octnet_link_status_change(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct lio *lio = (struct lio *)wk->ctxptr;
+
+	rtnl_lock();
+	call_netdevice_notifiers(NETDEV_CHANGEMTU, lio->netdev);
+	rtnl_unlock();
+}
+
+/**
+ * \brief Sets up the mtu status change work
+ * @param netdev network device
+ */
+static inline void setup_link_status_change_wq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	lio->link_status_wq.wq = alloc_workqueue("link-status",
+						 WQ_MEM_RECLAIM, 0);
+	if (!lio->link_status_wq.wq) {
+		dev_err(&oct->pci_dev->dev, "unable to create cavium link status wq\n");
+		return;
+	}
+	INIT_DELAYED_WORK(&lio->link_status_wq.wk.work,
+			  octnet_link_status_change);
+	lio->link_status_wq.wk.ctxptr = lio;
+}
+
+static inline void cleanup_link_status_change_wq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	cancel_delayed_work_sync(&lio->link_status_wq.wk.work);
+	destroy_workqueue(lio->link_status_wq.wq);
+}
+
+/**
  * \brief Update link status
  * @param netdev network device
  * @param ls link status structure
@@ -1385,11 +1427,16 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 			napi_disable(napi);
 
 		oct->props[lio->ifidx].napi_enabled = 0;
+
+		if (OCTEON_CN23XX_PF(oct))
+			oct->droq[0]->ops.poll_mode = 0;
 	}
 
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
+	cleanup_link_status_change_wq(netdev);
+
 	delete_glists(lio);
 
 	free_netdev(netdev);
@@ -2267,6 +2314,14 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 		octeon_register_droq_ops(octeon_dev, q_no, &droq_ops);
 	}
 
+	if (OCTEON_CN23XX_PF(octeon_dev)) {
+		/* 23XX PF can receive control messages (via the first PF-owned
+		 * droq) from the firmware even if the ethX interface is down,
+		 * so that's why poll_mode must be off for the first droq.
+		 */
+		octeon_dev->droq[0]->ops.poll_mode = 0;
+	}
+
 	/* set up IQs. */
 	for (q = 0; q < lio->linfo.num_txpciq; q++) {
 		num_tx_descs = CFG_GET_NUM_TX_DESCS_NIC_IF(octeon_get_conf
@@ -2348,12 +2403,20 @@ static int liquidio_open(struct net_device *netdev)
 			napi_enable(napi);
 
 		oct->props[lio->ifidx].napi_enabled = 1;
+
+		if (OCTEON_CN23XX_PF(oct))
+			oct->droq[0]->ops.poll_mode = 1;
 	}
 
 	oct_ptp_open(netdev);
 
 	ifstate_set(lio, LIO_IFSTATE_RUNNING);
 
+	/* Ready for link status updates */
+	lio->intf_open = 1;
+
+	netif_info(lio, ifup, lio->netdev, "Interface Open, ready for traffic\n");
+
 	if (OCTEON_CN23XX_PF(oct)) {
 		if (!oct->msix_on)
 			setup_tx_poll_fn(netdev);
@@ -2363,14 +2426,9 @@ static int liquidio_open(struct net_device *netdev)
 
 	start_txq(netdev);
 
-	netif_info(lio, ifup, lio->netdev, "Interface Open, ready for traffic\n");
-
 	/* tell Octeon to start forwarding packets to host */
 	send_rx_ctrl_cmd(lio, 1);
 
-	/* Ready for link status updates */
-	lio->intf_open = 1;
-
 	dev_info(&oct->pci_dev->dev, "%s interface is opened\n",
 		 netdev->name);
 
@@ -3663,6 +3721,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			liquidio_set_feature(netdev,
 					     OCTNET_CMD_VERBOSE_ENABLE, 0);
 
+		setup_link_status_change_wq(netdev);
+
 		/* Register the network device with the OS */
 		if (register_netdev(netdev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "Device registration failed\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 7cfbdf9..d3b68d8 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -122,6 +122,10 @@ struct lio {
 
 	/* work queue for  txq status */
 	struct cavium_wq	txq_status_wq;
+
+	/* work queue for  link status */
+	struct cavium_wq	link_status_wq;
+
 };
 
 #define LIO_SIZE         (sizeof(struct lio))
-- 
1.8.3.1
