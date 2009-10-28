From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 11/23] igb: make tx hang check multiqueue,
	check eop descriptor
Date: Wed, 28 Oct 2009 02:48:51 -0700
Message-ID: <20091028094850.13156.29899.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:36023
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751630AbZJ1Jwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:52:45 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes the tx hang check run over all tx queues instead of just
queue 0.  Also have hang display info on EOP descriptor instead of the
descriptor at the start of the chain.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7f32211..f75f90f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3002,6 +3002,10 @@ link_up:
 		}
 	}
 
+	/* Force detection of hung controller every watchdog period */
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		adapter->tx_ring[i].detect_tx_hung = true;
+
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	if (adapter->msix_entries) {
 		u32 eics = 0;
@@ -3014,9 +3018,6 @@ link_up:
 		wr32(E1000_ICS, E1000_ICS_RXDMT0);
 	}
 
-	/* Force detection of hung controller every watchdog period */
-	tx_ring->detect_tx_hung = true;
-
 	/* Reset the timer */
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer,
@@ -3667,6 +3668,7 @@ static void igb_tx_timeout(struct net_device *netdev)
 
 	/* Do the reset outside of interrupt context */
 	adapter->tx_timeout_count++;
+
 	schedule_work(&adapter->reset_task);
 	wr32(E1000_EICS,
 	     (adapter->eims_enable_mask & ~adapter->eims_other));
@@ -4804,7 +4806,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 				readl(tx_ring->tail),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
-				tx_ring->buffer_info[i].time_stamp,
+				tx_ring->buffer_info[eop].time_stamp,
 				eop,
 				jiffies,
 				eop_desc->wb.status);

