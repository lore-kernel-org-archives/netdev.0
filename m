From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 05/22] cxgb4: Add T5 write combining support
Date: Thu, 14 Mar 2013 20:38:51 +0530
Message-ID: <1363273748-25330-6-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6815 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab3CNPPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:15:18 -0400
In-Reply-To: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Rastapur <santosh@chelsio.com>

This patch implements a low latency Write Combining (aka Write Coalescing) work
request path. PCIE maps User Space Doorbell BAR2 region writes to the new
interface to SGE. SGE pulls a new message from PCIE new interface and if its a
coalesced write work request then pushes it for processing. This patch copies
coalesced work request to memory mapped BAR2 space.

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   53 ++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   52 +++++++++++++++++++++-
 3 files changed, 102 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index a91dea6..f8ff30e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -439,6 +439,7 @@ struct sge_txq {
 	spinlock_t db_lock;
 	int db_disabled;
 	unsigned short db_pidx;
+	u64 udb;
 };
 
 struct sge_eth_txq {                /* state for an SGE Ethernet Tx queue */
@@ -543,6 +544,7 @@ enum chip_type {
 
 struct adapter {
 	void __iomem *regs;
+	void __iomem *bar2;
 	struct pci_dev *pdev;
 	struct device *pdev_dev;
 	unsigned int mbox;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3d6d23a..ce1451c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1327,6 +1327,8 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"VLANinsertions     ",
 	"GROpackets         ",
 	"GROmerged          ",
+	"WriteCoalSuccess   ",
+	"WriteCoalFail      ",
 };
 
 static int get_sset_count(struct net_device *dev, int sset)
@@ -1422,11 +1424,25 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
+	u32 val1, val2;
 
 	t4_get_port_stats(adapter, pi->tx_chan, (struct port_stats *)data);
 
 	data += sizeof(struct port_stats) / sizeof(u64);
 	collect_sge_port_stats(adapter, pi, (struct queue_port_stats *)data);
+	data += sizeof(struct queue_port_stats) / sizeof(u64);
+	if (!is_t4(adapter->chip)) {
+		t4_write_reg(adapter, SGE_STAT_CFG, STATSOURCE_T5(7));
+		val1 = t4_read_reg(adapter, SGE_STAT_TOTAL);
+		val2 = t4_read_reg(adapter, SGE_STAT_MATCH);
+		*data = val1 - val2;
+		data++;
+		*data = val2;
+		data++;
+	} else {
+		memset(data, 0, 2 * sizeof(u64));
+		*data += 2;
+	}
 }
 
 /*
@@ -5337,10 +5353,11 @@ static void free_some_resources(struct adapter *adapter)
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
+#define SEGMENT_SIZE 128
 
 static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	int func, i, err;
+	int func, i, err, s_qpp, qpp, num_seg;
 	struct port_info *pi;
 	bool highdma = false;
 	struct adapter *adapter = NULL;
@@ -5420,7 +5437,34 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = t4_prep_adapter(adapter);
 	if (err)
-		goto out_unmap_bar;
+		goto out_unmap_bar0;
+
+	if (!is_t4(adapter->chip)) {
+		s_qpp = QUEUESPERPAGEPF1 * adapter->fn;
+		qpp = 1 << QUEUESPERPAGEPF0_GET(t4_read_reg(adapter,
+		      SGE_EGRESS_QUEUES_PER_PAGE_PF) >> s_qpp);
+		num_seg = PAGE_SIZE / SEGMENT_SIZE;
+
+		/* Each segment size is 128B. Write coalescing is enabled only
+		 * when SGE_EGRESS_QUEUES_PER_PAGE_PF reg value for the
+		 * queue is less no of segments that can be accommodated in
+		 * a page size.
+		 */
+		if (qpp > num_seg) {
+			dev_err(&pdev->dev,
+				"Incorrect number of egress queues per page\n");
+			err = -EINVAL;
+			goto out_unmap_bar0;
+		}
+		adapter->bar2 = ioremap_wc(pci_resource_start(pdev, 2),
+		pci_resource_len(pdev, 2));
+		if (!adapter->bar2) {
+			dev_err(&pdev->dev, "cannot map device bar2 region\n");
+			err = -ENOMEM;
+			goto out_unmap_bar0;
+		}
+	}
+
 	setup_memwin(adapter);
 	err = adap_init0(adapter);
 	setup_memwin_rdma(adapter);
