From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 1/4] printk: add %I4, %I6, %i4, %i6 format specifiers
Date: Wed, 29 Oct 2008 11:35:40 -0700
Message-ID: <1225305340.5688.36.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:26663 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbYJ2TDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 15:03:34 -0400
Received: by yw-out-2324.google.com with SMTP id 9so53675ywe.1
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 12:03:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For use in printing IPv4, or IPv6 addresses in the usual way:

%i4 and %I4 are currently equivalent and print the address in
dot-separated decimal x.x.x.x

%I6 prints 16-bit network order hex with colon separators:
xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx

%i6 omits the colons.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 lib/vsprintf.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index cb5bc04..a863006 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -616,6 +616,23 @@ static char *ip6_addr_string(char *buf, char *end, u8 *addr, int field_width,
 	return string(buf, end, ip6_addr, field_width, precision, flags & ~SPECIAL);
 }
 
+static char *ip4_addr_string(char *buf, char *end, u8 *addr, int field_width,
+			 int precision, int flags)
+{
+	char ip4_addr[4 * 4]; /* (4 * 3 decimal digits), 3 dots and trailing zero */
+	char *p = ip4_addr;
+	int i;
+
+	for (i = 0; i < 4; i++) {
+		p = put_dec_trunc(p, addr[i]);
+		if (i != 3)
+			*p++ = '.';
+	}
+	*p = '\0';
+
+	return string(buf, end, ip4_addr, field_width, precision, flags & ~SPECIAL);
+}
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -629,6 +646,10 @@ static char *ip6_addr_string(char *buf, char *end, u8 *addr, int field_width,
  *       addresses (not the name nor the flags)
  * - 'M' For a 6-byte MAC address, it prints the address in the
  *       usual colon-separated hex notation
+ * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way (dot-separated
+ *       decimal for v4 and colon separated network-order 16 bit hex for v6)
+ * - 'i' [46] for 'raw' IPv4/IPv6 addresses, IPv6 omits the colons, IPv4 is
+         currently the same
  * - '6' For a IPv6 address prints the address in network-ordered 16 bit hex
  *       with colon separators
  *
@@ -650,6 +671,16 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int field
 		return mac_address_string(buf, end, ptr, field_width, precision, flags);
 	case '6':
 		return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
+	case 'i':
+		flags |= SPECIAL;
+		/* Fallthrough */
+	case 'I':
+		if (fmt[1] == '6')
+			return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
+		if (fmt[1] == '4')
+			return ip4_addr_string(buf, end, ptr, field_width, precision, flags);
+		flags &= ~SPECIAL;
+		break;
 	}
 	flags |= SMALL;
 	if (field_width == -1) {
-- 
1.6.0.3.756.gb776d


