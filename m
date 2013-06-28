From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 1/2] lib: vsprintf: add IPv4/v6 generic %p[Ii]S[pfs] format specifier
Date: Fri, 28 Jun 2013 14:05:30 +0200
Message-ID: <1372421131-1672-2-git-send-email-dborkman@redhat.com>
References: <1372421131-1672-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372421131-1672-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to avoid making code that deals with printing both, IPv4 and
IPv6 addresses, unnecessary complicated as for example ...

  if (sa.sa_family == AF_INET6)
    printk("... %pI6 ...", ..sin6_addr);
  else
    printk("... %pI4 ...", ..sin_addr.s_addr);

... it would be better to introduce a format specifier that can deal
with those kind of situations internally; just as we have a "struct
sockaddr" for generic mapping into "struct sockaddr_in" or "struct
sockaddr_in6" as e.g. done in "union sctp_addr". Then, we could
reduce the above statement into something like:

  printk("... %pIS ..", &sockaddr);

In case our pointer is NULL, pointer() then deals with that already at
an earlier point in time internally. While we're at it, support for both
%piS/%pIS, where 'S' stands for sockaddr, comes (almost) for free.

Additionally to that, postfix specifiers 'p', 'f' and 's' are supported
as suggested and initially implemented in 2009 by Joe Perches [1].
Handling of those additional specifiers orientate on the initial RFC that
was proposed. Also we support IPv6 compressed format specified by 'c' and
various other IPv4 extensions as stated in the documentation part.

Likely, there are many other areas than just SCTP in the kernel to make
use of this extension as well.

 [1] http://patchwork.ozlabs.org/patch/31480/

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
CC: Joe Perches <joe@perches.com>
CC: linux-kernel@vger.kernel.org
---
 v1->v2:
  - Added documentation into printk-formats.txt
  - Changed %pig/%pIg into %piS/%pIS
  - Changed braces/indent in pointer()
  - Also CC lkml
 v2->v3:
  - Reworked entire patch to include port, flowinfo, scope and others
  - Various printk tests with these new specifiers
  - Improved documentation

 Documentation/printk-formats.txt |  32 ++++++++++++
 lib/vsprintf.c                   | 108 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 138 insertions(+), 2 deletions(-)

diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
index 3af5ae6..3d4b76f 100644
--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -121,6 +121,38 @@ IPv6 addresses:
 	print a compressed IPv6 address as described by
 	http://tools.ietf.org/html/rfc5952
 
+IPv4/IPv6 addresses (generic, with port, flowinfo, scope):
+
+	%pIS	1.2.3.4		or 0001:0002:0003:0004:0005:0006:0007:0008
+	%piS	001.002.003.004	or 00010002000300040005000600070008
+	%pISc	1.2.3.4		or 1:2:3:4:5:6:7:8
+	%pISpc	1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345
+	%p[Ii]S[p][hnblcfs]
+
+	For printing an IP address without the need to distinguish whether it's
+	of type AF_INET or AF_INET6, a pointer to a valid 'struct sockaddr',
+	specified through 'IS' or 'iS', can be passed to this format specifier.
+
+	The additional 'p', 'f', and 's' specifiers are used to specify port
+	(IPv4, IPv6), flowinfo (IPv6) and scope (IPv6). Ports have a ':' prefix,
+	flowinfo a '/' and scope a '%', each followed by the actual value.
+
+	In case of an IPv6 address the compressed IPv6 address as described by
+	http://tools.ietf.org/html/rfc5952 is being used if the additional
+	specifier 'c' is given. The IPv6 address is surrounded by '[', ']' in
+	case of additional specifiers 'p', 'f' or 's' as suggested by
+	https://tools.ietf.org/html/draft-ietf-6man-text-addr-representation-07
+
+	In case of IPv4 addresses, the additional 'h', 'n', 'b', and 'l'
+	specifiers can be used as well and are ignored in case of an IPv6
+	address.
+
+	Further examples:
+
+	%pISfc		1.2.3.4		or [1:2:3:4:5:6:7:8]/123456789
+	%pISsc		1.2.3.4		or [1:2:3:4:5:6:7:8]%1234567890
+	%pISpfc		1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345/123456789
+
 UUID/GUID addresses:
 
 	%pUb	00010203-0405-0607-0809-0a0b0c0d0e0f
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index e149c64..da2a4d5 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -923,6 +923,87 @@ char *ip4_addr_string(char *buf, char *end, const u8 *addr,
 }
 
 static noinline_for_stack
