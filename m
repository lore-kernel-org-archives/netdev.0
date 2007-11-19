From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6] [TCP] MTUprobe: fix potential sk_send_head corruption
Date: Mon, 19 Nov 2007 16:02:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711191559060.24866@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-153072018-1195480969=:24866"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45272 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbXKSOCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 09:02:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-153072018-1195480969=:24866
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


When the abstraction functions got added, conversion was made
here incorrectly. As a result, the skb may end up pointing
to skb which got included to the probe skb and then was freed.
For it to trigger, however, transmit_skb must fail sending as
well.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    3 +++
 net/ipv4/tcp_output.c |    1 -
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index decd8f3..c11b613 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1342,6 +1342,9 @@ static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 {
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
 	tcp_rb_insert(new, &tcp_sk(sk)->write_queue_rb);
+
+	if (sk->sk_send_head == skb)
+		sk->sk_send_head = new;
 }
 
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8fe3ee2..1654fac 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1343,7 +1343,6 @@ static int tcp_mtu_probe(struct sock *sk)
 	TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(nskb)->end_seq = TCP_SKB_CB(skb)->seq + probe_size;
 	tcp_insert_write_queue_before(nskb, skb, sk);
-	tcp_advance_send_head(sk, skb);
 
 	TCP_SKB_CB(nskb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(nskb)->sacked = 0;
-- 
1.5.0.6

---696243703-153072018-1195480969=:24866--
