From: Per Hurtig <per.hurtig@kau.se>
Subject: [PATCH v2 1/1] tcp: fixing TLP's FIN recovery
Date: Thu, 12 Jun 2014 17:08:32 +0200
Message-ID: <1402585712-12103-1-git-send-email-per.hurtig@kau.se>
References: <1402583577.3645.477.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Per Hurtig <per.hurtig@kau.se>, panweiping3@gmail.com,
	nanditad@google.com, netdev@vger.kernel.org, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se, ncardwell@google.com,
	sergei.shtylyov@cogentembedded.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:11598 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752900AbaFLPRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 11:17:18 -0400
In-Reply-To: <1402583577.3645.477.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to a problem observed when losing a FIN segment that does not
contain data.  In such situations, TLP is unable to recover from
*any* tail loss and instead adds at least PTO ms to the
retransmission process, i.e., RTO = RTO + PTO.

Signed-off-by: Per Hurtig <per.hurtig@kau.se>
---
 net/ipv4/tcp_output.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ad7549f..819bf0c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2131,9 +2131,7 @@ void tcp_send_loss_probe(struct sock *sk)
 	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
 		goto rearm_timer;
 
-	/* Probe with zero data doesn't trigger fast recovery. */
-	if (skb->len > 0)
-		err = __tcp_retransmit_skb(sk, skb);
+	err = __tcp_retransmit_skb(sk, skb);
 
 	/* Record snd_nxt for loss detection. */
 	if (likely(!err))
-- 
1.9.1
