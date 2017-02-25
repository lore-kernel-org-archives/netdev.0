From: Mathias Nyman <m.nyman@iki.fi>
Subject: Re: [PATCH 1/1] color: use "light" colors for dark background
Date: Sat, 25 Feb 2017 19:29:58 +0200
Message-ID: <20170225172958.GA26279@iki.fi>
References: <20170224101312.31538-1-pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org,
        Yegor Yefremov <yegorslists@googlemail.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Petr Vorel <pvorel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:58304 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751356AbdBYRaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Feb 2017 12:30:02 -0500
Content-Disposition: inline
In-Reply-To: <20170224101312.31538-1-pvorel@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-02-24 11:13+0100, Petr Vorel wrote:
>COLORFGBG environment variable is used to detect dark background.
>
>Idea and a bit of code is borrowed from Vim, thanks.
>
>Signed-off-by: Petr Vorel <pvorel@suse.cz>
>---
>Colors are nice, but the ones chosen aren't suitable for dark background.

Yea, I admit, the original color palette is kind of horrendous. I
wouldn't say the current colors are suitable for a light background
either.

I propose you just replace the current colors with their bold
variants, and leave the background hue guessing out all together. That
would be an all-round improvement for everyone.

I'll include some comments on this patch-set anyway, as I had a look
at it.

>COLORFGBG environment variable is used in some libraries and software (e.g.
>ncurses, Vim). COLORFGBG is set by various terminal emulators (e.g. konsole,
>rxvt and rxvt-unicode).
>
>Chosen colors are questionable. Best solution would be also allow user to
>redefine colors, like ls does with LS_COLORS or grep with GREP_COLORS. But that
>is maybe overkill.
>---
> include/color.h |  1 +
> lib/color.c     | 43 ++++++++++++++++++++++++++++++++++++++++++-
> 2 files changed, 43 insertions(+), 1 deletion(-)
>
>diff --git a/include/color.h b/include/color.h
>index c1c29831..43190db4 100644
>--- a/include/color.h
>+++ b/include/color.h
>@@ -12,6 +12,7 @@ enum color_attr {
> };
>
> void enable_color(void);
>+void set_background(void);
> int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...);
> enum color_attr ifa_family_color(__u8 ifa_family);
> enum color_attr oper_state_color(__u8 state);
>diff --git a/lib/color.c b/lib/color.c
>index 95596be2..69375b26 100644
>--- a/lib/color.c
>+++ b/lib/color.c
>@@ -1,5 +1,7 @@
> #include <stdio.h>
> #include <stdarg.h>
>+#include <stdlib.h>
>+#include <string.h>
> #include <sys/socket.h>
> #include <sys/types.h>
> #include <linux/if.h>
>@@ -14,6 +16,12 @@ enum color {
> 	C_MAGENTA,
> 	C_CYAN,
> 	C_WHITE,
>+	C_LIGHT_RED,
>+	C_LIGHT_GREEN,
>+	C_LIGHT_YELLOW,
>+	C_LIGHT_BLUE,
>+	C_LIGHT_MAGENTA,
>+	C_LIGHT_CYAN,

You have missed to add C_LIGHT_WHITE here.

The naming is also confusing, because while you say "light", the
colors defined below are actually _bold_. They may have an lightening
effect, but this naming is just confusing in the code.

> 	C_CLEAR
> };
>
>@@ -25,25 +33,58 @@ static const char * const color_codes[] = {
> 	"\e[35m",
> 	"\e[36m",
> 	"\e[37m",
>+	"\e[1;31m",
>+	"\e[1;32m",
>+	"\e[1;33m",
>+	"\e[1;34m",
>+	"\e[1;35m",
>+	"\e[1;36m",

You have also missed to add the white color ("\e[1;37m",) here as
well.

> 	"\e[0m",
> 	NULL,
> };
>
> static enum color attr_colors[] = {
>+	/* light background */
> 	C_CYAN,
> 	C_YELLOW,
> 	C_MAGENTA,
> 	C_BLUE,
> 	C_GREEN,
> 	C_RED,
>+	C_CLEAR,
>+
>+	/* dark background */
>+	C_LIGHT_CYAN,
>+	C_LIGHT_YELLOW,
>+	C_LIGHT_MAGENTA,
>+	C_LIGHT_BLUE,
>+	C_LIGHT_GREEN,
>+	C_LIGHT_RED,
> 	C_CLEAR
> };
>
>+static int is_dark_bg;
> static int color_is_enabled;
>
> void enable_color(void)
> {
> 	color_is_enabled = 1;
>+	set_background();
>+}
>+
>+void set_background(void)

The function name is a bit misleading. Only after reading the whole
function did I understand that what you do here is choose the color
palette - not set the background.

>+{
>+	char *p = getenv("COLORFGBG");
>+
>+	/*
>+	 * COLORFGBG environment variable usually contains either two or three
>+	 * values separated by semicolons; we want the last value in either case.
>+	 * If this value is 0-6 or 8, background is dark.
>+	 */
>+	if (p && (p = (char *)strrchr(p, ';')) != NULL
>+		&& ((p[1] >= '0' && p[1] <= '6') || p[1] == '8')
>+		&& p[2] == '\0')
>+		is_dark_bg = 1;
> }
>
> int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
>@@ -58,7 +99,7 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
> 		goto end;
> 	}
>
>-	ret += fprintf(fp, "%s", color_codes[attr_colors[attr]]);
>+	ret += fprintf(fp, "%s", color_codes[attr_colors[is_dark_bg ? attr + 7 : attr]]);
> 	ret += vfprintf(fp, fmt, args);
> 	ret += fprintf(fp, "%s", color_codes[C_CLEAR]);
>
>-- 
>2.11.0
>
