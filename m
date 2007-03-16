From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 1/5] [TCP]: Add highest_sack seqno, points to globally highest SACK
Date: Fri, 16 Mar 2007 16:39:58 +0200
Message-ID: <11740560021077-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11740560023261-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36759 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965558AbXCPOkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 10:40:04 -0400
In-Reply-To: <11740560023261-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is guaranteed to be valid only when !tp->sacked_out. In most
cases this seqno is available in the last ACK but there is no
guarantee for that. The new fast recovery loss marking algorithm
needs this as entry point.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h  |    2 ++
 net/ipv4/tcp_input.c |    8 +++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 09f2d66..9e542d5 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -335,6 +335,8 @@ #endif
=20
 	struct tcp_sack_block_wire recv_sack_cache[4];
=20
+	u32	highest_sack;	/* Start seq of globally highest revd SACK (valid o=
nly in slowpath) */
+
 	/* from STCP, retrans queue hinting */
 	struct sk_buff* lost_skb_hint;
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9c3b4c7..dbc98ce 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -954,8 +954,10 @@ tcp_sacktag_write_queue(struct sock *sk,
 	int i;
 	int first_sack_index;
=20
-	if (!tp->sacked_out)
+	if (!tp->sacked_out) {
 		tp->fackets_out =3D 0;
+		tp->highest_sack =3D tp->snd_una;
+	}
 	prior_fackets =3D tp->fackets_out;
=20
 	/* Check for D-SACK. */
@@ -1189,6 +1191,10 @@ tcp_sacktag_write_queue(struct sock *sk,
=20
 				if (fack_count > tp->fackets_out)
 					tp->fackets_out =3D fack_count;
+
+				if (after(TCP_SKB_CB(skb)->seq,
+				    tp->highest_sack))
+					tp->highest_sack =3D TCP_SKB_CB(skb)->seq;
 			} else {
 				if (dup_sack && (sacked&TCPCB_RETRANS))
 					reord =3D min(fack_count, reord);
--=20
1.4.2

