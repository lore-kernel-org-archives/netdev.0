From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] ixgbe: Clear out stray tx work on link down
Date: Tue, 28 Apr 2009 01:43:12 -0700
Message-ID: <20090428084312.32710.49988.stgit@localhost.localdomain>
References: <20090428084236.32710.14750.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:37245 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752948AbZD1In3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:43:29 -0400
In-Reply-To: <20090428084236.32710.14750.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson, Shannon <shannon.nelson@intel.com>

Ayyappan at VMware noticed that we're missing this check from ixgbe which
is in our other drivers.  The difference with this implementation from our
other drivers is that this checks all the tx queues rather than just tx[0].

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 60c3a21..35ff703 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4117,6 +4117,9 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 link_speed = adapter->link_speed;
 	bool link_up = adapter->link_up;
+	int i;
+	struct ixgbe_ring *tx_ring;
+	int some_tx_pending = 0;
 
 	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
 
@@ -4174,6 +4177,25 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 		}
 	}
 
+	if (!netif_carrier_ok(netdev)) {
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			tx_ring = &adapter->tx_ring[i];
+			if (tx_ring->next_to_use != tx_ring->next_to_clean) {
+				some_tx_pending = 1;
+				break;
+			}
+		}
+
+		if (some_tx_pending) {
+			/* We've lost link, so the controller stops DMA,
+			 * but we've got queued Tx work that's never going
+			 * to get done, so reset controller to flush Tx.
+			 * (Do the reset outside of interrupt context).
+			 */
+			 schedule_work(&adapter->reset_task);
+		}
+	}
+
 	ixgbe_update_stats(adapter);
 	adapter->flags &= ~IXGBE_FLAG_IN_WATCHDOG_TASK;
 }

