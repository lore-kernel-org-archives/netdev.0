From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, trace: make ctx access checks more robust
Date: Sun, 15 Jan 2017 01:34:25 +0100
Message-ID: <1484440465-20491-1-git-send-email-daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54090 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750743AbdAOAeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 19:34:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure that ctx cannot potentially be accessed oob by asserting
explicitly that ctx access size into pt_regs for BPF_PROG_TYPE_KPROBE
programs must be within limits. In case some 32bit archs have pt_regs
not being a multiple of 8, then BPF_DW access could cause such access.

BPF_PROG_TYPE_KPROBE progs don't have a ctx conversion function since
there's no extra mapping needed. kprobe_prog_is_valid_access() didn't
enforce sizeof(long) as the only allowed access size, since LLVM can
generate non BPF_W/BPF_DW access to regs from time to time.

For BPF_PROG_TYPE_TRACEPOINT we don't have a ctx conversion either, so
add a BUILD_BUG_ON() check to make sure that BPF_DW access will not be
a similar issue in future (ctx works on event buffer as opposed to
pt_regs there).

Fixes: 2541517c32be ("tracing, perf: Implement BPF programs attached to kprobes")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 ( Applies to both, but net-next should be just okay. For the comment
   I used kernel comment style as done throughout whole bpf_trace.c. )

 kernel/trace/bpf_trace.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 1860e7f..81fbc86 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -459,6 +459,13 @@ static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type
 		return false;
 	if (off % size != 0)
 		return false;
+	/*
+	 * Assertion for 32 bit to make sure last 8 byte access
+	 * (BPF_DW) to the last 4 byte member is disallowed.
+	 */
+	if (off + size > sizeof(struct pt_regs))
+		return false;
+
 	return true;
 }
 
@@ -540,6 +547,8 @@ static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type
 		return false;
 	if (off % size != 0)
 		return false;
+
+	BUILD_BUG_ON(PERF_MAX_TRACE_SIZE % sizeof(__u64));
 	return true;
 }
 
-- 
2.5.5
