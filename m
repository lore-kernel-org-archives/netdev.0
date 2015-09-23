From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] cls_bpf: also dump TCA_BPF_FLAGS
Date: Wed, 23 Sep 2015 21:56:46 +0200
Message-ID: <9e9ae1f3f6412f02ced924132ba5137425f3a699.1443037353.git.daniel@iogearbox.net>
References: <cover.1443037353.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36051 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbbIWT45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 15:56:57 -0400
In-Reply-To: <cover.1443037353.git.daniel@iogearbox.net>
In-Reply-To: <cover.1443037353.git.daniel@iogearbox.net>
References: <cover.1443037353.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 43388da42a49 ("cls_bpf: introduce integrated actions") we
have added TCA_BPF_FLAGS. We can also retrieve this information from
the prog, dump it back to user space as well. It's useful in tc when
displaying/dumping filter info.

Also, remove tp from cls_bpf_prog_from_efd(), came in as a conflict
from a rebase and it's unused here (later work may add it along with
a real user).

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_bpf.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 0590816..7d92415 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -265,8 +265,7 @@ static int cls_bpf_prog_from_ops(struct nlattr **tb, struct cls_bpf_prog *prog)
 	return 0;
 }
 
-static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
-				 const struct tcf_proto *tp)
+static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog)
 {
 	struct bpf_prog *fp;
 	char *name = NULL;
@@ -339,7 +338,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	prog->exts_integrated = have_exts;
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
-		       cls_bpf_prog_from_efd(tb, prog, tp);
+		       cls_bpf_prog_from_efd(tb, prog);
 	if (ret < 0) {
 		tcf_exts_destroy(&exts);
 		return ret;
@@ -468,6 +467,7 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 {
 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) fh;
 	struct nlattr *nest;
+	u32 bpf_flags = 0;
 	int ret;
 
 	if (prog == NULL)
@@ -492,6 +492,11 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	if (tcf_exts_dump(skb, &prog->exts) < 0)
 		goto nla_put_failure;
 
+	if (prog->exts_integrated)
+		bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
+	if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
+		goto nla_put_failure;
+
 	nla_nest_end(skb, nest);
 
 	if (tcf_exts_dump_stats(skb, &prog->exts) < 0)
-- 
1.9.3
