From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] e1000e: do not disable receiver on 82574/82583
Date: Thu, 11 Aug 2011 15:31:46 -0700
Message-ID: <1313101908-11622-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53658 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753665Ab1HKWbw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 18:31:52 -0400
In-Reply-To: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Due to a hardware erratum, the receiver on 82574 and 82583 should not be
stopped once it has been started.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c   |    6 ++++--
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |    3 ++-
 drivers/net/e1000e/netdev.c  |    7 +++++--
 4 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 480f259..536b3a5 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -2085,7 +2085,8 @@ struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.flags2			  = FLAG2_CHECK_PHY_HANG
-				  | FLAG2_DISABLE_ASPM_L0S,
+				  | FLAG2_DISABLE_ASPM_L0S
+				  | FLAG2_NO_DISABLE_RX,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
@@ -2104,7 +2105,8 @@ struct e1000_info e1000_82583_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
-	.flags2			= FLAG2_DISABLE_ASPM_L0S,
+	.flags2			= FLAG2_DISABLE_ASPM_L0S
+				  | FLAG2_NO_DISABLE_RX,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 638d175..35916f4 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -453,6 +453,7 @@ struct e1000_info {
 #define FLAG2_DISABLE_ASPM_L0S            (1 << 7)
 #define FLAG2_DISABLE_AIM                 (1 << 8)
 #define FLAG2_CHECK_PHY_HANG              (1 << 9)
+#define FLAG2_NO_DISABLE_RX               (1 << 10)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 06d88f3..6a0526a 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1206,7 +1206,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rx_ring->next_to_clean = 0;
 
 	rctl = er32(RCTL);
-	ew32(RCTL, rctl & ~E1000_RCTL_EN);
+	if (!(adapter->flags2 & FLAG2_NO_DISABLE_RX))
+		ew32(RCTL, rctl & ~E1000_RCTL_EN);
 	ew32(RDBAL, ((u64) rx_ring->dma & 0xFFFFFFFF));
 	ew32(RDBAH, ((u64) rx_ring->dma >> 32));
 	ew32(RDLEN, rx_ring->size);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ab4be80..c0406b1 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2915,7 +2915,8 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 
 	/* disable receives while setting up the descriptors */
 	rctl = er32(RCTL);
-	ew32(RCTL, rctl & ~E1000_RCTL_EN);
+	if (!(adapter->flags2 & FLAG2_NO_DISABLE_RX))
+		ew32(RCTL, rctl & ~E1000_RCTL_EN);
 	e1e_flush();
 	usleep_range(10000, 20000);
 
@@ -3394,7 +3395,8 @@ void e1000e_down(struct e1000_adapter *adapter)
 
 	/* disable receives in the hardware */
 	rctl = er32(RCTL);
-	ew32(RCTL, rctl & ~E1000_RCTL_EN);
+	if (!(adapter->flags2 & FLAG2_NO_DISABLE_RX))
+		ew32(RCTL, rctl & ~E1000_RCTL_EN);
 	/* flush and sleep below */
 
 	netif_stop_queue(netdev);
@@ -3403,6 +3405,7 @@ void e1000e_down(struct e1000_adapter *adapter)
 	tctl = er32(TCTL);
 	tctl &= ~E1000_TCTL_EN;
 	ew32(TCTL, tctl);
+
 	/* flush both disables and wait for them to finish */
 	e1e_flush();
 	usleep_range(10000, 20000);
-- 
1.7.6

