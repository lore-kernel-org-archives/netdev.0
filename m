From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 1/6] printk: add %p6 format specifier for IPv6 addresses
Date: Tue, 28 Oct 2008 12:53:32 -0700
Message-ID: <1225223612.11483.34.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:47380 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbYJ1Txh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 15:53:37 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2778520wfd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 12:53:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Takes a pointer to a IPv6 address and formats it in the usual
colon-separated hex format:
xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx

Each 16 bit word is printed in network-endian byteorder.

%#p6 is also supported and will omit the colons.

%p6 is a replacement for NIP6_FMT and NIP6()
%#p6 is a replacement for NIP6_SEQFMT and NIP6()

Note that NIP6() took a struct in6_addr whereas this takes a pointer
to a struct in6_addr.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, based against net-next.  I've broken it up into more digestible
pieces, feel free to squash them together as you see fit.

 lib/vsprintf.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 0deaaaf..cb5bc04 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -598,6 +598,24 @@ static char *mac_address_string(char *buf, char *end, u8 *addr, int field_width,
 	return string(buf, end, mac_addr, field_width, precision, flags & ~SPECIAL);
 }
 
+static char *ip6_addr_string(char *buf, char *end, u8 *addr, int field_width,
+			 int precision, int flags)
+{
+	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing zero */
+	char *p = ip6_addr;
+	int i;
+
+	for (i = 0; i < 8; i++) {
+		p = pack_hex_byte(p, addr[2 * i]);
+		p = pack_hex_byte(p, addr[2 * i + 1]);
+		if (!(flags & SPECIAL) && i != 7)
+			*p++ = ':';
+	}
+	*p = '\0';
+
+	return string(buf, end, ip6_addr, field_width, precision, flags & ~SPECIAL);
+}
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -611,6 +629,8 @@ static char *mac_address_string(char *buf, char *end, u8 *addr, int field_width,
  *       addresses (not the name nor the flags)
  * - 'M' For a 6-byte MAC address, it prints the address in the
  *       usual colon-separated hex notation
+ * - '6' For a IPv6 address prints the address in network-ordered 16 bit hex
+ *       with colon separators
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -628,6 +648,8 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int field
 		return resource_string(buf, end, ptr, field_width, precision, flags);
 	case 'M':
 		return mac_address_string(buf, end, ptr, field_width, precision, flags);
+	case '6':
+		return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
 	}
 	flags |= SMALL;
 	if (field_width == -1) {
-- 
1.6.0.3.729.g6ea410


