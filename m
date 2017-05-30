From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 6/9] bpf: fix stack_depth usage by test_bpf.ko
Date: Tue, 30 May 2017 13:31:32 -0700
Message-ID: <20170530203135.3642768-7-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58104 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750871AbdE3Ubh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:37 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UKQmIX009090
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2asegy08cc-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:37 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 fa3740ca457611e798ce0002c9931860-69b636b0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

test_bpf.ko doesn't call verifier before selecting interpreter or JITing,
hence the tests need to manually specify the amount of stack they consume.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/test_bpf.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index be88cbaadde3..070bde56474c 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -84,6 +84,7 @@ struct bpf_test {
 	} test[MAX_SUBTESTS];
 	int (*fill_helper)(struct bpf_test *self);
 	__u8 frag_data[MAX_DATA];
+	int stack_depth; /* for eBPF only, since tests don't call verifier */
 };
 
 /* Large test cases need separate allocation and fill handler. */
@@ -455,6 +456,7 @@ static int __bpf_fill_stxdw(struct bpf_test *self, int size)
 
 	self->u.ptr.insns = insn;
 	self->u.ptr.len = len;
+	self->stack_depth = 40;
 
 	return 0;
 }
@@ -2317,7 +2319,8 @@ static struct bpf_test tests[] = {
 		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x08, 0x06, 0, 0,
 		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 		  0x10, 0xbf, 0x48, 0xd6, 0x43, 0xd6},
-		{ { 38, 256 } }
+		{ { 38, 256 } },
+		.stack_depth = 64,
 	},
 	/* BPF_ALU | BPF_MOV | BPF_X */
 	{
@@ -4169,6 +4172,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xff } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_B: Store/Load byte: max positive",
@@ -4181,6 +4185,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x7f } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_MEM_B: Store/Load byte: max negative",
@@ -4194,6 +4199,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xff } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_H: Store/Load half word: max negative",
@@ -4206,6 +4212,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xffff } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_H: Store/Load half word: max positive",
@@ -4218,6 +4225,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x7fff } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_MEM_H: Store/Load half word: max negative",
@@ -4231,6 +4239,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xffff } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_W: Store/Load word: max negative",
@@ -4243,6 +4252,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xffffffff } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_W: Store/Load word: max positive",
@@ -4255,6 +4265,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x7fffffff } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_MEM_W: Store/Load word: max negative",
@@ -4268,6 +4279,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xffffffff } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_DW: Store/Load double word: max negative",
@@ -4280,6 +4292,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xffffffff } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_DW: Store/Load double word: max negative 2",
@@ -4297,6 +4310,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x1 } },
+		.stack_depth = 40,
 	},
 	{
 		"ST_MEM_DW: Store/Load double word: max positive",
@@ -4309,6 +4323,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x7fffffff } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_MEM_DW: Store/Load double word: max negative",
@@ -4322,6 +4337,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0xffffffff } },
+		.stack_depth = 40,
 	},
 	/* BPF_STX | BPF_XADD | BPF_W/DW */
 	{
@@ -4336,6 +4352,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x22 } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_XADD_W: Test side-effects, r10: 0x12 + 0x10 = 0x22",
@@ -4351,6 +4368,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0 } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_XADD_W: Test side-effects, r0: 0x12 + 0x10 = 0x22",
@@ -4363,6 +4381,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x12 } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_XADD_W: X + 1 + 1 + 1 + ...",
@@ -4384,6 +4403,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x22 } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_XADD_DW: Test side-effects, r10: 0x12 + 0x10 = 0x22",
@@ -4399,6 +4419,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0 } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_XADD_DW: Test side-effects, r0: 0x12 + 0x10 = 0x22",
@@ -4411,6 +4432,7 @@ static struct bpf_test tests[] = {
 		INTERNAL,
 		{ },
 		{ { 0, 0x12 } },
+		.stack_depth = 40,
 	},
 	{
 		"STX_XADD_DW: X + 1 + 1 + 1 + ...",
@@ -5809,6 +5831,7 @@ static struct bpf_prog *generate_filter(int which, int *err)
 		/* Type doesn't really matter here as long as it's not unspec. */
 		fp->type = BPF_PROG_TYPE_SOCKET_FILTER;
 		memcpy(fp->insnsi, fptr, fp->len * sizeof(struct bpf_insn));
+		fp->aux->stack_depth = tests[which].stack_depth;
 
 		/* We cannot error here as we don't need type compatibility
 		 * checks.
-- 
2.9.3
