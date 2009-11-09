From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next] Phonet: allocate and copy for pipe TX without sock lock
Date: Mon,  9 Nov 2009 16:06:40 +0200
Message-ID: <1257775600-23389-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:44691 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939AbZKIOGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 09:06:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index cbaa1d6..bdc17bd 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -843,7 +843,7 @@ static int pep_sendmsg(struct kiocb *iocb, struct s=
ock *sk,
 			struct msghdr *msg, size_t len)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
-	struct sk_buff *skb =3D NULL;
+	struct sk_buff *skb;
 	long timeo;
 	int flags =3D msg->msg_flags;
 	int err, done;
@@ -851,6 +851,16 @@ static int pep_sendmsg(struct kiocb *iocb, struct =
sock *sk,
 	if (msg->msg_flags & MSG_OOB || !(msg->msg_flags & MSG_EOR))
 		return -EOPNOTSUPP;
=20
+	skb =3D sock_alloc_send_skb(sk, MAX_PNPIPE_HEADER + len,
+					flags & MSG_DONTWAIT, &err);
+	if (!skb)
+		return -ENOBUFS;
+
+	skb_reserve(skb, MAX_PHONET_HEADER + 3);
+	err =3D memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	if (err < 0)
+		goto outfree;
+
 	lock_sock(sk);
 	timeo =3D sock_sndtimeo(sk, flags & MSG_DONTWAIT);
 	if ((1 << sk->sk_state) & (TCPF_LISTEN|TCPF_CLOSE)) {
@@ -894,28 +904,13 @@ disabled:
 			goto disabled;
 	}
=20
-	if (!skb) {
-		skb =3D sock_alloc_send_skb(sk, MAX_PNPIPE_HEADER + len,
-						flags & MSG_DONTWAIT, &err);
-		if (skb =3D=3D NULL)
-			goto out;
-		skb_reserve(skb, MAX_PHONET_HEADER + 3);
-
-		if (sk->sk_state !=3D TCP_ESTABLISHED ||
-		    !atomic_read(&pn->tx_credits))
-			goto disabled; /* sock_alloc_send_skb might sleep */
-	}
-
-	err =3D memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
-	if (err < 0)
-		goto out;
-
 	err =3D pipe_skb_send(sk, skb);
 	if (err >=3D 0)
 		err =3D len; /* success! */
 	skb =3D NULL;
 out:
 	release_sock(sk);
+outfree:
 	kfree_skb(skb);
 	return err;
 }
--=20
1.6.3.3

