From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v3 -next 2/2] tcp: syncookies: reduce mss table to four values
Date: Fri, 20 Sep 2013 22:32:56 +0200
Message-ID: <1379709176-1625-2-git-send-email-fw@strlen.de>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50694 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753946Ab3ITUge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 16:36:34 -0400
In-Reply-To: <1379709176-1625-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Halve mss table size to make blind cookie guessing more difficult.
This is sad since the tables were already small, but there
is little alternative except perhaps adding more precise mss information
in the tcp timestamp.  Timestamps are unfortunately not ubiquitous.

Guessing all possible cookie values still has 8-in 2**32 chance.

Reported-by: Jakob Lell <jakob@jakoblell.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v2:
 - add comment explaining mss choices for tcp6 cookies, too
 Changes since v1:
 - add comment explaining mss choices

 net/ipv4/syncookies.c | 22 +++++++++++-----------
 net/ipv6/syncookies.c | 15 +++++++++------
 2 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b6ea297..15e0241 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -136,22 +136,22 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
 }
 
 /*
- * MSS Values are taken from the 2009 paper
- * 'Measuring TCP Maximum Segment Size' by S. Alcock and R. Nelson:
- *  - values 1440 to 1460 accounted for 80% of observed mss values
- *  - values outside the 536-1460 range are rare (<0.2%).
+ * MSS Values are chosen based on the 2011 paper
+ * 'An Analysis of TCP Maximum Segement Sizes' by S. Alcock and R. Nelson.
+ * Values ..
+ *  .. lower than 536 are rare (< 0.2%)
+ *  .. between 537 and 1299 account for less than < 1.5% of observed values
+ *  .. in the 1300-1349 range account for about 15 to 20% of observed mss values
+ *  .. exceeding 1460 are very rare (< 0.04%)
  *
- * Table must be sorted.
+ *  1460 is the single most frequently announced mss value (30 to 46% depending
+ *  on monitor location).  Table must be sorted.
  */
 static __u16 const msstab[] = {
-	64,
-	512,
 	536,
-	1024,
-	1440,
+	1300,
+	1440,	/* 1440, 1452: PPPoE */
 	1460,
-	4312,
-	8960,
 };
 
 /*
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 13ca0a0..d703218 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -24,15 +24,18 @@
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
-/* Table must be sorted. */
+/* RFC 2460, Section 8.3:
+ * [ipv6 tcp] MSS must be computed as the maximum packet size minus 60 [..]
+ *
+ * Due to IPV6_MIN_MTU=1280 the lowest possible MSS is 1220, which allows
+ * using higher values than ipv4 tcp syncookies.
+ * The other values are chosen based on ethernet (1500 and 9k MTU), plus
+ * one that accounts for common encap (PPPoe) overhead. Table must be sorted.
+ */
 static __u16 const msstab[] = {
-	64,
-	512,
-	536,
-	1280 - 60,
+	1280 - 60, /* IPV6_MIN_MTU - 60 */
 	1480 - 60,
 	1500 - 60,
-	4460 - 60,
 	9000 - 60,
 };
 
-- 
1.8.1.5
