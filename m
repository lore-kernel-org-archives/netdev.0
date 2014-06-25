From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH v2 16/17] MIPS: bpf: Use 32 or 64-bit load instruction to load an address to register
Date: Wed, 25 Jun 2014 09:39:38 +0100
Message-ID: <1403685578-25170-1-git-send-email-markos.chandras@imgtec.com>
References: <53AA85E8.5090403@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <dborkman@redhat.com>,
        "Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <53AA85E8.5090403@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

When loading a pointer to register we need to use the appropriate
32 or 64bit instruction to preserve the pointers' top 32bits.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
Changes since v1:
- Change function name to make it clear that we are loading a
pointer to a register, not an address
---
 arch/mips/net/bpf_jit.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 4505e2e6ab53..6e3963425b64 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -453,6 +453,17 @@ static inline void emit_wsbh(unsigned int dst, unsigned int src,
 	emit_instr(ctx, wsbh, dst, src);
 }
 
+/* load pointer to register */
+static inline void emit_load_ptr(unsigned int dst, unsigned int src,
+				     int imm, struct jit_ctx *ctx)
+{
+	/* src contains the base addr of the 32/64-pointer */
+	if (config_enabled(CONFIG_64BIT))
+		emit_instr(ctx, ld, dst, imm, src);
+	else
+		emit_instr(ctx, lw, dst, imm, src);
+}
+
 /* load a function pointer to register */
 static inline void emit_load_func(unsigned int reg, ptr imm,
 				  struct jit_ctx *ctx)
@@ -1277,7 +1288,8 @@ jmp_cmp:
 			/* A = skb->dev->ifindex */
 			ctx->flags |= SEEN_SKB | SEEN_A | SEEN_S0;
 			off = offsetof(struct sk_buff, dev);
-			emit_load(r_s0, r_skb, off, ctx);
+			/* Load *dev pointer */
+			emit_load_ptr(r_s0, r_skb, off, ctx);
 			/* error (0) in the delay slot */
 			emit_bcond(MIPS_COND_EQ, r_s0, r_zero,
 				   b_imm(prog->len, ctx), ctx);
-- 
2.0.0
