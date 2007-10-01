From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: DLPAR memory add fix
Date: Mon, 1 Oct 2007 16:33:18 +0200
Message-ID: <200710011633.18305.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:12634 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755178AbXJAOdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 10:33:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to stability issues in high load situations the HW queue handling
has to be changed. The HW queues are now stopped and restarted again instead
of destroying and allocating new HW queues. 

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/ehea/ehea.h      |    4 +-
 drivers/net/ehea/ehea_main.c |  276 +++++++++++++++++++++++++++++++++++++-----
 drivers/net/ehea/ehea_phyp.h |    1 +
 drivers/net/ehea/ehea_qmr.c  |   20 ++--
 drivers/net/ehea/ehea_qmr.h  |    4 +-
 5 files changed, 259 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index c0cbd94..3022089 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,13 +40,13 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0074"
+#define DRV_VERSION	"EHEA_0077"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
 #define DLPAR_MEM_ADD      2
 #define DLPAR_MEM_REM      4
-#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM)
+#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD)
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 62d6c1e..5bc0a15 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -97,6 +97,7 @@ u64 ehea_driver_flags = 0;
 struct workqueue_struct *ehea_driver_wq;
 struct work_struct ehea_rereg_mr_task;
 
+struct semaphore dlpar_mem_lock;
 
 static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 					const struct of_device_id *id);
@@ -177,16 +178,24 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
 	struct sk_buff **skb_arr_rq1 = pr->rq1_skba.arr;
 	struct net_device *dev = pr->port->netdev;
 	int max_index_mask = pr->rq1_skba.len - 1;
+	int fill_wqes = pr->rq1_skba.os_skbs + nr_of_wqes;
+	int adder = 0;
 	int i;
 
-	if (!nr_of_wqes)
+	pr->rq1_skba.os_skbs = 0;
+
+	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))) {
+		pr->rq1_skba.index = index;
+		pr->rq1_skba.os_skbs = fill_wqes;
 		return;
+	}
 
-	for (i = 0; i < nr_of_wqes; i++) {
+	for (i = 0; i < fill_wqes; i++) {
 		if (!skb_arr_rq1[index]) {
 			skb_arr_rq1[index] = netdev_alloc_skb(dev,
 							      EHEA_L_PKT_SIZE);
 			if (!skb_arr_rq1[index]) {
+				pr->rq1_skba.os_skbs = fill_wqes - i;
 				ehea_error("%s: no mem for skb/%d wqes filled",
 					   dev->name, i);
 				break;
@@ -194,9 +203,14 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
 		}
 		index--;
 		index &= max_index_mask;
+		adder++;
 	}
+
+	if (adder == 0)
+		return;
+
 	/* Ring doorbell */
-	ehea_update_rq1a(pr->qp, i);
+	ehea_update_rq1a(pr->qp, adder);
 }
 
 static int ehea_init_fill_rq1(struct ehea_port_res *pr, int nr_rq1a)
@@ -230,16 +244,21 @@ static int ehea_refill_rq_def(struct ehea_port_res *pr,
 	struct sk_buff **skb_arr = q_skba->arr;
 	struct ehea_rwqe *rwqe;
 	int i, index, max_index_mask, fill_wqes;
+	int adder = 0;
 	int ret = 0;
 
 	fill_wqes = q_skba->os_skbs + num_wqes;
+	q_skba->os_skbs = 0;
 
-	if (!fill_wqes)
+	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))) {
+		q_skba->os_skbs = fill_wqes;
 		return ret;
+	}
 
 	index = q_skba->index;
 	max_index_mask = q_skba->len - 1;
 	for (i = 0; i < fill_wqes; i++) {
+		u64 tmp_addr;
 		struct sk_buff *skb = netdev_alloc_skb(dev, packet_size);
 		if (!skb) {
 			ehea_error("%s: no mem for skb/%d wqes filled",
@@ -251,30 +270,37 @@ static int ehea_refill_rq_def(struct ehea_port_res *pr,
 		skb_reserve(skb, NET_IP_ALIGN);
 
 		skb_arr[index] = skb;
+		tmp_addr = ehea_map_vaddr(skb->data);
+		if (tmp_addr == -1) {
+			dev_kfree_skb(skb);
+			q_skba->os_skbs = fill_wqes - i;
+			ret = 0;
+			break;
+		}
 
 		rwqe = ehea_get_next_rwqe(qp, rq_nr);
 		rwqe->wr_id = EHEA_BMASK_SET(EHEA_WR_ID_TYPE, wqe_type)
 			    | EHEA_BMASK_SET(EHEA_WR_ID_INDEX, index);
 		rwqe->sg_list[0].l_key = pr->recv_mr.lkey;
-		rwqe->sg_list[0].vaddr = ehea_map_vaddr(skb->data);
+		rwqe->sg_list[0].vaddr = tmp_addr;
 		rwqe->sg_list[0].len = packet_size;
 		rwqe->data_segments = 1;
 
 		index++;
 		index &= max_index_mask;
-
-		if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags)))
-			goto out;
+		adder++;
 	}
 
 	q_skba->index = index;
