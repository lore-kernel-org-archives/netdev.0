From: Divy Le Ray <None@chelsio.com>
Subject: [PATCH 2/10] cxgb3 - bind qsets on multiport adapter
Date: Tue, 30 Jan 2007 19:43:50 -0800
Message-ID: <20070131034350.8585.68707.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:6383 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932622AbXAaDn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 22:43:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Inform FW about the queue set->interface mapping.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |    2 +
 drivers/net/cxgb3/cxgb3_main.c |   68 ++++++++++++++++++++++++++--------------
 drivers/net/cxgb3/sge.c        |    8 +++++
 3 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 16643f6..8902007 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -46,6 +46,7 @@ enum {				/* adapter flags */
 	FULL_INIT_DONE = (1 << 0),
 	USING_MSI = (1 << 1),
 	USING_MSIX = (1 << 2),
+	QUEUES_BOUND = (1 << 3),
 };
 
 struct rx_desc;
@@ -244,6 +245,7 @@ void t3_free_sge_resources(struct adapte
 void t3_sge_err_intr_handler(struct adapter *adapter);
 intr_handler_t t3_intr_handler(struct adapter *adap, int polling);
 int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev);
+int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p);
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 8044146..7e7ee7a 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -649,6 +649,37 @@ static void init_port_mtus(struct adapte
 	t3_write_reg(adapter, A_TP_MTU_PORT_TABLE, mtus);
 }
 
+static void send_pktsched_cmd(struct adapter *adap, int sched, int qidx, int lo,
+			      int hi, int port)
+{
+	struct sk_buff *skb;
+	struct mngt_pktsched_wr *req;
+
+	skb = alloc_skb(sizeof(*req), GFP_KERNEL | __GFP_NOFAIL);
+	req = (struct mngt_pktsched_wr *)skb_put(skb, sizeof(*req));
+	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_MNGT));
+	req->mngt_opcode = FW_MNGTOPCODE_PKTSCHED_SET;
+	req->sched = sched;
+	req->idx = qidx;
+	req->min = lo;
+	req->max = hi;
+	req->binding = port;
+	t3_mgmt_tx(adap, skb);
+}
+
+static void bind_qsets(struct adapter *adap)
+{
+	int i, j;
+
+	for_each_port(adap, i) {
+		const struct port_info *pi = adap2pinfo(adap, i);
+
+		for (j = 0; j < pi->nqsets; ++j)
+			send_pktsched_cmd(adap, 1, pi->first_qset + j, -1,
+					  -1, i);
+	}
+}
+
 /**
  *	cxgb_up - enable the adapter
  *	@adapter: adapter being enabled
@@ -708,6 +739,11 @@ static int cxgb_up(struct adapter *adap)
 
 	t3_sge_start(adap);
 	t3_intr_enable(adap);
+
+	if ((adap->flags & (USING_MSIX | QUEUES_BOUND)) == USING_MSIX)
+		bind_qsets(adap);
+	adap->flags |= QUEUES_BOUND;
+
 out:
 	return err;
 irq_err:
@@ -1830,34 +1866,18 @@ static int cxgb_extension_ioctl(struct n
 		break;
 	}
 	case CHELSIO_SET_PKTSCHED:{
-		struct sk_buff *skb;
 		struct ch_pktsched_params p;
-		struct mngt_pktsched_wr *req;
 
-		if (!(adapter->flags & FULL_INIT_DONE))
-			return -EIO;	/* uP must be up and running */
+		if (!capable(CAP_NET_ADMIN))
+				return -EPERM;
+		if (!adapter->open_device_map)
+				return -EAGAIN;	/* uP and SGE must be running */
 		if (copy_from_user(&p, useraddr, sizeof(p)))
-			return -EFAULT;
-		skb = alloc_skb(sizeof(*req), GFP_KERNEL);
-		if (!skb)
-			return -ENOMEM;
-		req =
-			(struct mngt_pktsched_wr *)skb_put(skb,
-							sizeof(*req));
-		req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_MNGT));
-		req->mngt_opcode = FW_MNGTOPCODE_PKTSCHED_SET;
-		req->sched = p.sched;
-		req->idx = p.idx;
-		req->min = p.min;
-		req->max = p.max;
-		req->binding = p.binding;
-		printk(KERN_INFO
-			"pktsched: sched %u idx %u min %u max %u binding %u\n",
-			req->sched, req->idx, req->min, req->max,
-			req->binding);
-		skb->priority = 1;
-		offload_tx(&adapter->tdev, skb);
+				return -EFAULT;
+		send_pktsched_cmd(adapter, p.sched, p.idx, p.min, p.max,
+				  p.binding);
 		break;
+			
 	}
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 6c77f4b..ccea06a 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1198,6 +1198,14 @@ static void restart_ctrlq(unsigned long
 		     F_SELEGRCNTX | V_EGRCNTX(q->cntxt_id));
 }
 
+/*
+ * Send a management message through control queue 0
+ */
+int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb)
+{
+	return ctrl_xmit(adap, &adap->sge.qs[0].txq[TXQ_CTRL], skb);
+}
+
 /**
  *	write_ofld_wr - write an offload work request
  *	@adap: the adapter
