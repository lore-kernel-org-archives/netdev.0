From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 iproute2] get_rate: detect 32bit overflows
Date: Mon, 03 Jun 2013 08:51:33 -0700
Message-ID: <1370274693.24311.154.camel@edumazet-glaptop>
References: <1370199083.24311.43.camel@edumazet-glaptop>
	 <1370209008.24311.91.camel@edumazet-glaptop>
	 <1370270231.1918.10.camel@bwh-desktop.uk.level5networks.com>
	 <1370272783.24311.148.camel@edumazet-glaptop>
	 <1370273807.1918.20.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f178.google.com ([209.85.160.178]:36790 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758778Ab3FCP6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:58:55 -0400
Received: by mail-gh0-f178.google.com with SMTP id g15so244244ghb.37
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 08:58:55 -0700 (PDT)
In-Reply-To: <1370273807.1918.20.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 16:36 +0100, Ben Hutchings wrote:

> Oops, I read this as being strtol() currently, not strtod().  Currently
> '1.5gbit' will work, but this change will break that.  So I think you
> need to keep bps as a double.

Arg

> Then here I think the check should be *rate != floor(bps), i.e. accept
> rounding down of a non-integer number of bytes but any other change is
> assumed to be overflow.

Thanks Ben, here is v4 then ;)

[PATCH v4] get_rate: detect 32bit overflows

Current rate limit is 34.359.738.360 bit per second, and
unfortunately 40Gbps links are above it.

overflows in get_rate() are currently not detected, and some
users are confused. Let's detect this and complain.

Note that some qdisc are ready to get extended range, but this will
need additional attributes and new iproute2

With help from Ben Hutchings

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/tc_util.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 8e62a01..8114c97 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -152,19 +152,23 @@ int get_rate(unsigned *rate, const char *str)
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
+	if (*rate != floor(bps))
+		return -1;
+	return 0;
 }
 
 void print_rate(char *buf, int len, __u32 rate)
