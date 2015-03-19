From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf, filter: do not convert skb->protocol to host endianess during runtime
Date: Thu, 19 Mar 2015 19:38:27 +0100
Message-ID: <daaebd74ce31bd9ef7509c7083ba03d67af008bd.1426789778.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38636 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbCSSib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 14:38:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c24973957975 ("bpf: allow BPF programs access 'protocol' and 'vlan_tci'
fields") has added support for accessing protocol, vlan_present and vlan_tci
into the skb offset map.

As referenced in the below discussion, accessing skb->protocol from an eBPF
program should be converted without handling endianess.

The reason for this is that an eBPF program could simply do a check more
naturally, by f.e. testing skb->protocol == htons(ETH_P_IP), where the LLVM
compiler resolves htons() against a constant automatically during compilation
time, as opposed to an otherwise needed run time conversion.

After all, the way of programming both from a user perspective differs quite
a lot, i.e. bpf_asm ["ld proto"] versus a C subset/LLVM.

Reference: https://patchwork.ozlabs.org/patch/450819/
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 (Follow-up from our previous discussion)

 net/core/filter.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index b95ae7f..bdaac58 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -178,16 +178,6 @@ static u32 convert_skb_access(int skb_field, int dst_reg, int src_reg,
 				      offsetof(struct sk_buff, queue_mapping));
 		break;
 
-	case SKF_AD_PROTOCOL:
-		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
-
-		/* dst_reg = *(u16 *) (src_reg + offsetof(protocol)) */
-		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
-				      offsetof(struct sk_buff, protocol));
-		/* dst_reg = ntohs(dst_reg) [emitting a nop or swap16] */
-		*insn++ = BPF_ENDIAN(BPF_FROM_BE, dst_reg, 16);
-		break;
-
 	case SKF_AD_VLAN_TAG:
 	case SKF_AD_VLAN_TAG_PRESENT:
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
@@ -219,8 +209,13 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 
 	switch (fp->k) {
 	case SKF_AD_OFF + SKF_AD_PROTOCOL:
-		cnt = convert_skb_access(SKF_AD_PROTOCOL, BPF_REG_A, BPF_REG_CTX, insn);
-		insn += cnt - 1;
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
+
+		/* A = *(u16 *) (CTX + offsetof(protocol)) */
+		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
+				      offsetof(struct sk_buff, protocol));
+		/* A = ntohs(A) [emitting a nop or swap16] */
+		*insn = BPF_ENDIAN(BPF_FROM_BE, BPF_REG_A, 16);
 		break;
 
 	case SKF_AD_OFF + SKF_AD_PKTTYPE:
@@ -1224,6 +1219,13 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 				      offsetof(struct sk_buff, len));
 		break;
 
+	case offsetof(struct __sk_buff, protocol):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+				      offsetof(struct sk_buff, protocol));
+		break;
+
 	case offsetof(struct __sk_buff, mark):
 		return convert_skb_access(SKF_AD_MARK, dst_reg, src_reg, insn);
 
@@ -1233,9 +1235,6 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 	case offsetof(struct __sk_buff, queue_mapping):
 		return convert_skb_access(SKF_AD_QUEUE, dst_reg, src_reg, insn);
 
-	case offsetof(struct __sk_buff, protocol):
-		return convert_skb_access(SKF_AD_PROTOCOL, dst_reg, src_reg, insn);
-
 	case offsetof(struct __sk_buff, vlan_present):
 		return convert_skb_access(SKF_AD_VLAN_TAG_PRESENT,
 					  dst_reg, src_reg, insn);
-- 
1.9.3
