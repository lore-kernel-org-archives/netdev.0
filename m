From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 3/3] tcp: Add tcp_parse_aligned_timestamp
Date: Fri, 22 Aug 2008 23:38:29 +0300
Message-ID: <1219437509-10048-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1219437509-10048-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1219437509-10048-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44291 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbYHVUib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 16:38:31 -0400
In-Reply-To: <1219437509-10048-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some duplicated code lying around. Located with my suffix tree
tool.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   37 ++++++++++++++++++-------------------
 1 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7cd1ad0..5e70b2c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3447,6 +3447,22 @@ void tcp_parse_options(struct sk_buff *skb, stru=
ct tcp_options_received *opt_rx,
 	}
 }
=20
+static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcp=
hdr *th)
+{
+	__be32 *ptr =3D (__be32 *)(th + 1);
+
+	if (*ptr =3D=3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
+			  | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)) {
+		tp->rx_opt.saw_tstamp =3D 1;
+		++ptr;
+		tp->rx_opt.rcv_tsval =3D ntohl(*ptr);
+		++ptr;
+		tp->rx_opt.rcv_tsecr =3D ntohl(*ptr);
+		return 1;
+	}
+	return 0;
+}
+
 /* Fast parse options. This hopes to only see timestamps.
  * If it is wrong it falls back on tcp_parse_options().
  */
@@ -3458,16 +3474,8 @@ static int tcp_fast_parse_options(struct sk_buff=
 *skb, struct tcphdr *th,
 		return 0;
 	} else if (tp->rx_opt.tstamp_ok &&
 		   th->doff =3D=3D (sizeof(struct tcphdr)>>2)+(TCPOLEN_TSTAMP_ALIGNE=
D>>2)) {
-		__be32 *ptr =3D (__be32 *)(th + 1);
-		if (*ptr =3D=3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
-				  | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)) {
-			tp->rx_opt.saw_tstamp =3D 1;
-			++ptr;
-			tp->rx_opt.rcv_tsval =3D ntohl(*ptr);
-			++ptr;
-			tp->rx_opt.rcv_tsecr =3D ntohl(*ptr);
+		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
-		}
 	}
 	tcp_parse_options(skb, &tp->rx_opt, 1);
 	return 1;
@@ -4827,19 +4835,10 @@ int tcp_rcv_established(struct sock *sk, struct=
 sk_buff *skb,
=20
 		/* Check timestamp */
 		if (tcp_header_len =3D=3D sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALI=
GNED) {
-			__be32 *ptr =3D (__be32 *)(th + 1);
-
 			/* No? Slow path! */
-			if (*ptr !=3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
-					  | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP))
+			if (!tcp_parse_aligned_timestamp(tp, th))
 				goto slow_path;
=20
-			tp->rx_opt.saw_tstamp =3D 1;
-			++ptr;
-			tp->rx_opt.rcv_tsval =3D ntohl(*ptr);
-			++ptr;
-			tp->rx_opt.rcv_tsecr =3D ntohl(*ptr);
-
 			/* If PAWS failed, check it more carefully in slow path */
 			if ((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) < 0)
 				goto slow_path;
--=20
1.5.2.2

