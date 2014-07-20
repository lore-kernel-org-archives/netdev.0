From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [RFC PATCH 2/2] net: arc_emac: prevent reuse of unreclaimed tx descriptors
Date: Sun, 20 Jul 2014 17:44:58 +0200
Message-ID: <1405871098-5663-3-git-send-email-b.galvani@gmail.com>
References: <1405871098-5663-1-git-send-email-b.galvani@gmail.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Max Schwarz <max.schwarz@online.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Thierry Reding <thierry.reding@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405871098-5663-1-git-send-email-b.galvani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After transmitting a frame, the current code stops the queue only when
the next buffer descriptor in the ring is still owned by the device.
This is not enough since the tx code must also wait that descriptors
get reclaimed by arc_emacs_tx_clean() before using them again.

This patch changes the logic in tx path to ensure that descriptors are
used for transmission only after they have been reclaimed.

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c |   46 ++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 4adc01f..02fba2d 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -30,6 +30,17 @@
 #define DRV_VERSION	"1.0"
 
 /**
+ * arc_emac_tx_avail - Return the number of available slots in the tx ring.
+ * @priv: Pointer to ARC EMAC private data structure.
+ *
+ * returns: the number of slots available for transmission in tx the ring.
+ */
+static inline int arc_emac_tx_avail(struct arc_emac_priv *priv)
+{
+	return (priv->txbd_dirty + TX_BD_NUM - priv->txbd_curr - 1) % TX_BD_NUM;
+}
+
+/**
  * arc_emac_adjust_link - Adjust the PHY link duplex.
  * @ndev:	Pointer to the net_device structure.
  *
@@ -180,10 +191,15 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		txbd->info = 0;
 
 		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
-
-		if (netif_queue_stopped(ndev))
-			netif_wake_queue(ndev);
 	}
+
+	/* Ensure that txbd_dirty is visible to tx() before checking
+	 * for queue stopped.
+	 */
+	smp_mb();
+
+	if (netif_queue_stopped(ndev) && arc_emac_tx_avail(priv))
+		netif_wake_queue(ndev);
 }
 
 /**
@@ -574,11 +590,9 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 
 	len = max_t(unsigned int, ETH_ZLEN, skb->len);
 
-	/* EMAC still holds this buffer in its possession.
-	 * CPU must not modify this buffer descriptor
-	 */
-	if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC)) {
+	if (unlikely(!arc_emac_tx_avail(priv))) {
 		netif_stop_queue(ndev);
+		netdev_err(ndev, "BUG! Tx Ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -603,18 +617,24 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	skb_tx_timestamp(skb);
 
 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
+	arc_reg_set(priv, R_STATUS, TXPL_MASK);
 
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
 
-	/* Get "info" of the next BD */
-	info = &priv->txbd[*txbd_curr].info;
+	/* Ensure that tx_clean() sees the new txbd_curr before
+	 * checking the queue status. This prevents an unneeded wake
+	 * of the queue in tx_clean().
+	 */
+	smp_mb();
 
-	/* Check if if Tx BD ring is full - next BD is still owned by EMAC */
-	if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC))
+	if (!arc_emac_tx_avail(priv)) {
 		netif_stop_queue(ndev);
-
-	arc_reg_set(priv, R_STATUS, TXPL_MASK);
+		/* Refresh tx_dirty */
+		smp_mb();
+		if (arc_emac_tx_avail(priv))
+			netif_start_queue(ndev);
+	}
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4
