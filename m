From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v5 3/6] net: sh_eth: fix the rxdesc pointer when rx descriptor
 empty happens
Date: Tue, 29 May 2012 17:14:54 +0900
Message-ID: <4FC4857E.6020907@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When Receive Descriptor Empty happens, rxdesc pointer of the driver
and actual next descriptor of the controller may be mismatch.
This patch fixes it.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 about v5:
  - this patch is the same as v3

 drivers/net/ethernet/renesas/sh_eth.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 10f2a89..906e410 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1098,8 +1098,12 @@ static int sh_eth_rx(struct net_device *ndev)

 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R))
+	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
+		/* fix the values for the next receiving */
+		mdp->cur_rx = mdp->dirty_rx = (sh_eth_read(ndev, RDFAR) -
+					       sh_eth_read(ndev, RDLAR)) >> 4;
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
+	}

 	return 0;
 }
@@ -1196,8 +1200,6 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		/* Receive Descriptor Empty int */
 		ndev->stats.rx_over_errors++;

-		if (sh_eth_read(ndev, EDRRR) ^ EDRRR_R)
-			sh_eth_write(ndev, EDRRR_R, EDRRR);
 		if (netif_msg_rx_err(mdp))
 			dev_err(&ndev->dev, "Receive Descriptor Empty\n");
 	}
-- 
1.7.1

