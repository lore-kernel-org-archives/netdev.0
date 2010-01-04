From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 3/3] Phonet: reject unsupported sendmsg/recvmsg flags
Date: Mon,  4 Jan 2010 14:02:49 +0200
Message-ID: <1262606569-3021-3-git-send-email-remi@remlab.net>
References: <1262606569-3021-1-git-send-email-remi@remlab.net>
 <1262606569-3021-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:50113 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536Ab0ADMJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 07:09:26 -0500
In-Reply-To: <1262606569-3021-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/datagram.c |    6 ++++--
 net/phonet/pep.c      |   10 +++++++++-
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 67f072e..387197b 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -75,7 +75,8 @@ static int pn_sendmsg(struct kiocb *iocb, struct sock=
 *sk,
 	struct sk_buff *skb;
 	int err;
=20
-	if (msg->msg_flags & MSG_OOB)
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_NOSIGNAL|
+				MSG_CMSG_COMPAT))
 		return -EOPNOTSUPP;
=20
 	if (msg->msg_name =3D=3D NULL)
@@ -119,7 +120,8 @@ static int pn_recvmsg(struct kiocb *iocb, struct so=
ck *sk,
 	int rval =3D -EOPNOTSUPP;
 	int copylen;
=20
-	if (flags & MSG_OOB)
+	if (flags & ~(MSG_PEEK|MSG_TRUNC|MSG_DONTWAIT|MSG_NOSIGNAL|
+			MSG_CMSG_COMPAT))
 		goto out_nofree;
=20
 	if (addr_len)
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 72db27e..360cf37 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -860,7 +860,9 @@ static int pep_sendmsg(struct kiocb *iocb, struct s=
ock *sk,
 	int flags =3D msg->msg_flags;
 	int err, done;
=20
-	if (msg->msg_flags & MSG_OOB || !(msg->msg_flags & MSG_EOR))
+	if ((msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_NOSIGNAL|
+				MSG_CMSG_COMPAT)) ||
+			!(msg->msg_flags & MSG_EOR))
 		return -EOPNOTSUPP;
=20
 	skb =3D sock_alloc_send_skb(sk, MAX_PNPIPE_HEADER + len,
@@ -981,6 +983,10 @@ static int pep_recvmsg(struct kiocb *iocb, struct =
sock *sk,
 	struct sk_buff *skb;
 	int err;
=20
+	if (flags & ~(MSG_OOB|MSG_PEEK|MSG_TRUNC|MSG_DONTWAIT|MSG_WAITALL|
+			MSG_NOSIGNAL|MSG_CMSG_COMPAT))
+		return -EOPNOTSUPP;
+
 	if (unlikely(1 << sk->sk_state & (TCPF_LISTEN | TCPF_CLOSE)))
 		return -ENOTCONN;
=20
@@ -988,6 +994,8 @@ static int pep_recvmsg(struct kiocb *iocb, struct s=
ock *sk,
 		/* Dequeue and acknowledge control request */
 		struct pep_sock *pn =3D pep_sk(sk);
=20
+		if (flags & MSG_PEEK)
+			return -EOPNOTSUPP;
 		skb =3D skb_dequeue(&pn->ctrlreq_queue);
 		if (skb) {
 			pep_ctrlreq_error(sk, skb, PN_PIPE_NO_ERROR,
--=20
1.6.3.3

