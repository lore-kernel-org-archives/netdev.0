From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: [PATCH][TCP]: simplify tcp_mark_lost_retrans()
Date: Wed, 07 Jan 2009 10:25:16 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0901071009000.6102@rhea>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:64214 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938AbZAGJz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 04:55:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed that in tcp_mark_lost_retrans the for-loop is only entered
if tcp_is_fack(tp) evaluates to true:

           if (!tcp_is_fack(tp) || !tp->retrans_out ||
               !after(received_upto, tp->lost_retrans_low) ||
               icsk->icsk_ca_state != TCP_CA_Recovery)
                   return;

Therefore the following check in the for-loop seems to be redundant,
because it always evaluates to true:

                      (tcp_is_fack(tp) ||
                       !before(received_upto,
                               ack_seq + tp->reordering * tp->mss_cache))

Did I miss something?

Best regards,
Arnd Hannemann

From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

Because the for loop is only executed for FACK-enabled flows remove
redundant checks within the loop.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
---
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 99b7ecb..cd8b4bd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1178,10 +1178,7 @@ static void tcp_mark_lost_retrans(struct sock *sk)
    		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))
    			continue;

-		if (after(received_upto, ack_seq) &&
-		    (tcp_is_fack(tp) ||
-		     !before(received_upto,
-			     ack_seq + tp->reordering * tp->mss_cache))) {
+		if (after(received_upto, ack_seq)) {
    			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
    			tp->retrans_out -= tcp_skb_pcount(skb);

