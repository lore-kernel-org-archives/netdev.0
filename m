From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 5/6] net: bpf, add skb to sk lookup routines
Date: Thu, 03 Aug 2017 16:38:16 -0700
Message-ID: <20170803233816.12107.48409.stgit@john-Precision-Tower-5810>
References: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: davem@davemloft.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35790 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCXia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:38:30 -0400
Received: by mail-pg0-f68.google.com with SMTP id l64so144512pge.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:38:30 -0700 (PDT)
In-Reply-To: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some useful skb to sk routines to fine ports on a connected
socket.

This is for testing, we may prefer to put sk in bpf sk_buff
representation and access these fields directly. Similar to
sock ops ctx access.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/uapi/linux/bpf.h |    2 ++
 net/core/filter.c        |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index a89e831..c626c8f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -604,6 +604,8 @@ enum bpf_attach_type {
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
 	FN(map_ctx_update_elem),	\
+	FN(skb_get_local_port),		\
+	FN(skb_get_remote_port),	\
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/net/core/filter.c b/net/core/filter.c
index 2644f2d..3234200 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2993,6 +2993,38 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
+BPF_CALL_1(bpf_get_remote_port, struct sk_buff *, skb)
+{
+	struct sock *sk = skb->sk;//sk_to_full_sk(skb->sk);
+
+	if (!sk)// || !sk_fullsock(sk))
+		return overflowuid;
+	return sk->sk_dport;
+}
+
+static const struct bpf_func_proto bpf_skb_get_remote_port_proto = {
+	.func           = bpf_get_remote_port,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+};
+
+BPF_CALL_1(bpf_get_local_port, struct sk_buff *, skb)
+{
+	struct sock *sk = skb->sk;
+
+	if (!sk)// || !sk_fullsock(sk))
+		return overflowuid;
+	return sk->sk_num;
+}
+
+static const struct bpf_func_proto bpf_skb_get_local_port_proto = {
+	.func           = bpf_get_local_port,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+};
+
 BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 	   int, level, int, optname, char *, optval, int, optlen)
 {
@@ -3135,6 +3167,10 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 		return &bpf_get_socket_cookie_proto;
 	case BPF_FUNC_get_socket_uid:
 		return &bpf_get_socket_uid_proto;
+	case BPF_FUNC_skb_get_remote_port:
+		return &bpf_skb_get_remote_port_proto;
+	case BPF_FUNC_skb_get_local_port:
+		return &bpf_skb_get_local_port_proto;
 	case BPF_FUNC_sk_redirect_map:
 		return &bpf_sk_redirect_map_proto;
 	case BPF_FUNC_map_ctx_update_elem:
