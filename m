From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net-next 10/15] net: cls_bpf: allow offloaded filters to update stats
Date: Wed, 14 Sep 2016 20:00:18 +0100
Message-ID: <1473879623-15382-11-git-send-email-jakub.kicinski@netronome.com>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36757 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756110AbcINTAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 15:00:53 -0400
Received: by mail-wm0-f48.google.com with SMTP id b187so61689860wme.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 12:00:52 -0700 (PDT)
In-Reply-To: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call into offloaded filters to update stats.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/pkt_cls.h |  1 +
 net/sched/cls_bpf.c   | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 57af9f3032ff..5ccaa4be7d96 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -490,6 +490,7 @@ enum tc_clsbpf_command {
 	TC_CLSBPF_ADD,
 	TC_CLSBPF_REPLACE,
 	TC_CLSBPF_DESTROY,
+	TC_CLSBPF_STATS,
 };
 
 struct tc_cls_bpf_offload {
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1aad314089e9..86ef331f78e8 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -223,6 +223,15 @@ static void cls_bpf_stop_offload(struct tcf_proto *tp,
 	prog->offloaded = false;
 }
 
+static void cls_bpf_offload_update_stats(struct tcf_proto *tp,
+					 struct cls_bpf_prog *prog)
+{
+	if (!prog->offloaded)
+		return;
+
+	cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_STATS);
+}
+
 static int cls_bpf_init(struct tcf_proto *tp)
 {
 	struct cls_bpf_head *head;
@@ -578,6 +587,8 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	tm->tcm_handle = prog->handle;
 
+	cls_bpf_offload_update_stats(tp, prog);
+
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-- 
1.9.1
