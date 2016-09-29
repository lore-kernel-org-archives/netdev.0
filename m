From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v3 net-next 1/4] net/sched: act_mirred: Rename tcfm_ok_push to tcfm_mac_header_xmit and make it a bool
Date: Thu, 29 Sep 2016 14:03:29 +0300
Message-ID: <1475147012-15538-2-git-send-email-shmulik.ladkani@gmail.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36680 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753186AbcI2LD7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 07:03:59 -0400
Received: by mail-wm0-f67.google.com with SMTP id b184so10146799wma.3
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 04:03:58 -0700 (PDT)
In-Reply-To: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'tcfm_ok_push' specifies whether a mac_len sized push is needed upon
egress to the target device (if action is performed at ingress).

Rename it to 'tcfm_mac_header_xmit' as this is actually an attribute of
the target device (and use a bool instead of int).

This allows to decouple the attribute from the action to be taken.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 v2: declare tcfm_mac_header_xmit as bool instead of int

 include/net/tc_act/tc_mirred.h |  2 +-
 net/sched/act_mirred.c         | 11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 62770add15..95431092c4 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -8,7 +8,7 @@ struct tcf_mirred {
 	struct tc_action	common;
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
-	int			tcfm_ok_push;
+	bool			tcfm_mac_header_xmit;
 	struct net_device __rcu	*tcfm_dev;
 	struct list_head	tcfm_list;
 };
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 667dc382df..16e17a887b 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -60,11 +60,12 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 	struct nlattr *tb[TCA_MIRRED_MAX + 1];
+	bool mac_header_xmit = false;
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct net_device *dev;
-	int ret, ok_push = 0;
 	bool exists = false;
+	int ret;
 
 	if (nla == NULL)
 		return -EINVAL;
@@ -102,10 +103,10 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		case ARPHRD_IPGRE:
 		case ARPHRD_VOID:
 		case ARPHRD_NONE:
-			ok_push = 0;
+			mac_header_xmit = false;
 			break;
 		default:
-			ok_push = 1;
+			mac_header_xmit = true;
 			break;
 		}
 	} else {
@@ -136,7 +137,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			dev_put(rcu_dereference_protected(m->tcfm_dev, 1));
 		dev_hold(dev);
 		rcu_assign_pointer(m->tcfm_dev, dev);
-		m->tcfm_ok_push = ok_push;
+		m->tcfm_mac_header_xmit = mac_header_xmit;
 	}
 
 	if (ret == ACT_P_CREATED) {
@@ -181,7 +182,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		goto out;
 
 	if (!(at & AT_EGRESS)) {
-		if (m->tcfm_ok_push)
+		if (m->tcfm_mac_header_xmit)
 			skb_push_rcsum(skb2, skb->mac_len);
 	}
 
-- 
2.7.4
