From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc: more user friendly rates
Date: Thu, 21 Nov 2013 22:37:17 -0800
Message-ID: <1385102237.10637.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:43020 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab3KVGhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 01:37:20 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so881721pbc.11
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 22:37:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Display more user friendly rates.

10Mbit is more readable than 10000Kbit

Before : 
class htb 1:2 root prio 0 rate 10000Kbit ceil 10000Kbit ...

After:
class htb 1:2 root prio 0 rate 10Mbit ceil 10Mbit ...

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/tc_util.c |   32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index be3ed07..67f6948 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -173,28 +173,22 @@ int get_rate(unsigned *rate, const char *str)
 
 void print_rate(char *buf, int len, __u64 rate)
 {
-	double tmp = (double)rate*8;
 	extern int use_iec;
+	unsigned long kilo = use_iec ? 1024 : 1000;
+	const char *str = use_iec ? "i" : "";
+	int i = 0;
+	static char *units[5] = {"", "K", "M", "G", "T"};
 
-	if (use_iec) {
-		if (tmp >= 1000.0*1024.0*1024.0*1024.0)
-			snprintf(buf, len, "%.0fGibit", tmp/(1024.0*1024.0*1024.0));
-		else if (tmp >= 1000.0*1024.0*1024.0)
-			snprintf(buf, len, "%.0fMibit", tmp/(1024.0*1024.0));
-		else if (tmp >= 1000.0*1024)
-			snprintf(buf, len, "%.0fKibit", tmp/1024);
-		else
-			snprintf(buf, len, "%.0fbit", tmp);
-	} else {
-		if (tmp >= 1000.0*1000000000.0)
-			snprintf(buf, len, "%.0fGbit", tmp/1000000000.0);
-		else if (tmp >= 1000.0*1000000.0)
-			snprintf(buf, len, "%.0fMbit", tmp/1000000.0);
-		else if (tmp >= 1000.0 * 1000.0)
-			snprintf(buf, len, "%.0fKbit", tmp/1000.0);
-		else
-			snprintf(buf, len, "%.0fbit",  tmp);
+	rate <<= 3; /* bytes/sec -> bits/sec */
+
+	for (i = 0; i < ARRAY_SIZE(units); i++)  {
+		if (rate < kilo)
+			break;
+		if (((rate % kilo) != 0) && rate < 1000*kilo)
+			break;
+		rate /= kilo;
 	}
+	snprintf(buf, len, "%.0f%s%sbit", (double)rate, units[i], str);
 }
 
 char * sprint_rate(__u64 rate, char *buf)
