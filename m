From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next] bpf: avoid rcu_dereference inside bpf_event_mutex lock region
Date: Mon, 30 Oct 2017 13:50:22 -0700
Message-ID: <20171030205022.3980618-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60358 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932153AbdJ3Uu0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:50:26 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9UKkgvd005281
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:50:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2dx7txs562-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:50:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During perf event attaching/detaching bpf programs,
the tp_event->prog_array change is protected by the
bpf_event_mutex lock in both attaching and deteching
functions. Although tp_event->prog_array is a rcu
pointer, rcu_derefrence is not needed to access it
since mutex lock will guarantee ordering.

Verified through "make C=2" that sparse
locking check still happy with the new change.

Also change the label name in perf_event_{attach,detach}_bpf_prog
from "out" to "unlock" to reflect the code action after the label.

Signed-off-by: Yonghong Song <yhs@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/trace/bpf_trace.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

Peter,

Could you check whether the below change to remove rcu_dereference_protected
is what you wanted or not?

Thanks!

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index b65011d..e7685c5 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -767,20 +767,19 @@ int perf_event_attach_bpf_prog(struct perf_event *event,
 	mutex_lock(&bpf_event_mutex);
 
 	if (event->prog)
-		goto out;
+		goto unlock;
 
-	old_array = rcu_dereference_protected(event->tp_event->prog_array,
-					      lockdep_is_held(&bpf_event_mutex));
+	old_array = event->tp_event->prog_array;
 	ret = bpf_prog_array_copy(old_array, NULL, prog, &new_array);
 	if (ret < 0)
-		goto out;
+		goto unlock;
 
 	/* set the new array to event->tp_event and set event->prog */
 	event->prog = prog;
 	rcu_assign_pointer(event->tp_event->prog_array, new_array);
 	bpf_prog_array_free(old_array);
 
-out:
+unlock:
 	mutex_unlock(&bpf_event_mutex);
 	return ret;
 }
@@ -794,11 +793,9 @@ void perf_event_detach_bpf_prog(struct perf_event *event)
 	mutex_lock(&bpf_event_mutex);
 
 	if (!event->prog)
-		goto out;
-
-	old_array = rcu_dereference_protected(event->tp_event->prog_array,
-					      lockdep_is_held(&bpf_event_mutex));
+		goto unlock;
 
+	old_array = event->tp_event->prog_array;
 	ret = bpf_prog_array_copy(old_array, event->prog, NULL, &new_array);
 	if (ret < 0) {
 		bpf_prog_array_delete_safe(old_array, event->prog);
@@ -810,6 +807,6 @@ void perf_event_detach_bpf_prog(struct perf_event *event)
 	bpf_prog_put(event->prog);
 	event->prog = NULL;
 
-out:
+unlock:
 	mutex_unlock(&bpf_event_mutex);
 }
-- 
2.9.5
