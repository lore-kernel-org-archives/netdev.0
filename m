From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix warning fallout from recent NAPI interface
 changes.
Date: Fri, 26 Dec 2008 15:12:07 -0800 (PST)
Message-ID: <20081226.151207.150273521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40792
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752215AbYLZXMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 18:12:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just pushed the following into net-next-2.6

net: Fix warning fallout from recent NAPI interface changes.

When we removed the network device argument from several
NAPI interfaces in 908a7a16b852ffd618a9127be8d62432182d81b4
("net: Remove unused netdev arg from some NAPI interfaces.")
several drivers now started getting unused variable warnings.

This fixes those up.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/nes/nes_nic.c |    1 -
 drivers/net/atl1e/atl1e_main.c      |    1 -
 drivers/net/b44.c                   |    1 -
 drivers/net/bnx2x_main.c            |    1 -
 drivers/net/chelsio/sge.c           |    3 ---
 drivers/net/ixgb/ixgb_main.c        |    1 -
 drivers/net/myri10ge/myri10ge.c     |    1 -
 drivers/net/qla3xxx.c               |    1 -
 drivers/net/qlge/qlge_main.c        |    1 -
 drivers/net/s2io.c                  |    2 --
 drivers/net/sfc/efx.c               |    1 -
 11 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 80e7a4d..57a47cf 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -99,7 +99,6 @@ static int nics_per_function = 1;
 static int nes_netdev_poll(struct napi_struct *napi, int budget)
 {
 	struct nes_vnic *nesvnic = container_of(napi, struct nes_vnic, napi);
-	struct net_device *netdev = nesvnic->netdev;
 	struct nes_device *nesdev = nesvnic->nesdev;
 	struct nes_hw_nic_cq *nescq = &nesvnic->nic_cq;
 
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index a72a461..bb9094d 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1501,7 +1501,6 @@ static int atl1e_clean(struct napi_struct *napi, int budget)
 {
 	struct atl1e_adapter *adapter =
 			container_of(napi, struct atl1e_adapter, napi);
-	struct net_device *netdev  = adapter->netdev;
 	struct pci_dev    *pdev    = adapter->pdev;
 	u32 imr_data;
 	int work_done = 0;
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 934a950..0e7470a 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -846,7 +846,6 @@ static int b44_rx(struct b44 *bp, int budget)
 static int b44_poll(struct napi_struct *napi, int budget)
 {
 	struct b44 *bp = container_of(napi, struct b44, napi);
-	struct net_device *netdev = bp->dev;
 	int work_done;
 
 	spin_lock_irq(&bp->lock);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 02ab9b0..ef8103b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1592,7 +1592,6 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 {
 	struct bnx2x_fastpath *fp = fp_cookie;
 	struct bnx2x *bp = fp->bp;
-	struct net_device *dev = bp->dev;
 	int index = FP_IDX(fp);
 
 	/* Return here if interrupt is disabled */
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 7896468..d984b79 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1609,7 +1609,6 @@ static int process_pure_responses(struct adapter *adapter)
 int t1_poll(struct napi_struct *napi, int budget)
 {
 	struct adapter *adapter = container_of(napi, struct adapter, napi);
-	struct net_device *dev = adapter->port[0].dev;
 	int work_done = process_responses(adapter, budget);
 
 	if (likely(work_done < budget)) {
@@ -1627,8 +1626,6 @@ irqreturn_t t1_interrupt(int irq, void *data)
 	int handled;
 
 	if (likely(responses_pending(adapter))) {
-		struct net_device *dev = sge->netdev;
-
 		writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
 
 		if (napi_schedule_prep(&adapter->napi)) {
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 679125b..eee28d3 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1742,7 +1742,6 @@ static int
 ixgb_clean(struct napi_struct *napi, int budget)
 {
 	struct ixgb_adapter *adapter = container_of(napi, struct ixgb_adapter, napi);
-	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 
 	ixgb_clean_tx_irq(adapter);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 2da3ce1..5e70180 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1503,7 +1503,6 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 {
 	struct myri10ge_slice_state *ss =
 	    container_of(napi, struct myri10ge_slice_state, napi);
-	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
 #ifdef CONFIG_MYRI10GE_DCA
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 33e8e62..189ec29 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2284,7 +2284,6 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 static int ql_poll(struct napi_struct *napi, int budget)
 {
 	struct ql3_adapter *qdev = container_of(napi, struct ql3_adapter, napi);
-	struct net_device *ndev = qdev->ndev;
 	int rx_cleaned = 0, tx_cleaned = 0;
 	unsigned long hw_flags;
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 4070d53..718a7bd 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1732,7 +1732,6 @@ static irqreturn_t qlge_msix_tx_isr(int irq, void *dev_id)
 static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring = dev_id;
-	struct ql_adapter *qdev = rx_ring->qdev;
 	netif_rx_schedule(&rx_ring->napi);
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 748b4cb..f5c57c0 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2866,7 +2866,6 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 {
 	struct s2io_nic *nic = container_of(napi, struct s2io_nic, napi);
 	struct ring_info *ring;
-	struct net_device *dev = nic->dev;
 	struct config_param *config;
 	struct mac_info *mac_control;
 	int pkts_processed = 0;
@@ -4330,7 +4329,6 @@ static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 	struct ring_info *ring = (struct ring_info *)dev_id;
 	struct s2io_nic *sp = ring->nic;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
-	struct net_device *dev = sp->dev;
 
 	if (unlikely(!is_s2io_card_up(sp)))
 		return IRQ_HANDLED;
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5cc59e6..7673fd9 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -216,7 +216,6 @@ static int efx_poll(struct napi_struct *napi, int budget)
 {
 	struct efx_channel *channel =
 		container_of(napi, struct efx_channel, napi_str);
-	struct net_device *napi_dev = channel->napi_dev;
 	int rx_packets;
 
 	EFX_TRACE(channel->efx, "channel %d NAPI poll executing on CPU %d\n",
-- 
1.5.6.5

