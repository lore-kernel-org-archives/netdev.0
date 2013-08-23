From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 4/6] net: syncookies: export cookie_v6_init_sequence/cookie_v6_check
Date: Fri, 23 Aug 2013 09:52:07 +0200
Message-ID: <1377244329-20146-5-git-send-email-kaber@trash.net>
References: <1377244329-20146-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49534 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451Ab3HWHwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 03:52:13 -0400
In-Reply-To: <1377244329-20146-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract the local TCP stack independant parts of tcp_v6_init_sequence()
and cookie_v6_check() and export them for use by the upcoming IPv6 SYNPROXY
target.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/tcp.h     |  4 ++++
 net/ipv6/syncookies.c | 25 ++++++++++++++++---------
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 63256c6..22872c7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -503,8 +503,12 @@ extern bool cookie_check_timestamp(struct tcp_options_received *opt,
 				struct net *net, bool *ecn_ok);
 
 /* From net/ipv6/syncookies.c */
+extern int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
+			     u32 cookie);
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
 #ifdef CONFIG_SYN_COOKIES
+extern u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
+				     const struct tcphdr *th, u16 *mssp);
 extern __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
 				     __u16 *mss);
 #else
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d5dda20..bf63ac8 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -112,32 +112,38 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, const struct in6_addr *saddr,
 		& COOKIEMASK;
 }
 
-__u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb, __u16 *mssp)
+u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
+			      const struct tcphdr *th, __u16 *mssp)
 {
-	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	const struct tcphdr *th = tcp_hdr(skb);
 	int mssind;
 	const __u16 mss = *mssp;
 
-	tcp_synq_overflow(sk);
-
 	for (mssind = ARRAY_SIZE(msstab) - 1; mssind ; mssind--)
 		if (mss >= msstab[mssind])
 			break;
 
 	*mssp = msstab[mssind];
 
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
-
 	return secure_tcp_syn_cookie(&iph->saddr, &iph->daddr, th->source,
 				     th->dest, ntohl(th->seq),
 				     jiffies / (HZ * 60), mssind);
 }
+EXPORT_SYMBOL_GPL(__cookie_v6_init_sequence);
 
-static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
+__u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb, __u16 *mssp)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
+
+	tcp_synq_overflow(sk);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
+
+	return __cookie_v6_init_sequence(iph, th, mssp);
+}
+
+int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
+		      __u32 cookie)
+{
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, &iph->saddr, &iph->daddr,
 					    th->source, th->dest, seq,
@@ -145,6 +151,7 @@ static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
+EXPORT_SYMBOL_GPL(__cookie_v6_check);
 
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
@@ -167,7 +174,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	if (tcp_synq_no_recent_overflow(sk) ||
-		(mss = cookie_check(skb, cookie)) == 0) {
+		(mss = __cookie_v6_check(ipv6_hdr(skb), th, cookie)) == 0) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
 	}
-- 
1.8.1.4
