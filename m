From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 1/4] include - Convert IP4 address class macros
	to inline functions
Date: Mon, 19 Nov 2007 22:41:43 -0800
Message-ID: <1195540903.4675.92.camel@localhost>
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
Received: from DSL022.labridge.com ([206.117.136.22]:2498 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752405AbXKTGln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 01:41:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
macros to inline functions ipv4_is_<type>(__be32 addr)

Adds some type safety and arguably some readability

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
+static inline __be32 ipv4_addr_octets(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
+{
+	return htonl((((__u32)(a & 0xff)) << 24) |
+		     (((__u32)(b & 0xff)) << 16) |
+		     (((__u32)(c & 0xff)) << 8) |
+		     (((__u32)(d & 0xff)) << 0));
+}
+
+static inline bool ipv4_is_loopback(__be32 addr)
+{
+	return (addr & ipv4_addr_octets(255,0,0,0)) == ipv4_addr_octets(127,0,0,0);
+}
+
+static inline bool ipv4_is_multicast(__be32 addr)
+{
+	return (addr & ipv4_addr_octets(240,0,0,0)) == ipv4_addr_octets(224,0,0,0);
+}
+
+static inline bool ipv4_is_local_multicast(__be32 addr)
+{
+	return (addr & ipv4_addr_octets(255,255,255,0)) == ipv4_addr_octets(224,0,0,0);
+}
+
+static inline bool ipv4_is_badclass(__be32 addr)
+{
+	return (addr & ipv4_addr_octets(240,0,0,0)) == ipv4_addr_octets(240,0,0,0);
+}
+
+static inline bool ipv4_is_zeronet(__be32 addr)
+{
+	return (addr & ipv4_addr_octets(255,0,0,0)) == ipv4_addr_octets(0,0,0,0);
+}
+
 /* Some random defines to make it easier in the kernel.. */
-#define LOOPBACK(x)	(((x) & htonl(0xff000000)) == htonl(0x7f000000))
-#define MULTICAST(x)	(((x) & htonl(0xf0000000)) == htonl(0xe0000000))
-#define BADCLASS(x)	(((x) & htonl(0xf0000000)) == htonl(0xf0000000))
-#define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
-#define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))
+
+#define LOOPBACK(x)	ipv4_is_loopback(x)
+#define MULTICAST(x)	ipv4_is_multicast(x)
+#define LOCAL_MCAST(x)	ipv4_is_local_multicast(x)
+#define BADCLASS(x)	ipv4_is_badclass(x)
+#define ZERONET(x)	ipv4_is_zeronet(x)
 
 #endif
 


