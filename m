From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Tue, 13 Mar 2012 11:04:42 +0100
Message-ID: <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, "Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1331587715-26069-1-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I made a quick pseudo-patch for BPF JIT support. As far as I can tell,
the actual code itself is very simple, just:

case BPF_S_ANC_SECCOMP_LD_W:
	/* SECCOMP doesn't use SKB, no need to preserve %rdi. */
	t_offset = seccomp_bpf_load - (image + addrs[i]);
	EMIT1_off32(0xbf, K); /* mov imm32,%rdi */
	EMIT1_off32(0xe8, t_offset); /* call */
	break;

EAX is set directly as it's the return register, EBX is preserved by the
callee, RDI and other registers are unused by seccomp, so no need for
trampoline code AFAIK.

The rest of the patch just makes the JIT code suitable for sharing.
Only real change is that after this patch unused insns memory is freed.

The code is untested and even uncompiled, as I've only access to my 32-bit
laptop at the moment.

Would be interesting to know if this actually works and what the performance
difference is for seccomp.

Greetings,

Indan


 arch/x86/net/bpf_jit_comp.c |   47 ++++++++++++++++++++----------------------
 include/linux/filter.h      |   14 +++++++-----
 net/core/filter.c           |   27 ++++++++++++++++++++++--
 3 files changed, 54 insertions(+), 34 deletions(-)

---

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7c1b765..3cd6626 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -118,7 +118,7 @@ static inline void bpf_flush_icache(void *start, void *end)
 }


-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(const struct sock_filter* filter, int flen, int use_skb)
 {
 	u8 temp[64];
 	u8 *prog;
@@ -131,15 +131,13 @@ void bpf_jit_compile(struct sk_filter *fp)
 	int pc_ret0 = -1; /* bpf index of first RET #0 instruction (if any) */
 	unsigned int cleanup_addr; /* epilogue code offset */
 	unsigned int *addrs;
-	const struct sock_filter *filter = fp->insns;
-	int flen = fp->len;

 	if (!bpf_jit_enable)
-		return;
+		return NULL;

 	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
+		return NULL;

 	/* Before first pass, make a rough estimation of addrs[]
 	 * each bpf instruction is translated to less than 64 bytes
@@ -151,11 +149,16 @@ void bpf_jit_compile(struct sk_filter *fp)
 	cleanup_addr = proglen; /* epilogue address */

 	for (pass = 0; pass < 10; pass++) {
-		u8 seen_or_pass0 = (pass == 0) ? (SEEN_XREG | SEEN_DATAREF | SEEN_MEM) : seen;
+		u8 seen_or_pass0 = seen;
 		/* no prologue/epilogue for trivial filters (RET something) */
 		proglen = 0;
 		prog = temp;

+		if (pass == 0) {
+			seen_or_pass0 = SEEN_XREG | SEEN_MEM;
+			if (use_skb)
+				seen_or_pass0 |= SEEN_DATAREF;
+		}
 		if (seen_or_pass0) {
 			EMIT4(0x55, 0x48, 0x89, 0xe5); /* push %rbp; mov %rsp,%rbp */
 			EMIT4(0x48, 0x83, 0xec, 96);	/* subq  $96,%rsp	*/
@@ -472,6 +475,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 				CLEAR_A();
 #endif
 				break;
+#ifdef CONFIG_SECCOMP_FILTER
+			case BPF_S_ANC_SECCOMP_LD_W:
+				/* SECCOMP doesn't use SKB, no need to preserve %rdi. */
+				t_offset = seccomp_bpf_load - (image + addrs[i]);
+				EMIT1_off32(0xbf, K); /* mov imm32,%rdi */
+				EMIT1_off32(0xe8, t_offset); /* call */
+				break;
+#endif
 			case BPF_S_LD_W_ABS:
 				func = sk_load_word;
 common_load:			seen |= SEEN_DATAREF;
@@ -588,13 +599,14 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				/* hmm, too complex filter, give up with jit compiler */
 				goto out;
 			}
+			BUG_ON(!use_skb && (seen & SEEN_DATAREF));
 			ilen = prog - temp;
 			if (image) {
 				if (unlikely(proglen + ilen > oldproglen)) {
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
-					return;
+					return NULL;
 				}
 				memcpy(image + proglen, temp, ilen);
 			}
@@ -635,28 +647,13 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				       16, 1, image, proglen, false);

 		bpf_flush_icache(image, image + proglen);
-
-		fp->bpf_func = (void *)image;
 	}
 out:
 	kfree(addrs);
