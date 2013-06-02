From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] get_rate: detect 32bit overflows
Date: Sun, 02 Jun 2013 11:51:23 -0700
Message-ID: <1370199083.24311.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:49432 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755422Ab3FBSvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 14:51:25 -0400
Received: by mail-pb0-f50.google.com with SMTP id wy17so4694306pbc.37
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 11:51:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current rate limit is 34.359.738.360 bit per second, and
unfortunately 40Gbps links are above it.

overflows in get_rate() are currently not detected, and some
users are confused. Let's detect this and complain.

Note that some qdisc are ready to get extended range, but this will
need additional attributes and new iproute2

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/tc_util.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 8e62a01..0a25250 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -146,21 +146,26 @@ static const struct rate_suffix {
 int get_rate(unsigned *rate, const char *str)
 {
 	char *p;
-	double bps = strtod(str, &p);
+	long long bps = strtoll(str, &p, 0);
 	const struct rate_suffix *s;
 
 	if (p == str)
 		return -1;
 
+	bps /= 8; /* -> bytes per second */
 	if (*p == '\0') {
-		*rate = bps / 8.;	/* assume bits/sec */
+common:
+		*rate = bps;
+		/* detect if an overflow happened */
+		if (*rate != bps)
+			return -1;
 		return 0;
 	}
 
 	for (s = suffixes; s->name; ++s) {
 		if (strcasecmp(s->name, p) == 0) {
-			*rate = (bps * s->scale) / 8.;
-			return 0;
+			bps *= s->scale;
+			goto common;
 		}
 	}
 
