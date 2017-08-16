From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 04/10] bpf: introduce new program type for skbs on
 sockets
Date: Tue, 15 Aug 2017 22:31:58 -0700
Message-ID: <20170816053158.15445.22396.stgit@john-Precision-Tower-5810>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38686 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdHPFcP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:32:15 -0400
Received: by mail-pf0-f196.google.com with SMTP id h75so423960pfh.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:32:15 -0700 (PDT)
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A class of programs, run from strparser and soon from a new map type
called sock map, are used with skb as the context but on established
sockets. By creating a specific program type for these we can use
bpf helpers that expect full sockets and get the verifier to ensure
these helpers are not used out of context.

The new type is BPF_PROG_TYPE_SK_SKB. This patch introduces the
infrastructure and type.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/linux/bpf_types.h |    1 +
 include/uapi/linux/bpf.h  |    1 +
 net/core/filter.c         |   36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+)

diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index b1e1035..4b72db3 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -11,6 +11,7 @@
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_OUT, lwt_inout_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_XMIT, lwt_xmit_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_SOCK_OPS, sock_ops_prog_ops)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SK_SKB, sk_skb_prog_ops)
 #endif
 #ifdef CONFIG_BPF_EVENTS
 BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe_prog_ops)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 91da837..2e796e3 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -127,6 +127,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_OUT,
 	BPF_PROG_TYPE_LWT_XMIT,
 	BPF_PROG_TYPE_SOCK_OPS,
+	BPF_PROG_TYPE_SK_SKB,
 };
 
 enum bpf_attach_type {
diff --git a/net/core/filter.c b/net/core/filter.c
index 5afe3ac..c1108bf 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3234,6 +3234,20 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	}
 }
 
+static const struct bpf_func_proto *sk_skb_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_skb_load_bytes:
+		return &bpf_skb_load_bytes_proto;
+	case BPF_FUNC_get_socket_cookie:
+		return &bpf_get_socket_cookie_proto;
+	case BPF_FUNC_get_socket_uid:
+		return &bpf_get_socket_uid_proto;
+	default:
+		return bpf_base_func_proto(func_id);
+	}
+}
+
 static const struct bpf_func_proto *
 lwt_xmit_func_proto(enum bpf_func_id func_id)
 {
@@ -3525,6 +3539,22 @@ static bool sock_ops_is_valid_access(int off, int size,
 	return __is_valid_sock_ops_access(off, size);
 }
 
+static bool sk_skb_is_valid_access(int off, int size,
+				   enum bpf_access_type type,
+				   struct bpf_insn_access_aux *info)
+{
+	switch (off) {
+	case bpf_ctx_range(struct __sk_buff, data):
+		info->reg_type = PTR_TO_PACKET;
+		break;
+	case bpf_ctx_range(struct __sk_buff, data_end):
+		info->reg_type = PTR_TO_PACKET_END;
+		break;
+	}
+
+	return bpf_skb_is_valid_access(off, size, type, info);
+}
+
 static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 				  const struct bpf_insn *si,
 				  struct bpf_insn *insn_buf,
@@ -3992,6 +4022,12 @@ static u32 sock_ops_convert_ctx_access(enum bpf_access_type type,
 	.convert_ctx_access	= sock_ops_convert_ctx_access,
 };
 
+const struct bpf_verifier_ops sk_skb_prog_ops = {
+	.get_func_proto		= sk_skb_func_proto,
+	.is_valid_access	= sk_skb_is_valid_access,
+	.convert_ctx_access	= bpf_convert_ctx_access,
+};
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
