From: Joe Perches <joe@perches.com>
Subject: [PATCH] lib/vsprintf.c: Avoid possible unaligned accesses in %pI6c
Date: Fri, 18 Sep 2009 16:04:06 -0700
Message-ID: <1253315046.2543.475.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jens Rosenboom <me@jayr.de>, David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1026 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758295AbZIRXEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 19:04:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom noticed that a possibly unaligned const char*
is cast to a const struct in6_addr *.

Avoid this at the cost of a struct in6_addr copy on the stack.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d320c18..5d299d0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -671,7 +671,7 @@ static char *ip4_string(char *p, const u8 *addr, bool leading_zeros)
 	return p;
 }
 
-static char *ip6_compressed_string(char *p, const struct in6_addr *addr)
+static char *ip6_compressed_string(char *p, const char *addr)
 {
 	int i;
 	int j;
@@ -683,7 +683,12 @@ static char *ip6_compressed_string(char *p, const struct in6_addr *addr)
 	u8 hi;
 	u8 lo;
 	bool needcolon = false;
-	bool useIPv4 = ipv6_addr_v4mapped(addr) || ipv6_addr_is_isatap(addr);
+	bool useIPv4;
+	struct in6_addr in6;
+
+	memcpy(&in6, addr, sizeof(struct in6_addr));
+
+	useIPv4 = ipv6_addr_v4mapped(&in6) || ipv6_addr_is_isatap(&in6);
 
 	memset(zerolength, 0, sizeof(zerolength));
 
@@ -695,7 +700,7 @@ static char *ip6_compressed_string(char *p, const struct in6_addr *addr)
 	/* find position of longest 0 run */
 	for (i = 0; i < range; i++) {
 		for (j = i; j < range; j++) {
-			if (addr->s6_addr16[j] != 0)
+			if (in6.s6_addr16[j] != 0)
 				break;
 			zerolength[i]++;
 		}
@@ -722,7 +727,7 @@ static char *ip6_compressed_string(char *p, const struct in6_addr *addr)
 			needcolon = false;
 		}
 		/* hex u16 without leading 0s */
-		word = ntohs(addr->s6_addr16[i]);
+		word = ntohs(in6.s6_addr16[i]);
 		hi = word >> 8;
 		lo = word & 0xff;
 		if (hi) {
@@ -741,19 +746,19 @@ static char *ip6_compressed_string(char *p, const struct in6_addr *addr)
 	if (useIPv4) {
 		if (needcolon)
 			*p++ = ':';
-		p = ip4_string(p, &addr->s6_addr[12], false);
+		p = ip4_string(p, &in6.s6_addr[12], false);
 	}
 
 	*p = '\0';
 	return p;
 }
 
-static char *ip6_string(char *p, const struct in6_addr *addr, const char *fmt)
+static char *ip6_string(char *p, const char *addr, const char *fmt)
 {
 	int i;
 	for (i = 0; i < 8; i++) {
-		p = pack_hex_byte(p, addr->s6_addr[2 * i]);
-		p = pack_hex_byte(p, addr->s6_addr[2 * i + 1]);
+		p = pack_hex_byte(p, *addr++);
+		p = pack_hex_byte(p, *addr++);
 		if (fmt[0] == 'I' && i != 7)
 			*p++ = ':';
 	}
@@ -768,9 +773,9 @@ static char *ip6_addr_string(char *buf, char *end, const u8 *addr,
 	char ip6_addr[sizeof("xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:255.255.255.255")];
 
 	if (fmt[0] == 'I' && fmt[2] == 'c')
-		ip6_compressed_string(ip6_addr, (const struct in6_addr *)addr);
+		ip6_compressed_string(ip6_addr, addr);
 	else
-		ip6_string(ip6_addr, (const struct in6_addr *)addr, fmt);
+		ip6_string(ip6_addr, addr, fmt);
 
 	return string(buf, end, ip6_addr, spec);
 }


