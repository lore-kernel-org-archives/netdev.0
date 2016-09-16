From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv5 net-next 10/15] net: cls_bpf: allow offloaded filters to update stats
Date: Fri, 16 Sep 2016 10:36:57 +0100
Message-ID: <1474018622-10653-11-git-send-email-jakub.kicinski@netronome.com>
References: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38395 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756672AbcIPJhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:37:48 -0400
Received: by mail-wm0-f54.google.com with SMTP id 1so30506701wmz.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 02:37:47 -0700 (PDT)
In-Reply-To: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call into offloaded filters to update stats.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
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
index 18f9869cd4da..9b29e0673346 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -220,6 +220,15 @@ static void cls_bpf_stop_offload(struct tcf_proto *tp,
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
@@ -575,6 +584,8 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	tm->tcm_handle = prog->handle;
 
+	cls_bpf_offload_update_stats(tp, prog);
+
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-- 
1.9.1
