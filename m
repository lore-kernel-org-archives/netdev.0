From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] [TCP]: Move FRTO checks out from write queue
 abstraction funcs
Date: Fri, 23 Nov 2007 14:25:08 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231422500.24866@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-807877614-1195820708=:24866"
Cc: Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37277 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383AbXKWMZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 07:25:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-807877614-1195820708=:24866
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Better place exists in update_send_head (other non-queue related
adjustments are done there as well) which is the only caller of 
tcp_advance_send_head (now that the bogus call from mtu_probe is
gone).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    5 -----
 net/ipv4/tcp_output.c |    4 ++++
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ebe7347..59c1bce 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1241,14 +1241,9 @@ static inline struct sk_buff *tcp_send_head(struct sock *sk)
 
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-
 	sk->sk_send_head = skb->next;
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
-	/* Don't override Nagle indefinately with F-RTO */
-	if (tp->frto_counter == 2)
-		tp->frto_counter = 3;
 }
 
 static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unlinked)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 44d70db..3b17688 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -80,6 +80,10 @@ static void update_send_head(struct sock *sk, struct sk_buff *skb)
 	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 	tcp_packets_out_inc(sk, skb);
+
+	/* Don't override Nagle indefinately with F-RTO */
+	if (tp->frto_counter == 2)
+		tp->frto_counter = 3;
 }
 
 /* SND.NXT, if window was not shrunk.
-- 
1.5.0.6

---696243703-807877614-1195820708=:24866--
