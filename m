From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 2/4] liquidio updates and features
Date: Thu, 19 May 2016 11:56:31 -0700
Message-ID: <1463684193-25264-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1463684193-25264-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bl2on0088.outbound.protection.outlook.com ([65.55.169.88]:36126
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753782AbcESVfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 17:35:24 -0400
In-Reply-To: <1463684193-25264-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is second in series of patches for liquidio new features
and updates:

1) Adds support in Napi to handle tx buffers apart from RX traffic.

2) Resolves the order of chip reset while destroying the resources by
postoponing soft reset in destroy resources function until all queues
are removed properly.

3) Handles Release firmware properly upon failure to load firmware
properly.

4) Adds support of vlan offloads.

5) Support for pci command for new chips octeon2(o2) octeon3(o3).

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 370 ++++++++++++++++-----
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 134 ++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   1 +
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |   4 +
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  | 129 +++++--
 5 files changed, 517 insertions(+), 121 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 1a49d77..17d7095 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -698,10 +698,15 @@ static inline void txqs_wake(struct net_device *netdev)
 			int qno = lio->linfo.txpciq[i %
 				(lio->linfo.num_txpciq)].s.q_no;
 
-			if (__netif_subqueue_stopped(netdev, i))
+			if (__netif_subqueue_stopped(netdev, i)) {
+				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, qno,
+							  tx_restart, 1);
 				netif_wake_subqueue(netdev, i);
+			}
 		}
 	} else {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, lio->txq,
+					  tx_restart, 1);
 		netif_wake_queue(netdev);
 	}
 }
@@ -776,6 +781,8 @@ static inline int check_txq_status(struct lio *lio)
 				continue;
 			if (__netif_subqueue_stopped(lio->netdev, q)) {
 				wake_q(lio->netdev, q);
+				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq,
+							  tx_restart, 1);
 				ret_val++;
 			}
 		}
@@ -783,6 +790,8 @@ static inline int check_txq_status(struct lio *lio)
 		if (octnet_iq_is_full(lio->oct_dev, lio->txq))
 			return 0;
 		wake_q(lio->netdev, lio->txq);
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, lio->txq,
+					  tx_restart, 1);
 		ret_val = 1;
 	}
 	return ret_val;
@@ -972,6 +981,42 @@ static inline void update_link_status(struct net_device *netdev,
 	}
 }
 
+/* Runs in interrupt context. */
+static void update_txq_status(struct octeon_device *oct, int iq_num)
+{
+	struct net_device *netdev;
+	struct lio *lio;
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
+
+	/*octeon_update_iq_read_idx(oct, iq);*/
+
+	netdev = oct->props[iq->ifidx].netdev;
+
+	/* This is needed because the first IQ does not have
+	 * a netdev associated with it.
+	 */
+	if (!netdev)
+		return;
+
+	lio = GET_LIO(netdev);
+	if (netif_is_multiqueue(netdev)) {
+		if (__netif_subqueue_stopped(netdev, iq->q_index) &&
+		    lio->linfo.link.s.link_up &&
+		    (!octnet_iq_is_full(oct, iq_num))) {
+			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
+						  tx_restart, 1);
+			netif_wake_subqueue(netdev, iq->q_index);
+		} else {
+			if (!octnet_iq_is_full(oct, lio->txq)) {
+				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev,
+							  lio->txq,
+							  tx_restart, 1);
+				wake_q(netdev, lio->txq);
+			}
+		}
+	}
+}
+
 /**
  * \brief Droq packet processor sceduler
  * @param oct octeon device
@@ -1159,7 +1204,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 			dev_err(&oct->pci_dev->dev, "OQ had pending packets\n");
 
 		/* Disable interrupts  */
-		oct->fn_list.disable_interrupt(oct->chip);
+		oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
 
 		/* Release the interrupt line */
 		free_irq(oct->pci_dev->irq, oct);
@@ -1167,19 +1212,13 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		if (oct->flags & LIO_FLAG_MSI_ENABLED)
 			pci_disable_msi(oct->pci_dev);
 
-		/* Soft reset the octeon device before exiting */
-		oct->fn_list.soft_reset(oct);
-
-		/* Disable the device, releasing the PCI INT */
-		pci_disable_device(oct->pci_dev);
-
 		/* fallthrough */
 	case OCT_DEV_IN_RESET:
 	case OCT_DEV_DROQ_INIT_DONE:
 		/*atomic_set(&oct->status, OCT_DEV_DROQ_INIT_DONE);*/
 		mdelay(100);
