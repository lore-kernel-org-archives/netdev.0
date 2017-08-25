From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 2/8] bpf: Add mark and priority to sock options that can be set
Date: Fri, 25 Aug 2017 12:05:35 -0700
Message-ID: <1503687941-626-3-git-send-email-dsahern@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37643 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755040AbdHYTFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:05:52 -0400
Received: by mail-pg0-f66.google.com with SMTP id a7so887760pgn.4
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:05:52 -0700 (PDT)
In-Reply-To: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add socket mark and priority to fields that can be set by
ebpf program when a socket is created.

Signed-off-by: David Ahern <dsahern@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  2 ++
 net/core/filter.c        | 26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 595e31b30f23..f72b957580cd 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -773,6 +773,8 @@ struct bpf_sock {
 	__u32 family;
 	__u32 type;
 	__u32 protocol;
+	__u32 mark;
+	__u32 priority;
 };
 
 #define XDP_PACKET_HEADROOM 256
diff --git a/net/core/filter.c b/net/core/filter.c
index 4bcd6baa80c9..d582d1b1e533 100644
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
@@ -3947,6 +3951,28 @@ static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
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
