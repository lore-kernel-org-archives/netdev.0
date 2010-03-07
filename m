From: Joe Perches <joe@perches.com>
Subject: [PATCH] vsprintf.c: Reduce sizeof struct printf_spec from 24 to 8
 bytes
Date: Sat, 06 Mar 2010 17:10:14 -0800
Message-ID: <1267924214.1937.12.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <20100304143837.af39845d.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
	 <1267911399.849.39.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
	 <1267914654.849.81.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
	 <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
	 <1267918554.849.89.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
	 <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>
	 <alpine.LFD.2.00.1003061556420.23804@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003061556420.23804@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-03-06 at 15:58 -0800, Linus Torvalds wrote:
> And no, I guess we don't really need to make it 32-bit. Fitting in 64 bits 
> would already be a big improvement over what we have now.

Reducing the size of struct printf_spec is a good thing
because multiple instances are commonly passed on stack.

It's possible for type to be u8 and field_width to be s8,
but this is likely small enough for now.

Signed-off-by: Joe Perches <joe@perches.com>
---
 lib/vsprintf.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

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
 
