From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_mirred: cleanup and optimization
Date: Fri, 13 Nov 2009 13:36:43 +0800
Message-ID: <4AFCF06B.1090602@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	xiaosuo <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:41767 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbZKMFgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 00:36:46 -0500
Received: by pzk1 with SMTP id 1so1066179pzk.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 21:36:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_mirred: cleanup and optimization.

cleanup and optimization.
1. don't let go back using goto.
2. move checking if eaction is valid in tcf_mirred_init().
3. don't call skb_act_clone() until it is necessary.
4. one exit of the critical context.
5. allow eaction is TCA_INGRESS_MIRROR & TCA_INGRESS_REDIR.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/sched/act_mirred.c | 121
++++++++++++++++++++++++++-----------------------
1 file changed, 65 insertions(+), 56 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index b9aaab4..1e8b042 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -8,8 +8,6 @@
  *
  * Authors:	Jamal Hadi Salim (2002-4)
  *
- * TODO: Add ingress support (and socket redirect support)
- *
  */
 
 #include <linux/types.h>
@@ -65,52 +63,63 @@ static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct tcf_common *pc;
-	struct net_device *dev = NULL;
-	int ret = 0, err;
-	int ok_push = 0;
+	struct net_device *dev;
+	int ret, ok_push = 0;
 
 	if (nla == NULL)
 		return -EINVAL;
-
-	err = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, mirred_policy);
-	if (err < 0)
-		return err;
-
+	ret = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, mirred_policy);
+	if (ret < 0)
+		return ret;
 	if (tb[TCA_MIRRED_PARMS] == NULL)
 		return -EINVAL;
 	parm = nla_data(tb[TCA_MIRRED_PARMS]);
-
+	switch (parm->eaction) {
+	case TCA_EGRESS_MIRROR:
+	case TCA_EGRESS_REDIR:
+	case TCA_INGRESS_MIRROR:
+	case TCA_INGRESS_REDIR:
+		break;
+	default:
+		return -EINVAL;
+	}
 	if (parm->ifindex) {
-		dev = __dev_get_by_index(&init_net, parm->ifindex);
+		dev = dev_get_by_index(&init_net, parm->ifindex);
 		if (dev == NULL)
 			return -ENODEV;
 		switch (dev->type) {
-			case ARPHRD_TUNNEL:
-			case ARPHRD_TUNNEL6:
-			case ARPHRD_SIT:
-			case ARPHRD_IPGRE:
-			case ARPHRD_VOID:
-			case ARPHRD_NONE:
-				ok_push = 0;
-				break;
-			default:
-				ok_push = 1;
-				break;
+		case ARPHRD_TUNNEL:
+		case ARPHRD_TUNNEL6:
+		case ARPHRD_SIT:
+		case ARPHRD_IPGRE:
+		case ARPHRD_VOID:
+		case ARPHRD_NONE:
+			ok_push = 0;
+			break;
+		default:
+			ok_push = 1;
+			break;
 		}
+	} else {
+		dev = NULL;
 	}
 
 	pc = tcf_hash_check(parm->index, a, bind, &mirred_hash_info);
 	if (!pc) {
-		if (!parm->ifindex)
+		if (dev == NULL)
 			return -EINVAL;
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind,
 				     &mirred_idx_gen, &mirred_hash_info);
-		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+		if (IS_ERR(pc)) {
+			dev_put(dev);
+			return PTR_ERR(pc);
+		}
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
 			tcf_mirred_release(to_mirred(pc), bind);
+			if (dev != NULL)
+				dev_put(dev);
 			return -EEXIST;
 		}
 	}
@@ -119,12 +128,11 @@ static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 	spin_lock_bh(&m->tcf_lock);
 	m->tcf_action = parm->action;
 	m->tcfm_eaction = parm->eaction;
-	if (parm->ifindex) {
+	if (dev != NULL) {
 		m->tcfm_ifindex = parm->ifindex;
 		if (ret != ACT_P_CREATED)
 			dev_put(m->tcfm_dev);
 		m->tcfm_dev = dev;
-		dev_hold(dev);
 		m->tcfm_ok_push = ok_push;
 	}
 	spin_unlock_bh(&m->tcf_lock);
@@ -146,59 +154,60 @@ static int tcf_mirred_cleanup(struct tc_action *a, int bind)
 static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 		      struct tcf_result *res)
 {
-	struct tcf_mirred *m = a->priv;
 	struct net_device *dev;
-	struct sk_buff *skb2 = NULL;
-	u32 at = G_TC_AT(skb->tc_verd);
+	struct sk_buff *skb2;
+	u32 at;
+	struct tcf_mirred *m = a->priv;
+	int retval, err = 1;
 
 	spin_lock(&m->tcf_lock);
-
-	dev = m->tcfm_dev;
 	m->tcf_tm.lastuse = jiffies;
 
-	if (!(dev->flags&IFF_UP) ) {
+	dev = m->tcfm_dev;
+	if (!(dev->flags & IFF_UP) ) {
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
-	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
+	if (m->tcfm_eaction != TCA_EGRESS_MIRROR &&
+	    m->tcfm_eaction != TCA_INGRESS_MIRROR)
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
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
 
 static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)


