From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Thu, 29 Sep 2016 14:03:32 +0300
Message-ID: <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35919 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753162AbcI2LET (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 07:04:19 -0400
Received: by mail-wm0-f66.google.com with SMTP id b184so10148536wma.3
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 04:04:18 -0700 (PDT)
In-Reply-To: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Up until now, 'action mirred' supported only egress actions (either
TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).

This patch implements the corresponding ingress actions
TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.

This allows attaching filters whose target is to hand matching skbs into
the rx processing of a specified device.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 v3: Addressed non coherency due to reading m->tcfm_eaction multiple times,
     as spotted by Eric Dumazet

 net/sched/act_mirred.c | 51 ++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 45 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 69dcce8c75..22dcfd68e6 100644
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
@@ -97,6 +116,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	switch (parm->eaction) {
 	case TCA_EGRESS_MIRROR:
 	case TCA_EGRESS_REDIR:
+	case TCA_INGRESS_REDIR:
+	case TCA_INGRESS_MIRROR:
 		break;
 	default:
 		if (exists)
@@ -156,15 +177,20 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		      struct tcf_result *res)
 {
 	struct tcf_mirred *m = to_mirred(a);
+	bool m_mac_header_xmit;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	int retval, err;
+	int retval, err = 0;
+	int m_eaction;
+	int mac_len;
 	u32 at;
 
 	tcf_lastuse_update(&m->tcf_tm);
 	bstats_cpu_update(this_cpu_ptr(m->common.cpu_bstats), skb);
 
 	rcu_read_lock();
+	m_mac_header_xmit = READ_ONCE(m->tcfm_mac_header_xmit);
+	m_eaction = READ_ONCE(m->tcfm_eaction);
 	retval = READ_ONCE(m->tcf_action);
 	dev = rcu_dereference(m->tcfm_dev);
 	if (unlikely(!dev)) {
@@ -183,23 +209,36 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	if (!skb2)
 		goto out;
 
-	if (!(at & AT_EGRESS)) {
-		if (m->tcfm_mac_header_xmit)
+	/* If action's target direction differs than filter's direction,
+	 * and devices expect a mac header on xmit, then mac push/pull is
+	 * needed.
+	 */
+	if (at != tcf_mirred_act_direction(m_eaction) && m_mac_header_xmit) {
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
+	if (tcf_mirred_is_act_redirect(m_eaction))
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
-	err = dev_queue_xmit(skb2);
+	if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
+		err = dev_queue_xmit(skb2);
+	else
+		netif_receive_skb(skb2);
 
 	if (err) {
 out:
 		qstats_overlimit_inc(this_cpu_ptr(m->common.cpu_qstats));
-		if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
+		if (tcf_mirred_is_act_redirect(m_eaction))
 			retval = TC_ACT_SHOT;
 	}
 	rcu_read_unlock();
-- 
2.7.4
