From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next-2.6] syncookies: update mss tables
Date: Thu,  3 Jun 2010 12:43:57 +0200
Message-ID: <1275561837-24269-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60312 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751616Ab0FCKr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:47:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- ipv6 msstab: account for ipv6 header size
- ipv4 msstab: add mss for Jumbograms.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/syncookies.c |   38 +++++++++++++++++++-------------------
 net/ipv6/syncookies.c |   39 +++++++++++++++------------------------
 2 files changed, 34 insertions(+), 43 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index c9dac86..a7cbcc4 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -138,23 +138,23 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
 }
 
 /*
- * This table has to be sorted and terminated with (__u16)-1.
- * XXX generate a better table.
- * Unresolved Issues: HIPPI with a 64k MSS is not well supported.
+ * MSS Values are taken from the 2009 paper
+ * 'Measuring TCP Maximum Segment Size' by S. Alcock and R. Nelson:
+ *  - values 1440 to 1460 accounted for 80% of observed mss values
+ *  - values outside the 536-1460 range are rare (<0.2%).
+ *
+ * Table must be sorted.
  */
 static __u16 const msstab[] = {
-	64 - 1,
-	256 - 1,
-	512 - 1,
-	536 - 1,
-	1024 - 1,
-	1440 - 1,
-	1460 - 1,
-	4312 - 1,
-	(__u16)-1
+	64,
+	512,
+	536,
+	1024,
+	1440,
+	1460,
+	4312,
+	8960,
 };
-/* The number doesn't include the -1 terminator */
-#define NUM_MSS (ARRAY_SIZE(msstab) - 1)
 
 /*
  * Generate a syncookie.  mssp points to the mss, which is returned
@@ -169,10 +169,10 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 
 	tcp_synq_overflow(sk);
 
-	/* XXX sort msstab[] by probability?  Binary search? */
-	for (mssind = 0; mss > msstab[mssind + 1]; mssind++)
-		;
-	*mssp = msstab[mssind] + 1;
+	for (mssind = ARRAY_SIZE(msstab) - 1; mssind ; mssind--)
+		if (mss >= msstab[mssind])
+			break;
+	*mssp = msstab[mssind];
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
@@ -202,7 +202,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 					    jiffies / (HZ * 60),
 					    COUNTER_TRIES);
 
-	return mssind < NUM_MSS ? msstab[mssind] + 1 : 0;
+	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
 
 static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 9fcb3ec..70d330f 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -27,28 +27,17 @@ extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
-/*
- * This table has to be sorted and terminated with (__u16)-1.
- * XXX generate a better table.
- * Unresolved Issues: HIPPI with a 64k MSS is not well supported.
- *
- * Taken directly from ipv4 implementation.
- * Should this list be modified for ipv6 use or is it close enough?
- * rfc 2460 8.3 suggests mss values 20 bytes less than ipv4 counterpart
- */
+/* Table must be sorted. */
 static __u16 const msstab[] = {
-	64 - 1,
-	256 - 1,
-	512 - 1,
-	536 - 1,
-	1024 - 1,
-	1440 - 1,
-	1460 - 1,
-	4312 - 1,
-	(__u16)-1
+	64,
+	512,
+	536,
+	1280 - 60,
+	1480 - 60,
+	1500 - 60,
+	4460 - 60,
+	9000 - 60,
 };
-/* The number doesn't include the -1 terminator */
-#define NUM_MSS (ARRAY_SIZE(msstab) - 1)
 
 /*
  * This (misnamed) value is the age of syncookie which is permitted.
@@ -134,9 +123,11 @@ __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 
 	tcp_synq_overflow(sk);
 
-	for (mssind = 0; mss > msstab[mssind + 1]; mssind++)
-		;
-	*mssp = msstab[mssind] + 1;
+	for (mssind = ARRAY_SIZE(msstab) - 1; mssind ; mssind--)
+		if (mss >= msstab[mssind])
+			break;
+
+	*mssp = msstab[mssind];
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
@@ -154,7 +145,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 					    th->source, th->dest, seq,
 					    jiffies / (HZ * 60), COUNTER_TRIES);
 
-	return mssind < NUM_MSS ? msstab[mssind] + 1 : 0;
+	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
 
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
-- 
1.6.4.4

