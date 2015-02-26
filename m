From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] tcp: tso: allow CA_CWR state in tcp_tso_should_defer()
Date: Thu, 26 Feb 2015 14:10:20 -0800
Message-ID: <1424988620-10781-4-git-send-email-edumazet@google.com>
References: <1424988620-10781-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:35139 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbbBZWMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 17:12:32 -0500
Received: by mail-oi0-f74.google.com with SMTP id u20so4038178oif.1
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 14:12:31 -0800 (PST)
In-Reply-To: <1424988620-10781-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another TCP issue is triggered by ECN.

Under pressure, receiver gets ECN marks, and send back ACK packets
with ECE TCP flag. Senders enter CA_CWR state.

In this state, tcp_tso_should_defer() is short cut :

if (icsk->icsk_ca_state != TCP_CA_Open)
    goto send_now;

This means that about all ACK packets we receive are triggering
a partial send, and because cwnd is kept small, we can only send
a small amount of data for each incoming ACK,
which in return generate more ACK packets.

Allowing CA_Open and CA_CWR states to enable TSO defer in
tcp_tso_should_defer() brings performance back :
TSO autodefer has more chance to defer under pressure.

This patch increases TSO and LRO/GRO efficiency back to normal levels,
and does not impact overall ECN behavior.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5f4fb4d5bbd6..8bbd86cd81c8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1762,7 +1762,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 		goto send_now;
 
-	if (icsk->icsk_ca_state != TCP_CA_Open)
+	if (!((1 << icsk->icsk_ca_state) & (TCPF_CA_Open | TCPF_CA_CWR)))
 		goto send_now;
 
 	/* Avoid bursty behavior by allowing defer
-- 
2.2.0.rc0.207.ga3a616c
