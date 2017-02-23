From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v3 2/3] Add a eBPF helper function to retrieve socket uid
Date: Wed, 22 Feb 2017 20:44:52 -0800
Message-ID: <1487825093-5221-3-git-send-email-chenbofeng.kernel@gmail.com>
References: <1487825093-5221-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Chenbo Feng <fengc@google.com>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34957 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752135AbdBWEpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 23:45:33 -0500
Received: by mail-pg0-f68.google.com with SMTP id 1so3158201pgz.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 20:45:11 -0800 (PST)
In-Reply-To: <1487825093-5221-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Returns the owner uid of the socket inside a sk_buff. This is useful to
perform per-UID accounting of network traffic or per-UID packet
filtering. The socket need to be a fullsock otherwise 0 is returned.

Change since V2:
Add a sk_to_full_sk() check before retrieving the uid. Moved the helper
function from bpf_base_func_proto() to both sk_filter_func_proto() and
tc_cls_act_func_proto(). Add function name to uapi header file under
tools/include

Change since V1:
Removed the unnecessary declarations and export command, resolved
conflict with master branch. Examine if the socket is a full socket
before getting the uid.

Signed-off-by: Chenbo Feng <chenbofeng.kernel@gmail.com>
---
 include/uapi/linux/bpf.h       |  9 ++++++++-
 net/core/filter.c              | 19 +++++++++++++++++++
 tools/include/uapi/linux/bpf.h |  3 ++-
 3 files changed, 29 insertions(+), 2 deletions(-)

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
index 06263c0..53c4afc 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2612,6 +2612,21 @@ static const struct bpf_func_proto bpf_get_socket_cookie_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
+BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
+{
+	struct sock *sk = sk_to_full_sk(skb->sk);
+	kuid_t kuid = sock_net_uid(dev_net(skb->dev), sk);
+
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
@@ -2648,6 +2663,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_load_bytes_proto;
 	case BPF_FUNC_get_socket_cookie:
 		return &bpf_get_socket_cookie_proto;
+	case BPF_FUNC_get_socket_uid:
+		return &bpf_get_socket_uid_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
@@ -2709,6 +2726,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
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
