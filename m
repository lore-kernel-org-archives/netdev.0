From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH net-next 2/2] net/sched: act_vlan: Introduce TCA_VLAN_ACT_MODIFY vlan action
Date: Sun, 18 Sep 2016 17:33:45 +0300
Message-ID: <1474209225-23665-3-git-send-email-shmulik.ladkani@gmail.com>
References: <1474209225-23665-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33551 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934380AbcIROeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 10:34:04 -0400
Received: by mail-wm0-f65.google.com with SMTP id w84so3851798wmg.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 07:34:03 -0700 (PDT)
In-Reply-To: <1474209225-23665-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCA_VLAN_ACT_MODIFY allows one to change an existing tag.

It accepts same attributes as TCA_VLAN_ACT_PUSH (protocol, id,
priority).
If packet is vlan tagged, then the tag gets overwritten according to
user specified attributes.

For example, this allows user to replace a tag's vid while preserving
its priority bits (as opposed to "action vlan pop pipe action vlan push").

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 include/uapi/linux/tc_act/tc_vlan.h |  1 +
 net/sched/act_vlan.c                | 29 ++++++++++++++++++++++++++++-
 2 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tc_act/tc_vlan.h b/include/uapi/linux/tc_act/tc_vlan.h
index be72b6e384..bddb272b84 100644
--- a/include/uapi/linux/tc_act/tc_vlan.h
+++ b/include/uapi/linux/tc_act/tc_vlan.h
@@ -16,6 +16,7 @@
 
 #define TCA_VLAN_ACT_POP	1
 #define TCA_VLAN_ACT_PUSH	2
+#define TCA_VLAN_ACT_MODIFY	3
 
 struct tc_vlan {
 	tc_gen;
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 59a8d3150a..e5eeaa7a01 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -30,6 +30,7 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_vlan *v = to_vlan(a);
 	int action;
 	int err;
+	u16 tci;
 
 	spin_lock(&v->tcf_lock);
 	tcf_lastuse_update(&v->tcf_tm);
@@ -48,6 +49,30 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 		if (err)
 			goto drop;
 		break;
+	case TCA_VLAN_ACT_MODIFY:
+		if (!skb_vlan_tagged(skb))
+			goto unlock;
+		/* extract existing tag (and guarantee no hwaccel tag) */
+		if (skb_vlan_tag_present(skb)) {
+			tci = skb_vlan_tag_get(skb);
+			skb->vlan_tci = 0;
+		} else {
+			if (skb->mac_len < VLAN_ETH_HLEN)
+				goto unlock;
+			err = __skb_vlan_pop(skb, &tci);
+			if (err)
+				goto drop;
+		}
+		/* replace the vid */
+		tci = (tci & ~VLAN_VID_MASK) | v->tcfv_push_vid;
+		/* replace prio bits, if tcfv_push_prio specified */
+		if (v->tcfv_push_prio) {
+			tci &= ~VLAN_PRIO_MASK;
+			tci |= v->tcfv_push_prio << VLAN_PRIO_SHIFT;
+		}
+		/* put updated tci as hwaccel tag */
+		__vlan_hwaccel_put_tag(skb, v->tcfv_push_proto, tci);
+		break;
 	default:
 		BUG();
 	}
@@ -102,6 +127,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	case TCA_VLAN_ACT_POP:
 		break;
 	case TCA_VLAN_ACT_PUSH:
+	case TCA_VLAN_ACT_MODIFY:
 		if (!tb[TCA_VLAN_PUSH_VLAN_ID]) {
 			if (exists)
 				tcf_hash_release(*a, bind);
@@ -185,7 +211,8 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 	if (nla_put(skb, TCA_VLAN_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 
-	if (v->tcfv_action == TCA_VLAN_ACT_PUSH &&
+	if ((v->tcfv_action == TCA_VLAN_ACT_PUSH ||
+	     v->tcfv_action == TCA_VLAN_ACT_MODIFY) &&
 	    (nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) ||
 	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL,
 			  v->tcfv_push_proto) ||
-- 
2.7.4
