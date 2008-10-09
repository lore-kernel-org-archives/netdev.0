From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/4] tcpv6: combine tcp_v6_send_(reset|ack)
Date: Thu,  9 Oct 2008 12:35:37 +0300
Message-ID: <1223544937-12595-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1223544937-12595-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60789 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755419AbYJIJfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 05:35:42 -0400
In-Reply-To: <1223544937-12595-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ codiff tcp_ipv6.o.old tcp_ipv6.o.new
net/ipv6/tcp_ipv6.c:
  tcp_v6_md5_hash_hdr | -144
  tcp_v6_send_ack     | -585
  tcp_v6_send_reset   | -540
 3 functions changed, 1269 bytes removed, diff: -1269

net/ipv6/tcp_ipv6.c:
  tcp_v6_send_response | +791
 1 function changed, 791 bytes added, diff: +791

tcp_ipv6.o.new:
 4 functions changed, 791 bytes added, 1269 bytes removed, diff: -478

I choose to leave the reset related netns comment in place (not
the one that is killed) as I cannot understand its English so
it's a bit hard for me to evaluate its usefulness :-).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/tcp_ipv6.c |  139 +++++++++++++++----------------------------=
--------
 1 files changed, 40 insertions(+), 99 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 082724b..9204caf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -941,7 +941,8 @@ static int tcp_v6_gso_send_check(struct sk_buff *sk=
b)
 	return 0;
 }
=20
-static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
+static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack=
, u32 win,
+				 u32 ts, struct tcp_md5sig_key *key, int rst)
 {
 	struct tcphdr *th =3D tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
@@ -950,31 +951,14 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
 	struct sock *ctl_sk =3D net->ipv6.tcp_sk;
 	unsigned int tot_len =3D sizeof(struct tcphdr);
 	__be32 *topt;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
-#endif
-
-	if (th->rst)
-		return;
-
-	if (!ipv6_unicast_destination(skb))
-		return;
=20
+	if (ts)
+		tot_len +=3D TCPOLEN_TSTAMP_ALIGNED;
 #ifdef CONFIG_TCP_MD5SIG
-	if (sk)
-		key =3D tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
-	else
-		key =3D NULL;
-
 	if (key)
 		tot_len +=3D TCPOLEN_MD5SIG_ALIGNED;
 #endif
=20
-	/*
-	 * We need to grab some memory, and put together an RST,
-	 * and then put it into the queue to be sent.
-	 */
-
 	buff =3D alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
 			 GFP_ATOMIC);
 	if (buff =3D=3D NULL)
@@ -989,18 +973,21 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
 	t1->dest =3D th->source;
 	t1->source =3D th->dest;
 	t1->doff =3D tot_len / 4;
-	t1->rst =3D 1;
-
-	if(th->ack) {
-		t1->seq =3D th->ack_seq;
-	} else {
-		t1->ack =3D 1;
-		t1->ack_seq =3D htonl(ntohl(th->seq) + th->syn + th->fin
-				    + skb->len - (th->doff<<2));
-	}
+	t1->seq =3D htonl(seq);
+	t1->ack_seq =3D htonl(ack);
+	t1->ack =3D !rst || !th->ack;
+	t1->rst =3D rst;
+	t1->window =3D htons(win);
=20
 	topt =3D (__be32 *)(t1 + 1);
=20
+	if (ts) {
+		*topt++ =3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
+				(TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
+		*topt++ =3D htonl(tcp_time_stamp);
+		*topt++ =3D htonl(ts);
+	}
+
 #ifdef CONFIG_TCP_MD5SIG
 	if (key) {
 		*topt++ =3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
@@ -1035,7 +1022,8 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >=3D 0) {
 			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
-			TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
+			if (rst)
+				TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
 			return;
 		}
 	}
@@ -1043,87 +1031,40 @@ static void tcp_v6_send_reset(struct sock *sk, =
struct sk_buff *skb)
 	kfree_skb(buff);
 }
=20
-static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32=
 win, u32 ts,
-			    struct tcp_md5sig_key *key)
+static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcphdr *th =3D tcp_hdr(skb), *t1;
-	struct sk_buff *buff;
-	struct flowi fl;
-	struct net *net =3D dev_net(skb->dst->dev);
-	struct sock *ctl_sk =3D net->ipv6.tcp_sk;
-	unsigned int tot_len =3D sizeof(struct tcphdr);
-	__be32 *topt;
-
-	if (ts)
-		tot_len +=3D TCPOLEN_TSTAMP_ALIGNED;
+	struct tcphdr *th =3D tcp_hdr(skb);
+	u32 seq =3D 0, ack_seq =3D 0;
 #ifdef CONFIG_TCP_MD5SIG
-	if (key)
-		tot_len +=3D TCPOLEN_MD5SIG_ALIGNED;
+	struct tcp_md5sig_key *key;
 #endif
=20
-	buff =3D alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
-	if (buff =3D=3D NULL)
+	if (th->rst)
 		return;
=20
-	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
-
-	t1 =3D (struct tcphdr *) skb_push(buff, tot_len);
-
-	/* Swap the send and the receive. */
-	memset(t1, 0, sizeof(*t1));
-	t1->dest =3D th->source;
-	t1->source =3D th->dest;
-	t1->doff =3D tot_len / 4;
-	t1->seq =3D htonl(seq);
-	t1->ack_seq =3D htonl(ack);
-	t1->ack =3D 1;
-	t1->window =3D htons(win);
-
-	topt =3D (__be32 *)(t1 + 1);
-
-	if (ts) {
-		*topt++ =3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
-				(TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
-		*topt++ =3D htonl(tcp_time_stamp);
-		*topt++ =3D htonl(ts);
-	}
+	if (!ipv6_unicast_destination(skb))
+		return;
=20
 #ifdef CONFIG_TCP_MD5SIG
-	if (key) {
-		*topt++ =3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
-				(TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
-		tcp_v6_md5_hash_hdr((__u8 *)topt, key,
-				    &ipv6_hdr(skb)->saddr,
-				    &ipv6_hdr(skb)->daddr, t1);
-	}
+	if (sk)
+		key =3D tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
+	else
+		key =3D NULL;
 #endif
=20
-	buff->csum =3D csum_partial((char *)t1, tot_len, 0);
-
-	memset(&fl, 0, sizeof(fl));
-	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
-	ipv6_addr_copy(&fl.fl6_src, &ipv6_hdr(skb)->daddr);
-
-	t1->check =3D csum_ipv6_magic(&fl.fl6_src, &fl.fl6_dst,
-				    tot_len, IPPROTO_TCP,
-				    buff->csum);
-
-	fl.proto =3D IPPROTO_TCP;
-	fl.oif =3D inet6_iif(skb);
-	fl.fl_ip_dport =3D t1->dest;
-	fl.fl_ip_sport =3D t1->source;
-	security_skb_classify_flow(skb, &fl);
+	if (th->ack)
+		seq =3D ntohl(th->ack_seq);
+	else
+		ack_seq =3D ntohl(th->seq) + th->syn + th->fin + skb->len -
+			  (th->doff << 2);
=20
-	if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
-		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >=3D 0) {
-			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
-			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
-			return;
-		}
-	}
+	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1);
+}
=20
-	kfree_skb(buff);
+static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32=
 win, u32 ts,
+			    struct tcp_md5sig_key *key)
+{
+	tcp_v6_send_response(skb, seq, ack, win, ts, key, 0);
 }
=20
 static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
--=20
1.5.2.2

