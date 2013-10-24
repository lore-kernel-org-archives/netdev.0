From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: only take RTT from timestamps if new data is acked
Date: Thu, 24 Oct 2013 08:55:25 -0700
Message-ID: <1382630125-21416-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:39035 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432Ab3JXPzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 11:55:39 -0400
Received: by mail-vc0-f202.google.com with SMTP id ld13so178081vcb.5
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 08:55:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch ed08495c3 "tcp: use RTT from SACK for RTO" has a bug that
it does not check if the ACK acknowledge new data before taking
the RTT sample from TCP timestamps. This patch adds the check
back as required by the RFC.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 305cd05..6ffe41a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2856,7 +2856,8 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 	 * left edge of the send window.
 	 * See draft-ietf-tcplw-high-performance-00, section 3.3.
 	 */
-	if (seq_rtt < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
+	if (seq_rtt < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
+	    flag & FLAG_ACKED)
 		seq_rtt = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
 
 	if (seq_rtt < 0)
-- 
1.8.4.1
