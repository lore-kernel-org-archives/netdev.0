From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V4 7/7] net/sched: cls_bpf: Reflect HW offload status
Date: Thu, 16 Feb 2017 10:31:16 +0200
Message-ID: <1487233876-28576-8-git-send-email-ogerlitz@mellanox.com>
References: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Roi Dayan <roid@mellanox.com>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45008 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753062AbdBPIbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 03:31:38 -0500
In-Reply-To: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF classifier support for the "in hw" offloading flags.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/sched/cls_bpf.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index d9c9701..80f6884 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -148,6 +148,7 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_bpf_offload bpf_offload = {};
 	struct tc_to_netdev offload;
+	int err;
 
 	offload.type = TC_SETUP_CLSBPF;
 	offload.cls_bpf = &bpf_offload;
@@ -159,8 +160,13 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	bpf_offload.exts_integrated = prog->exts_integrated;
 	bpf_offload.gen_flags = prog->gen_flags;
 
-	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					     tp->protocol, &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					    tp->protocol, &offload);
+
+	if (!err && (cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE))
+		prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
+
+	return err;
 }
 
 static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
@@ -511,6 +517,9 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		return ret;
 	}
 
+	if (!tc_in_hw(prog->gen_flags))
+		prog->gen_flags |= TCA_CLS_FLAGS_NOT_IN_HW;
+
 	if (oldprog) {
 		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
-- 
2.5.5
