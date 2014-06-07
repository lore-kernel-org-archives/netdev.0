From: Per Hurtig <per.hurtig@kau.se>
Subject: [PATCH] tcp: fixing TLP's FIN recovery
Date: Sat,  7 Jun 2014 13:10:19 +0200
Message-ID: <1402139419-9118-1-git-send-email-per.hurtig@kau.se>
References: <1402081628.3645.315.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Per Hurtig <per.hurtig@kau.se>, eric.dumazet@gmail.com,
	anna.brunstrom@kau.se, mohammad.rajiullah@kau.se,
	ncardwell@google.com, nanditad@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:53445 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752425AbaFGLTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2014 07:19:35 -0400
In-Reply-To: <1402081628.3645.315.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to a problem observed when losing a FIN segment that does not
contain data.  In such situations, TLP is unable to recover from
*any* tail loss and instead adds at least PTO ms to the
retransmission process, i.e., RTO = RTO + PTO.
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
+	/* Probe with zero data doesn't trigger fast recovery, if not
+	 * FIN flag is set.
+	 */
+	if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
 		err = __tcp_retransmit_skb(sk, skb);
 
 	/* Record snd_nxt for loss detection. */
-- 
1.9.1
