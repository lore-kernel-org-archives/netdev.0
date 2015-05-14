From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] net: batch of last_rx update avoidance in
 ethernet drivers.
Date: Thu, 14 May 2015 20:17:22 +0200
Message-ID: <20150514181722.GA8041@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>,
	Chris Metcalf <cmetcalf@tilera.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55487 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbbENSRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 14:17:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

None of those drivers uses last_rx for its own needs.

See 4dc89133f49b8cfd77ba7e83f5960aed63aaa99e ("net: add a comment on
netdev->last_rx") for reference.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Wingman Kwok <w-kwok2@ti.com>
Cc: Murali Karicheri <m-karicheri2@ti.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c      | 1 -
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c | 1 -
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 --
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 --
 drivers/net/ethernet/moxa/moxart_ether.c      | 1 -
 drivers/net/ethernet/ti/netcp_core.c          | 1 -
 drivers/net/ethernet/tile/tilepro.c           | 3 ---
 7 files changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index db84ddc..d45fd1b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -2072,7 +2072,6 @@ skip_data:
 		skb_record_rx_queue(skb, channel->queue_index);
 		skb_mark_napi_id(skb, napi);
 
-		netdev->last_rx = jiffies;
 		napi_gro_receive(napi, skb);
 
 next_packet:
diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index 0ffdcd3..a5e077e 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -500,7 +500,6 @@ static int hix5hd2_rx(struct net_device *dev, int limit)
 		napi_gro_receive(&priv->napi, skb);
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += skb->len;
-		dev->last_rx = jiffies;
 next:
 		pos = dma_ring_incr(pos, RX_DESC_NUM);
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 4bd3a80..0b4a7be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1688,7 +1688,6 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		skb_mark_napi_id(skb, &rx_ring->q_vector->napi);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
-		rx_ring->netdev->last_rx = jiffies;
 		rx_desc->wb.qword1.status_error_len = 0;
 
 	} while (likely(total_rx_packets < budget));
@@ -1821,7 +1820,6 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 #endif
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
-		rx_ring->netdev->last_rx = jiffies;
 		rx_desc->wb.qword1.status_error_len = 0;
 	} while (likely(total_rx_packets < budget));
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index b077e02..3ef2309 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1156,7 +1156,6 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		skb_mark_napi_id(skb, &rx_ring->q_vector->napi);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
-		rx_ring->netdev->last_rx = jiffies;
 		rx_desc->wb.qword1.status_error_len = 0;
 
 	} while (likely(total_rx_packets < budget));
@@ -1271,7 +1270,6 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 			 : 0;
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
-		rx_ring->netdev->last_rx = jiffies;
 		rx_desc->wb.qword1.status_error_len = 0;
 	} while (likely(total_rx_packets < budget));
 
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 81d0f1c..becbb5f 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -244,7 +244,6 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 		napi_gro_receive(&priv->napi, skb);
 		rx++;
 
-		ndev->last_rx = jiffies;
 		priv->stats.rx_packets++;
 		priv->stats.rx_bytes += len;
 		if (desc0 & RX_DESC0_MULTICAST)
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 0a28c07..5ec4ed3 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -698,7 +698,6 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		}
 	}
 
-	netcp->ndev->last_rx = jiffies;
 	netcp->ndev->stats.rx_packets++;
 	netcp->ndev->stats.rx_bytes += skb->len;
 
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 3d8f60d..6f0a449 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -721,9 +721,6 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 	if (!hash_default)
 		__inv_buffer(buf, len);
 
-	/* ISSUE: Is this needed? */
-	dev->last_rx = jiffies;
-
 #ifdef TILE_NET_DUMP_PACKETS
 	dump_packet(buf, len, "rx");
 #endif /* TILE_NET_DUMP_PACKETS */
-- 
Ueimor
