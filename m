From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 09/10] tcp: more accurate fallback counters (DEBUGONLY)
Date: Mon, 24 Nov 2008 16:22:06 +0200
Message-ID: <1227536527-29713-10-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35317 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbYKXOWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:13 -0500
In-Reply-To: <1227536527-29713-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not for inclusion! For those who are interested enough on internals
while maintaining high-speed.
---
 include/linux/snmp.h |   13 +++++++++++++
 net/ipv4/proc.c      |   13 +++++++++++++
 net/ipv4/tcp_input.c |   47 ++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 62 insertions(+), 11 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index aee3f1e..501186a 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -219,6 +219,19 @@ enum
 	LINUX_MIB_SACKSHIFTED,
 	LINUX_MIB_SACKMERGED,
 	LINUX_MIB_SACKSHIFTFALLBACK,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKGSO,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKSKBBITS,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKSKBDATA,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKBELOW,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKFIRST,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKPREVBITS,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKMSS,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKNOHEAD,
+	LINUX_MIB_SACKCOLLAPSEFALLBACKSHIFT,
+	LINUX_MIB_SACKCOLLAPSENOOPSEQ,
+	LINUX_MIB_SACKCOLLAPSENOOPSMALLPCOUNT,
+	LINUX_MIB_SACKCOLLAPSENOOPSMALLLEN,
+	LINUX_MIB_SACKCOLLAPSEHOLE,
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 731789b..1d37fcd 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -237,6 +237,19 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPSackShifted", LINUX_MIB_SACKSHIFTED),
 	SNMP_MIB_ITEM("TCPSackMerged", LINUX_MIB_SACKMERGED),
 	SNMP_MIB_ITEM("TCPSackShiftFallback", LINUX_MIB_SACKSHIFTFALLBACK),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKGSO", LINUX_MIB_SACKCOLLAPSEFALLBACKGSO),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKSKBBITS", LINUX_MIB_SACKCOLLAPSEFALLBACKSKBBITS),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKSKBDATA", LINUX_MIB_SACKCOLLAPSEFALLBACKSKBDATA),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKBELOW", LINUX_MIB_SACKCOLLAPSEFALLBACKBELOW),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKFIRST", LINUX_MIB_SACKCOLLAPSEFALLBACKFIRST),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKPREVBITS", LINUX_MIB_SACKCOLLAPSEFALLBACKPREVBITS),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKMSS", LINUX_MIB_SACKCOLLAPSEFALLBACKMSS),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKNOHEAD", LINUX_MIB_SACKCOLLAPSEFALLBACKNOHEAD),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEFALLBACKSHIFT", LINUX_MIB_SACKCOLLAPSEFALLBACKSHIFT),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSENOOPSEQ", LINUX_MIB_SACKCOLLAPSENOOPSEQ),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSENOOPSMALLPCOUNT", LINUX_MIB_SACKCOLLAPSENOOPSMALLPCOUNT),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSENOOPSMALLLEN", LINUX_MIB_SACKCOLLAPSENOOPSMALLLEN),
+	SNMP_MIB_ITEM("TCPSACKCOLLAPSEHOLE", LINUX_MIB_SACKCOLLAPSEHOLE),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d8235cf..ffa37f9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1475,26 +1475,38 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 	int len;
 	int in_sack;
 
-	if (!sk_can_gso(sk))
+	if (!sk_can_gso(sk)) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKGSO);
 		goto fallback;
+	}
 
 	/* Normally R but no L won't result in plain S */
 	if (!dup_sack &&
-	    (TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) == TCPCB_SACKED_RETRANS)
+	    (TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) == TCPCB_SACKED_RETRANS) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKSKBBITS);
 		goto fallback;
-	if (!skb_can_shift(skb))
+	}
+	if (!skb_can_shift(skb)) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKSKBDATA);
 		goto fallback;
+	}
 	/* This frame is about to be dropped (was ACKed). */
-	if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
+	if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKBELOW);
 		goto fallback;
+	}
 
 	/* Can only happen with delayed DSACK + discard craziness */
-	if (unlikely(skb == tcp_write_queue_head(sk)))
+	if (unlikely(skb == tcp_write_queue_head(sk))) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKFIRST);
 		goto fallback;
+	}
 	prev = tcp_write_queue_prev(sk, skb);
 
-	if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED)
+	if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKPREVBITS);
 		goto fallback;
+	}
 
 	in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
@@ -1507,17 +1519,23 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 		/* TODO: Fix DSACKs to not fragment already SACKed and we can
 		 * drop this restriction as unnecessary
 		 */
-		if (mss != tcp_shift_mss(prev))
+		if (mss != tcp_shift_mss(prev)) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKMSS);
 			goto fallback;
+		}
 	} else {
-		if (!after(TCP_SKB_CB(skb)->end_seq, start_seq))
+		if (!after(TCP_SKB_CB(skb)->end_seq, start_seq)) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSENOOPSEQ);
 			goto noop;
+		}
 		/* CHECKME: This is non-MSS split case only?, this will
 		 * cause skipped skbs due to advancing loop btw, original
 		 * has that feature too
 		 */
-		if (tcp_skb_pcount(skb) <= 1)
+		if (tcp_skb_pcount(skb) <= 1) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSENOOPSMALLPCOUNT);
 			goto noop;
+		}
 
 		in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq);
 		if (!in_sack) {
@@ -1532,6 +1550,7 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 			 * it would make skb timestamp tracking considerably
 			 * harder problem.
 			 */
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKNOHEAD);
 			goto fallback;
 		}
 
@@ -1548,12 +1567,15 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 		/* TODO: Fix DSACKs to not fragment already SACKed and we can
 		 * drop this restriction as unnecessary
 		 */
-		if (mss != tcp_shift_mss(prev))
+		if (mss != tcp_shift_mss(prev)) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKMSS);
 			goto fallback;
+		}
 
 		if (len == mss) {
 			pcount = 1;
 		} else if (len < mss) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSENOOPSMALLLEN);
 			goto noop;
 		} else {
 			pcount = len / mss;
@@ -1561,8 +1583,10 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
-	if (!skb_shift(prev, skb, len))
+	if (!skb_shift(prev, skb, len)) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEFALLBACKSHIFT);
 		goto fallback;
+	}
 	if (!tcp_shifted_skb(sk, prev, skb, pcount, len, *fack_count, reord,
 			     flag, mss))
 		goto out;
@@ -1583,6 +1607,7 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 
 	len = skb->len;
 	if (skb_shift(prev, skb, len)) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKCOLLAPSEHOLE);
 		pcount += tcp_skb_pcount(skb);
 		tcp_shifted_skb(sk, prev, skb, tcp_skb_pcount(skb), len,
 				*fack_count, reord, flag, mss);
-- 
1.5.2.2

