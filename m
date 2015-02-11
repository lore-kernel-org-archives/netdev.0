From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/7] ebpf: check first for MAXINSNS in bpf_prog_load
Date: Wed, 11 Feb 2015 01:15:14 +0100
Message-ID: <a1a9810494aebf0c0be8660e996b84c1cdb06444.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56170 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbBKAPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:15:34 -0500
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just minor ... before doing all the copying work, we may want
to check for instruction count earlier. Also, we may want to
warn the user in case we would otherwise need to truncate the
license information.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/syscall.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 536edc2..73b105c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -473,25 +473,26 @@ static int bpf_prog_load(union bpf_attr *attr)
 {
 	enum bpf_prog_type type = attr->prog_type;
 	struct bpf_prog *prog;
-	int err;
 	char license[128];
 	bool is_gpl;
+	int err;
 
 	if (CHECK_ATTR(BPF_PROG_LOAD))
 		return -EINVAL;
+	if (attr->insn_cnt >= BPF_MAXINSNS)
+		return -EINVAL;
 
 	/* copy eBPF program license from user space */
-	if (strncpy_from_user(license, u64_to_ptr(attr->license),
-			      sizeof(license) - 1) < 0)
-		return -EFAULT;
-	license[sizeof(license) - 1] = 0;
+	err = strncpy_from_user(license, u64_to_ptr(attr->license),
+				sizeof(license));
+	if (err == sizeof(license))
+		err = -ERANGE;
+	if (err < 0)
+		return err;
 
 	/* eBPF programs must be GPL compatible to use GPL-ed functions */
 	is_gpl = license_is_gpl_compatible(license);
 
-	if (attr->insn_cnt >= BPF_MAXINSNS)
-		return -EINVAL;
-
 	/* plain bpf_prog allocation */
 	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
 	if (!prog)
-- 
1.9.3
