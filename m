From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/30] act_connmark: Remember the struct net instead of guessing it.
Date: Tue, 22 Sep 2015 11:14:15 +0200
Message-ID: <1442913260-3925-26-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35166 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932862AbbIVJIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:08:00 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Stop guessing the struct net instead of remember it.  Guessing is just
silly and will be problematic in the future when I implement routes
between network namespaces.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/tc_act/tc_connmark.h |    1 +
 net/sched/act_connmark.c         |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/tc_act/tc_connmark.h b/include/net/tc_act/tc_connmark.h
index 5c1104c..02caa40 100644
--- a/include/net/tc_act/tc_connmark.h
+++ b/include/net/tc_act/tc_connmark.h
@@ -5,6 +5,7 @@
 
 struct tcf_connmark_info {
 	struct tcf_common common;
+	struct net *net;
 	u16 zone;
 };
 
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 5019a47..413ac39 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -74,7 +74,7 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	zone.id = ca->zone;
 	zone.dir = NF_CT_DEFAULT_ZONE_DIR;
 
-	thash = nf_conntrack_find_get(dev_net(skb->dev), &zone, &tuple);
+	thash = nf_conntrack_find_get(ca->net, &zone, &tuple);
 	if (!thash)
 		goto out;
 
@@ -119,6 +119,7 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 
 		ci = to_connmark(a);
 		ci->tcf_action = parm->action;
+		ci->net = net;
 		ci->zone = parm->zone;
 
 		tcf_hash_insert(a);
-- 
1.7.10.4
