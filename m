From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Thu, 22 Sep 2016 16:21:52 +0300
Message-ID: <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38294 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933453AbcIVNXl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 09:23:41 -0400
Received: by mail-wm0-f54.google.com with SMTP id l132so148292457wmf.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 06:23:40 -0700 (PDT)
In-Reply-To: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Up until now, 'action mirred' supported only egress actions (either
TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).

This patch implements the corresponding ingress actions
TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.

This allows attaching filters whose target is to hand matching skbs into
the rx processing of a specified device.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 Was wondering, whether netif_receive_skb or dev_forward_skb should be
 used for the rx bouncing. Used netif_receive_skb as in ifb device.

 net/sched/act_mirred.c | 48 ++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 42 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 28629d3..942120e 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -33,6 +33,25 @@
 static LIST_HEAD(mirred_list);
 static DEFINE_SPINLOCK(mirred_list_lock);
 
+static bool tcf_mirred_is_act_redirect(int action)
+{
+	return action == TCA_EGRESS_REDIR || action == TCA_INGRESS_REDIR;
+}
+
+static u32 tcf_mirred_act_direction(int action)
+{
+	switch (action) {
+	case TCA_EGRESS_REDIR:
+	case TCA_EGRESS_MIRROR:
+		return AT_EGRESS;
+	case TCA_INGRESS_REDIR:
+	case TCA_INGRESS_MIRROR:
+		return AT_INGRESS;
+	default:
+		BUG();
+	}
+}
+
 static void tcf_mirred_release(struct tc_action *a, int bind)
 {
 	struct tcf_mirred *m = to_mirred(a);
@@ -96,6 +115,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	switch (parm->eaction) {
 	case TCA_EGRESS_MIRROR:
 	case TCA_EGRESS_REDIR:
+	case TCA_INGRESS_REDIR:
+	case TCA_INGRESS_MIRROR:
 		break;
 	default:
 		if (exists)
@@ -157,7 +178,8 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_mirred *m = to_mirred(a);
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	int retval, err;
+	int retval, err = 0;
+	int mac_len;
 	u32 at;
 
 	tcf_lastuse_update(&m->tcf_tm);
@@ -182,23 +204,37 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	if (!skb2)
 		goto out;
 
-	if (!(at & AT_EGRESS)) {
-		if (m->tcfm_mac_header_xmit)
+	/* If action's target direction differs than filter's direction,
+	 * and devices expect a mac header on xmit, then mac push/pull is
+	 * needed.
+	 */
+	if (at != tcf_mirred_act_direction(m->tcfm_eaction) &&
+	    m->tcfm_mac_header_xmit) {
+		if (at & AT_EGRESS) {
+			/* caught at egress, act ingress: pull mac */
+			mac_len = skb_network_header(skb) - skb_mac_header(skb);
+			skb_pull_rcsum(skb2, mac_len);
+		} else {
+			/* caught at ingress, act egress: push mac */
 			skb_push_rcsum(skb2, skb->mac_len);
+		}
 	}
 
 	/* mirror is always swallowed */
-	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
+	if (tcf_mirred_is_act_redirect(m->tcfm_eaction))
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
-	err = dev_queue_xmit(skb2);
+	if (tcf_mirred_act_direction(m->tcfm_eaction) & AT_EGRESS)
+		err = dev_queue_xmit(skb2);
+	else
+		netif_receive_skb(skb2);
 
 	if (err) {
 out:
 		qstats_overlimit_inc(this_cpu_ptr(m->common.cpu_qstats));
-		if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
+		if (tcf_mirred_is_act_redirect(m->tcfm_eaction))
 			retval = TC_ACT_SHOT;
 	}
 	rcu_read_unlock();
-- 
1.9.1
