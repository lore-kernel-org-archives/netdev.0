From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: allow BPF programs access skb->skb_iif and skb->dev->ifindex fields
Date: Wed, 27 May 2015 15:30:39 -0700
Message-ID: <1432765839-7709-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35626 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127AbbE0Waw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 18:30:52 -0400
Received: by pdea3 with SMTP id a3so26677238pde.2
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 15:30:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

classic BPF already exposes skb->dev->ifindex via SKF_AD_IFINDEX extension.
Allow eBPF program to access it as well. Note that classic aborts execution
of the program if 'skb->dev == NULL' (which is inconvenient for program
writers), whereas eBPF returns zero in such case.
Also expose the 'skb_iif' field, since programs triggered by redirected
packet need to known the original interface index.
Summary:
__skb->ifindex         -> skb->dev->ifindex
__skb->ingress_ifindex -> skb->skb_iif

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |    2 ++
 net/core/filter.c        |   18 ++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f0a9af8b4dae..72f3080afa1e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -236,6 +236,8 @@ struct __sk_buff {
 	__u32 vlan_tci;
 	__u32 vlan_proto;
 	__u32 priority;
+	__u32 ingress_ifindex;
+	__u32 ifindex;
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 3adcca6f17a4..2c30d6632d66 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1499,6 +1499,24 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 				      offsetof(struct sk_buff, priority));
 		break;
 
+	case offsetof(struct __sk_buff, ingress_ifindex):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, skb_iif) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sk_buff, skb_iif));
+		break;
+
+	case offsetof(struct __sk_buff, ifindex):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
+
+		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, dev)),
+				      dst_reg, src_reg,
+				      offsetof(struct sk_buff, dev));
+		*insn++ = BPF_JMP_IMM(BPF_JEQ, dst_reg, 0, 1);
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, dst_reg,
+				      offsetof(struct net_device, ifindex));
+		break;
+
 	case offsetof(struct __sk_buff, mark):
 		return convert_skb_access(SKF_AD_MARK, dst_reg, src_reg, insn);
 
-- 
1.7.9.5
