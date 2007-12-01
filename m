From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 19/21] [TCP]: Introduce tcp_real_queue_head(sk)
Date: Sun,  2 Dec 2007 00:48:14 +0200
Message-ID: <11965492972550-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi> <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971864-git-send-email-ilpo.jarvinen@helsinki.f
 i> <11965492972309-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971718-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33125 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbXLAWs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:26 -0500
In-Reply-To: <11965492971718-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

This is necessary when SACKed and non-SACKed spaces become
separate in the later patch.

However, callers should be converted to behave without this
later on.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h    |    8 ++++++++
 net/ipv4/tcp_input.c |    4 ++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 117fcc4..5bb2de6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1214,6 +1214,14 @@ static inline struct sk_buff *tcp_write_queue_he=
ad(struct sock *sk)
 	return skb;
 }
=20
+/* FIXME, this should eventually vanish because callers likely benefit
+ * from scanning the non-SACKed and SACKed spaces separately.
+ */
+static inline struct sk_buff *tcp_real_queue_head(struct sock *sk)
+{
+	return tcp_write_queue_head(sk);
+}
+
 static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
 {
 	struct sk_buff *skb =3D sk->sk_write_queue.prev;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7d5d316..1187dfa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1928,7 +1928,7 @@ static int tcp_check_sack_reneging(struct sock *s=
k)
 	 * receiver _host_ is heavily congested (or buggy).
 	 * Do processing similar to RTO timeout.
 	 */
-	if ((skb =3D tcp_write_queue_head(sk)) !=3D NULL &&
+	if ((skb =3D tcp_real_queue_head(sk)) !=3D NULL &&
 	    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 		struct inet_connection_sock *icsk =3D inet_csk(sk);
 		NET_INC_STATS_BH(LINUX_MIB_TCPSACKRENEGING);
@@ -2773,7 +2773,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p,
 	s32 seq_rtt =3D -1;
 	ktime_t last_ackt =3D net_invalid_timestamp();
=20
-	while ((skb =3D tcp_write_queue_head(sk)) && skb !=3D tcp_send_head(s=
k)) {
+	while ((skb =3D tcp_real_queue_head(sk)) && skb !=3D tcp_send_head(sk=
)) {
 		struct tcp_skb_cb *scb =3D TCP_SKB_CB(skb);
 		u32 end_seq;
 		u32 acked_pcount;
--=20
1.5.0.6

