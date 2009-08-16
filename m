From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] lib/vsprintf.c: Add struct sockaddr * "%pN<foo>" output
Date: Sat, 15 Aug 2009 21:10:18 -0700
Message-ID: <1250395818.4625.15.camel@Joe-Laptop.home>
References: <1250230925.6641.92.camel@fnki-nb00130>
	 <20090814.001519.40499255.davem@davemloft.net>
	 <1250237739.16632.12.camel@fnki-nb00130>
	 <20090814.131218.139318801.davem@davemloft.net>
	 <1250349894.4620.5.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jens@mcbone.net, brian.haley@hp.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3561 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbZHPEKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2009 00:10:30 -0400
In-Reply-To: <1250349894.4620.5.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chuck.

Here's a tentative patch that adds that facility you wanted in
this thread.
http://kerneltrap.org/mailarchive/linux-netdev/2008/11/25/4231684

This patch is on top of this patch:
http://marc.info/?l=linux-netdev&m=125034992003220&w=2

I'm not sure it's great or even useful, but just for discussion.

Use style:
* - 'N' For network socket (sockaddr) pointers
*       if sa_family is IPv4, output is %pI4; if IPv6, output is %pI6c
*       May be used with any combination of additional specifiers below
*       'p' decimal socket port number for IPv[46]: ":12345"
*       'f' decimal flowinfo for IPv6: "/123456789"
*       's' decimal scope_id number for IPv6: "%1234567890"
*       so %pNp will print if IPv4 "1.2.3.4:1234", if IPv6: "1::c0a8:a:1234"

I think using ":" as the separator for the port number, while common,
and already frequently used in kernel source (see bullet 2 in):
http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt
"Section 6: Notes on Combining IPv6 Addresses with Port Numbers".
is not good for readability.

Perhaps this style should be changed to the "[ipv6]:port" described
in the draft above.

cheers, Joe

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 9b79536..b3cbc38 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -791,6 +791,90 @@ static char *ip4_addr_string(char *buf, char *end, const u8 *addr,
 	return string(buf, end, ip4_addr, spec);
 }
 
+static char *u32_dec_val(char *p, u32 val)
+{
+	char temp[9];
+	int digits;
+	u32 hi_val = val / 100000;
+	char *pos;
+	pos = put_dec_trunc(temp, val%100000);
+	if (hi_val)
+		pos = put_dec_trunc(pos, hi_val);
+	digits = pos - temp;
+	/* reverse the digits in temp */
+	while (digits--)
+		*p++ = temp[digits];
+	return p;
+}
+
+static char *socket_addr_string(char *buf, char *end,
+				const struct sockaddr *sa,
+				struct printf_spec spec, const char *fmt)
+{
+	char addr[sizeof("xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:255.255.255.255") +
+		  sizeof(":12345") +
+		  sizeof("%1234567890") +
+		  sizeof("/123456789")];
+	char *p;
+	struct sockaddr_in *sa4 = (struct sockaddr_in *)sa;
+	struct sockaddr_in6 *sa6 = (struct sockaddr_in6 *)sa;
+
+	switch (sa->sa_family) {
+	case AF_INET:
+		p = ip4_string(addr, (const u8 *)&sa4->sin_addr.s_addr, false);
+		break;
+	case AF_INET6:
+		p = ip6_compressed_string(addr, &sa6->sin6_addr);
+		break;
+	default: {
+		struct printf_spec num_spec = {
+			.base = 16,
+			.precision = -1,
+			.field_width = 2 * sizeof(void *),
+			.flags = SPECIAL | SMALL | ZEROPAD,
+		};
+
+		p = strcpy(addr, "Bad socket address: ")
+			+ sizeof("Bad socket address: ");
+		p = number(p, addr + sizeof(addr), (unsigned long)sa, num_spec);
+		break;
+	}
+	}
+
+	while (isalpha(*++fmt)) {
+		switch (*fmt) {
+		case 'p':
+			*p++ = ':';
+			switch (sa->sa_family) {
+			case AF_INET:
+				p = u32_dec_val(p,ntohs(sa4->sin_port));
+				break;
+			case AF_INET6:
+				p = u32_dec_val(p,ntohs(sa6->sin6_port));
+				break;
+			}
+			break;
+		case 's':
+			*p++ = '%';
+			switch (sa->sa_family) {
+			case AF_INET6:
+				p = u32_dec_val(p, sa6->sin6_scope_id);
+			}
+			break;
+		case 'f':
+			*p++ = '/';
+			switch (sa->sa_family) {
+			case AF_INET6:
+				p = u32_dec_val(p, ntohl(sa6->sin6_flowinfo &
+							 IPV6_FLOWINFO_MASK));
+			}
+			break;
+		}
+	}
+	*p = '\0';
+	return string(buf, end, addr, spec);
+}
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -814,6 +898,13 @@ static char *ip4_addr_string(char *buf, char *end, const u8 *addr,
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
  * - 'I6c' for IPv6 addresses printed as specified by
  *       http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt
+ * - 'N' For network socket (sockaddr) pointers
+ *       if sa_family is IPv4, output is %pI4; if IPv6, output is %pI6c
+ *       May be used with any combination of additional specifiers below
+ *       'p' decimal socket port number for IPv[46]: ":12345"
+ *       'f' decimal flowinfo for IPv6: "/123456789"
+ *       's' decimal scope_id number for IPv6: "%1234567890"
+ *       so %pNp will print if IPv4 "1.2.3.4:1234", if IPv6: "1::c0a8:a:1234"
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
  * pointer to the real address.
@@ -852,7 +943,10 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 			return ip4_addr_string(buf, end, ptr, spec, fmt);
 		}
 		break;
+	case 'N':
+		return socket_addr_string(buf, end, ptr, spec, fmt);
 	}
+
 	spec.flags |= SMALL;
 	if (spec.field_width == -1) {
 		spec.field_width = 2*sizeof(void *);


