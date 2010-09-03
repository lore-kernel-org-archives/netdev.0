From: =?UTF-8?q?Diego=20Elio=20Petten=C3=B2?= <flameeyes@gmail.com>
Subject: [PATCH] sctp: implement SIOCINQ ioctl() (take 2)
Date: Fri,  3 Sep 2010 03:14:24 +0200
Message-ID: <1283476464-14341-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Diego=20Elio=20'Flameeyes'=20Petten=C3=B2?=
	<flameeyes@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57758 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761Ab0ICBOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 21:14:10 -0400
Received: by wwj40 with SMTP id 40so1656993wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 18:14:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Diego Elio 'Flameeyes' Petten=C3=B2 <flameeyes@gmail.com>

This simple patch copies the current approach for SIOCINQ ioctl() from =
DCCP
into SCTP so that the userland code working with SCTP can use a similar
interface across different protocols to know how much space to allocate=
 for
a buffer.
---
 net/sctp/socket.c |   35 ++++++++++++++++++++++++++++++++++-
 1 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ca44917..54c01e4 100644
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
+		unsigned long amount =3D 0;
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

