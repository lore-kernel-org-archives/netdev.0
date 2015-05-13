From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] test_bpf: add tests related to BPF_MAXINSNS
Date: Wed, 13 May 2015 13:12:43 +0200
Message-ID: <f35ca0ee7ba9a7a934dc6131a32fafa941d8dcad.1431515140.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Nicolas Schichan <nschichan@freebox.fr>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58099 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933730AbbEMLMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of torture test cases related to the bug fixed in 0b59d8806a31
("ARM: net: delegate filter to kernel interpreter when imm_offset()
return value can't fit into 12bits.").

I've added a helper to allocate and fill the insn space. Output on
x86_64 from my laptop:

test_bpf: #233 BPF_MAXINSNS: Maximum possible literals jited:0 7 PASS
test_bpf: #234 BPF_MAXINSNS: Single literal jited:0 8 PASS
test_bpf: #235 BPF_MAXINSNS: Run/add until end jited:0 11553 PASS
test_bpf: #236 BPF_MAXINSNS: Too many instructions PASS
test_bpf: #237 BPF_MAXINSNS: Very long jump jited:0 9 PASS
test_bpf: #238 BPF_MAXINSNS: Ctx heavy transformations jited:0 20329 20398 PASS
test_bpf: #239 BPF_MAXINSNS: Call heavy transformations jited:0 32178 32475 PASS
test_bpf: #240 BPF_MAXINSNS: Jump heavy test jited:0 10518 PASS

test_bpf: #233 BPF_MAXINSNS: Maximum possible literals jited:1 4 PASS
test_bpf: #234 BPF_MAXINSNS: Single literal jited:1 4 PASS
test_bpf: #235 BPF_MAXINSNS: Run/add until end jited:1 1625 PASS
test_bpf: #236 BPF_MAXINSNS: Too many instructions PASS
test_bpf: #237 BPF_MAXINSNS: Very long jump jited:1 8 PASS
test_bpf: #238 BPF_MAXINSNS: Ctx heavy transformations jited:1 3301 3174 PASS
test_bpf: #239 BPF_MAXINSNS: Call heavy transformations jited:1 24107 23491 PASS
test_bpf: #240 BPF_MAXINSNS: Jump heavy test jited:1 8651 PASS

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Nicolas Schichan <nschichan@freebox.fr>
---
 include/linux/filter.h |   8 ++
 lib/test_bpf.c         | 317 +++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 316 insertions(+), 9 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index ce1d72d..200be4a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -277,6 +277,14 @@ struct bpf_prog_aux;
 		.off   = 0,					\
 		.imm   = 0 })
 
+/* Internal classic blocks for direct assignment */
+
+#define __BPF_STMT(CODE, K)					\
+	((struct sock_filter) BPF_STMT(CODE, K))
+
+#define __BPF_JUMP(CODE, K, JT, JF)				\
+	((struct sock_filter) BPF_JUMP(CODE, K, JT, JF))
+
 #define bytes_to_bpf_size(bytes)				\
 ({								\
 	int bpf_size = -EINVAL;					\
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 8bca780..66358b2 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -21,6 +21,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
+#include <linux/random.h>
 
 /* General test specific settings */
 #define MAX_SUBTESTS	3
@@ -67,6 +68,10 @@ struct bpf_test {
 	union {
 		struct sock_filter insns[MAX_INSNS];
 		struct bpf_insn insns_int[MAX_INSNS];
+		struct {
+			void *insns;
+			unsigned int len;
+		} ptr;
 	} u;
 	__u8 aux;
 	__u8 data[MAX_DATA];
@@ -74,8 +79,190 @@ struct bpf_test {
 		int data_size;
 		__u32 result;
 	} test[MAX_SUBTESTS];
+	int (*fill_helper)(struct bpf_test *self);
 };
 
+/* Large test cases need separate allocation and fill handler. */
+
+static int bpf_fill_maxinsns1(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	__u32 k = ~0;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	for (i = 0; i < len; i++, k--)
+		insn[i] = __BPF_STMT(BPF_RET | BPF_K, k);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns2(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	for (i = 0; i < len; i++)
+		insn[i] = __BPF_STMT(BPF_RET | BPF_K, 0xfefefefe);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns3(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	struct rnd_state rnd;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	prandom_seed_state(&rnd, 3141592653589793238ULL);
+
+	for (i = 0; i < len - 1; i++) {
+		__u32 k = prandom_u32_state(&rnd);
+
+		insn[i] = __BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, k);
+	}
+
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_A, 0);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns4(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS + 1;
+	struct sock_filter *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	for (i = 0; i < len; i++)
+		insn[i] = __BPF_STMT(BPF_RET | BPF_K, 0xfefefefe);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns5(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	insn[0] = __BPF_JUMP(BPF_JMP | BPF_JA, len - 2, 0, 0);
+
+	for (i = 1; i < len - 1; i++)
+		insn[i] = __BPF_STMT(BPF_RET | BPF_K, 0xfefefefe);
+
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_K, 0xabababab);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns6(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	for (i = 0; i < len - 1; i++)
+		insn[i] = __BPF_STMT(BPF_LD | BPF_W | BPF_ABS, SKF_AD_OFF +
+				     SKF_AD_VLAN_TAG_PRESENT);
+
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_A, 0);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns7(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	for (i = 0; i < len - 4; i++)
+		insn[i] = __BPF_STMT(BPF_LD | BPF_W | BPF_ABS, SKF_AD_OFF +
+				     SKF_AD_CPU);
+
+	insn[len - 4] = __BPF_STMT(BPF_MISC | BPF_TAX, 0);
+	insn[len - 3] = __BPF_STMT(BPF_LD | BPF_W | BPF_ABS, SKF_AD_OFF +
+				   SKF_AD_CPU);
+	insn[len - 2] = __BPF_STMT(BPF_ALU | BPF_SUB | BPF_X, 0);
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_A, 0);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns8(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	int i, jmp_off = len - 3;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	insn[0] = __BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff);
+
+	for (i = 1; i < len - 1; i++)
+		insn[i] = __BPF_JUMP(BPF_JMP | BPF_JGT, 0xffffffff, jmp_off--, 0);
+
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_A, 0);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
 static struct bpf_test tests[] = {
 	{
 		"TAX",
@@ -3998,6 +4185,73 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 1 } },
 	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Maximum possible literals",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xffffffff } },
+		.fill_helper = bpf_fill_maxinsns1,
+	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Single literal",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xfefefefe } },
+		.fill_helper = bpf_fill_maxinsns2,
+	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Run/add until end",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0x947bf368 } },
+		.fill_helper = bpf_fill_maxinsns3,
+	},
+	{
+		"BPF_MAXINSNS: Too many instructions",
+		{ },
+		CLASSIC | FLAG_NO_DATA | FLAG_EXPECTED_FAIL,
+		{ },
+		{ },
+		.fill_helper = bpf_fill_maxinsns4,
+	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Very long jump",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xabababab } },
+		.fill_helper = bpf_fill_maxinsns5,
+	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Ctx heavy transformations",
+		{ },
+		CLASSIC,
+		{ },
+		{
+			{  1, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) },
+			{ 10, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) }
+		},
+		.fill_helper = bpf_fill_maxinsns6,
+	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Call heavy transformations",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 1, 0 }, { 10, 0 } },
+		.fill_helper = bpf_fill_maxinsns7,
+	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Jump heavy test",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xffffffff } },
+		.fill_helper = bpf_fill_maxinsns8,
+	},
 };
 
 static struct net_device dev;
