From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 8/8] samples/bpf: use bpf_prog_query() interface
Date: Mon, 2 Oct 2017 22:50:28 -0700
Message-ID: <20171003055028.1294791-9-ast@fb.com>
References: <20171003055028.1294791-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41155 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751059AbdJCFud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 01:50:33 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v935nT4K008513
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 22:50:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dbwmpabw4-15
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 22:50:33 -0700
In-Reply-To: <20171003055028.1294791-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use BPF_PROG_QUERY command to strengthen test coverage

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/test_cgrp2_attach2.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/samples/bpf/test_cgrp2_attach2.c b/samples/bpf/test_cgrp2_attach2.c
index 9a9f6836e5e9..3e8232cc04a8 100644
--- a/samples/bpf/test_cgrp2_attach2.c
+++ b/samples/bpf/test_cgrp2_attach2.c
@@ -236,6 +236,7 @@ static int prog_load_cnt(int verdict, int val)
 
 static int test_multiprog(void)
 {
+	__u32 prog_ids[4], prog_cnt = 0, attach_flags, saved_prog_id;
 	int cg1 = 0, cg2 = 0, cg3 = 0, cg4 = 0, cg5 = 0, key = 0;
 	int drop_prog, allow_prog[6] = {}, rc = 0;
 	unsigned long long value;
@@ -304,6 +305,32 @@ static int test_multiprog(void)
 	assert(bpf_map_lookup_elem(map_fd, &key, &value) == 0);
 	assert(value == 1 + 2 + 8 + 32);
 
+	/* query the number of effective progs in cg5 */
+	assert(bpf_prog_query(cg5, BPF_CGROUP_INET_EGRESS, BPF_F_QUERY_EFFECTIVE,
+			      NULL, NULL, &prog_cnt) == 0);
+	assert(prog_cnt == 4);
+	/* retrieve prog_ids of effective progs in cg5 */
+	assert(bpf_prog_query(cg5, BPF_CGROUP_INET_EGRESS, BPF_F_QUERY_EFFECTIVE,
+			      &attach_flags, prog_ids, &prog_cnt) == 0);
+	assert(prog_cnt == 4);
+	assert(attach_flags == 0);
+	saved_prog_id = prog_ids[0];
+	/* check enospc handling */
+	prog_ids[0] = 0;
+	prog_cnt = 2;
+	assert(bpf_prog_query(cg5, BPF_CGROUP_INET_EGRESS, BPF_F_QUERY_EFFECTIVE,
+			      &attach_flags, prog_ids, &prog_cnt) == -1 &&
+	       errno == ENOSPC);
+	assert(prog_cnt == 4);
+	/* check that prog_ids are returned even when buffer is too small */
+	assert(prog_ids[0] == saved_prog_id);
+	/* retrieve prog_id of single attached prog in cg5 */
+	prog_ids[0] = 0;
+	assert(bpf_prog_query(cg5, BPF_CGROUP_INET_EGRESS, 0,
+			      NULL, prog_ids, &prog_cnt) == 0);
+	assert(prog_cnt == 1);
+	assert(prog_ids[0] == saved_prog_id);
+
 	/* detach bottom program and ping again */
 	if (bpf_prog_detach2(-1, cg5, BPF_CGROUP_INET_EGRESS)) {
 		log_err("Detaching prog from cg5");
@@ -341,6 +368,15 @@ static int test_multiprog(void)
 	assert(system(PING_CMD) == 0);
 	assert(bpf_map_lookup_elem(map_fd, &key, &value) == 0);
 	assert(value == 1 + 2 + 4);
+
+	prog_cnt = 4;
+	assert(bpf_prog_query(cg5, BPF_CGROUP_INET_EGRESS, BPF_F_QUERY_EFFECTIVE,
+			      &attach_flags, prog_ids, &prog_cnt) == 0);
+	assert(prog_cnt == 3);
+	assert(attach_flags == 0);
+	assert(bpf_prog_query(cg5, BPF_CGROUP_INET_EGRESS, 0,
+			      NULL, prog_ids, &prog_cnt) == 0);
+	assert(prog_cnt == 0);
 	goto out;
 err:
 	rc = 1;
-- 
2.9.5
