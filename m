From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 13/21] orinoco: simplify 802.3 encapsulation code
Date: Fri, 07 Apr 2006 04:10:45 -0400
Message-ID: <20060407081045.16107.18508.stgit@dv.roinet.com>
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

Use skb_pull() to strip the addresses from the original packet.  Don't
strip protocol bytes.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco.c |   44 ++++++++++++++++++----------------=
------
 drivers/net/wireless/orinoco.h |   14 -------------
 2 files changed, 20 insertions(+), 38 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index e7d06b9..4d63738 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -421,9 +421,8 @@ static int orinoco_xmit(struct sk_buff *
 	hermes_t *hw =3D &priv->hw;
 	int err =3D 0;
 	u16 txfid =3D priv->txfid;
-	char *p;
 	struct ethhdr *eh;
-	int data_len, data_off;
+	int data_off;
 	struct hermes_tx_descriptor desc;
 	unsigned long flags;
=20
@@ -453,8 +452,7 @@ static int orinoco_xmit(struct sk_buff *
 	}
=20
 	/* Check packet length */
-	data_len =3D skb->len;
-	if (data_len < ETH_HLEN)
+	if (skb->len < ETH_HLEN)
 		goto drop;
=20
 	eh =3D (struct ethhdr *)skb->data;
@@ -477,22 +475,22 @@ static int orinoco_xmit(struct sk_buff *
=20
 	/* Encapsulate Ethernet-II frames */
 	if (ntohs(eh->h_proto) > ETH_DATA_LEN) { /* Ethernet-II frame */
-		struct header_struct hdr;
-		data_len =3D skb->len - ETH_HLEN;
-		data_off =3D HERMES_802_3_OFFSET + sizeof(hdr);
-		p =3D skb->data + ETH_HLEN;
-
-		/* 802.3 header */
-		memcpy(hdr.dest, eh->h_dest, ETH_ALEN);
-		memcpy(hdr.src, eh->h_source, ETH_ALEN);
-		hdr.len =3D htons(data_len + ENCAPS_OVERHEAD);
-	=09
-		/* 802.2 header */
-		memcpy(&hdr.dsap, &encaps_hdr, sizeof(encaps_hdr));
-		=09
-		hdr.ethertype =3D eh->h_proto;
-		err  =3D hermes_bap_pwrite(hw, USER_BAP, &hdr, sizeof(hdr),
-					 txfid, HERMES_802_3_OFFSET);
+		struct header_struct {
+			struct ethhdr eth;	/* 802.3 header */
+			u8 encap[6];		/* 802.2 header */
+		} __attribute__ ((packed)) hdr;
+
+		/* Strip destination and source from the data */
+		skb_pull(skb, 2 * ETH_ALEN);
+		data_off =3D HERMES_802_2_OFFSET + sizeof(encaps_hdr);
+
+		/* And move them to a separate header */
+		memcpy(&hdr.eth, eh, 2 * ETH_ALEN);
+		hdr.eth.h_proto =3D htons(sizeof(encaps_hdr) + skb->len);
+		memcpy(hdr.encap, encaps_hdr, sizeof(encaps_hdr));
+
+		err =3D hermes_bap_pwrite(hw, USER_BAP, &hdr, sizeof(hdr),
+					txfid, HERMES_802_3_OFFSET);
 		if (err) {
 			if (net_ratelimit())
 				printk(KERN_ERR "%s: Error %d writing packet "
@@ -500,12 +498,10 @@ static int orinoco_xmit(struct sk_buff *
 			goto busy;
 		}
 	} else { /* IEEE 802.3 frame */
-		data_len =3D skb->len;
 		data_off =3D HERMES_802_3_OFFSET;
-		p =3D skb->data;
 	}
=20
-	err =3D hermes_bap_pwrite(hw, USER_BAP, p, data_len,
+	err =3D hermes_bap_pwrite(hw, USER_BAP, skb->data, skb->len,
 				txfid, data_off);
 	if (err) {
 		printk(KERN_ERR "%s: Error %d writing packet to BAP\n",
@@ -527,7 +523,7 @@ static int orinoco_xmit(struct sk_buff *
 	}
=20
 	dev->trans_start =3D jiffies;
-	stats->tx_bytes +=3D data_off + data_len;
+	stats->tx_bytes +=3D data_off + skb->len;
 	goto ok;
=20
  drop:
diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoc=
o.h
index c6922a7..ca01e45 100644
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -30,20 +30,6 @@ struct orinoco_key {
 	char data[ORINOCO_MAX_KEY_SIZE];
 } __attribute__ ((packed));
=20
-struct header_struct {
-	/* 802.3 */
-	u8 dest[ETH_ALEN];
-	u8 src[ETH_ALEN];
-	__be16 len;
-	/* 802.2 */
-	u8 dsap;
-	u8 ssap;
-	u8 ctrl;
-	/* SNAP */
-	u8 oui[3];
-	unsigned short ethertype;
-} __attribute__ ((packed));
-
 typedef enum {
 	FIRMWARE_TYPE_AGERE,
 	FIRMWARE_TYPE_INTERSIL,



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
