From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Tue, 10 Nov 2015 14:41:41 -0800
Message-ID: <1447195301-16757-3-git-send-email-yang.shi@linaro.org>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

aarch64 doesn't have native support for XADD instruction, implement it by
the below instruction sequence:

Load (dst + off) to a register
Add src to it
Store it back to (dst + off)

Signed-off-by: Yang Shi <yang.shi@linaro.org>
CC: Zi Shen Lim <zlim.lnx@gmail.com>
CC: Xi Wang <xi.wang@gmail.com>
---
 arch/arm64/net/bpf_jit_comp.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 49c1f1b..0b1d2d3 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -609,7 +609,21 @@ emit_cond_jmp:
 	case BPF_STX | BPF_XADD | BPF_W:
 	/* STX XADD: lock *(u64 *)(dst + off) += src */
 	case BPF_STX | BPF_XADD | BPF_DW:
-		goto notyet;
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(1, tmp2, off, ctx);
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			emit(A64_LDR32(tmp, dst, tmp2), ctx);
+			emit(A64_ADD(is64, tmp, tmp, src), ctx);
+			emit(A64_STR32(tmp, dst, tmp2), ctx);
+			break;
+		case BPF_DW:
+			emit(A64_LDR64(tmp, dst, tmp2), ctx);
+			emit(A64_ADD(is64, tmp, tmp, src), ctx);
+			emit(A64_STR64(tmp, dst, tmp2), ctx);
+			break;
+		}
+		break;
 
 	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)) */
 	case BPF_LD | BPF_ABS | BPF_W:
@@ -679,9 +693,6 @@ emit_cond_jmp:
 		}
 		break;
 	}
-notyet:
-		pr_info_once("*** NOT YET: opcode %02x ***\n", code);
-		return -EFAULT;
 
 	default:
 		pr_err_once("unknown opcode %02x\n", code);
-- 
2.0.2
