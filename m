From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net v2] tcp: ipv6: Update MIB counters for drops
Date: Thu, 31 Jan 2013 10:24:19 -0800
Message-ID: <1359656659-29375-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	niveditasinghvi@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:60840 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab3AaSYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 13:24:31 -0500
Received: by mail-da0-f49.google.com with SMTP id v40so1397026dad.36
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 10:24:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS in
tcp_v6_conn_request() and tcp_v6_err(). tcp_v6_conn_request() in particular can
drop SYNs for various reasons which are not currently tracked.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
Changes from V1: Removed one needless update to ListenOverflows.

 net/ipv6/tcp_ipv6.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93825dd..4f43537 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -423,6 +423,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		}
 
 		inet_csk_reqsk_queue_drop(sk, req, prev);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto out;
 
 	case TCP_SYN_SENT:
@@ -958,8 +959,10 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 	}
 
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 		goto drop;
+	}
 
 	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
 	if (req == NULL)
@@ -1108,6 +1111,7 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return 0; /* don't send reset */
 }
 
-- 
1.7.0.4
