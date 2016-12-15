From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v6 1/5] net: xdp: add invalid buffer warning
Date: Thu, 15 Dec 2016 12:12:54 -0800
Message-ID: <20161215201253.23639.72211.stgit@john-Precision-Tower-5810>
References: <20161215200712.23639.53043.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch, davem@davemloft.net
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35433 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754042AbcLOUdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 15:33:10 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so3285908pfk.2
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 12:33:09 -0800 (PST)
In-Reply-To: <20161215200712.23639.53043.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a warning for drivers to use when encountering an invalid
buffer for XDP. For normal cases this should not happen but to catch
this in virtual/qemu setups that I may not have expected from the
emulation layer having a standard warning is useful.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/filter.h |    1 +
 net/core/filter.c      |    6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 6a16583..af8a180 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -602,6 +602,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
 void bpf_warn_invalid_xdp_action(u32 act);
+void bpf_warn_invalid_xdp_buffer(void);
 
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
diff --git a/net/core/filter.c b/net/core/filter.c
index b146170..7190bd6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2972,6 +2972,12 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
+void bpf_warn_invalid_xdp_buffer(void)
+{
+	WARN_ONCE(1, "Illegal XDP buffer encountered, expect throughput degradation\n");
+}
+EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_buffer);
+
 static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 					int src_reg, int ctx_off,
 					struct bpf_insn *insn_buf,
