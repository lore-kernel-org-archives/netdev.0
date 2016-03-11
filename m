From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/3] ipv4: Update parameters for csum_tcpudp_magic
 to their original types
Date: Fri, 11 Mar 2016 14:05:34 -0800
Message-ID: <20160311220534.13431.2332.stgit@localhost.localdomain>
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

This patch updates all instances of csum_tcpudp_magic and
csum_tcpudp_nofold to reflect the types that are usually used as the source
inputs.  For example the protocol field is populated based on nexthdr which
is actually an unsigned 8 bit value.  The length is usually populated based
on skb->len which is an unsigned integer.

This addresses an issue in which the IPv6 function csum_ipv6_magic was
generating a checksum using the full 32b of skb->len while
csum_tcpudp_magic was only using the lower 16 bits.  As a result we could
run into issues when attempting to adjust the checksum as there was no
protocol agnostic way to update it.

With this change the value is still truncated as many architectures use
"(len + proto) << 8", however this truncation only occurs for values
greater than 16776960 in length and as such is unlikely to occur as we stop
the inner headers at ~64K in size.

I did have to make a few minor changes in the arm, mn10300, nios2, and
score versions of the function in order to support these changes as they
were either using things such as an OR to combine the protocol and length,
or were using ntohs to convert the length which would have truncated the
value.

I also updated a few spots in terms of whitespace and type differences for
the addresses.  Most of this was just to make sure all of the definitions
were in sync going forward.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 arch/alpha/include/asm/checksum.h          |    9 +++------
 arch/alpha/lib/checksum.c                  |    8 ++------
 arch/arc/include/asm/checksum.h            |    4 ++--
 arch/arm/include/asm/checksum.h            |   10 +++++-----
 arch/avr32/include/asm/checksum.h          |   10 ++++------
 arch/blackfin/include/asm/checksum.h       |    4 ++--
 arch/c6x/include/asm/checksum.h            |    4 ++--
 arch/cris/include/arch-v10/arch/checksum.h |    4 ++--
 arch/cris/include/arch-v32/arch/checksum.h |    2 +-
 arch/cris/include/asm/checksum.h           |    5 ++---
 arch/frv/include/asm/checksum.h            |    8 ++++----
 arch/hexagon/include/asm/checksum.h        |    8 ++++----
 arch/hexagon/lib/checksum.c                |   10 ++++------
 arch/ia64/include/asm/checksum.h           |   12 ++++--------
 arch/ia64/lib/checksum.c                   |    8 ++++----
 arch/m32r/include/asm/checksum.h           |   10 ++++------
 arch/metag/include/asm/checksum.h          |    7 +++----
 arch/microblaze/include/asm/checksum.h     |    4 ++--
 arch/mips/include/asm/checksum.h           |    6 +++---
 arch/mn10300/include/asm/checksum.h        |   17 +++++------------
 arch/nios2/include/asm/checksum.h          |    9 ++++-----
 arch/parisc/include/asm/checksum.h         |   10 ++++------
 arch/s390/include/asm/checksum.h           |    6 ++----
 arch/score/include/asm/checksum.h          |   10 +++++-----
 arch/sh/include/asm/checksum_32.h          |    6 ++----
 arch/sparc/include/asm/checksum_32.h       |   10 ++++------
 arch/sparc/include/asm/checksum_64.h       |    6 ++----
 arch/unicore32/include/asm/checksum.h      |    4 ++--
 arch/x86/include/asm/checksum_32.h         |    6 ++----
 arch/x86/include/asm/checksum_64.h         |    8 ++++----
 arch/x86/um/asm/checksum.h                 |    9 ++++-----
 arch/xtensa/include/asm/checksum.h         |   10 ++++------
 include/asm-generic/checksum.h             |    8 ++++----
 lib/checksum.c                             |    4 +---
 34 files changed, 106 insertions(+), 150 deletions(-)

