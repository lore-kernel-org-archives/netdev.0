From: Joe Perches <joe@perches.com>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros,
 recursive vsnprintf
Date: Sat, 06 Mar 2010 15:35:54 -0800
Message-ID: <1267918554.849.89.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <20100304143837.af39845d.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
	 <1267911399.849.39.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
	 <1267914654.849.81.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
	 <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1480 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352Ab0CFXf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Mar 2010 18:35:57 -0500
In-Reply-To: <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-03-06 at 14:57 -0800, Linus Torvalds wrote:
> 
> On Sat, 6 Mar 2010, Linus Torvalds wrote:
> > 
> > I'm not convinced. We pass that 'printf_spec' around a lot, including 
> > nesting. Not as a pointer, either.
> 
> Btw, I wonder if those fields could become bitfields, or 'unsigned char' 
> etc. That printf_spec really is unnecessarily big. It should _easily_ fit 
> in a single register on a 64-bit platform, possibly even a 32-bit one (we 
> could limit field width and precision to 5 bits, for example)

I believe 32 bits isn't possible.

type:6
flags:8
width:8
base:6
precision:6
qualifier:8

So maybe something like this:

 lib/vsprintf.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)
---
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index af4aaa6..fdee7f7 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -408,12 +408,12 @@ enum format_type {
 };
 
 struct printf_spec {
-	enum format_type	type;
-	int			flags;		/* flags to number() */
-	int			field_width;	/* width of output field */
-	int			base;
-	int			precision;	/* # of digits/chars */
-	int			qualifier;
+	u16	type;
+	s16	field_width;	/* width of output field */
+	u8	flags;		/* flags to number() */
+	u8	base;
+	s8	precision;	/* # of digits/chars */
+	u8	qualifier;
 };
 
 static char *number(char *buf, char *end, unsigned long long num,
@@ -1333,7 +1333,7 @@ int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
 			break;
 
 		case FORMAT_TYPE_NRCHARS: {
-			int qualifier = spec.qualifier;
+			u8 qualifier = spec.qualifier;
 
 			if (qualifier == 'l') {
 				long *ip = va_arg(args, long *);
@@ -1619,7 +1619,7 @@ do {									\
 
 		case FORMAT_TYPE_NRCHARS: {
 			/* skip %n 's argument */
-			int qualifier = spec.qualifier;
+			u8 qualifier = spec.qualifier;
 			void *skip_arg;
 			if (qualifier == 'l')
 				skip_arg = va_arg(args, long *);
@@ -1885,7 +1885,9 @@ int vsscanf(const char *buf, const char *fmt, va_list args)
 	char *next;
 	char digit;
 	int num = 0;
-	int qualifier, base, field_width;
+	u8 qualifier;
+	u8 base;
+	s16 field_width;
 	bool is_sign;
 
 	while (*fmt && *str) {
@@ -1963,7 +1965,7 @@ int vsscanf(const char *buf, const char *fmt, va_list args)
 		{
 			char *s = (char *)va_arg(args, char *);
 			if (field_width == -1)
-				field_width = INT_MAX;
+				field_width = SHORT_MAX;
 			/* first, skip leading white space in buffer */
 			str = skip_spaces(str);
 



