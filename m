From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next] tcp: metrics: Fix rcu-race when deleting multiple entries
Date: Tue, 21 Jan 2014 13:30:26 +0100
Message-ID: <1390307426-10840-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:41906 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbaAUMab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 07:30:31 -0500
Received: by mail-wg0-f51.google.com with SMTP id z12so7799557wgg.18
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 04:30:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bbf852b96ebdc6d1 I introduced the tmlist, which allows to delete
multiple entries from the cache that match a specified destination if no
source-IP is specified.

However, as the cache is an RCU-list, we should not create this tmlist, as
it will change the tcpm_next pointer of the element that will be deleted
and so a thread iterating over the cache's entries while holding the
RCU-lock might get "redirected" to this tmlist.

This patch fixes this, by reverting back to the old behavior prior to
bbf852b96ebdc6d1, which means that we simply change the tcpm_next
pointer of the previous element (pp) to jump over the one we are
deleting.
The difference is that we call kfree_rcu() directly on the cache entry,
which allows us to delete multiple entries from the list.

Fixes: bbf852b96ebdc6d1 (tcp: metrics: Delete all entries matching a certain destination)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_metrics.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index fa950941de65..9ae48b4a37d1 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1019,13 +1019,13 @@ static int tcp_metrics_flush_all(struct net *net)
 static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 {
 	struct tcpm_hash_bucket *hb;
-	struct tcp_metrics_block *tm, *tmlist = NULL;
+	struct tcp_metrics_block *tm;
 	struct tcp_metrics_block __rcu **pp;
 	struct inetpeer_addr saddr, daddr;
 	unsigned int hash;
 	struct net *net = genl_info_net(info);
 	int ret;
-	bool src = true;
+	bool src = true, found = false;
 
 	ret = parse_nl_addr(info, &daddr, &hash, 1);
 	if (ret < 0)
@@ -1044,19 +1044,15 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		if (addr_same(&tm->tcpm_daddr, &daddr) &&
 		    (!src || addr_same(&tm->tcpm_saddr, &saddr))) {
 			*pp = tm->tcpm_next;
-			tm->tcpm_next = tmlist;
-			tmlist = tm;
+			kfree_rcu(tm, rcu_head);
+			found = true;
 		} else {
 			pp = &tm->tcpm_next;
 		}
 	}
 	spin_unlock_bh(&tcp_metrics_lock);
-	if (!tmlist)
+	if (!found)
 		return -ESRCH;
-	for (tm = tmlist; tm; tm = tmlist) {
-		tmlist = tm->tcpm_next;
-		kfree_rcu(tm, rcu_head);
-	}
 	return 0;
 }
 
-- 
1.8.3.2
