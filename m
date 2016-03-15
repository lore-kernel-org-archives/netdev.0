From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] cls_bpf: reset class and reuse major in da
Date: Tue, 15 Mar 2016 22:41:22 +0100
Message-ID: <9e700a6f163815e6f79db50e7a8f9f52696f28e7.1458075641.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51113 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427AbcCOVl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 17:41:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two issues with the current code. First one is that we need
to set res->class to 0 in case we use non-default classid matching.

This is important for the case where cls_bpf was initially set up with
an optional binding to a default class with tcf_bind_filter(), where
the underlying qdisc implements bind_tcf() that fills res->class and
tests for it later on when doing the classification. Convention for
these cases is that after tc_classify() was called, such qdiscs (atm,
drr, qfq, cbq, hfsc, htb) first test class, and if 0, then they lookup
based on classid.

Second, there's a bug with da mode, where res->classid is only assigned
a 16 bit minor, but it needs to expand to the full 32 bit major/minor
combination instead, therefore we need to expand with the bound major.
This is fine as classes belonging to a classful qdisc must share the
same major.

Fixes: 045efa82ff56 ("cls_bpf: introduce integrated actions")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/sched/cls_bpf.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 8dc8430..425fe6a 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -103,8 +103,9 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		}
 
 		if (prog->exts_integrated) {
-			res->class = prog->res.class;
-			res->classid = qdisc_skb_cb(skb)->tc_classid;
+			res->class   = 0;
+			res->classid = TC_H_MAJ(prog->res.classid) |
+				       qdisc_skb_cb(skb)->tc_classid;
 
 			ret = cls_bpf_exec_opcode(filter_res);
 			if (ret == TC_ACT_UNSPEC)
@@ -114,10 +115,12 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 		if (filter_res == 0)
 			continue;
-
-		*res = prog->res;
-		if (filter_res != -1)
+		if (filter_res != -1) {
+			res->class   = 0;
 			res->classid = filter_res;
+		} else {
+			*res = prog->res;
+		}
 
 		ret = tcf_exts_exec(skb, &prog->exts, res);
 		if (ret < 0)
-- 
1.9.3
