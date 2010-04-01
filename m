From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] net: add support for htonb and ntohb
Date: Thu, 1 Apr 2010 16:32:10 -0400
Message-ID: <20100401203209.GC28741@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757471Ab0DAUcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 16:32:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After my recent post to net-2.6 this week to accidentally run htons to a
u8, it is clear to me we _must_ add some infrastructure to make sure
single bytes are in the correct network and host order on big and little
endian systems.  Today seemed like the perfect day to post this.

This patch adds basic support for htonb and ntohb.  Patches to add this
in the entire networking tree in _every_ case where a single byte is
accessed will be posted next week -- I'm almost done with them!

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 byteorder/big_endian.h    |   30 ++++++++++++++++++++++++++
 byteorder/generic.h       |    6 +++++
 byteorder/little_endian.h |   30 ++++++++++++++++++++++++++
 swab.h                    |   53 ++++++++++++++++++++++++++++++++++++++++++++--
 types.h                   |    2 +
 5 files changed, 119 insertions(+), 2 deletions(-)

diff --git a/include/linux/byteorder/big_endian.h b/include/linux/byteorder/big_endian.h
index 3c80fd7..87f1089 100644
--- a/include/linux/byteorder/big_endian.h
+++ b/include/linux/byteorder/big_endian.h
@@ -15,30 +15,40 @@
 #define __constant_ntohl(x) ((__force __u32)(__be32)(x))
 #define __constant_htons(x) ((__force __be16)(__u16)(x))
 #define __constant_ntohs(x) ((__force __u16)(__be16)(x))
+#define __constant_htonb(x) ((__force __be8)(__u8)(x))
+#define __constant_ntohb(x) ((__force __u8)(__be8)(x))
 #define __constant_cpu_to_le64(x) ((__force __le64)___constant_swab64((x)))
 #define __constant_le64_to_cpu(x) ___constant_swab64((__force __u64)(__le64)(x))
 #define __constant_cpu_to_le32(x) ((__force __le32)___constant_swab32((x)))
 #define __constant_le32_to_cpu(x) ___constant_swab32((__force __u32)(__le32)(x))
 #define __constant_cpu_to_le16(x) ((__force __le16)___constant_swab16((x)))
 #define __constant_le16_to_cpu(x) ___constant_swab16((__force __u16)(__le16)(x))
+#define __constant_cpu_to_le8(x) ((__force __le8)___constant_swab8((x)))
+#define __constant_le8_to_cpu(x) ___constant_swab8((__force __u8)(__le8)(x))
 #define __constant_cpu_to_be64(x) ((__force __be64)(__u64)(x))
 #define __constant_be64_to_cpu(x) ((__force __u64)(__be64)(x))
 #define __constant_cpu_to_be32(x) ((__force __be32)(__u32)(x))
 #define __constant_be32_to_cpu(x) ((__force __u32)(__be32)(x))
 #define __constant_cpu_to_be16(x) ((__force __be16)(__u16)(x))
 #define __constant_be16_to_cpu(x) ((__force __u16)(__be16)(x))
+#define __constant_cpu_to_be8(x) ((__force __be8)(__u8)(x))
+#define __constant_be8_to_cpu(x) ((__force __u8)(__be8)(x))
 #define __cpu_to_le64(x) ((__force __le64)__swab64((x)))
 #define __le64_to_cpu(x) __swab64((__force __u64)(__le64)(x))
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
 #define __le32_to_cpu(x) __swab32((__force __u32)(__le32)(x))
 #define __cpu_to_le16(x) ((__force __le16)__swab16((x)))
 #define __le16_to_cpu(x) __swab16((__force __u16)(__le16)(x))
+#define __cpu_to_le8(x) ((__force __le8)__swab8((x)))
+#define __le8_to_cpu(x) __swab8((__force __u8)(__le8)(x))
 #define __cpu_to_be64(x) ((__force __be64)(__u64)(x))
 #define __be64_to_cpu(x) ((__force __u64)(__be64)(x))
 #define __cpu_to_be32(x) ((__force __be32)(__u32)(x))
 #define __be32_to_cpu(x) ((__force __u32)(__be32)(x))
 #define __cpu_to_be16(x) ((__force __be16)(__u16)(x))
 #define __be16_to_cpu(x) ((__force __u16)(__be16)(x))
