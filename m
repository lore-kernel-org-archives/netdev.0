From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/2] act_mirred: cleanup
Date: Mon, 16 Nov 2009 16:33:52 +0800
Message-ID: <412e6f7f0911160033h649b44b2o669196b8b14bf6fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:42825 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbZKPIdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 03:33:47 -0500
Received: by pzk1 with SMTP id 1so2634530pzk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 00:33:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_mirred: cleanup

1. don't let go back using goto.
2. don't call skb_act_clone() until it is necessary.
3. one exit of the critical context.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_mirred.c |   59
 +++++++++++++++++++++++++++----------------------
  1 file changed, 33 insertions(+), 26 deletions(-)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index b9aaab4..b812c20 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -148,47 +148,39 @@ static int tcf_mirred(struct sk_buff *skb,
struct tc_action *a,
 {
 	struct tcf_mirred *m = a->priv;
 	struct net_device *dev;
-	struct sk_buff *skb2 = NULL;
-	u32 at = G_TC_AT(skb->tc_verd);
+	struct sk_buff *skb2;
+	u32 at;
+	int retval, err = 1;

 	spin_lock(&m->tcf_lock);
-
-	dev = m->tcfm_dev;
 	m->tcf_tm.lastuse = jiffies;
+	if (m->tcfm_eaction != TCA_EGRESS_MIRROR &&
+	    m->tcfm_eaction != TCA_EGRESS_REDIR) {
+		if (net_ratelimit())
+			printk("tcf_mirred unknown action %d\n",
+			       m->tcfm_eaction);
+		goto out;
+	}

-	if (!(dev->flags&IFF_UP) ) {
+	dev = m->tcfm_dev;
+	if (!(dev->flags & IFF_UP)) {
 		if (net_ratelimit())
 			printk("mirred to Houston: device %s is gone!\n",
 			       dev->name);
-bad_mirred:
-		if (skb2 != NULL)
-			kfree_skb(skb2);
-		m->tcf_qstats.overlimits++;
-		m->tcf_bstats.bytes += qdisc_pkt_len(skb);
-		m->tcf_bstats.packets++;
-		spin_unlock(&m->tcf_lock);
-		/* should we be asking for packet to be dropped?
-		 * may make sense for redirect case only
-		*/
-		return TC_ACT_SHOT;
+		goto out;
 	}

 	skb2 = skb_act_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
-		goto bad_mirred;
-	if (m->tcfm_eaction != TCA_EGRESS_MIRROR &&
-	    m->tcfm_eaction != TCA_EGRESS_REDIR) {
-		if (net_ratelimit())
-			printk("tcf_mirred unknown action %d\n",
-			       m->tcfm_eaction);
-		goto bad_mirred;
-	}
+		goto out;

 	m->tcf_bstats.bytes += qdisc_pkt_len(skb2);
 	m->tcf_bstats.packets++;
-	if (!(at & AT_EGRESS))
+	at = G_TC_AT(skb->tc_verd);
+	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
 			skb_push(skb2, skb2->dev->hard_header_len);
+	}

 	/* mirror is always swallowed */
 	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
@@ -197,8 +189,23 @@ bad_mirred:
 	skb2->dev = dev;
 	skb2->iif = skb->dev->ifindex;
 	dev_queue_xmit(skb2);
+	err = 0;
+
+out:
+	if (err) {
+		m->tcf_qstats.overlimits++;
+		m->tcf_bstats.bytes += qdisc_pkt_len(skb);
+		m->tcf_bstats.packets++;
+		/* should we be asking for packet to be dropped?
+		 * may make sense for redirect case only
+		 */
+		retval = TC_ACT_SHOT;
+	} else {
+		retval = m->tcf_action;
+	}
 	spin_unlock(&m->tcf_lock);
-	return m->tcf_action;
+
+	return retval;
 }

 static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a,
int bind, int ref)
