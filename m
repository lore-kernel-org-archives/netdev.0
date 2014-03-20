From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 11/15] e1000e: Fix Explicitly set Transmit Control Register
Date: Wed, 19 Mar 2014 20:30:01 -0700
Message-ID: <1395286205-9676-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395286205-9676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Todd Fujinaka <todd.fujinaka@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40723 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbaCTDa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 23:30:27 -0400
In-Reply-To: <1395286205-9676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

This patch causes the TCTL to be explicitly set to fix a problem with
poor network performance (throughput) on certain silicon when configured
for 100M HDX performance.

Cc: Todd Fujinaka <todd.fujinaka@intel.com>
Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Acked-by: Bruce W. Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index d577723..6bd1832 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2898,7 +2898,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	u64 tdba;
-	u32 tdlen, tarc;
+	u32 tdlen, tctl, tarc;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	tdba = tx_ring->dma;
@@ -2935,6 +2935,12 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	/* erratum work around: set txdctl the same for both queues */
 	ew32(TXDCTL(1), er32(TXDCTL(0)));
 
+	/* Program the Transmit Control Register */
+	tctl = er32(TCTL);
+	tctl &= ~E1000_TCTL_CT;
+	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
+		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
+
 	if (adapter->flags & FLAG_TARC_SPEED_MODE_BIT) {
 		tarc = er32(TARC(0));
 		/* set the speed mode bit, we'll clear it if we're not at
@@ -2965,6 +2971,8 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	/* enable Report Status bit */
 	adapter->txd_cmd |= E1000_TXD_CMD_RS;
 
+	ew32(TCTL, tctl);
+
 	hw->mac.ops.config_collision_dist(hw);
 }
 
-- 
1.8.3.1