+#define __cpu_to_be8(x) ((__force __be8)(__u8)(x))
+#define __be8_to_cpu(x) ((__force __u8)(__be8)(x))
 
 static inline __le64 __cpu_to_le64p(const __u64 *p)
 {
@@ -64,6 +74,14 @@ static inline __u16 __le16_to_cpup(const __le16 *p)
 {
 	return __swab16p((__u16 *)p);
 }
+static inline __le8 __cpu_to_le8p(const __u8 *p)
+{
+	return (__force __le8)__swab8p(p);
+}
+static inline __u8 __le8_to_cpup(const __le8 *p)
+{
+	return __swab8p((__u8 *)p);
+}
 static inline __be64 __cpu_to_be64p(const __u64 *p)
 {
 	return (__force __be64)*p;
@@ -88,18 +106,30 @@ static inline __u16 __be16_to_cpup(const __be16 *p)
 {
 	return (__force __u16)*p;
 }
+static inline __be8 __cpu_to_be8p(const __u8 *p)
+{
+	return (__force __be8)*p;
+}
+static inline __u8 __be8_to_cpup(const __be8 *p)
+{
+	return (__force __u8)*p;
+}
 #define __cpu_to_le64s(x) __swab64s((x))
 #define __le64_to_cpus(x) __swab64s((x))
 #define __cpu_to_le32s(x) __swab32s((x))
 #define __le32_to_cpus(x) __swab32s((x))
 #define __cpu_to_le16s(x) __swab16s((x))
 #define __le16_to_cpus(x) __swab16s((x))
+#define __cpu_to_le8s(x) __swab8s((x))
+#define __le8_to_cpus(x) __swab8s((x))
 #define __cpu_to_be64s(x) do { (void)(x); } while (0)
 #define __be64_to_cpus(x) do { (void)(x); } while (0)
 #define __cpu_to_be32s(x) do { (void)(x); } while (0)
 #define __be32_to_cpus(x) do { (void)(x); } while (0)
 #define __cpu_to_be16s(x) do { (void)(x); } while (0)
 #define __be16_to_cpus(x) do { (void)(x); } while (0)
+#define __cpu_to_be8s(x) do { (void)(x); } while (0)
+#define __be8_to_cpus(x) do { (void)(x); } while (0)
 
 #ifdef __KERNEL__
 #include <linux/byteorder/generic.h>
diff --git a/include/linux/byteorder/generic.h b/include/linux/byteorder/generic.h
index 0846e6b..11c9f36 100644
--- a/include/linux/byteorder/generic.h
+++ b/include/linux/byteorder/generic.h
@@ -127,18 +127,24 @@
 
 #undef ntohl
 #undef ntohs
+#undef ntohb
 #undef htonl
 #undef htons
+#undef htonb
 
 #define ___htonl(x) __cpu_to_be32(x)
 #define ___htons(x) __cpu_to_be16(x)
+#define ___htonb(x) __cpu_to_be8(x)
 #define ___ntohl(x) __be32_to_cpu(x)
 #define ___ntohs(x) __be16_to_cpu(x)
+#define ___ntohb(x) __be8_to_cpu(x)
 
 #define htonl(x) ___htonl(x)
 #define ntohl(x) ___ntohl(x)
 #define htons(x) ___htons(x)
 #define ntohs(x) ___ntohs(x)
+#define htonb(x) ___htonb(x)
+#define ntohb(x) ___ntohb(x)
 
 static inline void le16_add_cpu(__le16 *var, u16 val)
 {
diff --git a/include/linux/byteorder/little_endian.h b/include/linux/byteorder/little_endian.h
index 83195fb..ef862db 100644
--- a/include/linux/byteorder/little_endian.h
+++ b/include/linux/byteorder/little_endian.h
@@ -15,30 +15,40 @@
 #define __constant_ntohl(x) ___constant_swab32((__force __be32)(x))
 #define __constant_htons(x) ((__force __be16)___constant_swab16((x)))
 #define __constant_ntohs(x) ___constant_swab16((__force __be16)(x))
+#define __constant_htonb(x) ((__force __be8)___constant_swab8((x)))
+#define __constant_ntohb(x) ___constant_swab8((__force __be8)(x))
 #define __constant_cpu_to_le64(x) ((__force __le64)(__u64)(x))
 #define __constant_le64_to_cpu(x) ((__force __u64)(__le64)(x))
 #define __constant_cpu_to_le32(x) ((__force __le32)(__u32)(x))
 #define __constant_le32_to_cpu(x) ((__force __u32)(__le32)(x))
 #define __constant_cpu_to_le16(x) ((__force __le16)(__u16)(x))
 #define __constant_le16_to_cpu(x) ((__force __u16)(__le16)(x))
+#define __constant_cpu_to_le8(x) ((__force __le8)(__u8)(x))
+#define __constant_le8_to_cpu(x) ((__force __u8)(__le8)(x))
 #define __constant_cpu_to_be64(x) ((__force __be64)___constant_swab64((x)))
 #define __constant_be64_to_cpu(x) ___constant_swab64((__force __u64)(__be64)(x))
 #define __constant_cpu_to_be32(x) ((__force __be32)___constant_swab32((x)))
 #define __constant_be32_to_cpu(x) ___constant_swab32((__force __u32)(__be32)(x))
 #define __constant_cpu_to_be16(x) ((__force __be16)___constant_swab16((x)))
 #define __constant_be16_to_cpu(x) ___constant_swab16((__force __u16)(__be16)(x))
+#define __constant_cpu_to_be8(x) ((__force __be8)___constant_swab8((x)))
+#define __constant_be8_to_cpu(x) ___constant_swab8((__force __u8)(__be8)(x))
 #define __cpu_to_le64(x) ((__force __le64)(__u64)(x))
 #define __le64_to_cpu(x) ((__force __u64)(__le64)(x))
 #define __cpu_to_le32(x) ((__force __le32)(__u32)(x))
 #define __le32_to_cpu(x) ((__force __u32)(__le32)(x))
 #define __cpu_to_le16(x) ((__force __le16)(__u16)(x))
 #define __le16_to_cpu(x) ((__force __u16)(__le16)(x))
+#define __cpu_to_le8(x) ((__force __le8)(__u8)(x))
+#define __le8_to_cpu(x) ((__force __u8)(__le8)(x))
 #define __cpu_to_be64(x) ((__force __be64)__swab64((x)))
 #define __be64_to_cpu(x) __swab64((__force __u64)(__be64)(x))
 #define __cpu_to_be32(x) ((__force __be32)__swab32((x)))
 #define __be32_to_cpu(x) __swab32((__force __u32)(__be32)(x))
 #define __cpu_to_be16(x) ((__force __be16)__swab16((x)))
 #define __be16_to_cpu(x) __swab16((__force __u16)(__be16)(x))
+#define __cpu_to_be8(x) ((__force __be8)__swab8((x)))
+#define __be8_to_cpu(x) __swab8((__force __u8)(__be8)(x))
 
 static inline __le64 __cpu_to_le64p(const __u64 *p)
 {
@@ -64,6 +74,14 @@ static inline __u16 __le16_to_cpup(const __le16 *p)
 {
 	return (__force __u16)*p;
 }
+static inline __le8 __cpu_to_le8p(const __u8 *p)
+{
+	return (__force __le8)*p;
+}
+static inline __u8 __le8_to_cpup(const __le8 *p)
+{
+	return (__force __u8)*p;
+}
 static inline __be64 __cpu_to_be64p(const __u64 *p)
 {
 	return (__force __be64)__swab64p(p);
@@ -88,18 +106,30 @@ static inline __u16 __be16_to_cpup(const __be16 *p)
 {
 	return __swab16p((__u16 *)p);
 }
+static inline __be8 __cpu_to_be8p(const __u8 *p)
+{
+	return (__force __be8)__swab8p(p);
+}
+static inline __u8 __be8_to_cpup(const __be8 *p)
+{
+	return __swab8p((__u8 *)p);
+}
 #define __cpu_to_le64s(x) do { (void)(x); } while (0)
 #define __le64_to_cpus(x) do { (void)(x); } while (0)
 #define __cpu_to_le32s(x) do { (void)(x); } while (0)
 #define __le32_to_cpus(x) do { (void)(x); } while (0)
 #define __cpu_to_le16s(x) do { (void)(x); } while (0)
 #define __le16_to_cpus(x) do { (void)(x); } while (0)
+#define __cpu_to_le8s(x) do { (void)(x); } while (0)
+#define __le8_to_cpus(x) do { (void)(x); } while (0)
 #define __cpu_to_be64s(x) __swab64s((x))
 #define __be64_to_cpus(x) __swab64s((x))
 #define __cpu_to_be32s(x) __swab32s((x))
 #define __be32_to_cpus(x) __swab32s((x))
 #define __cpu_to_be16s(x) __swab16s((x))
 #define __be16_to_cpus(x) __swab16s((x))
+#define __cpu_to_be8s(x) __swab8s((x))
+#define __be8_to_cpus(x) __swab8s((x))
 
 #ifdef __KERNEL__
 #include <linux/byteorder/generic.h>
diff --git a/include/linux/swab.h b/include/linux/swab.h
index ea0c02f..043d9a6 100644
--- a/include/linux/swab.h
+++ b/include/linux/swab.h
@@ -7,8 +7,11 @@
 
 /*
  * casts are necessary for constants, because we never know how for sure
- * how U/UL/ULL map to __u16, __u32, __u64. At least not in a portable way.
+ * how U/UL/ULL map to __u8, __u16, __u32, __u64. At least not in a portable way.
  */
+#define ___constant_swab8(x) ((__u8)(				\
+	(((__u8)(x) & (__u8)0xffU) << 8)))
+
 #define ___constant_swab16(x) ((__u16)(				\
 	(((__u16)(x) & (__u16)0x00ffU) << 8) |			\
 	(((__u16)(x) & (__u16)0xff00U) >> 8)))
@@ -40,9 +43,18 @@
 /*
  * Implement the following as inlines, but define the interface using
  * macros to allow constant folding when possible:
- * ___swab16, ___swab32, ___swab64, ___swahw32, ___swahb32
+ * ___swab8, ___swab16, ___swab32, ___swab64, ___swahw32, ___swahb32
  */
 
+static inline __attribute_const__ __u8 __fswab8(__u8 val)
+{
+#ifdef __arch_swab8
+	return __arch_swab8(val);
+#else
+	return ___constant_swab8(val);
+#endif
+}
+
 static inline __attribute_const__ __u16 __fswab16(__u16 val)
 {
 #ifdef __arch_swab16
@@ -93,6 +105,15 @@ static inline __attribute_const__ __u32 __fswahb32(__u32 val)
 }
 
 /**
+ * __swab8 - return an 8-bit value
+ * @x: value to not byteswap
+ */
+#define __swab8(x)				\
+	(__builtin_constant_p((__u8)(x)) ?	\
+	___constant_swab8(x) :			\
+	__fswab8(x))
+
+/**
  * __swab16 - return a byteswapped 16-bit value
  * @x: value to byteswap
  */
@@ -142,6 +163,19 @@ static inline __attribute_const__ __u32 __fswahb32(__u32 val)
 	__fswahb32(x))
 
 /**
+ * __swab8p - return an 8-bit value from a pointer
+ * @p: pointer to a naturally-aligned 8-bit value
+ */
+static inline __u8 __swab8p(const __u8 *p)
+{
+#ifdef __arch_swab8p
+	return __arch_swab8p(p);
+#else
+	return __swab8(*p);
+#endif
+}
+
+/**
  * __swab16p - return a byteswapped 16-bit value from a pointer
  * @p: pointer to a naturally-aligned 16-bit value
  */
