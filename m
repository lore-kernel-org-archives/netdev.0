From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCHv6 03/10] ib_core: RDMAoE support only QP1
Date: Mon, 16 Nov 2009 17:53:28 +0200
Message-ID: <20091116155328.GD2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ewg <ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/ewg>
List-Post: <mailto:ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
List-Help: <mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=subscribe>
Sender: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
Errors-To: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
List-Id: netdev.vger.kernel.org

Since RDMAoE is using Ethernet as its link layer, there is no need for QP0. QP1
is still needed since it handles communications between CM agents. This patch
will create only QP1 for RDMAoE ports.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/core/agent.c |   39 +++++++++++++++++++++++++--------------
 drivers/infiniband/core/mad.c   |   37 +++++++++++++++++++++++++++++--------
 2 files changed, 54 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/core/agent.c b/drivers/infiniband/core/agent.c
index ae7c288..45c6d20 100644
--- a/drivers/infiniband/core/agent.c
+++ b/drivers/infiniband/core/agent.c
@@ -48,6 +48,8 @@
 struct ib_agent_port_private {
 	struct list_head port_list;
 	struct ib_mad_agent *agent[2];
+	struct ib_device    *device;
+	u8		     port_num;
 };
 
 static DEFINE_SPINLOCK(ib_agent_port_list_lock);
@@ -58,11 +60,10 @@ __ib_get_agent_port(struct ib_device *device, int port_num)
 {
 	struct ib_agent_port_private *entry;
 
-	list_for_each_entry(entry, &ib_agent_port_list, port_list) {
-		if (entry->agent[0]->device == device &&
-		    entry->agent[0]->port_num == port_num)
+	list_for_each_entry(entry, &ib_agent_port_list, port_list)
+		if (entry->device == device && entry->port_num == port_num)
 			return entry;
-	}
+
 	return NULL;
 }
 
@@ -146,6 +147,7 @@ int ib_agent_port_open(struct ib_device *device, int port_num)
 	struct ib_agent_port_private *port_priv;
 	unsigned long flags;
 	int ret;
+	enum rdma_transport_type tt;
 
 	/* Create new device info */
 	port_priv = kzalloc(sizeof *port_priv, GFP_KERNEL);
@@ -155,14 +157,17 @@ int ib_agent_port_open(struct ib_device *device, int port_num)
 		goto error1;
 	}
 
-	/* Obtain send only MAD agent for SMI QP */
-	port_priv->agent[0] = ib_register_mad_agent(device, port_num,
-						    IB_QPT_SMI, NULL, 0,
-						    &agent_send_handler,
-						    NULL, NULL);
-	if (IS_ERR(port_priv->agent[0])) {
-		ret = PTR_ERR(port_priv->agent[0]);
-		goto error2;
+	tt = rdma_port_get_transport(device, port_num);
+	if (tt == RDMA_TRANSPORT_IB) {
+		/* Obtain send only MAD agent for SMI QP */
+		port_priv->agent[0] = ib_register_mad_agent(device, port_num,
+							    IB_QPT_SMI, NULL, 0,
+							    &agent_send_handler,
+							    NULL, NULL);
+		if (IS_ERR(port_priv->agent[0])) {
+			ret = PTR_ERR(port_priv->agent[0]);
+			goto error2;
+		}
 	}
 
 	/* Obtain send only MAD agent for GSI QP */
@@ -175,6 +180,9 @@ int ib_agent_port_open(struct ib_device *device, int port_num)
 		goto error3;
 	}
 
+	port_priv->device = device;
+	port_priv->port_num = port_num;
+
 	spin_lock_irqsave(&ib_agent_port_list_lock, flags);
 	list_add_tail(&port_priv->port_list, &ib_agent_port_list);
 	spin_unlock_irqrestore(&ib_agent_port_list_lock, flags);
@@ -182,7 +190,8 @@ int ib_agent_port_open(struct ib_device *device, int port_num)
 	return 0;
 
 error3:
-	ib_unregister_mad_agent(port_priv->agent[0]);
+	if (tt == RDMA_TRANSPORT_IB)
+		ib_unregister_mad_agent(port_priv->agent[0]);
 error2:
 	kfree(port_priv);
 error1:
@@ -205,7 +214,9 @@ int ib_agent_port_close(struct ib_device *device, int port_num)
 	spin_unlock_irqrestore(&ib_agent_port_list_lock, flags);
 
 	ib_unregister_mad_agent(port_priv->agent[1]);
-	ib_unregister_mad_agent(port_priv->agent[0]);
+	if (rdma_port_get_transport(device, port_num) == RDMA_TRANSPORT_IB)
+		ib_unregister_mad_agent(port_priv->agent[0]);
+
 	kfree(port_priv);
 	return 0;
 }
diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index 28a47a8..857049c 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -2610,6 +2610,9 @@ static void cleanup_recv_queue(struct ib_mad_qp_info *qp_info)
 	struct ib_mad_private *recv;
 	struct ib_mad_list_head *mad_list;
 
