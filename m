From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 5/9] ixgbe: Fix 82598 MSI-X allocation on systems with more
	than 8 CPU cores
Date: Wed, 01 Apr 2009 00:34:05 -0700
Message-ID: <20090401073405.3749.98186.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:58756 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759014AbZDAHeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:34:24 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

MSI-X allocation broke after the 82599 merge on systems with more than 8
CPU cores.  82598 drops back into MSI mode, which isn't sufficient to run
full, efficient 10G line rate.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8f6e263..63c0f19 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2934,6 +2934,7 @@ err_tx_ring_allocation:
  **/
 static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
 	int err = 0;
 	int vector, v_budget;
 
@@ -2948,12 +2949,12 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 
 	/*
 	 * At the same time, hardware can only support a maximum of
-	 * MAX_MSIX_COUNT vectors.  With features such as RSS and VMDq,
-	 * we can easily reach upwards of 64 Rx descriptor queues and
-	 * 32 Tx queues.  Thus, we cap it off in those rare cases where
-	 * the cpu count also exceeds our vector limit.
+	 * hw.mac->max_msix_vectors vectors.  With features
+	 * such as RSS and VMDq, we can easily surpass the number of Rx and Tx
+	 * descriptor queues supported by our device.  Thus, we cap it off in
+	 * those rare cases where the cpu count also exceeds our vector limit.
 	 */
-	v_budget = min(v_budget, MAX_MSIX_COUNT);
+	v_budget = min(v_budget, (int)hw->mac.max_msix_vectors);
 
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter. */

