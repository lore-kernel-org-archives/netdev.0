From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 (2nd try)] [TCP] MTUprobe: fix potential sk_send_head
 corruption
Date: Mon, 19 Nov 2007 16:15:54 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711191610590.24866@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0711191559060.24866@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-869651294-1195481754=:24866"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37827 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbXKSOP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 09:15:56 -0500
In-Reply-To: <Pine.LNX.4.64.0711191559060.24866@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-869651294-1195481754=:24866
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Please ignore the previous version, it had an rbtree artifact which made 
it to not apply cleanly, here's the corrected version:

--
[PATCH] [TCP] MTUprobe: fix potential sk_send_head corruption

When the abstraction functions got added, conversion here was
made incorrectly. As a result, the skb may end up pointing
to skb which got included to the probe skb and then was freed.
For it to trigger, however, skb_transmit must fail sending as
well.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    3 +++
 net/ipv4/tcp_output.c |    1 -
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1bceca8..f0c5e7a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1290,6 +1290,9 @@ static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sock *sk)
 {
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+
+	if (sk->sk_send_head == skb)
+		sk->sk_send_head = new;
 }
 
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b0ece43..30d6737 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1346,7 +1346,6 @@ static int tcp_mtu_probe(struct sock *sk)
 
 	skb = tcp_send_head(sk);
 	tcp_insert_write_queue_before(nskb, skb, sk);
-	tcp_advance_send_head(sk, skb);
 
 	TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(nskb)->end_seq = TCP_SKB_CB(skb)->seq + probe_size;
-- 
1.5.0.6

---696243703-869651294-1195481754=:24866--