+	if (adder == 0)
+		goto out;
 
 	/* Ring doorbell */
 	iosync();
 	if (rq_nr == 2)
-		ehea_update_rq2a(pr->qp, i);
+		ehea_update_rq2a(pr->qp, adder);
 	else
-		ehea_update_rq3a(pr->qp, i);
+		ehea_update_rq3a(pr->qp, adder);
 out:
 	return ret;
 }
@@ -1967,11 +1993,12 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ehea_dump(swqe, 512, "swqe");
 	}
 
-	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags)))
-		goto out;
+	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))) {
+		netif_stop_queue(dev);
+		swqe->tx_control |= EHEA_SWQE_PURGE;
+	}
 
 	ehea_post_swqe(pr->qp, swqe);
-	pr->tx_packets++;
 
 	if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
 		spin_lock_irqsave(&pr->netif_queue, flags);
@@ -1984,7 +2011,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	dev->trans_start = jiffies;
 	spin_unlock(&pr->xmit_lock);
-out:
+
 	return NETDEV_TX_OK;
 }
 
@@ -2376,6 +2403,192 @@ static int ehea_stop(struct net_device *dev)
 	return ret;
 }
 
+void ehea_purge_sq(struct ehea_qp *orig_qp)
+{
+	struct ehea_qp qp = *orig_qp;
+	struct ehea_qp_init_attr *init_attr = &qp.init_attr;
+	struct ehea_swqe *swqe;
+	int wqe_index;
+	int i;
+
+	for (i = 0; i < init_attr->act_nr_send_wqes; i++) {
+		swqe = ehea_get_swqe(&qp, &wqe_index);
+		swqe->tx_control |= EHEA_SWQE_PURGE;
+	}
+}
+
+int ehea_stop_qps(struct net_device *dev)
+{
+	struct ehea_port *port = netdev_priv(dev);
+	struct ehea_adapter *adapter = port->adapter;
+	struct hcp_modify_qp_cb0* cb0;
+	int ret = -EIO;
+	int dret;
+	int i;
+	u64 hret;
+	u64 dummy64 = 0;
+	u16 dummy16 = 0;
+
+	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!cb0) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < (port->num_def_qps + port->num_add_tx_qps); i++) {
+		struct ehea_port_res *pr =  &port->port_res[i];
+		struct ehea_qp *qp = pr->qp;
+
+		/* Purge send queue */
+		ehea_purge_sq(qp);
+
+		/* Disable queue pair */
+		hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
+					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
+					    cb0);
+		if (hret != H_SUCCESS) {
+			ehea_error("query_ehea_qp failed (1)");
+			goto out;
+		}
+
+		cb0->qp_ctl_reg = (cb0->qp_ctl_reg & H_QP_CR_RES_STATE) << 8;
+		cb0->qp_ctl_reg &= ~H_QP_CR_ENABLED;
+
+		hret = ehea_h_modify_ehea_qp(adapter->handle, 0, qp->fw_handle,
+					     EHEA_BMASK_SET(H_QPCB0_QP_CTL_REG,
+							    1), cb0, &dummy64,
+					     &dummy64, &dummy16, &dummy16);
+		if (hret != H_SUCCESS) {
+			ehea_error("modify_ehea_qp failed (1)");
+			goto out;
+		}
+
+		hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
+					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
+					    cb0);
+		if (hret != H_SUCCESS) {
+			ehea_error("query_ehea_qp failed (2)");
+			goto out;
+		}
+
+		/* deregister shared memory regions */
+		dret = ehea_rem_smrs(pr);
+		if (dret) {
+			ehea_error("unreg shared memory region failed");
+			goto out;
+		}
+	}
+
+	ret = 0;
+out:
+	kfree(cb0);
+
+	return ret;
+}
+
+void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res * pr)
+{
+	struct ehea_qp qp = *orig_qp;
+	struct ehea_qp_init_attr *init_attr = &qp.init_attr;
+	struct ehea_rwqe *rwqe;
+	struct sk_buff **skba_rq2 = pr->rq2_skba.arr;
+	struct sk_buff **skba_rq3 = pr->rq3_skba.arr;
+	struct sk_buff *skb;
+	u32 lkey = pr->recv_mr.lkey;
+
+
+	int i;
+	int index;
+
+	for (i = 0; i < init_attr->act_nr_rwqes_rq2 + 1; i++) {
+		rwqe = ehea_get_next_rwqe(&qp, 2);
+		rwqe->sg_list[0].l_key = lkey;
+		index = EHEA_BMASK_GET(EHEA_WR_ID_INDEX, rwqe->wr_id);
+		skb = skba_rq2[index];
+		if (skb)
+			rwqe->sg_list[0].vaddr = ehea_map_vaddr(skb->data);
+	}
+
+	for (i = 0; i < init_attr->act_nr_rwqes_rq3 + 1; i++) {
+		rwqe = ehea_get_next_rwqe(&qp, 3);
+		rwqe->sg_list[0].l_key = lkey;
+		index = EHEA_BMASK_GET(EHEA_WR_ID_INDEX, rwqe->wr_id);
+		skb = skba_rq3[index];
+		if (skb)
+			rwqe->sg_list[0].vaddr = ehea_map_vaddr(skb->data);
+	}
+}
+
+int ehea_restart_qps(struct net_device *dev)
+{
+	struct ehea_port *port = netdev_priv(dev);
+	struct ehea_adapter *adapter = port->adapter;
+	int ret = 0;
+	int i;
+
+	struct hcp_modify_qp_cb0* cb0;
+	u64 hret;
+	u64 dummy64 = 0;
+	u16 dummy16 = 0;
+
+	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!cb0) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < (port->num_def_qps + port->num_add_tx_qps); i++) {
+		struct ehea_port_res *pr =  &port->port_res[i];
+		struct ehea_qp *qp = pr->qp;
+
+		ret = ehea_gen_smrs(pr);
+		if (ret) {
+			ehea_error("creation of shared memory regions failed");
+			goto out;
+		}
+
+		ehea_update_rqs(qp, pr);
+
+		/* Enable queue pair */
+		hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
+					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
+					    cb0);
+		if (hret != H_SUCCESS) {
+			ehea_error("query_ehea_qp failed (1)");
+			goto out;
+		}
+
+		cb0->qp_ctl_reg = (cb0->qp_ctl_reg & H_QP_CR_RES_STATE) << 8;
+		cb0->qp_ctl_reg |= H_QP_CR_ENABLED;
+
+		hret = ehea_h_modify_ehea_qp(adapter->handle, 0, qp->fw_handle,
+					     EHEA_BMASK_SET(H_QPCB0_QP_CTL_REG,
+							    1), cb0, &dummy64,
+					     &dummy64, &dummy16, &dummy16);
+		if (hret != H_SUCCESS) {
+			ehea_error("modify_ehea_qp failed (1)");
+			goto out;
+		}
+
+		hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
+					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
+					    cb0);
+		if (hret != H_SUCCESS) {
+			ehea_error("query_ehea_qp failed (2)");
+			goto out;
+		}
+
+		/* refill entire queue */
+		ehea_refill_rq1(pr, pr->rq1_skba.index, 0);
+		ehea_refill_rq2(pr, 0);
+		ehea_refill_rq3(pr, 0);
+	}
+out:
+	kfree(cb0);
+
+	return ret;
+}
+
 static void ehea_reset_port(struct work_struct *work)
 {
 	int ret;
@@ -2395,6 +2608,8 @@ static void ehea_reset_port(struct work_struct *work)
 	if (ret)
 		goto out;
 
+	ehea_set_multicast_list(dev);
+
 	if (netif_msg_timer(port))
 		ehea_info("Device %s resetted successfully", dev->name);
 
@@ -2411,6 +2626,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 	int ret, i;
 	struct ehea_adapter *adapter;
 
+	down(&dlpar_mem_lock);
 	ehea_info("LPAR memory enlarged - re-initializing driver");
 
 	list_for_each_entry(adapter, &adapter_list, list)
@@ -2423,14 +2639,14 @@ static void ehea_rereg_mrs(struct work_struct *work)
 					struct net_device *dev = port->netdev;
 
 					if (dev->flags & IFF_UP) {
-						ehea_info("stopping %s",
-							  dev->name);
 						down(&port->port_lock);
 						netif_stop_queue(dev);
-
+						ret = ehea_stop_qps(dev);
+						if (ret) {
+							up(&port->port_lock);
+							goto out;
+						}
 						port_napi_disable(port);
-
-						ehea_down(dev);
 						up(&port->port_lock);
 					}
 				}