diff --git a/arch/alpha/include/asm/checksum.h b/arch/alpha/include/asm/checksum.h
index d3854bbf0a9e..cba34b1c738c 100644
--- a/arch/alpha/include/asm/checksum.h
+++ b/arch/alpha/include/asm/checksum.h
@@ -13,14 +13,11 @@ extern __sum16 ip_fast_csum(const void *iph, unsigned int ihl);
  * computes the checksum of the TCP/UDP pseudo-header
  * returns a 16-bit checksum, already complemented
  */
-extern __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					   unsigned short len,
-					   unsigned short proto,
-					   __wsum sum);
+__sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
+			  __u32 len, __u8 proto, __wsum sum);
 
 __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-				unsigned short len, unsigned short proto,
-				__wsum sum);
+			  __u32 len, __u8 proto, __wsum sum);
 
 /*
  * computes the checksum of a memory block at buff, length len,
diff --git a/arch/alpha/lib/checksum.c b/arch/alpha/lib/checksum.c
index 199f6efa83fa..377f9e34eb97 100644
--- a/arch/alpha/lib/checksum.c
+++ b/arch/alpha/lib/checksum.c
@@ -42,9 +42,7 @@ static inline unsigned short from64to16(unsigned long x)
  * returns a 16-bit checksum, already complemented.
  */
 __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-				   unsigned short len,
