From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v6 4/6] bpf: Add support for reading socket family, type, protocol
Date: Wed, 30 Nov 2016 10:16:48 -0800
Message-ID: <1480529810-25850-5-git-send-email-dsa@cumulusnetworks.com>
References: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:32995 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754355AbcK3SRW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:17:22 -0500
Received: by mail-pg0-f41.google.com with SMTP id 3so84642274pgd.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:16:59 -0800 (PST)
In-Reply-To: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add socket family, type and protocol to bpf_sock allowing bpf programs
read-only access.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v6
- new patch for version 6 of set

 include/net/sock.h       | 15 +++++++++++++++
 include/uapi/linux/bpf.h |  3 +++
 net/core/filter.c        | 42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 442cbb118a07..69afda6bea15 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -389,6 +389,21 @@ struct sock {
 	 * Because of non atomicity rules, all
 	 * changes are protected by socket lock.
 	 */
+	unsigned int		__sk_flags_offset[0];
+#ifdef __BIG_ENDIAN_BITFIELD
+#define SK_FL_PROTO_SHIFT  16
+#define SK_FL_PROTO_MASK   0x00ff0000
+
+#define SK_FL_TYPE_SHIFT   0
+#define SK_FL_TYPE_MASK    0x0000ffff
+#else
+#define SK_FL_PROTO_SHIFT  8
+#define SK_FL_PROTO_MASK   0x0000ff00
+
+#define SK_FL_TYPE_SHIFT   16
+#define SK_FL_TYPE_MASK    0xffff0000
+#endif
+
 	kmemcheck_bitfield_begin(flags);
 	unsigned int		sk_padding : 2,
 				sk_no_check_tx : 1,
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 75964e00d947..b47ffd117fd6 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -541,6 +541,9 @@ struct bpf_tunnel_key {
 
 struct bpf_sock {
 	__u32 bound_dev_if;
+	__u32 family;
+	__u32 type;
+	__u32 protocol;
 };
 
 /* User return codes for XDP prog type.
diff --git a/net/core/filter.c b/net/core/filter.c
index 5ee722dc097d..ddc86efe1911 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2960,6 +2960,33 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	return insn - insn_buf;
 }
 
+#define SOCKF_AD_TYPE     1
+#define SOCKF_AD_PROTOCOL 2
+
+static u32 convert_sock_access(int sock_field, int dst_reg, int src_reg,
+			       struct bpf_insn *insn_buf)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (sock_field) {
+	case SOCKF_AD_TYPE:
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sock, __sk_flags_offset));
+		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_TYPE_MASK);
+		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_TYPE_SHIFT);
+		break;
+
+	case SOCKF_AD_PROTOCOL:
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sock, __sk_flags_offset));
+		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_PROTO_MASK);
+		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_PROTO_SHIFT);
+		break;
+	}
+
+	return insn - insn_buf;
+}
+
 static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
 					  int dst_reg, int src_reg,
 					  int ctx_off,
@@ -2979,6 +3006,21 @@ static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
 			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
 				      offsetof(struct sock, sk_bound_dev_if));
 		break;
+
+	case offsetof(struct bpf_sock, family):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_family) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+				      offsetof(struct sock, sk_family));
+		break;
+
+	case offsetof(struct bpf_sock, type):
+		return convert_sock_access(SOCKF_AD_TYPE, dst_reg, src_reg,
+					   insn_buf);
+
+	case offsetof(struct bpf_sock, protocol):
+		return convert_sock_access(SOCKF_AD_PROTOCOL, dst_reg, src_reg,
+					   insn_buf);
 	}
 
 	return insn - insn_buf;
-- 
2.1.4
