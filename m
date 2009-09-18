From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: Allow tx itr specific settings
Date: Fri, 18 Sep 2009 12:46:06 -0700
Message-ID: <20090918194606.28898.37888.stgit@localhost.localdomain>
References: <20090918194533.28898.49436.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:60512
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751827AbZIRTqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 15:46:23 -0400
In-Reply-To: <20090918194533.28898.49436.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson, Shannon <shannon.nelson@intel.com>

Allow the user to set Tx specific itr values.  This only makes sense
when there are separate vectors for Tx and Rx.  When the queues are
doubled up RxTx on the vectors, we still only use the rx itr value.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    6 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c |   75 ++++++++++++++++++++++++++++++-------
 drivers/net/ixgbe/ixgbe_main.c    |   31 +++++++++------
 3 files changed, 83 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index dd688d4..385be60 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -267,7 +267,8 @@ struct ixgbe_adapter {
 	enum ixgbe_fc_mode last_lfc_mode;
 
 	/* Interrupt Throttle Rate */
-	u32 itr_setting;
+	u32 rx_itr_setting;
+	u32 tx_itr_setting;
 	u16 eitr_low;
 	u16 eitr_high;
 
@@ -351,7 +352,8 @@ struct ixgbe_adapter {
 	struct ixgbe_hw_stats stats;
 
 	/* Interrupt Throttle Rate */
-	u32 eitr_param;
+	u32 rx_eitr_param;
+	u32 tx_eitr_param;
 
 	unsigned long state;
 	u64 tx_busy;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 026e94a..53b0a66 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1929,7 +1929,7 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 	ec->tx_max_coalesced_frames_irq = adapter->tx_ring[0].work_limit;
 
 	/* only valid if in constant ITR mode */
-	switch (adapter->itr_setting) {
+	switch (adapter->rx_itr_setting) {
 	case 0:
 		/* throttling disabled */
 		ec->rx_coalesce_usecs = 0;
@@ -1940,9 +1940,25 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 		break;
 	default:
 		/* fixed interrupt rate mode */
-		ec->rx_coalesce_usecs = 1000000/adapter->eitr_param;
+		ec->rx_coalesce_usecs = 1000000/adapter->rx_eitr_param;
 		break;
 	}
+
+	/* only valid if in constant ITR mode */
+	switch (adapter->tx_itr_setting) {
+	case 0:
+		/* throttling disabled */
+		ec->tx_coalesce_usecs = 0;
+		break;
+	case 1:
+		/* dynamic ITR mode */
+		ec->tx_coalesce_usecs = 1;
+		break;
+	default:
+		ec->tx_coalesce_usecs = 1000000/adapter->tx_eitr_param;
+		break;
+	}
+
 	return 0;
 }
 
@@ -1953,6 +1969,14 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	struct ixgbe_q_vector *q_vector;
 	int i;
 
+	/*
+	 * don't accept tx specific changes if we've got mixed RxTx vectors
+	 * test and jump out here if needed before changing the rx numbers
+	 */
+	if ((1000000/ec->tx_coalesce_usecs) != adapter->tx_eitr_param &&
+	    adapter->q_vector[0]->txr_count && adapter->q_vector[0]->rxr_count)
+		return -EINVAL;
+
 	if (ec->tx_max_coalesced_frames_irq)
 		adapter->tx_ring[0].work_limit = ec->tx_max_coalesced_frames_irq;
 
@@ -1963,26 +1987,49 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 			return -EINVAL;
 
 		/* store the value in ints/second */
-		adapter->eitr_param = 1000000/ec->rx_coalesce_usecs;
+		adapter->rx_eitr_param = 1000000/ec->rx_coalesce_usecs;
 
 		/* static value of interrupt rate */
-		adapter->itr_setting = adapter->eitr_param;
+		adapter->rx_itr_setting = adapter->rx_eitr_param;
 		/* clear the lower bit as its used for dynamic state */
-		adapter->itr_setting &= ~1;
+		adapter->rx_itr_setting &= ~1;
 	} else if (ec->rx_coalesce_usecs == 1) {
 		/* 1 means dynamic mode */
-		adapter->eitr_param = 20000;
-		adapter->itr_setting = 1;
+		adapter->rx_eitr_param = 20000;
+		adapter->rx_itr_setting = 1;
 	} else {
 		/*
 		 * any other value means disable eitr, which is best
 		 * served by setting the interrupt rate very high
 		 */
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
-			adapter->eitr_param = IXGBE_MAX_RSC_INT_RATE;
+			adapter->rx_eitr_param = IXGBE_MAX_RSC_INT_RATE;
 		else
-			adapter->eitr_param = IXGBE_MAX_INT_RATE;
-		adapter->itr_setting = 0;
+			adapter->rx_eitr_param = IXGBE_MAX_INT_RATE;
+		adapter->rx_itr_setting = 0;
+	}
+
+	if (ec->tx_coalesce_usecs > 1) {
+		/* check the limits */
+		if ((1000000/ec->tx_coalesce_usecs > IXGBE_MAX_INT_RATE) ||
+		    (1000000/ec->tx_coalesce_usecs < IXGBE_MIN_INT_RATE))
+			return -EINVAL;
+
+		/* store the value in ints/second */
+		adapter->tx_eitr_param = 1000000/ec->tx_coalesce_usecs;
+
+		/* static value of interrupt rate */
+		adapter->tx_itr_setting = adapter->tx_eitr_param;
+
+		/* clear the lower bit as its used for dynamic state */
+		adapter->tx_itr_setting &= ~1;
+	} else if (ec->tx_coalesce_usecs == 1) {
+		/* 1 means dynamic mode */
+		adapter->tx_eitr_param = 10000;
+		adapter->tx_itr_setting = 1;
+	} else {
+		adapter->tx_eitr_param = IXGBE_MAX_INT_RATE;
+		adapter->tx_itr_setting = 0;
 	}
 
 	/* MSI/MSIx Interrupt Mode */
@@ -1992,17 +2039,17 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		for (i = 0; i < num_vectors; i++) {
 			q_vector = adapter->q_vector[i];
 			if (q_vector->txr_count && !q_vector->rxr_count)
-				/* tx vector gets half the rate */
-				q_vector->eitr = (adapter->eitr_param >> 1);
+				/* tx only */
+				q_vector->eitr = adapter->tx_eitr_param;
 			else
 				/* rx only or mixed */
-				q_vector->eitr = adapter->eitr_param;
+				q_vector->eitr = adapter->rx_eitr_param;
 			ixgbe_write_eitr(q_vector);
 		}
 	/* Legacy Interrupt Mode */
 	} else {
 		q_vector = adapter->q_vector[0];
-		q_vector->eitr = adapter->eitr_param;
+		q_vector->eitr = adapter->rx_eitr_param;
 		ixgbe_write_eitr(q_vector);
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 056434c..1aa9f6a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -926,12 +926,12 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			                      r_idx + 1);
 		}
 
