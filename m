From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bnx2: 64 bit stats on all arches
Date: Thu, 08 Jul 2010 16:08:43 +0200
Message-ID: <1278598123.2651.24.camel@edumazet-laptop>
References: <C27F8246C663564A84BB7AB3439772421B842BD250@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Matthew Carlson <mcarlson@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36641 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704Ab0GHOIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 10:08:49 -0400
Received: by wyf23 with SMTP id 23so572250wyf.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 07:08:47 -0700 (PDT)
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B842BD250@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 juillet 2010 =C3=A0 07:00 -0700, Michael Chan a =C3=A9crit =
:

> It seems that GET_64BIT_NET_STATS32 is no longer needed.
> Other than that,
>=20
> Acked-by: Michael Chan <mchan@broadcom.com>
>=20
> Thanks.

Indeed, thanks for the tip !
Here is the updated version.

[PATCH net-next-2.6] bnx2: 64 bit stats on all arches

Now core network is able to handle 64 bit netdevice stats on 32 bit
arches, we can provide them for bnx2, since hardware maintains some 64
bit counters.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 22fa1e9..a203f39 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6589,36 +6589,25 @@ bnx2_save_stats(struct bnx2 *bp)
 		temp_stats[i] +=3D hw_stats[i];
 }
=20
-#define GET_64BIT_NET_STATS64(ctr)				\
-	(unsigned long) ((unsigned long) (ctr##_hi) << 32) +	\
-	(unsigned long) (ctr##_lo)
+#define GET_64BIT_NET_STATS64(ctr)		\
+	(((u64) (ctr##_hi) << 32) + (u64) (ctr##_lo))
=20
-#define GET_64BIT_NET_STATS32(ctr)				\
-	(ctr##_lo)
-
-#if (BITS_PER_LONG =3D=3D 64)
 #define GET_64BIT_NET_STATS(ctr)				\
 	GET_64BIT_NET_STATS64(bp->stats_blk->ctr) +		\
 	GET_64BIT_NET_STATS64(bp->temp_stats_blk->ctr)
-#else
-#define GET_64BIT_NET_STATS(ctr)				\
-	GET_64BIT_NET_STATS32(bp->stats_blk->ctr) +		\
-	GET_64BIT_NET_STATS32(bp->temp_stats_blk->ctr)
-#endif
=20
 #define GET_32BIT_NET_STATS(ctr)				\
 	(unsigned long) (bp->stats_blk->ctr +			\
 			 bp->temp_stats_blk->ctr)
=20
-static struct net_device_stats *
-bnx2_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *
+bnx2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net=
_stats)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
-	struct net_device_stats *net_stats =3D &dev->stats;
=20
-	if (bp->stats_blk =3D=3D NULL) {
+	if (bp->stats_blk =3D=3D NULL)
 		return net_stats;
-	}
+
 	net_stats->rx_packets =3D
 		GET_64BIT_NET_STATS(stat_IfHCInUcastPkts) +
 		GET_64BIT_NET_STATS(stat_IfHCInMulticastPkts) +
@@ -8289,7 +8278,7 @@ static const struct net_device_ops bnx2_netdev_op=
s =3D {
 	.ndo_open		=3D bnx2_open,
 	.ndo_start_xmit		=3D bnx2_start_xmit,
 	.ndo_stop		=3D bnx2_close,
-	.ndo_get_stats		=3D bnx2_get_stats,
+	.ndo_get_stats64	=3D bnx2_get_stats64,
 	.ndo_set_rx_mode	=3D bnx2_set_rx_mode,
 	.ndo_do_ioctl		=3D bnx2_ioctl,
 	.ndo_validate_addr	=3D eth_validate_addr,


