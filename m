From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: don't warn every time we clear an Rx timestamp register
Date: Sat, 11 Feb 2017 21:30:25 -0800
Message-ID: <20170212053028.98581-12-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:30258 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdBLFad (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:33 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The intent of this message was to indicate to a user that we might have
missed a timestamp event for a valid packet. The original method of
detecting the missed events relied on waiting until all 4 registers were
filled.

A recent commit d55458c0cd7a5 ("i40e: replace PTP Rx timestamp hang
logic") replaced this logic with much better detection
scheme that could detect a stalled Rx timestamp register even when other
registers were still functional.

The new logic means that a message will be displayed almost as soon as
a timestamp for a dropped frame occurs. This new logic highlights that
the hardware will attempt timestamp for frames which it later decides to
drop. The most prominent example is when a multicast PTP frame is
received on a multicast address that we are not subscribed to.

Because the hardware initiates the Rx timestamp as soon as possible, it
will latch an RXTIME register, but then drop the packet.

This results in users being confused by the message as they are not
expecting to see dropped timestamp messages unless their application
also indicates that timestamps were missing.

Resolve this by reducing the severity and frequency of the displayed
message. We now only print the message if 3 or 4 of the RXTIME registers
are stalled and get cleared within the same watchdog event. This ensures
that the common case does not constantly display the message.
Additionally, since the message is likely not as meaningful to most
users, reduce the message to a dev_dbg instead of a dev_warn.

Users can still get a count of the number of timestamps dropped by
reading the ethtool statistics value, if necessary.

Change-ID: I35494442226a444c418dfb4f91a3070d06c8435c
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 9e49ffa..2caee35 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -280,7 +280,7 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
-	int i;
+	unsigned int i, cleared = 0;
 
 	/* Since we cannot turn off the Rx timestamp logic if the device is
 	 * configured for Tx timestamping, we check if Rx timestamping is
@@ -306,14 +306,25 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 		    time_is_before_jiffies(pf->latch_events[i] + HZ)) {
 			rd32(hw, I40E_PRTTSYN_RXTIME_H(i));
 			pf->latch_event_flags &= ~BIT(i);
-			pf->rx_hwtstamp_cleared++;
-			dev_warn(&pf->pdev->dev,
-				 "Clearing a missed Rx timestamp event for RXTIME[%d]\n",
-				 i);
+			cleared++;
 		}
 	}
 
 	spin_unlock_bh(&pf->ptp_rx_lock);
+
+	/* Log a warning if more than 2 timestamps got dropped in the same
+	 * check. We don't want to warn about all drops because it can occur
+	 * in normal scenarios such as PTP frames on multicast addresses we
+	 * aren't listening to. However, administrator should know if this is
+	 * the reason packets aren't receiving timestamps.
+	 */
+	if (cleared > 2)
+		dev_dbg(&pf->pdev->dev,
+			"Dropped %d missed RXTIME timestamp events\n",
+			cleared);
+
+	/* Finally, update the rx_hwtstamp_cleared counter */
+	pf->rx_hwtstamp_cleared += cleared;
 }
 
 /**
-- 
2.10.2