+	if (!qp_info->qp)
+		return;
+
 	while (!list_empty(&qp_info->recv_queue.list)) {
 
 		mad_list = list_entry(qp_info->recv_queue.list.next,
@@ -2651,6 +2654,9 @@ static int ib_mad_port_start(struct ib_mad_port_private *port_priv)
 
 	for (i = 0; i < IB_MAD_QPS_CORE; i++) {
 		qp = port_priv->qp_info[i].qp;
+		if (!qp)
+			continue;
+
 		/*
 		 * PKey index for QP1 is irrelevant but
 		 * one is needed for the Reset to Init transition
@@ -2692,6 +2698,9 @@ static int ib_mad_port_start(struct ib_mad_port_private *port_priv)
 	}
 
 	for (i = 0; i < IB_MAD_QPS_CORE; i++) {
+		if (!port_priv->qp_info[i].qp)
+			continue;
+
 		ret = ib_mad_post_receive_mads(&port_priv->qp_info[i], NULL);
 		if (ret) {
 			printk(KERN_ERR PFX "Couldn't post receive WRs\n");
@@ -2770,6 +2779,9 @@ error:
 
 static void destroy_mad_qp(struct ib_mad_qp_info *qp_info)
 {
+	if (!qp_info->qp)
+		return;
+
 	ib_destroy_qp(qp_info->qp);
 	kfree(qp_info->snoop_table);
 }
@@ -2785,6 +2797,7 @@ static int ib_mad_port_open(struct ib_device *device,
 	struct ib_mad_port_private *port_priv;
 	unsigned long flags;
 	char name[sizeof "ib_mad123"];
+	int has_smi;
 
 	/* Create new device info */
 	port_priv = kzalloc(sizeof *port_priv, GFP_KERNEL);
@@ -2800,7 +2813,11 @@ static int ib_mad_port_open(struct ib_device *device,
 	init_mad_qp(port_priv, &port_priv->qp_info[0]);
 	init_mad_qp(port_priv, &port_priv->qp_info[1]);
 
-	cq_size = (mad_sendq_size + mad_recvq_size) * 2;
+	cq_size = mad_sendq_size + mad_recvq_size;
+	has_smi = rdma_port_get_transport(device, port_num) == RDMA_TRANSPORT_IB;
+	if (has_smi)
+		cq_size *= 2;
+
 	port_priv->cq = ib_create_cq(port_priv->device,
 				     ib_mad_thread_completion_handler,
 				     NULL, port_priv, cq_size, 0);
@@ -2824,9 +2841,11 @@ static int ib_mad_port_open(struct ib_device *device,
 		goto error5;
 	}
 
-	ret = create_mad_qp(&port_priv->qp_info[0], IB_QPT_SMI);
-	if (ret)
-		goto error6;
+	if (has_smi) {
+		ret = create_mad_qp(&port_priv->qp_info[0], IB_QPT_SMI);
+		if (ret)
+			goto error6;
+	}
 	ret = create_mad_qp(&port_priv->qp_info[1], IB_QPT_GSI);
 	if (ret)
 		goto error7;
@@ -2915,7 +2934,8 @@ static void ib_mad_init_device(struct ib_device *device)
 	int start, end, i;
 	enum rdma_transport_type tt;
 
-	if (!rdma_is_transport_supported(device, RDMA_TRANSPORT_IB))
+	if (!rdma_is_transport_supported(device, RDMA_TRANSPORT_IB) &&
+	    !rdma_is_transport_supported(device, RDMA_TRANSPORT_RDMAOE))
 		return;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH) {
@@ -2928,7 +2948,7 @@ static void ib_mad_init_device(struct ib_device *device)
 
 	for (i = start; i <= end; i++) {
 		tt = rdma_port_get_transport(device, i);
-		if (tt != RDMA_TRANSPORT_IB)
+		if (tt != RDMA_TRANSPORT_IB && tt != RDMA_TRANSPORT_RDMAOE)
 			continue;
 
 		if (ib_mad_port_open(device, i)) {
@@ -2956,7 +2976,8 @@ error:
 	i--;
 
 	while (i >= start) {
-		if (rdma_port_get_transport(device, i) == RDMA_TRANSPORT_IB) {
+		tt = rdma_port_get_transport(device, i);
+		if (tt == RDMA_TRANSPORT_IB || tt == RDMA_TRANSPORT_RDMAOE) {
 			if (ib_agent_port_close(device, i))
 				printk(KERN_ERR PFX "Couldn't close %s port %d "
 				       "for agents\n",
@@ -2983,7 +3004,7 @@ static void ib_mad_remove_device(struct ib_device *device)
 	}
 	for (i = 0; i < num_ports; i++, cur_port++) {
 		tt = rdma_port_get_transport(device, i);
-		if (tt == RDMA_TRANSPORT_IB) {
+		if (tt == RDMA_TRANSPORT_IB || tt == RDMA_TRANSPORT_RDMAOE) {
 			if (ib_agent_port_close(device, cur_port))
 				printk(KERN_ERR PFX "Couldn't close %s port %d "
 				       "for agents\n",
-- 
1.6.5.2
