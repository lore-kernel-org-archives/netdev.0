From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: detect SYN/data drop when F-RTO is disabled
Date: Thu, 31 Jan 2013 11:16:46 -0800
Message-ID: <1359659806-29556-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:33042 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab3AaTQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 14:16:49 -0500
Received: by mail-qa0-f73.google.com with SMTP id g10so349231qah.4
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 11:16:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On receiving the SYN-ACK, Fast Open checks icsk_retransmit for SYN
retransmission to detect SYN/data drops. But if F-RTO is disabled,
icsk_retransmit is reset at step D of tcp_fastretrans_alert() (
under tcp_ack()) before tcp_rcv_fastopen_synack(). The fix is to use
total_retrans instead which accounts for SYN retransmission regardless
the use of F-RTO.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 492c7cf..de52403 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5647,8 +5647,7 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 	 * the remote receives only the retransmitted (regular) SYNs: either
 	 * the original SYN-data or the corresponding SYN-ACK is lost.
 	 */
-	syn_drop = (cookie->len <= 0 && data &&
-		    inet_csk(sk)->icsk_retransmits);
+	syn_drop = (cookie->len <= 0 && data && tp->total_retrans);
 
 	tcp_fastopen_cache_set(sk, mss, cookie, syn_drop);
 
-- 
1.8.1
