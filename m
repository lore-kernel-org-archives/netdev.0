From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 08/12] net: cls_bpf: allow offloaded filters to update stats
Date: Wed,  1 Jun 2016 17:50:10 +0100
Message-ID: <1464799814-4453-9-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35267 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932550AbcFAQvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:52 -0400
Received: by mail-wm0-f41.google.com with SMTP id a136so191958459wme.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:51 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call into offloaded filters to update stats.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/pkt_cls.h |  1 +
 net/sched/cls_bpf.c   | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e6b3dfb3159b..7a7bae628d1a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -442,6 +442,7 @@ enum tc_clsbpf_command {
 	TC_CLSBPF_ADD,
 	TC_CLSBPF_REPLACE,
 	TC_CLSBPF_DESTROY,
+	TC_CLSBPF_STATS,
 };
 
 struct tc_cls_bpf_offload {
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1083910cebaf..66215d9d6c9c 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -224,6 +224,15 @@ static void cls_bpf_stop_offload(struct tcf_proto *tp,
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
@@ -574,6 +583,8 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	tm->tcm_handle = prog->handle;
 
+	cls_bpf_offload_update_stats(tp, prog);
+
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-- 
1.9.1
