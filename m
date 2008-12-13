From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 06/11] can: merge error paths
Date: Sat, 13 Dec 2008 21:17:46 +0200
Message-ID: <12291958712963-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229195871718-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711089-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711225-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958713600-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958712305-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41228 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbYLMTRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:17:55 -0500
In-Reply-To: <12291958712305-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>
Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
---
 net/can/raw.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/can/raw.c b/net/can/raw.c
index 6e0663f..27aab63 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -641,17 +641,12 @@ static int raw_sendmsg(struct kiocb *iocb, struct=
 socket *sock,
=20
 	skb =3D sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT,
 				  &err);
-	if (!skb) {
-		dev_put(dev);
-		return err;
-	}
+	if (!skb)
+		goto put_dev;
=20
 	err =3D memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
-	if (err < 0) {
-		kfree_skb(skb);
-		dev_put(dev);
-		return err;
-	}
+	if (err < 0)
+		goto free_skb;
 	skb->dev =3D dev;
 	skb->sk  =3D sk;
=20
@@ -660,9 +655,16 @@ static int raw_sendmsg(struct kiocb *iocb, struct =
socket *sock,
 	dev_put(dev);
=20
 	if (err)
-		return err;
+		goto send_failed;
=20
 	return size;
+
+free_skb:
+	kfree_skb(skb);
+put_dev:
+	dev_put(dev);
+send_failed:
+	return err;
 }
=20
 static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
--=20
1.5.2.2

