From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/3 Ver2] tcp: Slightly optimize tcp_sendmsg
Date: Thu, 10 Dec 2009 22:46:59 +0530
Message-ID: <20091210171659.20777.67516.sendpatchset@localhost.localdomain>
References: <20091210171652.20777.79982.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:38134 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761232AbZLJRQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 12:16:55 -0500
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBAHDvrH024207
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 04:13:57 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBAHDF3p1585266
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 04:13:15 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBAHH1BD012572
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 04:17:01 +1100
In-Reply-To: <20091210171652.20777.79982.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krishna Kumar <krkumar2@in.ibm.com>

Slightly optimize tcp_sendmsg since NETIF_F_SG is used many
times iteratively in the loop. The only other modification is
to change:
			} else if (i =3D=3D MAX_SKB_FRAGS ||
				   (!i &&
				   !(sk->sk_route_caps & NETIF_F_SG))) {
	to:
			} else if (i =3D=3D MAX_SKB_FRAGS || !sg) {

The reason why this change is correct: this code (other than
the MAX_SKB_FRAGS case) executes only due to the else part
of: "if (skb_tailroom(skb) > 0) {" - i.e. there was no space
in the skb to put the data inline. Hence SG is false is a
sufficient condition, and there is no way a fragment can be
added to the skb.

Changelog:
	- Added the above explanation for the change

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Acked-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff -ruNp org/net/ipv4/tcp.c new/net/ipv4/tcp.c
--- org/net/ipv4/tcp.c	2009-12-10 21:22:41.000000000 +0530
+++ new/net/ipv4/tcp.c	2009-12-10 21:32:06.000000000 +0530
@@ -876,12 +876,12 @@ ssize_t tcp_sendpage(struct socket *sock
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
=20
-static inline int select_size(struct sock *sk)
+static inline int select_size(struct sock *sk, int sg)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	int tmp =3D tp->mss_cache;
=20
-	if (sk->sk_route_caps & NETIF_F_SG) {
+	if (sg) {
 		if (sk_can_gso(sk))
 			tmp =3D 0;
 		else {
@@ -905,7 +905,7 @@ int tcp_sendmsg(struct kiocb *iocb, stru
 	struct sk_buff *skb;
 	int iovlen, flags;
 	int mss_now, size_goal;
-	int err, copied;
+	int sg, err, copied;
 	long timeo;
=20
 	lock_sock(sk);
@@ -933,6 +933,8 @@ int tcp_sendmsg(struct kiocb *iocb, stru
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
=20
+	sg =3D sk->sk_route_caps & NETIF_F_SG;
+
 	while (--iovlen >=3D 0) {
 		int seglen =3D iov->iov_len;
 		unsigned char __user *from =3D iov->iov_base;
@@ -958,8 +960,9 @@ new_segment:
 				if (!sk_stream_memory_free(sk))
 					goto wait_for_sndbuf;
=20
-				skb =3D sk_stream_alloc_skb(sk, select_size(sk),
-						sk->sk_allocation);
+				skb =3D sk_stream_alloc_skb(sk,
+							  select_size(sk, sg),
+							  sk->sk_allocation);
 				if (!skb)
 					goto wait_for_memory;
=20
@@ -996,9 +999,7 @@ new_segment:
 					/* We can extend the last page
 					 * fragment. */
 					merge =3D 1;
-				} else if (i =3D=3D MAX_SKB_FRAGS ||
-					   (!i &&
-					   !(sk->sk_route_caps & NETIF_F_SG))) {
+				} else if (i =3D=3D MAX_SKB_FRAGS || !sg) {
 					/* Need to add new fragment and cannot
 					 * do this because interface is non-SG,
 					 * or because all the page slots are
