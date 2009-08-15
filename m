From: Joe Perches <joe@perches.com>
Subject: [PATCH] lib/vsprintf.c: Add "%pI6c" - print pointer as compressed
 ipv6 address
Date: Sat, 15 Aug 2009 08:24:54 -0700
Message-ID: <1250349894.4620.5.camel@Joe-Laptop.home>
References: <1250230925.6641.92.camel@fnki-nb00130>
	 <20090814.001519.40499255.davem@davemloft.net>
	 <1250237739.16632.12.camel@fnki-nb00130>
	 <20090814.131218.139318801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jens@mcbone.net, chuck.lever@oracle.com, brian.haley@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2955 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583AbZHOPZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2009 11:25:11 -0400
In-Reply-To: <20090814.131218.139318801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-08-14 at 13:12 -0700, David Miller wrote:
> I'd say that kernel log messages are OK to tinker with, whereas procfs
> and sysfs file contents are not.

Here's a patch to start that tinkering with log messages

Add functions to format and print a compressed ipv6 address
Does longest 0 match "::" compression
Added an #include <net/addrconf.h>
Changed currently unused "%pi4" to use leading 0s (001.002.003.004)
Changed code to not modify "spec"

'I' [46] for IPv4/IPv6 addresses printed in the usual way
    IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
    IPv6 uses colon separated network-order 16 bit hex with leading 0's
'i' [46] for 'raw' IPv4/IPv6 addresses
    IPv6 omits the colons (01020304...0f)
    IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
'I6c' for IPv6 addresses printed as specified by
    http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt

Signed-off-by: Joe Perches <joe@perches.com>
---
 lib/vsprintf.c |  205 +++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 158 insertions(+), 47 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 756ccaf..9b79536 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -25,6 +25,7 @@
 #include <linux/kallsyms.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <net/addrconf.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/div64.h>
@@ -630,60 +631,162 @@ static char *resource_string(char *buf, char *end, struct resource *res,
 }
 
 static char *mac_address_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec)
+				struct printf_spec spec, const char *fmt)
 {
-	char mac_addr[6 * 3]; /* (6 * 2 hex digits), 5 colons and trailing zero */
+	char mac_addr[sizeof("xx:xx:xx:xx:xx:xx")];
 	char *p = mac_addr;
 	int i;
 
 	for (i = 0; i < 6; i++) {
 		p = pack_hex_byte(p, addr[i]);
-		if (!(spec.flags & SPECIAL) && i != 5)
+		if (fmt[0] == 'M' && i != 5)
 			*p++ = ':';
 	}
 	*p = '\0';
-	spec.flags &= ~SPECIAL;
 
 	return string(buf, end, mac_addr, spec);
 }
 
-static char *ip6_addr_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec)
+static char *ip4_string(char *p, const u8 *addr, bool leading_zeros)
 {
-	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing zero */
-	char *p = ip6_addr;
 	int i;
 
+	for (i = 0; i < 4; i++) {
+		char temp[3];	/* hold each IP quad in reverse order */
+		int digits = put_dec_trunc(temp, addr[i]) - temp;
+		if (leading_zeros) {
+			if (digits < 3)
+				*p++ = '0';
+			if (digits < 2)
+				*p++ = '0';
+		}
+		/* reverse the digits in the quad */
+		while (digits--)
+			*p++ = temp[digits];
+		if (i < 3)
+			*p++ = '.';
+	}
+
+	*p = '\0';
+	return p;
+}
+
+static char *ip6_compressed_string(char *p, const struct in6_addr *addr)
+{
+	int i;
+	int j;
+	int range;
+	unsigned char zerolength[8];
+	int longest = 0;
+	int colonpos = -1;
+	u16 word;
+	u8 hi;
+	u8 lo;
+	bool printhi;
+	bool needcolon = false;
+	bool useIPv4 = ipv6_addr_v4mapped(addr) || ipv6_addr_is_isatap(addr);
+
+	memset(zerolength, 0, sizeof(zerolength));
+
+	if (useIPv4)
+		range = 6;
+	else
+		range = 8;
+
+	/* find position of longest 0 run */
+	for (i = 0; i < range; i++) {
+		for (j = i; j < range; j++) {
+			if (addr->s6_addr16[j] != 0)
+				break;
+			zerolength[i]++;
+		}
+	}
+	for (i = 0; i < range; i++) {
+		if (zerolength[i] > longest) {
+			longest = zerolength[i];
+			colonpos = i;
+		}
+	}
+	if (colonpos != -1 && zerolength[colonpos] < 2)
+		colonpos = -1;
+
+	for (i = 0; i < range; i++) {
+		if (i == colonpos) {
+			if (needcolon || i == 0)
+				*p++ = ':';
+			*p++ = ':';
+			needcolon = false;
+			while (i + 1 < range && addr->s6_addr16[i + 1] == 0) {
+				i++;	/* skip successive 0s */
+			}
+			continue;
+		}
+		if (needcolon) {
+			*p++ = ':';
+			needcolon = false;
+		}
+		/* hex u16 without leading 0s */
+		word = ntohs(addr->s6_addr16[i]);
+		hi = word >> 8;
+		lo = word & 0xff;
+		printhi = false;
+		if (hi) {
+			if (hi > 0x0f)
+				p = pack_hex_byte(p, hi);
+			else
+				*p++ = hex_asc_lo(hi);
+			printhi = true;
+		}
+		if (printhi || lo > 0x0f)
+			p = pack_hex_byte(p, lo);
+		else
+			*p++ = hex_asc_lo(lo);
+		needcolon = true;
+	}
+
+	if (useIPv4) {
+		if (needcolon)
+			*p++ = ':';
+		p = ip4_string(p, &addr->s6_addr[12], false);
+	}
+
+	*p = '\0';
+	return p;
+}
+
+static char *ip6_string(char *p, const struct in6_addr *addr, const char *fmt)
+{
+	int i;
 	for (i = 0; i < 8; i++) {
-		p = pack_hex_byte(p, addr[2 * i]);
-		p = pack_hex_byte(p, addr[2 * i + 1]);
-		if (!(spec.flags & SPECIAL) && i != 7)
+		p = pack_hex_byte(p, addr->s6_addr[2 * i]);
+		p = pack_hex_byte(p, addr->s6_addr[2 * i + 1]);
+		if (fmt[0] == 'I' && i != 7)
 			*p++ = ':';
 	}
+
 	*p = '\0';
-	spec.flags &= ~SPECIAL;
+	return p;
+}
+
+static char *ip6_addr_string(char *buf, char *end, const u8 *addr,
+			     struct printf_spec spec, const char *fmt)
+{
+	char ip6_addr[sizeof("xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:255.255.255.255")];
+
+	if (fmt[0] == 'I' && fmt[2] == 'c')
+		ip6_compressed_string(ip6_addr, (const struct in6_addr *)addr);
+	else
+		ip6_string(ip6_addr, (const struct in6_addr *)addr, fmt);
 
 	return string(buf, end, ip6_addr, spec);
 }
 
