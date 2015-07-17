From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/2] test_bpf: add bpf_skb_vlan_push/pop() tests
Date: Thu, 16 Jul 2015 19:58:04 -0700
Message-ID: <1437101884-2081-3-git-send-email-ast@plumgrid.com>
References: <1437101884-2081-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36748 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbbGQC6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 22:58:12 -0400
Received: by pdjr16 with SMTP id r16so54588945pdj.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 19:58:11 -0700 (PDT)
In-Reply-To: <1437101884-2081-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

improve accuracy of timing in test_bpf and add two stress tests:
- {skb->data[0], get_smp_processor_id} repeated 2k times
- {skb->data[0], vlan_push} x 68 followed by {skb->data[0], vlan_pop} x 68

1st test is useful to test performance of JIT implementation of BPF_LD_ABS
together with BPF_CALL instructions.
2nd test is stressing skb_vlan_push/pop logic together with skb->data access
via BPF_LD_ABS insn which checks that re-caching of skb->data is done correctly.

In order to call bpf_skb_vlan_push() from test_bpf.ko have to add
three export_symbol_gpl.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/core.c |    1 +
 lib/test_bpf.c    |   98 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 net/core/filter.c |    2 ++
 3 files changed, 98 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index bf38f5e8196c..fafa74161445 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -177,6 +177,7 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__bpf_call_base);
 
 /**
  *	__bpf_prog_run - run eBPF program on a given context
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 9198f28a5528..8b5e66f008b0 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -18,6 +18,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/filter.h>
+#include <linux/bpf.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
@@ -355,6 +356,81 @@ static int bpf_fill_ja(struct bpf_test *self)
 	return __bpf_fill_ja(self, 12, 9);
 }
 
+static int bpf_fill_ld_abs_get_processor_id(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct sock_filter *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	for (i = 0; i < len - 1; i += 2) {
+		insn[i] = __BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 0);
+		insn[i + 1] = __BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
+					 SKF_AD_OFF + SKF_AD_CPU);
+	}
+
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_K, 0xbee);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+#define PUSH_CNT 68
+/* test: {skb->data[0], vlan_push} x 68 + {skb->data[0], vlan_pop} x 68 */
+static int bpf_fill_ld_abs_vlan_push_pop(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct bpf_insn *insn;
+	int i = 0, j, k = 0;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	insn[i++] = BPF_MOV64_REG(R6, R1);
+loop:
+	for (j = 0; j < PUSH_CNT; j++) {
+		insn[i++] = BPF_LD_ABS(BPF_B, 0);
+		insn[i] = BPF_JMP_IMM(BPF_JNE, R0, 0x34, len - i - 2);
+		i++;
+		insn[i++] = BPF_MOV64_REG(R1, R6);
+		insn[i++] = BPF_MOV64_IMM(R2, 1);
+		insn[i++] = BPF_MOV64_IMM(R3, 2);
+		insn[i++] = BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+					 bpf_skb_vlan_push_proto.func - __bpf_call_base);
+		insn[i] = BPF_JMP_IMM(BPF_JNE, R0, 0, len - i - 2);
+		i++;
+	}
+
+	for (j = 0; j < PUSH_CNT; j++) {
+		insn[i++] = BPF_LD_ABS(BPF_B, 0);
+		insn[i] = BPF_JMP_IMM(BPF_JNE, R0, 0x34, len - i - 2);
+		i++;
+		insn[i++] = BPF_MOV64_REG(R1, R6);
+		insn[i++] = BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+					 bpf_skb_vlan_pop_proto.func - __bpf_call_base);
+		insn[i] = BPF_JMP_IMM(BPF_JNE, R0, 0, len - i - 2);
+		i++;
+	}
+	if (++k < 5)
+		goto loop;
+
+	for (; i < len - 1; i++)
+		insn[i] = BPF_ALU32_IMM(BPF_MOV, R0, 0xbef);
+
+	insn[len - 1] = BPF_EXIT_INSN();
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
@@ -4398,6 +4474,22 @@ static struct bpf_test tests[] = {
 		{ { 0, 0xababcbac } },
 		.fill_helper = bpf_fill_maxinsns11,
 	},
+	{
+		"BPF_MAXINSNS: ld_abs+get_processor_id",
+		{ },
+		CLASSIC,
+		{ },
+		{ { 1, 0xbee } },
+		.fill_helper = bpf_fill_ld_abs_get_processor_id,
+	},
+	{
+		"BPF_MAXINSNS: ld_abs+vlan_push/pop",
+		{ },
+		INTERNAL,
+		{ 0x34 },
+		{ { 1, 0xbef } },
+		.fill_helper = bpf_fill_ld_abs_vlan_push_pop,
+	},
 };
 
 static struct net_device dev;
@@ -4551,14 +4643,14 @@ static int __run_one(const struct bpf_prog *fp, const void *data,
 	u64 start, finish;
 	int ret = 0, i;
 
-	start = ktime_to_us(ktime_get());
+	start = ktime_get_ns();
 
 	for (i = 0; i < runs; i++)
 		ret = BPF_PROG_RUN(fp, data);
 
-	finish = ktime_to_us(ktime_get());
+	finish = ktime_get_ns();
 
-	*duration = (finish - start) * 1000ULL;
+	*duration = finish - start;
 	do_div(*duration, runs);
 
 	return ret;
diff --git a/net/core/filter.c b/net/core/filter.c
index 3683ab09a48a..d8eb7e811aa3 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1456,6 +1456,7 @@ const struct bpf_func_proto bpf_skb_vlan_push_proto = {
 	.arg2_type      = ARG_ANYTHING,
 	.arg3_type      = ARG_ANYTHING,
 };
+EXPORT_SYMBOL_GPL(bpf_skb_vlan_push_proto);
 
 static u64 bpf_skb_vlan_pop(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
@@ -1470,6 +1471,7 @@ const struct bpf_func_proto bpf_skb_vlan_pop_proto = {
 	.ret_type       = RET_INTEGER,
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
+EXPORT_SYMBOL_GPL(bpf_skb_vlan_pop_proto);
 
 bool bpf_helper_changes_skb_data(void *func)
 {
-- 
1.7.9.5
