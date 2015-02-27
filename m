From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 06/10] ebpf: add sched_cls_type and map it to sk_filter's verifier ops
Date: Fri, 27 Feb 2015 15:55:38 +0100
Message-ID: <a12f2d74173bcc0ee9aafb5160fab39ad0b1b4c5.1425040940.git.daniel@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47845 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbbB0Ozv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 09:55:51 -0500
In-Reply-To: <cover.1425040939.git.daniel@iogearbox.net>
In-Reply-To: <cover.1425040939.git.daniel@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As discussed recently and at netconf/netdev01, we want to prevent making
bpf_verifier_ops registration available for modules, but have them at a
controlled place inside the kernel instead.

The reason for this is, that out-of-tree modules can go crazy and define
and register any verfifier ops they want, doing all sorts of crap, even
bypassing available GPLed eBPF helper functions. We don't want to offer
such a shiny playground, of course, but keep strict control to ourselves
inside the core kernel.

This also encourages us to design eBPF user helpers carefully and
generically, so they can be shared among various subsystems using eBPF.

For the eBPF traffic classifier (cls_bpf), it's a good start to share
the same helper facilities as we currently do in eBPF for socket filters.

That way, we have BPF_PROG_TYPE_SCHED_CLS look like it's own type, thus
one day if there's a good reason to diverge the set of helper functions
from the set available to socket filters, we keep ABI compatibility.

In future, we could place all bpf_prog_type_list at a central place,
perhaps.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |  1 +
 kernel/bpf/verifier.c    | 15 +++++++++++++--
 net/core/filter.c        |  7 +++++++
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0248180..3fa1af8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -118,6 +118,7 @@ enum bpf_map_type {
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
+	BPF_PROG_TYPE_SCHED_CLS,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a28e09c..594d341 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1172,6 +1172,17 @@ static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
+static bool may_access_skb(enum bpf_prog_type type)
+{
+	switch (type) {
+	case BPF_PROG_TYPE_SOCKET_FILTER:
+	case BPF_PROG_TYPE_SCHED_CLS:
+		return true;
+	default:
+		return false;
+	}
+}
+
 /* verify safety of LD_ABS|LD_IND instructions:
  * - they can only appear in the programs where ctx == skb
  * - since they are wrappers of function calls, they scratch R1-R5 registers,
@@ -1194,8 +1205,8 @@ static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
 	struct reg_state *reg;
 	int i, err;
 
-	if (env->prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
-		verbose("BPF_LD_ABS|IND instructions are only allowed in socket filters\n");
+	if (!may_access_skb(env->prog->aux->prog_type)) {
+		verbose("BPF_LD_ABS|IND instructions not allowed for this program type\n");
 		return -EINVAL;
 	}
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 7417212..514d408 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1166,9 +1166,16 @@ static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.type = BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
+static struct bpf_prog_type_list sched_cls_type __read_mostly = {
+	.ops = &sk_filter_ops,
+	.type = BPF_PROG_TYPE_SCHED_CLS,
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
+	bpf_register_prog_type(&sched_cls_type);
+
 	return 0;
 }
 late_initcall(register_sk_filter_ops);
-- 
1.9.3
