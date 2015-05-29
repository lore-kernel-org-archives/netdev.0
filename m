From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] tc: util: fix print_rate for ludicrous speeds
Date: Fri, 29 May 2015 21:47:45 +0200
Message-ID: <281e37b4ae33195fa475a2ceabf5c784785077b4.1432928262.git.daniel@iogearbox.net>
Cc: jose.r.guzman.mosqueda@intel.com, edumazet@google.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59803 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539AbbE2Trs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 15:47:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The for loop should only probe up to G[i]bit rates, so that we
end up with T[i]bit as the last max units[] slot for snprintf(3),
and not possibly an invalid pointer in case rate is multiple of
kilo.

Fixes: 8cecdc283743 ("tc: more user friendly rates")
Reported-by: Jose R. Guzman Mosqueda <jose.r.guzman.mosqueda@intel.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/tc_util.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index dc2b70f..aa6de24 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -250,18 +250,19 @@ void print_rate(char *buf, int len, __u64 rate)
 	extern int use_iec;
 	unsigned long kilo = use_iec ? 1024 : 1000;
 	const char *str = use_iec ? "i" : "";
-	int i = 0;
 	static char *units[5] = {"", "K", "M", "G", "T"};
+	int i;
 
 	rate <<= 3; /* bytes/sec -> bits/sec */
 
-	for (i = 0; i < ARRAY_SIZE(units); i++)  {
+	for (i = 0; i < ARRAY_SIZE(units) - 1; i++)  {
 		if (rate < kilo)
 			break;
 		if (((rate % kilo) != 0) && rate < 1000*kilo)
 			break;
 		rate /= kilo;
 	}
+
 	snprintf(buf, len, "%.0f%s%sbit", (double)rate, units[i], str);
 }
 
-- 
1.9.3
