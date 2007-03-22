From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 2/2] ehea: code cleanup
Date: Thu, 22 Mar 2007 17:50:24 +0100
Message-ID: <200703221750.24570.ossthema@de.ibm.com>
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
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:43350 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934120AbXCVRAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 13:00:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch includes:

- code cleanup related to resource management
- extended error data gathering for resource management
- removing trailing whitespaces

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---


This patch applies on top of the netdev upstream branch for 2.6.22


 drivers/net/ehea/ehea.h      |    3
 drivers/net/ehea/ehea_main.c |   95 ++++++++--------------
 drivers/net/ehea/ehea_phyp.c |    6 -
 drivers/net/ehea/ehea_phyp.h |    6 +
 drivers/net/ehea/ehea_qmr.c  |  184 +++++++++++++++++++++++++++++++------------
 drivers/net/ehea/ehea_qmr.h  |    7 +
 6 files changed, 187 insertions(+), 114 deletions(-)


diff -Nurp netdev-2.6/drivers/net/ehea/ehea.h netdev_backup/drivers/net/ehea/ehea.h
--- netdev-2.6/drivers/net/ehea/ehea.h	2007-03-22 15:37:46.000000000 +0100
+++ netdev_backup/drivers/net/ehea/ehea.h	2007-03-22 15:41:50.000000000 +0100
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0053"
+#define DRV_VERSION	"EHEA_0054"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -309,6 +309,7 @@ struct ehea_cq {
  * Memory Region
  */
 struct ehea_mr {
+	struct ehea_adapter *adapter;
 	u64 handle;
 	u64 vaddr;
 	u32 lkey;
diff -Nurp netdev-2.6/drivers/net/ehea/ehea_main.c netdev_backup/drivers/net/ehea/ehea_main.c
--- netdev-2.6/drivers/net/ehea/ehea_main.c	2007-03-22 15:37:46.000000000 +0100
+++ netdev_backup/drivers/net/ehea/ehea_main.c	2007-03-22 15:41:50.000000000 +0100
@@ -546,19 +546,19 @@ static int ehea_poll(struct net_device *
 		cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 		cqe_skb = ehea_poll_cq(pr->send_cq);
 
-		if (!cqe && !cqe_skb) 
+		if (!cqe && !cqe_skb)
 			return 0;
 
-		if (!netif_rx_reschedule(dev, dev->quota)) 
+		if (!netif_rx_reschedule(dev, dev->quota))
 			return 0;
 	}
-	
+
 	cqe = ehea_proc_rwqes(dev, pr, budget);
 	cqe_skb = ehea_proc_cqes(pr, 300);
 
 	if (cqe || cqe_skb)
 		pr->poll_counter++;
-       
+
 	return 1;
 }
 
@@ -1011,7 +1011,7 @@ static int ehea_configure_port(struct eh
 		else
 			cb0->default_qpn_arr[i] =
 				port->port_res[0].qp->init_attr.qp_nr;
-	
+
 	if (netif_msg_ifup(port))
 		ehea_dump(cb0, sizeof(*cb0), "ehea_configure_port");
 
@@ -1033,52 +1033,35 @@ out:
 	return ret;
 }
 
-static int ehea_gen_smrs(struct ehea_port_res *pr)
+int ehea_gen_smrs(struct ehea_port_res *pr)
 {
-	u64 hret;
+	int ret;
 	struct ehea_adapter *adapter = pr->port->adapter;
 
-	hret = ehea_h_register_smr(adapter->handle, adapter->mr.handle,
-				   adapter->mr.vaddr, EHEA_MR_ACC_CTRL,
-				   adapter->pd, &pr->send_mr);
-	if (hret != H_SUCCESS)
+	ret = ehea_gen_smr(adapter, &adapter->mr, &pr->send_mr);
+	if (ret)
 		goto out;
 
-	hret = ehea_h_register_smr(adapter->handle, adapter->mr.handle,
-				   adapter->mr.vaddr, EHEA_MR_ACC_CTRL,
-				   adapter->pd, &pr->recv_mr);
-	if (hret != H_SUCCESS)
-		goto out_freeres;
+	ret = ehea_gen_smr(adapter, &adapter->mr, &pr->recv_mr);
+	if (ret)
+		goto out_free;
 
 	return 0;
 
-out_freeres:
-	hret = ehea_h_free_resource(adapter->handle, pr->send_mr.handle);
-	if (hret != H_SUCCESS)
-		ehea_error("failed freeing SMR");
+out_free:
+	ehea_rem_mr(&pr->send_mr);
 out:
+	ehea_error("Generating SMRS failed\n");
 	return -EIO;
 }
 
