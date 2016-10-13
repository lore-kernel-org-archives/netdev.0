From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v4 net-next 2/4] net/sched: act_mirred: Refactor detection whether dev needs xmit at mac header
Date: Thu, 13 Oct 2016 09:06:42 +0300
Message-ID: <1476338804-25440-3-git-send-email-shmulik.ladkani@gmail.com>
References: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36203 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934267AbcJMGHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 02:07:51 -0400
Received: by mail-pf0-f193.google.com with SMTP id r16so4325229pfg.3
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 23:07:07 -0700 (PDT)
In-Reply-To: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move detection logic that tests whether device expects skb data to point
at mac_header upon xmit into a function.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/sched/act_mirred.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 16e17a8..69dcce8 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -54,6 +54,20 @@ static void tcf_mirred_release(struct tc_action *a, int bind)
 static int mirred_net_id;
 static struct tc_action_ops act_mirred_ops;
 
+static bool dev_is_mac_header_xmit(const struct net_device *dev)
+{
+	switch (dev->type) {
+	case ARPHRD_TUNNEL:
+	case ARPHRD_TUNNEL6:
+	case ARPHRD_SIT:
+	case ARPHRD_IPGRE:
+	case ARPHRD_VOID:
+	case ARPHRD_NONE:
+		return false;
+	}
+	return true;
+}
+
 static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			   struct nlattr *est, struct tc_action **a, int ovr,
 			   int bind)
@@ -96,19 +110,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
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
-			mac_header_xmit = false;
-			break;
-		default:
-			mac_header_xmit = true;
-			break;
-		}
+		mac_header_xmit = dev_is_mac_header_xmit(dev);
 	} else {
 		dev = NULL;
 	}
-- 
1.9.1
