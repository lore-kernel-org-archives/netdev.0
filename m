From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/3] ipv6: Pass proto to csum_ipv6_magic as __u8
 instead of unsigned short
Date: Fri, 11 Mar 2016 14:05:41 -0800
Message-ID: <20160311220541.13431.43866.stgit@localhost.localdomain>
References: <20160311215423.13431.64512.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexander.duyck@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160311215423.13431.64512.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates csum_ipv6_magic so that it correctly recognizes that
protocol is a unsigned 8 bit value.

This will allow us to better understand what limitations may or may not be
present in how we handle the data.  For example there are a number of
places that call htonl on the protocol value.  This is likely not necessary
and can be replaced with a multiplication by ntohl(1) which will be
converted to a shift by the compiler.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 arch/alpha/include/asm/checksum.h    |    3 +--
 arch/arm/include/asm/checksum.h      |    4 ++--
 arch/frv/include/asm/checksum.h      |    2 +-
 arch/ia64/include/asm/checksum.h     |    4 ++--
 arch/m68k/include/asm/checksum.h     |    2 +-
 arch/mips/include/asm/checksum.h     |    2 +-
 arch/parisc/include/asm/checksum.h   |    2 +-
 arch/score/include/asm/checksum.h    |    5 ++---
 arch/sh/include/asm/checksum_32.h    |    3 +--
 arch/sparc/include/asm/checksum_32.h |    3 +--
 arch/sparc/include/asm/checksum_64.h |    3 +--
 arch/x86/include/asm/checksum_32.h   |    3 +--
 arch/x86/include/asm/checksum_64.h   |    2 +-
 arch/x86/lib/csum-wrappers_64.c      |    2 +-
 arch/x86/um/asm/checksum_32.h        |    2 +-
 arch/xtensa/include/asm/checksum.h   |    2 +-
 include/net/ip6_checksum.h           |    3 +--
 net/ipv6/ip6_checksum.c              |    3 +--
 18 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/arch/alpha/include/asm/checksum.h b/arch/alpha/include/asm/checksum.h
index cba34b1c738c..f2bbdd2ace51 100644
--- a/arch/alpha/include/asm/checksum.h
+++ b/arch/alpha/include/asm/checksum.h
@@ -67,6 +67,5 @@ static inline __sum16 csum_fold(__wsum csum)
 #define _HAVE_ARCH_IPV6_CSUM
 extern __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			       const struct in6_addr *daddr,
-			       __u32 len, unsigned short proto,
-			       __wsum sum);
+			       __u32 len, __u8 proto, __wsum sum);
 #endif
diff --git a/arch/arm/include/asm/checksum.h b/arch/arm/include/asm/checksum.h
index 42d020b7dfba..524692f4acab 100644
--- a/arch/arm/include/asm/checksum.h
+++ b/arch/arm/include/asm/checksum.h
@@ -144,8 +144,8 @@ __csum_ipv6_magic(const struct in6_addr *saddr, const struct in6_addr *daddr, __
 		__be32 proto, __wsum sum);
 
 static inline __sum16
-csum_ipv6_magic(const struct in6_addr *saddr, const struct in6_addr *daddr, __u32 len,
-		unsigned short proto, __wsum sum)
+csum_ipv6_magic(const struct in6_addr *saddr, const struct in6_addr *daddr,
+		__u32 len, __u8 proto, __wsum sum)
 {
 	return csum_fold(__csum_ipv6_magic(saddr, daddr, htonl(len),
 					   htonl(proto), sum));
diff --git a/arch/frv/include/asm/checksum.h b/arch/frv/include/asm/checksum.h
index cd59cd4fd2d9..b77388c5901d 100644
--- a/arch/frv/include/asm/checksum.h
+++ b/arch/frv/include/asm/checksum.h
@@ -135,7 +135,7 @@ extern __sum16 ip_compute_csum(const void *buff, int len);
 #define _HAVE_ARCH_IPV6_CSUM
 static inline __sum16
 csum_ipv6_magic(const struct in6_addr *saddr, const struct in6_addr *daddr,
-		__u32 len, unsigned short proto, __wsum sum)
+		__u32 len, __u8 proto, __wsum sum)
 {
 	unsigned long tmp, tmp2;
 
diff --git a/arch/ia64/include/asm/checksum.h b/arch/ia64/include/asm/checksum.h
index ac9c687e8384..7accf54162b2 100644
--- a/arch/ia64/include/asm/checksum.h
+++ b/arch/ia64/include/asm/checksum.h
@@ -69,7 +69,7 @@ static inline __sum16 csum_fold(__wsum csum)
 #define _HAVE_ARCH_IPV6_CSUM	1
 struct in6_addr;
 extern __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
-	const struct in6_addr *daddr, __u32 len, unsigned short proto,
-	__wsum csum);
+			       const struct in6_addr *daddr,
+			       __u32 len, __u8 proto, __wsum csum);
 
 #endif /* _ASM_IA64_CHECKSUM_H */
