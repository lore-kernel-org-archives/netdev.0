From: Xi Wang <xi.wang@gmail.com>
Subject: [RFC PATCH net-next 5/6] sparc: bpf_jit_comp: refactor the BPF JIT interface
Date: Fri, 26 Apr 2013 03:51:45 -0400
Message-ID: <1366962706-24204-6-git-send-email-xi.wang@gmail.com>
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

Implement the refactored bpf_jit_compile() and bpf_jit_free().

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 arch/sparc/net/bpf_jit_comp.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index d36a85e..15e6513 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -354,21 +354,21 @@ do {	*prog++ = BR_OPC | WDISP22(OFF);		\
  * emit_jump() calls with adjusted offsets.
  */
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	unsigned int cleanup_addr, proglen, oldproglen = 0;
 	u32 temp[8], *prog, *func, seen = 0, pass;
-	const struct sock_filter *filter = fp->insns;
-	int i, flen = fp->len, pc_ret0 = -1;
+	int i, pc_ret0 = -1;
 	unsigned int *addrs;
 	void *image;
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
@@ -763,7 +763,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
-					return;
+					return bpf_func;
 				}
 				memcpy(image + proglen, temp, ilen);
 			}
@@ -799,11 +799,11 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 
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
@@ -814,10 +814,10 @@ static void jit_free_defer(struct work_struct *arg)
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
