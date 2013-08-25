From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2] tcp: syncookies: reduce cookie lifetime to 128 seconds
Date: Sun, 25 Aug 2013 19:54:01 +0200
Message-ID: <1377453242-4773-1-git-send-email-fw@strlen.de>
Cc: jbohac@suse.cz, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56427 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754748Ab3HYRzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 13:55:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently accept cookies that were created less than 4 minutes ago
(ie, cookies with counter delta 0-3).  Combined with the 8 mss table
values, this yields 32 possible values (out of 2**32) that will be valid.

Reducing the lifetime to < 2 minutes halves the guessing chance while
still providing a large enough period (possible cookies are
only validated if last synqueue overflow was less than 3 seconds ago).

While at it, get rid of jiffies value -- they overflow too quickly on
32 bit platforms.

getnstimeofday is used to create a counter that increments every 64s.

Reported-by: Jakob Lell <jakob@jakoblell.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h     | 12 ++++++++++++
 net/ipv4/syncookies.c | 32 ++++++++++----------------------
 net/ipv6/syncookies.c | 25 ++++++++-----------------
 3 files changed, 30 insertions(+), 39 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 09cb5c1..89368db 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -478,7 +478,19 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
+
+#define MAX_SYNCOOKIE_AGE 2 /* 128 seconds */
+
 #ifdef CONFIG_SYN_COOKIES
+#include <linux/ktime.h>
+
+static inline u32 tcp_cookie_time(void)
+{
+	struct timespec now;
+	getnstimeofday(&now);
+	return now.tv_sec >> 6; /* 64 seconds granularity */
+}
+
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
 				     __u16 *mss);
 #else
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b05c96e..e2f84eb 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -87,10 +87,8 @@ __u32 cookie_init_timestamp(struct request_sock *req)
 	return ts;
 }
 
-
 static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
-				   __be16 dport, __u32 sseq, __u32 count,
-				   __u32 data)
+				   __be16 dport, __u32 sseq, __u32 data)
 {
 	/*
 	 * Compute the secure sequence number.
@@ -102,7 +100,7 @@ static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
 	 * As an extra hack, we add a small "data" value that encodes the
 	 * MSS into the second hash value.
 	 */
-
+	u32 count = tcp_cookie_time();
 	return (cookie_hash(saddr, daddr, sport, dport, 0, 0) +
 		sseq + (count << COOKIEBITS) +
 		((cookie_hash(saddr, daddr, sport, dport, count, 1) + data)
@@ -114,22 +112,21 @@ static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
  * If the syncookie is bad, the data returned will be out of
  * range.  This must be checked by the caller.
  *
- * The count value used to generate the cookie must be within
- * "maxdiff" if the current (passed-in) "count".  The return value
- * is (__u32)-1 if this test fails.
+ * The count value used to generate the cookie must be less than
+ * MAX_SYNCOOKIE_AGE minutes in the past.
+ * The return value (__u32)-1 if this test fails.
  */
 static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
-				  __be16 sport, __be16 dport, __u32 sseq,
-				  __u32 count, __u32 maxdiff)
+				  __be16 sport, __be16 dport, __u32 sseq)
 {
-	__u32 diff;
+	u32 diff, count = tcp_cookie_time();
 
 	/* Strip away the layers from the cookie */
 	cookie -= cookie_hash(saddr, daddr, sport, dport, 0, 0) + sseq;
 
 	/* Cookie is now reduced to (count * 2^24) ^ (hash % 2^24) */
 	diff = (count - (cookie >> COOKIEBITS)) & ((__u32) - 1 >> COOKIEBITS);
-	if (diff >= maxdiff)
+	if (diff >= MAX_SYNCOOKIE_AGE)
 		return (__u32)-1;
 
 	return (cookie -
@@ -178,17 +175,10 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 
 	return secure_tcp_syn_cookie(iph->saddr, iph->daddr,
 				     th->source, th->dest, ntohl(th->seq),
-				     jiffies / (HZ * 60), mssind);
+				     mssind);
 }
 
 /*
- * This (misnamed) value is the age of syncookie which is permitted.
- * Its ideal value should be dependent on TCP_TIMEOUT_INIT and
- * sysctl_tcp_retries1. It's a rather complicated formula (exponential
- * backoff) to compute at runtime so it's currently hardcoded here.
- */
-#define COUNTER_TRIES 4
-/*
  * Check if a ack sequence number is a valid syncookie.
  * Return the decoded mss if it is, or 0 if not.
  */
@@ -198,9 +188,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 	const struct tcphdr *th = tcp_hdr(skb);
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, iph->saddr, iph->daddr,
-					    th->source, th->dest, seq,
-					    jiffies / (HZ * 60),
-					    COUNTER_TRIES);
+					    th->source, th->dest, seq);
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d5dda20..6a6d585 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -18,6 +18,7 @@
 #include <linux/random.h>
 #include <linux/cryptohash.h>
 #include <linux/kernel.h>
+#include <linux/ktime.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
 
@@ -36,14 +37,6 @@ static __u16 const msstab[] = {
 	9000 - 60,
 };
 
-/*
- * This (misnamed) value is the age of syncookie which is permitted.
- * Its ideal value should be dependent on TCP_TIMEOUT_INIT and
- * sysctl_tcp_retries1. It's a rather complicated formula (exponential
- * backoff) to compute at runtime so it's currently hardcoded here.
- */
-#define COUNTER_TRIES 4
-
 static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 					   struct request_sock *req,
 					   struct dst_entry *dst)
@@ -86,8 +79,9 @@ static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *dadd
 static __u32 secure_tcp_syn_cookie(const struct in6_addr *saddr,
 				   const struct in6_addr *daddr,
 				   __be16 sport, __be16 dport, __u32 sseq,
-				   __u32 count, __u32 data)
+				   __u32 data)
 {
+	u32 count = tcp_cookie_time();
 	return (cookie_hash(saddr, daddr, sport, dport, 0, 0) +
 		sseq + (count << COOKIEBITS) +
 		((cookie_hash(saddr, daddr, sport, dport, count, 1) + data)
@@ -96,15 +90,14 @@ static __u32 secure_tcp_syn_cookie(const struct in6_addr *saddr,
 
 static __u32 check_tcp_syn_cookie(__u32 cookie, const struct in6_addr *saddr,
 				  const struct in6_addr *daddr, __be16 sport,
-				  __be16 dport, __u32 sseq, __u32 count,
-				  __u32 maxdiff)
+				  __be16 dport, __u32 sseq)
 {
-	__u32 diff;
+	__u32 diff, count = tcp_cookie_time();
 
 	cookie -= cookie_hash(saddr, daddr, sport, dport, 0, 0) + sseq;
 
 	diff = (count - (cookie >> COOKIEBITS)) & ((__u32) -1 >> COOKIEBITS);
-	if (diff >= maxdiff)
+	if (diff >= MAX_SYNCOOKIE_AGE)
 		return (__u32)-1;
 
 	return (cookie -
@@ -130,8 +123,7 @@ __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb, __u16
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
 	return secure_tcp_syn_cookie(&iph->saddr, &iph->daddr, th->source,
-				     th->dest, ntohl(th->seq),
-				     jiffies / (HZ * 60), mssind);
+				     th->dest, ntohl(th->seq), mssind);
 }
 
 static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
@@ -140,8 +132,7 @@ static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
 	const struct tcphdr *th = tcp_hdr(skb);
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, &iph->saddr, &iph->daddr,
-					    th->source, th->dest, seq,
-					    jiffies / (HZ * 60), COUNTER_TRIES);
+					    th->source, th->dest, seq);
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
-- 
1.8.1.5
