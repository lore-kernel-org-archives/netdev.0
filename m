From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next] ipv6: Implement optimized IPv6 masked address comparison for ARM64
Date: Thu, 16 Mar 2017 22:42:52 -0600
Message-ID: <1489725772-7571-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        luke.starrett@broadcom.com, robin.murphy@arm.com,
        catalin.marinas@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52492 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdCQEny (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 00:43:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Android devices use multiple ip[6]tables for statistics, UID matching
and other functionality. Perf output indicated that ip6_do_table
was taking a considerable amount of CPU and more that ip_do_table
for an equivalent rate. ipv6_masked_addr_cmp was chosen for
optimization as there are more instructions required than the
equivalent operation in ip_packet_match.

Using 128 bit operations helps to reduce the number of instructions
for the match on an ARM64 system. This helps to improve UDPv6 DL
performance by 40Mbps (860Mbps -> 900Mbps) on a CPU limited system.

Tested on x86_64 UML to check if generic version is used and ARM64
to verify that ARM64 version is used.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 arch/alpha/include/asm/Kbuild      |  1 +
 arch/arc/include/asm/Kbuild        |  1 +
 arch/arm/include/asm/Kbuild        |  1 +
 arch/arm64/include/asm/ipv6.h      | 29 +++++++++++++++++++++++++++++
 arch/avr32/include/asm/Kbuild      |  1 +
 arch/blackfin/include/asm/Kbuild   |  1 +
 arch/c6x/include/asm/Kbuild        |  1 +
 arch/cris/include/asm/Kbuild       |  1 +
 arch/frv/include/asm/Kbuild        |  1 +
 arch/h8300/include/asm/Kbuild      |  1 +
 arch/hexagon/include/asm/Kbuild    |  1 +
 arch/ia64/include/asm/Kbuild       |  1 +
 arch/m32r/include/asm/Kbuild       |  1 +
 arch/m68k/include/asm/Kbuild       |  1 +
 arch/metag/include/asm/Kbuild      |  1 +
 arch/microblaze/include/asm/Kbuild |  1 +
 arch/mips/include/asm/Kbuild       |  1 +
 arch/mn10300/include/asm/Kbuild    |  1 +
 arch/nios2/include/asm/Kbuild      |  1 +
 arch/openrisc/include/asm/Kbuild   |  1 +
 arch/parisc/include/asm/Kbuild     |  1 +
 arch/powerpc/include/asm/Kbuild    |  1 +
 arch/s390/include/asm/Kbuild       |  1 +
 arch/score/include/asm/Kbuild      |  1 +
 arch/sh/include/asm/Kbuild         |  1 +
 arch/sparc/include/asm/Kbuild      |  1 +
 arch/tile/include/asm/Kbuild       |  1 +
 arch/um/include/asm/Kbuild         |  1 +
 arch/unicore32/include/asm/Kbuild  |  1 +
 arch/x86/include/asm/Kbuild        |  1 +
 arch/xtensa/include/asm/Kbuild     |  1 +
 include/asm-generic/ipv6.h         | 32 ++++++++++++++++++++++++++++++++
 include/net/ipv6.h                 | 20 +-------------------
 33 files changed, 92 insertions(+), 19 deletions(-)
 create mode 100644 arch/arm64/include/asm/ipv6.h
 create mode 100644 include/asm-generic/ipv6.h

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index d103db5..5b7e92b 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -3,6 +3,7 @@
 generic-y += clkdev.h
 generic-y += exec.h
 generic-y += export.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 63a0401..99f1456 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -14,6 +14,7 @@ generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kmap_types.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index b14e8c7..a0ba9ac 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -9,6 +9,7 @@ generic-y += errno.h
 generic-y += exec.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += kdebug.h
 generic-y += local.h
diff --git a/arch/arm64/include/asm/ipv6.h b/arch/arm64/include/asm/ipv6.h
new file mode 100644
index 0000000..d49dec6
--- /dev/null
+++ b/arch/arm64/include/asm/ipv6.h
@@ -0,0 +1,29 @@
+/* Copyright (c) 2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __ASM_IPV6_H
+#define __ASM_IPV6_H
+
+#include <linux/types.h>
+
+static inline bool
+ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
+		     const struct in6_addr *a2)
+{
+	const __uint128_t *ul1 = (const __uint128_t *)a1;
+	const __uint128_t *ulm = (const __uint128_t *)m;
+	const __uint128_t *ul2 = (const __uint128_t *)a1;
+
+	return !!((*ul1 ^ *ul2) & *ulm);
+}
+#define ipv6_masked_addr_cmp ipv6_masked_addr_cmp
+#endif /* __ASM_IPV6_H */
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 3d7ef2c..fd6a964 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -6,6 +6,7 @@ generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += exec.h
 generic-y += futex.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += local.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index 625db8a..f713d85 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -12,6 +12,7 @@ generic-y += futex.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index 82619c3..ff8033f 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -20,6 +20,7 @@ generic-y += io.h
 generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 0f5132b..c5b5fa0 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -15,6 +15,7 @@ generic-y += futex.h
 generic-y += hardirq.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index c33b467..0717ffb 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -1,6 +1,7 @@
 
 generic-y += clkdev.h
 generic-y += exec.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 341740c..0058275 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -23,6 +23,7 @@ generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 797b64a..4985925 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -20,6 +20,7 @@ generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += iomap.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 502a91d..cacba4c 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -1,6 +1,7 @@
 
 generic-y += clkdev.h
 generic-y += exec.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index deb2987..8ed14f5 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -2,6 +2,7 @@
 generic-y += clkdev.h
 generic-y += current.h
 generic-y += exec.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index d4f9ccb..1ddfeac 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -9,6 +9,7 @@ generic-y += futex.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index f9b9df5..2382a6e 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -16,6 +16,7 @@ generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index 1732ec1..66b7d8a 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -3,6 +3,7 @@ generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += device.h
 generic-y += exec.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 2535c7b..4453f33 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -5,6 +5,7 @@ generic-y += current.h
 generic-y += dma-contiguous.h
 generic-y += emergency-restart.h
 generic-y += export.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 97f64c7..df55c2b 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -2,6 +2,7 @@
 generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += exec.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index aaa3c21..d6b13ee 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -22,6 +22,7 @@ generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index fb01873..0d9ad5a 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -25,6 +25,7 @@ generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += ipcbuf.h
 generic-y += irq.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index a9909c2..b0e156e 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -8,6 +8,7 @@ generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += exec.h
 generic-y += hw_irq.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 5c4fbc8..f675f7c 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -1,6 +1,7 @@
 generic-y += clkdev.h
 generic-y += div64.h
 generic-y += export.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += local64.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 8aea32f..53a2335 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -2,6 +2,7 @@ generic-y += asm-offsets.h
 generic-y += clkdev.h
 generic-y += dma-contiguous.h
 generic-y += export.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index 926943a..9405456 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -4,6 +4,7 @@ header-y +=
 generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += current.h
+generic-y += ipv6.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index cf2a750..3984834 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -10,6 +10,7 @@ generic-y += exec.h
 generic-y += fcntl.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index e9e837b..d2acdaf 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -6,6 +6,7 @@ generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += exec.h
 generic-y += export.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += linkage.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index aa48b6e..9487778 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -12,6 +12,7 @@ generic-y += fcntl.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
+generic-y += ipv6.h
 generic-y += ipcbuf.h
 generic-y += irq_regs.h
 generic-y += local.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index e9d42aa..b226353 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -11,6 +11,7 @@ generic-y += futex.h
 generic-y += hardirq.h
 generic-y += hw_irq.h
 generic-y += io.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 84205fe..d01d723 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -19,6 +19,7 @@ generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
 generic-y += ipcbuf.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 5d6a53f..8a68e12 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -9,5 +9,6 @@ generated-y += xen-hypercalls.h
 generic-y += clkdev.h
 generic-y += dma-contiguous.h
 generic-y += early_ioremap.h
+generic-y += ipv6.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index f41408c..dc02075 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -9,6 +9,7 @@ generic-y += exec.h
 generic-y += fcntl.h
 generic-y += hardirq.h
 generic-y += ioctl.h
+generic-y += ipv6.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
diff --git a/include/asm-generic/ipv6.h b/include/asm-generic/ipv6.h
new file mode 100644
index 0000000..754adac
--- /dev/null
+++ b/include/asm-generic/ipv6.h
@@ -0,0 +1,32 @@
+/*	Linux INET6 implementation
+ *
+ *	Authors:
+ *	Pedro Roque		<roque@di.fc.ul.pt>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef ipv6_masked_addr_cmp
+#define ipv6_masked_addr_cmp ipv6_masked_addr_cmp
+static inline bool
+ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
+		     const struct in6_addr *a2)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	const unsigned long *ul1 = (const unsigned long *)a1;
+	const unsigned long *ulm = (const unsigned long *)m;
+	const unsigned long *ul2 = (const unsigned long *)a2;
+
+	return !!(((ul1[0] ^ ul2[0]) & ulm[0]) |
+		  ((ul1[1] ^ ul2[1]) & ulm[1]));
+#else
+	return !!(((a1->s6_addr32[0] ^ a2->s6_addr32[0]) & m->s6_addr32[0]) |
+		  ((a1->s6_addr32[1] ^ a2->s6_addr32[1]) & m->s6_addr32[1]) |
+		  ((a1->s6_addr32[2] ^ a2->s6_addr32[2]) & m->s6_addr32[2]) |
+		  ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3]));
+#endif
+}
+#endif
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dbf0abb..08ad1a98 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -21,6 +21,7 @@
 #include <net/flow.h>
 #include <net/flow_dissector.h>
 #include <net/snmp.h>
+#include <asm/ipv6.h>
 
 #define SIN6_LEN_RFC2133	24
 
@@ -385,25 +386,6 @@ static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr
 	return memcmp(a1, a2, sizeof(struct in6_addr));
 }
 
-static inline bool
-ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
-		     const struct in6_addr *a2)
-{
-#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
-	const unsigned long *ul1 = (const unsigned long *)a1;
-	const unsigned long *ulm = (const unsigned long *)m;
-	const unsigned long *ul2 = (const unsigned long *)a2;
-
-	return !!(((ul1[0] ^ ul2[0]) & ulm[0]) |
-		  ((ul1[1] ^ ul2[1]) & ulm[1]));
-#else
-	return !!(((a1->s6_addr32[0] ^ a2->s6_addr32[0]) & m->s6_addr32[0]) |
-		  ((a1->s6_addr32[1] ^ a2->s6_addr32[1]) & m->s6_addr32[1]) |
-		  ((a1->s6_addr32[2] ^ a2->s6_addr32[2]) & m->s6_addr32[2]) |
-		  ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3]));
-#endif
-}
-
 static inline void ipv6_addr_prefix(struct in6_addr *pfx, 
 				    const struct in6_addr *addr,
 				    int plen)
-- 
1.9.1
