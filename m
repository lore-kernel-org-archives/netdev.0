From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: Re: [PATCH] slip: cleanup statistics generation
Date: Wed, 3 Aug 2011 15:02:18 +0400
Message-ID: <CAKh5naZiFHjQ_q00iBk1kz5XCU9E4wC+7Pxd-8w=v96z-f0Vig@mail.gmail.com>
References: <CAKh5naZEyehLdP=sHM8H3_+n7ieto0YC_6hn3x=A+y823Gqs-Q@mail.gmail.com>
 <20110803.032632.1644745928704394302.davem@redhat.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60653 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107Ab1HCLCj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 07:02:39 -0400
Received: by vws1 with SMTP id 1so205160vws.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 04:02:38 -0700 (PDT)
In-Reply-To: <20110803.032632.1644745928704394302.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/3 David Miller <davem@redhat.com>:
> Test compile your changes much?
>
> drivers/net/slip.c: In function 'sl_get_stats64':
> drivers/net/slip.c:582:50: error: request for member =91stats=92 in s=
omething not a structure or union

OMG, sorry for the typo. Here is the correct patch.

Subject: [PATCH] slip: cleanup statistics generation

Remove unused tx_compressed, tx_compressed and tx_misses fields from
the slip structure. Also, make some device stats generation cleanups.

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |   29 ++++++++++++++---------------
 drivers/net/slip.h |    9 ---------
 2 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index f11b3f3..cbe8865 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -562,34 +562,33 @@ static struct rtnl_link_stats64 *
 sl_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats=
)
 {
 	struct net_device_stats *devstats =3D &dev->stats;
-	unsigned long c_rx_dropped =3D 0;
 #ifdef SL_INCLUDE_CSLIP
-	unsigned long c_rx_fifo_errors =3D 0;
-	unsigned long c_tx_fifo_errors =3D 0;
-	unsigned long c_collisions =3D 0;
 	struct slip *sl =3D netdev_priv(dev);
 	struct slcompress *comp =3D sl->slcomp;
-
-	if (comp) {
-		c_rx_fifo_errors =3D comp->sls_i_compressed;
-		c_rx_dropped     =3D comp->sls_i_tossed;
-		c_tx_fifo_errors =3D comp->sls_o_compressed;
-		c_collisions     =3D comp->sls_o_misses;
-	}
-	stats->rx_fifo_errors =3D sl->rx_compressed + c_rx_fifo_errors;
-	stats->tx_fifo_errors =3D sl->tx_compressed + c_tx_fifo_errors;
-	stats->collisions     =3D sl->tx_misses + c_collisions;
 #endif
 	stats->rx_packets     =3D devstats->rx_packets;
 	stats->tx_packets     =3D devstats->tx_packets;
 	stats->rx_bytes       =3D devstats->rx_bytes;
 	stats->tx_bytes       =3D devstats->tx_bytes;
-	stats->rx_dropped     =3D devstats->rx_dropped + c_rx_dropped;
+	stats->rx_dropped     =3D devstats->rx_dropped;
 	stats->tx_dropped     =3D devstats->tx_dropped;
 	stats->tx_errors      =3D devstats->tx_errors;
 	stats->rx_errors      =3D devstats->rx_errors;
 	stats->rx_over_errors =3D devstats->rx_over_errors;

+#ifdef SL_INCLUDE_CSLIP
+	if (comp) {
+		/* Generic compressed statistics */
+		stats->rx_compressed   =3D comp->sls_i_compressed;
+		stats->tx_compressed   =3D comp->sls_o_compressed;
+
+		/* Are we really still needs this? */
+		stats->rx_fifo_errors +=3D comp->sls_i_compressed;
+		stats->rx_dropped     +=3D comp->sls_i_tossed;
+		stats->tx_fifo_errors +=3D comp->sls_o_compressed;
+		stats->collisions     +=3D comp->sls_o_misses;
+	}
+#endif
 	return stats;
 }

diff --git a/drivers/net/slip.h b/drivers/net/slip.h
index aa0764c..67673cf 100644
--- a/drivers/net/slip.h
+++ b/drivers/net/slip.h
@@ -65,15 +65,6 @@ struct slip {
   unsigned char		*xbuff;		/* transmitter buffer		*/
   unsigned char         *xhead;         /* pointer to next byte to XMI=
T */
   int                   xleft;          /* bytes left in XMIT queue   =
  */
-
-  /* SLIP interface statistics. */
-#ifdef SL_INCLUDE_CSLIP
-  unsigned long		tx_compressed;
-  unsigned long		rx_compressed;
-  unsigned long		tx_misses;
-#endif
-  /* Detailed SLIP statistics. */
-
   int			mtu;		/* Our mtu (to spot changes!)   */
   int                   buffsize;       /* Max buffers sizes          =
  */

--=20
1.7.6
