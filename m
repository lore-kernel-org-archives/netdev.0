From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next] bpf: allow BPF programs access 'protocol' and 'vlan_tci' fields
Date: Mon, 16 Mar 2015 18:06:02 -0700
Message-ID: <1426554362-29991-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

as a follow on to patch 70006af95515 ("bpf: allow eBPF access skb fields")
this patch allows 'protocol' and 'vlan_tci' fields to be accessible
from extended BPF programs.

The usage of 'protocol', 'vlan_present' and 'vlan_tci' fields is the same as
corresponding SKF_AD_PROTOCOL, SKF_AD_VLAN_TAG_PRESENT and SKF_AD_VLAN_TAG
accesses in classic BPF.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---

1.
I was thinking to drop ntohs() from 'protocol' field for extended BPF, since
the programs could do:
if (skb->protocol == htons(ETH_P_IP))
which would have saved one or two cpu cycles.
But having similar behavior between classic and extended seems to be better.

2.
'vlan_tci' name is picked to match real sk_buff->vlan_tci field
and matches tpacket's tp_vlan_tci field.

 include/uapi/linux/bpf.h    |    3 ++
 net/core/filter.c           |   72 ++++++++++++++++++++++++++++++-------------
 samples/bpf/test_verifier.c |    9 ++++++
 3 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 929545a27546..1623047af463 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -178,6 +178,9 @@ struct __sk_buff {
 	__u32 pkt_type;
 	__u32 mark;
 	__u32 queue_mapping;
+	__u32 protocol;
+	__u32 vlan_present;
+	__u32 vlan_tci;
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 4e9dd0ad0d5b..b95ae7fe7e4f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -177,6 +177,35 @@ static u32 convert_skb_access(int skb_field, int dst_reg, int src_reg,
 		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
 				      offsetof(struct sk_buff, queue_mapping));
 		break;
+
+	case SKF_AD_PROTOCOL:
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
+
+		/* dst_reg = *(u16 *) (src_reg + offsetof(protocol)) */
+		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+				      offsetof(struct sk_buff, protocol));
+		/* dst_reg = ntohs(dst_reg) [emitting a nop or swap16] */
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, dst_reg, 16);
+		break;
+
+	case SKF_AD_VLAN_TAG:
+	case SKF_AD_VLAN_TAG_PRESENT:
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
+		BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
+
+		/* dst_reg = *(u16 *) (src_reg + offsetof(vlan_tci)) */
+		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+				      offsetof(struct sk_buff, vlan_tci));
+		if (skb_field == SKF_AD_VLAN_TAG) {
+			*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg,
+						~VLAN_TAG_PRESENT);
+		} else {
+			/* dst_reg >>= 12 */
+			*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, 12);
+			/* dst_reg &= 1 */
+			*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, 1);
+		}
+		break;
 	}
 
 	return insn - insn_buf;
@@ -190,13 +219,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 
 	switch (fp->k) {
 	case SKF_AD_OFF + SKF_AD_PROTOCOL:
-		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
-
-		/* A = *(u16 *) (CTX + offsetof(protocol)) */
-		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
-				      offsetof(struct sk_buff, protocol));
-		/* A = ntohs(A) [emitting a nop or swap16] */
-		*insn = BPF_ENDIAN(BPF_FROM_BE, BPF_REG_A, 16);
+		cnt = convert_skb_access(SKF_AD_PROTOCOL, BPF_REG_A, BPF_REG_CTX, insn);
+		insn += cnt - 1;
 		break;
 
 	case SKF_AD_OFF + SKF_AD_PKTTYPE:
@@ -242,22 +266,15 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		break;
 
 	case SKF_AD_OFF + SKF_AD_VLAN_TAG:
-	case SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT:
-		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
-		BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
+		cnt = convert_skb_access(SKF_AD_VLAN_TAG,
+					 BPF_REG_A, BPF_REG_CTX, insn);
+		insn += cnt - 1;
+		break;
 
-		/* A = *(u16 *) (CTX + offsetof(vlan_tci)) */
-		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
-				      offsetof(struct sk_buff, vlan_tci));
-		if (fp->k == SKF_AD_OFF + SKF_AD_VLAN_TAG) {
-			*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A,
-					      ~VLAN_TAG_PRESENT);
-		} else {
-			/* A >>= 12 */
-			*insn++ = BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 12);
-			/* A &= 1 */
-			*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, 1);
-		}
+	case SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT:
+		cnt = convert_skb_access(SKF_AD_VLAN_TAG_PRESENT,
+					 BPF_REG_A, BPF_REG_CTX, insn);
+		insn += cnt - 1;
 		break;
 
 	case SKF_AD_OFF + SKF_AD_PAY_OFFSET:
@@ -1215,6 +1232,17 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 
 	case offsetof(struct __sk_buff, queue_mapping):
 		return convert_skb_access(SKF_AD_QUEUE, dst_reg, src_reg, insn);
+
+	case offsetof(struct __sk_buff, protocol):
+		return convert_skb_access(SKF_AD_PROTOCOL, dst_reg, src_reg, insn);
+
+	case offsetof(struct __sk_buff, vlan_present):
+		return convert_skb_access(SKF_AD_VLAN_TAG_PRESENT,
+					  dst_reg, src_reg, insn);
+
+	case offsetof(struct __sk_buff, vlan_tci):
+		return convert_skb_access(SKF_AD_VLAN_TAG,
+					  dst_reg, src_reg, insn);
 	}
 
 	return insn - insn_buf;
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index df6dbb6576f6..75d561f9fd6a 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -658,6 +658,15 @@ static struct bpf_test tests[] = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
 				    offsetof(struct __sk_buff, queue_mapping)),
 			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, protocol)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, vlan_present)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, vlan_tci)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
 			BPF_EXIT_INSN(),
 		},
 		.result = ACCEPT,
-- 
1.7.9.5
