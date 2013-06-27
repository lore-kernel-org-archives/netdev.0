From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 1/2] lib: vsprintf: add IPv4/v6 generic %piS/%pIS format specifier
Date: Thu, 27 Jun 2013 11:43:44 +0200
Message-ID: <1372326225-19203-2-git-send-email-dborkman@redhat.com>
References: <1372326225-19203-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372326225-19203-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to avoid making code that deals with printing both, IPv4 and
IPv6 addresses, unnecessary complicated as for example ...

  if (sa.sa_family == AF_INET6)
    printk("... %pI6 ...", sin6_addr);
  else
    printk("... %pI4 ...", sin_addr.s_addr);

... it would be better to introduce a format specifier that can deal
with those kind of situations internally; just as we have a "struct
sockaddr" for generic mapping into "struct sockaddr_in" or "struct
sockaddr_in6" as e.g. done in "union sctp_addr". Then, we could
reduce the above statement into something like:

  printk("... %pIS ..", &sockaddr);

While we're at it, support for both %piS/%pIS, where 'S' stands for
sockaddr, comes for free. In case our pointer is NULL, pointer() then
deals with that already at an earlier point in time internally.

Likely, there are many other areas than just SCTP in the kernel to make
use of this extension as well.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
CC: linux-kernel@vger.kernel.org
---
 v1->v2:
  - Added documentation into printk-formats.txt, thanks Vlad Yasevich
  - Changed %pig/%pIg into %piS/%pIS, thanks Joe Perches
  - Changed braces/indent in pointer(), thanks Joe Perches
  - Also CC lkml, thanks Andy Shevchenko

 Documentation/printk-formats.txt | 11 +++++++++++
 lib/vsprintf.c                   | 16 ++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
index 3af5ae6..8794953 100644
--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -121,6 +121,17 @@ IPv6 addresses:
 	print a compressed IPv6 address as described by
 	http://tools.ietf.org/html/rfc5952
 
+Generic IPv4/IPv6 addresses:
+
+	%pIS
+	%piS
+
+	For printing an IP address without the need to distinguish weather it's
+	of type AF_INET or AF_INET6, a pointer to a 'struct sockaddr', specified
+	through 'IS' or 'iS', can be passed to this format specifier, which will
+	then be further processed by the above IPv4 ('I4', 'i4') or IPv6 ('I6',
+	'i6') handler.
+
 UUID/GUID addresses:
 
 	%pUb	00010203-0405-0607-0809-0a0b0c0d0e0f
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index e149c64..a587a90 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1004,10 +1004,10 @@ int kptr_restrict __read_mostly;
  * - 'MF' For a 6-byte MAC FDDI address, it prints the address
  *       with a dash-separated hex notation
  * - '[mM]R' For a 6-byte MAC address, Reverse order (Bluetooth)
- * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
+ * - 'I' [46S] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
- * - 'i' [46] for 'raw' IPv4/IPv6 addresses
+ * - 'i' [46S] for 'raw' IPv4/IPv6 addresses
  *       IPv6 omits the colons (01020304...0f)
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
  * - '[Ii]4[hnbl]' IPv4 addresses in host, network, big or little endian order
@@ -1093,6 +1093,16 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 			return ip6_addr_string(buf, end, ptr, spec, fmt);
 		case '4':
 			return ip4_addr_string(buf, end, ptr, spec, fmt);
+		case 'S': {
+			const struct sockaddr *sa = ptr;
+
+			if (sa->sa_family == AF_INET6) {
+				ptr = &((struct sockaddr_in6 *) sa)->sin6_addr;
+				return ip6_addr_string(buf, end, ptr, spec, fmt);
+			} else {
+				ptr = &((struct sockaddr_in *) sa)->sin_addr.s_addr;
+				return ip4_addr_string(buf, end, ptr, spec, fmt);
+			}}
 		}
 		break;
 	case 'U':
@@ -1370,6 +1380,8 @@ qualifier:
  * %pI6 print an IPv6 address with colons
  * %pi6 print an IPv6 address without colons
  * %pI6c print an IPv6 address as specified by RFC 5952
+ * %pIS depending on sa_family of 'struct sockaddr *' switch to %pI6/%pI4
+ * %piS depending on sa_family of 'struct sockaddr *' switch to %pi6/%pi4
  * %pU[bBlL] print a UUID/GUID in big or little endian using lower or upper
  *   case.
  * %*ph[CDN] a variable-length hex string with a separator (supports up to 64
-- 
1.7.11.7