diff --git a/arch/m68k/include/asm/checksum.h b/arch/m68k/include/asm/checksum.h
index 2f88d867c711..75e91f03b178 100644
--- a/arch/m68k/include/asm/checksum.h
+++ b/arch/m68k/include/asm/checksum.h
@@ -117,7 +117,7 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 #define _HAVE_ARCH_IPV6_CSUM
 static __inline__ __sum16
 csum_ipv6_magic(const struct in6_addr *saddr, const struct in6_addr *daddr,
-		__u32 len, unsigned short proto, __wsum sum)
+		__u32 len, __u8 proto, __wsum sum)
 {
 	register unsigned long tmp;
 	__asm__("addl %2@,%0\n\t"
diff --git a/arch/mips/include/asm/checksum.h b/arch/mips/include/asm/checksum.h
index c635541d40b8..bce1ce53149a 100644
--- a/arch/mips/include/asm/checksum.h
+++ b/arch/mips/include/asm/checksum.h
@@ -215,7 +215,7 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 #define _HAVE_ARCH_IPV6_CSUM
 static __inline__ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 					  const struct in6_addr *daddr,
-					  __u32 len, unsigned short proto,
+					  __u32 len, __u8 proto,
 					  __wsum sum)
 {
 	__wsum tmp;
diff --git a/arch/parisc/include/asm/checksum.h b/arch/parisc/include/asm/checksum.h
index 9815ab1fc8aa..60c2c42619c9 100644
--- a/arch/parisc/include/asm/checksum.h
+++ b/arch/parisc/include/asm/checksum.h
@@ -122,7 +122,7 @@ static inline __sum16 ip_compute_csum(const void *buf, int len)
 #define _HAVE_ARCH_IPV6_CSUM
 static __inline__ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 					  const struct in6_addr *daddr,
-					  __u32 len, unsigned short proto,
+					  __u32 len, __u8 proto,
 					  __wsum sum)
 {
 	__asm__ __volatile__ (
diff --git a/arch/score/include/asm/checksum.h b/arch/score/include/asm/checksum.h
index a375bc2700be..539d9fd45d21 100644
--- a/arch/score/include/asm/checksum.h
+++ b/arch/score/include/asm/checksum.h
@@ -179,9 +179,8 @@ static inline unsigned short ip_compute_csum(const void *buff, int len)
 
 #define _HAVE_ARCH_IPV6_CSUM
 static inline __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
-				const struct in6_addr *daddr,
-				__u32 len, unsigned short proto,
-				__wsum sum)
+				      const struct in6_addr *daddr,
+				      __u32 len, __u8 proto, __wsum sum)
 {
 	__asm__ __volatile__(
 		".set\tvolatile\t\t\t# csum_ipv6_magic\n\t"
diff --git a/arch/sh/include/asm/checksum_32.h b/arch/sh/include/asm/checksum_32.h
index fd730f140c06..9c84386d35cb 100644
--- a/arch/sh/include/asm/checksum_32.h
+++ b/arch/sh/include/asm/checksum_32.h
@@ -159,8 +159,7 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 #define _HAVE_ARCH_IPV6_CSUM
 static inline __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 				      const struct in6_addr *daddr,
-				      __u32 len, unsigned short proto,
-				      __wsum sum)
+				      __u32 len, __u8 proto, __wsum sum)
 {
 	unsigned int __dummy;
 	__asm__("clrt\n\t"
diff --git a/arch/sparc/include/asm/checksum_32.h b/arch/sparc/include/asm/checksum_32.h
index 86ae655a3c0f..eff748c871ec 100644
--- a/arch/sparc/include/asm/checksum_32.h
+++ b/arch/sparc/include/asm/checksum_32.h
@@ -199,8 +199,7 @@ static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
 
 static inline __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 				      const struct in6_addr *daddr,
-				      __u32 len, unsigned short proto,
-				      __wsum sum)
+				      __u32 len, __u8 proto, __wsum sum)
 {
 	__asm__ __volatile__ (
 		"addcc	%3, %4, %%g4\n\t"
diff --git a/arch/sparc/include/asm/checksum_64.h b/arch/sparc/include/asm/checksum_64.h
index ef0c6f48189a..0395d75322e9 100644
--- a/arch/sparc/include/asm/checksum_64.h
+++ b/arch/sparc/include/asm/checksum_64.h
@@ -125,8 +125,7 @@ static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
 
 static inline __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 				      const struct in6_addr *daddr,
-				      __u32 len, unsigned short proto,
-				      __wsum sum)
+				      __u32 len, __u8 proto, __wsum sum)
 {
 	__asm__ __volatile__ (
 "	addcc		%3, %4, %%g7\n"
diff --git a/arch/x86/include/asm/checksum_32.h b/arch/x86/include/asm/checksum_32.h
index 6f380605403d..532f85e6651f 100644
--- a/arch/x86/include/asm/checksum_32.h
+++ b/arch/x86/include/asm/checksum_32.h
@@ -149,8 +149,7 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 #define _HAVE_ARCH_IPV6_CSUM
 static inline __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 				      const struct in6_addr *daddr,
-				      __u32 len, unsigned short proto,
-				      __wsum sum)
+				      __u32 len, __u8 proto, __wsum sum)
 {
 	asm("addl 0(%1), %0	;\n"
 	    "adcl 4(%1), %0	;\n"
diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index 97b98e2039bc..c020ee75dce7 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -177,7 +177,7 @@ struct in6_addr;
 #define _HAVE_ARCH_IPV6_CSUM 1
 extern __sum16
 csum_ipv6_magic(const struct in6_addr *saddr, const struct in6_addr *daddr,
-		__u32 len, unsigned short proto, __wsum sum);
+		__u32 len, __u8 proto, __wsum sum);
 
 static inline unsigned add32_with_carry(unsigned a, unsigned b)
 {
diff --git a/arch/x86/lib/csum-wrappers_64.c b/arch/x86/lib/csum-wrappers_64.c
index 1318f75d56e4..28a6654f0d08 100644
--- a/arch/x86/lib/csum-wrappers_64.c
+++ b/arch/x86/lib/csum-wrappers_64.c
@@ -135,7 +135,7 @@ EXPORT_SYMBOL(csum_partial_copy_nocheck);
 
 __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			const struct in6_addr *daddr,
-			__u32 len, unsigned short proto, __wsum sum)
+			__u32 len, __u8 proto, __wsum sum)
 {
 	__u64 rest, sum64;
 
diff --git a/arch/x86/um/asm/checksum_32.h b/arch/x86/um/asm/checksum_32.h
index ab77b6f9a4bf..83a75f8a1233 100644
--- a/arch/x86/um/asm/checksum_32.h
+++ b/arch/x86/um/asm/checksum_32.h
@@ -13,7 +13,7 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 #define _HAVE_ARCH_IPV6_CSUM
 static __inline__ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 					  const struct in6_addr *daddr,
-					  __u32 len, unsigned short proto,
+					  __u32 len, __u8 proto,
 					  __wsum sum)
 {
 	__asm__(
diff --git a/arch/xtensa/include/asm/checksum.h b/arch/xtensa/include/asm/checksum.h
index 62254e6688f5..ec35074fcb03 100644
--- a/arch/xtensa/include/asm/checksum.h
+++ b/arch/xtensa/include/asm/checksum.h
@@ -175,7 +175,7 @@ static __inline__ __sum16 ip_compute_csum(const void *buff, int len)
 #define _HAVE_ARCH_IPV6_CSUM
 static __inline__ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 					  const struct in6_addr *daddr,
-					  __u32 len, unsigned short proto,
+					  __u32 len, __u8 proto,
 					  __wsum sum)
 {
 	unsigned int __dummy;
diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 1a49b73f7f6e..cca840584c88 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -37,8 +37,7 @@
 #ifndef _HAVE_ARCH_IPV6_CSUM
 __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			const struct in6_addr *daddr,
-			__u32 len, unsigned short proto,
-			__wsum csum);
+			__u32 len, __u8 proto, __wsum csum);
 #endif
 
 static inline __wsum ip6_compute_pseudo(struct sk_buff *skb, int proto)
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index 8f920580976f..b2025bf3da4a 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -6,8 +6,7 @@
 #ifndef _HAVE_ARCH_IPV6_CSUM
 __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			const struct in6_addr *daddr,
-			__u32 len, unsigned short proto,
-			__wsum csum)
+			__u32 len, __u8 proto, __wsum csum)
 {
 
 	int carry;
