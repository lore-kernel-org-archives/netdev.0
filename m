From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next] Driver: Vmxnet3: Extend register dump support
Date: Mon, 21 Sep 2015 20:01:29 -0700
Message-ID: <1442890889-6093-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Bhavesh Davda <bhavesh@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
Acked-by: Srividya Murali <smurali@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 118 ++++++++++++++++++++++++++--------
 drivers/net/vmxnet3/vmxnet3_int.h     |   4 +-
 2 files changed, 92 insertions(+), 30 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index c1d0e7a..a681569 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -183,16 +183,22 @@ vmxnet3_get_sset_count(struct net_device *netdev, int sset)
 }
 
 
-/* Should be multiple of 4 */
-#define NUM_TX_REGS	8
-#define NUM_RX_REGS	12
-
+/* This is a version 2 of the vmxnet3 ethtool_regs which goes hand in hand with
+ * the version 2 of the vmxnet3 support for ethtool(8) --register-dump.
+ * Therefore, if any registers are added, removed or modified, then a version
+ * bump and a corresponding change in the vmxnet3 support for ethtool(8)
+ * --register-dump would be required.
+ */
 static int
 vmxnet3_get_regs_len(struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-	return (adapter->num_tx_queues * NUM_TX_REGS * sizeof(u32) +
-		adapter->num_rx_queues * NUM_RX_REGS * sizeof(u32));
+
+	return ((9 /* BAR1 registers */ +
+		(1 + adapter->intr.num_intrs) +
+		(1 + adapter->num_tx_queues * 17 /* Tx queue registers */) +
+		(1 + adapter->num_rx_queues * 23 /* Rx queue registers */)) *
+		sizeof(u32));
 }
 
 
@@ -342,6 +348,12 @@ vmxnet3_get_ethtool_stats(struct net_device *netdev,
 }
 
 
+/* This is a version 2 of the vmxnet3 ethtool_regs which goes hand in hand with
+ * the version 2 of the vmxnet3 support for ethtool(8) --register-dump.
+ * Therefore, if any registers are added, removed or modified, then a version
+ * bump and a corresponding change in the vmxnet3 support for ethtool(8)
+ * --register-dump would be required.
+ */
 static void
 vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 {
@@ -351,40 +363,90 @@ vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 
 	memset(p, 0, vmxnet3_get_regs_len(netdev));
 
-	regs->version = 1;
+	regs->version = 2;
 
 	/* Update vmxnet3_get_regs_len if we want to dump more registers */
 
-	/* make each ring use multiple of 16 bytes */
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		buf[j++] = adapter->tx_queue[i].tx_ring.next2fill;
-		buf[j++] = adapter->tx_queue[i].tx_ring.next2comp;
-		buf[j++] = adapter->tx_queue[i].tx_ring.gen;
-		buf[j++] = 0;
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_VRRS);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_UVRS);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_DSAL);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_DSAH);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_MACL);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_MACH);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_ICR);
+	buf[j++] = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_ECR);
+
+	buf[j++] = adapter->intr.num_intrs;
+	for (i = 0; i < adapter->intr.num_intrs; i++) {
+		buf[j++] = VMXNET3_READ_BAR0_REG(adapter, VMXNET3_REG_IMR
+						 + i * VMXNET3_REG_ALIGN);
+	}
 
