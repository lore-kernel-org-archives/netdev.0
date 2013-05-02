From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v3 -next 2/2] x86: bpf_jit_comp: optimize BPF_S_ANC_SECCOMP_LD_W
Date: Thu,  2 May 2013 18:28:57 -0400
Message-ID: <1367533737-17196-3-git-send-email-xi.wang@gmail.com>
References: <1367533737-17196-1-git-send-email-xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Xi Wang <xi.wang@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367533737-17196-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch further optimizes JIT for seccomp filters.  It removes the
call to seccomp_bpf_load() and directly emits instructions instead.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Will Drewry <wad@chromium.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: David Laight <david.laight@aculab.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/x86/net/bpf_jit_comp.c | 126 ++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 116 insertions(+), 10 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 64c72aa..08b024b 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -8,10 +8,11 @@
  * of the License.
  */
 #include <linux/moduleloader.h>
-#include <asm/cacheflush.h>
 #include <linux/netdevice.h>
 #include <linux/filter.h>
 #include <linux/if_vlan.h>
+#include <asm/cacheflush.h>
+#include <asm/syscall.h>
 
 /*
  * Conventions :
@@ -113,7 +114,7 @@ do {								\
 #define SEEN_SKBREF  (1 << 3) /* use pointer to skb */
 #define SEEN_SECCOMP (1 << 4) /* seccomp filters */
 
-#define NEED_PERILOGUE(_seen) ((_seen) & (SEEN_XREG | SEEN_MEM | SEEN_DATAREF | SEEN_SECCOMP))
+#define NEED_PERILOGUE(_seen) ((_seen) & (SEEN_XREG | SEEN_MEM | SEEN_DATAREF))
 
 static inline void bpf_flush_icache(void *start, void *end)
 {
@@ -148,6 +149,25 @@ static int pkt_type_offset(void)
 	return -1;
 }
 