-				   unsigned short proto,
-				   __wsum sum)
+			  __u32 len, __u8 proto, __wsum sum)
 {
 	return (__force __sum16)~from64to16(
 		(__force u64)saddr + (__force u64)daddr +
@@ -52,9 +50,7 @@ __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
 }
 
 __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-				   unsigned short len,
-				   unsigned short proto,
-				   __wsum sum)
+			  __u32 len, __u8 proto, __wsum sum)
 {
 	unsigned long result;
 
diff --git a/arch/arc/include/asm/checksum.h b/arch/arc/include/asm/checksum.h
index 10957298b7a3..913eb4aab05b 100644
--- a/arch/arc/include/asm/checksum.h
+++ b/arch/arc/include/asm/checksum.h
@@ -70,8 +70,8 @@ ip_fast_csum(const void *iph, unsigned int ihl)
  * SA [4], DA [4], zeroes [1], Proto[1], TCP Seg(hdr+data) Len [2]
  */
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	__asm__ __volatile__(
 	"	add.f %0, %0, %1	\n"
diff --git a/arch/arm/include/asm/checksum.h b/arch/arm/include/asm/checksum.h
index 523315115478..42d020b7dfba 100644
--- a/arch/arm/include/asm/checksum.h
+++ b/arch/arm/include/asm/checksum.h
@@ -84,10 +84,10 @@ ip_fast_csum(const void *iph, unsigned int ihl)
 }
 
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
-	u32 lenprot = len | proto << 16;
+	u32 lenprot = len + proto;
 	if (__builtin_constant_p(sum) && sum == 0) {
 		__asm__(
 		"adds	%0, %1, %2	@ csum_tcpudp_nofold0	\n\t"
@@ -121,8 +121,8 @@ csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16
-csum_tcpudp_magic(__be32 saddr, __be32 daddr, unsigned short len,
-		  unsigned short proto, __wsum sum)
+csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
+		  __u8 proto, __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
 }
diff --git a/arch/avr32/include/asm/checksum.h b/arch/avr32/include/asm/checksum.h
index 4ddbfd2486af..4ab7d5bdaf53 100644
--- a/arch/avr32/include/asm/checksum.h
+++ b/arch/avr32/include/asm/checksum.h
@@ -111,9 +111,8 @@ static inline __sum16 csum_fold(__wsum sum)
 }
 
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					       unsigned short len,
-					       unsigned short proto,
-					       __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	asm("	add	%0, %1\n"
 	    "	adc	%0, %0, %2\n"
@@ -132,9 +131,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-						   unsigned short len,
-						   unsigned short proto,
-						   __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/arch/blackfin/include/asm/checksum.h b/arch/blackfin/include/asm/checksum.h
index 623cc7fb00bc..e7134bf94e3c 100644
--- a/arch/blackfin/include/asm/checksum.h
+++ b/arch/blackfin/include/asm/checksum.h
@@ -14,8 +14,8 @@
  */
 
 static inline __wsum
-__csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+__csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		     __u8 proto, __wsum sum)
 {
 	unsigned int carry;
 
diff --git a/arch/c6x/include/asm/checksum.h b/arch/c6x/include/asm/checksum.h
index 7246816d6e4d..249b0e421ddc 100644
--- a/arch/c6x/include/asm/checksum.h
+++ b/arch/c6x/include/asm/checksum.h
@@ -10,8 +10,8 @@
 #define _ASM_C6X_CHECKSUM_H
 
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	unsigned long long tmp;
 
diff --git a/arch/cris/include/arch-v10/arch/checksum.h b/arch/cris/include/arch-v10/arch/checksum.h
index b8000c5d7fe1..d1d1bd9e1090 100644
--- a/arch/cris/include/arch-v10/arch/checksum.h
+++ b/arch/cris/include/arch-v10/arch/checksum.h
@@ -9,8 +9,8 @@
  */
 
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	__wsum res;
 	__asm__ ("add.d %2, %0\n\t"
diff --git a/arch/cris/include/arch-v32/arch/checksum.h b/arch/cris/include/arch-v32/arch/checksum.h
index e5dcfce6e0dc..65cf205b1329 100644
--- a/arch/cris/include/arch-v32/arch/checksum.h
+++ b/arch/cris/include/arch-v32/arch/checksum.h
@@ -11,7 +11,7 @@
  */
 static inline __wsum
 csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-		   unsigned short len, unsigned short proto, __wsum sum)
+		   __u32 len, __u8 proto, __wsum sum)
 {
 	__wsum res;
 
diff --git a/arch/cris/include/asm/checksum.h b/arch/cris/include/asm/checksum.h
index 75dcb77d6cb0..ea949c60b190 100644
--- a/arch/cris/include/asm/checksum.h
+++ b/arch/cris/include/asm/checksum.h
@@ -63,9 +63,8 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
  */
 
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-						   unsigned short len,
-						   unsigned short proto,
-						   __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/arch/frv/include/asm/checksum.h b/arch/frv/include/asm/checksum.h
index 269da09ff637..cd59cd4fd2d9 100644
--- a/arch/frv/include/asm/checksum.h
+++ b/arch/frv/include/asm/checksum.h
@@ -105,8 +105,8 @@ static inline __sum16 csum_fold(__wsum sum)
  * returns a 16-bit checksum, already complemented
  */
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		  unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	asm("	addcc		%1,%0,%0,icc0	\n"
 	    "	addxcc		%2,%0,%0,icc0	\n"
@@ -120,8 +120,8 @@ csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
 }
 
 static inline __sum16
-csum_tcpudp_magic(__be32 saddr, __be32 daddr, unsigned short len,
-		  unsigned short proto, __wsum sum)
+csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
+		  __u8 proto, __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/arch/hexagon/include/asm/checksum.h b/arch/hexagon/include/asm/checksum.h
index 46ec8a7fd65f..d9f58d696238 100644
--- a/arch/hexagon/include/asm/checksum.h
+++ b/arch/hexagon/include/asm/checksum.h
@@ -38,12 +38,12 @@ __wsum csum_partial_copy_nocheck(const void *src, void *dst,
  * returns a 16-bit checksum, already complemented
  */
 #define csum_tcpudp_nofold csum_tcpudp_nofold
-__wsum csum_tcpudp_nofold(unsigned long saddr, unsigned long daddr,
-	unsigned short len, unsigned short proto, __wsum sum);
+__wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
+			  __u32 len, __u8 proto, __wsum sum);
 
 #define csum_tcpudp_magic csum_tcpudp_magic
-__sum16 csum_tcpudp_magic(unsigned long saddr, unsigned long daddr,
-	unsigned short len, unsigned short proto, __wsum sum);
+__sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
+			  __u32 len, __u8 proto, __wsum sum);
 
 #include <asm-generic/checksum.h>
 
diff --git a/arch/hexagon/lib/checksum.c b/arch/hexagon/lib/checksum.c
index 8169f78a46a7..617506d1a559 100644
--- a/arch/hexagon/lib/checksum.c
+++ b/arch/hexagon/lib/checksum.c
@@ -60,18 +60,16 @@ static inline unsigned short from64to16(u64 x)
  * computes the checksum of the TCP/UDP pseudo-header
  * returns a 16-bit checksum, already complemented.
  */
-__sum16 csum_tcpudp_magic(unsigned long saddr, unsigned long daddr,
-			  unsigned short len, unsigned short proto,
-			  __wsum sum)
+__sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
+			  __u32 len, __u8 proto, __wsum sum)
 {
 	return (__force __sum16)~from64to16(
 		(__force u64)saddr + (__force u64)daddr +
 		(__force u64)sum + ((len + proto) << 8));
 }
 
