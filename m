From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 15/19] kvm: add dynamic IRQ support
Date: Thu, 09 Apr 2009 12:32:00 -0400
Message-ID: <20090409163200.32740.90490.stgit@dev.haskins.net>
References: <20090409155200.32740.19358.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:53527 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935525AbZDIQ3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 12:29:54 -0400
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides the ability to dynamically declare and map an
interrupt-request handle to an x86 8-bit vector.

Problem Statement: Emulated devices (such as PCI, ISA, etc) have
interrupt routing done via standard PC mechanisms (MP-table, ACPI,
etc).  However, we also want to support a new class of devices
which exist in a new virtualized namespace and therefore should
not try to piggyback on these emulated mechanisms.  Rather, we
create a way to dynamically register interrupt resources that
acts indepent of the emulated counterpart.

On x86, a simplistic view of the interrupt model is that each core
has a local-APIC which can recieve messages from APIC-compliant
routing devices (such as IO-APIC and MSI) regarding details about
an interrupt (such as which vector to raise).  These routing devices
are controlled by the OS so they may translate a physical event
(such as "e1000: raise an RX interrupt") to a logical destination
(such as "inject IDT vector 46 on core 3").  A dynirq is a virtual
implementation of such a router (think of it as a virtual-MSI, but
without the coupling to an existing standard, such as PCI).

The model is simple: A guest OS can allocate the mapping of "IRQ"
handle to "vector/core" in any way it sees fit, and provide this
information to the dynirq module running in the host.  The assigned
IRQ then becomes the sole handle needed to inject an IDT vector
to the guest from a host.  A host entity that wishes to raise an
interrupt simple needs to call kvm_inject_dynirq(irq) and the routing
is performed transparently.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 arch/x86/Kconfig                |    5 +
 arch/x86/Makefile               |    3 
 arch/x86/include/asm/kvm_host.h |    9 +
 arch/x86/include/asm/kvm_para.h |   11 +
 arch/x86/kvm/Makefile           |    3 
 arch/x86/kvm/dynirq.c           |  329 +++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/guest/Makefile     |    2 
 arch/x86/kvm/guest/dynirq.c     |   95 +++++++++++
 arch/x86/kvm/x86.c              |    6 +
 include/linux/kvm.h             |    1 
 include/linux/kvm_guest.h       |    7 +
 include/linux/kvm_host.h        |    1 
 include/linux/kvm_para.h        |    1 
 13 files changed, 472 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/kvm/dynirq.c
 create mode 100644 arch/x86/kvm/guest/Makefile
 create mode 100644 arch/x86/kvm/guest/dynirq.c
 create mode 100644 include/linux/kvm_guest.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 3fca247..91fefd5 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -446,6 +446,11 @@ config KVM_GUEST
 	 This option enables various optimizations for running under the KVM
 	 hypervisor.
 
+config KVM_GUEST_DYNIRQ
+       bool "KVM Dynamic IRQ support"
+       depends on KVM_GUEST
+       default y
+
 source "arch/x86/lguest/Kconfig"
 
 config PARAVIRT
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index d1a47ad..d788815 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -147,6 +147,9 @@ core-$(CONFIG_XEN) += arch/x86/xen/
 # lguest paravirtualization support
 core-$(CONFIG_LGUEST_GUEST) += arch/x86/lguest/
 
+# kvm paravirtualization support
+core-$(CONFIG_KVM_GUEST) += arch/x86/kvm/guest/
+
 core-y += arch/x86/kernel/
 core-y += arch/x86/mm/
 
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 730843d..9ae398a 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -346,6 +346,12 @@ struct kvm_mem_alias {
 	gfn_t target_gfn;
 };
 
