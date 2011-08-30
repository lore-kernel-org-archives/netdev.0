From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] tcp: Change possible SYN flooding messages
Date: Tue, 30 Aug 2011 15:21:44 +0200
Message-ID: <1314710504.2935.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39243 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658Ab1H3NVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 09:21:44 -0400
Received: by wyg24 with SMTP id 24so4899028wyg.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 06:21:43 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Possible SYN flooding on port xxxx " messages can fill logs on servers.

Change logic to log the message only once per listener, and add two new
SNMP counters to track :

TCPReqQFullDoCookies : number of times a SYNCOOKIE was replied to client

TCPReqQFullDrop : number of times a SYN request was dropped because
syncookies were not enabled.

Based on a prior patch from Tom Herbert, and suggestions from David.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 include/linux/snmp.h       |    2 +
 include/net/request_sock.h |    3 +-
 include/net/tcp.h          |    3 ++
 net/ipv4/proc.c            |    2 +
 net/ipv4/tcp_ipv4.c        |   49 ++++++++++++++++++++---------------
 net/ipv6/tcp_ipv6.c        |   31 ++--------------------
 6 files changed, 40 insertions(+), 50 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 12b2b18..e16557a 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -231,6 +231,8 @@ enum
 	LINUX_MIB_TCPDEFERACCEPTDROP,
 	LINUX_MIB_IPRPFILTER, /* IP Reverse Path Filter (rp_filter) */
 	LINUX_MIB_TCPTIMEWAITOVERFLOW,		/* TCPTimeWaitOverflow */
+	LINUX_MIB_TCPREQQFULLDOCOOKIES,		/* TCPReqQFullDoCookies */
+	LINUX_MIB_TCPREQQFULLDROP,		/* TCPReqQFullDrop */
 	__LINUX_MIB_MAX
 };
 
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 99e6e19..4c0766e 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -96,7 +96,8 @@ extern int sysctl_max_syn_backlog;
  */
 struct listen_sock {
 	u8			max_qlen_log;
-	/* 3 bytes hole, try to use */
+	u8			synflood_warned;
+	/* 2 bytes hole, try to use */
 	int			qlen;
 	int			qlen_young;
 	int			clock_hand;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 149a415..e9b48b0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -460,6 +460,9 @@ extern int tcp_write_wakeup(struct sock *);
 extern void tcp_send_fin(struct sock *sk);
 extern void tcp_send_active_reset(struct sock *sk, gfp_t priority);
 extern int tcp_send_synack(struct sock *);
+extern int tcp_syn_flood_action(struct sock *sk,
+				const struct sk_buff *skb,
+				const char *proto);
 extern void tcp_push_one(struct sock *, unsigned int mss_now);
 extern void tcp_send_ack(struct sock *sk);
 extern void tcp_send_delayed_ack(struct sock *sk);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index b14ec7d..4bfad5d 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -254,6 +254,8 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPDeferAcceptDrop", LINUX_MIB_TCPDEFERACCEPTDROP),
 	SNMP_MIB_ITEM("IPReversePathFilter", LINUX_MIB_IPRPFILTER),
 	SNMP_MIB_ITEM("TCPTimeWaitOverflow", LINUX_MIB_TCPTIMEWAITOVERFLOW),
+	SNMP_MIB_ITEM("TCPReqQFullDoCookies", LINUX_MIB_TCPREQQFULLDOCOOKIES),
+	SNMP_MIB_ITEM("TCPReqQFullDrop", LINUX_MIB_TCPREQQFULLDROP),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b3f2611..c29912c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -808,20 +808,38 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
-static void syn_flood_warning(const struct sk_buff *skb)
+/*
+ * Return 1 if a syncookie should be sent
+ */
+int tcp_syn_flood_action(struct sock *sk,
+			 const struct sk_buff *skb,
+			 const char *proto)
 {
-	const char *msg;
+	const char *msg = "Dropping request";
+	int want_cookie = 0;
+	struct listen_sock *lopt;
+
+
 
 #ifdef CONFIG_SYN_COOKIES
-	if (sysctl_tcp_syncookies)
+	if (sysctl_tcp_syncookies) {
 		msg = "Sending cookies";
-	else
+		want_cookie = 1;
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDOCOOKIES);
+	} else
 #endif
-		msg = "Dropping request";
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);
 
-	pr_info("TCP: Possible SYN flooding on port %d. %s.\n",
-				ntohs(tcp_hdr(skb)->dest), msg);
+	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
+	if (!lopt->synflood_warned) {
+		lopt->synflood_warned = 1;
+		pr_info("%s: Possible SYN flooding on port %d. %s. "
+			" Check SNMP counters.\n",
+			proto, ntohs(tcp_hdr(skb)->dest), msg);
+	}
+	return want_cookie;
 }
+EXPORT_SYMBOL(tcp_syn_flood_action);
 
 /*
  * Save and compile IPv4 options into the request_sock if needed.
@@ -1235,11 +1253,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
-#ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
-#else
-#define want_cookie 0 /* Argh, why doesn't gcc optimize this :( */
-#endif
 
 	/* Never answer to SYNs send to broadcast or multicast */
 	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
@@ -1250,14 +1264,9 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * evidently real one.
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
-		if (net_ratelimit())
-			syn_flood_warning(skb);
-#ifdef CONFIG_SYN_COOKIES
-		if (sysctl_tcp_syncookies) {
-			want_cookie = 1;
-		} else
-#endif
-		goto drop;
+		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
+		if (!want_cookie)
+			goto drop;
 	}
 
 	/* Accept backlog is full. If we have already queued enough
@@ -1303,9 +1312,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		while (l-- > 0)
 			*c++ ^= *hash_location++;
 
-#ifdef CONFIG_SYN_COOKIES
 		want_cookie = 0;	/* not our kind of cookie */
-#endif
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
 	} else if (!tp->rx_opt.cookie_in_always) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 44a5859..12bdb9a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -531,20 +531,6 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
 	return tcp_v6_send_synack(sk, req, rvp);
 }
 
-static inline void syn_flood_warning(struct sk_buff *skb)
-{
-#ifdef CONFIG_SYN_COOKIES
-	if (sysctl_tcp_syncookies)
-		printk(KERN_INFO
-		       "TCPv6: Possible SYN flooding on port %d. "
-		       "Sending cookies.\n", ntohs(tcp_hdr(skb)->dest));
-	else
-#endif
-		printk(KERN_INFO
-		       "TCPv6: Possible SYN flooding on port %d. "
-		       "Dropping request.\n", ntohs(tcp_hdr(skb)->dest));
-}
-
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
 	kfree_skb(inet6_rsk(req)->pktopts);
@@ -1179,11 +1165,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
-#ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
-#else
-#define want_cookie 0
-#endif
 
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_conn_request(sk, skb);
@@ -1192,14 +1174,9 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
-		if (net_ratelimit())
-			syn_flood_warning(skb);
-#ifdef CONFIG_SYN_COOKIES
-		if (sysctl_tcp_syncookies)
-			want_cookie = 1;
-		else
-#endif
-		goto drop;
+		want_cookie = tcp_syn_flood_action(sk, skb, "TCPv6");
+		if (!want_cookie)
+			goto drop;
 	}
 
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
@@ -1249,9 +1226,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		while (l-- > 0)
 			*c++ ^= *hash_location++;
 
-#ifdef CONFIG_SYN_COOKIES
 		want_cookie = 0;	/* not our kind of cookie */
-#endif
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
 	} else if (!tp->rx_opt.cookie_in_always) {
