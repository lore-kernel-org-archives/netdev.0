From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH net-next 2/4] net/sched: act_mirred: Refactor detection whether dev needs xmit at mac header
Date: Thu, 22 Sep 2016 16:21:50 +0300
Message-ID: <1474550512-7552-3-git-send-email-shmulik.ladkani@gmail.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38858 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932383AbcIVNXQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 09:23:16 -0400
Received: by mail-wm0-f49.google.com with SMTP id l132so148270772wmf.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 06:23:15 -0700 (PDT)
In-Reply-To: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Move detection logic that tests whether device expects skb data to point
to mac_header upon xmit into a function.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/sched/act_mirred.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 7b03b13..28629d3 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -54,6 +54,20 @@ static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 static int mirred_net_id;
 static struct tc_action_ops act_mirred_ops;
 
+static int dev_is_mac_header_xmit(const struct net_device *dev)
+{
+	switch (dev->type) {
+	case ARPHRD_TUNNEL:
+	case ARPHRD_TUNNEL6:
+	case ARPHRD_SIT:
+	case ARPHRD_IPGRE:
+	case ARPHRD_VOID:
+	case ARPHRD_NONE:
+		return 0;
+	}
+	return 1;
+}
+
 static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			   struct nlattr *est, struct tc_action **a, int ovr,
 			   int bind)
@@ -95,19 +109,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 				tcf_hash_release(*a, bind);
 			return -ENODEV;
 		}
-		switch (dev->type) {
-		case ARPHRD_TUNNEL:
-		case ARPHRD_TUNNEL6:
-		case ARPHRD_SIT:
-		case ARPHRD_IPGRE:
-		case ARPHRD_VOID:
-		case ARPHRD_NONE:
-			mac_header_xmit = 0;
-			break;
-		default:
-			mac_header_xmit = 1;
-			break;
-		}
+		mac_header_xmit = dev_is_mac_header_xmit(dev);
 	} else {
 		dev = NULL;
 	}
-- 
1.9.1
