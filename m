From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive verification log)
Date: Tue, 16 Sep 2014 17:39:26 -0700
Message-ID: <1410914370-29883-8-git-send-email-ast@plumgrid.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410914370-29883-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

add optional attributes for BPF_PROG_LOAD syscall:
union bpf_attr {
    struct {
	...
	__u32         log_level; /* verbosity level of eBPF verifier */
	__u32         log_size;  /* size of user buffer */
	__aligned_u64 log_buf;   /* user supplied 'char *buffer' */
    };
};

when log_level > 0 the verifier will return its verification log in the user
supplied buffer 'log_buf' which can be used by program author to analyze why
verifier rejected given program.

'Understanding eBPF verifier messages' section of Documentation/networking/filter.txt
provides several examples of these messages, like the program:

  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_LD_MAP_FD(BPF_REG_1, 0),
  BPF_CALL_FUNC(BPF_FUNC_map_lookup_elem),
  BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
  BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
  BPF_EXIT_INSN(),

will be rejected with the following multi-line message in log_buf:

  0: (7a) *(u64 *)(r10 -8) = 0
  1: (bf) r2 = r10
  2: (07) r2 += -8
  3: (b7) r1 = 0
  4: (85) call 1
  5: (15) if r0 == 0x0 goto pc+1
   R0=map_ptr R10=fp
  6: (7a) *(u64 *)(r0 +4) = 0
  misaligned access off 4 size 8

The format of the output can change at any time as verifier evolves.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/uapi/linux/bpf.h |    3 +
 kernel/bpf/syscall.c     |    2 +-
 kernel/bpf/verifier.c    |  235 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 239 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 424f442016e7..31b0ac208a52 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -138,6 +138,9 @@ union bpf_attr {
 		__u32		insn_cnt;
 		__aligned_u64	insns;
 		__aligned_u64	license;
+		__u32		log_level;	/* verbosity level of verifier */
+		__u32		log_size;	/* size of user buffer */
+		__aligned_u64	log_buf;	/* user supplied buffer */
 	};
 } __attribute__((aligned(8)));
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 67b5e29f183e..c7be7163bd11 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -458,7 +458,7 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 }
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD license
+#define	BPF_PROG_LOAD_LAST_FIELD log_buf
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d6f9c3d6b4d7..871edc1f2e1f 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -125,9 +125,244 @@
  * are set to NOT_INIT to indicate that they are no longer readable.
  */
 
