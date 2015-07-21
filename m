From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net-next 3/3] ARM: net: add support for BPF_ANC | SKF_AD_HATYPE in ARM JIT.
Date: Tue, 21 Jul 2015 14:16:40 +0200
Message-ID: <1437481000-22835-4-git-send-email-nschichan@freebox.fr>
References: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Cc: Russell King <linux@arm.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/arm/net/bpf_jit_32.c | 22 ++++++++++++++++++++--
 arch/arm/net/bpf_jit_32.h |  3 +++
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index fe28beb..6dcff2b 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -828,7 +828,9 @@ b_epilogue:
 			emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
 			break;
 		case BPF_ANC | SKF_AD_IFINDEX:
+		case BPF_ANC | SKF_AD_HATYPE:
 			/* A = skb->dev->ifindex */
+			/* A = skb->dev->type */
 			ctx->seen |= SEEN_SKB;
 			off = offsetof(struct sk_buff, dev);
 			emit(ARM_LDR_I(r_scratch, r_skb, off), ctx);
@@ -838,8 +840,24 @@ b_epilogue:
 
 			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
 						  ifindex) != 4);
-			off = offsetof(struct net_device, ifindex);
-			emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
+			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
+						  type) != 2);
+
+			if (code == (BPF_ANC | SKF_AD_IFINDEX)) {
+				off = offsetof(struct net_device, ifindex);
+				emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
+			} else {
+				/*
+				 * offset of field "type" in "struct
+				 * net_device" is above what can be
+				 * used in the ldrh rd, [rn, #imm]
+				 * instruction, so load the offset in
+				 * a register and use ldrh rd, [rn, rm]
+				 */
+				off = offsetof(struct net_device, type);
+				emit_mov_i(ARM_R3, off, ctx);
+				emit(ARM_LDRH_R(r_A, r_scratch, ARM_R3), ctx);
+			}
 			break;
 		case BPF_ANC | SKF_AD_MARK:
 			ctx->seen |= SEEN_SKB;
diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
index b2d7d92..4b17d5ab 100644
--- a/arch/arm/net/bpf_jit_32.h
+++ b/arch/arm/net/bpf_jit_32.h
@@ -74,6 +74,7 @@
 #define ARM_INST_LDRB_I		0x05d00000
 #define ARM_INST_LDRB_R		0x07d00000
 #define ARM_INST_LDRH_I		0x01d000b0
+#define ARM_INST_LDRH_R		0x019000b0
 #define ARM_INST_LDR_I		0x05900000
 
 #define ARM_INST_LDM		0x08900000
@@ -160,6 +161,8 @@
 				 | (rm))
 #define ARM_LDRH_I(rt, rn, off)	(ARM_INST_LDRH_I | (rt) << 12 | (rn) << 16 \
 				 | (((off) & 0xf0) << 4) | ((off) & 0xf))
+#define ARM_LDRH_R(rt, rn, rm)	(ARM_INST_LDRH_R | (rt) << 12 | (rn) << 16 \
+				 | (rm))
 
 #define ARM_LDM(rn, regs)	(ARM_INST_LDM | (rn) << 16 | (regs))
 
-- 
1.9.1