-		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-			if (!(oct->io_qmask.oq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.oq & (1ULL << i)))
 				continue;
 			octeon_delete_droq(oct, i);
 		}
@@ -1206,8 +1245,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		/* fallthrough */
 	case OCT_DEV_INSTR_QUEUE_INIT_DONE:
-		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-			if (!(oct->io_qmask.iq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.iq & (1ULL << i)))
 				continue;
 			octeon_delete_instr_queue(oct, i);
 		}
@@ -1219,14 +1258,21 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		/* fallthrough */
 	case OCT_DEV_PCI_MAP_DONE:
+
+		/* Soft reset the octeon device before exiting */
+		oct->fn_list.soft_reset(oct);
+
 		octeon_unmap_pci_barx(oct, 0);
 		octeon_unmap_pci_barx(oct, 1);
 
 		/* fallthrough */
 	case OCT_DEV_BEGIN_STATE:
+		/* Disable the device, releasing the PCI INT */
+		pci_disable_device(oct->pci_dev);
+
 		/* Nothing to be done here either */
 		break;
-	}                       /* end switch(oct->status) */
+	}                       /* end switch (oct->status) */
 
 	tasklet_kill(&oct_priv->droq_tasklet);
 }
@@ -1280,8 +1326,12 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
 		txqs_stop(netdev);
 
-	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
-		napi_disable(napi);
+	if (oct->props[lio->ifidx].napi_enabled == 1) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_disable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 0;
+	}
 
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
@@ -1450,9 +1500,10 @@ static inline int check_txq_state(struct lio *lio, struct sk_buff *skb)
 	if (octnet_iq_is_full(lio->oct_dev, iq))
 		return 0;
 
-	if (__netif_subqueue_stopped(lio->netdev, q))
+	if (__netif_subqueue_stopped(lio->netdev, q)) {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq, tx_restart, 1);
 		wake_q(lio->netdev, q);
-
+	}
 	return 1;
 }
 
@@ -1890,6 +1941,7 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 	struct sk_buff *skb = (struct sk_buff *)skbuff;
 	struct skb_shared_hwtstamps *shhwtstamps;
 	u64 ns;
+	u16 vtag = 0;
 	struct net_device *netdev = (struct net_device *)arg;
 	struct octeon_droq *droq = container_of(param, struct octeon_droq,
 						napi);
@@ -1966,6 +2018,16 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 		else
 			skb->ip_summed = CHECKSUM_NONE;
 
+		/* inbound VLAN tag */
+		if ((netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+		    (rh->r_dh.vlan != 0)) {
+			u16 vid = rh->r_dh.vlan;
+			u16 priority = rh->r_dh.priority;
+
+			vtag = priority << 13 | vid;
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vtag);
+		}
+
 		packet_was_received = napi_gro_receive(napi, skb) != GRO_DROP;
 
 		if (packet_was_received) {
@@ -2020,38 +2082,6 @@ static void liquidio_napi_drv_callback(void *arg)
 }
 
 /**
- * \brief Main NAPI poll function
- * @param droq octeon output queue
- * @param budget maximum number of items to process
- */
-static int liquidio_napi_do_rx(struct octeon_droq *droq, int budget)
-{
-	int work_done;
-	struct lio *lio = GET_LIO(droq->napi.dev);
-	struct octeon_device *oct = lio->oct_dev;
-
-	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
-						 POLL_EVENT_PROCESS_PKTS,
-						 budget);
-	if (work_done < 0) {
-		netif_info(lio, rx_err, lio->netdev,
-			   "Receive work_done < 0, rxq:%d\n", droq->q_no);
-		goto octnet_napi_finish;
-	}
-
-	if (work_done > budget)
-		dev_err(&oct->pci_dev->dev, ">>>> %s work_done: %d budget: %d\n",
-			__func__, work_done, budget);
-
-	return work_done;
-
-octnet_napi_finish:
-	napi_complete(&droq->napi);
-	octeon_process_droq_poll_cmd(oct, droq->q_no, POLL_EVENT_ENABLE_INTR,
-				     0);
-	return 0;
-}
-/**
  * \brief Entry point for NAPI polling
  * @param napi NAPI structure
  * @param budget maximum number of items to process
@@ -2060,35 +2090,57 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct octeon_droq *droq;
 	int work_done;
+	int tx_done = 0, iq_no;
+	struct octeon_instr_queue *iq;
+	struct octeon_device *oct;
 
 	droq = container_of(napi, struct octeon_droq, napi);
+	oct = droq->oct_dev;
+	iq_no = droq->q_no;
+	/* Handle Droq descriptors */
+	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
+						 POLL_EVENT_PROCESS_PKTS,
+						 budget);
 
