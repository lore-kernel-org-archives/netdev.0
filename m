From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 2/2] fec: Invert the order of function calls in fec_restart()
Date: Wed, 15 May 2013 14:06:27 -0300
Message-ID: <1368637587-13391-2-git-send-email-fabio.estevam@freescale.com>
References: <1368637587-13391-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <Frank.Li@freescale.com>,
	<kernel@pengutronix.de>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:14660
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759559Ab3EORGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 13:06:41 -0400
In-Reply-To: <1368637587-13391-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 54309fa6 ("net: fec: fix kernel oops when plug/unplug cable many times")
introduced the following 'if' block in the beginning of fec_start():

	if (netif_running(ndev)) {
		netif_device_detach(ndev);
		napi_disable(&fep->napi);
		netif_stop_queue(ndev);
		netif_tx_lock_bh(ndev);
	}

Then later in the end of fec_restart() there is another block that calls the
opposite of each one of these functions.

The correct approach would be to also call them with in the reverse order, so 
that we have as result:

	if (netif_running(ndev)) {
		netif_tx_unlock_bh(ndev);
		netif_wake_queue(ndev);
		napi_enable(&fep->napi);
		netif_device_attach(ndev);
	}

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 658fbc1..570dfad 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -616,10 +616,10 @@ fec_restart(struct net_device *ndev, int duplex)
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 
 	if (netif_running(ndev)) {
-		netif_device_attach(ndev);
-		napi_enable(&fep->napi);
-		netif_wake_queue(ndev);
 		netif_tx_unlock_bh(ndev);
+		netif_wake_queue(ndev);
+		napi_enable(&fep->napi);
+		netif_device_attach(ndev);
 	}
 }
 
-- 
1.8.1.2
