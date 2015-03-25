From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_syn_flood_action() can be static
Date: Wed, 25 Mar 2015 15:08:47 -0700
Message-ID: <1427321327.25985.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <octavian.purdila@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37175 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbbCYWIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:08:49 -0400
Received: by igcxg11 with SMTP id xg11so38556737igc.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:08:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 1fb6f159fd21 ("tcp: add tcp_conn_request"),
tcp_syn_flood_action() is no longer used from IPv6.

We can make it static, by moving it above tcp_conn_request()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h    |    2 --
 net/ipv4/tcp_input.c |   29 +++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c  |   29 -----------------------------
 3 files changed, 29 insertions(+), 31 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 42690daa924e4db6415856eadc80f3e7117a415d..963303fb96ae227263e648fb0c8dbafdc9cbc945 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -529,8 +529,6 @@ int tcp_write_wakeup(struct sock *);
 void tcp_send_fin(struct sock *sk);
 void tcp_send_active_reset(struct sock *sk, gfp_t priority);
 int tcp_send_synack(struct sock *);
-bool tcp_syn_flood_action(struct sock *sk, const struct sk_buff *skb,
-			  const char *proto);
 void tcp_push_one(struct sock *, unsigned int mss_now);
 void tcp_send_ack(struct sock *sk);
 void tcp_send_delayed_ack(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 023196f7ec37a616346bbbef54adea72b7f3269e..18b80e8bc5336564560b7897a939bbbb2d83e5ed 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5987,6 +5987,35 @@ struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 }
 EXPORT_SYMBOL(inet_reqsk_alloc);
 
+/*
+ * Return true if a syncookie should be sent
+ */
+static bool tcp_syn_flood_action(struct sock *sk,
+				 const struct sk_buff *skb,
+				 const char *proto)
+{
+	const char *msg = "Dropping request";
+	bool want_cookie = false;
+	struct listen_sock *lopt;
+
+#ifdef CONFIG_SYN_COOKIES
+	if (sysctl_tcp_syncookies) {
+		msg = "Sending cookies";
+		want_cookie = true;
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDOCOOKIES);
+	} else
+#endif
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);
+
+	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
+	if (!lopt->synflood_warned && sysctl_tcp_syncookies != 2) {
+		lopt->synflood_warned = 1;
+		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
+			proto, ntohs(tcp_hdr(skb)->dest), msg);
+	}
+	return want_cookie;
+}
+
 int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		     const struct tcp_request_sock_ops *af_ops,
 		     struct sock *sk, struct sk_buff *skb)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e073517b2cc727afdbde9161ce4305810a7e9bb4..5aababa20a212068d7ef5acf74c85ddb3d99f61f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -856,35 +856,6 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
-/*
- * Return true if a syncookie should be sent
- */
-bool tcp_syn_flood_action(struct sock *sk,
-			 const struct sk_buff *skb,
-			 const char *proto)
-{
-	const char *msg = "Dropping request";
-	bool want_cookie = false;
-	struct listen_sock *lopt;
-
-#ifdef CONFIG_SYN_COOKIES
-	if (sysctl_tcp_syncookies) {
-		msg = "Sending cookies";
-		want_cookie = true;
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDOCOOKIES);
-	} else
-#endif
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);
-
-	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
-	if (!lopt->synflood_warned && sysctl_tcp_syncookies != 2) {
-		lopt->synflood_warned = 1;
-		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
-			proto, ntohs(tcp_hdr(skb)->dest), msg);
-	}
-	return want_cookie;
-}
-EXPORT_SYMBOL(tcp_syn_flood_action);
 
 #ifdef CONFIG_TCP_MD5SIG
 /*
