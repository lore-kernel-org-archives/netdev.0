From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH 13/17] x86: allow the irq->vector translation to be
	determined outside of ioapic
Date: Tue, 31 Mar 2009 14:43:55 -0400
Message-ID: <20090331184355.28333.72382.stgit@dev.haskins.net>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:44296 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761892AbZCaSlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 14:41:44 -0400
In-Reply-To: <20090331184057.28333.77287.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ioapic code currently privately manages the mapping between irq
and vector.  This results in some layering violations as the support
for certain MSI operations need this info.  As a result, the MSI
code itself was moved to the ioapic module.  This is not really
optimal.

We now have another need to gain access to the vector assignment on
x86.  However, rather than put yet another inappropriately placed
function into io-apic, lets create a way to export this simple data
and therefore allow the logic to sit closer to where it belongs.

Ideally we should abstract the entire notion of irq->vector management
out of io-apic, but we leave that as an excercise for another day.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 arch/x86/include/asm/irq.h |    6 ++++++
 arch/x86/kernel/io_apic.c  |   25 +++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/irq.h b/arch/x86/include/asm/irq.h
index 592688e..b1726d8 100644
--- a/arch/x86/include/asm/irq.h
+++ b/arch/x86/include/asm/irq.h
@@ -40,6 +40,12 @@ extern unsigned int do_IRQ(struct pt_regs *regs);
 extern void init_IRQ(void);
 extern void native_init_IRQ(void);
 
+#ifdef CONFIG_SMP
+extern int set_irq_affinity(int irq, cpumask_t mask);
+#endif
+
+extern int irq_to_vector(int irq);
+
 /* Interrupt vector management */
 extern DECLARE_BITMAP(used_vectors, NR_VECTORS);
 extern int vector_used_by_percpu_irq(unsigned int vector);
diff --git a/arch/x86/kernel/io_apic.c b/arch/x86/kernel/io_apic.c
index bc7ac4d..86a2c36 100644
--- a/arch/x86/kernel/io_apic.c
+++ b/arch/x86/kernel/io_apic.c
@@ -614,6 +614,14 @@ set_ioapic_affinity_irq(unsigned int irq, const struct cpumask *mask)
 
 	set_ioapic_affinity_irq_desc(desc, mask);
 }
+
+int set_irq_affinity(int irq, cpumask_t mask)
+{
+	set_ioapic_affinity_irq(irq, &mask);
+
+	return 0;
+}
+
 #endif /* CONFIG_SMP */
 
 /*
@@ -3249,6 +3257,23 @@ void destroy_irq(unsigned int irq)
 	spin_unlock_irqrestore(&vector_lock, flags);
 }
 
+int irq_to_vector(int irq)
+{
+	struct irq_cfg *cfg;
+	unsigned long flags;
+	int ret = -ENOENT;
+
+	spin_lock_irqsave(&vector_lock, flags);
+
+	cfg = irq_cfg(irq);
+	if (cfg && cfg->vector != 0)
+		ret = cfg->vector;
+
+	spin_unlock_irqrestore(&vector_lock, flags);
+
+	return ret;
+}
+
 /*
  * MSI message composition
  */

