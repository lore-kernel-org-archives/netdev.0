From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH RFC 1/4] ARM: kgdb: Must poll for IPIs during busy-waiting
Date: Wed, 7 Jul 2010 21:13:10 +0400
Message-ID: <20100707171310.GA20015@oksana.dev.rtsoft.ru>
References: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wessel <jason.wessel@windriver.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: kgdb-bugreport@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:48303 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016Ab0GGRNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 13:13:15 -0400
Received: by ewy23 with SMTP id 23so2156157ewy.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 10:13:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On architectures w/o NMIs (e.g. ARM), ordinary (maskable) IRQs are used
for SMP IPI calls.

Various deadlocks are possible if we not poll for IPIs:

- The master CPU might hang in kgdb_roundup_cpus() because the slave CPU
  does not process IPIs;
- DMA cache coherency calls are implemented as IPIs, so the master CPU
  might hang in *dma_sync_*() calls that may be issued by the KGDB IO
  back-ends.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 arch/arm/kernel/kgdb.c |    8 ++++++++
 kernel/kgdb.c          |   23 ++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/arch/arm/kernel/kgdb.c b/arch/arm/kernel/kgdb.c
index a5b846b..5c61100 100644
--- a/arch/arm/kernel/kgdb.c
+++ b/arch/arm/kernel/kgdb.c
@@ -11,6 +11,7 @@
  */
 #include <linux/irq.h>
 #include <linux/kgdb.h>
+#include <asm/smp.h>
 #include <asm/traps.h>
 
 /* Make a local copy of the registers passed into the handler (bletch) */
@@ -171,6 +172,13 @@ void kgdb_roundup_cpus(unsigned long flags)
        local_irq_disable();
 }
 
+#ifdef CONFIG_SMP
+void kgdb_arch_poll_ipi(struct pt_regs *regs)
+{
+	do_IPI(regs);
+}
+#endif
+
 /**
  *	kgdb_arch_init - Perform any architecture specific initalization.
  *
diff --git a/kernel/kgdb.c b/kernel/kgdb.c
index 9934aa0..97edb05 100644
--- a/kernel/kgdb.c
+++ b/kernel/kgdb.c
@@ -225,6 +225,25 @@ int __weak kgdb_arch_init(void)
 	return 0;
 }
 
+/*
+ * On architectures w/o NMIs (e.g. ARM), ordinary (maskable) IRQs are used
+ * for SMP IPI calls.
+ *
+ * Various deadlocks are possible if we not poll for IPIs:
+ *
+ * - The master CPU might hang in kgdb_roundup_cpus() because the slave CPU
+ *   does not process IPIs;
+ * - DMA cache coherency calls are implemented as IPIs, so the master CPU
+ *   might hang in *dma_sync_*() calls that may be issued by the KGDB IO
+ *   back-ends.
+ *
+ * The rule of thumb: always poll for IPIs in busy-waiting loops until
+ * all CPUs are in KGDB (i.e. all cpu_in_kgdb[] are set).
+ */
+void __weak kgdb_arch_poll_ipi(struct pt_regs *regs)
+{
+}
+
 int __weak kgdb_skipexception(int exception, struct pt_regs *regs)
 {
 	return 0;
@@ -1389,6 +1408,8 @@ acquirelock:
 	 * master cpu and acquire the kgdb_active lock:
 	 */
 	while (1) {
+		kgdb_arch_poll_ipi(regs);
+
 		if (kgdb_info[cpu].exception_state & DCPU_WANT_MASTER) {
 			if (atomic_cmpxchg(&kgdb_active, -1, cpu) == cpu)
 				break;
@@ -1465,7 +1486,7 @@ return_normal:
 	 */
 	for_each_online_cpu(i) {
 		while (!atomic_read(&cpu_in_kgdb[i]))
-			cpu_relax();
+			kgdb_arch_poll_ipi(regs);
 	}
 
 	/*
-- 
1.7.0.5

