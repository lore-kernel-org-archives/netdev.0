From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [RFC PATCHv2] printk: add the %pM, %p4, %p6 format specifiers
Date: Sun, 26 Oct 2008 17:31:05 -0700
Message-ID: <1225067465.5672.1.camel@brick>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
	 <1225009308.3478.22.camel@johannes.berg>
	 <1225009822.3478.30.camel@johannes.berg>  <1225047674.10060.10.camel@brick>
	 (sfid-20081026_200122_320043_BFBB81CD)  <1225049591.3746.0.camel@johannes.berg>
	 <1225049929.10060.11.camel@brick>
	 (sfid-20081026_203902_019881_0F8064FC)  <1225050015.3746.2.camel@johannes.berg>
	 <1225060789.10060.13.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, anders@anduras.de,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:42534 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbYJ0AbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 20:31:09 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1801633wfd.4
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2008 17:31:07 -0700 (PDT)
In-Reply-To: <1225060789.10060.13.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add format specifiers for printing out colon-separated bytes:

MAC addresses (%pM):
xx:xx:xx:xx:xx:xx

IPv4 addresses (%p4):
xx:xx:xx:xx

IPv6 addresses (%p6):
xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx

%#pM, %#p4, %#p6 are also supported and print without the colon
separators.

[Based on Johannes Berg's initial patch]
Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
This one without the embarrassing index typos in ip6_address and mac_address.

 lib/vsprintf.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index a013bbc..eec3879 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -581,6 +581,58 @@ static char *resource_string(char *buf, char *end, struct resource *res, int fie
 	return string(buf, end, sym, field_width, precision, flags);
 }
 
+static char *ip4_address(char *buf, char *end, u8 *addr, int field_width,
+			 int precision, int flags)
+{
+	char ip4_addr[4 * 3]; /* (4 * 2 hex digits), 3 colons and trailing zero */
+	char *p = ip4_addr;
+	int i;
+
+	for (i = 0; i < 4; i++) {
+		p = pack_hex_byte(p, addr[i]);
+		if (!(flags & SPECIAL) && i != 3)
+			*p++ = ':';
+	}
+	*p = '\0';
+
+	return string(buf, end, ip4_addr, field_width, precision, flags & ~SPECIAL);
+}
+
+static char *ip6_address(char *buf, char *end, u8 *addr, int field_width,
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
+static char *mac_address(char *buf, char *end, u8 *addr, int field_width,
+			 int precision, int flags)
+{
+	char mac_addr[6 * 3]; /* (6 * 2 hex digits), 5 colons and trailing zero */
+	char *p = mac_addr;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		p = pack_hex_byte(p, addr[i]);
+		if (!(flags & SPECIAL) && i != 5)
+			*p++ = ':';
+	}
+	*p = '\0';
+
+	return string(buf, end, mac_addr, field_width, precision, flags & ~SPECIAL);
+}
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -592,6 +644,12 @@ static char *resource_string(char *buf, char *end, struct resource *res, int fie
  * - 'S' For symbolic direct pointers
  * - 'R' For a struct resource pointer, it prints the range of
  *       addresses (not the name nor the flags)
+ * - 'M' For a 6-byte MAC address, it prints the address in the
+ *       usual colon-separated hex notation
+ * - '4' For a 4-byte IPv4 address, it prints the address in the
+ *       usual colon-separated hex notation
+ * - 'M' For a 16-byte IPv6 address, it prints the address in colon separated
+ *       big-endian 16 bit hex notation
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -607,6 +665,12 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int field
 		return symbol_string(buf, end, ptr, field_width, precision, flags);
 	case 'R':
 		return resource_string(buf, end, ptr, field_width, precision, flags);
+	case 'M':
+		return mac_address(buf, end, ptr, field_width, precision, flags);
+	case '4':
+		return ip4_address(buf, end, ptr, field_width, precision, flags);
+	case '6':
+		return ip6_address(buf, end, ptr, field_width, precision, flags);
 	}
 	flags |= SMALL;
 	if (field_width == -1) {
-- 
1.6.0.3.729.g6ea410



