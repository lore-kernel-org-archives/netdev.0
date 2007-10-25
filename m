From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/4] e1000e: Fix PBA calculation for jumbo frame packets
Date: Thu, 25 Oct 2007 13:57:53 -0700
Message-ID: <20071025205753.32645.28837.stgit@localhost.localdomain>
References: <20071025205744.32645.59503.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38731 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427AbXJYU56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 16:57:58 -0400
In-Reply-To: <20071025205744.32645.59503.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon inspection the rx FIFO size calculation code was found to have
2 significant flaws: A superfluous minus sign resulting in the
wrong size to be used for jumbo frames on 82573 and ich9, as well
as that this code rewrote the read-only adapter->pba variable
resulting in different values at each run.

Without this patch jumbo's will work but performance will be
awkward since the TX size is not adequate for two whole frames.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 46c5ac6..e87ed31 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2328,8 +2328,11 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tx_space, min_tx_space, min_rx_space;
+	u32 pba;
 	u16 hwm;
 
+	ew32(PBA, adapter->pba);
+
 	if (mac->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN ) {
 		/* To maintain wire speed transmits, the Tx FIFO should be
 		 * large enough to accommodate two full transmit packets,
@@ -2337,11 +2340,11 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		 * the Rx FIFO should be large enough to accommodate at least
 		 * one full receive packet and is similarly rounded up and
 		 * expressed in KB. */
-		adapter->pba = er32(PBA);
+		pba = er32(PBA);
 		/* upper 16 bits has Tx packet buffer allocation size in KB */
-		tx_space = adapter->pba >> 16;
+		tx_space = pba >> 16;
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
-		adapter->pba &= 0xffff;
+		pba &= 0xffff;
 		/* the tx fifo also stores 16 bytes of information about the tx
 		 * but don't include ethernet FCS because hardware appends it */
 		min_tx_space = (mac->max_frame_size +
@@ -2357,20 +2360,21 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		/* If current Tx allocation is less than the min Tx FIFO size,
 		 * and the min Tx FIFO size is less than the current Rx FIFO
 		 * allocation, take space away from current Rx allocation */
-		if (tx_space < min_tx_space &&
-		    ((min_tx_space - tx_space) < adapter->pba)) {
-			adapter->pba -= - (min_tx_space - tx_space);
+		if ((tx_space < min_tx_space) &&
+		    ((min_tx_space - tx_space) < pba)) {
+			pba -= min_tx_space - tx_space;
 
 			/* if short on rx space, rx wins and must trump tx
 			 * adjustment or use Early Receive if available */
-			if ((adapter->pba < min_rx_space) &&
+			if ((pba < min_rx_space) &&
 			    (!(adapter->flags & FLAG_HAS_ERT)))
 				/* ERT enabled in e1000_configure_rx */
-				adapter->pba = min_rx_space;
+				pba = min_rx_space;
 		}
+
+		ew32(PBA, pba);
 	}
 
-	ew32(PBA, adapter->pba);
 
 	/* flow control settings */
 	/* The high water mark must be low enough to fit one full frame