-static int ehea_rem_smrs(struct ehea_port_res *pr)
+int ehea_rem_smrs(struct ehea_port_res *pr)
 {
-	struct ehea_adapter *adapter = pr->port->adapter;
-	int ret = 0;
-	u64 hret;
-
-	hret = ehea_h_free_resource(adapter->handle, pr->send_mr.handle);
-	if (hret != H_SUCCESS) {
-		ret = -EIO;
-		ehea_error("failed freeing send SMR for pr=%p", pr);
-	}
-
-	hret = ehea_h_free_resource(adapter->handle, pr->recv_mr.handle);
-	if (hret != H_SUCCESS) {
-		ret = -EIO;
-		ehea_error("failed freeing recv SMR for pr=%p", pr);
-	}
-
-	return ret;
+	if ((ehea_rem_mr(&pr->send_mr))
+	    || (ehea_rem_mr(&pr->recv_mr)))
+		return -EIO;
+	else
+		return 0;
 }
 
 static int ehea_init_q_skba(struct ehea_q_skb_arr *q_skba, int max_q_entries)
@@ -2240,7 +2223,7 @@ static int ehea_down(struct net_device *
 	ehea_free_interrupts(dev);
 
 	for (i = 0; i < port->num_def_qps; i++)
-		while (test_bit(__LINK_STATE_RX_SCHED, 
+		while (test_bit(__LINK_STATE_RX_SCHED,
 				&port->port_res[i].d_netdev->state))
 			msleep(1);
 
@@ -2415,7 +2398,7 @@ static struct device *ehea_register_port
 		ehea_error("failed to register attributes, ret=%d", ret);
 		goto out_unreg_of_dev;
 	}
-	
+
 	return &port->ofdev.dev;
 
 out_unreg_of_dev:
@@ -2514,7 +2497,7 @@ struct ehea_port *ehea_setup_single_port
 	}
 
 	ret = ehea_get_jumboframe_status(port, &jumbo);
-	if (ret) 
+	if (ret)
 		ehea_error("failed determining jumbo frame status for %s",
 			   port->netdev->name);
 
@@ -2557,7 +2540,7 @@ static int ehea_setup_ports(struct ehea_
 
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
-		
+
 		dn_log_port_id = (u32*)get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (!dn_log_port_id) {
@@ -2571,7 +2554,7 @@ static int ehea_setup_ports(struct ehea_
 							  eth_dn);
 		if (adapter->port[i])
 			ehea_info("%s -> logical port id #%d",
-				  adapter->port[i]->netdev->name, 
+				  adapter->port[i]->netdev->name,
 				  *dn_log_port_id);
 		i++;
 	};
@@ -2587,8 +2570,8 @@ static int ehea_setup_ports(struct ehea_
 	return -EINVAL;
 }
 
-static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter, 
-					   u32 logical_port_id) 
+static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter,
+					   u32 logical_port_id)
 {
 	struct device_node *lhea_dn;
 	struct device_node *eth_dn = NULL;
@@ -2596,7 +2579,7 @@ static struct device_node *ehea_get_eth_
 
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
-		
+
 		dn_log_port_id = (u32*)get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (dn_log_port_id)
@@ -2628,14 +2611,14 @@ static ssize_t ehea_probe_port(struct de
 			  port->netdev->name);
 		return -EINVAL;
 	}
-	
+
 	eth_dn = ehea_get_eth_dn(adapter, logical_port_id);
 
 	if (!eth_dn) {
 		ehea_info("no logical port with id %d found", logical_port_id);
 		return -EINVAL;
 	}
