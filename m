From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_nat: use stack variable
Date: Wed, 30 Jun 2010 17:07:09 +0800
Message-ID: <1277888829-30230-1-git-send-email-xiaosuo@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65286 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab0F3JJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 05:09:16 -0400
Received: by pvc7 with SMTP id 7so267597pvc.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 02:09:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_nat: use stack variable

structure tc_nat isn't too big for stack, so we can put it in stack.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_nat.c |   31 ++++++++++---------------------
 1 file changed, 10 insertions(+), 21 deletions(-)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 5709494..0be49a4 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -265,40 +265,29 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_nat *p = a->priv;
-	struct tc_nat *opt;
+	struct tc_nat opt;
 	struct tcf_t t;
-	int s;
 
-	s = sizeof(*opt);
+	opt.old_addr = p->old_addr;
+	opt.new_addr = p->new_addr;
+	opt.mask = p->mask;
+	opt.flags = p->flags;
 
-	/* netlink spinlocks held above us - must use ATOMIC */
-	opt = kzalloc(s, GFP_ATOMIC);
-	if (unlikely(!opt))
-		return -ENOBUFS;
+	opt.index = p->tcf_index;
+	opt.action = p->tcf_action;
+	opt.refcnt = p->tcf_refcnt - ref;
+	opt.bindcnt = p->tcf_bindcnt - bind;
 
-	opt->old_addr = p->old_addr;
-	opt->new_addr = p->new_addr;
-	opt->mask = p->mask;
-	opt->flags = p->flags;
-
-	opt->index = p->tcf_index;
-	opt->action = p->tcf_action;
-	opt->refcnt = p->tcf_refcnt - ref;
-	opt->bindcnt = p->tcf_bindcnt - bind;
-
-	NLA_PUT(skb, TCA_NAT_PARMS, s, opt);
+	NLA_PUT(skb, TCA_NAT_PARMS, sizeof(opt), &opt);
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
 	NLA_PUT(skb, TCA_NAT_TM, sizeof(t), &t);
 
-	kfree(opt);
-
 	return skb->len;
 
 nla_put_failure:
 	nlmsg_trim(skb, b);
-	kfree(opt);
 	return -1;
 }
 
