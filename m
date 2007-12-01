From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 16/21] [TCP]: Move tcp_check_dsack
Date: Sun,  2 Dec 2007 00:48:11 +0200
Message-ID: <11965492971864-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi> <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47544 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbXLAWsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:25 -0500
In-Reply-To: <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   66 +++++++++++++++++++++++++-----------------=
--------
 1 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cc61916..c33efc9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1171,39 +1171,6 @@ static void tcp_mark_lost_retrans(struct sock *s=
k)
 		tp->lost_retrans_low =3D new_low_seq;
 }
=20
-static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
-			   struct tcp_sack_block_wire *sp, int num_sacks,
-			   u32 prior_snd_una)
-{
-	u32 start_seq_0 =3D ntohl(get_unaligned(&sp[0].start_seq));
-	u32 end_seq_0 =3D ntohl(get_unaligned(&sp[0].end_seq));
-	int dup_sack =3D 0;
-
-	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
-		dup_sack =3D 1;
-		tcp_dsack_seen(tp);
-		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
-	} else if (num_sacks > 1) {
-		u32 end_seq_1 =3D ntohl(get_unaligned(&sp[1].end_seq));
-		u32 start_seq_1 =3D ntohl(get_unaligned(&sp[1].start_seq));
-
-		if (!after(end_seq_0, end_seq_1) &&
-		    !before(start_seq_0, start_seq_1)) {
-			dup_sack =3D 1;
-			tcp_dsack_seen(tp);
-			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
-		}
-	}
-
-	/* D-SACK for already forgotten data... Do dumb counting. */
-	if (dup_sack &&
-	    !after(end_seq_0, prior_snd_una) &&
-	    after(end_seq_0, tp->undo_marker))
-		tp->undo_retrans--;
-
-	return dup_sack;
-}
-
 /* Check if skb is fully within the SACK block. In presence of GSO skb=
s,
  * the incoming SACK may not exactly match but we can find smaller MSS
  * aligned portion of it that matches. Therefore we might need to frag=
ment
@@ -1404,6 +1371,39 @@ static struct sk_buff *tcp_maybe_skipping_dsack(=
struct sk_buff *skb,
 	return skb;
 }
=20
+static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
+			   struct tcp_sack_block_wire *sp, int num_sacks,
+			   u32 prior_snd_una)
+{
+	u32 start_seq_0 =3D ntohl(get_unaligned(&sp[0].start_seq));
+	u32 end_seq_0 =3D ntohl(get_unaligned(&sp[0].end_seq));
+	int dup_sack =3D 0;
+
+	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
+		dup_sack =3D 1;
+		tcp_dsack_seen(tp);
+		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
+	} else if (num_sacks > 1) {
+		u32 end_seq_1 =3D ntohl(get_unaligned(&sp[1].end_seq));
+		u32 start_seq_1 =3D ntohl(get_unaligned(&sp[1].start_seq));
+
+		if (!after(end_seq_0, end_seq_1) &&
+		    !before(start_seq_0, start_seq_1)) {
+			dup_sack =3D 1;
+			tcp_dsack_seen(tp);
+			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
+		}
+	}
+
+	/* D-SACK for already forgotten data... Do dumb counting. */
+	if (dup_sack &&
+	    !after(end_seq_0, prior_snd_una) &&
+	    after(end_seq_0, tp->undo_marker))
+		tp->undo_retrans--;
+
+	return dup_sack;
+}
+
 static int tcp_sack_cache_ok(struct tcp_sock *tp, struct tcp_sack_bloc=
k *cache)
 {
 	return cache < tp->recv_sack_cache + ARRAY_SIZE(tp->recv_sack_cache);
--=20
1.5.0.6

