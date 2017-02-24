From: Petr Vorel <pvorel@suse.cz>
Subject: [PATCH 1/1] color: use "light" colors for dark background
Date: Fri, 24 Feb 2017 11:13:12 +0100
Message-ID: <20170224101312.31538-1-pvorel@suse.cz>
Cc: Petr Vorel <pvorel@suse.cz>, Mathias Nyman <m.nyman@iki.fi>,
        Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45038 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751257AbdBXKNd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Feb 2017 05:13:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

COLORFGBG environment variable is used to detect dark background.

Idea and a bit of code is borrowed from Vim, thanks.

Signed-off-by: Petr Vorel <pvorel@suse.cz>
---
Colors are nice, but the ones chosen aren't suitable for dark background.
COLORFGBG environment variable is used in some libraries and software (e.g.
ncurses, Vim). COLORFGBG is set by various terminal emulators (e.g. konsole,
rxvt and rxvt-unicode).

Chosen colors are questionable. Best solution would be also allow user to
redefine colors, like ls does with LS_COLORS or grep with GREP_COLORS. But that
is maybe overkill.
---
 include/color.h |  1 +
 lib/color.c     | 43 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/include/color.h b/include/color.h
index c1c29831..43190db4 100644
--- a/include/color.h
+++ b/include/color.h
@@ -12,6 +12,7 @@ enum color_attr {
 };
 
 void enable_color(void);
+void set_background(void);
 int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...);
 enum color_attr ifa_family_color(__u8 ifa_family);
 enum color_attr oper_state_color(__u8 state);
diff --git a/lib/color.c b/lib/color.c
index 95596be2..69375b26 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -1,5 +1,7 @@
 #include <stdio.h>
 #include <stdarg.h>
+#include <stdlib.h>
+#include <string.h>
 #include <sys/socket.h>
 #include <sys/types.h>
 #include <linux/if.h>
@@ -14,6 +16,12 @@ enum color {
 	C_MAGENTA,
 	C_CYAN,
 	C_WHITE,
+	C_LIGHT_RED,
+	C_LIGHT_GREEN,
+	C_LIGHT_YELLOW,
+	C_LIGHT_BLUE,
+	C_LIGHT_MAGENTA,
+	C_LIGHT_CYAN,
 	C_CLEAR
 };
 
@@ -25,25 +33,58 @@ static const char * const color_codes[] = {
 	"\e[35m",
 	"\e[36m",
 	"\e[37m",
+	"\e[1;31m",
+	"\e[1;32m",
+	"\e[1;33m",
+	"\e[1;34m",
+	"\e[1;35m",
+	"\e[1;36m",
 	"\e[0m",
 	NULL,
 };
 
 static enum color attr_colors[] = {
+	/* light background */
 	C_CYAN,
 	C_YELLOW,
 	C_MAGENTA,
 	C_BLUE,
 	C_GREEN,
 	C_RED,
+	C_CLEAR,
+
+	/* dark background */
+	C_LIGHT_CYAN,
+	C_LIGHT_YELLOW,
+	C_LIGHT_MAGENTA,
+	C_LIGHT_BLUE,
+	C_LIGHT_GREEN,
+	C_LIGHT_RED,
 	C_CLEAR
 };
 
+static int is_dark_bg;
 static int color_is_enabled;
 
 void enable_color(void)
 {
 	color_is_enabled = 1;
+	set_background();
+}
+
+void set_background(void)
+{
+	char *p = getenv("COLORFGBG");
+
+	/*
+	 * COLORFGBG environment variable usually contains either two or three
+	 * values separated by semicolons; we want the last value in either case.
+	 * If this value is 0-6 or 8, background is dark.
+	 */
+	if (p && (p = (char *)strrchr(p, ';')) != NULL
+		&& ((p[1] >= '0' && p[1] <= '6') || p[1] == '8')
+		&& p[2] == '\0')
+		is_dark_bg = 1;
 }
 
 int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
@@ -58,7 +99,7 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 		goto end;
 	}
 
-	ret += fprintf(fp, "%s", color_codes[attr_colors[attr]]);
+	ret += fprintf(fp, "%s", color_codes[attr_colors[is_dark_bg ? attr + 7 : attr]]);
 	ret += vfprintf(fp, fmt, args);
 	ret += fprintf(fp, "%s", color_codes[C_CLEAR]);
 
-- 
2.11.0
