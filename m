From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 10/10] [TCP]: Track sacktag (DEVEL PATCH)
Date: Thu, 15 Nov 2007 15:37:34 +0200
Message-ID: <1195133854814-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58594 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757510AbXKONhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:40 -0500
In-Reply-To: <11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is not intented to go to mainline, provided just for those
who are interested enough about the algorithm internals during
a test.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/snmp.h |   19 +++++++++++++++++++
 net/ipv4/proc.c      |   19 +++++++++++++++++++
 net/ipv4/tcp_input.c |   50 ++++++++++++++++++++++++++++++++++++++++++=
++++++--
 3 files changed, 86 insertions(+), 2 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 89f0c2b..fbcd62d 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -214,6 +214,25 @@ enum
 	LINUX_MIB_TCPDSACKIGNOREDOLD,		/* TCPSACKIgnoredOld */
 	LINUX_MIB_TCPDSACKIGNOREDNOUNDO,	/* TCPSACKIgnoredNoUndo */
 	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
+	LINUX_MIB_TCP_SACK0,
+	LINUX_MIB_TCP_SACK1,
+	LINUX_MIB_TCP_SACK2,
+	LINUX_MIB_TCP_SACK3,
+	LINUX_MIB_TCP_SACK4,
+	LINUX_MIB_TCP_WALKEDSKBS,
+	LINUX_MIB_TCP_WALKEDDSACKS,
+	LINUX_MIB_TCP_SKIPPEDSKBS,
+	LINUX_MIB_TCP_NOCACHE,
+	LINUX_MIB_TCP_HEADWALK,
+	LINUX_MIB_TCP_FULLSKIP,
+	LINUX_MIB_TCP_TAILSKIP,
+	LINUX_MIB_TCP_HEADSKIP_TOHIGH,
+	LINUX_MIB_TCP_TAIL_TOHIGH,
+	LINUX_MIB_TCP_HEADSKIP,
+	LINUX_MIB_TCP_NEWSKIP,
+	LINUX_MIB_TCP_FULLWALK,
+	LINUX_MIB_TCP_TAILWALK,
+	LINUX_MIB_TCP_CACHEREMAINING,
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ce34b28..a5e842d 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -227,6 +227,25 @@ static const struct snmp_mib snmp4_net_list[] =3D =
{
 	SNMP_MIB_ITEM("TCPDSACKIgnoredOld", LINUX_MIB_TCPDSACKIGNOREDOLD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredNoUndo", LINUX_MIB_TCPDSACKIGNOREDNOUND=
O),
 	SNMP_MIB_ITEM("TCPSpuriousRTOs", LINUX_MIB_TCPSPURIOUSRTOS),
+	SNMP_MIB_ITEM("TCP_SACK0", LINUX_MIB_TCP_SACK0),
+	SNMP_MIB_ITEM("TCP_SACK1", LINUX_MIB_TCP_SACK1),
+	SNMP_MIB_ITEM("TCP_SACK2", LINUX_MIB_TCP_SACK2),
+	SNMP_MIB_ITEM("TCP_SACK3", LINUX_MIB_TCP_SACK3),
+	SNMP_MIB_ITEM("TCP_SACK4", LINUX_MIB_TCP_SACK4),
+	SNMP_MIB_ITEM("TCP_WALKEDSKBS", LINUX_MIB_TCP_WALKEDSKBS),
+	SNMP_MIB_ITEM("TCP_WALKEDDSACKS", LINUX_MIB_TCP_WALKEDDSACKS),
+	SNMP_MIB_ITEM("TCP_SKIPPEDSKBS", LINUX_MIB_TCP_SKIPPEDSKBS),
+	SNMP_MIB_ITEM("TCP_NOCACHE", LINUX_MIB_TCP_NOCACHE),
+	SNMP_MIB_ITEM("TCP_FULLWALK", LINUX_MIB_TCP_FULLWALK),
+	SNMP_MIB_ITEM("TCP_HEADWALK", LINUX_MIB_TCP_HEADWALK),
+	SNMP_MIB_ITEM("TCP_TAILWALK", LINUX_MIB_TCP_TAILWALK),
+	SNMP_MIB_ITEM("TCP_FULLSKIP", LINUX_MIB_TCP_FULLSKIP),
+	SNMP_MIB_ITEM("TCP_TAILSKIP", LINUX_MIB_TCP_TAILSKIP),
+	SNMP_MIB_ITEM("TCP_HEADSKIP", LINUX_MIB_TCP_HEADSKIP),
+	SNMP_MIB_ITEM("TCP_HEADSKIP_TOHIGH", LINUX_MIB_TCP_HEADSKIP_TOHIGH),
+	SNMP_MIB_ITEM("TCP_TAIL_TOHIGH", LINUX_MIB_TCP_TAIL_TOHIGH),
+	SNMP_MIB_ITEM("TCP_NEWSKIP", LINUX_MIB_TCP_NEWSKIP),
+	SNMP_MIB_ITEM("TCP_CACHEREMAINING", LINUX_MIB_TCP_CACHEREMAINING),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5833b01..87ab327 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1370,6 +1370,10 @@ static struct sk_buff *tcp_sacktag_walk(struct s=
k_buff *skb, struct sock *sk,
 			*flag |=3D tcp_sacktag_one(skb, tp, reord, dup_sack, *fack_count);
=20
 		*fack_count +=3D tcp_skb_pcount(skb);
+
+		NET_INC_STATS_BH(LINUX_MIB_TCP_WALKEDSKBS);
+		if (dup_sack)
+			NET_INC_STATS_BH(LINUX_MIB_TCP_WALKEDDSACKS);
 	}
 	return skb;
 }
