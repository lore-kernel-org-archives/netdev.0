From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/4] tcpv6: convert opt[] -> topt in tcp_v6_send_reset
Date: Thu,  9 Oct 2008 12:35:36 +0300
Message-ID: <1223544937-12595-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48804 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753AbYJIJfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 05:35:41 -0400
In-Reply-To: <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after this I get:

$ diff-funcs tcp_v6_send_reset tcp_ipv6.c tcp_ipv6.c tcp_v6_send_ack
 --- tcp_ipv6.c:tcp_v6_send_reset()
 +++ tcp_ipv6.c:tcp_v6_send_ack()
@@ -1,4 +1,5 @@
-static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
+static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32=
 win,
u32 ts,
+                           struct tcp_md5sig_key *key)
 {
        struct tcphdr *th =3D tcp_hdr(skb), *t1;
        struct sk_buff *buff;
@@ -7,31 +8,14 @@
        struct sock *ctl_sk =3D net->ipv6.tcp_sk;
        unsigned int tot_len =3D sizeof(struct tcphdr);
        __be32 *topt;
-#ifdef CONFIG_TCP_MD5SIG
-       struct tcp_md5sig_key *key;
-#endif
-
-       if (th->rst)
-               return;
-
-       if (!ipv6_unicast_destination(skb))
-               return;

+       if (ts)
+               tot_len +=3D TCPOLEN_TSTAMP_ALIGNED;
 #ifdef CONFIG_TCP_MD5SIG
-       if (sk)
-               key =3D tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr)=
;
-       else
-               key =3D NULL;
-
        if (key)
                tot_len +=3D TCPOLEN_MD5SIG_ALIGNED;
 #endif

-       /*
-        * We need to grab some memory, and put together an RST,
-        * and then put it into the queue to be sent.
-        */
-
        buff =3D alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_le=
n,
                         GFP_ATOMIC);
        if (buff =3D=3D NULL)
@@ -46,18 +30,20 @@
        t1->dest =3D th->source;
        t1->source =3D th->dest;
        t1->doff =3D tot_len / 4;
-       t1->rst =3D 1;
-
-       if(th->ack) {
-               t1->seq =3D th->ack_seq;
-       } else {
-               t1->ack =3D 1;
-               t1->ack_seq =3D htonl(ntohl(th->seq) + th->syn + th->fi=
n
-                                   + skb->len - (th->doff<<2));
-       }
+       t1->seq =3D htonl(seq);
+       t1->ack_seq =3D htonl(ack);
+       t1->ack =3D 1;
+       t1->window =3D htons(win);

        topt =3D (__be32 *)(t1 + 1);

+       if (ts) {
+               *topt++ =3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 1=
6) |
+                               (TCPOPT_TIMESTAMP << 8) |
TCPOLEN_TIMESTAMP);
+               *topt++ =3D htonl(tcp_time_stamp);
+               *topt++ =3D htonl(ts);
+       }
+
 #ifdef CONFIG_TCP_MD5SIG
        if (key) {
                *topt++ =3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 1=
6) |
@@ -84,15 +70,10 @@
        fl.fl_ip_sport =3D t1->source;
        security_skb_classify_flow(skb, &fl);

-       /* Pass a socket to ip6_dst_lookup either it is for RST
-        * Underlying function will use this to retrieve the network
-        * namespace
-        */
        if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
                if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >=3D 0) {
                        ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
                        TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
-                       TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
                        return;
                }
        }


=2E..which starts to be trivial to combine.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/tcp_ipv6.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3f268a3..082724b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -949,6 +949,7 @@ static void tcp_v6_send_reset(struct sock *sk, stru=
ct sk_buff *skb)
 	struct net *net =3D dev_net(skb->dst->dev);
 	struct sock *ctl_sk =3D net->ipv6.tcp_sk;
 	unsigned int tot_len =3D sizeof(struct tcphdr);
+	__be32 *topt;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
@@ -998,14 +999,13 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
 				    + skb->len - (th->doff<<2));
 	}
=20
+	topt =3D (__be32 *)(t1 + 1);
+
 #ifdef CONFIG_TCP_MD5SIG
 	if (key) {
-		__be32 *opt =3D (__be32*)(t1 + 1);
-		opt[0] =3D htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
-		tcp_v6_md5_hash_hdr((__u8 *)&opt[1], key,
+		*topt++ =3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
+				(TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
+		tcp_v6_md5_hash_hdr((__u8 *)topt, key,
 				    &ipv6_hdr(skb)->saddr,
 				    &ipv6_hdr(skb)->daddr, t1);
 	}
--=20
1.5.2.2

