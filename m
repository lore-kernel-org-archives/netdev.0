From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v5 16/16] bpf: update tools/include/uapi/linux/bpf.h
Date: Fri, 30 Jun 2017 13:07:06 -0700
Message-ID: <20170630200706.4183158-17-brakmo@fb.com>
References: <20170630200706.4183158-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51246 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752729AbdF3UHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 16:07:15 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UK32n9015299
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:14 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bdtfqrtg2-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:14 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 b4d033045dcf11e787371f53bdcd5fbc-7bb3f8f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 13:07:13 -0700
In-Reply-To: <20170630200706.4183158-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update tools/include/uapi/linux/bpf.h to include changes related to new
bpf sock_ops program type.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 tools/include/uapi/linux/bpf.h | 66 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 65 insertions(+), 1 deletion(-)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index f94b48b..284b366 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -120,12 +120,14 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_IN,
 	BPF_PROG_TYPE_LWT_OUT,
 	BPF_PROG_TYPE_LWT_XMIT,
+	BPF_PROG_TYPE_SOCK_OPS,
 };
 
 enum bpf_attach_type {
 	BPF_CGROUP_INET_INGRESS,
 	BPF_CGROUP_INET_EGRESS,
 	BPF_CGROUP_INET_SOCK_CREATE,
+	BPF_CGROUP_SOCK_OPS,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -518,6 +520,17 @@ union bpf_attr {
  *     Set full skb->hash.
  *     @skb: pointer to skb
  *     @hash: hash to set
+ *
+ * int bpf_setsockopt(bpf_socket, level, optname, optval, optlen)
+ *     Calls setsockopt. Not all opts are available, only those with
+ *     integer optvals plus TCP_CONGESTION.
+ *     Supported levels: SOL_SOCKET and IPROTO_TCP
+ *     @bpf_socket: pointer to bpf_socket
+ *     @level: SOL_SOCKET or IPROTO_TCP
+ *     @optname: option name
+ *     @optval: pointer to option value
+ *     @optlen: length of optval in byes
+ *     Return: 0 or negative error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -568,7 +581,8 @@ union bpf_attr {
 	FN(probe_read_str),		\
 	FN(get_socket_cookie),		\
 	FN(get_socket_uid),		\
-	FN(set_hash),
+	FN(set_hash),			\
+	FN(setsockopt),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -720,4 +734,54 @@ struct bpf_map_info {
 	__u32 map_flags;
 } __attribute__((aligned(8)));
 
+/* User bpf_sock_ops struct to access socket values and specify request ops
+ * and their replies.
+ * New fields can only be added at the end of this structure
+ */
+struct bpf_sock_ops {
+	__u32 op;
+	union {
+		__u32 reply;
+		__u32 replylong[4];
+	};
+	__u32 family;
+	__u32 remote_ip4;
+	__u32 local_ip4;
+	__u32 remote_ip6[4];
+	__u32 local_ip6[4];
+	__u32 remote_port;
+	__u32 local_port;
+};
+
+/* List of known BPF sock_ops operators.
+ * New entries can only be added at the end
+ */
+enum {
+	BPF_SOCK_OPS_VOID,
+	BPF_SOCK_OPS_TIMEOUT_INIT,	/* Should return SYN-RTO value to use or
+					 * -1 if default value should be used
+					 */
+	BPF_SOCK_OPS_RWND_INIT,		/* Should return initial advertized
+					 * window (in packets) or -1 if default
+					 * value should be used
+					 */
+	BPF_SOCK_OPS_TCP_CONNECT_CB,	/* Calls BPF program right before an
+					 * active connection is initialized
+					 */
+	BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB,	/* Calls BPF program when an
+						 * active connection is
+						 * established
+						 */
+	BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB,	/* Calls BPF program when a
+						 * passive connection is
+						 * established
+						 */
+	BPF_SOCK_OPS_NEEDS_ECN,		/* If connection's congestion control
+					 * needs ECN
+					 */
+};
+
+#define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
+#define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
+
 #endif /* _UAPI__LINUX_BPF_H__ */
-- 
2.9.3
