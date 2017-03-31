From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 2/6] tools/lib/bpf: add support for BPF_PROG_TEST_RUN command
Date: Thu, 30 Mar 2017 21:45:39 -0700
Message-ID: <20170331044543.4075183-3-ast@fb.com>
References: <20170331044543.4075183-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47456 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752390AbdCaEpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 00:45:49 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2V4hEED002197
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:48 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29hg5581jh-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:48 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 e6d72ede15cc11e7959724be0593f280-714f99a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 21:45:45 -0700
In-Reply-To: <20170331044543.4075183-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add support for BPF_PROG_TEST_RUN command to libbpf.a

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/include/uapi/linux/bpf.h | 24 ++++++++++++++++++++++++
 tools/lib/bpf/bpf.c            | 24 ++++++++++++++++++++++++
 tools/lib/bpf/bpf.h            |  4 +++-
 3 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 1ea08ce35567..a1d95386f562 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -81,6 +81,7 @@ enum bpf_cmd {
 	BPF_OBJ_GET,
 	BPF_PROG_ATTACH,
 	BPF_PROG_DETACH,
+	BPF_PROG_TEST_RUN,
 };
 
 enum bpf_map_type {
@@ -189,6 +190,17 @@ union bpf_attr {
 		__u32		attach_type;
 		__u32		attach_flags;
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_TEST_RUN command */
+		__u32		prog_fd;
+		__u32		retval;
+		__u32		data_size_in;
+		__u32		data_size_out;
+		__aligned_u64	data_in;
+		__aligned_u64	data_out;
+		__u32		repeat;
+		__u32		duration;
+	} test;
 } __attribute__((aligned(8)));
 
 /* BPF helper function descriptions:
@@ -459,6 +471,18 @@ union bpf_attr {
  *     Return:
  *       > 0 length of the string including the trailing NUL on success
  *       < 0 error
+ *
+ * u64 bpf_bpf_get_socket_cookie(skb)
+ *     Get the cookie for the socket stored inside sk_buff.
+ *     @skb: pointer to skb
+ *     Return: 8 Bytes non-decreasing number on success or 0 if the socket
+ *     field is missing inside sk_buff
+ *
+ * u32 bpf_get_socket_uid(skb)
+ *     Get the owner uid of the socket stored inside sk_buff.
+ *     @skb: pointer to skb
+ *     Return: uid of the socket owner on success or 0 if the socket pointer
+ *     inside sk_buff is NULL
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 9b58d20e8c93..f84c398c11f4 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -209,3 +209,27 @@ int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
 
 	return sys_bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
 }
+
+int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
+		      void *data_out, __u32 *size_out, __u32 *retval,
+		      __u32 *duration)
+{
+	union bpf_attr attr;
+	int ret;
+
+	bzero(&attr, sizeof(attr));
+	attr.test.prog_fd = prog_fd;
+	attr.test.data_in = ptr_to_u64(data);
+	attr.test.data_out = ptr_to_u64(data_out);
+	attr.test.data_size_in = size;
+	attr.test.repeat = repeat;
+
+	ret = sys_bpf(BPF_PROG_TEST_RUN, &attr, sizeof(attr));
+	if (size_out)
+		*size_out = attr.test.data_size_out;
+	if (retval)
+		*retval = attr.test.retval;
+	if (duration)
+		*duration = attr.test.duration;
+	return ret;
+}
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 93f021932623..edb4daeff7a5 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -47,6 +47,8 @@ int bpf_obj_get(const char *pathname);
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type,
 		    unsigned int flags);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
-
+int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
+		      void *data_out, __u32 *size_out, __u32 *retval,
+		      __u32 *duration);
 
 #endif
-- 
2.9.3
