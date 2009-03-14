From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 08/11] ixgbe: Add a few safety nets for register
	writes and descriptor cleanups
Date: Sat, 14 Mar 2009 01:14:50 -0700
Message-ID: <20090314081450.4687.87025.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:37979
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752791AbZCNIU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:20:58 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

There are possible times that a driver may fail to completely initialize,
due to a buggy platform or a buggy kernel.  In those cases, we'd rather
fail gracefully instead of a panic.  Add a few safety checks to some
critical paths to try and prevent a panic in these corner-case situations.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 78b0357..8821c5f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2458,8 +2458,10 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
-	writel(0, adapter->hw.hw_addr + rx_ring->head);
-	writel(0, adapter->hw.hw_addr + rx_ring->tail);
+	if (rx_ring->head)
+		writel(0, adapter->hw.hw_addr + rx_ring->head);
+	if (rx_ring->tail)
+		writel(0, adapter->hw.hw_addr + rx_ring->tail);
 }
 
 /**
@@ -2490,8 +2492,10 @@ static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
-	writel(0, adapter->hw.hw_addr + tx_ring->head);
-	writel(0, adapter->hw.hw_addr + tx_ring->tail);
+	if (tx_ring->head)
+		writel(0, adapter->hw.hw_addr + tx_ring->head);
+	if (tx_ring->tail)
+		writel(0, adapter->hw.hw_addr + tx_ring->tail);
 }
 
 /**
@@ -3327,7 +3331,8 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		ixgbe_free_tx_resources(adapter, &adapter->tx_ring[i]);
+		if (adapter->tx_ring[i].desc)
+			ixgbe_free_tx_resources(adapter, &adapter->tx_ring[i]);
 }
 
 /**
@@ -3363,7 +3368,8 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbe_free_rx_resources(adapter, &adapter->rx_ring[i]);
+		if (adapter->rx_ring[i].desc)
+			ixgbe_free_rx_resources(adapter, &adapter->rx_ring[i]);
 }
 
 /**

