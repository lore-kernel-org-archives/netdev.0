From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] lib: vsprintf: add IPv4/v6 generic %pig/%pIg format specifier
Date: Wed, 26 Jun 2013 19:01:12 +0200
Message-ID: <1372266073-11998-2-git-send-email-dborkman@redhat.com>
References: <1372266073-11998-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab3FZRBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 13:01:17 -0400
In-Reply-To: <1372266073-11998-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

  printk("... %pIg ..", &sockaddr);

While we're at it, support for both %pig/%pIg, where 'g' stands for
generic, comes for free. In case our pointer is NULL, pointer() then
deals with that already at an earlier point in time internally.

Likely, there are many other areas than just SCTP in the kernel to make
use of this extension as well.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/vsprintf.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index e149c64..7243742 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1004,10 +1004,10 @@ int kptr_restrict __read_mostly;
  * - 'MF' For a 6-byte MAC FDDI address, it prints the address
  *       with a dash-separated hex notation
  * - '[mM]R' For a 6-byte MAC address, Reverse order (Bluetooth)
- * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
+ * - 'I' [46g] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
- * - 'i' [46] for 'raw' IPv4/IPv6 addresses
+ * - 'i' [46g] for 'raw' IPv4/IPv6 addresses
  *       IPv6 omits the colons (01020304...0f)
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
  * - '[Ii]4[hnbl]' IPv4 addresses in host, network, big or little endian order
@@ -1093,6 +1093,18 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 			return ip6_addr_string(buf, end, ptr, spec, fmt);
 		case '4':
 			return ip4_addr_string(buf, end, ptr, spec, fmt);
+		case 'g':
+			{
+				const struct sockaddr *sa = ptr;
+
+				if (sa->sa_family == AF_INET6) {
+					ptr = &((struct sockaddr_in6 *) sa)->sin6_addr;
+					return ip6_addr_string(buf, end, ptr, spec, fmt);
+				} else {
+					ptr = &((struct sockaddr_in *) sa)->sin_addr.s_addr;
+					return ip4_addr_string(buf, end, ptr, spec, fmt);
+				}
+			}
 		}
 		break;
 	case 'U':
@@ -1370,6 +1382,8 @@ qualifier:
  * %pI6 print an IPv6 address with colons
  * %pi6 print an IPv6 address without colons
  * %pI6c print an IPv6 address as specified by RFC 5952
+ * %pIg depending on sa_family of 'struct sockaddr *' switch to %pI6/%pI4
+ * %pig depending on sa_family of 'struct sockaddr *' switch to %pi6/%pi4
  * %pU[bBlL] print a UUID/GUID in big or little endian using lower or upper
  *   case.
  * %*ph[CDN] a variable-length hex string with a separator (supports up to 64
-- 
1.7.11.7
