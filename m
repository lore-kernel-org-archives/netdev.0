From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 1/2] net: cls_u32: fix missed pcpu_success
 free_percpu
Date: Fri, 19 Sep 2014 21:50:04 -0700
Message-ID: <20140920045003.9869.16851.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:59012 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbaITEuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 00:50:25 -0400
Received: by mail-ob0-f172.google.com with SMTP id uy5so2396327obc.3
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 21:50:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a missed free_percpu in the unwind code path and when
keys are destroyed.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 730edb2..8d90e50 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -363,6 +363,9 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 #ifdef CONFIG_CLS_U32_PERF
 	free_percpu(n->pf);
 #endif
+#ifdef CONFIG_CLS_U32_MARK
+	free_percpu(n->pcpu_success);
+#endif
 	kfree(n);
 	return 0;
 }
@@ -693,6 +696,10 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 #ifdef CONFIG_CLS_U32_MARK
 	n->pcpu_success = alloc_percpu(u32);
+	if (!n->pcpu_success) {
+		err = -ENOMEM;
+		goto errout;
+	}
 
 	if (tb[TCA_U32_MARK]) {
 		struct tc_u32_mark *mark;
@@ -720,6 +727,12 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		*arg = (unsigned long)n;
 		return 0;
 	}
+
+#ifdef CONFIG_CLS_U32_MARK
+	free_percpu(n->pcpu_success);
+#endif
+
+errout:
 #ifdef CONFIG_CLS_U32_PERF
 	free_percpu(n->pf);
 #endif
