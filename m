From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 11:10:34 -0700
Message-ID: <1250187034.28285.93.camel@Joe-Laptop.home>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>
	 <4A843EF7.4010700@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3990 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbZHMSKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 14:10:39 -0400
In-Reply-To: <4A843EF7.4010700@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 12:27 -0400, Brian Haley wrote:
> Jens Rosenboom wrote:
> > Here is a new version that also
> > fixes
> > 
> > - Leave %pi6 alone
> > - Don't compress a single :0:
> > - Do output 0
> > The results and also the remaining issues can be seen with the attached
> > test program, that also exposes a bug in glibc for v4-mapped addresses
> > from 0/16.
> > To fully conform to the cited draft, we would still have to implement
> > v4-mapped and also check whether a second run of zeros would be longer
> > than the first one, although the draft also suggests that operators
> > should avoid using this kind of addresses, so maybe this second issue
> > can be neglected.
> 
> Yes, the "compress the most zeros" would be harder, and require two
> passes over the address.  I had to cut corners somewhere :)

2 things.

First a question, then a compilable but untested patch.

The patch allows "%p6ic" for compressed and "%p6ic4" for compressed
with ipv4 last u32.

Can somebody tell me what I'm doing wrong when I link Jens' test?

cc -o test test_ipv6.c lib/vsprintf.o lib/ctype.o
lib/vsprintf.o: In function `global constructors keyed to
65535_0_simple_strtoul':
/home/joe/linux/linux-2.6/lib/vsprintf.c:1972: undefined reference to
`__gcov_init'
lib/vsprintf.o:(.data+0x28): undefined reference to `__gcov_merge_add'
collect2: ld returned 1 exit status


Now for the patch.  Perhaps something like this (compiled, untested)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 756ccaf..dd02842 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -630,7 +630,7 @@ static char *resource_string(char *buf, char *end, struct resource *res,
 }
 
 static char *mac_address_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec)
+				struct printf_spec spec, const char *fmt)
 {
 	char mac_addr[6 * 3]; /* (6 * 2 hex digits), 5 colons and trailing zero */
 	char *p = mac_addr;
@@ -638,36 +638,128 @@ static char *mac_address_string(char *buf, char *end, u8 *addr,
 
 	for (i = 0; i < 6; i++) {
 		p = pack_hex_byte(p, addr[i]);
-		if (!(spec.flags & SPECIAL) && i != 5)
+		if (!(fmt[0] == 'm') && i != 5)
 			*p++ = ':';
 	}
 	*p = '\0';
-	spec.flags &= ~SPECIAL;
 
 	return string(buf, end, mac_addr, spec);
 }
 
+typedef enum { DC_START, DC_MIDDLE, DC_DONE } ip6_colon_t;
+
+static char *ip6_compress_u16(char *p, u16 addr16, u16 addr16_next,
+			      ip6_colon_t *colon, bool *needcolon)
+{
+	bool printhi;
+	u8 hi;
+	u8 lo;
+
+	if (addr16 == 0 && addr16_next == 0 && *colon == DC_START) {
+		*colon = DC_MIDDLE;
+		return p;
+	}
+	if (*colon == DC_MIDDLE) {
+		if (addr16 == 0)
+			return p;
+		*colon = DC_DONE;
+		*p++ = ':';
+		*p++ = ':';
+	} else if (*needcolon)
+		*p++ = ':';
+
+	printhi = false;
+	hi = addr16 >> 8;
+	lo = addr16 & 0xff;
+	if (hi) {
+		if (hi > 0x0f)
+			p = pack_hex_byte(p, hi);
+		else
+			*p++ = hex_asc_lo(hi);
+		printhi = true;
+	}
+	/*
+	 * If we printed the high-order bits we must print the
+	 * low-order ones, even if they're all zeros.
+	 */
+	if (printhi || lo > 0x0f)
+		p = pack_hex_byte(p, lo);
+	else 
+		*p++ = hex_asc_lo(lo);
+	*needcolon = true;
+
+	return p;
+}
+
+static char *ip6_compressed_string(char *buf, char *end, u8 *addr,
+				   struct printf_spec spec, const char *fmt,
+				   char *ip6_addr)
+{
+	char *p = ip6_addr;
+	int i;
+	bool needcolon = false;
+	u16 *addr16 = (u16 *)addr;
+	ip6_colon_t colon = DC_START;
+
+	if (fmt[3] == '4') {		/* use :: and ipv4 */
+		for (i = 0; i < 6; i++) {
+			p = ip6_compress_u16(p, addr16[i], addr16[i+1],
+					     &colon, &needcolon);
+		}
+		if (colon != DC_DONE) {
+			*p++ = ':';
+			*p++ = ':';
+			colon = DC_DONE;
+		}
+		addr += 6 * 2;
+		for (i = 0; i < 4; i++) {
+			p = put_dec_trunc(p, *addr++);
+			if (i != 3)
+				*p++ = '.';
+		}
+	} else {
+		for (i = 0; i < 7; i++) {
+			p = ip6_compress_u16(p, addr16[i], addr16[i+1],
+					     &colon, &needcolon);
+		}
+		p = ip6_compress_u16(p, addr16[7], 0xff, &colon, &needcolon);
+	}
+
+	if (colon == DC_MIDDLE) {
+		*p++ = ':';
+		*p++ = ':';
+	}
+
+	*p = '\0';
+
+	return string(buf, end, ip6_addr, spec);
+}
+
 static char *ip6_addr_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec)
+			     struct printf_spec spec, const char *fmt)
 {
-	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing zero */
+	char ip6_addr[7 * 4 + 7 + 4 * 4]; /* (7 * 4 hex digits) + 7 colons +
+					   * ipv4 address, and trailing zero */
 	char *p = ip6_addr;
 	int i;
 
+	if (fmt[0] == 'i' && fmt[2] == 'c')
+		return ip6_compressed_string(buf, end, addr, spec, fmt,
+					     ip6_addr);
+
 	for (i = 0; i < 8; i++) {
 		p = pack_hex_byte(p, addr[2 * i]);
 		p = pack_hex_byte(p, addr[2 * i + 1]);
-		if (!(spec.flags & SPECIAL) && i != 7)
+		if (fmt[0] == 'i' && i != 7)
 			*p++ = ':';
 	}
 	*p = '\0';
-	spec.flags &= ~SPECIAL;
 
 	return string(buf, end, ip6_addr, spec);
 }
 
 static char *ip4_addr_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec)
+			     struct printf_spec spec)
 {
 	char ip4_addr[4 * 4]; /* (4 * 3 decimal digits), 3 dots and trailing zero */
 	char temp[3];	/* hold each IP quad in reverse order */
@@ -683,11 +775,18 @@ static char *ip4_addr_string(char *buf, char *end, u8 *addr,
 			*p++ = '.';
 	}
 	*p = '\0';
-	spec.flags &= ~SPECIAL;
 
 	return string(buf, end, ip4_addr, spec);
 }
 
+static char *ip_addr_string(char *buf, char *end, u8 *addr,
+			    struct printf_spec spec, const char *fmt)
+{
+	if (fmt[1] == '6')
+		return ip6_addr_string(buf, end, addr, spec, fmt);
+	return ip4_addr_string(buf, end, addr, spec);
+}
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -726,20 +825,19 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
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
+	case 'm':			/* Colon separated: 00:01:02:03:04:05 */
+	case 'M':			/* Contiguous: 000102030405 */
+		return mac_address_string(buf, end, ptr, spec, fmt);
+	case 'i':			/*
+					 * Formatted IP supported
+					 * 4:	001.002.003.004
+					 * 6:	0001:0203:...:0708
+					 * 6c:	1::708
+					 * 6c4:	1::1.2.3.4
+					 */
+	case 'I':			/* Contiguous: */
+		if (fmt[1] == '4' || fmt[1] == '6')
+			ip_addr_string(buf, end, ptr, spec, fmt);
 		break;
 	}
 	spec.flags |= SMALL;