-	work_done = liquidio_napi_do_rx(droq, budget);
+	/* Flush the instruction queue */
+	iq = oct->instr_queue[iq_no];
+	if (iq) {
+		/* Process iq buffers with in the budget limits */
+		tx_done = octeon_flush_iq(oct, iq, 1, budget);
+		/* Update iq read-index rather than waiting for next interrupt.
+		 * Return back if tx_done is false.
+		 */
+		update_txq_status(oct, iq_no);
+		/*tx_done = (iq->flush_index == iq->octeon_read_index);*/
+	} else {
+		dev_err(&oct->pci_dev->dev, "%s:  iq (%d) num invalid\n",
+			__func__, iq_no);
+	}
 
-	if (work_done < budget) {
+	if ((work_done < budget) && (tx_done)) {
 		napi_complete(napi);
 		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
 					     POLL_EVENT_ENABLE_INTR, 0);
 		return 0;
 	}
 
-	return work_done;
+	return (!tx_done) ? (budget) : (work_done);
 }
 
 /**
  * \brief Setup input and output queues
  * @param octeon_dev octeon device
- * @param net_device Net device
+ * @param ifidx  Interface Index
  *
  * Note: Queues are with respect to the octeon device. Thus
  * an input queue is for egress packets, and output queues
  * are for ingress packets.
  */
 static inline int setup_io_queues(struct octeon_device *octeon_dev,
-				  struct net_device *net_device)
+				  int ifidx)
 {
-	static int first_time = 1;
-	static struct octeon_droq_ops droq_ops;
+	struct octeon_droq_ops droq_ops;
+	struct net_device *netdev;
 	static int cpu_id;
 	static int cpu_id_modulus;
 	struct octeon_droq *droq;
@@ -2097,23 +2149,26 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 	struct lio *lio;
 	int num_tx_descs;
 
-	lio = GET_LIO(net_device);
-	if (first_time) {
-		first_time = 0;
-		memset(&droq_ops, 0, sizeof(struct octeon_droq_ops));
+	netdev = octeon_dev->props[ifidx].netdev;
 
-		droq_ops.fptr = liquidio_push_packet;
+	lio = GET_LIO(netdev);
 
-		droq_ops.poll_mode = 1;
-		droq_ops.napi_fn = liquidio_napi_drv_callback;
-		cpu_id = 0;
-		cpu_id_modulus = num_present_cpus();
-	}
+	memset(&droq_ops, 0, sizeof(struct octeon_droq_ops));
+
+	droq_ops.fptr = liquidio_push_packet;
+	droq_ops.farg = (void *)netdev;
+
+	droq_ops.poll_mode = 1;
+	droq_ops.napi_fn = liquidio_napi_drv_callback;
+	cpu_id = 0;
+	cpu_id_modulus = num_present_cpus();
 
 	/* set up DROQs. */
 	for (q = 0; q < lio->linfo.num_rxpciq; q++) {
-		q_no = lio->linfo.rxpciq[q];
-
+		q_no = lio->linfo.rxpciq[q].s.q_no;
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"setup_io_queues index:%d linfo.rxpciq.s.q_no:%d\n",
+			q, q_no);
 		retval = octeon_setup_droq(octeon_dev, q_no,
 					   CFG_GET_NUM_RX_DESCS_NIC_IF
 						   (octeon_get_conf(octeon_dev),
@@ -2127,10 +2182,13 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 				__func__);
 			return 1;
 		}
-
 		droq = octeon_dev->droq[q_no];
 		napi = &droq->napi;
-		netif_napi_add(net_device, napi, liquidio_napi_poll, 64);
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"netif_napi_add netdev:%llx oct:%llx\n",
+			(u64)netdev,
+			(u64)octeon_dev);
+		netif_napi_add(netdev, napi, liquidio_napi_poll, 64);
 
 		/* designate a CPU for this droq */
 		droq->cpu_id = cpu_id;
@@ -2146,9 +2204,9 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 		num_tx_descs = CFG_GET_NUM_TX_DESCS_NIC_IF(octeon_get_conf
 							   (octeon_dev),
 							   lio->ifidx);
