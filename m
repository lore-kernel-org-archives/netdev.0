From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH v2 2/2] net: arc_emac: prevent reuse of unreclaimed tx descriptors
Date: Wed, 10 Sep 2014 22:50:03 +0200
Message-ID: <1410382203-10395-3-git-send-email-b.galvani@gmail.com>
References: <1410382203-10395-1-git-send-email-b.galvani@gmail.com>
Cc: Romain Perier <romain.perier@gmail.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Jingoo Han <jg1.han@samsung.com>,
	Max Schwarz <max.schwarz@online.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:63467 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621AbaIJUvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 16:51:44 -0400
In-Reply-To: <1410382203-10395-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the logic in tx path to ensure that tx descriptors
are reused for transmission only after they have been reclaimed by
arc_emac_tx_clean().

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c | 43 +++++++++++++++++++++++++++---------
 1 file changed, 32 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 1d08f63..abe1eab 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -28,6 +28,17 @@
 
 
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
@@ -182,10 +193,15 @@ static void arc_emac_tx_clean(struct net_device *ndev)
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
@@ -576,11 +592,9 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 
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
 
@@ -609,12 +623,19 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
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
+		/* Refresh tx_dirty */
+		smp_mb();
+		if (arc_emac_tx_avail(priv))
+			netif_start_queue(ndev);
+	}
 
 	arc_reg_set(priv, R_STATUS, TXPL_MASK);
 
-- 
1.9.1
