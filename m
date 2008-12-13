From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 07/11] ax25: join the return paths that free skb
Date: Sat, 13 Dec 2008 21:21:18 +0200
Message-ID: <1229196082-4162-8-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1229196082-4162-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47433 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbYLMTVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:21:25 -0500
In-Reply-To: <1229196082-4162-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ax25/ax25_in.c |   41 +++++++++++++++--------------------------
 1 files changed, 15 insertions(+), 26 deletions(-)

diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 4a5ba97..5f1d210 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -200,19 +200,15 @@ static int ax25_rcv(struct sk_buff *skb, struct n=
et_device *dev,
=20
 	skb_reset_transport_header(skb);
=20
-	if ((ax25_dev =3D ax25_dev_ax25dev(dev)) =3D=3D NULL) {
-		kfree_skb(skb);
-		return 0;
-	}
+	if ((ax25_dev =3D ax25_dev_ax25dev(dev)) =3D=3D NULL)
+		goto free;
=20
 	/*
 	 *	Parse the address header.
 	 */
=20
-	if (ax25_addr_parse(skb->data, skb->len, &src, &dest, &dp, &type, &da=
ma) =3D=3D NULL) {
-		kfree_skb(skb);
-		return 0;
-	}
+	if (ax25_addr_parse(skb->data, skb->len, &src, &dest, &dp, &type, &da=
ma) =3D=3D NULL)
+		goto free;
=20
 	/*
 	 *	Ours perhaps ?
@@ -239,10 +235,8 @@ static int ax25_rcv(struct sk_buff *skb, struct ne=
t_device *dev,
=20
 		ax25_send_to_raw(&dest, skb, skb->data[1]);
=20
-		if (!mine && ax25cmp(&dest, (ax25_address *)dev->broadcast) !=3D 0) =
{
-			kfree_skb(skb);
-			return 0;
-		}
+		if (!mine && ax25cmp(&dest, (ax25_address *)dev->broadcast) !=3D 0)
+			goto free;
=20
 		/* Now we are pointing at the pid byte */
 		switch (skb->data[1]) {
@@ -301,10 +295,8 @@ static int ax25_rcv(struct sk_buff *skb, struct ne=
t_device *dev,
 	 *	If not, should we DM the incoming frame (except DMs) or
 	 *	silently ignore them. For now we stay quiet.
 	 */
-	if (ax25_dev->values[AX25_VALUES_CONMODE] =3D=3D 0) {
-		kfree_skb(skb);
-		return 0;
-	}
+	if (ax25_dev->values[AX25_VALUES_CONMODE] =3D=3D 0)
+		goto free;
=20
 	/* LAPB */
=20
@@ -339,8 +331,7 @@ static int ax25_rcv(struct sk_buff *skb, struct net=
_device *dev,
 		if ((*skb->data & ~AX25_PF) !=3D AX25_DM && mine)
 			ax25_return_dm(dev, &src, &dest, &dp);
=20
-		kfree_skb(skb);
-		return 0;
+		goto free;
 	}
=20
 	/* b) received SABM(E) */
@@ -372,15 +363,12 @@ static int ax25_rcv(struct sk_buff *skb, struct n=
et_device *dev,
 		sk->sk_ack_backlog++;
 		bh_unlock_sock(sk);
 	} else {
-		if (!mine) {
-			kfree_skb(skb);
-			return 0;
-		}
+		if (!mine)
+			goto free;
=20
 		if ((ax25 =3D ax25_create_cb()) =3D=3D NULL) {
 			ax25_return_dm(dev, &src, &dest, &dp);
-			kfree_skb(skb);
-			return 0;
+			goto free;
 		}
=20
 		ax25_fillin_cb(ax25, ax25_dev);
@@ -436,9 +424,10 @@ static int ax25_rcv(struct sk_buff *skb, struct ne=
t_device *dev,
 		if (!sock_flag(sk, SOCK_DEAD))
 			sk->sk_data_ready(sk, skb->len);
 		sock_put(sk);
-	} else
+	} else {
+free:
 		kfree_skb(skb);
-
+	}
 	return 0;
 }
=20
--=20
1.5.2.2

