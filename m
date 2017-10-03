From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 7/8] libbpf: add support for BPF_PROG_QUERY
Date: Mon, 2 Oct 2017 22:50:27 -0700
Message-ID: <20171003055028.1294791-8-ast@fb.com>
References: <20171003055028.1294791-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41157 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751062AbdJCFud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 01:50:33 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v935nTgh008510
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 22:50:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dbwmpabw5-17
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 22:50:33 -0700
In-Reply-To: <20171003055028.1294791-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add support for BPF_PROG_QUERY command to libbpf

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/lib/bpf/bpf.c | 20 ++++++++++++++++++++
 tools/lib/bpf/bpf.h |  3 ++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index d4b6ba8292ee..5128677e4117 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -303,6 +303,26 @@ int bpf_prog_detach2(int prog_fd, int target_fd, enum bpf_attach_type type)
 	return sys_bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
 }
 
+int bpf_prog_query(int target_fd, enum bpf_attach_type type, __u32 query_flags,
+		   __u32 *attach_flags, __u32 *prog_ids, __u32 *prog_cnt)
+{
+	union bpf_attr attr;
+	int ret;
+
+	bzero(&attr, sizeof(attr));
+	attr.query.target_fd	= target_fd;
+	attr.query.attach_type	= type;
+	attr.query.query_flags	= query_flags;
+	attr.query.prog_cnt	= *prog_cnt;
+	attr.query.prog_ids	= ptr_to_u64(prog_ids);
+
+	ret = sys_bpf(BPF_PROG_QUERY, &attr, sizeof(attr));
+	if (attach_flags)
+		*attach_flags = attr.query.attach_flags;
+	*prog_cnt = attr.query.prog_cnt;
+	return ret;
+}
+
 int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
 		      void *data_out, __u32 *size_out, __u32 *retval,
 		      __u32 *duration)
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index afd64727c9cf..6534889e2b2f 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -75,5 +75,6 @@ int bpf_map_get_next_id(__u32 start_id, __u32 *next_id);
 int bpf_prog_get_fd_by_id(__u32 id);
 int bpf_map_get_fd_by_id(__u32 id);
 int bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len);
-
+int bpf_prog_query(int target_fd, enum bpf_attach_type type, __u32 query_flags,
+		   __u32 *attach_flags, __u32 *prog_ids, __u32 *prog_cnt);
 #endif
-- 
2.9.5
