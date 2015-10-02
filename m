From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH iproute2] batch: support quoted strings
Date: Fri,  2 Oct 2015 11:59:37 +0200
Message-ID: <1443779977-27227-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:37318 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbJBKIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 06:08:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support quoting strings with " or ' in an iproute2 batch file.

Enables to configure empty crypto keys (for ESP-null) or keys with
spaces:

    xfrm state add src 1.1.1.1 dst 2.2.2.2 proto ah spi 0x1 \
        mode tunnel auth hmac(sha1) "r4ezR/@kd6'749f2 6zf$"

    xfrm state add src 5.5.5.5 dst 2.2.2.2 proto esp spi 0x2 \
        mode tunnel enc cipher_null ""

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 lib/utils.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index 29b4f548acf3..107e3f5766d3 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -914,12 +914,31 @@ int makeargs(char *line, char *argv[], int maxargs)
 	char *cp;
 	int argc = 0;
 
-	for (cp = strtok(line, ws); cp; cp = strtok(NULL, ws)) {
+	for (cp = line + strspn(line, ws); *cp; cp += strspn(cp, ws)) {
 		if (argc >= (maxargs - 1)) {
 			fprintf(stderr, "Too many arguments to command\n");
 			exit(1);
 		}
+
+		/* word begins with quote */
+		if (*cp == '\'' || *cp == '"') {
+			char quote = *cp++;
+
+			argv[argc++] = cp;
+			/* find ending quote */
+			cp = strchr(cp, quote);
+			if (cp == NULL) {
+				fprintf(stderr, "Unterminated quoted string\n");
+				exit(1);
+			}
+			*cp++ = 0;
+			continue;
+		}
+
 		argv[argc++] = cp;
+		/* find end of word */
+		cp += strcspn(cp, ws);
+		*cp++ = 0;
 	}
 	argv[argc] = NULL;
 
-- 
2.1.4
