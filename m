From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH iproute2 1/1] color: Fix ip segfault in color_fprintf() when using --color switch
Date: Sun,  8 Oct 2017 16:38:47 +0200
Message-ID: <20171008143847.21699-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>,
        Julien Fortin <julien@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37287 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753623AbdJHOi7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 10:38:59 -0400
Received: by mail-wm0-f67.google.com with SMTP id r68so5118985wmr.4
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 07:38:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes two regressions:

Commit 959f1428 ("color: add new COLOR_NONE and disable_color function")
caused segfault, when running ip with --color switch, as 'attr + 8' in
color_fprintf() access array item out of bounds.
Changing latter value of ternar operator in attr_colors[] index is for
restoring the same colors.
Reproduce the bug with:
$ ip -c a

Commit d0e72011 ("ip: ipaddress.c: add support for json output")
introduced passing -1 as enum color_attr. This is not only wrong as no
color_attr has value -1, but also causes another segfault in color_fprintf()
on this setup as there is no item with index -1 in array of enum attr_colors[].
Using 0 is valid option.

Reproduce the bug with:
$ COLORFGBG='0;15' ip -c a

NOTE: COLORFGBG is environmental variable used for defining whether user
has light or dark background.
COLORFGBG="0;15" is used to ask for color set suitable for light background,
COLORFGBG="15;0" is used to ask for color set suitable for dark background.

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
 include/json_print.h | 2 +-
 lib/color.c          | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/json_print.h b/include/json_print.h
index b6ce1f9f..2f3f07c8 100644
--- a/include/json_print.h
+++ b/include/json_print.h
@@ -53,7 +53,7 @@ void close_json_array(enum output_type type, const char *delim);
 					     const char *fmt,		\
 					     type value)		\
 	{								\
-		print_color_##type_name(t, -1, key, fmt, value);	\
+		print_color_##type_name(t, 0, key, fmt, value);	\
 	}
 _PRINT_FUNC(int, int);
 _PRINT_FUNC(bool, bool);
diff --git a/lib/color.c b/lib/color.c
index 79d5e289..e597798f 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -110,7 +110,7 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 	}
 
 	ret += fprintf(fp, "%s",
-		       color_codes[attr_colors[is_dark_bg ? attr + 8 : attr]]);
+		       color_codes[attr_colors[is_dark_bg ? attr + 6 : attr - 1]]);
 	ret += vfprintf(fp, fmt, args);
 	ret += fprintf(fp, "%s", color_codes[C_CLEAR]);
 
-- 
2.14.2
