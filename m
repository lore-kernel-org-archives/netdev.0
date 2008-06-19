From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2/4] e1000: add module option to set transmit descriptor size
Date: Thu, 19 Jun 2008 17:18:50 -0400
Message-ID: <20080619211850.GD22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135AbYFSVSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 17:18:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch added the TxDescPower parameter to the e1000 module.  This
parameter represents the size-order of each transmit descriptor.  The
valid size for descriptors would be 2^7 (128) - 2^12 (4096) bytes each.
As this value decreases one may want to consider increasing the
TxDescriptors value to maintain the same amount of frame memory.  This
patch does not change the defaults for any particular hardware model, so
this will not have an effect on existing users.

The purpose of the patch is to address Tx Timeouts on 82545 and 82546
chips that can show up during high-stress situations.  Decreasing the
transmit descriptor size can shorten the amount of time that will be
spent DMAing frames to the hardware and can reduce the likely-hood that
Tx Timeouts will occur.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/e1000/e1000.h       |    6 ++++++
 drivers/net/e1000/e1000_main.c  |   12 ++----------
 drivers/net/e1000/e1000_param.c |   33 +++++++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 31feae1..67b3e2f 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -103,6 +103,11 @@ struct e1000_adapter;
 #define E1000_MIN_TXD                       80
 #define E1000_MAX_82544_TXD               4096
 
+#define E1000_DEFAULT_TXD_PWR               12
+#define E1000_MAX_TXD_PWR                   12
+#define E1000_MIN_TXD_PWR                    7
+#define E1000_MAX_82571_TXD_PWR             13
+
 #define E1000_DEFAULT_RXD                  256
 #define E1000_MAX_RXD                      256
 #define E1000_MIN_RXD                       80
@@ -284,6 +289,7 @@ struct e1000_adapter {
 	atomic_t tx_fifo_stall;
 	bool pcix_82544;
 	bool detect_tx_hung;
+	u32 tx_desc_pwr;
 
 	/* RX */
 #ifdef CONFIG_E1000_NAPI
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index af6846d..0dc1ef0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3061,9 +3061,6 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	return false;
 }
 
-#define E1000_MAX_TXD_PWR	12
-#define E1000_MAX_DATA_PER_TXD	(1<<E1000_MAX_TXD_PWR)
-
 static int
 e1000_tx_map(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
              struct sk_buff *skb, unsigned int first, unsigned int max_per_txd,
@@ -3335,8 +3332,8 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_tx_ring *tx_ring;
-	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
-	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
+	unsigned int max_txd_pwr = adapter->tx_desc_pwr;
+	unsigned int first, max_per_txd = (1 << max_txd_pwr);
 	unsigned int tx_flags = 0;
 	unsigned int len = skb->len - skb->data_len;
 	unsigned long flags;
@@ -3357,11 +3354,6 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-	/* 82571 and newer doesn't need the workaround that limited descriptor
-	 * length to 4kB */
-	if (adapter->hw.mac_type >= e1000_82571)
-		max_per_txd = 8192;
-
 	mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index e6565ce..ebaac5d 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -59,6 +59,18 @@
  */
 E1000_PARAM(TxDescriptors, "Number of transmit descriptors");
 
+/* Transmit Descriptor Power
+ *
+ * Valid Range: 7-12
+ * This value represents the size-order of each transmit descriptor.
+ * The valid size for descriptors would be 2^7 (128) - 2^12 (4096) bytes
+ * each.  As this value decreases one may want to consider increasing
+ * the TxDescriptors value to maintain the same amount of frame memory.
+ *
+ * Default Value: 12
+ */
+E1000_PARAM(TxDescPower, "Binary exponential size (2^X) of each transmit descriptor");
+
 /* Receive Descriptor Count
  *
  * Valid Range: 80-256 for 82542 and 82543 gigabit ethernet controllers
@@ -314,6 +328,27 @@ e1000_check_options(struct e1000_adapter *adapter)
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			tx_ring[i].count = tx_ring->count;
 	}
+	{ /* Transmit Descriptor Power */
+		struct e1000_option opt = {
+			.type = range_option,
+			.name = "Transmit Descriptor Power",
+			.err  = "using default of "
+			 	__MODULE_STRING(E1000_DEFAULT_TXD_PWR),
+			.def  = adapter->hw.mac_type < e1000_82571 ?
+				E1000_MAX_TXD_PWR : E1000_MAX_82571_TXD_PWR,
+			.arg  = { .r = { .min = E1000_MIN_TXD_PWR }}
+		};
+		opt.arg.r.max = adapter->hw.mac_type < e1000_82571 ?
+			E1000_MAX_TXD_PWR : E1000_MAX_82571_TXD_PWR;
+
+		if (num_TxDescPower > bd) {
+			adapter->tx_desc_pwr = TxDescPower[bd];
+			e1000_validate_option(&adapter->tx_desc_pwr, &opt, adapter);
+		} else {
+			adapter->tx_desc_pwr = opt.def;
+		}
+	}
+
 	{ /* Receive Descriptor Count */
 		struct e1000_option opt = {
 			.type = range_option,
-- 
1.5.2.1