@@ -211,6 +245,18 @@ static inline __u32 __swahb32p(const __u32 *p)
 }
 
 /**
+ * __swab8s - do not byteswap an 8-bit value in-place
+ * @p: pointer to a naturally-aligned 8-bit value
+ */
+static inline void __swab8s(__u8 *p)
+{
+#ifdef __arch_swab8s
+	__arch_swab8s(p);
+#else
+	*p = __swab8p(p);
+#endif
+}
+/**
  * __swab16s - byteswap a 16-bit value in-place
  * @p: pointer to a naturally-aligned 16-bit value
  */
@@ -279,16 +325,19 @@ static inline void __swahb32s(__u32 *p)
 }
 
 #ifdef __KERNEL__
+# define swab8 __swab8
 # define swab16 __swab16
 # define swab32 __swab32
 # define swab64 __swab64
 # define swahw32 __swahw32
 # define swahb32 __swahb32
+# define swab8p __swab8p
 # define swab16p __swab16p
 # define swab32p __swab32p
 # define swab64p __swab64p
 # define swahw32p __swahw32p
 # define swahb32p __swahb32p
+# define swab8s __swab8s
 # define swab16s __swab16s
 # define swab32s __swab32s
 # define swab64s __swab64s
diff --git a/include/linux/types.h b/include/linux/types.h
index c42724f..f8a0a0f 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -165,6 +165,8 @@ typedef unsigned long blkcnt_t;
 #define __bitwise
 #endif
 
+typedef __u8 __bitwise __le8;
+typedef __u8 __bitwise __be8;
 typedef __u16 __bitwise __le16;
 typedef __u16 __bitwise __be16;
 typedef __u32 __bitwise __le32;
