From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 iproute2] get_rate: detect 32bit overflows
Date: Sun, 02 Jun 2013 14:36:48 -0700
Message-ID: <1370209008.24311.91.camel@edumazet-glaptop>
References: <1370199083.24311.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:57555 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943Ab3FBVgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 17:36:50 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so4771562pbc.31
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 14:36:49 -0700 (PDT)
In-Reply-To: <1370199083.24311.43.camel@edumazet-glaptop>
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
v2: divide by 8 only at the right time

 tc/tc_util.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 8e62a01..8ca9d4e 100644
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
 
 	if (*p == '\0') {
-		*rate = bps / 8.;	/* assume bits/sec */
+common:
+		bps /= 8; /* -> bytes per second */
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
 
