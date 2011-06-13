From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] be2net: fix netdev_stats_update()
Date: Mon, 13 Jun 2011 08:49:08 +0200
Message-ID: <1307947748.2872.182.camel@edumazet-laptop>
References: <f67e2aac-b763-404d-8e45-5c5f52c56d18@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44235 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab1FMGtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 02:49:16 -0400
Received: by wya21 with SMTP id 21so2965851wya.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 23:49:15 -0700 (PDT)
In-Reply-To: <f67e2aac-b763-404d-8e45-5c5f52c56d18@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 juin 2011 =C3=A0 11:31 +0530, Sathya Perla a =C3=A9crit :
> This patch provides support for multiple TX queues.
>=20
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/benet/be.h         |   13 ++-
>  drivers/net/benet/be_ethtool.c |   50 +++++++---
>  drivers/net/benet/be_main.c    |  227 ++++++++++++++++++++++--------=
----------
>  3 files changed, 171 insertions(+), 119 deletions(-)
>=20

>  static void
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.=
c
> index 9ba197b..af6647a 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -427,6 +427,7 @@ void netdev_stats_update(struct be_adapter *adapt=
er)
>  	struct be_drv_stats *drvs =3D &adapter->drv_stats;
>  	struct net_device_stats *dev_stats =3D &adapter->netdev->stats;
>  	struct be_rx_obj *rxo;
> +	struct be_tx_obj *txo;
>  	int i;
> =20
>  	memset(dev_stats, 0, sizeof(*dev_stats));
> @@ -450,8 +451,10 @@ void netdev_stats_update(struct be_adapter *adap=
ter)
>  		}
>  	}
> =20
> -	dev_stats->tx_packets =3D tx_stats(adapter)->be_tx_pkts;
> -	dev_stats->tx_bytes =3D tx_stats(adapter)->be_tx_bytes;
> +	for_all_tx_queues(adapter, txo, i) {
> +		dev_stats->tx_packets +=3D tx_stats(txo)->be_tx_pkts;
> +		dev_stats->tx_bytes +=3D tx_stats(txo)->be_tx_bytes;
> +	}
> =20
>  	/* bad pkts received */
>  	dev_stats->rx_errors =3D drvs->rx_crc_errors +
> @@ -554,9 +557,9 @@ static u32 be_calc_rate(u64 bytes, unsigned long =
ticks)
>  	return rate;
>  }
> =20

Hi Sathya

Browsing into this patch made me realize be2net netdev_stats_update() i=
s
wrong.

It should not reset even temporarly netdev->stats.

You should have something like the following I cooked for linux-2.6, so
that you get the idea. Please respin your patch after applying followin=
g
fix.

[PATCH] be2net: fix netdev_stats_update()

Since this driver uses the default dev_get_stats() [ as it doesnt
provide ndo_get_stats() nor ndo_get_stats64() method ], resetting
netdev->stats can lead some SNMP readers catching intermediate values,
breaking the rule that counters only can increase in time.

We instead should use temporary accumulators and only set netdev->stats
values with final results.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/benet/be_main.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a485f7f..962509d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -427,28 +427,33 @@ void netdev_stats_update(struct be_adapter *adapt=
er)
 	struct be_drv_stats *drvs =3D &adapter->drv_stats;
 	struct net_device_stats *dev_stats =3D &adapter->netdev->stats;
 	struct be_rx_obj *rxo;
+	unsigned long rx_packets =3D 0, rx_bytes =3D 0, multicast =3D 0;
+	unsigned long rx_dropped =3D 0;
 	int i;
=20
-	memset(dev_stats, 0, sizeof(*dev_stats));
 	for_all_rx_queues(adapter, rxo, i) {
-		dev_stats->rx_packets +=3D rx_stats(rxo)->rx_pkts;
-		dev_stats->rx_bytes +=3D rx_stats(rxo)->rx_bytes;
-		dev_stats->multicast +=3D rx_stats(rxo)->rx_mcast_pkts;
+		rx_packets +=3D rx_stats(rxo)->rx_pkts;
+		rx_bytes +=3D rx_stats(rxo)->rx_bytes;
+		multicast +=3D rx_stats(rxo)->rx_mcast_pkts;
 		/*  no space in linux buffers: best possible approximation */
 		if (adapter->generation =3D=3D BE_GEN3) {
 			if (!(lancer_chip(adapter))) {
 				struct be_erx_stats_v1 *erx_stats =3D
 					be_erx_stats_from_cmd(adapter);
-				dev_stats->rx_dropped +=3D
+				rx_dropped +=3D
 				erx_stats->rx_drops_no_fragments[rxo->q.id];
 			}
 		} else {
 			struct be_erx_stats_v0 *erx_stats =3D
 					be_erx_stats_from_cmd(adapter);
-			dev_stats->rx_dropped +=3D
+			rx_dropped +=3D
 				erx_stats->rx_drops_no_fragments[rxo->q.id];
 		}
 	}
+	dev_stats->rx_packets =3D rx_packets;
+	dev_stats->rx_bytes =3D rx_bytes;
+	dev_stats->multicast =3D multicast;
+	dev_stats->rx_dropped =3D rx_dropped;
=20
 	dev_stats->tx_packets =3D tx_stats(adapter)->be_tx_pkts;
 	dev_stats->tx_bytes =3D tx_stats(adapter)->be_tx_bytes;


