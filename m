From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] act_bpf: allow non-default TC_ACT opcodes as BPF exec outcome
Date: Tue, 17 Mar 2015 20:25:57 +0100
Message-ID: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49853 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbbCQT0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 15:26:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revisiting commit d23b8ad8ab23 ("tc: add BPF based action") with regards
to eBPF support, I was thinking that it might be better to improve
return semantics from a BPF program invoked through BPF_PROG_RUN().

Currently, in case filter_res is 0, we overwrite the default action
opcode with TC_ACT_SHOT. A default action opcode configured through tc's
m_bpf can be: TC_ACT_RECLASSIFY, TC_ACT_PIPE, TC_ACT_SHOT, TC_ACT_UNSPEC,
TC_ACT_OK.

In cls_bpf, we have the possibility to overwrite the default class
associated with the classifier in case filter_res is _not_ 0xffffffff
(-1).

That allows us to fold multiple [e]BPF programs into a single one, where
they would otherwise need to be defined as a separate classifier with
its own classid, needlessly redoing parsing work, etc.

Similarly, we could do better in act_bpf: Since above TC_ACT* opcodes
are exported to UAPI anyway, we reuse them for return-code-to-tc-opcode
mapping, where we would allow above possibilities. Thus, like in cls_bpf,
a filter_res of 0xffffffff (-1) means that the configured _default_ action
is used. Any unkown return code from the BPF program would fail in
tcf_bpf() with TC_ACT_UNSPEC.

Should we one day want to make use of TC_ACT_STOLEN or TC_ACT_QUEUED,
which both have the same semantics, we have the option to either use
that as a default action (filter_res of 0xffffffff) or non-default BPF
return code.

All that will allow us to transparently use tcf_bpf() for both BPF
flavours.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 Note, act_bpf has not been officially released with 4.0, so we can
 still address it.

 net/sched/act_bpf.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 82c5d7f..5f6288f 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -25,21 +25,41 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
 	struct tcf_bpf *b = a->priv;
-	int action;
-	int filter_res;
+	int action, filter_res;
 
 	spin_lock(&b->tcf_lock);
+
 	b->tcf_tm.lastuse = jiffies;
 	bstats_update(&b->tcf_bstats, skb);
-	action = b->tcf_action;
 
 	filter_res = BPF_PROG_RUN(b->filter, skb);
-	if (filter_res == 0) {
-		/* Return code 0 from the BPF program
-		 * is being interpreted as a drop here.
-		 */
-		action = TC_ACT_SHOT;
+
+	/* A BPF program may overwrite the default action opcode.
+	 * Similarly as in cls_bpf, if filter_res == -1 we use the
+	 * default action specified from tc.
+	 *
+	 * In case a different well-known TC_ACT opcode has been
+	 * returned, it will overwrite the default one.
+	 *
+	 * For everything else that is unkown, TC_ACT_UNSPEC is
+	 * returned.
+	 */
+	switch (filter_res) {
+	case TC_ACT_PIPE:
+	case TC_ACT_RECLASSIFY:
+	case TC_ACT_OK:
+		action = filter_res;
+		break;
+	case TC_ACT_SHOT:
+		action = filter_res;
 		b->tcf_qstats.drops++;
+		break;
+	case TC_ACT_UNSPEC:
+		action = b->tcf_action;
+		break;
+	default:
+		action = TC_ACT_UNSPEC;
+		break;
 	}
 
 	spin_unlock(&b->tcf_lock);
-- 
1.9.3
