From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 2/2] tcp: TLP retransmits last if failed to send new packet
Date: Fri, 17 Jul 2015 14:22:52 -0700
Message-ID: <1437168172-24201-3-git-send-email-ycheng@google.com>
References: <1437168172-24201-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nanditad Dukkipati <nanditad@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33771 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbbGQVXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:23:15 -0400
Received: by pdbqm3 with SMTP id qm3so67525955pdb.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:23:15 -0700 (PDT)
In-Reply-To: <1437168172-24201-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TLP fails to send new packet because of receive window
limit or other reasons, it should fall back to retransmit
the last packet, instead of resorting to RTO.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Nanditad Dukkipati <nanditad@google.com>
---
 net/ipv4/tcp_output.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index deb944b..4f238bb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2226,7 +2226,7 @@ static bool skb_still_in_host_queue(const struct sock *sk,
 	return false;
 }
 
-/* When probe timeout (PTO) fires, send a new segment if one exists, else
+/* When probe timeout (PTO) fires, try send a new segment if possible, else
  * retransmit the last segment.
  */
 void tcp_send_loss_probe(struct sock *sk)
@@ -2237,9 +2237,14 @@ void tcp_send_loss_probe(struct sock *sk)
 	int mss = tcp_current_mss(sk);
 	int err = -1;
 
-	if (tcp_send_head(sk)) {
+	skb = tcp_send_head(sk);
+	if (skb) {
 		err = tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
-		goto rearm_timer;
+		if (!err)
+			goto rearm_timer;
+		skb = tcp_write_queue_prev(sk, skb);
+	} else {
+		skb = tcp_write_queue_tail(sk);
 	}
 
 	/* At most one outstanding TLP retransmission. */
@@ -2247,7 +2252,6 @@ void tcp_send_loss_probe(struct sock *sk)
 		goto rearm_timer;
 
 	/* Retransmit last segment. */
-	skb = tcp_write_queue_tail(sk);
 	if (WARN_ON(!skb))
 		goto rearm_timer;
 
@@ -2262,7 +2266,7 @@ void tcp_send_loss_probe(struct sock *sk)
 		if (unlikely(tcp_fragment(sk, skb, (pcount - 1) * mss, mss,
 					  GFP_ATOMIC)))
 			goto rearm_timer;
-		skb = tcp_write_queue_tail(sk);
+		skb = tcp_write_queue_next(sk, skb);
 	}
 
 	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
-- 
2.4.3.573.g4eafbef
