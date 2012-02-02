From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 2/2] caif: Bugfix double kfree_skb upon xmit failure
Date: Thu,  2 Feb 2012 12:21:03 +0100
Message-ID: <1328181663-13853-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1328181663-13853-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m020-f174.google.com ([209.85.217.174]:58974 "EHLO
	mail-lpp01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755572Ab2BBLVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 06:21:09 -0500
Received: by lbom4 with SMTP id m4so338139lbo.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 03:21:07 -0800 (PST)
In-Reply-To: <1328181663-13853-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

SKB is freed twice upon send error. The Network stack consumes SKB even
when it returns error code.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index a986280..a97d97a 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -539,8 +539,10 @@ static int transmit_skb(struct sk_buff *skb, struc=
t caifsock *cf_sk,
 	pkt =3D cfpkt_fromnative(CAIF_DIR_OUT, skb);
 	memset(skb->cb, 0, sizeof(struct caif_payload_info));
=20
-	if (cf_sk->layer.dn =3D=3D NULL)
+	if (cf_sk->layer.dn =3D=3D NULL) {
+		kfree_skb(skb);
 		return -EINVAL;
+	}
=20
 	return cf_sk->layer.dn->transmit(cf_sk->layer.dn, pkt);
 }
@@ -683,10 +685,10 @@ static int caif_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 		}
 		err =3D transmit_skb(skb, cf_sk,
 				msg->msg_flags&MSG_DONTWAIT, timeo);
-		if (err < 0) {
-			kfree_skb(skb);
+		if (err < 0)
+			/* skb is already freed */
 			goto pipe_err;
-		}
+
 		sent +=3D size;
 	}
=20
--=20
1.7.5.4
