From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/5] net: syncookies: export cookie_v4_init_sequence/cookie_v4_check
Date: Wed,  7 Aug 2013 19:42:48 +0200
Message-ID: <1375897371-18430-3-git-send-email-kaber@trash.net>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46893 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932621Ab3HGRnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 13:43:00 -0400
In-Reply-To: <1375897371-18430-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract the local TCP stack independant parts of tcp_v4_init_sequence()
and cookie_v4_check() and export them for use by the upcoming SYNPROXY
target.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/tcp.h     |  4 ++++
 net/ipv4/syncookies.c | 29 ++++++++++++++++++-----------
 2 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 18fc999..63256c6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -480,9 +480,13 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 
 /* From syncookies.c */
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
+extern int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
+			     u32 cookie);
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
 #ifdef CONFIG_SYN_COOKIES
+extern u32 __cookie_v4_init_sequence(const struct iphdr *iph,
+				     const struct tcphdr *th, u16 *mssp);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
 				     __u16 *mss);
 #else
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b05c96e..14a15c4 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -160,26 +160,33 @@ static __u16 const msstab[] = {
  * Generate a syncookie.  mssp points to the mss, which is returned
  * rounded down to the value encoded in the cookie.
  */
-__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
+u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
+			      u16 *mssp)
 {
-	const struct iphdr *iph = ip_hdr(skb);
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
 	return secure_tcp_syn_cookie(iph->saddr, iph->daddr,
 				     th->source, th->dest, ntohl(th->seq),
 				     jiffies / (HZ * 60), mssind);
 }
+EXPORT_SYMBOL_GPL(__cookie_v4_init_sequence);
+
+__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
+
+	tcp_synq_overflow(sk);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
+
+	return __cookie_v4_init_sequence(iph, th, mssp);
+}
 
 /*
  * This (misnamed) value is the age of syncookie which is permitted.
@@ -192,10 +199,9 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
  * Check if a ack sequence number is a valid syncookie.
  * Return the decoded mss if it is, or 0 if not.
  */
-static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
+int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
+		      u32 cookie)
 {
-	const struct iphdr *iph = ip_hdr(skb);
-	const struct tcphdr *th = tcp_hdr(skb);
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, iph->saddr, iph->daddr,
 					    th->source, th->dest, seq,
@@ -204,6 +210,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
+EXPORT_SYMBOL_GPL(__cookie_v4_check);
 
 static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 					   struct request_sock *req,
@@ -284,7 +291,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		goto out;
 
 	if (tcp_synq_no_recent_overflow(sk) ||
-	    (mss = cookie_check(skb, cookie)) == 0) {
+	    (mss = __cookie_v4_check(ip_hdr(skb), th, cookie)) == 0) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
 	}
-- 
1.8.1.4
