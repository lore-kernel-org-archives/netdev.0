From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: add per-packet timestamping
Date: Fri, 26 Mar 2010 14:36:47 -0700
Message-ID: <20100326213545.19028.21468.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:36732
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752248Ab0CZVhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 17:37:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This patch adds support for per-packet timestamping for the
82580 adapter. The rx timestamp code is also pulled out of the
inlined rx hotpath and instead moved to a seperate function.

This version adds a comment explaining the per-packet timestamping
code added to igb_hwtstamp_ioctl().

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.h |    2 ++
 drivers/net/igb/igb.h         |    2 ++
 drivers/net/igb/igb_main.c    |   45 ++++++++++++++++++++++++++++++++++-------
 3 files changed, 41 insertions(+), 8 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index c1cad8a..cbd1e12 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -53,6 +53,7 @@ extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
 #define E1000_SRRCTL_DESCTYPE_ADV_ONEBUF                0x02000000
 #define E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS          0x0A000000
 #define E1000_SRRCTL_DROP_EN                            0x80000000
+#define E1000_SRRCTL_TIMESTAMP                          0x40000000
 
 #define E1000_MRQC_ENABLE_RSS_4Q            0x00000002
 #define E1000_MRQC_ENABLE_VMDQ              0x00000003
@@ -109,6 +110,7 @@ union e1000_adv_rx_desc {
 #define E1000_RXDADV_HDRBUFLEN_MASK      0x7FE0
 #define E1000_RXDADV_HDRBUFLEN_SHIFT     5
 #define E1000_RXDADV_STAT_TS             0x10000 /* Pkt was time stamped */
+#define E1000_RXDADV_STAT_TSIP           0x08000 /* timestamp in packet */
 
 /* Transmit Descriptor - Advanced */
 union e1000_adv_tx_desc {
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a177570..4f69b6d 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -107,6 +107,7 @@ struct vf_data_storage {
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
 
 /* Supported Rx Buffer Sizes */
+#define IGB_RXBUFFER_64    64     /* Used for packet split */
 #define IGB_RXBUFFER_128   128    /* Used for packet split */
 #define IGB_RXBUFFER_1024  1024
 #define IGB_RXBUFFER_2048  2048
@@ -324,6 +325,7 @@ struct igb_adapter {
 
 #define IGB_82576_TSYNC_SHIFT 19
 #define IGB_82580_TSYNC_SHIFT 24
+#define IGB_TS_HDR_LEN        16
 enum e1000_state_t {
 	__IGB_TESTING,
 	__IGB_RESETTING,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2501c5d..9f9382b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2602,6 +2602,8 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 		         E1000_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
 	}
+	if (hw->mac.type == e1000_82580)
+		srrctl |= E1000_SRRCTL_TIMESTAMP;
 	/* Only set Drop Enable if we are supporting multiple queues */
 	if (adapter->vfs_allocated_count || adapter->num_rx_queues > 1)
 		srrctl |= E1000_SRRCTL_DROP_EN;
@@ -3936,6 +3938,9 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	 * i.e. RXBUFFER_2048 --> size-4096 slab
 	 */
 
+	if (adapter->hw.mac.type == e1000_82580)
+		max_frame += IGB_TS_HDR_LEN;
+
 	if (max_frame <= IGB_RXBUFFER_1024)
 		rx_buffer_len = IGB_RXBUFFER_1024;
 	else if (max_frame <= MAXIMUM_ETHERNET_VLAN_SIZE)
@@ -3943,6 +3948,14 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	else
 		rx_buffer_len = IGB_RXBUFFER_128;
 
+	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN + IGB_TS_HDR_LEN) ||
+	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE + IGB_TS_HDR_LEN))
+		rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE + IGB_TS_HDR_LEN;
+
+	if ((adapter->hw.mac.type == e1000_82580) &&
+	    (rx_buffer_len == IGB_RXBUFFER_128))
+		rx_buffer_len += IGB_RXBUFFER_64;
+
 	if (netif_running(netdev))
 		igb_down(adapter);
 
@@ -5159,7 +5172,7 @@ static inline void igb_rx_checksum_adv(struct igb_ring *ring,
 	dev_dbg(&ring->pdev->dev, "cksum success: bits %08X\n", status_err);
 }
 
-static inline void igb_rx_hwtstamp(struct igb_q_vector *q_vector, u32 staterr,
+static void igb_rx_hwtstamp(struct igb_q_vector *q_vector, u32 staterr,
                                    struct sk_buff *skb)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
@@ -5177,13 +5190,18 @@ static inline void igb_rx_hwtstamp(struct igb_q_vector *q_vector, u32 staterr,
 	 * If nothing went wrong, then it should have a skb_shared_tx that we
 	 * can turn into a skb_shared_hwtstamps.
 	 */
-	if (likely(!(staterr & E1000_RXDADV_STAT_TS)))
-		return;
-	if (!(rd32(E1000_TSYNCRXCTL) & E1000_TSYNCRXCTL_VALID))
-		return;
+	if (staterr & E1000_RXDADV_STAT_TSIP) {
+		u32 *stamp = (u32 *)skb->data;
+		regval = le32_to_cpu(*(stamp + 2));
+		regval |= (u64)le32_to_cpu(*(stamp + 3)) << 32;
+		skb_pull(skb, IGB_TS_HDR_LEN);
+	} else {
+		if(!(rd32(E1000_TSYNCRXCTL) & E1000_TSYNCRXCTL_VALID))
+			return;
 
-	regval = rd32(E1000_RXSTMPL);
-	regval |= (u64)rd32(E1000_RXSTMPH) << 32;
+		regval = rd32(E1000_RXSTMPL);
+		regval |= (u64)rd32(E1000_RXSTMPH) << 32;
+	}
 
 	igb_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
 }
@@ -5291,7 +5309,8 @@ send_up:
 			goto next_desc;
 		}
 
-		igb_rx_hwtstamp(q_vector, staterr, skb);
+		if (staterr & (E1000_RXDADV_STAT_TSIP | E1000_RXDADV_STAT_TS))
+			igb_rx_hwtstamp(q_vector, staterr, skb);
 		total_bytes += skb->len;
 		total_packets++;
 
@@ -5571,6 +5590,16 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 		return 0;
 	}
 
+	/*
+	 * Per-packet timestamping only works if all packets are
+	 * timestamped, so enable timestamping in all packets as
+	 * long as one rx filter was configured.
+	 */
+	if ((hw->mac.type == e1000_82580) && tsync_rx_ctl) {
+		tsync_rx_ctl = E1000_TSYNCRXCTL_ENABLED;
+		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_ALL;
+	}
+
 	/* enable/disable TX */
 	regval = rd32(E1000_TSYNCTXCTL);
 	regval &= ~E1000_TSYNCTXCTL_ENABLED;

