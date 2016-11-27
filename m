From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: turn on device when extracting statistics
Date: Sun, 27 Nov 2016 06:25:54 +0000
Message-ID: <AM4PR0401MB22601ACDFB926E5AE58A0B69FF8B0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1480068120-22137-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Chris Healy <cphealy@gmail.com>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        "Andrew Lunn" <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0088.outbound.protection.outlook.com ([104.47.2.88]:59712
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753222AbcK0GZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 01:25:59 -0500
In-Reply-To: <1480068120-22137-1-git-send-email-nikita.yoush@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com> Sent: Friday, Nov=
ember 25, 2016 6:02 PM
 >To: Andy Duan <fugang.duan@nxp.com>; David S. Miller
 ><davem@davemloft.net>; Troy Kisky <troy.kisky@boundarydevices.com>;
 >Andrew Lunn <andrew@lunn.ch>; Eric Nelson <eric@nelint.com>; Philippe
 >Reynes <tremyfr@gmail.com>; Johannes Berg <johannes@sipsolutions.net>;
 >netdev@vger.kernel.org; linux-kernel@vger.kernel.org
 >Cc: Chris Healy <cphealy@gmail.com>; Nikita Yushchenko
 ><nikita.yoush@cogentembedded.com>
 >Subject: [PATCH] net: fec: turn on device when extracting statistics
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
 >Fix that by wrapping statistics extraction into pm_runtime_get_sync() ...
 >pm_runtime_put_autosuspend() braces.
 >
 >Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
 >---

Acked-by: Fugang Duan <fugang.duan@nxp.com>

 > drivers/net/ethernet/freescale/fec_main.c | 11 ++++++++++-
 > 1 file changed, 10 insertions(+), 1 deletion(-)
 >
 >diff --git a/drivers/net/ethernet/freescale/fec_main.c
 >b/drivers/net/ethernet/freescale/fec_main.c
 >index 5aa9d4ded214..9c7592b80ce8 100644
 >--- a/drivers/net/ethernet/freescale/fec_main.c
 >+++ b/drivers/net/ethernet/freescale/fec_main.c
 >@@ -2317,10 +2317,19 @@ static void fec_enet_get_ethtool_stats(struct
 >net_device *dev,
 > 	struct ethtool_stats *stats, u64 *data)  {
 > 	struct fec_enet_private *fep =3D netdev_priv(dev);
 >-	int i;
 >+	int i, ret;
 >+
 >+	ret =3D pm_runtime_get_sync(&fep->pdev->dev);
 >+	if (IS_ERR_VALUE(ret)) {
 >+		memset(data, 0, sizeof(*data) * ARRAY_SIZE(fec_stats));
 >+		return;
 >+	}
 >
 > 	for (i =3D 0; i < ARRAY_SIZE(fec_stats); i++)
 > 		data[i] =3D readl(fep->hwp + fec_stats[i].offset);
 >+
 >+	pm_runtime_mark_last_busy(&fep->pdev->dev);
 >+	pm_runtime_put_autosuspend(&fep->pdev->dev);
 > }
 >
 > static void fec_enet_get_strings(struct net_device *netdev,
 >--
 >2.1.4
