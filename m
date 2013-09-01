From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 -next 1/2] tcp: syncookies: reduce cookie lifetime to 128 seconds
Date: Sun,  1 Sep 2013 21:55:55 +0200
Message-ID: <1378065356-25509-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49132 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753022Ab3IAT4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 15:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently accept cookies that were created less than 4 minutes ago
(ie, cookies with counter delta 0-3).  Combined with the 8 mss table
values, this yields 32 possible values (out of 2**32) that will be valid.

Reducing the lifetime to < 2 minutes halves the guessing chance while
still providing a large enough period.

While at it, get rid of jiffies value -- they overflow too quickly on
32 bit platforms.

getnstimeofday is used to create a counter that increments every 64s.
perf shows getnstimeofday cost is negible compared to sha_transform;
'ordinary' sequence number generation uses getnstimeofday, too.

Reported-by: Jakob Lell <jakob@jakoblell.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v1:
  - add comment explaining MAX_SYNCOOKIE_AGE value
  - add sentence about 'getnstimeofday' cost to commit message
  - rebase on net-next master

 include/net/tcp.h     | 19 +++++++++++++++++++
 net/ipv4/syncookies.c | 31 ++++++++++---------------------
 net/ipv6/syncookies.c | 24 +++++++-----------------
 3 files changed, 35 insertions(+), 38 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6a6a88d..7d9205c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -482,6 +482,24 @@ extern int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
 #ifdef CONFIG_SYN_COOKIES
+#include <linux/ktime.h>
+
+/* Syncookies use a monotonic timer which increments every 64 seconds.
+ * This counter is used both as a hash input and partially encoded into
+ * the cookie value.  A cookie is only validated further if the delta
+ * between the current counter value and the encoded one is less than this,
+ * i.e. a sent cookie is valid only at most for 128 seconds (or less if
+ * the counter advances immediately after a cookie is generated).
+ */
+#define MAX_SYNCOOKIE_AGE 2
+
+static inline u32 tcp_cookie_time(void)
+{
+	struct timespec now;
+	getnstimeofday(&now);
+	return now.tv_sec >> 6; /* 64 seconds granularity */
+}
+
 extern u32 __cookie_v4_init_sequence(const struct iphdr *iph,
 				     const struct tcphdr *th, u16 *mssp);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 14a15c4..b6ea297 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -89,8 +89,7 @@ __u32 cookie_init_timestamp(struct request_sock *req)
 
 
 static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
-				   __be16 dport, __u32 sseq, __u32 count,
-				   __u32 data)
+				   __be16 dport, __u32 sseq, __u32 data)
 {
 	/*
 	 * Compute the secure sequence number.
@@ -102,7 +101,7 @@ static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
 	 * As an extra hack, we add a small "data" value that encodes the
 	 * MSS into the second hash value.
 	 */
-
+	u32 count = tcp_cookie_time();
 	return (cookie_hash(saddr, daddr, sport, dport, 0, 0) +
 		sseq + (count << COOKIEBITS) +
 		((cookie_hash(saddr, daddr, sport, dport, count, 1) + data)
@@ -114,22 +113,21 @@ static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
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
@@ -173,7 +171,7 @@ u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 
 	return secure_tcp_syn_cookie(iph->saddr, iph->daddr,
 				     th->source, th->dest, ntohl(th->seq),
-				     jiffies / (HZ * 60), mssind);
+				     mssind);
 }
 EXPORT_SYMBOL_GPL(__cookie_v4_init_sequence);
 
@@ -189,13 +187,6 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
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
@@ -204,9 +195,7 @@ int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 {
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, iph->saddr, iph->daddr,
-					    th->source, th->dest, seq,
-					    jiffies / (HZ * 60),
-					    COUNTER_TRIES);
+					    th->source, th->dest, seq);
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index bf63ac8..13ca0a0 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -36,14 +36,6 @@ static __u16 const msstab[] = {
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
@@ -86,8 +78,9 @@ static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *dadd
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
@@ -96,15 +89,14 @@ static __u32 secure_tcp_syn_cookie(const struct in6_addr *saddr,
 
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
@@ -125,8 +117,7 @@ u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
 	*mssp = msstab[mssind];
 
 	return secure_tcp_syn_cookie(&iph->saddr, &iph->daddr, th->source,
-				     th->dest, ntohl(th->seq),
-				     jiffies / (HZ * 60), mssind);
+				     th->dest, ntohl(th->seq), mssind);
 }
 EXPORT_SYMBOL_GPL(__cookie_v6_init_sequence);
 
@@ -146,8 +137,7 @@ int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
 {
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, &iph->saddr, &iph->daddr,
-					    th->source, th->dest, seq,
-					    jiffies / (HZ * 60), COUNTER_TRIES);
+					    th->source, th->dest, seq);
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
-- 
1.8.1.5
