From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: fix tcp_should_expand_sndbuf() to use tcp_packets_in_flight()
Date: Fri, 20 Feb 2015 13:33:16 -0500
Message-ID: <1424457196-3497-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:65095 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820AbbBTSdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 13:33:42 -0500
Received: by mail-yk0-f171.google.com with SMTP id q200so8025826ykb.2
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 10:33:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_should_expand_sndbuf() does not expand the send buffer if we have
filled the congestion window.

However, it should use tcp_packets_in_flight() instead of
tp->packets_out to make this check.

Testing has established that the difference matters a lot if there are
many SACKed packets, causing a needless performance shortfall.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8fdd27b..fb4cf8b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4770,7 +4770,7 @@ static bool tcp_should_expand_sndbuf(const struct sock *sk)
 		return false;
 
 	/* If we filled the congestion window, do not expand.  */
-	if (tp->packets_out >= tp->snd_cwnd)
+	if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
 		return false;
 
 	return true;
-- 
2.2.0.rc0.207.ga3a616c
