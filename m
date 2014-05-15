From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 2/3] iproute2: utils: change hexstring_n2a and hexstring_a2n to do not work with ":"
Date: Thu, 15 May 2014 15:10:21 +0200
Message-ID: <1400159422-11797-3-git-send-email-jiri@resnulli.us>
References: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, mschmidt@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:62672 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbaEONKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 09:10:34 -0400
Received: by mail-lb0-f181.google.com with SMTP id u14so778070lbd.12
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 06:10:33 -0700 (PDT)
In-Reply-To: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 lib/utils.c | 46 +++++++++++++---------------------------------
 1 file changed, 13 insertions(+), 33 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 4e9c719..e9e1040 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -743,10 +743,6 @@ char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen)
 		sprintf(ptr, "%02x", str[i]);
 		ptr += 2;
 		blen -= 2;
-		if (i != len-1 && blen > 1) {
-			*ptr++ = ':';
-			blen--;
-		}
 	}
 	return buf;
 }
@@ -754,38 +750,22 @@ char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen)
 __u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
 {
 	int cnt = 0;
+	char *endptr;
 
-	for (;;) {
-		unsigned acc;
-		char ch;
-
-		acc = 0;
-
-		while ((ch = *str) != ':' && ch != 0) {
-			if (ch >= '0' && ch <= '9')
-				ch -= '0';
-			else if (ch >= 'a' && ch <= 'f')
-				ch -= 'a'-10;
-			else if (ch >= 'A' && ch <= 'F')
-				ch -= 'A'-10;
-			else
-				return NULL;
-			acc = (acc<<4) + ch;
-			str++;
-		}
-
-		if (acc > 255)
+	if (strlen(str) % 2)
+		return NULL;
+	while (cnt < blen && strlen(str) > 1) {
+		unsigned int tmp;
+		char tmpstr[3];
+
+		strncpy(tmpstr, str, 2);
+		tmpstr[2] = '\0';
+		tmp = strtoul(tmpstr, &endptr, 16);
+		if (errno != 0 || tmp > 0xFF || *endptr != '\0')
 			return NULL;
-		if (cnt < blen) {
-			buf[cnt] = acc;
-			cnt++;
-		}
-		if (ch == 0)
-			break;
-		++str;
+		buf[cnt++] = tmp;
+		str += 2;
 	}
-	if (cnt < blen)
-		memset(buf+cnt, 0, blen-cnt);
 	return buf;
 }
 
-- 
1.9.0
