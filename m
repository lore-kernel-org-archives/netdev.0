From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 6/6] net/sched: cls_bpf: Reflect HW offload status
Date: Tue, 14 Feb 2017 16:30:40 +0200
Message-ID: <1487082640-24813-7-git-send-email-ogerlitz@mellanox.com>
References: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54487 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754064AbdBNOay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 09:30:54 -0500
In-Reply-To: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF classifier support for the "in hw" offloading flags.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
---
 net/sched/cls_bpf.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index d9c9701..61a5b33 100644
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
 
+	if (!(tc_in_hw(prog->gen_flags)))
+		prog->gen_flags |= TCA_CLS_FLAGS_NOT_IN_HW;
+
 	if (oldprog) {
 		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
-- 
2.3.7
