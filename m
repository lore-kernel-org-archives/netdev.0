From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/9] bpf: reconcile bpf_tail_call and stack_depth
Date: Tue, 30 May 2017 13:31:30 -0700
Message-ID: <20170530203135.3642768-5-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58108 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750979AbdE3Ubj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:39 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UKQlWe009076
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2asegy08ce-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 fa27aafc457611e7ab280002c9dfb610-8c9328f0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next set of patches will take advantage of stack_depth tracking,
so make sure that the program that does bpf_tail_call() has
stack depth large enough for the callee.
We could have tracked the stack depth of the prog_array owner program
and only allow insertion of the programs with stack depth less
than the owner, but it will break existing applications.
Some of them have trivial root bpf program that only does
multiple bpf_tail_calls and at init time the prog array is empty.
In the future we may add a flag to do such tracking optionally,
but for now play simple and safe.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d96f27ff9f6f..14ccb0759fa4 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3470,6 +3470,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			 * the program array.
 			 */
 			prog->cb_access = 1;
+			env->prog->aux->stack_depth = MAX_BPF_STACK;
 
 			/* mark bpf_tail_call as different opcode to avoid
 			 * conditional branch in the interpeter for every normal
-- 
2.9.3
