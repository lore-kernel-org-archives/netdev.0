From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 3/4] Add support for __be64 and bitops,
	centralize several needed macros
Date: Wed, 04 May 2011 11:41:46 -0700
Message-ID: <20110504184145.26394.86015.stgit@gitlad.jf.intel.com>
References: <20110504183752.26394.29231.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com, dm@chelsio.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2841 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753994Ab1EDSmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 14:42:02 -0400
In-Reply-To: <20110504183752.26394.29231.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to add support for __be64 values and bitops to
ethtool.  In addition the patch pulls the SIOCETHTOOL define and the
ARRAY_SIZE define into ethtool-util.h for later use by the rxclass files.
These changes will be needed in order to support network flow
classifier rule configuration.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool-bitops.h |   25 +++++++++++++++++++++++++
 ethtool-util.h   |   16 ++++++++++++++--
 2 files changed, 39 insertions(+), 2 deletions(-)
 create mode 100644 ethtool-bitops.h

diff --git a/ethtool-bitops.h b/ethtool-bitops.h
new file mode 100644
index 0000000..b1eb426
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
+static inline int test_bit(unsigned int nr, const unsigned long *addr)
+{
+	return !!((1UL << (nr % BITS_PER_LONG)) &
+		  (((unsigned long *)addr)[nr / BITS_PER_LONG]));
+}
+
+#endif
diff --git a/ethtool-util.h b/ethtool-util.h
index 6a4f3f4..d8b621c 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -15,6 +15,7 @@
 #ifndef HAVE_BE_TYPES
 typedef __uint16_t __be16;
 typedef __uint32_t __be32;
+typedef unsigned long long __be64;
 #endif
 
 typedef unsigned long long u64;
@@ -28,11 +29,15 @@ typedef __int32_t s32;
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
@@ -43,8 +48,15 @@ static inline u32 cpu_to_be32(u32 value)
 {
 	return cpu_to_be16(value >> 16) | (cpu_to_be16(value) << 16);
 }
+static inline u64 cpu_to_be64(u64 value)
+{
+	return cpu_to_be32(value >> 32) | ((u64)cpu_to_be32(value) << 32);
+}
 #endif
 
+#define ntohll cpu_to_be64
+#define htonll cpu_to_be64
+
 #ifndef ARRAY_SIZE
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #endif

