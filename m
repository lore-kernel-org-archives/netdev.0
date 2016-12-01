From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v7 net-next 4/6] bpf: Add support for reading socket family, type, protocol
Date: Thu,  1 Dec 2016 08:48:06 -0800
Message-ID: <1480610888-31082-5-git-send-email-dsa@cumulusnetworks.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35397 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758687AbcLAQsS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:48:18 -0500
Received: by mail-pg0-f54.google.com with SMTP id p66so96800819pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:48:18 -0800 (PST)
In-Reply-To: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add socket family, type and protocol to bpf_sock allowing bpf programs
read-only access.

Add __sk_flags_offset[0] to struct sock before the bitfield to
programmtically determine the offset of the unsigned int containing
protocol and type.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v7
- remove convert_sock_access helper and put code inline

v6
- new patch for version 6 of set

 include/net/sock.h       | 15 +++++++++++++++
 include/uapi/linux/bpf.h |  3 +++
 net/core/filter.c        | 21 +++++++++++++++++++++
 3 files changed, 39 insertions(+)

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
index 5ee722dc097d..efcc22b44ec1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2979,6 +2979,27 @@ static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
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
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sock, __sk_flags_offset));
+		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_TYPE_MASK);
+		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_TYPE_SHIFT);
+		break;
+
+	case offsetof(struct bpf_sock, protocol):
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sock, __sk_flags_offset));
+		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_PROTO_MASK);
+		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_PROTO_SHIFT);
+		break;
 	}
 
 	return insn - insn_buf;
-- 
2.1.4
