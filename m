From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v5 2/3] Add a eBPF helper function to retrieve socket uid
Date: Mon, 20 Mar 2017 11:41:05 -0700
Message-ID: <1490035266-9861-3-git-send-email-chenbofeng.kernel@gmail.com>
References: <1490035266-9861-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35290 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756024AbdCTSlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 14:41:52 -0400
Received: by mail-pf0-f195.google.com with SMTP id n11so7222305pfg.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:41:35 -0700 (PDT)
In-Reply-To: <1490035266-9861-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Returns the owner uid of the socket inside a sk_buff. This is useful to
perform per-UID accounting of network traffic or per-UID packet
filtering. The socket need to be a fullsock otherwise overflowuid is
returned.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 include/uapi/linux/bpf.h       |  9 ++++++++-
 net/core/filter.c              | 22 ++++++++++++++++++++++
 tools/include/uapi/linux/bpf.h |  3 ++-
 3 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index dc81a9f..ff42111 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -462,6 +462,12 @@ union bpf_attr {
  *     @skb: pointer to skb
  *     Return: 8 Bytes non-decreasing number on success or 0 if the socket
  *     field is missing inside sk_buff
+ *
+ * u32 bpf_get_socket_uid(skb)
+ *     Get the owner uid of the socket stored inside sk_buff.
+ *     @skb: pointer to skb
+ *     Return: uid of the socket owner on success or 0 if the socket pointer
+ *     inside sk_buff is NULL
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -510,7 +516,8 @@ union bpf_attr {
 	FN(skb_change_head),		\
 	FN(xdp_adjust_head),		\
 	FN(probe_read_str),		\
-	FN(get_socket_cookie),
+	FN(get_socket_cookie),		\
+	FN(get_socket_uid),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/net/core/filter.c b/net/core/filter.c
index 5b65ae3..a7c25c1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2612,6 +2612,24 @@ static const struct bpf_func_proto bpf_get_socket_cookie_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
+BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
+{
+	kuid_t kuid;
+	struct sock *sk = sk_to_full_sk(skb->sk);
+
+	if (!sk || !sk_fullsock(sk))
+		return overflowuid;
+	kuid = sock_net_uid(sock_net(sk), sk);
+	return from_kuid_munged(current_user_ns(), kuid);
+}
+
+static const struct bpf_func_proto bpf_get_socket_uid_proto = {
+	.func           = bpf_get_socket_uid,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+};
+
 static const struct bpf_func_proto *
 bpf_base_func_proto(enum bpf_func_id func_id)
 {
@@ -2648,6 +2666,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_load_bytes_proto;
 	case BPF_FUNC_get_socket_cookie:
 		return &bpf_get_socket_cookie_proto;
+	case BPF_FUNC_get_socket_uid:
+		return &bpf_get_socket_uid_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
@@ -2709,6 +2729,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_under_cgroup_proto;
 	case BPF_FUNC_get_socket_cookie:
 		return &bpf_get_socket_cookie_proto;
+	case BPF_FUNC_get_socket_uid:
+		return &bpf_get_socket_uid_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index a94bdd3..4a2d56d 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -504,7 +504,8 @@ union bpf_attr {
 	FN(skb_change_head),		\
 	FN(xdp_adjust_head),		\
 	FN(probe_read_str),		\
-	FN(get_socket_cookie),
+	FN(get_socket_cookie),		\
+	FN(get_socket_uid),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
-- 
2.7.4
