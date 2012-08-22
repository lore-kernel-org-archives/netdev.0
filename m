From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 02:23:21 +0100
Message-ID: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<x86@kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13230 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753281Ab2HVBXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 21:23:25 -0400
In-Reply-To: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define reado(), writeo() and their raw counterparts using SSE.

Based on work by Stuart Hodgson <smhodgson@solarflare.com>.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 arch/x86/Kconfig.cpu      |    4 +++
 arch/x86/include/asm/io.h |   14 +++++++++
 arch/x86/lib/Makefile     |    1 +
 arch/x86/lib/oword_io.c   |   65 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 84 insertions(+), 0 deletions(-)
 create mode 100644 arch/x86/lib/oword_io.c

diff --git a/arch/x86/Kconfig.cpu b/arch/x86/Kconfig.cpu
index 706e12e..802508e 100644
--- a/arch/x86/Kconfig.cpu
+++ b/arch/x86/Kconfig.cpu
@@ -372,6 +372,10 @@ config X86_USE_3DNOW
 	def_bool y
 	depends on (MCYRIXIII || MK7 || MGEODE_LX) && !UML
 
+config X86_USE_SSE
+	def_bool y
+	depends on X86_64
+
 config X86_OOSTORE
 	def_bool y
 	depends on (MWINCHIP3D || MWINCHIPC6) && MTRR
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index d8e8eef..06b3e23 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -95,6 +95,20 @@ build_mmio_write(writeq, "q", unsigned long, "r", :"memory")
 
 #endif
 
+#ifdef CONFIG_X86_USE_SSE
+
+u128 reado(const volatile void __iomem *addr);
+void writeo(u128 val, volatile void __iomem *addr);
+
+#define __raw_reado(addr) reado(addr)
+#define __raw_writeo(val, addr)	writeo(val, addr)
+
+/* Let people know that we have them */
+#define reado			reado
+#define writeo			writeo
+
+#endif
+
 /**
  *	virt_to_phys	-	map virtual addresses to physical
  *	@address: address to remap
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index b00f678..1791198 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -25,6 +25,7 @@ lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
 
 obj-y += msr.o msr-reg.o msr-reg-export.o
+obj-$(CONFIG_X86_USE_SSE) += oword_io.o
 
 ifeq ($(CONFIG_X86_32),y)
         obj-y += atomic64_32.o
diff --git a/arch/x86/lib/oword_io.c b/arch/x86/lib/oword_io.c
new file mode 100644
index 0000000..8189bf3
--- /dev/null
+++ b/arch/x86/lib/oword_io.c
@@ -0,0 +1,65 @@
+/****************************************************************************
+ * 128-bit MMIO for x86
+ * Copyright 2012 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/export.h>
+#include <linux/preempt.h>
+#include <linux/types.h>
+#include <asm/io.h>
+
+/*
+ * We copy the data between a memory buffer and the MMIO address via
+ * register xmm0.  We have to save and restore the SSE state, and
+ * disable preemption.  Only the MMIO address is required to be
+ * 128-bit aligned, since the stack generally is not.
+ */
+
+u128 reado(const volatile void __iomem *addr)
+{
+	u128 ret;
+	u64 cr0;
+	u128 xmm0;
+
+	preempt_disable();
+	asm volatile (
+		"movq %%cr0,%0\n\t"
+		"clts\n\t"
+		"movups %%xmm0,%1\n\t"
+		"movaps %3,%%xmm0\n\t"
+		"movups %%xmm0,%2\n\t"
+		"sfence\n\t"
+		"movups %1,%%xmm0\n\t"
+		"movq %0,%%cr0\n\t"
+		: "=r"(cr0), "=m"(xmm0), "=m"(ret)
+		: "m"(*(const volatile u128 __iomem *)addr));
+	preempt_enable();
+
+	return ret;
+}
+EXPORT_SYMBOL(reado);
+
+void writeo(u128 val, volatile void __iomem *addr)
+{
+	u64 cr0;
+	u128 xmm0;
+
+	preempt_disable();
+	asm volatile (
+		"movq %%cr0,%0\n\t"
+		"clts\n\t"
+		"movups %%xmm0,%1\n\t"
+		"movups %3,%%xmm0\n\t"
+		"movaps %%xmm0,%2\n\t"
+		"sfence\n\t"
+		"movups %1,%%xmm0\n\t"
+		"movq %0,%%cr0\n\t"
+		: "=r"(cr0), "=m"(xmm0), "=m"(*(volatile u128 __iomem *)addr)
+		: "m"(val));
+	preempt_enable();
+}
+EXPORT_SYMBOL(writeo);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