@@ -2446,10 +2662,11 @@ static void ehea_rereg_mrs(struct work_struct *work)
 		}
 
 	ehea_destroy_busmap();
-
 	ret = ehea_create_busmap();
-	if (ret)
+	if (ret) {
+		ehea_error("creating ehea busmap failed");
 		goto out;
+	}
 
 	clear_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 
@@ -2471,21 +2688,18 @@ static void ehea_rereg_mrs(struct work_struct *work)
 					struct net_device *dev = port->netdev;
 
 					if (dev->flags & IFF_UP) {
-						ehea_info("restarting %s",
-							  dev->name);
 						down(&port->port_lock);
-
-						ret = ehea_up(dev);
-						if (!ret) {
-							port_napi_enable(port);
+						port_napi_enable(port);
+						ret = ehea_restart_qps(dev);
+						if (!ret)
 							netif_wake_queue(dev);
-						}
-
 						up(&port->port_lock);
 					}
 				}
 			}
 		}
+       up(&dlpar_mem_lock);
+       ehea_info("re-initializing driver complete");
 out:
 	return;
 }
@@ -2494,7 +2708,8 @@ static void ehea_tx_watchdog(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 
-	if (netif_carrier_ok(dev))
+	if (netif_carrier_ok(dev) &&
+	    !test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
 		queue_work(port->adapter->ehea_wq, &port->reset_task);
 }
 
@@ -3139,6 +3354,7 @@ int __init ehea_module_init(void)
 	ehea_driver_wq = create_workqueue("ehea_driver_wq");
 
 	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
+	sema_init(&dlpar_mem_lock, 1);
 
 	ret = check_module_parm();
 	if (ret)
diff --git a/drivers/net/ehea/ehea_phyp.h b/drivers/net/ehea/ehea_phyp.h
index 89b6353..faa191d 100644
--- a/drivers/net/ehea/ehea_phyp.h
+++ b/drivers/net/ehea/ehea_phyp.h
@@ -126,6 +126,7 @@ struct hcp_modify_qp_cb0 {
 #define H_QP_CR_STATE_RDY2RCV	    0x0000030000000000ULL /*  Ready to recv */
 #define H_QP_CR_STATE_RDY2SND	    0x0000050000000000ULL /*  Ready to send */
 #define H_QP_CR_STATE_ERROR	    0x0000800000000000ULL /*  Error */
+#define H_QP_CR_RES_STATE 	    0x0000007F00000000ULL /* Resultant state */
 
 struct hcp_modify_qp_cb1 {
 	u32 qpn;		/* 00 */
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index c82e245..329a252 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -563,8 +563,7 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 int ehea_create_busmap( void )
 {
 	u64 vaddr = EHEA_BUSMAP_START;
-	unsigned long abs_max_pfn = 0;
-	unsigned long sec_max_pfn;
+	unsigned long high_section_index = 0;
 	int i;
 
 	/*
@@ -574,14 +573,10 @@ int ehea_create_busmap( void )
 	ehea_bmap.valid_sections = 0;
 
 	for (i = 0; i < NR_MEM_SECTIONS; i++)
-		if (valid_section_nr(i)) {
-			sec_max_pfn = section_nr_to_pfn(i);
-			if (sec_max_pfn > abs_max_pfn)
-				abs_max_pfn = sec_max_pfn;
-			ehea_bmap.valid_sections++;
-		}
+		if (valid_section_nr(i))
+			high_section_index = i;
 
-	ehea_bmap.entries = abs_max_pfn / EHEA_PAGES_PER_SECTION + 1;
+	ehea_bmap.entries = high_section_index + 1;
 	ehea_bmap.vaddr = vmalloc(ehea_bmap.entries * sizeof(*ehea_bmap.vaddr));
 
 	if (!ehea_bmap.vaddr)
@@ -593,6 +588,7 @@ int ehea_create_busmap( void )
 		if (pfn_valid(pfn)) {
 			ehea_bmap.vaddr[i] = vaddr;
 			vaddr += EHEA_SECTSIZE;
+			ehea_bmap.valid_sections++;
 		} else
 			ehea_bmap.vaddr[i] = 0;
 	}
@@ -637,7 +633,7 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 
 	mr_len = ehea_bmap.valid_sections * EHEA_SECTSIZE;
 
-	pt =  kzalloc(EHEA_MAX_RPAGE * sizeof(u64), GFP_KERNEL);
+	pt =  kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!pt) {
 		ehea_error("no mem");
 		ret = -ENOMEM;
@@ -660,8 +656,8 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 			void *sectbase = __va(i << SECTION_SIZE_BITS);
 			unsigned long k = 0;
 
-			for (j = 0; j < (PAGES_PER_SECTION / EHEA_MAX_RPAGE);
-			      j++) {
+			for (j = 0; j < (EHEA_PAGES_PER_SECTION /
+					 EHEA_MAX_RPAGE); j++) {
 
 				for (m = 0; m < EHEA_MAX_RPAGE; m++) {
 					pg = sectbase + ((k++) * EHEA_PAGESIZE);
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index b71f845..562de0e 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -39,7 +39,7 @@
 #define EHEA_PAGESHIFT         12
 #define EHEA_PAGESIZE          (1UL << EHEA_PAGESHIFT)
 #define EHEA_SECTSIZE          (1UL << 24)
-#define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> PAGE_SHIFT)
+#define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> EHEA_PAGESHIFT)
 
 #if (1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE
 #error eHEA module can't work if kernel sectionsize < ehea sectionsize
@@ -145,7 +145,7 @@ struct ehea_rwqe {
 #define EHEA_CQE_VLAN_TAG_XTRACT   0x0400
 
 #define EHEA_CQE_TYPE_RQ           0x60
-#define EHEA_CQE_STAT_ERR_MASK     0x721F
+#define EHEA_CQE_STAT_ERR_MASK     0x720F
 #define EHEA_CQE_STAT_FAT_ERR_MASK 0x1F
 #define EHEA_CQE_STAT_ERR_TCP      0x4000
 #define EHEA_CQE_STAT_ERR_IP       0x2000
-- 
1.5.2

