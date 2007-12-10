From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Bind fackets_out state to highest_sack more tightly
Date: Mon, 10 Dec 2007 14:27:24 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712101426010.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-758338078-1197289644=:18529"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:32779 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbXLJM1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 07:27:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-758338078-1197289644=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Added checks will catch most of the errors if the current
complex fack_count counting logic is flawed somewhere.

Fackets_out should always be advancable if highest_sack is too
because the fackets_out is nowadays accurate (and obviously it
must be smaller than packets_out).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9499a12..23b2a34 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1270,24 +1270,28 @@ static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 			}
 		}
 
-		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
+		fack_count += tcp_skb_pcount(skb);
+		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp))) {
+			WARN_ON((fack_count <= tp->fackets_out) ||
+				(fack_count > tp->packets_out));
+
 			tcp_advance_highest_sack(sk, skb);
+			tp->fackets_out = fack_count;
+		} else
+			WARN_ON(fack_count > tp->fackets_out);
+
 		tcp_write_queue_requeue(skb, sk, TCP_WQ_SACKED);
 
 		TCP_SKB_CB(skb)->sacked |= TCPCB_SACKED_ACKED;
 		flag |= FLAG_DATA_SACKED;
 		tp->sacked_out += tcp_skb_pcount(skb);
 
-		fack_count += tcp_skb_pcount(skb);
-
 		/* Lost marker hint past SACKed? Tweak RFC3517 cnt */
 		if (!tcp_is_fack(tp) && (tp->lost_skb_hint != NULL) &&
 		    before(TCP_SKB_CB(skb)->seq,
 			   TCP_SKB_CB(tp->lost_skb_hint)->seq))
 			tp->lost_cnt_hint += tcp_skb_pcount(skb);
 
-		if (fack_count > tp->fackets_out)
-			tp->fackets_out = fack_count;
 	}
 
 	/* D-SACK. We can detect redundant retransmission in S|R and plain R
-- 
1.5.0.6

---696243703-758338078-1197289644=:18529--
