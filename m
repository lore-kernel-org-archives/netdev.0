From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 73/84] net/ipv4/tcp_metrics.c:252:3: error:
 implicit declaration of function 'inet6_twsk'
Date: Wed, 11 Jul 2012 02:39:39 -0700 (PDT)
Message-ID: <20120711.023939.1269322960321058056.davem@davemloft.net>
References: <20120711091233.GA24436@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: wfg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab2GKJjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 05:39:40 -0400
In-Reply-To: <20120711091233.GA24436@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wfg@linux.intel.com
Date: Wed, 11 Jul 2012 17:12:33 +0800

> net/ipv4/tcp_metrics.c: In function '__tcp_get_metrics_tw':
> net/ipv4/tcp_metrics.c:252:3: error: implicit declaration of function 'inet6_twsk' [-Werror=implicit-function-declaration]
> net/ipv4/tcp_metrics.c:252:7: warning: assignment makes pointer from integer without a cast [enabled by default]
> net/ipv4/tcp_metrics.c:253:41: error: dereferencing pointer to incomplete type

Fixed as follows:

====================
ipv6: Move ipv6 twsk accessors outside of CONFIG_IPV6 ifdefs.

Fixes build when ipv6 is disabled.

Reported-by: Fengguang Wu <wfg@linux.intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/ipv6.h |   32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 8260ef7..bc6c8fd 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -410,6 +410,22 @@ struct tcp6_sock {
 
 extern int inet6_sk_rebuild_header(struct sock *sk);
 
+struct inet6_timewait_sock {
+	struct in6_addr tw_v6_daddr;
+	struct in6_addr	tw_v6_rcv_saddr;
+};
+
+struct tcp6_timewait_sock {
+	struct tcp_timewait_sock   tcp6tw_tcp;
+	struct inet6_timewait_sock tcp6tw_inet6;
+};
+
+static inline struct inet6_timewait_sock *inet6_twsk(const struct sock *sk)
+{
+	return (struct inet6_timewait_sock *)(((u8 *)sk) +
+					      inet_twsk(sk)->tw_ipv6_offset);
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
@@ -459,28 +475,12 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
 #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
 
-struct inet6_timewait_sock {
-	struct in6_addr tw_v6_daddr;
-	struct in6_addr	tw_v6_rcv_saddr;
-};
-
-struct tcp6_timewait_sock {
-	struct tcp_timewait_sock   tcp6tw_tcp;
-	struct inet6_timewait_sock tcp6tw_inet6;
-};
-
 static inline u16 inet6_tw_offset(const struct proto *prot)
 {
 	return prot->twsk_prot->twsk_obj_size -
 			sizeof(struct inet6_timewait_sock);
 }
 
-static inline struct inet6_timewait_sock *inet6_twsk(const struct sock *sk)
-{
-	return (struct inet6_timewait_sock *)(((u8 *)sk) +
-					      inet_twsk(sk)->tw_ipv6_offset);
-}
-
 static inline struct in6_addr *__inet6_rcv_saddr(const struct sock *sk)
 {
 	return likely(sk->sk_state != TCP_TIME_WAIT) ?
-- 
1.7.10.4
