From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 11/21] orinoco: don't use any padding for Tx frames
Date: Fri, 07 Apr 2006 04:10:41 -0400
Message-ID: <20060407081041.16107.255.stgit@dv.roinet.com>
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

hermes_bap_pwrite() supports odd-sized packets now.   There is no
minimal packet size for 802.11.  Also, hermes_bap_pwrite() supports
odd-sized packets now.  This removes all reasons to pad the Tx data.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/hermes.c  |   38 ----------------------------------=
----
 drivers/net/wireless/hermes.h  |    2 --
 drivers/net/wireless/orinoco.c |   25 +++++++------------------
 3 files changed, 7 insertions(+), 58 deletions(-)

diff --git a/drivers/net/wireless/hermes.c b/drivers/net/wireless/hermes.=
c
index be24f01..2aa2f38 100644
--- a/drivers/net/wireless/hermes.c
+++ b/drivers/net/wireless/hermes.c
@@ -424,43 +424,6 @@ int hermes_bap_pwrite(hermes_t *hw, int=20
 	return err;
 }
=20
-/* Write a block of data to the chip's buffer with padding if
- * neccessary, via the BAP. Synchronization/serialization is the
- * caller's problem.
- *
- * Returns: < 0 on internal failure (errno), 0 on success, > 0 on error =
from firmware
- */
-int hermes_bap_pwrite_pad(hermes_t *hw, int bap, const void *buf, unsign=
ed data_len, int len,
-		      u16 id, u16 offset)
-{
-	int dreg =3D bap ? HERMES_DATA1 : HERMES_DATA0;
-	int err =3D 0;
-
-	if (len < 0 || data_len > len)
-		return -EINVAL;
-
-	err =3D hermes_bap_seek(hw, bap, id, offset);
-	if (err)
-		goto out;
-
-	/* Transfer all the complete words of data */
-	hermes_write_bytes(hw, dreg, buf, data_len);
-	/* If there is an odd byte left over pad and transfer it */
-	if (data_len & 1) {
-		u8 end[2];
-		end[1] =3D 0;
-		end[0] =3D ((unsigned char *)buf)[data_len - 1];
-		hermes_write_bytes(hw, dreg, end, 2);
-		data_len ++;
-	}
-	/* Now send zeros for the padding */
-	if (data_len < len)
-		hermes_clear_words(hw, dreg, (len - data_len) / 2);
-	/* Complete */
- out:
-	return err;
-}
-
 /* Read a Length-Type-Value record from the card.
  *
  * If length is NULL, we ignore the length read from the card, and
@@ -548,7 +511,6 @@ EXPORT_SYMBOL(hermes_allocate);
=20
 EXPORT_SYMBOL(hermes_bap_pread);
 EXPORT_SYMBOL(hermes_bap_pwrite);
-EXPORT_SYMBOL(hermes_bap_pwrite_pad);
 EXPORT_SYMBOL(hermes_read_ltv);
 EXPORT_SYMBOL(hermes_write_ltv);
=20
diff --git a/drivers/net/wireless/hermes.h b/drivers/net/wireless/hermes.=
h
index e1b279e..8e3f0e3 100644
--- a/drivers/net/wireless/hermes.h
+++ b/drivers/net/wireless/hermes.h
@@ -359,8 +359,6 @@ int hermes_bap_pread(hermes_t *hw, int b
 		       u16 id, u16 offset);
 int hermes_bap_pwrite(hermes_t *hw, int bap, const void *buf, int len,
 			u16 id, u16 offset);
-int hermes_bap_pwrite_pad(hermes_t *hw, int bap, const void *buf,
-			unsigned data_len, int len, u16 id, u16 offset);
 int hermes_read_ltv(hermes_t *hw, int bap, u16 rid, unsigned buflen,
 		    u16 *length, void *buf);
 int hermes_write_ltv(hermes_t *hw, int bap, u16 rid,
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index 173e9e4..9fde17b 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -423,7 +423,7 @@ static int orinoco_xmit(struct sk_buff *
 	u16 txfid =3D priv->txfid;
 	char *p;
 	struct ethhdr *eh;
-	int len, data_len, data_off;
+	int data_len, data_off;
 	struct hermes_tx_descriptor desc;
 	unsigned long flags;
=20
@@ -455,13 +455,10 @@ static int orinoco_xmit(struct sk_buff *
 		return NETDEV_TX_OK;
 	}
=20
-	/* Length of the packet body */
-	/* FIXME: what if the skb is smaller than this? */
-	len =3D max_t(int, ALIGN(skb->len, 2), ETH_ZLEN);
-	skb =3D skb_padto(skb, len);
-	if (skb =3D=3D NULL)
+	/* Check packet length */
+	data_len =3D skb->len;
+	if (data_len < ETH_HLEN)
 		goto fail;
-	len -=3D ETH_HLEN;
=20
 	eh =3D (struct ethhdr *)skb->data;
=20
@@ -485,7 +482,7 @@ static int orinoco_xmit(struct sk_buff *
 	/* Encapsulate Ethernet-II frames */
 	if (ntohs(eh->h_proto) > ETH_DATA_LEN) { /* Ethernet-II frame */
 		struct header_struct hdr;
-		data_len =3D len;
+		data_len =3D skb->len - ETH_HLEN;
 		data_off =3D HERMES_802_3_OFFSET + sizeof(hdr);
 		p =3D skb->data + ETH_HLEN;
=20
@@ -507,21 +504,13 @@ static int orinoco_xmit(struct sk_buff *
 			stats->tx_errors++;
 			goto fail;
 		}
-		/* Actual xfer length - allow for padding */
-		len =3D ALIGN(data_len, 2);
-		if (len < ETH_ZLEN - ETH_HLEN)
-			len =3D ETH_ZLEN - ETH_HLEN;
 	} else { /* IEEE 802.3 frame */
-		data_len =3D len + ETH_HLEN;
+		data_len =3D skb->len;
 		data_off =3D HERMES_802_3_OFFSET;
 		p =3D skb->data;
-		/* Actual xfer length - round up for odd length packets */
-		len =3D ALIGN(data_len, 2);
-		if (len < ETH_ZLEN)
-			len =3D ETH_ZLEN;
 	}
=20
-	err =3D hermes_bap_pwrite_pad(hw, USER_BAP, p, data_len, len,
+	err =3D hermes_bap_pwrite(hw, USER_BAP, p, data_len,
 				txfid, data_off);
 	if (err) {
 		printk(KERN_ERR "%s: Error %d writing packet to BAP\n",



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
