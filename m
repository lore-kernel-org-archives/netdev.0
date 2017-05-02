From: sunil.kovvuri@gmail.com
Subject: [PATCH 5/9] net: thunderx: Add basic XDP support
Date: Tue,  2 May 2017 18:36:54 +0530
Message-ID: <1493730418-24606-6-git-send-email-sunil.kovvuri@gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Adds basic XDP support i.e attaching a BPF program to an
interface. Also takes care of allocating separate Tx queues
for XDP path and for network stack packet transmission.

This patch doesn't support handling of any of the XDP actions,
all are treated as XDP_PASS i.e packets will be handed over to
the network stack.

Changes also involve allocating one receive buffer per page in XDP
mode and multiple in normal mode i.e when no BPF program is attached.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |   6 +-
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |  26 +++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 162 ++++++++++++++++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  15 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   9 ++
 5 files changed, 199 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index dca6aed..4a02e61 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -268,9 +268,9 @@ struct nicvf {
 	struct net_device	*netdev;
 	struct pci_dev		*pdev;
 	void __iomem		*reg_base;
+	struct bpf_prog         *xdp_prog;
 #define	MAX_QUEUES_PER_QSET			8
 	struct queue_set	*qs;
-	struct nicvf_cq_poll	*napi[8];
 	void			*iommu_domain;
 	u8			vf_id;
 	u8			sqs_id;
@@ -296,6 +296,7 @@ struct nicvf {
 	/* Queue count */
 	u8			rx_queues;
 	u8			tx_queues;
+	u8			xdp_tx_queues;
 	u8			max_queues;
 
 	u8			node;
@@ -320,6 +321,9 @@ struct nicvf {
 	struct nicvf_drv_stats  __percpu *drv_stats;
 	struct bgx_stats	bgx_stats;
 
+	/* Napi */
+	struct nicvf_cq_poll	*napi[8];
+
 	/* MSI-X  */
 	u8			num_vec;
 	char			irq_name[NIC_VF_MSIX_VECTORS][IFNAMSIZ + 15];
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index a89db5f..b9ece9c 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -721,7 +721,7 @@ static int nicvf_set_channels(struct net_device *dev,
 	struct nicvf *nic = netdev_priv(dev);
 	int err = 0;
 	bool if_up = netif_running(dev);
-	int cqcount;
+	u8 cqcount, txq_count;
 
 	if (!channel->rx_count || !channel->tx_count)
 		return -EINVAL;
@@ -730,10 +730,26 @@ static int nicvf_set_channels(struct net_device *dev,
 	if (channel->tx_count > nic->max_queues)
 		return -EINVAL;
 
+	if (nic->xdp_prog &&
+	    ((channel->tx_count + channel->rx_count) > nic->max_queues)) {
+		netdev_err(nic->netdev,
+			   "XDP mode, RXQs + TXQs > Max %d\n",
+			   nic->max_queues);
+		return -EINVAL;
+	}
+
 	if (if_up)
 		nicvf_stop(dev);
 
-	cqcount = max(channel->rx_count, channel->tx_count);
+	nic->rx_queues = channel->rx_count;
+	nic->tx_queues = channel->tx_count;
+	if (!nic->xdp_prog)
+		nic->xdp_tx_queues = 0;
+	else
+		nic->xdp_tx_queues = channel->rx_count;
+
+	txq_count = nic->xdp_tx_queues + nic->tx_queues;
+	cqcount = max(nic->rx_queues, txq_count);
 
 	if (cqcount > MAX_CMP_QUEUES_PER_QS) {
 		nic->sqs_count = roundup(cqcount, MAX_CMP_QUEUES_PER_QS);
@@ -742,12 +758,10 @@ static int nicvf_set_channels(struct net_device *dev,
 		nic->sqs_count = 0;
 	}
 
-	nic->qs->rq_cnt = min_t(u32, channel->rx_count, MAX_RCV_QUEUES_PER_QS);
-	nic->qs->sq_cnt = min_t(u32, channel->tx_count, MAX_SND_QUEUES_PER_QS);
+	nic->qs->rq_cnt = min_t(u8, nic->rx_queues, MAX_RCV_QUEUES_PER_QS);
+	nic->qs->sq_cnt = min_t(u8, txq_count, MAX_SND_QUEUES_PER_QS);
 	nic->qs->cq_cnt = max(nic->qs->rq_cnt, nic->qs->sq_cnt);
 
-	nic->rx_queues = channel->rx_count;
-	nic->tx_queues = channel->tx_count;
 	err = nicvf_set_real_num_queues(dev, nic->tx_queues, nic->rx_queues);
 	if (err)
 		return err;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 0d79894..9c48873 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -17,6 +17,8 @@
 #include <linux/prefetch.h>
 #include <linux/irq.h>
 #include <linux/iommu.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
 
 #include "nic_reg.h"
 #include "nic.h"
@@ -397,8 +399,10 @@ static void nicvf_request_sqs(struct nicvf *nic)
 
 	if (nic->rx_queues > MAX_RCV_QUEUES_PER_QS)
 		rx_queues = nic->rx_queues - MAX_RCV_QUEUES_PER_QS;
-	if (nic->tx_queues > MAX_SND_QUEUES_PER_QS)
-		tx_queues = nic->tx_queues - MAX_SND_QUEUES_PER_QS;
+
+	tx_queues = nic->tx_queues + nic->xdp_tx_queues;
+	if (tx_queues > MAX_SND_QUEUES_PER_QS)
+		tx_queues = tx_queues - MAX_SND_QUEUES_PER_QS;
 
 	/* Set no of Rx/Tx queues in each of the SQsets */
 	for (sqs = 0; sqs < nic->sqs_count; sqs++) {
@@ -496,6 +500,43 @@ static int nicvf_init_resources(struct nicvf *nic)
 	return 0;
 }
 
+static inline bool nicvf_xdp_rx(struct nicvf *nic,
+				struct bpf_prog *prog,
+				struct cqe_rx_t *cqe_rx)
+{
+	struct xdp_buff xdp;
+	u32 action;
+	u16 len;
+	u64 dma_addr, cpu_addr;
+
+	/* Retrieve packet buffer's DMA address and length */
+	len = *((u16 *)((void *)cqe_rx + (3 * sizeof(u64))));
+	dma_addr = *((u64 *)((void *)cqe_rx + (7 * sizeof(u64))));
+
+	cpu_addr = nicvf_iova_to_phys(nic, dma_addr);
+	if (!cpu_addr)
+		return false;
+
+	xdp.data = phys_to_virt(cpu_addr);
+	xdp.data_end = xdp.data + len;
+
+	rcu_read_lock();
+	action = bpf_prog_run_xdp(prog, &xdp);
+	rcu_read_unlock();
+
+	switch (action) {
+	case XDP_PASS:
+	case XDP_TX:
+	case XDP_ABORTED:
+	case XDP_DROP:
+		/* Pass on all packets to network stack */
+		return false;
+	default:
+		bpf_warn_invalid_xdp_action(action);
+	}
+	return false;
+}
+
 static void nicvf_snd_pkt_handler(struct net_device *netdev,
 				  struct cqe_send_t *cqe_tx,
 				  int budget, int *subdesc_cnt,
@@ -599,6 +640,11 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 			return;
 	}
 
+	/* For XDP, ignore pkts spanning multiple pages */
+	if (nic->xdp_prog && (cqe_rx->rb_cnt == 1))
+		if (nicvf_xdp_rx(snic, nic->xdp_prog, cqe_rx))
+			return;
+
 	skb = nicvf_get_rcv_skb(snic, cqe_rx);
 	if (!skb) {
 		netdev_dbg(nic->netdev, "Packet not received\n");
@@ -1529,6 +1575,117 @@ static int nicvf_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static void nicvf_set_xdp_queues(struct nicvf *nic, bool bpf_attached)
+{
+	u8 cq_count, txq_count;
+
+	/* Set XDP Tx queue count same as Rx queue count */
+	if (!bpf_attached)
+		nic->xdp_tx_queues = 0;
+	else
+		nic->xdp_tx_queues = nic->rx_queues;
+
+	/* If queue count > MAX_CMP_QUEUES_PER_QS, then additional qsets
+	 * needs to be allocated, check how many.
+	 */
+	txq_count = nic->xdp_tx_queues + nic->tx_queues;
+	cq_count = max(nic->rx_queues, txq_count);
+	if (cq_count > MAX_CMP_QUEUES_PER_QS) {
+		nic->sqs_count = roundup(cq_count, MAX_CMP_QUEUES_PER_QS);
+		nic->sqs_count = (nic->sqs_count / MAX_CMP_QUEUES_PER_QS) - 1;
+	} else {
+		nic->sqs_count = 0;
+	}
+
+	/* Set primary Qset's resources */
+	nic->qs->rq_cnt = min_t(u8, nic->rx_queues, MAX_RCV_QUEUES_PER_QS);
+	nic->qs->sq_cnt = min_t(u8, txq_count, MAX_SND_QUEUES_PER_QS);
+	nic->qs->cq_cnt = max_t(u8, nic->qs->rq_cnt, nic->qs->sq_cnt);
+
+	/* Update stack */
+	nicvf_set_real_num_queues(nic->netdev, nic->tx_queues, nic->rx_queues);
+}
+
+static int nicvf_xdp_setup(struct nicvf *nic, struct bpf_prog *prog)
+{
+	struct net_device *dev = nic->netdev;
+	bool if_up = netif_running(nic->netdev);
+	struct bpf_prog *old_prog;
+	bool bpf_attached = false;
+
+	/* For now just support only the usual MTU sized frames */
+	if (prog && (dev->mtu > 1500)) {
+		netdev_warn(dev, "Jumbo frames not yet supported with XDP, current MTU %d.\n",
+			    dev->mtu);
+		return -EOPNOTSUPP;
+	}
+
+	if (prog && prog->xdp_adjust_head)
+		return -EOPNOTSUPP;
+
+	/* ALL SQs attached to CQs i.e same as RQs, are treated as
+	 * XDP Tx queues and more Tx queues are allocated for
+	 * network stack to send pkts out.
+	 *
+	 * No of Tx queues are either same as Rx queues or whatever
+	 * is left in max no of queues possible.
+	 */
+	if ((nic->rx_queues + nic->tx_queues) > nic->max_queues) {
+		netdev_warn(dev,
+			    "Failed to attach BPF prog, RXQs + TXQs > Max %d\n",
+			    nic->max_queues);
+		return -ENOMEM;
+	}
+
+	if (if_up)
+		nicvf_stop(nic->netdev);
+
+	old_prog = xchg(&nic->xdp_prog, prog);
+	/* Detach old prog, if any */
+	if (old_prog)
+		bpf_prog_put(old_prog);
+
+	if (nic->xdp_prog) {
+		/* Attach BPF program */
+		nic->xdp_prog = bpf_prog_add(nic->xdp_prog, nic->rx_queues - 1);
+		if (!IS_ERR(nic->xdp_prog))
+			bpf_attached = true;
+	}
+
+	/* Calculate Tx queues needed for XDP and network stack */
+	nicvf_set_xdp_queues(nic, bpf_attached);
+
+	if (if_up) {
+		/* Reinitialize interface, clean slate */
+		nicvf_open(nic->netdev);
+		netif_trans_update(nic->netdev);
+	}
+
+	return 0;
+}
+
+static int nicvf_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+
+	/* To avoid checks while retrieving buffer address from CQE_RX,
+	 * do not support XDP for T88 pass1.x silicons which are anyway
+	 * not in use widely.
+	 */
+	if (pass1_silicon(nic->pdev))
+		return -EOPNOTSUPP;
+
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return nicvf_xdp_setup(nic, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = !!nic->xdp_prog;
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops nicvf_netdev_ops = {
 	.ndo_open		= nicvf_open,
 	.ndo_stop		= nicvf_stop,
@@ -1539,6 +1696,7 @@ static const struct net_device_ops nicvf_netdev_ops = {
 	.ndo_tx_timeout         = nicvf_tx_timeout,
 	.ndo_fix_features       = nicvf_fix_features,
 	.ndo_set_features       = nicvf_set_features,
+	.ndo_xdp		= nicvf_xdp,
 };
 
 static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index e4a02a9..8c3c571 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -19,14 +19,6 @@
 #include "q_struct.h"
 #include "nicvf_queues.h"
 
-static inline u64 nicvf_iova_to_phys(struct nicvf *nic, dma_addr_t dma_addr)
-{
-	/* Translation is installed only when IOMMU is present */
-	if (nic->iommu_domain)
-		return iommu_iova_to_phys(nic->iommu_domain, dma_addr);
-	return dma_addr;
-}
-
 static void nicvf_get_page(struct nicvf *nic)
 {
 	if (!nic->rb_pageref || !nic->rb_page)
@@ -149,8 +141,10 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, struct rbdr *rbdr,
 {
 	struct pgcache *pgcache = NULL;
 
-	/* Check if request can be accomodated in previous allocated page */
-	if (nic->rb_page &&
+	/* Check if request can be accomodated in previous allocated page.
+	 * But in XDP mode only one buffer per page is permitted.
+	 */
+	if (!nic->pnicvf->xdp_prog && nic->rb_page &&
 	    ((nic->rb_page_offset + buf_len) <= PAGE_SIZE)) {
 		nic->rb_pageref++;
 		goto ret;
@@ -961,6 +955,7 @@ int nicvf_set_qset_resources(struct nicvf *nic)
 
 	nic->rx_queues = qs->rq_cnt;
 	nic->tx_queues = qs->sq_cnt;
+	nic->xdp_tx_queues = 0;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index da48366..07136a2 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -10,6 +10,7 @@
 #define NICVF_QUEUES_H
 
 #include <linux/netdevice.h>
+#include <linux/iommu.h>
 #include "q_struct.h"
 
 #define MAX_QUEUE_SET			128
@@ -312,6 +313,14 @@ struct queue_set {
 
 #define	CQ_ERR_MASK	(CQ_WR_FULL | CQ_WR_DISABLE | CQ_WR_FAULT)
 
+static inline u64 nicvf_iova_to_phys(struct nicvf *nic, dma_addr_t dma_addr)
+{
+	/* Translation is installed only when IOMMU is present */
+	if (nic->iommu_domain)
+		return iommu_iova_to_phys(nic->iommu_domain, dma_addr);
+	return dma_addr;
+}
+
 void nicvf_unmap_sndq_buffers(struct nicvf *nic, struct snd_queue *sq,
 			      int hdr_sqe, u8 subdesc_cnt);
 void nicvf_config_vlan_stripping(struct nicvf *nic,
-- 
2.7.4