-		retval = octeon_setup_iq(octeon_dev, lio->linfo.txpciq[q],
-					 num_tx_descs,
-					 netdev_get_tx_queue(net_device, q));
+		retval = octeon_setup_iq(octeon_dev, ifidx, q,
+					 lio->linfo.txpciq[q], num_tx_descs,
+					 netdev_get_tx_queue(netdev, q));
 		if (retval) {
 			dev_err(&octeon_dev->pci_dev->dev,
 				" %s : Runtime IQ(TxQ) creation failed.\n",
@@ -2198,6 +2256,15 @@ static inline void setup_tx_poll_fn(struct net_device *netdev)
 			   &lio->txq_status_wq.wk.work, msecs_to_jiffies(1));
 }
 
+static inline void cleanup_tx_poll_fn(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	cancel_delayed_work_sync(&lio->txq_status_wq.wk.work);
+	flush_workqueue(lio->txq_status_wq.wq);
+	destroy_workqueue(lio->txq_status_wq.wq);
+}
+
 /**
  * \brief Net device open for LiquidIO
  * @param netdev network device
@@ -2208,8 +2275,12 @@ static int liquidio_open(struct net_device *netdev)
 	struct octeon_device *oct = lio->oct_dev;
 	struct napi_struct *napi, *n;
 
-	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
-		napi_enable(napi);
+	if (oct->props[lio->ifidx].napi_enabled == 0) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_enable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 1;
+	}
 
 	oct_ptp_open(netdev);
 
@@ -2261,6 +2332,8 @@ static int liquidio_stop(struct net_device *netdev)
 	/* Now it should be safe to tell Octeon that nic interface is down. */
 	send_rx_ctrl_cmd(lio, 0);
 
+	cleanup_tx_poll_fn(netdev);
+
 	if (lio->ptp_clock) {
 		ptp_clock_unregister(lio->ptp_clock);
 		lio->ptp_clock = NULL;
@@ -2277,6 +2350,7 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 	struct net_device *netdev = (struct net_device *)nctrl->netpndev;
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
+	u8 *mac;
 
 	switch (nctrl->ncmd.s.cmd) {
 	case OCTNET_CMD_CHANGE_DEVFLAGS:
@@ -2284,22 +2358,24 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 		break;
 
 	case OCTNET_CMD_CHANGE_MACADDR:
-		/* If command is successful, change the MACADDR. */
-		netif_info(lio, probe, lio->netdev, " MACAddr changed to 0x%llx\n",
-			   CVM_CAST64(nctrl->udd[0]));
-		dev_info(&oct->pci_dev->dev, "%s MACAddr changed to 0x%llx\n",
-			 netdev->name, CVM_CAST64(nctrl->udd[0]));
-		memcpy(netdev->dev_addr, ((u8 *)&nctrl->udd[0]) + 2, ETH_ALEN);
+		mac = ((u8 *)&nctrl->udd[0]) + 2;
+		netif_info(lio, probe, lio->netdev,
+			   "%s %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
+			   "MACAddr changed to", mac[0], mac[1],
+			   mac[2], mac[3], mac[4], mac[5]);
 		break;
 
 	case OCTNET_CMD_CHANGE_MTU:
 		/* If command is successful, change the MTU. */
 		netif_info(lio, probe, lio->netdev, " MTU Changed from %d to %d\n",
-			   netdev->mtu, nctrl->ncmd.s.param2);
+			   netdev->mtu, nctrl->ncmd.s.param1);
 		dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
 			 netdev->name, netdev->mtu,
-			 nctrl->ncmd.s.param2);
-		netdev->mtu = nctrl->ncmd.s.param2;
+			 nctrl->ncmd.s.param1);
+		rtnl_lock();
+		netdev->mtu = nctrl->ncmd.s.param1;
+		call_netdevice_notifiers(NETDEV_CHANGEMTU, netdev);
+		rtnl_unlock();
 		break;
 
 	case OCTNET_CMD_GPIO_ACCESS:
@@ -2307,6 +2383,11 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 
 		break;
 
+	case OCTNET_CMD_ID_ACTIVE:
+		netif_info(lio, probe, lio->netdev, "LED Flashing visual identification\n");
+
+		break;
+
 	case OCTNET_CMD_LRO_ENABLE:
 		dev_info(&oct->pci_dev->dev, "%s LRO Enabled\n", netdev->name);
 		break;
@@ -2325,12 +2406,31 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 			 netdev->name);
 		break;
 
+	case OCTNET_CMD_ENABLE_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter enabled\n",
+			 netdev->name);
+		break;
+
+	case OCTNET_CMD_ADD_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d added\n",
+			 netdev->name, nctrl->ncmd.s.param1);
+		break;
+
+	case OCTNET_CMD_DEL_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d removed\n",
+			 netdev->name, nctrl->ncmd.s.param1);
+		break;
+
 	case OCTNET_CMD_SET_SETTINGS:
 		dev_info(&oct->pci_dev->dev, "%s settings changed\n",
 			 netdev->name);
 
 		break;
 
