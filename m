From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/3] samples/bpf: stress test bpf_get_stackid
Date: Tue, 8 Mar 2016 15:07:53 -0800
Message-ID: <1457478474-1614041-2-git-send-email-ast@fb.com>
References: <1457478474-1614041-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457478474-1614041-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

increase stress by also calling bpf_get_stackid() from
various *spin* functions

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/spintest_kern.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/samples/bpf/spintest_kern.c b/samples/bpf/spintest_kern.c
index ef8ac33bb2e9..4b27619d91a4 100644
--- a/samples/bpf/spintest_kern.c
+++ b/samples/bpf/spintest_kern.c
@@ -8,6 +8,7 @@
 #include <linux/netdevice.h>
 #include <linux/version.h>
 #include <uapi/linux/bpf.h>
+#include <uapi/linux/perf_event.h>
 #include "bpf_helpers.h"
 
 struct bpf_map_def SEC("maps") my_map = {
@@ -23,6 +24,13 @@ struct bpf_map_def SEC("maps") my_map2 = {
 	.max_entries = 1024,
 };
 
+struct bpf_map_def SEC("maps") stackmap = {
+	.type = BPF_MAP_TYPE_STACK_TRACE,
+	.key_size = sizeof(u32),
+	.value_size = PERF_MAX_STACK_DEPTH * sizeof(u64),
+	.max_entries = 10000,
+};
+
 #define PROG(foo) \
 int foo(struct pt_regs *ctx) \
 { \
@@ -32,6 +40,7 @@ int foo(struct pt_regs *ctx) \
 	bpf_map_update_elem(&my_map, &v, &v, BPF_ANY); \
 	bpf_map_update_elem(&my_map2, &v, &v, BPF_ANY); \
 	bpf_map_delete_elem(&my_map2, &v); \
+	bpf_get_stackid(ctx, &stackmap, BPF_F_REUSE_STACKID); \
 	return 0; \
 }
 
-- 
2.8.0.rc1
