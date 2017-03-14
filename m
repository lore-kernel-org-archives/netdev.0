From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 2/5] MIPS: BPF: Add JIT support for SKF_AD_HATYPE.
Date: Tue, 14 Mar 2017 14:21:41 -0700
Message-ID: <20170314212144.29988-3-david.daney@cavium.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170314212144.29988-1-david.daney@cavium.com>
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

This let's us pass some additional "modprobe test-bpf" tests with JIT
enabled.

Reuse the code for SKF_AD_IFINDEX, but substitute the offset and size
of the "type" field.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/net/bpf_jit.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 49a2e22..880e329 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -365,6 +365,12 @@ static inline void emit_half_load(unsigned int reg, unsigned int base,
 	emit_instr(ctx, lh, reg, offset, base);
 }
 
+static inline void emit_half_load_unsigned(unsigned int reg, unsigned int base,
+					   unsigned int offset, struct jit_ctx *ctx)
+{
+	emit_instr(ctx, lhu, reg, offset, base);
+}
+
 static inline void emit_mul(unsigned int dst, unsigned int src1,
 			    unsigned int src2, struct jit_ctx *ctx)
 {
@@ -1112,6 +1118,8 @@ static int build_body(struct jit_ctx *ctx)
 			break;
 		case BPF_ANC | SKF_AD_IFINDEX:
 			/* A = skb->dev->ifindex */
+		case BPF_ANC | SKF_AD_HATYPE:
+			/* A = skb->dev->type */
 			ctx->flags |= SEEN_SKB | SEEN_A;
 			off = offsetof(struct sk_buff, dev);
 			/* Load *dev pointer */
@@ -1120,10 +1128,15 @@ static int build_body(struct jit_ctx *ctx)
 			emit_bcond(MIPS_COND_EQ, r_s0, r_zero,
 				   b_imm(prog->len, ctx), ctx);
 			emit_reg_move(r_ret, r_zero, ctx);
-			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
-						  ifindex) != 4);
-			off = offsetof(struct net_device, ifindex);
-			emit_load(r_A, r_s0, off, ctx);
+			if (code == (BPF_ANC | SKF_AD_IFINDEX)) {
+				BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
+				off = offsetof(struct net_device, ifindex);
+				emit_load(r_A, r_s0, off, ctx);
+			} else { /* (code == (BPF_ANC | SKF_AD_HATYPE) */
+				BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, type) != 2);
+				off = offsetof(struct net_device, type);
+				emit_half_load_unsigned(r_A, r_s0, off, ctx);
+			}
 			break;
 		case BPF_ANC | SKF_AD_MARK:
 			ctx->flags |= SEEN_SKB | SEEN_A;
-- 
2.9.3
