From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/2] samples/bpf: fix sockex2 example
Date: Tue, 22 Nov 2016 16:52:08 -0800
Message-ID: <1479862329-2361912-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48150 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753620AbcKWAw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 19:52:26 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAN0meqN011479
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 16:52:12 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26vwwestkf-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 16:52:12 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 10cb0168b11711e6892224be05904660-250dea50 for <netdev@vger.kernel.org>;        Tue,
 22 Nov 2016 16:52:10 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since llvm commit "Do not expand UNDEF SDNode during insn selection lowering"
llvm will generate code that uses uninitialized registers for cases
where C code is actually uses uninitialized data.
So this sockex2 example is technically broken.
Fix it by initializing on the stack variable fully.
Also increase verifier buffer limit, since verifier output
may not fit in 64k for this sockex2 code depending on llvm version.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/libbpf.h       | 2 +-
 samples/bpf/sockex2_kern.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index ac6edb61b64a..de96a935068d 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -18,7 +18,7 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
 
-#define LOG_BUF_SIZE 65536
+#define LOG_BUF_SIZE (256 * 1024)
 extern char bpf_log_buf[LOG_BUF_SIZE];
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
diff --git a/samples/bpf/sockex2_kern.c b/samples/bpf/sockex2_kern.c
index 44e5846c988f..f58acfc92556 100644
--- a/samples/bpf/sockex2_kern.c
+++ b/samples/bpf/sockex2_kern.c
@@ -198,7 +198,7 @@ struct bpf_map_def SEC("maps") hash_map = {
 SEC("socket2")
 int bpf_prog2(struct __sk_buff *skb)
 {
-	struct bpf_flow_keys flow;
+	struct bpf_flow_keys flow = {};
 	struct pair *value;
 	u32 key;
 
-- 
2.8.0
