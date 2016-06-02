From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils v2] ping: always accept . delimiter with -i number parsing
Date: Thu,  2 Jun 2016 00:46:54 -0400
Message-ID: <1464842814-30690-1-git-send-email-vapier@gentoo.org>
References: <1464752905-10347-6-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:57118 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978AbcFBEq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 00:46:58 -0400
In-Reply-To: <1464752905-10347-6-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always allow #.# format for the -i flag even when the current locale
uses a different separator.  Locale de_DE which uses #,# normally.

Simple testcase:
$ make USE_IDN=1
$ LANG=de_DE.UTF8 ./ping -i 0.5 localhost
$ LANG=de_DE.UTF8 ./ping -i 0,5 localhost

Reported-by: Sergey Fionov <fionov@gmail.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 ping_common.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/ping_common.c b/ping_common.c
index 62f53a6..6054a91 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -269,11 +269,28 @@ void common_options(int ch)
 		double dbl;
 		char *ep;
 
+#ifdef USE_IDN
+		int try_c_loc = 0;
+ retry_c_loc:
+#endif
+
 		errno = 0;
 		dbl = strtod(optarg, &ep);
 
+#ifdef USE_IDN
+		if (try_c_loc)
+			setlocale(LC_ALL, "");
+#endif
+
 		if (errno || *ep != '\0' ||
 		    !finite(dbl) || dbl < 0.0 || dbl >= (double)INT_MAX / 1000 - 1.0) {
+#ifdef USE_IDN
+			if (!try_c_loc) {
+				try_c_loc = 1;
+				setlocale(LC_ALL, "C");
+				goto retry_c_loc;
+			}
+#endif
 			fprintf(stderr, "ping: bad timing interval\n");
 			exit(2);
 		}
-- 
2.8.2
