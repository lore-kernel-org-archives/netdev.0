From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v5 3/7] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Sat, 23 Jan 2010 00:56:16 -0500
Message-ID: <4B5A8F80.6050108@gmail.com>
References: <4B5A88C4.7050205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040905040300050607030100"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:46686 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789Ab0AWF4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 00:56:20 -0500
In-Reply-To: <4B5A88C4.7050205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040905040300050607030100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Harmonize tcp_v4_rcv() and tcp_v6_rcv() -- better document tcp doff
and header length assumptions, and carefully compare implementations.

Reduces multiply/shifts, marginally improving speed.

Removes redundant tcp header length checks before checksumming.

Instead, assumes (and documents) that any backlog processing and
transform policies will carefully preserve the header, and will
ensure the socket buffer length remains >= the header size.

Stand-alone patch, originally developed for TCPCT.

Signed-off-by: William.Allen.Simpson@gmail.com
CC: Andi Kleen <andi@firstfloor.org>
---
  include/net/xfrm.h  |    7 ++++++
  net/ipv4/tcp_ipv4.c |   45 +++++++++++++++++++++-----------------
  net/ipv6/tcp_ipv6.c |   59 ++++++++++++++++++++++++++++----------------------
  3 files changed, 65 insertions(+), 46 deletions(-)

--------------040905040300050607030100
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2c5+2.6.33-rc5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+2c5+2.6.33-rc5.patch"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6d85861..89c5465 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -975,6 +975,13 @@ xfrm_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x, unsigned short
 }
 
 #ifdef CONFIG_XFRM
+/*
+ * For transport, the policy is checked before the presumed more expensive
+ * checksum. The transport header has already been checked for size, and is
+ * guaranteed to be contiguous. These policies must not alter the header or
+ * its position in the buffer, and should not shorten the buffer length
+ * without ensuring the length remains >= the header size.
+ */
 extern int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb, unsigned short family);
 
 static inline int __xfrm_policy_check2(struct sock *sk, int dir,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 65b8ebf..0a76e41 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1559,7 +1559,8 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
+	/* Assumes header and options unchanged since checksum_init() */
+	if (tcp_checksum_complete(skb))
 		goto csum_err;
 
 	if (sk->sk_state == TCP_LISTEN) {
@@ -1601,14 +1602,13 @@ csum_err:
 }
 
 /*
- *	From tcp_input.c
+ *	Called by ip_input.c: ip_local_deliver_finish()
  */
-
 int tcp_v4_rcv(struct sk_buff *skb)
 {
-	const struct iphdr *iph;
 	struct tcphdr *th;
 	struct sock *sk;
+	int tcp_header_len;
 	int ret;
 	struct net *net = dev_net(skb->dev);
 
@@ -1618,31 +1618,33 @@ int tcp_v4_rcv(struct sk_buff *skb)
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
 
 	th = tcp_hdr(skb);
-	iph = ip_hdr(skb);
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
-				    skb->len - th->doff * 4);
+				    skb->len - tcp_header_len);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when	 = 0;
-	TCP_SKB_CB(skb)->flags	 = iph->tos;
+	TCP_SKB_CB(skb)->flags	 = ip_hdr(skb)->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
 	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
@@ -1682,14 +1684,14 @@ process:
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
-
 	return ret;
 
 no_tcp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 
-	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
+	/* Assumes header and options unchanged since checksum_init() */
+	if (tcp_checksum_complete(skb)) {
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
@@ -1711,18 +1713,21 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
+	/* Assumes header and options unchanged since checksum_init() */
+	if (tcp_checksum_complete(skb)) {
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
+
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo,
-							iph->daddr, th->dest,
+							ip_hdr(skb)->daddr,
+							th->dest,
 							inet_iif(skb));
-		if (sk2) {
+		if (sk2 != NULL) {
 			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
 			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index febfd59..b76939a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1594,7 +1594,8 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
+	/* Assumes header and options unchanged since checksum_init() */
+	if (tcp_checksum_complete(skb))
 		goto csum_err;
 
 	if (sk->sk_state == TCP_LISTEN) {
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
@@ -1711,6 +1721,7 @@ process:
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	/* nf_reset(skb); in ip6_input.c ip6_input_finish() */
 
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
@@ -1743,7 +1754,8 @@ no_tcp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 
-	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
+	/* Assumes header and options unchanged since checksum_init() */
+	if (tcp_checksum_complete(skb)) {
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
@@ -1751,11 +1763,7 @@ bad_packet:
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
 
@@ -1769,24 +1777,23 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
+	/* Assumes header and options unchanged since checksum_init() */
+	if (tcp_checksum_complete(skb)) {
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


--------------040905040300050607030100--
