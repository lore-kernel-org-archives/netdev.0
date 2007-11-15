From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 08/10] [TCP]: Earlier SACK block verification & simplify access to them
Date: Thu, 15 Nov 2007 15:37:32 +0200
Message-ID: <1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58227 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757458AbXKONhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:38 -0500
In-Reply-To: <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h  |    2 +-
 net/ipv4/tcp_input.c |   85 ++++++++++++++++++++++++++++++------------=
--------
 2 files changed, 52 insertions(+), 35 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 34acee6..794497c 100644
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
index b301abb..69f2f79 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1340,9 +1340,11 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
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
 	int reord =3D tp->packets_out;
 	int flag =3D 0;
 	int found_dup_sack =3D 0;
@@ -1357,7 +1359,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		tp->highest_sack =3D tcp_write_queue_head(sk);
 	}
=20
-	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp,
+	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp_wire,
 					 num_sacks, prior_snd_una);
 	if (found_dup_sack)
 		flag |=3D FLAG_DSACKING_ACK;
@@ -1372,14 +1374,49 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	if (!tp->packets_out)
 		goto out;
=20
+	used_sacks =3D 0;
+	first_sack_index =3D 0;
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
+			if (i =3D=3D 0)
+				first_sack_index =3D -1;
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
@@ -1398,19 +1435,17 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 		tp->recv_sack_cache[i].end_seq =3D 0;
 	}
=20
-	first_sack_index =3D 0;
 	if (force_one_sack)
-		num_sacks =3D 1;
+		used_sacks =3D 1;
 	else {
 		int j;
 		tp->fastpath_skb_hint =3D NULL;
=20
 		/* order SACK blocks to allow in order walk of the retrans queue */
-		for (i =3D num_sacks-1; i > 0; i--) {
+		for (i =3D used_sacks - 1; i > 0; i--) {
 			for (j =3D 0; j < i; j++){
-				if (after(ntohl(sp[j].start_seq),
-					  ntohl(sp[j+1].start_seq))){
-					struct tcp_sack_block_wire tmp;
+				if (after(sp[j].start_seq, sp[j+1].start_seq)) {
+					struct tcp_sack_block tmp;
=20
 					tmp =3D sp[j];
 					sp[j] =3D sp[j+1];
@@ -1433,32 +1468,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 		cached_fack_count =3D 0;
 	}
=20
-	for (i =3D 0; i < num_sacks; i++) {
+	for (i =3D 0; i < used_sacks; i++) {
 		struct sk_buff *skb;
-		__u32 start_seq =3D ntohl(sp->start_seq);
-		__u32 end_seq =3D ntohl(sp->end_seq);
+		u32 start_seq =3D sp[i].start_seq;
+		u32 end_seq =3D sp[i].end_seq;
 		int fack_count;
 		int dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index));
 		int next_dup =3D (found_dup_sack && (i+1 =3D=3D first_sack_index));
=20
-		sp++;
-
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
@@ -1489,8 +1506,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 			/* Due to sorting DSACK may reside within this SACK block! */
 			if (next_dup) {
-				u32 dup_start =3D ntohl(sp->start_seq);
-				u32 dup_end =3D ntohl(sp->end_seq);
+				u32 dup_start =3D sp[i+1].start_seq;
+				u32 dup_end =3D sp[i+1].end_seq;
=20
 				if (before(TCP_SKB_CB(skb)->seq, dup_end)) {
 					in_sack =3D tcp_match_skb_to_sack(sk, skb, dup_start, dup_end);
--=20
1.5.0.6

