From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 3/3] drivers: isdn: get rid of custom strtoul()
Date: Thu, 15 Jul 2010 15:37:20 +0300
Message-ID: <1279197440-6585-3-git-send-email-andy.shevchenko@gmail.com>
References: <1279197440-6585-1-git-send-email-andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Tilman Schmidt <tilman@imap.cc>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49024 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756081Ab0GOMhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 08:37:43 -0400
In-Reply-To: <1279197440-6585-1-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were two methods isdn_gethex() and isdn_getnum() which are custom
implementations of strtoul(). Get rid of them in regard to
strict_strtoul() kernel's function.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Hansjoerg Lipp <hjlipp@web.de>
Cc: Tilman Schmidt <tilman@imap.cc>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: gigaset307x-common@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 drivers/isdn/gigaset/ev-layer.c |   80 ++++++++++-----------------------------
 1 files changed, 20 insertions(+), 60 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index a230ba7..a141876 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -385,64 +385,18 @@ static const struct zsau_resp_t {
 	{NULL,				ZSAU_UNKNOWN}
 };
 
-/*
- * Get integer from char-pointer
- */
-static int isdn_getnum(char *p)
-{
-	int v = -1;
-
-	gig_dbg(DEBUG_EVENT, "string: %s", p);
-
-	while (*p >= '0' && *p <= '9')
-		v = ((v < 0) ? 0 : (v * 10)) + (int) ((*p++) - '0');
-	if (*p)
-		v = -1; /* invalid Character */
-	return v;
-}
-
-/*
- * Get integer from char-pointer
- */
-static int isdn_gethex(char *p)
-{
-	int v = 0;
-	int c;
-
-	gig_dbg(DEBUG_EVENT, "string: %s", p);
-
-	if (!*p)
-		return -1;
-
-	do {
-		if (v > (INT_MAX - 15) / 16)
-			return -1;
-		c = *p;
-		if (c >= '0' && c <= '9')
-			c -= '0';
-		else if (c >= 'a' && c <= 'f')
-			c -= 'a' - 10;
-		else if (c >= 'A' && c <= 'F')
-			c -= 'A' - 10;
-		else
-			return -1;
-		v = v * 16 + c;
-	} while (*++p);
-
-	return v;
-}
-
 /* retrieve CID from parsed response
  * returns 0 if no CID, -1 if invalid CID, or CID value 1..65535
  */
 static int cid_of_response(char *s)
 {
-	int cid;
+	unsigned long cid;
+	int rc;
 
 	if (s[-1] != ';')
 		return 0;	/* no CID separator */
-	cid = isdn_getnum(s);
-	if (cid < 0)
+	rc = strict_strtoul(s, 10, &cid);
+	if (rc)
 		return 0;	/* CID not numeric */
 	if (cid < 1 || cid > 65535)
 		return -1;	/* CID out of range */
@@ -612,21 +566,27 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		case RT_ZCAU:
 			event->parameter = -1;
 			if (curarg + 1 < params) {
-				i = isdn_gethex(argv[curarg]);
-				j = isdn_gethex(argv[curarg + 1]);
-				if (i >= 0 && i < 256 && j >= 0 && j < 256)
-					event->parameter = (unsigned) i << 8
-							   | j;
-				curarg += 2;
+				unsigned long type, value;
+
+				i = strict_strtoul(argv[curarg++], 16, &type);
+				j = strict_strtoul(argv[curarg++], 16, &value);
+
+				if (i == 0 && type < 256 &&
+				    j == 0 && value < 256)
+					event->parameter = (type << 8) | value;
 			} else
 				curarg = params - 1;
 			break;
 		case RT_NUMBER:
+			event->parameter = -1;
 			if (curarg < params) {
-				event->parameter = isdn_getnum(argv[curarg]);
-				++curarg;
-			} else
-				event->parameter = -1;
+				unsigned long res;
+				int rc;
+
+				rc = strict_strtoul(argv[curarg++], 10, &res);
+				if (rc == 0)
+					event->parameter = res;
+			}
 			gig_dbg(DEBUG_EVENT, "parameter==%d", event->parameter);
 			break;
 		}
-- 
1.7.1.1

