From: Will Drewry <wad@chromium.org>
Subject: [PATCH v12 01/13] sk_run_filter: add support for custom load_pointer
Date: Wed, 29 Feb 2012 17:53:28 -0600
Message-ID: <1330559620-23543-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change allows CONFIG_SECCOMP to make use of BPF programs for
user-controlled system call filtering (as shown in this patch series).

To minimize the impact on existing BPF evaluation, function pointer
use must be declared at sk_chk_filter-time.  This allows ancillary
load instructions to be generated that use the function pointer rather
than adding _any_ code to the existing LD_* instruction paths.

Crude performance numbers using udpflood -l 10000000 against dummy0.
3 trials just udpflooding, 3 with tcpdump. Averaged then differenced.

[v11 #s]
* x86 32-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
          (tcpdump)   (no bpf)
- Without:  88.19s  -  70.98s  =  17.21s
- With:     90.97s  -  74.96s  =  15.98s
- Slowdown per packet: -123 nanoseconds

* x86 64-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
          (tcpdump)   (no bpf)
- Without: 117.80s  - 103.99s  =  13.80s
- With:    116.81s  - 101.85s  =  14.96s
- Slowdown per packet: 116 nanoseconds

In this round of benchmarking, the gap seems narrower and I've attempted
to take extra steps to ensure a quiescent system (especially given the
wild variability I was seeing on 64-bit last time).  It's not clear to
me if this overhead (on an Atom-class system) is acceptable or not.
Irrespective, I had planned to follow on to this patch set updating
every in-kernel callsite of sk_run/chk_filter to use bpf_*_filter
directly and alleviate the bounce through. I was hoping that could be
done independently, however.  If it would make sense to do that first
or just duplicate the sk_run_filter code in seccomp.c initially, please
let me know.

v11: - un-inline sk_*_filter to adhere to the existing export symbol use
       and not break bpf_jit_free (markus@chromium.org)
     - updated benchmarks
v10: - converted length to a u32 on the struct because it is passed in
       at bpf_run_filter time anyway. (indan@nul.nu)
     - added a comment about the LD_*_ falling through (joe@perches.com)
     - more clean up (pointer->load, drop SKB macro, comments) (indan@nul.nu)
v9: - n/a
v8: - fixed variable positioning and bad cast (eric.dumazet@gmail.com)
    - no longer passes A as a pointer (inspection of x86 asm shows A is
      %ebx again; thanks eric.dumazet@gmail.com)
    - cleaned up switch macros and expanded use
      (joe@perches.com, indan@nul.nu)
    - added length fn pointer and handled LD_W_LEN/LDX_W_LEN
    - moved from a wrapping struct to a typedef for the function
      pointer. (matches existing function pointer style)
    - added comprehensive comment above the typedef.
    - benchmarks
v7: - first cut

Signed-off-by: Will Drewry <wad@chromium.org>
---
 include/linux/filter.h |   46 +++++++++++++++++++
 net/core/filter.c      |  117 +++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 157 insertions(+), 6 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8eeb205..bdd02f9 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -110,6 +110,9 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
  */
 #define BPF_MEMWORDS 16
 
+/* BPF program (checking) flags */
+#define BPF_CHK_FLAGS_NO_SKB	1
+
 /* RATIONALE. Negative offsets are invalid in BPF.
    We use them to reference ancillary data.
    Unlike introduction new instructions, it does not break
@@ -145,6 +148,33 @@ struct sk_filter
 	struct sock_filter     	insns[0];
 };
 
+/**
+ * struct bpf_load_fn - callback and data for bpf_run_filter
+ * This structure is used by bpf_run_filter if bpf_chk_filter
+ * was invoked with BPF_CHK_FLAGS_NO_SKB.
+ *
+ * @load:
+ *   @data: const pointer to the data passed into bpf_run_filter
+ *   @k: offset into @skb's data
+ *   @size: the size of the requested data in bytes: 1, 2, or 4.
+ *   @buffer: If non-NULL, a 32-bit buffer for staging data.
+ *
+ * Returns a pointer to the requested data.
+ *
+ * This function operates similarly to load_pointer in net/core/filter.c
+ * except that the pointer to the returned data must already be
+ * byteswapped as appropriate to the source data and endianness.
+ * @buffer may be used if the data needs to be staged.
+ *
+ * @length: the length of the supplied data for use by the LD*_LEN
+ *          instructions.
+ */
+struct bpf_load_fn {
+	void *(*load)(const void *data, int k, unsigned int size,
+			 void *buffer);
+	u32 length;
+};
+
 static inline unsigned int sk_filter_len(const struct sk_filter *fp)
 {
 	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
@@ -153,9 +183,15 @@ static inline unsigned int sk_filter_len(const struct sk_filter *fp)
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
 extern unsigned int sk_run_filter(const struct sk_buff *skb,
 				  const struct sock_filter *filter);
+extern unsigned int bpf_run_filter(const void *data,
+				   const struct sock_filter *filter,
+				   const struct bpf_load_fn *load_fn);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
+
 extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
+extern int bpf_chk_filter(struct sock_filter *filter, unsigned int flen, u32 flags);
+
 
 #ifdef CONFIG_BPF_JIT
 extern void bpf_jit_compile(struct sk_filter *fp);
@@ -228,6 +264,16 @@ enum {
 	BPF_S_ANC_HATYPE,
 	BPF_S_ANC_RXHASH,
 	BPF_S_ANC_CPU,
+	/* Used to differentiate SKB data and generic data */
+	BPF_S_ANC_LD_W_ABS,
+	BPF_S_ANC_LD_H_ABS,
+	BPF_S_ANC_LD_B_ABS,
+	BPF_S_ANC_LD_W_LEN,
+	BPF_S_ANC_LD_W_IND,
+	BPF_S_ANC_LD_H_IND,
+	BPF_S_ANC_LD_B_IND,
+	BPF_S_ANC_LDX_W_LEN,
+	BPF_S_ANC_LDX_B_MSH,
 };
 
 #endif /* __KERNEL__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 5dea452..fe8d396 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -98,9 +98,10 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 EXPORT_SYMBOL(sk_filter);
 
 /**
- *	sk_run_filter - run a filter on a socket
- *	@skb: buffer to run the filter on
+ *	bpf_run_filter - run a BPF filter program on @data
+ *	@data: buffer to run the filter on
  *	@fentry: filter to apply
+ *	@load_fn: custom data accessor
  *
  * Decode and apply filter instructions to the skb->data.
  * Return length to keep, 0 for none. @skb is the data we are
@@ -109,8 +110,9 @@ EXPORT_SYMBOL(sk_filter);
  * and last instruction guaranteed to be a RET, we dont need to check
  * flen. (We used to pass to this function the length of filter)
  */
-unsigned int sk_run_filter(const struct sk_buff *skb,
-			   const struct sock_filter *fentry)
+unsigned int bpf_run_filter(const void *data,
+			    const struct sock_filter *fentry,
+			    const struct bpf_load_fn *load_fn)
 {
 	void *ptr;
 	u32 A = 0;			/* Accumulator */
@@ -118,6 +120,7 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 	u32 mem[BPF_MEMWORDS];		/* Scratch Memory Store */
 	u32 tmp;
 	int k;
+	const struct sk_buff *skb = data;
 
 	/*
 	 * Process array of filter instructions.
@@ -350,6 +353,55 @@ load_b:
 				A = 0;
 			continue;
 		}
+		case BPF_S_ANC_LD_W_ABS:
+			k = K;
+load_fn_w:
+			ptr = load_fn->load(data, k, 4, &tmp);
+			if (ptr) {
+				A = *(u32 *)ptr;
+				continue;
+			}
+			return 0;
+		case BPF_S_ANC_LD_H_ABS:
+			k = K;
+load_fn_h:
+			ptr = load_fn->load(data, k, 2, &tmp);
+			if (ptr) {
+				A = *(u16 *)ptr;
+				continue;
+			}
+			return 0;
+		case BPF_S_ANC_LD_B_ABS:
+			k = K;
+load_fn_b:
+			ptr = load_fn->load(data, k, 1, &tmp);
+			if (ptr) {
+				A = *(u8 *)ptr;
+				continue;
+			}
+			return 0;
+		case BPF_S_ANC_LDX_B_MSH:
+			ptr = load_fn->load(data, K, 1, &tmp);
+			if (ptr) {
+				X = (*(u8 *)ptr & 0xf) << 2;
+				continue;
+			}
+			return 0;
+		case BPF_S_ANC_LD_W_IND:
+			k = X + K;
+			goto load_fn_w;
+		case BPF_S_ANC_LD_H_IND:
+			k = X + K;
+			goto load_fn_h;
+		case BPF_S_ANC_LD_B_IND:
+			k = X + K;
+			goto load_fn_b;
+		case BPF_S_ANC_LD_W_LEN:
+			A = load_fn->length;
+			continue;
+		case BPF_S_ANC_LDX_W_LEN:
+			X = load_fn->length;
+			continue;
 		default:
 			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
 				       fentry->code, fentry->jt,
@@ -360,6 +412,21 @@ load_b:
 
 	return 0;
 }
+EXPORT_SYMBOL(bpf_run_filter);
+
+/**
+ *	sk_run_filter - run a filter on a socket
+ *	@skb: buffer to run the filter on
+ *	@fentry: filter to apply
+ *
+ * Runs bpf_run_filter with the struct sk_buff-specific data
+ * accessor behavior.
+ */
+unsigned int sk_run_filter(const struct sk_buff *skb,
+					 const struct sock_filter *filter)
+{
+	return bpf_run_filter(skb, filter, NULL);
+}
 EXPORT_SYMBOL(sk_run_filter);
 
 /*
@@ -423,9 +490,10 @@ error:
 }
 
 /**
- *	sk_chk_filter - verify socket filter code
+ *	bpf_chk_filter - verify socket filter BPF code
  *	@filter: filter to verify
  *	@flen: length of filter
+ *	@flags: May be BPF_CHK_FLAGS_NO_SKB or 0
  *
  * Check the user's filter code. If we let some ugly
  * filter code slip through kaboom! The filter must contain
@@ -434,9 +502,13 @@ error:
  *
  * All jumps are forward as they are not signed.
  *
+ * If BPF_CHK_FLAGS_NO_SKB is set in flags, any SKB-specific
+ * rules become illegal and a bpf_load_fn will be expected by
+ * bpf_run_filter.
+ *
  * Returns 0 if the rule set is legal or -EINVAL if not.
  */
-int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
+int bpf_chk_filter(struct sock_filter *filter, unsigned int flen, u32 flags)
 {
 	/*
 	 * Valid instructions are initialized to non-0.
@@ -542,9 +614,36 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			    pc + ftest->jf + 1 >= flen)
 				return -EINVAL;
 			break;
+#define MAYBE_USE_LOAD_FN(CODE) \
+			if (flags & BPF_CHK_FLAGS_NO_SKB) { \
+				code = BPF_S_ANC_##CODE; \
+				break; \
+			}
+		case BPF_S_LD_W_LEN:
+			MAYBE_USE_LOAD_FN(LD_W_LEN);
+			break;
+		case BPF_S_LDX_W_LEN:
+			MAYBE_USE_LOAD_FN(LDX_W_LEN);
+			break;
+		case BPF_S_LD_W_IND:
+			MAYBE_USE_LOAD_FN(LD_W_IND);
+			break;
+		case BPF_S_LD_H_IND:
+			MAYBE_USE_LOAD_FN(LD_H_IND);
+			break;
+		case BPF_S_LD_B_IND:
+			MAYBE_USE_LOAD_FN(LD_B_IND);
+			break;
+		case BPF_S_LDX_B_MSH:
+			MAYBE_USE_LOAD_FN(LDX_B_MSH);
+			break;
 		case BPF_S_LD_W_ABS:
+			MAYBE_USE_LOAD_FN(LD_W_ABS);
+			/* Falls through to BPF_S_LD_B_ABS. */
 		case BPF_S_LD_H_ABS:
+			MAYBE_USE_LOAD_FN(LD_H_ABS);
 		case BPF_S_LD_B_ABS:
+			MAYBE_USE_LOAD_FN(LD_B_ABS);
 #define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
 				code = BPF_S_ANC_##CODE;	\
 				break
@@ -572,6 +671,12 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 	}
 	return -EINVAL;
 }
+EXPORT_SYMBOL(bpf_chk_filter);
+
+int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
+{
+	return bpf_chk_filter(filter, flen, 0);
+}
 EXPORT_SYMBOL(sk_chk_filter);
 
 /**
-- 
1.7.5.4

