From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/25] netfilter: ipset: Fix warn: integer overflows 'sizeof(*map) + size * set->dsize'
Date: Wed, 10 Sep 2014 17:10:24 +0200
Message-ID: <1410361842-4656-8-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55815 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbaIJPKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 11:10:07 -0400
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Dan Carpenter reported that the static checker emits the warning

        net/netfilter/ipset/ip_set_list_set.c:600 init_list_set()
        warn: integer overflows 'sizeof(*map) + size * set->dsize'

Limit the maximal number of elements in list type of sets.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set_list.h |    1 +
 net/netfilter/ipset/ip_set_list_set.c       |    4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter/ipset/ip_set_list.h b/include/linux/netfilter/ipset/ip_set_list.h
index 68c2aea..fe2622a 100644
--- a/include/linux/netfilter/ipset/ip_set_list.h
+++ b/include/linux/netfilter/ipset/ip_set_list.h
@@ -6,5 +6,6 @@
 
 #define IP_SET_LIST_DEFAULT_SIZE	8
 #define IP_SET_LIST_MIN_SIZE		4
+#define IP_SET_LIST_MAX_SIZE		65536
 
 #endif /* __IP_SET_LIST_H */
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 3e2317f..f87adba 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -597,7 +597,9 @@ init_list_set(struct net *net, struct ip_set *set, u32 size)
 	struct set_elem *e;
 	u32 i;
 
-	map = kzalloc(sizeof(*map) + size * set->dsize, GFP_KERNEL);
+	map = kzalloc(sizeof(*map) +
+		      min_t(u32, size, IP_SET_LIST_MAX_SIZE) * set->dsize,
+		      GFP_KERNEL);
 	if (!map)
 		return false;
 
-- 
1.7.10.4
