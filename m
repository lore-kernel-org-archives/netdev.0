From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ARM: add cmpxchg64 helper for ARMv7-M
Date: Sat, 10 Dec 2016 11:36:34 +0100
Message-ID: <20161210103646.1407256-1-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Arnd Bergmann <arnd@arndb.de>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Russell King <linux@armlinux.org.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A change to the netfilter code in net-next introduced the first caller of
cmpxchg64 that can get built on ARMv7-M, leading to an error from the
assembler that points out the lack of 64-bit atomics on this architecture:

/tmp/ccMe7djj.s: Assembler messages:
/tmp/ccMe7djj.s:367: Error: selected processor does not support `ldrexd r0,r1,[lr]' in Thumb mode
/tmp/ccMe7djj.s:371: Error: selected processor does not support `strexd ip,r2,r3,[lr]' in Thumb mode
/tmp/ccMe7djj.s:389: Error: selected processor does not support `ldrexd r8,r9,[r7]' in Thumb mode
/tmp/ccMe7djj.s:393: Error: selected processor does not support `strexd lr,r0,r1,[r7]' in Thumb mode
scripts/Makefile.build:299: recipe for target 'net/netfilter/nft_counter.o' failed

This makes ARMv7-M use the same emulation from asm-generic/cmpxchg-local.h
that we use on architectures earlier than ARMv6K, to fix the build. The
32-bit atomics are available on ARMv7-M and we keep using them there.
This ARM specific change is probably something we should do regardless
of the netfilter code.

However, looking at the new nft_counter_reset() function in nft_counter.c,
this looks incorrect to me not just on ARMv7-M but also on other
architectures, with at least the following possible race:

	CPU A				CPU B
					u64_stats_fetch_begin_irq
	u64_stats_update_begin
	fetch(upper 32 bits)
					fetch(old)
					cmpxchg64(counter, old, 0);
	fetch(lower 32 bits)
					u64_stats_fetch_retry_irq == true
	store(upper 32 bits)
					fetch(old)
					cmpxchg64(counter, old, 0);
	store(lower 32 bits)
	u64_stats_update_end
					u64_stats_fetch_retry_irq == true
					fetch(old)
					cmpxchg64(counter, old, 0);
					u64_stats_fetch_retry_irq == false

In this example, the data returned by __nft_counter_reset() is zero
as we overwrite the per-cpu counter value during the retries.

Fixes: 43da04a593d8 ("netfilter: nf_tables: atomic dump and reset for stateful objects")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/include/asm/cmpxchg.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/arm/include/asm/cmpxchg.h b/arch/arm/include/asm/cmpxchg.h
index 97882f9bad12..12215515ba02 100644
--- a/arch/arm/include/asm/cmpxchg.h
+++ b/arch/arm/include/asm/cmpxchg.h
@@ -240,6 +240,7 @@ static inline unsigned long __cmpxchg_local(volatile void *ptr,
 				        sizeof(*(ptr)));		\
 })
 
+#ifndef CONFIG_CPU_V7M
 static inline unsigned long long __cmpxchg64(unsigned long long *ptr,
 					     unsigned long long old,
 					     unsigned long long new)
@@ -273,6 +274,18 @@ static inline unsigned long long __cmpxchg64(unsigned long long *ptr,
 
 #define cmpxchg64_local(ptr, o, n) cmpxchg64_relaxed((ptr), (o), (n))
 
+#else
+
+/* ARMv7-M has 32-bit ldrex/strex but no ldrexd/strexd */
+
+#define cmpxchg64(ptr, o, n)		__cmpxchg64_local_generic((ptr), (o), (n))
+#define cmpxchg64_relaxed(ptr, o, n)	__cmpxchg64_local_generic((ptr), (o), (n))
+#define cmpxchg64_local(ptr, o, n)	__cmpxchg64_local_generic((ptr), (o), (n))
+
+#include <asm-generic/cmpxchg-local.h>
+
+#endif
+
 #endif	/* __LINUX_ARM_ARCH__ >= 6 */
 
 #endif /* __ASM_ARM_CMPXCHG_H */
-- 
2.9.0

