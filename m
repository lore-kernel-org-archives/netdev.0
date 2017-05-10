From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] bpf: Add bpf_verify_program() to the library.
Date: Wed, 10 May 2017 15:10:00 -0400 (EDT)
Message-ID: <20170510.151000.1271350336586950089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42906 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754156AbdEJTKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 15:10:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This allows a test case to load a BPF program and unconditionally
acquire the verifier log.

It also allows specification of the strict alignment flag.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/lib/bpf/bpf.c | 22 ++++++++++++++++++++++
 tools/lib/bpf/bpf.h |  4 ++++
 2 files changed, 26 insertions(+)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 4fe444b80..6e17898 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -117,6 +117,28 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
+int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
+		       size_t insns_cnt, int strict_alignment,
+		       const char *license, __u32 kern_version,
+		       char *log_buf, size_t log_buf_sz)
+{
+	union bpf_attr attr;
+
+	bzero(&attr, sizeof(attr));
+	attr.prog_type = type;
+	attr.insn_cnt = (__u32)insns_cnt;
+	attr.insns = ptr_to_u64(insns);
+	attr.license = ptr_to_u64(license);
+	attr.log_buf = ptr_to_u64(log_buf);
+	attr.log_size = log_buf_sz;
+	attr.log_level = 2;
+	log_buf[0] = 0;
+	attr.kern_version = kern_version;
+	attr.prog_flags = strict_alignment ? BPF_F_STRICT_ALIGNMENT : 0;
+
+	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
+}
+
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags)
 {
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index edb4dae..972bd83 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -35,6 +35,10 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf,
 		     size_t log_buf_sz);
+int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
+		       size_t insns_cnt, int strict_alignment,
+		       const char *license, __u32 kern_version,
+		       char *log_buf, size_t log_buf_sz);
 
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
-- 
2.1.2.532.g19b5d50
