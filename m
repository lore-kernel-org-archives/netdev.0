From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH v2] bpf: fix a bug in verification logic when SUB operation taken on FRAME_PTR
Date: Thu, 18 Jun 2015 08:31:45 +0000
Message-ID: <1434616305-97746-1-git-send-email-wangnan0@huawei.com>
References: <1434615176-96706-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <pi3orama@163.com>
To: <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434615176-96706-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Original code has a problem, cause following code failed to pass verifier:

 r1 <- r10
 r1 -= 8
 r2 = 8
 r3 = unsafe pointer
 call BPF_FUNC_probe_read  <-- R1 type=inv expected=fp

However, by replacing 'r1 -= 8' to 'r1 += -8' the above program can be
loaded successfully.

This is because the verifier allows only BPF_ADD instruction on a
FRAME_PTR reigster to forge PTR_TO_STACK register, but makes BPF_SUB
on FRAME_PTR reigster to get a UNKNOWN_VALUE register.

This patch fix it by adding BPF_SUB in stack_relative checking.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
---

V1 is incorrect. Please ignore it and consider this one.

---
 kernel/bpf/verifier.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a251cf6..681ac72 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1020,7 +1020,8 @@ static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
 		}
 
 		/* pattern match 'bpf_add Rx, imm' instruction */
-		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
+		if ((opcode == BPF_ADD || opcode == BPF_SUB) &&
+		    BPF_CLASS(insn->code) == BPF_ALU64 &&
 		    regs[insn->dst_reg].type == FRAME_PTR &&
 		    BPF_SRC(insn->code) == BPF_K)
 			stack_relative = true;
-- 
1.8.3.4
