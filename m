From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v3] xen-apic: Enable on domU as well
Date: Mon, 10 Aug 2015 15:40:27 +0200
Message-ID: <1439214027-13994-1-git-send-email-Jason@zx2c4.com>
References: <1438879025-27362-1-git-send-email-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, <stable@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438879025-27362-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It turns out that domU also requires the Xen APIC driver. Otherwise we
get stuck in busy loops that never exit, such as in this stack trace:

(gdb) target remote localhost:9999
Remote debugging using localhost:9999
__xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
(gdb) bt
 #0  __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
 #1  __default_send_IPI_shortcut (shortcut=<optimized out>,
dest=<optimized out>, vector=<optimized out>) at
./arch/x86/include/asm/ipi.h:75
 #2  apic_send_IPI_self (vector=246) at arch/x86/kernel/apic/probe_64.c:54
 #3  0xffffffff81011336 in arch_irq_work_raise () at
arch/x86/kernel/irq_work.c:47
 #4  0xffffffff8114990c in irq_work_queue (work=0xffff88000fc0e400) at
kernel/irq_work.c:100
 #5  0xffffffff8110c29d in wake_up_klogd () at kernel/printk/printk.c:2633
 #6  0xffffffff8110ca60 in vprintk_emit (facility=0, level=<optimized
out>, dict=0x0 <irq_stack_union>, dictlen=<optimized out>,
fmt=<optimized out>, args=<optimized out>)
    at kernel/printk/printk.c:1778
 #7  0xffffffff816010c8 in printk (fmt=<optimized out>) at
kernel/printk/printk.c:1868
 #8  0xffffffffc00013ea in ?? ()
 #9  0x0000000000000000 in ?? ()

Mailing-list-thread: https://lkml.org/lkml/2015/8/4/755
Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: <stable@vger.kernel.org>
---
 arch/x86/xen/Makefile  | 4 ++--
 arch/x86/xen/xen-ops.h | 7 ++-----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/arch/x86/xen/Makefile b/arch/x86/xen/Makefile
index 7322755..4b6e29a 100644
--- a/arch/x86/xen/Makefile
+++ b/arch/x86/xen/Makefile
@@ -13,13 +13,13 @@ CFLAGS_mmu.o			:= $(nostackp)
 obj-y		:= enlighten.o setup.o multicalls.o mmu.o irq.o \
 			time.o xen-asm.o xen-asm_$(BITS).o \
 			grant-table.o suspend.o platform-pci-unplug.o \
-			p2m.o
+			p2m.o apic.o
 
 obj-$(CONFIG_EVENT_TRACING) += trace.o
 
 obj-$(CONFIG_SMP)		+= smp.o
 obj-$(CONFIG_PARAVIRT_SPINLOCKS)+= spinlock.o
 obj-$(CONFIG_XEN_DEBUG_FS)	+= debugfs.o
-obj-$(CONFIG_XEN_DOM0)		+= apic.o vga.o
+obj-$(CONFIG_XEN_DOM0)		+= vga.o
 obj-$(CONFIG_SWIOTLB_XEN)	+= pci-swiotlb-xen.o
 obj-$(CONFIG_XEN_EFI)		+= efi.o
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index c20fe29..d0a543b 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -98,20 +98,17 @@ static inline void xen_uninit_lock_cpu(int cpu)
 #endif
 
 struct dom0_vga_console_info;
-
 #ifdef CONFIG_XEN_DOM0
 void __init xen_init_vga(const struct dom0_vga_console_info *, size_t size);
-void __init xen_init_apic(void);
 #else
 static inline void __init xen_init_vga(const struct dom0_vga_console_info *info,
 				       size_t size)
 {
 }
-static inline void __init xen_init_apic(void)
-{
-}
 #endif
 
+void __init xen_init_apic(void);
+
 #ifdef CONFIG_XEN_EFI
 extern void xen_efi_init(void);
 #else
-- 
2.5.0
