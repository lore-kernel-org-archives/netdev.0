From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: ipset: list:set: fix reference counter update
Date: Fri, 12 Apr 2013 12:13:17 +0200
Message-ID: <1365761599-6990-3-git-send-email-pablo@netfilter.org>
References: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45019 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557Ab3DLKNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 06:13:31 -0400
In-Reply-To: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The last element can be replaced or pushed off and in both
cases the reference counter must be updated.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_list_set.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 8371c2b..09c744a 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -174,9 +174,13 @@ list_set_add(struct list_set *map, u32 i, ip_set_id_t id,
 {
 	const struct set_elem *e = list_set_elem(map, i);
 
-	if (i == map->size - 1 && e->id != IPSET_INVALID_ID)
-		/* Last element replaced: e.g. add new,before,last */
-		ip_set_put_byindex(e->id);
+	if (e->id != IPSET_INVALID_ID) {
+		const struct set_elem *x = list_set_elem(map, map->size - 1);
+
+		/* Last element replaced or pushed off */
+		if (x->id != IPSET_INVALID_ID)
+			ip_set_put_byindex(x->id);
+	}
 	if (with_timeout(map->timeout))
 		list_elem_tadd(map, i, id, ip_set_timeout_set(timeout));
 	else
-- 
1.7.10.4
