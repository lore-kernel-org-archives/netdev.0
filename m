From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 33/38] netfilter: connlimit: move insertion of new element out of count function
Date: Mon, 17 Mar 2014 13:42:53 +0100
Message-ID: <1395060178-11833-34-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59521 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933179AbaCQMns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:48 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Allows easier code-reuse in followup patches.

Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c |   38 +++++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index d4c6db1..0220d40 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -97,13 +97,12 @@ static int count_hlist(struct net *net,
 		       const struct nf_conntrack_tuple *tuple,
 		       const union nf_inet_addr *addr,
 		       const union nf_inet_addr *mask,
-		       u_int8_t family)
+		       u_int8_t family, bool *addit)
 {
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
 	struct hlist_node *n;
 	struct nf_conn *found_ct;
-	bool addit = true;
 	int matches = 0;
 
 	rcu_read_lock();
@@ -126,7 +125,7 @@ static int count_hlist(struct net *net,
 			 * We should not see tuples twice unless someone hooks
 			 * this into a table without "-p tcp --syn".
 			 */
-			addit = false;
+			*addit = false;
 		} else if (already_closed(found_ct)) {
 			/*
 			 * we do not care about connections which are
@@ -146,20 +145,22 @@ static int count_hlist(struct net *net,
 
 	rcu_read_unlock();
 
-	if (addit) {
-		/* save the new connection in our list */
-		conn = kmalloc(sizeof(*conn), GFP_ATOMIC);
-		if (conn == NULL)
-			return -ENOMEM;
-		conn->tuple = *tuple;
-		conn->addr = *addr;
-		hlist_add_head(&conn->node, head);
-		++matches;
-	}
-
 	return matches;
 }
 
+static bool add_hlist(struct hlist_head *head,
+		      const struct nf_conntrack_tuple *tuple,
+		      const union nf_inet_addr *addr)
+{
+	struct xt_connlimit_conn *conn = kmalloc(sizeof(*conn), GFP_ATOMIC);
+	if (conn == NULL)
+		return false;
+	conn->tuple = *tuple;
+	conn->addr = *addr;
+	hlist_add_head(&conn->node, head);
+	return true;
+}
+
 static int count_them(struct net *net,
 		      struct xt_connlimit_data *data,
 		      const struct nf_conntrack_tuple *tuple,
@@ -170,6 +171,7 @@ static int count_them(struct net *net,
 	struct hlist_head *hhead;
 	int count;
 	u32 hash;
+	bool addit = true;
 
 	if (family == NFPROTO_IPV6)
 		hash = connlimit_iphash6(addr, mask);
@@ -179,7 +181,13 @@ static int count_them(struct net *net,
 	hhead = &data->iphash[hash];
 
 	spin_lock_bh(&data->lock);
-	count = count_hlist(net, hhead, tuple, addr, mask, family);
+	count = count_hlist(net, hhead, tuple, addr, mask, family, &addit);
+	if (addit) {
+		if (add_hlist(hhead, tuple, addr))
+			count++;
+		else
+			count = -ENOMEM;
+	}
 	spin_unlock_bh(&data->lock);
 
 	return count;
-- 
1.7.10.4
