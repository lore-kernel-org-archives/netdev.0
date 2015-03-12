From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] cls_bpf: do eBPF invocation under non-bh RCU lock variant for maps
Date: Thu, 12 Mar 2015 20:03:12 +0100
Message-ID: <91a3d08794f55f1f7a86a45f5d00ee72c8106061.1426185074.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39852 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbbCLTDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 15:03:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, it is possible in cls_bpf to access eBPF maps only under
rcu_read_lock_bh() variants: while on ingress side, that is, handle_ing(),
the classifier would be called from __netif_receive_skb_core() under
rcu_read_lock(); on egress side, however, it's rcu_read_lock_bh() via
__dev_queue_xmit().

This rcu/rcu_bh mix doesn't work together with eBPF maps as they require
soley to be called under rcu_read_lock(). eBPF maps could also be shared
among various other eBPF programs (possibly even with other eBPF program
types, f.e. tracing) and user space processes, so any context is assumed.

Therefore, a possible fix for cls_bpf is to wrap/nest eBPF program
invocation under non-bh RCU lock variant.

Fixes: e2e9b6541dd4 ("cls_bpf: add initial eBPF support for programmable classifiers")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_bpf.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 243c9f2..5c4171c 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -64,8 +64,10 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 {
 	struct cls_bpf_head *head = rcu_dereference_bh(tp->root);
 	struct cls_bpf_prog *prog;
-	int ret;
+	int ret = -1;
 
+	/* Needed here for accessing maps. */
+	rcu_read_lock();
 	list_for_each_entry_rcu(prog, &head->plist, link) {
 		int filter_res = BPF_PROG_RUN(prog->filter, skb);
 
@@ -80,10 +82,11 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		if (ret < 0)
 			continue;
 
-		return ret;
+		break;
 	}
+	rcu_read_unlock();
 
-	return -1;
+	return ret;
 }
 
 static bool cls_bpf_is_ebpf(const struct cls_bpf_prog *prog)
-- 
1.9.3
