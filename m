From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Fix PPP async regression
Date: Fri, 27 Jun 2003 16:28:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627162818.606ac706.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply this patch, it fixes the PPP over async regression that the =
PPPoE
changes caused.  Basically, PPP puts a zero length skbuff in the receive =
queue
as an error token, and the last change caused that to get flushed as bad =
data.

Thanks to Diego Calleja Garc=EDa , Matthew Harrell for validating this.

diff -Nru a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c	Fri Jun 27 16:13:28 2003
+++ b/drivers/net/ppp_generic.c	Fri Jun 27 16:13:28 2003
@@ -1348,16 +1348,9 @@
 	struct channel *pch =3D chan->ppp;
 	int proto;
=20
-	if (pch =3D=3D 0)
-		goto drop;
-
-	/* need to have PPP header */
-	if (!pskb_may_pull(skb, 2)) {
-		if (pch->ppp) {
-			++pch->ppp->stats.rx_length_errors;
-			ppp_receive_error(pch->ppp);
-		}
-		goto drop;
+	if (pch =3D=3D 0 || skb->len =3D=3D 0) {
+		kfree_skb(skb);
+		return;
 	}
 =09
 	proto =3D PPP_PROTO(skb);
@@ -1374,10 +1367,6 @@
 		ppp_do_recv(pch->ppp, skb, pch);
 	}
 	read_unlock_bh(&pch->upl);
-	return;
- drop:
-	kfree_skb(skb);
-	return;
 }
=20
 /* Put a 0-length skb in the receive queue as an error indication */
@@ -1409,13 +1398,23 @@
 static void
 ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *=
pch)
 {
+	if (skb->len >=3D 2) {
 #ifdef CONFIG_PPP_MULTILINK
-	/* XXX do channel-level decompression here */
-	if (PPP_PROTO(skb) =3D=3D PPP_MP)
-		ppp_receive_mp_frame(ppp, skb, pch);
-	else
+		/* XXX do channel-level decompression here */
+		if (PPP_PROTO(skb) =3D=3D PPP_MP)
+			ppp_receive_mp_frame(ppp, skb, pch);
+		else
 #endif /* CONFIG_PPP_MULTILINK */
-		ppp_receive_nonmp_frame(ppp, skb);
+			ppp_receive_nonmp_frame(ppp, skb);
+		return;
+	}
+
+	if (skb->len > 0)
+		/* note: a 0-length skb is used as an error indication */
+		++ppp->stats.rx_length_errors;
+
+	kfree_skb(skb);
+	ppp_receive_error(ppp);
 }
=20
 static void
@@ -1448,7 +1447,7 @@
 		if (ppp->vj =3D=3D 0 || (ppp->flags & SC_REJ_COMP_TCP))
 			goto err;
=20
-		if (skb_tailroom(skb) < 124 || skb_is_nonlinear(skb) ) {
+		if (skb_tailroom(skb) < 124) {
 			/* copy to a new sk_buff with more tailroom */
 			ns =3D dev_alloc_skb(skb->len + 128);
 			if (ns =3D=3D 0) {
@@ -1460,6 +1459,9 @@
 			kfree_skb(skb);
 			skb =3D ns;
 		}
+		else if (!pskb_may_pull(skb, skb->len))
+			goto err;
+
 		len =3D slhc_uncompress(ppp->vj, skb->data + 2, skb->len - 2);
 		if (len <=3D 0) {
 			printk(KERN_DEBUG "PPP: VJ decompression error\n");
@@ -2033,12 +2035,12 @@
 static void
 ppp_ccp_peek(struct ppp *ppp, struct sk_buff *skb, int inbound)
 {
-	unsigned char *dp =3D skb->data + 2;
+	unsigned char *dp;
 	int len;
=20
-	if (!pskb_may_pull(skb, CCP_HDRLEN + 2)
-	    || skb->len < (len =3D CCP_LENGTH(dp)) + 2)
-		return;		/* too short */
+	if (!pskb_may_pull(skb, CCP_HDRLEN + 2))
+		return;	/* no header */
+	dp =3D skb->data + 2;
=20
 	switch (CCP_CODE(dp)) {
 	case CCP_CONFREQ:
@@ -2071,10 +2073,8 @@
 	case CCP_CONFACK:
 		if ((ppp->flags & (SC_CCP_OPEN | SC_CCP_UP)) !=3D SC_CCP_OPEN)
 			break;
-
-		if (!pskb_may_pull(skb, len))
-			break;
-
+		if (!pskb_may_pull(skb, len =3D CCP_LENGTH(dp)) + 2)
+			return;		/* too short */
 		dp +=3D CCP_HDRLEN;
 		len -=3D CCP_HDRLEN;
 		if (len < CCP_OPT_MINLEN || len < CCP_OPT_LENGTH(dp))
