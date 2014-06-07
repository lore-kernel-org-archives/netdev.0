From: Per Hurtig <per.hurtig@kau.se>
Subject: [PATCH] tcp: fixing TLP's FIN recovery
Date: Sat,  7 Jun 2014 16:34:40 +0200
Message-ID: <1402151680-11434-1-git-send-email-per.hurtig@kau.se>
References: <539319F6.2090907@cogentembedded.com>
Cc: Per Hurtig <per.hurtig@kau.se>, eric.dumazet@gmail.com,
	anna.brunstrom@kau.se, mohammad.rajiullah@kau.se,
	ncardwell@google.com, nanditad@google.com,
	sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:15960 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752775AbaFGOfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2014 10:35:37 -0400
In-Reply-To: <539319F6.2090907@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to a problem observed when losing a FIN segment that does not
contain data.  In such situations, TLP is unable to recover from
*any* tail loss and instead adds at least PTO ms to the
retransmission process, i.e., RTO = RTO + PTO.

Signed-off-by: Per Hurtig <per.hurtig@kau.se>
---
 net/ipv4/tcp_output.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d463c35..6573765 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2130,8 +2130,10 @@ void tcp_send_loss_probe(struct sock *sk)
 	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
 		goto rearm_timer;
 
-	/* Probe with zero data doesn't trigger fast recovery. */
-	if (skb->len > 0)
+	/* Probe with zero data doesn't trigger fast recovery, if FIN
+	 * flag is not set.
+	 */
+	if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
 		err = __tcp_retransmit_skb(sk, skb);
 
 	/* Record snd_nxt for loss detection. */
-- 
1.9.1
