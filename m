From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/8] [TCP]: Uninline tcp_set_state
Date: Sat, 12 Jan 2008 11:40:10 +0200
Message-ID: <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54395 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760270AbYALJkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:19 -0500
In-Reply-To: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/tcp.c:
  tcp_close_state | -226
  tcp_done        | -145
  tcp_close       | -564
  tcp_disconnect  | -141
 4 functions changed, 1076 bytes removed, diff: -1076

net/ipv4/tcp_input.c:
  tcp_fin               |  -86
  tcp_rcv_state_process | -164
 2 functions changed, 250 bytes removed, diff: -250

net/ipv4/tcp_ipv4.c:
  tcp_v4_connect | -209
 1 function changed, 209 bytes removed, diff: -209

net/ipv4/arp.c:
  arp_ignore |   +5
 1 function changed, 5 bytes added, diff: +5

net/ipv6/tcp_ipv6.c:
  tcp_v6_connect | -158
 1 function changed, 158 bytes removed, diff: -158

net/sunrpc/xprtsock.c:
  xs_sendpages |   -2
 1 function changed, 2 bytes removed, diff: -2

net/dccp/ccids/ccid3.c:
  ccid3_update_send_interval |   +7
 1 function changed, 7 bytes added, diff: +7

net/ipv4/tcp.c:
  tcp_set_state | +238
 1 function changed, 238 bytes added, diff: +238

built-in.o:
 12 functions changed, 250 bytes added, 1695 bytes removed, diff: -1445

I've no explanation why some unrelated changes seem to occur
consistently as well (arp_ignore, ccid3_update_send_interval;
I checked the arp_ignore asm and it seems to be due to some
reordered of operation order causing some extra opcodes to be
generated). Still, the benefits are pretty obvious from the
codiff's results.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Andi Kleen <andi@firstfloor.org>
---
 include/net/tcp.h |   35 +----------------------------------
 net/ipv4/tcp.c    |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 48081ad..306580c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -926,40 +926,7 @@ static const char *statename[]=3D{
 	"Close Wait","Last ACK","Listen","Closing"
 };
 #endif
-
-static inline void tcp_set_state(struct sock *sk, int state)
-{
-	int oldstate =3D sk->sk_state;
-
-	switch (state) {
-	case TCP_ESTABLISHED:
-		if (oldstate !=3D TCP_ESTABLISHED)
-			TCP_INC_STATS(TCP_MIB_CURRESTAB);
-		break;
-
-	case TCP_CLOSE:
-		if (oldstate =3D=3D TCP_CLOSE_WAIT || oldstate =3D=3D TCP_ESTABLISHE=
D)
-			TCP_INC_STATS(TCP_MIB_ESTABRESETS);
-
-		sk->sk_prot->unhash(sk);
-		if (inet_csk(sk)->icsk_bind_hash &&
-		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
-			inet_put_port(&tcp_hashinfo, sk);
-		/* fall through */
-	default:
-		if (oldstate=3D=3DTCP_ESTABLISHED)
-			TCP_DEC_STATS(TCP_MIB_CURRESTAB);
-	}
-
-	/* Change state AFTER socket is unhashed to avoid closed
-	 * socket sitting in hash tables.
-	 */
-	sk->sk_state =3D state;
-
-#ifdef STATE_TRACE
-	SOCK_DEBUG(sk, "TCP sk=3D%p, State %s -> %s\n",sk, statename[oldstate=
],statename[state]);
-#endif=09
-}
+extern void tcp_set_state(struct sock *sk, int state);
=20
 extern void tcp_done(struct sock *sk);
=20
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 34085e3..7d7b958 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1652,6 +1652,41 @@ recv_urg:
 	goto out;
 }
=20
+void tcp_set_state(struct sock *sk, int state)
+{
+	int oldstate =3D sk->sk_state;
+
+	switch (state) {
+	case TCP_ESTABLISHED:
+		if (oldstate !=3D TCP_ESTABLISHED)
+			TCP_INC_STATS(TCP_MIB_CURRESTAB);
+		break;
+
+	case TCP_CLOSE:
+		if (oldstate =3D=3D TCP_CLOSE_WAIT || oldstate =3D=3D TCP_ESTABLISHE=
D)
+			TCP_INC_STATS(TCP_MIB_ESTABRESETS);
+
+		sk->sk_prot->unhash(sk);
+		if (inet_csk(sk)->icsk_bind_hash &&
+		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
+			inet_put_port(&tcp_hashinfo, sk);
+		/* fall through */
+	default:
+		if (oldstate=3D=3DTCP_ESTABLISHED)
+			TCP_DEC_STATS(TCP_MIB_CURRESTAB);
+	}
+
+	/* Change state AFTER socket is unhashed to avoid closed
+	 * socket sitting in hash tables.
+	 */
+	sk->sk_state =3D state;
+
+#ifdef STATE_TRACE
+	SOCK_DEBUG(sk, "TCP sk=3D%p, State %s -> %s\n",sk, statename[oldstate=
],statename[state]);
+#endif=09
+}
+EXPORT_SYMBOL_GPL(tcp_set_state);
+
 /*
  *	State processing on a close. This implements the state shift for
  *	sending our FIN frame. Note that we only send a FIN for some
--=20
1.5.0.6

