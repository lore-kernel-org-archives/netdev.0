From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/6] [TCP]: Earlier SACK block verification & simplify access to them
Date: Thu, 11 Oct 2007 15:21:56 +0300
Message-ID: <11921053184007-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11921053182989-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053181239-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053181212-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053182585-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>,
	--cc@cs.helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60931 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646AbXJKMWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 08:22:02 -0400
In-Reply-To: <11921053182585-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h  |    2 +-
 net/ipv4/tcp_input.c |   75 ++++++++++++++++++++++++++++++------------=
-------
 2 files changed, 47 insertions(+), 30 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 0ec6bb6..3e412f2 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -330,7 +330,7 @@ struct tcp_sock {
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
 	struct tcp_sack_block selective_acks[4]; /* The SACKS themselves*/
=20
-	struct tcp_sack_block_wire recv_sack_cache[4];
+	struct tcp_sack_block recv_sack_cache[4];
=20
 	struct sk_buff *highest_sack;   /* highest skb with SACK received
 					 * (validity guaranteed only if
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 39d6a6a..c260642 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1350,9 +1350,11 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	unsigned char *ptr =3D (skb_transport_header(ack_skb) +
 			      TCP_SKB_CB(ack_skb)->sacked);
-	struct tcp_sack_block_wire *sp =3D (struct tcp_sack_block_wire *)(ptr=
+2);
+	struct tcp_sack_block_wire *sp_wire =3D (struct tcp_sack_block_wire *=
)(ptr+2);
+	struct tcp_sack_block sp[4];
 	struct sk_buff *cached_skb;
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
+	int used_sacks;
 	struct tcp_sacktag_state state;
 	int found_dup_sack;
 	int cached_fack_count;
@@ -1367,7 +1369,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		tp->highest_sack =3D tcp_write_queue_head(sk);
 	}
=20
-	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_=
snd_una);
+	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp_wire, num_sacks, p=
rior_snd_una);
 	if (found_dup_sack)
 		state.flag |=3D FLAG_DSACKING_ACK;
=20
@@ -1378,14 +1380,46 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_wind=
ow))
 		return 0;
=20
+	used_sacks =3D 0;
+	for (i =3D 0; i < num_sacks; i++) {
+		int dup_sack =3D !i && found_dup_sack;
+
+		sp[used_sacks].start_seq =3D ntohl(get_unaligned(&sp_wire[i].start_s=
eq));
+		sp[used_sacks].end_seq =3D ntohl(get_unaligned(&sp_wire[i].end_seq))=
;
+
+		if (!tcp_is_sackblock_valid(tp, dup_sack,
+					    sp[used_sacks].start_seq,
+					    sp[used_sacks].end_seq)) {
+			if (dup_sack) {
+				if (!tp->undo_marker)
+					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
+				else
+					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
+			} else {
+				/* Don't count olds caused by ACK reordering */
+				if ((TCP_SKB_CB(ack_skb)->ack_seq !=3D tp->snd_una) &&
+				    !after(sp[used_sacks].end_seq, tp->snd_una))
+					continue;
+				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
+			}
+			continue;
+		}
+
+		/* Ignore very old stuff early */
+		if (!after(sp[used_sacks].end_seq, prior_snd_una))
+			continue;
+
+		used_sacks++;
+	}
+
 	/* SACK fastpath:
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
 	 * and use retrans queue hinting otherwise slowpath */
 	force_one_sack =3D 1;
-	for (i =3D 0; i < num_sacks; i++) {
-		__be32 start_seq =3D sp[i].start_seq;
-		__be32 end_seq =3D sp[i].end_seq;
+	for (i =3D 0; i < used_sacks; i++) {
+		u32 start_seq =3D sp[i].start_seq;
+		u32 end_seq =3D sp[i].end_seq;
=20
 		if (i =3D=3D 0) {
 			if (tp->recv_sack_cache[i].start_seq !=3D start_seq)
@@ -1406,17 +1440,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
=20
 	state.first_sack_index =3D 0;
 	if (force_one_sack)
-		num_sacks =3D 1;
+		used_sacks =3D 1;
 	else {
 		int j;
 		tp->fastpath_skb_hint =3D NULL;
=20
 		/* order SACK blocks to allow in order walk of the retrans queue */
-		for (i =3D num_sacks-1; i > 0; i--) {
+		for (i =3D used_sacks-1; i > 0; i--) {
 			for (j =3D 0; j < i; j++){
-				if (after(ntohl(sp[j].start_seq),
-					  ntohl(sp[j+1].start_seq))){
-					struct tcp_sack_block_wire tmp;
+				if (after(sp[j].start_seq, sp[j+1].start_seq)) {
+					struct tcp_sack_block tmp;
=20
 					tmp =3D sp[j];
 					sp[j] =3D sp[j+1];
@@ -1443,29 +1476,13 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	state.prior_fackets =3D tp->fackets_out;
 	state.highest_sack_end_seq =3D 0;
=20
-	for (i=3D0; i<num_sacks; i++, sp++) {
+	for (i=3D0; i< used_sacks; i++) {
 		struct sk_buff *skb;
-		__u32 start_seq =3D ntohl(sp->start_seq);
-		__u32 end_seq =3D ntohl(sp->end_seq);
+		u32 start_seq =3D sp[i].start_seq;
+		u32 end_seq =3D sp[i].end_seq;
 		int fack_count;
 		int dup_sack =3D (found_dup_sack && (i =3D=3D state.first_sack_index=
));
=20
-		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq)) {
-			if (dup_sack) {
-				if (!tp->undo_marker)
-					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
-				else
-					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
-			} else {
-				/* Don't count olds caused by ACK reordering */
-				if ((TCP_SKB_CB(ack_skb)->ack_seq !=3D tp->snd_una) &&
-				    !after(end_seq, tp->snd_una))
-					continue;
-				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
-			}
-			continue;
-		}
-
 		skb =3D cached_skb;
 		fack_count =3D cached_fack_count;
=20
--=20
1.5.0.6

