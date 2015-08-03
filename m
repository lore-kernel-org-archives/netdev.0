From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] act_bpf: properly support late binding of bpf action to a classifier
Date: Mon,  3 Aug 2015 16:21:57 +0200
Message-ID: <8e2446e087041587d665a8ca2d105f164a8e0794.1438610179.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45503 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbbHCOWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 10:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the introduction of the BPF action in d23b8ad8ab23 ("tc: add BPF
based action"), late binding was not working as expected. I.e. setting
the action part for a classifier only via 'bpf index <num>', where <num>
is the index of an existing action, is being rejected by the kernel due
to other missing parameters.

It doesn't make sense to require these parameters such as BPF opcodes
etc, as they are not going to be used anyway: in this case, they're just
allocated/parsed and then freed again w/o doing anything meaningful.

Instead, parse and verify the remaining parameters *after* the test on
tcf_hash_check(), when we really know that we're dealing with creation
of a new action or replacement of an existing one and where late binding
is thus irrelevant.

After patch, test case is now working:

  FOO="1,6 0 0 4294967295,"
  tc actions add action bpf bytecode "$FOO"
  tc filter add dev foo parent 1: bpf bytecode "$FOO" flowid 1:1 action bpf index 1
  tc actions show action bpf
    action order 0: bpf bytecode '1,6 0 0 4294967295' default-action pipe
    index 1 ref 2 bind 1
  tc filter show dev foo
    filter protocol all pref 49152 bpf
    filter protocol all pref 49152 bpf handle 0x1 flowid 1:1 bytecode '1,6 0 0 4294967295'
    action order 1: bpf bytecode '1,6 0 0 4294967295' default-action pipe
    index 1 ref 2 bind 1

Late binding of a BPF action can be useful for preloading maps (e.g. before
they hit traffic) in case of eBPF programs, or to share a single eBPF action
with multiple classifiers.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 This one was still in my queue of fixes, net-next is totally fine here.
 Will push out minor iproute2 change afterwards.

 net/sched/act_bpf.c | 51 +++++++++++++++++++++++++++------------------------
 1 file changed, 27 insertions(+), 24 deletions(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index aaae8e8..1b97dab 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -278,7 +278,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	struct tc_act_bpf *parm;
 	struct tcf_bpf *prog;
 	bool is_bpf, is_ebpf;
-	int ret;
+	int ret, res = 0;
 
 	if (!nla)
 		return -EINVAL;
@@ -287,41 +287,43 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	if (ret < 0)
 		return ret;
 
-	is_bpf = tb[TCA_ACT_BPF_OPS_LEN] && tb[TCA_ACT_BPF_OPS];
-	is_ebpf = tb[TCA_ACT_BPF_FD];
-
-	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf) ||
-	    !tb[TCA_ACT_BPF_PARMS])
+	if (!tb[TCA_ACT_BPF_PARMS])
 		return -EINVAL;
 
 	parm = nla_data(tb[TCA_ACT_BPF_PARMS]);
 
-	memset(&cfg, 0, sizeof(cfg));
-
-	ret = is_bpf ? tcf_bpf_init_from_ops(tb, &cfg) :
-		       tcf_bpf_init_from_efd(tb, &cfg);
-	if (ret < 0)
-		return ret;
-
 	if (!tcf_hash_check(parm->index, act, bind)) {
 		ret = tcf_hash_create(parm->index, est, act,
 				      sizeof(*prog), bind, false);
 		if (ret < 0)
-			goto destroy_fp;
+			return ret;
 
-		ret = ACT_P_CREATED;
+		res = ACT_P_CREATED;
 	} else {
 		/* Don't override defaults. */
 		if (bind)
-			goto destroy_fp;
+			return 0;
 
 		tcf_hash_release(act, bind);
-		if (!replace) {
-			ret = -EEXIST;
-			goto destroy_fp;
-		}
+		if (!replace)
+			return -EEXIST;
 	}
 
+	is_bpf = tb[TCA_ACT_BPF_OPS_LEN] && tb[TCA_ACT_BPF_OPS];
+	is_ebpf = tb[TCA_ACT_BPF_FD];
+
+	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	memset(&cfg, 0, sizeof(cfg));
+
+	ret = is_bpf ? tcf_bpf_init_from_ops(tb, &cfg) :
+		       tcf_bpf_init_from_efd(tb, &cfg);
+	if (ret < 0)
+		goto out;
+
 	prog = to_bpf(act);
 	spin_lock_bh(&prog->tcf_lock);
 
@@ -341,15 +343,16 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	spin_unlock_bh(&prog->tcf_lock);
 
-	if (ret == ACT_P_CREATED)
+	if (res == ACT_P_CREATED)
 		tcf_hash_insert(act);
 	else
 		tcf_bpf_cfg_cleanup(&old);
 
-	return ret;
+	return res;
+out:
+	if (res == ACT_P_CREATED)
+		tcf_hash_cleanup(act, est);
 
-destroy_fp:
-	tcf_bpf_cfg_cleanup(&cfg);
 	return ret;
 }
 
-- 
1.9.3
