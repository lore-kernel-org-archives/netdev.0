From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 4/4] net_sched: act_vlan: Add priority option
Date: Wed, 10 Aug 2016 16:32:23 +0300
Message-ID: <1470835943-9042-5-git-send-email-hadarh@mellanox.com>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45349 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933600AbcHJT17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:27:59 -0400
In-Reply-To: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current vlan push action supports only vid and protocol options.
Add priority option.

Example script that adds vlan push action with vid and
priority:

tc filter add dev veth0 protocol ip parent ffff: \
	   flower \
	   	indev veth0 \
	   action vlan push id 100 priority 5

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 include/net/tc_act/tc_vlan.h        |  1 +
 include/uapi/linux/tc_act/tc_vlan.h |  1 +
 net/sched/act_vlan.c                | 13 +++++++++++--
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
index e29f52e..6b83588 100644
--- a/include/net/tc_act/tc_vlan.h
+++ b/include/net/tc_act/tc_vlan.h
@@ -20,6 +20,7 @@ struct tcf_vlan {
 	int			tcfv_action;
 	u16			tcfv_push_vid;
 	__be16			tcfv_push_proto;
+	u8			tcfv_push_prio;
 };
 #define to_vlan(a) ((struct tcf_vlan *)a)
 
diff --git a/include/uapi/linux/tc_act/tc_vlan.h b/include/uapi/linux/tc_act/tc_vlan.h
index 31151ff62..be72b6e 100644
--- a/include/uapi/linux/tc_act/tc_vlan.h
+++ b/include/uapi/linux/tc_act/tc_vlan.h
@@ -29,6 +29,7 @@ enum {
 	TCA_VLAN_PUSH_VLAN_ID,
 	TCA_VLAN_PUSH_VLAN_PROTOCOL,
 	TCA_VLAN_PAD,
+	TCA_VLAN_PUSH_VLAN_PRIORITY,
 	__TCA_VLAN_MAX,
 };
 #define TCA_VLAN_MAX (__TCA_VLAN_MAX - 1)
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 691409d..d2fcf7cd 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -43,7 +43,8 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 			goto drop;
 		break;
 	case TCA_VLAN_ACT_PUSH:
-		err = skb_vlan_push(skb, v->tcfv_push_proto, v->tcfv_push_vid);
+		err = skb_vlan_push(skb, v->tcfv_push_proto, v->tcfv_push_vid |
+				    (v->tcfv_push_prio << VLAN_PRIO_SHIFT));
 		if (err)
 			goto drop;
 		break;
@@ -65,6 +66,7 @@ static const struct nla_policy vlan_policy[TCA_VLAN_MAX + 1] = {
 	[TCA_VLAN_PARMS]		= { .len = sizeof(struct tc_vlan) },
 	[TCA_VLAN_PUSH_VLAN_ID]		= { .type = NLA_U16 },
 	[TCA_VLAN_PUSH_VLAN_PROTOCOL]	= { .type = NLA_U16 },
+	[TCA_VLAN_PUSH_VLAN_PRIORITY]	= { .type = NLA_U8 },
 };
 
 static int tcf_vlan_init(struct net *net, struct nlattr *nla,
@@ -78,6 +80,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	int action;
 	__be16 push_vid = 0;
 	__be16 push_proto = 0;
+	u8 push_prio = 0;
 	bool exists = false;
 	int ret = 0, err;
 
@@ -123,6 +126,9 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 		} else {
 			push_proto = htons(ETH_P_8021Q);
 		}
+
+		if (tb[TCA_VLAN_PUSH_VLAN_PRIORITY])
+			push_prio = nla_get_u8(tb[TCA_VLAN_PUSH_VLAN_PRIORITY]);
 		break;
 	default:
 		if (exists)
@@ -150,6 +156,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 
 	v->tcfv_action = action;
 	v->tcfv_push_vid = push_vid;
+	v->tcfv_push_prio = push_prio;
 	v->tcfv_push_proto = push_proto;
 
 	v->tcf_action = parm->action;
@@ -181,7 +188,9 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 	if (v->tcfv_action == TCA_VLAN_ACT_PUSH &&
 	    (nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) ||
 	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL,
-			  v->tcfv_push_proto)))
+			  v->tcfv_push_proto) ||
+	     (v->tcfv_push_prio && nla_put_u8(skb, TCA_VLAN_PUSH_VLAN_PRIORITY,
+					      v->tcfv_push_prio))))
 		goto nla_put_failure;
 
 	tcf_tm_dump(&t, &v->tcf_tm);
-- 
1.8.3.1
