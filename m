From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 4/6] Add support for __be64 and bitops to ethtool
Date: Thu, 21 Apr 2011 13:40:35 -0700
Message-ID: <20110421204035.23054.6918.stgit@gitlad.jf.intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41385 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587Ab1DUUkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 16:40:36 -0400
In-Reply-To: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to add support for __be64 values and bitops to
ethtool.  These changes will be needed in order to support network flow
classifier rule configuration.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool-bitops.h |   25 +++++++++++++++++++++++++
 ethtool-util.h   |   30 ++++++++++++++++++++++++++----
 ethtool.c        |    7 -------
 3 files changed, 51 insertions(+), 11 deletions(-)
 create mode 100644 ethtool-bitops.h

diff --git a/ethtool-bitops.h b/ethtool-bitops.h
new file mode 100644
index 0000000..0ff14f1
--- /dev/null
+++ b/ethtool-bitops.h
@@ -0,0 +1,25 @@
+#ifndef ETHTOOL_BITOPS_H__
+#define ETHTOOL_BITOPS_H__
+
+#define BITS_PER_BYTE		8
+#define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
+#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
+#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
+
+static inline void set_bit(int nr, unsigned long *addr)
+{
+	addr[nr / BITS_PER_LONG] |= 1UL << (nr % BITS_PER_LONG);
+}
+
+static inline void clear_bit(int nr, unsigned long *addr)
+{
+	addr[nr / BITS_PER_LONG] &= ~(1UL << (nr % BITS_PER_LONG));
+}
+
+static __always_inline int test_bit(unsigned int nr, const unsigned long *addr)
+{
+	return !!((1UL << (nr % BITS_PER_LONG)) &
+		  (((unsigned long *)addr)[nr / BITS_PER_LONG]));
+}
+
+#endif
diff --git a/ethtool-util.h b/ethtool-util.h
index f053028..3d46faf 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -5,15 +5,18 @@
 
 #include <sys/types.h>
 #include <endian.h>
+#include <sys/ioctl.h>
+#include <net/if.h>
+#include "ethtool-config.h"
+#include "ethtool-copy.h"
 
 /* ethtool.h expects these to be defined by <linux/types.h> */
 #ifndef HAVE_BE_TYPES
 typedef __uint16_t __be16;
 typedef __uint32_t __be32;
+typedef unsigned long long __be64;
 #endif
 
-#include "ethtool-copy.h"
-
 typedef unsigned long long u64;
 typedef __uint32_t u32;
 typedef __uint16_t u16;
@@ -23,11 +26,15 @@ typedef __int32_t s32;
 #if __BYTE_ORDER == __BIG_ENDIAN
 static inline u16 cpu_to_be16(u16 value)
 {
-    return value;
+	return value;
 }
 static inline u32 cpu_to_be32(u32 value)
 {
-    return value;
+	return value;
+}
+static inline u64 cpu_to_be64(u64 value)
+{
+	return value;
 }
 #else
 static inline u16 cpu_to_be16(u16 value)
@@ -38,6 +45,21 @@ static inline u32 cpu_to_be32(u32 value)
 {
 	return cpu_to_be16(value >> 16) | (cpu_to_be16(value) << 16);
 }
+static inline u64 cpu_to_be64(u64 value)
+{
+	return cpu_to_be32(value >> 32) | ((u64)cpu_to_be32(value) << 32);
+}
+#endif
+
+#define ntohll cpu_to_be64
+#define htonll cpu_to_be64
+
+#ifndef ARRAY_SIZE
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
+#endif
+
+#ifndef SIOCETHTOOL
+#define SIOCETHTOOL     0x8946
 #endif
 
 /* National Semiconductor DP83815, DP83816 */
diff --git a/ethtool.c b/ethtool.c
index 9ad7000..15af86a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -45,16 +45,9 @@
 #include <linux/sockios.h>
 #include "ethtool-util.h"
 
-
-#ifndef SIOCETHTOOL
-#define SIOCETHTOOL     0x8946
-#endif
 #ifndef MAX_ADDR_LEN
 #define MAX_ADDR_LEN	32
 #endif
-#ifndef ARRAY_SIZE
-#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
-#endif
 
 #ifndef HAVE_NETIF_MSG
 enum {

