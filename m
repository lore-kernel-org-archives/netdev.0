From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] igb, ixgbe: netdev_tx_reset_queue incorrectly called from tx init path
Date: Fri,  4 May 2012 04:05:03 -0700
Message-ID: <1336129504-29919-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56123 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755423Ab2EDLFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 07:05:07 -0400
In-Reply-To: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

igb and ixgbe incorrectly call netdev_tx_reset_queue() from
i{gb|xgbe}_clean_tx_ring() this sort of works in most cases except
when the number of real tx queues changes. When the number of real
tx queues changes netdev_tx_reset_queue() only gets called on the
new number of queues so when we reduce the number of queues we risk
triggering the watchdog timer and repeated device resets.

So this is not only a cosmetic issue but causes real bugs. For
example enabling/disabling DCB or FCoE in ixgbe will trigger this.

CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: John Bishop <johnx.bishop@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c        |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 5ec3159..d223500 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2771,8 +2771,6 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 
 	txdctl |= E1000_TXDCTL_QUEUE_ENABLE;
 	wr32(E1000_TXDCTL(reg_idx), txdctl);
-
-	netdev_tx_reset_queue(txring_txq(ring));
 }
 
 /**
@@ -3282,6 +3280,8 @@ static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
 	}
 
+	netdev_tx_reset_queue(txring_txq(tx_ring));
+
 	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
 	memset(tx_ring->tx_buffer_info, 0, size);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 31a2bf7..cfe7d26 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1780,6 +1780,8 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ntc);
 	}
 
+	netdev_tx_reset_queue(txring_txq(tx_ring));
+
 	/* re-map buffers to ring, store next to clean values */
 	ixgbe_alloc_rx_buffers(rx_ring, count);
 	rx_ring->next_to_clean = rx_ntc;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 50f0700..467948e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2671,8 +2671,6 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	/* enable queue */
 	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), txdctl);
 
-	netdev_tx_reset_queue(txring_txq(ring));
-
 	/* TXDCTL.EN will return 0 on 82598 if link is down, so skip it */
 	if (hw->mac.type == ixgbe_mac_82598EB &&
 	    !(IXGBE_READ_REG(hw, IXGBE_LINKS) & IXGBE_LINKS_UP))
@@ -4167,6 +4165,8 @@ static void ixgbe_clean_tx_ring(struct ixgbe_ring *tx_ring)
 		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 	}
 
+	netdev_tx_reset_queue(txring_txq(tx_ring));
+
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
 	memset(tx_ring->tx_buffer_info, 0, size);
 
-- 
1.7.7.6
