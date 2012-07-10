From: David Miller <davem@davemloft.net>
Subject: [PATCH 02/16] tcp: Abstract back handling peer aliveness test into
 helper function.
Date: Tue, 10 Jul 2012 08:07:11 -0700 (PDT)
Message-ID: <20120710.080711.2131167238971054094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab2GJPHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:12 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 0228158662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h      |    1 +
 net/ipv4/tcp_ipv4.c    |    2 +-
 net/ipv4/tcp_metrics.c |   10 ++++++++++
 net/ipv6/tcp_ipv6.c    |    2 +-
 4 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 98ca797..5478356 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -389,6 +389,7 @@ extern void tcp_enter_loss(struct sock *sk, int how);
 extern void tcp_clear_retrans(struct tcp_sock *tp);
 extern void tcp_update_metrics(struct sock *sk);
 extern void tcp_init_metrics(struct sock *sk);
+extern bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst);
 extern void tcp_disable_fack(struct tcp_sock *tp);
 extern void tcp_close(struct sock *sk, long timeout);
 extern void tcp_init_sock(struct sock *sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 64568fa..e9312a8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1405,7 +1405,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
 			  (sysctl_max_syn_backlog >> 2)) &&
 			 (!peer || !peer->tcp_ts_stamp) &&
-			 (!dst || !dst_metric(dst, RTAX_RTT))) {
+			 !tcp_peer_is_proven(req, dst)) {
 			/* Without syncookies last quarter of
 			 * backlog is filled with destinations,
 			 * proven to be alive.
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 2793ecf..9afe703 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1,7 +1,9 @@
+#include <linux/module.h>
 #include <linux/cache.h>
 #include <linux/tcp.h>
 
 #include <net/inet_connection_sock.h>
+#include <net/request_sock.h>
 #include <net/sock.h>
 #include <net/dst.h>
 #include <net/tcp.h>
@@ -190,3 +192,11 @@ reset:
 		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
+
+bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst)
+{
+	if (!dst)
+		return false;
+	return dst_metric(dst, RTAX_RTT) ? true : false;
+}
+EXPORT_SYMBOL_GPL(tcp_peer_is_proven);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6cc67ed..75d1795 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1177,7 +1177,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
 			  (sysctl_max_syn_backlog >> 2)) &&
 			 (!peer || !peer->tcp_ts_stamp) &&
-			 (!dst || !dst_metric(dst, RTAX_RTT))) {
+			 !tcp_peer_is_proven(req, dst)) {
 			/* Without syncookies last quarter of
 			 * backlog is filled with destinations,
 			 * proven to be alive.
-- 
1.7.10.4