-		
+
 	port = ehea_setup_single_port(adapter, logical_port_id, eth_dn);
 
 	of_node_put(eth_dn);
@@ -2649,8 +2632,8 @@ static ssize_t ehea_probe_port(struct de
 
 		ehea_info("added %s (logical port id=%d)", port->netdev->name,
 			  logical_port_id);
-	} else 
-		return -EIO;	       
+	} else
+		return -EIO;
 
 	return (ssize_t) count;
 }
@@ -2745,7 +2728,7 @@ static int __devinit ehea_probe_adapter(
 
 	dev->ofdev.dev.driver_data = adapter;
 
-	ret = ehea_reg_mr_adapter(adapter);
+	ret = ehea_reg_kernel_mr(adapter, &adapter->mr);
 	if (ret) {
 		dev_err(&dev->ofdev.dev, "reg_mr_adapter failed\n");
 		goto out_free_ad;
@@ -2810,7 +2793,7 @@ out_kill_eq:
 	ehea_destroy_eq(adapter->neq);
 
 out_free_res:
-	ehea_h_free_resource(adapter->handle, adapter->mr.handle);
+	ehea_rem_mr(&adapter->mr);
 
 out_free_ad:
 	kfree(adapter);
@@ -2821,7 +2804,6 @@ out:
 static int __devexit ehea_remove(struct ibmebus_dev *dev)
 {
 	struct ehea_adapter *adapter = dev->ofdev.dev.driver_data;
-	u64 hret;
 	int i;
 
 	for (i = 0; i < EHEA_MAX_PORTS; i++)
@@ -2838,12 +2820,7 @@ static int __devexit ehea_remove(struct 
 	tasklet_kill(&adapter->neq_tasklet);
 
 	ehea_destroy_eq(adapter->neq);
-
-	hret = ehea_h_free_resource(adapter->handle, adapter->mr.handle);
-	if (hret) {
-		dev_err(&dev->ofdev.dev, "free_resource_mr failed");
-		return -EIO;
-	}
+	ehea_rem_mr(&adapter->mr);
 	kfree(adapter);
 	return 0;
 }
diff -Nurp netdev-2.6/drivers/net/ehea/ehea_phyp.c netdev_backup/drivers/net/ehea/ehea_phyp.c
--- netdev-2.6/drivers/net/ehea/ehea_phyp.c	2007-03-22 14:07:32.000000000 +0100
+++ netdev_backup/drivers/net/ehea/ehea_phyp.c	2007-03-22 15:41:50.000000000 +0100
@@ -478,12 +478,14 @@ u64 ehea_h_disable_and_get_hea(const u64
 				 0, 0, 0, 0, 0, 0);             /* R7-R12 */
 }
 
-u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle)
+u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
+			 u64 force_bit)
 {
 	return ehea_plpar_hcall_norets(H_FREE_RESOURCE,
 				       adapter_handle,	   /* R4 */
 				       res_handle,         /* R5 */
-				       0, 0, 0, 0, 0);     /* R6-R10 */
+				       force_bit,
+				       0, 0, 0, 0);        /* R7-R10 */
 }
 
 u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
diff -Nurp netdev-2.6/drivers/net/ehea/ehea_phyp.h netdev_backup/drivers/net/ehea/ehea_phyp.h
--- netdev-2.6/drivers/net/ehea/ehea_phyp.h	2007-03-22 14:07:32.000000000 +0100
+++ netdev_backup/drivers/net/ehea/ehea_phyp.h	2007-03-22 15:41:50.000000000 +0100
@@ -414,7 +414,11 @@ u64 ehea_h_register_rpage(const u64 adap
 
 u64 ehea_h_disable_and_get_hea(const u64 adapter_handle, const u64 qp_handle);
 
-u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle);
+#define FORCE_FREE 1
+#define NORMAL_FREE 0
+
+u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
+			 u64 force_bit);
 
 u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
 			     const u64 length, const u32 access_ctrl,