-		buf[j++] = adapter->tx_queue[i].comp_ring.next2proc;
-		buf[j++] = adapter->tx_queue[i].comp_ring.gen;
-		buf[j++] = adapter->tx_queue[i].stopped;
-		buf[j++] = 0;
+	buf[j++] = adapter->num_tx_queues;
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct vmxnet3_tx_queue *tq = &adapter->tx_queue[i];
+
+		buf[j++] = VMXNET3_READ_BAR0_REG(adapter, VMXNET3_REG_TXPROD +
+						 i * VMXNET3_REG_ALIGN);
+
+		buf[j++] = VMXNET3_GET_ADDR_LO(tq->tx_ring.basePA);
+		buf[j++] = VMXNET3_GET_ADDR_HI(tq->tx_ring.basePA);
+		buf[j++] = tq->tx_ring.size;
+		buf[j++] = tq->tx_ring.next2fill;
+		buf[j++] = tq->tx_ring.next2comp;
+		buf[j++] = tq->tx_ring.gen;
+
+		buf[j++] = VMXNET3_GET_ADDR_LO(tq->data_ring.basePA);
+		buf[j++] = VMXNET3_GET_ADDR_HI(tq->data_ring.basePA);
+		buf[j++] = tq->data_ring.size;
+		/* transmit data ring buffer size */
+		buf[j++] = VMXNET3_HDR_COPY_SIZE;
+
+		buf[j++] = VMXNET3_GET_ADDR_LO(tq->comp_ring.basePA);
+		buf[j++] = VMXNET3_GET_ADDR_HI(tq->comp_ring.basePA);
+		buf[j++] = tq->comp_ring.size;
+		buf[j++] = tq->comp_ring.next2proc;
+		buf[j++] = tq->comp_ring.gen;
+
+		buf[j++] = tq->stopped;
 	}
 
+	buf[j++] = adapter->num_rx_queues;
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		buf[j++] = adapter->rx_queue[i].rx_ring[0].next2fill;
-		buf[j++] = adapter->rx_queue[i].rx_ring[0].next2comp;
-		buf[j++] = adapter->rx_queue[i].rx_ring[0].gen;
+		struct vmxnet3_rx_queue *rq = &adapter->rx_queue[i];
+
+		buf[j++] =  VMXNET3_READ_BAR0_REG(adapter, VMXNET3_REG_RXPROD +
+						  i * VMXNET3_REG_ALIGN);
+		buf[j++] =  VMXNET3_READ_BAR0_REG(adapter, VMXNET3_REG_RXPROD2 +
+						  i * VMXNET3_REG_ALIGN);
+
+		buf[j++] = VMXNET3_GET_ADDR_LO(rq->rx_ring[0].basePA);
+		buf[j++] = VMXNET3_GET_ADDR_HI(rq->rx_ring[0].basePA);
+		buf[j++] = rq->rx_ring[0].size;
+		buf[j++] = rq->rx_ring[0].next2fill;
+		buf[j++] = rq->rx_ring[0].next2comp;
+		buf[j++] = rq->rx_ring[0].gen;
+
+		buf[j++] = VMXNET3_GET_ADDR_LO(rq->rx_ring[1].basePA);
+		buf[j++] = VMXNET3_GET_ADDR_HI(rq->rx_ring[1].basePA);
+		buf[j++] = rq->rx_ring[1].size;
+		buf[j++] = rq->rx_ring[1].next2fill;
+		buf[j++] = rq->rx_ring[1].next2comp;
+		buf[j++] = rq->rx_ring[1].gen;
+
+		/* receive data ring */
 		buf[j++] = 0;
-
-		buf[j++] = adapter->rx_queue[i].rx_ring[1].next2fill;
-		buf[j++] = adapter->rx_queue[i].rx_ring[1].next2comp;
-		buf[j++] = adapter->rx_queue[i].rx_ring[1].gen;
 		buf[j++] = 0;
-
-		buf[j++] = adapter->rx_queue[i].comp_ring.next2proc;
-		buf[j++] = adapter->rx_queue[i].comp_ring.gen;
 		buf[j++] = 0;
 		buf[j++] = 0;
-	}
 
+		buf[j++] = VMXNET3_GET_ADDR_LO(rq->comp_ring.basePA);
+		buf[j++] = VMXNET3_GET_ADDR_HI(rq->comp_ring.basePA);
+		buf[j++] = rq->comp_ring.size;
+		buf[j++] = rq->comp_ring.next2proc;
+		buf[j++] = rq->comp_ring.gen;
+	}
 }
 
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 2652245..3f859a5 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.2.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.3.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040200
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040300
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.8.5.6
