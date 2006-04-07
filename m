From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 12/21] orinoco: refactor and clean up Tx error handling
Date: Fri, 07 Apr 2006 04:10:43 -0400
Message-ID: <20060407081043.16107.62995.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

The result of orinoco_xmit() can be OK, dropped packet and busy
transmitter.  Rename labels accordingly.  Increment stats->tx_errors in
one place.  Increment stats->tx_dropped - nobody is doing it for us.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco.c |   29 +++++++++++++----------------
 1 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index 9fde17b..e7d06b9 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -449,16 +449,13 @@ static int orinoco_xmit(struct sk_buff *
 		/* Oops, the firmware hasn't established a connection,
                    silently drop the packet (this seems to be the
                    safest approach). */
-		stats->tx_errors++;
-		orinoco_unlock(priv, &flags);
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
+		goto drop;
 	}
=20
 	/* Check packet length */
 	data_len =3D skb->len;
 	if (data_len < ETH_HLEN)
-		goto fail;
+		goto drop;
=20
 	eh =3D (struct ethhdr *)skb->data;
=20
@@ -469,8 +466,7 @@ static int orinoco_xmit(struct sk_buff *
 		if (net_ratelimit())
 			printk(KERN_ERR "%s: Error %d writing Tx descriptor "
 			       "to BAP\n", dev->name, err);
-		stats->tx_errors++;
-		goto fail;
+		goto busy;
 	}
=20
 	/* Clear the 802.11 header and data length fields - some
@@ -501,8 +497,7 @@ static int orinoco_xmit(struct sk_buff *
 			if (net_ratelimit())
 				printk(KERN_ERR "%s: Error %d writing packet "
 				       "header to BAP\n", dev->name, err);
-			stats->tx_errors++;
-			goto fail;
+			goto busy;
 		}
 	} else { /* IEEE 802.3 frame */
 		data_len =3D skb->len;
@@ -515,8 +510,7 @@ static int orinoco_xmit(struct sk_buff *
 	if (err) {
 		printk(KERN_ERR "%s: Error %d writing packet to BAP\n",
 		       dev->name, err);
-		stats->tx_errors++;
-		goto fail;
+		goto busy;
 	}
=20
 	/* Finally, we actually initiate the send */
@@ -529,20 +523,23 @@ static int orinoco_xmit(struct sk_buff *
 		if (net_ratelimit())
 			printk(KERN_ERR "%s: Error %d transmitting packet\n",
 				dev->name, err);
-		stats->tx_errors++;
-		goto fail;
+		goto busy;
 	}
=20
 	dev->trans_start =3D jiffies;
 	stats->tx_bytes +=3D data_off + data_len;
+	goto ok;
=20
-	orinoco_unlock(priv, &flags);
+ drop:
+	stats->tx_errors++;
+	stats->tx_dropped++;
=20
+ ok:
+	orinoco_unlock(priv, &flags);
 	dev_kfree_skb(skb);
-
 	return NETDEV_TX_OK;
- fail:
=20
+ busy:
 	orinoco_unlock(priv, &flags);
 	return NETDEV_TX_BUSY;
 }



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
