From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/2] syncookies: remove ecn_ok validation when decoding option timestamp
Date: Sun, 26 Oct 2014 00:38:48 +0200
Message-ID: <1414276729-17871-2-git-send-email-fw@strlen.de>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54075 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751308AbaJYWjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 18:39:01 -0400
In-Reply-To: <1414276729-17871-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Won't work anymore when tcp_ecn=0 and RTAX_FEATURES route attribute did
allow ecn.

While its possible to extend the test to also perform route lookup and
check RTAX_FEATURES, it doesn't seem worth it.

Thus, just turn on ecn if the client ts indicates so.
This means that while syn cookies are in use clients can turn on ecn
even if it is off.  However, there seems to be no harm in permitting
this.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h     | 3 +--
 net/ipv4/syncookies.c | 6 ++----
 net/ipv6/syncookies.c | 2 +-
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c73fc14..7c85167 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -495,8 +495,7 @@ __u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
 #endif
 
 __u32 cookie_init_timestamp(struct request_sock *req);
-bool cookie_check_timestamp(struct tcp_options_received *opt, struct net *net,
-			    bool *ecn_ok);
+bool cookie_check_timestamp(struct tcp_options_received *opt, bool *ecn_ok);
 
 /* From net/ipv6/syncookies.c */
 int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 32b98d0..b84cc12 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -225,7 +225,7 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  * return false if we decode an option that should not be.
  */
 bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
-			struct net *net, bool *ecn_ok)
+			    bool *ecn_ok)
 {
 	/* echoed timestamp, lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr & TSMASK;
@@ -240,8 +240,6 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
 
 	tcp_opt->sack_ok = (options & (1 << 4)) ? TCP_SACK_SEEN : 0;
 	*ecn_ok = (options >> 5) & 1;
-	if (*ecn_ok && !net->ipv4.sysctl_tcp_ecn)
-		return false;
 
 	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
 		return false;
@@ -287,7 +285,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
 		goto out;
 
 	ret = NULL;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 0e26e79..4df0258 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -183,7 +183,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
 		goto out;
 
 	ret = NULL;
-- 
2.0.4
