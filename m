From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 25/27] net: remove VLAN_TAG_PRESENT
Date: Tue,  3 Jan 2017 21:52:41 +0100 (CET)
Message-ID: <0332eff5a8b691ce0b86a2abe03d62d9d6f63d25.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Patrick McHardy <kaber@trash.net>,
        Alexei Starovoitov <ast@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34816 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965965AbdACUw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:56 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 arch/mips/net/bpf_jit.c         |  3 ---
 arch/powerpc/net/bpf_jit_comp.c |  3 ---
 arch/sparc/net/bpf_jit_comp.c   |  4 ----
 include/linux/if_vlan.h         | 11 ++++++-----
 include/linux/skbuff.h          | 16 +++++++++-------
 lib/test_bpf.c                  | 17 ++---------------
 net/core/filter.c               |  3 ---
 7 files changed, 17 insertions(+), 40 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 4b12b5df47e8..fb6d23415d16 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1143,9 +1143,6 @@ static int build_body(struct jit_ctx *ctx)
 						  vlan_tci) != 2);
 			off = offsetof(struct sk_buff, vlan_tci);
 			emit_half_load(r_s0, r_skb, off, ctx);
-#ifdef VLAN_TAG_PRESENT
-			emit_andi(r_A, r_s0, (u16)~VLAN_TAG_PRESENT, ctx);
-#endif
 			break;
 		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			ctx->flags |= SEEN_SKB | SEEN_A;
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 22ae63fb9b7d..fb3892763fff 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -381,9 +381,6 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 
 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  vlan_tci));
-#ifdef VLAN_TAG_PRESENT
-			PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
-#endif
 			break;
 		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			PPC_LBZ_OFFS(r_A, r_skb, PKT_VLAN_PRESENT_OFFSET());
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 61cc15dc86f7..d499b391393e 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -602,10 +602,6 @@ void bpf_jit_compile(struct bpf_prog *fp)
 				break;
 			case BPF_ANC | SKF_AD_VLAN_TAG:
 				emit_skb_load16(vlan_tci, r_A);
-#ifdef VLAN_TAG_PRESENT
-				emit_loadimm(~VLAN_TAG_PRESENT, r_TMP);
-				emit_and(r_A, r_TMP, r_A);
-#endif
 				break;
 			case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 				__emit_skb_load8(__pkt_vlan_present_offset, r_A);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 75e839b84a63..8ff2f0ed4c27 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -66,7 +66,6 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 #define VLAN_PRIO_MASK		0xe000 /* Priority Code Point */
 #define VLAN_PRIO_SHIFT		13
 #define VLAN_CFI_MASK		0x1000 /* Canonical Format Indicator */
-#define VLAN_TAG_PRESENT	VLAN_CFI_MASK
 #define VLAN_VID_MASK		0x0fff /* VLAN Identifier */
 #define VLAN_N_VID		4096
 
@@ -78,8 +77,8 @@ static inline bool is_vlan_dev(const struct net_device *dev)
         return dev->priv_flags & IFF_802_1Q_VLAN;
 }
 
-#define skb_vlan_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
-#define skb_vlan_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
+#define skb_vlan_tag_present(__skb)	((__skb)->vlan_present)
+#define skb_vlan_tag_get(__skb)		((__skb)->vlan_tci)
 #define skb_vlan_tag_get_id(__skb)	((__skb)->vlan_tci & VLAN_VID_MASK)
 #define skb_vlan_tag_get_prio(__skb)	((__skb)->vlan_tci & VLAN_PRIO_MASK)
 
