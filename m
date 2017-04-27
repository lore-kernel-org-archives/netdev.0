From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/10] net: sched: push chain dump to a separate function
Date: Thu, 27 Apr 2017 13:12:17 +0200
Message-ID: <1493291540-2119-8-git-send-email-jiri@resnulli.us>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, mlxsw@mellanox.com,
        simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36657 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936152AbdD0LMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:12:34 -0400
Received: by mail-wm0-f65.google.com with SMTP id u65so3797602wmu.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:12:33 -0700 (PDT)
In-Reply-To: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since there will be multiple chains to dump, push chain dumping code to
a separate function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 95 +++++++++++++++++++++++++++++------------------------
 1 file changed, 52 insertions(+), 43 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6f2ea68..9f48061 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -634,21 +634,65 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 			     RTM_NEWTFILTER);
 }
 
+static void tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
+			   struct netlink_callback *cb,
+			   long index_start, long *p_index)
+{
+	struct net *net = sock_net(skb->sk);
+	struct tcmsg *tcm = nlmsg_data(cb->nlh);
+	struct tcf_dump_args arg;
+	struct tcf_proto *tp;
+
+	for (tp = rtnl_dereference(chain->filter_chain);
+	     tp; tp = rtnl_dereference(tp->next), (*p_index)++) {
+		if (*p_index < index_start)
+			continue;
+		if (TC_H_MAJ(tcm->tcm_info) &&
+		    TC_H_MAJ(tcm->tcm_info) != tp->prio)
+			continue;
+		if (TC_H_MIN(tcm->tcm_info) &&
+		    TC_H_MIN(tcm->tcm_info) != tp->protocol)
+			continue;
+		if (*p_index > index_start)
+			memset(&cb->args[1], 0,
+			       sizeof(cb->args) - sizeof(cb->args[0]));
+		if (cb->args[1] == 0) {
+			if (tcf_fill_node(net, skb, tp, 0,
+					  NETLINK_CB(cb->skb).portid,
+					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					  RTM_NEWTFILTER) <= 0)
+				break;
+
+			cb->args[1] = 1;
+		}
+		if (!tp->ops->walk)
+			continue;
+		arg.w.fn = tcf_node_dump;
+		arg.skb = skb;
+		arg.cb = cb;
+		arg.w.stop = 0;
+		arg.w.skip = cb->args[1] - 1;
+		arg.w.count = 0;
+		tp->ops->walk(tp, &arg.w);
+		cb->args[1] = arg.w.count + 1;
+		if (arg.w.stop)
+			break;
+	}
+}
+
 /* called with RTNL */
 static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	int t;
-	int s_t;
 	struct net_device *dev;
 	struct Qdisc *q;
 	struct tcf_block *block;
-	struct tcf_proto *tp;
 	struct tcf_chain *chain;
 	struct tcmsg *tcm = nlmsg_data(cb->nlh);
 	unsigned long cl = 0;
 	const struct Qdisc_class_ops *cops;
-	struct tcf_dump_args arg;
+	long index_start;
+	long index;
 
 	if (nlmsg_len(cb->nlh) < sizeof(*tcm))
 		return skb->len;
@@ -677,45 +721,10 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		goto errout;
 	chain = block->chain;
 
-	s_t = cb->args[0];
-
-	for (tp = rtnl_dereference(chain->filter_chain), t = 0;
-	     tp; tp = rtnl_dereference(tp->next), t++) {
-		if (t < s_t)
-			continue;
-		if (TC_H_MAJ(tcm->tcm_info) &&
-		    TC_H_MAJ(tcm->tcm_info) != tp->prio)
-			continue;
-		if (TC_H_MIN(tcm->tcm_info) &&
-		    TC_H_MIN(tcm->tcm_info) != tp->protocol)
-			continue;
-		if (t > s_t)
-			memset(&cb->args[1], 0,
-			       sizeof(cb->args)-sizeof(cb->args[0]));
-		if (cb->args[1] == 0) {
-			if (tcf_fill_node(net, skb, tp, 0,
-					  NETLINK_CB(cb->skb).portid,
-					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					  RTM_NEWTFILTER) <= 0)
-				break;
-
-			cb->args[1] = 1;
-		}
-		if (tp->ops->walk == NULL)
-			continue;
-		arg.w.fn = tcf_node_dump;
-		arg.skb = skb;
-		arg.cb = cb;
-		arg.w.stop = 0;
-		arg.w.skip = cb->args[1] - 1;
-		arg.w.count = 0;
-		tp->ops->walk(tp, &arg.w);
-		cb->args[1] = arg.w.count + 1;
-		if (arg.w.stop)
-			break;
-	}
-
-	cb->args[0] = t;
+	index_start = cb->args[0];
+	index = 0;
+	tcf_chain_dump(chain, skb, cb, index_start, &index);
+	cb->args[0] = index;
 
 errout:
 	if (cl)
-- 
2.7.4
