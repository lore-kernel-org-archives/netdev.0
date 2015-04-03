From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf: add skb->priority to offset map for usage in {cls,act}_bpf
Date: Fri,  3 Apr 2015 20:52:24 +0200
Message-ID: <e9507df311c2d04e46143ee4bd321f99f917640d.1428086479.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40175 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbDCSwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 14:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the ability to read out the skb->priority from an eBPF
program, so that it can be taken into account from a tc filter
or action for the use-case where the priority is not being used
to directly override the filter classification in a qdisc, but
to tag traffic otherwise for the classifier; the priority can be
assigned from various places incl. user space, in future we may
also mangle it from an eBPF program.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 74aab6e..0db8580 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -184,6 +184,7 @@ struct __sk_buff {
 	__u32 vlan_present;
 	__u32 vlan_tci;
 	__u32 vlan_proto;
+	__u32 priority;
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 444a07e..955a7d7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1304,6 +1304,13 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 				      offsetof(struct sk_buff, vlan_proto));
 		break;
 
+	case offsetof(struct __sk_buff, priority):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, priority) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sk_buff, priority));
+		break;
+
 	case offsetof(struct __sk_buff, mark):
 		return convert_skb_access(SKF_AD_MARK, dst_reg, src_reg, insn);
 
-- 
1.9.3
