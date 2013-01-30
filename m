From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net] tcp: ipv6: Update MIB counters for drops
Date: Wed, 30 Jan 2013 14:58:03 -0800
Message-ID: <1359586683-16105-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, niveditasinghvi@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:63885 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756404Ab3A3W4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 17:56:53 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so989126dal.1
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 14:56:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS in
tcp_v6_conn_request() and tcp_v6_err(). tcp_v6_conn_request() in particular can
drop SYNs for various reasons which are not currently tracked.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
Ignored "line over 80 chars" warning for readability.

 net/ipv6/tcp_ipv6.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93825dd..c85a31c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -423,6 +423,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		}
 
 		inet_csk_reqsk_queue_drop(sk, req, prev);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto out;
 
 	case TCP_SYN_SENT:
@@ -954,12 +955,16 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
 		want_cookie = tcp_syn_flood_action(sk, skb, "TCPv6");
-		if (!want_cookie)
+		if (!want_cookie) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 			goto drop;
+		}
 	}
 
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 		goto drop;
+	}
 
 	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
 	if (req == NULL)
@@ -1108,6 +1113,7 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return 0; /* don't send reset */
 }
 
-- 
1.7.0.4
