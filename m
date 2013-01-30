From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net] tcp: Update MIB counters for drops
Date: Wed, 30 Jan 2013 14:57:50 -0800
Message-ID: <1359586670-16072-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, niveditasinghvi@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:54247 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216Ab3A3W4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 17:56:39 -0500
Received: by mail-pb0-f48.google.com with SMTP id wy12so1237347pbc.21
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 14:56:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS in
tcp_v4_conn_request() and tcp_v4_err(). tcp_v4_conn_request() in particular can
drop SYNs for various reasons which are not currently tracked.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
Ignored "line over 80 chars" warning for readability.

 net/ipv4/tcp_ipv4.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 629937d..029ac1f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -496,6 +496,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		 * errors returned from accept().
 		 */
 		inet_csk_reqsk_queue_drop(sk, req, prev);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto out;
 
 	case TCP_SYN_SENT:
@@ -1491,8 +1492,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
 		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
-		if (!want_cookie)
+		if (!want_cookie) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 			goto drop;
+		}
 	}
 
 	/* Accept backlog is full. If we have already queued enough
@@ -1502,7 +1505,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto drop;
 	}
 
@@ -1669,6 +1671,7 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return 0;
 }
 EXPORT_SYMBOL(tcp_v4_conn_request);
-- 
1.7.0.4
