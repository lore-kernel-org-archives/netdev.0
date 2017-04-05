From: David Howells <dhowells@redhat.com>
Subject: [PATCH 20/24] bpf: Restrict kernel image access functions when the
 kernel is locked down
Date: Wed, 05 Apr 2017 21:17:25 +0100
Message-ID: <149142344547.5101.4518618716303032193.stgit@warthog.procyon.org.uk>
References: <149142326734.5101.4596394505987813763.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-efi@vger.kernel.org,
        gnomes@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
        Chun-Yi Lee <jlee@suse.com>,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
        gregkh@linuxfoundation.org, matthew.garrett@nebula.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60676 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934102AbdDEURf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 16:17:35 -0400
In-Reply-To: <149142326734.5101.4596394505987813763.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chun-Yi Lee <jlee@suse.com>

There are some bpf functions can be used to read kernel memory:
bpf_probe_read, bpf_probe_write_user and bpf_trace_printk.  These allow
private keys in kernel memory (e.g. the hibernation image signing key) to
be read by an eBPF program.  Prohibit those functions when the kernel is
locked down.

Signed-off-by: Chun-Yi Lee <jlee@suse.com>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: netdev@vger.kernel.org
---

 kernel/trace/bpf_trace.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index cee9802cf3e0..7fde851f207b 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -65,6 +65,11 @@ BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
 {
 	int ret;
 
+	if (kernel_is_locked_down()) {
+		memset(dst, 0, size);
+		return -EPERM;
+	}
+
 	ret = probe_kernel_read(dst, unsafe_ptr, size);
 	if (unlikely(ret < 0))
 		memset(dst, 0, size);
@@ -84,6 +89,9 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 BPF_CALL_3(bpf_probe_write_user, void *, unsafe_ptr, const void *, src,
 	   u32, size)
 {
+	if (kernel_is_locked_down())
+		return -EPERM;
+
 	/*
 	 * Ensure we're in user context which is safe for the helper to
 	 * run. This helper has no business in a kthread.
@@ -143,6 +151,9 @@ BPF_CALL_5(bpf_trace_printk, char *, fmt, u32, fmt_size, u64, arg1,
 	if (fmt[--fmt_size] != 0)
 		return -EINVAL;
 
+	if (kernel_is_locked_down())
+		return __trace_printk(1, fmt, 0, 0, 0);
+
 	/* check format string for allowed specifiers */
 	for (i = 0; i < fmt_size; i++) {
 		if ((!isprint(fmt[i]) && !isspace(fmt[i])) || !isascii(fmt[i]))
