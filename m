From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 18:23:11 +0100
Message-ID: <1203960191.13162.118.camel@johannes.berg>
References: <1203589042.17534.145.camel@johannes.berg>
	 <1203616486.7181.269.camel@localhost> <47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
	 <1203933228.13162.58.camel@johannes.berg>
	 (sfid-20080225_100222_438832_CD58CB90)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, joe@perches.com, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:54343 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027AbYBYRZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 12:25:32 -0500
In-Reply-To: <1203933228.13162.58.camel@johannes.berg> (sfid-20080225_100222_438832_CD58CB90)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-02-25 at 10:53 +0100, Johannes Berg wrote:
> On Sat, 2008-02-23 at 20:02 -0800, David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Thu, 21 Feb 2008 19:00:03 +0100
> > 
> > > And adds back the overhead of two completely unnecessary
> > > function calls to the VLAN fastpath. How about just
> > > stopping this idiocy and reverting the appropriate patches
> > > to bring back MAC_FMT and use it where appropriate?
> > 
> > Agreed, I'll do that.
> 
> Maybe we should just add a new printf modifier like %M for MAC
> addresses? Then we could use sprintf, snprintf, printk and whatever we
> please without any of the macro stuff...

I have something like this in mind. Might even be faster than using the
MAC_FMT/MAC_ARG stuff because it's done in a single loop rather than
invoking the hex digit printing 6 times.


From: Johannes Berg <johannes@sipsolutions.net>
Subject: MAC printing with %M/%m

We've been through two ways to print MAC addresses to the kernel
logs/buffers/whatever.

Until recently, we had

#define MAC_FMT		"%.2x:%.2x:%.2x:..."
#define MAC_ARG(m)	(m)[0], (m)[1], (m)[2], ...

printk("bla bla " MAC_FMT "\n", MAC_ARG(mac));

This is fairly ugly and was found to lead to quite long strings
embedded in the kernel, all the %.2x stuff.


Recently, we changed to using print_mac():

DECLARE_MAC_BUF(mbuf);
printk("bla bla %s\n", print_mac(mbuf, mac));

This was, however, found to force the compiler to emit print_mac()
function calls in fast paths even when debugging was turned off.


Here's my take on it, putting it right into the vsnprintf code.
It allows you to write

printk("bla bla %m\n", mac);

without any further function calls or local variables.

The only problem I see with using 'm' and 'M' is that 'm' is already
defined by glibc to print strerror(errno).

This patch doesn't contain any conversion yet but that could happen
gradually, starting with the fast paths.

I've tested this code in userspace with a number of MAC addresses
and various output buffer limits.

Field length specifiers are allowed and treated as if the already
printed MAC address was given to a %s specifier, ie.
	%-20m	is like %-20s
etc.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 lib/vsprintf.c |   47 ++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 42 insertions(+), 5 deletions(-)

--- everything.orig/lib/vsprintf.c	2008-02-25 17:31:56.000000000 +0100
+++ everything/lib/vsprintf.c	2008-02-25 17:57:34.000000000 +0100
@@ -366,11 +366,11 @@ static noinline char* put_dec(char *buf,
 #define SMALL	32		/* Must be 32 == 0x20 */
 #define SPECIAL	64		/* 0x */
 
+/* we are called with base 8, 10 or 16, only, thus don't need "G..."  */
+static const char hexdigits[16] = "0123456789ABCDEF"; /* "GHIJKLMNOPQRSTUVWXYZ"; */
+
 static char *number(char *buf, char *end, unsigned long long num, int base, int size, int precision, int type)
 {
-	/* we are called with base 8, 10 or 16, only, thus don't need "G..."  */
-	static const char digits[16] = "0123456789ABCDEF"; /* "GHIJKLMNOPQRSTUVWXYZ"; */
-
 	char tmp[66];
 	char sign;
 	char locase;
@@ -408,7 +408,7 @@ static char *number(char *buf, char *end
 		tmp[i++] = '0';
 	/* Generic code, for any base:
 	else do {
-		tmp[i++] = (digits[do_div(num,base)] | locase);
+		tmp[i++] = (hexdigits[do_div(num,base)] | locase);
 	} while (num != 0);
 	*/
 	else if (base != 10) { /* 8 or 16 */
@@ -416,7 +416,7 @@ static char *number(char *buf, char *end
 		int shift = 3;
 		if (base == 16) shift = 4;
 		do {
-			tmp[i++] = (digits[((unsigned char)num) & mask] | locase);
+			tmp[i++] = (hexdigits[((unsigned char)num) & mask] | locase);
 			num >>= shift;
 		} while (num);
 	} else { /* base 10 */
@@ -621,6 +621,43 @@ int vsnprintf(char *buf, size_t size, co
 				}
 				continue;
 
+
+			case 'm':
+				flags |= SMALL;
+			case 'M':
+				s = va_arg(args, unsigned char *);
+				len = 17;
+
+				if (!(flags & LEFT)) {
+					while (len < field_width--) {
+						if (str < end)
+							*str = ' ';
+						++str;
+					}
+				}
+				for (i = 0; i < len; i++) {
+					if (str < end) {
+						if ((i % 3) == 0)
+							*str = hexdigits[(*(unsigned char *)s) >> 4];
+						else if ((i % 3) == 1)
+							*str = hexdigits[(*s) & 0xF];
+						else {
+							*str = ':';
+							s++;
+						}
+						if (flags & SMALL)
+							*str = TOLOWER(*str);
+					}
+					++str;
+				}
+				while (len < field_width--) {
+					if (str < end)
+						*str = ' ';
+					++str;
+				}
+				continue;
+
+
 			case 's':
 				s = va_arg(args, char *);
 				if ((unsigned long)s < PAGE_SIZE)