-	return;
+	return (void *)image;
 }

-static void jit_free_defer(struct work_struct *arg)
+void bpf_jit_free(bpf_func_t image)
 {
-	module_free(NULL, arg);
-}
-
-/* run from softirq, we must use a work_struct to call
- * module_free() from process context
- */
-void bpf_jit_free(struct sk_filter *fp)
-{
-	if (fp->bpf_func != sk_run_filter) {
-		struct work_struct *work = (struct work_struct *)fp->bpf_func;
-
-		INIT_WORK(work, jit_free_defer);
-		schedule_work(work);
-	}
+	module_free(NULL, image);
 }
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8eeb205..292ccca 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -135,12 +135,13 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 struct sk_buff;
 struct sock;

+typedef unsigned int (*bpf_func_t)(const struct sk_buff*, const struct sock_filter*);
+
 struct sk_filter
 {
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
-	unsigned int		(*bpf_func)(const struct sk_buff *skb,
-					    const struct sock_filter *filter);
+	bpf_func_t		bpf_func;
 	struct rcu_head		rcu;
 	struct sock_filter     	insns[0];
 };
@@ -158,14 +159,15 @@ extern int sk_detach_filter(struct sock *sk);
 extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);

 #ifdef CONFIG_BPF_JIT
-extern void bpf_jit_compile(struct sk_filter *fp);
-extern void bpf_jit_free(struct sk_filter *fp);
+extern bpf_func_t bpf_jit_compile(const struct sock_filter*, int flen, int use_skb);
+extern void bpf_jit_free(bpf_funct_t);
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
 #else
-static inline void bpf_jit_compile(struct sk_filter *fp)
+static inline bpf_func_t bpf_jit_compile(const struct sock_filter*, int flen, int use_skb)
 {
+	return NULL;
 }
-static inline void bpf_jit_free(struct sk_filter *fp)
+static inline void bpf_jit_free(bpf_func_t)
 {
 }
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
diff --git a/net/core/filter.c b/net/core/filter.c
index 5dea452..03e3ea3 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -574,6 +574,14 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 }
 EXPORT_SYMBOL(sk_chk_filter);

+/* run from softirq, we must use a work_struct to call
+ * bpf_jit_free() from process context
+ */
+static void jit_free_defer(struct work_struct *arg)
+{
+	bpf_jit_free((bpf_func_t)arg);
+}
+
 /**
  * 	sk_filter_release_rcu - Release a socket filter by rcu_head
  *	@rcu: rcu_head that contains the sk_filter to free
@@ -582,7 +590,12 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);

-	bpf_jit_free(fp);
+	if (fp->bpf_func != sk_run_filter) {
+		struct work_struct *work = (struct work_struct *)fp->bpf_func;
+
+		INIT_WORK(work, jit_free_defer);
+		schedule_work(work);
+	}
 	kfree(fp);
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
@@ -599,9 +612,10 @@ EXPORT_SYMBOL(sk_filter_release_rcu);
  */
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
-	struct sk_filter *fp, *old_fp;
+	struct sk_filter *fp, *old_fp, *new_fp;
 	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
 	int err;
+	bpf_func_t jit;

 	/* Make sure new filter is there and in the right amounts. */
 	if (fprog->filter == NULL)
@@ -625,7 +639,14 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 		return err;
 	}

-	bpf_jit_compile(fp);
+	jit = bpf_jit_compile(fp->insns, fp->len, 1);
+	if (jit) {
+		fp->bpf_func = jit;
+		/* Free unused insns memory */
+		newfp = krealloc(fp, sizeof(*fp), GFP_KERNEL);
+		if (newfp)
+			fp = newfp;
+	}

 	old_fp = rcu_dereference_protected(sk->sk_filter,
 					   sock_owned_by_user(sk));



