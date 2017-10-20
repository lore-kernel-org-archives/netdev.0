From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 2/5] bpf: Adding helper function bpf_getsockops
Date: Fri, 20 Oct 2017 11:05:40 -0700
Message-ID: <20171020180543.4156833-3-brakmo@fb.com>
References: <20171020180543.4156833-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>,
        "Daniel Borkmann" <daniel@iogearbox.net>,
        Blake Matheny <bmatheny@fb.com>,
        "Lawrence Brakmo" <brakmo@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41940 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753212AbdJTSGI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:06:08 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KI3wtu020498
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:06:08 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dqmeh0ckj-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:06:08 -0700
In-Reply-To: <20171020180543.4156833-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding support for helper function bpf_getsockops to socket_ops BPF
programs. This patch only supports TCP_CONGESTION.

Signed-off-by: Vlad Vysotsky <vlad@cs.ucla.edu>
Acked-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h                  | 19 ++++++++++---
 net/core/filter.c                         | 46 ++++++++++++++++++++++++++++++-
 tools/testing/selftests/bpf/bpf_helpers.h |  3 ++
 3 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1aca744..f650346 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -613,12 +613,22 @@ union bpf_attr {
  * int bpf_setsockopt(bpf_socket, level, optname, optval, optlen)
  *     Calls setsockopt. Not all opts are available, only those with
  *     integer optvals plus TCP_CONGESTION.
- *     Supported levels: SOL_SOCKET and IPROTO_TCP
+ *     Supported levels: SOL_SOCKET and IPPROTO_TCP
  *     @bpf_socket: pointer to bpf_socket
- *     @level: SOL_SOCKET or IPROTO_TCP
+ *     @level: SOL_SOCKET or IPPROTO_TCP
  *     @optname: option name
  *     @optval: pointer to option value
- *     @optlen: length of optval in byes
+ *     @optlen: length of optval in bytes
+ *     Return: 0 or negative error
+ *
+ * int bpf_getsockopt(bpf_socket, level, optname, optval, optlen)
+ *     Calls getsockopt. Not all opts are available.
+ *     Supported levels: IPPROTO_TCP
+ *     @bpf_socket: pointer to bpf_socket
+ *     @level: IPPROTO_TCP
+ *     @optname: option name
+ *     @optval: pointer to option value
+ *     @optlen: length of optval in bytes
  *     Return: 0 or negative error
  *
  * int bpf_skb_adjust_room(skb, len_diff, mode, flags)
@@ -721,7 +731,8 @@ union bpf_attr {
 	FN(sock_map_update),		\
 	FN(xdp_adjust_meta),		\
 	FN(perf_event_read_value),	\
-	FN(perf_prog_read_value),
+	FN(perf_prog_read_value),	\
+	FN(getsockopt),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/net/core/filter.c b/net/core/filter.c
index 09e011f..ccf62f4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3273,7 +3273,7 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 
 static const struct bpf_func_proto bpf_setsockopt_proto = {
 	.func		= bpf_setsockopt,
-	.gpl_only	= true,
+	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_ANYTHING,
@@ -3282,6 +3282,48 @@ static const struct bpf_func_proto bpf_setsockopt_proto = {
 	.arg5_type	= ARG_CONST_SIZE,
 };
 
+BPF_CALL_5(bpf_getsockopt, struct bpf_sock_ops_kern *, bpf_sock,
+	   int, level, int, optname, char *, optval, int, optlen)
+{
+	struct sock *sk = bpf_sock->sk;
+	int ret = 0;
+
+	if (!sk_fullsock(sk))
+		goto err_clear;
+
+#ifdef CONFIG_INET
+	if (level == SOL_TCP && sk->sk_prot->getsockopt == tcp_getsockopt) {
+		if (optname == TCP_CONGESTION) {
+			struct inet_connection_sock *icsk = inet_csk(sk);
+
+			if (!icsk->icsk_ca_ops || optlen <= 1)
+				goto err_clear;
+			strncpy(optval, icsk->icsk_ca_ops->name, optlen);
+			optval[optlen - 1] = 0;
+		} else {
+			goto err_clear;
+		}
+	} else {
+		goto err_clear;
+	}
+	return ret;
+#endif
+err_clear:
+	memset(optval, 0, optlen);
+	return -EINVAL;
+}
+
+static const struct bpf_func_proto bpf_getsockopt_proto = {
+	.func		= bpf_getsockopt,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg5_type	= ARG_CONST_SIZE,
+};
+
 static const struct bpf_func_proto *
 bpf_base_func_proto(enum bpf_func_id func_id)
 {
@@ -3460,6 +3502,8 @@ static const struct bpf_func_proto *
 	switch (func_id) {
 	case BPF_FUNC_setsockopt:
 		return &bpf_setsockopt_proto;
+	case BPF_FUNC_getsockopt:
+		return &bpf_getsockopt_proto;
 	case BPF_FUNC_sock_map_update:
 		return &bpf_sock_map_update_proto;
 	default:
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index e25dbf6..609514f 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -67,6 +67,9 @@ static int (*bpf_xdp_adjust_meta)(void *ctx, int offset) =
 static int (*bpf_setsockopt)(void *ctx, int level, int optname, void *optval,
 			     int optlen) =
 	(void *) BPF_FUNC_setsockopt;
+static int (*bpf_getsockopt)(void *ctx, int level, int optname, void *optval,
+			     int optlen) =
+	(void *) BPF_FUNC_getsockopt;
 static int (*bpf_sk_redirect_map)(void *map, int key, int flags) =
 	(void *) BPF_FUNC_sk_redirect_map;
 static int (*bpf_sock_map_update)(void *map, void *key, void *value,
-- 
2.9.5