-__wsum csum_tcpudp_nofold(unsigned long saddr, unsigned long daddr,
-			  unsigned short len, unsigned short proto,
-			  __wsum sum)
+__wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
+			  __u32 len, __u8 proto, __wsum sum)
 {
 	u64 result;
 
diff --git a/arch/ia64/include/asm/checksum.h b/arch/ia64/include/asm/checksum.h
index 97af155057e4..ac9c687e8384 100644
--- a/arch/ia64/include/asm/checksum.h
+++ b/arch/ia64/include/asm/checksum.h
@@ -16,15 +16,11 @@ extern __sum16 ip_fast_csum(const void *iph, unsigned int ihl);
  * Computes the checksum of the TCP/UDP pseudo-header returns a 16-bit
  * checksum, already complemented
  */
-extern __sum16 csum_tcpudp_magic (__be32 saddr, __be32 daddr,
-					     unsigned short len,
-					     unsigned short proto,
-					     __wsum sum);
+extern __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
+				 __u32 len, __u8 proto, __wsum sum);
 
-extern __wsum csum_tcpudp_nofold (__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
-					__wsum sum);
+extern __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
+				 __u32 len, __u8 proto, __wsum sum);
 
 /*
  * Computes the checksum of a memory block at buff, length len,
diff --git a/arch/ia64/lib/checksum.c b/arch/ia64/lib/checksum.c
index 9fc955026f86..2cb23cb0c2e1 100644
--- a/arch/ia64/lib/checksum.c
+++ b/arch/ia64/lib/checksum.c
@@ -34,8 +34,8 @@ from64to16 (unsigned long x)
  * returns a 16-bit checksum, already complemented.
  */
 __sum16