+	case OCTNET_CMD_SET_FLOW_CTL:
+		netif_info(lio, probe, lio->netdev, "Set RX/TX flow control parameters\n");
+		break;
+
 	default:
 		dev_err(&oct->pci_dev->dev, "%s Unknown cmd %d\n", __func__,
 			nctrl->ncmd.s.cmd);
@@ -2924,6 +3024,13 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (skb_shinfo(skb)->gso_size) {
 		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
 		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
+		stats->tx_gso++;
+	}
+
+	/* HW insert VLAN tag */
+	if (skb_vlan_tag_present(skb)) {
+		irh->priority = skb_vlan_tag_get(skb) >> 13;
+		irh->vlan = skb_vlan_tag_get(skb) & 0xfff;
 	}
 
 	xmit_more = skb->xmit_more;
@@ -2977,6 +3084,61 @@ static void liquidio_tx_timeout(struct net_device *netdev)
 	txqs_wake(netdev);
 }
 
+static int liquidio_vlan_rx_add_vid(struct net_device *netdev,
+				    __be16 proto __attribute__((unused)),
+				    u16 vid)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_ADD_VLAN_FILTER;
+	nctrl.ncmd.s.param1 = vid;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Add VLAN filter failed in core (ret: 0x%x)\n",
+			ret);
+	}
+
+	return ret;
+}
+
+static int liquidio_vlan_rx_kill_vid(struct net_device *netdev,
+				     __be16 proto __attribute__((unused)),
+				     u16 vid)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_DEL_VLAN_FILTER;
+	nctrl.ncmd.s.param1 = vid;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Add VLAN filter failed in core (ret: 0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+
 int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -3068,6 +3230,9 @@ static struct net_device_ops lionetdevops = {
 	.ndo_set_mac_address	= liquidio_set_mac,
 	.ndo_set_rx_mode	= liquidio_set_mcast_list,
 	.ndo_tx_timeout		= liquidio_tx_timeout,
+
+	.ndo_vlan_rx_add_vid    = liquidio_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid   = liquidio_vlan_rx_kill_vid,
 	.ndo_change_mtu		= liquidio_change_mtu,
 	.ndo_do_ioctl		= liquidio_ioctl,
 	.ndo_fix_features	= liquidio_fix_features,
@@ -3330,9 +3495,17 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
 		netdev->vlan_features = lio->dev_capability;
+		/* Add any unchangeable hw features */
+		lio->dev_capability |=  NETIF_F_HW_VLAN_CTAG_FILTER |
+					NETIF_F_HW_VLAN_CTAG_RX |
+					NETIF_F_HW_VLAN_CTAG_TX;
+
 		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
 
 		netdev->hw_features = lio->dev_capability;
+		/*HW_VLAN_RX and HW_VLAN_FILTER is always on*/
+		netdev->hw_features = netdev->hw_features &
+			~NETIF_F_HW_VLAN_CTAG_RX;
 
 		/* Point to the  properties for octeon device to which this
 		 * interface belongs.
@@ -3385,6 +3558,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
 					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
+		liquidio_set_feature(netdev, OCTNET_CMD_ENABLE_VLAN_FILTER, 0);
+
 		if ((debug != -1) && (debug & NETIF_MSG_HW))
 			liquidio_set_feature(netdev,
 					     OCTNET_CMD_VERBOSE_ENABLE, 0);
@@ -3536,6 +3711,7 @@ static void nic_starter(struct work_struct *work)
 static int octeon_device_init(struct octeon_device *octeon_dev)
 {
 	int j, ret;
+	char bootcmd[] = "\n";
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)octeon_dev->priv;
 	atomic_set(&octeon_dev->status, OCT_DEV_BEGIN_STATE);
@@ -3613,6 +3789,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		/* Release any previously allocated queues */
 		for (j = 0; j < octeon_dev->num_oqs; j++)
 			octeon_delete_droq(octeon_dev, j);
+		return 1;
 	}
 
 	atomic_set(&octeon_dev->status, OCT_DEV_DROQ_INIT_DONE);
@@ -3635,10 +3812,11 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	/* Setup the interrupt handler and record the INT SUM register address
 	 */
-	octeon_setup_interrupt(octeon_dev);
+	if (octeon_setup_interrupt(octeon_dev))
+		return 1;
 
 	/* Enable Octeon device interrupts */
-	octeon_dev->fn_list.enable_interrupt(octeon_dev->chip);
+	octeon_dev->fn_list.enable_interrupt(octeon_dev, OCTEON_ALL_INTR);
 
 	/* Enable the input and output queues for this Octeon device */
 	octeon_dev->fn_list.enable_io_queues(octeon_dev);
@@ -3647,19 +3825,24 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
 
-	if (ddr_timeout == 0) {
-		dev_info(&octeon_dev->pci_dev->dev,
-			 "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
-	}
+	if (ddr_timeout == 0)
+		dev_info(&octeon_dev->pci_dev->dev, "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
 
 	schedule_timeout_uninterruptible(HZ * LIO_RESET_SECS);
 
 	/* Wait for the octeon to initialize DDR after the soft-reset. */
+	while (ddr_timeout == 0) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (schedule_timeout(HZ / 10)) {
+			/* user probably pressed Control-C */
+			return 1;
+		}
+	}
 	ret = octeon_wait_for_ddr_init(octeon_dev, &ddr_timeout);
 	if (ret) {
 		dev_err(&octeon_dev->pci_dev->dev,
-			"DDR not initialized. Please confirm that board is configured to boot from Flash, ret: %d\n",
-			ret);
+			"DDR not initialized. Please confirm that board is configured to boot from Flash,ret: %d\n"
+			, ret);
 		return 1;
 	}
 
@@ -3668,6 +3851,9 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		return 1;
 	}
 
