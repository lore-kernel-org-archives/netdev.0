From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ixgbe: Fix TX stats accounting
Date: Tue, 24 Nov 2009 12:37:17 +0100
Message-ID: <4B0BC56D.1000909@gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>	 <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com>	 <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>	 <4B0A9E4E.9010804@gmail.com> <19210.54486.353397.804028@gargle.gargle.HOWL>	 <4B0ABF6D.9000103@gmail.com>	 <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com>	 <4B0B8F52.3010005@gmail.com> <1259053673.2631.30.camel@ppwaskie-mobl2>	 <4B0BADA6.7080602@gmail.com> <1259057164.2631.36.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "robert@herjulf.net" <robert@herjulf.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33136 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932686AbZKXLhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 06:37:18 -0500
In-Reply-To: <1259057164.2631.36.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several cpus can update netdev->stats.tx_bytes & netdev->stats.tx_packets
in parallel. In this case, TX stats are under estimated and false sharing
takes place.

After a pktgen session sending exactly 200000000 packets :
# ifconfig fiber0 | grep TX
          TX packets:198501982 errors:0 dropped:0 overruns:0 carrier:0


Multi queue devices should instead use txq->tx_bytes & txq->tx_packets
in their xmit() method (appropriate txq lock already held by caller, no
cache line miss), or use appropriate locking.

After patch, same pktgen session gives :

# ifconfig fiber0 | grep TX
          TX packets:200000000 errors:0 dropped:0 overruns:0 carrier:0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ebcec30..1cea120 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -425,8 +425,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	tx_ring->total_packets += total_packets;
 	tx_ring->stats.packets += total_packets;
 	tx_ring->stats.bytes += total_bytes;
-	netdev->stats.tx_bytes += total_bytes;
-	netdev->stats.tx_packets += total_packets;
 	return (count < tx_ring->work_limit);
 }
 
@@ -5249,6 +5247,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
+	struct netdev_queue *txq;
 	unsigned int first;
 	unsigned int tx_flags = 0;
 	u8 hdr_len = 0;
@@ -5345,6 +5344,9 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 				tx_ring->atr_count = 0;
 			}
 		}
+		txq = netdev_get_tx_queue(netdev, r_idx);
+		txq->tx_bytes += skb->len;
+		txq->tx_packets++;
 		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
 		               hdr_len);
 		ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
@@ -5359,19 +5361,6 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 }
 
 /**
- * ixgbe_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- **/
-static struct net_device_stats *ixgbe_get_stats(struct net_device *netdev)
-{
-	/* only return the current stats */
-	return &netdev->stats;
-}
-
-/**
  * ixgbe_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
@@ -5501,7 +5490,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
 	.ndo_select_queue	= ixgbe_select_queue,
-	.ndo_get_stats		= ixgbe_get_stats,
 	.ndo_set_rx_mode        = ixgbe_set_rx_mode,
 	.ndo_set_multicast_list	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
