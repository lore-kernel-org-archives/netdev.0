From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 16/19] kvm: Add VBUS support to the host
Date: Thu, 09 Apr 2009 12:32:05 -0400
Message-ID: <20090409163205.32740.60958.stgit@dev.haskins.net>
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
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for guest access to a VBUS assigned to the same
context as the VM.  It utilizes a IOQ+IRQ to move events from host->guest,
and provides a hypercall interface to move events guest->host.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 arch/x86/include/asm/kvm_para.h |    1 
 arch/x86/kvm/Kconfig            |    9 
 arch/x86/kvm/Makefile           |    3 
 arch/x86/kvm/x86.c              |    6 
 arch/x86/kvm/x86.h              |   12 
 include/linux/kvm.h             |    1 
 include/linux/kvm_host.h        |   20 +
 include/linux/kvm_para.h        |   59 ++
 virt/kvm/kvm_main.c             |    1 
 virt/kvm/vbus.c                 | 1307 +++++++++++++++++++++++++++++++++++++++
 10 files changed, 1419 insertions(+), 0 deletions(-)
 create mode 100644 virt/kvm/vbus.c

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index fba210e..19d81e0 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -14,6 +14,7 @@
 #define KVM_FEATURE_NOP_IO_DELAY	1
 #define KVM_FEATURE_MMU_OP		2
 #define KVM_FEATURE_DYNIRQ		3
+#define KVM_FEATURE_VBUS                4
 
 #define MSR_KVM_WALL_CLOCK  0x11
 #define MSR_KVM_SYSTEM_TIME 0x12
diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index b81125f..875e96e 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -64,6 +64,15 @@ config KVM_TRACE
 	  relayfs.  Note the ABI is not considered stable and will be
 	  modified in future updates.
 
+config KVM_HOST_VBUS
+       bool "KVM virtual-bus (VBUS) host-side support"
+       depends on KVM
+       select VBUS
+       default n
+       ---help---
+          This option enables host-side support for accessing virtual-bus
+	  devices.
+
 # OK, it's a little counter-intuitive to do this, but it puts it neatly under
 # the virtualization menu.
 source drivers/lguest/Kconfig
diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
index d5676f5..f749ec9 100644
--- a/arch/x86/kvm/Makefile
+++ b/arch/x86/kvm/Makefile
@@ -15,6 +15,9 @@ EXTRA_CFLAGS += -Ivirt/kvm -Iarch/x86/kvm
 
 kvm-objs := $(common-objs) x86.o mmu.o x86_emulate.o i8259.o irq.o lapic.o \
 	i8254.o dynirq.o
+ifeq ($(CONFIG_KVM_HOST_VBUS),y)
+kvm-objs += $(addprefix ../../../virt/kvm/, vbus.o)
+endif
 obj-$(CONFIG_KVM) += kvm.o
 kvm-intel-objs = vmx.o
 obj-$(CONFIG_KVM_INTEL) += kvm-intel.o
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e24f0a5..2369d84 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -996,6 +996,9 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_CLOCKSOURCE:
 		r = boot_cpu_has(X86_FEATURE_CONSTANT_TSC);
 		break;
+	case KVM_CAP_VBUS:
+		r = kvm_vbus_support();
+		break;
 	default:
 		r = 0;
 		break;
@@ -2688,6 +2691,9 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 	case KVM_HC_DYNIRQ:
 		ret = kvm_dynirq_hc(vcpu, a0, a1, a2);
 		break;
+	case KVM_HC_VBUS:
+		ret = kvm_vbus_hc(vcpu, a0, a1, a2);
+		break;
 	default:
 		ret = -KVM_ENOSYS;
 		break;
diff --git a/arch/x86/kvm/x86.h b/arch/x86/kvm/x86.h
index 6a4be78..b6c682b 100644
--- a/arch/x86/kvm/x86.h
+++ b/arch/x86/kvm/x86.h
@@ -3,6 +3,18 @@
 
 #include <linux/kvm_host.h>
 
