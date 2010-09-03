From: =?UTF-8?q?Diego=20Elio=20Petten=C3=B2?= <flameeyes@gmail.com>
Subject: [PATCH] sctp: implement SIOCINQ ioctl() (take 3)
Date: Fri,  3 Sep 2010 15:47:03 +0200
Message-ID: <1283521623-1609-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org,
	=?UTF-8?q?Diego=20Elio=20'Flameeyes'=20Petten=C3=B2?=
	<flameeyes@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab0ICNrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 09:47:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Diego Elio 'Flameeyes' Petten=C3=B2 <flameeyes@gmail.com>

This simple patch copies the current approach for SIOCINQ ioctl() from =
DCCP
into SCTP so that the userland code working with SCTP can use a similar
interface across different protocols to know how much space to allocate=
 for
a buffer.

Signed-off-by: Diego Elio Petten=C3=B2 <flameeyes@gmail.com>
---
 net/sctp/socket.c |   35 ++++++++++++++++++++++++++++++++++-
 1 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ca44917..199ec05 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3595,7 +3595,40 @@ out:
 /* The SCTP ioctl handler. */
 SCTP_STATIC int sctp_ioctl(struct sock *sk, int cmd, unsigned long arg=
)
 {
-	return -ENOIOCTLCMD;
+	int rc =3D -ENOTCONN;
+
+	sctp_lock_sock(sk);
+
+	/*
+	 * SEQPACKET-style sockets in LISTENING state are valid, for
+	 * SCTP, so only discard TCP-style sockets in LISTENING state.
+	 */
+	if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
+		goto out;
+
+	switch (cmd) {
+	case SIOCINQ: {
+		struct sk_buff *skb;
+		unsigned int amount =3D 0;
+
+		skb =3D skb_peek(&sk->sk_receive_queue);
+		if (skb !=3D NULL) {
+			/*
+			 * We will only return the amount of this packet since
+			 * that is all that will be read.
+			 */
+			amount =3D skb->len;
+		}
+		rc =3D put_user(amount, (int __user *)arg);
+	}
+		break;
+	default:
+		rc =3D -ENOIOCTLCMD;
+		break;
+	}
+out:
+	sctp_release_sock(sk);
+	return rc;
 }
=20
 /* This is the function which gets called during socket creation to
--=20
1.7.2.2

