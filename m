From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bpf: avoid warning for wrong pointer cast
Date: Sat, 16 Apr 2016 22:29:33 +0200
Message-ID: <1460838585-1248139-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two new functions in bpf contain a cast from a 'u64' to a
pointer. This works on 64-bit architectures but causes a warning
on all 32-bit architectures:

kernel/trace/bpf_trace.c: In function 'bpf_perf_event_output_tp':
kernel/trace/bpf_trace.c:350:13: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
  u64 ctx = *(long *)r1;

This changes the cast to first convert the u64 argument into a uintptr_t,
which is guaranteed to be the same size as a pointer.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 9940d67c93b5 ("bpf: support bpf_get_stackid() and bpf_perf_event_output() in tracepoint programs")
---
 kernel/trace/bpf_trace.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 413ec5614180..c082313a523a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -347,7 +347,7 @@ static u64 bpf_perf_event_output_tp(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
 	 * from bpf program and contain a pointer to 'struct pt_regs'. Fetch it
 	 * from there and call the same bpf_perf_event_output() helper
 	 */
-	u64 ctx = *(long *)r1;
+	u64 ctx = *(long *)(uintptr_t)r1;
 
 	return bpf_perf_event_output(ctx, r2, index, r4, size);
 }
@@ -365,7 +365,7 @@ static const struct bpf_func_proto bpf_perf_event_output_proto_tp = {
 
 static u64 bpf_get_stackid_tp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
-	u64 ctx = *(long *)r1;
+	u64 ctx = *(long *)(uintptr_t)r1;
 
 	return bpf_get_stackid(ctx, r2, r3, r4, r5);
 }
-- 
2.7.0
