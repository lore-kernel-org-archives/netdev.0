From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue,  3 Mar 2015 12:45:12 +0100
Message-ID: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case there was some tx buffer reclaimed and not enough rx packets
to consume the whole budget, napi_complete would not be called and
interrupts would be kept disabled, effectively resulting in the
network core never to call the poll callback again and no rx/tx
interrupts to be fired either.

Fix that by only accounting the rx work done in the poll callback.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 21206d3..a7f2cc3 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -486,7 +486,7 @@ static int bcm_enet_poll(struct napi_struct *napi, int budget)
 {
 	struct bcm_enet_priv *priv;
 	struct net_device *dev;
-	int tx_work_done, rx_work_done;
+	int rx_work_done;
 
 	priv = container_of(napi, struct bcm_enet_priv, napi);
 	dev = priv->net_dev;
@@ -498,14 +498,14 @@ static int bcm_enet_poll(struct napi_struct *napi, int budget)
 			 ENETDMAC_IR, priv->tx_chan);
 
 	/* reclaim sent skb */
-	tx_work_done = bcm_enet_tx_reclaim(dev, 0);
+	bcm_enet_tx_reclaim(dev, 0);
 
 	spin_lock(&priv->rx_lock);
 	rx_work_done = bcm_enet_receive_queue(dev, budget);
 	spin_unlock(&priv->rx_lock);
 
-	if (rx_work_done >= budget || tx_work_done > 0) {
-		/* rx/tx queue is not yet empty/clean */
+	if (rx_work_done >= budget) {
+		/* rx queue is not yet empty/clean */
 		return rx_work_done;
 	}
 
-- 
1.9.1
