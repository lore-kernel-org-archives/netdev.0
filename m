From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Tue, 12 Jan 2010 05:05:22 -0500
Message-ID: <4B4C4962.8040207@gmail.com>
References: <4B49D001.4000302@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010708010901000107070101"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754018Ab0ALKF3@vger.kernel.org>
In-Reply-To: <4B49D001.4000302@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010708010901000107070101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Harmonize tcp_v4_rcv() and tcp_v6_rcv() -- better document tcp doff and
header length assumptions.

Reduces multiply/shifts, marginally improving speed.

Retains redundant tcp header length checks before checksumming.

Stand-alone patch, originally developed for TCPCT.

Requires:
   net: tcp_header_len_th and tcp_option_len_th

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp_ipv4.c |   36 +++++++++++++++++++-------------
  net/ipv6/tcp_ipv6.c |   56 ++++++++++++++++++++++++++++----------------------
  2 files changed, 52 insertions(+), 40 deletions(-)

--------------010708010901000107070101
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+3v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+3v3.patch"

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 65b8ebf..7ea2cff 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1559,6 +1559,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	/* Transformed? re-check too short header and options before checksum */
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;
 
@@ -1601,14 +1602,14 @@ csum_err:
 }
 
 /*
- *	From tcp_input.c
+ *	Called by ip_input.c: ip_local_deliver_finish()
  */
-
 int tcp_v4_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
 	struct tcphdr *th;
 	struct sock *sk;
+	int tcp_header_len;
 	int ret;
 	struct net *net = dev_net(skb->dev);
 
@@ -1618,20 +1619,23 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	/* Count it even if it's bad */
 	TCP_INC_STATS_BH(net, TCP_MIB_INSEGS);
 
+	/* Check too short header */
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
 
-	th = tcp_hdr(skb);
-
-	if (th->doff < sizeof(struct tcphdr) / 4)
+	/* Check bad doff, compare doff directly to constant value */
+	tcp_header_len = tcp_hdr(skb)->doff;
+	if (tcp_header_len < (sizeof(struct tcphdr) / 4))
 		goto bad_packet;
-	if (!pskb_may_pull(skb, th->doff * 4))
+
+	/* Check too short header and options */
+	tcp_header_len *= 4;
+	if (!pskb_may_pull(skb, tcp_header_len))
 		goto discard_it;
 
-	/* An explanation is required here, I think.
-	 * Packet length and doff are validated by header prediction,
-	 * provided case of th->doff==0 is eliminated.
-	 * So, we defer the checks. */
+	/* Packet length and doff are validated by header prediction,
+	 * provided case of th->doff == 0 is eliminated (above).
+	 */
 	if (!skb_csum_unnecessary(skb) && tcp_v4_checksum_init(skb))
 		goto bad_packet;
 
@@ -1639,7 +1643,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	iph = ip_hdr(skb);
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
-				    skb->len - th->doff * 4);
+				    skb->len - tcp_header_len);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when	 = 0;
 	TCP_SKB_CB(skb)->flags	 = iph->tos;
@@ -1682,14 +1686,14 @@ process:
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
-
 	return ret;
 
 no_tcp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 
-	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
+	/* Transformed? re-check too short header and options before checksum */
+	if (skb->len < tcp_header_len_th(th) || tcp_checksum_complete(skb)) {
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
@@ -1711,18 +1715,20 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
+	/* Transformed? re-check too short header and options before checksum */
+	if (skb->len < tcp_header_len_th(th) || tcp_checksum_complete(skb)) {
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
+
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo,
 							iph->daddr, th->dest,
 							inet_iif(skb));
-		if (sk2) {
+		if (sk2 != NULL) {
 			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
 			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index febfd59..268bc8a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1594,6 +1594,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	/* Transformed? re-check too short header and options before checksum */
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;
 
@@ -1664,38 +1665,47 @@ ipv6_pktoptions:
 	return 0;
 }
 
+/*
+ *	Called by ip6_input.c: ip6_input_finish()
+ */
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
 	struct tcphdr *th;
 	struct sock *sk;
+	int tcp_header_len;
 	int ret;
 	struct net *net = dev_net(skb->dev);
 
 	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
 
-	/*
-	 *	Count it even if it's bad.
-	 */
+	/* Count it even if it's bad */
 	TCP_INC_STATS_BH(net, TCP_MIB_INSEGS);
 
+	/* Check too short header */
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
 
-	th = tcp_hdr(skb);
-
-	if (th->doff < sizeof(struct tcphdr)/4)
+	/* Check bad doff, compare doff directly to constant value */
+	tcp_header_len = tcp_hdr(skb)->doff;
+	if (tcp_header_len < (sizeof(struct tcphdr) / 4))
 		goto bad_packet;
-	if (!pskb_may_pull(skb, th->doff*4))
+
+	/* Check too short header and options */
+	tcp_header_len *= 4;
+	if (!pskb_may_pull(skb, tcp_header_len))
 		goto discard_it;
 
+	/* Packet length and doff are validated by header prediction,
+	 * provided case of th->doff == 0 is eliminated (above).
+	 */
 	if (!skb_csum_unnecessary(skb) && tcp_v6_checksum_init(skb))
 		goto bad_packet;
 
 	th = tcp_hdr(skb);
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
-				    skb->len - th->doff*4);
+				    skb->len - tcp_header_len);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when = 0;
 	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(ipv6_hdr(skb));
@@ -1743,7 +1753,8 @@ no_tcp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 
-	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
+	/* Transformed? re-check too short header and options before checksum */
+	if (skb->len < tcp_header_len_th(th) || tcp_checksum_complete(skb)) {
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
@@ -1751,11 +1762,7 @@ bad_packet:
 	}
 
 discard_it:
-
-	/*
-	 *	Discard frame
-	 */
-
+	/* Discard frame. */
 	kfree_skb(skb);
 	return 0;
 
@@ -1769,24 +1776,23 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
+	/* Transformed? re-check too short header and options before checksum */
+	if (skb->len < tcp_header_len_th(th) || tcp_checksum_complete(skb)) {
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
 
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
-	case TCP_TW_SYN:
-	{
-		struct sock *sk2;
-
-		sk2 = inet6_lookup_listener(dev_net(skb->dev), &tcp_hashinfo,
-					    &ipv6_hdr(skb)->daddr,
-					    ntohs(th->dest), inet6_iif(skb));
+	case TCP_TW_SYN: {
+		struct sock *sk2 = inet6_lookup_listener(dev_net(skb->dev),
+							 &tcp_hashinfo,
+							 &ipv6_hdr(skb)->daddr,
+							 ntohs(th->dest),
+							 inet6_iif(skb));
 		if (sk2 != NULL) {
-			struct inet_timewait_sock *tw = inet_twsk(sk);
-			inet_twsk_deschedule(tw, &tcp_death_row);
-			inet_twsk_put(tw);
+			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
 			goto process;
 		}
-- 
1.6.3.3


--------------010708010901000107070101--
