From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v3 2/5] bpf: Simplify bpf_load_program() error handling in the library
Date: Tue,  7 Feb 2017 21:56:06 +0100
Message-ID: <20170207205609.8035-3-mic@digikod.net>
References: <20170207205609.8035-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org,
        Wang Nan <wangnan0@huawei.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207205609.8035-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not call a second time bpf(2) when a program load failed.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
---
 tools/lib/bpf/bpf.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 3ddb58a36d3c..fda3f494f1cd 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -73,7 +73,6 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 		     size_t insns_cnt, char *license,
 		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
 {
-	int fd;
 	union bpf_attr attr;
 
 	bzero(&attr, sizeof(attr));
@@ -81,20 +80,15 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 	attr.insn_cnt = (__u32)insns_cnt;
 	attr.insns = ptr_to_u64(insns);
 	attr.license = ptr_to_u64(license);
-	attr.log_buf = ptr_to_u64(NULL);
-	attr.log_size = 0;
-	attr.log_level = 0;
+	attr.log_buf = ptr_to_u64(log_buf);
+	attr.log_size = log_buf_sz;
 	attr.kern_version = kern_version;
 
-	fd = sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
-	if (fd >= 0 || !log_buf || !log_buf_sz)
-		return fd;
+	if (log_buf && log_buf_sz > 0) {
+		attr.log_level = 1;
+		log_buf[0] = 0;
+	}
 
-	/* Try again with log */
-	attr.log_buf = ptr_to_u64(log_buf);
-	attr.log_size = log_buf_sz;
-	attr.log_level = 1;
-	log_buf[0] = 0;
 	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
-- 
2.11.0