+struct kvm_dynirq {
+	spinlock_t lock;
+	struct rb_root map;
+	struct kvm *kvm;
+};
+
 struct kvm_arch{
 	int naliases;
 	struct kvm_mem_alias aliases[KVM_ALIAS_SLOTS];
@@ -363,6 +369,7 @@ struct kvm_arch{
 	struct iommu_domain *iommu_domain;
 	struct kvm_pic *vpic;
 	struct kvm_ioapic *vioapic;
+	struct kvm_dynirq *dynirq;
 	struct kvm_pit *vpit;
 	struct hlist_head irq_ack_notifier_list;
 	int vapics_in_nmi_mode;
@@ -519,6 +526,8 @@ int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa,
 			  const void *val, int bytes);
 int kvm_pv_mmu_op(struct kvm_vcpu *vcpu, unsigned long bytes,
 		  gpa_t addr, unsigned long *ret);
+int kvm_dynirq_hc(struct kvm_vcpu *vcpu, int nr, gpa_t gpa, size_t len);
+void kvm_free_dynirq(struct kvm *kvm);
 
 extern bool tdp_enabled;
 
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index b8a3305..fba210e 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -13,6 +13,7 @@
 #define KVM_FEATURE_CLOCKSOURCE		0
 #define KVM_FEATURE_NOP_IO_DELAY	1
 #define KVM_FEATURE_MMU_OP		2
+#define KVM_FEATURE_DYNIRQ		3
 
 #define MSR_KVM_WALL_CLOCK  0x11
 #define MSR_KVM_SYSTEM_TIME 0x12
@@ -45,6 +46,16 @@ struct kvm_mmu_op_release_pt {
 	__u64 pt_phys;
 };
 
+/* Operations for KVM_HC_DYNIRQ */
+#define KVM_DYNIRQ_OP_SET   1
+#define KVM_DYNIRQ_OP_CLEAR 2
+
+struct kvm_dynirq_set {
+	__u32 irq;
+	__u32 vec;  /* x86 IDT vector */
+	__u32 dest; /* 0-based vcpu id */
+};
+
 #ifdef __KERNEL__
 #include <asm/processor.h>
 
diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
index d3ec292..d5676f5 100644
--- a/arch/x86/kvm/Makefile
+++ b/arch/x86/kvm/Makefile
@@ -14,9 +14,10 @@ endif
 EXTRA_CFLAGS += -Ivirt/kvm -Iarch/x86/kvm
 
 kvm-objs := $(common-objs) x86.o mmu.o x86_emulate.o i8259.o irq.o lapic.o \
-	i8254.o
+	i8254.o dynirq.o
 obj-$(CONFIG_KVM) += kvm.o
 kvm-intel-objs = vmx.o
 obj-$(CONFIG_KVM_INTEL) += kvm-intel.o
 kvm-amd-objs = svm.o
 obj-$(CONFIG_KVM_AMD) += kvm-amd.o
+
diff --git a/arch/x86/kvm/dynirq.c b/arch/x86/kvm/dynirq.c
new file mode 100644
index 0000000..54162dd
--- /dev/null
+++ b/arch/x86/kvm/dynirq.c
@@ -0,0 +1,329 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * Dynamic-Interrupt-Request (dynirq): This module provides the ability
+ * to dynamically declare and map an interrupt-request handle to an
+ * x86 8-bit vector.
+ *
+ * Problem Statement: Emulated devices (such as PCI, ISA, etc) have
+ * interrupt routing done via standard PC mechanisms (MP-table, ACPI,
+ * etc).  However, we also want to support a new class of devices
+ * which exist in a new virtualized namespace and therefore should
+ * not try to piggyback on these emulated mechanisms.  Rather, we
+ * create a way to dynamically register interrupt resources that
+ * acts indepent of the emulated counterpart.
+ *
+ * On x86, a simplistic view of the interrupt model is that each core
+ * has a local-APIC which can recieve messages from APIC-compliant
+ * routing devices (such as IO-APIC and MSI) regarding details about
+ * an interrupt (such as which vector to raise).  These routing devices
+ * are controlled by the OS so they may translate a physical event
+ * (such as "e1000: raise an RX interrupt") to a logical destination
+ * (such as "inject IDT vector 46 on core 3").  A dynirq is a virtual
+ * implementation of such a router (think of it as a virtual-MSI, but
+ * without the coupling to an existing standard, such as PCI).
+ *
+ * The model is simple: A guest OS can allocate the mapping of "IRQ"
+ * handle to "vector/core" in any way it sees fit, and provide this
+ * information to the dynirq module running in the host.  The assigned
+ * IRQ then becomes the sole handle needed to inject an IDT vector
+ * to the guest from a host.  A host entity that wishes to raise an
+ * interrupt simple needs to call kvm_inject_dynirq(irq) and the routing
+ * is performed transparently.
+ *
+ * Author:
+ *	Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+#include <linux/module.h>
+#include <linux/rbtree.h>
+#include <linux/mutex.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+
+#include <linux/kvm.h>
+#include <linux/kvm_host.h>
+#include <linux/kvm_para.h>
+#include <linux/workqueue.h>
+#include <linux/hardirq.h>
+
+#include "lapic.h"
+
+struct dynirq {
+	struct kvm_dynirq *parent;
+	unsigned int       irq;
+	unsigned short     vec;
+	unsigned int       dest;
+	struct rb_node     node;
+	struct work_struct work;
+};
+
+static inline struct dynirq *
+to_dynirq(struct rb_node *node)
+{
+	return node ? container_of(node, struct dynirq, node) : NULL;
+}
+
+static int
+map_add(struct rb_root *root, struct dynirq *entry)
+{
+	int		ret = 0;
+	struct rb_node **new, *parent = NULL;
+	struct rb_node *node = &entry->node;
+
+	new  = &(root->rb_node);
+
+	/* Figure out where to put new node */
+	while (*new) {
+		int val;
+
+		parent = *new;
+
+		val = to_dynirq(node)->irq - to_dynirq(*new)->irq;
+		if (val < 0)
+			new = &((*new)->rb_left);
+		else if (val > 0)
+			new = &((*new)->rb_right);
+		else {
+			ret = -EEXIST;
+			break;
+		}
+	}
+
+	if (!ret) {
+		/* Add new node and rebalance tree. */
+		rb_link_node(node, parent, new);
+		rb_insert_color(node, root);
+	}
+
+	return ret;
+}
+
+static struct dynirq *
+map_find(struct rb_root *root, unsigned int key)
+{
+	struct rb_node *node;
+
+	node = root->rb_node;
+
+	while (node) {
+		int val;
+
+		val = key - to_dynirq(node)->irq;
+		if (val < 0)
+			node = node->rb_left;
+		else if (val > 0)
+			node = node->rb_right;
+		else
+			break;
+	}
+
+	return to_dynirq(node);
+}
+
+static void
+dynirq_add(struct kvm_dynirq *dynirq, struct dynirq *entry)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&dynirq->lock, flags);
+	ret = map_add(&dynirq->map, entry);
+	spin_unlock_irqrestore(&dynirq->lock, flags);
+}
+
+static struct dynirq *
+dynirq_find(struct kvm_dynirq *dynirq, int irq)
+{
+	struct dynirq *entry;
+	unsigned long flags;
+
+	spin_lock_irqsave(&dynirq->lock, flags);
+	entry = map_find(&dynirq->map, irq);
+	spin_unlock_irqrestore(&dynirq->lock, flags);
+
+	return entry;
+}
+
+static int
+_kvm_inject_dynirq(struct kvm *kvm, struct dynirq *entry)
+{
+	struct kvm_vcpu *vcpu;
+	int ret;
+
+	mutex_lock(&kvm->lock);
+
+	vcpu = kvm->vcpus[entry->dest];
+	if (!vcpu) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	ret = kvm_apic_set_irq(vcpu, entry->vec, 1);
+
+out:
+	mutex_unlock(&kvm->lock);
+
+	return ret;
+}
+
+static void
+deferred_inject_dynirq(struct work_struct *work)
+{
+	struct dynirq *entry = container_of(work, struct dynirq, work);
+	struct kvm_dynirq *dynirq = entry->parent;
+	struct kvm *kvm = dynirq->kvm;
+
+	_kvm_inject_dynirq(kvm, entry);
+}
+
+int
+kvm_inject_dynirq(struct kvm *kvm, int irq)
+{
+	struct kvm_dynirq *dynirq = kvm->arch.dynirq;
+	struct dynirq *entry;
+
+	entry = dynirq_find(dynirq, irq);
+	if (!entry)
+		return -EINVAL;
+
+	if (preemptible())
+		return _kvm_inject_dynirq(kvm, entry);
+
+	schedule_work(&entry->work);
+	return 0;
+}
+
+static int
+hc_set(struct kvm_vcpu *vcpu, gpa_t gpa, size_t len)
+{
+	struct kvm_dynirq_set args;
+	struct kvm_dynirq    *dynirq = vcpu->kvm->arch.dynirq;
+	struct dynirq        *entry;
+	int                   ret;
+
+	if (len != sizeof(args))
+		return -EINVAL;
+
+	ret = kvm_read_guest(vcpu->kvm, gpa, &args, len);
+	if (ret < 0)
+		return ret;
+
+	if (args.dest >= KVM_MAX_VCPUS)
+		return -EINVAL;
+
+	entry = dynirq_find(dynirq, args.irq);
+	if (!entry) {
+		entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+		INIT_WORK(&entry->work, deferred_inject_dynirq);
+	} else
+		rb_erase(&entry->node, &dynirq->map);
+
+	entry->irq  = args.irq;
+	entry->vec  = args.vec;
+	entry->dest = args.dest;
+
+	dynirq_add(dynirq, entry);
+
+	return 0;
+}
+
+static int
+hc_clear(struct kvm_vcpu *vcpu, gpa_t gpa, size_t len)
+{
+	struct kvm_dynirq *dynirq = vcpu->kvm->arch.dynirq;
+	struct dynirq *entry;
+	unsigned long flags;
+	u32 irq;
+	int ret;
+
+	if (len != sizeof(irq))
+		return -EINVAL;
+
+	ret = kvm_read_guest(vcpu->kvm, gpa, &irq, len);
+	if (ret < 0)
+		return ret;
+
+	spin_lock_irqsave(&dynirq->lock, flags);
+
+	entry = map_find(&dynirq->map, irq);
+	if (entry)
+		rb_erase(&entry->node, &dynirq->map);
+
+	spin_unlock_irqrestore(&dynirq->lock, flags);
+
+	if (!entry)
+		return -ENOENT;
+
+	kfree(entry);
+	return 0;
+}
+
+/*
+ * Our hypercall format will always follow with the call-id in arg[0],
+ * a pointer to the arguments in arg[1], and the argument length in arg[2]
+ */
+int
+kvm_dynirq_hc(struct kvm_vcpu *vcpu, int nr, gpa_t gpa, size_t len)
+{
+	int ret = -EINVAL;
+
+	mutex_lock(&vcpu->kvm->lock);
+
+	if (unlikely(!vcpu->kvm->arch.dynirq)) {
+		struct kvm_dynirq *dynirq;
+
+		dynirq = kzalloc(sizeof(*dynirq), GFP_KERNEL);
+		if (!dynirq)
+			return -ENOMEM;
+
+		spin_lock_init(&dynirq->lock);
+		dynirq->map = RB_ROOT;
+		dynirq->kvm = vcpu->kvm;
+		vcpu->kvm->arch.dynirq = dynirq;
+	}
+
+	switch (nr) {
+	case KVM_DYNIRQ_OP_SET:
+		ret = hc_set(vcpu, gpa, len);
+		break;
+	case KVM_DYNIRQ_OP_CLEAR:
+		ret = hc_clear(vcpu, gpa, len);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	mutex_unlock(&vcpu->kvm->lock);
+
+	return ret;
+}
+
+void
+kvm_free_dynirq(struct kvm *kvm)
+{
+	struct kvm_dynirq *dynirq = kvm->arch.dynirq;
+	struct rb_node *node;
+
+	while ((node = rb_first(&dynirq->map))) {
+		struct dynirq *entry = to_dynirq(node);
+
+		rb_erase(node, &dynirq->map);
+		kfree(entry);
+	}
+
+	kfree(dynirq);
+}
diff --git a/arch/x86/kvm/guest/Makefile b/arch/x86/kvm/guest/Makefile
new file mode 100644
index 0000000..de8f824
--- /dev/null
+++ b/arch/x86/kvm/guest/Makefile
@@ -0,0 +1,2 @@
+
+obj-$(CONFIG_KVM_GUEST_DYNIRQ) += dynirq.o
\ No newline at end of file
diff --git a/arch/x86/kvm/guest/dynirq.c b/arch/x86/kvm/guest/dynirq.c
new file mode 100644
index 0000000..a5cf55e
--- /dev/null
+++ b/arch/x86/kvm/guest/dynirq.c
@@ -0,0 +1,95 @@
+#include <linux/module.h>
+#include <linux/irq.h>
+#include <linux/kvm.h>
+#include <linux/kvm_para.h>
+
+#include <asm/irq.h>
+#include <asm/apic.h>
+
+/*
+ * -----------------------
+ * Dynamic-IRQ support
+ * -----------------------
+ */
+
+static int dynirq_set(int irq, int dest)
+{
+	struct kvm_dynirq_set op = {
+		.irq  = irq,
+		.vec  = irq_to_vector(irq),
+		.dest = dest,
+	};
+
+	return kvm_hypercall3(KVM_HC_DYNIRQ, KVM_DYNIRQ_OP_SET,
+			      __pa(&op), sizeof(op));
+}
+
+static void dynirq_chip_noop(unsigned int irq)
+{
+}
+
+static void dynirq_chip_eoi(unsigned int irq)
+{
+	ack_APIC_irq();
+}
+
+struct irq_chip kvm_irq_chip = {
+	.name		= "KVM-DYNIRQ",
+	.mask		= dynirq_chip_noop,
+	.unmask		= dynirq_chip_noop,
+	.eoi		= dynirq_chip_eoi,
+};
+
+int create_kvm_dynirq(int cpu)
+{
+	const cpumask_t *mask = get_cpu_mask(cpu);
+	int irq;
+	int ret;
+
+	ret = kvm_para_has_feature(KVM_FEATURE_DYNIRQ);
+	if (!ret)
+		return -ENOENT;
+
+	irq = create_irq();
+	if (irq < 0)
+		return -ENOSPC;
+
+#ifdef CONFIG_SMP
+	ret = set_irq_affinity(irq, *mask);
+	if (ret < 0)
+		goto error;
+#endif
+
+	set_irq_chip_and_handler_name(irq,
+				      &kvm_irq_chip,
+				      handle_percpu_irq,
+				      "apiceoi");
+
+	ret = dynirq_set(irq, cpu);
+	if (ret < 0)
+		goto error;
+
+	return irq;
+
+error:
+	destroy_irq(irq);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(create_kvm_dynirq);
+
+int destroy_kvm_dynirq(int irq)
+{
+	__u32 _irq = irq;
+
+	if (kvm_para_has_feature(KVM_FEATURE_DYNIRQ))
+		kvm_hypercall3(KVM_HC_DYNIRQ,
+			       KVM_DYNIRQ_OP_CLEAR,
+			       __pa(&_irq),
+			       sizeof(_irq));
+
+	destroy_irq(irq);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(destroy_kvm_dynirq);
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 9b0a649..e24f0a5 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -972,6 +972,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_MP_STATE:
 	case KVM_CAP_SYNC_MMU:
 	case KVM_CAP_RESET:
+	case KVM_CAP_DYNIRQ:
 		r = 1;
 		break;
 	case KVM_CAP_COALESCED_MMIO:
@@ -2684,6 +2685,9 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 	case KVM_HC_MMU_OP:
 		r = kvm_pv_mmu_op(vcpu, a0, hc_gpa(vcpu, a1, a2), &ret);
 		break;
+	case KVM_HC_DYNIRQ:
+		ret = kvm_dynirq_hc(vcpu, a0, a1, a2);
+		break;
 	default:
 		ret = -KVM_ENOSYS;
 		break;
@@ -4141,6 +4145,8 @@ void kvm_arch_destroy_vm(struct kvm *kvm)
 	kvm_free_pit(kvm);
 	kfree(kvm->arch.vpic);
 	kfree(kvm->arch.vioapic);
+	if (kvm->arch.dynirq)
+		kvm_free_dynirq(kvm);
 	kvm_free_vcpus(kvm);
 	kvm_free_physmem(kvm);
 	if (kvm->arch.apic_access_page)
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 7ffd8f5..349d273 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -397,6 +397,7 @@ struct kvm_trace_rec {
 #define KVM_CAP_USER_NMI 22
 #endif
 #define KVM_CAP_RESET 23
+#define KVM_CAP_DYNIRQ 24
 
 /*
  * ioctls for VM fds
diff --git a/include/linux/kvm_guest.h b/include/linux/kvm_guest.h
new file mode 100644
index 0000000..7dd7930
--- /dev/null
+++ b/include/linux/kvm_guest.h
@@ -0,0 +1,7 @@
+#ifndef __LINUX_KVM_GUEST_H
+#define __LINUX_KVM_GUEST_H
+
+extern int create_kvm_dynirq(int cpu);
+extern int destroy_kvm_dynirq(int irq);
+
+#endif /* __LINUX_KVM_GUEST_H */
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 506eca1..bec9b35 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -297,6 +297,7 @@ int kvm_cpu_get_interrupt(struct kvm_vcpu *v);
 int kvm_cpu_has_interrupt(struct kvm_vcpu *v);
 int kvm_cpu_has_pending_timer(struct kvm_vcpu *vcpu);
 void kvm_vcpu_kick(struct kvm_vcpu *vcpu);
+int kvm_inject_dynirq(struct kvm *kvm, int irq);
 
 int kvm_is_mmio_pfn(pfn_t pfn);
 
diff --git a/include/linux/kvm_para.h b/include/linux/kvm_para.h
index 3ddce03..a2de904 100644
--- a/include/linux/kvm_para.h
+++ b/include/linux/kvm_para.h
@@ -16,6 +16,7 @@
 
 #define KVM_HC_VAPIC_POLL_IRQ		1
 #define KVM_HC_MMU_OP			2
+#define KVM_HC_DYNIRQ			3
 
 /*
  * hypercalls use architecture specific

