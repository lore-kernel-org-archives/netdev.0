From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 1/6] bpf: verifier: add checks for BPF_ABS | BPF_IND instructions
Date: Mon,  1 Dec 2014 15:06:34 -0800
Message-ID: <1417475199-15950-2-git-send-email-ast@plumgrid.com>
References: <1417475199-15950-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417475199-15950-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

introduce program type BPF_PROG_TYPE_SOCKET_FILTER that is used
for attaching programs to sockets where ctx == skb.

add verifier checks for ABS/IND instructions which can only be seen
in socket filters, therefore the check:
  if (env->prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER)
    verbose("BPF_LD_ABS|IND instructions are only allowed in socket filters\n");

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
v2: no changes

 include/uapi/linux/bpf.h |    1 +
 kernel/bpf/verifier.c    |   70 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4a3d0f84f178..45da7ec7d274 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -117,6 +117,7 @@ enum bpf_map_type {
 
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
+	BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index b6a1f7c14a67..a28e09c7825d 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1172,6 +1172,70 @@ static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
+/* verify safety of LD_ABS|LD_IND instructions:
+ * - they can only appear in the programs where ctx == skb
+ * - since they are wrappers of function calls, they scratch R1-R5 registers,
+ *   preserve R6-R9, and store return value into R0
+ *
+ * Implicit input:
+ *   ctx == skb == R6 == CTX
+ *
+ * Explicit input:
+ *   SRC == any register
+ *   IMM == 32-bit immediate
+ *
+ * Output:
+ *   R0 - 8/16/32-bit skb data converted to cpu endianness
+ */
+static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
+{
+	struct reg_state *regs = env->cur_state.regs;
+	u8 mode = BPF_MODE(insn->code);
+	struct reg_state *reg;
+	int i, err;
+
+	if (env->prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
+		verbose("BPF_LD_ABS|IND instructions are only allowed in socket filters\n");
+		return -EINVAL;
+	}
+
+	if (insn->dst_reg != BPF_REG_0 || insn->off != 0 ||
+	    (mode == BPF_ABS && insn->src_reg != BPF_REG_0)) {
+		verbose("BPF_LD_ABS uses reserved fields\n");
+		return -EINVAL;
+	}
+
+	/* check whether implicit source operand (register R6) is readable */
+	err = check_reg_arg(regs, BPF_REG_6, SRC_OP);
+	if (err)
+		return err;
+
+	if (regs[BPF_REG_6].type != PTR_TO_CTX) {
+		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to skb\n");
+		return -EINVAL;
+	}
+
+	if (mode == BPF_IND) {
+		/* check explicit source operand */
+		err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+		if (err)
+			return err;
+	}
+
+	/* reset caller saved regs to unreadable */
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
+		reg = regs + caller_saved[i];
+		reg->type = NOT_INIT;
+		reg->imm = 0;
+	}
+
+	/* mark destination R0 register as readable, since it contains
+	 * the value fetched from the packet
+	 */
+	regs[BPF_REG_0].type = UNKNOWN_VALUE;
+	return 0;
+}
+
 /* non-recursive DFS pseudo code
  * 1  procedure DFS-iterative(G,v):
  * 2      label v as discovered
@@ -1677,8 +1741,10 @@ process_bpf_exit:
 			u8 mode = BPF_MODE(insn->code);
 
 			if (mode == BPF_ABS || mode == BPF_IND) {
-				verbose("LD_ABS is not supported yet\n");
-				return -EINVAL;
+				err = check_ld_abs(env, insn);
+				if (err)
+					return err;
+
 			} else if (mode == BPF_IMM) {
 				err = check_ld_imm(env, insn);
 				if (err)
-- 
1.7.9.5