-csum_tcpudp_magic (__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
+		  __u8 proto, __wsum sum)
 {
 	return (__force __sum16)~from64to16(
 		(__force u64)saddr + (__force u64)daddr +
@@ -45,8 +45,8 @@ csum_tcpudp_magic (__be32 saddr, __be32 daddr, unsigned short len,
 EXPORT_SYMBOL(csum_tcpudp_magic);
 
 __wsum
-csum_tcpudp_nofold (__be32 saddr, __be32 daddr, unsigned short len,
-		    unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	unsigned long result;
 
diff --git a/arch/m32r/include/asm/checksum.h b/arch/m32r/include/asm/checksum.h
index a7a7c4f44abe..d68e93c9bd62 100644
--- a/arch/m32r/include/asm/checksum.h
+++ b/arch/m32r/include/asm/checksum.h
@@ -114,9 +114,8 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 }
 
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					       unsigned short len,
-					       unsigned short proto,
-					       __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 #if defined(__LITTLE_ENDIAN)
 	unsigned long len_proto = (proto + len) << 8;
@@ -145,9 +144,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-						   unsigned short len,
-						   unsigned short proto,
-						   __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/arch/metag/include/asm/checksum.h b/arch/metag/include/asm/checksum.h
index 08dd1cc65799..f65fe83b1730 100644
--- a/arch/metag/include/asm/checksum.h
+++ b/arch/metag/include/asm/checksum.h
@@ -59,8 +59,7 @@ extern __sum16 ip_fast_csum(const void *iph, unsigned int ihl);
  * returns a 16-bit checksum, already complemented
  */
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	unsigned long len_proto = (proto + len) << 8;
@@ -78,8 +77,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
 }
 
 static inline __sum16
-csum_tcpudp_magic(__be32 saddr, __be32 daddr, unsigned short len,
-		  unsigned short proto, __wsum sum)
+csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
+		  __u8 proto, __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
 }
diff --git a/arch/microblaze/include/asm/checksum.h b/arch/microblaze/include/asm/checksum.h
index 0185cbefdda4..adeecebbb0d1 100644
--- a/arch/microblaze/include/asm/checksum.h
+++ b/arch/microblaze/include/asm/checksum.h
@@ -16,8 +16,8 @@
  */
 #define csum_tcpudp_nofold	csum_tcpudp_nofold
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	__asm__("add %0, %0, %1\n\t"
 		"addc %0, %0, %2\n\t"
diff --git a/arch/mips/include/asm/checksum.h b/arch/mips/include/asm/checksum.h
index 3ceacde5eb6e..c635541d40b8 100644
--- a/arch/mips/include/asm/checksum.h
+++ b/arch/mips/include/asm/checksum.h
@@ -160,9 +160,9 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 }
 #define ip_fast_csum ip_fast_csum
 
-static inline __wsum csum_tcpudp_nofold(__be32 saddr,
-	__be32 daddr, unsigned short len, unsigned short proto,
-	__wsum sum)
+static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	__asm__(
 	"	.set	push		# csum_tcpudp_nofold\n"
diff --git a/arch/mn10300/include/asm/checksum.h b/arch/mn10300/include/asm/checksum.h
index 9fb2a8d8826a..c80df5b504ac 100644
--- a/arch/mn10300/include/asm/checksum.h
+++ b/arch/mn10300/include/asm/checksum.h
@@ -37,16 +37,11 @@ static inline __sum16 csum_fold(__wsum sum)
 	return (~sum) >> 16;
 }
 
-static inline __wsum csum_tcpudp_nofold(unsigned long saddr,
-					unsigned long daddr,
-					unsigned short len,
-					unsigned short proto,
+static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
-	__wsum tmp;
-
-	tmp = (__wsum) ntohs(len) << 16;
-	tmp += (__wsum) proto << 8;
+	__wsum tmp = (__wsum)((len + proto) << 8);
 
 	asm(
 		"	add	%1,%0		\n"
@@ -64,10 +59,8 @@ static inline __wsum csum_tcpudp_nofold(unsigned long saddr,
  * computes the checksum of the TCP/UDP pseudo-header
  * returns a 16-bit checksum, already complemented
  */
-static inline __sum16 csum_tcpudp_magic(unsigned long saddr,
-					unsigned long daddr,
-					unsigned short len,
-					unsigned short proto,
+static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
diff --git a/arch/nios2/include/asm/checksum.h b/arch/nios2/include/asm/checksum.h
index 6bc1f0d5df7b..703c5ee63421 100644
--- a/arch/nios2/include/asm/checksum.h
+++ b/arch/nios2/include/asm/checksum.h
@@ -45,8 +45,7 @@ static inline __sum16 csum_fold(__wsum sum)
  */
 #define csum_tcpudp_nofold csum_tcpudp_nofold
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	__asm__ __volatile__(
@@ -60,7 +59,7 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
 		"cmpltu	r8, %0, %3\n"
 		"add	%0, %0, r8\n"	/* add carry */
 		: "=r" (sum), "=r" (saddr)
-		: "r" (daddr), "r" ((ntohs(len) << 16) + (proto * 256)),
+		: "r" (daddr), "r" ((len + proto) << 8),
 		  "0" (sum),
 		  "1" (saddr)
 		: "r8");
@@ -69,8 +68,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
 }
 
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto, __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
 }
diff --git a/arch/parisc/include/asm/checksum.h b/arch/parisc/include/asm/checksum.h
index c84b2fcb18a9..9815ab1fc8aa 100644
--- a/arch/parisc/include/asm/checksum.h
+++ b/arch/parisc/include/asm/checksum.h
@@ -85,9 +85,8 @@ static inline __sum16 csum_fold(__wsum csum)
 }
  
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					       unsigned short len,
-					       unsigned short proto,
-					       __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	__asm__(
 	"	add  %1, %0, %0\n"
@@ -104,9 +103,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-						   unsigned short len,
-						   unsigned short proto,
-						   __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/arch/s390/include/asm/checksum.h b/arch/s390/include/asm/checksum.h
index 740364856355..d7f100c53f07 100644
--- a/arch/s390/include/asm/checksum.h
+++ b/arch/s390/include/asm/checksum.h
@@ -91,8 +91,7 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
  * returns a 32-bit checksum
  */
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-                   unsigned short len, unsigned short proto,
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len, __u8 proto,
                    __wsum sum)
 {
 	__u32 csum = (__force __u32)sum;
@@ -118,8 +117,7 @@ csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  */
 
 static inline __sum16
-csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-                  unsigned short len, unsigned short proto,
+csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len, __u8 proto,
                   __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
diff --git a/arch/score/include/asm/checksum.h b/arch/score/include/asm/checksum.h
index 961bd64015a8..a375bc2700be 100644
--- a/arch/score/include/asm/checksum.h
+++ b/arch/score/include/asm/checksum.h
@@ -127,10 +127,10 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 }
 
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
-	unsigned long tmp = (ntohs(len) << 16) + proto * 256;
+	unsigned long tmp = (len + proto) << 8;
 	__asm__ __volatile__(
 		".set volatile\n\t"
 		"add\t%0, %0, %2\n\t"
@@ -161,8 +161,8 @@ csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16
-csum_tcpudp_magic(__be32 saddr, __be32 daddr, unsigned short len,
-		unsigned short proto, __wsum sum)
+csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
+		  __u8 proto, __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
 }
diff --git a/arch/sh/include/asm/checksum_32.h b/arch/sh/include/asm/checksum_32.h
index 14b7ac2f0a07..fd730f140c06 100644
--- a/arch/sh/include/asm/checksum_32.h
+++ b/arch/sh/include/asm/checksum_32.h
@@ -115,8 +115,7 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 }
 
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 #ifdef __LITTLE_ENDIAN__
@@ -142,8 +141,7 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
diff --git a/arch/sparc/include/asm/checksum_32.h b/arch/sparc/include/asm/checksum_32.h
index 426b2389a1c2..86ae655a3c0f 100644
--- a/arch/sparc/include/asm/checksum_32.h
+++ b/arch/sparc/include/asm/checksum_32.h
@@ -170,9 +170,8 @@ static inline __sum16 csum_fold(__wsum sum)
 }
 
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					       unsigned short len,
-					       unsigned short proto,
-					       __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	__asm__ __volatile__("addcc\t%1, %0, %0\n\t"
 			     "addxcc\t%2, %0, %0\n\t"
@@ -190,9 +189,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-						   unsigned short len,
-						   unsigned short proto,
-						   __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/arch/sparc/include/asm/checksum_64.h b/arch/sparc/include/asm/checksum_64.h
index b8779a6a5911..ef0c6f48189a 100644
--- a/arch/sparc/include/asm/checksum_64.h
+++ b/arch/sparc/include/asm/checksum_64.h
@@ -96,8 +96,7 @@ static inline __sum16 csum_fold(__wsum sum)
 }
 
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					unsigned int len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	__asm__ __volatile__(
@@ -116,8 +115,7 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
diff --git a/arch/unicore32/include/asm/checksum.h b/arch/unicore32/include/asm/checksum.h
index f55c3f937c3e..23ceb9e3a89b 100644
--- a/arch/unicore32/include/asm/checksum.h
+++ b/arch/unicore32/include/asm/checksum.h
@@ -20,8 +20,8 @@
  */
 
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	__asm__(
 	"add.a	%0, %1, %2\n"
diff --git a/arch/x86/include/asm/checksum_32.h b/arch/x86/include/asm/checksum_32.h
index f50de6951738..6f380605403d 100644
--- a/arch/x86/include/asm/checksum_32.h
+++ b/arch/x86/include/asm/checksum_32.h
@@ -112,8 +112,7 @@ static inline __sum16 csum_fold(__wsum sum)
 }
 
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	asm("addl %1, %0	;\n"
@@ -131,8 +130,7 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto,
+					__u32 len, __u8 proto,
 					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index cd00e1774491..97b98e2039bc 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -84,8 +84,8 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
  * 32bit unfolded.
  */
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum)
 {
 	asm("  addl %1, %0\n"
 	    "  adcl %2, %0\n"
@@ -110,8 +110,8 @@ csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
  * complemented and ready to be filled in.
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					unsigned short len,
-					unsigned short proto, __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
 }
diff --git a/arch/x86/um/asm/checksum.h b/arch/x86/um/asm/checksum.h
index ee940185e89f..54d96f1e3594 100644
--- a/arch/x86/um/asm/checksum.h
+++ b/arch/x86/um/asm/checksum.h
@@ -87,8 +87,8 @@ static inline __sum16 csum_fold(__wsum sum)
  * 32bit unfolded.
  */
 static inline __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		   unsigned short proto, __wsum sum)
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		  __u8 proto, __wsum sum)
 {
 	asm("  addl %1, %0\n"
 	    "  adcl %2, %0\n"
@@ -104,9 +104,8 @@ csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
  * returns a 16-bit checksum, already complemented
  */
 static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-					   unsigned short len,
-					   unsigned short proto,
-					   __wsum sum)
+					__u32 len, __u8 proto,
+					__wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/arch/xtensa/include/asm/checksum.h b/arch/xtensa/include/asm/checksum.h
index 0593de689b56..62254e6688f5 100644
--- a/arch/xtensa/include/asm/checksum.h
+++ b/arch/xtensa/include/asm/checksum.h
@@ -123,9 +123,8 @@ static __inline__ __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 }
 
 static __inline__ __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-						   unsigned short len,
