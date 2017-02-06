From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v2 2/2] Add a eBPF helper function to retrieve socket uid
Date: Sun,  5 Feb 2017 18:17:28 -0800
Message-ID: <1486347448-15393-3-git-send-email-chenbofeng.kernel@gmail.com>
References: <1486347448-15393-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>
To: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36549 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752582AbdBFCSO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 21:18:14 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so5722871pfo.3
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 18:18:14 -0800 (PST)
In-Reply-To: <1486347448-15393-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Returns the owner uid of the socket inside a sk_buff. This is useful to
perform per-UID accounting of network traffic or per-UID packet
filtering.

Signed-off-by: Chenbo Feng <chenbofeng.kernel@gmail.com>
---
 include/uapi/linux/bpf.h |  9 ++++++++-
 net/core/filter.c        | 17 +++++++++++++++++
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6923d21..4854027 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -455,6 +455,12 @@ union bpf_attr {
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
@@ -503,7 +509,8 @@ union bpf_attr {
 	FN(skb_change_head),		\
 	FN(xdp_adjust_head),		\
 	FN(probe_read_str),		\
-	FN(get_socket_cookie),
+	FN(get_socket_cookie),		\
+	FN(get_socket_uid),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/net/core/filter.c b/net/core/filter.c
index 632fb91..523ed08 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2612,6 +2612,21 @@ static const struct bpf_func_proto bpf_get_socket_cookie_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
+BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
+{
+	struct sock *sk = skb->sk;
+	kuid_t kuid = sock_net_uid(net, sk && sk_fullsock(sk) ?
+				   sk : NULL);
+	return (u32)kuid.val;
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
@@ -2637,6 +2652,8 @@ bpf_base_func_proto(enum bpf_func_id func_id)
 			return bpf_get_trace_printk_proto();
 	case BPF_FUNC_get_socket_cookie:
 		return &bpf_get_socket_cookie_proto;
+	case BPF_FUNC_get_socket_uid:
+		return &bpf_get_socket_uid_proto;
 	default:
 		return NULL;
 	}
-- 
2.7.4
