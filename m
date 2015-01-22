From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 3/4] sh_eth: Fix crash or memory leak when resizing
 rings on device that is down
Date: Thu, 22 Jan 2015 12:41:34 +0000
Message-ID: <1421930494.1222.288.camel@xylophone.i.decadent.org.uk>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:40680 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbbAVMle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:41:34 -0500
In-Reply-To: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the device is down then no packet buffers should be allocated.
We also must not touch its registers as it may be powered off.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |   34 +++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 0be16dd..be7aa43 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1976,29 +1976,31 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 		sh_eth_write(ndev, 0, EDTRR);
 		sh_eth_write(ndev, 0, EDRRR);
 		synchronize_irq(ndev->irq);
-	}
 
-	/* Free all the skbuffs in the Rx queue. */
-	sh_eth_ring_free(ndev);
-	/* Free DMA buffer */
-	sh_eth_free_dma_buffer(mdp);
+		/* Free all the skbuffs in the Rx queue. */
+		sh_eth_ring_free(ndev);
+		/* Free DMA buffer */
+		sh_eth_free_dma_buffer(mdp);
+	}
 
 	/* Set new parameters */
 	mdp->num_rx_ring = ring->rx_pending;
 	mdp->num_tx_ring = ring->tx_pending;
 
-	ret = sh_eth_ring_init(ndev);
-	if (ret < 0) {
-		netdev_err(ndev, "%s: sh_eth_ring_init failed.\n", __func__);
-		return ret;
-	}
-	ret = sh_eth_dev_init(ndev, false);
-	if (ret < 0) {
-		netdev_err(ndev, "%s: sh_eth_dev_init failed.\n", __func__);
-		return ret;
-	}
-
 	if (netif_running(ndev)) {
+		ret = sh_eth_ring_init(ndev);
+		if (ret < 0) {
+			netdev_err(ndev, "%s: sh_eth_ring_init failed.\n",
+				   __func__);
+			return ret;
+		}
+		ret = sh_eth_dev_init(ndev, false);
+		if (ret < 0) {
+			netdev_err(ndev, "%s: sh_eth_dev_init failed.\n",
+				   __func__);
+			return ret;
+		}
+
 		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
 		/* Setting the Rx mode will start the Rx process. */
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
-- 
1.7.10.4
