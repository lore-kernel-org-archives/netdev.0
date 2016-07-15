From: Kshitiz Gupta <kshitiz.gupta@ni.com>
Subject: [PATCH] igb: fix adjusting ptp timestamps for tx/rx latency
Date: Fri, 15 Jul 2016 18:08:16 -0400
Message-ID: <1468620496-7849-1-git-send-email-kshitiz.gupta@ni.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kshitiz Gupta <kshitiz.gupta@ni.com>
To: Aaron Brown <aaron.f.brown@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix PHY delay compensation math in igb_ptp_tx_hwtstamp() and
igb_ptp_rx_rgtstamp. Add PHY delay compensation in
igb_ptp_rx_pktstamp().

In the IGB driver, there are two functions that retrieve timestamps
received by the PHY - igb_ptp_rx_rgtstamp() and igb_ptp_rx_pktstamp().
The previous commit only changed igb_ptp_rx_rgtstamp(), and the change
was incorrect.

There are two instances in which PHY delay compensations should be
made:

- Before the packet transmission over the PHY, the latency between
  when the packet is timestamped and transmission of the packets,
  should be an add operation, but it is currently a subtract.

- After the packets are received from the PHY, the latency between
  the receiving and timestamping of the packets should be a subtract
  operation, but it is currently an add.

Signed-off-by: Kshitiz Gupta <kshitiz.gupta@ni.com>
Fixes: 3f544d2 (igb: adjust ptp timestamps for tx/rx latency)
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index f097c5a..3f27f13 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -743,7 +743,7 @@ static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 		}
 	}
 
-	shhwtstamps.hwtstamp = ktime_sub_ns(shhwtstamps.hwtstamp, adjust);
+	shhwtstamps.hwtstamp = ktime_add_ns(shhwtstamps.hwtstamp, adjust);
 
 	skb_tstamp_tx(adapter->ptp_tx_skb, &shhwtstamps);
 	dev_kfree_skb_any(adapter->ptp_tx_skb);
@@ -766,13 +766,30 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector,
 			 struct sk_buff *skb)
 {
 	__le64 *regval = (__le64 *)va;
+	struct igb_adapter *adapter = q_vector->adapter;
+	int adjust = 0;
 
 	/* The timestamp is recorded in little endian format.
 	 * DWORD: 0        1        2        3
 	 * Field: Reserved Reserved SYSTIML  SYSTIMH
 	 */
-	igb_ptp_systim_to_hwtstamp(q_vector->adapter, skb_hwtstamps(skb),
+	igb_ptp_systim_to_hwtstamp(adapter, skb_hwtstamps(skb),
 				   le64_to_cpu(regval[1]));
+
+	/* adjust timestamp for the RX latency based on link speed */
+	switch (adapter->link_speed) {
+	case SPEED_10:
+		adjust = IGB_RX_LATENCY_10;
+		break;
+	case SPEED_100:
+		adjust = IGB_RX_LATENCY_100;
+		break;
+	case SPEED_1000:
+		adjust = IGB_RX_LATENCY_1000;
+		break;
+	}
+	skb_hwtstamps(skb)->hwtstamp =
+		ktime_sub_ns(skb_hwtstamps(skb)->hwtstamp, adjust);
 }
 
 /**
@@ -824,7 +841,7 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 		}
 	}
 	skb_hwtstamps(skb)->hwtstamp =
-		ktime_add_ns(skb_hwtstamps(skb)->hwtstamp, adjust);
+		ktime_sub_ns(skb_hwtstamps(skb)->hwtstamp, adjust);
 
 	/* Update the last_rx_timestamp timer in order to enable watchdog check
 	 * for error case of latched timestamp on a dropped packet.
-- 
2.1.4
