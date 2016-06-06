From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] cbq: remove only caller of qdisc->drop()
Date: Mon,  6 Jun 2016 23:20:27 +0200
Message-ID: <1465248027-21652-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54037 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbcFFVUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 17:20:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since initial revision of cbq in 2004 iproute2 never implemented
support for TCA_CBQ_OVL_STRATEGY, which is what needs to be set to
activate the class->drop() call (TC_CBQ_OVL_DROP strategy must be
set by userspace).

So lets remove this.  We can even do this in a backwards compatible
way by switching ovl_drop to perform a dequeue+drop on the leaf.

A followup commit can then remove all .drop qdisc methods since this
was the only caller.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 On a related note, iproute2 doesn't support the TCA_CBQ_POLICE
 attribute either.  If we'd remove that too we could then get rid
 of __parent and reshape_fail in struct Qdisc.

 However, in TCA_CBQ_POLICE case there is no way to replace
 the functionality, i.e. we'd have to -EOPNOTSUPP or ignore
 TCA_CBQ_POLICE if some other non-iproute2 tool presents it to us.

 AFAICS TCA_CBQ_POLICE doesn't work all that well even if userspace
 would set it, one needs to:

  add a class
  attach a qdisc to the class (default pfifo doesn't work as
      q->handle is 0 and cbq_set_police() is a no-op in this case)
  re-'add' the same class (tc class change ...) again

  user must also specifiy a defmap (e.g. 'split 1:0 defmap 3f'), since
  this 'police' feature relies on its presence
  the added qdisc (or the leaves) must be one of bfifo, pfifo, tbf or
  netem as only these implement qdisc_reshape_fail() call.

  If all of these conditions are met, then instead of drop the leaf
  qdiscs mentioned above would attempt to re-enqueue the skb in the
  cbq TC_PRIO_BESTEFFORT class if their limit is reached.

  I think it would be safe to just ignore TCA_CBQ_POLICE and change the
  qdiscs to drop right away.

  Does anyone have a reason to leave this in the tree?  Thanks!

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index baafddf..df79791 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -542,9 +542,14 @@ static void cbq_ovl_lowprio(struct cbq_class *cl)
 
 static void cbq_ovl_drop(struct cbq_class *cl)
 {
-	if (cl->q->ops->drop)
-		if (cl->q->ops->drop(cl->q))
-			cl->qdisc->q.qlen--;
+	struct sk_buff *skb = cl->q->ops->dequeue(cl->q);
+
+	if (skb) {
+		cl->deficit -= qdisc_pkt_len(skb);
+		cl->qdisc->q.qlen--;
+		qdisc_drop(skb, cl->qdisc);
+	}
+
 	cl->xstats.overactions++;
 	cbq_ovl_classic(cl);
 }
-- 
2.7.3
