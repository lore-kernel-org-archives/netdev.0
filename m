From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/8] ipt: use gnet_stats for action stats
Date: Wed, 3 Nov 2004 23:00:26 +0100
Message-ID: <20041103220026.GD12289@postel.suug.ch>
References: <20041103215816.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103215816.GA12289@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/ipt.c linux-2.6.10-rc1-bk11/net/sched/ipt.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/ipt.c	2004-11-02 11:59:44.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/ipt.c	2004-11-02 12:14:04.000000000 +0100
@@ -218,9 +218,8 @@
 	*/
 	p->tm.install = jiffies;
 #ifdef CONFIG_NET_ESTIMATOR
-	if (est) {
-		qdisc_new_estimator(&p->stats, p->stats_lock, est);
-	}
+	if (est)
+		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
 #endif
 	h = tcf_hash(p->index);
 	write_lock_bh(&ipt_lock);
@@ -258,8 +257,8 @@
 	spin_lock(&p->lock);
 
 	p->tm.lastuse = jiffies;
-	p->stats.bytes += skb->len;
-	p->stats.packets++;
+	p->bstats.bytes += skb->len;
+	p->bstats.packets++;
 
 	if (skb_cloned(skb) ) {
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -278,7 +277,7 @@
 		break;
 	case NF_DROP:
 		result = TC_ACT_SHOT;
-		p->stats.drops++;
+		p->qstats.drops++;
 		break;
 	case IPT_CONTINUE:
 		result = TC_ACT_PIPE;
@@ -346,17 +345,6 @@
 	return -1;
 }
 
-int
-tcf_ipt_stats(struct sk_buff *skb, struct tc_action *a)
-{
-	struct tcf_ipt *p;
-	p = PRIV(a,ipt);
-	if (NULL != p)
-		return qdisc_copy_stats(skb, &p->stats, p->stats_lock);
-
-	return 1;
-}
-
 struct tc_action_ops act_ipt_ops = {
 	.next		=	NULL,
 	.kind		=	"ipt",
@@ -364,7 +352,6 @@
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_ipt,
-	.get_stats	=	tcf_ipt_stats,
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_cleanup,
 	.lookup		=	tcf_hash_search,
