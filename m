From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [patch net] net: fec: fix compile with CONFIG_M5272
Date: Mon, 5 Dec 2016 07:31:23 +0000
Message-ID: <AM4PR0401MB22609781F54C6FC2F0AD22D4FF830@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1480864677-15310-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        "Andrew Lunn" <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0048.outbound.protection.outlook.com ([104.47.2.48]:39232
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750855AbcLEHql (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 02:46:41 -0500
In-Reply-To: <1480864677-15310-1-git-send-email-nikita.yoush@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com> Sent: Sunday, Dec=
ember 04, 2016 11:18 PM
 >To: David S. Miller <davem@davemloft.net>; Andy Duan
 ><fugang.duan@nxp.com>; Troy Kisky <troy.kisky@boundarydevices.com>;
 >Andrew Lunn <andrew@lunn.ch>; Eric Nelson <eric@nelint.com>; Philippe
 >Reynes <tremyfr@gmail.com>; Johannes Berg <johannes@sipsolutions.net>;
 >netdev@vger.kernel.org
 >Cc: Chris Healy <cphealy@gmail.com>; Fabio Estevam
 ><fabio.estevam@nxp.com>; linux-kernel@vger.kernel.org; Nikita
 >Yushchenko <nikita.yoush@cogentembedded.com>
 >Subject: [patch net] net: fec: fix compile with CONFIG_M5272
 >
 >Commit 4dfb80d18d05 ("net: fec: cache statistics while device is down")
 >introduced unconditional statistics-related actions.
 >
 >However, when driver is compiled with CONFIG_M5272, staticsics-related
 >definitions do not exist, which results into build errors.
 >
 >Fix that by adding needed #if !defined(CONFIG_M5272).
 >
 >Fixes: 4dfb80d18d05 ("net: fec: cache statistics while device is down")
 >Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
 >---
 > drivers/net/ethernet/freescale/fec_main.c | 12 +++++++++---
 > 1 file changed, 9 insertions(+), 3 deletions(-)
 >
 >diff --git a/drivers/net/ethernet/freescale/fec_main.c
 >b/drivers/net/ethernet/freescale/fec_main.c
 >index 6a20c24a2003..89e902767abb 100644
 >--- a/drivers/net/ethernet/freescale/fec_main.c
 >+++ b/drivers/net/ethernet/freescale/fec_main.c
 >@@ -2884,7 +2884,9 @@ fec_enet_close(struct net_device *ndev)
 > 	if (fep->quirks & FEC_QUIRK_ERR006687)
 > 		imx6q_cpuidle_fec_irqs_unused();
 >
 >+#if !defined(CONFIG_M5272)
 > 	fec_enet_update_ethtool_stats(ndev);
 >+#endif
It is better to define fec_enet_update_ethtool_stats()  for CONFIG_M5272 li=
ke static void fec_enet_update_ethtool_stats(struct net_device *dev){}, or =
directly return in .fec_enet_update_ethtool_stats():
@@ -2315,6 +2315,10 @@ static void fec_enet_update_ethtool_stats(struct net=
_device *dev)
        struct fec_enet_private *fep =3D netdev_priv(dev);
        int i;

+#if defined(CONFIG_M5272)
+       return;
+#endif
+
>
 > 	fec_enet_clk_enable(ndev, false);
 > 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 >@@ -3192,7 +3194,9 @@ static int fec_enet_init(struct net_device *ndev)
 >
 > 	fec_restart(ndev);
 >
 >+#if !defined(CONFIG_M5272)
 > 	fec_enet_update_ethtool_stats(ndev);
 >+#endif
 >
ditto

 > 	return 0;
 > }
 >@@ -3292,9 +3296,11 @@ fec_probe(struct platform_device *pdev)
 > 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
 >
 > 	/* Init network device */
 >-	ndev =3D alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
 >-				  ARRAY_SIZE(fec_stats) * sizeof(u64),
 >-				  num_tx_qs, num_rx_qs);
 >+	ndev =3D alloc_etherdev_mqs(sizeof(struct fec_enet_private) #if
 >+!defined(CONFIG_M5272)
 >+				  + ARRAY_SIZE(fec_stats) * sizeof(u64)
 >#endif
 >+				  , num_tx_qs, num_rx_qs);
 > 	if (!ndev)
 > 		return -ENOMEM;
 >
 >--
 >2.1.4