-		/* if this is a tx only vector halve the interrupt rate */
 		if (q_vector->txr_count && !q_vector->rxr_count)
-			q_vector->eitr = (adapter->eitr_param >> 1);
+			/* tx only */
+			q_vector->eitr = adapter->tx_eitr_param;
 		else if (q_vector->rxr_count)
-			/* rx only */
-			q_vector->eitr = adapter->eitr_param;
+			/* rx or mixed */
+			q_vector->eitr = adapter->rx_eitr_param;
 
 		ixgbe_write_eitr(q_vector);
 	}
@@ -1359,7 +1359,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		if (adapter->itr_setting & 1)
+		if (adapter->rx_itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter,
@@ -1420,7 +1420,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		if (adapter->itr_setting & 1)
+		if (adapter->rx_itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter,
@@ -1458,10 +1458,10 @@ static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 	if (!ixgbe_clean_tx_irq(q_vector, tx_ring))
 		work_done = budget;
 
-	/* If all Rx work done, exit the polling mode */
+	/* If all Tx work done, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		if (adapter->itr_setting & 1)
+		if (adapter->tx_itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter, ((u64)1 << q_vector->v_idx));
@@ -1848,7 +1848,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
-	                EITR_INTS_PER_SEC_TO_REG(adapter->eitr_param));
+	                EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr_param));
 
 	ixgbe_set_ivar(adapter, 0, 0, 0);
 	ixgbe_set_ivar(adapter, 1, 0, 0);
@@ -2991,7 +2991,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		if (adapter->itr_setting & 1)
+		if (adapter->rx_itr_setting & 1)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter, IXGBE_EIMS_RTX_QUEUE);
@@ -3601,7 +3601,10 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
-		q_vector->eitr = adapter->eitr_param;
+		if (q_vector->txr_count && !q_vector->rxr_count)
+			q_vector->eitr = adapter->tx_eitr_param;
+		else
+			q_vector->eitr = adapter->rx_eitr_param;
 		q_vector->v_idx = q_idx;
 		netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 64);
 		adapter->q_vector[q_idx] = q_vector;
@@ -3870,8 +3873,10 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->fc.disable_fc_autoneg = false;
 
 	/* enable itr by default in dynamic mode */
-	adapter->itr_setting = 1;
-	adapter->eitr_param = 20000;
+	adapter->rx_itr_setting = 1;
+	adapter->rx_eitr_param = 20000;
+	adapter->tx_itr_setting = 1;
+	adapter->tx_eitr_param = 10000;
 
 	/* set defaults for eitr in MegaBytes */
 	adapter->eitr_low = 10;

