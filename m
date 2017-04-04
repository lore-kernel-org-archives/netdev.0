From: Aaron Conole <aconole@bytheb.org>
Subject: [RFC net-next] bpf: taint loading !is_gpl programs
Date: Tue,  4 Apr 2017 14:33:54 -0400
Message-ID: <20170404183354.8579-1-aconole@bytheb.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34198 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753564AbdDDSeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 14:34:01 -0400
Received: by mail-qt0-f196.google.com with SMTP id x35so24310820qtc.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 11:34:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eBPF framework is used for more than just socket level filtering.  It
can also provide tracing, and even change the way packets coming into the
system look.  Most of the eBPF callable symbols are available to non-gpl
programs, and this includes helper functions which modify packets.  This
allows proprietary eBPF code to link to the kernel and make decisions
which can negatively impact network performance.

Since the sources for these programs are only available under a proprietary
license, it seems better to treat them the same as other proprietary
modules: set the system taint flag.  An exemption is made for socket-level
filters, since they do not really impact networking for the whole kernel.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 kernel/bpf/syscall.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index ab0cf4c4..1255b51 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -860,6 +860,11 @@ static int bpf_prog_load(union bpf_attr *attr)
 
 	bpf_prog_kallsyms_add(prog);
 	trace_bpf_prog_load(prog, err);
+	if (type != BPF_PROG_TYPE_SOCKET_FILTER && !is_gpl && !(err < 0)) {
+		if (!test_taint(TAINT_PROPRIETARY_MODULE))
+			pr_warn("bpf license '%s' taints kernel.\n", license);
+		add_taint(TAINT_PROPRIETARY_MODULE, LOCKDEP_STILL_OK);
+	}
 	return err;
 
 free_used_maps:
-- 
2.9.3
