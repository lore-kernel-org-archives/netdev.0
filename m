From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [patch net] net: fec: cache statistics while device is down
Date: Tue, 29 Nov 2016 01:22:01 +0000
Message-ID: <AM4PR0401MB2260081367AC9A140448A631FF8D0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1480343227-725-1-git-send-email-nikita.yoush@cogentembedded.com>
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
Received: from mail-db5eur01on0075.outbound.protection.outlook.com ([104.47.2.75]:22560
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751758AbcK2By3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 20:54:29 -0500
In-Reply-To: <1480343227-725-1-git-send-email-nikita.yoush@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com> Sent: Monday, Nov=
ember 28, 2016 10:27 PM
 >To: David S. Miller <davem@davemloft.net>; Andy Duan
 ><fugang.duan@nxp.com>; Troy Kisky <troy.kisky@boundarydevices.com>;
 >Andrew Lunn <andrew@lunn.ch>; Eric Nelson <eric@nelint.com>; Philippe
 >Reynes <tremyfr@gmail.com>; Johannes Berg <johannes@sipsolutions.net>;
 >netdev@vger.kernel.org
 >Cc: Chris Healy <cphealy@gmail.com>; Fabio Estevam
 ><fabio.estevam@nxp.com>; linux-kernel@vger.kernel.org; Nikita
 >Yushchenko <nikita.yoush@cogentembedded.com>
 >Subject: [patch net] net: fec: cache statistics while device is down
 >
 >Execution 'ethtool -S' on fec device that is down causes OOPS on Vybrid
 >board:
 >
 >Unhandled fault: external abort on non-linefetch (0x1008) at 0xe0898200 p=
gd
 >=3D ddecc000 [e0898200] *pgd=3D9e406811, *pte=3D400d1653, *ppte=3D400d145=
3
 >Internal error: : 1008 [#1] SMP ARM ...
 >
 >Reason of OOPS is that fec_enet_get_ethtool_stats() accesses fec register=
s
 >while IPG clock is stopped by PM.
 >
 >Fix that by caching statistics in fec_enet_private. Cache is updated just
 >before statistics request if device is up, and also just before turning d=
evice
 >off on down path.
 >
 >Additional locking is not needed, since cached statistics is always updat=
ed
 >under rtnl_lock().
 >
 >Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
 >---
 > drivers/net/ethernet/freescale/fec.h      |  2 ++
 > drivers/net/ethernet/freescale/fec_main.c | 21 +++++++++++++++++----
 > 2 files changed, 19 insertions(+), 4 deletions(-)
 >
 >diff --git a/drivers/net/ethernet/freescale/fec.h
 >b/drivers/net/ethernet/freescale/fec.h
 >index c865135f3cb9..5ea740b4cf14 100644
 >--- a/drivers/net/ethernet/freescale/fec.h
 >+++ b/drivers/net/ethernet/freescale/fec.h
 >@@ -574,6 +574,8 @@ struct fec_enet_private {
 > 	unsigned int reload_period;
 > 	int pps_enable;
 > 	unsigned int next_counter;
 >+
 >+	u64 ethtool_stats[0];
 > };
 >
 > void fec_ptp_init(struct platform_device *pdev); diff --git
 >a/drivers/net/ethernet/freescale/fec_main.c
 >b/drivers/net/ethernet/freescale/fec_main.c
 >index 5aa9d4ded214..7da2d94ec8e5 100644
 >--- a/drivers/net/ethernet/freescale/fec_main.c
 >+++ b/drivers/net/ethernet/freescale/fec_main.c
 >@@ -2313,14 +2313,24 @@ static const struct fec_stat {
 > 	{ "IEEE_rx_octets_ok", IEEE_R_OCTETS_OK },  };
 >
 >-static void fec_enet_get_ethtool_stats(struct net_device *dev,
 >-	struct ethtool_stats *stats, u64 *data)
 >+static void fec_enet_update_ethtool_stats(struct net_device *dev)
 > {
 > 	struct fec_enet_private *fep =3D netdev_priv(dev);
 > 	int i;
 >
 > 	for (i =3D 0; i < ARRAY_SIZE(fec_stats); i++)
 >-		data[i] =3D readl(fep->hwp + fec_stats[i].offset);
 >+		fep->ethtool_stats[i] =3D readl(fep->hwp +
 >fec_stats[i].offset); }
 >+
 >+static void fec_enet_get_ethtool_stats(struct net_device *dev,
 >+				       struct ethtool_stats *stats, u64 *data) {
 >+	struct fec_enet_private *fep =3D netdev_priv(dev);
 >+
 >+	if (netif_running(dev))
 >+		fec_enet_update_ethtool_stats(dev);
 >+
 >+	memcpy(data, fep->ethtool_stats, ARRAY_SIZE(fec_stats) *
 >sizeof(u64));
 > }
 >
 > static void fec_enet_get_strings(struct net_device *netdev, @@ -2874,6
 >+2884,8 @@ fec_enet_close(struct net_device *ndev)
 > 	if (fep->quirks & FEC_QUIRK_ERR006687)
 > 		imx6q_cpuidle_fec_irqs_unused();
 >
 >+	fec_enet_update_ethtool_stats(ndev);
 >+
If user never open the interface, ethtool_stats[] always is 0 that are not =
expected.
So, it also should be called at . fec_enet_init() ?

 > 	fec_enet_clk_enable(ndev, false);
 > 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 > 	pm_runtime_mark_last_busy(&fep->pdev->dev);
 >@@ -3278,7 +3290,8 @@ fec_probe(struct platform_device *pdev)
 > 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
 >
 > 	/* Init network device */
 >-	ndev =3D alloc_etherdev_mqs(sizeof(struct fec_enet_private),
 >+	ndev =3D alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
 >+				  ARRAY_SIZE(fec_stats) * sizeof(u64),
 > 				  num_tx_qs, num_rx_qs);
 > 	if (!ndev)
 > 		return -ENOMEM;
 >--
 >2.1.4
