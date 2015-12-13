From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] e1000e: fix division by zero on jumbo MTUs
Date: Sun, 13 Dec 2015 00:31:26 -0800
Message-ID: <1449995490-17020-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dmitry Fleytman <dmitry@daynix.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Leonid Bloch <leonid@daynix.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4841 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210AbbLMIbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:31:37 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Fleytman <dmitry@daynix.com>

This patch fixes possible division by zero in receive
interrupt handler when working without adaptive interrupt
moderation.

The adaptive interrupt moderation mechanism is typically
disabled on jumbo MTUs.

Signed-off-by: Dmitry Fleytman <dmitry@daynix.com>
Signed-off-by: Leonid Bloch <leonid@daynix.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 0003bf6..7724473 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1959,8 +1959,10 @@ static irqreturn_t e1000_intr_msix_rx(int __always_unused irq, void *data)
 	 * previous interrupt.
 	 */
 	if (rx_ring->set_itr) {
-		writel(1000000000 / (rx_ring->itr_val * 256),
-		       rx_ring->itr_register);
+		u32 itr = rx_ring->itr_val ?
+			  1000000000 / (rx_ring->itr_val * 256) : 0;
+
+		writel(itr, rx_ring->itr_register);
 		rx_ring->set_itr = 0;
 	}
 
-- 
2.5.0
