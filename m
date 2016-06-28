From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/6] bpf: minor cleanups on fd maps and helpers
Date: Tue, 28 Jun 2016 12:18:23 +0200
Message-ID: <e1f27c152dad20c93622a08bc6ba75cfb1666f2b.1467106475.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54538 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbcF1KuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:50:20 -0400
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor cleanups: i) Remove the unlikely() from fd array map lookups
and let the CPU branch predictor do its job, scenarios where there is not
always a map entry are very well valid. ii) Move the attribute type check
in the bpf_perf_event_read() helper a bit earlier so it's consistent wrt
checks with bpf_perf_event_output() helper as well. iii) remove some
comments that are self-documenting in kprobe_prog_is_valid_access() and
therefore make it consistent to tp_prog_is_valid_access() as well.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/core.c        |  3 +--
 kernel/trace/bpf_trace.c | 18 ++++++------------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index b94a365..d638062 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -719,14 +719,13 @@ select_insn:
 
 		if (unlikely(index >= array->map.max_entries))
 			goto out;
-
 		if (unlikely(tail_call_cnt > MAX_TAIL_CALL_CNT))
 			goto out;
 
 		tail_call_cnt++;
 
 		prog = READ_ONCE(array->ptrs[index]);
-		if (unlikely(!prog))
+		if (!prog)
 			goto out;
 
 		/* ARG1 at this point is guaranteed to point to CTX from
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3de25fb..4e61f74 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -199,19 +199,19 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 		return -E2BIG;
 
 	ee = READ_ONCE(array->ptrs[index]);
-	if (unlikely(!ee))
+	if (!ee)
 		return -ENOENT;
 
 	event = ee->event;
+	if (unlikely(event->attr.type != PERF_TYPE_HARDWARE &&
+		     event->attr.type != PERF_TYPE_RAW))
+		return -EINVAL;
+
 	/* make sure event is local and doesn't have pmu::count */
 	if (event->oncpu != smp_processor_id() ||
 	    event->pmu->count)
 		return -EINVAL;
 
-	if (unlikely(event->attr.type != PERF_TYPE_HARDWARE &&
-		     event->attr.type != PERF_TYPE_RAW))
-		return -EINVAL;
-
 	/*
 	 * we don't know if the function is run successfully by the
 	 * return value. It can be judged in other places, such as
@@ -251,7 +251,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 		return -E2BIG;
 
 	ee = READ_ONCE(array->ptrs[index]);
-	if (unlikely(!ee))
+	if (!ee)
 		return -ENOENT;
 
 	event = ee->event;
@@ -354,18 +354,12 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
 					enum bpf_reg_type *reg_type)
 {
-	/* check bounds */
 	if (off < 0 || off >= sizeof(struct pt_regs))
 		return false;
-
-	/* only read is allowed */
 	if (type != BPF_READ)
 		return false;
-
-	/* disallow misaligned access */
 	if (off % size != 0)
 		return false;
-
 	return true;
 }
 
-- 
1.9.3
