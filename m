From: Joe Perches <joe@perches.com>
Subject: [net-next PATCH] lib/vsprintf.c: Add IPV4 options %pI4[hnbl] for
 host, network, big and little endian
Date: Tue, 05 Jan 2010 00:42:18 -0800
Message-ID: <1262680938.1952.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1508 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696Ab0AEImU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 03:42:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should allow the removal of the #defines and uses
of NIPQUAD and NIPQUAD_FMT

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d4996cf..5f12ffa 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -692,13 +692,37 @@ static char *mac_address_string(char *buf, char *end, u8 *addr,
 	return string(buf, end, mac_addr, spec);
 }
 
-static char *ip4_string(char *p, const u8 *addr, bool leading_zeros)
+static char *ip4_string(char *p, const u8 *addr, const char *fmt)
 {
 	int i;
-
+	bool leading_zeros = (fmt[0] == 'i');
+	int index;
+	int step;
+
+	switch (fmt[2]) {
+	case 'h':
+#ifdef __BIG_ENDIAN
+		index = 0;
+		step = 1;
+#else
+		index = 3;
+		step = -1;
+#endif
+		break;
+	case 'l':
+		index = 3;
+		step = -1;
+		break;
+	case 'n':
+	case 'b':
+	default:
+		index = 0;
+		step = 1;
+		break;
+	}
 	for (i = 0; i < 4; i++) {
 		char temp[3];	/* hold each IP quad in reverse order */
-		int digits = put_dec_trunc(temp, addr[i]) - temp;
+		int digits = put_dec_trunc(temp, addr[index]) - temp;
 		if (leading_zeros) {
 			if (digits < 3)
 				*p++ = '0';
@@ -710,6 +734,7 @@ static char *ip4_string(char *p, const u8 *addr, bool leading_zeros)
 			*p++ = temp[digits];
 		if (i < 3)
 			*p++ = '.';
+		index += step;
 	}
 	*p = '\0';
 
@@ -789,7 +814,7 @@ static char *ip6_compressed_string(char *p, const char *addr)
 	if (useIPv4) {
 		if (needcolon)
 			*p++ = ':';
-		p = ip4_string(p, &in6.s6_addr[12], false);
+		p = ip4_string(p, &in6.s6_addr[12], "I4");
 	}
 	*p = '\0';
 
@@ -829,7 +854,7 @@ static char *ip4_addr_string(char *buf, char *end, const u8 *addr,
 {
 	char ip4_addr[sizeof("255.255.255.255")];
 
-	ip4_string(ip4_addr, addr, fmt[0] == 'i');
+	ip4_string(ip4_addr, addr, fmt);
 
 	return string(buf, end, ip4_addr, spec);
 }
@@ -902,6 +927,7 @@ static char *uuid_string(char *buf, char *end, const u8 *addr,
  * - 'i' [46] for 'raw' IPv4/IPv6 addresses
  *       IPv6 omits the colons (01020304...0f)
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
+ * - '[Ii]4[hnbl]' IPv4 addresses in host, network, big or little endian order
  * - 'I6c' for IPv6 addresses printed as specified by
  *       http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt
  * - 'U' For a 16 byte UUID/GUID, it prints the UUID/GUID in the form


