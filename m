From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next] ebpf: Allow dereferences of PTR_TO_STACK registers
Date: Tue, 21 Jul 2015 19:00:40 -0700
Message-ID: <1437530440-1474680-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>,
	Alex Gartrell <agartrell@fb.com>
To: <ast@kernel.org>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39099 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751756AbbGVCAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 22:00:48 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6M1wbqE018663
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 19:00:47 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vt142g66x-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 19:00:47 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 777f41e6301511e5894c0002c9dfb610-babfb2b0 for <netdev@vger.kernel.org>;	Tue,
 21 Jul 2015 19:00:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

        mov %rsp, %r1           ; r1 = rsp
        add $-8, %r1            ; r1 = rsp - 8
        store_q $123, -8(%rsp)  ; *(u64*)r1 = 123  <- valid
        store_q $123, (%r1)     ; *(u64*)r1 = 123  <- previously invalid
        mov $0, %r0
        exit                    ; Always need to exit

And we'd get the following error:

	0: (bf) r1 = r10
	1: (07) r1 += -8
	2: (7a) *(u64 *)(r10 -8) = 999
	3: (7a) *(u64 *)(r1 +0) = 999
	R1 invalid mem access 'fp'

	Unable to load program

We already know that a register is a stack address and the appropriate
offset, so we should be able to validate those references as well.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 kernel/bpf/verifier.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 039d866..5dfbece 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -676,6 +676,15 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 			err = check_stack_write(state, off, size, value_regno);
 		else
 			err = check_stack_read(state, off, size, value_regno);
+	} else if (state->regs[regno].type == PTR_TO_STACK) {
+		int real_off = state->regs[regno].imm + off;
+
+		if (t == BPF_WRITE)
+			err = check_stack_write(
+				state, real_off, size, value_regno);
+		else
+			err = check_stack_read(
+				state, real_off, size, value_regno);
 	} else {
 		verbose("R%d invalid mem access '%s'\n",
 			regno, reg_type_str[state->regs[regno].type]);
-- 
Alex Gartrell <agartrell@fb.com>
