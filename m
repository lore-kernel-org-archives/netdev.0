From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 1/4] include - Convert IP4 address class macros
	to inline functions
Date: Wed, 14 Nov 2007 07:53:23 -0800
Message-ID: <1195055603.5163.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1473 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754931AbXKNPxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 10:53:24 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
macros to inline functions is_ip4_[type](__be32 addr)
Adds some type safety and maybe some readability

No change in compiled image size

Signed-off-by: Joe Perches <joe@perches.com>

---

 include/linux/in.h |   45 ++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 3975cbf..ac6eff1 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -246,12 +246,47 @@ struct sockaddr_in {
 #include <asm/byteorder.h> 
 
 #ifdef __KERNEL__
+
+static inline __be32 ip4_addr_octets(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
+{
+	return htonl((((__u32)(a & 0xff)) << 24) |
+		     (((__u32)(b & 0xff)) << 16) |
+		     (((__u32)(c & 0xff)) << 8) |
+		     (((__u32)(d & 0xff)) << 0));
+}
+
+static inline bool is_ip4_loopback(__be32 addr)
+{
+	return (addr & ip4_addr_octets(255,0,0,0)) == ip4_addr_octets(127,0,0,0);
+}
+
+static inline bool is_ip4_multicast(__be32 addr)
+{
+	return (addr & ip4_addr_octets(240,0,0,0)) == ip4_addr_octets(224,0,0,0);
+}
+
+static inline bool is_ip4_local_multicast(__be32 addr)
+{
+	return (addr & ip4_addr_octets(255,255,255,0)) == ip4_addr_octets(224,0,0,0);
+}
+
+static inline bool is_ip4_badclass(__be32 addr)
+{
+	return (addr & ip4_addr_octets(240,0,0,0)) == ip4_addr_octets(240,0,0,0);
+}
+
+static inline bool is_ip4_zeronet(__be32 addr)
+{
+	return (addr & ip4_addr_octets(255,0,0,0)) == ip4_addr_octets(0,0,0,0);
+}
+
 /* Some random defines to make it easier in the kernel.. */
-#define LOOPBACK(x)	(((x) & htonl(0xff000000)) == htonl(0x7f000000))
-#define MULTICAST(x)	(((x) & htonl(0xf0000000)) == htonl(0xe0000000))
-#define BADCLASS(x)	(((x) & htonl(0xf0000000)) == htonl(0xf0000000))
-#define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
-#define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))
+
+#define LOOPBACK(x)	is_ip4_loopback(x)
+#define MULTICAST(x)	is_ip4_multicast(x)
+#define LOCAL_MCAST(x)	is_ip4_local_multicast(x)
+#define BADCLASS(x)	is_ip4_badclass(x)
+#define ZERONET(x)	is_ip4_zeronet(x)
 
 #endif
 


