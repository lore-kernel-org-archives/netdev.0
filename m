From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] e1000e: 82579 performance improvements
Date: Thu, 30 Sep 2010 00:39:37 -0700
Message-ID: <20100930073934.13378.44230.stgit@localhost.localdomain>
References: <20100930073814.13378.4212.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:35705 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754818Ab0I3Hj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 03:39:56 -0400
In-Reply-To: <20100930073814.13378.4212.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The initial support for 82579 was tuned poorly for performance.  Adjust the
packet buffer allocation appropriately for both standard and jumbo frames;
and for jumbo frames increase the receive descriptor pre-fetch, disable
adaptive interrupt moderation and set the DMA latency tolerance.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ich8lan.c |    2 +-
 drivers/net/e1000e/netdev.c  |   50 +++++++++++++++++++++++++++++++++++++-----
 3 files changed, 46 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index da3b82f..8a79bbd 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -455,6 +455,7 @@ struct e1000_info {
 #define FLAG2_HAS_EEE                     (1 << 5)
 #define FLAG2_DMA_BURST                   (1 << 6)
 #define FLAG2_CHECK_PHY_HANG              (1 << 7)
+#define FLAG2_DISABLE_AIM                 (1 << 8)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 57b5435..e3374d9 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3986,7 +3986,7 @@ struct e1000_info e1000_pch2_info = {
 				  | FLAG_APME_IN_WUC,
 	.flags2			= FLAG2_HAS_PHY_STATS
 				  | FLAG2_HAS_EEE,
-	.pba			= 18,
+	.pba			= 26,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a8b55ab..c194804 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2290,6 +2290,11 @@ static void e1000_set_itr(struct e1000_adapter *adapter)
 		goto set_itr_now;
 	}
 
+	if (adapter->flags2 & FLAG2_DISABLE_AIM) {
+		new_itr = 0;
+		goto set_itr_now;
+	}
+
 	adapter->tx_itr = e1000_update_itr(adapter,
 				    adapter->tx_itr,
 				    adapter->total_tx_packets,
@@ -2338,7 +2343,10 @@ set_itr_now:
 		if (adapter->msix_entries)
 			adapter->rx_ring->set_itr = 1;
 		else
-			ew32(ITR, 1000000000 / (new_itr * 256));
+			if (new_itr)
+				ew32(ITR, 1000000000 / (new_itr * 256));
+			else
+				ew32(ITR, 0);
 	}
 }
 
@@ -2920,7 +2928,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 
 	/* irq moderation */
 	ew32(RADV, adapter->rx_abs_int_delay);
-	if (adapter->itr_setting != 0)
+	if ((adapter->itr_setting != 0) && (adapter->itr != 0))
 		ew32(ITR, 1000000000 / (adapter->itr * 256));
 
 	ctrl_ext = er32(CTRL_EXT);
@@ -2965,11 +2973,13 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	 * packet size is equal or larger than the specified value (in 8 byte
 	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048
 	 */
-	if (adapter->flags & FLAG_HAS_ERT) {
+	if ((adapter->flags & FLAG_HAS_ERT) ||
+	    (adapter->hw.mac.type == e1000_pch2lan)) {
 		if (adapter->netdev->mtu > ETH_DATA_LEN) {
 			u32 rxdctl = er32(RXDCTL(0));
 			ew32(RXDCTL(0), rxdctl | 0x3);
-			ew32(ERT, E1000_ERT_2048 | (1 << 13));
+			if (adapter->flags & FLAG_HAS_ERT)
+				ew32(ERT, E1000_ERT_2048 | (1 << 13));
 			/*
 			 * With jumbo frames and early-receive enabled,
 			 * excessive C-state transition latencies result in
@@ -3232,9 +3242,35 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		fc->low_water = 0x05048;
 		fc->pause_time = 0x0650;
 		fc->refresh_time = 0x0400;
+		if (adapter->netdev->mtu > ETH_DATA_LEN) {
+			pba = 14;
+			ew32(PBA, pba);
+		}
 		break;
 	}
 
+	/*
+	 * Disable Adaptive Interrupt Moderation if 2 full packets cannot
+	 * fit in receive buffer and early-receive not supported.
+	 */
+	if (adapter->itr_setting & 0x3) {
+		if (((adapter->max_frame_size * 2) > (pba << 10)) &&
+		    !(adapter->flags & FLAG_HAS_ERT)) {
+			if (!(adapter->flags2 & FLAG2_DISABLE_AIM)) {
+				dev_info(&adapter->pdev->dev,
+					"Interrupt Throttle Rate turned off\n");
+				adapter->flags2 |= FLAG2_DISABLE_AIM;
+				ew32(ITR, 0);
+			}
+		} else if (adapter->flags2 & FLAG2_DISABLE_AIM) {
+			dev_info(&adapter->pdev->dev,
+				 "Interrupt Throttle Rate turned on\n");
+			adapter->flags2 &= ~FLAG2_DISABLE_AIM;
+			adapter->itr = 20000;
+			ew32(ITR, 1000000000 / (adapter->itr * 256));
+		}
+	}
+
 	/* Allow time for pending master requests to run */
 	mac->ops.reset_hw(hw);
 
@@ -3553,7 +3589,8 @@ static int e1000_open(struct net_device *netdev)
 		e1000_update_mng_vlan(adapter);
 
 	/* DMA latency requirement to workaround early-receive/jumbo issue */
-	if (adapter->flags & FLAG_HAS_ERT)
+	if ((adapter->flags & FLAG_HAS_ERT) ||
+	    (adapter->hw.mac.type == e1000_pch2lan))
 		pm_qos_add_request(&adapter->netdev->pm_qos_req,
 				   PM_QOS_CPU_DMA_LATENCY,
 				   PM_QOS_DEFAULT_VALUE);
@@ -3662,7 +3699,8 @@ static int e1000_close(struct net_device *netdev)
 	if (adapter->flags & FLAG_HAS_AMT)
 		e1000_release_hw_control(adapter);
 
-	if (adapter->flags & FLAG_HAS_ERT)
+	if ((adapter->flags & FLAG_HAS_ERT) ||
+	    (adapter->hw.mac.type == e1000_pch2lan))
 		pm_qos_remove_request(&adapter->netdev->pm_qos_req);
 
 	pm_runtime_put_sync(&pdev->dev);

