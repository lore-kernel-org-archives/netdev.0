From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH 4/6] ARM: net: add support for BPF_ANC | SKF_AD_PKTTYPE in ARM JIT.
Date: Thu, 16 Jul 2015 18:46:33 +0200
Message-ID: <1437065195-10887-5-git-send-email-nschichan@freebox.fr>
References: <1437065195-10887-1-git-send-email-nschichan@freebox.fr>
Cc: Russell King <linux@arm.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437065195-10887-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/arm/net/bpf_jit_32.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index c011e22..6ff248c 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -895,6 +895,17 @@ b_epilogue:
 				OP_IMM3(ARM_AND, r_A, r_A, 0x1, ctx);
 			}
 			break;
+		case BPF_ANC | SKF_AD_PKTTYPE:
+			ctx->seen |= SEEN_SKB;
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
+						  __pkt_type_offset[0]) != 1);
+			off = PKT_TYPE_OFFSET();
+			emit(ARM_LDRB_I(r_A, r_skb, off), ctx);
+			emit(ARM_AND_I(r_A, r_A, PKT_TYPE_MAX), ctx);
+#ifdef __BIG_ENDIAN_BITFIELD
+			emit(ARM_LSR_I(r_A, r_A, 5), ctx);
+#endif
+			break;
 		case BPF_ANC | SKF_AD_QUEUE:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
-- 
1.9.1
