From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 2/8] bpf: Add mark and priority to sock options that can be set
Date: Tue, 22 Aug 2017 17:20:15 -0700
Message-ID: <1503447621-27997-3-git-send-email-dsahern@gmail.com>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36580 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752784AbdHWAUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:20:30 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so217336pgy.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:20:30 -0700 (PDT)
In-Reply-To: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add socket mark and priority to fields that can be set by
ebpf program when a socket is created.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/uapi/linux/bpf.h |  2 ++
 net/core/filter.c        | 26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 843818dff96d..a89e5e6dff7c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -764,6 +764,8 @@ struct bpf_sock {
 	__u32 family;
 	__u32 type;
 	__u32 protocol;
+	__u32 mark;
+	__u32 priority;
 };
 
 #define XDP_PACKET_HEADROOM 256
diff --git a/net/core/filter.c b/net/core/filter.c
index fa2115695037..7ee75a40ff03 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3444,6 +3444,10 @@ static bool sock_filter_is_valid_access(int off, int size,
 		switch (off) {
 		case offsetof(struct bpf_sock, bound_dev_if):
 			break;
+		case offsetof(struct bpf_sock, mark):
+			break;
+		case offsetof(struct bpf_sock, priority):
+			break;
 		default:
 			return false;
 		}
@@ -3952,6 +3956,28 @@ static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
 				      offsetof(struct sock, sk_bound_dev_if));
 		break;
 
+	case offsetof(struct bpf_sock, mark):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_mark) != 4);
+
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
+					offsetof(struct sock, sk_mark));
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
+				      offsetof(struct sock, sk_mark));
+		break;
+
+	case offsetof(struct bpf_sock, priority):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_priority) != 4);
+
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
+					offsetof(struct sock, sk_priority));
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
+				      offsetof(struct sock, sk_priority));
+		break;
+
 	case offsetof(struct bpf_sock, family):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_family) != 2);
 
-- 
2.1.4
