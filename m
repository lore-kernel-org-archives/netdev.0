From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 02/13] tcp: tcp_v[46]_conn_request: fix snt_synack initialization
Date: Wed, 25 Jun 2014 17:09:51 +0300
Message-ID: <1403705402-14388-3-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>,
	Cardwell <ncardwell@google.com>,
	Daniel Lee <longinus00@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45741 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757174AbaFYOK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:29 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 016818d07 (tcp: TCP Fast Open Server - take SYNACK RTT after
completing 3WHS) changes the code to only take a snt_synack timestamp
when a SYNACK transmit or retransmit succeeds. This behaviour is later
broken by commit 843f4a55e (tcp: use tcp_v4_send_synack on first
SYN-ACK), as snt_synack is now updated even if tcp_v4_send_synack
fails.

Also, commit 3a19ce0ee (tcp: IPv6 support for fastopen server) misses
the required IPv6 updates for 016818d07.

This patch makes sure that snt_synack is updated only when the SYNACK
trasnmit/retransmit succeeds, for both IPv4 and IPv6.

Cc: Cardwell <ncardwell@google.com>
Cc: Daniel Lee <longinus00@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 net/ipv4/tcp_ipv4.c | 2 --
 net/ipv6/tcp_ipv6.c | 3 ++-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 180336d..145f640 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1370,7 +1370,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	tcp_rsk(req)->snt_isn = isn;
-	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 	tcp_openreq_init_rwin(req, sk, dst);
 	fastopen = !want_cookie &&
 		   tcp_try_fastopen(sk, skb, req, &foc, dst);
@@ -1380,7 +1379,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (err || want_cookie)
 			goto drop_and_free;
 
-		tcp_rsk(req)->snt_synack = tcp_time_stamp;
 		tcp_rsk(req)->listener = NULL;
 		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 08ae3da..a962455 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -497,6 +497,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
+		if (!tcp_rsk(req)->snt_synack && !err)
+			tcp_rsk(req)->snt_synack = tcp_time_stamp;
 	}
 
 done:
@@ -1100,7 +1102,6 @@ have_isn:
 		goto drop_and_free;
 
 	tcp_rsk(req)->snt_isn = isn;
-	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 	tcp_openreq_init_rwin(req, sk, dst);
 	fastopen = !want_cookie &&
 		   tcp_try_fastopen(sk, skb, req, &foc, dst);
-- 
1.8.3.2
