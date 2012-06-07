From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: neighbour: fix neigh_dump_info()
Date: Thu, 07 Jun 2012 16:58:35 +0200
Message-ID: <1339081115.5083.21.camel@edumazet-glaptop>
References: <ea0a16e085389e68b480c4b0baf05645@visp.net.lb>
	 <1339078935.5083.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55227 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab2FGO6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 10:58:41 -0400
Received: by eaak11 with SMTP id k11so267493eaa.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 07:58:40 -0700 (PDT)
In-Reply-To: <1339078935.5083.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Denys found out "ip neigh" output was truncated to
about 54 neighbours.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
---
 net/core/neighbour.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index eb09f8b..d81d026 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2219,9 +2219,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 
-	for (h = 0; h < (1 << nht->hash_shift); h++) {
-		if (h < s_h)
-			continue;
+	for (h = s_h; h < (1 << nht->hash_shift); h++) {
 		if (h > s_h)
 			s_idx = 0;
 		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
@@ -2260,9 +2258,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 
 	read_lock_bh(&tbl->lock);
 
-	for (h = 0; h <= PNEIGH_HASHMASK; h++) {
-		if (h < s_h)
-			continue;
+	for (h = s_h; h <= PNEIGH_HASHMASK; h++) {
 		if (h > s_h)
 			s_idx = 0;
 		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
@@ -2297,7 +2293,7 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 	struct neigh_table *tbl;
 	int t, family, s_t;
 	int proxy = 0;
-	int err = 0;
+	int err;
 
 	read_lock(&neigh_tbl_lock);
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
@@ -2311,7 +2307,7 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_t = cb->args[0];
 
-	for (tbl = neigh_tables, t = 0; tbl && (err >= 0);
+	for (tbl = neigh_tables, t = 0; tbl;
 	     tbl = tbl->next, t++) {
 		if (t < s_t || (family && tbl->family != family))
 			continue;
@@ -2322,6 +2318,8 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 			err = pneigh_dump_table(tbl, skb, cb);
 		else
 			err = neigh_dump_table(tbl, skb, cb);
+		if (err < 0)
+			break;
 	}
 	read_unlock(&neigh_tbl_lock);
 