-static char *ip4_addr_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec)
+static char *ip4_addr_string(char *buf, char *end, const u8 *addr,
+			     struct printf_spec spec, const char *fmt)
 {
-	char ip4_addr[4 * 4]; /* (4 * 3 decimal digits), 3 dots and trailing zero */
-	char temp[3];	/* hold each IP quad in reverse order */
-	char *p = ip4_addr;
-	int i, digits;
+	char ip4_addr[sizeof("255.255.255.255")];
 
-	for (i = 0; i < 4; i++) {
-		digits = put_dec_trunc(temp, addr[i]) - temp;
-		/* reverse the digits in the quad */
-		while (digits--)
-			*p++ = temp[digits];
-		if (i != 3)
-			*p++ = '.';
-	}
-	*p = '\0';
-	spec.flags &= ~SPECIAL;
+	ip4_string(ip4_addr, addr, fmt[0] == 'i');
 
 	return string(buf, end, ip4_addr, spec);
 }
@@ -702,11 +805,15 @@ static char *ip4_addr_string(char *buf, char *end, u8 *addr,
  *       addresses (not the name nor the flags)
  * - 'M' For a 6-byte MAC address, it prints the address in the
  *       usual colon-separated hex notation
- * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way (dot-separated
- *       decimal for v4 and colon separated network-order 16 bit hex for v6)
- * - 'i' [46] for 'raw' IPv4/IPv6 addresses, IPv6 omits the colons, IPv4 is
- *       currently the same
- *
+ * - 'm' For a 6-byte MAC address, it prints the hex address without colons
+ * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
+ *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
+ *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
+ * - 'i' [46] for 'raw' IPv4/IPv6 addresses
+ *       IPv6 omits the colons (01020304...0f)
+ *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
+ * - 'I6c' for IPv6 addresses printed as specified by
+ *       http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
  * pointer to the real address.
@@ -726,20 +833,24 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		return symbol_string(buf, end, ptr, spec, *fmt);
 	case 'R':
 		return resource_string(buf, end, ptr, spec);
-	case 'm':
-		spec.flags |= SPECIAL;
-		/* Fallthrough */
-	case 'M':
-		return mac_address_string(buf, end, ptr, spec);
-	case 'i':
-		spec.flags |= SPECIAL;
-		/* Fallthrough */
-	case 'I':
-		if (fmt[1] == '6')
-			return ip6_addr_string(buf, end, ptr, spec);
-		if (fmt[1] == '4')
-			return ip4_addr_string(buf, end, ptr, spec);
-		spec.flags &= ~SPECIAL;
+	case 'M':			/* Colon separated: 00:01:02:03:04:05 */
+	case 'm':			/* Contiguous: 000102030405 */
+		return mac_address_string(buf, end, ptr, spec, fmt);
+	case 'I':			/* Formatted IP supported
+					 * 4:	1.2.3.4
+					 * 6:	0001:0203:...:0708
+					 * 6c:	1::708 or 1::1.2.3.4
+					 */
+	case 'i':			/* Contiguous:
+					 * 4:	001.002.003.004
+					 * 6:   000102...0f
+					 */
+		switch (fmt[1]) {
+		case '6':
+			return ip6_addr_string(buf, end, ptr, spec, fmt);
+		case '4':
+			return ip4_addr_string(buf, end, ptr, spec, fmt);
+		}
 		break;
 	}
 	spec.flags |= SMALL;
-- 
1.6.3.1.10.g659a0.dirty



