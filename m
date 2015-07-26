From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tso: allow deferring under reordering state
Date: Sun, 26 Jul 2015 09:45:24 +0200
Message-ID: <1437896724.20182.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37821 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbbGZHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 03:45:29 -0400
Received: by wibud3 with SMTP id ud3so78433312wib.0
        for <netdev@vger.kernel.org>; Sun, 26 Jul 2015 00:45:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While doing experiments with reordering resilience, we found
linux senders were not able to send at full speed under reordering,
because every incoming SACK was releasing one MSS.

This patch removes the limitation, as we did for CWR state
in commit a0ea700e409 ("tcp: tso: allow CA_CWR state in
tcp_tso_should_defer()")

Neal Cardwell had a concern about limited transmit so
Yuchung conducted experiments on GFE and found nothing
worth adding an extra check on fast path :

  if (icsk->icsk_ca_state == TCP_CA_Disorder &&
      tcp_sk(sk)->reordering == sysctl_tcp_reordering)
          goto send_now;

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 71057849593a..7d1efa762b75 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1774,7 +1774,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 		goto send_now;
 
-	if (!((1 << icsk->icsk_ca_state) & (TCPF_CA_Open | TCPF_CA_CWR)))
+	if (icsk->icsk_ca_state >= TCP_CA_Recovery)
 		goto send_now;
 
 	/* Avoid bursty behavior by allowing defer
