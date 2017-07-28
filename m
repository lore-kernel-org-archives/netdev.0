From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/20] net: sched: cls_bpf: no need to call tcf_exts_change for newly allocated struct
Date: Fri, 28 Jul 2017 16:40:38 +0200
Message-ID: <20170728144042.6380-17-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36399 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752210AbdG1Olg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id 184so27681721wmo.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:36 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the prog struct was allocated right before cls_bpf_set_parms call,
no need to use tcf_exts_change to do atomic change, and we can just
fill-up the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_bpf.c | 25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 929cae9..d8bc3ec 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -387,7 +387,6 @@ static int cls_bpf_set_parms(struct net *net, struct tcf_proto *tp,
 			     struct nlattr **tb, struct nlattr *est, bool ovr)
 {
 	bool is_bpf, is_ebpf, have_exts = false;
-	struct tcf_exts exts;
 	u32 gen_flags = 0;
 	int ret;
 
@@ -396,28 +395,23 @@ static int cls_bpf_set_parms(struct net *net, struct tcf_proto *tp,
 	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf))
 		return -EINVAL;
 
-	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
-	ret = tcf_exts_validate(net, tp, tb, est, &exts, ovr);
+	ret = tcf_exts_validate(net, tp, tb, est, &prog->exts, ovr);
 	if (ret < 0)
-		goto errout;
+		return ret;
 
 	if (tb[TCA_BPF_FLAGS]) {
 		u32 bpf_flags = nla_get_u32(tb[TCA_BPF_FLAGS]);
 
-		if (bpf_flags & ~TCA_BPF_FLAG_ACT_DIRECT) {
-			ret = -EINVAL;
-			goto errout;
-		}
+		if (bpf_flags & ~TCA_BPF_FLAG_ACT_DIRECT)
+			return -EINVAL;
 
 		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
 	}
 	if (tb[TCA_BPF_FLAGS_GEN]) {
 		gen_flags = nla_get_u32(tb[TCA_BPF_FLAGS_GEN]);
 		if (gen_flags & ~CLS_BPF_SUPPORTED_GEN_FLAGS ||
-		    !tc_flags_valid(gen_flags)) {
-			ret = -EINVAL;
-			goto errout;
-		}
+		    !tc_flags_valid(gen_flags))
+			return -EINVAL;
 	}
 
 	prog->exts_integrated = have_exts;
@@ -426,19 +420,14 @@ static int cls_bpf_set_parms(struct net *net, struct tcf_proto *tp,
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
 		       cls_bpf_prog_from_efd(tb, prog, tp);
 	if (ret < 0)
-		goto errout;
+		return ret;
 
 	if (tb[TCA_BPF_CLASSID]) {
 		prog->res.classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
 		tcf_bind_filter(tp, &prog->res, base);
 	}
 
-	tcf_exts_change(&prog->exts, &exts);
 	return 0;
-
-errout:
-	tcf_exts_destroy(&exts);
-	return ret;
 }
 
 static u32 cls_bpf_grab_new_handle(struct tcf_proto *tp,
-- 
2.9.3
