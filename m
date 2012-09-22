From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 4/4] tcp: TCP Fast Open Server - call tcp_validate_incoming() for all packets
Date: Sat, 22 Sep 2012 10:18:57 -0400
Message-ID: <1348323537-30310-4-git-send-email-ncardwell@google.com>
References: <1348323537-30310-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:47285 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab2IVOTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 10:19:33 -0400
Received: by ggnq2 with SMTP id q2so333647ggn.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 07:19:32 -0700 (PDT)
In-Reply-To: <1348323537-30310-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A TCP Fast Open (TFO) passive connection must call both
tcp_check_req() and tcp_validate_incoming() for all incoming ACKs that
are attempting to complete the 3WHS.

This is needed to parallel all the action that happens for a non-TFO
connection, where for an ACK that is attempting to complete the 3WHS
we call both tcp_check_req() and tcp_validate_incoming().

For example, upon receiving the ACK that completes the 3WHS, we need
to call tcp_fast_parse_options() and update ts_recent based on the
incoming timestamp value in the ACK.

One symptom of the problem with the previous code was that for passive
TFO connections using TCP timestamps, the outgoing TS ecr values
ignored the incoming TS val value on the ACK that completed the 3WHS.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bb32668..36e069a1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5969,7 +5969,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 		if (tcp_check_req(sk, skb, req, NULL, true) == NULL)
 			goto discard;
-	} else if (!tcp_validate_incoming(sk, skb, th, 0))
+	}
+	if (!tcp_validate_incoming(sk, skb, th, 0))
 		return 0;
 
 	/* step 5: check the ACK field */
-- 
1.7.7.3
