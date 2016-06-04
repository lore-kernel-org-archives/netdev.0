From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, trace: use READ_ONCE for retrieving file ptr
Date: Sat,  4 Jun 2016 20:50:59 +0200
Message-ID: <5aa8512414e4f9f19734e59665f0fe893a109be2.1465065428.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, xiakaixu@huawei.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33053 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbcFDSvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 14:51:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bpf_perf_event_read() and bpf_perf_event_output(), we must use
READ_ONCE() for fetching the struct file pointer, which could get
updated concurrently, so we must prevent the compiler from potential
refetching.

We already do this with tail calls for fetching the related bpf_prog,
but not so on stored perf events. Semantics for both are the same
with regards to updates.

Fixes: a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")
Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 780bcbe..720b7bb 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -198,7 +198,7 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 	if (unlikely(index >= array->map.max_entries))
 		return -E2BIG;
 
-	file = (struct file *)array->ptrs[index];
+	file = READ_ONCE(array->ptrs[index]);
 	if (unlikely(!file))
 		return -ENOENT;
 
@@ -247,7 +247,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 	if (unlikely(index >= array->map.max_entries))
 		return -E2BIG;
 
-	file = (struct file *)array->ptrs[index];
+	file = READ_ONCE(array->ptrs[index]);
 	if (unlikely(!file))
 		return -ENOENT;
 
-- 
1.9.3
