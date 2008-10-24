From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] add %pM printf format specifier
Date: Sat, 25 Oct 2008 01:46:48 +0200
Message-ID: <1224892008.3919.27.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40108 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbYJXXqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 19:46:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new printf format specifier for the kernel, %pM,
to be used to print out MAC addresses. This has advantages
over the current print_mac scheme:
 * no need for DECLARE_MAC_BUF
 * can be used safely in statements that might be compiled
   out without the print_mac call staying.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 lib/vsprintf.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

--- everything.orig/lib/vsprintf.c	2008-10-25 01:21:54.000000000 +0200
+++ everything/lib/vsprintf.c	2008-10-25 01:24:15.000000000 +0200
@@ -581,6 +581,22 @@ static char *resource_string(char *buf, 
 	return string(buf, end, sym, field_width, precision, flags);
 }
 
+static char *mac_address(char *buf, char *end, u8 *addr, int field_width, int precision, int flags)
+{
+	/* room for 6 * two hex digits, 5 colons and trailing zero */
+	char mac[18];
+	char *p = mac, *pend = mac + sizeof(mac);
+	int i;
+
+	for (i=0; i < 6; i++) {
+		p = number(p, pend, addr[i], 16, 2, -1, SMALL | ZEROPAD);
+		*p++ = ':';
+	}
+	mac[17] = '\0';
+
+	return string(buf, end, mac, field_width, precision, flags);
+}
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -592,6 +608,8 @@ static char *resource_string(char *buf, 
  * - 'S' For symbolic direct pointers
  * - 'R' For a struct resource pointer, it prints the range of
  *       addresses (not the name nor the flags)
+ * - 'M' For a 6-byte MAC address, it prints the address in the
+ *       usual colon-separated hex notation
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -607,6 +625,8 @@ static char *pointer(const char *fmt, ch
 		return symbol_string(buf, end, ptr, field_width, precision, flags);
 	case 'R':
 		return resource_string(buf, end, ptr, field_width, precision, flags);
+	case 'M':
+		return mac_address(buf, end, ptr, field_width, precision, flags);
 	}
 	flags |= SMALL;
 	if (field_width == -1) {


