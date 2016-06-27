From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, perf: delay release of BPF prog after grace period
Date: Mon, 27 Jun 2016 21:38:11 +0200
Message-ID: <7b2f4311ea7b4d0acc0042b49b8443702f1d1a70.1467055933.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jann Horn <jann@thejh.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit dead9f29ddcc ("perf: Fix race in BPF program unregister") moved
destruction of BPF program from free_event_rcu() callback to __free_event(),
which is problematic if used with tail calls: if prog A is attached as
trace event directly, but at the same time present in a tail call map used
by another trace event program elsewhere, then we need to delay destruction
via RCU grace period since it can still be in use by the program doing the
tail call (the prog first needs to be dropped from the tail call map, then
trace event with prog A attached destroyed, so we get immediate destruction).

Fixes: dead9f29ddcc ("perf: Fix race in BPF program unregister")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: Jann Horn <jann@thejh.net>
---
 include/linux/bpf.h  | 4 ++++
 kernel/events/core.c | 2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8269caf..0de4de6 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -264,6 +264,10 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
+
+static inline void bpf_prog_put_rcu(struct bpf_prog *prog)
+{
+}
 #endif /* CONFIG_BPF_SYSCALL */
 
 /* verifier prototypes for helper functions called from eBPF programs */
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 274450e..d00c47b 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7531,7 +7531,7 @@ static void perf_event_free_bpf_prog(struct perf_event *event)
 	prog = event->tp_event->prog;
 	if (prog) {
 		event->tp_event->prog = NULL;
-		bpf_prog_put(prog);
+		bpf_prog_put_rcu(prog);
 	}
 }
 
-- 
1.9.3