+/* helper to find the offset in struct seccomp_data */
+#define BPF_DATA(_name) offsetof(struct seccomp_data, _name)
+
+/* helper to find the negative offset from the end of struct pt_regs */
+#define roffsetof(_type, _member) ((int)(offsetof(_type, _member) - sizeof(_type)))
+#define PT_REGS(_name)  roffsetof(struct pt_regs, _name)
+
+#define EMIT_REGS_LOAD(offset)				\
+do {							\
+	if (is_imm8(offset)) {				\
+		/* mov off8(%r8),%eax */		\
+		EMIT4(0x41, 0x8b, 0x40, offset);	\
+	} else {					\
+		/* mov off32(%r8),%eax */		\
+		EMIT3(0x41, 0x8b, 0x80);		\
+		EMIT(offset, 4);			\
+	}						\
+} while (0)
+
 static void *__bpf_jit_compile(struct sock_filter *filter, unsigned int flen, u8 seen_all)
 {
 	u8 temp[64];
@@ -229,12 +249,44 @@ static void *__bpf_jit_compile(struct sock_filter *filter, unsigned int flen, u8
 		}
 
 #ifdef CONFIG_SECCOMP_FILTER_JIT
+		/* For seccomp filters, load :
+		 *  r9  = current
+		 *  r8  = current->thread.sp0
+		 *  edi = task_thread_info(current)->status & TS_COMPAT
+		 *
+		 * r8 points to the end of struct pt_regs, task_pt_regs(current) + 1
+		 */
 		if (seen_or_pass0 & SEEN_SECCOMP) {
 			/* seccomp filters: skb must be NULL */
 			if (seen_or_pass0 & (SEEN_SKBREF | SEEN_DATAREF)) {
 				pr_err_once("seccomp filters shouldn't use skb");
 				goto out;
 			}
+
+			/* r9 = current */
+			EMIT1(0x65);EMIT4(0x4c, 0x8b, 0x0c, 0x25); /* mov %gs:imm32,%r9 */
+			EMIT((u32)(unsigned long)&current_task, 4);
+
+			/* r8 = current->thread.sp0 */
+			EMIT3(0x4d, 0x8b, 0x81); /* mov off32(%r9),%r8 */
+			EMIT(offsetof(struct task_struct, thread.sp0), 4);
+
+			/* edi = task_thread_info(current)->status & TS_COMPAT */
+#ifdef CONFIG_IA32_EMULATION
+			/* task_thread_info(current): current->stack */
+			BUILD_BUG_ON(!is_imm8(offsetof(struct task_struct, stack)));
+			/* mov off8(%r9),%rdi */
+			EMIT4(0x49, 0x8b, 0x79, offsetof(struct task_struct, stack));
+			/* task_thread_info(current)->status */
+			BUILD_BUG_ON(!is_imm8(offsetof(struct thread_info, status)));
+			BUILD_BUG_ON(FIELD_SIZEOF(struct thread_info, status) != 4);
+			/* mov off8(%rdi),%edi */
+			EMIT3(0x8b, 0x7f, offsetof(struct thread_info, status));
+			/* task_thread_info(current)->status & TS_COMPAT */
+			BUILD_BUG_ON(!is_imm8(TS_COMPAT));
+			/* and imm8,%edi */
+			EMIT3(0x83, 0xe7, TS_COMPAT);
+#endif /* CONFIG_IA32_EMULATION */
 		}
 #endif /* CONFIG_SECCOMP_FILTER_JIT */
 
@@ -709,14 +761,68 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 #ifdef CONFIG_SECCOMP_FILTER_JIT
 			case BPF_S_ANC_SECCOMP_LD_W:
 				seen |= SEEN_SECCOMP;
-				func = (u8 *)seccomp_bpf_load;
-				t_offset = func - (image + addrs[i]);
-				/* seccomp filters don't use %rdi, %r8, %r9
-				 * it is safe to not save them
-				 */
-				EMIT1_off32(0xbf, K); /* mov imm32,%edi */
-				EMIT1_off32(0xe8, t_offset); /* call seccomp_bpf_load */
-				break;
+				if (K == BPF_DATA(nr)) {
+					/* A = task_pt_regs(current)->orig_ax */
+					EMIT_REGS_LOAD(PT_REGS(orig_ax));
+					break;
+				}
+				if (K == BPF_DATA(arch)) {
+					/* A = AUDIT_ARCH_X86_64 */
+					EMIT1_off32(0xb8, AUDIT_ARCH_X86_64); /* mov imm32,%eax */
+#ifdef CONFIG_IA32_EMULATION
+					/* A = compat ? AUDIT_ARCH_I386 : AUDIT_ARCH_X86_64 */
+					EMIT1_off32(0xb9, AUDIT_ARCH_I386); /* mov imm32,%ecx */
+					EMIT2(0x85, 0xff); /* test %edi,%edi */
+					EMIT3(0x0f, 0x45, 0xc1); /* cmovne %ecx,%eax*/
+#endif /* CONFIG_IA32_EMULATION */
+					break;
+				}
+				if (K >= BPF_DATA(args[0]) && K < BPF_DATA(args[6])) {
+					int arg = (K - BPF_DATA(args[0])) / sizeof(u64);
+					int off = K % sizeof(u64);
+
+					switch (arg) {
+					case 0: off += PT_REGS(di); break;
+					case 1: off += PT_REGS(si); break;
+					case 2: off += PT_REGS(dx); break;
+					case 3: off += PT_REGS(r10); break;
+					case 4: off += PT_REGS(r8); break;
+					case 5: off += PT_REGS(r9); break;
+					}
+					EMIT_REGS_LOAD(off);
+#ifdef CONFIG_IA32_EMULATION
+					off = K % sizeof(u64);
+					switch (arg) {
+					case 0: off += PT_REGS(bx); break;
+					case 1: off += PT_REGS(cx); break;
+					case 2: off += PT_REGS(dx); break;
+					case 3: off += PT_REGS(si); break;
+					case 4: off += PT_REGS(di); break;
+					case 5: off += PT_REGS(bp); break;
+					}
+					if (is_imm8(off)) {
+						/* mov off8(%r8),%ecx */
+						EMIT4(0x41, 0x8b, 0x48, off);
+					} else {
+						/* mov off32(%r8),%ecx */
+						EMIT3(0x41, 0x8b, 0x88);
+						EMIT(off, 4);
+					}
+					EMIT2(0x85, 0xff); /* test %edi,%edi */
+					EMIT3(0x0f, 0x45, 0xc1); /* cmovne %ecx,%eax*/
+#endif /* CONFIG_IA32_EMULATION */
+					break;
+				}
+				if (K == BPF_DATA(instruction_pointer)) {
+					/* A = task_pt_regs(current)->ip */
+					EMIT_REGS_LOAD(PT_REGS(ip));
+					break;
+				}
+				if (K == BPF_DATA(instruction_pointer) + sizeof(u32)) {
+					EMIT_REGS_LOAD(PT_REGS(ip) + 4);
+					break;
+				}
+				goto out;
 #endif /* CONFIG_SECCOMP_FILTER_JIT */
 			default:
 				/* hmm, too complex filter, give up with jit compiler */
-- 
1.8.1.2
