From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 17:53:29 +0800
Message-ID: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:49907 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbZKPJxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 04:53:24 -0500
Received: by pwi3 with SMTP id 3so3169785pwi.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 01:53:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_mirred: optimization.

move checking if eaction is valid in tcf_mirred_init()

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
----
 net/sched/act_mirred.c |   60
 +++++++++++++++++++++++--------------------------
  1 file changed, 29 insertions(+), 31 deletions(-)
--- a/net/sched/act_mirred.c	2009-11-16 16:21:21.000000000 +0800
+++ b/net/sched/act_mirred.c	2009-11-16 17:43:37.000000000 +0800
@@ -65,48 +65,53 @@
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
+		break;
+	default:
+		return -EINVAL;
+	}
 	if (parm->ifindex) {
 		dev = __dev_get_by_index(&init_net, parm->ifindex);
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
 		if (IS_ERR(pc))
-		    return PTR_ERR(pc);
+			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
@@ -119,12 +124,12 @@
 	spin_lock_bh(&m->tcf_lock);
 	m->tcf_action = parm->action;
 	m->tcfm_eaction = parm->eaction;
-	if (parm->ifindex) {
+	if (dev != NULL) {
 		m->tcfm_ifindex = parm->ifindex;
 		if (ret != ACT_P_CREATED)
 			dev_put(m->tcfm_dev);
-		m->tcfm_dev = dev;
 		dev_hold(dev);
+		m->tcfm_dev = dev;
 		m->tcfm_ok_push = ok_push;
 	}
 	spin_unlock_bh(&m->tcf_lock);
@@ -154,13 +159,6 @@

 	spin_lock(&m->tcf_lock);
 	m->tcf_tm.lastuse = jiffies;
-	if (m->tcfm_eaction != TCA_EGRESS_MIRROR &&
-	    m->tcfm_eaction != TCA_EGRESS_REDIR) {
-		if (net_ratelimit())
-			printk("tcf_mirred unknown action %d\n",
-			       m->tcfm_eaction);
-		goto out;
-	}

 	dev = m->tcfm_dev;
 	if (!(dev->flags & IFF_UP)) {
