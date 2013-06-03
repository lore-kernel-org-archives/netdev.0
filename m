From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 iproute2] get_rate: detect 32bit overflows
Date: Mon, 03 Jun 2013 08:19:43 -0700
Message-ID: <1370272783.24311.148.camel@edumazet-glaptop>
References: <1370199083.24311.43.camel@edumazet-glaptop>
	 <1370209008.24311.91.camel@edumazet-glaptop>
	 <1370270231.1918.10.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:64386 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab3FCPTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:19:46 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so5855698pbc.31
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 08:19:46 -0700 (PDT)
In-Reply-To: <1370270231.1918.10.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 15:37 +0100, Ben Hutchings wrote:

> This would be more understandable without a goto.  I think this ordering
> would work:

Yeah you're right, thanks !

[PATCH v3] get_rate: detect 32bit overflows

Current rate limit is 34.359.738.360 bit per second, and
unfortunately 40Gbps links are above it.

overflows in get_rate() are currently not detected, and some
users are confused. Let's detect this and complain.

Note that some qdisc are ready to get extended range, but this will
need additional attributes and new iproute2

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/tc_util.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 8e62a01..912216c 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -146,25 +146,29 @@ static const struct rate_suffix {
 int get_rate(unsigned *rate, const char *str)
 {
 	char *p;
-	double bps = strtod(str, &p);
+	long long bps = strtoll(str, &p, 0);
 	const struct rate_suffix *s;
 
 	if (p == str)
 		return -1;
 
-	if (*p == '\0') {
-		*rate = bps / 8.;	/* assume bits/sec */
-		return 0;
-	}
-
 	for (s = suffixes; s->name; ++s) {
 		if (strcasecmp(s->name, p) == 0) {
-			*rate = (bps * s->scale) / 8.;
-			return 0;
+			bps *= s->scale;
+			p += strlen(p);
+			break;
 		}
 	}
 
-	return -1;
+	if (*p)
+		return -1; /* unknown suffix */
+
+	bps /= 8; /* -> bytes per second */
+	*rate = bps;
+	/* detect if an overflow happened */
+	if (*rate != bps)
+		return -1;
+	return 0;
 }
 
 void print_rate(char *buf, int len, __u32 rate)
