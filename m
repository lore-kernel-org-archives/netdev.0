From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [RFC net-next 03/12] net: remove inet6_reqsk_alloc
Date: Mon, 23 Jun 2014 21:42:40 +0300
Message-ID: <1403548969-12303-4-git-send-email-octavian.purdila@intel.com>
References: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42127 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753367AbaFWSo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 14:44:27 -0400
In-Reply-To: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since pktops is only used for IPv6 only and opts is used for IPv4
only, we can move these fields into a union and this allows us to drop
the inet6_reqsk_alloc function as after this change it becomes
equivalent with inet_reqsk_alloc.

This patch also fixes an kmemcheck issue in the IPv6 stack: the flags
field was not annotated after a request_sock was allocated.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/linux/ipv6.h    | 10 ----------
 include/net/inet_sock.h |  6 ++++--
 net/dccp/ipv6.c         |  2 +-
 net/ipv6/syncookies.c   |  2 +-
 net/ipv6/tcp_ipv6.c     |  2 +-
 5 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2faef33..c811300 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -256,16 +256,6 @@ static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 	return inet_sk(__sk)->pinet6;
 }
 
-static inline struct request_sock *inet6_reqsk_alloc(struct request_sock_ops *ops)
-{
-	struct request_sock *req = reqsk_alloc(ops);
-
-	if (req)
-		inet_rsk(req)->pktopts = NULL;
-
-	return req;
-}
-
 static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 {
 	return (struct raw6_sock *)sk;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b1edf17..a829b77 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -88,8 +88,10 @@ struct inet_request_sock {
 				acked	   : 1,
 				no_srccheck: 1;
 	kmemcheck_bitfield_end(flags);
-	struct ip_options_rcu	*opt;
-	struct sk_buff		*pktopts;
+	union {
+		struct ip_options_rcu	*opt;
+		struct sk_buff		*pktopts;
+	};
 	u32                     ir_mark;
 };
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4db3c2a..04cb17d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -386,7 +386,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = inet6_reqsk_alloc(&dccp6_request_sock_ops);
+	req = inet_reqsk_alloc(&dccp6_request_sock_ops);
 	if (req == NULL)
 		goto drop;
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index a822b88..83cea1d 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -187,7 +187,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	ret = NULL;
-	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
+	req = inet_reqsk_alloc(&tcp6_request_sock_ops);
 	if (!req)
 		goto out;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a962455..5e2d7e6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1010,7 +1010,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
-	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
+	req = inet_reqsk_alloc(&tcp6_request_sock_ops);
 	if (req == NULL)
 		goto drop;
 
-- 
1.8.3.2
