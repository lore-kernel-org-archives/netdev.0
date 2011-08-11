From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH] tcp: Replace possible syn attack msg by counters
Date: Wed, 10 Aug 2011 22:38:02 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:32295 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514Ab1HKFiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 01:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than printing the message to the log, use a mib counter to keep
track of the count of occurences of syn cookies being used or syn
being dropped when request queue is full.

Rationale is these messages can fill up /var/log/messages on server
which is simply under heavy load... I'm not sure how much more useful
they would be in identifying a server DOS attack (compared to
counters).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/snmp.h |    2 ++
 net/ipv4/proc.c      |    2 ++
 net/ipv4/tcp_ipv4.c  |   30 +++++++++---------------------
 net/ipv6/tcp_ipv6.c  |   29 +++++++++--------------------
 4 files changed, 22 insertions(+), 41 deletions(-)

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
index 955b8e6..f36ab28 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -807,21 +807,6 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
-static void syn_flood_warning(const struct sk_buff *skb)
-{
-	const char *msg;
-
-#ifdef CONFIG_SYN_COOKIES
-	if (sysctl_tcp_syncookies)
-		msg = "Sending cookies";
-	else
-#endif
-		msg = "Dropping request";
-
-	pr_info("TCP: Possible SYN flooding on port %d. %s.\n",
-				ntohs(tcp_hdr(skb)->dest), msg);
-}
-
 /*
  * Save and compile IPv4 options into the request_sock if needed.
  */
@@ -1249,14 +1234,17 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * evidently real one.
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
-		if (net_ratelimit())
-			syn_flood_warning(skb);
 #ifdef CONFIG_SYN_COOKIES
-		if (sysctl_tcp_syncookies) {
-			want_cookie = 1;
-		} else
+		want_cookie = sysctl_tcp_syncookies;
 #endif
-		goto drop;
+		if (want_cookie)
+			NET_INC_STATS_BH(sock_net(sk),
+			      LINUX_MIB_TCPREQQFULLDOCOOKIES);
+		else {
+			NET_INC_STATS_BH(sock_net(sk),
+			    LINUX_MIB_TCPREQQFULLDROP);
+			goto drop;
+		}
 	}
 
 	/* Accept backlog is full. If we have already queued enough
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 78aa534..810ae64 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -530,20 +530,6 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
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
@@ -1191,14 +1177,17 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
-		if (net_ratelimit())
-			syn_flood_warning(skb);
 #ifdef CONFIG_SYN_COOKIES
-		if (sysctl_tcp_syncookies)
-			want_cookie = 1;
-		else
+		want_cookie = sysctl_tcp_syncookies;
 #endif
-		goto drop;
+		if (want_cookie)
+			NET_INC_STATS_BH(sock_net(sk),
+			      LINUX_MIB_TCPREQQFULLDOCOOKIES);
+		else {
+			NET_INC_STATS_BH(sock_net(sk),
+			    LINUX_MIB_TCPREQQFULLDROP);
+			goto drop;
+		}
 	}
 
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
-- 
1.7.3.1

