From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH 14/17] kvm: add a reset capability
Date: Tue, 31 Mar 2009 14:44:00 -0400
Message-ID: <20090331184400.28333.50396.stgit@dev.haskins.net>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:39234 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268AbZCaSlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 14:41:45 -0400
In-Reply-To: <20090331184057.28333.77287.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a way to detect if a VM is reset later in the series, so lets
add a capability for userspace to signal a VM reset down to the kernel.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 arch/x86/kvm/x86.c       |    1 +
 include/linux/kvm.h      |    2 ++
 include/linux/kvm_host.h |    6 ++++++
 virt/kvm/kvm_main.c      |   36 ++++++++++++++++++++++++++++++++++++
 4 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 758b7a1..9b0a649 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -971,6 +971,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_NOP_IO_DELAY:
 	case KVM_CAP_MP_STATE:
 	case KVM_CAP_SYNC_MMU:
+	case KVM_CAP_RESET:
 		r = 1;
 		break;
 	case KVM_CAP_COALESCED_MMIO:
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 0424326..7ffd8f5 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -396,6 +396,7 @@ struct kvm_trace_rec {
 #ifdef __KVM_HAVE_USER_NMI
 #define KVM_CAP_USER_NMI 22
 #endif
+#define KVM_CAP_RESET 23
 
 /*
  * ioctls for VM fds
@@ -429,6 +430,7 @@ struct kvm_trace_rec {
 				   struct kvm_assigned_pci_dev)
 #define KVM_ASSIGN_IRQ _IOR(KVMIO, 0x70, \
 			    struct kvm_assigned_irq)
+#define KVM_RESET	          _IO(KVMIO,  0x67)
 
 /*
  * ioctls for vcpu fds
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index bf6f703..506eca1 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -17,6 +17,7 @@
 #include <linux/preempt.h>
 #include <linux/marker.h>
 #include <linux/msi.h>
+#include <linux/notifier.h>
 #include <asm/signal.h>
 
 #include <linux/kvm.h>
@@ -132,6 +133,8 @@ struct kvm {
 	unsigned long mmu_notifier_seq;
 	long mmu_notifier_count;
 #endif
+
+	struct raw_notifier_head reset_notifier; /* triggers when VM reboots */
 };
 
 /* The guest did something we don't support. */
@@ -158,6 +161,9 @@ void kvm_exit(void);
 void kvm_get_kvm(struct kvm *kvm);
 void kvm_put_kvm(struct kvm *kvm);
 
+int kvm_reset_notifier_register(struct kvm *kvm, struct notifier_block *nb);
+int kvm_reset_notifier_unregister(struct kvm *kvm, struct notifier_block *nb);
+
 #define HPA_MSB ((sizeof(hpa_t) * 8) - 1)
 #define HPA_ERR_MASK ((hpa_t)1 << HPA_MSB)
 static inline int is_error_hpa(hpa_t hpa) { return hpa >> HPA_MSB; }
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 29a667c..fca2d25 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -868,6 +868,8 @@ static struct kvm *kvm_create_vm(void)
 #ifdef KVM_COALESCED_MMIO_PAGE_OFFSET
 	kvm_coalesced_mmio_init(kvm);
 #endif
+	RAW_INIT_NOTIFIER_HEAD(&kvm->reset_notifier);
+
 out:
 	return kvm;
 }
@@ -1485,6 +1487,35 @@ void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
 	}
 }
 
+static void kvm_notify_reset(struct kvm *kvm)
+{
+	mutex_lock(&kvm->lock);
+	raw_notifier_call_chain(&kvm->reset_notifier, 0, kvm);
+	mutex_unlock(&kvm->lock);
+}
+
+int kvm_reset_notifier_register(struct kvm *kvm, struct notifier_block *nb)
+{
+	int ret;
+
+	mutex_lock(&kvm->lock);
+	ret = raw_notifier_chain_register(&kvm->reset_notifier, nb);
+	mutex_unlock(&kvm->lock);
+
+	return ret;
+}
+
+int kvm_reset_notifier_unregister(struct kvm *kvm, struct notifier_block *nb)
+{
+	int ret;
+
+	mutex_lock(&kvm->lock);
+	ret = raw_notifier_chain_unregister(&kvm->reset_notifier, nb);
+	mutex_unlock(&kvm->lock);
+
+	return ret;
+}
+
 /*
  * The vCPU has executed a HLT instruction with in-kernel mode enabled.
  */
@@ -1929,6 +1960,11 @@ static long kvm_vm_ioctl(struct file *filp,
 		break;
 	}
 #endif
+	case KVM_RESET: {
+		kvm_notify_reset(kvm);
+		r = 0;
+		break;
+	}
 	default:
 		r = kvm_arch_vm_ioctl(filp, ioctl, arg);
 	}

