From: Xi Wang <xi.wang@gmail.com>
Subject: [RFC PATCH net-next 6/6] s390/bpf,jit: refactor the BPF JIT interface
Date: Fri, 26 Apr 2013 03:51:46 -0400
Message-ID: <1366962706-24204-7-git-send-email-xi.wang@gmail.com>
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
 arch/s390/net/bpf_jit_comp.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 0972e91..7966e0c 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -738,19 +738,19 @@ out:
 	return -1;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	unsigned long size, prg_len, lit_len;
 	struct bpf_jit jit, cjit;
 	unsigned int *addrs;
 	int pass, i;
+	bpf_func_t bpf_func = sk_run_filter;
 
 	if (!bpf_jit_enable)
-		return;
-	addrs = kmalloc(fp->len * sizeof(*addrs), GFP_KERNEL);
+		return bpf_func;
+	addrs = kzalloc(flen * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
-	memset(addrs, 0, fp->len * sizeof(*addrs));
+		return bpf_func;
 	memset(&jit, 0, sizeof(cjit));
 	memset(&cjit, 0, sizeof(cjit));
 
@@ -759,10 +759,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 		jit.lit = jit.mid;
 
 		bpf_jit_prologue(&jit);
-		bpf_jit_noleaks(&jit, fp->insns);
-		for (i = 0; i < fp->len; i++) {
-			if (bpf_jit_insn(&jit, fp->insns + i, addrs, i,
-					 i == fp->len - 1))
+		bpf_jit_noleaks(&jit, filter);
+		for (i = 0; i < flen; i++) {
+			if (bpf_jit_insn(&jit, filter + i, addrs, i,
+					 i == flen - 1))
 				goto out;
 		}
 		bpf_jit_epilogue(&jit);
@@ -789,8 +789,8 @@ void bpf_jit_compile(struct sk_filter *fp)
 		cjit = jit;
 	}
 	if (bpf_jit_enable > 1) {
-		pr_err("flen=%d proglen=%lu pass=%d image=%p\n",
-		       fp->len, jit.end - jit.start, pass, jit.start);
+		pr_err("flen=%u proglen=%lu pass=%d image=%p\n",
+		       flen, jit.end - jit.start, pass, jit.start);
 		if (jit.start) {
 			printk(KERN_ERR "JIT code:\n");
 			print_fn_code(jit.start, jit.mid - jit.start);
@@ -800,9 +800,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 		}
 	}
 	if (jit.start)
-		fp->bpf_func = (void *) jit.start;
+		bpf_func = (void *) jit.start;
 out:
 	kfree(addrs);
+	return bpf_func;
 }
 
 static void jit_free_defer(struct work_struct *arg)
@@ -813,13 +814,13 @@ static void jit_free_defer(struct work_struct *arg)
 /* run from softirq, we must use a work_struct to call
  * module_free() from process context
  */
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(bpf_func_t bpf_func)
 {
 	struct work_struct *work;
 
-	if (fp->bpf_func == sk_run_filter)
+	if (bpf_func == sk_run_filter)
 		return;
-	work = (struct work_struct *)fp->bpf_func;
+	work = (struct work_struct *)bpf_func;
 	INIT_WORK(work, jit_free_defer);
 	schedule_work(work);
 }
-- 
1.8.1.2
