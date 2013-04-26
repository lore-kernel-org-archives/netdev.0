From: Xi Wang <xi.wang@gmail.com>
Subject: [RFC PATCH net-next 2/6] x86: bpf_jit_comp: support BPF_S_ANC_SECCOMP_LD_W instruction
Date: Fri, 26 Apr 2013 03:51:42 -0400
Message-ID: <1366962706-24204-3-git-send-email-xi.wang@gmail.com>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the seccomp BPF_S_ANC_SECCOMP_LD_W instruction
in x86 JIT.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 arch/x86/net/bpf_jit_comp.c | 38 ++++++++++++++++++++++++++------------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index f66b540..03c9c81 100644
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
@@ -144,7 +145,7 @@ static int pkt_type_offset(void)
 	return -1;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	u8 temp[64];
 	u8 *prog;
@@ -157,15 +158,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 	int pc_ret0 = -1; /* bpf index of first RET #0 instruction (if any) */
 	unsigned int cleanup_addr; /* epilogue code offset */
 	unsigned int *addrs;
-	const struct sock_filter *filter = fp->insns;
-	int flen = fp->len;
+	bpf_func_t bpf_func = sk_run_filter;
 
 	if (!bpf_jit_enable)
-		return;
+		return bpf_func;
 
 	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
+		return bpf_func;
 
 	/* Before first pass, make a rough estimation of addrs[]
 	 * each bpf instruction is translated to less than 64 bytes
@@ -684,6 +684,20 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				}
 				EMIT_COND_JMP(f_op, f_offset);
 				break;
+#ifdef CONFIG_SECCOMP_FILTER
+			case BPF_S_ANC_SECCOMP_LD_W:
+				if (K == offsetof(struct seccomp_data, arch)) {
+					int arch = syscall_get_arch(current, NULL);
+
+					EMIT1_off32(0xb8, arch); /* mov arch,%eax */
+					break;
+				}
+				func = (u8 *)seccomp_bpf_load;
+				t_offset = func - (image + addrs[i]);
+				EMIT1_off32(0xbf, K); /* mov imm32,%edi */
+				EMIT1_off32(0xe8, t_offset); /* call seccomp_bpf_load */
+				break;
+#endif
 			default:
 				/* hmm, too complex filter, give up with jit compiler */
 				goto out;
@@ -694,7 +708,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
-					return;
+					return bpf_func;
 				}
 				memcpy(image + proglen, temp, ilen);
 			}
@@ -731,11 +745,11 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
-		fp->bpf_func = (void *)image;
+		bpf_func = (void *)image;
 	}
 out:
 	kfree(addrs);
-	return;
+	return bpf_func;
 }
 
 static void jit_free_defer(struct work_struct *arg)
@@ -746,10 +760,10 @@ static void jit_free_defer(struct work_struct *arg)
 /* run from softirq, we must use a work_struct to call
  * module_free() from process context
  */
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(bpf_func_t bpf_func)
 {
-	if (fp->bpf_func != sk_run_filter) {
-		struct work_struct *work = (struct work_struct *)fp->bpf_func;
+	if (bpf_func != sk_run_filter) {
+		struct work_struct *work = (struct work_struct *)bpf_func;
 
 		INIT_WORK(work, jit_free_defer);
 		schedule_work(work);
-- 
1.8.1.2