diff -Nurp netdev-2.6/drivers/net/ehea/ehea_qmr.c netdev_backup/drivers/net/ehea/ehea_qmr.c
--- netdev-2.6/drivers/net/ehea/ehea_qmr.c	2007-03-22 14:07:32.000000000 +0100
+++ netdev_backup/drivers/net/ehea/ehea_qmr.c	2007-03-22 15:41:50.000000000 +0100
@@ -197,7 +197,7 @@ out_kill_hwq:
 	hw_queue_dtor(&cq->hw_queue);
 
 out_freeres:
-	ehea_h_free_resource(adapter->handle, cq->fw_handle);
+	ehea_h_free_resource(adapter->handle, cq->fw_handle, FORCE_FREE);
 
 out_freemem:
 	kfree(cq);
@@ -206,25 +206,38 @@ out_nomem:
 	return NULL;
 }
 
-int ehea_destroy_cq(struct ehea_cq *cq)
+u64 ehea_destroy_cq_res(struct ehea_cq *cq, u64 force)
 {
-	u64 adapter_handle, hret;
+	u64 hret;
+	u64 adapter_handle = cq->adapter->handle;
+
+        /* deregister all previous registered pages */
+	hret = ehea_h_free_resource(adapter_handle, cq->fw_handle, force);
+	if (hret != H_SUCCESS)
+		return hret;
+
+	hw_queue_dtor(&cq->hw_queue);
+	kfree(cq);
+
+	return hret;
+}
 
+int ehea_destroy_cq(struct ehea_cq *cq)
+{
+	u64 hret;
 	if (!cq)
 		return 0;
 
-	adapter_handle = cq->adapter->handle;
+	if ((hret = ehea_destroy_cq_res(cq, NORMAL_FREE)) == H_R_STATE) {
+		ehea_error_data(cq->adapter, cq->fw_handle);
+		hret = ehea_destroy_cq_res(cq, FORCE_FREE);
+	}
 
-	/* deregister all previous registered pages */
-	hret = ehea_h_free_resource(adapter_handle, cq->fw_handle);
 	if (hret != H_SUCCESS) {
 		ehea_error("destroy CQ failed");
 		return -EIO;
 	}
 
-	hw_queue_dtor(&cq->hw_queue);
-	kfree(cq);
-
 	return 0;
 }
 
@@ -297,7 +310,7 @@ out_kill_hwq:
 	hw_queue_dtor(&eq->hw_queue);
 
 out_freeres:
-	ehea_h_free_resource(adapter->handle, eq->fw_handle);
+	ehea_h_free_resource(adapter->handle, eq->fw_handle, FORCE_FREE);
 
 out_freemem:
 	kfree(eq);
@@ -316,27 +329,41 @@ struct ehea_eqe *ehea_poll_eq(struct ehe
 	return eqe;
 }
 
-int ehea_destroy_eq(struct ehea_eq *eq)
+u64 ehea_destroy_eq_res(struct ehea_eq *eq, u64 force)
 {
 	u64 hret;
 	unsigned long flags;
 
-	if (!eq)
-		return 0;
-
 	spin_lock_irqsave(&eq->spinlock, flags);
 
-	hret = ehea_h_free_resource(eq->adapter->handle, eq->fw_handle);
+	hret = ehea_h_free_resource(eq->adapter->handle, eq->fw_handle, force);
 	spin_unlock_irqrestore(&eq->spinlock, flags);
 
-	if (hret != H_SUCCESS) {
-		ehea_error("destroy_eq failed");
-		return -EIO;
-	}
+	if (hret != H_SUCCESS)
+		return hret;
 
 	hw_queue_dtor(&eq->hw_queue);
 	kfree(eq);
 
+	return hret;
+}
+
+int ehea_destroy_eq(struct ehea_eq *eq)
+{
+	u64 hret;
+	if (!eq)
+		return 0;
+
+	if ((hret = ehea_destroy_eq_res(eq, NORMAL_FREE)) == H_R_STATE) {
+		ehea_error_data(eq->adapter, eq->fw_handle);
+		hret = ehea_destroy_eq_res(eq, FORCE_FREE);
+	}
+
+	if (hret != H_SUCCESS) {
+		ehea_error("destroy EQ failed");
+		return -EIO;
+        }
+
 	return 0;
 }
 