@@ -5552,6 +5596,9 @@ sriov:
  out_free_dev:
 	free_some_resources(adapter);
  out_unmap_bar:
+	if (!is_t4(adapter->chip))
+		iounmap(adapter->bar2);
+ out_unmap_bar0:
 	iounmap(adapter->regs);
  out_free_adapter:
 	kfree(adapter);
@@ -5602,6 +5649,8 @@ static void remove_one(struct pci_dev *pdev)
 
 		free_some_resources(adapter);
 		iounmap(adapter->regs);
+		if (!is_t4(adapter->chip))
+			iounmap(adapter->bar2);
 		kfree(adapter);
 		pci_disable_pcie_error_reporting(pdev);
 		pci_disable_device(pdev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 7b17623..8b47b25 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -816,6 +816,22 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 		*end = 0;
 }
 
+/* This function copies 64 byte coalesced work request to
+ * memory mapped BAR2 space(user space writes).
+ * For coalesced WR SGE, fetches data from the FIFO instead of from Host.
+ */
+static void cxgb_pio_copy(u64 __iomem *dst, u64 *src)
+{
+	int count = 8;
+
+	while (count) {
+		writeq(*src, dst);
+		src++;
+		dst++;
+		count--;
+	}
+}
+
 /**
  *	ring_tx_db - check and potentially ring a Tx queue's doorbell
  *	@adap: the adapter
@@ -826,11 +842,25 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
  */
 static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 {
+	unsigned int *wr, index;
+
 	wmb();            /* write descriptors before telling HW */
 	spin_lock(&q->db_lock);
 	if (!q->db_disabled) {
-		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
-			     QID(q->cntxt_id) | PIDX(n));
+		if (is_t4(adap->chip)) {
+			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
+				     QID(q->cntxt_id) | PIDX(n));
+		} else {
+			if (n == 1) {
+				index = q->pidx ? (q->pidx - 1) : (q->size - 1);
+				wr = (unsigned int *)&q->desc[index];
+				cxgb_pio_copy((u64 __iomem *)
+					      (adap->bar2 + q->udb + 64),
+					      (u64 *)wr);
+			} else
+				writel(n,  adap->bar2 + q->udb + 8);
+			wmb();
+		}
 	}
 	q->db_pidx = q->pidx;
 	spin_unlock(&q->db_lock);
@@ -2151,11 +2181,27 @@ err:
 
 static void init_txq(struct adapter *adap, struct sge_txq *q, unsigned int id)
 {
+	q->cntxt_id = id;
+	if (!is_t4(adap->chip)) {
+		unsigned int s_qpp;
+		unsigned short udb_density;
+		unsigned long qpshift;
+		int page;
+
+		s_qpp = QUEUESPERPAGEPF1 * adap->fn;
+		udb_density = 1 << QUEUESPERPAGEPF0_GET((t4_read_reg(adap,
+				SGE_EGRESS_QUEUES_PER_PAGE_PF) >> s_qpp));
+		qpshift = PAGE_SHIFT - ilog2(udb_density);
+		q->udb = q->cntxt_id << qpshift;
+		q->udb &= PAGE_MASK;
+		page = q->udb / PAGE_SIZE;
+		q->udb += (q->cntxt_id - (page * udb_density)) * 128;
+	}
+
 	q->in_use = 0;
 	q->cidx = q->pidx = 0;
 	q->stops = q->restarts = 0;
 	q->stat = (void *)&q->desc[q->size];
-	q->cntxt_id = id;
 	spin_lock_init(&q->db_lock);
 	adap->sge.egr_map[id - adap->sge.egr_start] = q;
 }
-- 
1.7.1
