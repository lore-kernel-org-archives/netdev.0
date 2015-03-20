From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] ebpf: add sched_act_type and map it to sk_filter's verifier ops
Date: Fri, 20 Mar 2015 15:11:11 +0100
Message-ID: <3f1f15c00b7dd9899035696eef924b23a008afc2.1426859241.git.daniel@iogearbox.net>
References: <cover.1426859241.git.daniel@iogearbox.net>
Cc: jiri@resnulli.us, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55555 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbbCTOLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 10:11:22 -0400
In-Reply-To: <cover.1426859241.git.daniel@iogearbox.net>
In-Reply-To: <cover.1426859241.git.daniel@iogearbox.net>
References: <cover.1426859241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to prepare eBPF support for tc action, we need to add
sched_act_type, so that the eBPF verifier is aware of what helper
function act_bpf may use, that it can load skb data and read out
currently available skb fields.

This is bascially analogous to 96be4325f443 ("ebpf: add sched_cls_type
and map it to sk_filter's verifier ops").

BPF_PROG_TYPE_SCHED_CLS and BPF_PROG_TYPE_SCHED_ACT need to be
separate since both will have a different set of functionality in
future (classifier vs action), thus we won't run into ABI troubles
when the point in time comes to diverge functionality from the
classifier.

The future plan for act_bpf would be that it will be able to write
into skb->data and alter selected fields mirrored in struct __sk_buff.

For an initial support, it's sufficient to map it to sk_filter_ops.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/bpf.h | 1 +
 kernel/bpf/verifier.c    | 1 +
 net/core/filter.c        | 6 ++++++
 3 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1623047..3dd314a 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -119,6 +119,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
 	BPF_PROG_TYPE_SCHED_CLS,
+	BPF_PROG_TYPE_SCHED_ACT,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c22ebd3..0e714f7 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1180,6 +1180,7 @@ static bool may_access_skb(enum bpf_prog_type type)
 	switch (type) {
 	case BPF_PROG_TYPE_SOCKET_FILTER:
 	case BPF_PROG_TYPE_SCHED_CLS:
+	case BPF_PROG_TYPE_SCHED_ACT:
 		return true;
 	default:
 		return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index b95ae7f..3bc6482 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1264,10 +1264,16 @@ static struct bpf_prog_type_list sched_cls_type __read_mostly = {
 	.type = BPF_PROG_TYPE_SCHED_CLS,
 };
 
+static struct bpf_prog_type_list sched_act_type __read_mostly = {
+	.ops = &sk_filter_ops,
+	.type = BPF_PROG_TYPE_SCHED_ACT,
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
 	bpf_register_prog_type(&sched_cls_type);
+	bpf_register_prog_type(&sched_act_type);
 
 	return 0;
 }
-- 
1.9.3
