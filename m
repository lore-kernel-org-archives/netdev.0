From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] igb: fix race condition with PTP_TX_IN_PROGRESS bits
Date: Tue,  6 Jun 2017 01:58:02 -0700
Message-ID: <20170606085809.78571-5-jeffrey.t.kirsher@intel.com>
References: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30962 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751422AbdFFI6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:16 -0400
In-Reply-To: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Hardware related to the igb driver has a limitation of only handling one
Tx timestamp at a time. Thus, the driver uses a state bit lock to
enforce that only one timestamp request is honored at a time.

Unfortunately this suffers from a simple race condition. The bit lock is
not cleared until after skb_tstamp_tx() is called notifying the stack of
a new Tx timestamp. Even a well behaved application which sends only one
timestamp request at once and waits for a response might wake up and
send a new packet before the bit lock is cleared. This results in
needlessly dropping some Tx timestamp requests.

We can fix this by unlocking the state bit as soon as we read the
Timestamp register, as this is the first point at which it is safe to
unlock.

To avoid issues with the skb pointer, we'll use a copy of the pointer
and set the global variable in the driver structure to NULL first. This
ensures that the next timestamp request does not modify our local copy
of the skb pointer.

This ensures that well behaved applications do not accidentally race
with the unlock bit. Obviously an application which sends multiple Tx
timestamp requests at once will still only timestamp one packet at
a time. Unfortunately there is nothing we can do about this.

Reported-by: David Mirabito <davidm@metamako.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index d333d6d80194..ffd2c7c36d9c 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -721,6 +721,7 @@ void igb_ptp_rx_hang(struct igb_adapter *adapter)
  **/
 static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 {
+	struct sk_buff *skb = adapter->ptp_tx_skb;
 	struct e1000_hw *hw = &adapter->hw;
 	struct skb_shared_hwtstamps shhwtstamps;
 	u64 regval;
@@ -748,10 +749,17 @@ static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 	shhwtstamps.hwtstamp =
 		ktime_add_ns(shhwtstamps.hwtstamp, adjust);
 
-	skb_tstamp_tx(adapter->ptp_tx_skb, &shhwtstamps);
-	dev_kfree_skb_any(adapter->ptp_tx_skb);
+	/* Clear the lock early before calling skb_tstamp_tx so that
+	 * applications are not woken up before the lock bit is clear. We use
+	 * a copy of the skb pointer to ensure other threads can't change it
+	 * while we're notifying the stack.
+	 */
 	adapter->ptp_tx_skb = NULL;
 	clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
+
+	/* Notify the stack and free the skb after we've unlocked */
+	skb_tstamp_tx(skb, &shhwtstamps);
+	dev_kfree_skb_any(skb);
 }
 
 /**
-- 
2.12.2