@@ -390,7 +389,7 @@ static inline struct sk_buff *vlan_insert_tag_set_proto(struct sk_buff *skb,
  */
 static inline void __vlan_hwaccel_clear_tag(struct sk_buff *skb)
 {
-	skb->vlan_tci = 0;
+	skb->vlan_present = 0;
 }
 
 /**
@@ -402,6 +401,7 @@ static inline void __vlan_hwaccel_clear_tag(struct sk_buff *skb)
  */
 static inline void __vlan_hwaccel_copy_tag(struct sk_buff *dst, const struct sk_buff *src)
 {
+	dst->vlan_present = src->vlan_present;
 	dst->vlan_proto = src->vlan_proto;
 	dst->vlan_tci = src->vlan_tci;
 }
@@ -436,7 +436,8 @@ static inline void __vlan_hwaccel_put_tag(struct sk_buff *skb,
 					  __be16 vlan_proto, u16 vlan_tci)
 {
 	skb->vlan_proto = vlan_proto;
-	skb->vlan_tci = VLAN_TAG_PRESENT | vlan_tci;
+	skb->vlan_tci = vlan_tci;
+	skb->vlan_present = 1;
 }
 
 /**
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 168c3e486bd4..c37d8d76fe34 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -740,6 +740,14 @@ struct sk_buff {
 	__u8			csum_level:2;
 	__u8			csum_bad:1;
 
+#ifdef __BIG_ENDIAN_BITFIELD
+#define PKT_VLAN_PRESENT_BIT	7
+#else
+#define PKT_VLAN_PRESENT_BIT	0
+#endif
+#define PKT_VLAN_PRESENT_OFFSET()	offsetof(struct sk_buff, __pkt_vlan_present_offset)
+	__u8			__pkt_vlan_present_offset[0];
+	__u8			vlan_present:1;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
@@ -749,7 +757,7 @@ struct sk_buff {
 #ifdef CONFIG_NET_SWITCHDEV
 	__u8			offload_fwd_mark:1;
 #endif
-	/* 2, 4 or 5 bit hole */
+	/* 1-4 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
@@ -768,12 +776,6 @@ struct sk_buff {
 	__u32			priority;
 	int			skb_iif;
 	__u32			hash;
-#define PKT_VLAN_PRESENT_BIT	4	// CFI (12-th bit) in TCI
-#ifdef __BIG_ENDIAN
-#define PKT_VLAN_PRESENT_OFFSET()	offsetof(struct sk_buff, vlan_tci)
-#else
-#define PKT_VLAN_PRESENT_OFFSET()	(offsetof(struct sk_buff, vlan_tci) + 1)
-#endif
 	__be16			vlan_proto;
 	__u16			vlan_tci;
 #if defined(CONFIG_NET_RX_BUSY_POLL) || defined(CONFIG_XPS)
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 00d345006671..9cb21a20e2f8 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -38,6 +38,7 @@
 #define SKB_HASH	0x1234aaab
 #define SKB_QUEUE_MAP	123
 #define SKB_VLAN_TCI	0xffff
+#define SKB_VLAN_PRESENT	1
 #define SKB_DEV_IFINDEX	577
 #define SKB_DEV_TYPE	588
 
@@ -691,13 +692,8 @@ static struct bpf_test tests[] = {
 		CLASSIC,
 		{ },
 		{
-#ifdef VLAN_TAG_PRESENT
-			{ 1, SKB_VLAN_TCI & ~VLAN_TAG_PRESENT },
-			{ 10, SKB_VLAN_TCI & ~VLAN_TAG_PRESENT }
-#else
 			{ 1, SKB_VLAN_TCI },
 			{ 10, SKB_VLAN_TCI }
-#endif
 		},
 	},
 	{
@@ -710,13 +706,8 @@ static struct bpf_test tests[] = {
 		CLASSIC,
 		{ },
 		{
-#ifdef VLAN_TAG_PRESENT
-			{ 1, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) },
-			{ 10, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) }
-#else
 			{ 1, SKB_VLAN_PRESENT },
 			{ 10, SKB_VLAN_PRESENT }
-#endif
 		},
 	},
 	{
@@ -4783,13 +4774,8 @@ static struct bpf_test tests[] = {
 		CLASSIC,
 		{ },
 		{
-#ifdef VLAN_TAG_PRESENT
-			{  1, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) },
-			{ 10, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) }
-#else
 			{  1, SKB_VLAN_PRESENT },
 			{ 10, SKB_VLAN_PRESENT }
-#endif
 		},
 		.fill_helper = bpf_fill_maxinsns6,
 	},
@@ -5501,6 +5487,7 @@ static struct sk_buff *populate_skb(char *buf, int size)
 	skb->queue_mapping = SKB_QUEUE_MAP;
 	skb->vlan_tci = SKB_VLAN_TCI;
 	skb->vlan_proto = htons(ETH_P_IP);
+	skb->vlan_present = SKB_VLAN_PRESENT;
 	skb->dev = &dev;
 	skb->dev->ifindex = SKB_DEV_IFINDEX;
 	skb->dev->type = SKB_DEV_TYPE;
diff --git a/net/core/filter.c b/net/core/filter.c
index 5209c5f5ac4a..f75011928a7a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -193,9 +193,6 @@ static u32 convert_skb_access(int skb_field, int dst_reg, int src_reg,
 		/* dst_reg = *(u16 *) (src_reg + offsetof(vlan_tci)) */
 		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
 				      offsetof(struct sk_buff, vlan_tci));
-#ifdef VLAN_TAG_PRESENT
-		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, ~VLAN_TAG_PRESENT);
-#endif
 		break;
 	case SKF_AD_VLAN_TAG_PRESENT:
 		*insn++ = BPF_LDX_MEM(BPF_B, dst_reg, src_reg, PKT_VLAN_PRESENT_OFFSET());
-- 
2.11.0
