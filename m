From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 2/7] liquidio CN23XX: VF link status
Date: Wed, 7 Dec 2016 08:54:32 -0800
Message-ID: <1481129677-10586-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0084.outbound.protection.outlook.com ([104.47.37.84]:43712
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932685AbcLGQy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 11:54:59 -0500
In-Reply-To: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF link status related changes.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 249 +++++++++++++++++++++
 1 file changed, 249 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index f05a7c3..07e4864 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -163,6 +163,186 @@ static void ifstate_reset(struct lio *lio, int state_flag)
 	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) & ~(state_flag)));
 }
 
+/**
+ * \brief Stop Tx queues
+ * @param netdev network device
+ */
+static void txqs_stop(struct net_device *netdev)
+{
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++)
+			netif_stop_subqueue(netdev, i);
+	} else {
+		netif_stop_queue(netdev);
+	}
+}
+
+/**
+ * \brief Start Tx queues
+ * @param netdev network device
+ */
+static void txqs_start(struct net_device *netdev)
+{
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++)
+			netif_start_subqueue(netdev, i);
+	} else {
+		netif_start_queue(netdev);
+	}
+}
+
+/**
+ * \brief Wake Tx queues
+ * @param netdev network device
+ */
+static void txqs_wake(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++) {
+			int qno = lio->linfo.txpciq[i % (lio->linfo.num_txpciq)]
+				      .s.q_no;
+			if (__netif_subqueue_stopped(netdev, i)) {
+				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, qno,
+							  tx_restart, 1);
+				netif_wake_subqueue(netdev, i);
+			}
+		}
+	} else {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, lio->txq,
+					  tx_restart, 1);
+		netif_wake_queue(netdev);
+	}
+}
+
+/**
+ * \brief Start Tx queue
+ * @param netdev network device
+ */
+static void start_txq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	if (lio->linfo.link.s.link_up) {
+		txqs_start(netdev);
+		return;
+	}
+}
+
+/**
+ * \brief Print link information
+ * @param netdev network device
+ */
+static void print_link_info(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED) {
+		struct oct_link_info *linfo = &lio->linfo;
+
+		if (linfo->link.s.link_up) {
+			netif_info(lio, link, lio->netdev, "%d Mbps %s Duplex UP\n",
+				   linfo->link.s.speed,
+				   (linfo->link.s.duplex) ? "Full" : "Half");
+		} else {
+			netif_info(lio, link, lio->netdev, "Link Down\n");
+		}
+	}
+}
+
+/**
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
+static int setup_link_status_change_wq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	lio->link_status_wq.wq = alloc_workqueue("link-status",
+						 WQ_MEM_RECLAIM, 0);
+	if (!lio->link_status_wq.wq) {
+		dev_err(&oct->pci_dev->dev, "unable to create cavium link status wq\n");
+		return -1;
+	}
+	INIT_DELAYED_WORK(&lio->link_status_wq.wk.work,
+			  octnet_link_status_change);
+	lio->link_status_wq.wk.ctxptr = lio;
+
+	return 0;
+}
+
+static void cleanup_link_status_change_wq(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	if (lio->link_status_wq.wq) {
+		cancel_delayed_work_sync(&lio->link_status_wq.wk.work);
+		destroy_workqueue(lio->link_status_wq.wq);
+	}
+}
+
+/**
+ * \brief Update link status
+ * @param netdev network device
+ * @param ls link status structure
+ *
+ * Called on receipt of a link status response from the core application to
+ * update each interface's link status.
+ */
+static void update_link_status(struct net_device *netdev,
+			       union oct_link_status *ls)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	if ((lio->intf_open) && (lio->linfo.link.u64 != ls->u64)) {
+		lio->linfo.link.u64 = ls->u64;
+
+		print_link_info(netdev);
+		lio->link_changes++;
+
+		if (lio->linfo.link.s.link_up) {
+			netif_carrier_on(netdev);
+			txqs_wake(netdev);
+		} else {
+			netif_carrier_off(netdev);
+			txqs_stop(netdev);
+		}
+
+		if (lio->linfo.link.s.mtu < netdev->mtu) {
+			dev_warn(&oct->pci_dev->dev,
+				 "PF has changed the MTU for gmx port. Reducing the mtu from %d to %d\n",
+				 netdev->mtu, lio->linfo.link.s.mtu);
+			lio->mtu = lio->linfo.link.s.mtu;
+			netdev->mtu = lio->linfo.link.s.mtu;
+			queue_delayed_work(lio->link_status_wq.wq,
+					   &lio->link_status_wq.wk.work, 0);
+		}
+	}
+}
+
 static
 int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
 {
@@ -499,6 +679,8 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
+	cleanup_link_status_change_wq(netdev);
+
 	free_netdev(netdev);
 
 	oct->props[ifidx].gmxport = -1;
@@ -635,6 +817,28 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 }
 
 /**
+ * \brief Net device open for LiquidIO
+ * @param netdev network device
+ */
+static int liquidio_open(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	ifstate_set(lio, LIO_IFSTATE_RUNNING);
+
+	/* Ready for link status updates */
+	lio->intf_open = 1;
+
+	netif_info(lio, ifup, lio->netdev, "Interface Open, ready for traffic\n");
+	start_txq(netdev);
+
+	dev_info(&oct->pci_dev->dev, "%s interface is opened\n", netdev->name);
+
+	return 0;
+}
+
+/**
  * \brief Net device stop for LiquidIO
  * @param netdev network device
  */
