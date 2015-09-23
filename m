From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] cls_bpf: make binding to classid optional
Date: Wed, 23 Sep 2015 21:56:47 +0200
Message-ID: <564eafb6e648e41ad57f5d36139d667745478366.1443037353.git.daniel@iogearbox.net>
References: <cover.1443037353.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36059 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbbIWT46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 15:56:58 -0400
In-Reply-To: <cover.1443037353.git.daniel@iogearbox.net>
In-Reply-To: <cover.1443037353.git.daniel@iogearbox.net>
References: <cover.1443037353.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The binding to a particular classid was so far always mandatory for
cls_bpf, but it doesn't need to be. Therefore, lift this restriction
as similarly done in other classifiers.

Only a couple of qdiscs make use of class from the tcf_result, others
don't strictly care, so let the user choose his needs (those that read
out class can handle situations where it could be NULL).

An explicit check for tcf_unbind_filter() is also not needed here, as
the previous r->class was 0, so the xchg() will return that and
therefore a callback to the qdisc's unbind_tcf() is skipped.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_bpf.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 7d92415..d6c0a0b 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -307,14 +307,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 {
 	bool is_bpf, is_ebpf, have_exts = false;
 	struct tcf_exts exts;
-	u32 classid;
 	int ret;
 
 	is_bpf = tb[TCA_BPF_OPS_LEN] && tb[TCA_BPF_OPS];
 	is_ebpf = tb[TCA_BPF_FD];
-
-	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf) ||
-	    !tb[TCA_BPF_CLASSID])
+	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf))
 		return -EINVAL;
 
 	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
@@ -322,7 +319,6 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	if (ret < 0)
 		return ret;
 
-	classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
 	if (tb[TCA_BPF_FLAGS]) {
 		u32 bpf_flags = nla_get_u32(tb[TCA_BPF_FLAGS]);
 
@@ -334,7 +330,6 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
 	}
 
-	prog->res.classid = classid;
 	prog->exts_integrated = have_exts;
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
@@ -344,9 +339,12 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 		return ret;
 	}
 
-	tcf_bind_filter(tp, &prog->res, base);
-	tcf_exts_change(tp, &prog->exts, &exts);
+	if (tb[TCA_BPF_CLASSID]) {
+		prog->res.classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
+		tcf_bind_filter(tp, &prog->res, base);
+	}
 
+	tcf_exts_change(tp, &prog->exts, &exts);
 	return 0;
 }
 
@@ -479,7 +477,8 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (nla_put_u32(skb, TCA_BPF_CLASSID, prog->res.classid))
+	if (prog->res.classid &&
+	    nla_put_u32(skb, TCA_BPF_CLASSID, prog->res.classid))
 		goto nla_put_failure;
 
 	if (cls_bpf_is_ebpf(prog))
-- 
1.9.3