+#ifdef CONFIG_KVM_HOST_VBUS
+static inline int kvm_vbus_support(void)
+{
+    return 1;
+}
+#else
+static inline int kvm_vbus_support(void)
+{
+    return 0;
+}
+#endif
+
 static inline void kvm_clear_exception_queue(struct kvm_vcpu *vcpu)
 {
 	vcpu->arch.exception.pending = false;
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 349d273..077daac 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -398,6 +398,7 @@ struct kvm_trace_rec {
 #endif
 #define KVM_CAP_RESET 23
 #define KVM_CAP_DYNIRQ 24
+#define KVM_CAP_VBUS 25
 
 /*
  * ioctls for VM fds
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index bec9b35..757f998 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -120,6 +120,9 @@ struct kvm {
 	struct list_head vm_list;
 	struct kvm_io_bus mmio_bus;
 	struct kvm_io_bus pio_bus;
+#ifdef CONFIG_KVM_HOST_VBUS
+	struct kvm_vbus *kvbus;
+#endif
 	struct kvm_vm_stat stat;
 	struct kvm_arch arch;
 	atomic_t users_count;
@@ -471,4 +474,21 @@ static inline int mmu_notifier_retry(struct kvm_vcpu *vcpu, unsigned long mmu_se
 }
 #endif
 
+#ifdef CONFIG_KVM_HOST_VBUS
+
+int kvm_vbus_hc(struct kvm_vcpu *vcpu, int nr, gpa_t gpa, size_t len);
+void kvm_vbus_release(struct kvm_vbus *kvbus);
+
+#else /* CONFIG_KVM_HOST_VBUS */
+
+static inline int
+kvm_vbus_hc(struct kvm_vcpu *vcpu, int nr, gpa_t gpa, size_t len)
+{
+	return -EINVAL;
+}
+
+#define kvm_vbus_release(kvbus) do {} while (0)
+
+#endif /* CONFIG_KVM_HOST_VBUS */
+
 #endif
diff --git a/include/linux/kvm_para.h b/include/linux/kvm_para.h
index a2de904..ca5203c 100644
--- a/include/linux/kvm_para.h
+++ b/include/linux/kvm_para.h
@@ -17,6 +17,65 @@
 #define KVM_HC_VAPIC_POLL_IRQ		1
 #define KVM_HC_MMU_OP			2
 #define KVM_HC_DYNIRQ			3
+#define KVM_HC_VBUS			4
+
+/* Payload of KVM_HC_VBUS */
+#define KVM_VBUS_MAGIC   0x27fdab45
+#define KVM_VBUS_VERSION 1
+
+enum kvm_vbus_op{
+	KVM_VBUS_OP_BUSOPEN,
+	KVM_VBUS_OP_BUSREG,
+	KVM_VBUS_OP_DEVOPEN,
+	KVM_VBUS_OP_DEVCLOSE,
+	KVM_VBUS_OP_DEVCALL,
+	KVM_VBUS_OP_DEVSHM,
+	KVM_VBUS_OP_SHMSIGNAL,
+};
+
+struct kvm_vbus_busopen {
+	__u32 magic;
+	__u32 version;
+	__u64 capabilities;
+};
+
+struct kvm_vbus_eventqreg {
+	__u32 irq;
+	__u32 count;
+	__u64 ring;
+	__u64 data;
+};
+
+struct kvm_vbus_busreg {
+	__u32 count;  /* supporting multiple queues allows for prio, etc */
+	struct kvm_vbus_eventqreg eventq[1];
+};
+
+enum kvm_vbus_eventid {
+	KVM_VBUS_EVENT_DEVADD,
+	KVM_VBUS_EVENT_DEVDROP,
+	KVM_VBUS_EVENT_SHMSIGNAL,
+	KVM_VBUS_EVENT_SHMCLOSE,
+};
+
+#define VBUS_MAX_DEVTYPE_LEN 128
+
+struct kvm_vbus_add_event {
+	__u64  id;
+	char type[VBUS_MAX_DEVTYPE_LEN];
+};
+
+struct kvm_vbus_handle_event {
+	__u64 handle;
+};
+
+struct kvm_vbus_event {
+	__u32 eventid;
+	union {
+		struct kvm_vbus_add_event    add;
+		struct kvm_vbus_handle_event handle;
+	} data;
+};
 
 /*
  * hypercalls use architecture specific
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index fca2d25..2e4ba8b 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -942,6 +942,7 @@ static int kvm_vm_release(struct inode *inode, struct file *filp)
 {
 	struct kvm *kvm = filp->private_data;
 
+	kvm_vbus_release(kvm->kvbus);
 	kvm_put_kvm(kvm);
 	return 0;
 }
diff --git a/virt/kvm/vbus.c b/virt/kvm/vbus.c
new file mode 100644
index 0000000..17b3392
--- /dev/null
+++ b/virt/kvm/vbus.c
@@ -0,0 +1,1307 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
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
+
+#include <linux/module.h>
+#include <linux/rbtree.h>
+#include <linux/spinlock.h>
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <linux/ioq.h>
+
+#include <linux/kvm.h>
+#include <linux/kvm_host.h>
+#include <linux/kvm_para.h>
+#include <linux/vbus.h>
+#include <linux/vbus_client.h>
+
+#undef PDEBUG
+#ifdef KVMVBUS_DEBUG
+#include <linux/ftrace.h>
+#  define PDEBUG(fmt, args...) ftrace_printk(fmt, ## args)
+#else
+#  define PDEBUG(fmt, args...)
+#endif
+
+struct kvm_vbus_eventq {
+	spinlock_t          lock;
+	struct ioq         *ioq;
+	struct ioq_notifier notifier;
+	struct list_head    backlog;
+	struct {
+		u64         gpa;
+		size_t      len;
+		void       *ptr;
+	} ringdata;
+	struct work_struct  work;
+	int                 backpressure:1;
+};
+
+enum kvm_vbus_state {
+	kvm_vbus_state_init,
+	kvm_vbus_state_registration,
+	kvm_vbus_state_running,
+};
+
+struct kvm_vbus {
+	struct mutex	        lock;
+	enum kvm_vbus_state     state;
+	struct kvm             *kvm;
+	struct vbus            *vbus;
+	struct vbus_client     *client;
+	struct kvm_vbus_eventq  eventq;
+	struct work_struct      destruct;
+	struct vbus_memctx     *ctx;
+	struct {
+		struct notifier_block vbus;
+		struct notifier_block reset;
+	} notify;
+};
+
+struct vbus_client *to_client(struct kvm_vcpu *vcpu)
+{
+	return vcpu ? vcpu->kvm->kvbus->client : NULL;
+}
+
+static void*
+kvm_vmap(struct kvm *kvm, gpa_t gpa, size_t len)
+{
+	struct page **page_list;
+	void *ptr = NULL;
+	unsigned long addr;
+	off_t offset;
+	size_t npages;
+	int ret;
+
+	addr = gfn_to_hva(kvm, gpa >> PAGE_SHIFT);
+
+	offset = offset_in_page(gpa);
+	npages = PAGE_ALIGN(len + offset) >> PAGE_SHIFT;
+
+	if (npages > (PAGE_SIZE / sizeof(struct page *)))
+		return NULL;
+
+	page_list = (struct page **) __get_free_page(GFP_KERNEL);
+	if (!page_list)
+		return NULL;
+
+	ret = get_user_pages_fast(addr, npages, 1, page_list);
+	if (ret < 0)
+		goto out;
+
+	down_write(&current->mm->mmap_sem);
+
+	ptr = vmap(page_list, npages, VM_MAP, PAGE_KERNEL);
+	if (ptr)
+		current->mm->locked_vm += npages;
+
+	up_write(&current->mm->mmap_sem);
+
+	ptr = ptr+offset;
+
+out:
+	free_page((unsigned long)page_list);
+
+	return ptr;
+}
+
+static void
+kvm_vunmap(void *ptr)
+{
+	/* FIXME: do we need to adjust current->mm->locked_vm? */
+	vunmap((void *)((unsigned long)ptr & PAGE_MASK));
+}
+
+/*
+ * -----------------
+ * kvm_shm routines
+ * -----------------
+ */
+
+struct kvm_shm {
+	struct kvm_vbus   *kvbus;
+	struct vbus_shm    shm;
+};
+
+static void
+kvm_shm_release(struct vbus_shm *shm)
+{
+	struct kvm_shm *_shm = container_of(shm, struct kvm_shm, shm);
+
+	kvm_vunmap(_shm->shm.ptr);
+	kfree(_shm);
+}
+
+static struct vbus_shm_ops kvm_shm_ops = {
+	.release = kvm_shm_release,
+};
+
+static int
+kvm_shm_map(struct kvm_vbus *kvbus, __u64 ptr, __u32 len, struct kvm_shm **kshm)
+{
+	struct kvm_shm *_shm;
+	void *vmap;
+
+	if (!can_do_mlock())
+		return -EPERM;
+
+	_shm = kzalloc(sizeof(*_shm), GFP_KERNEL);
+	if (!_shm)
+		return -ENOMEM;
+
+	_shm->kvbus = kvbus;
+
+	vmap = kvm_vmap(kvbus->kvm, ptr, len);
+	if (!vmap) {
+		kfree(_shm);
+		return -EFAULT;
+	}
+
+	vbus_shm_init(&_shm->shm, &kvm_shm_ops, vmap, len);
+
+	*kshm = _shm;
+
+	return 0;
+}
+
+/*
+ * -----------------
+ * vbus_memctx routines
+ * -----------------
+ */
+
+struct kvm_memctx {
+	struct kvm *kvm;
+	struct vbus_memctx *taskmem;
+	struct vbus_memctx ctx;
+};
+
+static struct kvm_memctx *to_kvm_memctx(struct vbus_memctx *ctx)
+{
+	return container_of(ctx, struct kvm_memctx, ctx);
+}
+
+
+static unsigned long
+kvm_memctx_copy_to(struct vbus_memctx *ctx, void *dst, const void *src,
+	       unsigned long n)
+{
+	struct kvm_memctx *kvm_memctx = to_kvm_memctx(ctx);
+	struct vbus_memctx *tm = kvm_memctx->taskmem;
+	gpa_t gpa = (gpa_t)dst;
+	unsigned long addr;
+	int offset;
+
+	addr = gfn_to_hva(kvm_memctx->kvm, gpa >> PAGE_SHIFT);
+	offset = offset_in_page(gpa);
+
+	return tm->ops->copy_to(tm, (void *)(addr + offset), src, n);
+}
+
+static unsigned long
+kvm_memctx_copy_from(struct vbus_memctx *ctx, void *dst, const void *src,
+		  unsigned long n)
+{
+	struct kvm_memctx *kvm_memctx = to_kvm_memctx(ctx);
+	struct vbus_memctx *tm = kvm_memctx->taskmem;
+	gpa_t gpa = (gpa_t)src;
+	unsigned long addr;
+	int offset;
+
+	addr = gfn_to_hva(kvm_memctx->kvm, gpa >> PAGE_SHIFT);
+	offset = offset_in_page(gpa);
+
+	return tm->ops->copy_from(tm, dst, (void *)(addr + offset), n);
+}
+
+static void
+kvm_memctx_release(struct vbus_memctx *ctx)
+{
+	struct kvm_memctx *kvm_memctx = to_kvm_memctx(ctx);
+
+	vbus_memctx_put(kvm_memctx->taskmem);
+	kvm_put_kvm(kvm_memctx->kvm);
+
+	kfree(kvm_memctx);
+}
+
+static struct vbus_memctx_ops kvm_memctx_ops = {
+	.copy_to   = &kvm_memctx_copy_to,
+	.copy_from = &kvm_memctx_copy_from,
+	.release   = &kvm_memctx_release,
+};
+
+struct vbus_memctx *kvm_memctx_alloc(struct kvm *kvm)
+{
+	struct kvm_memctx *kvm_memctx;
+
+	kvm_memctx = kzalloc(sizeof(*kvm_memctx), GFP_KERNEL);
+	if (!kvm_memctx)
+		return NULL;
+
+	kvm_get_kvm(kvm);
+	kvm_memctx->kvm = kvm;
+
+	kvm_memctx->taskmem = task_memctx_alloc(current);
+	vbus_memctx_init(&kvm_memctx->ctx, &kvm_memctx_ops);
+
+	return &kvm_memctx->ctx;
+}
+
+/*
+ * -----------------
+ * general routines
+ * -----------------
+ */
+
+static int
+_signal_init(struct kvm *kvm, struct shm_signal_desc *desc,
+	     struct shm_signal *signal, struct shm_signal_ops *ops)
+{
+	if (desc->magic != SHM_SIGNAL_MAGIC)
+		return -EINVAL;
+
+	if (desc->ver != SHM_SIGNAL_VER)
+		return -EINVAL;
+
+	shm_signal_init(signal);
+
+	signal->locale    = shm_locality_south;
+	signal->ops       = ops;
+	signal->desc      = desc;
+
+	return 0;
+}
+
+static struct kvm_vbus_event *
+event_ptr_translate(struct kvm_vbus_eventq *eventq, u64 ptr)
+{
+	u64 off = ptr - eventq->ringdata.gpa;
+
+	if ((ptr < eventq->ringdata.gpa)
+	    || (off > (eventq->ringdata.len - sizeof(struct kvm_vbus_event))))
+		return NULL;
+
+	return eventq->ringdata.ptr + off;
+}
+
+/*
+ * ------------------
+ * event-object code
+ * ------------------
+ */
+
+struct _event {
+	atomic_t              refs;
+	struct list_head      list;
+	struct kvm_vbus_event data;
+};
+
+static void
+_event_init(struct _event *event)
+{
+	memset(event, 0, sizeof(*event));
+	atomic_set(&event->refs, 1);
+	INIT_LIST_HEAD(&event->list);
+}
+
+static void
+_event_get(struct _event *event)
+{
+	atomic_inc(&event->refs);
+}
+
+static inline void
+_event_put(struct _event *event)
+{
+	if (atomic_dec_and_test(&event->refs))
+		kfree(event);
+}
+
+/*
+ * ------------------
+ * event-inject code
+ * ------------------
+ */
+
+static struct kvm_vbus_eventq *notify_to_eventq(struct ioq_notifier *notifier)
+{
+	return container_of(notifier, struct kvm_vbus_eventq, notifier);
+}
+
+static struct kvm_vbus_eventq *work_to_eventq(struct work_struct *work)
+{
+	return container_of(work, struct kvm_vbus_eventq, work);
+}
+
+/*
+ * This is invoked by the guest whenever they signal our eventq when
+ * we have notifications enabled
+ */
+static void
+eventq_notify(struct ioq_notifier *notifier)
+{
+	struct kvm_vbus_eventq *eventq = notify_to_eventq(notifier);
+	unsigned long           flags;
+
+	spin_lock_irqsave(&eventq->lock, flags);
+
+	if (!ioq_full(eventq->ioq, ioq_idxtype_inuse)) {
+		eventq->backpressure = false;
+		ioq_notify_disable(eventq->ioq, 0);
+		schedule_work(&eventq->work);
+	}
+
+	spin_unlock_irqrestore(&eventq->lock, flags);
+}
+
+static void
+events_flush(struct kvm_vbus_eventq *eventq)
+{
+	struct ioq_iterator     iter;
+	int                     ret;
+	unsigned long           flags;
+	struct _event          *_event, *tmp;
+	int                     dirty = 0;
+
+	spin_lock_irqsave(&eventq->lock, flags);
+
+	/* We want to iterate on the tail of the in-use index */
+	ret = ioq_iter_init(eventq->ioq, &iter, ioq_idxtype_inuse, 0);
+	BUG_ON(ret < 0);
+
+	ret = ioq_iter_seek(&iter, ioq_seek_tail, 0, 0);
+	BUG_ON(ret < 0);
+
+	list_for_each_entry_safe(_event, tmp, &eventq->backlog, list) {
+		struct kvm_vbus_event *ev;
+
+		if (!iter.desc->sown) {
+			eventq->backpressure = true;
+			ioq_notify_enable(eventq->ioq, 0);
+			break;
+		}
+
+		if (iter.desc->len < sizeof(*ev)) {
+			SHM_SIGNAL_FAULT(eventq->ioq->signal,
+					 "Desc too small on eventq: %p: %d<%d",
+					 iter.desc->ptr,
+					 iter.desc->len, sizeof(*ev));
+			break;
+		}
+
+		ev = event_ptr_translate(eventq, iter.desc->ptr);
+		if (!ev) {
+			SHM_SIGNAL_FAULT(eventq->ioq->signal,
+					 "Invalid address on eventq: %p",
+					 iter.desc->ptr);
+			break;
+		}
+
+		memcpy(ev, &_event->data, sizeof(*ev));
+
+		list_del_init(&_event->list);
+		_event_put(_event);
+
+		ret = ioq_iter_push(&iter, 0);
+		BUG_ON(ret < 0);
+
+		dirty = 1;
+	}
+
+	spin_unlock_irqrestore(&eventq->lock, flags);
+
+	/*
+	 * Signal the IOQ outside of the spinlock so that we can potentially
+	 * directly inject this interrupt instead of deferring it
+	 */
+	if (dirty)
+		ioq_signal(eventq->ioq, 0);
+}
+
+static int
+event_inject(struct kvm_vbus_eventq *eventq, struct _event *_event)
+{
+	unsigned long flags;
+
+	if (!list_empty(&_event->list))
+		return -EBUSY;
+
+	spin_lock_irqsave(&eventq->lock, flags);
+	list_add_tail(&_event->list, &eventq->backlog);
+	spin_unlock_irqrestore(&eventq->lock, flags);
+
+	events_flush(eventq);
+
+	return 0;
+}
+
+static void
+eventq_reinject(struct work_struct *work)
+{
+	struct kvm_vbus_eventq *eventq = work_to_eventq(work);
+
+	events_flush(eventq);
+}
+
+/*
+ * devadd/drop are in the slow path and are rare enough that we will
+ * simply allocate memory for the event from the heap
+ */
+static int
+devadd_inject(struct kvm_vbus_eventq *eventq, const char *type, u64 id)
+{
+	struct _event *_event;
+	struct kvm_vbus_add_event *ae;
+	int ret;
+
+	_event = kmalloc(sizeof(*_event), GFP_KERNEL);
+	if (!_event)
+		return -ENOMEM;
+
+	_event_init(_event);
+
+	_event->data.eventid = KVM_VBUS_EVENT_DEVADD;
+	ae = (struct kvm_vbus_add_event *)&_event->data.data;
+	ae->id = id;
+	strncpy(ae->type, type, VBUS_MAX_DEVTYPE_LEN);
+
+	ret = event_inject(eventq, _event);
+	if (ret < 0)
+		_event_put(_event);
+
+	return ret;
+}
+
+/*
+ * "handle" events are used to send any kind of event that simply
+ * uses a handle as a parameter.  This includes things like DEVDROP
+ * and SHMSIGNAL, etc.
+ */
+static struct _event *
+handle_event_alloc(u64 id, u64 handle)
+{
+	struct _event *_event;
+	struct kvm_vbus_handle_event *he;
+
+	_event = kmalloc(sizeof(*_event), GFP_KERNEL);
+	if (!_event)
+		return NULL;
+
+	_event_init(_event);
+	_event->data.eventid = id;
+
+	he = (struct kvm_vbus_handle_event *)&_event->data.data;
+	he->handle = handle;
+
+	return _event;
+}
+
+static int
+devdrop_inject(struct kvm_vbus_eventq *eventq, u64 id)
+{
+	struct _event *_event;
+	int ret;
+
+	_event = handle_event_alloc(KVM_VBUS_EVENT_DEVDROP, id);
+	if (!_event)
+		return -ENOMEM;
+
+	ret = event_inject(eventq, _event);
+	if (ret < 0)
+		_event_put(_event);
+
+	return ret;
+}
+
+static struct kvm_vbus_eventq *
+prio_to_eventq(struct kvm_vbus *kvbus, int prio)
+{
+	/*
+	 * NOTE: priority is ignored for now...all events aggregate onto a
+	 * single queue
+	 */
+
+	return &kvbus->eventq;
+}
+
+/*
+ * -----------------
+ * event ioq
+ *
+ * This queue is used by the infrastructure to transmit events (such as
+ * "new device", or "signal an ioq") to the guest.  We do this so that
+ * we minimize the number of hypercalls required to inject an event.
+ * In theory, the guest only needs to process a single interrupt vector
+ * and it doesnt require switching back to host context since the state
+ * is placed within the ring
+ * -----------------
+ */
+
+struct eventq_signal {
+	struct kvm_vbus   *kvbus;
+	struct vbus_shm   *shm;
+	struct shm_signal  signal;
+	int                irq;
+};
+
+static struct eventq_signal *signal_to_eventq(struct shm_signal *signal)
+{
+       return container_of(signal, struct eventq_signal, signal);
+}
+
+static int
+eventq_signal_inject(struct shm_signal *signal)
+{
+	struct eventq_signal *_signal = signal_to_eventq(signal);
+	struct kvm *kvm = _signal->kvbus->kvm;
+
+	/* Inject an interrupt to the guest */
+	kvm_inject_dynirq(kvm, _signal->irq);
+
+	return 0;
+}
+
+static void
+eventq_signal_release(struct shm_signal *signal)
+{
+	struct eventq_signal *_signal = signal_to_eventq(signal);
+
+	vbus_shm_put(_signal->shm);
+	kfree(_signal);
+}
+
+static struct shm_signal_ops eventq_signal_ops = {
+	.inject  = eventq_signal_inject,
+	.release = eventq_signal_release,
+};
+
+static int
+_eventq_attach(struct kvm_vbus *kvbus, __u32 count, __u64 ptr, int irq,
+	       struct ioq **ioq)
+{
+	struct ioq_ring_head *desc;
+	struct eventq_signal *_signal = NULL;
+	struct kvm_shm *_shm = NULL;
+	size_t len = IOQ_HEAD_DESC_SIZE(count);
+	int ret;
+
+	ret = kvm_shm_map(kvbus, ptr, len, &_shm);
+	if (ret < 0)
+		return ret;
+
+	_signal = kzalloc(sizeof(*_signal), GFP_KERNEL);
+	if (!_signal) {
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	desc = _shm->shm.ptr;
+
+	ret = _signal_init(kvbus->kvm,
+			   &desc->signal,
+			   &_signal->signal,
+			   &eventq_signal_ops);
+	if (ret < 0) {
+		kfree(_signal);
+		_signal = NULL;
+		goto error;
+	}
+
+	_signal->kvbus = kvbus;
+	_signal->irq   = irq;
+	_signal->shm   = &_shm->shm;
+	vbus_shm_get(&_shm->shm); /* dropped when the signal releases */
+
+	/* FIXME: we should make maxcount configurable */
+	ret = vbus_shm_ioq_attach(&_shm->shm, &_signal->signal, 2048, ioq);
+	if (ret < 0)
+		goto error;
+
+	return 0;
+
+error:
+	if (_signal)
+		shm_signal_put(&_signal->signal);
+
+	if (_shm)
+		vbus_shm_put(&_shm->shm);
+
+	return ret;
+}
+
+/*
+ * -----------------
+ * device_signal routines
+ *
+ * This is the more standard signal that is allocated to communicate
+ * with a specific device's shm region
+ * -----------------
+ */
+
+struct device_signal {
+	struct kvm_vbus   *kvbus;
+	struct vbus_shm   *shm;
+	struct shm_signal  signal;
+	struct _event     *inject;
+	int                prio;
+	u64                handle;
+};
+
+static struct device_signal *to_dsig(struct shm_signal *signal)
+{
+       return container_of(signal, struct device_signal, signal);
+}
+
+static void
+_device_signal_inject(struct device_signal *_signal)
+{
+	struct kvm_vbus_eventq *eventq;
+	int ret;
+
+	eventq = prio_to_eventq(_signal->kvbus, _signal->prio);
+
+	ret = event_inject(eventq, _signal->inject);
+	if (ret < 0)
+		_event_put(_signal->inject);
+}
+
+static int
+device_signal_inject(struct shm_signal *signal)
+{
+	struct device_signal *_signal = to_dsig(signal);
+
+	_event_get(_signal->inject); /* will be dropped by injection code */
+	_device_signal_inject(_signal);
+
+	return 0;
+}
+
+static void
+device_signal_release(struct shm_signal *signal)
+{
+	struct device_signal *_signal = to_dsig(signal);
+	struct kvm_vbus_eventq *eventq;
+	unsigned long flags;
+
+	eventq = prio_to_eventq(_signal->kvbus, _signal->prio);
+
+	/*
+	 * Change the event-type while holding the lock so we do not race
+	 * with any potential threads already processing the queue
+	 */
+	spin_lock_irqsave(&eventq->lock, flags);
+	_signal->inject->data.eventid = KVM_VBUS_EVENT_SHMCLOSE;
+	spin_unlock_irqrestore(&eventq->lock, flags);
+
+	/*
+	 * do not take a reference to event..last will be dropped once
+	 * transmitted.
+	 */
+	_device_signal_inject(_signal);
+
+	vbus_shm_put(_signal->shm);
+	kfree(_signal);
+}
+
+static struct shm_signal_ops device_signal_ops = {
+	.inject  = device_signal_inject,
+	.release = device_signal_release,
+};
+
+static int
+device_signal_alloc(struct kvm_vbus *kvbus, struct vbus_shm *shm,
+		    u32 offset, u32 prio, u64 cookie,
+		    struct device_signal **dsignal)
+{
+	struct device_signal *_signal;
+	int ret;
+
+	_signal = kzalloc(sizeof(*_signal), GFP_KERNEL);
+	if (!_signal)
+		return -ENOMEM;
+
+	ret = _signal_init(kvbus->kvm, shm->ptr + offset,
+			   &_signal->signal,
+			   &device_signal_ops);
+	if (ret < 0) {
+		kfree(_signal);
+		return ret;
+	}
+
+	_signal->inject = handle_event_alloc(KVM_VBUS_EVENT_SHMSIGNAL, cookie);
+	if (!_signal->inject) {
+		shm_signal_put(&_signal->signal);
+		return -ENOMEM;
+	}
+
+	_signal->kvbus  = kvbus;
+	_signal->shm    = shm;
+	_signal->prio   = prio;
+	vbus_shm_get(shm); /* dropped when the signal is released */
+
+	*dsignal = _signal;
+
+	return 0;
+}
+
+/*
+ * ------------------
+ * notifiers
+ * ------------------
+ */
+
+/*
+ * This is called whenever our associated vbus emits an event.  We inject
+ * these events at the highest logical priority
+ */
+static int
+vbus_notifier(struct notifier_block *nb, unsigned long nr, void *data)
+{
+	struct kvm_vbus *kvbus = container_of(nb, struct kvm_vbus, notify.vbus);
+	struct kvm_vbus_eventq *eventq = prio_to_eventq(kvbus, 0);
+
+	switch (nr) {
+	case VBUS_EVENT_DEVADD: {
+		struct vbus_event_devadd *ev = data;
+
+		devadd_inject(eventq, ev->type, ev->id);
+		break;
+	}
+	case VBUS_EVENT_DEVDROP: {
+		unsigned long id = *(unsigned long *)data;
+
+		devdrop_inject(eventq, id);
+		break;
+	}
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+static void
+deferred_destruct(struct work_struct *work)
+{
+	struct kvm_vbus *kvbus = container_of(work, struct kvm_vbus, destruct);
+
+	kvm_vbus_release(kvbus);
+}
+
+/*
+ * This is called if the guest reboots...we should release our association
+ * with the vbus (if any)
+ */
+static int
+reset_notifier(struct notifier_block *nb, unsigned long nr, void *data)
+{
+	struct kvm_vbus *kvbus = container_of(nb, struct kvm_vbus,
+					      notify.reset);
+
+	schedule_work(&kvbus->destruct);
+	kvbus->kvm->kvbus = NULL;
+
+	return NOTIFY_DONE;
+}
+
+static int
+kvm_vbus_eventq_attach(struct kvm_vbus *kvbus, struct kvm_vbus_eventq *eventq,
+		      u32 count, u64 ring, u64 data, int irq)
+{
+	struct ioq *ioq;
+	size_t len;
+	void *ptr;
+	int ret;
+
+	if (eventq->ioq)
+		return -EINVAL;
+
+	ret = _eventq_attach(kvbus, count, ring, irq, &ioq);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * We are going to pre-vmap the eventq data for performance reasons
+	 */
+	len = count * sizeof(struct kvm_vbus_event);
+	ptr =  kvm_vmap(kvbus->kvm, data, len);
+	if (!ptr) {
+		ioq_put(ioq);
+		return -EFAULT;
+	}
+
+	spin_lock_init(&eventq->lock);
+	eventq->ioq = ioq;
+	INIT_WORK(&eventq->work, eventq_reinject);
+
+	eventq->notifier.signal = eventq_notify;
+	ioq->notifier = &eventq->notifier;
+
+	INIT_LIST_HEAD(&eventq->backlog);
+
+	eventq->ringdata.len = len;
+	eventq->ringdata.gpa = data;
+	eventq->ringdata.ptr = ptr;
+
+	return 0;
+}
+
+static void
+kvm_vbus_eventq_detach(struct kvm_vbus_eventq *eventq)
+{
+	if (eventq->ioq)
+		ioq_put(eventq->ioq);
+
+	if (eventq->ringdata.ptr)
+		kvm_vunmap(eventq->ringdata.ptr);
+}
+
+static int
+kvm_vbus_alloc(struct kvm_vcpu *vcpu)
+{
+	struct vbus *vbus = task_vbus_get(current);
+	struct vbus_client *client;
+	struct kvm_vbus *kvbus;
+	int ret;
+
+	if (!vbus)
+		return -EPERM;
+
+	client = vbus_client_attach(vbus);
+	if (!client) {
+		vbus_put(vbus);
+		return -ENOMEM;
+	}
+
+	kvbus = kzalloc(sizeof(*kvbus), GFP_KERNEL);
+	if (!kvbus) {
+		vbus_put(vbus);
+		vbus_client_put(client);
+		return -ENOMEM;
+	}
+
+	mutex_init(&kvbus->lock);
+	kvbus->state = kvm_vbus_state_registration;
+	kvbus->kvm = vcpu->kvm;
+	kvbus->vbus = vbus;
+	kvbus->client = client;
+
+	vcpu->kvm->kvbus = kvbus;
+
+	INIT_WORK(&kvbus->destruct, deferred_destruct);
+	kvbus->ctx = kvm_memctx_alloc(vcpu->kvm);
+
+	kvbus->notify.vbus.notifier_call = vbus_notifier;
+	kvbus->notify.vbus.priority = 0;
+
+	kvbus->notify.reset.notifier_call = reset_notifier;
+	kvbus->notify.reset.priority = 0;
+
+	ret = kvm_reset_notifier_register(vcpu->kvm, &kvbus->notify.reset);
+	if (ret < 0) {
+		kvm_vbus_release(kvbus);
+		return ret;
+	}
+
+	return 0;
+}
+
+void
+kvm_vbus_release(struct kvm_vbus *kvbus)
+{
+	if (!kvbus)
+		return;
+
+	if (kvbus->ctx)
+		vbus_memctx_put(kvbus->ctx);
+
+	kvm_vbus_eventq_detach(&kvbus->eventq);
+
+	if (kvbus->client)
+		vbus_client_put(kvbus->client);
+
+	if (kvbus->vbus) {
+		vbus_notifier_unregister(kvbus->vbus, &kvbus->notify.vbus);
+		vbus_put(kvbus->vbus);
+	}
+
+	kvm_reset_notifier_unregister(kvbus->kvm, &kvbus->notify.reset);
+
+	flush_scheduled_work();
+
+	kvbus->kvm->kvbus = NULL;
+
+	kfree(kvbus);
+}
+
+/*
+ * ------------------
+ * hypercall implementation
+ * ------------------
+ */
+
+static int
+hc_busopen(struct kvm_vcpu *vcpu, void *data)
+{
+	struct kvm_vbus_busopen *args = data;
+
+	if (vcpu->kvm->kvbus)
+		return -EEXIST;
+
+	if (args->magic != KVM_VBUS_MAGIC)
+		return -EINVAL;
+
+	if (args->version != KVM_VBUS_VERSION)
+		return -EINVAL;
+
+	args->capabilities = 0;
+
+	return kvm_vbus_alloc(vcpu);
+}
+
+static int
+hc_busreg(struct kvm_vcpu *vcpu, void *data)
+{
+	struct kvm_vbus_busreg *args = data;
+	struct kvm_vbus_eventqreg *qreg = &args->eventq[0];
+	struct kvm_vbus *kvbus = vcpu->kvm->kvbus;
+	int ret;
+
+	if (args->count != 1)
+		return -EINVAL;
+
+	ret = kvm_vbus_eventq_attach(kvbus,
+				     &kvbus->eventq,
+				     qreg->count,
+				     qreg->ring,
+				     qreg->data,
+				     qreg->irq);
+	if (ret < 0)
+		return ret;
+
+	ret = vbus_notifier_register(kvbus->vbus, &kvbus->notify.vbus);
+	if (ret < 0)
+		return ret;
+
+	kvbus->state = kvm_vbus_state_running;
+
+	return 0;
+}
+
+static int
+hc_deviceopen(struct kvm_vcpu *vcpu, void *data)
+{
+	struct vbus_deviceopen *args = data;
+	struct kvm_vbus *kvbus = vcpu->kvm->kvbus;
+	struct vbus_client *c = kvbus->client;
+
+	return c->ops->deviceopen(c, kvbus->ctx,
+				  args->devid, args->version, &args->handle);
+}
+
+static int
+hc_deviceclose(struct kvm_vcpu *vcpu, void *data)
+{
+	__u64 devh = *(__u64 *)data;
+	struct vbus_client *c = to_client(vcpu);
+
+	return c->ops->deviceclose(c, devh);
+}
+
+static int
+hc_devicecall(struct kvm_vcpu *vcpu, void *data)
+{
+	struct vbus_devicecall *args = data;
+	struct vbus_client *c = to_client(vcpu);
+
+	return c->ops->devicecall(c, args->devh, args->func,
+				  (void *)args->datap, args->len, args->flags);
+}
+
+static int
+hc_deviceshm(struct kvm_vcpu *vcpu, void *data)
+{
+	struct vbus_deviceshm *args = data;
+	struct kvm_vbus *kvbus = vcpu->kvm->kvbus;
+	struct vbus_client *c = to_client(vcpu);
+	struct device_signal *_signal = NULL;
+	struct shm_signal *signal = NULL;
+	struct kvm_shm *_shm;
+	u64 handle;
+	int ret;
+
+	ret = kvm_shm_map(kvbus, args->datap, args->len, &_shm);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Establishing a signal is optional
+	 */
+	if (args->signal.offset != -1) {
+		ret = device_signal_alloc(kvbus, &_shm->shm,
+					  args->signal.offset,
+					  args->signal.prio,
+					  args->signal.cookie,
+					  &_signal);
+		if (ret < 0)
+			goto out;
+
+		signal = &_signal->signal;
+	}
+
+	ret = c->ops->deviceshm(c, args->devh, args->id,
+				&_shm->shm, signal,
+				args->flags, &handle);
+	if (ret < 0)
+		goto out;
+
+	args->handle = handle;
+	if (_signal)
+		_signal->handle = handle;
+
+	return 0;
+
+out:
+	if (signal)
+		shm_signal_put(signal);
+
+	vbus_shm_put(&_shm->shm);
+	return ret;
+}
+
+static int
+hc_shmsignal(struct kvm_vcpu *vcpu, void *data)
+{
+	__u64 handle = *(__u64 *)data;
+	struct kvm_vbus *kvbus;
+	struct vbus_client *c = to_client(vcpu);
+
+	/* A non-zero handle is targeted at a device's shm */
+	if (handle)
+		return c->ops->shmsignal(c, handle);
+
+	kvbus = vcpu->kvm->kvbus;
+
+	/* A null handle is signaling our eventq */
+	_shm_signal_wakeup(kvbus->eventq.ioq->signal);
+
+	return 0;
+}
+
+struct hc_op {
+	int nr;
+	int len;
+	int dirty;
+	int (*func)(struct kvm_vcpu *vcpu, void *args);
+};
+
+static struct hc_op _hc_busopen = {
+	.nr = KVM_VBUS_OP_BUSOPEN,
+	.len = sizeof(struct kvm_vbus_busopen),
+	.dirty = 1,
+	.func = &hc_busopen,
+};
+
+static struct hc_op _hc_busreg = {
+	.nr = KVM_VBUS_OP_BUSREG,
+	.len = sizeof(struct kvm_vbus_busreg),
+	.func = &hc_busreg,
+};
+
+static struct hc_op _hc_devopen = {
+	.nr = KVM_VBUS_OP_DEVOPEN,
+	.len = sizeof(struct vbus_deviceopen),
+	.dirty = 1,
+	.func = &hc_deviceopen,
+};
+
+static struct hc_op _hc_devclose = {
+	.nr = KVM_VBUS_OP_DEVCLOSE,
+	.len = sizeof(u64),
+	.func = &hc_deviceclose,
+};
+
+static struct hc_op _hc_devcall = {
+	.nr = KVM_VBUS_OP_DEVCALL,
+	.len = sizeof(struct vbus_devicecall),
+	.func = &hc_devicecall,
+};
+
+static struct hc_op _hc_devshm = {
+	.nr = KVM_VBUS_OP_DEVSHM,
+	.len = sizeof(struct vbus_deviceshm),
+	.dirty = 1,
+	.func = &hc_deviceshm,
+};
+
+static struct hc_op _hc_shmsignal = {
+	.nr = KVM_VBUS_OP_SHMSIGNAL,
+	.len = sizeof(u64),
+	.func = &hc_shmsignal,
+};
+
+static struct hc_op *hc_ops[] = {
+	&_hc_busopen,
+	&_hc_busreg,
+	&_hc_devopen,
+	&_hc_devclose,
+	&_hc_devcall,
+	&_hc_devshm,
+	&_hc_shmsignal,
+	NULL,
+};
+
+static int
+hc_execute_indirect(struct kvm_vcpu *vcpu, struct hc_op *op, gpa_t gpa)
+{
+	struct kvm *kvm  = vcpu->kvm;
+	char       *args = NULL;
+	int         ret;
+
+	BUG_ON(!op->len);
+
+	args = kmalloc(op->len, GFP_KERNEL);
+	if (!args)
+		return -ENOMEM;
+
+	ret = kvm_read_guest(kvm, gpa, args, op->len);
+	if (ret < 0)
+		goto out;
+
+	ret = op->func(vcpu, args);
+
+	if (ret >= 0 && op->dirty)
+		ret = kvm_write_guest(kvm, gpa, args, op->len);
+
+out:
+	kfree(args);
+
+	return ret;
+}
+
+static int
+hc_execute_direct(struct kvm_vcpu *vcpu, struct hc_op *op, gpa_t gpa)
+{
+	struct kvm  *kvm   = vcpu->kvm;
+	void        *args;
+	char        *kaddr;
+	struct page *page;
+	int          ret;
+
+	page = gfn_to_page(kvm, gpa >> PAGE_SHIFT);
+	if (page == bad_page) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	kaddr = kmap(page);
+	if (!kaddr) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	args = kaddr + offset_in_page(gpa);
+
+	ret = op->func(vcpu, args);
+
+out:
+	if (kaddr)
+		kunmap(kaddr);
+
+	if (ret >= 0 && op->dirty)
+		kvm_release_page_dirty(page);
+	else
+		kvm_release_page_clean(page);
+
+	return ret;
+}
+
+static int
+hc_execute(struct kvm_vcpu *vcpu, struct hc_op *op, gpa_t gpa, size_t len)
+{
+	if (len != op->len)
+		return -EINVAL;
+
+	/*
+	 * Execute-immediate if there is no data
+	 */
+	if (!len)
+		return op->func(vcpu, NULL);
+
+	/*
+	 * We will need to copy the arguments in the unlikely case that the
+	 * gpa pointer crosses a page boundary
+	 *
+	 * FIXME: Is it safe to assume PAGE_SIZE is relevant to gpa?
+	 */
+	if (unlikely(len && (offset_in_page(gpa) + len) > PAGE_SIZE))
+		return hc_execute_indirect(vcpu, op, gpa);
+
+	/*
+	 * Otherwise just execute with zero-copy by mapping the arguments
+	 */
+	return hc_execute_direct(vcpu, op, gpa);
+}
+
+/*
+ * Our hypercall format will always follow with the call-id in arg[0],
+ * a pointer to the arguments in arg[1], and the argument length in arg[2]
+ */
+int
+kvm_vbus_hc(struct kvm_vcpu *vcpu, int nr, gpa_t gpa, size_t len)
+{
+	struct kvm_vbus *kvbus = vcpu->kvm->kvbus;
+	enum kvm_vbus_state state = kvbus ? kvbus->state : kvm_vbus_state_init;
+	int i;
+
+	PDEBUG("nr=%d, state=%d\n", nr, state);
+
+	switch (state) {
+	case kvm_vbus_state_init:
+		if (nr != KVM_VBUS_OP_BUSOPEN) {
+			PDEBUG("expected BUSOPEN\n");
+			return -EINVAL;
+		}
+		break;
+	case kvm_vbus_state_registration:
+		if (nr != KVM_VBUS_OP_BUSREG) {
+			PDEBUG("expected BUSREG\n");
+			return -EINVAL;
+		}
+		break;
+	default:
+		break;
+	}
+
+	for (i = 0; i < ARRAY_SIZE(hc_ops); i++) {
+		struct hc_op *op = hc_ops[i];
+
+		if (op->nr != nr)
+			continue;
+
+		return hc_execute(vcpu, op, gpa, len);
+	}
+
+	PDEBUG("error: no matching function for nr=%d\n", nr);
+
+	return -EINVAL;
+}

