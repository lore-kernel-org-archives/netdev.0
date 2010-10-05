From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [stable-2.6.32 PATCH] igb: rx_fifo_errors counter fix
Date: Tue, 05 Oct 2010 16:04:09 -0700
Message-ID: <20101005230407.24172.84596.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:49476
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753225Ab0JEXEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 19:04:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Alexey Vlasov reported insane rx_queue_drop_packet_count
(rx_fifo_errors) values.

IGB drivers is doing an accumulation for 82575, instead using a zero
value for rqdpc_total.

Reported-by: Alexey Vlasov <renton@renton.name>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8111776..a13705b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3552,6 +3552,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 phy_tmp;
+	unsigned long rqdpc_total = 0;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
@@ -3645,7 +3646,6 @@ void igb_update_stats(struct igb_adapter *adapter)
 
 	if (hw->mac.type != e1000_82575) {
 		u32 rqdpc_tmp;
-		u64 rqdpc_total = 0;
 		int i;
 		/* Read out drops stats per RX queue.  Notice RQDPC (Receive
 		 * Queue Drop Packet Count) stats only gets incremented, if
@@ -3660,7 +3660,6 @@ void igb_update_stats(struct igb_adapter *adapter)
 			adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
 			rqdpc_total += adapter->rx_ring[i].rx_stats.drops;
 		}
-		adapter->net_stats.rx_fifo_errors = rqdpc_total;
 	}
 
 	/* Note RNBC (Receive No Buffers Count) is an not an exact
@@ -3668,7 +3667,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	 * one of the reason for saving it in rx_fifo_errors, as its
 	 * potentially not a true drop.
 	 */
-	adapter->net_stats.rx_fifo_errors += adapter->stats.rnbc;
+	adapter->net_stats.rx_fifo_errors = rqdpc_total + adapter->stats.rnbc;
 
 	/* RLEC on some newer hardware can be incorrect so build
 	 * our own version based on RUC and ROC */

