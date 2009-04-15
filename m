From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: update real_num_tx_queues on changing
	num_rx_queues
Date: Tue, 14 Apr 2009 20:52:17 -0700
Message-ID: <20090415035217.10107.54118.stgit@localhost.localdomain>
References: <20090415035155.10107.6878.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Wu Fengguang <fengguang.wu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:38574 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752328AbZDODwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 23:52:34 -0400
In-Reply-To: <20090415035155.10107.6878.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wu Fengguang <fengguang.wu@intel.com>

Move the update of real_num_tx_queues from
ixgbe_acquire_msix_vectors() to ixgbe_set_num_queues(), to ensure it
be always in sync with num_tx_queues.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 862dd34..11fd153 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2723,17 +2723,21 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 {
-	/* Start with base case */
-	adapter->num_rx_queues = 1;
-	adapter->num_tx_queues = 1;
-
 #ifdef CONFIG_IXGBE_DCB
 	if (ixgbe_set_dcb_queues(adapter))
-		return;
+		goto done;
 
 #endif
 	if (ixgbe_set_rss_queues(adapter))
-		return;
+		goto done;
+
+	/* fallback to base case */
+	adapter->num_rx_queues = 1;
+	adapter->num_tx_queues = 1;
+
+done:
+	/* Notify the stack of the (possibly) reduced Tx Queue count. */
+	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
@@ -2992,9 +2996,6 @@ try_msi:
 	}
 
 out:
-	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
-
 	return err;
 }
 

