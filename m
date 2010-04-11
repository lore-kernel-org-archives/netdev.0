From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] drivers: net: last_rx elimination
Date: Sun, 11 Apr 2010 10:48:14 +0200
Message-ID: <1270975694.2078.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:42191 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab0DKIsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 04:48:18 -0400
Received: by bwz19 with SMTP id 19so194338bwz.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 01:48:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network drivers do not have to update last_rx, unless they need it for
their private use.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bcm63xx_enet.c         |    1 -
 drivers/net/can/at91_can.c         |    2 --
 drivers/net/ixgbevf/ixgbevf_main.c |    1 -
 drivers/net/ksz884x.c              |    2 --
 drivers/net/octeon/octeon_mgmt.c   |    1 -
 drivers/net/stmmac/stmmac_main.c   |    1 -
 drivers/net/vmxnet3/vmxnet3_drv.c  |    1 -
 7 files changed, 9 deletions(-)

diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 5173340..10f428f 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -343,7 +343,6 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
 		skb->protocol = eth_type_trans(skb, dev);
 		priv->stats.rx_packets++;
 		priv->stats.rx_bytes += len;
-		dev->last_rx = jiffies;
 		netif_receive_skb(skb);
 
 	} while (--budget > 0);
diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index a2f29a3..1fd45e5 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -662,7 +662,6 @@ static int at91_poll_err(struct net_device *dev, int quota, u32 reg_sr)
 	at91_poll_err_frame(dev, cf, reg_sr);
 	netif_receive_skb(skb);
 
-	dev->last_rx = jiffies;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += cf->can_dlc;
 
@@ -899,7 +898,6 @@ static void at91_irq_err(struct net_device *dev)
 	at91_irq_err_state(dev, cf, new_state);
 	netif_rx(skb);
 
-	dev->last_rx = jiffies;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += cf->can_dlc;
 
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 65cb133..2082c88 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -610,7 +610,6 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
 
 		ixgbevf_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
-		adapter->netdev->last_rx = jiffies;
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 0977964..26ccf46 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -5053,8 +5053,6 @@ static inline int rx_proc(struct net_device *dev, struct ksz_hw* hw,
 	priv->stats.rx_bytes += packet_len;
 
 	/* Notify upper layer for received packet. */
-	dev->last_rx = jiffies;
-
 	rx_status = netif_rx(skb);
 
 	return 0;
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index ee894ed..43ffbba 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -316,7 +316,6 @@ good:
 		skb->protocol = eth_type_trans(skb, netdev);
 		netdev->stats.rx_packets++;
 		netdev->stats.rx_bytes += skb->len;
-		netdev->last_rx = jiffies;
 		netif_receive_skb(skb);
 		rc = 0;
 	} else if (re.s.code == RING_ENTRY_CODE_MORE) {
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 963f591..d03e57c 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1279,7 +1279,6 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 			priv->dev->stats.rx_packets++;
 			priv->dev->stats.rx_bytes += frame_len;
-			priv->dev->last_rx = jiffies;
 		}
 		entry = next_entry;
 		p = p_next;	/* use prefetched values */
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 58dfa36..90e783a 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1174,7 +1174,6 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 				netif_receive_skb(skb);
 			}
 
-			adapter->netdev->last_rx = jiffies;
 			ctx->skb = NULL;
 		}
 


