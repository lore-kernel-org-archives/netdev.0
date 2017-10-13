From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH iproute2 v2 2/4] color: Fix another ip segfault when using --color switch
Date: Fri, 13 Oct 2017 15:57:17 +0200
Message-ID: <20171013135719.18450-3-petr.vorel@gmail.com>
References: <20171013135719.18450-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>,
        Julien Fortin <julien@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33943 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753374AbdJMN5l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:57:41 -0400
Received: by mail-wr0-f193.google.com with SMTP id l1so991927wrc.1
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 06:57:40 -0700 (PDT)
In-Reply-To: <20171013135719.18450-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 959f1428 ("color: add new COLOR_NONE and disable_color function")
introducing color enum COLOR_NONE, which is not only duplicite of
COLOR_CLEAR, but also caused segfault, when running ip with --color
switch, as 'attr + 8' in color_fprintf() access array item out of
bounds. Thus removing it and restoring "magic" offset + 7.

Reproduce with:
$ ip -c a

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
 include/color.h | 1 -
 lib/color.c     | 4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/color.h b/include/color.h
index 1cd6f7d2..c183ef79 100644
--- a/include/color.h
+++ b/include/color.h
@@ -2,7 +2,6 @@
 #define __COLOR_H__ 1
 
 enum color_attr {
-	COLOR_NONE,
 	COLOR_IFNAME,
 	COLOR_MAC,
 	COLOR_INET,
diff --git a/lib/color.c b/lib/color.c
index 79d5e289..05afcb21 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -104,13 +104,13 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 
 	va_start(args, fmt);
 
-	if (!color_is_enabled || attr == COLOR_NONE) {
+	if (!color_is_enabled || attr == COLOR_CLEAR) {
 		ret = vfprintf(fp, fmt, args);
 		goto end;
 	}
 
 	ret += fprintf(fp, "%s",
-		       color_codes[attr_colors[is_dark_bg ? attr + 8 : attr]]);
+		       color_codes[attr_colors[is_dark_bg ? attr + 7 : attr]]);
 	ret += vfprintf(fp, fmt, args);
 	ret += fprintf(fp, "%s", color_codes[C_CLEAR]);
 
-- 
2.14.2
