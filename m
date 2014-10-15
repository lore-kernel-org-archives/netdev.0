From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/3] ipv4: share tcp_v4_save_options() with cookie_v4_check()
Date: Wed, 15 Oct 2014 14:33:21 -0700
Message-ID: <1413408802-21052-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:55124 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbaJOVde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 17:33:34 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so1945419pdb.39
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 14:33:34 -0700 (PDT)
In-Reply-To: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

cookie_v4_check() allocates ip_options_rcu in the same way
with tcp_v4_save_options(), we can just make it a helper function.

Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/tcp.h     | 20 ++++++++++++++++++++
 net/ipv4/syncookies.c | 10 +---------
 net/ipv4/tcp_ipv4.c   | 20 --------------------
 3 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 74efeda..869637a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1666,4 +1666,24 @@ int tcpv4_offload_init(void);
 void tcp_v4_init(void);
 void tcp_init(void);
 
+/*
+ * Save and compile IPv4 options, return a pointer to it
+ */
+static inline struct ip_options_rcu *tcp_v4_save_options(struct sk_buff *skb)
+{
+	const struct ip_options *opt = &TCP_SKB_CB(skb)->header.h4.opt;
+	struct ip_options_rcu *dopt = NULL;
+
+	if (opt && opt->optlen) {
+		int opt_size = sizeof(*dopt) + opt->optlen;
+
+		dopt = kmalloc(opt_size, GFP_ATOMIC);
+		if (dopt && __ip_options_echo(&dopt->opt, skb, opt)) {
+			kfree(dopt);
+			dopt = NULL;
+		}
+	}
+	return dopt;
+}
+
 #endif	/* _TCP_H */
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 7e7401c..c68d0a1 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -317,15 +317,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
 	 */
-	if (opt && opt->optlen) {
-		int opt_size = sizeof(struct ip_options_rcu) + opt->optlen;
-
-		ireq->opt = kmalloc(opt_size, GFP_ATOMIC);
-		if (ireq->opt != NULL && __ip_options_echo(&ireq->opt->opt, skb, opt)) {
-			kfree(ireq->opt);
-			ireq->opt = NULL;
-		}
-	}
+	ireq->opt = tcp_v4_save_options(skb);
 
 	if (security_inet_conn_request(sk, skb, req)) {
 		reqsk_free(req);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 552e87e..6a2a7d6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -880,26 +880,6 @@ bool tcp_syn_flood_action(struct sock *sk,
 }
 EXPORT_SYMBOL(tcp_syn_flood_action);
 
-/*
- * Save and compile IPv4 options into the request_sock if needed.
- */
-static struct ip_options_rcu *tcp_v4_save_options(struct sk_buff *skb)
-{
-	const struct ip_options *opt = &TCP_SKB_CB(skb)->header.h4.opt;
-	struct ip_options_rcu *dopt = NULL;
-
-	if (opt && opt->optlen) {
-		int opt_size = sizeof(*dopt) + opt->optlen;
-
-		dopt = kmalloc(opt_size, GFP_ATOMIC);
-		if (dopt && __ip_options_echo(&dopt->opt, skb, opt)) {
-			kfree(dopt);
-			dopt = NULL;
-		}
-	}
-	return dopt;
-}
-
 #ifdef CONFIG_TCP_MD5SIG
 /*
  * RFC2385 MD5 checksumming requires a mapping of
-- 
1.8.3.1
