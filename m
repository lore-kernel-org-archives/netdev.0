From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/34] netfilter: ipset: Add skbinfo extension kernel support for the list set type.
Date: Mon, 29 Sep 2014 14:38:58 +0200
Message-ID: <1411994363-8451-10-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34083 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068AbaI2Mi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:28 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Danilov <littlesmilingcloud@gmail.com>

Add skbinfo extension kernel support for the list set type.
Introduce the new revision of the list set type.

Signed-off-by: Anton Danilov <littlesmilingcloud@gmail.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_list_set.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index f87adba..f8f6828 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -17,7 +17,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				1    Counters support added */
-#define IPSET_TYPE_REV_MAX	2 /* Comments support added */
+/*				2    Comments support added */
+#define IPSET_TYPE_REV_MAX	3 /* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -73,6 +74,10 @@ list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
 				ip_set_update_counter(ext_counter(e, set),
 						      ext, &opt->ext,
 						      cmdflags);
+			if (SET_WITH_SKBINFO(set))
+				ip_set_get_skbinfo(ext_skbinfo(e, set),
+						   ext, &opt->ext,
+						   cmdflags);
 			return ret;
 		}
 	}
@@ -197,6 +202,8 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 		ip_set_init_counter(ext_counter(e, set), ext);
 	if (SET_WITH_COMMENT(set))
 		ip_set_init_comment(ext_comment(e, set), ext);
+	if (SET_WITH_SKBINFO(set))
+		ip_set_init_skbinfo(ext_skbinfo(e, set), ext);
 	return 0;
 }
 
@@ -307,6 +314,8 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			ip_set_init_counter(ext_counter(e, set), ext);
 		if (SET_WITH_COMMENT(set))
 			ip_set_init_comment(ext_comment(e, set), ext);
+		if (SET_WITH_SKBINFO(set))
+			ip_set_init_skbinfo(ext_skbinfo(e, set), ext);
 		/* Set is already added to the list */
 		ip_set_put_byindex(map->net, d->id);
 		return 0;
@@ -378,7 +387,10 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -667,6 +679,9 @@ static struct ip_set_type list_set_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4