@@ -653,6 +857,8 @@ static int liquidio_stop(struct net_device *netdev)
 
 	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
 
+	txqs_stop(netdev);
+
 	dev_info(&oct->pci_dev->dev, "%s interface is stopped\n", netdev->name);
 
 	return 0;
@@ -758,11 +964,47 @@ static int liquidio_set_features(struct net_device *netdev,
 }
 
 static const struct net_device_ops lionetdevops = {
+	.ndo_open		= liquidio_open,
+	.ndo_stop		= liquidio_stop,
 	.ndo_fix_features	= liquidio_fix_features,
 	.ndo_set_features	= liquidio_set_features,
 	.ndo_select_queue	= select_q,
 };
 
+static int lio_nic_info(struct octeon_recv_info *recv_info, void *buf)
+{
+	struct octeon_device *oct = (struct octeon_device *)buf;
+	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
+	union oct_link_status *ls;
+	int gmxport = 0;
+	int i;
+
+	if (recv_pkt->buffer_size[0] != sizeof(*ls)) {
+		dev_err(&oct->pci_dev->dev, "Malformed NIC_INFO, len=%d, ifidx=%d\n",
+			recv_pkt->buffer_size[0],
+			recv_pkt->rh.r_nic_info.gmxport);
+		goto nic_info_err;
+	}
+
+	gmxport = recv_pkt->rh.r_nic_info.gmxport;
+	ls = (union oct_link_status *)get_rbd(recv_pkt->buffer_ptr[0]);
+
+	octeon_swap_8B_data((u64 *)ls, (sizeof(union oct_link_status)) >> 3);
+
+	for (i = 0; i < oct->ifcount; i++) {
+		if (oct->props[i].gmxport == gmxport) {
+			update_link_status(oct->props[i].netdev, ls);
+			break;
+		}
+	}
+
+nic_info_err:
+	for (i = 0; i < recv_pkt->buffer_count; i++)
+		recv_buffer_free(recv_pkt->buffer_ptr[i]);
+	octeon_free_recv_info(recv_info);
+	return 0;
+}
+
 /**
  * \brief Setup network interfaces
  * @param octeon_dev  octeon device
@@ -788,6 +1030,10 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 	ifidx_or_pfnum = octeon_dev->pf_num;
 
+	/* This is to handle link status changes */
+	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC, OPCODE_NIC_INFO,
+				    lio_nic_info, octeon_dev);
+
 	for (i = 0; i < octeon_dev->ifcount; i++) {
 		resp_size = sizeof(struct liquidio_if_cfg_resp);
 		ctx_size = sizeof(struct liquidio_if_cfg_context);
@@ -946,6 +1192,9 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE,
 					     0);
 
+		if (setup_link_status_change_wq(netdev))
+			goto setup_nic_dev_fail;
+
 		/* Register the network device with the OS */
 		if (register_netdev(netdev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "Device registration failed\n");
-- 
1.8.3.1
