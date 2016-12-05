From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [patch net v2] net: fec: fix compile with CONFIG_M5272
Date: Mon, 5 Dec 2016 09:08:24 +0000
Message-ID: <AM4PR0401MB2260AF3F6FE2D14049FADEFBFF830@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1480925763-20254-1-git-send-email-nikita.yoush@cogentembedded.com>
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
Received: from mail-db5eur01on0074.outbound.protection.outlook.com ([104.47.2.74]:48704
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751233AbcLEK67 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 05:58:59 -0500
In-Reply-To: <1480925763-20254-1-git-send-email-nikita.yoush@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com> Sent: Monday, Dec=
ember 05, 2016 4:16 PM
 >To: David S. Miller <davem@davemloft.net>; Andy Duan
 ><fugang.duan@nxp.com>; Troy Kisky <troy.kisky@boundarydevices.com>;
 >Andrew Lunn <andrew@lunn.ch>; Eric Nelson <eric@nelint.com>; Philippe
 >Reynes <tremyfr@gmail.com>; Johannes Berg <johannes@sipsolutions.net>;
 >netdev@vger.kernel.org
 >Cc: Chris Healy <cphealy@gmail.com>; Fabio Estevam
 ><fabio.estevam@nxp.com>; linux-kernel@vger.kernel.org; Nikita
 >Yushchenko <nikita.yoush@cogentembedded.com>
 >Subject: [patch net v2] net: fec: fix compile with CONFIG_M5272
 >
 >Commit 4dfb80d18d05 ("net: fec: cache statistics while device is down")
 >introduced unconditional statistics-related actions.
 >
 >However, when driver is compiled with CONFIG_M5272, staticsics-related
 >definitions do not exist, which results into build errors.
 >
 >Fix that by adding explicit handling of !defined(CONFIG_M5272) case.
 >
 >Fixes: 4dfb80d18d05 ("net: fec: cache statistics while device is down")
 >Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
 >---
 >Changes since v1:
 >- instead of #ifdef'ing calls to fec_enet_update_ethtool_stats(), add
 >  definition of empty fec_enet_update_ethtool_stats() for CONFIG_M5272
 >  case,
 >- add FEC_STATS_SIZE macro to avoid #ifdef in the middle of
 >  alloc_etherdev_mqs() args.
 >
 > drivers/net/ethernet/freescale/fec_main.c | 13 ++++++++++---
 > 1 file changed, 10 insertions(+), 3 deletions(-)
 >
Acked-by: Fugang Duan <fugang.duan@nxp.com>

 >diff --git a/drivers/net/ethernet/freescale/fec_main.c
 >b/drivers/net/ethernet/freescale/fec_main.c
 >index 5f77caa59534..741cf4a57bfc 100644
 >--- a/drivers/net/ethernet/freescale/fec_main.c
 >+++ b/drivers/net/ethernet/freescale/fec_main.c
 >@@ -2313,6 +2313,8 @@ static const struct fec_stat {
 > 	{ "IEEE_rx_octets_ok", IEEE_R_OCTETS_OK },  };
 >
 >+#define FEC_STATS_SIZE		(ARRAY_SIZE(fec_stats) * sizeof(u64))
 >+
 > static void fec_enet_update_ethtool_stats(struct net_device *dev)  {
 > 	struct fec_enet_private *fep =3D netdev_priv(dev); @@ -2330,7
 >+2332,7 @@ static void fec_enet_get_ethtool_stats(struct net_device *dev,
 > 	if (netif_running(dev))
 > 		fec_enet_update_ethtool_stats(dev);
 >
 >-	memcpy(data, fep->ethtool_stats, ARRAY_SIZE(fec_stats) *
 >sizeof(u64));
 >+	memcpy(data, fep->ethtool_stats, FEC_STATS_SIZE);
 > }
 >
 > static void fec_enet_get_strings(struct net_device *netdev, @@ -2355,6
 >+2357,12 @@ static int fec_enet_get_sset_count(struct net_device *dev, in=
t
 >sset)
 > 		return -EOPNOTSUPP;
 > 	}
 > }
 >+
 >+#else	/* !defined(CONFIG_M5272) */
 >+#define FEC_STATS_SIZE	0
 >+static inline void fec_enet_update_ethtool_stats(struct net_device
 >+*dev) { }
 > #endif /* !defined(CONFIG_M5272) */
 >
 > static int fec_enet_nway_reset(struct net_device *dev) @@ -3293,8
 >+3301,7 @@ fec_probe(struct platform_device *pdev)
 >
 > 	/* Init network device */
 > 	ndev =3D alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
 >-				  ARRAY_SIZE(fec_stats) * sizeof(u64),
 >-				  num_tx_qs, num_rx_qs);
 >+				  FEC_STAT_SIZE, num_tx_qs, num_rx_qs);
 > 	if (!ndev)
 > 		return -ENOMEM;
 >
 >--
 >2.1.4