@@ -1386,6 +1390,8 @@ static struct sk_buff *tcp_sacktag_skip(struct sk=
_buff *skb, struct sock *sk,
=20
 		if (before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
 			break;
+
+		NET_INC_STATS_BH(LINUX_MIB_TCP_SKIPPEDSKBS);
 	}
 	return skb;
 }
@@ -1434,6 +1440,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	int fack_count;
 	int i, j;
 	int first_sack_index;
+	int fullwalk =3D 1;
=20
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
@@ -1523,6 +1530,17 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 			cache++;
 	}
=20
+	switch (used_sacks) {
+		case 0: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK0); break;
+		case 1: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK1); break;
+		case 2: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK2); break;
+		case 3: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK3); break;
+		case 4: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK4); break;
+	}
+
+	if (!tcp_sack_cache_ok(tp, cache))
+		NET_INC_STATS_BH(LINUX_MIB_TCP_NOCACHE);
+
 	while (i < used_sacks) {
 		u32 start_seq =3D sp[i].start_seq;
 		u32 end_seq =3D sp[i].end_seq;
@@ -1544,6 +1562,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		/* Can skip some work by looking recv_sack_cache? */
 		if (tcp_sack_cache_ok(tp, cache) && !dup_sack &&
 		    after(end_seq, cache->start_seq)) {
+			int headskip =3D 0;
+
+			fullwalk =3D 0;
=20
 			/* Head todo? */
 			if (before(start_seq, cache->start_seq)) {
@@ -1551,12 +1572,18 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 				skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq,
 						       cache->start_seq, dup_sack,
 						       &fack_count, &reord, &flag);
-			}
+				NET_INC_STATS_BH(LINUX_MIB_TCP_HEADWALK);
+			} else
+				headskip =3D 1;
=20
 			/* Rest of the block already fully processed? */
 			if (!after(end_seq, cache->end_seq)) {
 				skb =3D tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq=
,
 							       &fack_count, &reord, &flag);
+				if (headskip)
+					NET_INC_STATS_BH(LINUX_MIB_TCP_FULLSKIP);
+				else
+					NET_INC_STATS_BH(LINUX_MIB_TCP_TAILSKIP);
 				goto advance_sp;
 			}
=20
@@ -1571,24 +1598,37 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 				skb =3D tcp_write_queue_next(sk, tp->highest_sack);
 				fack_count =3D tp->fackets_out;
 				cache++;
+
+				if (headskip)
+					NET_INC_STATS_BH(LINUX_MIB_TCP_HEADSKIP_TOHIGH);
+				else
+					NET_INC_STATS_BH(LINUX_MIB_TCP_TAIL_TOHIGH);
 				goto walk;
 			}
=20
 			skb =3D tcp_sacktag_skip(skb, sk, cache->end_seq);
 			/* Check overlap against next cached too (past this one already) */
 			cache++;
+
+			if (headskip)
+				NET_INC_STATS_BH(LINUX_MIB_TCP_HEADSKIP);
 			continue;
 		}
=20
 		if (!before(start_seq, tcp_highest_sack_seq(tp))) {
 			skb =3D tcp_write_queue_next(sk, tp->highest_sack);
 			fack_count =3D tp->fackets_out;
+			NET_INC_STATS_BH(LINUX_MIB_TCP_NEWSKIP);
 		}
 		skb =3D tcp_sacktag_skip(skb, sk, start_seq);
=20
 walk:
 		skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq, end_seq,
 				       dup_sack, &fack_count, &reord, &flag);
+		if (fullwalk)
+			NET_INC_STATS_BH(LINUX_MIB_TCP_FULLWALK);
+		else
+			NET_INC_STATS_BH(LINUX_MIB_TCP_TAILWALK);
=20
 advance_sp:
 		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
@@ -1598,15 +1638,21 @@ advance_sp:
 			flag &=3D ~FLAG_ONLY_ORIG_SACKED;
=20
 		i++;
+		fullwalk =3D 1;
 	}
=20
+	if (tcp_sack_cache_ok(tp, cache))
+		NET_INC_STATS_BH(LINUX_MIB_TCP_CACHEREMAINING);
+
 	/* Clear the head of the cache sack blocks so we can skip it next tim=
e */
 	for (i =3D 0; i < ARRAY_SIZE(tp->recv_sack_cache) - used_sacks; i++) =
{
 		tp->recv_sack_cache[i].start_seq =3D 0;
 		tp->recv_sack_cache[i].end_seq =3D 0;
 	}
-	for (j =3D 0; j < used_sacks; j++)
+	for (j =3D 0; j < used_sacks; j++) {
+		WARN_ON(i >=3D ARRAY_SIZE(tp->recv_sack_cache));
 		tp->recv_sack_cache[i++] =3D sp[j];
+	}
=20
 	flag |=3D tcp_mark_lost_retrans(sk);
=20
--=20
1.5.0.6