@@ -471,41 +498,56 @@ out_kill_hwsq:
 
 out_freeres:
 	ehea_h_disable_and_get_hea(adapter->handle, qp->fw_handle);
-	ehea_h_free_resource(adapter->handle, qp->fw_handle);
+	ehea_h_free_resource(adapter->handle, qp->fw_handle, FORCE_FREE);
 
 out_freemem:
 	kfree(qp);
 	return NULL;
 }
 
-int ehea_destroy_qp(struct ehea_qp *qp)
+u64 ehea_destroy_qp_res(struct ehea_qp *qp, u64 force)
 {
-	u64 hret;
-	struct ehea_qp_init_attr *qp_attr = &qp->init_attr;
+        u64 hret;
+        struct ehea_qp_init_attr *qp_attr = &qp->init_attr;
 
-	if (!qp)
-		return 0;
 
-	ehea_h_disable_and_get_hea(qp->adapter->handle, qp->fw_handle);
-	hret = ehea_h_free_resource(qp->adapter->handle, qp->fw_handle);
-	if (hret != H_SUCCESS) {
-		ehea_error("destroy_qp failed");
-		return -EIO;
-	}
+        ehea_h_disable_and_get_hea(qp->adapter->handle, qp->fw_handle);
+        hret = ehea_h_free_resource(qp->adapter->handle, qp->fw_handle, force);
+        if (hret != H_SUCCESS)
+                return hret;
 
-	hw_queue_dtor(&qp->hw_squeue);
-	hw_queue_dtor(&qp->hw_rqueue1);
+        hw_queue_dtor(&qp->hw_squeue);
+        hw_queue_dtor(&qp->hw_rqueue1);
 
-   	if (qp_attr->rq_count > 1)
-		hw_queue_dtor(&qp->hw_rqueue2);
-   	if (qp_attr->rq_count > 2)
-		hw_queue_dtor(&qp->hw_rqueue3);
-	kfree(qp);
+        if (qp_attr->rq_count > 1)
+                hw_queue_dtor(&qp->hw_rqueue2);
+        if (qp_attr->rq_count > 2)
+                hw_queue_dtor(&qp->hw_rqueue3);
+        kfree(qp);
 
-	return 0;
+        return hret;
 }
 
-int ehea_reg_mr_adapter(struct ehea_adapter *adapter)
+int ehea_destroy_qp(struct ehea_qp *qp)
+{
+        u64 hret;
+        if (!qp)
+                return 0;
+
+        if ((hret = ehea_destroy_qp_res(qp, NORMAL_FREE)) == H_R_STATE) {
+                ehea_error_data(qp->adapter, qp->fw_handle);
+                hret = ehea_destroy_qp_res(qp, FORCE_FREE);
+        }
+
+        if (hret != H_SUCCESS) {
+                ehea_error("destroy QP failed");
+                return -EIO;
+        }
+
+        return 0;
+}
+
+int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 {
 	int i, k, ret;
 	u64 hret, pt_abs, start, end, nr_pages;
@@ -526,14 +568,14 @@ int ehea_reg_mr_adapter(struct ehea_adap
 
 	hret = ehea_h_alloc_resource_mr(adapter->handle, start, end - start,
 					acc_ctrl, adapter->pd,
-					&adapter->mr.handle, &adapter->mr.lkey);
+					&mr->handle, &mr->lkey);
 	if (hret != H_SUCCESS) {
 		ehea_error("alloc_resource_mr failed");
 		ret = -EIO;
 		goto out;
 	}
 
-	adapter->mr.vaddr = KERNELBASE;
+	mr->vaddr = KERNELBASE;
 	k = 0;
 
 	while (nr_pages > 0) {
@@ -545,7 +587,7 @@ int ehea_reg_mr_adapter(struct ehea_adap
 							     EHEA_PAGESIZE)));
 
 			hret = ehea_h_register_rpage_mr(adapter->handle,
-							adapter->mr.handle, 0,
+							mr->handle, 0,
 							0, (u64)pt_abs,
 							num_pages);
 			nr_pages -= num_pages;
