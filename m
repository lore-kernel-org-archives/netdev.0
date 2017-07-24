From: Ilya Matveychikov <matvejchikov@gmail.com>
Subject: [PATCH] tcp: remove redundant argument from tcp_rcv_established()
Date: Mon, 24 Jul 2017 16:02:12 +0400
Message-ID: <187C550C-E5E9-45E7-BC6C-20431B6883E0@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33203 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbdGXMCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 08:02:16 -0400
Received: by mail-wm0-f68.google.com with SMTP id q189so1172136wmd.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 05:02:16 -0700 (PDT)
Received: from [10.1.0.103] (bba193486.alshamil.net.ae. [217.165.96.192])
        by smtp.gmail.com with ESMTPSA id 90sm12656153wrk.38.2017.07.24.05.02.13
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 05:02:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last (4th) argument of tcp_rcv_established() is redundant as it
always equals to skb->len and the skb itself is always passed as 2th
agrument. There is no reason to have it.

Signed-off-by: Ilya V. Matveychikov <matvejchikov@gmail.com>
---
 include/net/tcp.h    | 2 +-
 net/ipv4/tcp_input.c | 3 ++-
 net/ipv4/tcp_ipv4.c  | 2 +-
 net/ipv4/tcp_probe.c | 5 +++--
 net/ipv6/tcp_ipv6.c  | 2 +-
 5 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7048329..f4ae655 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -363,7 +363,7 @@ void tcp_delack_timer_handler(struct sock *sk);
 int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb);
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			 const struct tcphdr *th, unsigned int len);
+			 const struct tcphdr *th);
 void tcp_rcv_space_adjust(struct sock *sk);
 int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp);
 void tcp_twsk_destructor(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2920e0c..adc3f3e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5358,8 +5358,9 @@ static bool tcp_validate_incoming(struct sock *sk, =
struct sk_buff *skb,
  *	tcp_data_queue when everything is OK.
  */
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			 const struct tcphdr *th, unsigned int len)
+			 const struct tcphdr *th)
 {
+	unsigned int len =3D skb->len;
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
 	tcp_mstamp_refresh(tp);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a20e7f0..3a19ea2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1458,7 +1458,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff =
*skb)
 				sk->sk_rx_dst =3D NULL;
 			}
 		}
-		tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len);
+		tcp_rcv_established(sk, skb, tcp_hdr(skb));
 		return 0;
 	}
=20
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index f6c50af..697f4c6 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -105,8 +105,9 @@ static inline int tcp_probe_avail(void)
  * Note: arguments must match tcp_rcv_established()!
  */
 static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-				 const struct tcphdr *th, unsigned int =
len)
+				 const struct tcphdr *th)
 {
+	unsigned int len =3D skb->len;
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_sock *inet =3D inet_sk(sk);
=20
@@ -145,7 +146,7 @@ static void jtcp_rcv_established(struct sock *sk, =
struct sk_buff *skb,
 				BUG();
 			}
=20
-			p->length =3D skb->len;
+			p->length =3D len;
 			p->snd_nxt =3D tp->snd_nxt;
 			p->snd_una =3D tp->snd_una;
 			p->snd_cwnd =3D tp->snd_cwnd;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2521690..90a3257 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1296,7 +1296,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct =
sk_buff *skb)
 			}
 		}
=20
-		tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len);
+		tcp_rcv_established(sk, skb, tcp_hdr(skb));
 		if (opt_skb)
 			goto ipv6_pktoptions;
 		return 0;
--=20
2.7.4