+/* single container for all structs
+ * one verifier_env per bpf_check() call
+ */
+struct verifier_env {
+};
+
+/* verbose verifier prints what it's seeing
+ * bpf_check() is called under lock, so no race to access these global vars
+ */
+static u32 log_level, log_size, log_len;
+static char *log_buf;
+
+static DEFINE_MUTEX(bpf_verifier_lock);
+
+/* log_level controls verbosity level of eBPF verifier.
+ * verbose() is used to dump the verification trace to the log, so the user
+ * can figure out what's wrong with the program
+ */
+static void verbose(const char *fmt, ...)
+{
+	va_list args;
+
+	if (log_level == 0 || log_len >= log_size - 1)
+		return;
+
+	va_start(args, fmt);
+	log_len += vscnprintf(log_buf + log_len, log_size - log_len, fmt, args);
+	va_end(args);
+}
+
+static const char *const bpf_class_string[] = {
+	[BPF_LD]    = "ld",
+	[BPF_LDX]   = "ldx",
+	[BPF_ST]    = "st",
+	[BPF_STX]   = "stx",
+	[BPF_ALU]   = "alu",
+	[BPF_JMP]   = "jmp",
+	[BPF_RET]   = "BUG",
+	[BPF_ALU64] = "alu64",
+};
+
+static const char *const bpf_alu_string[] = {
+	[BPF_ADD >> 4]  = "+=",
+	[BPF_SUB >> 4]  = "-=",
+	[BPF_MUL >> 4]  = "*=",
+	[BPF_DIV >> 4]  = "/=",
+	[BPF_OR  >> 4]  = "|=",
+	[BPF_AND >> 4]  = "&=",
+	[BPF_LSH >> 4]  = "<<=",
+	[BPF_RSH >> 4]  = ">>=",
+	[BPF_NEG >> 4]  = "neg",
+	[BPF_MOD >> 4]  = "%=",
+	[BPF_XOR >> 4]  = "^=",
+	[BPF_MOV >> 4]  = "=",
+	[BPF_ARSH >> 4] = "s>>=",
+	[BPF_END >> 4]  = "endian",
+};
+
+static const char *const bpf_ldst_string[] = {
+	[BPF_W >> 3]  = "u32",
+	[BPF_H >> 3]  = "u16",
+	[BPF_B >> 3]  = "u8",
+	[BPF_DW >> 3] = "u64",
+};
+
+static const char *const bpf_jmp_string[] = {
+	[BPF_JA >> 4]   = "jmp",
+	[BPF_JEQ >> 4]  = "==",
+	[BPF_JGT >> 4]  = ">",
+	[BPF_JGE >> 4]  = ">=",
+	[BPF_JSET >> 4] = "&",
+	[BPF_JNE >> 4]  = "!=",
+	[BPF_JSGT >> 4] = "s>",
+	[BPF_JSGE >> 4] = "s>=",
+	[BPF_CALL >> 4] = "call",
+	[BPF_EXIT >> 4] = "exit",
+};
+
+static void print_bpf_insn(struct bpf_insn *insn)
+{
+	u8 class = BPF_CLASS(insn->code);
+
+	if (class == BPF_ALU || class == BPF_ALU64) {
+		if (BPF_SRC(insn->code) == BPF_X)
+			verbose("(%02x) %sr%d %s %sr%d\n",
+				insn->code, class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg,
+				bpf_alu_string[BPF_OP(insn->code) >> 4],
+				class == BPF_ALU ? "(u32) " : "",
+				insn->src_reg);
+		else
+			verbose("(%02x) %sr%d %s %s%d\n",
+				insn->code, class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg,
+				bpf_alu_string[BPF_OP(insn->code) >> 4],
+				class == BPF_ALU ? "(u32) " : "",
+				insn->imm);
+	} else if (class == BPF_STX) {
+		if (BPF_MODE(insn->code) == BPF_MEM)
+			verbose("(%02x) *(%s *)(r%d %+d) = r%d\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->dst_reg,
+				insn->off, insn->src_reg);
+		else if (BPF_MODE(insn->code) == BPF_XADD)
+			verbose("(%02x) lock *(%s *)(r%d %+d) += r%d\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->dst_reg, insn->off,
+				insn->src_reg);
+		else
+			verbose("BUG_%02x\n", insn->code);
+	} else if (class == BPF_ST) {
+		if (BPF_MODE(insn->code) != BPF_MEM) {
+			verbose("BUG_st_%02x\n", insn->code);
+			return;
+		}
+		verbose("(%02x) *(%s *)(r%d %+d) = %d\n",
+			insn->code,
+			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			insn->dst_reg,
+			insn->off, insn->imm);
+	} else if (class == BPF_LDX) {
+		if (BPF_MODE(insn->code) != BPF_MEM) {
+			verbose("BUG_ldx_%02x\n", insn->code);
+			return;
+		}
+		verbose("(%02x) r%d = *(%s *)(r%d %+d)\n",
+			insn->code, insn->dst_reg,
+			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			insn->src_reg, insn->off);
+	} else if (class == BPF_LD) {
+		if (BPF_MODE(insn->code) == BPF_ABS) {
+			verbose("(%02x) r0 = *(%s *)skb[%d]\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->imm);
+		} else if (BPF_MODE(insn->code) == BPF_IND) {
+			verbose("(%02x) r0 = *(%s *)skb[r%d + %d]\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->src_reg, insn->imm);
+		} else if (BPF_MODE(insn->code) == BPF_IMM) {
+			verbose("(%02x) r%d = 0x%x\n",
+				insn->code, insn->dst_reg, insn->imm);
+		} else {
+			verbose("BUG_ld_%02x\n", insn->code);
+			return;
+		}
+	} else if (class == BPF_JMP) {
+		u8 opcode = BPF_OP(insn->code);
+
+		if (opcode == BPF_CALL) {
+			verbose("(%02x) call %d\n", insn->code, insn->imm);
+		} else if (insn->code == (BPF_JMP | BPF_JA)) {
+			verbose("(%02x) goto pc%+d\n",
+				insn->code, insn->off);
+		} else if (insn->code == (BPF_JMP | BPF_EXIT)) {
+			verbose("(%02x) exit\n", insn->code);
+		} else if (BPF_SRC(insn->code) == BPF_X) {
+			verbose("(%02x) if r%d %s r%d goto pc%+d\n",
+				insn->code, insn->dst_reg,
+				bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				insn->src_reg, insn->off);
+		} else {
+			verbose("(%02x) if r%d %s 0x%x goto pc%+d\n",
+				insn->code, insn->dst_reg,
+				bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				insn->imm, insn->off);
+		}
+	} else {
+		verbose("(%02x) %s\n", insn->code, bpf_class_string[class]);
+	}
+}
+
 int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 {
+	char __user *log_ubuf = NULL;
+	struct verifier_env *env;
 	int ret = -EINVAL;
 
+	if (prog->len <= 0 || prog->len > BPF_MAXINSNS)
+		return -E2BIG;
+
+	/* 'struct verifier_env' can be global, but since it's not small,
+	 * allocate/free it every time bpf_check() is called
+	 */
+	env = kzalloc(sizeof(struct verifier_env), GFP_KERNEL);
+	if (!env)
+		return -ENOMEM;
+
+	/* grab the mutex to protect few globals used by verifier */
+	mutex_lock(&bpf_verifier_lock);
+
+	if (attr->log_level || attr->log_buf || attr->log_size) {
+		/* user requested verbose verifier output
+		 * and supplied buffer to store the verification trace
+		 */
+		log_level = attr->log_level;
+		log_ubuf = (char __user *) (unsigned long) attr->log_buf;
+		log_size = attr->log_size;
+		log_len = 0;
+
+		ret = -EINVAL;
+		/* log_* values have to be sane */
+		if (log_size < 128 || log_size > UINT_MAX >> 8 ||
+		    log_level == 0 || log_ubuf == NULL)
+			goto free_env;
+
+		ret = -ENOMEM;
+		log_buf = vmalloc(log_size);
+		if (!log_buf)
+			goto free_env;
+	} else {
+		log_level = 0;
+	}
+
+	/* ret = do_check(env); */
+
+	if (log_level && log_len >= log_size - 1) {
+		BUG_ON(log_len >= log_size);
+		/* verifier log exceeded user supplied buffer */
+		ret = -ENOSPC;
+		/* fall through to return what was recorded */
+	}
+
+	/* copy verifier log back to user space including trailing zero */
+	if (log_level && copy_to_user(log_ubuf, log_buf, log_len + 1) != 0) {
+		ret = -EFAULT;
+		goto free_log_buf;
+	}
+
+
+free_log_buf:
+	if (log_level)
+		vfree(log_buf);
+free_env:
+	kfree(env);
+	mutex_unlock(&bpf_verifier_lock);
 	return ret;
 }
-- 
1.7.9.5
