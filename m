From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: Change default Tx work limit size to 256 buffers
Date: Thu, 15 Sep 2011 21:42:43 -0700
Message-ID: <1316148173-11209-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25391 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228Ab1IPEm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:42:57 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the default Tx work limit is 256 buffers or
1/2 of an entire ring instead of a full ring size so that it is much more
likely that we will be able to actually reach the work limit value.
Previously with the value set to an entire ring it would not have been
possible for us to trigger an event due to the fact that the Tx work is
stopped at the point where we cannot place one more buffer on the ring and
it is not restarted until cleanup is complete.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 58482fc..3f5a744 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -53,6 +53,7 @@
 
 /* TX/RX descriptor defines */
 #define IXGBE_DEFAULT_TXD		    512
+#define IXGBE_DEFAULT_TX_WORK		    256
 #define IXGBE_MAX_TXD			   4096
 #define IXGBE_MIN_TXD			     64
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a30f826..0f633ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -804,7 +804,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	struct ixgbe_tx_buffer *tx_buffer;
 	union ixgbe_adv_tx_desc *tx_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
-	u16 budget = q_vector->tx.work_limit;
+	unsigned int budget = q_vector->tx.work_limit;
 	u16 i = tx_ring->next_to_clean;
 
 	tx_buffer = &tx_ring->tx_buffer_info[i];
@@ -891,7 +891,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		ixgbe_tx_timeout_reset(adapter);
 
 		/* the adapter is about to reset, no point in enabling stuff */
-		return budget;
+		return true;
 	}
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
@@ -908,7 +908,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		}
 	}
 
-	return budget;
+	return !!budget;
 }
 
 #ifdef CONFIG_IXGBE_DCA
@@ -5091,7 +5091,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
 
 	/* set default work limits */
-	adapter->tx_work_limit = adapter->tx_ring_count;
+	adapter->tx_work_limit = IXGBE_DEFAULT_TX_WORK;
 
 	/* initialize eeprom parameters */
 	if (ixgbe_init_eeprom_params_generic(hw)) {
-- 
1.7.6
