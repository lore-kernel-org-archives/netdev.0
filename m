From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [patch net] net: fec: fix compile with CONFIG_M5272
Date: Sun,  4 Dec 2016 18:17:57 +0300
Message-ID: <1480864677-15310-1-git-send-email-nikita.yoush@cogentembedded.com>
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel@vger.kernel.org,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: "David S. Miller" <davem@davemloft.net>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36208 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751261AbcLDPSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 10:18:13 -0500
Received: by mail-wm0-f53.google.com with SMTP id g23so61909179wme.1
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 07:18:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4dfb80d18d05 ("net: fec: cache statistics while device is down")
introduced unconditional statistics-related actions.

However, when driver is compiled with CONFIG_M5272, staticsics-related
definitions do not exist, which results into build errors.

Fix that by adding needed #if !defined(CONFIG_M5272).

Fixes: 4dfb80d18d05 ("net: fec: cache statistics while device is down")
Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 6a20c24a2003..89e902767abb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2884,7 +2884,9 @@ fec_enet_close(struct net_device *ndev)
 	if (fep->quirks & FEC_QUIRK_ERR006687)
 		imx6q_cpuidle_fec_irqs_unused();
 
+#if !defined(CONFIG_M5272)
 	fec_enet_update_ethtool_stats(ndev);
+#endif
 
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
@@ -3192,7 +3194,9 @@ static int fec_enet_init(struct net_device *ndev)
 
 	fec_restart(ndev);
 
+#if !defined(CONFIG_M5272)
 	fec_enet_update_ethtool_stats(ndev);
+#endif
 
 	return 0;
 }
@@ -3292,9 +3296,11 @@ fec_probe(struct platform_device *pdev)
 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
 
 	/* Init network device */
-	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
-				  ARRAY_SIZE(fec_stats) * sizeof(u64),
-				  num_tx_qs, num_rx_qs);
+	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private)
+#if !defined(CONFIG_M5272)
+				  + ARRAY_SIZE(fec_stats) * sizeof(u64)
+#endif
+				  , num_tx_qs, num_rx_qs);
 	if (!ndev)
 		return -ENOMEM;
 
-- 
2.1.4
