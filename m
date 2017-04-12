From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [RFC PATCH 7/7] net: ethernet: update drivers to make both SW and HW TX timestamps
Date: Wed, 12 Apr 2017 16:17:37 +0200
Message-ID: <20170412141737.5881-8-mlichvar@redhat.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34614 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753286AbdDLOR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:17:56 -0400
In-Reply-To: <20170412141737.5881-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers were calling the skb_tx_timestamp() function only when
hardware timestamp was not requested. Now that applications have an
option to receive both timestamps in separate messages, the drivers need
to be modified to always call skb_tx_timestamp().

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c          | 3 +--
 drivers/net/ethernet/intel/e1000e/netdev.c        | 4 ++--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c   | 3 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 ++----
 4 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 89b21d7..5a2ad9c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1391,8 +1391,7 @@ static void xgbe_prep_tx_tstamp(struct xgbe_prv_data *pdata,
 		spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
 	}
 
-	if (!XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES, PTP))
-		skb_tx_timestamp(skb);
+	skb_tx_timestamp(skb);
 }
 
 static void xgbe_prep_vlan(struct sk_buff *skb, struct xgbe_packet_data *packet)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 097b1ec2..eee047b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5850,10 +5850,10 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 			adapter->tx_hwtstamp_skb = skb_get(skb);
 			adapter->tx_hwtstamp_start = jiffies;
 			schedule_work(&adapter->tx_hwtstamp_work);
-		} else {
-			skb_tx_timestamp(skb);
 		}
 
+		skb_tx_timestamp(skb);
+
 		netdev_sent_queue(netdev, skb->len);
 		e1000_tx_queue(tx_ring, tx_flags, count);
 		/* Make sure there is space in the ring for the next send. */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index d54490d..50c182c 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1418,8 +1418,7 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->hw->desc->tx_enable_tstamp(first_desc);
 	}
 
-	if (!tqueue->hwts_tx_en)
-		skb_tx_timestamp(skb);
+	skb_tx_timestamp(skb);
 
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr, txq_index);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a290c50..b866985 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2880,8 +2880,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->xstats.tx_set_ic_bit++;
 	}
 
-	if (!priv->hwts_tx_en)
-		skb_tx_timestamp(skb);
+	skb_tx_timestamp(skb);
 
 	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 		     priv->hwts_tx_en)) {
@@ -3083,8 +3082,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->xstats.tx_set_ic_bit++;
 	}
 
-	if (!priv->hwts_tx_en)
-		skb_tx_timestamp(skb);
+	skb_tx_timestamp(skb);
 
 	/* Ready to fill the first descriptor and set the OWN bit w/o any
 	 * problems because all the descriptors are actually ready to be
-- 
2.9.3
