From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 11/29] bpf: verifier (add ability to receive verification log)
Date: Sun, 24 Aug 2014 13:21:12 -0700
Message-ID: <1408911690-7598-12-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36467 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbaHXUWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 16:22:09 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so19673712pab.40
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 13:22:09 -0700 (PDT)
In-Reply-To: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add optional attributes for BPF_PROG_LOAD syscall:
  BPF_PROG_LOG_LEVEL,     /* verbosity level of eBPF verifier */
  BPF_PROG_LOG_BUF,       /* user supplied buffer */
  BPF_PROG_LOG_SIZE,      /* size of user buffer */

In such case the verifier will return its verification log in the user
supplied buffer which can be used by humans to analyze why verifier
rejected given program

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |    4 +
 kernel/bpf/syscall.c     |    3 +
 kernel/bpf/verifier.c    |  236 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 243 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 7468fe55db7b..d280acad4b28 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -379,6 +379,10 @@ enum bpf_prog_attributes {
 	BPF_PROG_UNSPEC,
 	BPF_PROG_TEXT,		/* array of eBPF instructions */
 	BPF_PROG_LICENSE,	/* license string */
+	/* optional program attributes */
+	BPF_PROG_LOG_LEVEL,	/* verbosity level of eBPF verifier */
+	BPF_PROG_LOG_BUF,	/* user supplied buffer */
+	BPF_PROG_LOG_SIZE,	/* size of user buffer */
 	__BPF_PROG_ATTR_MAX,
 };
 #define BPF_PROG_ATTR_MAX (__BPF_PROG_ATTR_MAX - 1)
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index a3581646ee11..60cb760cb423 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -443,6 +443,9 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 static const struct nla_policy prog_policy[BPF_PROG_ATTR_MAX + 1] = {
 	[BPF_PROG_TEXT]      = { .type = NLA_BINARY },
 	[BPF_PROG_LICENSE]   = { .type = NLA_NUL_STRING },
+	[BPF_PROG_LOG_LEVEL] = { .type = NLA_U32 },
+	[BPF_PROG_LOG_BUF]   = { .len = sizeof(void *) },
+	[BPF_PROG_LOG_SIZE]  = { .type = NLA_U32 },
 };
 
 static int bpf_prog_load(enum bpf_prog_type type, struct nlattr __user *uattr,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c1dc2441994a..2484a3387ca2 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -144,9 +144,245 @@
  * load/store to bpf_context are checked against known fields
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
+static void *log_buf;
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
 int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 {
+	void __user *log_ubuf = NULL;
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
+	if (tb[BPF_PROG_LOG_LEVEL] && tb[BPF_PROG_LOG_BUF] &&
+	    tb[BPF_PROG_LOG_SIZE]) {
+		/* user requested verbose verifier output
+		 * and supplied buffer to store the verification trace
+		 */
+		log_level = nla_get_u32(tb[BPF_PROG_LOG_LEVEL]);
+		log_ubuf = *(void __user **) nla_data(tb[BPF_PROG_LOG_BUF]);
+		log_size = nla_get_u32(tb[BPF_PROG_LOG_SIZE]);
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
