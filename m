From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH 3/3] net: arc_emac: fix sk_buff leak
Date: Tue,  9 Feb 2016 18:20:40 +0300
Message-ID: <1455031240-29385-4-git-send-email-al.kochet@gmail.com>
References: <1455031240-29385-1-git-send-email-al.kochet@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"'David S. Miller'" <davem@davemloft.net>,
	Alexander Kochetkov <al.kochet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455031240-29385-1-git-send-email-al.kochet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EMAC could be disabled, while there is some sb_buff
in use. That buffers got lost for linux.

In order to reproduce run on device during active ethernet work:
    ifconfig eth0 down

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>

---
CC: stable@vger.kernel.org # 3.18.x-
---
 drivers/net/ethernet/arc/emac_main.c |   62 ++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 4f6e5be..6446af1 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -518,6 +518,64 @@ static void arc_emac_set_rx_mode(struct net_device *ndev)
 }
 
 /**
+ * arc_free_tx_queue - free skb from tx queue
+ * @ndev:	Pointer to the network device.
+ *
+ * This function must be called while EMAC disable
+ */
+static void arc_free_tx_queue(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	unsigned int i;
+
+	for (i = 0; i < TX_BD_NUM; i++) {
+		struct arc_emac_bd *txbd = &priv->txbd[i];
+		struct buffer_state *tx_buff = &priv->tx_buff[i];
+
+		if (tx_buff->skb) {
+			dma_unmap_single(&ndev->dev, dma_unmap_addr(tx_buff, addr),
+					 dma_unmap_len(tx_buff, len), DMA_TO_DEVICE);
+
+			/* return the sk_buff to system */
+			dev_kfree_skb_irq(tx_buff->skb);
+		}
+
+		txbd->info = 0;
+		txbd->data = 0;
+		tx_buff->skb = NULL;
+	}
+}
+
+/**
+ * arc_free_rx_queue - free skb from rx queue
+ * @ndev:	Pointer to the network device.
+ *
+ * This function must be called while EMAC disable
+ */
+static void arc_free_rx_queue(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+	unsigned int i;
+
+	for (i = 0; i < RX_BD_NUM; i++) {
+		struct arc_emac_bd *rxbd = &priv->rxbd[i];
+		struct buffer_state *rx_buff = &priv->rx_buff[i];
+
+		if (rx_buff->skb) {
+			dma_unmap_single(&ndev->dev, dma_unmap_addr(rx_buff, addr),
+					dma_unmap_len(rx_buff, len), DMA_FROM_DEVICE);
+
+			/* return the sk_buff to system */
+			dev_kfree_skb_irq(rx_buff->skb);
+		}
+
+		rxbd->info = 0;
+		rxbd->data = 0;
+		rx_buff->skb = NULL;
+	}
+}
+
+/**
  * arc_emac_stop - Close the network device.
  * @ndev:	Pointer to the network device.
  *
@@ -538,6 +596,10 @@ static int arc_emac_stop(struct net_device *ndev)
 	/* Disable EMAC */
 	arc_reg_clr(priv, R_CTRL, EN_MASK);
 
+	/* Return the sk_buff to system */
+	arc_free_tx_queue(ndev);
+	arc_free_rx_queue(ndev);
+
 	return 0;
 }
 
-- 
1.7.9.5