-						   unsigned short proto,
-						   __wsum sum)
+					    __u32 len, __u8 proto,
+					    __wsum sum)
 {
 
 #ifdef __XTENSA_EL__
@@ -157,9 +156,8 @@ static __inline__ __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
  * returns a 16-bit checksum, already complemented
  */
 static __inline__ __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
-						       unsigned short len,
-						       unsigned short proto,
-						       __wsum sum)
+					    __u32 len, __u8 proto,
+					    __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr,daddr,len,proto,sum));
 }
diff --git a/include/asm-generic/checksum.h b/include/asm-generic/checksum.h
index 59811df58c5b..3150cbd8eb21 100644
--- a/include/asm-generic/checksum.h
+++ b/include/asm-generic/checksum.h
@@ -65,14 +65,14 @@ static inline __sum16 csum_fold(__wsum csum)
  * returns a 16-bit checksum, already complemented
  */
 extern __wsum
-csum_tcpudp_nofold(__be32 saddr, __be32 daddr, unsigned short len,
-		unsigned short proto, __wsum sum);
+csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
+		   __u8 proto, __wsum sum);
 #endif
 
 #ifndef csum_tcpudp_magic
 static inline __sum16
-csum_tcpudp_magic(__be32 saddr, __be32 daddr, unsigned short len,
-		  unsigned short proto, __wsum sum)
+csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
+		  __u8 proto, __wsum sum)
 {
 	return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
 }
diff --git a/lib/checksum.c b/lib/checksum.c
index 8b39e86dbab5..d3ec93f9e5f3 100644
--- a/lib/checksum.c
+++ b/lib/checksum.c
@@ -191,9 +191,7 @@ static inline u32 from64to32(u64 x)
 }
 
 __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
-			unsigned short len,
-			unsigned short proto,
-			__wsum sum)
+			  __u32 len, __u8 proto, __wsum sum)
 {
 	unsigned long long s = (__force u32)sum;
 