@@ -4051,10 +4305,15 @@ static void release_test_data(const struct bpf_test *test, void *data)
 	kfree_skb(data);
 }
 
-static int probe_filter_length(struct sock_filter *fp)
+static int filter_length(int which)
 {
-	int len = 0;
+	struct sock_filter *fp;
+	int len;
 
+	if (tests[which].fill_helper)
+		return tests[which].u.ptr.len;
+
+	fp = tests[which].u.insns;
 	for (len = MAX_INSNS - 1; len > 0; --len)
 		if (fp[len].code != 0 || fp[len].k != 0)
 			break;
@@ -4062,16 +4321,25 @@ static int probe_filter_length(struct sock_filter *fp)
 	return len + 1;
 }
 
+static void *filter_pointer(int which)
+{
+	if (tests[which].fill_helper)
+		return tests[which].u.ptr.insns;
+	else
+		return tests[which].u.insns;
+}
+
 static struct bpf_prog *generate_filter(int which, int *err)
 {
-	struct bpf_prog *fp;
-	struct sock_fprog_kern fprog;
-	unsigned int flen = probe_filter_length(tests[which].u.insns);
 	__u8 test_type = tests[which].aux & TEST_TYPE_MASK;
+	unsigned int flen = filter_length(which);
+	void *fptr = filter_pointer(which);
+	struct sock_fprog_kern fprog;
+	struct bpf_prog *fp;
 
 	switch (test_type) {
 	case CLASSIC:
-		fprog.filter = tests[which].u.insns;
+		fprog.filter = fptr;
 		fprog.len = flen;
 
 		*err = bpf_prog_create(&fp, &fprog);
@@ -4107,8 +4375,7 @@ static struct bpf_prog *generate_filter(int which, int *err)
 		}
 
 		fp->len = flen;
-		memcpy(fp->insnsi, tests[which].u.insns_int,
-		       fp->len * sizeof(struct bpf_insn));
+		memcpy(fp->insnsi, fptr, fp->len * sizeof(struct bpf_insn));
 
 		bpf_prog_select_runtime(fp);
 		break;
@@ -4180,6 +4447,29 @@ static int run_one(const struct bpf_prog *fp, struct bpf_test *test)
 	return err_cnt;
 }
 
+static __init int prepare_bpf_tests(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(tests); i++) {
+		if (tests[i].fill_helper &&
+		    tests[i].fill_helper(&tests[i]) < 0)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static __init void destroy_bpf_tests(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(tests); i++) {
+		if (tests[i].fill_helper)
+			kfree(tests[i].u.ptr.insns);
+	}
+}
+
 static __init int test_bpf(void)
 {
 	int i, err_cnt = 0, pass_cnt = 0;
@@ -4227,7 +4517,16 @@ static __init int test_bpf(void)
 
 static int __init test_bpf_init(void)
 {
-	return test_bpf();
+	int ret;
+
+	ret = prepare_bpf_tests();
+	if (ret < 0)
+		return ret;
+
+	ret = test_bpf();
+
+	destroy_bpf_tests();
+	return ret;
 }
 
 static void __exit test_bpf_exit(void)
-- 
1.9.3