+char *ip6_addr_string_sa(char *buf, char *end, const struct sockaddr_in6 *sa,
+			 struct printf_spec spec, const char *fmt)
+{
+	bool have_p = false, have_s = false, have_f = false, have_c = false;
+	char ip6_addr[sizeof("[xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:255.255.255.255]") +
+		      sizeof(":12345") + sizeof("/123456789") +
+		      sizeof("%1234567890")];
+	char *p = ip6_addr, *pend = ip6_addr + sizeof(ip6_addr);
+	const u8 *addr = (const u8 *) &sa->sin6_addr;
+	char fmt6[2] = { fmt[0], '6'};
+	u8 off = 0;
+
+	fmt++;
+	while (isalpha(*++fmt)) {
+		switch (*fmt) {
+		case 'p':
+			have_p = true;
+			break;
+		case 'f':
+			have_f = true;
+			break;
+		case 's':
+			have_s = true;
+			break;
+		case 'c':
+			have_c = true;
+			break;
+		}
+	}
+
+	if (have_p || have_s || have_f) {
+		*p = '[';
+		off = 1;
+	}
+
+	if (fmt6[0] == 'I' && have_c)
+		p = ip6_compressed_string(ip6_addr + off, addr);
+	else
+		p = ip6_string(ip6_addr + off, addr, fmt6);
+
+	if (have_p || have_s || have_f)
+		*p++ = ']';
+
+	if (have_p) {
+		*p++ = ':';
+		p = number(p, pend, ntohs(sa->sin6_port), spec);
+	}
+	if (have_f) {
+		*p++ = '/';
+		p = number(p, pend, ntohl(sa->sin6_flowinfo &
+					  IPV6_FLOWINFO_MASK), spec);
+	}
+	if (have_s) {
+		*p++ = '%';
+		p = number(p, pend, sa->sin6_scope_id, spec);
+	}
+	*p = '\0';
+
+	return string(buf, end, ip6_addr, spec);
+}
+
+static noinline_for_stack
+char *ip4_addr_string_sa(char *buf, char *end, const struct sockaddr_in *sa,
+			 struct printf_spec spec, const char *fmt)
+{
+	bool have_p = (fmt[2] && fmt[2] == 'p');
+	char *p, ip4_addr[sizeof("255.255.255.255") + sizeof(":12345")];
+	char *pend = ip4_addr + sizeof(ip4_addr);
+	char fmt4[3] = { fmt[0], '4', have_p ? (fmt[3] ? : 0) : fmt[2] };
+
+	p = ip4_string(ip4_addr, (const u8 *) &sa->sin_addr.s_addr, fmt4);
+	if (have_p) {
+		*p++ = ':';
+		p = number(p, pend, ntohs(sa->sin_port), spec);
+	}
+	*p = '\0';
+
+	return string(buf, end, ip4_addr, spec);
+}
+
+static noinline_for_stack
 char *uuid_string(char *buf, char *end, const u8 *addr,
 		  struct printf_spec spec, const char *fmt)
 {
@@ -1007,11 +1088,17 @@ int kptr_restrict __read_mostly;
  * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
+ *       [S][pfs]
+ *       Generic IPv4/IPv6 address (struct sockaddr *) that falls back to
+ *       [4] or [6] and is able to print port [p], flowinfo [f], scope [s]
  * - 'i' [46] for 'raw' IPv4/IPv6 addresses
  *       IPv6 omits the colons (01020304...0f)
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
- * - '[Ii]4[hnbl]' IPv4 addresses in host, network, big or little endian order
- * - 'I6c' for IPv6 addresses printed as specified by
+ *       [S][pfs]
+ *       Generic IPv4/IPv6 address (struct sockaddr *) that falls back to
+ *       [4] or [6] and is able to print port [p], flowinfo [f], scope [s]
+ * - '[Ii][4S][hnbl]' IPv4 addresses in host, network, big or little endian order
+ * - 'I[6S]c' for IPv6 addresses printed as specified by
  *       http://tools.ietf.org/html/rfc5952
  * - 'U' For a 16 byte UUID/GUID, it prints the UUID/GUID in the form
  *       "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
@@ -1093,6 +1180,21 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 			return ip6_addr_string(buf, end, ptr, spec, fmt);
 		case '4':
 			return ip4_addr_string(buf, end, ptr, spec, fmt);
+		case 'S': {
+			const union {
+				struct sockaddr		raw;
+				struct sockaddr_in	v4;
+				struct sockaddr_in6	v6;
+			} *sa = ptr;
+
+			switch (sa->raw.sa_family) {
+			case AF_INET:
+				return ip4_addr_string_sa(buf, end, &sa->v4, spec, fmt);
+			case AF_INET6:
+				return ip6_addr_string_sa(buf, end, &sa->v6, spec, fmt);
+			default:
+				return string(buf, end, "(invalid address)", spec);
+			}}
 		}
 		break;
 	case 'U':
@@ -1370,6 +1472,8 @@ qualifier:
  * %pI6 print an IPv6 address with colons
  * %pi6 print an IPv6 address without colons
  * %pI6c print an IPv6 address as specified by RFC 5952
+ * %pIS depending on sa_family of 'struct sockaddr *' print IPv4/IPv6 address
+ * %piS depending on sa_family of 'struct sockaddr *' print IPv4/IPv6 address
  * %pU[bBlL] print a UUID/GUID in big or little endian using lower or upper
  *   case.
  * %*ph[CDN] a variable-length hex string with a separator (supports up to 64
-- 
1.7.11.7
