From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net] bpf: one perf event close won't free bpf program attached by another perf event
Date: Mon, 18 Sep 2017 16:38:36 -0700
Message-ID: <20170918233836.1817062-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44137 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750990AbdIRXih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:38:37 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8INZ3Jw031100
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 16:38:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2d2pwu88w1-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 16:38:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug exhibited by the following scenario:
  1. fd1 = perf_event_open with attr.config = ID1
  2. attach bpf program prog1 to fd1
  3. fd2 = perf_event_open with attr.config = ID1
     <this will be successful>
  4. user program closes fd2 and prog1 is detached from the tracepoint.
  5. user program with fd1 does not work properly as tracepoint
     no output any more.

The issue happens at step 4. Multiple perf_event_open can be called
successfully, but only one bpf prog pointer in the tp_event. In the
current logic, any fd release for the same tp_event will free
the tp_event->prog.

The fix is to free tp_event->prog only when the closing fd
corresponds to the one which registered the program.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 Additional context: discussed with Alexei internally but did not find
 a solution which can avoid introducing the additional field in
 trace_event_call structure.

 Peter, could you take a look as well and maybe you could have better
 alternative? Thanks!

 include/linux/trace_events.h | 1 +
 kernel/events/core.c         | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index 7f11050..2e0f222 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -272,6 +272,7 @@ struct trace_event_call {
 	int				perf_refcount;
 	struct hlist_head __percpu	*perf_events;
 	struct bpf_prog			*prog;
+	struct perf_event		*bpf_prog_owner;
 
 	int	(*perf_perm)(struct trace_event_call *,
 			     struct perf_event *);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 3e691b7..6bc21e2 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8171,6 +8171,7 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 		}
 	}
 	event->tp_event->prog = prog;
+	event->tp_event->bpf_prog_owner = event;
 
 	return 0;
 }
@@ -8185,7 +8186,7 @@ static void perf_event_free_bpf_prog(struct perf_event *event)
 		return;
 
 	prog = event->tp_event->prog;
-	if (prog) {
+	if (prog && event->tp_event->bpf_prog_owner == event) {
 		event->tp_event->prog = NULL;
 		bpf_prog_put(prog);
 	}
-- 
2.9.5
