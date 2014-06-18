From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/13] netfilter: ctnetlink: fix dumping of dying/unconfirmed conntracks
Date: Wed, 18 Jun 2014 11:44:28 +0200
Message-ID: <1403084679-11227-3-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41391 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965470AbaFRJov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:44:51 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dumping prematurely stops, it seems the callback argument that
indicates that all entries have been dumped is set after iterating
on the first cpu list. The dumping also may stop before the entire
per-cpu list content is also dumped.

With this patch, conntrack -L dying now shows the dying list content
again.

Fixes: b7779d06 ("netfilter: conntrack: spinlock per cpu to protect special lists.")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 5857963..ef0eedd 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1163,9 +1163,6 @@ ctnetlink_dump_list(struct sk_buff *skb, struct netlink_callback *cb, bool dying
 	if (cb->args[2])
 		return 0;
 
-	if (cb->args[0] == nr_cpu_ids)
-		return 0;
-
 	for (cpu = cb->args[0]; cpu < nr_cpu_ids; cpu++) {
 		struct ct_pcpu *pcpu;
 
@@ -1194,6 +1191,7 @@ restart:
 			rcu_read_unlock();
 			if (res < 0) {
 				nf_conntrack_get(&ct->ct_general);
+				cb->args[0] = cpu;
 				cb->args[1] = (unsigned long)ct;
 				spin_unlock_bh(&pcpu->lock);
 				goto out;
@@ -1202,10 +1200,10 @@ restart:
 		if (cb->args[1]) {
 			cb->args[1] = 0;
 			goto restart;
-		} else
-			cb->args[2] = 1;
+		}
 		spin_unlock_bh(&pcpu->lock);
 	}
+	cb->args[2] = 1;
 out:
 	if (last)
 		nf_ct_put(last);
-- 
1.7.10.4