@@ -554,34 +596,68 @@ int ehea_reg_mr_adapter(struct ehea_adap
 							  (k * EHEA_PAGESIZE)));
 
 			hret = ehea_h_register_rpage_mr(adapter->handle,
-							adapter->mr.handle, 0,
+							mr->handle, 0,
 							0, abs_adr,1);
 			nr_pages--;
 		}
 
 		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED)) {
 			ehea_h_free_resource(adapter->handle,
-						adapter->mr.handle);
-			ehea_error("register_rpage_mr failed: hret = %lX",
-				   hret);
+					     mr->handle, FORCE_FREE);
+			ehea_error("register_rpage_mr failed");
 			ret = -EIO;
 			goto out;
 		}
 	}
 
 	if (hret != H_SUCCESS) {
-		ehea_h_free_resource(adapter->handle, adapter->mr.handle);
-		ehea_error("register_rpage failed for last page: hret = %lX",
-			   hret);
+		ehea_h_free_resource(adapter->handle, mr->handle,
+				     FORCE_FREE);
+		ehea_error("register_rpage failed for last page");
 		ret = -EIO;
 		goto out;
 	}
+
+	mr->adapter = adapter;
 	ret = 0;
 out:
 	kfree(pt);
 	return ret;
 }
 
+int ehea_rem_mr(struct ehea_mr *mr)
+{
+	u64 hret;
+
+	if (!mr || !mr->adapter)
+		return -EINVAL;
+
+	hret = ehea_h_free_resource(mr->adapter->handle, mr->handle,
+				    FORCE_FREE);
+	if (hret != H_SUCCESS) {
+		ehea_error("destroy MR failed");
+		return -EIO;
+	}
+
+	return 0;
+}
+
+int ehea_gen_smr(struct ehea_adapter *adapter, struct ehea_mr *old_mr,
+		 struct ehea_mr *shared_mr)
+{
+	u64 hret;
+
+	hret = ehea_h_register_smr(adapter->handle, old_mr->handle,
+				   old_mr->vaddr, EHEA_MR_ACC_CTRL,
+				   adapter->pd, shared_mr);
+	if (hret != H_SUCCESS)
+		return -EIO;
+
+	shared_mr->adapter = adapter;
+
+	return 0;
+}
+
 void print_error_data(u64 *data)
 {
 	int length;
@@ -597,6 +673,14 @@ void print_error_data(u64 *data)
 		ehea_error("QP (resource=%lX) state: AER=0x%lX, AERR=0x%lX, "
 			   "port=%lX", resource, data[6], data[12], data[22]);
 
+	if (type == 0x4) /* Completion Queue */
+		ehea_error("CQ (resource=%lX) state: AER=0x%lX", resource,
+			   data[6]);
+
+	if (type == 0x3) /* Event Queue */
+		ehea_error("EQ (resource=%lX) state: AER=0x%lX", resource,
+			   data[6]);
+
 	ehea_dump(data, length, "error data");
 }
 
diff -Nurp netdev-2.6/drivers/net/ehea/ehea_qmr.h netdev_backup/drivers/net/ehea/ehea_qmr.h
--- netdev-2.6/drivers/net/ehea/ehea_qmr.h	2007-03-22 14:09:39.000000000 +0100
+++ netdev_backup/drivers/net/ehea/ehea_qmr.h	2007-03-22 15:41:50.000000000 +0100
@@ -361,7 +361,12 @@ struct ehea_qp *ehea_create_qp(struct eh
 
 int ehea_destroy_qp(struct ehea_qp *qp);
 
-int ehea_reg_mr_adapter(struct ehea_adapter *adapter);
+int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr);
+
+int ehea_gen_smr(struct ehea_adapter *adapter, struct ehea_mr *old_mr,
+		 struct ehea_mr *shared_mr);
+
+int ehea_rem_mr(struct ehea_mr *mr);
 
 void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
 
