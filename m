From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: sched: cls_rcvp, complete rcu conversion
Date: Fri, 26 Sep 2014 10:02:50 -0700
Message-ID: <20140926170249.27131.97630.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:40348 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799AbaIZRDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 13:03:14 -0400
Received: by mail-ob0-f181.google.com with SMTP id wo20so10356013obc.40
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 10:03:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This completes the cls_rsvp conversion to RCU safe
copy, update semantics.

As a result all cases of tcf_exts_change occur on
empty lists now.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_rsvp.h |   44 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 41 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index b044c20..2512c46 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -222,6 +222,33 @@ matched:
 	return -1;
 }
 
+static void rsvp_replace(struct tcf_proto *tp, struct rsvp_filter *n, u32 h)
+{
+	struct rsvp_head *head = rtnl_dereference(tp->root);
+	struct rsvp_session *s;
+	struct rsvp_filter __rcu **ins;
+	struct rsvp_filter *pins;
+	unsigned int h1 = h & 0xFF;
+	unsigned int h2 = (h >> 8) & 0xFF;
+
+	for (s = rtnl_dereference(head->ht[h1]); s;
+	     s = rtnl_dereference(s->next)) {
+		for (ins = &s->ht[h2], pins = rtnl_dereference(*ins); ;
+		     ins = &pins->next, pins = rtnl_dereference(*ins)) {
+			if (pins->handle == h) {
+				RCU_INIT_POINTER(n->next, pins->next);
+				rcu_assign_pointer(*ins, n);
+				return;
+			}
+		}
+	}
+
+	/* Something went wrong if we are trying to replace a non-existant
+	 * node. Mind as well halt instead of silently failing.
+	 */
+	BUG_ON(1);
+}
+
 static unsigned long rsvp_get(struct tcf_proto *tp, u32 handle)
 {
 	struct rsvp_head *head = rtnl_dereference(tp->root);
@@ -454,15 +481,26 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	f = (struct rsvp_filter *)*arg;
 	if (f) {
 		/* Node exists: adjust only classid */
+		struct rsvp_filter *n;
 
 		if (f->handle != handle && handle)
 			goto errout2;
+
+		n = kmemdup(f, sizeof(*f), GFP_KERNEL);
+		if (!n) {
+			err = -ENOMEM;
+			goto errout2;
+		}
+
+		tcf_exts_init(&n->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+
 		if (tb[TCA_RSVP_CLASSID]) {
-			f->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID]);
-			tcf_bind_filter(tp, &f->res, base);
+			n->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID]);
+			tcf_bind_filter(tp, &n->res, base);
 		}
 
-		tcf_exts_change(tp, &f->exts, &e);
+		tcf_exts_change(tp, &n->exts, &e);
+		rsvp_replace(tp, n, handle);
 		return 0;
 	}
 