+	/* Divert uboot to take commands from host instead. */
+	ret = octeon_console_send_cmd(octeon_dev, bootcmd, 50);
+
 	dev_dbg(&octeon_dev->pci_dev->dev, "Initializing consoles\n");
 	ret = octeon_init_consoles(octeon_dev);
 	if (ret) {
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index e4bee85..a8e8033 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -291,6 +291,138 @@ union octnet_cmd {
 
 #define   OCTNET_CMD_SIZE     (sizeof(union octnet_cmd))
 
+/* Instruction Header (DPI - CN78xx) - for OCTEON-III models */
+struct  octeon_instr_ih3 {
+#ifdef __BIG_ENDIAN_BITFIELD
+
+	/** Reserved3 */
+	u64     reserved3:1;
+
+	/** Gather indicator 1=gather*/
+	u64     gather:1;
+
+	/** Data length OR no. of entries in gather list */
+	u64     dlengsz:14;
+
+	/** Front Data size */
+	u64     fsz:6;
+
+	/** Reserved2 */
+	u64     reserved2:4;
+
+	/** PKI port kind - PKIND */
+	u64     pkind:6;
+
+	/** Reserved1 */
+	u64     reserved1:32;
+
+#else
+	/** Reserved1 */
+	u64     reserved1:32;
+
+	/** PKI port kind - PKIND */
+	u64     pkind:6;
+
+	/** Reserved2 */
+	u64     reserved2:4;
+
+	/** Front Data size */
+	u64     fsz:6;
+
+	/** Data length OR no. of entries in gather list */
+	u64     dlengsz:14;
+
+	/** Gather indicator 1=gather*/
+	u64     gather:1;
+
+	/** Reserved3 */
+	u64     reserved3:1;
+
+#endif
+};
+
+/* Optional PKI Instruction Header(PKI IH) - for OCTEON CN78XX models */
+/** BIG ENDIAN format.   */
+struct  octeon_instr_pki_ih3 {
+#ifdef __BIG_ENDIAN_BITFIELD
+
+	/** Wider bit */
+	u64     w:1;
+
+	/** Raw mode indicator 1 = RAW */
+	u64     raw:1;
+
+	/** Use Tag */
+	u64     utag:1;
+
+	/** Use QPG */
+	u64     uqpg:1;
+
+	/** Reserved2 */
+	u64     reserved2:1;
+
+	/** Parse Mode */
+	u64     pm:3;
+
+	/** Skip Length */
+	u64     sl:8;
+
+	/** Use Tag Type */
+	u64     utt:1;
+
+	/** Tag type */
+	u64     tagtype:2;
+
+	/** Reserved1 */
+	u64     reserved1:2;
+
+	/** QPG Value */
+	u64     qpg:11;
+
+	/** Tag Value */
+	u64     tag:32;
+
+#else
+
+	/** Tag Value */
+	u64     tag:32;
+
+	/** QPG Value */
+	u64     qpg:11;
+
+	/** Reserved1 */
+	u64     reserved1:2;
+
+	/** Tag type */
+	u64     tagtype:2;
+
+	/** Use Tag Type */
+	u64     utt:1;
+
+	/** Skip Length */
+	u64     sl:8;
+
+	/** Parse Mode */
+	u64     pm:3;
+
+	/** Reserved2 */
+	u64     reserved2:1;
+
+	/** Use QPG */
+	u64     uqpg:1;
+
+	/** Use Tag */
+	u64     utag:1;
+
+	/** Raw mode indicator 1 = RAW */
+	u64     raw:1;
+
+	/** Wider bit */
+	u64     w:1;
+#endif
+
+};
+
 /** Instruction Header */
 struct octeon_instr_ih2 {
 #ifdef __BIG_ENDIAN_BITFIELD
@@ -674,6 +806,8 @@ struct oct_link_stats {
 #define VITESSE_PHY_GPIO_DRIVEOFF 0x4
 #define VITESSE_PHY_GPIO_HIGH     0x2
 #define VITESSE_PHY_GPIO_LOW      0x3
+#define LED_IDENTIFICATION_ON     0x1
+#define LED_IDENTIFICATION_OFF    0x0
 
 struct oct_mdio_cmd {
 	u64 op;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index b58b24c..e09fc4c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -268,6 +268,7 @@ struct octdev_props {
 	/* Each interface in the Octeon device has a network
 	 * device pointer (used for OS specific calls).
 	 */
+	int    napi_enabled;
 	int    gmxport;
 	struct net_device *netdev;
 };
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index ce84912..37b6fa28 100644
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
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 6deb0ee..aa814af 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -128,69 +128,140 @@ static inline int octnet_iq_is_full(struct octeon_device *oct, u32 q_no)
 		>= (oct->instr_queue[q_no]->max_count - 2));
 }
 
-/** Utility function to prepare a 64B NIC instruction based on a setup command
- * @param cmd - pointer to instruction to be filled in.
- * @param setup - pointer to the setup structure
- * @param q_no - which queue for back pressure
- *
- * Assumes the cmd instruction is pre-allocated, but no fields are filled in.
- */
 static inline void
-octnet_prepare_pci_cmd(struct octeon_instr_64B *cmd,
-		       union octnic_cmd_setup *setup, u32 tag)
+octnet_prepare_pci_cmd_o2(struct octeon_device *oct,
+			  union octeon_instr_64B *cmd,
+			  union octnic_cmd_setup *setup, u32 tag)
 {
-	struct octeon_instr_ih *ih;
+	struct octeon_instr_ih2 *ih2;
 	struct octeon_instr_irh *irh;
 	union octnic_packet_params packet_params;
+	int port;
 
-	memset(cmd, 0, sizeof(struct octeon_instr_64B));
+	memset(cmd, 0, sizeof(union octeon_instr_64B));
 
-	ih = (struct octeon_instr_ih *)&cmd->ih;
+	ih2 = (struct octeon_instr_ih2 *)&cmd->cmd2.ih2;
 
 	/* assume that rflag is cleared so therefore front data will only have
-	 * irh and ossp[1] and ossp[2] for a total of 24 bytes
+	 * irh and ossp[0], ossp[1] for a total of 32 bytes
 	 */
-	ih->fsz = 24;
+	ih2->fsz = 24;
 
-	ih->tagtype = ORDERED_TAG;
-	ih->grp = DEFAULT_POW_GRP;
+	ih2->tagtype = ORDERED_TAG;
+	ih2->grp = DEFAULT_POW_GRP;
+
+	port = (int)oct->instr_queue[setup->s.iq_no]->txpciq.s.port;
 
 	if (tag)
-		ih->tag = tag;
+		ih2->tag = tag;
 	else
-		ih->tag = LIO_DATA(setup->s.ifidx);
+		ih2->tag = LIO_DATA(port);
 
-	ih->raw = 1;
-	ih->qos = (setup->s.ifidx & 3) + 4;	/* map qos based on interface */
+	ih2->raw = 1;
+	ih2->qos = (port & 3) + 4;	/* map qos based on interface */
 
 	if (!setup->s.gather) {
-		ih->dlengsz = setup->s.u.datasize;
+		ih2->dlengsz = setup->s.u.datasize;
 	} else {
-		ih->gather = 1;
-		ih->dlengsz = setup->s.u.gatherptrs;
+		ih2->gather = 1;
+		ih2->dlengsz = setup->s.u.gatherptrs;
 	}
 
-	irh = (struct octeon_instr_irh *)&cmd->irh;
+	irh = (struct octeon_instr_irh *)&cmd->cmd2.irh;
 
 	irh->opcode = OPCODE_NIC;
 	irh->subcode = OPCODE_NIC_NW_DATA;
 
 	packet_params.u32 = 0;
 
-	if (setup->s.cksum_offset) {
-		packet_params.s.csoffset = setup->s.cksum_offset;
-		packet_params.s.ipv4opts_ipv6exthdr =
-						setup->s.ipv4opts_ipv6exthdr;
+	packet_params.s.ip_csum = setup->s.ip_csum;
+	packet_params.s.transport_csum = setup->s.transport_csum;
+	packet_params.s.tnl_csum = setup->s.tnl_csum;
+	packet_params.s.tsflag = setup->s.timestamp;
+
+	irh->ossp = packet_params.u32;
+}
+
+static inline void
+octnet_prepare_pci_cmd_o3(struct octeon_device *oct,
+			  union octeon_instr_64B *cmd,
+			  union octnic_cmd_setup *setup, u32 tag)
+{
+	struct octeon_instr_irh *irh;
+	struct octeon_instr_ih3     *ih3;
+	struct octeon_instr_pki_ih3 *pki_ih3;
+	union octnic_packet_params packet_params;
+	int port;
+
+	memset(cmd, 0, sizeof(union octeon_instr_64B));
+
+	ih3 = (struct octeon_instr_ih3 *)&cmd->cmd3.ih3;
+	pki_ih3 = (struct octeon_instr_pki_ih3 *)&cmd->cmd3.pki_ih3;
+
+	/* assume that rflag is cleared so therefore front data will only have
+	 * irh and ossp[1] and ossp[2] for a total of 24 bytes
+	 */
+	ih3->pkind       = oct->instr_queue[setup->s.iq_no]->txpciq.s.pkind;
+	/*PKI IH*/
+	ih3->fsz = 24 + 8;
+
+	if (!setup->s.gather) {
+		ih3->dlengsz = setup->s.u.datasize;
+	} else {
+		ih3->gather = 1;
+		ih3->dlengsz = setup->s.u.gatherptrs;
 	}
 
+	pki_ih3->w       = 1;
+	pki_ih3->raw     = 1;
+	pki_ih3->utag    = 1;
+	pki_ih3->utt     = 1;
+	pki_ih3->uqpg    = oct->instr_queue[setup->s.iq_no]->txpciq.s.use_qpg;
+
+	port = (int)oct->instr_queue[setup->s.iq_no]->txpciq.s.port;
+
+	if (tag)
+		pki_ih3->tag = tag;
+	else
+		pki_ih3->tag     = LIO_DATA(port);
+
+	pki_ih3->tagtype = ORDERED_TAG;
+	pki_ih3->qpg     = oct->instr_queue[setup->s.iq_no]->txpciq.s.qpg;
+	pki_ih3->pm      = 0x7; /*0x7 - meant for Parse nothing, uninterpreted*/
+	pki_ih3->sl      = 8;   /* sl will be sizeof(pki_ih3)*/
+
+	irh = (struct octeon_instr_irh *)&cmd->cmd3.irh;
+
+	irh->opcode = OPCODE_NIC;
+	irh->subcode = OPCODE_NIC_NW_DATA;
+
+	packet_params.u32 = 0;
+
 	packet_params.s.ip_csum = setup->s.ip_csum;
+	packet_params.s.transport_csum = setup->s.transport_csum;
 	packet_params.s.tnl_csum = setup->s.tnl_csum;
-	packet_params.s.ifidx = setup->s.ifidx;
 	packet_params.s.tsflag = setup->s.timestamp;
 
 	irh->ossp = packet_params.u32;
 }
 
+/** Utility function to prepare a 64B NIC instruction based on a setup command
+ * @param cmd - pointer to instruction to be filled in.
+ * @param setup - pointer to the setup structure
+ * @param q_no - which queue for back pressure
+ *
+ * Assumes the cmd instruction is pre-allocated, but no fields are filled in.
+ */
+static inline void
+octnet_prepare_pci_cmd(struct octeon_device *oct, union octeon_instr_64B *cmd,
+		       union octnic_cmd_setup *setup, u32 tag)
+{
+	if (OCTEON_CN6XXX(oct))
+		octnet_prepare_pci_cmd_o2(oct, cmd, setup, tag);
+	else
+		octnet_prepare_pci_cmd_o3(oct, cmd, setup, tag);
+}
+
 /** Allocate and a soft command with space for a response immediately following
  * the commnad.
  * @param oct - octeon device pointer
-- 
1.8.3.1
