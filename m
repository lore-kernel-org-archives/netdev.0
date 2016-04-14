From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp: remove false sharing in tcp_rcv_state_process()
Date: Wed, 13 Apr 2016 22:05:40 -0700
Message-ID: <1460610340-22163-3-git-send-email-edumazet@google.com>
References: <1460610340-22163-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33836 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbcDNFFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 01:05:50 -0400
Received: by mail-pf0-f170.google.com with SMTP id c20so42297328pfc.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 22:05:49 -0700 (PDT)
In-Reply-To: <1460610340-22163-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last known hot point during SYNFLOOD attack is the clearing
of rx_opt.saw_tstamp in tcp_rcv_state_process()

It is not needed for a listener, so we move it where it matters.

Performance while a SYNFLOOD hits a single listener socket
went from 5 Mpps to 6 Mpps on my test server (24 cores, 8 NIC RX queues)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7ea7034af83f..90e0d9256b74 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5796,8 +5796,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 	int queued = 0;
 	bool acceptable;
 
-	tp->rx_opt.saw_tstamp = 0;
-
 	switch (sk->sk_state) {
 	case TCP_CLOSE:
 		goto discard;
@@ -5838,6 +5836,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		goto discard;
 
 	case TCP_SYN_SENT:
+		tp->rx_opt.saw_tstamp = 0;
 		queued = tcp_rcv_synsent_state_process(sk, skb, th);
 		if (queued >= 0)
 			return queued;
@@ -5849,6 +5848,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	tp->rx_opt.saw_tstamp = 0;
 	req = tp->fastopen_rsk;
 	if (req) {
 		WARN_ON_ONCE(sk->sk_state != TCP_SYN_RECV &&
-- 
2.8.0.rc3.226.g39d4020
