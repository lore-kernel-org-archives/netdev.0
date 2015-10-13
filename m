From: Leonid Bloch <leonid@daynix.com>
Subject: [PATCH] e1000e: fix division by zero on jumbo MTUs
Date: Tue, 13 Oct 2015 12:48:18 +0300
Message-ID: <1444729698-9441-1-git-send-email-leonid@daynix.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Dmitry Fleytman <dmitry@daynix.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Fleytman <dmitry@daynix.com>

This patch fixes possible division by zero in receive
interrupt handler when working without adaptive interrupt
moderation.

The adaptive interrupt moderation mechanism is typically
disabled on jumbo MTUs.

Signed-off-by: Dmitry Fleytman <dmitry@daynix.com>
Signed-off-by: Leonid Bloch <leonid@daynix.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index faf4b3f..a60dce1 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1959,8 +1959,10 @@ static irqreturn_t e1000_intr_msix_rx(int __always_unused irq, void *data)
 	 * previous interrupt.
 	 */
 	if (rx_ring->set_itr) {
-		writel(1000000000 / (rx_ring->itr_val * 256),
-		       rx_ring->itr_register);
+		u32 itr = rx_ring->itr_val ?
+			1000000000 / (rx_ring->itr_val * 256) : 0;
+
+		writel(itr, rx_ring->itr_register);
 		rx_ring->set_itr = 0;
 	}
 
-- 
2.4.3
